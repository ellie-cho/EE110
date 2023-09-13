;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																			 ;
;                                  sysinit.s                                 ;
;                                     HW2                                    ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program calls system initialization functions of the
;					keypad, including giving power to peripherals and the
;					clocks.
;
; Input:            Switches.
; Output:           None.
;
; User Interface:   No real user interface.  The program fills a buffer with
;                   data based on the switches pressed by the user.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
;
; Revision History:
;    11/9/21	Ellie Cho	Initial revision
;	 11/13/21	Ellie Cho	set up stack
;	 11/15/21	Ellie Cho	set up initial test function
;    11/17/21   Ellie Cho	tried to fix bugs
;	 11/20/21	Ellie Cho	changed test function to simple infinite loop
;	 11/27/21	Ellie Cho	fixed some bugs
;	 11/29/21	Ellie Cho	code works now


	.include keypad_symbols.inc
	.def SystemInitialization
	.ref ScanDebounce
SystemInitialization:
; MoveVectorTable:
; Description: this function moves the interrupt vector table from its current
; location to SRAM at the location VecTable.
EnableKeypadClock:
	MOVW	R0, #PRCM_Low
	MOVT	R0, #PRCM_High
	MOVW	R1, #GPT0En
	STR		R1, [R0, #GPTCLKGR]
	STR		R1, [R0, #GPTCLKGS]
	STR		R1, [R0, #GPTCLKGDS]
	STR		R1, [R0, #CLKLOADCTL] ;also store to CLKLOADCTL

WaitUntilGPT0En:	;waits until GPTO clock is enabled
	LDR		R1, [R0, #CLKLOADCTL] ;look at CLKLOADCTL
	CMP     R1, #0x2
	BNE		WaitUntilClock


EnablePowerToPeripherals:	;enables the power to peripherals
	MOVW	R0, #PRCM_Low	;go to PRCM base address
	MOVT	R0, #PRCM_High
	MOVW    R1, #PERIPH_ON	;load constant that would turn peripheral on
	STR		R1, [R0, #PDCTL0];store that constant into PDCTL0 reg
WaitUntilPeripheralPower:
	LDR		R2, [R0, #PDSTAT0PERIPH];read status of peripheral power
	CMP		R2, #0x1	;compare to "high"
	BNE		WaitUntilPeripheralPower;if not high, wait until it is turned on

EnableGPIOClock:	;enable gpio clock
	MOVW	R1, #0x0001		;move "high" value to R1
	STR		R1, [R0, #GPIOCLKGR] ;store "high" to GPIOCLKGR reg
	STR		R1, [R0, #CLKLOADCTL]; also store to CLKLOADCTL reg
WaitUntilClock:	;waits until GPIO clock is enabled
	LDR		R1, [R0, #CLKLOADCTL] ;look at CLKLOADCTL
	CMP     R1, #0x2
	BNE		WaitUntilClock
	BX		LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                     HW1                                    ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the code for HW #1.
;
;
; Revision History:
;    10/23/21  Ellie Cho               initial revision
;	 10/29/21  Ellie Cho			   defined some functions and variables
									  ;set up ports

;	 10/31/21  Ellie Cho			  ;tried to fix some bugs
;	 11/2/21   Ellie Cho		      ;added functions related to peripheral
									  ;and gpioclk
;	 11/3/21   Ellie Cho			  ;fixed bugs; code is now working

; local include files
	.include "symbols.inc"


; Description: This program turns on the red LED of the Launchpad when the left
; switch is pressed and the green LED when the right switch is pressed. The red
; LED is connected to DIO6, the green LED is connected to DIO7, the left switch
; is connected to DIO13, and the right switch is connected to DIO14.



MV32 .macro	R, IN
	MOV		R, IN & 0xFFFF
	MOVT 	R, IN >> 16
	.endm


;executable code starts here
	.text

;setup the reset vector
	.global ResetISR ;this is the entry point

ResetISR:

main:




EnablePowerToPeripherals:	;enables the power to peripherals
	MOVW	R0, #PRCM_Low	;go to PRCM base address
	MOVT	R0, #PRCM_High
	MOVW    R1, #PERIPH_ON	;load constant that would turn peripheral on
	STR		R1, [R0, #PDCTL0];store that constant into PDCTL0 reg
WaitUntilPeripheralPower:
	LDR		R2, [R0, #PDSTAT0PERIPH];read status of peripheral power
	CMP		R2, #0x1	;compare to "high"
	BNE		WaitUntilPeripheralPower	;if not high, wait until it is turned on

EnableGPIOClock:	;enable gpio clock
	MOVW	R1, #0x0001		;move "high" value to R1
	STR		R1, [R0, #GPIOCLKGR] ;store "high" to GPIOCLKGR reg
	STR		R1, [R0, #CLKLOADCTL]; also store to CLKLOADCTL reg
WaitUntilClock:	;waits until GPIO clock is enabled
	LDR		R1, [R0, #CLKLOADCTL] ;look at CLKLOADCTL
	CMP     R1, #0x2
	BNE		WaitUntilClock

SetPorts:	;set LEDs as outputs and switches as inputs
;get GPIO base address
	MOVW 	R1, #GPIOBaseAddress_Low
	MOVT	R1, #GPIOBaseAddress_High
;move 0 into R2
	MOVW 	R2, #OESettings
	STR 	R2, [R1, #DOE31_0]
;pull up resistors and input settings to switch pins, output settings to LED pins
	MOVW	R7, #IOCBaseAddress_Low
	MOVT	R7, #IOCBaseAddress_High
	MOVW	R3, #PullUpInputSettings_Low
	MOVT	R3, #PullUpInputSettings_High
	MOVW	R4, #OutputSettings
	STR		R4, [R7, #IOCFG6]
	STR		R4, [R7, #IOCFG7]
	STR		R3, [R7, #IOCFG13]
	STR		R3, [R7, #IOCFG14]

CheckLeftSwitch:;checks if left switch is on or off
	MOVW 	R1, #GPIOBaseAddress_Low
	MOVT	R1, #GPIOBaseAddress_High
	LDR		R2, [R1, #DIN31_0]
	;mask all values but the DIO13 bit
	AND		R4, R2, #DIO13_OFF
	;compare to "left switch off"
	CMP 	R4, #DIO13_OFF
	BNE 	TurnRedLEDOn ;this should see if the switch is off and if it is not, go to "turn on" function
	NOP

TurnRedLEDOff:;turns red LED off
	MOVW 	R1, #GPIOBaseAddress_Low	;load GPIO base address
	MOVT	R1, #GPIOBaseAddress_High
	LDR		R2, [R1, #DOUT4_7]	;read in output pin states
	MOVW	R3, #DIO6_OFF_MASK_LOW	;load mask for dio6
	MOVT	R3, #DIO6_OFF_MASK_HIGH
	AND		R4, R3, R2	;this turns off the dio6 pin
	STR 	R4, [R1, #DOUT4_7]	;store to dout7..4
	B		CheckRightSwitch	;now move to right switch
	NOP


TurnRedLEDOn: ;turns red LED on
	MOVW 	R1, #GPIOBaseAddress_Low	;load GPIO base address
	MOVT	R1, #GPIOBaseAddress_High
	MOVW 	R2, #DIO6_ON_LOW	;load constant for DIO6 on
	MOVT	R2, #DIO6_ON_HIGH
	LDR		R3, [R1, #DOUT4_7]	;read in current output pins
	ORR		R5, R2, R3		    ;or with constant for DIO6 on
	STR 	R5, [R1, #DOUT4_7]  ;store in output pins (this turns red LED on)

CheckRightSwitch:;checks if the right switch is on or off
	MOVW 	R1, #GPIOBaseAddress_Low ;load in GPIO base address
	MOVT	R1, #GPIOBaseAddress_High
	LDR		R2, [R1, #DIN31_0]	;read input pins
	;mask all values but the DIO14 bit
	AND		R4, R2, #DIO14_OFF
	;compare to "right switch off"
	CMP 	R4, #DIO14_OFF
	BNE 	TurnGreenLEDOn ;this should see if the switch is off and if it is not, go to "turn on" function
	NOP

TurnGreenLEDOff: ;turns green LED off
	MOVW 	R1, #GPIOBaseAddress_Low ;load in GPIO base address
	MOVT	R1, #GPIOBaseAddress_High
	LDR		R2, [R1, #DOUT4_7] ;load in output pins
	MOVW	R3, #0xFFFF		;load in constant for turning the green LED off
	MOVT	R3, #0xFEFF		;this is a "masking" procedure
	AND		R4, R3, R2		;only change that pin
	STR 	R4, [R1, #DOUT4_7] ;store into outputs, turning green LED off
	B		LoopBack
	NOP
TurnGreenLEDOn: ;turns green LED on
	MOVW 	R1, #GPIOBaseAddress_Low  ;load in GPIO base address
	MOVT	R1, #GPIOBaseAddress_High
	MOVW 	R2, #DIO7_ON_LOW ;read in value for turning green LED on
	MOVT	R2, #DIO7_ON_HIGH
	LDR		R3, [R1, #DOUT4_7] ;load in current LED states
	ORR		R5, R2, R3		;use "or" to only change that bit
	STR 	R5, [R1, #DOUT4_7]	;store into LED state --> turns green LED on

LoopBack:
	B	CheckLeftSwitch ;loops back to checking left switch
	NOP


;data segment (not used)
	.data


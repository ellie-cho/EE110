;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the hardware functions for the
;				    LCD, including the initialization function for the
;					shared variables and the event handler.
;
; Functions:
;	InitLCD()
;	LowestLevelWR(RS)
;	LowestLevelRD(RS)
;	Display(r, c, str)
;	DisplayChar(r, c, ch)
;
; Revision History:
;    2/28/2022	Ellie Cho	initial revision
;	 3/5/2022	Ellie Cho	added initLCD
;	 3/7/2022	Ellie Cho	added lowest_level_WR
;	 3/9/2022	Ellie Cho	added lowest_level_RD

	.include "lcd_symbols.inc"
	.include "macros.inc"
	.def Lowest_Level_WR
	.def Lowest_Level_RD
	.def DisplayChar
	.def InitLCD
	.ref InitTimer
	.ref InitPorts

;Lowest_Level_WR(RS, data):
;The lowest level write function is called whenever the LCD is written to
;RS is in R0
;data is in R8
Lowest_Level_WR:
	;change pins to outputs
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR		R2, [R1, #DOE31_0]
	MOVW	R4, #WR_OE_Settings
	ORN		R3, R2, R4
	STR		R3, [R1, #DOE31_0]
;check if timer has expired
;	if not, wait until timer expires
CheckTimerExpired:
	;When the timer expires, the timer enable in the CTL register is low
	MOVW	R1, #GPT1BaseAddressLow
	MOVT	R1, #GPT1BaseAddressHigh
	LDR		R2, [R1, #CTL_Offset]
	AND		R3, R2, #TimerEnOn
	CMP		R3, #TimerEnOn
	BNE		CheckTimerExpired
	;BEQ	OutputRSRW
OutputRSRW:
;output RS, R/W = 0
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR 	R2, [R1, #DOUT31_0]
	MV32	R9, #RS_LOW
	AND		R3, R2, R9
	MV32	R9, #RW_LOW
	AND		R4, R3, R9
	STR		R4, [R1, #DOUT31_0]
;wait t_AS - through a loop (48MHz clock)
Wait_t_AS: ;wait t_AS, which is the set up time for RS, R/W, and E
		   ;t_AS = 140ns. With a 48MHz clock, need to wait 9.12
		   ;times -> 10 times
	MOV		R1, #0 ;start count at 0
Wait_t_AS_Loop:
	ADD		R1, R1, #1 ;increment until R1 = 10
	CMP		R1, #10
	BNE		Wait_t_AS_Loop
	;BEQ	OutputEHigh
OutputEHigh:
;output E to high
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR 	R2, [R1, #DOUT31_0]
	AND		R3, R2, #E_HIGH
	STR		R3, [R1, #DOUT31_0]
TimerStart:
;start a timer that expires at tcycle
;turn the timer enable on
	MOVW	R1, #GPT1BaseAddressLow
	MOVT	R1, #GPT1BaseAddressHigh
	LDR		R2, [R1, #CTL_Offset]
	ORN		R3, R2, #TimerEnOn
	STR		R3, [R1, #CTL_Offset]
PutData:
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR		R2, [R1, #DOUT31_0]
	ORN		R3, R2, R8
	STR		R3, [R1, #DOUT31_0]
;wait PW_EH
Wait_PW_EH: ;PW_EH = 450ns = 22 wait cycles
	MOV		R4, #22
Wait_PW_EH_Loop:
	SUB		R4, R4, #1
	CMP		R4, #0
	BNE		Wait_PW_EH_Loop
	;BEQ	OutputELow
OutputELow:
;output enable low
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR		R2, [R1, #DOUT31_0]
	MV32	R4, #E_LOW
	AND		R3, R2, R4
	STR		R3, [R1, #DOUT31_0]
	BX		LR






Lowest_Level_RD:
;change pins to inputs
PinsToInputs:
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR		R2, [R1, #DOE31_0]
	ORN		R3, R2, #RD_OE_Settings
	STR		R3, [R1, #DOE31_0]

;Check if timer has expired. If not, wait until timer expires.
CheckIfTimerExpired:
	;When the timer expires, the timer enable in the CTL register is low
	MOVW	R1, #GPT1BaseAddressLow
	MOVT	R1, #GPT1BaseAddressHigh
	LDR		R2, [R1, #CTL_Offset]
	AND		R3, R2, #TimerEnOn
	CMP		R3, #TimerEnOn
	BNE		CheckIfTimerExpired
	;BEQ	OutputRS
OutputRS:
;output RS, R/W = 1
;RS is in R0
	LDR 	R2, [R1, #DOUT31_0]
	AND		R3, R2, R0
	MV32	R9, #RW_LOW
	AND		R4, R3, R9
	STR		R4, [R1, #DOUT31_0]
;wait t_AS
Wait_t_AS_RD: ;wait t_AS, which is the set up time for RS, R/W, and E
		   ;t_AS = 140ns. With a 48MHz clock, need to wait 9.12
		   ;times -> 10 times
	MOV		R1, #10 ;start count at 0
Wait_t_AS_Loop_RD:
	SUB		R1, R1, #1 ;decrement until R1 = 0
	CMP		R1, #0
	BNE		Wait_t_AS_Loop_RD
	;BEQ	PutEnableHigh
;output E to high
PutEnableHigh:
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR 	R2, [R1, #DOUT31_0]
	AND		R3, R2, #E_HIGH
	STR		R3, [R1, #DOUT31_0]
;start a timer that expires at t_cycle
StartTimer:
;turn the timer enable on
	MOVW	R1, #GPT1BaseAddressLow
	MOVT	R1, #GPT1BaseAddressHigh
	LDR		R2, [R1, #CTL_Offset]
	ORN		R3, R2, #TimerEnOn
	STR		R3, [R1, #CTL_Offset]
;wait t_DDR
t_DDR_Wait: ;t_DDR = 320ns = 15.36 cycles -> 16 cycles
	MOV		R1, #10 ;start count at 0
t_DDR_Wait_Loop:
	SUB		R1, R1, #1 ;decrement until R1 = 0
	CMP		R1, #0
	BNE		t_DDR_Wait
	;BEQ	ReadBits
ReadBits:
;read DB7..DB0
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR 	R2, [R1, #DOUT31_0]
	AND		R0, R2, #ReadMask ;only care about lowest 8 bits
	;returns the read value in R0
Wait_PW_EH_t_DDR:
;wait PW_EH - t_DDR = 450-140ns = 310ns = 15 cycles
	MOV		R1, #15
Wait_PW_EH_t_DDR_Loop:
	SUB		R1, R1, #1 ;decrement
	CMP		R1, #0
	BNE		Wait_PW_EH_t_DDR_Loop
	;BEQ	OutputEnableLow
OutputEnableLow:
;output enable low
	MOVW	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
	LDR		R2, [R1, #DOUT31_0]
	MV32	R4, #E_LOW
	AND		R3, R2, R4
	STR		R3, [R1, #DOUT31_0]
	BX		LR



;InitLCD()
;Description:
;The function is called at the beginning and initializes the LCD.
;(This is the 8-bit initialization from the handout.)
InitLCD:
;Turn on peripheral power
EnablePowerToPeripherals:	;enables the power to peripherals
	MOVW	R0, #PRCM_Low	;go to PRCM base address
	MOVT	R0, #PRCM_High
	MOVW    R1, #PERIPH_ON	;load constant that would turn peripheral on
	STR		R1, [R0, #PDCTL0];store that constant into PDCTL0 reg
WaitUntilPeripheralPower:
	LDR		R2, [R0, #PDSTAT0PERIPH];read status of peripheral power
	CMP		R2, #0x1	;compare to "high"
	BNE		WaitUntilPeripheralPower	;if not high, wait until it is turned on
;Wait 15ms after power is on
Wait15ms:
	MV32	R0, #720000
WaitLoop15ms:
	SUB		R0, R0, #1
	CMP		R0, #0	;number for 15ms
	BNE		WaitLoop15ms
	;BEQ	FunctionSetCommand
FunctionSetCommand: ;Do Function Set Command for 8-bit interface
	MOV		R0, #0
	MOV		R8, #FunctionSet
	BL		Lowest_Level_WR

Wait4ms1:	;wait for more than 4.1 ms
			;4.1ms = 196800 cycles
	MV32 	R0, #196800
WaitLoop4ms1:
	SUB		R1, R0, #1
	CMP		R1, #0
	BNE		WaitLoop4ms1
	;BEQ		FunctionSetCommand2
FunctionSetCommand2: ;Do Function Set Command for 8-bit interface
	MOV		R0, #0
	MOV		R8, #FunctionSet
	BL		Lowest_Level_WR
Wait100us:
	MOVW	R0, #4800
WaitLoop100us:
	SUB		R1, R0, #1
	CMP		R1, #0
	BNE		WaitLoop100us
	;BEQ	FunctionSetCommand3
FunctionSetCommand3: ;Do Function Set Command for 8-bit interface
	MOV		R0, #0
	MOV		R8, #FunctionSet
	BL		Lowest_Level_WR
;now, busy flag can be checked
;Function Set
FunctionSetting:
	MOV		R0, #0
	MOV		R8, #FunctionSet
	BL		Lowest_Level_WR

;CHECK BUSY FLAG

;Turn Display OFF
DisplayOFF:
	MOV		R0, #0
	MOV		R8, #DisplayOff
	BL		Lowest_Level_WR
;check BF, if high, wait until it is low
CheckBF:
	;set R/W =1
	LDR		R3, [R1, #DOUT31_0]
	ORN		R2, R3, #Read
	STR		R2, [R1, #DOUT31_0]
	MOV		R0, #0		;RS = 0
	BL		Lowest_Level_RD
	LDR		R3, [R1, #DIN31_0]
	AND		R2, R3, #BF_MASK
	CMP		R2, #BF_MASK
	BNE		CheckBF
	;BEQ	ClearDisplay
;Clear Display
ClearDisplayInit:
	MOV		R0, #0
	MOV		R8, #ClearDisplay
	BL		Lowest_Level_WR

;check BF, if high, wait until it is low
CheckBF2:
	;set R/W =1
	LDR		R3, [R1, #DOUT31_0]
	ORN		R2, R3, #Read
	STR		R2, [R1, #DOUT31_0]
	MOV		R0, #0		;RS = 0
	BL		Lowest_Level_RD
	LDR		R3, [R1, #DIN31_0]
	AND		R2, R3, #BF_MASK
	CMP		R2, #BF_MASK
	BNE		CheckBF2
	;BEQ	EntryModeSet
;Entry Mode Set: 00000110, 0000001111
EntryModeSet:
	MOV		R0, #0
	MOV		R8, #EntryMode
	BL		Lowest_Level_WR
;check BF, if high, wait until it is low
CheckBF3:
	;set R/W =1
	LDR		R3, [R1, #DOUT31_0]
	ORN		R2, R3, #Read
	STR		R2, [R1, #DOUT31_0]
	MOV		R0, #0		;RS = 0
	BL		Lowest_Level_RD
	LDR		R3, [R1, #DIN31_0]
	AND		R2, R3, #BF_MASK
	CMP		R2, #BF_MASK
	BNE		CheckBF3
	;BEQ    DisplayON

;Turn Display ON
DisplayOn:
	MOV		R0, #0
	MOV		R8, #DisplayON
	BL		Lowest_Level_WR
	BX		LR

DisplayChar: ;DisplayChar(r,c,ch)
;Description: The function outputs the character ch to the display starting on column c in line r.
;Input:
;r - 16-bit unsigned value
;c - 16-bit unsigned value
;Output:
;None
;Shared Variables:
;ch - the ascii value for the character we will output
;r - the row we are going to start outputting
;c - the column we are going to start outputting
;User Interface:
;None
;Error Handling:
;Algorithms:
;None.
;Data Structures:
;None.
;Known Bugs:
;None.
;Limitations:
;None.
;Pseudocode:
;save r*40 + c into R1
;adjust cursor position to R1
;check BF, if high, wait until it is low
;LowestLevelWR(RS = 1, ch)
ComputePosition:


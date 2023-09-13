;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																			 ;
;                       	  keypad_functions.s                             ;
;                                    KEYPAD                                  ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains the hardware functions for the
;				    keypad, including the initialization function for the
;					shared variables and the event handler.
;
; Functions:
;	InitKeypad():	initializes all shared variables
;	ScanDebounce(): called every 20ms, scans a row of the keypad and debounces
;					the switch if a key is down.
; Revision History:
;    11/9/21	Ellie Cho	Initial revision
;	 11/13/21	Ellie Cho	set up initkeypad
;	 11/15/21	Ellie Cho	set up initial event handler
;    11/17/21   Ellie Cho	tried to fix bugs
;	 11/20/21	Ellie Cho	added buffer queueing to event handler
;	 11/27/21	Ellie Cho	fixed some bugs
;	 11/29/21	Ellie Cho	code works now




	.def ScanDebounce
	.def InitKeypad
	.include "keypad_symbols.inc"

;InitKeypad()
;Description:
;The function is called at the beginning and sets all the shared
;variables of the keypad.
;Input:
;None
;Output:
;None
;Shared Variables:
;debounced_switch (WR): flag that is high when a key is debounced
;key_code (WR): The key code of each switch is listed at the end of this
; document. This corresponds to which key is scanned and debounced.
;debounce_cntr (WR): keeps track of the time since switch has been pressed,
;starting from DEBOUNCE_TIME = 20ms.
;row_index (WR): keeps track of which row we are at
;current_pattern (WR): this is similar to key_code, but also stores the state
; of the pins when no switches are down -- the low
;				          bits are then all high.
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
;InitKeyPad():
;"setting all the shared variables
;debounced_switch = 0;
;key_code = 0x0000 0000;
;debounce_cntr = DEBOUNCE_TIME; "10 milliseconds
;row_index = 0;
;current_pattern = ^h000;

InitKeypad:
	MOVW	R1, #INIT_PATTERN
	MOVW	R2, #DEBOUNCE_TIME
	MOVW	R3, #ROW_ZERO
	MOVW	R5, key_code
	MOVT	R5, key_code
	MOVW	R6, current_pattern
	MOVT	R6, current_pattern
	MOVW	R7, previous_pattern
	MOVT	R7, previous_pattern
	MOVW	R8, row_index
	MOVT	R8, row_index
	MOVW	R9, debounce_cntr
	MOVT	R9, debounce_cntr
	STR		R1, [R5]
	STR		R1, [R6]
	STR		R1, [R7]
	STR		R2, [R9]
	STR		R3, [R8]
InitializeBuffer:
	;initialize buffer_pointer and buffer values
	MOVW	R3, #BUFFER_POINTER_INIT
	MOVW	R4, #BUFFER_INIT
	MOVW	R5, buffer_pointer
	MOVT	R5, buffer_pointer
	MOVW	R6, buffer
	MOVT	R6, buffer
	STR		R3, [R5]
	STR		R4, [R6]
	BX		LR

;Event Handler (runs in the background):
;Description:
;Debounces the switch if there is a switch that is down, scans for debounced
;switches. The function is called once every millisecond by the timer.
;Everytime the function is called, it only scans one row. In the next call,
;the next row is scanned.
;Inputs:
;None
;Output:
;None
;Shared Variables:
;debounce_cntr (RD, WR): keeps track of the time since switch has been pressed,
; starting from DEBOUNCE_TIME = 100ms.
;row_index (RD, WR): keeps track of which row we are at
;key_code (WR): The key code of each switch is listed at the end of this
;document. This corresponds to which key is scanned and debounced.
;current_pattern (RD, WR): this is similar to key_code, but also stores the
;state of the pins when no switches are down -- the low
; bits are then all high.


ScanDebounce:
	;clear interrupts for the keypad clock
	MOVW	R0, #GPT0BaseAddressLow
	MOVT	R0, #GPTOBaseAddressHigh
	MOV 	R1, #CLEAR_KEYPAD_INTERRUPT		;this clears the interrupt
	STR		R1, [R0, #ICLR_OFFSET]
	;disable interrupts
	MOVW	R1, event_calls
	MOVT	R1, event_calls
	LDR		R3, [R1]
	ADD		R2, R3, #1
	STR		R2, [R1]
	PUSH	{LR}

	MOVW	R0, current_pattern	;load current_pattern ex:11101111
	MOVT	R0, current_pattern
	LDR		R1, [R0]
	AND		R3, R1, #MASK_OUTPUT ;mask outputs so only columns are visible
							     ;ex: 00001111
	MOVW	R2, previous_pattern	;save a copy of the column pattern
	MOVT	R2, previous_pattern
	STR		R3, [R2]
	AND		R4, R1, #MASK_INPUT	;now mask columns so only rows are visible
							    ; ex: 11101111 meaning row 0
	STR		R4, [R0]   ;save rows to current_pattern
	LDR		R1, [R0]	;R1 has new current_pattern
	;B		GoToRow
GoToRow:
	MOVW	R0, #GPIOBaseAddressLow	;access GPIO
	MOVT	R0, #GPIOBaseAddressHigh
	;B		TurnOffAllRows
TurnOffAllRows:
	MOVW	R9, #ZERO_ROWS		;turn off rows by passing in 0s to row pins
	STR		R9, [R0, #DOUT23_20]	;this step is necessary bc writing
								    ;to DOUTSET does not work unless
								  	;you zero everything first
	;B		TurnOnAllButOne
TurnOnAllButOne:
	MOVW	R6, #OFFSET_ROW_LOW		;row offset from row pattern to row values
	MOVT	R6, #OFFSET_ROW_HIGH
	MUL		R5, R4, R6				;multiply offset to row pattern to get
									;DOUTSET31_0 value to write
	STR		R5, [R0, #DOUTSET31_0]	;turn on everything but the row
									;we are scanning
	;B		CheckColumnsUp
CheckColumnsUp:
	;read in column inputs
	MOVW	R0, #GPIOBaseAddressLow
	MOVT	R0, #GPIOBaseAddressHigh
	LDR		R2, [R0, #DIN31_0]	;R2 has input values
	MOVW	R3, #COLUMN_SHIFT
	LSL		R4, R2, R3
	CMP		R4, #ALLCOLSUP		;check if all columns are up
	BNE		CmpColsDown		;if not, check which column is up
	;BEQ	ColsAllUp
ColsAllUp:
	;save columns to current_pattern
	ORR		R4, R1, #MASK_OUTPUT;or current_pattern with all 1s in the columns
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	STR		R4, [R0]		;save current_pattern
	;reset debounce counter
	MOVW 	R5, debounce_cntr
	MOVT	R5, debounce_cntr
	MOVW    R6, #DEBOUNCE_TIME
	STR		R6, [R5]
	;increment	row_index
	MOVW	R5,	row_index
	MOVT	R5, row_index
	LDR	    R7, [R5]
	CMP		R7, #MAX_ROW
	;BEQ	ResetRow
	BNE		IncRow
ResetRow:	;if the scanner is at the last row, go back to first row
	MOVW	R6, #ROW_ZERO
	STR		R6, [R5]
	MOVW	R8, #INIT_PATTERN
	STR		R8, [R0]	;store 11101111 to current_pattern
	B		EndEvent
IncRow:
	ADD		R6, R7, #0x1	;increrment row_index and save to R6
	STR		R6, [R5]		;store row_index
	;shift current_pattern
	LDR		R1, [R0]	;load_current_pattern ex: 10111111
	LSL	    R2, R1, #1	;ex: 01111110
	;make all columns high again
	ORR		R3, R2, #UPCOLPATTERN
	AND		R4, R3, #EIGHT_BIT_MASK ;only take the last 8 bits
	;save current_pattern
	STR		R4, [R0]
	B		EndEvent

CmpColsDown:	;checks which column is down and goes to appropriate code
	MOVW	R0, #GPIOBaseAddressLow
	MOVT	R0, #GPIOBaseAddressHigh
	LDR		R2, [R0, #DOUT23_20]
	MOVW    R3, #COL0DOWNLow
	MOVT	R3, #COL0DOWNHigh
	CMP		R4, R3
	BEQ		Col0Down
	MOVW	R3, #COL1DOWNLow
	MOVT	R3, #COL1DOWNHigh
	CMP		R4, R3
	BEQ		Col1Down
	MOVW	R3, #COL2DOWNLow
	MOVT	R3, #COL2DOWNHigh
	CMP		R4, R3
	BEQ		Col2Down
	MOVW	R3, #COL3DOWNLow
	MOVT	R3, #COL3DOWNHigh
	CMP		R4, R3
	BEQ		Col3Down
	B		EndEvent ; should never come here
Col0Down:	;column 0 is down --> move appropriate pattern to current_pattern
			;then check if this is a new switch press (if the debounce counter
			;needs to be restarted)
	MOVW	R3, #COL0Pattern
	ORR		R4, R1, R3		;note: R1 has current_pattern without columns
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	STR		R4, [R0]	;update current_pattern
	B		CmpCurrentPreviousCol
Col1Down:	;column 1 is down --> move appropriate pattern to current_pattern
			;then check if this is a new switch press (if the debounce counter
			;needs to be restarted)
	MOVW	R3, #COL1Pattern
	ORR		R4, R1, R3		;note: R1 has current_pattern without columns
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	STR		R4, [R0]	;update current_pattern
	B		CmpCurrentPreviousCol
Col2Down:	;column 2 is down --> move appropriate pattern to current_pattern
			;then check if this is a new switch press (if the debounce counter
			;needs to be restarted)
	MOVW	R3, #COL2Pattern
	ORR		R4, R1, R3		;note: R1 has current_pattern without columns
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	STR		R4, [R0]	;update current_pattern
	B		CmpCurrentPreviousCol
Col3Down:	;column 3 is down --> move appropriate pattern to current_pattern
			;then check if this is a new switch press (if the debounce counter
			;needs to be restarted)
	MOVW	R3, #COL3Pattern
	ORR		R4, R1, R3		;note: R1 has current_pattern without columns
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	STR		R4, [R0]	;update current_pattern
	B		CmpCurrentPreviousCol


CmpCurrentPreviousCol: ;see if the current column pattern is different from the
					   ;previous
	MOVW	R0, current_pattern
	MOVT	R0, current_pattern
	LDR		R1, [R0]
	;mask non_column bits
	AND		R2, R1, #MASK_OUTPUT
	MOVW	R3, previous_pattern
	MOVT	R3, previous_pattern
	LDR		R4, [R3]
	CMP		R2, R4
	BNE		NewSwitchDown	;if the new pattern is different from the previous,
							;go to NewSwitchDown to reset the debounce_cntr
							;and
	;BEQ	ContinueDebounce

ContinueDebounce:	;decrement the debounce counter
	MOVW	R5, debounce_cntr
	MOVT	R5, debounce_cntr
	LDR		R6, [R5]
	SUB		R7, R6, #0x1	;decrement debounce_cntr
	STR		R7, [R5]

CheckIfDoneDebouncing:	;See if debounce counter is 0. If not, end event. If it
					    ;is 0, the switch is done debouncing and needs to be
					    ;handled.
	CMP		R7, #DONEDEBOUNCING
	BNE		EndEvent
	;BE		HandleDebouncedSwitch

HandleDebouncedSwitch:

ResetDebounceCounter:
	;debounce_cntr reset to DEBOUNCE_TIME
	MOVW	R4, debounce_cntr
	MOVT	R4, debounce_cntr
	MOVW	R5, #DEBOUNCE_TIME
	STR		R5, [R4]
	;B		SetKeyCode
SetKeyCode:	;write the current_pattern to key_code
	MOVW	R6, key_code
	MOVT	R6, key_code
	MOVW	R7, current_pattern
	MOVT	R7, current_pattern
	LDR		R8, [R7]
	STR		R8, [R6]
	;B		WriteToBuffer
WriteToBuffer:	;write the debounced key code to the buffer
	MOVW	R2, buffer
	MOVT	R2, buffer
	MOVW	R3, buffer_pointer
	MOVT	R3, buffer_pointer
	LDR		R4, [R3]
	STR		R8, [R2, R4]
	ADD		R10, R4, #0x4 ;increment buffer_pointer
	CMP		R10, #40 ;if larger than 40, loop back to 0
	BEQ		LoopPointerBack
	STR		R10, [R3]
	B		EndEvent
LoopPointerBack:
	MOVW	R3, buffer_pointer
	MOVT	R3, buffer_pointer
	MOVW	R4, #0
	STR		R4, [R3]
	B		EndEvent
NewSwitchDown:	;runs if there is a new switch press
	;reset debounce_cntr
	MOVW	R4, debounce_cntr
	MOVT	R4, debounce_cntr
	MOVW	R5, #DEBOUNCE_TIME
	STR		R5, [R4]
	;B		EndEvent

EndEvent:
	;turn on interrupts again
	MOVW	R0, #CPU_SCS_Low
	MOVT	R0, #CPU_SCS_High
	MOVW	R1, #KeypadIRQOn
	STR		R1, [R0, #NVIC_ISER0]
	CPSIE	I
	POP		{LR}
	BX		LR

;make code the combination of row output and column inputs high 4 bits are row pattern, low 4 bits are from the read-in value from the columns
;Switch 1 down: row 1 and column 1 -- Code: [01110111]
;Switch 2 down: row 1 and column 2 -- Code: [01111011]
;Switch 3 down: row 1 and column 3 -- Code: [01111101]
;Switch 4 down: row 1 and column 4 -- Code: [01111110]
;Switch 5 down: row 2 and column 1 -- Code: [10110111]
;Switch 6 down: row 2 and column 2 -- Code: [10111011]
;Switch 7 down: row 2 and column 3 -- Code: [10111101]
;Switch 8 down: row 2 and column 4 -- Code: [10111110]
;Switch 9 down: row 3 and column 1 -- Code: [11010111]
;Switch 10 down: row 3 and column 2 -- Code: [11011011]
;Switch 11 down: row 3 and column 3 -- Code: [11011101]
;Switch 12 down: row 3 and column 4 -- Code: [11011110]
;Switch 13 down: row 3 and column 3 -- Code: [11100111]
;Switch 14 down: row 3 and column 3 -- Code: [11101011]
;Switch 15 down: row 3 and column 3 -- Code: [11101101]
;Switch 16 down: row 3 and column 3 -- Code: [11101110]


key_code_bridge:			.word	key_code
debounce_cntr_bridge:		.word	debounce_cntr
row_index_bridge:			.word	row_index
debounced_switch_bridge:	.word	debounced_switch
current_pattern_bridge:		.word	current_pattern
previous_pattern_bridge:	.word	previous_pattern
buffer_bridge:				.word	buffer
event_calls_bridge:			.word	event_calls

	.data


	.align 8
key_code:			.space	4	;the code of a debounced switch, tells user
								;which switch was pressed
	.align 8
debounce_cntr:		.space	4	;debounce counter that counts 100ms before
								;a key press is debounced
	.align 8
row_index:			.space	4	;row being scanned
	.align 8
debounced_switch:	.space	4	;flag for when a switch is debounced
	.align 8
current_pattern:	.space	4	;stores current pattern of the keypad
	.align 8
previous_pattern:	.space  4	;stores the previous pattern of the keypad
	.align 8
buffer:				.space 	BUFFER_SPACE	;stores key presses
	.align 8
buffer_pointer: 	.space	POINTER_SPACE	;stores location in the buffer to
											;write to next
	.align 8
event_calls:		.space	4

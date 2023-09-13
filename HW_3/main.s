;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																			 ;
;                                    main.s                                  ;
;                                     LCD                                    ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program tests the LCD functions.
;                   It sets up the stack and calls the initialization
;				    functions and  the test function, which is just an
;					infinite loop.
;
; Input:            None.
; Output:           LCD.
;
; User Interface:   None.
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
;    2/28/21	Ellie Cho	initial revision


; local include files
;   none

	.include "lcd_symbols.inc"
	.include "macros.inc"
	.ref InitTimer
	.ref InitLCD
	.ref InitPorts
;executable code starts here
	.text

;setup the reset vector
	.global ResetISR ;this is the entry point

ResetISR:



main:
;set up stack pointer
StackSetUp:
	MOVW	R0, TopOfStack
	MOVT	R0, TopOfStack
	MSR		MSP, R0
	SUB		R0, R0, #HANDLER_STACK_SIZE
	MSR		PSP, R0

MoveVectorTable:
	PUSH	{R4}
	;B		MoveVecTableInit
MoveVecTableInit:
	MOVW	R1, #CPU_SCS_Low
	MOVT	R1, #CPU_SCS_High
	LDR		R0, [R1, #VTOR_OFFSET]
	MOVW	R2, VecTable
	MOVT	R2, VecTable
	MOV		R3, #VEC_TABLE_SIZE
	;B		MoveVecCopyLoop
MoveVecCopyLoop:
	LDR		R4, [R0], #BYTES_PER_WORD
	STR		R4, [R2], #BYTES_PER_WORD
	SUBS	R3, #0x1
	BNE		MoveVecCopyLoop
	;B		MoveVecCopyDone

MoveVecCopyDone:
	MOVW	R2, VecTable
	MOVT	R2, VecTable
	STR		R2, [R1, #VTOR_OFFSET]
	;B		MoveVecTableDone
MoveVecTableDone:
	POP		{R4}
CallInitializationFunctions:
	BL		InitPorts				;set ports
	BL		InitTimer
	BL		InitLCD
	;B		EnableInterrupts




VecTable_bridge		.word	VecTable
TopOfStack_bridge	.word	TopOfStack


	.data

	.align  8
	.SPACE	TOTAL_STACK_SIZE
TopOfStack:

		.align 512
VecTable:		.space	VEC_TABLE_SIZE * BYTES_PER_WORD


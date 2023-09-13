;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																			 ;
;                                    main.s                                  ;
;                                    KEYPAD                                  ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program tests the keypad functions for Homework #2.
;                   It sets up the stack and calls the initialization
;				    functions and  the test function, which is just an
;					infinite loop.
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


; local include files
;   none
	.include "keypad_symbols.inc"


	.ref ScanDebounce
	.ref InitKeypad
	.ref GetKey
	.ref IsAKey
	.ref InitTimer
	.ref InitPorts
	.ref SystemInitialization


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
	MOVW	R1, #CPU_SCS_BASE_ADDR_LOW
	MOVT	R1, #CPU_SCS_BASE_ADDR_HIGH
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

SetUpVectorTable:
; write the address of the event handler function into the vector table offset
; for GP Timer 0A
	MOVW	R1, VecTable
	MOVT	R1, VecTable
	MOVW	R2, ScanDebounce
	MOVT	R2, ScanDebounce
	STR		R2, [R1, #GPTimer0A]
	;B		CallInitializationFunctions
CallInitializationFunctions:
	BL		SystemInitialization	;initializes vector table, power, and clocks
	BL		InitPorts				;set ports
	BL		InitTimer
	BL		InitKeypad
	;B		EnableInterrupts
EnableInterrupts:
	MOVW	R0, #CPU_SCS_Low
	MOVT	R0, #CPU_SCS_High
	MOVW	R1, #KeypadIRQOn
	STR		R1, [R0, #NVIC_ISER0]
	CPSIE	I
	;B		SwitchTestLoop

SwitchTestLoop:	;infinite loop
STWaitLoop:
	NOP
	B		STWaitLoop




VecTable_bridge		.word	VecTable
TopOfStack_bridge	.word	TopOfStack


	.data

	.align  8
	.SPACE	TOTAL_STACK_SIZE
TopOfStack:

		.align 512
VecTable:		.space	VEC_TABLE_SIZE * BYTES_PER_WORD

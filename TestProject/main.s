
	.include "symbols.inc"
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
	MOVW	R0, #0xFFFF
	ORNS	R1, R0, #0
AbsFunction:
	MV32	R0, #AbsValue
	ASR		R1, R0, #31 ;R1 is 0xFFFF if R0 is negative, 0x0000 if R0 is positive
	EOR		R0, R0, R1	;2s complement
	NOP

SignFunction:
	MV32	R0, #SgnValue
	LSR		R1, R0, #31 ;get the sign bit only
	SBCS	R1, R1, #1
	ADC		R1, R1, #1
PowerOf2:
	MV32	R0, #PowerValue
	ANDS	R1, R0, #PowerValue - 1
	ORRS	R2, R0, #0
	ORRS	R3, R1, R2
	NOP

SineofAngle:
	ADR		R4, SinTable
	;adjust R0
	;look up angle
	LDRSB	R1, [R4], R0
	;adjust sign
	

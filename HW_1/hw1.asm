;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                     HW1                                    ;
;                                  EE/CS 110a                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the code for HW #1.  The public functions
; included are:
;    DisplayTest - test the display functions
;
;
; Revision History:
;    10/23/21  Ellie Cho               initial revision
;	 10/29/21  Ellie Cho			   defined some functions and variables
									  ;set up ports



; local include files
;   none
	.include "symbols.inc"
	.thumb

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

SetupStack:
MOV		R1	#TOTAL_STACK_SIZE
MSR		MSP, R1
SUB		R1, R1, #HANDLER_STACK_SIZE
MSR		PSP, R1



;set LEDs as outputs and switches as inputs
SetPorts:
;get GPIO base address
MOVW 	R1, #GPIOBaseAddress
;move 0 into R2
MOVW 	R2, #OESettings
STR 	R2, [R1, #DOE31_0]
;pull up resistors to switch pins
MOVW	R7, #IOCBaseAddress
MOVW	R3, #PullUpInputSettings
MOVW	R4, #OutputSettings
STR		R4, [R7, #IOCFG6]
STR		R4, [R7, #IOCFG7]
STR		R3, [R7, #IOCFG13]
STR		R3, [R7, #IOCFG14]

CheckLeftSwitch:
;read value of left switch
MOVW 	R1, #GPIOBaseAddress
MOV 	R2, [R1, #DIN31_0] ;get states of dio31..0 pins
;mask all values but dio6
MOVW    R3, #DIO13_ON
AND	    R4, R2, R3
;compare to "left switch on"
CMP 	R4, #DIO13_ON
CBNZ 	R2, TurnRedLEDOff ;this should see if the switch is on and if it is not, go to "turn off" function
NOP

TurnRedLEDOn:
MOVW 	R1, #GPIOBaseAddress
MOVW 	R2, #RED_ON
STR 	R2, [R1, #DOUT4_7]
B		CheckRightSwitch
NOP


TurnRedLEDOff:
;if equal, load "LED on" state
;store in red LED (DIO6)
MOVW 	R1, #GPIOBaseAddress
MOVW 	R2, #OFF
STR 	R2, [R1, #DOUT4_7]
B		CheckRightSwitch
NOP

CheckRightSwitch:
;read value of left switch
MOVW 	R1, #GPIOBaseAddress
MOV 	R2, [R1, #DIN31_0] ;get states of dio31..0 pins
;mask all values but dio6
MOVW    R3, #DIO14_ON
AND	    R4, R2, R3
;compare to "right_switch_on"
CMP 	R4, #DIO14_ON
CBNZ 	R2, TurnGreenLEDOff ;this should see if the switch is on and if it is not, go to "turn off" function
NOP

TurnGreenLEDOn:
MOVW 	R1, #GPIOBaseAddress
MOVW 	R3, #GREEN_ON
STR 	R3, [R1, #DOUT4_7]
B		CheckLeftSwitch
NOP

TurnGreenLEDOff:
MOVW 	R1, #GPIOBaseAddress
MOVW 	R3, #LOW
STR 	R3, [R1, #DOUT4_7]
B		CheckLeftSwitch
NOP

Loop:
B	CheckLeftSwitch
NOP


;data segment
.data
;	the stack
	.align 8	STACK_SIZE

TopOfStack:

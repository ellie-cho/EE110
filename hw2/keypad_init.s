	.def InitTimer
	.def InitPorts
	.include "keypad_symbols.inc"
	.include "macros.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                KEYPAD_INIT.S                               ;
;                               Keypad Functions                             ;
;                                Initialization                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program initializes the timer and ports for HW2.
; Input:            None.
; Output:           None.
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
; Revision History:
;    11/9/21  Ellie Cho 	initial revision

;InitTimer():
;Description:
;Configures the general purpose timer to generate an interrupt every
;millisecond. (1kHz timer interrupt)
;Input:
;None
;Output:
;None
;Shared Variables:
;None.
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

;access general purpose timer 0A register
;set register:
;	CFG = 0x00000004	;CFG is setup for two 16-bit counters
;	CTL = 0x00000001	;CTL enables timer A.
;	IMR = 0x00000001	;IMR enables the timeout event interrupt
;	TAMR = 0x00000002	;TAMR sets up a periodic down counter with interrupts
						; enabled
;	TAILR = 39999 ;to get 1 kHz interrupts need to divide the 40 MHz clock by
				  ;40,000 so no prescalar needed
;	TAPR = 0


InitTimer:

SetGPT0Registers:
	MOVW	R1, #GPT0BaseAddressLow
	MOVT	R1, #GPTOBaseAddressHigh
	MOVW	R2, #CFG_VALUE_LOW
	MOVT	R2, #CFG_VALUE_HIGH
	STR		R2, [R1, #CFG_OFFSET]
	MOVW	R2, #CTL_VALUE_LOW
	MOVT	R2, #CTL_VALUE_HIGH
	STR		R2, [R1, #CTL_OFFSET]
	MOVW	R2, #IMR_VALUE_LOW
	MOVT	R2, #IMR_VALUE_HIGH
	STR		R2, [R1, #IMR_OFFSET]
	MOVW	R2, #TAMR_VALUE_LOW
	MOVT	R2, #TAMR_VALUE_HIGH
	STR		R2, [R1, #TAMR_OFFSET]
	MOVW	R2, #TAILR_VALUE
	STR		R2, [R1, #TAILR_OFFSET]
	MOVW	R2, #TAPR_VALUE
	STR		R2, [R1, #TAPR_OFFSET]
	BX		LR


;InitPorts()
;Description:
;Configures the DIO pins used by the keypad as either inputs or outputs.
;We will be scanning the rows and reading the columns; rows are inputs,
;columns are outputs.
;Input:
;None
;Output:
;None
;Shared Variables:
;None.
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
;enable peripheral power
;enable gpio clock
;enable clock to timer
;set DIO19..DIO16 to be outputs
;set DIO23..DIO20 to be inputs

InitPorts:


SetPorts:	;set rows as outputs and columns as inputs
;get GPIO base address
	MOVW 	R1, #GPIOBaseAddressLow
	MOVT	R1, #GPIOBaseAddressHigh
;save output enable settings to DOE31..0 address --> enables those pins
; to be outputs
	MOVW 	R2, #OESettingsLow
	MOVT	R2, #OESettingsHigh
	STR 	R2, [R1, #DOE31_0]
;configure output settings to row pins, pull-up input settings to
;column pins
;rows are 23..20 and columns are 19..16
	MOVW	R7, #IOCBaseAddress_Low
	MOVT	R7, #IOCBaseAddress_High
	MOVW	R3, #PullUpInputSettings_Low
	MOVT	R3, #PullUpInputSettings_High
	MOVW	R4, #OutputSettings
	STR		R3, [R7, #IOCFG19]
	STR		R3, [R7, #IOCFG18]
	STR		R3, [R7, #IOCFG17]
	STR		R3, [R7, #IOCFG16]
	STR		R4, [R7, #IOCFG23]
	STR		R4, [R7, #IOCFG22]
	STR		R4, [R7, #IOCFG21]
	STR		R4, [R7, #IOCFG20]
	BX		LR

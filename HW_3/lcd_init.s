	.include "lcd_symbols.inc"
	.include "macros.inc"
	.def InitPorts
	.def InitTimer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  LCD_INIT.S                                ;
;                                 LCD Functions                              ;
;                                Initialization                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program initializes the timer and ports for the LCD.
; Functions:		InitPorts()- Configures the DIO pins used by the LCD as
;					either inputs or outputs. The RS, R/W, and E pins of the
;					LCD are always outputs. DB0..DB7 pins can be either
;					inputs or outputs depending on R/W.
;					InitTimer() - Configures the timer to be one-shot mode
;					for 1ms delay, is used to check for notBusy and enable
; Revision History:
;    2/28/22  Ellie Cho 	initial revision

;InitTimer()
;Description:
;Configures the timer to be one-shot mode for 1ms delay
;used to check for notBusy and enable
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
;access general purpose timer 1A register
;set register:
;	CFG = 0x00000000	;CFG is setup for one 32-bit counter
;	CTL = 0x00000001	;CTL enables timer A.
;	IMR = 0x00000000	;IMR is set for no timeout event interrupt
;	TAMR = 0x00000002	;TAMR sets up a one-shot count-down timer
;	TAILR = 48 		;tcycle = 1000ns, with a 48MHz timer, this is 48 cycles
;	TAPR = 0
InitTimer:
SetGPT1Registers:
	MV32	R1, #GPT1BaseAddress
	MV32	R2, #CFG_VALUE
	STR		R2, [R1, #CFG_OFFSET]
	MOVW	R2, #CTL_VALUE_LOW
	MOVT	R2, #CTL_VALUE_HIGH
	STR		R2, [R1, #CTL_OFFSET]
	MOVW	R2, #TAMR_VALUE_LOW
	MOVT	R2, #TAMR_VALUE_HIGH
	STR		R2, [R1, #TAMR_OFFSET]
	MOVW	R2, #TAILR_VALUE
	STR		R2, [R1, #TAILR_OFFSET]
	MOVW	R2, #TAPR_VALUE
	STR		R2, [R1, #TAPR_OFFSET]
	BX		LR



InitPorts:
;Description:
;Configures the DIO pins used by the LCD as either inputs or outputs.
;The RS, R/W, and E pins of the LCD are always outputs
;DB0..DB7 pins can be either inputs or outputs depending on R/W.
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
;set RS, R/W, and E pins as outputs (RS = D8, R/W = D9, E = D10)
;D7..D0 pins are set as outputs if R/W = 0
;D7..D0 pins are set as inputs if R/W = 1

	MOVW 	R1, #GPIOBaseAddressLow ;get GPIO base address
	MOVT	R1, #GPIOBaseAddressHigh
	MV32 	R2, #OESettings  ;set RS, R/W, and E pins as outputs (RS = D8, R/W = D9, E = D10)
	STR 	R2, [R1, #DOE31_0]


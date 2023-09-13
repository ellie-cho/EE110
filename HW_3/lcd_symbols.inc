;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                LCD_SYMBOLS.INC                             ;
;                                 LCD Functions                              ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program defines constants used in the LCD.
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
;    2/28/22    Ellie Cho   initial revision
GPIOBaseAddressLow  .EQU    0x2000  ;base addresses from memory map
GPIOBaseAddressHigh .EQU    0x4002
GPT1BaseAddressLow     .EQU    0x1000
GPT1BaseAddressHigh    .EQU    0x4001
CFG_VALUE       .EQU    0x00000000
CFG_OFFSET          .EQU    0x0       ;offset of CFG in GPT0 base address
CTL_VALUE_LOW       .EQU    0x0001    ;CTL enables timer A.
CTL_VALUE_HIGH      .EQU    0x0000
CTL_VALUE_LOW       .EQU    0x0001    ;CTL enables timer A.
CTL_VALUE_HIGH      .EQU    0x0000
CTL_OFFSET          .EQU    0xC       ;offset of CTL in GPT0 base address
IMR_VALUE_LOW       .EQU    0x0001    ;IMR enables the timeout event interrupt
IMR_VALUE_HIGH      .EQU    0x0000
IMR_OFFSET          .EQU    0x18
TAMR_VALUE_LOW      .EQU    0x0002  ;TAMR sets up a periodic down counter
                                    ;with interrupts enabled
TAMR_VALUE_HIGH     .EQU    0x0000
TAMR_OFFSET         .EQU    0x4     ;offset of TAMR register in GPT0
TAILR_VALUE         .EQU    48
TAILR_OFFSET        .EQU    0x28    ;offset of TAILR register from GPT0 base
TAPR_VALUE          .EQU    0       ;no need for TAPR bc TAILR fits in 16 bits
TAPR_OFFSET         .EQU    0x38

IOCFG23             .EQU    0x5C    ;offsets of IOCFG registers from IOC base
IOCFG22             .EQU    0x58
IOCFG21             .EQU    0x54
IOCFG20             .EQU    0x50
IOCFG19             .EQU    0x4C
IOCFG18             .EQU    0x48
IOCFG17             .EQU    0x44
IOCFG16             .EQU    0x40
IOCBaseAddress      .EQU    0x40081000 ;base address of IOC
HANDLER_STACK_SIZE  .EQU    128
PROCESS_STACK_SIZE  .EQU    256
TOTAL_STACK_SIZE    .EQU    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE
CPU_SCS_Low         .EQU    0xE000
CPU_SCS_High        .EQU    0xE000
NVIC_ISER0          .EQU    0x100   ;offset for the NVIC_ISER0 register (turn
                                    ;on interrupts)
VTOR_OFFSET         .EQU    0xD08
CPU_SCS_Base_Address    .EQU    0xE000E000
VEC_TABLE_SIZE      .EQU    0x36 ;54 entries in the vector
BYTES_PER_WORD      .EQU    0x4       ;settings for there to be 32 bit words
DOE31_0             .EQU    0xD0
OESettings          .EQU    00000000000b
WR_OE_Settings      .EQU    11111111111b
PRCM                .EQU    0x40082000 ;base address of PRCM
PRCM_Low            .EQU    0x2000
PRCM_High           .EQU    0x4008
PDCTL0              .EQU    0x12C     ;offset for pdctl0
PERIPH_ON           .EQU    0x4       ;value when the peripheral is powered
PDCTL0Periph        .EQU    0x138     ;offset for pdctl0periph
PDSTAT0             .EQU    0x140     ;status of the PD
PDSTAT0PERIPH       .EQU    0x14C     ;status of the peripheral power
Fifteen             .EQU    15000
DOUT31_0            .EQU    0x80
Init_Settings       .EQU    00001100000b
FunctionSet         .EQU    00000110000b
RW_LOW             .EQU    0x000005FF
RS_LOW             .EQU    0x000006FF
E_HIGH              .EQU    00100000000b
E_LOW               .EQU    01111111111b
BF_MASK             .EQU    10000000b
Read                .EQU    100000000b
TAMR_Settings       .EQU    1b
CTL_Offset          .EQU    0xC
TimerEnOn           .EQU    00000000001b
ReadMask            .EQU    11111111b
RD_OE_Settings      .EQU    11100000000b
DisplayOff			.EQU	00000001000b
EntryMode			.EQU	00000000110b
DisplayON			.EQU	00000001111b
ClearDisplay		.EQU	00000000001b
DIN31_0             .EQU    0xC0    ;offset for DIn31..0 from GPIO base


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              KEYPAD_SYMBOLS.INC                            ;
;                               Keypad Functions                             ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program defines constants used in HW2
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
;    11/9/21  Ellie Cho     initial revision
;    11/12/21 Ellie Cho     added useful base addresses and offsets
;    11/15/21 Ellie Cho     added all initialization constants
;    11/20/21 Ellie Cho     added some event handler masks and constants
;    11/29/21 Ellie Cho     added more useful constants for turning off irqs


CPU_SCS_BASE_ADDR_LOW   .EQU    0xE000
CPU_SCS_BASE_ADDR_HIGH  .EQU    0xE000
VTOR_OFFSET         .EQU    0xD08
VEC_TABLE_SIZE      .EQU    0x36 ;54 entries in the vector
GPTimer0A           .EQU    0x07C   ;offset for GPTimer0A Interrupt
                                    ;in Interrupt Vector table
GPIOBaseAddressLow  .EQU    0x2000  ;base addresses from memory map
GPIOBaseAddressHigh .EQU    0x4002
GPT0BaseAddressLow  .EQU    0x0000
GPTOBaseAddressHigh .EQU    0x4001
CFG_VALUE_LOW       .EQU    0x0004    ;CFG is setup for two 16-bit counters
CFG_VALUE_HIGH      .EQU    0x0000
CFG_OFFSET          .EQU    0x0       ;offset of CFG in GPT0 base address
CTL_VALUE_LOW       .EQU    0x0001    ;CTL enables timer A.
CTL_VALUE_HIGH      .EQU    0x0000
CTL_OFFSET          .EQU    0xC       ;offset of CTL in GPT0 base address
IMR_VALUE_LOW       .EQU    0x0001    ;IMR enables the timeout event interrupt
IMR_VALUE_HIGH      .EQU    0x0000
IMR_OFFSET          .EQU    0x18
TAMR_VALUE_LOW      .EQU    0x0002  ;TAMR sets up a periodic down counter
TAMR_VALUE_HIGH     .EQU    0x0000
TAMR_OFFSET         .EQU    0x4     ;offset of TAMR register in GPT0
TAILR_VALUE         .EQU    39999   ;to get 1 kHz interrupts need to divide
                                    ;the 40 MHz clock by 40,000 so no prescalar
                                    ;needed
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
IOCBaseAddress      .EQU     0x40081000 ;base address of IOC
PullUpInputSettings .EQU     0x20004000    ;sets switches to be pull up inputs
PRCM_Low             .EQU     0x2000 ;base address of PRCM
PRCM_High            .EQU     0x4008
GPTCLKGR            .EQU     0x54   ;offset of GPTCLK from GPT0 base
GPT0En              .EQU     0x1    ;constant to enable GPT0CLK
GPTCLKGS            .EQU     0x58   ;offset for GPTCLKGS
GPTCLKGDS           .EQU     0x5C   ;offset for GPTCLKGDS
PDCTL0              .EQU     0x12C     ;offset for pdctl0
PDCTL0Periph        .EQU     0x138     ;offset for pdctl0periph
PDSTAT0             .EQU     0x140     ;status of the PD
PDSTAT0PERIPH       .EQU     0x14C     ;status of the peripheral power
GPIOCLKGR           .EQU     0x48      ;offset to register that turns the
;                                       GPIOCLK on or off
CLKLOADCTL          .EQU     0x28      ;offset to register that allows gpio
;                                       clock to be turned on
BYTES_PER_WORD      .EQU    0x4       ;settings for there to be 32 bit words

DOUT23_20           .EQU    0x14    ;offset for GPIO pins 23..20 output
                                    ;settings from GPIO base
ZERO_ROWS           .EQU    0x0     ;constant for zeroing rows
DOUT16_19           .EQU    0x10    ;offset for GPIO pins 16..20
ALLCOLSUP           .EQU    0xF0000000
                                ;value of read in columns when they are high
COL0DOWNLow         .EQU    0x0000  ;column 0 is down, 1-3 are high
COL0DOWNHigh        .EQU    0x7000
COL1DOWNLow         .EQU    0x0000  ;column 1 is down, 0, 2, 3 are high
COL1DOWNHigh        .EQU    0xB000
COL2DOWNLow         .EQU    0x0000  ;column 2 is down, 0, 1, 3 are high
COL2DOWNHigh        .EQU    0xD000
COL3DOWNLow         .EQU    0x0000  ;column 3 is down, 0, 1, 2 are high
COL3DOWNHigh        .EQU    0xE000
MASK_INPUT          .EQU    11110000b    ;mask so only output bits are visible
                                            ;of the pattern
MASK_OUTPUT         .EQU    00001111b    ;mask so only input bits are visible
                                            ;in the pattern
UPCOLPATTERN        .EQU    00001111b   ;column pattern for when all columns
                                            ;are up
COL0Pattern         .EQU    00001110b   ;pattern for when column 0 is down
COL1Pattern         .EQU    00001101b   ;   "                    1   "
COL2Pattern         .EQU    00001011b   ;   "                    2   "
COL3Pattern         .EQU    00000111b   ;   "                    3   "
DEBOUNCE_TIME       .EQU    100 ;100ms debounce time (my keys are kind of
                                                                  ;sticky)
MAX_ROW             .EQU    0x0003  ;max value of row
ROW_ZERO            .EQU    0x0     ;represents that the current row is 0
INIT_PATTERN        .EQU    11101111b   ;initial pattern of the keypad- all
                                        ;cols up, scanning row 0
DONEDEBOUNCING      .EQU    0x0         ;value of debounce counter when done
BUFFER_SPACE        .EQU    40    ;20 spaces in the buffer
BUFFER_POINTER_INIT .EQU    0x0   ;initial value of buffer pointer = 0
BUFFER_INIT         .EQU    0x0   ;initial value in buffer
PERIPH_ON            .EQU     0x4       ;value when the peripheral is powered
OESettingsHigh      .EQU    0000000011110000b
OESettingsLow       .EQU    0000000000000000b
DOE31_0             .EQU    0xD0
IOCBaseAddress_Low   .EQU     0x1000
IOCBaseAddress_High  .EQU     0x4008
PullUpInputSettings  .EQU     0x20004000    ;sets inputs to be pull up
OutputSettings       .EQU     0         ;sets outputs
POINTER_SPACE        .EQU     2
PullUpInputSettings_Low     .EQU    0x4000
PullUpInputSettings_High    .EQU    0x2000
HANDLER_STACK_SIZE   .EQU   128
PROCESS_STACK_SIZE   .EQU   256
TOTAL_STACK_SIZE      .EQU  PROCESS_STACK_SIZE + HANDLER_STACK_SIZE
CPU_SCS_Base_Address    .EQU    0xE000E000
CPU_SCS_Low         .EQU    0xE000
CPU_SCS_High        .EQU    0xE000
NVIC_ISER0          .EQU    0x100   ;offset for the NVIC_ISER0 register (turn
                                    ;on interrupts)
KeypadIRQOn         .EQU    1000000000000000b   ;settings for the
                                                ;NVIC_ISER0 reg to turn on
                                                ;irq15 :gptimer0a
DOUTSET31_0         .EQU    0x90   ;offset for DOutSet31_0 register
                                    ;from GPIO base
ROW_OFFSET          .EQU    0x10000 ;multiplied with the row pattern
                                    ;to get DIO read in
DIN31_0             .EQU    0xC0    ;offset for DIn31..0 from GPIO base
OFFSET_ROW_LOW      .EQU    0x0000  ;offset value from read in to pattern
OFFSET_ROW_HIGH     .EQU    0x1
COLUMN_SHIFT        .EQU    12      ;LSL shift value for read in columns;
                                    ;then compared with ALL_COLS_HIGH to check
                                    ;if no switch was pressed
EIGHT_BIT_MASK          .EQU    11111111b ;mask to only look at last eight bits
NVIC_ICER0          .EQU    0x180   ;offset for NVIC_ISER0 from CPU_SCS base
ICLR_OFFSET         .EQU    0x24  ;offset for ICLR register from GPTO base
CLEAR_KEYPAD_INTERRUPT  .EQU   0x1;value to put in ICLR reg to clear keypad IRQ
END

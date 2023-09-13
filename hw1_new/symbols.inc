
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW 1                                    ;
;                                "symbols.inc"                               ;
;                                 EE/CS 110a                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Revision History:
;    10/23/21  Ellie Cho               initial revision
;    10/29/21  Ellie Cho               looked up and added base addresses

;    10/31/21  Ellie Cho              ;defined more useful constants

;    11/3/21   Ellie Cho              ;fixed bugs; code is now working
GPIOBaseAddress      .EQU     0x40022000 ;base address of GPIO
GPIOBaseAddress_Low  .EQU     0x2000
GPIOBaseAddress_High .EQU     0x4002
IOCBaseAddress       .EQU     0x40081000 ;base address of IOC
IOCBaseAddress_Low   .EQU     0x1000
IOCBaseAddress_High  .EQU     0x4008
DOE31_0              .EQU     0xD0    ;output enable reg
DOUT4_7              .EQU     0x4     ;output for DIO7..4
OESettings           .EQU     0xC0    ;settings for DIO6 and DIO7 to be outputs
DIN31_0              .EQU     0xC0    ;inputs from DIO31..0
IOCFG6               .EQU     0x18    ;addresses for iocfg registers
IOCFG7               .EQU     0x1C
IOCFG13              .EQU     0x34
IOCFG14              .EQU     0x38
PullUpInputSettings  .EQU     0x20004000    ;sets switches to be pull up inputs
PullUpInputSettings_Low     .EQU    0x4000
PullUpInputSettings_High    .EQU    0x2000
OutputSettings       .EQU     0         ;sets leds to be outputs
DIO13_OFF            .EQU     0x2000    ;value of DIN31..0 when DIO13 is off
DIO14_OFF            .EQU     0x4000    ;value of DIN31..0 when DIO14 is off
OFF                  .EQU     0         ;0
PRCM                 .EQU     0x40082000 ;base address of PRCM
PRCM_Low             .EQU     0x2000
PRCM_High            .EQU     0x4008
PDCTL0               .EQU     0x12C     ;offset for pdctl0
PERIPH_ON            .EQU     0x4       ;value when the peripheral is powered
PDCTL0Periph         .EQU     0x138     ;offset for pdctl0periph
PDSTAT0              .EQU     0x140     ;status of the PD
PDSTAT0PERIPH        .EQU     0x14C     ;status of the peripheral power
GPIOCLKGR            .EQU     0x48      ;offset to register that turns the GPIOCLK on or off
CLKLOADCTL           .EQU     0x28      ;offset to register that allows gpio clock to be turned on
DIO6_ON              .EQU     0x10000   ;turns on red led
DIO6_ON_LOW         .EQU     0x0000
DIO6_ON_HIGH        .EQU     0x0001
DIO7_ON              .EQU     0x1000000 ;turns on green led
DIO7_ON_LOW         .EQU     0x0000
DIO7_ON_HIGH        .EQU     0x0100
DOUTSET31_0          .EQU     0x90      ;offset to DOUTSET31..0 register
DIO6_OFF_MASK       .EQU    0xFFFEFFF   ;turns off red led without affecting other dios
DIO6_OFF_MASK_LOW    .EQU    0xFFFF
DIO6_OFF_MASK_HIGH    .EQU    0xFFFE    ;turns off green led without affecting other dios
DIO7_OFF_MASK          .EQU     0xFEFFFFFF
DIO7_OFF_MASK_LOW    .EQU     0xFFFF
DIO7_OFF_MASK_HIGH   .EQU       0xFEFF



GPIOBaseAddress      .EQU     0x40022000
GPIOBaseAddress_Low  .EQU     0x2000
GPIOBaseAddress_High .EQU     0x4002   ;base address of GPIO
IOCBaseAddress       .EQU     0x40081000
IOCBaseAddress_Low   .EQU     0x1000
IOCBaseAddress_High  .EQU     0x4008   ;base address of IOC
DOE31_0              .EQU     0xD0                       ;output enable reg
DOUT4_7              .EQU     0x4
OESettings           .EQU     0xC0    ;settings for DIO6 and DIO7 to be outputs
DIN31_0              .EQU     0xC0
IOCFG6               .EQU     0x18                       ;addresses for iocfg registers
IOCFG7               .EQU     0x1C
IOCFG13              .EQU     0x34
IOCFG14              .EQU     0x38
PullUpInputSettings  .EQU     0x20004000
PullUpInputSettings_Low     .EQU    0x4000
PullUpInputSettings_High    .EQU    0x2000
OutputSettings       .EQU     0
DIO13_ON             .EQU     0x2000
DIO14_ON             .EQU     0x4000
RED_ON               .EQU     0x0001
GREEN_ON             .EQU     0x2010000
GREEN_ON_Low         .EQU     0x0000
GREEN_ON_High        .EQU     0x0201
OFF                  .EQU     0
Total_Stack_Size     .EQU     0x2000

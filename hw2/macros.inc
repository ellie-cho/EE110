;MACRO for MV32:

MV32 .macro R, IN
    MOV     R, IN & 0xFFFF
    MOVT    R, IN >> 16
    .endm

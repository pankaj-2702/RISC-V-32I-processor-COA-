# Comprehensive RV32I Test Program
.text
.globl _start
_start:
    addi x1, x0, 10      # 0x00a00093
    addi x2, x0, 20      # 0x01400113
    add  x3, x1, x2      # 0x002081b3
    sub  x4, x2, x1      # 0x40110233
    and  x5, x1, x2      # 0x0020f2b3
    or   x6, x1, x2      # 0x0020e333
    xor  x7, x1, x2      # 0x0020c3b3
    slli x8, x1, 2       # 0x00209413
    slt  x9, x1, x2      # 0x0020a4b3
    sw   x3, 0(x0)       # 0x00302023
    lw   x10, 0(x0)      # 0x00002503
    lui  x11, 0x12345    # 0x123455b7
    beq  x1, x1, 8       # 0x00108463
    addi x12, x0, 99     # 0x06300613
    addi x12, x0, 50     # 0x03200613
    jal  x0, 0           # 0x0000006f

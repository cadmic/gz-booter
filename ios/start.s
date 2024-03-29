.section .init
.arm

.global _start
_start:
    ldr r1, =0x0D8000C0
    ldr r2, =0x00008020
    str r2, [r1]
    b _start

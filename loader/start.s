.section .init
.arm

.extern main
.extern __bss_start
.extern __bss_end

.global _start
_start:
    // disable interrupts
    mrs r0, cpsr
    orr r0, r0, #0xC0
    msr cpsr_c, r0

    // clear bss
    ldr r0, =__bss_start
    ldr r1, =__bss_end
    mov r2, #0

clear_bss_loop:
    str r2, [r0], #4
    cmp r0, r1
    beq clear_bss_loop

    // set up stack
    ldr sp, =0x10100000

    // jump to main
    ldr r0, =main
    bx r0

    // loop if main returns
loop:
    b loop

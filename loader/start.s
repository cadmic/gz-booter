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

    // call main
    ldr r0, =main
    blx r0

    // disable MMU
    mrc p15, 0, r0, c1, c0, 0
    bic r0, r0, #0x1
    mcr p15, 0, r0, c1, c0, 0

    // clean dcache
clean_dcache_loop:
    mrc p15, 0, r15, c7, c10, 3
    bne clean_dcache_loop

    // drain write buffer
    mcr p15, 0, r0, c7, c10, 4

    // invalidate icache
    mcr p15, 0, r0, c7, c5, 0

    // branch to IOS reset vector
    ldr pc, =0xFFFF0000

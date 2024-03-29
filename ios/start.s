.section .init
.arm

.extern main
.extern __bss_start
.extern __bss_end

_start:
    ldr pc, =reset_handler
    ldr pc, =syscall_handler
    ldr pc, =swi_handler
    ldr pc, =prefetch_abort_handler
    ldr pc, =data_abort_handler
    ldr pc, =0
    ldr pc, =irq_handler
    ldr pc, =fiq_handler

reset_handler:
    // clear HW_ARMIRQMASK
    mov r0, #0
    ldr r1, =0xD80003C
    str r0, [r1]

    // clear bss
    ldr r0, =__bss_start
    ldr r1, =__bss_end
    mov r2, #0

clear_bss_loop:
    str r2, [r0], #4
    cmp r0, r1
    beq clear_bss_loop

    // enable interrupts
    mrs r0, cpsr
    bic r0, r0, #0xC0
    msr cpsr_c, r0

    // set up stack
    ldr sp, =__stack_end

    // call main
    ldr r0, =main
    blx r0

    // loop forever
loop:
    b loop

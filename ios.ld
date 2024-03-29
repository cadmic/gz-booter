OUTPUT_FORMAT("elf32-bigarm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY {
    sram  : ORIGIN = 0xFFFF0000, LENGTH = 0x10000
    stack : ORIGIN = 0xFFFE0000, LENGTH = 0x08000
}

SECTIONS {
    .init : {
        *(.init)
        . = ALIGN(4);
    } >sram

    .text : {
        *(.text)
        . = ALIGN(4);
    } >sram

    .rodata : {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } >sram

    .data : {
        *(.data)
        . = ALIGN(4);
    } >sram

    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } >sram

    .stack : {
        __stack_start = .;
        . = ORIGIN(stack) + LENGTH(stack);
        __stack_end = .;
    } >stack
}

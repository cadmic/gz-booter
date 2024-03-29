OUTPUT_FORMAT("elf32-bigarm")
OUTPUT_ARCH(arm)
ENTRY(_start)

MEMORY {
    mem2 : ORIGIN = 0x10000000, LENGTH = 0x100000
}

SECTIONS {
    .init : {
        *(.init)
        . = ALIGN(4);
    } >mem2

    .text : {
        *(.text)
        . = ALIGN(4);
    } >mem2

    .rodata : {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } >mem2

    .data : {
        *(.data)
        . = ALIGN(4);
    } >mem2

    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } >mem2
}

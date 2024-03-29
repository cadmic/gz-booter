#ifndef _LOADER_H_
#define _LOADER_H_

#include "types.h"

#define LOADER_ARGS_ADDR 0x10100000

// Arguments passed to loader and IOS at 0x10100000/0x90100000
typedef struct LoaderArgs {
    // Path to .iso on SD card
    char iso_path[256];
    // Pointer to MIOS v10 .elf
    u32 mios_elf_addr;
    // Pointer to IOS binary
    u32 ios_bin_addr;
} LoaderArgs;

#endif

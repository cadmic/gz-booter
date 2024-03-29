#include "loader.h"
#include "printf.h"
#include "string.h"

int main(void) {
    printf("Hello from loader!\n");

    LoaderArgs* args = (LoaderArgs*)LOADER_ARGS_ADDR;
    printf("ISO path: %s\n", args->iso_path);
    printf("MIOS ELF address: 0x%x\n", args->mios_elf_addr);
    printf("IOS binary address: 0x%x\n", args->ios_bin_addr);

    memcpy((void*)0xFFFF0000, (void*)args->ios_bin_addr, 0x10000);

    // Returning from main will jump to newly-loaded IOS
    printf("Starting IOS\n");
    return 0;
}

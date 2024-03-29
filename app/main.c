#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <fat.h>
#include <gccore.h>

#include "loader.h"
#include "types.h"

static void* xfb = NULL;
static GXRModeObj* rmode = NULL;

void panic(const char* fmt, ...) {
    va_list va;
    va_start(va, fmt);
    vprintf(fmt, va);
    va_end(va);

    // TODO: wait for user input
    exit(1);
}

size_t load_file(const char* path, u32 addr) {
    u32 bytes = 0;
    char buffer[1024];

    FILE* file = fopen(path, "rb");
    if (file == NULL) {
        panic("Could not open file %s\n", path);
    }

    while (true) {
        size_t bytes_read = fread(buffer, 1, sizeof(buffer), file);
        if (bytes_read == 0) {
            break;
        }

        memcpy((void*)addr, buffer, bytes_read);
        bytes += bytes_read;
    }

    fclose(file);
    DCFlushRange((void*)addr, bytes);
    printf("Loaded file %s to 0x%08X-0x%08X\n", path, addr, addr + bytes);
    return bytes;
}

// Performs an IOS exploit to gain code execution on Starlet in kernel mode. See
// https://github.com/mkwcat/saoirse/blob/9287a1024fcdd8a02a7f88305fb7942bfd3ac0d3/channel/Main/IOSBoot.cpp#L86
// for details.
void do_exploit(void) {
    s32 fd = IOS_Open("/dev/sha", 0);
    if (fd < 0) {
        panic("IOS_Open failed: %d\n", fd);
    }

    u32* mem1 = (u32*)0x80000000;
    mem1[0] = 0x49004708; // ldr r1, [pc, #0]; bx r1
    mem1[1] = 0x10000000; // loader entry

    ioctlv vec[3];
    vec[0].data = (void*)0x00000000;
    vec[0].len = 0;
    vec[1].data = (void*)0xFFFE0028;
    vec[1].len = 0;
    vec[2].data = (void*)0x80000000;
    vec[2].len = 32;

    s32 result = IOS_Ioctlv(fd, 0, 1, 2, vec);
    if (result < 0) {
        panic("IOS_Ioctlv failed: %d\n", result);
    }

    // Wait forever; IOS will restart Broadway
    while (true) {
        VIDEO_WaitVSync();
    }
}

bool reset_pressed = false;
bool power_pressed = false;

void reset_callback(u32 irq, void* ctx) { reset_pressed = true; }

void power_callback(void) { power_pressed = true; }

int main(int argc, char* argv[]) {
    VIDEO_Init();

    rmode = VIDEO_GetPreferredMode(NULL);
    xfb = MEM_K0_TO_K1(SYS_AllocateFramebuffer(rmode));

    VIDEO_Configure(rmode);
    VIDEO_SetNextFramebuffer(xfb);
    VIDEO_SetBlack(false);
    VIDEO_Flush();

    VIDEO_WaitVSync();
    if (rmode->viTVMode & VI_NON_INTERLACE) {
        VIDEO_WaitVSync();
    }

    CON_Init(xfb, 20, 20, rmode->fbWidth, rmode->xfbHeight, rmode->fbWidth * VI_DISPLAY_PIX_SZ);
    CON_EnableGecko(1, 0);

    SYS_SetPowerCallback(power_callback);
    SYS_SetResetCallback(reset_callback);

    PAD_Init();

    if (!fatInitDefault()) {
        panic("Failed to initialize FAT filesystem\n");
    }

    load_file("sd:/apps/gz-booter/loader.bin", 0x90000000);

    u32 args_addr = LOADER_ARGS_ADDR | 0x80000000;
    LoaderArgs* args = (LoaderArgs*)args_addr;

    u32 ios_bin_addr = args_addr + sizeof(LoaderArgs);
    load_file("sd:/apps/gz-booter/ios.bin", ios_bin_addr);

    args->iso_path[0] = '\0';
    args->mios_elf_addr = 0;
    args->ios_bin_addr = ios_bin_addr & ~0x80000000;
    DCFlushRange((void*)args_addr, sizeof(LoaderArgs));

    while (true) {
        PAD_ScanPads();
        u16 buttons = PAD_ButtonsDown(0);

        if (power_pressed) {
            printf("Shutting down ...\n");
            SYS_ResetSystem(SYS_POWEROFF, 0, 0);
        } else if (reset_pressed || (buttons & PAD_BUTTON_START)) {
            printf("Exiting ...\n");
            SYS_ResetSystem(SYS_RETURNTOMENU, 0, 0);
        } else if (buttons & PAD_BUTTON_A) {
            printf("A button pressed, performing exploit\n");
            do_exploit();
        }

        VIDEO_WaitVSync();
    }

    return 0;
}

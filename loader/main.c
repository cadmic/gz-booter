#include <stdint.h>

typedef uint32_t u32;

int main(void) {
    *(volatile u32*)0x0D8000C0 = 0x00008020;
    return 0;
}

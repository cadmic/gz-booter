#include "string.h"

void* memcpy(void* dest, const void* src, size_t count) {
    u32* dst32 = (u32*)dest;
    u32* src32 = (u32*)src;
    while (count >= 4) {
        *dst32++ = *src32++;
        count -= 4;
    }

    u8* dst8 = (u8*)dst32;
    u8* src8 = (u8*)src32;
    while (count--) {
        *dst8++ = *src8++;
    }

    return dest;
}

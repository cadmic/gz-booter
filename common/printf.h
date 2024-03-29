#ifndef _PRINTF_H_
#define _PRINTF_H_

#include "types.h"

// Supports the following format specifiers:
// %c: character
// %s: string
// %x: unsigned 32-bit integer in hexadecimal
void printf(const char *format, ...);

#endif

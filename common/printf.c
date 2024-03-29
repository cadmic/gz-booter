#include "printf.h"

// EXI channel 1 (Port B)
#define EXI_CSR (*((volatile u32*)0x0D806814))
#define EXI_CR (*((volatile u32*)0x0D806820))
#define EXI_DATA (*((volatile u32*)0x0D806824))

void print_char(char c) {
    u32 result;
    do {
        // Select device 0, 32 MHz clock
        EXI_CSR = 0xD0;
        // Set data
        EXI_DATA = 0xB0000000 | (c << 20);
        // Start 1-byte immediate transfer
        EXI_CR = 0x19;

        // Wait for transfer to complete
        while (EXI_CR & 1) {}

        // Check if transfer was successful
        result = EXI_DATA & 0x04000000;
    } while (!result);
}

void print_string(const char* s) {
    while (*s) {
        print_char(*s++);
    }
}

void print_hex(u32 n) {
    for (int i = 7; i >= 0; i--) {
        char c = (n >> (i * 4)) & 0xF;
        print_char(c < 10 ? '0' + c : 'A' + c - 10);
    }
}

void printf(const char* format, ...) {
    va_list args;
    va_start(args, format);

    while (*format) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case '%':
                    print_char('%');
                    break;
                case 'c':
                    print_char(va_arg(args, s32));
                    break;
                case 's':
                    print_string(va_arg(args, const char*));
                    break;
                case 'x':
                    print_hex(va_arg(args, u32));
                    break;
                default:
                    print_char('%');
                    print_char(*format);
                    break;
            }
        } else {
            print_char(*format);
        }
        format++;
    }

    va_end(args);
}

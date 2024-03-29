#include "printf.h"

void syscall_handler(void) {
    printf("syscall\n");
}

void swi_handler(void) {
    printf("swi\n");
}

void prefetch_abort_handler(void) {
    printf("prefetch abort\n");
}

void data_abort_handler(void) {
    printf("data abort\n");
}

void irq_handler(void) {
    printf("irq\n");
}

void fiq_handler(void) {
    printf("fiq\n");
}

int main(void) {
    printf("Hello from IOS!\n");
    return 0;
}

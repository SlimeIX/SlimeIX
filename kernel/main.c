#include <slimeix/defs.h>

void kmain(void) {
    vga_write("SlimeIX");
    while (1) { __asm__("hlt"); }
} 
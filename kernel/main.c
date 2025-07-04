#include <slimeix/defs.h>

void kmain(void) {
    gtty_init();
    gtty_write("SlimeIX serial\n");
    vga_write("SlimeIX");
    while (1) { __asm__("hlt"); }
} 
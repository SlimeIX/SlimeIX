#include <slimeix/defs.h>
#include <slimeix/version.h>

void kmain(void) {
    gtty_init();
    gtty_write("SlimeIX ");
    gtty_write(SLIMEIX_VERSION);
    gtty_write(" serial\n");
    vga_write("SlimeIX");
    while (1) { __asm__("hlt"); }
} 
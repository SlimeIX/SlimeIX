#ifndef SLIMEIX_DEFS_H
#define SLIMEIX_DEFS_H

#include <stdint.h>

void vga_write(const char*);
void console_putc(char);
void gtty_init(void);
void gtty_write(const char*);

#endif 
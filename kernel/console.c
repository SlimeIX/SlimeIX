#include <stddef.h>
#include <slimeix/defs.h>

#define VGA ((volatile unsigned short*)0xB8000)
#define COLUMNS 80
#define LINES 25

static uint8_t cursor_x = 0;
static uint8_t cursor_y = 0;

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" :: "a"(val), "Nd"(port));
}

static void update_cursor() {
    uint16_t pos = cursor_y * COLUMNS + cursor_x;
    outb(0x3D4, 14);
    outb(0x3D5, pos >> 8);
    outb(0x3D4, 15);
    outb(0x3D5, pos);
}

static void scroll() {
    size_t i;
    for (i = 0; i < (LINES - 1) * COLUMNS; i++)
        VGA[i] = VGA[i + COLUMNS];
    for (i = (LINES - 1) * COLUMNS; i < LINES * COLUMNS; i++)
        VGA[i] = 0x0720; /* blank */
}

void console_putc(char c) {
    if (c == '\n') {
        cursor_x = 0;
        if (++cursor_y >= LINES) {
            scroll();
            cursor_y = LINES - 1;
        }
    } else {
        VGA[cursor_y * COLUMNS + cursor_x] = (0x07 << 8) | (uint8_t)c;
        if (++cursor_x >= COLUMNS) {
            cursor_x = 0;
            if (++cursor_y >= LINES) {
                scroll();
                cursor_y = LINES - 1;
            }
        }
    }
    update_cursor();
}

void vga_write(const char *s) {
    while (*s) {
        console_putc(*s++);
    }
} 
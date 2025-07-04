#include <slimeix/defs.h>

#define PORT 0x3F8  /* COM1 */

static inline void outb(unsigned short p, unsigned char v){__asm__("outb %0,%1"::"a"(v),"Nd"(p));}
static inline unsigned char inb(unsigned short p){unsigned char r;__asm__("inb %1,%0":"=a"(r):"Nd"(p));return r;}

void gtty_init(void){
    outb(PORT + 1, 0x00);
    outb(PORT + 3, 0x80);
    outb(PORT + 0, 1);       /* divisor lo */
    outb(PORT + 1, 0);       /* divisor hi */
    outb(PORT + 3, 0x03);    /* 8N1 */
    outb(PORT + 2, 0xC7);    /* FIFO */
}

static void gtty_putc(char c){
    while(!(inb(PORT + 5) & 0x20));
    outb(PORT, c);
}

void gtty_write(const char *s){
    while(*s) gtty_putc(*s++);
} 
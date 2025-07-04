.set ALIGN, 1<<0
.set MEMINFO, 1<<1
.set FLAGS, ALIGN | MEMINFO
.set MAGIC, 0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

.section .bss
    .lcomm stack, 0x4000

.section .text
.global _start
_start:
    mov $stack+0x4000, %esp
    call kmain
    cli
1:  hlt
    jmp 1b 
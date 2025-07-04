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
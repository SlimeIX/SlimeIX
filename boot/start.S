.section .bss
    .lcomm stack, 0x4000

.section .text
.global _start
.extern random_fill
_start:
    mov $stack, %edi
    mov $0x4000, %ecx
    call random_fill
    mov $stack+0x4000, %esp
    call kmain
    cli
1:  hlt
    jmp 1b 
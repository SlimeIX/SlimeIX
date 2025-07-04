.section .text
.global random_fill
# void random_fill(void *buf, unsigned len)
random_fill:
    push %ebp
    mov %esp, %ebp
    mov 8(%ebp), %edi   # buf
    mov 12(%ebp), %ecx  # len
    xor %eax, %eax
1:
    # попытка RDRAND (x86)
    .byte 0x0f, 0xc7, 0xf0  # rdrand %eax
    jc 2f
    # fallback: просто инкремент
    inc %eax
2:
    stosb
    loop 1b
    pop %ebp
    ret 
.code16
.global _boot
.org 0x7C00

_boot:
    cli
    xor %ax,%ax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%ss
    mov $0x7C00,%sp
    sti

    inb $0x92,%al
    or $0x02,%al
    out %al,$0x92

    mov $dap,%si
    mov $0x42,%ah
    int $0x13
    jc .fail

    lgdt gdt_ptr
    mov %cr0,%eax
    or $1,%eax
    mov %eax,%cr0
    jmp $0x08,$pm32

.code32
pm32:
    mov $0x10,%ax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%ss
    mov $0x200000,%esp

    mov $0x10000,%esi
    mov $0x100000,%edi
    mov $(KERNEL_BYTES/4),%ecx
    cld
    rep movsd

    jmp $0x08,$0x100000

.fail:
    hlt
    jmp .fail

.align 8
.gdt:
    .quad 0x0
    .quad 0x00CF9A000000FFFF
    .quad 0x00CF92000000FFFF
.gdt_end:

gdt_ptr:
    .word .gdt_end-.gdt-1
    .long .gdt

.align 16
dap:
    .byte 0x10,0
    .word KERNEL_SECTORS
    .word 0x0000
    .word 0x1000
    .long 1,0

.set KERNEL_SECTORS,200
.set KERNEL_BYTES,KERNEL_SECTORS*512

.org 510
.word 0xAA55
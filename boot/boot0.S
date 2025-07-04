.code16
.global _start
.org 0

START_ADDR equ 0x7E00

_start:
    cli
    xor %ax,%ax
    mov %ax,%ds
    mov %ax,%es
    mov %ax,%ss
    mov $0x7C00,%sp
    sti

    ; load boot1
    mov $dap,%si
    mov $0x42,%ah
    int $0x13
    jc .fail

    jmp START_ADDR

.fail:
    hlt
    jmp .fail

; disk address packet for boot1
.align 16
dap:
    .byte 0x10,0
    .word BOOT1_SECTORS
    .word START_ADDR & 0xF
    .word START_ADDR >> 4
    .long 1,0

.set BOOT1_SECTORS,16

.org 510
.word 0xAA55
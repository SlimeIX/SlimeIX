.intel_syntax noprefix
.code16
.global _start
.org 0

.equ START_ADDR, 0x7E00
.equ BOOT1_SECTORS, 16

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    mov [drive_num], dl
    sti

    in al, 0x92
    or al, 0x02
    out 0x92, al

    mov si, dap
    mov ah, 0x42
    int 0x13
    jc fail

    jmp START_ADDR

fail:
    hlt
    jmp fail

drive_num: .byte 0

# Disk Address Packet (16 bytes)
.align 16
dap:
    .byte 0x10, 0x00
    .word BOOT1_SECTORS
    .word 0x0000            # offset 0x7E00 & 0xF
    .word 0x07E0            # segment 0x7E0
    .long 1, 0

.org 510
.word 0xAA55
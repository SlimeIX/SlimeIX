.intel_syntax noprefix
.code16
.org 0x7E00
.global boot1_entry

.equ KERNEL_LBA, 17
.equ KERNEL_SECT, 16

boot1_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    # enable A20
    in al, 0x92
    or al, 2
    out 0x92, al

    # fallback 8042
    call empty_8042
    mov al, 0xD1
    out 0x64, al
    call empty_8042
    mov al, 0xDF
    out 0x60, al
    call empty_8042

    # reprogram PIC
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    mov al, 0xFF
    out 0x21, al
    out 0xA1, al

    # prepare DAP pointer DS:SI
    lea si, [dap]

    # set load segment 0x1000 in DAP and in ES
    mov ax, 0x1000
    mov word ptr [dap+6], ax   # buffer segment
    mov es, ax
    xor bx, bx                 # buffer offset 0 in DAP already

    mov ah, 0x0E
    mov al, 'R'
    int 0x10

    mov ah, 0x42               
    int 0x13
    jc disk_fail

    # debug: print 'O'
    mov ah, 0x0E
    mov al, 'O'
    int 0x10

    # switch to protected mode
    cli
    lgdt [gdt_ptr]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_start

.code32
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x200000
    jmp 0x00100000

.code16
disk_fail:
    hlt
    jmp disk_fail

# wait for KBC input buffer empty
empty_8042:
    in al, 0x64
    test al, 2
    jnz empty_8042
    ret

# Disk Address Packet (16 bytes)
.align 4
dap:
    .byte 0x10, 0x00
    .word KERNEL_SECT
    .word 0x0000        # buffer offset
    .word 0x0000        # buffer segment (patched)
    .long KERNEL_LBA
    .long 0x00000000

# GDT
.align 8
gdt:
    .quad 0x0000000000000000
    .quad 0x00CF9A000000FFFF
    .quad 0x00CF92000000FFFF

gdt_ptr:
    .word gdt_end - gdt - 1
    .long gdt

gdt_end:
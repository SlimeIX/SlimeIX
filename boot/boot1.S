.intel_syntax noprefix
.code16
.org 0x7E00
.global boot1_entry

.equ KERNEL_LBA, 17
.equ KERNEL_SECT, 400      # ~200KiB, adjust if kernel grows

boot1_entry:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; enable A20 fast gate
    in al, 0x92
    or al, 2
    out 0x92, al

    ; build disk address packet on stack
    push word 0x10          ; size
    push word 0             ; reserved
    push word KERNEL_SECT
    push word 0             ; offset
    push word 0x0000        ; segment 0 (ES loaded later)
    push dword KERNEL_LBA
    push dword 0            ; upper 32 bits

    ; ES:BX -> DAP (point to top of stack)
    mov bx, sp
    mov es, ax

    ; load to 0x100000 -> ES=0x1000, BX=0
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    ; BIOS int 13h ext read
    mov ah, 0x42
    int 0x13
    jc disk_fail

    ; switch to protected mode
    cli
    lgdt [gdt_ptr]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_entry

; 32-bit
.code32
pm_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x200000

    ; jump to kernel
    jmp 0x00100000

disk_fail:
    hlt
    jmp disk_fail

.align 8
gdt:
    .quad 0x0
    .quad 0x00CF9A000000FFFF
    .quad 0x00CF92000000FFFF

gdt_ptr:
    .word gdt_end - gdt - 1
    .long gdt

gdt_end:
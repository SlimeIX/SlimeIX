.intel_syntax noprefix
.code16
.global _start
.org 0

.equ START_ADDR, 0x7E00
.equ BOOT1_SECTORS, 16

_start:
    # debug: print 'M'
    mov ah, 0x0E
    mov al, 'M'
    int 0x10

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    mov [drive_num], dl
    sti

    # check if LBA supported
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc legacy_read

    # LBA read
    mov si, dap
    mov ah, 0x42
    int 0x13
    jc fail

    jmp START_ADDR

legacy_read:
    # CHS read fallback
    mov ah, 0x02
    mov al, BOOT1_SECTORS
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [drive_num]
    mov bx, START_ADDR
    int 0x13
    jc fail

    jmp START_ADDR

fail:
    hlt
    jmp fail

drive_num: .byte 0

.align 16
dap:
    .byte 0x10, 0x00
    .word BOOT1_SECTORS
    .word 0x0000            
    .word 0x07E0            
    .long 1, 0

# MBR partition table (4 entries, 16 bytes each)
.org 446
part1:
    .byte 0x80          # bootable
    .byte 0x01, 0x01, 0x00  # CHS start: head 1, sector 1, cylinder 0
    .byte 0x06          # FAT16 partition type
    .byte 0xFE, 0x3F, 0x00  # CHS end: head 254, sector 63, cylinder 1023
    .long 0x00000001    # LBA start: 1
    .long 0x0001F3FF    # LBA count: 128000 sectors (~64MB)

# remaining partitions empty
.fill 48, 1, 0          # fill remaining 3 partitions with zeros

.org 510
.word 0xAA55
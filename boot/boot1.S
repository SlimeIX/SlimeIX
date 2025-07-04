.intel_syntax noprefix
.code16
.org 0x7E00
.global boot1_entry

boot1_entry:
    mov si, msg
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je hang
    int 0x10
    jmp .loop

hang:
    hlt
    jmp hang

msg db 'Boot1 ready',0 
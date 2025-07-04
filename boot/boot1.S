.code16
.org 0x7E00

print:
    mov ah,0x0E
.msg:
    lodsb
    cmp al,0
    je hang
    int 0x10
    jmp .msg

hang:
    hlt
    jmp hang

msg db "Boot1 ready",0 
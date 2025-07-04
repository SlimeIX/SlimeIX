.intel_syntax noprefix
.code64
.global _start

.section .text
_start:
    # UEFI entry point
    push rbp
    mov rbp, rsp
    
    # save UEFI handles
    mov [efi_handle], rcx
    mov [efi_systab], rdx
    
    # get memory map
    lea r8, [memory_map_size]
    lea r9, [memory_map]
    mov rcx, [efi_systab]
    mov rcx, [rcx + 64]  # RuntimeServices
    call [rcx + 56]      # GetMemoryMap
    
    # load kernel
    lea rcx, [kernel_path]
    mov rdx, 0x100000
    call load_file
    
    # exit boot services
    mov rcx, [efi_handle]
    mov rdx, [memory_map_key]
    call [efi_systab + 64 + 72]  # ExitBootServices
    
    # jump to kernel
    jmp 0x100000

load_file:
    # simple file loading stub
    ret

.section .data
efi_handle: .quad 0
efi_systab: .quad 0
memory_map_size: .quad 0
memory_map_key: .quad 0
kernel_path: .asciz "\\EFI\\SLIMEIX\\KERNEL.BIN"

.section .reloc
    .long 0 
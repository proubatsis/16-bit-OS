[bits 16]
[org 0x7c00]

main:
    mov bp, 0x8000 ; Set up the stack
    mov sp, bp
    
    mov bx, loading_msg
    call print_string
    
    ; Load the file table
    push word file_table_sector
    call load_file_table
    
    ; Load kernel.bin from the floppy
    push word KERNEL_OFFSET
    push word KERNEL_SEGMENT
    push kernel_filename
    call open_file
    
    cmp ax, 0
    je drive_read_error
    
    ; Jump to the kernel
    jmp KERNEL_SEGMENT:KERNEL_OFFSET
    
drive_read_error:
    mov bx, error_msg
    call print_string
    jmp $
    
; print string starting at memory location in bx
print_string:
    mov ah, 0x0e      ; Write char function (int 0x10)
    
    .loop:
        mov al, [bx]  ; Load next char/byte from the string
        cmp al, 0     ; Has the end of the string been reached?
        je .done
        
        int 0x10      ; Place char in al on the screen
        inc bx        ; Point bx to the next char
        jmp .loop
    
    .done:
        ret
        
%include 'bootloader/memory.asm'
%include 'bootloader/strings.asm'
%include 'bootloader/file_io.asm'
        
; Messages
loading_msg db "Loading OS...", 0x0D, 0x0A, 0x00
error_msg db "ERROR - Did not load OS successfully!", 0x00

; Address of where the kernel will be loaded
KERNEL_SEGMENT equ 0x0000
KERNEL_OFFSET equ 0x8400

; The kernel's filename
kernel_filename db "kernel.bin", 0

; Sector of the floppy where the file system table is located
file_table_sector equ 4

; Fill with zeroes and place the magic number (0xAA55) at the end
times 510-($-$$) db 0
dw 0xaa55


[bits 16]
[org 0x7c00]

main:
    mov bp, 0x8000 ; Set up the stack
    mov sp, bp
    
    mov bx, loading_msg
    call print_string
    
    ; Read the kernel off of the floppy disk
    mov ah, 0x02    ; Read disk function
    mov al, 0x01    ; Read 1 sector
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x02    ; Sector 2 (After bootsector)
    mov dh, 0x00    ; Head 0
    mov dl, 0x00    ; Drive 0 (First Floppy Disk)
    
    ; Load kernel at address es:bx
    mov bx, KERNEL_SEGMENT
    mov es, bx
    mov bx, KERNEL_OFFSET
    
    ; Read from the floppy
    int 0x13

    ; Error checking    
    cmp ah, 0
    jne drive_read_error
    
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
        
; Messages
loading_msg db "Loading OS...", 0x0D, 0x0A, 0x00
error_msg db "ERROR - Did not load OS successfully!", 0x00

; Address of where the kernel will be loaded
KERNEL_SEGMENT equ 0x0000
KERNEL_OFFSET equ 0x8100

; Fill with zeroes and place the magic number (0xAA55) at the end
times 510-($-$$) db 0
dw 0xaa55


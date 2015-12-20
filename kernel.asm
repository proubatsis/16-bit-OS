[bits 16]
[org 0x8400]

main:
    mov bp, 0xFFFF
    mov sp, bp
    sub sp, 4
    
    push welcome_message
    call print_string
    
    push word 512
    call malloc
    
    mov bx, ax
    mov [bp - 2], bx
    
    push word [bx]
    push word malloc_segment
    push filename
    call open_file
    
    mov bx, [bp - 2]
    mov [bp - 4], ax
    
    push word 32
    push file_buffer
    push word 0
    push word [bx]
    push word malloc_segment
    call memcpy
    
    mov ax, [bp - 4]
    
    ; add null terminator to string
    mov bx, ax
    add bx, file_buffer
    mov [bx], word 0
    
    push file_buffer
    call print_string
    
    push word [bp - 2]
    call free
    
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/file_io.asm'
%include 'kernel/strings.asm'
%include 'kernel/memory.asm'

welcome_message db "Welcome to my OS!", 0x0D, 0x0A, 0x00

filename db "file.txt"
file_buffer: times 32 db 0



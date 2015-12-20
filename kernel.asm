[bits 16]
[org 0x8400]

main:
    mov bp, 0xFFFF
    mov sp, bp
    
    push welcome_message
    call print_string
    
    push file_buffer
    push word 0
    push filename
    call open_file
    
    push file_buffer
    call print_string
    
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/file_io.asm'
%include 'kernel/strings.asm'
%include 'kernel/memory.asm'

welcome_message db "Welcome to my OS!", 0x0D, 0x0A, 0x00

filename db "file.txt"
file_buffer: times 32 db 0



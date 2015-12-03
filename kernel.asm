[bits 16]
[org 0x8100]

main:
    mov bp, 0x8900
    mov sp, bp
    
    push welcome_message
    call print_string
    
    push word file_table_sector
    call load_file_table
    
    push file_buffer
    push word 0
    push filename
    call open_file
    
    ; add null terminator to string
    mov bx, ax
    add bx, file_buffer
    mov [bx], word 0
    
    push file_buffer
    call print_string
    
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/file_io.asm'
%include 'kernel/strings.asm'
%include 'kernel/memory.asm'

welcome_message db "Welcome to my OS!", 0x0D, 0x0A, 0x00

filename db "third_file.txt"
file_buffer: times 512 db 0

file_table_sector equ 4

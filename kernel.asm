[bits 16]
[org 0x8100]

main:
    mov bp, 0x8900
    mov sp, bp
    
    push welcome_message
    call print_string
    
    push word file_table_sector
    call load_file_table
    
    push filename
    call lookup_file
    
    cmp ax, 0
    je file_not_found
    
    push found_msg
    call print_string
    
    jmp $
    
file_not_found:
    push no_file_msg
    call print_string
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/file_io.asm'
%include 'kernel/strings.asm'

welcome_message db "Welcome to my OS!", 0x0D, 0x0A, 0x00

no_file_msg db "File not found!", 0x0D, 0x0A, 0x00
found_msg db "File Found!", 0x0D, 0x0A, 0x00

file_input: times 32 db 0
input_buffer: times 32 db 0

filename db "stuff.bin", 0

file_table_sector equ 3

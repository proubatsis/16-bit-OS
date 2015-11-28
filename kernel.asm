[bits 16]
[org 0x8100]

main:
    mov bp, 0x9000
    mov sp, bp
    
    push hello_world
    call print_string
    
    push input_buffer
    call input
    
    push input_buffer
    call print_string
    
    jmp $
    
%include 'kernel/std_io.asm'
    
hello_world: db "Hello, World, Type something please: ", 0
input_buffer: times 32 db 0

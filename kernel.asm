[bits 16]
[org 0x8100]

main:
    mov bp, 0x9000
    mov sp, bp
    
    push hello_world
    call print_string
    
    jmp $
    
%include 'kernel/io.asm'
    
hello_world: db "Hello, World", 0

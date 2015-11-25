[bits 16]
[org 0x8100]

main:
    mov bp, 0x9000
    mov sp, bp
    
    mov bx, hello_world
    call print_string
    
    jmp $
    
; Print string starting from memory location in bx
print_string:
    mov ah, 0x0e
    
    .loop:
        mov al, [bx]
        cmp al, 0
        je .done
        
        int 0x10
        inc bx
        jmp .loop
        
    .done:
        ret
    
hello_world: db "Hello, World", 0

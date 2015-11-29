[bits 16]
[org 0x8100]

main:
    mov bp, 0x8900
    mov sp, bp
    
    push password_message
    call print_string
    
    push input_buffer
    call input
    
    push password
    push input_buffer
    call compare_strings
    
    cmp ax, 0
    je grant_access
    jmp deny_access
    
    jmp $
    
grant_access:
    push access_granted
    call print_string
    jmp $
    
deny_access:
    push access_denied
    call print_string
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/strings.asm'

password: db "monkeys", 0
password_message: db "Enter the password: ", 0
access_granted: db "Access Granted!", 0
access_denied: db "Access Denied...", 0

input_buffer: times 32 db 0

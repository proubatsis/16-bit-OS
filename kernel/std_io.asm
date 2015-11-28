; print_string(char*) -> Returns nothing
; Print a string
print_string:

    ; Set up stack frame
    push bp
    mov bp, sp
    
    pusha ; Save all registers
    
    mov ah, 0x0e      ; 0x0e is the function to write a char to the screen with int 0x10
    mov bx, [ebp + 4] ; Get the first argument
    
    .loop:
        mov al, [bx]  ; Get the next char from bx
        cmp al, 0     ; Are we at the end of the string?
        je .done
        
        int 0x10      ; Print the character
        inc bx        ; Increment address to point to the next char
        jmp .loop
    
    .done:
        popa          ; Restore all registers
        
        mov sp, bp
        pop bp
        ret
    

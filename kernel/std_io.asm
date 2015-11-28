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
    
;input(char* buffer) -> Returns nothing
;keyboard input stored in the given buffer
input:
    ; Set up stack frame
    push bp
    mov bp, sp
    
    pusha ; Save all registers
    
    mov bx, [bp + 4] ; Get the start of the buffer
    
    .loop:
        mov ah, 0x00 ; Keyboard character input function for int 0x16
        int 0x16
        
        ; Print what was typed
        mov ah, 0x0E
        int 0x10
        
        cmp al, 0x0D ; Check for carriage return
        je .done
        
        mov [bx], al ; Store the character in the buffer
        inc bx       ; Move to the next address in the buffer

        jmp .loop
    
    .done:
    	mov ah, 0x0E     ; Print new line
    	mov al, 0x0A
    	int 0x10
    	
        mov [bx], byte 0 ; End of string
        popa             ; Restore all registers
        
        mov sp, bp
        pop bp
        ret
        

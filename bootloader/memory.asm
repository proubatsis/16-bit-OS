; memcpy(byte* src_seg, byte* src_off, byte* dst_seg, byte* dst_off, word count)
; copy 'count' amount of bytes from src to dst
memcpy:
    push bp
    mov bp, sp
    sub sp, 4            ; Two local variables
    
    pusha
    
    mov ax, [bp + 6]
    mov [bp - 2], ax     ; src_off into first local variable
    
    mov ax, [bp + 10]
    mov [bp - 4], ax     ; dst_off into second local variable
    
    mov cx, [bp + 12]    ; Put count into cx
    
    .loop:
        mov bx, [bp + 4]
        mov es, bx       ; src_seg into segment register
        mov bx, [bp - 2] ; src_off into bx
        
        mov al, [es:bx]  ; store value from src
        
        mov bx, [bp + 8]
        mov es, bx       ; dst_seg into segment register
        mov bx, [bp - 4] ; dst_off into bx
        
        mov [es:bx], al  ; copy value from src to dst
        
        dec cx
        
        cmp cx, 0        ; are we done copying?
        je .done
        
        inc word [bp - 2]
        inc word [bp - 4]
        
        jmp .loop
    
    .done:
        popa
        
        mov sp, bp
        pop bp
        ret
        

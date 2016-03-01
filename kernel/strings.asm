; Copyright (C) 2016  Panagiotis Roubatsis
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License along
;    with this program; if not, write to the Free Software Foundation, Inc.,
;    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


; compare_strings(char*, char*)
; Return 0 (in ax) if the strings are equal
compare_strings:
    push bp
    mov bp, sp
    sub sp, 2 ; One local variable (Flag)
    
    pusha
    
    mov [bp - 2], word 0 ; Flag = 0
    mov bx, [bp + 4]
    mov si, [bp + 6]
    
    .loop:
        mov ah, byte [bx]
        mov al, byte [si]
        cmp ah, al     ; Compare the characters in each string
        jne .not_equal
        
        cmp ah, 0      ; Has the end of the string been reached?
        je .done
        
        ; Go to the next char
        inc bx
        inc si
        jmp .loop
    
    .not_equal:
        inc word [bp - 2] ; Flag++ (Therefore the strings aren't equal)
    
    .done:
        popa
        
        ; Return the flag to indicate whether the strings are equal or not
        mov ax, [bp - 2]
        
        mov sp, bp
        pop bp
        
        ret

; get_length(char*)
; Return (in ax) the length of the string (iterations until null).
get_length:
    push bp
    mov bp, sp

    push bx          ; bx and dx will be modified, save them.
    push dx
    
    mov bx, [bp + 4] ; Address of first char
    mov ax, 0        ; Length counter
    
    .loop:
        mov dl, [bx]
        
        cmp dl, 0    ; End of string?
        je .done
        
        inc ax       ; increment char count (length)
        inc bx       ; goto next char
        jmp .loop
        
    .done:
        pop dx       ; restore bx and dx
        pop bx
        
        mov sp, bp
        pop bp
        ret
        

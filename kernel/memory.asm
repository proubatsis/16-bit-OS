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
        
; malloc(word size)
; Allocate memory of size 'size' in bytes. Memory is allocated at
; the segment 'malloc_segment' and the address of the 
; offset is returned (the offset value may be changed by a call to free).
malloc:
    push bp
    mov bp, sp
    
    ; Get end of malloc_table to add to it
    mov di, malloc_table_head
    .loop:
        mov ax, [di + 4]
        cmp ax, 0
        
        je .allocate
        
        add di, 6
        jmp .loop
        
    .allocate:
        mov ax, [malloc_offset]
        mov [di], ax
        
        add ax, [bp + 4]        ; End address of the offset
        mov [malloc_offset], ax ; Store the new offset
        
        ; Store size in table
        mov ax, [bp + 4]
        mov [di + 2], ax
        
        ; Store next element address in table
        mov ax, di
        add ax, 6
        mov [di + 4], ax
        
        mov ax, di              ; Return the address that refers to the offset of the allocated memory
        
        mov bp, sp
        pop bp
        
        ret

; free(word* malloc_table_item)
; Free the item returned by a call to malloc
; so that the memory can be used by something else.
free:
    push bp
    mov bp, sp
    sub sp, 4 ; Two local variables
    
    ; Iterate the list and look for the provided element
    mov bx, [bp + 4]
    mov si, malloc_table_head
    .remove_loop:
        cmp [si + 4], bx
        je .remove_node
        
        mov di, [si + 4] ; Goto next node
        mov si, [di]
        jmp .remove_loop
        
    ; Remove the node from the linked list
    .remove_node:
        mov ax, [bx + 4] ; Get what the node to be removed points to
        mov [si + 4], ax ; Set the previous node to point to what the removed node pointed to
    
    ; Decrease malloc_offset by the size of the allocated memory
    mov bx, [bp + 4]
    mov ax, [malloc_offset]
    mov [bp - 2], ax     ; Save the original offset
    sub ax, [bx + 2]
    mov [malloc_offset], ax
    
    ; Save the size of the node
    mov ax, [bx + 2]
    mov [bp - 4], ax
    
    ; Shift all the data to free up space at the address in malloc_offset
    mov dx, [bx]
    add dx, [bx + 2]
    mov ax, [bp - 2]
    sub ax, dx ; Calculate count
    push ax
    
    ; Destination offset & segment
    push word [bx]
    push word malloc_segment
    
    ; Calculate source offset
    mov ax, [bx]
    add ax, [bx + 2]
    push ax
    push word malloc_segment
    
    call memcpy
    
    
    ; Decrement all remaining sizes in the table by the size of this node
    mov si, malloc_table_head
    mov di, [si + 4]
    mov si, [di]
    .decrement_loop:
        cmp word [si], word 0
        je .done
        
        ; Decrement
        mov ax, [si + 2]
        sub ax, [bp - 4]
        mov [si + 2], ax
        
        ; Next node
        mov di, [si + 4]
        mov si, [di]
        jmp .decrement_loop
    
    .done:
        mov sp, bp
        pop bp
        ret

malloc_segment equ 0x2000
malloc_offset dw 0x0000

; First entry in malloc table (head node)
malloc_table_head:
dw 0xFFFF ; 0xFFFF offset represents head node
dw 0      ; Any value, doesn't matter.
dw malloc_table

malloc_table times 1530 dw 0; Linked list of offsets and sizes. Format:
                            ; offset    dw
                            ; size      dw
                            ; next_item dw

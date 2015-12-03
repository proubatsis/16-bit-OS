; read_floppy(word buffer_segment, word buffer_offset, byte start_sector, byte sector_count)
; Read from the floppy disk at the start_sector for sector_countand store the result at
; the address buffer_segment:buffer_offset.
read_floppy:
    push bp
    mov bp, sp
    pusha
    
    mov ah, 0x02     ; Read from floppy function (int 0x16)
    mov cl, [bp + 8] ; start_sector
    mov al, [bp + 10]; sector_count
    mov ch, 0x00     ; Cylinder 0
    mov dh, 0x00     ; Head 0
    mov dl, 0x00     ; Drive 0 (First Floppy)
    
    mov bx, [bp + 4]
    mov es, bx       ; buffer_segment
    mov bx, [bp + 6] ; buffer_offset
    
    int 0x13         ; Read disk
    
    popa
    mov sp, bp
    pop bp
    ret

; load_file_table(byte sector)
; Load the file table from the given sector
; of the floppy into memory adress 0x8A00.
load_file_table:
    push bp
    mov bp, sp
    
    push word 1        ; Read 1 sector
    push word [bp + 4] ; Read the given sector
    push word file_table_offset
    push word file_table_segment
    call read_floppy
    
    mov sp, bp
    pop bp
    ret
    
file_table_segment equ 0x0000
file_table_offset equ 0x8A00

; lookup_file(char* filename)
; Lookup the given filename in the file table.
; If the file is found return the address of its
; properties starting at the first sector parameter (after filename and next address).
; Otherwise return 0.
; Assumes that load_file_table has already been called and that
; strings.asm has been imported.
lookup_file:
    push bp
    mov bp, sp
    sub sp, 2
    
    mov [bp - 2], word file_table_offset
    
    .loop:
        push word [bp - 2]
        push word [bp + 4]
        call compare_strings
        
        cmp ax, 0
        je .found
        
        push word [bp - 2] ; Get the length of the string in the table
        call get_length
        
        ; Goto next item
        add ax, [bp - 2]   ; End of string
        inc ax             ; Next parameter
        mov bx, ax
        mov bx, [bx]       ; Point bx to the next item
        mov [bp - 2], bx
        
        ; No items left
        cmp bx, 0
        je .not_found
        
        jmp .loop
    
    .not_found:
        mov ax, 0
        jmp .done
        
    .found:
        push word [bp - 2]
        call get_length
        add ax, [bp - 2] ; Skip the string
        add ax, 2        ; Skip the first parameter
        
    .done:
        mov sp, bp
        pop bp
        ret
        
        
; open_file(char* filename, byte* dst_seg, byte* dst_off)
; Open the file with the given filename and
; store its contents in dst. Return the size of the file.
; Return 0 if there was an error.
; Assumes that memory.asm has already been imported.
open_file:
    push bp
    mov bp, sp
    sub sp, 2 ; One local variable
    
    ; lookup the filename
    push word [bp + 4]
    call lookup_file
    
    ; was the file not found?
    cmp ax, 0
    je .error
    
    mov bx, ax
    
    mov ah, 0
    
    ; sector count
    mov al, [bx + 2]
    push ax
    
    ; start sector
    mov al, [bx + 1]
    push ax
    
    ; destination offset
    push word [bp + 8]
    
    ; destination segment
    push word [bp + 6]
    
    ; read the disk
    call read_floppy
    
    ; save the file size
    mov dx, [bx + 5]
    mov [bp - 2], dx
    
    ; file offset
    mov ax, [bx + 3]
    cmp ax, 0
    je .done
    
    ; memory offset
    add ax, [bp + 8]
    
    mov si, ax
    mov di, [bp + 8]
    
    ; memcpy count is the size of the file
    push word [bp - 2]
    
    ; destination
    push di
    push word [bp + 6]
    
    ; source
    push si
    push word [bp + 6]
    
    call memcpy
    jmp .done
    
    .error:
        mov ax, 0
        mov [bp - 2], ax
        
    .done:
        mov ax, [bp - 2]
        
        mov sp, bp
        pop bp
        ret
        

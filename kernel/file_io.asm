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


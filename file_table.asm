[bits 16]

; This table sits in the sector after the kernel on the floppy.
; It's used to lookup files on the floppy given the name of a file.

; Format
; string: file name ending with null teriminator (0)
; byte: first sector the file is located on
; byte: how many sectors the file sits on
; byte: offset -> how many bytes after the start of the sector the file is located
; byte: flags (read, write, execute) (00000100 or 0x04 = Read) (00000010 or 0x02 = Write) (00000001 or 0x01 = Execute)

db "test_file.txt", 0
db 4
db 1
db 0
db 0x06

db "stuff.bin", 0
db 5
db 1
db 0
db 0x07


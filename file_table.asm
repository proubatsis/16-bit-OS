[bits 16]
[org 0x8A00]

; This table sits in the sector after the kernel on the floppy.
; It's used to lookup files on the floppy given the name of a file.

; Format
; string: file name ending with null teriminator (0)
; word: address of the next file parameters, 0 if it's the last one.
; byte: first sector the file is located on
; byte: how many sectors the file sits on
; byte: offset -> how many bytes after the start of the sector the file is located
; byte: flags (read, write, execute) (00000100 or 0x04 = Read) (00000010 or 0x02 = Write) (00000001 or 0x01 = Execute)

file1:
db "test_file.txt", 0
dw file2
db 4
db 1
db 0
db 0x06

file2:
db "stuff.bin", 0
dw file3
db 5
db 1
db 0
db 0x07

file3:
db "helloworld", 0
dw 0
db 6
db 1
db 0
db 0x06

[bits 16]
[org 0x8100]

; This table sits in the sector after the kernel on the floppy.
; It's used to lookup files on the floppy given the name of a file.

; Format
; string: file name ending with null teriminator (0)
; word: address of the next file parameters, 0 if it's the last one.
; byte: first sector the file is located on
; byte: how many sectors the file sits on
; word: offset -> how many bytes after the start of the sector the file is located
; word: size of the file in bytes
; byte: flags (read, write, execute) (00000100 or 0x04 = Read) (00000010 or 0x02 = Write) (00000001 or 0x01 = Execute)

kernel:
db "kernel.bin", 0
dw file1
db 2
db 2
dw 0
dw 999
db 0x05

file1:
db "test.txt", 0
dw file2
db 5
db 1
dw 0
dw 18
db 0x06

file2:
db "third_file.txt", 0
dw file3
db 5
db 1
dw 18
dw 16
db 0x06

file3:
db "file.txt", 0
dw 0
db 5
db 1
dw 34
dw 14
db 0x06

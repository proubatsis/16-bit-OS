[bits 16]
[org 0x8400]


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


main:
    mov bp, 0xFFFF
    mov sp, bp
    
    push welcome_message
    call print_string
    
    push file_buffer
    push word 0
    push filename
    call open_file
    
    push file_buffer
    call print_string
    
    jmp $
    
%include 'kernel/std_io.asm'
%include 'kernel/file_io.asm'
%include 'kernel/strings.asm'
%include 'kernel/memory.asm'

welcome_message db "Welcome to my OS!", 0x0D, 0x0A, 0x00

filename db "file.txt"
file_buffer: times 32 db 0



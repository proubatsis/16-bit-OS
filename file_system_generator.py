#!/usr/bin/python

import math
import sys
import os

# Files
COMBINED_FILE = "files.bin"
FILE_TABLE_FILE = "file_table.asm"

# File table information
FILE_TABLE_HEADER = "[bits 16]\n[org 0x8100]\n"
FLOPPY_SECTOR_SIZE = 512
DEFAULT_RWX = 0x07
BASE_SECTOR = 3 # After the bootloader and file table

ASM_BYTE = "db"
ASM_WORD = "dw"

def combine_files(files_list, output_file):
    """ (list of files open for binary reading, file open for binary writing) -> None
    
    Place the contents of all the files in files_list into the output_file.
    """
    
    for f in files_list:
        output_file.write(f.read())
        
def file_name_to_label(file_name):
    """ (str) -> str
    
    Return the file name as a label for the file table entry (Remove period to combine file name and extension).
    
    >>> print(file_name_to_label("example.txt"))
    exampletxt
    """
    
    return file_name.replace(".", "")
    
class FileTableEntry:
    """ Represents an entry in a file table """
    
    def __init__(self, file_name, next_label, sector, sector_count, sector_offset, file_size, read_write_exec_flags):
        """ (FileTableEntry, str, str, int, int, int, int, int) -> None
        
        Create a file table entry.
        """
        
        self.file_name = file_name
        self.next_label = next_label
        self.sector = sector
        self.sector_count = sector_count
        self.sector_offset = sector_offset
        self.file_size = file_size
        self.read_write_exec_flags = read_write_exec_flags
        
    def __str__(self):
        """ (FileTableEntry) -> str
    
        Return a str that represents an entry in the file table.
    
        >>> entry = FileTableEntry('kernel.bin', 'file1', 2, 2, 0, 1024, 7)
        >>> print(entry)
        kernelbin:
        db "kernel.bin", 0
        dw file1
        db 2
        db 2
        dw 0
        dw 1024
        db 7
        """
        
        entry = file_name_to_label(self.file_name) + ":\n"
        entry += "{0} \"{1}\", 0\n".format(ASM_BYTE, self.file_name)
        entry += "{0} {1}\n".format(ASM_WORD, self.next_label)
        entry += "{0} {1}\n{0} {2}\n".format(ASM_BYTE, self.sector, self.sector_count)
        entry += "{0} {1}\n{0} {2}\n".format(ASM_WORD, self.sector_offset, self.file_size)
        entry += "{0} {1}".format(ASM_BYTE, self.read_write_exec_flags)
        
        return entry
        
class FileTable:
    """ Represents a file table """
    
    def __init__(self, start_sector = 1):
        """ (FileTable, int) -> None
        
        Create an empty file table.
        """
        
        self.entries = []
        self.base_sector = start_sector
        self.current_size = 0
    
    def add_entry(self, entry_index, file_names, file_sizes):
        """ (FileTable, int, list of str, list of int) -> None
        
        Precondition: len(file_names) == len(file_sizes)
        and 0 <= entry_index < len(file_names).
        
        Add an entry to the file table. Add an entry for the the file
        at entry_index of the specificed by the lists file_names, labels,
        and file_sizes.
        
        >>> table = FileTable(2)
        >>> names = ['kernel.bin', 'example.txt']
        >>> sizes = [1024, 18]
        >>> table.add_entry(0, names, sizes)
        >>> print(table.entries[0])
        kernelbin:
        db "kernel.bin", 0
        dw exampletxt
        db 2
        db 2
        dw 0
        dw 1024
        db 7
        """
        
        # Obtain required data from the lists
        file_name = file_names[entry_index]
        
        next_label = "0"
        if entry_index < len(file_names) - 1:
            next_label = file_name_to_label(file_names[entry_index + 1])
            
        size = file_sizes[entry_index]
        
        # Calculate all other data
        offset = self.current_size % FLOPPY_SECTOR_SIZE
        sector = int(self.current_size / FLOPPY_SECTOR_SIZE) + self.base_sector
        sector_count = int(math.ceil((size + offset) / float(FLOPPY_SECTOR_SIZE)))
        
        # Update file table
        self.current_size += size
        
        entry = FileTableEntry(file_name, next_label, sector, sector_count, offset, size, DEFAULT_RWX)
        self.entries.append(entry)
        
    def __str__(self):
        output = FILE_TABLE_HEADER + "\n"
        
        for entry in self.entries:
            output += str(entry) + "\n\n"
        
        return output
        

file_names = sys.argv[1:]
file_sizes = list(map(lambda fname: os.path.getsize(fname), file_names))

# Combine all the files passed in via the command line into one file
# specified by the COMBINED_FILE constant.
files = list(map(lambda fname: open(fname, "rb"), file_names))
output_file = open(COMBINED_FILE, "wb")

combine_files(files, output_file)

output_file.close()
for f in files: f.close()

# Generate the file table
table = FileTable(BASE_SECTOR)
for i in range(len(file_names)):
    table.add_entry(i, file_names, file_sizes)
    
file_table_output = open(FILE_TABLE_FILE, "w")
file_table_output.write(str(table))
file_table_output.close()



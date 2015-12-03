all: os.img
	mkdir build
	mv os.img build/os.img
	mv bootloader.bin build/bootloader.bin
	mv kernel.bin build/kernel.bin
	mv file_table.bin build/file_table.bin
	mv combined.bin build/combined.bin

os.img: bootloader.bin kernel.bin file_table.bin combined.bin
	dd if=/dev/zero of=os.img bs=512 count=2880
	dd if=bootloader.bin of=os.img conv=notrunc
	dd if=kernel.bin of=os.img conv=notrunc bs=512 seek=1
	dd if=file_table.bin of=os.img conv=notrunc bs=512 seek=3
	dd if=combined.bin of=os.img conv=notrunc bs=512 seek=4

bootloader.bin: bootloader.asm
	nasm -f bin -o bootloader.bin bootloader.asm
	
kernel.bin: kernel.asm kernel/std_io.asm kernel/file_io.asm kernel/strings.asm
	nasm -f bin -o kernel.bin kernel.asm

file_table.bin: file_table.asm
	nasm -f bin -o file_table.bin file_table.asm
	
combined.bin: file.txt test.txt third_file.txt
	cat test.txt third_file.txt file.txt >> combined.bin

clean:
	rm -r build
	


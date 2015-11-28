os.img: build_path bootloader.bin kernel.bin
	dd if=/dev/zero of=build/os.img bs=512 count=2880
	dd if=build/bootloader.bin of=build/os.img conv=notrunc
	dd if=build/kernel.bin of=build/os.img conv=notrunc bs=512 seek=1

bootloader.bin:
	nasm -f bin -o build/bootloader.bin bootloader.asm
	
kernel.bin:
	nasm -f bin -o build/kernel.bin kernel.asm
	
build_path:
	mkdir build

clean:
	rm -r build
	


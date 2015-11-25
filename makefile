os.img: bootloader.bin kernel.bin
	dd if=/dev/zero of=os.img bs=512 count=2880
	dd if=bootloader.bin of=os.img conv=notrunc
	dd if=kernel.bin of=os.img conv=notrunc bs=512 seek=1

bootloader.bin:
	nasm -f bin -o bootloader.bin bootloader.asm
	
kernel.bin:
	nasm -f bin -o kernel.bin kernel.asm

clean:
	rm os.img
	rm bootloader.bin
	rm kernel.bin


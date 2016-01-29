all: forth.o
	ld -m elf_i386 forth.o
#	xxd a.out > a.hex 

forth.o: forth.s
	nasm -f elf -F dwarf -g forth.s # -l a.lst

clean:
	rm forth.o a.out a.hex a.lst

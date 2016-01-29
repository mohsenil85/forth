all: forth.o
	ld -m elf_i386 forth.o

forth.o: forth.s
	nasm -f elf -F dwarf -g forth.s

clean:
	rm forth.o a.out

all: forth.o
	ld -m elf_i386 -g forth.o

forth.o: forth.s
	nasm -f elf32 -g -F stabs forth.s

clean:
	rm forth.o a.out

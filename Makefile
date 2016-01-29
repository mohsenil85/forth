all: forth.o
	gcc -m32 forth.o

forth.o: forth.s
	nasm -f elf32 -g -F stabs forth.s

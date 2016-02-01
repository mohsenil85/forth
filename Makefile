forth.nasm.out: forth.o
	ld -m elf_i386 forth.o -o forth.nasm.out
#	xxd a.out > a.hex 

forth.nasm.o: forth.s
	nasm -f elf32 -F dwarf -g forth-nasm.asm -o forth.nasm.o # -l a.lst
gas:
	gcc -m32 -static -nostdlib -g forth.S

.PHONY: clean
clean:
	rm *.o *.out #;rm  a.hex a.lst			

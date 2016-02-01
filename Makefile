# all: forth.o
# 	ld -m elf_i386 forth.o
#	xxd a.out > a.hex 

# forth.o: forth.s
# 	nasm -f elf32 -F dwarf -g forth.s # -l a.lst
all:
	gcc -m32 -static -nostdlib -g forth.S

.PHONY: clean
clean:
	rm forth.o a.out #;rm  a.hex a.lst			

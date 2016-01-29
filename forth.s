	;; forth.s
	;; Wed Jan 27 18:47:05 PST 2016
	;; should all be in 32bit intel?

	%macro NEXT 0
	lodsw
	jmp [eax]
	%endm

	%macro PUSHRSP 1
	lea ebp, [ebp-4]	;make space on the ebp stack
	mov ebp, %1		;store whats in ARG on there
	%endm

	%macro POPRSP 1
	mov %1,ebp		;pop whats on ebp, return to REG
	lea ebp, [ebp+4]	;move stack pointer "up" or "back"
	%endm


section .data

msg:    db      "Hennnnnnrld!",0x0a
len:	equ 	$ - msg
        

section .text

DOCOL:
	PUSHRSP esi
	add eax, 4
	mov esi, eax

global 	_start
_start:
	mov eax, 1
	mov ebx, 2
	mov ecx, 3
	mov edx, 4
	PUSHRSP edx
	POPRSP eax
	;NEXT
	;do writing
	mov edx, len	;load length
	mov ecx, msg	;load string
	mov ebx, 1	;stdout
	mov eax, 4	;syscall for write
	int 0x80	;call kernel

	
	;exit
	mov ebx, 0 ;exit status
	mov eax, 1 ;syscall for exit
	int 0x80	;call kernel
	

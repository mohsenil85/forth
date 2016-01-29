	;; forth.s
	;; Wed Jan 27 18:47:05 PST 2016
	;; should all be in 32bit intel?

	%macro NEXT 0
	lodsd
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

;	%macro defcode 4,0 ;name,namelen,label,flags=0
;	section .rodata
;	align 4
;	global %1_%3 ;ie, name_label
;%1_%3:
	



section .data
	msg:    db      "Hennnnnnrld!",0x0a
	len:	equ 	$ - msg

section .text
	align 4

;;;;my stuff
kernel:
	int 0x80	;call kernel
	
write_thing:
	mov edx, len	;load length
	mov ecx, msg	;load string
	mov ebx, 1	;stdout
	mov eax, 4	;syscall for write
	call kernel

bye:
	mov ebx, 0 	;exit status
	mov eax, 1 	;syscall for exit
	call kernel

;;;;jonestuff

DOCOL:
	PUSHRSP esi
	add eax, 4
	mov esi, eax

global 	_start
_start:
	cld 		;clear direction flag (?)
	mov esp, cold_start
	lodsd
	jmp [eax]
	;NEXT
	
section .rodata

cold_start:
	mov eax, 1
	mov ebx, 2
	mov ecx, 3
	mov edx, 4
	
	call write_thing

	call bye	
	
	

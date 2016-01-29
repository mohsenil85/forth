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
	;RETURN_STACK_SIZE: db 8192
	;BUFFER_SIZE: db 4096

section .bss
	my_var: resw 32
	var_s0:	resw 32 	;stores addr at top of param stack 	
	resb 4096
return_stack:
	resb 8192
return_stack_top: 
	resb 4096
buffer:
	resb 4096


section .text
	align 4

;;;;my stuff
sys_call:
	int 0x80	;call sys_call
	
write_thing:
	mov edx, len	;load length
	mov ecx, msg	;load string
	mov ebx, 1	;stdout
	mov eax, 4	;syscall for write
	call sys_call

bye:
	mov ebx, 0 	;exit status
	mov eax, 1 	;syscall for exit
	call sys_call

;;;;jonestuff

DOCOL:
	PUSHRSP esi
	add eax, 4
	mov esi, eax
	NEXT

global 	_start
_start:
	cld 		;clear direction flag (?)
	mov esp, cold_start
	mov [$var_s0], esp
	mov eax, 1
	mov ebx, 2
	mov ecx, 3
	mov edx, 4
	mov [$my_var], eax
	push dword [eax]
	push dword [ebx]
	push dword [ecx]
	push dword [edx]
	call bye
	
section .rodata

cold_start:
	mov eax, 1
	mov ebx, 2
	mov ecx, 3
	mov edx, 4
	
	call write_thing

	call bye	
	
	

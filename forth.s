            ;; forth.s
            ;; Wed Jan 27 18:47:05 PST 2016
            ;; should all be in 32bit intel?

	%macro NEXT 0
	lodsw
	jmp [eax]
	%endm

	%macro PUSHRSP 1
	lea ebp, [ebp-4]
	mov $1, [ebp]
	%endmacro

section .data
msg:    db      "Hennnnnnrld!",0x0a
len:	equ 	$ - msg
        

section .text

global 	_start

_start:
	mov eax, 1
	mov ebx, 1
	mov ecx, 1
	mov edx, 1
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
	

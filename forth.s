            ;; forth.s
            ;; Wed Jan 27 18:47:05 PST 2016
            ;; should all be in 32bit intel?

%macro NEXT 0
    lodsw
    jmp [eax]
%endmacro

        global _start

_start: 
	;do writing
	mov edx, len	;stdout
	mov ecx, msg	;stdout
	mov ebx, 1	;stdout
	mov eax, 4	;syscall for write
	int 0x80	;call kernel
	
	;exit
	mov ebx, 0 ;exit status
	mov eax, 1 ;syscall for exit
	
	

        
section .data
msg:    db      "Hello world!", 10
len:    equ $ - msg
        

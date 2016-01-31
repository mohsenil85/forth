;; forth.s
;; Wed Jan 27 18:47:05 PST 2016
        
%macro NEXT 0
        lodsd
        jmp  eax 
%endm

%macro PUSHRSP 1
        lea ebp, [ebp-4]	;make space on the ebp stack
        mov ebp, %1		;store whats in ARG on there
%endm

%macro POPRSP 1
        mov %1,ebp		;pop whats on ebp, return to REG
        lea ebp, [ebp+4]	;move stack pointer "up" or "back"
%endm

        
section .text
align 4

;;;;my stuff
        
write_thing:
        mov edx, len	;load length
        mov ecx, msg	;load string
        mov ebx, 1	;stdout
        mov eax, 4	;syscall for write
        int 0x80
        ret
        
bye:
        mov ebx, 0 	;exit status
        mov eax, 1 	;syscall for exit
        int 0x80
        
;;;;jonestuff

DOCOL:
        PUSHRSP esi
        add eax, 4
        mov esi, eax
        NEXT

global 	_start
_start:
        cld 		;clear direction flag (?)
        mov ebp, var_S0
        call set_up_data_segment
        mov esi, cold_start 
        NEXT
        
        ;;call bye                
        
;;;section .rodata

cold_start:
        call write_thing
        call bye                
        

section .text
set_up_data_segment:
        xor ebx, ebx
        mov eax, 45             ;linux brk
        int 0x80
        mov [var_HERE], eax     ;initalize HERE with where the break starts
        add eax,INITIAL_DATA_SEGMENT_SIZE ;add 10000 to it
        mov ebx, eax                      ;call brk with the new addr
        mov eax, 45
        int 0x80                  ;syssegv
        ret

section .bss
my_var: resw 32
var_S0:	resw 32 	;stores addr at top of param s tack 	
var_HERE: resw 32
        resb 4096
return_stack:
        resb 8192
return_stack_top: 
        resb 4096
buffer:
        resb 4096

section .data
link: db 0
msg:    db      "Hennnnnnrld!",0x0a
len:	equ 	$ - msg
        ;RETURN_STACK_SIZE: db 8192
        ;BUFFER_SIZE: db 4096
INITIAL_DATA_SEGMENT_SIZE: dd 0x10000
initial_break:
        dd 0x0
current_break:
        dd 0x0
new_break:
        dd 0x0
        

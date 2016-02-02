        ## forth.S
        ## Wed Jan 27 18:47:05 PST 2016

        .macro NEXT
        lodsl
        jmp *(%eax)
        .endm 

        .macro PUSHRSP reg 
        lea -4(%ebp),%ebp      #make space on the ebp stack
        movl \reg,(%ebp)          #store whats in reg on there
        .endm 

        .macro POPRSP reg 
        mov (%ebp),\reg          #pop whats on ebp, return to REG
        lea 4(%ebp),%ebp       #move stack pointer "up" or "back"
        .endm 


        .text
        .align 4

        ####my stuff

write_thing: 
        movl $len,%edx         #load length
        movl $msg,%ecx         #load string
        movl $1,%ebx           #stdout
        movl $4,%eax           #syscall for write
        int $0x80

bye: 
        movl $0,%ebx    #exit status
        movl $1,%eax    #syscall for exit
        int $0x80

        .text
        .align 4
DOCOL: 
        PUSHRSP %esi //push esi on return stack
        addl $4,%eax //make eax point to firt data word
        movl %eax,%esi
        NEXT

        .text
        .globl _start
_start: 
        cld             #clear direction flag (?)
        mov %esp,var_S0 
        mov $return_stack_top, %ebp
        call set_up_data_segment

        mov $cold_start, %esi
        NEXT

        .section .rodata

cold_start: 
        .int QUIT

        .set F_IMMED,0x80
        .set F_HIDDEN,0x20
        .set F_LENMASK,0x1f

        .set link,0 //link

        call write_thing
        call bye

        .macro defword name, namelen, flags=0,label
        .section .rodata
        .align 4
        .globl name_\label
name_\label :
        .int link
        .set link,name_\label
        .byte \flags+\namelen
        .ascii "\name"
        .align 4
        .globl \label
\label :
        .int DOCOL
        .endm

        .macro defcode name, namelen, flags=0, label
        .section .rodata
        .align 4
        .globl name_\label
name_\label :
        .int link
        .set link,name_\label
        .byte \flags+\namelen
        .ascii "\name"
        .align 4
        .globl \label
\label :
        .int code_\label //different
        .text
        .globl code_\label
code_\label :
        .endm


        //FORTH PRIMITIVES

        defcode "DROP",4,,DROP
        pop %eax
        NEXT

        defcode "SWAP",4,,SWAP
        pop %eax
        pop %ebx
        push %eax
        push %ebx
        NEXT

        defcode "DUP",3,,DUP
        mov (%esp),%eax
        push %eax
        NEXT

        defcode "OVER",4,,OVER
        mov 4(%esp),%eax //second elt of stack
        push %eax
        NEXT

        defcode "ROT",3,,ROT
        pop %eax
        pop %ebx
        pop %ecx
        push %ebx
        push %eax
        push %ecx
        NEXT

        defcode "-ROT",4,,NROT
        pop %eax
        pop %ebx
        pop %ecx
        push %eax
        push %ecx
        push %ebx
        NEXT

        defcode "EXIT",4,,EXIT
        POPRSP %eax
        NEXT

        defcode "LIT",3,,LIT
        lodsl
        push %eax
        NEXT


        .macro defvar name,namelen,flags=0,label,initial=0
        defcode \name, \namelen, \flags, \label
        push $var_\name
        NEXT
        .data
        .align 4
var_\name :
        .int \initial
        .endm
        
        defvar "STATE",5,,STATE
        defvar "HERE",4,,HERE
        defvar "LATEST",6,,LATEST #,name_SYSCALL0
        defvar "S0",2,,SZ
        defvar "BASE",4,,BASE


        .macro defconst name, namelen, flags=0, label, value
        defcode \name, \namelen, \flags, \label
        push $\value
        NEXT
        .endm

#include <sys/syscall.h>

        defconst "R0",2,,RZ,return_stack_top
        defconst "DOCOL",5,,__DOCOL,DOCOL
        defconst "F_IMMED",7,,__F_IMMED,F_IMMED
        defconst "F_HIDDEN",8,,__F_HIDDEN,F_HIDDEN
        defconst "F_LENMASK",9,,__F_LENMASK,F_LENMASK

        defconst "SYS_EXIT",8,,SYS_EXIT,__NR_exit
        defconst "SYS_OPEN",8,,SYS_OPEN,__NR_open
        defconst "SYS_CLOSE",9,,SYS_CLOSE,__NR_close
        defconst "SYS_READ",8,,SYS_READ,__NR_read
        defconst "SYS_WRITE",9,,SYS_WRITE,__NR_write
        defconst "SYS_CREAT",9,,SYS_CREAT,__NR_creat
        defconst "SYS_BRK",7,,SYS_BRK,__NR_brk

        defconst "O_RDONLY",8,,__O_RDONLY,0
        defconst "O_WRONLY",8,,__O_WRONLY,1
        defconst "O_RDWR",6,,__O_RDWR,2
        defconst "O_CREAT",7,,__O_CREAT,0100
        defconst "O_EXCL",6,,__O_EXCL,0200
        defconst "O_TRUNC",7,,__O_TRUNC,01000
        defconst "O_APPEND",8,,__O_APPEND,02000
        defconst "O_NONBLOCK",10,,__O_NONBLOCK,04000


        defcode ">R",2,,TOR
        pop %eax
        PUSHRSP %eax
        NEXT

        defcode "R>",2,,FROMR
        PUSHRSP %eax
        push %eax
        NEXT

        defcode "RSP@",4,,RSPFETCH
        push %ebp
        NEXT

        defcode "RSP!",4,,RSPSTORE
        pop %ebp
        NEXT

        defcode "RDROP",5,,RDROP
        addl $4,%ebp
        NEXT

        defcode "BRANCH",6,,BRANCH
        add (%esi),%esi
        NEXT

        defcode "0BRANCH",7,,ZBRANCH
        pop %eax
        test %eax,%eax
        jz code_BRANCH
        lodsl
        NEXT


        defword "QUIT",4,,QUIT
        .int RZ,RSPSTORE
        .int INTERPRET
        .int BRANCH,-8

        
        defcode ",",1,,COMMA
        pop %eax
        call _COMMA
        NEXT

_COMMA: 
        movl var_HERE,%edi
        stosl
        movl %edi,var_HERE
        ret

        defcode "KEY",3,,KEY
        call _KEY
        push %eax
        NEXT

_KEY:   
        mov (currkey),%ebx
        cmp (bufftop),%ebx
        jge 1f
        xor %eax,%eax
        mov (%ebx),%al
        inc %ebx
        mov %ebx,(currkey)
        ret
1:      
        xor %ebx,%ebx
        mov $buffer,%ecx
        mov %ecx,currkey
        mov $BUFFER_SIZE,%edx
        mov $__NR_read,%eax
        int $0x80
        test %eax,%eax
        jbe 2f
        addl %eax,%ecx
        mov %ecx,bufftop
        jmp _KEY
        
2:      
        xor %ebx,%ebx
        mov $__NR_exit,%eax
        int $0x80
        
        .data
        .align 4
currkey:        
        .int buffer
bufftop:        
        .int buffer


        defcode "WORD",4,,WORD
        call _WORD
        push %edi
        push %ecx
        NEXT

_WORD:  
1:
        call _KEY
        cmpb $'\\',%al
        je 3f
        cmpb $' ',%al
        jbe 1b

        mov $word_buffer,%edi
2:      
        stosb
        call _KEY
        cmpb $' ',%al
        ja 2b

        sub $word_buffer,%edi
        mov %edi,%ecx
        mov $word_buffer,%edi
        ret
3:
        call _KEY
        cmpb $'\n',%al
        jne 3b
        jmp 1b

        .data

word_buffer:    
        .space 32 
        
_NUMBER:        
        xor %eax,%eax
        xor %ebx,%ebx

        test %ecx,%ecx
        jz 5f

        movl var_BASE,%edx

        movb (%edi),%bl
        inc %edi
        push %eax
        cmpb $'-',%bl
        jnz 2f
        pop %eax
        push %ebx
        dec %ecx
        jnz 1f
        pop %ebx
        movl $1,%ecx
        ret


1:	imull %edx,%eax
	movb (%edi),%bl
	inc %edi

2:	subb $'0',%bl
	jb 4f
	cmp $10,%bl
	jb 3f
	subb $17,%bl
	jb 4f
	addb $10,%bl

3:	cmp %dl,%bl
	jge 4f

	add %ebx,%eax
	dec %ecx
	jnz 1b

4:	pop %ebx
	test %ebx,%ebx
	jz 5f
	neg %eax

5:	ret

        
	defcode "FIND",4,,FIND
	pop %ecx
	pop %edi
	call _FIND
	push %eax
	NEXT

_FIND:
	push %esi

	mov var_LATEST,%edx
1:
        test %edx,%edx
	je 4f

	xor %eax,%eax
	movb 4(%edx),%al
	andb $(F_HIDDEN|F_LENMASK),%al
	cmpb %cl,%al
	jne 2f
	push %ecx
	push %edi
	lea 5(%edx),%esi
	repe cmpsb
	pop %edi
	pop %ecx
	jne 2f
	pop %esi
	mov %edx,%eax
	ret

2:
	mov (%edx),%edx
	jmp 1b

4:
	pop %esi
	xor %eax,%eax
	ret


        defcode ">CFA",4,,TCFA
        pop %edi
        call _TCFA
        push %edi
        NEXT

_TCFA:  
        xor %eax,%eax
        add $4,%edi
        movb (%edi),%al
        inc %edi
        andb $F_LENMASK,%al
        add %eax,%edi
        andl $3,%edi
        andl $~3,%edi
        ret
        


        
        defcode "INTERPRET",9,,INTERPRET
        call _WORD

        xor %eax,%eax
        movl %eax,interpret_is_lit
        call _FIND
        test %eax,%eax
        jz 1f

        mov %eax,%edi
        movb 4(%edi),%al
        push %ax
        call _TCFA
        pop %ax
        andb $F_IMMED,%al
        mov %edi,%eax
        jnz 4f

        jmp 2f

1:      
        incl interpret_is_lit
        call _NUMBER
        test %ecx,%ecx
        jnz 6f
        mov %eax,%eax
        mov $LIT,%eax

2:      
        movl var_STATE,%edx
        test %edx,%edx
        jz 4f

        call _COMMA
        mov interpret_is_lit,%ecx
        test %ecx,%ecx
        jz 3f
        mov %ebx,%eax
        call _COMMA
3:      NEXT

4:
        mov interpret_is_lit,%ecx
        test %ecx,%ecx
        jnz 5f

        jmp *(%eax)

5:
        push %ebx
        NEXT

6:      
        mov $2,%ebx
        mov $errmsg, %ecx
        mov $errmsgend-errmsg,%edx
        mov $__NR_write,%eax
        int $0x80
        
	mov (currkey),%ecx	// the error occurred just before currkey position
	mov %ecx,%edx
	sub $buffer,%edx	// %edx = currkey - buffer (length in buffer before currkey)
	cmp $40,%edx		// if > 40, then print only 40 characters
	jle 7f
	mov $40,%edx
7:	sub %edx,%ecx		// %ecx = start of area to print, %edx = length
	mov $__NR_write,%eax	// write syscall
	int $0x80
	mov $errmsgnl,%ecx	// newline
	mov $1,%edx
	mov $__NR_write,%eax	// write syscall
	int $0x80
	NEXT
	.section .rodata
errmsg: .ascii "PARSE ERROR: "
errmsgend:
errmsgnl: .ascii "\n"
        
        
        .data
        .align 4
interpret_is_lit:
        .int 0
        
        .section .text
        .set INITIAL_DATA_SEGMENT_SIZE,65536
set_up_data_segment: 
        xor %ebx,%ebx
        movl $__NR_brk,%eax           #linux brk
        int $0x80
        movl %eax,var_HERE      #initalize HERE with where the break starts
        addl $INITIAL_DATA_SEGMENT_SIZE, %eax #add 10000 to it
        movl %eax,%ebx                    #call brk with the new addr
        movl $__NR_brk,%eax           #linux brk
        int $0x80                 
        ret

	.set RETURN_STACK_SIZE,8192
	.set BUFFER_SIZE,4096

	.align 4096
return_stack:
	.space RETURN_STACK_SIZE
return_stack_top:
	.align 4096

buffer:
	.space BUFFER_SIZE


	.section .data
msg:
    .ascii "foo\n"
len = . - msg

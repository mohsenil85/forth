        ## forth.s
        ## Wed Jan 27 18:47:05 PST 2016

.macro NEXT
        lodsl
        jmp *(%eax)
.endm 

.macro PUSHRSP reg 
        lea -4(%ebp),%ebp      #make space on the ebp stack
        movl \reg, (%ebp)          #store whats in reg on there
.endm 

.macro POPRSP reg 
        mov (%ebp), \reg          #pop whats on ebp, return to REG
        lea 4(%ebp), %ebp       #move stack pointer "up" or "back"
.endm 


.text
.align 4

        ####my stuff

write_thing: 
        movl $len, %edx #load length
        movl $msg, %ecx #load string
        movl $1,%ebx    #stdout
        movl $4,%eax    #syscall for write
        int $0x80

bye: 
        movl $0,%ebx    #exit status
        movl $1,%eax    #syscall for exit
        int $0x80

        ####jonestuff
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

        push $2
        push $3
.int DUP 
        
        xor %eax, %eax
        xor %ebx, %ebx
        pop %eax
        pop %ebx
        call write_thing
        call bye
        
.section .rodata
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
        

#include <sys/syscall.h>
.macro defconst name, namelen, flags=0, label, value
        defcode \name, \namelen, \flags, \label
        push $\value
        NEXT
.endm
        

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

        defword "QUIT",4,,QUIT
.int RZ,RSPSTORE
        //.int INTERPRET
.int BRANCH,-8

.section .rodata
.section .text
        
.set INITIAL_DATA_SEGMENT_SIZE,65536
set_up_data_segment: 
        xor %ebx,%ebx
        movl $45,%eax           #linux brk
        int $0x80
        movl %eax,var_HERE      #initalize HERE with where the break starts
        addl $INITIAL_DATA_SEGMENT_SIZE, %eax #add 10000 to it
        movl %eax,%ebx                    #call brk with the new addr
        movl $45,%eax
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

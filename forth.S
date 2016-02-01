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
        xor %eax,%eax

        mov $cold_start, %esi
        NEXT

.section .rodata

cold_start: 
        .int QUIT

        .set F_IMMED,0x80
        .set F_HIDDEN,0x20
        .set F_LENMASK,0x1f


        .set link,0 //link

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
        
.macro defconst name, namelen, flags=0, label, value
        defcode \name, \namelen, \flags, \label
        push $\value
        NEXT
.endm
        
defconst "R0",2,,RZ,return_stack_top

defcode "RSP!",4,,RSPSTORE
defcode "BRANCH",6,,BRANCH
        add (%esi),%esi

defword "QUIT",4,,QUIT
        .int RZ,RSPSTORE
        //.int INTERPRET
.int BRANCH,-8

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

.bss
var_HERE:
.space 4
var_S0:
.space 8

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

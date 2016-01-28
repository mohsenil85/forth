            ;; forth.s
            ;; Wed Jan 27 18:47:05 PST 2016
            ;; should all be in 32bit intel?

%macro NEXT 0
    lodsw
    jmp [eax]
%endmacro

        global main

main: 
        push dword len
        push dword msg
        push dword 1            ;stdout
        mov eax, 4
        sub esp, 4
        int 0x80
        add esp, 16
        
        push dword 0
        mov eax, 1
        sub esp, 12
        int 0x80
        
section .data
msg:    db      "Hello world!", 10
len:    equ $ - msg
        

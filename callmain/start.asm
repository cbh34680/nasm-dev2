
global \
    _start:function (_start.funcend - _start), \
    c_print_str:function (c_print_str.funcend - c_print_str)

extern main

section .text

_start:
    push rbp
    mov rbp, rsp
    and rsp, -16
                                    ;        +8   +8
    mov rdi, [rbp + 8]              ; argc [rbp|argc|argv[0]|...|null|env[0]]
    lea rsi, [rbp + 16]
    lea rdx, [rsi + rdi * 8 + 8]    ; {(rbp+16) + (argc*8) = null-addr} + 8
    call main
    mov rdi, rax

    mov eax, 60
    syscall

    ud2
.funcend:


c_print_str:
    push rbp
    mov rbp, rsp



    leave
    ret
.funcend:

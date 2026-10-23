
global \
    _start:function (_start.funcend - _start)

extern main

section .text

_start:
    push rbp
    mov rbp, rsp
    and rsp, -16

    mov rdi, [rbp + 8]
    lea rsi, [rbp + 16]
    lea rdx, [rsi + rdi * 8 + 8]
    call main
    mov rdi, rax

    mov eax, 60
    syscall

    ud2
.funcend:

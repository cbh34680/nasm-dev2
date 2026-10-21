
global \
    _start:function (_start.funcend - _start)
section .text

_start:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea r8, [rbp - 8]


    mov eax, 60
    mov edi, 10
    syscall

    leave
    ret
.funcend:

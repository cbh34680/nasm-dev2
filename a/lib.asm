;bits 64
global \
    print_hello:function (print_hello.funcend - print_hello)


section .rodata
start_msg: db "@ This is a program for learning purposes.", 0xA, 0
.dataend:

start_msg_len: equ $ - start_msg - 1

section .text
print_hello:
    push rbp
    mov rbp, rsp
    and rsp, -16

    ; 最初のメッセージ
    mov eax, 1
    mov edi, 1
    lea rsi, [rel start_msg]
    mov rdx, start_msg_len
    syscall

    leave
    ret
.funcend:

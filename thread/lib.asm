;bits 64
global \
    print_hello:function (print_hello.funcend - print_hello), \
    print_data: function (print_data.funcend - print_data), \
    lock_count: function (lock_count.funcend - lock_count), \
    unlock_count: function (unlock_count.funcend - unlock_count)


section .rodata
    start_msg: db "@ This is a program for learning purposes.", 0xA, 0
    start_msg_len: equ $ - start_msg - 1

section .data
    lock_data: db 0

section .text

; Test-and-Test-and-Set
lock_count:
    mov al, [rel lock_data]
    test al, al
    jnz .wait

    mov al, 1
    xchg al, [rel lock_data]
    test al, al
    jz .exit

.wait:
    pause
    jmp lock_count

.exit:
    ret
.funcend:

unlock_count:
    mov byte [rel lock_data], 0
    ret
.funcend:

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

print_data:
    push rbp
    mov rbp, rsp
    and rsp, -16
    mov rdx, rsi
    mov rsi, rdi

    mov eax, 1
    mov edi, 1
    syscall

    leave
    ret
.funcend:

;bits 64
global \
    print_hello:function (print_hello.funcend - print_hello), \
    print_data: function (print_data.funcend - print_data), \
    lock_count: function (lock_count.funcend - lock_count), \
    unlock_count: function (unlock_count.funcend - unlock_count)

section .data
    lock_data: db 0

section .rodata
    start_msg: db "@ This is a program for learning purposes.", 0xA, 0
    start_msg_len: equ $ - start_msg - 1

    dqarr: dq 0x5, 0x6, 0x7, -1
    dqarr_end: equ $ - dqarr

section .text
print_hello:
    push rbp
    mov rbp, rsp
    and rsp, -16

    ; 7 -> 6 -> 5
    lea r8, [rel dqarr]
    mov ecx, 3
.loop_start:
    lea rax, [r8 + rcx * 8 - 8]
    mov rax, [rax]
    loop .loop_start

    ; RDI = RAX * 3
    mov rax, 3
    lea rdi, [rax * 2 + rax]

    ; 'h' -> al
    mov rax, start_msg + 3
    mov al, [rax]

    ; 最初のメッセージ
    mov eax, 1
    mov edi, 1
    lea rsi, [rel start_msg]
    mov rdx, start_msg_len
    syscall

    leave
    ret
.funcend:

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

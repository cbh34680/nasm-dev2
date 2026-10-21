
global \
    mset1:function (mset1.funcend - mset1), \
    mset5:function (mset5.funcend - mset5), \
    mset2:function (mset2.funcend - mset2), \
    mset3:function (mset3.funcend - mset3), \
    mset4:function (mset4.funcend - mset4), \
    scan1:function (scan1.funcend - scan1) \

section .text

mset1:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea r8, [rbp - 8]

    xor eax, eax
    lea rdi, [rbp - 8]
    mov ecx, 8
    mov al, '@'
    cld

.loop_s:
    stosb
    loop .loop_s

    leave
    ret
.funcend:

mset5:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea r8, [rbp - 8]


    leave
    ret
.funcend:

mset2:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea r8, [rbp - 8]

    xor eax, eax
    lea rdi, [rbp - 8]
    mov ecx, 8
    mov al, '@'
    cld

    rep stosb

    leave
    ret
.funcend:

mset3:
    push rbp
    mov rbp, rsp
    mov r8, rdi

    mov al, '@'
    cld
    mov rcx, rsi
    rep stosb

    leave
    ret
.funcend:

mset4:
    push rbp
    mov rbp, rsp
    mov r8, rdi

    mov eax, -5
    cld
    mov rcx, rsi
    rep stosd

    leave
    ret
.funcend:

scan1:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea r8, [rbp - 8]

    lea rdi, [rbp - 8]
    mov rsi, 8
    call mset3

    lea rdi, [rbp - 8]
    mov al, '='
    cld
    mov ecx, 8

.loop_s:
    scasb
    loop .loop_s

    ;
    lea rdi, [rbp - 8]
    mov byte [rdi + 3], '='
    cld
    mov ecx, 8

.loop_s2:
    scasb
    jz .hit2
    loop .loop_s2

.hit2:

    leave
    ret
.funcend:

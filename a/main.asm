;bits 64
global \
    _start:function (_start.funcend - _start)


section .rodata
start_msg: db "@ This is a program for learning purposes.", 0xA, 0
.dataend:

start_msg_len: equ $ - start_msg - 1

section .text
_start:
    and rsp, -16                    ; -16=0xfffffffffffffff0 と rsp を and することで、下位 4bit(0x0-0xf) の範囲をクリアする
                                    ; 16byte 境界にそろえる (rsp%16 == 0)
    mov rbp, rsp

    ; 最初のメッセージ
    mov eax, 1
    mov edi, 1
    lea rsi, [rel start_msg]
    mov rdx, start_msg_len
    syscall


    mov eax, 60
    mov edi, 2
    syscall
.funcend:

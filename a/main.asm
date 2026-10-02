;bits 64
global _start

extern exit, string_length, print_string, print_char, print_newline, \
    print_uint

%include "lib.inc"


section .rodata
start_msg: db "This is a program for learning purposes.", 0xA, 0

;str1: db "Hello\n"             ; このように書くと 'H' 'e' 'l' 'l' 'o' '\' 'n' の 7 文字と解釈される
str1:   db "Hello"
        db 0xA
str1_len: equ $ - str1
        db 0


section .text
_start:
    lea rdi, [start_msg]
    call print_string

    mov eax, str1_len           ; rax=6

    lea rdi, [str1]
    call string_length          ; rax=6

    call print_string

    mov edi, 0x41               ; 'A'
                                ; 16 ビットレジスタの di, dil では上位ビットが 0 にならないので edi を使う
    call print_char

    call print_newline

    mov rdi, 12345678901234567890
    call print_uint

    call print_newline

    mov edi, 2
    call exit

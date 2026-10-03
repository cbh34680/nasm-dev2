;bits 64
global _start

extern exit, string_length, print_string, print_char, print_newline, \
    print_uint, print_int, read_char

%include "lib.inc"


section .rodata
start_msg: db "@ This is a program for learning purposes.", 0xA, 0

;str1: db "Hello\n"             ; このように書くと 'H' 'e' 'l' 'l' 'o' '\' 'n' の 7 文字と解釈される
str1:   db "Hello"
        db 0xA
str1_len: equ $ - str1
        db 0

input_msg: db "Input> ", 0

leave_msg: db "@ Program End", 0xA, 0


section .text
_start:
    and rsp, -16                    ; -16=0xfffffffffffffff0 と rsp を and することで、下位 4bit(0x0-0x15) の範囲をクリアする
                                    ; 16byte 境界にそろえる (rsp%16 == 0)

    ; 最初のメッセージ
    lea rdi, [rel start_msg]
    call print_string

    mov eax, str1_len               ; rax=6

    lea rdi, [rel str1]
    call string_length              ; rax=6

    call print_string

    mov edi, 'A'                    ; 16 ビットレジスタの di, dil では上位ビットが 0 にならないので edi を使う
    call print_char
    call print_newline

    ; 符号なし 64bit 数値の出力
    mov rdi, 12345678901234567890
    call print_uint
    call print_newline

    ; 符号付き 64bit 数値の出力
    mov rdi, -9045678901234567890
    call print_int
    call print_newline

    ; 入力を促すメッセージを出力
    lea rdi, [rel input_msg]
    call print_string

    ; 1 文字の入力
    call read_char
    test eax, eax                   ; 入力値のチェック
    jz .after_getc

    mov ebx, eax

    ; 入力された文字を出力
    mov edi, eax
    call print_char
    call print_newline

    ; バッファ中の余分な文字をクリア
    mov eax, ebx

.flush_buffer:
    cmp al, 0xA
    je .after_getc

    call read_char
    test eax, eax                   ; 入力値のチェック
    jz .after_getc

    jmp .flush_buffer

.after_getc:
    ; 最後のメッセージを出力
    lea edi, [rel leave_msg]
    call print_string

    mov edi, 2
    call exit

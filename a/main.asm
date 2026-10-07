;bits 64
global _start

extern exit, clear_eflags, \
    string_length, print_string, print_char, print_newline, \
    print_uint, print_int, read_char, read_word, flush_stdin, \
    parse_uint, parse_int

%include "lib.inc"


section .rodata
start_msg: db "@ This is a program for learning purposes.", 0xA, 0

;str1: db "Hello\n"             ; このように書くと 'H' 'e' 'l' 'l' 'o' '\' 'n' の 7 文字と解釈される
str1:   db "Hello"
        db 0xA
str1_len: equ $ - str1
        db 0

input_letter_msg: db "Input Letter> ", 0
input_word_msg: db "Input Word> ", 0

leave_msg: db "@ Program End", 0xA, 0

%define MAIN_STACK_SIZE 1024
%define READ_WORD_BUF 32
%define PARSE_UINT_LENGTH 40

section .text
_start:
    and rsp, -16                    ; -16=0xfffffffffffffff0 と rsp を and することで、下位 4bit(0x0-0xf) の範囲をクリアする
                                    ; 16byte 境界にそろえる (rsp%16 == 0)
    mov rbp, rsp

    sub rsp, MAIN_STACK_SIZE        ; スタックサイズとして 1kb を確保

    save_callee_saved
    call code_test
    assert_callee_saved_exit

    ; 最初のメッセージ
    lea rdi, [rel start_msg]
    save_callee_saved
    call print_string
    assert_callee_saved_exit

    mov eax, str1_len               ; rax=6

    lea rdi, [rel str1]
    call string_length              ; rax=6

    call print_string

    mov edi, 'A'                    ; DI/DIL への書き込みでは上位ビットが保持されるので EDI を使う
    save_callee_saved
    call print_char
    assert_callee_saved_exit
    save_callee_saved
    call print_newline
    assert_callee_saved_exit

    ; 符号なし 64bit 数値の出力
    mov rdi, 12345678901234567890
    save_callee_saved
    call print_uint
    assert_callee_saved_exit
    call print_newline

    ; 符号付き 64bit 数値の出力
    mov rdi, -9045678901234567890
    save_callee_saved
    call print_int
    assert_callee_saved_exit
    call print_newline

%if 0
    ; 入力を促すメッセージを出力
    lea rdi, [rel input_letter_msg]
    call print_string

    ; 1 文字の入力
    save_callee_saved
    call read_char
    assert_callee_saved_exit
    test eax, eax                       ; 入力値のチェック
    jz .after_read_char
    cmp eax, 0xA                        ; 改行なら表示しない
    je .after_read_char

    ; 入力された文字を出力
    mov edi, eax
    call print_char
    call print_newline

.after_read_char:
    ; 残りの入力バッファーをクリア
    save_callee_saved
    call flush_stdin
    assert_callee_saved_exit
%endif

    ; 入力を促すメッセージを出力
    lea rdi, [rel input_word_msg]
    call print_string

    ; 単語の入力
    lea rdi, [rbp - READ_WORD_BUF]
    mov esi, READ_WORD_BUF
    save_callee_saved
    call read_word
    assert_callee_saved_exit

    test rax, rax                               ; 入力エラーのチェック
    jz .after_read_word

    mov rdi, rax                                ; 入力文字列を表示
    call print_string
    call print_newline

    lea rdi, [rbp - READ_WORD_BUF]              ; 入力文字列の長さを表示
    call string_length
    mov rdi, rax
    call print_uint
    call print_newline

.after_read_word:
    ; 残りの入力バッファーをクリア
    call flush_stdin

    ; 文字列->数値変換 (unsigned)
    lea rdi, [rbp - READ_WORD_BUF]
    save_callee_saved
    call parse_uint
    assert_callee_saved_exit

    mov [rbp - PARSE_UINT_LENGTH], rdx

    mov rdi, rax
    call print_uint
    call print_newline

    mov rdi, [rbp - PARSE_UINT_LENGTH]
    call print_uint
    call print_newline

    ; 文字列->数値変換 (signed)
    lea rdi, [rbp - READ_WORD_BUF]
    save_callee_saved
    call parse_int
    assert_callee_saved_exit


    ; 最後のメッセージを出力
    lea edi, [rel leave_msg]
    call print_string

    mov edi, 2
    call exit


; 調査用
code_test:
    push rbp
    mov rbp, rsp

    mov ecx, 1
    test ecx, ecx

    mov ecx, 0
    test ecx, ecx

    mov cl, '/'
    sub cl, '0'

    call clear_eflags
    mov cl, 5
    cmp cl, 9

    call clear_eflags
    mov cl, 'a'
    cmp cl, '9'

    mov cl, -1
    add cl, -1

    movsx rcx, cl

    call clear_eflags
    mov rax, 0x7fffffffffffffff
    add rax, 1

    call clear_eflags
    mov rax, 0x8000000000000000
    add rax, -1

    leave
    ret

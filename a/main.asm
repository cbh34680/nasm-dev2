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
skip_msg: db "@ Skip Char - ", 0

leave_msg: db "@ Program End", 0xA, 0


section .text
_start:
    and rsp, -16                    ; -16=0xfffffffffffffff0 と rsp を and することで、下位 4bit(0x0-0xf) の範囲をクリアする
                                    ; 16byte 境界にそろえる (rsp%16 == 0)

    ; 最初のメッセージ
    lea rdi, [rel start_msg]
    assert_callee_saved_entry
    call print_string
    assert_callee_saved_exit

    mov eax, str1_len               ; rax=6

    lea rdi, [rel str1]
    call string_length              ; rax=6

    call print_string

    mov edi, 'A'                    ; DI/DIL への書き込みでは上位ビットが保持されるので EDI を使う
    assert_callee_saved_entry
    call print_char
    assert_callee_saved_exit
    assert_callee_saved_entry
    call print_newline
    assert_callee_saved_exit

    ; 符号なし 64bit 数値の出力
    mov rdi, 12345678901234567890
    assert_callee_saved_entry
    call print_uint
    assert_callee_saved_exit
    call print_newline

    ; 符号付き 64bit 数値の出力
    mov rdi, -9045678901234567890
    assert_callee_saved_entry
    call print_int
    assert_callee_saved_exit
    call print_newline

    ; 入力を促すメッセージを出力
    lea rdi, [rel input_msg]
    call print_string

    ; 1 文字の入力
    assert_callee_saved_entry
    call read_char
    assert_callee_saved_exit
    test eax, eax                       ; 入力値のチェック
    jz .after_getc
    cmp eax, 0xA                        ; 改行なら表示しない
    je .after_getc

    ; 入力された文字を出力
    mov edi, eax
    call print_char
    call print_newline

    ; 残りの入力バッファーをクリア
    assert_callee_saved_entry
    call flush_stdin
    assert_callee_saved_exit

.after_getc:
    ; 最後のメッセージを出力
    lea edi, [rel leave_msg]
    call print_string

    mov edi, 2
    call exit


; 入力バッファーをクリア
; 引数なし
flush_stdin:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, 16

.loop:
    assert_call_alignment
    call read_char
    test eax, eax                       ; エラー又は中断なら終了
    jz .exit
    cmp eax, 0xA                        ; 改行になったら終了
    je .exit

    mov dword [rbp - 16], eax

    lea rdi, [rel skip_msg]
    call print_string

    mov edi, [rbp - 16]
    call print_char
    call print_newline

    jmp .loop

.exit:
    leave
    ret

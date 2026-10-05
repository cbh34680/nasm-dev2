;[bits 64]
global exit, string_length, print_string, print_char, print_newline, \
    print_uint, print_int, read_char, read_word, flush_stdin

%include "lib.inc"


section .rodata
dec_chars: db "0123456789", 0
div_dq_10: dq 10

skip_msg: db "@ Skip Char - ", 0

section .text
; exit
; 引数1:RDI) リターンコード
exit:
    assert_func_entry_alignment
    mov eax, sys_exit
    syscall


; 文字列長の算出
; 引数1:RDI) 文字列の先頭アドレス
string_length:
    assert_func_entry_alignment
    mov rax, rdi
    ;lea rax, [rdi]             ; 上記と同じ意味。計算が必要なときは lea を使う

.loop:
    cmp byte [rax], 0           ; rax が指すアドレスから 1 バイトを 0 と比較
    je .done

    inc rax
    jmp .loop

.done:
    sub rax, rdi                ; 引数の rdi と rax の差が文字列長
    ret
    ;pop r8                     ; pop rip とは書けないが、戻りアドレスをレジスタに保存し jmp すれば同じ動作になる
    ;jmp r8


; 文字列出力
; 引数1:RDI) 文字列の先頭アドレス
print_string:
    assert_func_entry_alignment
    sub rsp, 8                  ; アライメントを 16 バイト境界に合わせる

    mov rsi, rdi                ; 引数の文字列のアドレスを第 2 引数に設定
    assert_call_alignment
    call string_length
    mov rdx, rax                ; 文字列長を第 3 引数に設定

    mov eax, sys_write          ; 即値で 32 ビット範囲のときは 32 ビットレジスタを使う
    mov edi, STDOUT_FILENO      ; fd
    syscall

    add rsp, 8
    ret


; 1 文字出力
; 引数1:RDI) 文字(DIL)
print_char:
    assert_func_entry_alignment
    push rbp                    ; ここでスタックを 8 バイト下げているので、戻りアドレスと合わせて 16 バイト境界になる
    mov rbp, rsp

    sub rsp, 16                 ; call 前に rsp を 16 バイト境界に合わせる
                                ; push rbp 後は rsp % 16 == 0 のため、
                                ; 16 の倍数を減算してもアライメントは維持される
    mov [rbp - 1], dil

    mov eax, sys_write
    mov edi, STDOUT_FILENO
    lea rsi, [rbp - 1]
    mov edx, 1
    syscall

    ;mov rsp, rbp
    ;pop rbp
    leave                       ; 上記2命令の代わりになる
    ret


; 改行を出力
; 引数なし
print_newline:
    assert_func_entry_alignment
    sub rsp, 8                  ; アライメントを 16 バイト境界に合わせる

    mov edi, 0xA                ; '\n'
    assert_call_alignment
    call print_char

    add rsp, 8
    ret


; 文字列を反転する
; 引数1:RDI) 文字列の先頭アドレス
; 引数2:RSI) 文字列長
string_reverse:
    assert_func_entry_alignment
    lea rdx, [rdi + rsi]

.loop:
    dec rdx

    cmp rdi, rdx
    jae .last

    mov ah, [rdi]
    mov al, [rdx]
    mov [rdi], al
    mov [rdx], ah               ; r8 レジスタではエラーになる
                                ; REX プレフィックスを必要とするレジスタと ah を同時に指定できない
                                ; al なら r8 でも OK
    inc rdi
    jmp .loop

.last:
    ret


; 符号なし 64 ビット数値の 10 進数出力
; 引数1:RDI) 数値
%define PRINT_UINT_STACK_SIZE 32

print_uint:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, PRINT_UINT_STACK_SIZE

    lea r8, [rbp - PRINT_UINT_STACK_SIZE]       ; 文字列化した領域
    mov rax, rdi                                ; 割られる数

.loop:
    xor rdx, rdx                                ; 余り
    div qword [rel div_dq_10]                   ; 定数 10 で割る

    lea r9, [rel dec_chars]
    mov cl, [r9 + rdx]
    mov [r8], cl                                ; rbp-32 からの領域に文字を保存
    inc r8

    test rax, rax
    jnz .loop

    mov byte [r8], 0                            ; '\0' 終端

    mov rax, rbp                                ; rax - (rbp-32) = 文字列の長さ
    sub rax, PRINT_UINT_STACK_SIZE
    sub r8, rax                                 ; 文字列長が r8 に入る

    lea rdi, [rbp - PRINT_UINT_STACK_SIZE]
    mov rsi, r8

    push rdi
    sub rsp, 8                                  ; アライメントを 16 に合わせる
    assert_call_alignment
    call string_reverse
    add rsp, 8
    pop rdi

    assert_call_alignment
    call print_string

.next:
    leave
    ret


; 符号付き 64 ビット数値の 10 進数出力
; 引数1:RDI) 数値
print_int:
    assert_func_entry_alignment
    push rbx
    mov rbx, rdi

    ;bt rdi, 63                                  ; 先頭のビットが立っているか確認
    ;jnc .positive                               ; bits[63] == 0 --> 正数
    test rdi, rdi                               ; 負数のときは SF=1 になる
    jns .positive                               ; SF==0 --> 正数

    neg rbx                                     ; 負数なら 2 の補数を計算

    mov dil, '-'                                ; マイナス記号を出力
    assert_call_alignment
    call print_char

.positive:
    mov rdi, rbx
    assert_call_alignment
    call print_uint

    pop rbx
    ret


; 標準入力から 1 文字入力
; 引数なし
%define READ_CHAR_STACK_SIZE 16

read_char:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, READ_CHAR_STACK_SIZE

    mov eax, sys_read
    mov edi, STDIN_FILENO
    lea rsi, [rbp - READ_CHAR_STACK_SIZE]
    mov edx, 1
    assert_call_alignment
    syscall

    test rax, rax
    jle .end                                    ; Ctrl+D(=0) 又はエラー(<0) のとき

    xor rax, rax
    mov al, [rbp - READ_CHAR_STACK_SIZE]

.end:
    leave
    ret


; 標準入力から単語を入力
; 引数1:RDI) 書き込みバッファのアドレス
; 引数2:RSI) 書き込みバッファのサイズ
%define READ_WORD_SAVE_RBX 8
%define READ_WORD_ARG_ADDR 24
%define READ_WORD_ARG_SIZE 32

read_word:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; 各レジスタ値の保存
    mov [rbp - READ_WORD_SAVE_RBX], rbx
    mov [rbp - READ_WORD_ARG_ADDR], rdi
    mov [rbp - READ_WORD_ARG_SIZE], rsi
    mov rbx, rdi                                ; rbx はバッファ中の書き込み位置をポイント

.loop:
    mov rax, rbx
    sub rax, [rbp - READ_WORD_ARG_ADDR]
    cmp rax, [rbp - READ_WORD_ARG_SIZE]         ; 書き込み位置がバッファサイズ以上かチェック
    jae .fault

    assert_call_alignment
    call read_char                              ; 1 文字入力
    test al, al
    jz .fault
    cmp al, 0xA
    je .term

    cmp rbx, [rbp - READ_WORD_ARG_ADDR]         ; 既に単語入力が始まっているかをチェック
    jne .started

    cmp al, ' '                                 ; 先頭の空白/タブは読み飛ばす
    je .loop
    cmp al, 0x9
    je .loop

    jmp .store

.started:
    cmp al, ' '                                 ; 単語が開始された後に発生した空白/タブなら終了
    je .term
    cmp al, 0x9
    je .term

.store:
    mov byte [rbx], al                          ; 入力値をバッファへ書き込み
    inc rbx
    jmp .loop

.term:
    mov byte[rbx], 0
    mov rax, [rbp - READ_WORD_ARG_ADDR]
    jmp .end

.fault:
    mov eax, 0
    jmp .end

.end:
    mov rbx, [rbp - READ_WORD_SAVE_RBX]

    leave
    ret


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

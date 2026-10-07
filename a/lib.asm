;[bits 64]
global exit, clear_eflags, \
    string_length, print_string, print_char, print_newline, \
    print_uint, print_int, read_char, read_word, flush_stdin, \
    parse_uint, parse_int, string_equals, string_copy

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


; eflags をクリア
clear_eflags:
    assert_func_entry_alignment
%if 0
    pushfq
    pop rax
    and rax, ~0x0cd5
    push rax
    popfq
%else
    mov eax, 1
    test eax, eax
%endif
    ret


; 文字列長の算出
; 引数1:RDI) 文字列の先頭アドレス
string_length:
    assert_func_entry_alignment
    mov rax, rdi
    ;lea rax, [rdi]             ; 上記と同じ意味。計算が必要なときは lea を使う

.loop_start:
    cmp byte [rax], 0           ; rax が指すアドレスから 1 バイトを 0 と比較
    je .done

    inc rax
    jmp .loop_start

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

.loop_start:
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
    jmp .loop_start

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

.loop_start:
    xor rdx, rdx                                ; 余り
    div qword [rel div_dq_10]                   ; 定数 10 で割る

    lea r9, [rel dec_chars]
    mov cl, [r9 + rdx]
    mov [r8], cl                                ; rbp-32 からの領域に文字を保存
    inc r8

    test rax, rax
    jnz .loop_start

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
    jz .end                                     ; Ctrl+D(=0) のとき
    js .end                                     ; エラー(<0) のとき
    ;jle .end                                    ; Ctrl+D(=0) 又はエラー(<0) のとき

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

.loop_start:
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

    ; まだ単語が開始されていないときの分岐
    cmp al, ' '                                 ; 先頭の空白/タブは読み飛ばす
    je .loop_start
    cmp al, 0x9
    je .loop_start

    jmp .store

.started:
    ; 単語が開始されたあとの分岐
    cmp al, ' '                                 ; 空白/タブなら終了
    je .term
    cmp al, 0x9
    je .term

.store:
    ; 入力値をバッファへ書き込み
    mov byte [rbx], al
    inc rbx
    jmp .loop_start

.term:
    mov byte[rbx], 0                            ; '\0' 終端
    mov rax, [rbp - READ_WORD_ARG_ADDR]
    jmp .end

.fault:
    mov eax, 0
    jmp .end

.end:
    mov rbx, [rbp - READ_WORD_SAVE_RBX]         ; rbx を復元
    leave
    ret


; 入力バッファーをクリア
; 引数なし
flush_stdin0:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, 16

.loop_start:
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

    jmp .loop_start

.exit:
    leave
    ret


flush_stdin:
    assert_func_entry_alignment
    sub rsp, 8

    mov eax, sys_ioctl
    mov edi, STDIN_FILENO
    mov rsi, TCFLSH
    mov rdx, TCIFLUSH
    syscall

    add rsp, 8
    ret


; 文字列->符号なし 64bit 数値変換
; 引数1:RDI) 文字列の先頭アドレス
; 戻り値1: RAX) 変換後 64bit 数値
; 戻り値2: RDX) 処理した文字列の長さ
%define PARSE_UINT_ARG_ADDR 8

parse_uint:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp

    sub rsp, 16
    mov [rbp - PARSE_UINT_ARG_ADDR], rdi        ; 文字列の先頭アドレスを保存

    xor r8d, r8d                                ; 戻り数値保存
    xor ecx, ecx                                ; 入力文字列の 1byte

.loop_start:
    mov cl, [rdi]

    test cl, cl
    jz .loop_break                              ; '\0' なら終了

    sub cl, '0'
    jc .loop_break                              ; 0 未満なら終了
    cmp cl, 9
    ja .loop_break                              ; 9 超過なら終了

    mov rax, r8
    mov edx, 10
    mul rdx                                     ; 10 倍して桁溢れなら終了
    jc .loop_break

    add rax, rcx                                ; 加算して桁溢れなら終了
    jc .loop_break

    mov r8, rax
    inc rdi
    jmp .loop_start

.loop_break:
    mov rax, r8

    sub rdi, [rbp - PARSE_UINT_ARG_ADDR]        ; 処理した長さを rdx に保存
    mov rdx, rdi

    leave
    ret


; 文字列->符号あり 64bit 数値変換
; 引数1:RDI) 文字列の先頭アドレス
; 戻り値1: RAX) 変換後 64bit 数値
; 戻り値2: RDX) 処理した文字列の長さ
%define PARSE_INT_ARG_ADDR 8

parse_int:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp

    sub rsp, 16
    mov [rbp - PARSE_INT_ARG_ADDR], rdi

    xor ecx, ecx                            ; cl: 入力バッファの 1 バイト
    xor r8d, r8d                            ; 合計用
    xor r9d, r9d                            ; 負数の場合に 1

    cmp byte [rdi], '-'
    jne .check_plus
    mov r9d, 1                              ; 文字列の先頭が '-' のときは r9d を 1
    inc rdi
    jmp .loop_start

.check_plus:
    cmp byte[rdi], '+'
    jne .loop_start
    inc rdi

.loop_start:
    mov cl, [rdi]
    test cl, cl
    jz .loop_break

    sub cl, '0'
    jc .loop_break
    cmp cl, 9
    ja .loop_break

    test r9d, 1
    jz .positive

    ; 負数の場合
    movsx rcx, cl                           ; cl(0～9)を64bitへ符号拡張
    neg rcx

.positive:
    mov rax, r8
    mov edx, 10
    imul rdx
    jo .loop_break

    add rax, rcx
    jo .loop_break

    mov r8, rax

    inc rdi
    jmp .loop_start

.loop_break:
    mov rax, r8
    sub rdi, [rbp - PARSE_INT_ARG_ADDR]
    mov rdx, rdi

    leave
    ret


; 文字列の比較
; 引数1:RDI) 文字列のアドレス
; 引数2:RSI) 文字列のアドレス
; 戻り値:RAX)  等しいときは 1、それ以外は 0
string_equals:
    assert_func_entry_alignment
    sub rsp, 8

    cmp rdi, rsi
    je .equal

    xor eax, eax

.loop_start:
    mov al, [rdi]
    mov ah, [rsi]

    cmp al, ah
    jne .not_equal

    inc rdi
    inc rsi

    test al, al
    jnz .loop_start

.equal:
    mov eax, 1
    jmp .last

.not_equal:
    mov eax, 0
    jmp .last

.last:
    add rsp, 8
    ret


; 文字列のコピー
; 引数1:RDI) コピー元文字列のアドレス
; 引数2:RSI) コピー先バッファのアドレス
; 引数3:RDX) コピー先バッファのサイズ
; 戻り値:RAX) 文字列がバッファに収まるときはバッファのアドレス、それ以外は 0
%define STRING_COPY_SAVE_RSI 8

string_copy:
    assert_func_entry_alignment
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov [rbp - STRING_COPY_SAVE_RSI], rsi

.loop_start:
    mov rax, rsi
    sub rax, [rbp - STRING_COPY_SAVE_RSI]
    cmp rax, rdx                                        ; 空き領域があるかチェック
    jae .fault

    mov al, [rdi]
    mov [rsi], al

    inc rdi
    inc rsi

    test al, al
    jnz .loop_start

    mov rax, [rbp - STRING_COPY_SAVE_RSI]
    jmp .last

.fault:
    mov eax, 0

.last:

    leave
    ret


global exit, string_length, print_string, print_char, print_newline, \
    print_uint


%macro assert_func_entry_alignment 0
    test rsp, 7
    jnz %%bad
    test rsp, 8
    jnz %%ok
%%bad:
    ud2
%%ok:
%endmacro

%macro assert_call_alignment 0
    test rsp, 0xf
    jz %%ok
    ud2
%%ok:
%endmacro


%define STDOUT_FILENO 1
%define sys_write 1
%define sys_exit 60

section .rodata
dec_chars: db "0123456789"
div_dq_10: dq 10


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
reverse_string:
    assert_func_entry_alignment
    lea rdx, [rdi + rsi]

.loop:
    dec rdx

    cmp rdi, rdx
    jge .last

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
    div qword [div_dq_10]                       ; 定数 10 で割る

    mov cl, [dec_chars + rdx]
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
    call reverse_string
    add rsp, 8
    pop rdi

    assert_call_alignment
    call print_string

.next:
    leave
    ret

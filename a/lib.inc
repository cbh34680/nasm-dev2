%ifndef LIB_INC
%define LIB_INC

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

%macro assert_callee_saved_entry 0
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro assert_callee_saved_exit 0
    cmp r15, [rsp]
    jne %%bad
    cmp r14, [rsp + 8]
    jne %%bad
    cmp r13, [rsp + 16]
    jne %%bad
    cmp r12, [rsp + 24]
    jne %%bad
    cmp rbp, [rsp + 32]
    jne %%bad
    cmp rbx, [rsp + 40]
    jne %%bad

    add rsp, 48
    jmp %%ok

%%bad:
    ud2

%%ok:
%endmacro


%define STDIN_FILENO 0
%define STDOUT_FILENO 1

%define sys_read 0
%define sys_write 1
%define sys_exit 60

%endif

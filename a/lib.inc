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


%define STDOUT_FILENO 1
%define sys_write 1
%define sys_exit 60

%endif

default rel
bits 64

segment .text

global invokeNative
invokeNative:
    push rbp
    mov rbp, rsp

    mov r10, rcx    ; func_ptr
    mov rax, rdx    ; argv
    mov rcx, r8     ; n_stacks

; fill all fp args
    movsd xmm0, [rax + 0]
    movsd xmm1, [rax + 8]
    movsd xmm2, [rax + 16]
    movsd xmm3, [rax + 24]

; check for stack args
    cmp rcx, 0
    jz cycle_end

    mov rdx, rsp
    and rdx, 15
    jz no_abort
    int 3
no_abort:
    mov rdx, rcx
    and rdx, 1
    shl rdx, 3
    sub rsp, rdx

; store stack args
    lea r9, [rax + rcx * 8 + 56]
    sub r9, rsp ; offset
cycle:
    push [qword rsp + r9]
    loop cycle

cycle_end:
    mov rcx, [rax + 32]
    mov rdx, [rax + 40]
    mov r8,  [rax + 48]
    mov r9,  [rax + 56]

    sub rsp, 32 ; shadow space

    call r10
    leave
    ret

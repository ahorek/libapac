.text
    .arch generic64
    .arch .adx
    .arch .bmi2

    .globl mul_bc_zen4
    .type mul_bc_zen4, @function
mul_bc_zen4:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %rdi
    pushq   %rsi
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    xorq    %rax, %rax
    movq    %rdi, %rbp        # result
    movq    %rsi, %rbx        # op1
    movq    104(%rbp), %r10   # size2 from stack
    movq    %rbp, %r13
    movq    %rbx, %r11
    movq    %rcx, %r12
    shrq    $3, %rcx
    andq    $7, %r12
    xorq    %r15, %r15

loop_outer:
    movq    %rcx, %rcx
    movq    (%r8, %rax, 8), %rdx    # op2[i]
    leaq    (%r13, %rax, 8), %rbp   # result + i
    leaq    (%r11), %rbx            # op1

    testq   %rcx, %rcx
    jz      before_remainder

    .p2align 4
inner_unrolled:
    mulxq   (%rbx), %rsi, %rdi      # rdi:rsi = rdx * [rbx]
    adcxq   (%rbp), %rsi
    adoxq   8(%rbp), %rdi
    movq    %rsi, (%rbp)
    movq    %rdi, %r14

    mulxq   8(%rbx), %rsi, %rdi     # rdi:rsi = rdx * [rbx+8]
    adcxq   %r14, %rsi
    adoxq   16(%rbp), %rdi
    movq    %rsi, 8(%rbp)
    movq    %rdi, %r14

    mulxq   16(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+16]
    adcxq   %r14, %rsi
    adoxq   24(%rbp), %rdi
    movq    %rsi, 16(%rbp)
    movq    %rdi, %r14

    mulxq   24(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+24]
    adcxq   %r14, %rsi
    adoxq   32(%rbp), %rdi
    movq    %rsi, 24(%rbp)
    movq    %rdi, %r14

    mulxq   32(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+32]
    adcxq   %r14, %rsi
    adoxq   40(%rbp), %rdi
    movq    %rsi, 32(%rbp)
    movq    %rdi, %r14

    mulxq   40(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+40]
    adcxq   %r14, %rsi
    adoxq   48(%rbp), %rdi
    movq    %rsi, 40(%rbp)
    movq    %rdi, %r14

    mulxq   48(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+48]
    adcxq   %r14, %rsi
    adoxq   56(%rbp), %rdi
    movq    %rsi, 48(%rbp)
    movq    %rdi, %r14

    mulxq   56(%rbx), %rsi, %rdi    # rdi:rsi = rdx * [rbx+56]
    adcxq   %r14, %rsi
    adoxq   64(%rbp), %rdi
    movq    %rsi, 56(%rbp)
    movq    %rdi, 64(%rbp)

    leaq    64(%rbx), %rbx
    leaq    64(%rbp), %rbp
    decq    %rcx
    jnz     inner_unrolled

    .p2align 4
before_remainder:
    movq    %r12, %rcx
    jrcxz   outer_loop_end

    .p2align 4
remainder:
    mulxq   (%rbx), %rsi, %rdi      # rdi:rsi = rdx * [rbx]
    adcxq   (%rbp), %rsi
    adoxq   8(%rbp), %rdi
    movq    %rsi, (%rbp)
    movq    %rdi, 8(%rbp)

    leaq    8(%rbx), %rbx
    leaq    8(%rbp), %rbp
    loop    remainder

outer_loop_end:
    adcq    $0, (%rbp)

    incq    %rax
    cmpq    %r10, %rax
    jne     loop_outer

end_of_func:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rsi
    popq    %rdi
    popq    %rbx
    leave
    ret
    .size mul_bc_zen4, .-mul_bc_zen4

    .globl mul_bc_x64
    .type mul_bc_x64, @function
mul_bc_x64:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %rdi
    pushq   %rsi
    pushq   %r12
    pushq   %r13

    movq    %rsi, %rbx        # op1
    xorq    %r10, %r10        # i = 0

outer_loop:
    xorq    %rdi, %rdi        # temp_reg = 0
    xorq    %r11, %r11        # j = 0
    xorq    %rdx, %rdx        # high64 = 0
    movq    %r10, %r12        # result index = i
    movq    %rcx, %r13        # size1
    movq    (%r8, %r10, 8), %rsi  # op2[i]
    movq    %rsi, %rax

inner_loop:
    adcq    %rdx, %rdi            # temp_reg += (CF + high64)
    mulq    (%rbx, %r11, 8)       # rdx:rax = rax * op1[j]
    addq    %rax, %rdi            # temp_reg += low64
    adcq    $0, %rdx              # high64 += CF
    addq    %rdi, (%rdi, %r12, 8) # result[i + j] += temp_reg
    movq    %rsi, %rax            # reload op2[i]
    movq    $0, %rdi              # temp_reg = 0
    incq    %r11
    incq    %r12
    decq    %r13
    jnz     inner_loop

loop_end:
    adcq    %rdx, (%rdi, %r12, 8) # propagate final carry
    incq    %r10
    movq    80(%rbp), %rsi         # size2 from stack
    cmpq    %rsi, %r10
    jne     outer_loop

end_of_func2:
    popq    %r13
    popq    %r12
    popq    %rsi
    popq    %rdi
    popq    %rbx
    leave
    ret
    .size mul_bc_x64, .-mul_bc_x64
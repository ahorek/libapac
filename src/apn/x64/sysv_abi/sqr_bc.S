.text

.globl sqr_bc_zen4
.type sqr_bc_zen4, @function
sqr_bc_zen4:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %rsi
    pushq   %rdi
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    # Save original parameters
    movq    %rdi, %rax    # result
    movq    %rsi, %rbx    # operand
    movq    %rdx, %rcx    # size

    movq    %rcx, %r9
    decq    %r9
    testq   %r9, %r9
    jz      .before_pass2_zen4

    xorq    %r13, %r13    # outer loop counter
    xorq    %r15, %r15    # carry

.outer_loop_pass1_zen4:
    movq    (%rbx, %r13, 8), %rdx    # Load current limb
    leaq    8(%rax, %r13, 8), %r10    # result pointer
    leaq    8(%rbx, %r13, 8), %r11    # operand pointer
    movq    %r9, %rcx                 # inner loop counter
    movq    %r9, %r12
    shrq    $2, %rcx                  # unrolled iterations
    andq    $3, %r12                  # remainder
    
    # Clear flags for adox/adcx
    xorq    %r8, %r8
    
    testq   %rcx, %rcx
    jz      .inner_loop_befr_rem_pass1_zen4

.p2align 4
.inner_loop_4unroll_pass1_zen4:
    # Process 4 limbs per iteration
    mulx    (%r11), %rsi, %rdi
    adcx    %rsi, %rsi
    movq    (%r10), %r14
    adox    %rsi, %r14
    movq    %r14, (%r10)
    adcx    %rdi, %rdi
    movq    8(%r10), %r14
    adox    %rdi, %r14
    movq    %r14, 8(%r10)

    mulx    8(%r11), %rsi, %rdi
    adcx    %rsi, %rsi
    movq    16(%r10), %r14
    adox    %rsi, %r14
    movq    %r14, 16(%r10)
    adcx    %rdi, %rdi
    movq    24(%r10), %r14
    adox    %rdi, %r14
    movq    %r14, 24(%r10)

    mulx    16(%r11), %rsi, %rdi
    adcx    %rsi, %rsi
    movq    32(%r10), %r14
    adox    %rsi, %r14
    movq    %r14, 32(%r10)
    adcx    %rdi, %rdi
    movq    40(%r10), %r14
    adox    %rdi, %r14
    movq    %r14, 40(%r10)

    mulx    24(%r11), %rsi, %rdi
    adcx    %rsi, %rsi
    movq    48(%r10), %r14
    adox    %rsi, %r14
    movq    %r14, 48(%r10)
    adcx    %rdi, %rdi
    movq    56(%r10), %r14
    adox    %rdi, %r14
    movq    %r14, 56(%r10)

    addq    $32, %r11
    addq    $64, %r10
    decq    %rcx
    jnz     .inner_loop_4unroll_pass1_zen4

.p2align 4
.inner_loop_befr_rem_pass1_zen4:
    movq    %r12, %rcx
    jrcxz   .outer_loop_end_pass1_zen4

.inner_loop_rem_pass1_zen4:
    mulx    (%r11), %rsi, %rdi
    adcx    %rsi, %rsi
    movq    (%r10), %r14
    adox    %rsi, %r14
    movq    %r14, (%r10)
    adcx    %rdi, %rdi
    movq    8(%r10), %r14
    adox    %rdi, %r14
    movq    %r14, 8(%r10)

    addq    $8, %r11
    addq    $16, %r10
    loop    .inner_loop_rem_pass1_zen4

.outer_loop_end_pass1_zen4:
    movq    (%r10), %r14
    adcx    %r15, %r14
    adox    %r15, %r14
    movq    %r14, (%r10)
    incq    %r13
    decq    %r9
    jnz     .outer_loop_pass1_zen4

.before_pass2_zen4:
    movq    %rax, %r10    # result
    movq    %rbx, %r11    # operand
    movq    %rcx, %rcx    # size
    xorq    %r12, %r12    # carry

.loop_pass2_zen4:
    movq    (%r11), %rdx
    mulx    %rdx, %rsi, %rdi    # square the limb
    adcq    %rsi, (%r10)
    adcq    %rdi, 8(%r10)
    addq    $8, %r11
    addq    $16, %r10
    loop    .loop_pass2_zen4

.end_of_func_zen4:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rdi
    popq    %rsi
    popq    %rbx
    leave
    ret
.size sqr_bc_zen4, .-sqr_bc_zen4

.globl sqr_bc_x64
.type sqr_bc_x64, @function
sqr_bc_x64:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %rsi
    pushq   %rdi
    pushq   %r12
    pushq   %r13

    # Save parameters
    movq    %rdi, %rdi    # result
    movq    %rsi, %rsi    # operand
    movq    %rdx, %rcx    # size

    movq    %rcx, %r9
    decq    %r9
    testq   %r9, %r9
    jz      .before_pass3_x64

    xorq    %r12, %r12    # outer counter

.outer_loop_pass1_x64:
    movq    %r9, %rcx     # inner counter
    xorq    %rbx, %rbx    # temp
    xorq    %rdx, %rdx    # carry
    movq    (%rsi, %r12, 8), %r13  # current limb
    leaq    8(%rdi, %r12, 8), %r10 # result pointer
    leaq    8(%rsi, %r12, 8), %r11 # operand pointer

.p2align 4
.inner_loop_pass1_x64:
    movq    %r13, %rax
    adcq    %rdx, %rbx
    mulq    (%r11)
    addq    %rax, %rbx
    adcq    $0, %rdx
    addq    %rbx, (%r10)
    movq    $0, %rbx
    addq    $8, %r10
    addq    $8, %r11
    loop    .inner_loop_pass1_x64

.outer_loop_end_pass1_x64:
    incq    %r12
    adcq    %rdx, (%r10)
    decq    %r9
    jnz     .outer_loop_pass1_x64

.before_pass2_x64:
    leaq    8(%rdi), %r10
    movq    %rcx, %rcx
    subq    $1, %rcx
    xorq    %r11, %r11

.loop_pass2_x64:
    rclq    $1, (%r10)
    rclq    $1, 8(%r10)
    addq    $16, %r10
    loop    .loop_pass2_x64

.before_pass3_x64:
    movq    %rdi, %r10    # result
    movq    %rsi, %r11    # operand
    movq    %rcx, %rcx    # size
    xorq    %r12, %r12    # carry

.loop_pass3_x64:
    adcq    $0, %r12
    movq    (%r11), %rax
    mulq    %rax
    addq    %rax, %r12
    addq    %r12, (%r10)
    adcq    %rdx, 8(%r10)
    movq    $0, %r12
    addq    $8, %r11
    addq    $16, %r10
    loop    .loop_pass3_x64

.end_of_func2_x64:
    popq    %r13
    popq    %r12
    popq    %rdi
    popq    %rsi
    popq    %rbx
    leave
    ret
.size sqr_bc_x64, .-sqr_bc_x64
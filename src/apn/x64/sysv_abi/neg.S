#   O---------------------------------------------------------------------------O
#   |                                                                           |
#   |                           NEGATION FUNCTIONS                              |
#   |                                                                           |
#   O---------------------------------------------------------------------------O

    .text

    # Function Arguments
    #
    # rdi -> result (apn_seg*)   
    # rsi -> op1 (const apn_seg*)
    # rdx -> size (apn_size)

# Negations (2's Complement) procedure tuned for
# AMD's Zen4 Microarchitecture with 4x unroll

    .globl neg_zen4
    .type neg_zen4, @function
neg_zen4:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rdx, %r11
    shrq    $2, %rdx
    andq    $3, %r11
    jz      unroll_loop_outer

small_loop:
    movq    $0, %rax
    movq    (%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %r11
    jnz     small_loop

unroll_loop_outer:
    setc    %al
    testq   %rdx, %rdx
    bt      $0, %ax
    jz      end_of_func

main_loop:
    movq    $0, %rax
    movq    (%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, (%rdi)

    movq    $0, %rax
    movq    8(%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, 8(%rdi)

    movq    $0, %rax
    movq    16(%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, 16(%rdi)

    movq    $0, %rax
    movq    24(%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, 24(%rdi)

    leaq    32(%rsi), %rsi
    leaq    32(%rdi), %rdi
    decq    %rdx
    jnz     main_loop

    .p2align 4
end_of_func:
    # discard any carry or borrow if generated
    leave
    ret
    .size neg_zen4, .-neg_zen4

# lowest common denominator generic implementation

    .globl neg_x64
    .type neg_x64, @function
neg_x64:
    pushq   %rbp
    movq    %rsp, %rbp

small_loop2:
    movq    $0, %rax
    movq    (%rsi), %r9
    sbbq    %r9, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %rdx
    jnz     small_loop2

end_of_func2:
    # no need to return the borrow as this is
    # 2's complement negation
    leave
    ret
    .size neg_x64, .-neg_x64
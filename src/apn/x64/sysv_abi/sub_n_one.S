    .text

    .globl sub_n_one_zen4
    .type sub_n_one_zen4, @function
sub_n_one_zen4:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    (%rsi), %rax
    subq    %rcx, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    setc    %al
    decq    %rdx

    movq    %rdx, %r11
    shrq    $2, %rdx
    andq    $3, %r11
    bt      $0, %ax
    jz      before_unroll

small_loop:
    movq    (%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %r11
    jnz     small_loop

before_unroll:
    setc    %al
    testq   %rdx, %rdx
    bt      $0, %ax
    jz      end_of_func

loop_unrolled:
    movq    (%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, (%rdi)

    movq    8(%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, 8(%rdi)

    movq    16(%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, 16(%rdi)

    movq    24(%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, 24(%rdi)

    leaq    32(%rsi), %rsi
    leaq    32(%rdi), %rdi
    decq    %rdx
    jnz     loop_unrolled

end_of_func:
    setc    %al
    movzbl  %al, %eax
    leave
    ret
    .size sub_n_one_zen4, .-sub_n_one_zen4

    .globl sub_n_one_x64
    .type sub_n_one_x64, @function
sub_n_one_x64:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    (%rsi), %rax
    subq    %rcx, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %rdx
    jz      end_of_func2

main_loop:
    movq    (%rsi), %rax
    sbbq    $0, %rax
    movq    %rax, (%rdi)

    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %rdx
    jnz     main_loop

end_of_func2:
    setc    %al
    movzbl  %al, %eax
    leave
    ret
    .size sub_n_one_x64, .-sub_n_one_x64
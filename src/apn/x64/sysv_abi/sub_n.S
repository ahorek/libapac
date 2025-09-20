    .text

    .globl sub_n_zen4
    .type sub_n_zen4, @function
sub_n_zen4:
    pushq   %rbp
    movq    %rsp, %rbp

    xorq    %rax, %rax
    movq    %rcx, %r11
    shrq    $2, %rcx
    andq    $3, %r11
    jz      before_unrolled

small_loop:
    movq    (%rdx), %rax
    sbbq    (%rsi), %rax
    movq    %rax, (%rdi)

    leaq    8(%rdx), %rdx
    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %r11
    jnz     small_loop

before_unrolled:
    setc    %al
    testq   %rcx, %rcx
    bt      $0, %ax
    jz      end_of_func

big_loop:
    movq    (%rdx), %rax
    sbbq    (%rsi), %rax
    movq    %rax, (%rdi)

    movq    8(%rdx), %rax
    sbbq    8(%rsi), %rax
    movq    %rax, 8(%rdi)

    movq    16(%rdx), %rax
    sbbq    16(%rsi), %rax
    movq    %rax, 16(%rdi)

    movq    24(%rdx), %rax
    sbbq    24(%rsi), %rax
    movq    %rax, 24(%rdi)

    leaq    32(%rdx), %rdx
    leaq    32(%rsi), %rsi
    leaq    32(%rdi), %rdi
    decq    %rcx
    jnz     big_loop

    .p2align 4
end_of_func:
    setc    %al
    movzbl  %al, %eax
    leave
    ret
    .size sub_n_zen4, .-sub_n_zen4

    .globl sub_n_x64
    .type sub_n_x64, @function
sub_n_x64:
    pushq   %rbp
    movq    %rsp, %rbp

main_loop:
    movq    (%rdx), %rax
    sbbq    (%rsi), %rax
    movq    %rax, (%rdi)

    leaq    8(%rdx), %rdx
    leaq    8(%rsi), %rsi
    leaq    8(%rdi), %rdi
    decq    %rcx
    jnz     main_loop

    .p2align 4
end_of_func2:
    setc    %al
    movzbl  %al, %eax
    leave
    ret
    .size sub_n_x64, .-sub_n_x64
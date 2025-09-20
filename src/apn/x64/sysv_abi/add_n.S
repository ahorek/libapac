#   O---------------------------------------------------------------------------O
#   |                                                                           |
#   |                   BALANCED ADDITION FUNCS (N LIMBS)                       |
#   |                                                                           |
#   O---------------------------------------------------------------------------O

.text

# Procedure tuned for optimal performance
# on AMD Zen4 microarchitecture

.globl add_n_zen4
.type add_n_zen4, @function
add_n_zen4:
    xor     %rax, %rax
    mov     %r9, %r11
    shr     $2, %r9        # size /= 4
    and     $3, %r11       # size %= 4
    jz      before_unrolled

    # runs at most thrice

small_loop:
    mov     (%rdx), %rax
    adc     (%r8), %rax
    mov     %rax, (%rcx)

    lea     8(%rdx), %rdx
    lea     8(%r8), %r8
    lea     8(%rcx), %rcx
    dec     %r11
    jnz     small_loop
    
before_unrolled:
    setc    %al           # for carry propagation
    test    %r9, %r9      # test if unrolled size is zero
    bt      $0, %ax       # bit-test doesn't modify zero flag
    jz      end_of_func     

big_loop:
    mov     (%rdx), %rax
    adc     (%r8), %rax
    mov     %rax, (%rcx)

    mov     8(%rdx), %rax
    adc     8(%r8), %rax
    mov     %rax, 8(%rcx)

    mov     16(%rdx), %rax
    adc     16(%r8), %rax
    mov     %rax, 16(%rcx)

    mov     24(%rdx), %rax
    adc     24(%r8), %rax
    mov     %rax, 24(%rcx)

    lea     32(%rdx), %rdx
    lea     32(%r8), %r8
    lea     32(%rcx), %rcx
    dec     %r9
    jnz     big_loop

.p2align 4
end_of_func:
    setc    %al
    movzbl  %al, %eax
    ret

.size add_n_zen4, .-add_n_zen4

# generic lowest common denominator x64 
# procedure for balanced addition

.globl add_n_x64
.type add_n_x64, @function
add_n_x64:
main_loop:
    mov     (%rdx), %rax
    adc     (%r8), %rax
    mov     %rax, (%rcx)

    lea     8(%rdx), %rdx
    lea     8(%r8), %r8
    lea     8(%rcx), %rcx
    dec     %r9
    jnz     main_loop

.p2align 4
end_of_func2:
    setc    %al
    movzbl  %al, %eax
    ret

.size add_n_x64, .-add_n_x64
#   O---------------------------------------------------------------------------O
#   |                                                                           |
#   |            APN-ARR BY ONE LIMB MULTIPLICATION FUNCTIONS                   |
#   |                                                                           |
#   O---------------------------------------------------------------------------O

.text

#   -------------------------
#
#        MULX/ADOX/ADCX (Zen4 optimized)
#
#   -------------------------

.globl addmul_one_zen4
.type addmul_one_zen4, @function
addmul_one_zen4:
    push    %rbx
    push    %rdi
    push    %rsi
    push    %r12

    # Register usage:
    # r10 = result pointer (was rcx)
    # r11 = op1 pointer (was rdx) 
    # r9  = multiplier value
    # r8  = size
    # rcx = loop counter
    # r12 = temporary storage
    
    xor     %rax, %rax        # Clear flags
    xor     %rbx, %rbx
    
    xchg    %rcx, %r10        # Free up rcx for loop counter
    xchg    %rdx, %r11        # Free up rdx for mulx
    
    mov     %r8, %rcx         # Copy size to loop counter
    shr     $3, %rcx          # size / 8 (unrolled iterations)
    and     $7, %r8           # size % 8 (remainder)
    mov     %r9, %rdx         # Load multiplier value for mulx
    
    test    %rcx, %rcx
    jz      .before_remainder  # Skip unrolled loop if no full blocks

.p2align 4
.unrolled_loop:
    # Process 8 limbs per iteration
    mulx    (%r11), %rsi, %rdi
    adcx    (%r10), %rsi
    adox    8(%r10), %rdi
    mov     %rsi, (%r10)
    mov     %rdi, %r12

    mulx    8(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    16(%r10), %rdi
    mov     %rsi, 8(%r10)
    mov     %rdi, %r12

    mulx    16(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    24(%r10), %rdi
    mov     %rsi, 16(%r10)
    mov     %rdi, %r12

    mulx    24(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    32(%r10), %rdi
    mov     %rsi, 24(%r10)
    mov     %rdi, %r12

    mulx    32(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    40(%r10), %rdi
    mov     %rsi, 32(%r10)
    mov     %rdi, %r12

    mulx    40(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    48(%r10), %rdi
    mov     %rsi, 40(%r10)
    mov     %rdi, %r12

    mulx    48(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    56(%r10), %rdi
    mov     %rsi, 48(%r10)
    mov     %rdi, %r12

    mulx    56(%r11), %rsi, %rdi
    adcx    %r12, %rsi
    adox    64(%r10), %rdi
    mov     %rsi, 56(%r10)
    mov     %rdi, 64(%r10)

    lea     64(%r10), %r10    # Advance result pointer
    lea     64(%r11), %r11    # Advance op1 pointer
    dec     %rcx              # Decrement loop counter

    jnz     .unrolled_loop

.before_remainder:
    mov     %r8, %rcx         # Load remainder count
    jrcxz   .end_of_func      # Skip if no remainder

.remainder_loop:
    mulx    (%r11), %rsi, %rdi
    adcx    (%r10), %rsi
    adox    8(%r10), %rdi
    mov     %rsi, (%r10)
    mov     %rdi, 8(%r10)
    
    lea     8(%r10), %r10     # Advance result pointer
    lea     8(%r11), %r11     # Advance op1 pointer
    loop    .remainder_loop

.end_of_func:
    pop     %r12
    pop     %rsi
    pop     %rdi
    pop     %rbx
    ret

.size addmul_one_zen4, .-addmul_one_zen4

#   -------------------------
#
#            MUL/ADC (Generic x64)
#
#   -------------------------

.globl addmul_one_x64
.type addmul_one_x64, @function
addmul_one_x64:
    push    %rbx
    push    %rdi
    push    %rsi

    # Register usage:
    # r10 = result pointer (was rdi)
    # r11 = op1 pointer (was rsi)
    # r9  = multiplier value
    # rcx = loop counter
    
    xchg    %rdi, %rcx        # Free up rcx for loop counter
    xchg    %rsi, %rdx        # Free up rdx for mul

    xor     %rdx, %rdx        # Clear high part for mul
    xor     %rbx, %rbx        # Clear temp register
    mov     %r8, %rcx         # Load size
    mov     %rdi, %r10        # Save result pointer
    mov     %rsi, %r11        # Save op1 pointer
    
    test    %rcx, %rcx
    jz      .end_of_func2

.main_loop:
    mov     %r9, %rax         # Restore multiplier value
    adc     %rdx, %rbx        # temp_reg += (CF + high64)
    mulq    (%r11)            # rdx:rax = rax * op1[idx]

    add     %rax, %rbx        # Add low part to temp
    adc     $0, %rdx          # Propagate carry to high part
    add     %rbx, (%r10)      # Add to result

    mov     $0, %rbx          # Clear temp register

    lea     8(%r10), %r10     # Advance result pointer
    lea     8(%r11), %r11     # Advance op1 pointer
    loop    .main_loop

    # Handle final carry
    adc     %rdx, (%r10)
    setc    %al
    movzbl  %al, %eax

.end_of_func2:
    pop     %rsi
    pop     %rdi
    pop     %rbx
    ret

.size addmul_one_x64, .-addmul_one_x64
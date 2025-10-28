	.text

#   O---------------------------------------------------------------------------O
#   |                                                                           |
#   |                   ADD SINGLE-LIMB TO APN-ARR FUNCTIONS                    |
#   |                                                                           |
#   O---------------------------------------------------------------------------O

#   Function Arguments
#
#   rdi -> result (apn_seg*)   
#   rsi -> op1 (const apn_seg*)
#   rdx -> size (apn_size)
#   rcx -> val (apn_seg)

	.globl	add_n_one_zen4
	.type	add_n_one_zen4, @function
add_n_one_zen4:
# assumes rdx is at least 1
# via APAC_ASSERT in caller function

	mov	(%rsi), %rax
	add	%rcx, %rax
	mov	%rax, (%rdi)

	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	setc	%al
	dec	%rdx

	mov	%rdx, %r11
	shr	$2, %rdx
	and	$3, %r11
	bt	$0, %ax          # doesn't modify zero flag
	jz	before_unroll

small_loop:
	mov	(%rsi), %rax
	adc	$0, %rax
	mov	%rax, (%rdi)

	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	dec	%r11
	jnz	small_loop

before_unroll:
	setc	%al
	test	%rdx, %rdx
	bt	$0, %ax      # same here       
	jz	end_of_func

loop_unrolled:
	mov	(%rsi), %rax
	adc	$0, %rax
	mov	%rax, (%rdi)

	mov	8(%rsi), %rax
	adc	$0, %rax
	mov	%rax, 8(%rdi)

	mov	16(%rsi), %rax
	adc	$0, %rax
	mov	%rax, 16(%rdi)

	mov	24(%rsi), %rax
	adc	$0, %rax
	mov	%rax, 24(%rdi)

	lea	32(%rsi), %rsi
	lea	32(%rdi), %rdi
	dec	%rdx
	jnz	loop_unrolled

end_of_func:
	setc	%al
	movzbq	%al, %rax      # Changed from movzbl to movzbq
	ret
	.size	add_n_one_zen4, .-add_n_one_zen4

# Generic x64 routine

	.globl	add_n_one_x64
	.type	add_n_one_x64, @function
add_n_one_x64:
	mov	(%rsi), %rax
	add	%rcx, %rax
	mov	%rax, (%rdi)

	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	dec	%rdx
	jz	end_of_func_x64

main_loop:
	mov	(%rsi), %rax
	adc	$0, %rax
	mov	%rax, (%rdi)

	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	dec	%rdx
	jnz	main_loop

end_of_func_x64:
	setc	%al
	movzbq	%al, %rax      # Changed from movzbl to movzbq
	ret
	.size	add_n_one_x64, .-add_n_one_x64
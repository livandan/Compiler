	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	addi	sp, sp, -224
	sd	s0, 184(sp)
	sd	s1, 176(sp)
	sd	s2, 104(sp)
	sd	s3, 96(sp)
	sd	s4, 88(sp)
	sd	s5, 80(sp)
	sd	s6, 72(sp)
	sd	s7, 64(sp)
	sd	s8, 56(sp)
	sd	s9, 48(sp)
	sd	s10, 40(sp)
	sd	s11, 32(sp)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	ld	s0, 184(sp)
	ld	s1, 176(sp)
	ld	s2, 104(sp)
	ld	s3, 96(sp)
	ld	s4, 88(sp)
	ld	s5, 80(sp)
	ld	s6, 72(sp)
	ld	s7, 64(sp)
	ld	s8, 56(sp)
	ld	s9, 48(sp)
	ld	s10, 40(sp)
	ld	s11, 32(sp)
	li	a0, 0
	addi	sp, sp, 224
	ret
.Lfunc_end8:
	.size	main, .Lfunc_end8-main
                                        # -- End function

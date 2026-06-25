    .file    "builtin.c"
    .option nopic
    .attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0"
    .attribute unaligned_access, 0
    .attribute stack_align, 16
    .text
    .align    1
    .globl    print
    .type    print, @function
print:
    mv    a1,a0
    lui    a0,%hi(.LC0)
    addi    a0,a0,%lo(.LC0)
    tail    printf
    .size    print, .-print
    .align    1
    .globl    println
    .type    println, @function
println:
    tail    puts
    .size    println, .-println
    .align    1
    .globl    printInt
    .type    printInt, @function
printInt:
    mv    a1,a0
    lui    a0,%hi(.LC1)
    addi    a0,a0,%lo(.LC1)
    tail    printf
    .size    printInt, .-printInt
    .align    1
    .globl    printlnInt
    .type    printlnInt, @function
printlnInt:
    mv    a1,a0
    lui    a0,%hi(.LC2)
    addi    a0,a0,%lo(.LC2)
    tail    printf
    .size    printlnInt, .-printlnInt
    .align    1
    .globl    getString
    .type    getString, @function
getString:
    addi    sp,sp,-16
    li    a0,256
    sd    ra,8(sp)
    sd    s0,0(sp)
    call    malloc
    mv    s0,a0
    mv    a1,a0
    lui    a0,%hi(.LC0)
    addi    a0,a0,%lo(.LC0)
    call    scanf
    mv    a0,s0
    ld    ra,8(sp)
    ld    s0,0(sp)
    addi    sp,sp,16
    jr    ra
    .size    getString, .-getString
    .align    1
    .globl    getInt
    .type    getInt, @function
getInt:
    addi    sp,sp,-32
    lui    a0,%hi(.LC1)
    addi    a1,sp,12
    addi    a0,a0,%lo(.LC1)
    sd    ra,24(sp)
    call    scanf
    ld    ra,24(sp)
    lw    a0,12(sp)
    addi    sp,sp,32
    jr    ra
    .size    getInt, .-getInt
    .align    1
    .globl    builtin_memset
    .type    builtin_memset, @function
builtin_memset:
    tail    memset
    .size    builtin_memset, .-builtin_memset
    .align    1
    .globl    builtin_memcpy
    .type    builtin_memcpy, @function
builtin_memcpy:
    tail    memcpy
    .size    builtin_memcpy, .-builtin_memcpy
    .section    .rodata.str1.8,"aMS",@progbits,1
    .align    3
.LC0:
    .string    "%s"
    .zero    5
.LC1:
    .string    "%d"
    .zero    5
.LC2:
    .string    "%d\n"
    .ident    "livandan's compiler 1.0"
	.text
	.globl	fn.0                            # -- Begin function fn.0
	.p2align	1
	.type	fn.0,@function
fn.0:                                   # @fn.0
# %bb.0:                                # %alloca
	addi	sp, sp, -512
	sd	s1, 464(sp)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	lw	t0, 0(a0)
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	li	t1, 1103
	mulw	t0, t0, t1
	add	s1, t0, x0
	li	t1, 4721
	addw	t0, s1, t1
	add	s1, t0, x0
	li	t1, 1048583
	remw	t0, s1, t1
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(a0)
	lw	t0, 0(a0)
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	slti	s1, t0, 0
	add	t0, s1, x0
	beq	x0, t0, .LBB8_0_jump_0
	j	.LBB8_11
.LBB8_0_jump_0:                               # %label_0_jump_0
	j	.LBB8_12
.LBB8_11:                               # %label_11
	lw	t0, 0(a0)
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	li	t0, 0
	subw	t0, t0, t1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(a0)
	j	.LBB8_12
.LBB8_12:                               # %label_12
	ld	s1, 464(sp)
	li	a0, 0
	addi	sp, sp, 512
	ret
.Lfunc_end8:
	.size	fn.0, .Lfunc_end8-fn.0
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -496
	j	.LBB9_0
.LBB9_0:                               # %label_0
	sd	ra, 488(sp)
	call	fn.5
	sw	a0, 140(sp)
	ld	ra, 488(sp)
	li	a0, 0
	addi	sp, sp, 496
	ret
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.globl	fn.2                            # -- Begin function fn.2
	.p2align	1
	.type	fn.2,@function
fn.2:                                   # @fn.2
# %bb.0:                                # %alloca
	addi	sp, sp, -624
	sd	s0, 584(sp)
	sd	s1, 576(sp)
	sd	s2, 504(sp)
	sd	s3, 496(sp)
	sd	s4, 488(sp)
	sd	s6, 472(sp)
	sd	s7, 464(sp)
	j	.LBB10_0
.LBB10_0:                               # %label_0
	addi	t0, a2, 0
	sd	t0, 264(sp)
	ld	t0, 264(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	a4, 0
	li	s0, 1
	j	.LBB10_10
.LBB10_10:                               # %label_10
	sltu	s7, s0, a1
	add	t0, s7, x0
	beq	x0, t0, .LBB10_10_jump_0
	j	.LBB10_11
.LBB10_10_jump_0:                               # %label_10_jump_0
	j	.LBB10_12
.LBB10_11:                               # %label_11
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 248(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 228(sp)
	lw	t0, 244(sp)
	lw	t1, 228(sp)
	xor	t0, t0, t1
	sltiu	s6, t0, 1
	add	t0, s6, x0
	beq	x0, t0, .LBB10_11_jump_0
	j	.LBB10_25
.LBB10_11_jump_0:                               # %label_11_jump_0
	j	.LBB10_26
.LBB10_12:                               # %label_12
	ld	s0, 584(sp)
	ld	s1, 576(sp)
	ld	s2, 504(sp)
	ld	s3, 496(sp)
	ld	s4, 488(sp)
	ld	s6, 472(sp)
	ld	s7, 464(sp)
	li	a0, 0
	addi	sp, sp, 624
	ret
.LBB10_25:                               # %label_25
	li	t1, 1
	addw	t0, a4, t1
	sw	t0, 220(sp)
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a2, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t1, 220(sp)
	sw	t1, 0(t0)
	li	t1, 1
	addw	t0, s0, t1
	add	s4, t0, x0
	lw	t0, 220(sp)
	add	a5, t0, x0
	add	s1, s4, x0
	j	.LBB10_27
.LBB10_26:                               # %label_26
	xori	t0, a4, 0
	sltu	s3, x0, t0
	add	t0, s3, x0
	beq	x0, t0, .LBB10_26_jump_0
	j	.LBB10_38
.LBB10_26_jump_0:                               # %label_26_jump_0
	j	.LBB10_39
.LBB10_27:                               # %label_27
	add	a4, a5, x0
	add	s0, s1, x0
	j	.LBB10_10
.LBB10_38:                               # %label_38
	li	t1, 1
	subw	t0, a4, t1
	add	s2, t0, x0
	add	t0, s2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a2, t0
	sd	t2, 184(sp)
	ld	t0, 184(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 180(sp)
	add	a6, t0, x0
	add	a3, s0, x0
	j	.LBB10_40
.LBB10_39:                               # %label_39
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a2, t0
	sd	t2, 168(sp)
	ld	t0, 168(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	t1, 1
	addw	t0, s0, t1
	add	a7, t0, x0
	add	a3, a7, x0
	add	a6, a4, x0
	j	.LBB10_40
.LBB10_40:                               # %label_40
	add	a5, a6, x0
	add	s1, a3, x0
	j	.LBB10_27
.Lfunc_end10:
	.size	fn.2, .Lfunc_end10-fn.2
                                        # -- End function
	.globl	fn.3                            # -- Begin function fn.3
	.p2align	1
	.type	fn.3,@function
fn.3:                                   # @fn.3
# %bb.0:                                # %alloca
	addi	sp, sp, -560
	sd	s0, 520(sp)
	sd	s1, 512(sp)
	sd	s2, 440(sp)
	li	t6, 196
	add	t6, t6, sp
	sd	t6, 200(sp)
	j	.LBB11_0
.LBB11_0:                               # %label_0
	ld	t0, 200(sp)
	li	t1, 24681
	sw	t1, 0(t0)
	li	s0, 0
	j	.LBB11_10
.LBB11_10:                               # %label_10
	sltu	s2, s0, a2
	add	t0, s2, x0
	beq	x0, t0, .LBB11_10_jump_0
	j	.LBB11_11
.LBB11_10_jump_0:                               # %label_10_jump_0
	j	.LBB11_12
.LBB11_11:                               # %label_11
	sd	ra, 552(sp)
	sd	a0, 504(sp)
	sd	a1, 496(sp)
	sd	a2, 488(sp)
	sd	a3, 480(sp)
	sd	a4, 472(sp)
	sd	a5, 464(sp)
	sd	a6, 456(sp)
	ld	a0, 200(sp)
	call	fn.0
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 504(sp)
	add	t2, t1, t0
	sd	t2, 184(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 180(sp)
	li	t1, 5
	remw	t0, t0, t1
	sw	t0, 176(sp)
	ld	t0, 184(sp)
	lw	t1, 176(sp)
	sw	t1, 0(t0)
	li	t1, 1
	addw	t0, s0, t1
	add	a6, t0, x0
	sd	a6, 456(sp)
	ld	ra, 552(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	ld	a4, 472(sp)
	ld	a5, 464(sp)
	ld	a6, 456(sp)
	add	s0, a6, x0
	j	.LBB11_10
.LBB11_12:                               # %label_12
	li	s1, 0
	j	.LBB11_25
.LBB11_25:                               # %label_25
	sltu	a5, s1, a3
	add	t0, a5, x0
	beq	x0, t0, .LBB11_25_jump_0
	j	.LBB11_26
.LBB11_25_jump_0:                               # %label_25_jump_0
	j	.LBB11_27
.LBB11_26:                               # %label_26
	sd	ra, 552(sp)
	sd	a0, 504(sp)
	sd	a1, 496(sp)
	sd	a2, 488(sp)
	sd	a3, 480(sp)
	sd	a4, 472(sp)
	sd	a5, 464(sp)
	sd	a6, 456(sp)
	ld	a0, 200(sp)
	call	fn.0
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 496(sp)
	add	t2, t1, t0
	sd	t2, 160(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	li	t1, 5
	remw	t0, t0, t1
	sw	t0, 152(sp)
	ld	t0, 160(sp)
	lw	t1, 152(sp)
	sw	t1, 0(t0)
	li	t1, 1
	addw	t0, s1, t1
	add	a4, t0, x0
	sd	a4, 472(sp)
	ld	ra, 552(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	ld	a4, 472(sp)
	ld	a5, 464(sp)
	ld	a6, 456(sp)
	add	s1, a4, x0
	j	.LBB11_25
.LBB11_27:                               # %label_27
	ld	s0, 520(sp)
	ld	s1, 512(sp)
	ld	s2, 440(sp)
	li	a0, 0
	addi	sp, sp, 560
	ret
.Lfunc_end11:
	.size	fn.3, .Lfunc_end11-fn.3
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	addi	sp, sp, -480
	j	.LBB12_0
.LBB12_0:                               # %label_0
	sd	ra, 472(sp)
	call	fn.1
	ld	ra, 472(sp)
	li	a0, 0
	addi	sp, sp, 480
	ret
.Lfunc_end12:
	.size	main, .Lfunc_end12-main
                                        # -- End function
	.globl	fn.5                            # -- Begin function fn.5
	.p2align	1
	.type	fn.5,@function
fn.5:                                   # @fn.5
# %bb.0:                                # %alloca
	li	t6, -2208
	add	sp, sp, t6
	li	t6, 1048
	add	t6, t6, sp
	sd	t6, 1848(sp)
	li	t6, 240
	add	t6, t6, sp
	sd	t6, 1040(sp)
	li	t6, 192
	add	t6, t6, sp
	sd	t6, 232(sp)
	li	t6, 144
	add	t6, t6, sp
	sd	t6, 184(sp)
	j	.LBB13_0
.LBB13_0:                               # %label_0
	li	t6, 2200
	add	t6, sp, t6
	sd	ra, 0(t6)
	ld	t0, 1040(sp)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 800
	call	builtin_memset
	ld	t0, 1848(sp)
	ld	t1, 1040(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	ld	t0, 184(sp)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40
	call	builtin_memset
	ld	t0, 232(sp)
	ld	t1, 184(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40
	call	builtin_memcpy
	ld	a0, 1848(sp)
	ld	a1, 232(sp)
	li	a2, 200
	li	a3, 10
	call	fn.3
	ld	a0, 1848(sp)
	ld	a1, 232(sp)
	li	a2, 200
	li	a3, 10
	call	fn.6
	sw	a0, 140(sp)
	li	t6, 2200
	add	t6, sp, t6
	ld	ra, 0(t6)
	lw	a0, 140(sp)
	li	t6, 2208
	add	sp, sp, t6
	ret
.Lfunc_end13:
	.size	fn.5, .Lfunc_end13-fn.5
                                        # -- End function
	.globl	fn.6                            # -- Begin function fn.6
	.p2align	1
	.type	fn.6,@function
fn.6:                                   # @fn.6
# %bb.0:                                # %alloca
	addi	sp, sp, -768
	sd	s0, 728(sp)
	sd	s1, 720(sp)
	sd	s2, 648(sp)
	sd	s3, 640(sp)
	sd	s4, 632(sp)
	sd	s5, 624(sp)
	sd	s7, 608(sp)
	sd	s8, 600(sp)
	sd	s9, 592(sp)
	sd	s10, 584(sp)
	sd	s11, 576(sp)
	li	t6, 368
	add	t6, t6, sp
	sd	t6, 408(sp)
	li	t6, 320
	add	t6, t6, sp
	sd	t6, 360(sp)
	j	.LBB14_0
.LBB14_0:                               # %label_0
	sd	ra, 760(sp)
	sd	a0, 712(sp)
	sd	a1, 704(sp)
	sd	a2, 696(sp)
	sd	a3, 688(sp)
	sd	a4, 680(sp)
	sd	a5, 672(sp)
	sd	a6, 664(sp)
	sd	a7, 656(sp)
	sd	t3, 568(sp)
	sd	t4, 560(sp)
	sd	t5, 552(sp)
	ld	t0, 360(sp)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40
	call	builtin_memset
	ld	t0, 408(sp)
	ld	t1, 360(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40
	call	builtin_memcpy
	ld	a0, 704(sp)
	ld	a1, 688(sp)
	ld	a2, 408(sp)
	call	fn.2
	ld	ra, 760(sp)
	ld	a0, 712(sp)
	ld	a1, 704(sp)
	ld	a2, 696(sp)
	ld	a3, 688(sp)
	ld	a4, 680(sp)
	ld	a5, 672(sp)
	ld	a6, 664(sp)
	ld	a7, 656(sp)
	ld	t3, 568(sp)
	ld	t4, 560(sp)
	ld	t5, 552(sp)
	li	t0, 0
	sw	t0, 180(sp)
	li	s2, 0
	li	s1, 0
	j	.LBB14_17
.LBB14_17:                               # %label_17
	sltu	t0, s2, a2
	sb	t0, 319(sp)
	lbu	t0, 319(sp)
	beq	x0, t0, .LBB14_17_jump_0
	j	.LBB14_18
.LBB14_17_jump_0:                               # %label_17_jump_0
	j	.LBB14_19
.LBB14_18:                               # %label_18
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a1, t0
	sd	t2, 304(sp)
	ld	t0, 304(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	add	t0, s2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 288(sp)
	ld	t0, 288(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	lw	t0, 300(sp)
	lw	t1, 284(sp)
	xor	t0, t0, t1
	sltiu	t0, t0, 1
	sb	t0, 283(sp)
	add	a7, s2, x0
	add	s0, s1, x0
	lbu	t0, 283(sp)
	beq	x0, t0, .LBB14_18_jump_0
	j	.LBB14_32
.LBB14_18_jump_0:                               # %label_18_jump_0
	j	.LBB14_33
.LBB14_19:                               # %label_19
	lw	a0, 180(sp)
	ld	s0, 728(sp)
	ld	s1, 720(sp)
	ld	s2, 648(sp)
	ld	s3, 640(sp)
	ld	s4, 632(sp)
	ld	s5, 624(sp)
	ld	s7, 608(sp)
	ld	s8, 600(sp)
	ld	s9, 592(sp)
	ld	s10, 584(sp)
	ld	s11, 576(sp)
	addi	sp, sp, 768
	ret
.LBB14_32:                               # %label_32
	li	t1, 1
	addw	t0, s2, t1
	sw	t0, 276(sp)
	li	t1, 1
	addw	t0, s1, t1
	sw	t0, 272(sp)
	lw	t0, 276(sp)
	add	a7, t0, x0
	lw	t0, 272(sp)
	add	s0, t0, x0
	j	.LBB14_33
.LBB14_33:                               # %label_33
	xor	t0, s0, a3
	sltiu	t0, t0, 1
	sb	t0, 271(sp)
	lbu	t0, 271(sp)
	beq	x0, t0, .LBB14_33_jump_0
	j	.LBB14_41
.LBB14_33_jump_0:                               # %label_33_jump_0
	j	.LBB14_42
.LBB14_41:                               # %label_41
	lw	t0, 180(sp)
	li	t1, 1
	addw	t0, t0, t1
	sw	t0, 264(sp)
	li	t1, 1
	subw	t0, s0, t1
	sw	t0, 260(sp)
	lw	t0, 260(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 408(sp)
	add	t2, t1, t0
	sd	t2, 248(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	lw	t0, 264(sp)
	add	s7, t0, x0
	lw	t0, 244(sp)
	add	a4, t0, x0
	add	s3, a7, x0
	j	.LBB14_43
.LBB14_42:                               # %label_42
	sltu	t0, a7, a2
	sb	t0, 243(sp)
	lbu	t0, 243(sp)
	beq	x0, t0, .LBB14_42_jump_0
	j	.LBB14_53
.LBB14_42_jump_0:                               # %label_42_jump_0
	j	.LBB14_54
.LBB14_43:                               # %label_43
	add	t0, s7, x0
	sw	t0, 180(sp)
	add	s2, s3, x0
	add	s1, a4, x0
	j	.LBB14_17
.LBB14_53:                               # %label_53
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a1, t0
	sd	t2, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 228(sp)
	add	t0, a7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 216(sp)
	ld	t0, 216(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	lw	t0, 228(sp)
	lw	t1, 212(sp)
	xor	t0, t0, t1
	sltu	t4, x0, t0
	add	t5, t4, x0
	add	s11, t5, x0
	j	.LBB14_55
.LBB14_54:                               # %label_54
	li	t3, 0
	add	s11, t3, x0
	j	.LBB14_55
.LBB14_55:                               # %label_55
	add	s4, a7, x0
	add	a5, s0, x0
	add	t0, s11, x0
	beq	x0, t0, .LBB14_55_jump_0
	j	.LBB14_68
.LBB14_55_jump_0:                               # %label_55_jump_0
	j	.LBB14_69
.LBB14_68:                               # %label_68
	xori	t0, s0, 0
	sltu	s10, x0, t0
	add	t0, s10, x0
	beq	x0, t0, .LBB14_68_jump_0
	j	.LBB14_72
.LBB14_68_jump_0:                               # %label_68_jump_0
	j	.LBB14_73
.LBB14_69:                               # %label_69
	lw	t0, 180(sp)
	add	s7, t0, x0
	add	s3, s4, x0
	add	a4, a5, x0
	j	.LBB14_43
.LBB14_72:                               # %label_72
	li	t1, 1
	subw	t0, s0, t1
	add	s9, t0, x0
	add	t0, s9, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 408(sp)
	add	t2, t1, t0
	sd	t2, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	add	a6, t0, x0
	add	s5, a7, x0
	j	.LBB14_74
.LBB14_73:                               # %label_73
	li	t1, 1
	addw	t0, a7, t1
	add	s8, t0, x0
	add	s5, s8, x0
	add	a6, s0, x0
	j	.LBB14_74
.LBB14_74:                               # %label_74
	add	s4, s5, x0
	add	a5, a6, x0
	j	.LBB14_69
.Lfunc_end14:
	.size	fn.6, .Lfunc_end14-fn.6
                                        # -- End function

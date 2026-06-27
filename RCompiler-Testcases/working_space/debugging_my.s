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
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	addi	sp, sp, -176
	sd	s0, 160(sp)
	sd	s1, 168(sp)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	li	a1, 12346
	li	a0, 12347
	li	s1, 12348
	sd	ra, 128(sp)
	sd	a0, 136(sp)
	sd	a1, 144(sp)
	sd	a2, 152(sp)
	li	a0, 12345
	ld	a1, 144(sp)
	ld	a2, 136(sp)
	add	a3, s1, x0
	call	fn.3
	add	a2, a0, x0
	sd	a2, 152(sp)
	li	a1, 12350
	sd	a1, 144(sp)
	li	a0, 12352
	sd	a0, 136(sp)
	li	s1, 12356
	ld	a0, 152(sp)
	ld	a1, 144(sp)
	ld	a2, 136(sp)
	add	a3, s1, x0
	call	fn.4
	add	a1, a0, x0
	sd	a1, 144(sp)
	li	a0, 12358
	sd	a0, 136(sp)
	li	s1, 12362
	ld	a0, 152(sp)
	ld	a1, 144(sp)
	ld	a2, 136(sp)
	add	a3, s1, x0
	call	fn.2
	add	a0, a0, x0
	sd	a0, 136(sp)
	ld	a0, 152(sp)
	ld	a1, 144(sp)
	ld	a2, 136(sp)
	li	a3, 12345
	call	fn.5
	add	s1, a0, x0
	ld	ra, 128(sp)
	ld	a0, 136(sp)
	ld	a1, 144(sp)
	ld	a2, 152(sp)
	add	t0, s1, x0
	beqz	t0, .LBB8_30
.LBB8_27:                               # %label_27
	li	t6, 12345
	addw	s0, a2, t6
	j	.LBB8_29
.LBB8_28:                               # %label_28
	li	t6, 12345
	addw	s0, a1, t6
.LBB8_29:                               # %label_29
	ld	s0, 160(sp)
	ld	s1, 168(sp)
	li	a0, 0
	addi	sp, sp, 176
	ret
.LBB8_30:                               # %label_30
	sd	ra, 128(sp)
	sd	a0, 136(sp)
	sd	a1, 144(sp)
	sd	a2, 152(sp)
	ld	a0, 136(sp)
	ld	a1, 144(sp)
	ld	a2, 152(sp)
	li	a3, 12345
	call	fn.1
	add	s0, a0, x0
	ld	ra, 128(sp)
	ld	a0, 136(sp)
	ld	a1, 144(sp)
	ld	a2, 152(sp)
	add	t0, s0, x0
	beq	x0, t0, .LBB8_30_jump_0
	j	.LBB8_27
.LBB8_30_jump_0:                               # %label_30_jump_0
	j	.LBB8_28
.Lfunc_end8:
	.size	main, .Lfunc_end8-main
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -304
	sd	s0, 200(sp)
	sd	s1, 208(sp)
	sd	s2, 216(sp)
	sd	s3, 224(sp)
	sd	s4, 232(sp)
	sd	s5, 240(sp)
	sd	s6, 248(sp)
	sd	s7, 256(sp)
	sd	s8, 264(sp)
	sd	s9, 272(sp)
	sd	s10, 280(sp)
	sd	s11, 288(sp)
	j	.LBB9_0
.LBB9_0:                               # %label_0
	addiw	t0, a0, -1
	sw	t0, 0(sp)
	addiw	t0, a1, -2
	sw	t0, 4(sp)
	addiw	t0, a2, -3
	sw	t0, 8(sp)
	addiw	t0, a3, -4
	sw	t0, 12(sp)
	lw	t1, 0(sp)
	sub	t0, a3, t1
	sltu	a5, x0, t0
	add	t0, a5, x0
	beqz	t0, .LBB9_408
.LBB9_20:                               # %label_20
	li	t0, 1
	sb	t0, 96(sp)
	j	.LBB9_22
.LBB9_21:                               # %label_21
	li	t0, 0
	sb	t0, 96(sp)
.LBB9_22:                               # %label_22
	lbu	a0, 96(sp)
	ld	s0, 200(sp)
	ld	s1, 208(sp)
	ld	s2, 216(sp)
	ld	s3, 224(sp)
	ld	s4, 232(sp)
	ld	s5, 240(sp)
	ld	s6, 248(sp)
	ld	s7, 256(sp)
	ld	s8, 264(sp)
	ld	s9, 272(sp)
	ld	s10, 280(sp)
	ld	s11, 288(sp)
	addi	sp, sp, 304
	ret
.LBB9_23:                               # %label_23
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	sb	t0, 16(sp)
	lbu	t0, 16(sp)
	beq	x0, t0, .LBB9_23_jump_0
	j	.LBB9_20
.LBB9_23_jump_0:                               # %label_23_jump_0
	j	.LBB9_21
.LBB9_24:                               # %label_24
	lw	t0, 4(sp)
	slt	t0, t0, a1
	xori	t0, t0, 1
	sb	t0, 17(sp)
	lbu	t0, 17(sp)
	beq	x0, t0, .LBB9_24_jump_0
	j	.LBB9_20
.LBB9_24_jump_0:                               # %label_24_jump_0
	j	.LBB9_23
.LBB9_28:                               # %label_28
	lw	t1, 0(sp)
	slt	t0, t1, a3
	xori	t0, t0, 1
	sb	t0, 18(sp)
	lbu	t0, 18(sp)
	beq	x0, t0, .LBB9_28_jump_0
	j	.LBB9_20
.LBB9_28_jump_0:                               # %label_28_jump_0
	j	.LBB9_24
.LBB9_32:                               # %label_32
	lw	t1, 12(sp)
	sub	t0, a1, t1
	sltu	t0, x0, t0
	sb	t0, 19(sp)
	lbu	t0, 19(sp)
	beq	x0, t0, .LBB9_32_jump_0
	j	.LBB9_20
.LBB9_32_jump_0:                               # %label_32_jump_0
	j	.LBB9_28
.LBB9_36:                               # %label_36
	lw	t0, 12(sp)
	slt	t0, a2, t0
	sb	t0, 20(sp)
	lbu	t0, 20(sp)
	beq	x0, t0, .LBB9_36_jump_0
	j	.LBB9_20
.LBB9_36_jump_0:                               # %label_36_jump_0
	j	.LBB9_32
.LBB9_40:                               # %label_40
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t0, t1
	sb	t0, 21(sp)
	lbu	t0, 21(sp)
	beq	x0, t0, .LBB9_40_jump_0
	j	.LBB9_20
.LBB9_40_jump_0:                               # %label_40_jump_0
	j	.LBB9_36
.LBB9_44:                               # %label_44
	slt	t0, a3, a0
	xori	t0, t0, 1
	sb	t0, 22(sp)
	lbu	t0, 22(sp)
	beq	x0, t0, .LBB9_44_jump_0
	j	.LBB9_20
.LBB9_44_jump_0:                               # %label_44_jump_0
	j	.LBB9_40
.LBB9_48:                               # %label_48
	slt	t0, a3, a1
	xori	t0, t0, 1
	sb	t0, 23(sp)
	lbu	t0, 23(sp)
	beq	x0, t0, .LBB9_48_jump_0
	j	.LBB9_20
.LBB9_48_jump_0:                               # %label_48_jump_0
	j	.LBB9_44
.LBB9_52:                               # %label_52
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 24(sp)
	lbu	t0, 24(sp)
	beq	x0, t0, .LBB9_52_jump_0
	j	.LBB9_20
.LBB9_52_jump_0:                               # %label_52_jump_0
	j	.LBB9_48
.LBB9_56:                               # %label_56
	lw	t0, 4(sp)
	slt	t0, a1, t0
	sb	t0, 25(sp)
	lbu	t0, 25(sp)
	beq	x0, t0, .LBB9_56_jump_0
	j	.LBB9_20
.LBB9_56_jump_0:                               # %label_56_jump_0
	j	.LBB9_52
.LBB9_60:                               # %label_60
	lw	t1, 0(sp)
	slt	t0, a3, t1
	sb	t0, 26(sp)
	lbu	t0, 26(sp)
	beq	x0, t0, .LBB9_60_jump_0
	j	.LBB9_20
.LBB9_60_jump_0:                               # %label_60_jump_0
	j	.LBB9_56
.LBB9_64:                               # %label_64
	lw	t1, 12(sp)
	slt	t0, a1, t1
	xori	t0, t0, 1
	sb	t0, 27(sp)
	lbu	t0, 27(sp)
	beq	x0, t0, .LBB9_64_jump_0
	j	.LBB9_20
.LBB9_64_jump_0:                               # %label_64_jump_0
	j	.LBB9_60
.LBB9_68:                               # %label_68
	lw	t0, 12(sp)
	slt	t0, a2, t0
	xori	t0, t0, 1
	sb	t0, 28(sp)
	lbu	t0, 28(sp)
	beq	x0, t0, .LBB9_68_jump_0
	j	.LBB9_20
.LBB9_68_jump_0:                               # %label_68_jump_0
	j	.LBB9_64
.LBB9_72:                               # %label_72
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 29(sp)
	lbu	t0, 29(sp)
	beq	x0, t0, .LBB9_72_jump_0
	j	.LBB9_20
.LBB9_72_jump_0:                               # %label_72_jump_0
	j	.LBB9_68
.LBB9_76:                               # %label_76
	slt	t0, a0, a3
	sb	t0, 30(sp)
	lbu	t0, 30(sp)
	beq	x0, t0, .LBB9_76_jump_0
	j	.LBB9_20
.LBB9_76_jump_0:                               # %label_76_jump_0
	j	.LBB9_72
.LBB9_80:                               # %label_80
	slt	t0, a1, a3
	sb	t0, 31(sp)
	lbu	t0, 31(sp)
	beq	x0, t0, .LBB9_80_jump_0
	j	.LBB9_20
.LBB9_80_jump_0:                               # %label_80_jump_0
	j	.LBB9_76
.LBB9_84:                               # %label_84
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 32(sp)
	lbu	t0, 32(sp)
	beq	x0, t0, .LBB9_84_jump_0
	j	.LBB9_20
.LBB9_84_jump_0:                               # %label_84_jump_0
	j	.LBB9_80
.LBB9_88:                               # %label_88
	lw	t0, 4(sp)
	slt	t0, a1, t0
	xori	t0, t0, 1
	sb	t0, 33(sp)
	lbu	t0, 33(sp)
	beq	x0, t0, .LBB9_88_jump_0
	j	.LBB9_20
.LBB9_88_jump_0:                               # %label_88_jump_0
	j	.LBB9_84
.LBB9_92:                               # %label_92
	lw	t1, 0(sp)
	sub	t0, a3, t1
	sltu	t0, x0, t0
	sb	t0, 34(sp)
	lbu	t0, 34(sp)
	beq	x0, t0, .LBB9_92_jump_0
	j	.LBB9_20
.LBB9_92_jump_0:                               # %label_92_jump_0
	j	.LBB9_88
.LBB9_96:                               # %label_96
	lw	t1, 12(sp)
	slt	t0, t1, a1
	sb	t0, 35(sp)
	lbu	t0, 35(sp)
	beq	x0, t0, .LBB9_96_jump_0
	j	.LBB9_20
.LBB9_96_jump_0:                               # %label_96_jump_0
	j	.LBB9_92
.LBB9_100:                               # %label_100
	lw	t0, 12(sp)
	slt	t0, t0, a2
	sb	t0, 36(sp)
	lbu	t0, 36(sp)
	beq	x0, t0, .LBB9_100_jump_0
	j	.LBB9_20
.LBB9_100_jump_0:                               # %label_100_jump_0
	j	.LBB9_96
.LBB9_104:                               # %label_104
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 37(sp)
	lbu	t0, 37(sp)
	beq	x0, t0, .LBB9_104_jump_0
	j	.LBB9_20
.LBB9_104_jump_0:                               # %label_104_jump_0
	j	.LBB9_100
.LBB9_108:                               # %label_108
	slt	t0, a0, a3
	xori	t0, t0, 1
	sb	t0, 38(sp)
	lbu	t0, 38(sp)
	beq	x0, t0, .LBB9_108_jump_0
	j	.LBB9_20
.LBB9_108_jump_0:                               # %label_108_jump_0
	j	.LBB9_104
.LBB9_112:                               # %label_112
	sub	t0, a1, a3
	sltu	t0, x0, t0
	sb	t0, 39(sp)
	lbu	t0, 39(sp)
	beq	x0, t0, .LBB9_112_jump_0
	j	.LBB9_20
.LBB9_112_jump_0:                               # %label_112_jump_0
	j	.LBB9_108
.LBB9_116:                               # %label_116
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	sb	t0, 40(sp)
	lbu	t0, 40(sp)
	beq	x0, t0, .LBB9_116_jump_0
	j	.LBB9_20
.LBB9_116_jump_0:                               # %label_116_jump_0
	j	.LBB9_112
.LBB9_120:                               # %label_120
	lw	t0, 4(sp)
	slt	t0, t0, a1
	sb	t0, 41(sp)
	lbu	t0, 41(sp)
	beq	x0, t0, .LBB9_120_jump_0
	j	.LBB9_20
.LBB9_120_jump_0:                               # %label_120_jump_0
	j	.LBB9_116
.LBB9_124:                               # %label_124
	lw	t1, 0(sp)
	slt	t0, a3, t1
	xori	t0, t0, 1
	sb	t0, 42(sp)
	lbu	t0, 42(sp)
	beq	x0, t0, .LBB9_124_jump_0
	j	.LBB9_20
.LBB9_124_jump_0:                               # %label_124_jump_0
	j	.LBB9_120
.LBB9_128:                               # %label_128
	lw	t1, 12(sp)
	slt	t0, t1, a1
	xori	t0, t0, 1
	sb	t0, 43(sp)
	lbu	t0, 43(sp)
	beq	x0, t0, .LBB9_128_jump_0
	j	.LBB9_20
.LBB9_128_jump_0:                               # %label_128_jump_0
	j	.LBB9_124
.LBB9_132:                               # %label_132
	lw	t0, 12(sp)
	sub	t0, t0, a2
	sltu	t0, x0, t0
	sb	t0, 44(sp)
	lbu	t0, 44(sp)
	beq	x0, t0, .LBB9_132_jump_0
	j	.LBB9_20
.LBB9_132_jump_0:                               # %label_132_jump_0
	j	.LBB9_128
.LBB9_136:                               # %label_136
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t1, t0
	sb	t0, 45(sp)
	lbu	t0, 45(sp)
	beq	x0, t0, .LBB9_136_jump_0
	j	.LBB9_20
.LBB9_136_jump_0:                               # %label_136_jump_0
	j	.LBB9_132
.LBB9_140:                               # %label_140
	slt	t0, a3, a0
	sb	t0, 46(sp)
	lbu	t0, 46(sp)
	beq	x0, t0, .LBB9_140_jump_0
	j	.LBB9_20
.LBB9_140_jump_0:                               # %label_140_jump_0
	j	.LBB9_136
.LBB9_144:                               # %label_144
	slt	t0, a1, a3
	xori	t0, t0, 1
	sb	t0, 47(sp)
	lbu	t0, 47(sp)
	beq	x0, t0, .LBB9_144_jump_0
	j	.LBB9_20
.LBB9_144_jump_0:                               # %label_144_jump_0
	j	.LBB9_140
.LBB9_148:                               # %label_148
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 48(sp)
	lbu	t0, 48(sp)
	beq	x0, t0, .LBB9_148_jump_0
	j	.LBB9_20
.LBB9_148_jump_0:                               # %label_148_jump_0
	j	.LBB9_144
.LBB9_152:                               # %label_152
	lw	t0, 4(sp)
	sub	t0, t0, a1
	sltu	t0, x0, t0
	sb	t0, 49(sp)
	lbu	t0, 49(sp)
	beq	x0, t0, .LBB9_152_jump_0
	j	.LBB9_20
.LBB9_152_jump_0:                               # %label_152_jump_0
	j	.LBB9_148
.LBB9_156:                               # %label_156
	lw	t1, 0(sp)
	slt	t0, t1, a3
	sb	t0, 50(sp)
	lbu	t0, 50(sp)
	beq	x0, t0, .LBB9_156_jump_0
	j	.LBB9_20
.LBB9_156_jump_0:                               # %label_156_jump_0
	j	.LBB9_152
.LBB9_160:                               # %label_160
	lw	t1, 12(sp)
	slt	t0, a1, t1
	sb	t0, 51(sp)
	lbu	t0, 51(sp)
	beq	x0, t0, .LBB9_160_jump_0
	j	.LBB9_20
.LBB9_160_jump_0:                               # %label_160_jump_0
	j	.LBB9_156
.LBB9_164:                               # %label_164
	lw	t0, 12(sp)
	slt	t0, t0, a2
	xori	t0, t0, 1
	sb	t0, 52(sp)
	lbu	t0, 52(sp)
	beq	x0, t0, .LBB9_164_jump_0
	j	.LBB9_20
.LBB9_164_jump_0:                               # %label_164_jump_0
	j	.LBB9_160
.LBB9_168:                               # %label_168
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 53(sp)
	lbu	t0, 53(sp)
	beq	x0, t0, .LBB9_168_jump_0
	j	.LBB9_20
.LBB9_168_jump_0:                               # %label_168_jump_0
	j	.LBB9_164
.LBB9_172:                               # %label_172
	sub	t0, a3, a0
	sltu	t0, x0, t0
	sb	t0, 54(sp)
	lbu	t0, 54(sp)
	beq	x0, t0, .LBB9_172_jump_0
	j	.LBB9_20
.LBB9_172_jump_0:                               # %label_172_jump_0
	j	.LBB9_168
.LBB9_176:                               # %label_176
	slt	t0, a3, a1
	sb	t0, 55(sp)
	lbu	t0, 55(sp)
	beq	x0, t0, .LBB9_176_jump_0
	j	.LBB9_20
.LBB9_176_jump_0:                               # %label_176_jump_0
	j	.LBB9_172
.LBB9_180:                               # %label_180
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	sb	t0, 56(sp)
	lbu	t0, 56(sp)
	beq	x0, t0, .LBB9_180_jump_0
	j	.LBB9_20
.LBB9_180_jump_0:                               # %label_180_jump_0
	j	.LBB9_176
.LBB9_184:                               # %label_184
	lw	t0, 4(sp)
	slt	t0, t0, a1
	xori	t0, t0, 1
	sb	t0, 57(sp)
	lbu	t0, 57(sp)
	beq	x0, t0, .LBB9_184_jump_0
	j	.LBB9_20
.LBB9_184_jump_0:                               # %label_184_jump_0
	j	.LBB9_180
.LBB9_188:                               # %label_188
	lw	t1, 0(sp)
	slt	t0, t1, a3
	xori	t0, t0, 1
	sb	t0, 58(sp)
	lbu	t0, 58(sp)
	beq	x0, t0, .LBB9_188_jump_0
	j	.LBB9_20
.LBB9_188_jump_0:                               # %label_188_jump_0
	j	.LBB9_184
.LBB9_192:                               # %label_192
	lw	t1, 12(sp)
	sub	t0, a1, t1
	sltu	t0, x0, t0
	sb	t0, 59(sp)
	lbu	t0, 59(sp)
	beq	x0, t0, .LBB9_192_jump_0
	j	.LBB9_20
.LBB9_192_jump_0:                               # %label_192_jump_0
	j	.LBB9_188
.LBB9_196:                               # %label_196
	lw	t0, 12(sp)
	slt	t0, a2, t0
	sb	t0, 60(sp)
	lbu	t0, 60(sp)
	beq	x0, t0, .LBB9_196_jump_0
	j	.LBB9_20
.LBB9_196_jump_0:                               # %label_196_jump_0
	j	.LBB9_192
.LBB9_200:                               # %label_200
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t0, t1
	sb	t0, 61(sp)
	lbu	t0, 61(sp)
	beq	x0, t0, .LBB9_200_jump_0
	j	.LBB9_20
.LBB9_200_jump_0:                               # %label_200_jump_0
	j	.LBB9_196
.LBB9_204:                               # %label_204
	slt	t0, a3, a0
	xori	t0, t0, 1
	sb	t0, 62(sp)
	lbu	t0, 62(sp)
	beq	x0, t0, .LBB9_204_jump_0
	j	.LBB9_20
.LBB9_204_jump_0:                               # %label_204_jump_0
	j	.LBB9_200
.LBB9_208:                               # %label_208
	slt	t0, a3, a1
	xori	t0, t0, 1
	sb	t0, 63(sp)
	lbu	t0, 63(sp)
	beq	x0, t0, .LBB9_208_jump_0
	j	.LBB9_20
.LBB9_208_jump_0:                               # %label_208_jump_0
	j	.LBB9_204
.LBB9_212:                               # %label_212
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 64(sp)
	lbu	t0, 64(sp)
	beq	x0, t0, .LBB9_212_jump_0
	j	.LBB9_20
.LBB9_212_jump_0:                               # %label_212_jump_0
	j	.LBB9_208
.LBB9_216:                               # %label_216
	lw	t0, 4(sp)
	slt	t0, a1, t0
	sb	t0, 65(sp)
	lbu	t0, 65(sp)
	beq	x0, t0, .LBB9_216_jump_0
	j	.LBB9_20
.LBB9_216_jump_0:                               # %label_216_jump_0
	j	.LBB9_212
.LBB9_220:                               # %label_220
	lw	t1, 0(sp)
	slt	t0, a3, t1
	sb	t0, 66(sp)
	lbu	t0, 66(sp)
	beq	x0, t0, .LBB9_220_jump_0
	j	.LBB9_20
.LBB9_220_jump_0:                               # %label_220_jump_0
	j	.LBB9_216
.LBB9_224:                               # %label_224
	lw	t1, 12(sp)
	slt	t0, a1, t1
	xori	t0, t0, 1
	sb	t0, 67(sp)
	lbu	t0, 67(sp)
	beq	x0, t0, .LBB9_224_jump_0
	j	.LBB9_20
.LBB9_224_jump_0:                               # %label_224_jump_0
	j	.LBB9_220
.LBB9_228:                               # %label_228
	lw	t0, 12(sp)
	slt	t0, a2, t0
	xori	t0, t0, 1
	sb	t0, 68(sp)
	lbu	t0, 68(sp)
	beq	x0, t0, .LBB9_228_jump_0
	j	.LBB9_20
.LBB9_228_jump_0:                               # %label_228_jump_0
	j	.LBB9_224
.LBB9_232:                               # %label_232
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 69(sp)
	lbu	t0, 69(sp)
	beq	x0, t0, .LBB9_232_jump_0
	j	.LBB9_20
.LBB9_232_jump_0:                               # %label_232_jump_0
	j	.LBB9_228
.LBB9_236:                               # %label_236
	slt	t0, a0, a3
	sb	t0, 70(sp)
	lbu	t0, 70(sp)
	beq	x0, t0, .LBB9_236_jump_0
	j	.LBB9_20
.LBB9_236_jump_0:                               # %label_236_jump_0
	j	.LBB9_232
.LBB9_240:                               # %label_240
	slt	t0, a1, a3
	sb	t0, 71(sp)
	lbu	t0, 71(sp)
	beq	x0, t0, .LBB9_240_jump_0
	j	.LBB9_20
.LBB9_240_jump_0:                               # %label_240_jump_0
	j	.LBB9_236
.LBB9_244:                               # %label_244
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 72(sp)
	lbu	t0, 72(sp)
	beq	x0, t0, .LBB9_244_jump_0
	j	.LBB9_20
.LBB9_244_jump_0:                               # %label_244_jump_0
	j	.LBB9_240
.LBB9_248:                               # %label_248
	lw	t0, 4(sp)
	slt	t0, a1, t0
	xori	t0, t0, 1
	sb	t0, 73(sp)
	lbu	t0, 73(sp)
	beq	x0, t0, .LBB9_248_jump_0
	j	.LBB9_20
.LBB9_248_jump_0:                               # %label_248_jump_0
	j	.LBB9_244
.LBB9_252:                               # %label_252
	lw	t1, 0(sp)
	sub	t0, a3, t1
	sltu	t0, x0, t0
	sb	t0, 74(sp)
	lbu	t0, 74(sp)
	beq	x0, t0, .LBB9_252_jump_0
	j	.LBB9_20
.LBB9_252_jump_0:                               # %label_252_jump_0
	j	.LBB9_248
.LBB9_256:                               # %label_256
	lw	t1, 12(sp)
	slt	t0, t1, a1
	sb	t0, 75(sp)
	lbu	t0, 75(sp)
	beq	x0, t0, .LBB9_256_jump_0
	j	.LBB9_20
.LBB9_256_jump_0:                               # %label_256_jump_0
	j	.LBB9_252
.LBB9_260:                               # %label_260
	lw	t0, 12(sp)
	slt	t0, t0, a2
	sb	t0, 76(sp)
	lbu	t0, 76(sp)
	beq	x0, t0, .LBB9_260_jump_0
	j	.LBB9_20
.LBB9_260_jump_0:                               # %label_260_jump_0
	j	.LBB9_256
.LBB9_264:                               # %label_264
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 77(sp)
	lbu	t0, 77(sp)
	beq	x0, t0, .LBB9_264_jump_0
	j	.LBB9_20
.LBB9_264_jump_0:                               # %label_264_jump_0
	j	.LBB9_260
.LBB9_268:                               # %label_268
	slt	t0, a0, a3
	xori	t0, t0, 1
	sb	t0, 78(sp)
	lbu	t0, 78(sp)
	beq	x0, t0, .LBB9_268_jump_0
	j	.LBB9_20
.LBB9_268_jump_0:                               # %label_268_jump_0
	j	.LBB9_264
.LBB9_272:                               # %label_272
	sub	t0, a1, a3
	sltu	t0, x0, t0
	sb	t0, 79(sp)
	lbu	t0, 79(sp)
	beq	x0, t0, .LBB9_272_jump_0
	j	.LBB9_20
.LBB9_272_jump_0:                               # %label_272_jump_0
	j	.LBB9_268
.LBB9_276:                               # %label_276
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	sb	t0, 80(sp)
	lbu	t0, 80(sp)
	beq	x0, t0, .LBB9_276_jump_0
	j	.LBB9_20
.LBB9_276_jump_0:                               # %label_276_jump_0
	j	.LBB9_272
.LBB9_280:                               # %label_280
	lw	t0, 4(sp)
	slt	t0, t0, a1
	sb	t0, 81(sp)
	lbu	t0, 81(sp)
	beq	x0, t0, .LBB9_280_jump_0
	j	.LBB9_20
.LBB9_280_jump_0:                               # %label_280_jump_0
	j	.LBB9_276
.LBB9_284:                               # %label_284
	lw	t1, 0(sp)
	slt	t0, a3, t1
	xori	t0, t0, 1
	sb	t0, 82(sp)
	lbu	t0, 82(sp)
	beq	x0, t0, .LBB9_284_jump_0
	j	.LBB9_20
.LBB9_284_jump_0:                               # %label_284_jump_0
	j	.LBB9_280
.LBB9_288:                               # %label_288
	lw	t1, 12(sp)
	slt	t0, t1, a1
	xori	t0, t0, 1
	sb	t0, 83(sp)
	lbu	t0, 83(sp)
	beq	x0, t0, .LBB9_288_jump_0
	j	.LBB9_20
.LBB9_288_jump_0:                               # %label_288_jump_0
	j	.LBB9_284
.LBB9_292:                               # %label_292
	lw	t0, 12(sp)
	sub	t0, t0, a2
	sltu	t0, x0, t0
	sb	t0, 84(sp)
	lbu	t0, 84(sp)
	beq	x0, t0, .LBB9_292_jump_0
	j	.LBB9_20
.LBB9_292_jump_0:                               # %label_292_jump_0
	j	.LBB9_288
.LBB9_296:                               # %label_296
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t1, t0
	sb	t0, 85(sp)
	lbu	t0, 85(sp)
	beq	x0, t0, .LBB9_296_jump_0
	j	.LBB9_20
.LBB9_296_jump_0:                               # %label_296_jump_0
	j	.LBB9_292
.LBB9_300:                               # %label_300
	slt	t0, a3, a0
	sb	t0, 86(sp)
	lbu	t0, 86(sp)
	beq	x0, t0, .LBB9_300_jump_0
	j	.LBB9_20
.LBB9_300_jump_0:                               # %label_300_jump_0
	j	.LBB9_296
.LBB9_304:                               # %label_304
	slt	t0, a1, a3
	xori	t0, t0, 1
	sb	t0, 87(sp)
	lbu	t0, 87(sp)
	beq	x0, t0, .LBB9_304_jump_0
	j	.LBB9_20
.LBB9_304_jump_0:                               # %label_304_jump_0
	j	.LBB9_300
.LBB9_308:                               # %label_308
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 88(sp)
	lbu	t0, 88(sp)
	beq	x0, t0, .LBB9_308_jump_0
	j	.LBB9_20
.LBB9_308_jump_0:                               # %label_308_jump_0
	j	.LBB9_304
.LBB9_312:                               # %label_312
	lw	t0, 4(sp)
	sub	t0, t0, a1
	sltu	t0, x0, t0
	sb	t0, 89(sp)
	lbu	t0, 89(sp)
	beq	x0, t0, .LBB9_312_jump_0
	j	.LBB9_20
.LBB9_312_jump_0:                               # %label_312_jump_0
	j	.LBB9_308
.LBB9_316:                               # %label_316
	lw	t1, 0(sp)
	slt	t0, t1, a3
	sb	t0, 90(sp)
	lbu	t0, 90(sp)
	beq	x0, t0, .LBB9_316_jump_0
	j	.LBB9_20
.LBB9_316_jump_0:                               # %label_316_jump_0
	j	.LBB9_312
.LBB9_320:                               # %label_320
	lw	t1, 12(sp)
	slt	t0, a1, t1
	sb	t0, 91(sp)
	lbu	t0, 91(sp)
	beq	x0, t0, .LBB9_320_jump_0
	j	.LBB9_20
.LBB9_320_jump_0:                               # %label_320_jump_0
	j	.LBB9_316
.LBB9_324:                               # %label_324
	lw	t0, 12(sp)
	slt	t0, t0, a2
	xori	t0, t0, 1
	sb	t0, 92(sp)
	lbu	t0, 92(sp)
	beq	x0, t0, .LBB9_324_jump_0
	j	.LBB9_20
.LBB9_324_jump_0:                               # %label_324_jump_0
	j	.LBB9_320
.LBB9_328:                               # %label_328
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 93(sp)
	lbu	t0, 93(sp)
	beq	x0, t0, .LBB9_328_jump_0
	j	.LBB9_20
.LBB9_328_jump_0:                               # %label_328_jump_0
	j	.LBB9_324
.LBB9_332:                               # %label_332
	sub	t0, a3, a0
	sltu	t0, x0, t0
	sb	t0, 94(sp)
	lbu	t0, 94(sp)
	beq	x0, t0, .LBB9_332_jump_0
	j	.LBB9_20
.LBB9_332_jump_0:                               # %label_332_jump_0
	j	.LBB9_328
.LBB9_336:                               # %label_336
	slt	t0, a3, a1
	sb	t0, 95(sp)
	lbu	t0, 95(sp)
	beq	x0, t0, .LBB9_336_jump_0
	j	.LBB9_20
.LBB9_336_jump_0:                               # %label_336_jump_0
	j	.LBB9_332
.LBB9_340:                               # %label_340
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	s11, t0, t1
	add	t0, s11, x0
	beq	x0, t0, .LBB9_340_jump_0
	j	.LBB9_20
.LBB9_340_jump_0:                               # %label_340_jump_0
	j	.LBB9_336
.LBB9_344:                               # %label_344
	lw	t0, 4(sp)
	slt	t0, t0, a1
	xori	s10, t0, 1
	add	t0, s10, x0
	beq	x0, t0, .LBB9_344_jump_0
	j	.LBB9_20
.LBB9_344_jump_0:                               # %label_344_jump_0
	j	.LBB9_340
.LBB9_348:                               # %label_348
	lw	t1, 0(sp)
	slt	t0, t1, a3
	xori	s9, t0, 1
	add	t0, s9, x0
	beq	x0, t0, .LBB9_348_jump_0
	j	.LBB9_20
.LBB9_348_jump_0:                               # %label_348_jump_0
	j	.LBB9_344
.LBB9_352:                               # %label_352
	lw	t1, 12(sp)
	sub	t0, a1, t1
	sltu	s8, x0, t0
	add	t0, s8, x0
	beq	x0, t0, .LBB9_352_jump_0
	j	.LBB9_20
.LBB9_352_jump_0:                               # %label_352_jump_0
	j	.LBB9_348
.LBB9_356:                               # %label_356
	lw	t0, 12(sp)
	slt	s7, a2, t0
	add	t0, s7, x0
	beq	x0, t0, .LBB9_356_jump_0
	j	.LBB9_20
.LBB9_356_jump_0:                               # %label_356_jump_0
	j	.LBB9_352
.LBB9_360:                               # %label_360
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	slt	s6, t0, t1
	add	t0, s6, x0
	beq	x0, t0, .LBB9_360_jump_0
	j	.LBB9_20
.LBB9_360_jump_0:                               # %label_360_jump_0
	j	.LBB9_356
.LBB9_364:                               # %label_364
	slt	t0, a3, a0
	xori	s5, t0, 1
	add	t0, s5, x0
	beq	x0, t0, .LBB9_364_jump_0
	j	.LBB9_20
.LBB9_364_jump_0:                               # %label_364_jump_0
	j	.LBB9_360
.LBB9_368:                               # %label_368
	slt	t0, a3, a1
	xori	s4, t0, 1
	add	t0, s4, x0
	beq	x0, t0, .LBB9_368_jump_0
	j	.LBB9_20
.LBB9_368_jump_0:                               # %label_368_jump_0
	j	.LBB9_364
.LBB9_372:                               # %label_372
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	sub	t0, t0, t1
	sltu	s3, x0, t0
	add	t0, s3, x0
	beq	x0, t0, .LBB9_372_jump_0
	j	.LBB9_20
.LBB9_372_jump_0:                               # %label_372_jump_0
	j	.LBB9_368
.LBB9_376:                               # %label_376
	lw	t0, 4(sp)
	slt	s2, a1, t0
	add	t0, s2, x0
	beq	x0, t0, .LBB9_376_jump_0
	j	.LBB9_20
.LBB9_376_jump_0:                               # %label_376_jump_0
	j	.LBB9_372
.LBB9_380:                               # %label_380
	lw	t1, 0(sp)
	slt	s1, a3, t1
	add	t0, s1, x0
	beq	x0, t0, .LBB9_380_jump_0
	j	.LBB9_20
.LBB9_380_jump_0:                               # %label_380_jump_0
	j	.LBB9_376
.LBB9_384:                               # %label_384
	lw	t1, 12(sp)
	slt	t0, a1, t1
	xori	s0, t0, 1
	add	t0, s0, x0
	beq	x0, t0, .LBB9_384_jump_0
	j	.LBB9_20
.LBB9_384_jump_0:                               # %label_384_jump_0
	j	.LBB9_380
.LBB9_388:                               # %label_388
	lw	t0, 12(sp)
	slt	t0, a2, t0
	xori	t5, t0, 1
	add	t0, t5, x0
	beq	x0, t0, .LBB9_388_jump_0
	j	.LBB9_20
.LBB9_388_jump_0:                               # %label_388_jump_0
	j	.LBB9_384
.LBB9_392:                               # %label_392
	lw	t0, 4(sp)
	lw	t1, 12(sp)
	sub	t0, t0, t1
	sltu	t4, x0, t0
	add	t0, t4, x0
	beq	x0, t0, .LBB9_392_jump_0
	j	.LBB9_20
.LBB9_392_jump_0:                               # %label_392_jump_0
	j	.LBB9_388
.LBB9_396:                               # %label_396
	slt	t3, a0, a3
	add	t0, t3, x0
	beq	x0, t0, .LBB9_396_jump_0
	j	.LBB9_20
.LBB9_396_jump_0:                               # %label_396_jump_0
	j	.LBB9_392
.LBB9_400:                               # %label_400
	slt	a7, a1, a3
	add	t0, a7, x0
	beq	x0, t0, .LBB9_400_jump_0
	j	.LBB9_20
.LBB9_400_jump_0:                               # %label_400_jump_0
	j	.LBB9_396
.LBB9_404:                               # %label_404
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	xori	a6, t0, 1
	add	t0, a6, x0
	beq	x0, t0, .LBB9_404_jump_0
	j	.LBB9_20
.LBB9_404_jump_0:                               # %label_404_jump_0
	j	.LBB9_400
.LBB9_408:                               # %label_408
	lw	t0, 4(sp)
	slt	t0, a1, t0
	xori	a4, t0, 1
	add	t0, a4, x0
	beq	x0, t0, .LBB9_408_jump_0
	j	.LBB9_20
.LBB9_408_jump_0:                               # %label_408_jump_0
	j	.LBB9_404
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.globl	fn.2                            # -- Begin function fn.2
	.p2align	1
	.type	fn.2,@function
fn.2:                                   # @fn.2
# %bb.0:                                # %alloca
	addi	sp, sp, -96
	j	.LBB10_0
.LBB10_0:                               # %label_0
	xor	a7, a0, a1
	or	a6, a1, a2
	and	a5, a2, a3
	xor	a4, a3, a0
	and	t3, a4, a7
	xor	t3, t3, a1
	or	t4, a2, t3
	xor	t3, a5, a3
	or	t4, t4, t3
	and	t3, a0, a6
	xor	t3, t3, a2
	or	t4, t4, t3
	xor	t3, a4, a7
	or	t4, t4, t3
	and	t3, a1, a5
	xor	t3, t3, a3
	or	t4, t4, t3
	xor	t3, a0, a6
	or	t4, t4, t3
	and	t3, a2, a4
	xor	t3, t3, a7
	or	t4, t4, t3
	xor	t3, a1, a5
	or	t4, t4, t3
	and	t3, a3, a0
	xor	t3, t3, a6
	or	t4, t4, t3
	xor	t3, a2, a4
	or	t4, t4, t3
	and	t3, a7, a1
	xor	t3, t3, a5
	or	t4, t4, t3
	xor	t3, a3, a0
	or	t4, t4, t3
	and	t3, a6, a2
	xor	t3, t3, a4
	or	t4, t4, t3
	xor	t3, a7, a1
	or	t4, t4, t3
	and	t3, a5, a3
	xor	t3, t3, a0
	or	t4, t4, t3
	xor	t3, a6, a2
	or	t4, t4, t3
	and	t3, a4, a7
	xor	t3, t3, a1
	or	t4, t4, t3
	xor	t3, a5, a3
	or	t4, t4, t3
	and	t3, a0, a6
	xor	t3, t3, a2
	or	t4, t4, t3
	xor	t3, a4, a7
	or	t4, t4, t3
	and	t3, a1, a5
	xor	t3, t3, a3
	or	t4, t4, t3
	xor	t3, a0, a6
	or	t4, t4, t3
	and	t3, a2, a4
	xor	t3, t3, a7
	or	t4, t4, t3
	xor	t3, a1, a5
	or	t4, t4, t3
	and	t3, a3, a0
	xor	t3, t3, a6
	or	t4, t4, t3
	xor	t3, a2, a4
	or	t4, t4, t3
	and	t3, a7, a1
	xor	t3, t3, a5
	or	t4, t4, t3
	xor	t3, a3, a0
	or	t4, t4, t3
	and	t3, a6, a2
	xor	t3, t3, a4
	or	t4, t4, t3
	xor	t3, a7, a1
	or	t4, t4, t3
	and	t3, a5, a3
	xor	t3, t3, a0
	or	t4, t4, t3
	xor	t3, a6, a2
	or	t4, t4, t3
	and	t3, a4, a7
	xor	t3, t3, a1
	or	t4, t4, t3
	xor	t3, a5, a3
	or	t4, t4, t3
	and	t3, a0, a6
	xor	t3, t3, a2
	or	t4, t4, t3
	xor	t3, a4, a7
	or	t4, t4, t3
	and	t3, a1, a5
	xor	t3, t3, a3
	or	t4, t4, t3
	xor	t3, a0, a6
	or	t4, t4, t3
	and	t3, a2, a4
	xor	t3, t3, a7
	or	t4, t4, t3
	xor	t3, a1, a5
	or	t4, t4, t3
	and	t3, a3, a0
	xor	t3, t3, a6
	or	t4, t4, t3
	xor	t3, a2, a4
	or	t4, t4, t3
	and	t3, a7, a1
	xor	t3, t3, a5
	or	t4, t4, t3
	xor	t3, a3, a0
	or	t4, t4, t3
	and	t3, a6, a2
	xor	t3, t3, a4
	or	t4, t4, t3
	xor	t3, a7, a1
	or	t4, t4, t3
	and	t3, a5, a3
	xor	t3, t3, a0
	or	t4, t4, t3
	xor	t3, a6, a2
	or	t4, t4, t3
	and	t3, a4, a7
	xor	t3, t3, a1
	or	t4, t4, t3
	xor	t3, a5, a3
	or	t4, t4, t3
	and	t3, a0, a6
	xor	t3, t3, a2
	or	t4, t4, t3
	xor	t3, a4, a7
	or	t4, t4, t3
	and	t3, a1, a5
	xor	t3, t3, a3
	or	t4, t4, t3
	xor	t3, a0, a6
	or	t4, t4, t3
	and	t3, a2, a4
	xor	a7, t3, a7
	or	a7, t4, a7
	xor	a5, a1, a5
	or	a7, a7, a5
	and	a5, a3, a0
	xor	a5, a5, a6
	or	a5, a7, a5
	xor	a4, a2, a4
	or	t0, a5, a4
	sw	t0, 0(sp)
	lw	a0, 0(sp)
	addi	sp, sp, 96
	ret
.Lfunc_end10:
	.size	fn.2, .Lfunc_end10-fn.2
                                        # -- End function
	.globl	fn.3                            # -- Begin function fn.3
	.p2align	1
	.type	fn.3,@function
fn.3:                                   # @fn.3
# %bb.0:                                # %alloca
	addi	sp, sp, -96
	j	.LBB11_0
.LBB11_0:                               # %label_0
	addiw	a7, a0, 17
	addiw	a6, a1, -23
	addiw	a5, a2, 31
	addiw	a4, a3, -43
	subw	t3, a0, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	t3, t3, a7
	subw	t3, t3, a6
	addw	t3, t3, a5
	addw	t3, t3, a4
	addw	t3, t3, a0
	addw	t3, t3, a4
	addw	t3, t3, a0
	subw	t3, t3, a1
	addw	t3, t3, a2
	addw	t3, t3, a3
	addw	a7, t3, a7
	subw	a6, a7, a6
	addw	a5, a6, a5
	addw	a4, a5, a4
	addw	t0, a4, a0
	sw	t0, 0(sp)
	lw	a0, 0(sp)
	addi	sp, sp, 96
	ret
.Lfunc_end11:
	.size	fn.3, .Lfunc_end11-fn.3
                                        # -- End function
	.globl	fn.4                            # -- Begin function fn.4
	.p2align	1
	.type	fn.4,@function
fn.4:                                   # @fn.4
# %bb.0:                                # %alloca
	addi	sp, sp, -96
	j	.LBB12_0
.LBB12_0:                               # %label_0
	addw	a7, a0, a1
	addw	a6, a1, a2
	addw	a5, a2, a3
	addw	a4, a3, a0
	li	t1, 1
	mulw	t4, a1, t1
	li	t1, 2
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a7, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a3, t1
	subw	t4, t4, t3
	li	t1, 2
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a4, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a2, t1
	subw	t4, t4, t3
	li	t1, 7
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 8
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 9
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 1
	mulw	t3, a5, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a1, t1
	subw	t4, t4, t3
	li	t1, 3
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 4
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 5
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 6
	mulw	t3, a6, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a0, t1
	subw	t4, t4, t3
	li	t1, 8
	mulw	t3, a3, t1
	addw	t4, t4, t3
	li	t1, 9
	mulw	t3, a5, t1
	subw	t4, t4, t3
	li	t1, 1
	mulw	t3, a1, t1
	addw	t4, t4, t3
	li	t1, 2
	mulw	t3, a7, t1
	addw	t4, t4, t3
	li	t1, 3
	mulw	t3, a4, t1
	subw	t4, t4, t3
	li	t1, 4
	mulw	t3, a2, t1
	addw	t4, t4, t3
	li	t1, 5
	mulw	t3, a6, t1
	subw	t4, t4, t3
	li	t1, 6
	mulw	t3, a0, t1
	addw	t4, t4, t3
	li	t1, 7
	mulw	t3, a3, t1
	addw	t3, t4, t3
	li	t1, 8
	mulw	a5, a5, t1
	subw	t3, t3, a5
	li	t1, 9
	mulw	a5, a1, t1
	addw	t3, t3, a5
	li	t1, 1
	mulw	a5, a7, t1
	subw	a5, t3, a5
	li	t1, 2
	mulw	a4, a4, t1
	addw	a5, a5, a4
	li	t1, 3
	mulw	a4, a2, t1
	addw	a5, a5, a4
	li	t1, 4
	mulw	a4, a6, t1
	subw	a5, a5, a4
	li	t1, 5
	mulw	a4, a0, t1
	addw	a5, a5, a4
	li	t1, 6
	mulw	a4, a3, t1
	subw	t0, a5, a4
	sw	t0, 0(sp)
	lw	a0, 0(sp)
	addi	sp, sp, 96
	ret
.Lfunc_end12:
	.size	fn.4, .Lfunc_end12-fn.4
                                        # -- End function
	.globl	fn.5                            # -- Begin function fn.5
	.p2align	1
	.type	fn.5,@function
fn.5:                                   # @fn.5
# %bb.0:                                # %alloca
	addi	sp, sp, -288
	sd	s0, 184(sp)
	sd	s1, 192(sp)
	sd	s2, 200(sp)
	sd	s3, 208(sp)
	sd	s4, 216(sp)
	sd	s5, 224(sp)
	sd	s6, 232(sp)
	sd	s7, 240(sp)
	sd	s8, 248(sp)
	sd	s9, 256(sp)
	sd	s10, 264(sp)
	sd	s11, 272(sp)
	j	.LBB13_0
.LBB13_0:                               # %label_0
	addiw	t0, a0, 1
	sw	t0, 0(sp)
	addiw	t0, a1, 2
	sw	t0, 4(sp)
	addiw	t0, a2, 3
	sw	t0, 8(sp)
	addiw	t0, a3, 4
	sw	t0, 12(sp)
	slt	a5, a0, a1
	add	t0, a5, x0
	beq	x0, t0, .LBB13_0_jump_0
	j	.LBB13_348
.LBB13_0_jump_0:                               # %label_0_jump_0
	j	.LBB13_21
.LBB13_20:                               # %label_20
	li	t0, 1
	sb	t0, 81(sp)
	j	.LBB13_22
.LBB13_21:                               # %label_21
	li	t0, 0
	sb	t0, 81(sp)
.LBB13_22:                               # %label_22
	lbu	a0, 81(sp)
	ld	s0, 184(sp)
	ld	s1, 192(sp)
	ld	s2, 200(sp)
	ld	s3, 208(sp)
	ld	s4, 216(sp)
	ld	s5, 224(sp)
	ld	s6, 232(sp)
	ld	s7, 240(sp)
	ld	s8, 248(sp)
	ld	s9, 256(sp)
	ld	s10, 264(sp)
	ld	s11, 272(sp)
	addi	sp, sp, 288
	ret
.LBB13_23:                               # %label_23
	slt	t0, a2, a3
	xori	t0, t0, 1
	sb	t0, 16(sp)
	lbu	t0, 16(sp)
	beq	x0, t0, .LBB13_23_jump_0
	j	.LBB13_20
.LBB13_23_jump_0:                               # %label_23_jump_0
	j	.LBB13_21
.LBB13_24:                               # %label_24
	lw	t1, 12(sp)
	sub	t0, a2, t1
	sltu	t0, x0, t0
	sb	t0, 17(sp)
	lbu	t0, 17(sp)
	beq	x0, t0, .LBB13_24_jump_0
	j	.LBB13_23
.LBB13_24_jump_0:                               # %label_24_jump_0
	j	.LBB13_21
.LBB13_28:                               # %label_28
	lw	t1, 0(sp)
	slt	t0, t1, a1
	sb	t0, 18(sp)
	lbu	t0, 18(sp)
	beq	x0, t0, .LBB13_28_jump_0
	j	.LBB13_24
.LBB13_28_jump_0:                               # %label_28_jump_0
	j	.LBB13_21
.LBB13_32:                               # %label_32
	slt	t0, a0, a1
	sb	t0, 19(sp)
	lbu	t0, 19(sp)
	beq	x0, t0, .LBB13_32_jump_0
	j	.LBB13_28
.LBB13_32_jump_0:                               # %label_32_jump_0
	j	.LBB13_21
.LBB13_36:                               # %label_36
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 20(sp)
	lbu	t0, 20(sp)
	beq	x0, t0, .LBB13_36_jump_0
	j	.LBB13_32
.LBB13_36_jump_0:                               # %label_36_jump_0
	j	.LBB13_21
.LBB13_40:                               # %label_40
	lw	t0, 8(sp)
	slt	t0, a3, t0
	xori	t0, t0, 1
	sb	t0, 21(sp)
	lbu	t0, 21(sp)
	beq	x0, t0, .LBB13_40_jump_0
	j	.LBB13_36
.LBB13_40_jump_0:                               # %label_40_jump_0
	j	.LBB13_21
.LBB13_44:                               # %label_44
	lw	t0, 4(sp)
	sub	t0, t0, a0
	sltu	t0, x0, t0
	sb	t0, 22(sp)
	lbu	t0, 22(sp)
	beq	x0, t0, .LBB13_44_jump_0
	j	.LBB13_40
.LBB13_44_jump_0:                               # %label_44_jump_0
	j	.LBB13_21
.LBB13_48:                               # %label_48
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t1, t0
	sb	t0, 23(sp)
	lbu	t0, 23(sp)
	beq	x0, t0, .LBB13_48_jump_0
	j	.LBB13_44
.LBB13_48_jump_0:                               # %label_48_jump_0
	j	.LBB13_21
.LBB13_52:                               # %label_52
	slt	t0, a3, a2
	sb	t0, 24(sp)
	lbu	t0, 24(sp)
	beq	x0, t0, .LBB13_52_jump_0
	j	.LBB13_48
.LBB13_52_jump_0:                               # %label_52_jump_0
	j	.LBB13_21
.LBB13_56:                               # %label_56
	lw	t1, 12(sp)
	slt	t0, a2, t1
	xori	t0, t0, 1
	sb	t0, 25(sp)
	lbu	t0, 25(sp)
	beq	x0, t0, .LBB13_56_jump_0
	j	.LBB13_52
.LBB13_56_jump_0:                               # %label_56_jump_0
	j	.LBB13_21
.LBB13_60:                               # %label_60
	lw	t1, 0(sp)
	slt	t0, t1, a1
	xori	t0, t0, 1
	sb	t0, 26(sp)
	lbu	t0, 26(sp)
	beq	x0, t0, .LBB13_60_jump_0
	j	.LBB13_56
.LBB13_60_jump_0:                               # %label_60_jump_0
	j	.LBB13_21
.LBB13_64:                               # %label_64
	sub	t0, a0, a1
	sltu	t0, x0, t0
	sb	t0, 27(sp)
	lbu	t0, 27(sp)
	beq	x0, t0, .LBB13_64_jump_0
	j	.LBB13_60
.LBB13_64_jump_0:                               # %label_64_jump_0
	j	.LBB13_21
.LBB13_68:                               # %label_68
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	sb	t0, 28(sp)
	lbu	t0, 28(sp)
	beq	x0, t0, .LBB13_68_jump_0
	j	.LBB13_64
.LBB13_68_jump_0:                               # %label_68_jump_0
	j	.LBB13_21
.LBB13_72:                               # %label_72
	lw	t0, 8(sp)
	slt	t0, t0, a3
	sb	t0, 29(sp)
	lbu	t0, 29(sp)
	beq	x0, t0, .LBB13_72_jump_0
	j	.LBB13_68
.LBB13_72_jump_0:                               # %label_72_jump_0
	j	.LBB13_21
.LBB13_76:                               # %label_76
	lw	t0, 4(sp)
	slt	t0, t0, a0
	xori	t0, t0, 1
	sb	t0, 30(sp)
	lbu	t0, 30(sp)
	beq	x0, t0, .LBB13_76_jump_0
	j	.LBB13_72
.LBB13_76_jump_0:                               # %label_76_jump_0
	j	.LBB13_21
.LBB13_80:                               # %label_80
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 31(sp)
	lbu	t0, 31(sp)
	beq	x0, t0, .LBB13_80_jump_0
	j	.LBB13_76
.LBB13_80_jump_0:                               # %label_80_jump_0
	j	.LBB13_21
.LBB13_84:                               # %label_84
	sub	t0, a3, a2
	sltu	t0, x0, t0
	sb	t0, 32(sp)
	lbu	t0, 32(sp)
	beq	x0, t0, .LBB13_84_jump_0
	j	.LBB13_80
.LBB13_84_jump_0:                               # %label_84_jump_0
	j	.LBB13_21
.LBB13_88:                               # %label_88
	lw	t1, 12(sp)
	slt	t0, t1, a2
	sb	t0, 33(sp)
	lbu	t0, 33(sp)
	beq	x0, t0, .LBB13_88_jump_0
	j	.LBB13_84
.LBB13_88_jump_0:                               # %label_88_jump_0
	j	.LBB13_21
.LBB13_92:                               # %label_92
	lw	t1, 0(sp)
	slt	t0, a1, t1
	sb	t0, 34(sp)
	lbu	t0, 34(sp)
	beq	x0, t0, .LBB13_92_jump_0
	j	.LBB13_88
.LBB13_92_jump_0:                               # %label_92_jump_0
	j	.LBB13_21
.LBB13_96:                               # %label_96
	slt	t0, a0, a1
	xori	t0, t0, 1
	sb	t0, 35(sp)
	lbu	t0, 35(sp)
	beq	x0, t0, .LBB13_96_jump_0
	j	.LBB13_92
.LBB13_96_jump_0:                               # %label_96_jump_0
	j	.LBB13_21
.LBB13_100:                               # %label_100
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 36(sp)
	lbu	t0, 36(sp)
	beq	x0, t0, .LBB13_100_jump_0
	j	.LBB13_96
.LBB13_100_jump_0:                               # %label_100_jump_0
	j	.LBB13_21
.LBB13_104:                               # %label_104
	lw	t0, 8(sp)
	sub	t0, t0, a3
	sltu	t0, x0, t0
	sb	t0, 37(sp)
	lbu	t0, 37(sp)
	beq	x0, t0, .LBB13_104_jump_0
	j	.LBB13_100
.LBB13_104_jump_0:                               # %label_104_jump_0
	j	.LBB13_21
.LBB13_108:                               # %label_108
	lw	t0, 4(sp)
	slt	t0, a0, t0
	sb	t0, 38(sp)
	lbu	t0, 38(sp)
	beq	x0, t0, .LBB13_108_jump_0
	j	.LBB13_104
.LBB13_108_jump_0:                               # %label_108_jump_0
	j	.LBB13_21
.LBB13_112:                               # %label_112
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t0, t1
	sb	t0, 39(sp)
	lbu	t0, 39(sp)
	beq	x0, t0, .LBB13_112_jump_0
	j	.LBB13_108
.LBB13_112_jump_0:                               # %label_112_jump_0
	j	.LBB13_21
.LBB13_116:                               # %label_116
	slt	t0, a3, a2
	xori	t0, t0, 1
	sb	t0, 40(sp)
	lbu	t0, 40(sp)
	beq	x0, t0, .LBB13_116_jump_0
	j	.LBB13_112
.LBB13_116_jump_0:                               # %label_116_jump_0
	j	.LBB13_21
.LBB13_120:                               # %label_120
	lw	t1, 12(sp)
	slt	t0, t1, a2
	xori	t0, t0, 1
	sb	t0, 41(sp)
	lbu	t0, 41(sp)
	beq	x0, t0, .LBB13_120_jump_0
	j	.LBB13_116
.LBB13_120_jump_0:                               # %label_120_jump_0
	j	.LBB13_21
.LBB13_124:                               # %label_124
	lw	t1, 0(sp)
	sub	t0, a1, t1
	sltu	t0, x0, t0
	sb	t0, 42(sp)
	lbu	t0, 42(sp)
	beq	x0, t0, .LBB13_124_jump_0
	j	.LBB13_120
.LBB13_124_jump_0:                               # %label_124_jump_0
	j	.LBB13_21
.LBB13_128:                               # %label_128
	slt	t0, a1, a0
	sb	t0, 43(sp)
	lbu	t0, 43(sp)
	beq	x0, t0, .LBB13_128_jump_0
	j	.LBB13_124
.LBB13_128_jump_0:                               # %label_128_jump_0
	j	.LBB13_21
.LBB13_132:                               # %label_132
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	sb	t0, 44(sp)
	lbu	t0, 44(sp)
	beq	x0, t0, .LBB13_132_jump_0
	j	.LBB13_128
.LBB13_132_jump_0:                               # %label_132_jump_0
	j	.LBB13_21
.LBB13_136:                               # %label_136
	lw	t0, 8(sp)
	slt	t0, t0, a3
	xori	t0, t0, 1
	sb	t0, 45(sp)
	lbu	t0, 45(sp)
	beq	x0, t0, .LBB13_136_jump_0
	j	.LBB13_132
.LBB13_136_jump_0:                               # %label_136_jump_0
	j	.LBB13_21
.LBB13_140:                               # %label_140
	lw	t0, 4(sp)
	slt	t0, a0, t0
	xori	t0, t0, 1
	sb	t0, 46(sp)
	lbu	t0, 46(sp)
	beq	x0, t0, .LBB13_140_jump_0
	j	.LBB13_136
.LBB13_140_jump_0:                               # %label_140_jump_0
	j	.LBB13_21
.LBB13_144:                               # %label_144
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 47(sp)
	lbu	t0, 47(sp)
	beq	x0, t0, .LBB13_144_jump_0
	j	.LBB13_140
.LBB13_144_jump_0:                               # %label_144_jump_0
	j	.LBB13_21
.LBB13_148:                               # %label_148
	slt	t0, a2, a3
	sb	t0, 48(sp)
	lbu	t0, 48(sp)
	beq	x0, t0, .LBB13_148_jump_0
	j	.LBB13_144
.LBB13_148_jump_0:                               # %label_148_jump_0
	j	.LBB13_21
.LBB13_152:                               # %label_152
	lw	t1, 12(sp)
	slt	t0, a2, t1
	sb	t0, 49(sp)
	lbu	t0, 49(sp)
	beq	x0, t0, .LBB13_152_jump_0
	j	.LBB13_148
.LBB13_152_jump_0:                               # %label_152_jump_0
	j	.LBB13_21
.LBB13_156:                               # %label_156
	lw	t1, 0(sp)
	slt	t0, a1, t1
	xori	t0, t0, 1
	sb	t0, 50(sp)
	lbu	t0, 50(sp)
	beq	x0, t0, .LBB13_156_jump_0
	j	.LBB13_152
.LBB13_156_jump_0:                               # %label_156_jump_0
	j	.LBB13_21
.LBB13_160:                               # %label_160
	slt	t0, a1, a0
	xori	t0, t0, 1
	sb	t0, 51(sp)
	lbu	t0, 51(sp)
	beq	x0, t0, .LBB13_160_jump_0
	j	.LBB13_156
.LBB13_160_jump_0:                               # %label_160_jump_0
	j	.LBB13_21
.LBB13_164:                               # %label_164
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	sub	t0, t0, t1
	sltu	t0, x0, t0
	sb	t0, 52(sp)
	lbu	t0, 52(sp)
	beq	x0, t0, .LBB13_164_jump_0
	j	.LBB13_160
.LBB13_164_jump_0:                               # %label_164_jump_0
	j	.LBB13_21
.LBB13_168:                               # %label_168
	lw	t0, 8(sp)
	slt	t0, a3, t0
	sb	t0, 53(sp)
	lbu	t0, 53(sp)
	beq	x0, t0, .LBB13_168_jump_0
	j	.LBB13_164
.LBB13_168_jump_0:                               # %label_168_jump_0
	j	.LBB13_21
.LBB13_172:                               # %label_172
	lw	t0, 4(sp)
	slt	t0, t0, a0
	sb	t0, 54(sp)
	lbu	t0, 54(sp)
	beq	x0, t0, .LBB13_172_jump_0
	j	.LBB13_168
.LBB13_172_jump_0:                               # %label_172_jump_0
	j	.LBB13_21
.LBB13_176:                               # %label_176
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 55(sp)
	lbu	t0, 55(sp)
	beq	x0, t0, .LBB13_176_jump_0
	j	.LBB13_172
.LBB13_176_jump_0:                               # %label_176_jump_0
	j	.LBB13_21
.LBB13_180:                               # %label_180
	slt	t0, a2, a3
	xori	t0, t0, 1
	sb	t0, 56(sp)
	lbu	t0, 56(sp)
	beq	x0, t0, .LBB13_180_jump_0
	j	.LBB13_176
.LBB13_180_jump_0:                               # %label_180_jump_0
	j	.LBB13_21
.LBB13_184:                               # %label_184
	lw	t1, 12(sp)
	sub	t0, a2, t1
	sltu	t0, x0, t0
	sb	t0, 57(sp)
	lbu	t0, 57(sp)
	beq	x0, t0, .LBB13_184_jump_0
	j	.LBB13_180
.LBB13_184_jump_0:                               # %label_184_jump_0
	j	.LBB13_21
.LBB13_188:                               # %label_188
	lw	t1, 0(sp)
	slt	t0, t1, a1
	sb	t0, 58(sp)
	lbu	t0, 58(sp)
	beq	x0, t0, .LBB13_188_jump_0
	j	.LBB13_184
.LBB13_188_jump_0:                               # %label_188_jump_0
	j	.LBB13_21
.LBB13_192:                               # %label_192
	slt	t0, a0, a1
	sb	t0, 59(sp)
	lbu	t0, 59(sp)
	beq	x0, t0, .LBB13_192_jump_0
	j	.LBB13_188
.LBB13_192_jump_0:                               # %label_192_jump_0
	j	.LBB13_21
.LBB13_196:                               # %label_196
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t0, t1
	xori	t0, t0, 1
	sb	t0, 60(sp)
	lbu	t0, 60(sp)
	beq	x0, t0, .LBB13_196_jump_0
	j	.LBB13_192
.LBB13_196_jump_0:                               # %label_196_jump_0
	j	.LBB13_21
.LBB13_200:                               # %label_200
	lw	t0, 8(sp)
	slt	t0, a3, t0
	xori	t0, t0, 1
	sb	t0, 61(sp)
	lbu	t0, 61(sp)
	beq	x0, t0, .LBB13_200_jump_0
	j	.LBB13_196
.LBB13_200_jump_0:                               # %label_200_jump_0
	j	.LBB13_21
.LBB13_204:                               # %label_204
	lw	t0, 4(sp)
	sub	t0, t0, a0
	sltu	t0, x0, t0
	sb	t0, 62(sp)
	lbu	t0, 62(sp)
	beq	x0, t0, .LBB13_204_jump_0
	j	.LBB13_200
.LBB13_204_jump_0:                               # %label_204_jump_0
	j	.LBB13_21
.LBB13_208:                               # %label_208
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t1, t0
	sb	t0, 63(sp)
	lbu	t0, 63(sp)
	beq	x0, t0, .LBB13_208_jump_0
	j	.LBB13_204
.LBB13_208_jump_0:                               # %label_208_jump_0
	j	.LBB13_21
.LBB13_212:                               # %label_212
	slt	t0, a3, a2
	sb	t0, 64(sp)
	lbu	t0, 64(sp)
	beq	x0, t0, .LBB13_212_jump_0
	j	.LBB13_208
.LBB13_212_jump_0:                               # %label_212_jump_0
	j	.LBB13_21
.LBB13_216:                               # %label_216
	lw	t1, 12(sp)
	slt	t0, a2, t1
	xori	t0, t0, 1
	sb	t0, 65(sp)
	lbu	t0, 65(sp)
	beq	x0, t0, .LBB13_216_jump_0
	j	.LBB13_212
.LBB13_216_jump_0:                               # %label_216_jump_0
	j	.LBB13_21
.LBB13_220:                               # %label_220
	lw	t1, 0(sp)
	slt	t0, t1, a1
	xori	t0, t0, 1
	sb	t0, 66(sp)
	lbu	t0, 66(sp)
	beq	x0, t0, .LBB13_220_jump_0
	j	.LBB13_216
.LBB13_220_jump_0:                               # %label_220_jump_0
	j	.LBB13_21
.LBB13_224:                               # %label_224
	sub	t0, a0, a1
	sltu	t0, x0, t0
	sb	t0, 67(sp)
	lbu	t0, 67(sp)
	beq	x0, t0, .LBB13_224_jump_0
	j	.LBB13_220
.LBB13_224_jump_0:                               # %label_224_jump_0
	j	.LBB13_21
.LBB13_228:                               # %label_228
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	sb	t0, 68(sp)
	lbu	t0, 68(sp)
	beq	x0, t0, .LBB13_228_jump_0
	j	.LBB13_224
.LBB13_228_jump_0:                               # %label_228_jump_0
	j	.LBB13_21
.LBB13_232:                               # %label_232
	lw	t0, 8(sp)
	slt	t0, t0, a3
	sb	t0, 69(sp)
	lbu	t0, 69(sp)
	beq	x0, t0, .LBB13_232_jump_0
	j	.LBB13_228
.LBB13_232_jump_0:                               # %label_232_jump_0
	j	.LBB13_21
.LBB13_236:                               # %label_236
	lw	t0, 4(sp)
	slt	t0, t0, a0
	xori	t0, t0, 1
	sb	t0, 70(sp)
	lbu	t0, 70(sp)
	beq	x0, t0, .LBB13_236_jump_0
	j	.LBB13_232
.LBB13_236_jump_0:                               # %label_236_jump_0
	j	.LBB13_21
.LBB13_240:                               # %label_240
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 71(sp)
	lbu	t0, 71(sp)
	beq	x0, t0, .LBB13_240_jump_0
	j	.LBB13_236
.LBB13_240_jump_0:                               # %label_240_jump_0
	j	.LBB13_21
.LBB13_244:                               # %label_244
	sub	t0, a3, a2
	sltu	t0, x0, t0
	sb	t0, 72(sp)
	lbu	t0, 72(sp)
	beq	x0, t0, .LBB13_244_jump_0
	j	.LBB13_240
.LBB13_244_jump_0:                               # %label_244_jump_0
	j	.LBB13_21
.LBB13_248:                               # %label_248
	lw	t1, 12(sp)
	slt	t0, t1, a2
	sb	t0, 73(sp)
	lbu	t0, 73(sp)
	beq	x0, t0, .LBB13_248_jump_0
	j	.LBB13_244
.LBB13_248_jump_0:                               # %label_248_jump_0
	j	.LBB13_21
.LBB13_252:                               # %label_252
	lw	t1, 0(sp)
	slt	t0, a1, t1
	sb	t0, 74(sp)
	lbu	t0, 74(sp)
	beq	x0, t0, .LBB13_252_jump_0
	j	.LBB13_248
.LBB13_252_jump_0:                               # %label_252_jump_0
	j	.LBB13_21
.LBB13_256:                               # %label_256
	slt	t0, a0, a1
	xori	t0, t0, 1
	sb	t0, 75(sp)
	lbu	t0, 75(sp)
	beq	x0, t0, .LBB13_256_jump_0
	j	.LBB13_252
.LBB13_256_jump_0:                               # %label_256_jump_0
	j	.LBB13_21
.LBB13_260:                               # %label_260
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 76(sp)
	lbu	t0, 76(sp)
	beq	x0, t0, .LBB13_260_jump_0
	j	.LBB13_256
.LBB13_260_jump_0:                               # %label_260_jump_0
	j	.LBB13_21
.LBB13_264:                               # %label_264
	lw	t0, 8(sp)
	sub	t0, t0, a3
	sltu	t0, x0, t0
	sb	t0, 77(sp)
	lbu	t0, 77(sp)
	beq	x0, t0, .LBB13_264_jump_0
	j	.LBB13_260
.LBB13_264_jump_0:                               # %label_264_jump_0
	j	.LBB13_21
.LBB13_268:                               # %label_268
	lw	t0, 4(sp)
	slt	t0, a0, t0
	sb	t0, 78(sp)
	lbu	t0, 78(sp)
	beq	x0, t0, .LBB13_268_jump_0
	j	.LBB13_264
.LBB13_268_jump_0:                               # %label_268_jump_0
	j	.LBB13_21
.LBB13_272:                               # %label_272
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t0, t1
	sb	t0, 79(sp)
	lbu	t0, 79(sp)
	beq	x0, t0, .LBB13_272_jump_0
	j	.LBB13_268
.LBB13_272_jump_0:                               # %label_272_jump_0
	j	.LBB13_21
.LBB13_276:                               # %label_276
	slt	t0, a3, a2
	xori	t0, t0, 1
	sb	t0, 80(sp)
	lbu	t0, 80(sp)
	beq	x0, t0, .LBB13_276_jump_0
	j	.LBB13_272
.LBB13_276_jump_0:                               # %label_276_jump_0
	j	.LBB13_21
.LBB13_280:                               # %label_280
	lw	t1, 12(sp)
	slt	t0, t1, a2
	xori	s11, t0, 1
	add	t0, s11, x0
	beq	x0, t0, .LBB13_280_jump_0
	j	.LBB13_276
.LBB13_280_jump_0:                               # %label_280_jump_0
	j	.LBB13_21
.LBB13_284:                               # %label_284
	lw	t1, 0(sp)
	sub	t0, a1, t1
	sltu	s10, x0, t0
	add	t0, s10, x0
	beq	x0, t0, .LBB13_284_jump_0
	j	.LBB13_280
.LBB13_284_jump_0:                               # %label_284_jump_0
	j	.LBB13_21
.LBB13_288:                               # %label_288
	slt	s9, a1, a0
	add	t0, s9, x0
	beq	x0, t0, .LBB13_288_jump_0
	j	.LBB13_284
.LBB13_288_jump_0:                               # %label_288_jump_0
	j	.LBB13_21
.LBB13_292:                               # %label_292
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	slt	s8, t0, t1
	add	t0, s8, x0
	beq	x0, t0, .LBB13_292_jump_0
	j	.LBB13_288
.LBB13_292_jump_0:                               # %label_292_jump_0
	j	.LBB13_21
.LBB13_296:                               # %label_296
	lw	t0, 8(sp)
	slt	t0, t0, a3
	xori	s7, t0, 1
	add	t0, s7, x0
	beq	x0, t0, .LBB13_296_jump_0
	j	.LBB13_292
.LBB13_296_jump_0:                               # %label_296_jump_0
	j	.LBB13_21
.LBB13_300:                               # %label_300
	lw	t0, 4(sp)
	slt	t0, a0, t0
	xori	s6, t0, 1
	add	t0, s6, x0
	beq	x0, t0, .LBB13_300_jump_0
	j	.LBB13_296
.LBB13_300_jump_0:                               # %label_300_jump_0
	j	.LBB13_21
.LBB13_304:                               # %label_304
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	sub	t0, t0, t1
	sltu	s5, x0, t0
	add	t0, s5, x0
	beq	x0, t0, .LBB13_304_jump_0
	j	.LBB13_300
.LBB13_304_jump_0:                               # %label_304_jump_0
	j	.LBB13_21
.LBB13_308:                               # %label_308
	slt	s4, a2, a3
	add	t0, s4, x0
	beq	x0, t0, .LBB13_308_jump_0
	j	.LBB13_304
.LBB13_308_jump_0:                               # %label_308_jump_0
	j	.LBB13_21
.LBB13_312:                               # %label_312
	lw	t1, 12(sp)
	slt	s3, a2, t1
	add	t0, s3, x0
	beq	x0, t0, .LBB13_312_jump_0
	j	.LBB13_308
.LBB13_312_jump_0:                               # %label_312_jump_0
	j	.LBB13_21
.LBB13_316:                               # %label_316
	lw	t1, 0(sp)
	slt	t0, a1, t1
	xori	s2, t0, 1
	add	t0, s2, x0
	beq	x0, t0, .LBB13_316_jump_0
	j	.LBB13_312
.LBB13_316_jump_0:                               # %label_316_jump_0
	j	.LBB13_21
.LBB13_320:                               # %label_320
	slt	t0, a1, a0
	xori	s1, t0, 1
	add	t0, s1, x0
	beq	x0, t0, .LBB13_320_jump_0
	j	.LBB13_316
.LBB13_320_jump_0:                               # %label_320_jump_0
	j	.LBB13_21
.LBB13_324:                               # %label_324
	lw	t0, 12(sp)
	lw	t1, 8(sp)
	sub	t0, t0, t1
	sltu	s0, x0, t0
	add	t0, s0, x0
	beq	x0, t0, .LBB13_324_jump_0
	j	.LBB13_320
.LBB13_324_jump_0:                               # %label_324_jump_0
	j	.LBB13_21
.LBB13_328:                               # %label_328
	lw	t0, 8(sp)
	slt	t5, a3, t0
	add	t0, t5, x0
	beq	x0, t0, .LBB13_328_jump_0
	j	.LBB13_324
.LBB13_328_jump_0:                               # %label_328_jump_0
	j	.LBB13_21
.LBB13_332:                               # %label_332
	lw	t0, 4(sp)
	slt	t4, t0, a0
	add	t0, t4, x0
	beq	x0, t0, .LBB13_332_jump_0
	j	.LBB13_328
.LBB13_332_jump_0:                               # %label_332_jump_0
	j	.LBB13_21
.LBB13_336:                               # %label_336
	lw	t0, 0(sp)
	lw	t1, 4(sp)
	slt	t0, t0, t1
	xori	t3, t0, 1
	add	t0, t3, x0
	beq	x0, t0, .LBB13_336_jump_0
	j	.LBB13_332
.LBB13_336_jump_0:                               # %label_336_jump_0
	j	.LBB13_21
.LBB13_340:                               # %label_340
	slt	t0, a2, a3
	xori	a7, t0, 1
	add	t0, a7, x0
	beq	x0, t0, .LBB13_340_jump_0
	j	.LBB13_336
.LBB13_340_jump_0:                               # %label_340_jump_0
	j	.LBB13_21
.LBB13_344:                               # %label_344
	lw	t1, 12(sp)
	sub	t0, a2, t1
	sltu	a6, x0, t0
	add	t0, a6, x0
	beq	x0, t0, .LBB13_344_jump_0
	j	.LBB13_340
.LBB13_344_jump_0:                               # %label_344_jump_0
	j	.LBB13_21
.LBB13_348:                               # %label_348
	lw	t1, 0(sp)
	slt	a4, t1, a1
	add	t0, a4, x0
	beq	x0, t0, .LBB13_348_jump_0
	j	.LBB13_344
.LBB13_348_jump_0:                               # %label_348_jump_0
	j	.LBB13_21
.Lfunc_end13:
	.size	fn.5, .Lfunc_end13-fn.5
                                        # -- End function

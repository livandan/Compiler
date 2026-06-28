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
	li	t6, -481984
	add	sp, sp, t6
	sd	s0, 1168(sp)
	sd	s1, 1176(sp)
	sd	s2, 1184(sp)
	sd	s3, 1192(sp)
	sd	s4, 1200(sp)
	sd	s5, 1208(sp)
	sd	s6, 1216(sp)
	sd	s7, 1224(sp)
	sd	s8, 1232(sp)
	sd	s9, 1240(sp)
	sd	s10, 1248(sp)
	sd	s11, 1256(sp)
	addi	t6, sp, 1264
	sd	t6, 312(sp)
	addi	t6, sp, 1280
	sd	t6, 152(sp)
	li	t6, 41304
	add	t6, sp, t6
	sd	t6, 128(sp)
	li	t6, 81304
	add	t6, sp, t6
	sd	t6, 168(sp)
	li	t6, 81324
	add	t6, sp, t6
	sd	t6, 208(sp)
	li	t6, 81344
	add	t6, sp, t6
	sd	t6, 216(sp)
	li	t6, 81364
	add	t6, sp, t6
	sd	t6, 144(sp)
	li	t6, 121388
	add	t6, sp, t6
	sd	t6, 224(sp)
	li	t6, 161388
	add	t6, sp, t6
	sd	t6, 264(sp)
	li	t6, 161408
	add	t6, sp, t6
	sd	t6, 176(sp)
	li	t6, 161428
	add	t6, sp, t6
	sd	t6, 184(sp)
	li	t6, 161448
	add	t6, sp, t6
	sd	t6, 160(sp)
	li	t6, 201472
	add	t6, sp, t6
	sd	t6, 232(sp)
	li	t6, 241472
	add	t6, sp, t6
	sd	t6, 288(sp)
	li	t6, 281480
	add	t6, sp, t6
	sd	t6, 296(sp)
	li	t6, 321488
	add	t6, sp, t6
	sd	t6, 200(sp)
	li	t6, 361496
	add	t6, sp, t6
	sd	t6, 248(sp)
	li	t6, 361896
	add	t6, sp, t6
	sd	t6, 136(sp)
	li	t6, 361916
	add	t6, sp, t6
	sd	t6, 280(sp)
	li	t6, 401916
	add	t6, sp, t6
	sd	t6, 304(sp)
	li	t6, 401936
	add	t6, sp, t6
	sd	t6, 256(sp)
	li	t6, 441936
	add	t6, sp, t6
	sd	t6, 240(sp)
	li	t6, 441956
	add	t6, sp, t6
	sd	t6, 192(sp)
	li	t6, 481956
	add	t6, sp, t6
	sd	t6, 272(sp)
.LBB8_0:                               # %label_0
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	li	a0, 21001
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t0, 312(sp)
	mv	s1, t0
	li	t1, 100
	sw	t1, 0(s1)
	ld	t0, 312(sp)
	addi	s1, t0, 4
	li	t1, 500
	sw	t1, 0(s1)
	ld	t0, 312(sp)
	addi	s1, t0, 8
	li	t1, 1000
	sw	t1, 0(s1)
	ld	t0, 312(sp)
	addi	s1, t0, 12
	li	t1, 2000
	sw	t1, 0(s1)
	li	a0, 0
	li	t0, 0
	sd	t0, 608(sp)
	li	t0, 0
	sd	t0, 616(sp)
	li	t0, 0
	sd	t0, 624(sp)
	li	t0, 0
	sd	t0, 632(sp)
	li	t0, 0
	sd	t0, 640(sp)
	li	t0, 0
	sd	t0, 648(sp)
	li	t0, 0
	sd	t0, 656(sp)
	li	t0, 0
	sd	t0, 664(sp)
	li	t0, 0
	sd	t0, 672(sp)
	li	t0, 0
	sd	t0, 680(sp)
	li	t0, 0
	sd	t0, 688(sp)
	li	t0, 0
	sd	t0, 696(sp)
	li	t0, 0
	sd	t0, 704(sp)
	li	t0, 0
	sd	t0, 712(sp)
	li	t0, 0
	sd	t0, 720(sp)
.LBB8_6:                               # %label_6
	mv	t0, a0
	li	t1, 4
	bge	t0, t1, .LBB8_8
.LBB8_7:                               # %label_7
	mv	t0, a0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 312(sp)
	add	t2, t1, t0
	sd	t2, 736(sp)
	ld	t0, 736(sp)
	lw	s1, 0(t0)
	li	t1, 100
	mulw	t0, a0, t1
	sw	t0, 952(sp)
	lw	t1, 952(sp)
	li	t6, 21000
	addw	t0, t1, t6
	sw	t0, 956(sp)
	lw	t0, 956(sp)
	addiw	t0, t0, 10
	sw	t0, 892(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	lw	a0, 892(sp)
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	li	s0, 0
	ld	t0, 608(sp)
	sd	t0, 416(sp)
	ld	t0, 616(sp)
	sd	t0, 424(sp)
	ld	t0, 624(sp)
	sd	t0, 432(sp)
	ld	t0, 632(sp)
	sd	t0, 440(sp)
	ld	t0, 640(sp)
	sd	t0, 448(sp)
	ld	t0, 648(sp)
	sd	t0, 456(sp)
	ld	t0, 656(sp)
	sd	t0, 464(sp)
	ld	t0, 664(sp)
	sd	t0, 472(sp)
	ld	t0, 672(sp)
	sd	t0, 480(sp)
	ld	t0, 680(sp)
	sd	t0, 488(sp)
	ld	t0, 688(sp)
	sd	t0, 496(sp)
	ld	t0, 696(sp)
	sd	t0, 504(sp)
	ld	t0, 704(sp)
	sd	t0, 512(sp)
	ld	t0, 712(sp)
	sd	t0, 520(sp)
	ld	t0, 720(sp)
	sd	t0, 528(sp)
.LBB8_20:                               # %label_20
	mv	t0, s0
	li	t1, 8
	bge	t0, t1, .LBB8_22
.LBB8_21:                               # %label_21
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	mv	a0, s0
	mv	a1, s1
	ld	a2, 152(sp)
	call	fn.14
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	t0, 128(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t0, 152(sp)
	addi	t0, t0, 24
	sd	t0, 360(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 360(sp)
	ld	a1, 128(sp)
	mv	a2, s1
	call	fn.2
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 168(sp)
	call	fn.12
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	ld	a2, 168(sp)
	call	fn.15
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	call	fn.1
	sb	a0, 856(sp)
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	lbu	t1, 856(sp)
	li	t0, 1
	subw	t0, t0, t1
	sb	t0, 569(sp)
	lbu	t0, 569(sp)
	bnez	t0, .LBB8_43
.LBB8_44:                               # %label_44
	ld	t0, 152(sp)
	addi	t0, t0, 24
	sd	t0, 560(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 560(sp)
	ld	a1, 128(sp)
	mv	a2, s1
	call	fn.2
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 208(sp)
	call	fn.12
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	ld	a2, 208(sp)
	call	fn.21
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	call	fn.1
	sb	a0, 948(sp)
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	lbu	t1, 948(sp)
	li	t0, 1
	subw	t5, t0, t1
	mv	t0, t5
	beqz	t0, .LBB8_64
.LBB8_63:                               # %label_63
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	li	a0, 21902
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
.LBB8_64:                               # %label_64
	ld	t0, 152(sp)
	addi	t4, t0, 24
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	mv	a0, t4
	ld	a1, 128(sp)
	mv	a2, s1
	call	fn.2
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	ld	a0, 216(sp)
	call	fn.12
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	ld	a2, 216(sp)
	call	fn.10
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	ld	a0, 128(sp)
	mv	a1, s1
	call	fn.1
	mv	t3, a0
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	li	t0, 1
	subw	s11, t0, t3
	mv	t0, s11
	beqz	t0, .LBB8_84
.LBB8_83:                               # %label_83
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	li	a0, 21903
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
.LBB8_84:                               # %label_84
	ld	t0, 168(sp)
	addi	s10, t0, 12
	lw	s9, 0(s10)
	li	t1, 100
	divw	s8, s9, t1
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	mv	a0, s8
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	ld	t0, 208(sp)
	addi	s7, t0, 12
	lw	s6, 0(s7)
	li	t1, 100
	divw	s5, s6, t1
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	mv	a0, s5
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	ld	t0, 216(sp)
	addi	s4, t0, 12
	lw	s3, 0(s4)
	li	t1, 100
	divw	s2, s3, t1
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	sd	t4, 1152(sp)
	mv	a0, s2
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	ld	t4, 1152(sp)
	addiw	t0, s0, 1
	sw	t0, 896(sp)
	ld	t0, 128(sp)
	sd	t0, 528(sp)
	ld	t0, 128(sp)
	sd	t0, 512(sp)
	ld	t0, 128(sp)
	sd	t0, 504(sp)
	ld	t0, 128(sp)
	sd	t0, 488(sp)
	ld	t0, 128(sp)
	sd	t0, 472(sp)
	ld	t0, 128(sp)
	sd	t0, 464(sp)
	ld	t0, 128(sp)
	sd	t0, 448(sp)
	ld	t0, 128(sp)
	sd	t0, 432(sp)
	ld	t0, 128(sp)
	sd	t0, 424(sp)
	ld	t0, 360(sp)
	sd	t0, 416(sp)
	ld	t0, 168(sp)
	sd	t0, 440(sp)
	ld	t0, 560(sp)
	sd	t0, 456(sp)
	ld	t0, 208(sp)
	sd	t0, 480(sp)
	sd	t4, 496(sp)
	ld	t0, 216(sp)
	sd	t0, 520(sp)
	lw	t0, 896(sp)
	mv	s0, t0
	j	.LBB8_20
.LBB8_8:                               # %label_8
	sd	ra, 1072(sp)
	li	a0, 0
	li	a1, 5000
	ld	a2, 144(sp)
	call	fn.14
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	t0, 224(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 1072(sp)
	ld	t0, 144(sp)
	addi	a1, t0, 24
	sd	ra, 1072(sp)
	sd	a1, 1088(sp)
	mv	a0, a1
	ld	a1, 224(sp)
	li	a2, 5000
	call	fn.2
	ld	ra, 1072(sp)
	ld	a1, 1088(sp)
	sd	ra, 1072(sp)
	ld	a0, 264(sp)
	call	fn.12
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	a0, 224(sp)
	li	a1, 5000
	ld	a2, 264(sp)
	call	fn.21
	ld	ra, 1072(sp)
	li	a1, 0
	li	a0, 0
	li	s1, 0
	li	t0, 0
	sw	t0, 328(sp)
.LBB8_121:                               # %label_121
	lw	t0, 328(sp)
	li	t1, 1000
	bge	t0, t1, .LBB8_123
.LBB8_122:                               # %label_122
	lw	t0, 328(sp)
	li	t1, 73
	mulw	t0, t0, t1
	sw	t0, 960(sp)
	lw	t0, 960(sp)
	addiw	t0, t0, 29
	sw	t0, 964(sp)
	lw	t0, 964(sp)
	li	t1, 100000
	remw	t0, t0, t1
	sw	t0, 592(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a1, 1088(sp)
	ld	a0, 176(sp)
	call	fn.12
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a1, 1088(sp)
	ld	t0, 144(sp)
	addi	t0, t0, 24
	sd	t0, 872(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a1, 1088(sp)
	ld	a0, 872(sp)
	li	a1, 5000
	lw	a2, 592(sp)
	ld	a3, 176(sp)
	call	fn.5
	sw	a0, 968(sp)
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a1, 1088(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a1, 1088(sp)
	ld	a0, 184(sp)
	call	fn.12
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a1, 1088(sp)
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a1, 1088(sp)
	ld	a0, 224(sp)
	li	a1, 5000
	lw	a2, 592(sp)
	ld	a3, 184(sp)
	call	fn.6
	mv	s0, a0
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a1, 1088(sp)
	sw	a1, 324(sp)
	lw	t0, 968(sp)
	li	t1, -1
	bne	t0, t1, .LBB8_152
.LBB8_151:                               # %label_151
	ld	t0, 176(sp)
	addi	t0, t0, 16
	sd	t0, 336(sp)
	ld	t0, 336(sp)
	lw	t0, 0(t0)
	sw	t0, 548(sp)
	lw	t1, 548(sp)
	addw	t0, a0, t1
	sw	t0, 392(sp)
	ld	t0, 184(sp)
	addi	t0, t0, 16
	sd	t0, 344(sp)
	ld	t0, 344(sp)
	lw	t0, 0(t0)
	sw	t0, 552(sp)
	lw	t1, 552(sp)
	addw	t0, s1, t1
	sw	t0, 396(sp)
	lw	t0, 328(sp)
	addiw	t0, t0, 1
	sw	t0, 400(sp)
	lw	t0, 392(sp)
	mv	a0, t0
	lw	t0, 396(sp)
	mv	s1, t0
	lw	t0, 400(sp)
	sw	t0, 328(sp)
	lw	t0, 324(sp)
	mv	a1, t0
	j	.LBB8_121
.LBB8_22:                               # %label_22
	addiw	a7, a0, 1
	mv	a0, a7
	ld	t0, 416(sp)
	sd	t0, 608(sp)
	ld	t0, 424(sp)
	sd	t0, 616(sp)
	ld	t0, 432(sp)
	sd	t0, 624(sp)
	ld	t0, 440(sp)
	sd	t0, 632(sp)
	ld	t0, 448(sp)
	sd	t0, 640(sp)
	ld	t0, 456(sp)
	sd	t0, 648(sp)
	ld	t0, 464(sp)
	sd	t0, 656(sp)
	ld	t0, 472(sp)
	sd	t0, 664(sp)
	ld	t0, 480(sp)
	sd	t0, 672(sp)
	ld	t0, 488(sp)
	sd	t0, 680(sp)
	ld	t0, 496(sp)
	sd	t0, 688(sp)
	ld	t0, 504(sp)
	sd	t0, 696(sp)
	ld	t0, 512(sp)
	sd	t0, 704(sp)
	ld	t0, 520(sp)
	sd	t0, 712(sp)
	ld	t0, 528(sp)
	sd	t0, 720(sp)
	j	.LBB8_6
.LBB8_43:                               # %label_43
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a7, 1136(sp)
	li	a0, 21901
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a7, 1136(sp)
	j	.LBB8_44
.LBB8_123:                               # %label_123
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a1, 1088(sp)
	mv	a0, a1
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a1, 1088(sp)
	li	t1, 1000
	divw	a4, a0, t1
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	mv	a0, a4
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	li	t1, 1000
	divw	a4, s1, t1
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	mv	a0, a4
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	sd	ra, 1072(sp)
	li	a0, 1
	li	a1, 300
	ld	a2, 160(sp)
	call	fn.14
	ld	ra, 1072(sp)
	ld	t0, 160(sp)
	addi	a5, t0, 24
	ld	t0, 160(sp)
	mv	a4, t0
	lw	a4, 0(a4)
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	sd	a5, 1120(sp)
	mv	a0, a5
	li	a1, 300
	mv	a2, a4
	call	fn.16
	mv	a6, a0
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	ld	a5, 1120(sp)
	sd	ra, 1072(sp)
	sd	a6, 1128(sp)
	ld	t0, 232(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 1072(sp)
	ld	a6, 1128(sp)
	ld	t0, 160(sp)
	addi	a4, t0, 24
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	sd	a6, 1128(sp)
	mv	a0, a4
	ld	a1, 232(sp)
	li	a2, 300
	call	fn.2
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	ld	a6, 1128(sp)
	sd	ra, 1072(sp)
	sd	a6, 1128(sp)
	ld	a0, 232(sp)
	li	a1, 300
	call	fn.4
	mv	a5, a0
	ld	ra, 1072(sp)
	ld	a6, 1128(sp)
	ld	t0, 160(sp)
	mv	a4, t0
	lw	a4, 0(a4)
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	sd	a5, 1120(sp)
	sd	a6, 1128(sp)
	mv	a0, a4
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	ld	a5, 1120(sp)
	ld	a6, 1128(sp)
	li	t1, 1000
	divw	a4, a6, t1
	sd	ra, 1072(sp)
	sd	a4, 1112(sp)
	sd	a5, 1120(sp)
	mv	a0, a4
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a4, 1112(sp)
	ld	a5, 1120(sp)
	sd	ra, 1072(sp)
	sd	a5, 1120(sp)
	mv	a0, a5
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a5, 1120(sp)
	sd	ra, 1072(sp)
	li	a0, 50
	li	a1, 50
	li	a2, 1
	ld	a3, 288(sp)
	call	fn.7
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	li	a0, 50
	li	a1, 50
	li	a2, 2
	ld	a3, 296(sp)
	call	fn.7
	ld	ra, 1072(sp)
	ld	t0, 200(sp)
	addi	s0, t0, 8
	sd	ra, 1072(sp)
	ld	t0, 248(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	ld	ra, 1072(sp)
	li	t0, 0
	sw	t0, 408(sp)
.LBB8_206:                               # %label_206
	lw	t0, 408(sp)
	li	t1, 100
	bgeu	t0, t1, .LBB8_208
.LBB8_207:                               # %label_207
	lw	t0, 408(sp)
	li	t1, 400
	mul	t0, t0, t1
	add	t2, s0, t0
	sd	t2, 744(sp)
	sd	ra, 1072(sp)
	ld	t0, 744(sp)
	ld	t1, 248(sp)
	mv	a0, t0
	mv	a1, t1
	li	a2, 400
	call	builtin_memcpy
	ld	ra, 1072(sp)
	lw	t0, 408(sp)
	addiw	t0, t0, 1
	sw	t0, 900(sp)
	lw	t0, 900(sp)
	sw	t0, 408(sp)
	j	.LBB8_206
.LBB8_150:                               # %label_150
	addiw	t0, a1, 1
	sw	t0, 576(sp)
	lw	t0, 576(sp)
	sw	t0, 324(sp)
	j	.LBB8_151
.LBB8_152:                               # %label_152
	sw	a1, 324(sp)
	mv	t0, s0
	li	t1, -1
	bne	t0, t1, .LBB8_150
	j	.LBB8_151
.LBB8_208:                               # %label_208
	ld	t0, 200(sp)
	addi	t0, t0, 4
	sd	t0, 1032(sp)
	ld	t0, 1032(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 200(sp)
	sd	t0, 1040(sp)
	ld	t0, 1040(sp)
	li	t1, 0
	sw	t1, 0(t0)
	sd	ra, 1072(sp)
	ld	a0, 288(sp)
	ld	a1, 296(sp)
	ld	a2, 200(sp)
	call	fn.3
	sb	a0, 1056(sp)
	ld	ra, 1072(sp)
	lbu	t0, 1056(sp)
	beqz	t0, .LBB8_218
.LBB8_217:                               # %label_217
	li	s0, 0
	li	t0, 0
	sw	t0, 352(sp)
.LBB8_228:                               # %label_228
	lw	t0, 352(sp)
	li	t1, 50
	bge	t0, t1, .LBB8_230
.LBB8_229:                               # %label_229
	li	t0, 0
	sw	t0, 320(sp)
.LBB8_234:                               # %label_234
	lw	t0, 320(sp)
	li	t1, 50
	bge	t0, t1, .LBB8_236
.LBB8_235:                               # %label_235
	ld	t0, 200(sp)
	addi	t0, t0, 8
	sd	t0, 368(sp)
	lw	t0, 352(sp)
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 368(sp)
	add	t2, t1, t0
	sd	t2, 376(sp)
	lw	t0, 320(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 376(sp)
	add	t2, t1, t0
	sd	t2, 384(sp)
	ld	t0, 384(sp)
	lw	t0, 0(t0)
	sw	t0, 860(sp)
	lw	t1, 860(sp)
	addw	t0, s0, t1
	sw	t0, 864(sp)
	lw	t0, 864(sp)
	li	t6, 1000000000
	and	t0, t0, t6
	sw	t0, 580(sp)
	lw	t0, 320(sp)
	addiw	t0, t0, 1
	sw	t0, 584(sp)
	lw	t0, 580(sp)
	mv	s0, t0
	lw	t0, 584(sp)
	sw	t0, 320(sp)
	j	.LBB8_234
.LBB8_218:                               # %label_218
	sd	ra, 1072(sp)
	ld	a0, 136(sp)
	call	fn.12
	ld	ra, 1072(sp)
	li	t0, 0
	sw	t0, 404(sp)
	li	s0, 0
.LBB8_257:                               # %label_257
	lw	t0, 404(sp)
	li	t1, 5000
	bge	t0, t1, .LBB8_259
.LBB8_258:                               # %label_258
	ld	t0, 144(sp)
	addi	t0, t0, 24
	sd	t0, 752(sp)
	lw	t0, 404(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 752(sp)
	add	t2, t1, t0
	sd	t2, 760(sp)
	ld	t0, 760(sp)
	lw	t0, 0(t0)
	sw	t0, 972(sp)
	lw	t1, 972(sp)
	addw	t0, s0, t1
	sw	t0, 908(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 768(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 776(sp)
	ld	t0, 776(sp)
	lw	t0, 0(t0)
	sw	t0, 976(sp)
	lw	t0, 976(sp)
	addiw	t0, t0, 1
	sw	t0, 980(sp)
	ld	t0, 768(sp)
	lw	t1, 980(sp)
	sw	t1, 0(t0)
	lw	t0, 404(sp)
	addiw	t0, t0, 1
	sw	t0, 912(sp)
	lw	t0, 908(sp)
	mv	s0, t0
	lw	t0, 912(sp)
	sw	t0, 404(sp)
	j	.LBB8_257
.LBB8_230:                               # %label_230
	li	t1, 1000000000
	remw	t0, s0, t1
	sw	t0, 588(sp)
	sd	ra, 1072(sp)
	lw	a0, 588(sp)
	call	printlnInt
	ld	ra, 1072(sp)
	j	.LBB8_218
.LBB8_236:                               # %label_236
	lw	t0, 352(sp)
	addiw	t0, t0, 1
	sw	t0, 904(sp)
	lw	t0, 904(sp)
	sw	t0, 352(sp)
	j	.LBB8_228
.LBB8_259:                               # %label_259
	li	t0, 0
	sw	t0, 540(sp)
	li	s1, 0
.LBB8_275:                               # %label_275
	lw	t0, 540(sp)
	li	t1, 5000
	bge	t0, t1, .LBB8_277
.LBB8_276:                               # %label_276
	lw	t0, 540(sp)
	li	t1, 11241
	mulw	t0, t0, t1
	sw	t0, 984(sp)
	lw	t0, 984(sp)
	li	t6, 12345
	addw	t0, t0, t6
	sw	t0, 988(sp)
	lw	t0, 988(sp)
	li	t1, 5000
	remw	t0, t0, t1
	sw	t0, 992(sp)
	ld	t0, 144(sp)
	addi	t0, t0, 24
	sd	t0, 784(sp)
	lw	t0, 992(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 784(sp)
	add	t2, t1, t0
	sd	t2, 792(sp)
	ld	t0, 792(sp)
	lw	t0, 0(t0)
	sw	t0, 996(sp)
	lw	t1, 996(sp)
	addw	t0, s1, t1
	sw	t0, 916(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 800(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 808(sp)
	ld	t0, 808(sp)
	lw	t0, 0(t0)
	sw	t0, 1000(sp)
	lw	t0, 1000(sp)
	addiw	t0, t0, 1
	sw	t0, 1004(sp)
	ld	t0, 800(sp)
	lw	t1, 1004(sp)
	sw	t1, 0(t0)
	lw	t0, 540(sp)
	addiw	t0, t0, 1
	sw	t0, 920(sp)
	lw	t0, 916(sp)
	mv	s1, t0
	lw	t0, 920(sp)
	sw	t0, 540(sp)
	j	.LBB8_275
.LBB8_277:                               # %label_277
	li	t0, 0
	sw	t0, 536(sp)
	li	a0, 0
.LBB8_298:                               # %label_298
	lw	t0, 536(sp)
	li	t1, 1000
	bge	t0, t1, .LBB8_300
.LBB8_299:                               # %label_299
	lw	t0, 536(sp)
	li	t1, 5
	mulw	t0, t0, t1
	sw	t0, 1008(sp)
	lw	t0, 1008(sp)
	li	t1, 5000
	remw	t0, t0, t1
	sw	t0, 1012(sp)
	ld	t0, 144(sp)
	addi	t0, t0, 24
	sd	t0, 816(sp)
	lw	t0, 1012(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 816(sp)
	add	t2, t1, t0
	sd	t2, 824(sp)
	ld	t0, 824(sp)
	lw	t0, 0(t0)
	sw	t0, 1016(sp)
	lw	t1, 1016(sp)
	addw	t0, a0, t1
	sw	t0, 924(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 832(sp)
	ld	t0, 136(sp)
	addi	t0, t0, 4
	sd	t0, 840(sp)
	ld	t0, 840(sp)
	lw	t0, 0(t0)
	sw	t0, 1020(sp)
	lw	t0, 1020(sp)
	addiw	t0, t0, 1
	sw	t0, 1024(sp)
	ld	t0, 832(sp)
	lw	t1, 1024(sp)
	sw	t1, 0(t0)
	lw	t0, 536(sp)
	addiw	t0, t0, 1
	sw	t0, 928(sp)
	lw	t0, 924(sp)
	mv	a0, t0
	lw	t0, 928(sp)
	sw	t0, 536(sp)
	j	.LBB8_298
.LBB8_300:                               # %label_300
	li	t1, 1000
	divw	a3, s0, t1
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a3, 1104(sp)
	mv	a0, a3
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a3, 1104(sp)
	li	t1, 1000
	divw	a3, s1, t1
	sd	ra, 1072(sp)
	sd	a0, 1080(sp)
	sd	a3, 1104(sp)
	mv	a0, a3
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a0, 1080(sp)
	ld	a3, 1104(sp)
	li	t1, 100
	divw	a3, a0, t1
	sd	ra, 1072(sp)
	sd	a3, 1104(sp)
	mv	a0, a3
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a3, 1104(sp)
	ld	t0, 136(sp)
	addi	a3, t0, 4
	lw	a3, 0(a3)
	li	t1, 1000
	divw	a3, a3, t1
	sd	ra, 1072(sp)
	sd	a3, 1104(sp)
	mv	a0, a3
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a3, 1104(sp)
	li	t0, 0
	sw	t0, 544(sp)
.LBB8_330:                               # %label_330
	lw	t0, 544(sp)
	li	t1, 10000
	bgeu	t0, t1, .LBB8_332
.LBB8_331:                               # %label_331
	lw	t0, 544(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 280(sp)
	add	t2, t1, t0
	sd	t2, 848(sp)
	ld	t0, 848(sp)
	li	t1, 42
	sw	t1, 0(t0)
	lw	t0, 544(sp)
	addiw	t0, t0, 1
	sw	t0, 932(sp)
	lw	t0, 932(sp)
	sw	t0, 544(sp)
	j	.LBB8_330
.LBB8_332:                               # %label_332
	sd	ra, 1072(sp)
	ld	a0, 304(sp)
	call	fn.12
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	a0, 280(sp)
	li	a1, 1000
	ld	a2, 304(sp)
	call	fn.21
	ld	ra, 1072(sp)
	ld	t0, 304(sp)
	addi	t0, t0, 12
	sd	t0, 1048(sp)
	ld	t0, 1048(sp)
	lw	t0, 0(t0)
	sw	t0, 1064(sp)
	lw	t0, 1064(sp)
	li	t1, 100
	divw	t0, t0, t1
	sw	t0, 1060(sp)
	sd	ra, 1072(sp)
	lw	a0, 1060(sp)
	call	printlnInt
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	t0, 256(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 1072(sp)
	li	t0, 0
	sw	t0, 356(sp)
	li	s1, 0
	li	s0, 0
.LBB8_349:                               # %label_349
	lw	t0, 356(sp)
	li	t1, 1000
	bge	t0, t1, .LBB8_351
.LBB8_350:                               # %label_350
	lw	t0, 356(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 256(sp)
	add	a0, t1, t0
	lw	t0, 356(sp)
	li	t1, 2
	remw	t0, t0, t1
	sw	t0, 1028(sp)
	lw	t0, 1028(sp)
	beq	t0, x0, .LBB8_356
.LBB8_357:                               # %label_357
	li	t0, 2
	sw	t0, 940(sp)
	li	t0, 2
	sw	t0, 600(sp)
	lw	t0, 940(sp)
	sw	t0, 728(sp)
	sw	s1, 596(sp)
.LBB8_358:                               # %label_358
	lw	t1, 728(sp)
	sw	t1, 0(a0)
	lw	t0, 356(sp)
	addiw	t0, t0, 1
	sw	t0, 944(sp)
	lw	t0, 944(sp)
	sw	t0, 356(sp)
	lw	t0, 596(sp)
	mv	s1, t0
	lw	t0, 600(sp)
	mv	s0, t0
	j	.LBB8_349
.LBB8_351:                               # %label_351
	sd	ra, 1072(sp)
	ld	a0, 240(sp)
	call	fn.12
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	a0, 256(sp)
	li	a1, 1000
	ld	a2, 240(sp)
	call	fn.10
	ld	ra, 1072(sp)
	ld	t0, 240(sp)
	addi	a2, t0, 12
	lw	a2, 0(a2)
	li	t1, 100
	divw	a2, a2, t1
	sd	ra, 1072(sp)
	sd	a2, 1096(sp)
	mv	a0, a2
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a2, 1096(sp)
	sd	ra, 1072(sp)
	ld	t0, 192(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 1072(sp)
	ld	t0, 192(sp)
	mv	a2, t0
	li	t1, 123
	sw	t1, 0(a2)
	sd	ra, 1072(sp)
	ld	a0, 272(sp)
	call	fn.12
	ld	ra, 1072(sp)
	sd	ra, 1072(sp)
	ld	a0, 192(sp)
	li	a1, 1
	ld	a2, 272(sp)
	call	fn.13
	ld	ra, 1072(sp)
	ld	t0, 192(sp)
	mv	a2, t0
	lw	a2, 0(a2)
	sd	ra, 1072(sp)
	sd	a2, 1096(sp)
	mv	a0, a2
	call	printlnInt
	ld	ra, 1072(sp)
	ld	a2, 1096(sp)
	sd	ra, 1072(sp)
	li	a0, 21999
	call	printlnInt
	ld	ra, 1072(sp)
	ld	s0, 1168(sp)
	ld	s1, 1176(sp)
	ld	s2, 1184(sp)
	ld	s3, 1192(sp)
	ld	s4, 1200(sp)
	ld	s5, 1208(sp)
	ld	s6, 1216(sp)
	ld	s7, 1224(sp)
	ld	s8, 1232(sp)
	ld	s9, 1240(sp)
	ld	s10, 1248(sp)
	ld	s11, 1256(sp)
	li	a0, 0
	li	t6, 481984
	add	sp, sp, t6
	ret
.LBB8_356:                               # %label_356
	li	t0, 1
	sw	t0, 936(sp)
	li	t0, 1
	sw	t0, 596(sp)
	lw	t0, 936(sp)
	sw	t0, 728(sp)
	sw	s0, 600(sp)
	j	.LBB8_358
.Lfunc_end8:
	.size	fn.0, .Lfunc_end8-fn.0
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -96
.LBB9_0:                               # %label_0
	li	a2, 0
.LBB9_5:                               # %label_5
	addiw	t4, a1, -1
	mv	t0, a2
	mv	t1, t4
	bge	t0, t1, .LBB9_7
.LBB9_6:                               # %label_6
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	a7, 0(t3)
	addiw	a5, a2, 1
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	a4, 0(a6)
	mv	t0, a7
	mv	t1, a4
	blt	t1, t0, .LBB9_12
.LBB9_13:                               # %label_13
	addiw	a3, a2, 1
	mv	a2, a3
	j	.LBB9_5
.LBB9_7:                               # %label_7
	li	a0, 1
	addi	sp, sp, 96
	ret
.LBB9_12:                               # %label_12
	li	a0, 0
	addi	sp, sp, 96
	ret
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.globl	fn.2                            # -- Begin function fn.2
	.p2align	1
	.type	fn.2,@function
fn.2:                                   # @fn.2
# %bb.0:                                # %alloca
	addi	sp, sp, -80
.LBB10_0:                               # %label_0
	li	a3, 0
.LBB10_7:                               # %label_7
	mv	t0, a3
	mv	t1, a2
	bge	t0, t1, .LBB10_9
.LBB10_8:                               # %label_8
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a1, t0
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	t0, 0(a6)
	sw	t0, 4(sp)
	lw	t1, 4(sp)
	sw	t1, 0(a7)
	addiw	a4, a3, 1
	mv	a3, a4
	j	.LBB10_7
.LBB10_9:                               # %label_9
	li	a0, 0
	addi	sp, sp, 80
	ret
.Lfunc_end10:
	.size	fn.2, .Lfunc_end10-fn.2
                                        # -- End function
	.globl	fn.3                            # -- Begin function fn.3
	.p2align	1
	.type	fn.3,@function
fn.3:                                   # @fn.3
# %bb.0:                                # %alloca
	addi	sp, sp, -336
	sd	s0, 240(sp)
	sd	s2, 248(sp)
	sd	s3, 256(sp)
	sd	s4, 264(sp)
	sd	s5, 272(sp)
	sd	s6, 280(sp)
	sd	s7, 288(sp)
	sd	s8, 296(sp)
	sd	s9, 304(sp)
	sd	s10, 312(sp)
	sd	s11, 320(sp)
.LBB11_0:                               # %label_0
	mv	a4, a0
	lw	a5, 0(a4)
	addi	a4, a1, 4
	lw	a4, 0(a4)
	mv	t0, a5
	mv	t1, a4
	beq	t0, t1, .LBB11_7
.LBB11_6:                               # %label_6
	ld	s0, 240(sp)
	ld	s2, 248(sp)
	ld	s3, 256(sp)
	ld	s4, 264(sp)
	ld	s5, 272(sp)
	ld	s6, 280(sp)
	ld	s7, 288(sp)
	ld	s8, 296(sp)
	ld	s9, 304(sp)
	ld	s10, 312(sp)
	ld	s11, 320(sp)
	li	a0, 0
	addi	sp, sp, 336
	ret
.LBB11_7:                               # %label_7
	addi	a3, a2, 4
	addi	s9, a0, 4
	lw	t0, 0(s9)
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(a3)
	mv	a3, a2
	mv	s9, a1
	lw	t0, 0(s9)
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(a3)
	li	t3, 0
	li	a3, 0
.LBB11_26:                               # %label_26
	addi	t0, a0, 4
	sd	t0, 96(sp)
	ld	t0, 96(sp)
	lw	t0, 0(t0)
	sw	t0, 124(sp)
	mv	t0, t3
	lw	t1, 124(sp)
	bge	t0, t1, .LBB11_28
.LBB11_27:                               # %label_27
	li	a7, 0
.LBB11_35:                               # %label_35
	mv	t0, a1
	sd	t0, 0(sp)
	ld	t0, 0(sp)
	lw	t0, 0(t0)
	sw	t0, 104(sp)
	mv	t0, a7
	lw	t1, 104(sp)
	bge	t0, t1, .LBB11_37
.LBB11_36:                               # %label_36
	addi	t0, a2, 8
	sd	t0, 8(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 8(sp)
	add	t2, t1, t0
	sd	t2, 16(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 16(sp)
	add	t2, t1, t0
	sd	t2, 24(sp)
	ld	t0, 24(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	a6, 0
.LBB11_50:                               # %label_50
	mv	t0, a0
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 108(sp)
	mv	t0, a6
	lw	t1, 108(sp)
	bge	t0, t1, .LBB11_52
.LBB11_51:                               # %label_51
	addi	t0, a2, 8
	sd	t0, 40(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 40(sp)
	add	t2, t1, t0
	sd	t2, 48(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 48(sp)
	add	t2, t1, t0
	sd	t2, 56(sp)
	addi	t0, a2, 8
	sd	t0, 64(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 64(sp)
	add	t2, t1, t0
	sd	t2, 72(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 72(sp)
	add	t2, t1, t0
	sd	t2, 80(sp)
	ld	t0, 80(sp)
	lw	t0, 0(t0)
	sw	t0, 112(sp)
	addi	s11, a0, 8
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	add	s10, s11, t0
	mv	t0, a6
	li	t1, 4
	mul	t0, t0, t1
	add	s8, s10, t0
	lw	s7, 0(s8)
	addi	s6, a1, 8
	mv	t0, a6
	li	t1, 400
	mul	t0, t0, t1
	add	s5, s6, t0
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	add	s4, s5, t0
	lw	s3, 0(s4)
	mulw	s2, s7, s3
	lw	t0, 112(sp)
	addw	t0, t0, s2
	sw	t0, 116(sp)
	ld	t0, 56(sp)
	lw	t1, 116(sp)
	sw	t1, 0(t0)
	addiw	s0, a6, 1
	mv	a6, s0
	j	.LBB11_50
.LBB11_28:                               # %label_28
	ld	s0, 240(sp)
	ld	s2, 248(sp)
	ld	s3, 256(sp)
	ld	s4, 264(sp)
	ld	s5, 272(sp)
	ld	s6, 280(sp)
	ld	s7, 288(sp)
	ld	s8, 296(sp)
	ld	s9, 304(sp)
	ld	s10, 312(sp)
	ld	s11, 320(sp)
	li	a0, 1
	addi	sp, sp, 336
	ret
.LBB11_37:                               # %label_37
	addiw	t4, t3, 1
	mv	t3, t4
	j	.LBB11_26
.LBB11_52:                               # %label_52
	addiw	t5, a7, 1
	mv	a7, t5
	mv	a3, a6
	j	.LBB11_35
.Lfunc_end11:
	.size	fn.3, .Lfunc_end11-fn.3
                                        # -- End function
	.globl	fn.4                            # -- Begin function fn.4
	.p2align	1
	.type	fn.4,@function
fn.4:                                   # @fn.4
# %bb.0:                                # %alloca
	addi	sp, sp, -224
	sd	s0, 176(sp)
	sd	s1, 184(sp)
	addi	t6, sp, 192
	sd	t6, 128(sp)
.LBB12_0:                               # %label_0
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	ld	a0, 128(sp)
	call	fn.12
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	ld	a2, 128(sp)
	call	fn.21
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	li	t1, 2
	remw	a2, a1, t1
	mv	t0, a2
	bne	t0, x0, .LBB12_11
.LBB12_10:                               # %label_10
	li	t1, 2
	divuw	s0, a1, t1
	addiw	s0, s0, -1
	mv	t0, s0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s1, 0(s0)
	li	t1, 2
	divuw	s0, a1, t1
	mv	t0, s0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s0, 0(s0)
	addw	s0, s1, s0
	li	t1, 2
	divw	s0, s0, t1
	sw	s0, 136(sp)
.LBB12_12:                               # %label_12
	lw	a0, 136(sp)
	ld	s0, 176(sp)
	ld	s1, 184(sp)
	addi	sp, sp, 224
	ret
.LBB12_11:                               # %label_11
	li	t1, 2
	divuw	s0, a1, t1
	mv	t0, s0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s0, 0(s0)
	sw	s0, 136(sp)
	j	.LBB12_12
.Lfunc_end12:
	.size	fn.4, .Lfunc_end12-fn.4
                                        # -- End function
	.globl	fn.5                            # -- Begin function fn.5
	.p2align	1
	.type	fn.5,@function
fn.5:                                   # @fn.5
# %bb.0:                                # %alloca
	addi	sp, sp, -176
	sd	s0, 112(sp)
	sd	s1, 120(sp)
	sd	s3, 128(sp)
	sd	s4, 136(sp)
	sd	s5, 144(sp)
	sd	s6, 152(sp)
	sd	s7, 160(sp)
	sd	s8, 168(sp)
.LBB13_0:                               # %label_0
	mv	s7, a3
	mv	s6, a3
	lw	s6, 0(s6)
	addiw	t0, s6, 1
	sw	t0, 24(sp)
	lw	t1, 24(sp)
	sw	t1, 0(s7)
	li	t0, 0
	sw	t0, 0(sp)
.LBB13_15:                               # %label_15
	lw	t0, 0(sp)
	mv	t1, a1
	bge	t0, t1, .LBB13_17
.LBB13_16:                               # %label_16
	addi	s5, a3, 12
	addi	s4, a3, 12
	lw	s3, 0(s4)
	addiw	t0, s3, 1
	sw	t0, 8(sp)
	lw	t1, 8(sp)
	sw	t1, 0(s5)
	addi	s1, a3, 4
	addi	s0, a3, 4
	lw	t5, 0(s0)
	addiw	t0, t5, 1
	sw	t0, 12(sp)
	lw	t1, 12(sp)
	sw	t1, 0(s1)
	lw	t0, 0(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	a7, 0(t3)
	mv	t0, a7
	mv	t1, a2
	beq	t0, t1, .LBB13_33
.LBB13_34:                               # %label_34
	lw	t0, 0(sp)
	addiw	a5, t0, 1
	sw	a5, 0(sp)
	j	.LBB13_15
.LBB13_17:                               # %label_17
	addi	a6, a3, 16
	addi	s8, a3, 16
	lw	s8, 0(s8)
	addw	t0, s8, a1
	sw	t0, 20(sp)
	lw	t1, 20(sp)
	sw	t1, 0(a6)
	ld	s0, 112(sp)
	ld	s1, 120(sp)
	ld	s3, 128(sp)
	ld	s4, 136(sp)
	ld	s5, 144(sp)
	ld	s6, 152(sp)
	ld	s7, 160(sp)
	ld	s8, 168(sp)
	li	a0, -1
	addi	sp, sp, 176
	ret
.LBB13_33:                               # %label_33
	addi	a6, a3, 16
	addi	s8, a3, 16
	lw	s8, 0(s8)
	lw	t1, 0(sp)
	addw	s8, s8, t1
	addiw	t0, s8, 1
	sw	t0, 16(sp)
	lw	t1, 16(sp)
	sw	t1, 0(a6)
	lw	a0, 0(sp)
	ld	s0, 112(sp)
	ld	s1, 120(sp)
	ld	s3, 128(sp)
	ld	s4, 136(sp)
	ld	s5, 144(sp)
	ld	s6, 152(sp)
	ld	s7, 160(sp)
	ld	s8, 168(sp)
	addi	sp, sp, 176
	ret
.Lfunc_end13:
	.size	fn.5, .Lfunc_end13-fn.5
                                        # -- End function
	.globl	fn.6                            # -- Begin function fn.6
	.p2align	1
	.type	fn.6,@function
fn.6:                                   # @fn.6
# %bb.0:                                # %alloca
	addi	sp, sp, -256
	sd	s0, 160(sp)
	sd	s2, 168(sp)
	sd	s3, 176(sp)
	sd	s4, 184(sp)
	sd	s5, 192(sp)
	sd	s6, 200(sp)
	sd	s7, 208(sp)
	sd	s8, 216(sp)
	sd	s9, 224(sp)
	sd	s10, 232(sp)
	sd	s11, 240(sp)
.LBB14_0:                               # %label_0
	mv	t3, a3
	mv	s0, a3
	lw	s0, 0(s0)
	addiw	t0, s0, 1
	sw	t0, 64(sp)
	lw	t1, 64(sp)
	sw	t1, 0(t3)
	addiw	t3, a1, -1
	li	t5, 0
	mv	t4, t3
.LBB14_18:                               # %label_18
	mv	t0, t5
	mv	t1, t4
	blt	t1, t0, .LBB14_20
.LBB14_19:                               # %label_19
	subw	t0, t4, t5
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	li	t1, 2
	divw	t0, t0, t1
	sw	t0, 44(sp)
	lw	t1, 44(sp)
	addw	t0, t5, t1
	sw	t0, 0(sp)
	addi	t0, a3, 12
	sd	t0, 8(sp)
	addi	t0, a3, 12
	sd	t0, 16(sp)
	ld	t0, 16(sp)
	lw	t0, 0(t0)
	sw	t0, 48(sp)
	lw	t0, 48(sp)
	addiw	t0, t0, 1
	sw	t0, 52(sp)
	ld	t0, 8(sp)
	lw	t1, 52(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 24(sp)
	addi	s11, a3, 4
	lw	s10, 0(s11)
	addiw	t0, s10, 1
	sw	t0, 56(sp)
	ld	t0, 24(sp)
	lw	t1, 56(sp)
	sw	t1, 0(t0)
	lw	t0, 0(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	a5, 0(a6)
	mv	t0, a5
	mv	t1, a2
	beq	t0, t1, .LBB14_43
.LBB14_44:                               # %label_44
	lw	t0, 0(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	s8, a0, t0
	lw	s7, 0(s8)
	mv	t0, s7
	mv	t1, a2
	blt	t0, t1, .LBB14_59
.LBB14_60:                               # %label_60
	lw	t0, 0(sp)
	addiw	s5, t0, -1
	mv	t3, s5
	mv	s0, t5
.LBB14_61:                               # %label_61
.LBB14_45:                               # %label_45
	addi	s4, a3, 16
	addi	s3, a3, 16
	lw	s2, 0(s3)
	addiw	t0, s2, 1
	sw	t0, 32(sp)
	lw	t1, 32(sp)
	sw	t1, 0(s4)
	mv	t5, s0
	mv	t4, t3
	j	.LBB14_18
.LBB14_20:                               # %label_20
	ld	s0, 160(sp)
	ld	s2, 168(sp)
	ld	s3, 176(sp)
	ld	s4, 184(sp)
	ld	s5, 192(sp)
	ld	s6, 200(sp)
	ld	s7, 208(sp)
	ld	s8, 216(sp)
	ld	s9, 224(sp)
	ld	s10, 232(sp)
	ld	s11, 240(sp)
	li	a0, -1
	addi	sp, sp, 256
	ret
.LBB14_43:                               # %label_43
	addi	a4, a3, 16
	addi	s9, a3, 16
	lw	s9, 0(s9)
	addiw	t0, s9, 1
	sw	t0, 60(sp)
	lw	t1, 60(sp)
	sw	t1, 0(a4)
	lw	a0, 0(sp)
	ld	s0, 160(sp)
	ld	s2, 168(sp)
	ld	s3, 176(sp)
	ld	s4, 184(sp)
	ld	s5, 192(sp)
	ld	s6, 200(sp)
	ld	s7, 208(sp)
	ld	s8, 216(sp)
	ld	s9, 224(sp)
	ld	s10, 232(sp)
	ld	s11, 240(sp)
	addi	sp, sp, 256
	ret
.LBB14_59:                               # %label_59
	lw	t0, 0(sp)
	addiw	s6, t0, 1
	mv	s0, s6
	mv	t3, t4
	j	.LBB14_61
.Lfunc_end14:
	.size	fn.6, .Lfunc_end14-fn.6
                                        # -- End function
	.globl	fn.7                            # -- Begin function fn.7
	.p2align	1
	.type	fn.7,@function
fn.7:                                   # @fn.7
# %bb.0:                                # %alloca
	addi	sp, sp, -752
	sd	s0, 256(sp)
	sd	s1, 264(sp)
	sd	s2, 272(sp)
	sd	s4, 280(sp)
	sd	s5, 288(sp)
	sd	s6, 296(sp)
	sd	s7, 304(sp)
	sd	s8, 312(sp)
	sd	s9, 320(sp)
	sd	s10, 328(sp)
	sd	s11, 336(sp)
	addi	t6, sp, 344
	sd	t6, 0(sp)
.LBB15_0:                               # %label_0
	addi	t0, a3, 8
	sd	t0, 144(sp)
	sd	ra, 160(sp)
	sd	a0, 168(sp)
	sd	a1, 176(sp)
	sd	a2, 184(sp)
	sd	a3, 192(sp)
	sd	a4, 200(sp)
	sd	a5, 208(sp)
	sd	a6, 216(sp)
	sd	a7, 224(sp)
	sd	t3, 232(sp)
	sd	t4, 240(sp)
	sd	t5, 248(sp)
	ld	t0, 0(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	ld	ra, 160(sp)
	ld	a0, 168(sp)
	ld	a1, 176(sp)
	ld	a2, 184(sp)
	ld	a3, 192(sp)
	ld	a4, 200(sp)
	ld	a5, 208(sp)
	ld	a6, 216(sp)
	ld	a7, 224(sp)
	ld	t3, 232(sp)
	ld	t4, 240(sp)
	ld	t5, 248(sp)
	li	s0, 0
.LBB15_12:                               # %label_12
	mv	t0, s0
	li	t1, 100
	bgeu	t0, t1, .LBB15_14
.LBB15_13:                               # %label_13
	mv	t0, s0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 144(sp)
	add	t2, t1, t0
	sd	t2, 96(sp)
	sd	ra, 160(sp)
	sd	a0, 168(sp)
	sd	a1, 176(sp)
	sd	a2, 184(sp)
	sd	a3, 192(sp)
	sd	a5, 208(sp)
	sd	a6, 216(sp)
	sd	a7, 224(sp)
	sd	t3, 232(sp)
	sd	t4, 240(sp)
	sd	t5, 248(sp)
	ld	t0, 96(sp)
	ld	t1, 0(sp)
	mv	a0, t0
	mv	a1, t1
	li	a2, 400
	call	builtin_memcpy
	ld	ra, 160(sp)
	ld	a0, 168(sp)
	ld	a1, 176(sp)
	ld	a2, 184(sp)
	ld	a3, 192(sp)
	ld	a5, 208(sp)
	ld	a6, 216(sp)
	ld	a7, 224(sp)
	ld	t3, 232(sp)
	ld	t4, 240(sp)
	ld	t5, 248(sp)
	addiw	a4, s0, 1
	mv	s0, a4
	j	.LBB15_12
.LBB15_14:                               # %label_14
	addi	s11, a3, 4
	sw	a0, 0(s11)
	mv	s11, a3
	sw	a1, 0(s11)
	li	t5, 0
	li	s0, 0
	li	a4, 0
.LBB15_26:                               # %label_26
	mv	t0, t5
	mv	t1, a0
	bge	t0, t1, .LBB15_28
.LBB15_27:                               # %label_27
	li	t4, 0
.LBB15_33:                               # %label_33
	mv	t0, t4
	mv	t1, a1
	bge	t0, t1, .LBB15_35
.LBB15_34:                               # %label_34
	mv	t0, a2
	beq	t0, x0, .LBB15_39
.LBB15_40:                               # %label_40
	mv	t0, a2
	li	t1, 1
	beq	t0, t1, .LBB15_62
.LBB15_63:                               # %label_63
	mv	t0, a2
	li	t1, 2
	bne	t0, t1, .LBB15_80
.LBB15_79:                               # %label_79
	addi	t0, a3, 8
	sd	t0, 48(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 48(sp)
	add	t2, t1, t0
	sd	t2, 56(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 56(sp)
	add	t2, t1, t0
	sd	t2, 64(sp)
	mulw	t0, t5, a1
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	addw	t0, t0, t4
	sw	t0, 132(sp)
	lw	t0, 132(sp)
	addiw	t0, t0, 1
	sw	t0, 136(sp)
	ld	t0, 64(sp)
	lw	t1, 136(sp)
	sw	t1, 0(t0)
	mv	a7, s0
	mv	a5, a4
.LBB15_41:                               # %label_41
	addiw	s2, t4, 1
	mv	t4, s2
	mv	s0, a7
	mv	a4, a5
	j	.LBB15_33
.LBB15_28:                               # %label_28
	ld	s0, 256(sp)
	ld	s1, 264(sp)
	ld	s2, 272(sp)
	ld	s4, 280(sp)
	ld	s5, 288(sp)
	ld	s6, 296(sp)
	ld	s7, 304(sp)
	ld	s8, 312(sp)
	ld	s9, 320(sp)
	ld	s10, 328(sp)
	ld	s11, 336(sp)
	li	a0, 0
	addi	sp, sp, 752
	ret
.LBB15_35:                               # %label_35
	addiw	s1, t5, 1
	mv	t5, s1
	j	.LBB15_26
.LBB15_39:                               # %label_39
	addi	t0, a3, 8
	sd	t0, 104(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 104(sp)
	add	t2, t1, t0
	sd	t2, 112(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 112(sp)
	add	s11, t1, t0
	mv	t0, t5
	mv	t1, t4
	beq	t0, t1, .LBB15_49
.LBB15_50:                               # %label_50
	li	t0, 0
	sw	t0, 44(sp)
	li	a6, 0
	lw	t0, 44(sp)
	sw	t0, 8(sp)
	mv	t3, s0
.LBB15_51:                               # %label_51
	lw	t1, 8(sp)
	sw	t1, 0(s11)
	mv	a7, t3
	mv	a5, a6
	j	.LBB15_41
.LBB15_49:                               # %label_49
	li	t0, 1
	sw	t0, 40(sp)
	li	t3, 1
	lw	t0, 40(sp)
	sw	t0, 8(sp)
	mv	a6, a4
	j	.LBB15_51
.LBB15_62:                               # %label_62
	addi	t0, a3, 8
	sd	t0, 16(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 16(sp)
	add	t2, t1, t0
	sd	t2, 24(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 24(sp)
	add	t2, t1, t0
	sd	t2, 32(sp)
	li	t1, 17
	mulw	t0, t5, t1
	sw	t0, 72(sp)
	li	t1, 23
	mulw	t0, t4, t1
	sw	t0, 76(sp)
	lw	t0, 72(sp)
	lw	t1, 76(sp)
	addw	t0, t0, t1
	sw	t0, 80(sp)
	lw	t0, 80(sp)
	addiw	t0, t0, 13
	sw	t0, 84(sp)
	lw	t0, 84(sp)
	li	t1, 100
	remw	t0, t0, t1
	sw	t0, 88(sp)
	ld	t0, 32(sp)
	lw	t1, 88(sp)
	sw	t1, 0(t0)
	mv	a7, s0
	mv	a5, a4
	j	.LBB15_41
.LBB15_80:                               # %label_80
	addi	t0, a3, 8
	sd	t0, 120(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 120(sp)
	add	s10, t1, t0
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	add	s9, s10, t0
	mulw	s8, t5, t5
	mulw	s7, t4, t4
	addw	s6, s8, s7
	mulw	s5, t5, t4
	addw	s4, s6, s5
	li	t1, 50
	remw	t0, s4, t1
	sw	t0, 156(sp)
	lw	t1, 156(sp)
	sw	t1, 0(s9)
	mv	a7, s0
	mv	a5, a4
	j	.LBB15_41
.Lfunc_end15:
	.size	fn.7, .Lfunc_end15-fn.7
                                        # -- End function
	.globl	fn.8                            # -- Begin function fn.8
	.p2align	1
	.type	fn.8,@function
fn.8:                                   # @fn.8
# %bb.0:                                # %alloca
	addi	sp, sp, -336
	sd	s0, 248(sp)
	sd	s1, 256(sp)
	sd	s2, 264(sp)
	sd	s3, 272(sp)
	sd	s4, 280(sp)
	sd	s5, 288(sp)
	sd	s6, 296(sp)
	sd	s7, 304(sp)
	sd	s8, 312(sp)
	sd	s9, 320(sp)
	sd	s10, 328(sp)
.LBB16_0:                               # %label_0
	li	t0, 2
	mulw	s3, t0, a2
	addiw	s6, s3, 1
	li	t0, 2
	mulw	s3, t0, a2
	addiw	s5, s3, 2
	addi	s4, a3, 4
	addi	s3, a3, 4
	lw	s3, 0(s3)
	addiw	t0, s3, 1
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(s4)
	mv	s7, a2
	mv	t0, s6
	mv	t1, a1
	bge	t0, t1, .LBB16_25
.LBB16_24:                               # %label_24
	addi	s2, a3, 12
	addi	a6, a3, 12
	lw	a6, 0(a6)
	addiw	t0, a6, 1
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(s2)
	addi	s2, a3, 4
	addi	a6, a3, 4
	lw	a6, 0(a6)
	addiw	t0, a6, 2
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(s2)
	mv	t0, s6
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	s2, 0(a6)
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	a6, 0(a6)
	mv	s8, a2
	mv	t0, s2
	mv	t1, a6
	blt	t1, t0, .LBB16_41
.LBB16_42:                               # %label_42
	mv	s7, s8
.LBB16_25:                               # %label_25
	mv	s9, s7
	mv	t0, s5
	mv	t1, a1
	blt	t0, t1, .LBB16_53
.LBB16_54:                               # %label_54
	mv	t0, s9
	mv	t1, a2
	bne	t0, t1, .LBB16_82
.LBB16_83:                               # %label_83
	ld	s0, 248(sp)
	ld	s1, 256(sp)
	ld	s2, 264(sp)
	ld	s3, 272(sp)
	ld	s4, 280(sp)
	ld	s5, 288(sp)
	ld	s6, 296(sp)
	ld	s7, 304(sp)
	ld	s8, 312(sp)
	ld	s9, 320(sp)
	ld	s10, 328(sp)
	li	a0, 0
	addi	sp, sp, 336
	ret
.LBB16_41:                               # %label_41
	mv	s8, s6
	j	.LBB16_42
.LBB16_53:                               # %label_53
	addi	a5, a3, 12
	addi	a4, a3, 12
	lw	a4, 0(a4)
	addiw	t0, a4, 1
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(a5)
	addi	a5, a3, 4
	addi	a4, a3, 4
	lw	a4, 0(a4)
	addiw	t0, a4, 2
	sw	t0, 152(sp)
	lw	t1, 152(sp)
	sw	t1, 0(a5)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a5, 0(a4)
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a4, 0(a4)
	mv	s10, s7
	mv	t0, a5
	mv	t1, a4
	blt	t1, t0, .LBB16_70
.LBB16_71:                               # %label_71
	mv	s9, s10
	j	.LBB16_54
.LBB16_70:                               # %label_70
	mv	s10, s5
	j	.LBB16_71
.LBB16_82:                               # %label_82
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t0, 0(s0)
	sw	t0, 156(sp)
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	mv	t0, s9
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a0, t0
	lw	t0, 0(a7)
	sw	t0, 160(sp)
	lw	t1, 160(sp)
	sw	t1, 0(s0)
	mv	t0, s9
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t1, 156(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 8
	addi	s1, a3, 8
	lw	s1, 0(s1)
	addiw	t0, s1, 1
	sw	t0, 164(sp)
	lw	t1, 164(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 4
	addi	s1, a3, 4
	lw	s1, 0(s1)
	addiw	t0, s1, 4
	sw	t0, 168(sp)
	lw	t1, 168(sp)
	sw	t1, 0(s0)
	sd	ra, 176(sp)
	sd	a0, 184(sp)
	sd	a1, 192(sp)
	sd	a3, 208(sp)
	mv	a2, s9
	call	fn.8
	ld	ra, 176(sp)
	ld	a0, 184(sp)
	ld	a1, 192(sp)
	ld	a3, 208(sp)
	j	.LBB16_83
.Lfunc_end16:
	.size	fn.8, .Lfunc_end16-fn.8
                                        # -- End function
	.globl	fn.9                            # -- Begin function fn.9
	.p2align	1
	.type	fn.9,@function
fn.9:                                   # @fn.9
# %bb.0:                                # %alloca
	addi	sp, sp, -320
	sd	s0, 224(sp)
	sd	s1, 232(sp)
	sd	s2, 240(sp)
	sd	s3, 248(sp)
	sd	s4, 256(sp)
	sd	s5, 264(sp)
	sd	s6, 272(sp)
	sd	s7, 280(sp)
	sd	s8, 288(sp)
	sd	s9, 296(sp)
	sd	s10, 304(sp)
.LBB17_0:                               # %label_0
	mv	s2, a2
	mv	s5, a2
	lw	s5, 0(s5)
	addiw	t0, s5, 1
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(s2)
	li	s7, 0
	li	s2, 0
.LBB17_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 120(sp)
	mv	t0, s7
	lw	t1, 120(sp)
	bge	t0, t1, .LBB17_15
.LBB17_14:                               # %label_14
	addiw	t0, s7, 1
	sw	t0, 116(sp)
	lw	t0, 116(sp)
	mv	s4, t0
	mv	s5, s7
.LBB17_25:                               # %label_25
	mv	t0, s4
	mv	t1, a1
	bge	t0, t1, .LBB17_27
.LBB17_26:                               # %label_26
	addi	t0, a2, 12
	sd	t0, 0(sp)
	addi	t0, a2, 12
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 88(sp)
	lw	t0, 88(sp)
	addiw	t0, t0, 1
	sw	t0, 92(sp)
	ld	t0, 0(sp)
	lw	t1, 92(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 16(sp)
	addi	t0, a2, 4
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	addiw	t0, t0, 2
	sw	t0, 100(sp)
	ld	t0, 16(sp)
	lw	t1, 100(sp)
	sw	t1, 0(t0)
	mv	t0, s4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 104(sp)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 108(sp)
	mv	s6, s5
	lw	t0, 104(sp)
	lw	t1, 108(sp)
	blt	t0, t1, .LBB17_43
.LBB17_44:                               # %label_44
	addiw	t0, s4, 1
	sw	t0, 52(sp)
	lw	t0, 52(sp)
	mv	s4, t0
	mv	s5, s6
	j	.LBB17_25
.LBB17_15:                               # %label_15
	addi	a3, a2, 16
	addi	s8, a2, 16
	lw	s9, 0(s8)
	mulw	s8, a1, a1
	addw	t0, s9, s8
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(a3)
	ld	s0, 224(sp)
	ld	s1, 232(sp)
	ld	s2, 240(sp)
	ld	s3, 248(sp)
	ld	s4, 256(sp)
	ld	s5, 264(sp)
	ld	s6, 272(sp)
	ld	s7, 280(sp)
	ld	s8, 288(sp)
	ld	s9, 296(sp)
	ld	s10, 304(sp)
	li	a0, 0
	addi	sp, sp, 320
	ret
.LBB17_27:                               # %label_27
	mv	s3, s2
	mv	t0, s5
	mv	t1, s7
	bne	t0, t1, .LBB17_57
.LBB17_58:                               # %label_58
	addiw	a4, s7, 1
	mv	s7, a4
	mv	s2, s3
	j	.LBB17_13
.LBB17_43:                               # %label_43
	mv	s6, s4
	j	.LBB17_44
.LBB17_57:                               # %label_57
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 64(sp)
	ld	t0, 64(sp)
	lw	t0, 0(t0)
	sw	t0, 56(sp)
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 80(sp)
	ld	t0, 80(sp)
	lw	t0, 0(t0)
	sw	t0, 124(sp)
	ld	t0, 72(sp)
	lw	t1, 124(sp)
	sw	t1, 0(t0)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	s10, a0, t0
	lw	t1, 56(sp)
	sw	t1, 0(s10)
	addi	s1, a2, 8
	addi	s0, a2, 8
	lw	t5, 0(s0)
	addiw	t0, t5, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s1)
	addi	t3, a2, 4
	addi	a7, a2, 4
	lw	a6, 0(a7)
	addiw	t0, a6, 4
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(t3)
	lw	t0, 56(sp)
	mv	s3, t0
	j	.LBB17_58
.Lfunc_end17:
	.size	fn.9, .Lfunc_end17-fn.9
                                        # -- End function
	.globl	fn.10                            # -- Begin function fn.10
	.p2align	1
	.type	fn.10,@function
fn.10:                                   # @fn.10
# %bb.0:                                # %alloca
	addi	sp, sp, -176
	sd	s0, 168(sp)
.LBB18_0:                               # %label_0
	mv	t0, a1
	li	t1, 1
	bge	t1, t0, .LBB18_7
.LBB18_6:                               # %label_6
	addiw	s0, a1, -1
	sd	ra, 136(sp)
	sd	a0, 144(sp)
	sd	a2, 160(sp)
	li	a1, 0
	mv	a2, s0
	ld	a3, 160(sp)
	call	fn.19
	ld	ra, 136(sp)
	ld	a0, 144(sp)
	ld	a2, 160(sp)
.LBB18_7:                               # %label_7
	ld	s0, 168(sp)
	li	a0, 0
	addi	sp, sp, 176
	ret
.Lfunc_end18:
	.size	fn.10, .Lfunc_end18-fn.10
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	addi	sp, sp, -144
.LBB19_0:                               # %label_0
	sd	ra, 128(sp)
	call	fn.0
	ld	ra, 128(sp)
	li	a0, 0
	addi	sp, sp, 144
	ret
.Lfunc_end19:
	.size	main, .Lfunc_end19-main
                                        # -- End function
	.globl	fn.12                            # -- Begin function fn.12
	.p2align	1
	.type	fn.12,@function
fn.12:                                   # @fn.12
# %bb.0:                                # %alloca
	addi	sp, sp, -32
.LBB20_0:                               # %label_0
	addi	a1, a0, 16
	li	t1, 0
	sw	t1, 0(a1)
	addi	a1, a0, 12
	li	t1, 0
	sw	t1, 0(a1)
	addi	a1, a0, 8
	li	t1, 0
	sw	t1, 0(a1)
	addi	a1, a0, 4
	li	t1, 0
	sw	t1, 0(a1)
	mv	a1, a0
	li	t1, 0
	sw	t1, 0(a1)
	li	a0, 0
	addi	sp, sp, 32
	ret
.Lfunc_end20:
	.size	fn.12, .Lfunc_end20-fn.12
                                        # -- End function
	.globl	fn.13                            # -- Begin function fn.13
	.p2align	1
	.type	fn.13,@function
fn.13:                                   # @fn.13
# %bb.0:                                # %alloca
	addi	sp, sp, -352
	sd	s0, 272(sp)
	sd	s1, 280(sp)
	sd	s3, 288(sp)
	sd	s4, 296(sp)
	sd	s5, 304(sp)
	sd	s7, 312(sp)
	sd	s8, 320(sp)
	sd	s9, 328(sp)
	sd	s10, 336(sp)
.LBB21_0:                               # %label_0
	mv	s0, a2
	mv	t4, a2
	lw	t4, 0(t4)
	addiw	t0, t4, 1
	sw	t0, 164(sp)
	lw	t1, 164(sp)
	sw	t1, 0(s0)
	li	t1, 2
	divw	s0, a1, t1
	addiw	s0, s0, -1
	mv	s1, s0
.LBB21_16:                               # %label_16
	mv	t0, s1
	blt	t0, x0, .LBB21_18
.LBB21_17:                               # %label_17
	sd	ra, 176(sp)
	sd	a0, 184(sp)
	sd	a1, 192(sp)
	sd	a2, 200(sp)
	sd	a3, 208(sp)
	sd	a7, 240(sp)
	mv	a2, s1
	ld	a3, 200(sp)
	call	fn.8
	ld	ra, 176(sp)
	ld	a0, 184(sp)
	ld	a1, 192(sp)
	ld	a2, 200(sp)
	ld	a3, 208(sp)
	ld	a7, 240(sp)
	addiw	t0, s1, -1
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	mv	s1, t0
	j	.LBB21_16
.LBB21_18:                               # %label_18
	addiw	t0, a1, -1
	sw	t0, 160(sp)
	lw	t0, 160(sp)
	mv	a3, t0
.LBB21_29:                               # %label_29
	mv	t0, a3
	bge	x0, t0, .LBB21_31
.LBB21_30:                               # %label_30
	mv	t0, a0
	sd	t0, 128(sp)
	ld	t0, 128(sp)
	lw	t0, 0(t0)
	sw	t0, 144(sp)
	mv	t5, a0
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	t0, 0(t3)
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(t5)
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	s10, a0, t0
	lw	t1, 144(sp)
	sw	t1, 0(s10)
	addi	s9, a2, 8
	addi	s8, a2, 8
	lw	s7, 0(s8)
	addiw	t0, s7, 1
	sw	t0, 152(sp)
	lw	t1, 152(sp)
	sw	t1, 0(s9)
	addi	s5, a2, 4
	addi	s4, a2, 4
	lw	s3, 0(s4)
	addiw	t0, s3, 4
	sw	t0, 156(sp)
	lw	t1, 156(sp)
	sw	t1, 0(s5)
	sd	ra, 176(sp)
	sd	a0, 184(sp)
	sd	a1, 192(sp)
	sd	a2, 200(sp)
	sd	a3, 208(sp)
	mv	a1, a3
	li	a2, 0
	ld	a3, 200(sp)
	call	fn.8
	ld	ra, 176(sp)
	ld	a0, 184(sp)
	ld	a1, 192(sp)
	ld	a2, 200(sp)
	ld	a3, 208(sp)
	addiw	a7, a3, -1
	mv	a3, a7
	j	.LBB21_29
.LBB21_31:                               # %label_31
	addi	a6, a2, 16
	addi	a4, a2, 16
	lw	a5, 0(a4)
	mulw	a4, a1, a1
	addw	t0, a5, a4
	sw	t0, 168(sp)
	lw	t1, 168(sp)
	sw	t1, 0(a6)
	ld	s0, 272(sp)
	ld	s1, 280(sp)
	ld	s3, 288(sp)
	ld	s4, 296(sp)
	ld	s5, 304(sp)
	ld	s7, 312(sp)
	ld	s8, 320(sp)
	ld	s9, 328(sp)
	ld	s10, 336(sp)
	li	a0, 0
	addi	sp, sp, 352
	ret
.Lfunc_end21:
	.size	fn.13, .Lfunc_end21-fn.13
                                        # -- End function
	.globl	fn.14                            # -- Begin function fn.14
	.p2align	1
	.type	fn.14,@function
fn.14:                                   # @fn.14
# %bb.0:                                # %alloca
	addi	sp, sp, -448
	sd	s0, 352(sp)
	sd	s1, 360(sp)
	sd	s3, 368(sp)
	sd	s4, 376(sp)
	sd	s5, 384(sp)
	sd	s6, 392(sp)
	sd	s7, 400(sp)
	sd	s8, 408(sp)
	sd	s9, 416(sp)
	sd	s10, 424(sp)
	sd	s11, 432(sp)
.LBB22_0:                               # %label_0
	addi	s9, a2, 24
	sd	ra, 256(sp)
	sd	a0, 264(sp)
	sd	a1, 272(sp)
	sd	a2, 280(sp)
	sd	a3, 288(sp)
	sd	a6, 312(sp)
	mv	a0, s9
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 256(sp)
	ld	a0, 264(sp)
	ld	a1, 272(sp)
	ld	a2, 280(sp)
	ld	a3, 288(sp)
	ld	a6, 312(sp)
	addi	s9, a2, 20
	sw	a1, 0(s9)
	addi	s9, a2, 16
	li	t1, 0
	sb	t1, 0(s9)
	addi	s9, a2, 12
	li	t1, 999999
	sw	t1, 0(s9)
	addi	s9, a2, 8
	li	t1, -999999
	sw	t1, 0(s9)
	addi	s9, a2, 4
	li	t1, 0
	sw	t1, 0(s9)
	mv	s9, a2
	li	t1, 0
	sw	t1, 0(s9)
	li	a3, 0
.LBB22_16:                               # %label_16
	mv	t0, a3
	mv	t1, a1
	bge	t0, t1, .LBB22_18
.LBB22_17:                               # %label_17
	mv	t0, a0
	beq	t0, x0, .LBB22_23
.LBB22_24:                               # %label_24
	mv	t0, a0
	li	t1, 1
	beq	t0, t1, .LBB22_33
.LBB22_34:                               # %label_34
	mv	t0, a0
	li	t1, 2
	beq	t0, t1, .LBB22_42
.LBB22_43:                               # %label_43
	mv	t0, a0
	li	t1, 3
	beq	t0, t1, .LBB22_53
.LBB22_54:                               # %label_54
	mv	t0, a0
	li	t1, 4
	beq	t0, t1, .LBB22_75
.LBB22_76:                               # %label_76
	mv	t0, a0
	li	t1, 5
	beq	t0, t1, .LBB22_101
.LBB22_102:                               # %label_102
	mv	t0, a0
	li	t1, 6
	beq	t0, t1, .LBB22_115
.LBB22_116:                               # %label_116
	mv	t0, a0
	li	t1, 7
	beq	t0, t1, .LBB22_125
.LBB22_126:                               # %label_126
	mulw	t0, a3, a3
	sw	t0, 208(sp)
	li	t1, 7
	mulw	t0, a3, t1
	sw	t0, 212(sp)
	lw	t0, 208(sp)
	lw	t1, 212(sp)
	addw	t0, t0, t1
	sw	t0, 216(sp)
	lw	t0, 216(sp)
	addiw	t0, t0, 17
	sw	t0, 220(sp)
	lw	t0, 220(sp)
	li	t1, 1000
	remw	t0, t0, t1
	sw	t0, 92(sp)
	lw	t0, 92(sp)
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	sw	t0, 24(sp)
.LBB22_127:                               # %label_127
	lw	t0, 24(sp)
	sw	t0, 16(sp)
.LBB22_117:                               # %label_117
	lw	t0, 16(sp)
	sw	t0, 20(sp)
.LBB22_103:                               # %label_103
	lw	t0, 20(sp)
	sw	t0, 12(sp)
.LBB22_77:                               # %label_77
	lw	t0, 12(sp)
	mv	s11, t0
.LBB22_55:                               # %label_55
	mv	s10, s11
.LBB22_44:                               # %label_44
	mv	s8, s10
.LBB22_35:                               # %label_35
	sw	s8, 0(sp)
.LBB22_25:                               # %label_25
	addi	s7, a2, 24
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	s6, s7, t0
	lw	t1, 0(sp)
	sw	t1, 0(s6)
	addi	s5, a2, 4
	addi	s4, a2, 4
	lw	s3, 0(s4)
	lw	t1, 0(sp)
	addw	t0, s3, t1
	sw	t0, 224(sp)
	lw	t1, 224(sp)
	sw	t1, 0(s5)
	addi	s1, a2, 12
	lw	s0, 0(s1)
	lw	t0, 0(sp)
	mv	t1, s0
	blt	t0, t1, .LBB22_170
.LBB22_171:                               # %label_171
	addi	t4, a2, 8
	lw	t3, 0(t4)
	lw	t0, 0(sp)
	mv	t1, t3
	bge	t1, t0, .LBB22_179
.LBB22_178:                               # %label_178
	addi	a7, a2, 8
	lw	t1, 0(sp)
	sw	t1, 0(a7)
.LBB22_179:                               # %label_179
	addiw	a6, a3, 1
	mv	a3, a6
	j	.LBB22_16
.LBB22_18:                               # %label_18
	mv	a5, a2
	addi	a4, a2, 4
	lw	a4, 0(a4)
	divw	t0, a4, a1
	sw	t0, 248(sp)
	lw	t1, 248(sp)
	sw	t1, 0(a5)
	ld	s0, 352(sp)
	ld	s1, 360(sp)
	ld	s3, 368(sp)
	ld	s4, 376(sp)
	ld	s5, 384(sp)
	ld	s6, 392(sp)
	ld	s7, 400(sp)
	ld	s8, 408(sp)
	ld	s9, 416(sp)
	ld	s10, 424(sp)
	ld	s11, 432(sp)
	li	a0, 0
	addi	sp, sp, 448
	ret
.LBB22_23:                               # %label_23
	li	t1, 11047
	mulw	t0, a3, t1
	sw	t0, 240(sp)
	lw	t0, 240(sp)
	li	t6, 12345
	addw	t0, t0, t6
	sw	t0, 244(sp)
	lw	t0, 244(sp)
	li	t1, 100000
	remw	t0, t0, t1
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	sw	t0, 236(sp)
	lw	t0, 236(sp)
	sw	t0, 0(sp)
	j	.LBB22_25
.LBB22_33:                               # %label_33
	li	t1, 3
	mulw	t0, a3, t1
	sw	t0, 160(sp)
	lw	t0, 160(sp)
	addiw	t0, t0, 7
	sw	t0, 72(sp)
	lw	t0, 72(sp)
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	mv	s8, t0
	j	.LBB22_35
.LBB22_42:                               # %label_42
	subw	t0, a1, a3
	sw	t0, 164(sp)
	lw	t0, 164(sp)
	li	t1, 5
	mulw	t0, t0, t1
	sw	t0, 168(sp)
	lw	t0, 168(sp)
	addiw	t0, t0, 13
	sw	t0, 76(sp)
	lw	t0, 76(sp)
	sw	t0, 132(sp)
	lw	t0, 132(sp)
	mv	s10, t0
	j	.LBB22_44
.LBB22_53:                               # %label_53
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 172(sp)
	mv	t0, a3
	lw	t1, 172(sp)
	blt	t0, t1, .LBB22_58
.LBB22_59:                               # %label_59
	subw	t0, a1, a3
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	li	t1, 4
	mulw	t0, t0, t1
	sw	t0, 36(sp)
	lw	t0, 36(sp)
	sw	t0, 52(sp)
	lw	t0, 52(sp)
	sw	t0, 4(sp)
.LBB22_60:                               # %label_60
	lw	t0, 4(sp)
	sw	t0, 56(sp)
	lw	t0, 56(sp)
	mv	s11, t0
	j	.LBB22_55
.LBB22_58:                               # %label_58
	li	t1, 4
	mulw	t0, a3, t1
	sw	t0, 32(sp)
	lw	t0, 32(sp)
	sw	t0, 48(sp)
	lw	t0, 48(sp)
	sw	t0, 4(sp)
	j	.LBB22_60
.LBB22_75:                               # %label_75
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 176(sp)
	mv	t0, a3
	lw	t1, 176(sp)
	blt	t0, t1, .LBB22_80
.LBB22_81:                               # %label_81
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 108(sp)
	lw	t1, 108(sp)
	subw	t0, a3, t1
	sw	t0, 112(sp)
	lw	t0, 112(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 44(sp)
	lw	t0, 44(sp)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	sw	t0, 8(sp)
.LBB22_82:                               # %label_82
	lw	t0, 8(sp)
	sw	t0, 68(sp)
	lw	t0, 68(sp)
	sw	t0, 12(sp)
	j	.LBB22_77
.LBB22_80:                               # %label_80
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 100(sp)
	lw	t0, 100(sp)
	subw	t0, t0, a3
	sw	t0, 104(sp)
	lw	t0, 104(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	sw	t0, 60(sp)
	lw	t0, 60(sp)
	sw	t0, 8(sp)
	j	.LBB22_82
.LBB22_101:                               # %label_101
	li	t1, 2
	mulw	t0, a3, t1
	sw	t0, 180(sp)
	li	t1, 10
	remw	t0, a3, t1
	sw	t0, 184(sp)
	lw	t0, 184(sp)
	xori	t0, t0, 5
	sltiu	t0, t0, 1
	sb	t0, 122(sp)
	lbu	t0, 122(sp)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	li	t1, 100
	mulw	t0, t0, t1
	sw	t0, 192(sp)
	lw	t0, 180(sp)
	lw	t1, 192(sp)
	addw	t0, t0, t1
	sw	t0, 80(sp)
	lw	t0, 80(sp)
	sw	t0, 136(sp)
	lw	t0, 136(sp)
	sw	t0, 20(sp)
	j	.LBB22_103
.LBB22_115:                               # %label_115
	li	t1, 10
	divw	t0, a3, t1
	sw	t0, 196(sp)
	lw	t0, 196(sp)
	li	t1, 7
	mulw	t0, t0, t1
	sw	t0, 200(sp)
	lw	t0, 200(sp)
	addiw	t0, t0, 23
	sw	t0, 84(sp)
	lw	t0, 84(sp)
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	sw	t0, 16(sp)
	j	.LBB22_117
.LBB22_125:                               # %label_125
	li	t1, 2
	remw	t0, a3, t1
	sw	t0, 204(sp)
	lw	t0, 204(sp)
	beq	t0, x0, .LBB22_130
.LBB22_131:                               # %label_131
	subw	t0, a1, a3
	sw	t0, 88(sp)
	lw	t0, 88(sp)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	sw	t0, 28(sp)
.LBB22_132:                               # %label_132
	lw	t0, 28(sp)
	sw	t0, 152(sp)
	lw	t0, 152(sp)
	sw	t0, 24(sp)
	j	.LBB22_127
.LBB22_130:                               # %label_130
	sw	a3, 144(sp)
	lw	t0, 144(sp)
	sw	t0, 28(sp)
	j	.LBB22_132
.LBB22_170:                               # %label_170
	addi	t5, a2, 12
	lw	t1, 0(sp)
	sw	t1, 0(t5)
	j	.LBB22_171
.Lfunc_end22:
	.size	fn.14, .Lfunc_end22-fn.14
                                        # -- End function
	.globl	fn.15                            # -- Begin function fn.15
	.p2align	1
	.type	fn.15,@function
fn.15:                                   # @fn.15
# %bb.0:                                # %alloca
	addi	sp, sp, -352
	sd	s0, 256(sp)
	sd	s2, 264(sp)
	sd	s3, 272(sp)
	sd	s4, 280(sp)
	sd	s5, 288(sp)
	sd	s6, 296(sp)
	sd	s7, 304(sp)
	sd	s8, 312(sp)
	sd	s9, 320(sp)
	sd	s10, 328(sp)
	sd	s11, 336(sp)
.LBB23_0:                               # %label_0
	mv	a3, a2
	mv	s4, a2
	lw	s4, 0(s4)
	addiw	t0, s4, 1
	sw	t0, 160(sp)
	lw	t1, 160(sp)
	sw	t1, 0(a3)
	li	s7, 0
	li	a3, 0
.LBB23_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 156(sp)
	mv	t0, s7
	lw	t1, 156(sp)
	bge	t0, t1, .LBB23_15
.LBB23_14:                               # %label_14
	li	s6, 0
	li	s4, 0
.LBB23_22:                               # %label_22
	subw	t0, a1, s7
	sw	t0, 92(sp)
	lw	t0, 92(sp)
	addiw	t0, t0, -1
	sw	t0, 96(sp)
	mv	t0, s6
	lw	t1, 96(sp)
	bge	t0, t1, .LBB23_24
.LBB23_23:                               # %label_23
	addi	t0, a2, 12
	sd	t0, 0(sp)
	addi	t0, a2, 12
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 100(sp)
	lw	t0, 100(sp)
	addiw	t0, t0, 1
	sw	t0, 104(sp)
	ld	t0, 0(sp)
	lw	t1, 104(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 16(sp)
	addi	t0, a2, 4
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 108(sp)
	lw	t0, 108(sp)
	addiw	t0, t0, 2
	sw	t0, 112(sp)
	ld	t0, 16(sp)
	lw	t1, 112(sp)
	sw	t1, 0(t0)
	mv	t0, s6
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 116(sp)
	addiw	t0, s6, 1
	sw	t0, 120(sp)
	lw	t0, 120(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 124(sp)
	mv	s5, s4
	mv	s3, a3
	lw	t0, 116(sp)
	lw	t1, 124(sp)
	blt	t1, t0, .LBB23_43
.LBB23_44:                               # %label_44
	addiw	a7, s6, 1
	mv	s6, a7
	mv	s4, s5
	mv	a3, s3
	j	.LBB23_22
.LBB23_15:                               # %label_15
	addi	a4, a2, 16
	addi	s8, a2, 16
	lw	s9, 0(s8)
	mulw	s8, a1, a1
	addw	t0, s9, s8
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(a4)
	ld	s0, 256(sp)
	ld	s2, 264(sp)
	ld	s3, 272(sp)
	ld	s4, 280(sp)
	ld	s5, 288(sp)
	ld	s6, 296(sp)
	ld	s7, 304(sp)
	ld	s8, 312(sp)
	ld	s9, 320(sp)
	ld	s10, 328(sp)
	ld	s11, 336(sp)
	li	a0, 0
	addi	sp, sp, 352
	ret
.LBB23_24:                               # %label_24
	li	t0, 1
	subw	a6, t0, s4
	mv	t0, a6
	bnez	t0, .LBB23_15
.LBB23_88:                               # %label_88
	addiw	a5, s7, 1
	mv	s7, a5
	j	.LBB23_13
.LBB23_43:                               # %label_43
	mv	t0, s6
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 48(sp)
	mv	t0, s6
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 64(sp)
	addiw	t0, s6, 1
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 132(sp)
	ld	t0, 64(sp)
	lw	t1, 132(sp)
	sw	t1, 0(t0)
	addiw	t0, s6, 1
	sw	t0, 136(sp)
	lw	t0, 136(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 80(sp)
	ld	t0, 80(sp)
	lw	t1, 48(sp)
	sw	t1, 0(t0)
	addi	s11, a2, 8
	addi	s10, a2, 8
	lw	s2, 0(s10)
	addiw	t0, s2, 1
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(s11)
	addi	s0, a2, 4
	addi	t5, a2, 4
	lw	t4, 0(t5)
	addiw	t0, t4, 4
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(s0)
	li	s5, 1
	lw	t0, 48(sp)
	mv	s3, t0
	j	.LBB23_44
.Lfunc_end23:
	.size	fn.15, .Lfunc_end23-fn.15
                                        # -- End function
	.globl	fn.16                            # -- Begin function fn.16
	.p2align	1
	.type	fn.16,@function
fn.16:                                   # @fn.16
# %bb.0:                                # %alloca
	addi	sp, sp, -112
	sd	s0, 96(sp)
.LBB24_0:                               # %label_0
	li	a4, 0
	li	a3, 0
.LBB24_8:                               # %label_8
	mv	t0, a3
	mv	t1, a1
	bge	t0, t1, .LBB24_10
.LBB24_9:                               # %label_9
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t5, 0(s0)
	subw	t4, t5, a2
	mulw	t3, t4, t4
	addw	a6, a4, t3
	addiw	a5, a3, 1
	mv	a4, a6
	mv	a3, a5
	j	.LBB24_8
.LBB24_10:                               # %label_10
	divw	t0, a4, a1
	sw	t0, 4(sp)
	lw	a0, 4(sp)
	ld	s0, 96(sp)
	addi	sp, sp, 112
	ret
.Lfunc_end24:
	.size	fn.16, .Lfunc_end24-fn.16
                                        # -- End function
	.globl	fn.17                            # -- Begin function fn.17
	.p2align	1
	.type	fn.17,@function
fn.17:                                   # @fn.17
# %bb.0:                                # %alloca
	addi	sp, sp, -320
	sd	s0, 240(sp)
	sd	s2, 248(sp)
	sd	s4, 256(sp)
	sd	s5, 264(sp)
	sd	s6, 272(sp)
	sd	s7, 280(sp)
	sd	s9, 288(sp)
	sd	s10, 296(sp)
	sd	s11, 304(sp)
.LBB25_0:                               # %label_0
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a6, 0(a4)
	addiw	a4, a1, -1
	addi	a5, a3, 4
	addi	s7, a3, 4
	lw	s7, 0(s7)
	addiw	t0, s7, 1
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(a5)
	li	a5, 0
	mv	t3, a1
.LBB25_24:                               # %label_24
	mv	t0, t3
	mv	t1, a2
	bge	t0, t1, .LBB25_26
.LBB25_25:                               # %label_25
	addi	t0, a3, 12
	sd	t0, 8(sp)
	addi	t0, a3, 12
	sd	t0, 16(sp)
	ld	t0, 16(sp)
	lw	t0, 0(t0)
	sw	t0, 88(sp)
	lw	t0, 88(sp)
	addiw	t0, t0, 1
	sw	t0, 92(sp)
	ld	t0, 8(sp)
	lw	t1, 92(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 24(sp)
	addi	t0, a3, 4
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	addiw	t0, t0, 1
	sw	t0, 100(sp)
	ld	t0, 24(sp)
	lw	t1, 100(sp)
	sw	t1, 0(t0)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 104(sp)
	mv	t4, a4
	mv	a7, a5
	lw	t0, 104(sp)
	mv	t1, a6
	bge	t1, t0, .LBB25_42
.LBB25_43:                               # %label_43
	addiw	s2, t3, 1
	mv	t3, s2
	mv	a4, t4
	mv	a5, a7
	j	.LBB25_24
.LBB25_26:                               # %label_26
	addiw	t5, a4, 1
	mv	t0, t5
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t0, 0(t5)
	sw	t0, 120(sp)
	addiw	t5, a4, 1
	mv	t0, t5
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t0, 0(t5)
	sw	t0, 124(sp)
	lw	t1, 124(sp)
	sw	t1, 0(s0)
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t1, 120(sp)
	sw	t1, 0(t5)
	addi	t5, a3, 8
	addi	s0, a3, 8
	lw	s0, 0(s0)
	addiw	t0, s0, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(t5)
	addi	t5, a3, 4
	addi	s0, a3, 4
	lw	s0, 0(s0)
	addiw	t0, s0, 4
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(t5)
	addiw	t0, a4, 1
	sw	t0, 84(sp)
	lw	a0, 84(sp)
	ld	s0, 240(sp)
	ld	s2, 248(sp)
	ld	s4, 256(sp)
	ld	s5, 264(sp)
	ld	s6, 272(sp)
	ld	s7, 280(sp)
	ld	s9, 288(sp)
	ld	s10, 296(sp)
	ld	s11, 304(sp)
	addi	sp, sp, 320
	ret
.LBB25_42:                               # %label_42
	addiw	t0, a4, 1
	sw	t0, 0(sp)
	lw	t0, 0(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 48(sp)
	ld	t0, 48(sp)
	lw	t0, 0(t0)
	sw	t0, 4(sp)
	lw	t0, 0(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 64(sp)
	ld	t0, 64(sp)
	lw	t0, 0(t0)
	sw	t0, 108(sp)
	ld	t0, 56(sp)
	lw	t1, 108(sp)
	sw	t1, 0(t0)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t1, 4(sp)
	sw	t1, 0(t0)
	addi	s11, a3, 8
	addi	s10, a3, 8
	lw	s9, 0(s10)
	addiw	t0, s9, 1
	sw	t0, 112(sp)
	lw	t1, 112(sp)
	sw	t1, 0(s11)
	addi	s6, a3, 4
	addi	s5, a3, 4
	lw	s4, 0(s5)
	addiw	t0, s4, 4
	sw	t0, 116(sp)
	lw	t1, 116(sp)
	sw	t1, 0(s6)
	lw	t0, 0(sp)
	mv	t4, t0
	lw	t0, 4(sp)
	mv	a7, t0
	j	.LBB25_43
.Lfunc_end25:
	.size	fn.17, .Lfunc_end25-fn.17
                                        # -- End function
	.globl	fn.18                            # -- Begin function fn.18
	.p2align	1
	.type	fn.18,@function
fn.18:                                   # @fn.18
# %bb.0:                                # %alloca
	addi	sp, sp, -320
	sd	s0, 240(sp)
	sd	s1, 248(sp)
	sd	s2, 256(sp)
	sd	s3, 264(sp)
	sd	s4, 272(sp)
	sd	s5, 280(sp)
	sd	s7, 288(sp)
	sd	s8, 296(sp)
	sd	s9, 304(sp)
	sd	s10, 312(sp)
.LBB26_0:                               # %label_0
	mv	a3, a2
	mv	s10, a2
	lw	s10, 0(s10)
	addiw	t0, s10, 1
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(a3)
	li	a5, 1
.LBB26_13:                               # %label_13
	mv	t0, a5
	mv	t1, a1
	bge	t0, t1, .LBB26_15
.LBB26_14:                               # %label_14
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 96(sp)
	ld	t0, 96(sp)
	lw	t0, 0(t0)
	sw	t0, 56(sp)
	addiw	t0, a5, -1
	sw	t0, 128(sp)
	addi	t0, a2, 4
	sd	t0, 104(sp)
	addi	t0, a2, 4
	sd	t0, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 132(sp)
	lw	t0, 132(sp)
	addiw	t0, t0, 1
	sw	t0, 136(sp)
	ld	t0, 104(sp)
	lw	t1, 136(sp)
	sw	t1, 0(t0)
	lw	t0, 128(sp)
	mv	a4, t0
.LBB26_33:                               # %label_33
	mv	t0, a4
	bge	t0, x0, .LBB26_36
.LBB26_35:                               # %label_35
	addiw	s3, a4, 1
	mv	t0, s3
	li	t1, 4
	mul	t0, t0, t1
	add	s4, a0, t0
	lw	t1, 56(sp)
	sw	t1, 0(s4)
	addi	s2, a2, 4
	addi	s1, a2, 4
	lw	s0, 0(s1)
	addiw	t0, s0, 1
	sw	t0, 88(sp)
	lw	t1, 88(sp)
	sw	t1, 0(s2)
	addiw	t4, a5, 1
	mv	a5, t4
	j	.LBB26_13
.LBB26_15:                               # %label_15
	addi	t3, a2, 16
	addi	a6, a2, 16
	lw	a7, 0(a6)
	mulw	a6, a1, a1
	addw	t0, a7, a6
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(t3)
	ld	s0, 240(sp)
	ld	s1, 248(sp)
	ld	s2, 256(sp)
	ld	s3, 264(sp)
	ld	s4, 272(sp)
	ld	s5, 280(sp)
	ld	s7, 288(sp)
	ld	s8, 296(sp)
	ld	s9, 304(sp)
	ld	s10, 312(sp)
	li	a0, 0
	addi	sp, sp, 320
	ret
.LBB26_34:                               # %label_34
	addi	t0, a2, 12
	sd	t0, 0(sp)
	addi	t0, a2, 12
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 60(sp)
	lw	t0, 60(sp)
	addiw	t0, t0, 1
	sw	t0, 64(sp)
	ld	t0, 0(sp)
	lw	t1, 64(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 16(sp)
	addi	t0, a2, 4
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 68(sp)
	lw	t0, 68(sp)
	addiw	t0, t0, 2
	sw	t0, 72(sp)
	ld	t0, 16(sp)
	lw	t1, 72(sp)
	sw	t1, 0(t0)
	addiw	t0, a4, 1
	sw	t0, 76(sp)
	lw	t0, 76(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 32(sp)
	mv	t0, a4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	ld	t0, 32(sp)
	lw	t1, 80(sp)
	sw	t1, 0(t0)
	addi	s9, a2, 4
	addi	s8, a2, 4
	lw	s7, 0(s8)
	addiw	t0, s7, 2
	sw	t0, 84(sp)
	lw	t1, 84(sp)
	sw	t1, 0(s9)
	addiw	s5, a4, -1
	mv	a4, s5
	j	.LBB26_33
.LBB26_36:                               # %label_36
	mv	t0, a4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 48(sp)
	ld	t0, 48(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	lw	t0, 120(sp)
	lw	t1, 56(sp)
	blt	t1, t0, .LBB26_34
	j	.LBB26_35
.Lfunc_end26:
	.size	fn.18, .Lfunc_end26-fn.18
                                        # -- End function
	.globl	fn.19                            # -- Begin function fn.19
	.p2align	1
	.type	fn.19,@function
fn.19:                                   # @fn.19
# %bb.0:                                # %alloca
	addi	sp, sp, -240
	sd	s0, 216(sp)
	sd	s1, 224(sp)
	sd	s2, 232(sp)
.LBB27_0:                               # %label_0
	mv	s2, a3
	mv	a7, a3
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(s2)
	mv	t0, a1
	mv	t1, a2
	bge	t0, t1, .LBB27_15
.LBB27_14:                               # %label_14
	subw	a5, a2, a1
	li	t1, 2
	divw	a5, a5, t1
	addw	a6, a1, a5
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	sd	a6, 200(sp)
	mv	a2, a6
	call	fn.19
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	ld	a6, 200(sp)
	addiw	a5, a6, 1
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	sd	a5, 192(sp)
	sd	a6, 200(sp)
	mv	a1, a5
	call	fn.19
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	ld	a5, 192(sp)
	ld	a6, 200(sp)
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	sd	a6, 200(sp)
	mv	a2, a6
	ld	a3, 168(sp)
	ld	a4, 176(sp)
	call	fn.22
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	ld	a6, 200(sp)
.LBB27_15:                               # %label_15
	addi	a4, a3, 16
	addi	s0, a3, 16
	lw	s1, 0(s0)
	subw	s0, a2, a1
	addiw	s0, s0, 1
	addw	t0, s1, s0
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(a4)
	ld	s0, 216(sp)
	ld	s1, 224(sp)
	ld	s2, 232(sp)
	li	a0, 0
	addi	sp, sp, 240
	ret
.Lfunc_end27:
	.size	fn.19, .Lfunc_end27-fn.19
                                        # -- End function
	.globl	fn.20                            # -- Begin function fn.20
	.p2align	1
	.type	fn.20,@function
fn.20:                                   # @fn.20
# %bb.0:                                # %alloca
	addi	sp, sp, -240
	sd	s0, 216(sp)
	sd	s1, 224(sp)
	sd	s2, 232(sp)
.LBB28_0:                               # %label_0
	mv	s2, a3
	mv	a7, a3
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(s2)
	mv	t0, a1
	mv	t1, a2
	bge	t0, t1, .LBB28_15
.LBB28_14:                               # %label_14
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	call	fn.17
	mv	a6, a0
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	addiw	a5, a6, -1
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	sd	a5, 192(sp)
	sd	a6, 200(sp)
	mv	a2, a5
	call	fn.20
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	ld	a5, 192(sp)
	ld	a6, 200(sp)
	addiw	a5, a6, 1
	sd	ra, 144(sp)
	sd	a0, 152(sp)
	sd	a1, 160(sp)
	sd	a2, 168(sp)
	sd	a3, 176(sp)
	sd	a5, 192(sp)
	mv	a1, a5
	call	fn.20
	ld	ra, 144(sp)
	ld	a0, 152(sp)
	ld	a1, 160(sp)
	ld	a2, 168(sp)
	ld	a3, 176(sp)
	ld	a5, 192(sp)
.LBB28_15:                               # %label_15
	addi	a4, a3, 16
	addi	s0, a3, 16
	lw	s1, 0(s0)
	subw	s0, a2, a1
	addiw	s0, s0, 1
	addw	t0, s1, s0
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(a4)
	ld	s0, 216(sp)
	ld	s1, 224(sp)
	ld	s2, 232(sp)
	li	a0, 0
	addi	sp, sp, 240
	ret
.Lfunc_end28:
	.size	fn.20, .Lfunc_end28-fn.20
                                        # -- End function
	.globl	fn.21                            # -- Begin function fn.21
	.p2align	1
	.type	fn.21,@function
fn.21:                                   # @fn.21
# %bb.0:                                # %alloca
	addi	sp, sp, -176
	sd	s0, 168(sp)
.LBB29_0:                               # %label_0
	mv	t0, a1
	li	t1, 1
	bge	t1, t0, .LBB29_7
.LBB29_6:                               # %label_6
	addiw	s0, a1, -1
	sd	ra, 136(sp)
	sd	a0, 144(sp)
	sd	a2, 160(sp)
	li	a1, 0
	mv	a2, s0
	ld	a3, 160(sp)
	call	fn.20
	ld	ra, 136(sp)
	ld	a0, 144(sp)
	ld	a2, 160(sp)
.LBB29_7:                               # %label_7
	ld	s0, 168(sp)
	li	a0, 0
	addi	sp, sp, 176
	ret
.Lfunc_end29:
	.size	fn.21, .Lfunc_end29-fn.21
                                        # -- End function
	.globl	fn.22                            # -- Begin function fn.22
	.p2align	1
	.type	fn.22,@function
fn.22:                                   # @fn.22
# %bb.0:                                # %alloca
	addi	sp, sp, -496
	sd	s0, 424(sp)
	sd	s1, 432(sp)
	sd	s3, 440(sp)
	sd	s4, 448(sp)
	sd	s5, 456(sp)
	sd	s7, 464(sp)
	sd	s8, 472(sp)
	sd	s10, 480(sp)
	sd	s11, 488(sp)
.LBB30_0:                               # %label_0
	subw	s11, a2, a1
	addiw	t0, s11, 1
	sw	t0, 60(sp)
	subw	t0, a3, a2
	sw	t0, 52(sp)
	lw	t1, 60(sp)
	li	t0, 10000
	subw	s11, t0, t1
	li	a7, 0
.LBB30_26:                               # %label_26
	mv	t0, a7
	lw	t1, 60(sp)
	bge	t0, t1, .LBB30_28
.LBB30_27:                               # %label_27
	addw	t0, s11, a7
	sw	t0, 252(sp)
	lw	t0, 252(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 64(sp)
	addw	t0, a1, a7
	sw	t0, 256(sp)
	lw	t0, 256(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 260(sp)
	ld	t0, 64(sp)
	lw	t1, 260(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 80(sp)
	addi	t0, a4, 4
	sd	t0, 88(sp)
	ld	t0, 88(sp)
	lw	s10, 0(t0)
	addiw	t0, s10, 2
	sw	t0, 264(sp)
	ld	t0, 80(sp)
	lw	t1, 264(sp)
	sw	t1, 0(t0)
	addiw	s8, a7, 1
	mv	a7, s8
	j	.LBB30_26
.LBB30_28:                               # %label_28
	li	t3, 0
	li	s8, 0
	mv	a7, a1
.LBB30_52:                               # %label_52
	mv	t0, t3
	lw	t1, 60(sp)
	blt	t0, t1, .LBB30_55
.LBB30_54:                               # %label_54
	mv	t5, t3
	mv	a5, a7
.LBB30_122:                               # %label_122
	mv	t0, t5
	lw	t1, 60(sp)
	bge	t0, t1, .LBB30_124
.LBB30_123:                               # %label_123
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 144(sp)
	addw	t0, s11, t5
	sw	t0, 296(sp)
	lw	t0, 296(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	ld	t0, 144(sp)
	lw	t1, 300(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 160(sp)
	addi	t0, a4, 4
	sd	t0, 168(sp)
	ld	t0, 168(sp)
	lw	t0, 0(t0)
	sw	t0, 304(sp)
	lw	t0, 304(sp)
	addiw	t0, t0, 2
	sw	t0, 308(sp)
	ld	t0, 160(sp)
	lw	t1, 308(sp)
	sw	t1, 0(t0)
	addiw	t0, t5, 1
	sw	t0, 244(sp)
	addiw	t0, a5, 1
	sw	t0, 248(sp)
	lw	t0, 244(sp)
	mv	t5, t0
	lw	t0, 248(sp)
	mv	a5, t0
	j	.LBB30_122
.LBB30_53:                               # %label_53
	addi	t0, a4, 12
	sd	t0, 0(sp)
	addi	t0, a4, 12
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 192(sp)
	lw	t0, 192(sp)
	addiw	t0, t0, 1
	sw	t0, 196(sp)
	ld	t0, 0(sp)
	lw	t1, 196(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 16(sp)
	addi	t0, a4, 4
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 200(sp)
	lw	t0, 200(sp)
	addiw	t0, t0, 2
	sw	t0, 204(sp)
	ld	t0, 16(sp)
	lw	t1, 204(sp)
	sw	t1, 0(t0)
	addw	t0, s11, t3
	sw	t0, 208(sp)
	lw	t0, 208(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	addiw	t0, a2, 1
	sw	t0, 216(sp)
	lw	t0, 216(sp)
	addw	t0, t0, s8
	sw	t0, 220(sp)
	lw	t0, 220(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 224(sp)
	lw	t0, 212(sp)
	lw	t1, 224(sp)
	bge	t1, t0, .LBB30_74
.LBB30_75:                               # %label_75
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 112(sp)
	addiw	t0, a2, 1
	sw	t0, 276(sp)
	lw	t0, 276(sp)
	addw	t0, t0, s8
	sw	t0, 280(sp)
	lw	t0, 280(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 120(sp)
	ld	t0, 120(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	ld	t0, 112(sp)
	lw	t1, 284(sp)
	sw	t1, 0(t0)
	addiw	t0, s8, 1
	sw	t0, 236(sp)
	lw	t0, 236(sp)
	mv	a5, t0
	mv	t4, t3
.LBB30_76:                               # %label_76
	addi	t0, a4, 4
	sd	t0, 128(sp)
	addi	t0, a4, 4
	sd	t0, 136(sp)
	ld	t0, 136(sp)
	lw	t0, 0(t0)
	sw	t0, 288(sp)
	lw	t0, 288(sp)
	addiw	t0, t0, 1
	sw	t0, 292(sp)
	ld	t0, 128(sp)
	lw	t1, 292(sp)
	sw	t1, 0(t0)
	addiw	t0, a7, 1
	sw	t0, 240(sp)
	lw	t0, 240(sp)
	mv	a7, t0
	mv	t3, t4
	mv	s8, a5
	j	.LBB30_52
.LBB30_55:                               # %label_55
	mv	t0, s8
	lw	t1, 52(sp)
	blt	t0, t1, .LBB30_53
	j	.LBB30_54
.LBB30_74:                               # %label_74
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 96(sp)
	addw	t0, s11, t3
	sw	t0, 268(sp)
	lw	t0, 268(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 104(sp)
	ld	t0, 104(sp)
	lw	t0, 0(t0)
	sw	t0, 272(sp)
	ld	t0, 96(sp)
	lw	t1, 272(sp)
	sw	t1, 0(t0)
	addiw	t0, t3, 1
	sw	t0, 232(sp)
	lw	t0, 232(sp)
	mv	t4, t0
	mv	a5, s8
	j	.LBB30_76
.LBB30_124:                               # %label_124
	mv	a6, s8
.LBB30_147:                               # %label_147
	mv	t0, a6
	lw	t1, 52(sp)
	bge	t0, t1, .LBB30_149
.LBB30_148:                               # %label_148
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 176(sp)
	addiw	t0, a2, 1
	sw	t0, 312(sp)
	lw	t0, 312(sp)
	addw	s7, t0, a6
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 184(sp)
	ld	t0, 184(sp)
	lw	t0, 0(t0)
	sw	t0, 316(sp)
	ld	t0, 176(sp)
	lw	t1, 316(sp)
	sw	t1, 0(t0)
	addi	s5, a4, 4
	addi	s4, a4, 4
	lw	s3, 0(s4)
	addiw	t0, s3, 2
	sw	t0, 320(sp)
	lw	t1, 320(sp)
	sw	t1, 0(s5)
	addiw	s1, a6, 1
	addiw	s0, a5, 1
	mv	a6, s1
	mv	a5, s0
	j	.LBB30_147
.LBB30_149:                               # %label_149
	ld	s0, 424(sp)
	ld	s1, 432(sp)
	ld	s3, 440(sp)
	ld	s4, 448(sp)
	ld	s5, 456(sp)
	ld	s7, 464(sp)
	ld	s8, 472(sp)
	ld	s10, 480(sp)
	ld	s11, 488(sp)
	li	a0, 0
	addi	sp, sp, 496
	ret
.Lfunc_end30:
	.size	fn.22, .Lfunc_end30-fn.22
                                        # -- End function

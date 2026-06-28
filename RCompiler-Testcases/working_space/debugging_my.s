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
	li	t6, -482048
	add	sp, sp, t6
	li	t6, 481944
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 481952
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 481960
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 481968
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 481976
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 481984
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 481992
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 482000
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 482008
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 482016
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 482024
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 482032
	add	t6, sp, t6
	sd	s11, 0(t6)
	addi	t6, sp, 128
	sd	t6, 144(sp)
	addi	t6, sp, 184
	li	t0, 40208
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40216
	add	t6, t6, sp
	li	t0, 80216
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80236
	add	t6, t6, sp
	li	t0, 80256
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80284
	add	t6, t6, sp
	li	t0, 80304
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80316
	add	t6, t6, sp
	li	t0, 80336
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80352
	add	t6, t6, sp
	li	t0, 120376
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 120384
	add	t6, t6, sp
	li	t0, 160384
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160396
	add	t6, t6, sp
	li	t0, 160416
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160444
	add	t6, t6, sp
	li	t0, 160464
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160484
	add	t6, t6, sp
	li	t0, 160504
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160560
	add	t6, t6, sp
	li	t0, 200584
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 200592
	add	t6, t6, sp
	li	t0, 240592
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 240600
	add	t6, t6, sp
	li	t0, 280608
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 280616
	add	t6, t6, sp
	li	t0, 320624
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320632
	add	t6, t6, sp
	li	t0, 360640
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 360648
	add	t6, t6, sp
	li	t0, 361048
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 361156
	add	t6, t6, sp
	li	t0, 361176
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 361384
	add	t6, t6, sp
	li	t0, 401384
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 401412
	add	t6, t6, sp
	li	t0, 401432
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 401456
	add	t6, t6, sp
	li	t0, 441456
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 441492
	add	t6, t6, sp
	li	t0, 441512
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 441520
	add	t6, t6, sp
	li	t0, 481520
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 481532
	add	t6, t6, sp
	li	t0, 481552
	add	t0, sp, t0
	sd	t6, 0(t0)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	a0, 21001
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	ld	t0, 144(sp)
	mv	s1, t0
	li	t1, 100
	sw	t1, 0(s1)
	ld	t0, 144(sp)
	addi	s1, t0, 4
	li	t1, 500
	sw	t1, 0(s1)
	ld	t0, 144(sp)
	addi	s1, t0, 8
	li	t1, 1000
	sw	t1, 0(s1)
	ld	t0, 144(sp)
	addi	s1, t0, 12
	li	t1, 2000
	sw	t1, 0(s1)
	li	a0, 0
	li	t0, 0
	li	t6, 481568
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481584
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481600
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481616
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481632
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481648
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481664
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481680
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481696
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481712
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481728
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481744
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481760
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481776
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 481792
	add	t6, sp, t6
	sd	t0, 0(t6)
.LBB8_6:                               # %label_6
	mv	t0, a0
	li	t1, 4
	bge	t0, t1, .LBB8_8
.LBB8_7:                               # %label_7
	mv	t0, a0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 144(sp)
	add	t2, t1, t0
	sd	t2, 160(sp)
	ld	t0, 160(sp)
	lw	s1, 0(t0)
	li	t1, 100
	mulw	t0, a0, t1
	sw	t0, 168(sp)
	lw	t1, 168(sp)
	li	t6, 21000
	addw	t0, t1, t6
	sw	t0, 172(sp)
	lw	t0, 172(sp)
	addiw	t0, t0, 10
	sw	t0, 176(sp)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	lw	a0, 176(sp)
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	s0, 0
	li	t6, 481568
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481560
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481584
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481576
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481600
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481592
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481616
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481608
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481632
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481624
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481648
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481640
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481664
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481656
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481680
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481672
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481696
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481688
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481712
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481704
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481728
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481720
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481744
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481736
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481760
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481752
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481776
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481768
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481792
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481784
	add	t6, sp, t6
	sd	t0, 0(t6)
	j	.LBB8_20
.LBB8_8:                               # %label_8
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	a0, 0
	li	a1, 5000
	li	t6, 120376
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 160384
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a1, t0, 24
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	mv	a0, a1
	li	t6, 160384
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 5000
	call	fn.2
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 160416
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 160384
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 160416
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	a1, 0
	li	a0, 0
	li	s1, 0
	li	t0, 0
	li	t6, 481820
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_121
.LBB8_20:                               # %label_20
	mv	t0, s0
	li	t1, 8
	bge	t0, t1, .LBB8_22
.LBB8_21:                               # %label_21
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	mv	a0, s0
	mv	a1, s1
	li	t6, 40208
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 40208
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 80224
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80224
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a1, 0(t6)
	mv	a2, s1
	call	fn.2
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80256
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	li	t6, 80256
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.15
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	call	fn.1
	li	t6, 80264
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 80264
	add	t6, sp, t6
	lbu	t1, 0(t6)
	li	t0, 1
	subw	t0, t0, t1
	li	t6, 80265
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 80265
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB8_21_jump_0
	j	.LBB8_43
.LBB8_21_jump_0:                               # %label_21_jump_0
	j	.LBB8_44
.LBB8_22:                               # %label_22
	addiw	a7, a0, 1
	mv	a0, a7
	li	t6, 481560
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481568
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481576
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481584
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481592
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481600
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481608
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481616
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481624
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481632
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481640
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481648
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481656
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481664
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481672
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481680
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481688
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481696
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481704
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481712
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481720
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481728
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481736
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481744
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481752
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481760
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481768
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481776
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481784
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481792
	add	t6, sp, t6
	sd	t0, 0(t6)
	j	.LBB8_6
.LBB8_43:                               # %label_43
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	a0, 21901
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
.LBB8_44:                               # %label_44
	li	t6, 40208
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 80272
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80272
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a1, 0(t6)
	mv	a2, s1
	call	fn.2
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80304
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	li	t6, 80304
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	call	fn.1
	li	t6, 80312
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 80312
	add	t6, sp, t6
	lbu	t1, 0(t6)
	li	t0, 1
	subw	t5, t0, t1
	mv	t0, t5
	beqz	t0, .LBB8_64
.LBB8_63:                               # %label_63
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	a0, 21902
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
.LBB8_64:                               # %label_64
	li	t6, 40208
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t4, t0, 24
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	mv	a0, t4
	li	t6, 80216
	add	t6, sp, t6
	ld	a1, 0(t6)
	mv	a2, s1
	call	fn.2
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 80336
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	li	t6, 80336
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	a0, 0(t6)
	mv	a1, s1
	call	fn.1
	mv	t3, a0
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t0, 1
	subw	s11, t0, t3
	mv	t0, s11
	beqz	t0, .LBB8_84
.LBB8_83:                               # %label_83
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	a0, 21903
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
.LBB8_84:                               # %label_84
	li	t6, 80256
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s10, t0, 12
	lw	s9, 0(s10)
	li	t1, 100
	divw	s8, s9, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	mv	a0, s8
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 80304
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s7, t0, 12
	lw	s6, 0(s7)
	li	t1, 100
	divw	s5, s6, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	mv	a0, s5
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 80336
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s4, t0, 12
	lw	s3, 0(s4)
	li	t1, 100
	divw	s2, s3, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	sd	t4, 0(t6)
	mv	a0, s2
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 481928
	add	t6, sp, t6
	ld	t4, 0(t6)
	addiw	t0, s0, 1
	li	t6, 80344
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481784
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481752
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481736
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481704
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481672
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481656
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481624
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481592
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481576
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80224
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481560
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80256
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481608
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80272
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481640
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80304
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481688
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481720
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 80336
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 481768
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 80344
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s0, t0
	j	.LBB8_20
.LBB8_121:                               # %label_121
	li	t2, 481820
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 1000
	bge	t0, t1, .LBB8_123
.LBB8_122:                               # %label_122
	li	t6, 481820
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 73
	mulw	t0, t0, t1
	li	t6, 160428
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160428
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 29
	li	t6, 160432
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160432
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100000
	remw	t0, t0, t1
	li	t6, 160436
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 160464
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 160472
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 160472
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 160436
	add	t6, sp, t6
	lw	a2, 0(t6)
	li	t6, 160464
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.5
	li	t6, 160480
	add	t6, sp, t6
	sw	a0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 160504
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 160384
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 160436
	add	t6, sp, t6
	lw	a2, 0(t6)
	li	t6, 160504
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.6
	mv	s0, a0
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 481800
	add	t6, sp, t6
	sw	a1, 0(t6)
	li	t2, 160480
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, -1
	bne	t0, t1, .LBB8_152
	j	.LBB8_151
.LBB8_123:                               # %label_123
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	sd	a1, 0(t6)
	mv	a0, a1
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481864
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t1, 1000
	divw	a4, a0, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	mv	a0, a4
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t1, 1000
	divw	a4, s1, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	mv	a0, a4
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	a0, 1
	li	a1, 300
	li	t6, 200584
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 200584
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a5, t0, 24
	li	t6, 200584
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a4, t0
	lw	a4, 0(a4)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	sd	a5, 0(t6)
	mv	a0, a5
	li	a1, 300
	mv	a2, a4
	call	fn.16
	mv	a6, a0
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 240592
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 200584
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a4, t0, 24
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	sd	a6, 0(t6)
	mv	a0, a4
	li	t6, 240592
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 300
	call	fn.2
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 240592
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 300
	call	fn.4
	mv	a5, a0
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 200584
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a4, t0
	lw	a4, 0(a4)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	sd	a6, 0(t6)
	mv	a0, a4
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 481904
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t1, 1000
	divw	a4, a6, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	sd	a5, 0(t6)
	mv	a0, a4
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481888
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	sd	a5, 0(t6)
	mv	a0, a5
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481896
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	a0, 50
	li	a1, 50
	li	a2, 1
	li	t6, 280608
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	a0, 50
	li	a1, 50
	li	a2, 2
	li	t6, 320624
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 360640
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s0, t0, 8
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 361048
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t0, 0
	li	t6, 481824
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_206
.LBB8_150:                               # %label_150
	addiw	t0, a1, 1
	li	t6, 160516
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160516
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481800
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB8_151:                               # %label_151
	li	t6, 160464
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	li	t6, 160520
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160520
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 160528
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160528
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, a0, t1
	li	t6, 160532
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160504
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	li	t6, 160536
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160536
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 160544
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160544
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s1, t1
	li	t6, 160548
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481820
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 160552
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160532
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	a0, t0
	li	t6, 160548
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s1, t0
	li	t6, 160552
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481820
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481800
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	a1, t0
	j	.LBB8_121
.LBB8_152:                               # %label_152
	li	t6, 481800
	add	t6, sp, t6
	sw	a1, 0(t6)
	mv	t0, s0
	li	t1, -1
	bne	t0, t1, .LBB8_150
	j	.LBB8_151
.LBB8_206:                               # %label_206
	li	t2, 481824
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 100
	bgeu	t0, t1, .LBB8_208
.LBB8_207:                               # %label_207
	li	t6, 481824
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 400
	mul	t0, t0, t1
	add	t2, s0, t0
	li	t6, 361064
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 361064
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 361048
	add	t6, sp, t6
	ld	t1, 0(t6)
	mv	a0, t0
	mv	a1, t1
	li	a2, 400
	call	builtin_memcpy
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481824
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361072
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361072
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481824
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_206
.LBB8_208:                               # %label_208
	li	t6, 360640
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361080
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361080
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 360640
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 361088
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361088
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 280608
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 320624
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 360640
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.3
	li	t6, 361096
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t2, 361096
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_218
.LBB8_217:                               # %label_217
	li	s1, 0
	li	t0, 0
	li	t6, 481828
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s0, 0
	j	.LBB8_228
.LBB8_218:                               # %label_218
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t0, 0
	li	t6, 481816
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s0, 0
	j	.LBB8_257
.LBB8_228:                               # %label_228
	li	t2, 481828
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 50
	bge	t0, t1, .LBB8_230
.LBB8_229:                               # %label_229
	li	t0, 0
	li	t6, 481832
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_234
.LBB8_230:                               # %label_230
	li	t1, 1000000000
	remw	t0, s1, t1
	li	t6, 361148
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 361148
	add	t6, sp, t6
	lw	a0, 0(t6)
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	j	.LBB8_218
.LBB8_234:                               # %label_234
	li	t2, 481832
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 50
	bge	t0, t1, .LBB8_236
.LBB8_235:                               # %label_235
	li	t6, 360640
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 361104
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481828
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 361104
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 361112
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 481832
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 361112
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 361120
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 361120
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361128
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361128
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s1, t1
	li	t6, 361132
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361132
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 1000000000
	and	t0, t0, t6
	li	t6, 361136
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481832
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361140
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361136
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s1, t0
	li	t6, 361140
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481832
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_234
.LBB8_236:                               # %label_236
	li	t6, 481828
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361144
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361144
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481828
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481832
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s0, t0
	j	.LBB8_228
.LBB8_257:                               # %label_257
	li	t2, 481816
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 5000
	bge	t0, t1, .LBB8_259
.LBB8_258:                               # %label_258
	li	t6, 120376
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 361192
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 481816
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 361192
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 361200
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 361200
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361208
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361208
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s0, t1
	li	t6, 361212
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361216
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361224
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361224
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361232
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361232
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361236
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361216
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 361236
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 481816
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361240
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361212
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s0, t0
	li	t6, 361240
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481816
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_257
.LBB8_259:                               # %label_259
	li	t0, 0
	li	t6, 481812
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s1, 0
.LBB8_275:                               # %label_275
	li	t2, 481812
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 5000
	bge	t0, t1, .LBB8_277
.LBB8_276:                               # %label_276
	li	t6, 481812
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 11241
	mulw	t0, t0, t1
	li	t6, 361248
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361248
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 12345
	addw	t0, t0, t6
	li	t6, 361252
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361252
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5000
	remw	t0, t0, t1
	li	t6, 361256
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 361264
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361256
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 361264
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 361272
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 361272
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361280
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361280
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s1, t1
	li	t6, 361284
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361288
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361296
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361296
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361304
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361304
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361308
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361288
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 361308
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 481812
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361312
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361284
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s1, t0
	li	t6, 361312
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481812
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_275
.LBB8_277:                               # %label_277
	li	t0, 0
	li	t6, 481808
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	a0, 0
.LBB8_298:                               # %label_298
	li	t2, 481808
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 1000
	bge	t0, t1, .LBB8_300
.LBB8_299:                               # %label_299
	li	t6, 481808
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5
	mulw	t0, t0, t1
	li	t6, 361320
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361320
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5000
	remw	t0, t0, t1
	li	t6, 361324
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 361328
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361324
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 361328
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 361336
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 361336
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361344
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361344
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, a0, t1
	li	t6, 361348
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361352
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 361360
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 361360
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 361368
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361368
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361372
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361352
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 361372
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 481808
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 361376
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 361348
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	a0, t0
	li	t6, 361376
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481808
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_298
.LBB8_300:                               # %label_300
	li	t1, 1000
	divw	a3, s0, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	sd	a3, 0(t6)
	mv	a0, a3
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t1, 1000
	divw	a3, s1, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	sd	a3, 0(t6)
	mv	a0, a3
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481856
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t1, 100
	divw	a3, a0, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	sd	a3, 0(t6)
	mv	a0, a3
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 361176
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a3, t0, 4
	lw	a3, 0(a3)
	li	t1, 1000
	divw	a3, a3, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	sd	a3, 0(t6)
	mv	a0, a3
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481880
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t0, 0
	li	t6, 481836
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB8_330:                               # %label_330
	li	t2, 481836
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 10000
	bgeu	t0, t1, .LBB8_332
.LBB8_331:                               # %label_331
	li	t6, 481836
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 401384
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 401400
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 401400
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 42
	sw	t1, 0(t0)
	li	t6, 481836
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 401408
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 401408
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481836
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_330
.LBB8_332:                               # %label_332
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 401432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 401384
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 401432
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 401432
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	li	t6, 401440
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 401440
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 401448
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 401448
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100
	divw	t0, t0, t1
	li	t6, 401452
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 401452
	add	t6, sp, t6
	lw	a0, 0(t6)
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 441456
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t0, 0
	li	t6, 481804
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s1, 0
	li	s0, 0
.LBB8_349:                               # %label_349
	li	t2, 481804
	add	t2, t2, sp
	lw	t0, 0(t2)
	li	t1, 1000
	bge	t0, t1, .LBB8_351
.LBB8_350:                               # %label_350
	li	t6, 481804
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 441456
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t1, t0
	li	t6, 481804
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 2
	remw	t0, t0, t1
	li	t6, 441468
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t2, 441468
	add	t2, t2, sp
	lw	t0, 0(t2)
	beq	t0, x0, .LBB8_356
	j	.LBB8_357
.LBB8_351:                               # %label_351
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 441512
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 441456
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 441512
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 441512
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a2, t0, 12
	lw	a2, 0(a2)
	li	t1, 100
	divw	a2, a2, t1
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481872
	add	t6, sp, t6
	sd	a2, 0(t6)
	mv	a0, a2
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481872
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481520
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a0, t0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481520
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a2, t0
	li	t1, 123
	sw	t1, 0(a2)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481552
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481520
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1
	li	t6, 481552
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.13
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481520
	add	t6, sp, t6
	ld	t0, 0(t6)
	mv	a2, t0
	lw	a2, 0(a2)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 481872
	add	t6, sp, t6
	sd	a2, 0(t6)
	mv	a0, a2
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481872
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 481848
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	a0, 21999
	call	printlnInt
	li	t6, 481848
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 481944
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 481952
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 481960
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 481968
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 481976
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 481984
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 481992
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 482000
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 482008
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 482016
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 482024
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 482032
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 482048
	add	sp, sp, t6
	ret
.LBB8_356:                               # %label_356
	li	t0, 1
	li	t6, 441476
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t0, 1
	li	t6, 481840
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 441476
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 441484
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481844
	add	t6, sp, t6
	sw	s0, 0(t6)
	j	.LBB8_358
.LBB8_357:                               # %label_357
	li	t0, 2
	li	t6, 441480
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t0, 2
	li	t6, 481844
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 441480
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 441484
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481840
	add	t6, sp, t6
	sw	s1, 0(t6)
.LBB8_358:                               # %label_358
	li	t6, 441484
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(a0)
	li	t6, 481804
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 441488
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 441488
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 481804
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 481840
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s1, t0
	li	t6, 481844
	add	t6, sp, t6
	lw	t0, 0(t6)
	mv	s0, t0
	j	.LBB8_349
.Lfunc_end8:
	.size	fn.0, .Lfunc_end8-fn.0
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -96
	j	.LBB9_0
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
	j	.LBB9_13
.LBB9_7:                               # %label_7
	li	a0, 1
	addi	sp, sp, 96
	ret
.LBB9_12:                               # %label_12
	li	a0, 0
	addi	sp, sp, 96
	ret
.LBB9_13:                               # %label_13
	addiw	a3, a2, 1
	mv	a2, a3
	j	.LBB9_5
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.globl	fn.2                            # -- Begin function fn.2
	.p2align	1
	.type	fn.2,@function
fn.2:                                   # @fn.2
# %bb.0:                                # %alloca
	addi	sp, sp, -80
	j	.LBB10_0
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
	j	.LBB11_0
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
	sw	t0, 4(sp)
	lw	t1, 4(sp)
	sw	t1, 0(a3)
	mv	a3, a2
	mv	s9, a1
	lw	t0, 0(s9)
	sw	t0, 8(sp)
	lw	t1, 8(sp)
	sw	t1, 0(a3)
	li	t3, 0
	li	a3, 0
.LBB11_26:                               # %label_26
	addi	t0, a0, 4
	sd	t0, 16(sp)
	ld	t0, 16(sp)
	lw	t0, 0(t0)
	sw	t0, 24(sp)
	mv	t0, t3
	lw	t1, 24(sp)
	bge	t0, t1, .LBB11_28
.LBB11_27:                               # %label_27
	li	a7, 0
	j	.LBB11_35
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
.LBB11_35:                               # %label_35
	mv	t0, a1
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 40(sp)
	mv	t0, a7
	lw	t1, 40(sp)
	bge	t0, t1, .LBB11_37
.LBB11_36:                               # %label_36
	addi	t0, a2, 8
	sd	t0, 48(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 48(sp)
	add	t2, t1, t0
	sd	t2, 56(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 56(sp)
	add	t2, t1, t0
	sd	t2, 64(sp)
	ld	t0, 64(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	a6, 0
	j	.LBB11_50
.LBB11_37:                               # %label_37
	addiw	t4, t3, 1
	mv	t3, t4
	j	.LBB11_26
.LBB11_50:                               # %label_50
	mv	t0, a0
	sd	t0, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	mv	t0, a6
	lw	t1, 80(sp)
	bge	t0, t1, .LBB11_52
.LBB11_51:                               # %label_51
	addi	t0, a2, 8
	sd	t0, 88(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 88(sp)
	add	t2, t1, t0
	sd	t2, 96(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 96(sp)
	add	t2, t1, t0
	sd	t2, 104(sp)
	addi	t0, a2, 8
	sd	t0, 112(sp)
	mv	t0, t3
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 112(sp)
	add	t2, t1, t0
	sd	t2, 120(sp)
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 120(sp)
	add	t2, t1, t0
	sd	t2, 128(sp)
	ld	t0, 128(sp)
	lw	t0, 0(t0)
	sw	t0, 136(sp)
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
	lw	t0, 136(sp)
	addw	t0, t0, s2
	sw	t0, 140(sp)
	ld	t0, 104(sp)
	lw	t1, 140(sp)
	sw	t1, 0(t0)
	addiw	s0, a6, 1
	mv	a6, s0
	j	.LBB11_50
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
	sd	s0, 200(sp)
	sd	s1, 208(sp)
	addi	t6, sp, 132
	sd	t6, 152(sp)
	j	.LBB12_0
.LBB12_0:                               # %label_0
	sd	ra, 168(sp)
	sd	a0, 176(sp)
	sd	a1, 184(sp)
	ld	a0, 152(sp)
	call	fn.12
	ld	ra, 168(sp)
	ld	a0, 176(sp)
	ld	a1, 184(sp)
	sd	ra, 168(sp)
	sd	a0, 176(sp)
	sd	a1, 184(sp)
	ld	a2, 152(sp)
	call	fn.21
	ld	ra, 168(sp)
	ld	a0, 176(sp)
	ld	a1, 184(sp)
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
	sw	s0, 164(sp)
	j	.LBB12_12
.LBB12_11:                               # %label_11
	li	t1, 2
	divuw	s0, a1, t1
	mv	t0, s0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s0, 0(s0)
	sw	s0, 164(sp)
.LBB12_12:                               # %label_12
	lw	a0, 164(sp)
	ld	s0, 200(sp)
	ld	s1, 208(sp)
	addi	sp, sp, 224
	ret
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
	j	.LBB13_0
.LBB13_0:                               # %label_0
	mv	s7, a3
	mv	s6, a3
	lw	s6, 0(s6)
	addiw	t0, s6, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(s7)
	li	t0, 0
	sw	t0, 28(sp)
.LBB13_15:                               # %label_15
	lw	t0, 28(sp)
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
	lw	t0, 28(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	a7, 0(t3)
	mv	t0, a7
	mv	t1, a2
	beq	t0, t1, .LBB13_33
	j	.LBB13_34
.LBB13_17:                               # %label_17
	addi	a6, a3, 16
	addi	s8, a3, 16
	lw	s8, 0(s8)
	addw	t0, s8, a1
	sw	t0, 24(sp)
	lw	t1, 24(sp)
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
	lw	t1, 28(sp)
	addw	s8, s8, t1
	addiw	t0, s8, 1
	sw	t0, 20(sp)
	lw	t1, 20(sp)
	sw	t1, 0(a6)
	lw	a0, 28(sp)
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
.LBB13_34:                               # %label_34
	lw	t0, 28(sp)
	addiw	a5, t0, 1
	sw	a5, 28(sp)
	j	.LBB13_15
.Lfunc_end13:
	.size	fn.5, .Lfunc_end13-fn.5
                                        # -- End function
	.globl	fn.6                            # -- Begin function fn.6
	.p2align	1
	.type	fn.6,@function
fn.6:                                   # @fn.6
# %bb.0:                                # %alloca
	addi	sp, sp, -256
	sd	s0, 168(sp)
	sd	s2, 176(sp)
	sd	s3, 184(sp)
	sd	s4, 192(sp)
	sd	s5, 200(sp)
	sd	s6, 208(sp)
	sd	s7, 216(sp)
	sd	s8, 224(sp)
	sd	s9, 232(sp)
	sd	s10, 240(sp)
	sd	s11, 248(sp)
	j	.LBB14_0
.LBB14_0:                               # %label_0
	mv	t3, a3
	mv	s0, a3
	lw	s0, 0(s0)
	addiw	t0, s0, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
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
	sw	t0, 8(sp)
	lw	t0, 8(sp)
	li	t1, 2
	divw	t0, t0, t1
	sw	t0, 12(sp)
	lw	t1, 12(sp)
	addw	t0, t5, t1
	sw	t0, 16(sp)
	addi	t0, a3, 12
	sd	t0, 24(sp)
	addi	t0, a3, 12
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	addiw	t0, t0, 1
	sw	t0, 44(sp)
	ld	t0, 24(sp)
	lw	t1, 44(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 48(sp)
	addi	s11, a3, 4
	lw	s10, 0(s11)
	addiw	t0, s10, 1
	sw	t0, 56(sp)
	ld	t0, 48(sp)
	lw	t1, 56(sp)
	sw	t1, 0(t0)
	lw	t0, 16(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	a5, 0(a6)
	mv	t0, a5
	mv	t1, a2
	beq	t0, t1, .LBB14_43
	j	.LBB14_44
.LBB14_20:                               # %label_20
	ld	s0, 168(sp)
	ld	s2, 176(sp)
	ld	s3, 184(sp)
	ld	s4, 192(sp)
	ld	s5, 200(sp)
	ld	s6, 208(sp)
	ld	s7, 216(sp)
	ld	s8, 224(sp)
	ld	s9, 232(sp)
	ld	s10, 240(sp)
	ld	s11, 248(sp)
	li	a0, -1
	addi	sp, sp, 256
	ret
.LBB14_43:                               # %label_43
	addi	a4, a3, 16
	addi	s9, a3, 16
	lw	s9, 0(s9)
	addiw	t0, s9, 1
	sw	t0, 64(sp)
	lw	t1, 64(sp)
	sw	t1, 0(a4)
	lw	a0, 16(sp)
	ld	s0, 168(sp)
	ld	s2, 176(sp)
	ld	s3, 184(sp)
	ld	s4, 192(sp)
	ld	s5, 200(sp)
	ld	s6, 208(sp)
	ld	s7, 216(sp)
	ld	s8, 224(sp)
	ld	s9, 232(sp)
	ld	s10, 240(sp)
	ld	s11, 248(sp)
	addi	sp, sp, 256
	ret
.LBB14_44:                               # %label_44
	lw	t0, 16(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	s8, a0, t0
	lw	s7, 0(s8)
	mv	t0, s7
	mv	t1, a2
	blt	t0, t1, .LBB14_59
	j	.LBB14_60
.LBB14_45:                               # %label_45
	addi	s4, a3, 16
	addi	s3, a3, 16
	lw	s2, 0(s3)
	addiw	t0, s2, 1
	sw	t0, 72(sp)
	lw	t1, 72(sp)
	sw	t1, 0(s4)
	mv	t5, s0
	mv	t4, t3
	j	.LBB14_18
.LBB14_59:                               # %label_59
	lw	t0, 16(sp)
	addiw	s6, t0, 1
	mv	s0, s6
	mv	t3, t4
	j	.LBB14_61
.LBB14_60:                               # %label_60
	lw	t0, 16(sp)
	addiw	s5, t0, -1
	mv	t3, s5
	mv	s0, t5
.LBB14_61:                               # %label_61
	j	.LBB14_45
.Lfunc_end14:
	.size	fn.6, .Lfunc_end14-fn.6
                                        # -- End function
	.globl	fn.7                            # -- Begin function fn.7
	.p2align	1
	.type	fn.7,@function
fn.7:                                   # @fn.7
# %bb.0:                                # %alloca
	addi	sp, sp, -768
	sd	s0, 680(sp)
	sd	s1, 688(sp)
	sd	s2, 696(sp)
	sd	s4, 704(sp)
	sd	s5, 712(sp)
	sd	s6, 720(sp)
	sd	s7, 728(sp)
	sd	s8, 736(sp)
	sd	s9, 744(sp)
	sd	s10, 752(sp)
	sd	s11, 760(sp)
	addi	t6, sp, 8
	sd	t6, 408(sp)
	j	.LBB15_0
.LBB15_0:                               # %label_0
	addi	t0, a3, 8
	sd	t0, 0(sp)
	sd	ra, 584(sp)
	sd	a0, 592(sp)
	sd	a1, 600(sp)
	sd	a2, 608(sp)
	sd	a3, 616(sp)
	sd	a4, 624(sp)
	sd	a5, 632(sp)
	sd	a6, 640(sp)
	sd	a7, 648(sp)
	sd	t3, 656(sp)
	sd	t4, 664(sp)
	sd	t5, 672(sp)
	ld	t0, 408(sp)
	mv	a0, t0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	ld	ra, 584(sp)
	ld	a0, 592(sp)
	ld	a1, 600(sp)
	ld	a2, 608(sp)
	ld	a3, 616(sp)
	ld	a4, 624(sp)
	ld	a5, 632(sp)
	ld	a6, 640(sp)
	ld	a7, 648(sp)
	ld	t3, 656(sp)
	ld	t4, 664(sp)
	ld	t5, 672(sp)
	li	s0, 0
.LBB15_12:                               # %label_12
	mv	t0, s0
	li	t1, 100
	bgeu	t0, t1, .LBB15_14
.LBB15_13:                               # %label_13
	mv	t0, s0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 0(sp)
	add	t2, t1, t0
	sd	t2, 424(sp)
	sd	ra, 584(sp)
	sd	a0, 592(sp)
	sd	a1, 600(sp)
	sd	a2, 608(sp)
	sd	a3, 616(sp)
	sd	a5, 632(sp)
	sd	a6, 640(sp)
	sd	a7, 648(sp)
	sd	t3, 656(sp)
	sd	t4, 664(sp)
	sd	t5, 672(sp)
	ld	t0, 424(sp)
	ld	t1, 408(sp)
	mv	a0, t0
	mv	a1, t1
	li	a2, 400
	call	builtin_memcpy
	ld	ra, 584(sp)
	ld	a0, 592(sp)
	ld	a1, 600(sp)
	ld	a2, 608(sp)
	ld	a3, 616(sp)
	ld	a5, 632(sp)
	ld	a6, 640(sp)
	ld	a7, 648(sp)
	ld	t3, 656(sp)
	ld	t4, 664(sp)
	ld	t5, 672(sp)
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
	j	.LBB15_33
.LBB15_28:                               # %label_28
	ld	s0, 680(sp)
	ld	s1, 688(sp)
	ld	s2, 696(sp)
	ld	s4, 704(sp)
	ld	s5, 712(sp)
	ld	s6, 720(sp)
	ld	s7, 728(sp)
	ld	s8, 736(sp)
	ld	s9, 744(sp)
	ld	s10, 752(sp)
	ld	s11, 760(sp)
	li	a0, 0
	addi	sp, sp, 768
	ret
.LBB15_33:                               # %label_33
	mv	t0, t4
	mv	t1, a1
	bge	t0, t1, .LBB15_35
.LBB15_34:                               # %label_34
	mv	t0, a2
	beq	t0, x0, .LBB15_39
	j	.LBB15_40
.LBB15_35:                               # %label_35
	addiw	s1, t5, 1
	mv	t5, s1
	j	.LBB15_26
.LBB15_39:                               # %label_39
	addi	t0, a3, 8
	sd	t0, 440(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 440(sp)
	add	t2, t1, t0
	sd	t2, 448(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 448(sp)
	add	s11, t1, t0
	mv	t0, t5
	mv	t1, t4
	beq	t0, t1, .LBB15_49
	j	.LBB15_50
.LBB15_40:                               # %label_40
	mv	t0, a2
	li	t1, 1
	beq	t0, t1, .LBB15_62
	j	.LBB15_63
.LBB15_41:                               # %label_41
	addiw	s2, t4, 1
	mv	t4, s2
	mv	s0, a7
	mv	a4, a5
	j	.LBB15_33
.LBB15_49:                               # %label_49
	li	t0, 1
	sw	t0, 460(sp)
	li	t3, 1
	lw	t0, 460(sp)
	sw	t0, 468(sp)
	mv	a6, a4
	j	.LBB15_51
.LBB15_50:                               # %label_50
	li	t0, 0
	sw	t0, 464(sp)
	li	a6, 0
	lw	t0, 464(sp)
	sw	t0, 468(sp)
	mv	t3, s0
.LBB15_51:                               # %label_51
	lw	t1, 468(sp)
	sw	t1, 0(s11)
	mv	a7, t3
	mv	a5, a6
	j	.LBB15_41
.LBB15_62:                               # %label_62
	addi	t0, a3, 8
	sd	t0, 480(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 480(sp)
	add	t2, t1, t0
	sd	t2, 488(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 488(sp)
	add	t2, t1, t0
	sd	t2, 496(sp)
	li	t1, 17
	mulw	t0, t5, t1
	sw	t0, 504(sp)
	li	t1, 23
	mulw	t0, t4, t1
	sw	t0, 508(sp)
	lw	t0, 504(sp)
	lw	t1, 508(sp)
	addw	t0, t0, t1
	sw	t0, 512(sp)
	lw	t0, 512(sp)
	addiw	t0, t0, 13
	sw	t0, 516(sp)
	lw	t0, 516(sp)
	li	t1, 100
	remw	t0, t0, t1
	sw	t0, 520(sp)
	ld	t0, 496(sp)
	lw	t1, 520(sp)
	sw	t1, 0(t0)
	j	.LBB15_64
.LBB15_63:                               # %label_63
	mv	t0, a2
	li	t1, 2
	beq	t0, t1, .LBB15_79
	j	.LBB15_80
.LBB15_64:                               # %label_64
	mv	a7, s0
	mv	a5, a4
	j	.LBB15_41
.LBB15_79:                               # %label_79
	addi	t0, a3, 8
	sd	t0, 528(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 528(sp)
	add	t2, t1, t0
	sd	t2, 536(sp)
	mv	t0, t4
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 536(sp)
	add	t2, t1, t0
	sd	t2, 544(sp)
	mulw	t0, t5, a1
	sw	t0, 552(sp)
	lw	t0, 552(sp)
	addw	t0, t0, t4
	sw	t0, 556(sp)
	lw	t0, 556(sp)
	addiw	t0, t0, 1
	sw	t0, 560(sp)
	ld	t0, 544(sp)
	lw	t1, 560(sp)
	sw	t1, 0(t0)
	j	.LBB15_81
.LBB15_80:                               # %label_80
	addi	t0, a3, 8
	sd	t0, 568(sp)
	mv	t0, t5
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 568(sp)
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
	sw	t0, 576(sp)
	lw	t1, 576(sp)
	sw	t1, 0(s9)
.LBB15_81:                               # %label_81
	j	.LBB15_64
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
	j	.LBB16_0
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
	sw	t0, 128(sp)
	lw	t1, 128(sp)
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
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(s2)
	addi	s2, a3, 4
	addi	a6, a3, 4
	lw	a6, 0(a6)
	addiw	t0, a6, 2
	sw	t0, 140(sp)
	lw	t1, 140(sp)
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
	j	.LBB16_42
.LBB16_25:                               # %label_25
	mv	s9, s7
	mv	t0, s5
	mv	t1, a1
	blt	t0, t1, .LBB16_53
	j	.LBB16_54
.LBB16_41:                               # %label_41
	mv	s8, s6
.LBB16_42:                               # %label_42
	mv	s7, s8
	j	.LBB16_25
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
	j	.LBB16_71
.LBB16_54:                               # %label_54
	mv	t0, s9
	mv	t1, a2
	bne	t0, t1, .LBB16_82
	j	.LBB16_83
.LBB16_70:                               # %label_70
	mv	s10, s5
.LBB16_71:                               # %label_71
	mv	s9, s10
	j	.LBB16_54
.LBB16_82:                               # %label_82
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t0, 0(s0)
	sw	t0, 160(sp)
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	mv	t0, s9
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a0, t0
	lw	t0, 0(a7)
	sw	t0, 164(sp)
	lw	t1, 164(sp)
	sw	t1, 0(s0)
	mv	t0, s9
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t1, 160(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 8
	addi	s1, a3, 8
	lw	s1, 0(s1)
	addiw	t0, s1, 1
	sw	t0, 168(sp)
	lw	t1, 168(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 4
	addi	s1, a3, 4
	lw	s1, 0(s1)
	addiw	t0, s1, 4
	sw	t0, 172(sp)
	lw	t1, 172(sp)
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
.Lfunc_end16:
	.size	fn.8, .Lfunc_end16-fn.8
                                        # -- End function
	.globl	fn.9                            # -- Begin function fn.9
	.p2align	1
	.type	fn.9,@function
fn.9:                                   # @fn.9
# %bb.0:                                # %alloca
	addi	sp, sp, -336
	sd	s0, 240(sp)
	sd	s1, 248(sp)
	sd	s2, 256(sp)
	sd	s3, 264(sp)
	sd	s4, 272(sp)
	sd	s5, 280(sp)
	sd	s6, 288(sp)
	sd	s7, 296(sp)
	sd	s8, 304(sp)
	sd	s9, 312(sp)
	sd	s10, 320(sp)
	j	.LBB17_0
.LBB17_0:                               # %label_0
	mv	s2, a2
	mv	s5, a2
	lw	s5, 0(s5)
	addiw	t0, s5, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(s2)
	li	s7, 0
	li	s2, 0
.LBB17_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 4(sp)
	mv	t0, s7
	lw	t1, 4(sp)
	bge	t0, t1, .LBB17_15
.LBB17_14:                               # %label_14
	addiw	t0, s7, 1
	sw	t0, 12(sp)
	lw	t0, 12(sp)
	mv	s4, t0
	mv	s5, s7
	j	.LBB17_25
.LBB17_15:                               # %label_15
	addi	a3, a2, 16
	addi	s8, a2, 16
	lw	s9, 0(s8)
	mulw	s8, a1, a1
	addw	t0, s9, s8
	sw	t0, 156(sp)
	lw	t1, 156(sp)
	sw	t1, 0(a3)
	ld	s0, 240(sp)
	ld	s1, 248(sp)
	ld	s2, 256(sp)
	ld	s3, 264(sp)
	ld	s4, 272(sp)
	ld	s5, 280(sp)
	ld	s6, 288(sp)
	ld	s7, 296(sp)
	ld	s8, 304(sp)
	ld	s9, 312(sp)
	ld	s10, 320(sp)
	li	a0, 0
	addi	sp, sp, 336
	ret
.LBB17_25:                               # %label_25
	mv	t0, s4
	mv	t1, a1
	bge	t0, t1, .LBB17_27
.LBB17_26:                               # %label_26
	addi	t0, a2, 12
	sd	t0, 24(sp)
	addi	t0, a2, 12
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	addiw	t0, t0, 1
	sw	t0, 44(sp)
	ld	t0, 24(sp)
	lw	t1, 44(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 48(sp)
	addi	t0, a2, 4
	sd	t0, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	addiw	t0, t0, 2
	sw	t0, 68(sp)
	ld	t0, 48(sp)
	lw	t1, 68(sp)
	sw	t1, 0(t0)
	mv	t0, s4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 88(sp)
	ld	t0, 88(sp)
	lw	t0, 0(t0)
	sw	t0, 96(sp)
	mv	s6, s5
	lw	t0, 80(sp)
	lw	t1, 96(sp)
	blt	t0, t1, .LBB17_43
	j	.LBB17_44
.LBB17_27:                               # %label_27
	mv	s3, s2
	mv	t0, s5
	mv	t1, s7
	bne	t0, t1, .LBB17_57
	j	.LBB17_58
.LBB17_43:                               # %label_43
	mv	s6, s4
.LBB17_44:                               # %label_44
	addiw	t0, s4, 1
	sw	t0, 104(sp)
	lw	t0, 104(sp)
	mv	s4, t0
	mv	s5, s6
	j	.LBB17_25
.LBB17_57:                               # %label_57
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 128(sp)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 136(sp)
	ld	t0, 136(sp)
	lw	t0, 0(t0)
	sw	t0, 144(sp)
	ld	t0, 128(sp)
	lw	t1, 144(sp)
	sw	t1, 0(t0)
	mv	t0, s5
	li	t1, 4
	mul	t0, t0, t1
	add	s10, a0, t0
	lw	t1, 120(sp)
	sw	t1, 0(s10)
	addi	s1, a2, 8
	addi	s0, a2, 8
	lw	t5, 0(s0)
	addiw	t0, t5, 1
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(s1)
	addi	t3, a2, 4
	addi	a7, a2, 4
	lw	a6, 0(a7)
	addiw	t0, a6, 4
	sw	t0, 152(sp)
	lw	t1, 152(sp)
	sw	t1, 0(t3)
	lw	t0, 120(sp)
	mv	s3, t0
.LBB17_58:                               # %label_58
	addiw	a4, s7, 1
	mv	s7, a4
	mv	s2, s3
	j	.LBB17_13
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
	j	.LBB18_0
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
	j	.LBB19_0
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
	j	.LBB20_0
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
	sd	s0, 280(sp)
	sd	s1, 288(sp)
	sd	s3, 296(sp)
	sd	s4, 304(sp)
	sd	s5, 312(sp)
	sd	s7, 320(sp)
	sd	s8, 328(sp)
	sd	s9, 336(sp)
	sd	s10, 344(sp)
	j	.LBB21_0
.LBB21_0:                               # %label_0
	mv	s0, a2
	mv	t4, a2
	lw	t4, 0(t4)
	addiw	t0, t4, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s0)
	li	t1, 2
	divw	s0, a1, t1
	addiw	s0, s0, -1
	mv	s1, s0
.LBB21_16:                               # %label_16
	mv	t0, s1
	blt	t0, x0, .LBB21_18
.LBB21_17:                               # %label_17
	sd	ra, 184(sp)
	sd	a0, 192(sp)
	sd	a1, 200(sp)
	sd	a2, 208(sp)
	sd	a3, 216(sp)
	sd	a7, 248(sp)
	mv	a2, s1
	ld	a3, 208(sp)
	call	fn.8
	ld	ra, 184(sp)
	ld	a0, 192(sp)
	ld	a1, 200(sp)
	ld	a2, 208(sp)
	ld	a3, 216(sp)
	ld	a7, 248(sp)
	addiw	t0, s1, -1
	sw	t0, 136(sp)
	lw	t0, 136(sp)
	mv	s1, t0
	j	.LBB21_16
.LBB21_18:                               # %label_18
	addiw	t0, a1, -1
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	mv	a3, t0
.LBB21_29:                               # %label_29
	mv	t0, a3
	bge	x0, t0, .LBB21_31
.LBB21_30:                               # %label_30
	mv	t0, a0
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 160(sp)
	mv	t5, a0
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	t0, 0(t3)
	sw	t0, 164(sp)
	lw	t1, 164(sp)
	sw	t1, 0(t5)
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	s10, a0, t0
	lw	t1, 160(sp)
	sw	t1, 0(s10)
	addi	s9, a2, 8
	addi	s8, a2, 8
	lw	s7, 0(s8)
	addiw	t0, s7, 1
	sw	t0, 168(sp)
	lw	t1, 168(sp)
	sw	t1, 0(s9)
	addi	s5, a2, 4
	addi	s4, a2, 4
	lw	s3, 0(s4)
	addiw	t0, s3, 4
	sw	t0, 172(sp)
	lw	t1, 172(sp)
	sw	t1, 0(s5)
	sd	ra, 184(sp)
	sd	a0, 192(sp)
	sd	a1, 200(sp)
	sd	a2, 208(sp)
	sd	a3, 216(sp)
	mv	a1, a3
	li	a2, 0
	ld	a3, 208(sp)
	call	fn.8
	ld	ra, 184(sp)
	ld	a0, 192(sp)
	ld	a1, 200(sp)
	ld	a2, 208(sp)
	ld	a3, 216(sp)
	addiw	a7, a3, -1
	mv	a3, a7
	j	.LBB21_29
.LBB21_31:                               # %label_31
	addi	a6, a2, 16
	addi	a4, a2, 16
	lw	a5, 0(a4)
	mulw	a4, a1, a1
	addw	t0, a5, a4
	sw	t0, 176(sp)
	lw	t1, 176(sp)
	sw	t1, 0(a6)
	ld	s0, 280(sp)
	ld	s1, 288(sp)
	ld	s3, 296(sp)
	ld	s4, 304(sp)
	ld	s5, 312(sp)
	ld	s7, 320(sp)
	ld	s8, 328(sp)
	ld	s9, 336(sp)
	ld	s10, 344(sp)
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
	addi	sp, sp, -480
	sd	s0, 384(sp)
	sd	s1, 392(sp)
	sd	s3, 400(sp)
	sd	s4, 408(sp)
	sd	s5, 416(sp)
	sd	s6, 424(sp)
	sd	s7, 432(sp)
	sd	s8, 440(sp)
	sd	s9, 448(sp)
	sd	s10, 456(sp)
	sd	s11, 464(sp)
	j	.LBB22_0
.LBB22_0:                               # %label_0
	addi	s9, a2, 24
	sd	ra, 288(sp)
	sd	a0, 296(sp)
	sd	a1, 304(sp)
	sd	a2, 312(sp)
	sd	a3, 320(sp)
	sd	a6, 344(sp)
	mv	a0, s9
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	ra, 288(sp)
	ld	a0, 296(sp)
	ld	a1, 304(sp)
	ld	a2, 312(sp)
	ld	a3, 320(sp)
	ld	a6, 344(sp)
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
	j	.LBB22_24
.LBB22_18:                               # %label_18
	mv	a5, a2
	addi	a4, a2, 4
	lw	a4, 0(a4)
	divw	t0, a4, a1
	sw	t0, 284(sp)
	lw	t1, 284(sp)
	sw	t1, 0(a5)
	ld	s0, 384(sp)
	ld	s1, 392(sp)
	ld	s3, 400(sp)
	ld	s4, 408(sp)
	ld	s5, 416(sp)
	ld	s6, 424(sp)
	ld	s7, 432(sp)
	ld	s8, 440(sp)
	ld	s9, 448(sp)
	ld	s10, 456(sp)
	ld	s11, 464(sp)
	li	a0, 0
	addi	sp, sp, 480
	ret
.LBB22_23:                               # %label_23
	li	t1, 11047
	mulw	t0, a3, t1
	sw	t0, 4(sp)
	lw	t0, 4(sp)
	li	t6, 12345
	addw	t0, t0, t6
	sw	t0, 8(sp)
	lw	t0, 8(sp)
	li	t1, 100000
	remw	t0, t0, t1
	sw	t0, 12(sp)
	lw	t0, 12(sp)
	sw	t0, 16(sp)
	lw	t0, 16(sp)
	sw	t0, 272(sp)
	j	.LBB22_25
.LBB22_24:                               # %label_24
	mv	t0, a0
	li	t1, 1
	beq	t0, t1, .LBB22_33
	j	.LBB22_34
.LBB22_25:                               # %label_25
	addi	s7, a2, 24
	mv	t0, a3
	li	t1, 4
	mul	t0, t0, t1
	add	s6, s7, t0
	lw	t1, 272(sp)
	sw	t1, 0(s6)
	addi	s5, a2, 4
	addi	s4, a2, 4
	lw	s3, 0(s4)
	lw	t1, 272(sp)
	addw	t0, s3, t1
	sw	t0, 276(sp)
	lw	t1, 276(sp)
	sw	t1, 0(s5)
	addi	s1, a2, 12
	lw	s0, 0(s1)
	lw	t0, 272(sp)
	mv	t1, s0
	blt	t0, t1, .LBB22_170
	j	.LBB22_171
.LBB22_33:                               # %label_33
	li	t1, 3
	mulw	t0, a3, t1
	sw	t0, 24(sp)
	lw	t0, 24(sp)
	addiw	t0, t0, 7
	sw	t0, 28(sp)
	lw	t0, 28(sp)
	sw	t0, 32(sp)
	lw	t0, 32(sp)
	mv	s8, t0
	j	.LBB22_35
.LBB22_34:                               # %label_34
	mv	t0, a0
	li	t1, 2
	beq	t0, t1, .LBB22_42
	j	.LBB22_43
.LBB22_35:                               # %label_35
	sw	s8, 272(sp)
	j	.LBB22_25
.LBB22_42:                               # %label_42
	subw	t0, a1, a3
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	li	t1, 5
	mulw	t0, t0, t1
	sw	t0, 44(sp)
	lw	t0, 44(sp)
	addiw	t0, t0, 13
	sw	t0, 48(sp)
	lw	t0, 48(sp)
	sw	t0, 52(sp)
	lw	t0, 52(sp)
	mv	s10, t0
	j	.LBB22_44
.LBB22_43:                               # %label_43
	mv	t0, a0
	li	t1, 3
	beq	t0, t1, .LBB22_53
	j	.LBB22_54
.LBB22_44:                               # %label_44
	mv	s8, s10
	j	.LBB22_35
.LBB22_53:                               # %label_53
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 60(sp)
	mv	t0, a3
	lw	t1, 60(sp)
	blt	t0, t1, .LBB22_58
	j	.LBB22_59
.LBB22_54:                               # %label_54
	mv	t0, a0
	li	t1, 4
	beq	t0, t1, .LBB22_75
	j	.LBB22_76
.LBB22_55:                               # %label_55
	mv	s10, s11
	j	.LBB22_44
.LBB22_58:                               # %label_58
	li	t1, 4
	mulw	t0, a3, t1
	sw	t0, 68(sp)
	lw	t0, 68(sp)
	sw	t0, 72(sp)
	lw	t0, 72(sp)
	sw	t0, 88(sp)
	j	.LBB22_60
.LBB22_59:                               # %label_59
	subw	t0, a1, a3
	sw	t0, 76(sp)
	lw	t0, 76(sp)
	li	t1, 4
	mulw	t0, t0, t1
	sw	t0, 80(sp)
	lw	t0, 80(sp)
	sw	t0, 84(sp)
	lw	t0, 84(sp)
	sw	t0, 88(sp)
.LBB22_60:                               # %label_60
	lw	t0, 88(sp)
	sw	t0, 92(sp)
	lw	t0, 92(sp)
	mv	s11, t0
	j	.LBB22_55
.LBB22_75:                               # %label_75
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 100(sp)
	mv	t0, a3
	lw	t1, 100(sp)
	blt	t0, t1, .LBB22_80
	j	.LBB22_81
.LBB22_76:                               # %label_76
	mv	t0, a0
	li	t1, 5
	beq	t0, t1, .LBB22_101
	j	.LBB22_102
.LBB22_77:                               # %label_77
	lw	t0, 268(sp)
	mv	s11, t0
	j	.LBB22_55
.LBB22_80:                               # %label_80
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 108(sp)
	lw	t0, 108(sp)
	subw	t0, t0, a3
	sw	t0, 112(sp)
	lw	t0, 112(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 116(sp)
	lw	t0, 116(sp)
	sw	t0, 120(sp)
	lw	t0, 120(sp)
	sw	t0, 140(sp)
	j	.LBB22_82
.LBB22_81:                               # %label_81
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 124(sp)
	lw	t1, 124(sp)
	subw	t0, a3, t1
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 132(sp)
	lw	t0, 132(sp)
	sw	t0, 136(sp)
	lw	t0, 136(sp)
	sw	t0, 140(sp)
.LBB22_82:                               # %label_82
	lw	t0, 140(sp)
	sw	t0, 144(sp)
	lw	t0, 144(sp)
	sw	t0, 268(sp)
	j	.LBB22_77
.LBB22_101:                               # %label_101
	li	t1, 2
	mulw	t0, a3, t1
	sw	t0, 152(sp)
	li	t1, 10
	remw	t0, a3, t1
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	xori	t0, t0, 5
	sltiu	t0, t0, 1
	sb	t0, 160(sp)
	lbu	t0, 160(sp)
	sw	t0, 164(sp)
	lw	t0, 164(sp)
	li	t1, 100
	mulw	t0, t0, t1
	sw	t0, 168(sp)
	lw	t0, 152(sp)
	lw	t1, 168(sp)
	addw	t0, t0, t1
	sw	t0, 172(sp)
	lw	t0, 172(sp)
	sw	t0, 176(sp)
	lw	t0, 176(sp)
	sw	t0, 264(sp)
	j	.LBB22_103
.LBB22_102:                               # %label_102
	mv	t0, a0
	li	t1, 6
	beq	t0, t1, .LBB22_115
	j	.LBB22_116
.LBB22_103:                               # %label_103
	lw	t0, 264(sp)
	sw	t0, 268(sp)
	j	.LBB22_77
.LBB22_115:                               # %label_115
	li	t1, 10
	divw	t0, a3, t1
	sw	t0, 184(sp)
	lw	t0, 184(sp)
	li	t1, 7
	mulw	t0, t0, t1
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 23
	sw	t0, 192(sp)
	lw	t0, 192(sp)
	sw	t0, 196(sp)
	lw	t0, 196(sp)
	sw	t0, 260(sp)
	j	.LBB22_117
.LBB22_116:                               # %label_116
	mv	t0, a0
	li	t1, 7
	beq	t0, t1, .LBB22_125
	j	.LBB22_126
.LBB22_117:                               # %label_117
	lw	t0, 260(sp)
	sw	t0, 264(sp)
	j	.LBB22_103
.LBB22_125:                               # %label_125
	li	t1, 2
	remw	t0, a3, t1
	sw	t0, 204(sp)
	lw	t0, 204(sp)
	beq	t0, x0, .LBB22_130
	j	.LBB22_131
.LBB22_126:                               # %label_126
	mulw	t0, a3, a3
	sw	t0, 232(sp)
	li	t1, 7
	mulw	t0, a3, t1
	sw	t0, 236(sp)
	lw	t0, 232(sp)
	lw	t1, 236(sp)
	addw	t0, t0, t1
	sw	t0, 240(sp)
	lw	t0, 240(sp)
	addiw	t0, t0, 17
	sw	t0, 244(sp)
	lw	t0, 244(sp)
	li	t1, 1000
	remw	t0, t0, t1
	sw	t0, 248(sp)
	lw	t0, 248(sp)
	sw	t0, 252(sp)
	lw	t0, 252(sp)
	sw	t0, 256(sp)
.LBB22_127:                               # %label_127
	lw	t0, 256(sp)
	sw	t0, 260(sp)
	j	.LBB22_117
.LBB22_130:                               # %label_130
	sw	a3, 212(sp)
	lw	t0, 212(sp)
	sw	t0, 224(sp)
	j	.LBB22_132
.LBB22_131:                               # %label_131
	subw	t0, a1, a3
	sw	t0, 216(sp)
	lw	t0, 216(sp)
	sw	t0, 220(sp)
	lw	t0, 220(sp)
	sw	t0, 224(sp)
.LBB22_132:                               # %label_132
	lw	t0, 224(sp)
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	sw	t0, 256(sp)
	j	.LBB22_127
.LBB22_170:                               # %label_170
	addi	t5, a2, 12
	lw	t1, 272(sp)
	sw	t1, 0(t5)
.LBB22_171:                               # %label_171
	addi	t4, a2, 8
	lw	t3, 0(t4)
	lw	t0, 272(sp)
	mv	t1, t3
	bge	t1, t0, .LBB22_179
.LBB22_178:                               # %label_178
	addi	a7, a2, 8
	lw	t1, 272(sp)
	sw	t1, 0(a7)
.LBB22_179:                               # %label_179
	addiw	a6, a3, 1
	mv	a3, a6
	j	.LBB22_16
.Lfunc_end22:
	.size	fn.14, .Lfunc_end22-fn.14
                                        # -- End function
	.globl	fn.15                            # -- Begin function fn.15
	.p2align	1
	.type	fn.15,@function
fn.15:                                   # @fn.15
# %bb.0:                                # %alloca
	addi	sp, sp, -368
	sd	s0, 288(sp)
	sd	s1, 296(sp)
	sd	s2, 304(sp)
	sd	s3, 312(sp)
	sd	s4, 320(sp)
	sd	s6, 328(sp)
	sd	s7, 336(sp)
	sd	s8, 344(sp)
	sd	s10, 352(sp)
	sd	s11, 360(sp)
	j	.LBB23_0
.LBB23_0:                               # %label_0
	mv	a3, a2
	mv	a5, a2
	lw	a5, 0(a5)
	addiw	t0, a5, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a3)
	li	t4, 0
	li	a7, 0
	li	a5, 0
	li	a3, 0
.LBB23_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 4(sp)
	mv	t0, t4
	lw	t1, 4(sp)
	bge	t0, t1, .LBB23_15
.LBB23_14:                               # %label_14
	li	t3, 0
	li	a5, 0
	j	.LBB23_22
.LBB23_15:                               # %label_15
	addi	s1, a2, 16
	addi	t5, a2, 16
	lw	s0, 0(t5)
	mulw	t5, a1, a1
	addw	t0, s0, t5
	sw	t0, 184(sp)
	lw	t1, 184(sp)
	sw	t1, 0(s1)
	ld	s0, 288(sp)
	ld	s1, 296(sp)
	ld	s2, 304(sp)
	ld	s3, 312(sp)
	ld	s4, 320(sp)
	ld	s6, 328(sp)
	ld	s7, 336(sp)
	ld	s8, 344(sp)
	ld	s10, 352(sp)
	ld	s11, 360(sp)
	li	a0, 0
	addi	sp, sp, 368
	ret
.LBB23_22:                               # %label_22
	subw	t0, a1, t4
	sw	t0, 12(sp)
	lw	t0, 12(sp)
	addiw	t0, t0, -1
	sw	t0, 16(sp)
	mv	t0, t3
	lw	t1, 16(sp)
	bge	t0, t1, .LBB23_24
.LBB23_23:                               # %label_23
	addi	t0, a2, 12
	sd	t0, 24(sp)
	addi	t0, a2, 12
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	addiw	t0, t0, 1
	sw	t0, 44(sp)
	ld	t0, 24(sp)
	lw	t1, 44(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 48(sp)
	addi	t0, a2, 4
	sd	t0, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	addiw	t0, t0, 2
	sw	t0, 68(sp)
	ld	t0, 48(sp)
	lw	t1, 68(sp)
	sw	t1, 0(t0)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	addiw	t0, t3, 1
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 88(sp)
	ld	t0, 88(sp)
	lw	t0, 0(t0)
	sw	t0, 100(sp)
	mv	a6, a5
	mv	a4, a3
	lw	t0, 80(sp)
	lw	t1, 100(sp)
	blt	t1, t0, .LBB23_43
	j	.LBB23_44
.LBB23_24:                               # %label_24
	li	t0, 1
	subw	s3, t0, a5
	mv	t0, s3
	beq	x0, t0, .LBB23_24_jump_0
	j	.LBB23_87
.LBB23_24_jump_0:                               # %label_24_jump_0
	j	.LBB23_88
.LBB23_43:                               # %label_43
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 128(sp)
	addiw	t0, t3, 1
	sw	t0, 144(sp)
	lw	t0, 144(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 136(sp)
	ld	t0, 136(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	ld	t0, 128(sp)
	lw	t1, 148(sp)
	sw	t1, 0(t0)
	addiw	t0, t3, 1
	sw	t0, 160(sp)
	lw	t0, 160(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 152(sp)
	ld	t0, 152(sp)
	lw	t1, 120(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 8
	sd	t0, 168(sp)
	addi	s11, a2, 8
	lw	s10, 0(s11)
	addiw	t0, s10, 1
	sw	t0, 176(sp)
	ld	t0, 168(sp)
	lw	t1, 176(sp)
	sw	t1, 0(t0)
	addi	s8, a2, 4
	addi	s7, a2, 4
	lw	s6, 0(s7)
	addiw	t0, s6, 4
	sw	t0, 180(sp)
	lw	t1, 180(sp)
	sw	t1, 0(s8)
	li	a6, 1
	lw	t0, 120(sp)
	mv	a4, t0
.LBB23_44:                               # %label_44
	addiw	s4, t3, 1
	mv	t3, s4
	mv	a5, a6
	mv	a3, a4
	j	.LBB23_22
.LBB23_87:                               # %label_87
	j	.LBB23_15
.LBB23_88:                               # %label_88
	addiw	s2, t4, 1
	mv	t4, s2
	mv	a7, t3
	j	.LBB23_13
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
	j	.LBB24_0
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
	addi	sp, sp, -336
	sd	s0, 256(sp)
	sd	s2, 264(sp)
	sd	s4, 272(sp)
	sd	s5, 280(sp)
	sd	s6, 288(sp)
	sd	s7, 296(sp)
	sd	s9, 304(sp)
	sd	s10, 312(sp)
	sd	s11, 320(sp)
	j	.LBB25_0
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
	sw	t0, 0(sp)
	lw	t1, 0(sp)
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
	sw	t0, 24(sp)
	lw	t0, 24(sp)
	addiw	t0, t0, 1
	sw	t0, 28(sp)
	ld	t0, 8(sp)
	lw	t1, 28(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 32(sp)
	addi	t0, a3, 4
	sd	t0, 40(sp)
	ld	t0, 40(sp)
	lw	t0, 0(t0)
	sw	t0, 48(sp)
	lw	t0, 48(sp)
	addiw	t0, t0, 1
	sw	t0, 52(sp)
	ld	t0, 32(sp)
	lw	t1, 52(sp)
	sw	t1, 0(t0)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	mv	t4, a4
	mv	a7, a5
	lw	t0, 64(sp)
	mv	t1, a6
	bge	t1, t0, .LBB25_42
	j	.LBB25_43
.LBB25_26:                               # %label_26
	addiw	t5, a4, 1
	mv	t0, t5
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t0, 0(t5)
	sw	t0, 136(sp)
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
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(s0)
	mv	t0, a2
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t1, 136(sp)
	sw	t1, 0(t5)
	addi	t5, a3, 8
	addi	s0, a3, 8
	lw	s0, 0(s0)
	addiw	t0, s0, 1
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(t5)
	addi	t5, a3, 4
	addi	s0, a3, 4
	lw	s0, 0(s0)
	addiw	t0, s0, 4
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(t5)
	addiw	t0, a4, 1
	sw	t0, 152(sp)
	lw	a0, 152(sp)
	ld	s0, 256(sp)
	ld	s2, 264(sp)
	ld	s4, 272(sp)
	ld	s5, 280(sp)
	ld	s6, 288(sp)
	ld	s7, 296(sp)
	ld	s9, 304(sp)
	ld	s10, 312(sp)
	ld	s11, 320(sp)
	addi	sp, sp, 336
	ret
.LBB25_42:                               # %label_42
	addiw	t0, a4, 1
	sw	t0, 72(sp)
	lw	t0, 72(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 80(sp)
	ld	t0, 80(sp)
	lw	t0, 0(t0)
	sw	t0, 88(sp)
	lw	t0, 72(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 96(sp)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 104(sp)
	ld	t0, 104(sp)
	lw	t0, 0(t0)
	sw	t0, 112(sp)
	ld	t0, 96(sp)
	lw	t1, 112(sp)
	sw	t1, 0(t0)
	mv	t0, t3
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 120(sp)
	ld	t0, 120(sp)
	lw	t1, 88(sp)
	sw	t1, 0(t0)
	addi	s11, a3, 8
	addi	s10, a3, 8
	lw	s9, 0(s10)
	addiw	t0, s9, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s11)
	addi	s6, a3, 4
	addi	s5, a3, 4
	lw	s4, 0(s5)
	addiw	t0, s4, 4
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(s6)
	lw	t0, 72(sp)
	mv	t4, t0
	lw	t0, 88(sp)
	mv	a7, t0
.LBB25_43:                               # %label_43
	addiw	s2, t3, 1
	mv	t3, s2
	mv	a4, t4
	mv	a5, a7
	j	.LBB25_24
.Lfunc_end25:
	.size	fn.17, .Lfunc_end25-fn.17
                                        # -- End function
	.globl	fn.18                            # -- Begin function fn.18
	.p2align	1
	.type	fn.18,@function
fn.18:                                   # @fn.18
# %bb.0:                                # %alloca
	addi	sp, sp, -336
	sd	s0, 248(sp)
	sd	s1, 256(sp)
	sd	s2, 264(sp)
	sd	s3, 272(sp)
	sd	s4, 280(sp)
	sd	s5, 288(sp)
	sd	s7, 296(sp)
	sd	s8, 304(sp)
	sd	s9, 312(sp)
	sd	s10, 320(sp)
	j	.LBB26_0
.LBB26_0:                               # %label_0
	mv	a3, a2
	mv	s10, a2
	lw	s10, 0(s10)
	addiw	t0, s10, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
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
	sd	t2, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 16(sp)
	addiw	t0, a5, -1
	sw	t0, 20(sp)
	addi	t0, a2, 4
	sd	t0, 24(sp)
	addi	t0, a2, 4
	sd	t0, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	addiw	t0, t0, 1
	sw	t0, 44(sp)
	ld	t0, 24(sp)
	lw	t1, 44(sp)
	sw	t1, 0(t0)
	lw	t0, 20(sp)
	mv	a4, t0
	j	.LBB26_33
.LBB26_15:                               # %label_15
	addi	t3, a2, 16
	addi	a6, a2, 16
	lw	a7, 0(a6)
	mulw	a6, a1, a1
	addw	t0, a7, a6
	sw	t0, 156(sp)
	lw	t1, 156(sp)
	sw	t1, 0(t3)
	ld	s0, 248(sp)
	ld	s1, 256(sp)
	ld	s2, 264(sp)
	ld	s3, 272(sp)
	ld	s4, 280(sp)
	ld	s5, 288(sp)
	ld	s7, 296(sp)
	ld	s8, 304(sp)
	ld	s9, 312(sp)
	ld	s10, 320(sp)
	li	a0, 0
	addi	sp, sp, 336
	ret
.LBB26_33:                               # %label_33
	mv	t0, a4
	bge	t0, x0, .LBB26_36
	j	.LBB26_35
.LBB26_34:                               # %label_34
	addi	t0, a2, 12
	sd	t0, 72(sp)
	addi	t0, a2, 12
	sd	t0, 80(sp)
	ld	t0, 80(sp)
	lw	t0, 0(t0)
	sw	t0, 88(sp)
	lw	t0, 88(sp)
	addiw	t0, t0, 1
	sw	t0, 92(sp)
	ld	t0, 72(sp)
	lw	t1, 92(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 96(sp)
	addi	t0, a2, 4
	sd	t0, 104(sp)
	ld	t0, 104(sp)
	lw	t0, 0(t0)
	sw	t0, 112(sp)
	lw	t0, 112(sp)
	addiw	t0, t0, 2
	sw	t0, 116(sp)
	ld	t0, 96(sp)
	lw	t1, 116(sp)
	sw	t1, 0(t0)
	addiw	t0, a4, 1
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 120(sp)
	mv	t0, a4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 136(sp)
	ld	t0, 136(sp)
	lw	t0, 0(t0)
	sw	t0, 144(sp)
	ld	t0, 120(sp)
	lw	t1, 144(sp)
	sw	t1, 0(t0)
	addi	s9, a2, 4
	addi	s8, a2, 4
	lw	s7, 0(s8)
	addiw	t0, s7, 2
	sw	t0, 148(sp)
	lw	t1, 148(sp)
	sw	t1, 0(s9)
	addiw	s5, a4, -1
	mv	a4, s5
	j	.LBB26_33
.LBB26_35:                               # %label_35
	addiw	s3, a4, 1
	mv	t0, s3
	li	t1, 4
	mul	t0, t0, t1
	add	s4, a0, t0
	lw	t1, 16(sp)
	sw	t1, 0(s4)
	addi	s2, a2, 4
	addi	s1, a2, 4
	lw	s0, 0(s1)
	addiw	t0, s0, 1
	sw	t0, 152(sp)
	lw	t1, 152(sp)
	sw	t1, 0(s2)
	addiw	t4, a5, 1
	mv	a5, t4
	j	.LBB26_13
.LBB26_36:                               # %label_36
	mv	t0, a4
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	lw	t1, 16(sp)
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
	j	.LBB27_0
.LBB27_0:                               # %label_0
	mv	s2, a3
	mv	a7, a3
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
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
	j	.LBB28_0
.LBB28_0:                               # %label_0
	mv	s2, a3
	mv	a7, a3
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
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
	j	.LBB29_0
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
	addi	sp, sp, -528
	sd	s0, 448(sp)
	sd	s1, 456(sp)
	sd	s3, 464(sp)
	sd	s4, 472(sp)
	sd	s5, 480(sp)
	sd	s7, 488(sp)
	sd	s8, 496(sp)
	sd	s10, 504(sp)
	sd	s11, 512(sp)
	j	.LBB30_0
.LBB30_0:                               # %label_0
	subw	s11, a2, a1
	addiw	t0, s11, 1
	sw	t0, 0(sp)
	subw	t0, a3, a2
	sw	t0, 4(sp)
	lw	t1, 0(sp)
	li	t0, 10000
	subw	s11, t0, t1
	li	a7, 0
.LBB30_26:                               # %label_26
	mv	t0, a7
	lw	t1, 0(sp)
	bge	t0, t1, .LBB30_28
.LBB30_27:                               # %label_27
	addw	t0, s11, a7
	sw	t0, 24(sp)
	lw	t0, 24(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 16(sp)
	addw	t0, a1, a7
	sw	t0, 40(sp)
	lw	t0, 40(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 32(sp)
	ld	t0, 32(sp)
	lw	t0, 0(t0)
	sw	t0, 44(sp)
	ld	t0, 16(sp)
	lw	t1, 44(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 48(sp)
	addi	t0, a4, 4
	sd	t0, 56(sp)
	ld	t0, 56(sp)
	lw	s10, 0(t0)
	addiw	t0, s10, 2
	sw	t0, 64(sp)
	ld	t0, 48(sp)
	lw	t1, 64(sp)
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
	lw	t1, 0(sp)
	blt	t0, t1, .LBB30_55
	j	.LBB30_54
.LBB30_53:                               # %label_53
	addi	t0, a4, 12
	sd	t0, 72(sp)
	addi	t0, a4, 12
	sd	t0, 80(sp)
	ld	t0, 80(sp)
	lw	t0, 0(t0)
	sw	t0, 88(sp)
	lw	t0, 88(sp)
	addiw	t0, t0, 1
	sw	t0, 92(sp)
	ld	t0, 72(sp)
	lw	t1, 92(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 96(sp)
	addi	t0, a4, 4
	sd	t0, 104(sp)
	ld	t0, 104(sp)
	lw	t0, 0(t0)
	sw	t0, 112(sp)
	lw	t0, 112(sp)
	addiw	t0, t0, 2
	sw	t0, 116(sp)
	ld	t0, 96(sp)
	lw	t1, 116(sp)
	sw	t1, 0(t0)
	addw	t0, s11, t3
	sw	t0, 128(sp)
	lw	t0, 128(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 120(sp)
	ld	t0, 120(sp)
	lw	t0, 0(t0)
	sw	t0, 132(sp)
	addiw	t0, a2, 1
	sw	t0, 144(sp)
	lw	t0, 144(sp)
	addw	t0, t0, s8
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 136(sp)
	ld	t0, 136(sp)
	lw	t0, 0(t0)
	sw	t0, 152(sp)
	lw	t0, 132(sp)
	lw	t1, 152(sp)
	bge	t1, t0, .LBB30_74
	j	.LBB30_75
.LBB30_54:                               # %label_54
	mv	t5, t3
	mv	a5, a7
	j	.LBB30_122
.LBB30_55:                               # %label_55
	mv	t0, s8
	lw	t1, 4(sp)
	blt	t0, t1, .LBB30_53
	j	.LBB30_54
.LBB30_74:                               # %label_74
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 160(sp)
	addw	t0, s11, t3
	sw	t0, 176(sp)
	lw	t0, 176(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 168(sp)
	ld	t0, 168(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	ld	t0, 160(sp)
	lw	t1, 180(sp)
	sw	t1, 0(t0)
	addiw	t0, t3, 1
	sw	t0, 184(sp)
	lw	t0, 184(sp)
	mv	t4, t0
	mv	a5, s8
	j	.LBB30_76
.LBB30_75:                               # %label_75
	mv	t0, a7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 192(sp)
	addiw	t0, a2, 1
	sw	t0, 208(sp)
	lw	t0, 208(sp)
	addw	t0, t0, s8
	sw	t0, 212(sp)
	lw	t0, 212(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 200(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 216(sp)
	ld	t0, 192(sp)
	lw	t1, 216(sp)
	sw	t1, 0(t0)
	addiw	t0, s8, 1
	sw	t0, 220(sp)
	lw	t0, 220(sp)
	mv	a5, t0
	mv	t4, t3
.LBB30_76:                               # %label_76
	addi	t0, a4, 4
	sd	t0, 224(sp)
	addi	t0, a4, 4
	sd	t0, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 240(sp)
	lw	t0, 240(sp)
	addiw	t0, t0, 1
	sw	t0, 244(sp)
	ld	t0, 224(sp)
	lw	t1, 244(sp)
	sw	t1, 0(t0)
	addiw	t0, a7, 1
	sw	t0, 248(sp)
	lw	t0, 248(sp)
	mv	a7, t0
	mv	t3, t4
	mv	s8, a5
	j	.LBB30_52
.LBB30_122:                               # %label_122
	mv	t0, t5
	lw	t1, 0(sp)
	bge	t0, t1, .LBB30_124
.LBB30_123:                               # %label_123
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 256(sp)
	addw	t0, s11, t5
	sw	t0, 272(sp)
	lw	t0, 272(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 264(sp)
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 276(sp)
	ld	t0, 256(sp)
	lw	t1, 276(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 280(sp)
	addi	t0, a4, 4
	sd	t0, 288(sp)
	ld	t0, 288(sp)
	lw	t0, 0(t0)
	sw	t0, 296(sp)
	lw	t0, 296(sp)
	addiw	t0, t0, 2
	sw	t0, 300(sp)
	ld	t0, 280(sp)
	lw	t1, 300(sp)
	sw	t1, 0(t0)
	addiw	t0, t5, 1
	sw	t0, 304(sp)
	addiw	t0, a5, 1
	sw	t0, 308(sp)
	lw	t0, 304(sp)
	mv	t5, t0
	lw	t0, 308(sp)
	mv	a5, t0
	j	.LBB30_122
.LBB30_124:                               # %label_124
	mv	a6, s8
.LBB30_147:                               # %label_147
	mv	t0, a6
	lw	t1, 4(sp)
	bge	t0, t1, .LBB30_149
.LBB30_148:                               # %label_148
	mv	t0, a5
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 320(sp)
	addiw	t0, a2, 1
	sw	t0, 336(sp)
	lw	t0, 336(sp)
	addw	s7, t0, a6
	mv	t0, s7
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 340(sp)
	ld	t0, 320(sp)
	lw	t1, 340(sp)
	sw	t1, 0(t0)
	addi	s5, a4, 4
	addi	s4, a4, 4
	lw	s3, 0(s4)
	addiw	t0, s3, 2
	sw	t0, 344(sp)
	lw	t1, 344(sp)
	sw	t1, 0(s5)
	addiw	s1, a6, 1
	addiw	s0, a5, 1
	mv	a6, s1
	mv	a5, s0
	j	.LBB30_147
.LBB30_149:                               # %label_149
	ld	s0, 448(sp)
	ld	s1, 456(sp)
	ld	s3, 464(sp)
	ld	s4, 472(sp)
	ld	s5, 480(sp)
	ld	s7, 488(sp)
	ld	s8, 496(sp)
	ld	s10, 504(sp)
	ld	s11, 512(sp)
	li	a0, 0
	addi	sp, sp, 528
	ret
.Lfunc_end30:
	.size	fn.22, .Lfunc_end30-fn.22
                                        # -- End function

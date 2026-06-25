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
	li	t6, -1003088
	add	sp, sp, t6
	li	t6, 1003048
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 1003040
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 1002968
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 1002960
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 1002952
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 1002944
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 1002936
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 1002928
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 1002920
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 1002912
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 1002904
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 1002896
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 1002712
	add	t6, t6, sp
	li	t0, 1002728
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1002688
	add	t6, t6, sp
	li	t0, 1002704
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 962656
	add	t6, t6, sp
	li	t0, 1002680
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 922624
	add	t6, t6, sp
	li	t0, 962648
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 882616
	add	t6, t6, sp
	li	t0, 922616
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842608
	add	t6, t6, sp
	li	t0, 882608
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842580
	add	t6, t6, sp
	li	t0, 842600
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842548
	add	t6, t6, sp
	li	t0, 842568
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842516
	add	t6, t6, sp
	li	t0, 842536
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842484
	add	t6, t6, sp
	li	t0, 842504
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842452
	add	t6, t6, sp
	li	t0, 842472
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 842420
	add	t6, t6, sp
	li	t0, 842440
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 802384
	add	t6, t6, sp
	li	t0, 842408
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 762352
	add	t6, t6, sp
	li	t0, 802376
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 722344
	add	t6, t6, sp
	li	t0, 762344
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682336
	add	t6, t6, sp
	li	t0, 722336
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682308
	add	t6, t6, sp
	li	t0, 682328
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682276
	add	t6, t6, sp
	li	t0, 682296
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682244
	add	t6, t6, sp
	li	t0, 682264
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682212
	add	t6, t6, sp
	li	t0, 682232
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682180
	add	t6, t6, sp
	li	t0, 682200
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 682148
	add	t6, t6, sp
	li	t0, 682168
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 642112
	add	t6, t6, sp
	li	t0, 682136
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 602080
	add	t6, t6, sp
	li	t0, 642104
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 562072
	add	t6, t6, sp
	li	t0, 602072
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 522064
	add	t6, t6, sp
	li	t0, 562064
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 482048
	add	t6, t6, sp
	li	t0, 522056
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 442032
	add	t6, t6, sp
	li	t0, 482040
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 402016
	add	t6, t6, sp
	li	t0, 442024
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 362000
	add	t6, t6, sp
	li	t0, 402008
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 321984
	add	t6, t6, sp
	li	t0, 361992
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 281968
	add	t6, t6, sp
	li	t0, 321976
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 241960
	add	t6, t6, sp
	li	t0, 281960
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 241552
	add	t6, t6, sp
	li	t0, 241952
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 241524
	add	t6, t6, sp
	li	t0, 241544
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 241492
	add	t6, t6, sp
	li	t0, 241512
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 201480
	add	t6, t6, sp
	li	t0, 241480
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 161472
	add	t6, t6, sp
	li	t0, 201472
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 161444
	add	t6, t6, sp
	li	t0, 161464
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 161412
	add	t6, t6, sp
	li	t0, 161432
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 121400
	add	t6, t6, sp
	li	t0, 161400
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 81392
	add	t6, t6, sp
	li	t0, 121392
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 81364
	add	t6, t6, sp
	li	t0, 81384
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 81332
	add	t6, t6, sp
	li	t0, 81352
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 41320
	add	t6, t6, sp
	li	t0, 81320
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1312
	add	t6, t6, sp
	li	t0, 41312
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1284
	add	t6, t6, sp
	sd	t6, 1304(sp)
	li	t6, 1252
	add	t6, t6, sp
	sd	t6, 1272(sp)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21001
	call	printlnInt
	li	t6, 1002704
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 1240(sp)
	ld	t0, 1240(sp)
	li	t1, 100
	sw	t1, 0(t0)
	li	t6, 1002704
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 1232(sp)
	ld	t0, 1232(sp)
	li	t1, 500
	sw	t1, 0(t0)
	li	t6, 1002704
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 1224(sp)
	ld	t0, 1224(sp)
	li	t1, 1000
	sw	t1, 0(t0)
	li	t6, 1002704
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 1216(sp)
	ld	t0, 1216(sp)
	li	t1, 2000
	sw	t1, 0(t0)
	li	t6, 1002728
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 1002704
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 16
	call	builtin_memcpy
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s3, 0
	li	t0, 0
	sd	t0, 464(sp)
	li	t0, 0
	sd	t0, 456(sp)
	li	t0, 0
	sd	t0, 448(sp)
	li	t0, 0
	sd	t0, 440(sp)
	li	t0, 0
	sd	t0, 432(sp)
	li	t0, 0
	sd	t0, 424(sp)
	li	t0, 0
	sd	t0, 416(sp)
	li	t0, 0
	sd	t0, 408(sp)
	li	t0, 0
	sd	t0, 400(sp)
	li	t0, 0
	sd	t0, 392(sp)
	li	t0, 0
	sd	t0, 384(sp)
	li	t0, 0
	sd	t0, 376(sp)
	li	t0, 0
	sd	t0, 368(sp)
	li	t0, 0
	sd	t0, 360(sp)
	li	t0, 0
	sd	t0, 352(sp)
.LBB8_7:                               # %label_7
	slti	t0, s3, 4
	sb	t0, 1215(sp)
	lbu	t0, 1215(sp)
	beqz	t0, .LBB8_9
.LBB8_8:                               # %label_8
	add	t0, s3, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 1002728
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	sd	t2, 1200(sp)
	ld	t0, 1200(sp)
	lw	t0, 0(t0)
	sw	t0, 1196(sp)
	li	t1, 100
	mulw	t0, s3, t1
	sw	t0, 1192(sp)
	lw	t1, 1192(sp)
	li	t6, 21000
	addw	t0, t1, t6
	sw	t0, 1188(sp)
	lw	t0, 1188(sp)
	addiw	t0, t0, 10
	sw	t0, 1184(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	lw	a0, 1184(sp)
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s2, 0
	ld	t0, 464(sp)
	add	t0, t0, x0
	sd	t0, 336(sp)
	ld	t0, 456(sp)
	add	t0, t0, x0
	sd	t0, 328(sp)
	ld	t0, 448(sp)
	add	t0, t0, x0
	sd	t0, 320(sp)
	ld	t0, 440(sp)
	add	t0, t0, x0
	sd	t0, 312(sp)
	ld	t0, 432(sp)
	add	t0, t0, x0
	sd	t0, 304(sp)
	ld	t0, 424(sp)
	add	t0, t0, x0
	sd	t0, 296(sp)
	ld	t0, 416(sp)
	add	t0, t0, x0
	sd	t0, 288(sp)
	ld	t0, 408(sp)
	add	t0, t0, x0
	sd	t0, 280(sp)
	ld	t0, 400(sp)
	add	t0, t0, x0
	sd	t0, 272(sp)
	ld	t0, 392(sp)
	add	t0, t0, x0
	sd	t0, 264(sp)
	ld	t0, 384(sp)
	add	t0, t0, x0
	sd	t0, 256(sp)
	ld	t0, 376(sp)
	add	t0, t0, x0
	sd	t0, 248(sp)
	ld	t0, 368(sp)
	add	t0, t0, x0
	sd	t0, 240(sp)
	ld	t0, 360(sp)
	add	t0, t0, x0
	sd	t0, 232(sp)
	ld	t0, 352(sp)
	add	t0, t0, x0
	sd	t0, 224(sp)
	j	.LBB8_21
.LBB8_9:                               # %label_9
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 0
	li	a1, 5000
	li	t6, 802376
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 802376
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 722336
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 762344
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 722336
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1176(sp)
	ld	a0, 1176(sp)
	li	t6, 762344
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 5000
	call	fn.2
	li	t6, 682296
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 682328
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 682296
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 762344
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 682328
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s6, 0
	li	s3, 0
	li	s2, 0
	li	a4, 0
	j	.LBB8_124
.LBB8_21:                               # %label_21
	slti	t0, s2, 8
	sb	t0, 1175(sp)
	lbu	t0, 1175(sp)
	beqz	t0, .LBB8_23
.LBB8_22:                               # %label_22
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	add	a0, s2, x0
	lw	a1, 1196(sp)
	li	t6, 962648
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 1002680
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 962648
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 882608
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 882608
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 1002680
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1160(sp)
	ld	a0, 1160(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	a1, 0(t6)
	lw	a2, 1196(sp)
	call	fn.2
	li	t6, 842568
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 842600
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 842568
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	li	t6, 842600
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.15
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	call	fn.1
	sb	a0, 1159(sp)
	lbu	t1, 1159(sp)
	li	t0, 1
	subw	t0, t0, t1
	sb	t0, 1158(sp)
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	lbu	t0, 1158(sp)
	beq	x0, t0, .LBB8_22_jump_0
	j	.LBB8_50
.LBB8_22_jump_0:                               # %label_22_jump_0
	j	.LBB8_51
.LBB8_23:                               # %label_23
	addiw	t0, s3, 1
	add	s6, t0, x0
	add	s3, s6, x0
	ld	t0, 336(sp)
	add	t0, t0, x0
	sd	t0, 464(sp)
	ld	t0, 328(sp)
	add	t0, t0, x0
	sd	t0, 456(sp)
	ld	t0, 320(sp)
	add	t0, t0, x0
	sd	t0, 448(sp)
	ld	t0, 312(sp)
	add	t0, t0, x0
	sd	t0, 440(sp)
	ld	t0, 304(sp)
	add	t0, t0, x0
	sd	t0, 432(sp)
	ld	t0, 296(sp)
	add	t0, t0, x0
	sd	t0, 424(sp)
	ld	t0, 288(sp)
	add	t0, t0, x0
	sd	t0, 416(sp)
	ld	t0, 280(sp)
	add	t0, t0, x0
	sd	t0, 408(sp)
	ld	t0, 272(sp)
	add	t0, t0, x0
	sd	t0, 400(sp)
	ld	t0, 264(sp)
	add	t0, t0, x0
	sd	t0, 392(sp)
	ld	t0, 256(sp)
	add	t0, t0, x0
	sd	t0, 384(sp)
	ld	t0, 248(sp)
	add	t0, t0, x0
	sd	t0, 376(sp)
	ld	t0, 240(sp)
	add	t0, t0, x0
	sd	t0, 368(sp)
	ld	t0, 232(sp)
	add	t0, t0, x0
	sd	t0, 360(sp)
	ld	t0, 224(sp)
	add	t0, t0, x0
	sd	t0, 352(sp)
	j	.LBB8_7
.LBB8_50:                               # %label_50
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21901
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_51:                               # %label_51
	li	t6, 1002680
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1144(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	ld	a0, 1144(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	a1, 0(t6)
	lw	a2, 1196(sp)
	call	fn.2
	li	t6, 842504
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 842536
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 842504
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	li	t6, 842536
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	call	fn.1
	add	t5, a0, x0
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t0, 1
	subw	t0, t0, t1
	add	t4, t0, x0
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	add	t0, t4, x0
	beqz	t0, .LBB8_71
.LBB8_70:                               # %label_70
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21902
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_71:                               # %label_71
	li	t6, 1002680
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1128(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	ld	a0, 1128(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	a1, 0(t6)
	lw	a2, 1196(sp)
	call	fn.2
	li	t6, 842440
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 842472
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 842440
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	li	t6, 842472
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 922616
	add	t6, sp, t6
	ld	a0, 0(t6)
	lw	a1, 1196(sp)
	call	fn.1
	add	s11, a0, x0
	li	t0, 1
	subw	t0, t0, s11
	add	s10, t0, x0
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	add	t0, s10, x0
	beqz	t0, .LBB8_91
.LBB8_90:                               # %label_90
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21903
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_91:                               # %label_91
	li	t6, 842600
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 1112(sp)
	ld	t0, 1112(sp)
	lw	t0, 0(t0)
	sw	t0, 1108(sp)
	lw	t0, 1108(sp)
	li	t1, 100
	divw	t0, t0, t1
	add	s9, t0, x0
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	add	a0, s9, x0
	call	printlnInt
	li	t6, 842536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 1096(sp)
	ld	t0, 1096(sp)
	lw	t0, 0(t0)
	sw	t0, 1092(sp)
	lw	t0, 1092(sp)
	li	t1, 100
	divw	t0, t0, t1
	add	s8, t0, x0
	add	a0, s8, x0
	call	printlnInt
	li	t6, 842472
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 1080(sp)
	ld	t0, 1080(sp)
	lw	t0, 0(t0)
	sw	t0, 1076(sp)
	lw	t0, 1076(sp)
	li	t1, 100
	divw	t0, t0, t1
	sw	t0, 1072(sp)
	lw	a0, 1072(sp)
	call	printlnInt
	addiw	t0, s2, 1
	add	s7, t0, x0
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 224(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 240(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 248(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 264(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 280(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 288(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 304(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 320(sp)
	li	t6, 922616
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 328(sp)
	ld	t0, 1160(sp)
	add	t0, t0, x0
	sd	t0, 336(sp)
	li	t6, 842600
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 312(sp)
	ld	t0, 1144(sp)
	add	t0, t0, x0
	sd	t0, 296(sp)
	li	t6, 842536
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 272(sp)
	ld	t0, 1128(sp)
	add	t0, t0, x0
	sd	t0, 256(sp)
	li	t6, 842472
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	sd	t0, 232(sp)
	add	s2, s7, x0
	j	.LBB8_21
.LBB8_124:                               # %label_124
	slti	t0, a4, 1000
	sb	t0, 1067(sp)
	lbu	t0, 1067(sp)
	beqz	t0, .LBB8_126
.LBB8_125:                               # %label_125
	li	t1, 73
	mulw	t0, a4, t1
	sw	t0, 1060(sp)
	lw	t0, 1060(sp)
	addiw	t0, t0, 29
	sw	t0, 1056(sp)
	lw	t0, 1056(sp)
	li	t1, 100000
	remw	t0, t0, t1
	sw	t0, 1052(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 682232
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 682264
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 682232
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1040(sp)
	ld	a0, 1040(sp)
	li	a1, 5000
	lw	a2, 1052(sp)
	li	t6, 682264
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.5
	sw	a0, 1036(sp)
	li	t6, 682168
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 682200
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 682168
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 762344
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	lw	a2, 1052(sp)
	li	t6, 682200
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.6
	add	s7, a0, x0
	lw	t0, 1036(sp)
	xori	t0, t0, -1
	sltu	t0, x0, t0
	sb	t0, 1031(sp)
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	lbu	t0, 1031(sp)
	beq	x0, t0, .LBB8_125_jump_0
	j	.LBB8_155
.LBB8_125_jump_0:                               # %label_125_jump_0
	j	.LBB8_156
.LBB8_126:                               # %label_126
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	add	a0, s6, x0
	call	printlnInt
	li	t1, 1000
	divw	t0, s3, t1
	add	s4, t0, x0
	add	a0, s4, x0
	call	printlnInt
	li	t1, 1000
	divw	t0, s2, t1
	add	s4, t0, x0
	add	a0, s4, x0
	call	printlnInt
	li	a0, 1
	li	a1, 300
	li	t6, 642104
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 682136
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 642104
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 682136
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 1008(sp)
	li	t6, 682136
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 1000(sp)
	ld	t0, 1000(sp)
	lw	t0, 0(t0)
	sw	t0, 996(sp)
	ld	a0, 1008(sp)
	li	a1, 300
	lw	a2, 996(sp)
	call	fn.16
	add	s4, a0, x0
	li	t6, 562064
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 602072
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 562064
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 682136
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 984(sp)
	ld	a0, 984(sp)
	li	t6, 602072
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 300
	call	fn.2
	li	t6, 602072
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 300
	call	fn.4
	add	s5, a0, x0
	li	t6, 682136
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 968(sp)
	ld	t0, 968(sp)
	lw	t0, 0(t0)
	sw	t0, 964(sp)
	lw	a0, 964(sp)
	call	printlnInt
	li	t1, 1000
	divw	t0, s4, t1
	add	s4, t0, x0
	add	a0, s4, x0
	call	printlnInt
	add	a0, s5, x0
	call	printlnInt
	li	a0, 50
	li	a1, 50
	li	a2, 1
	li	t6, 482040
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 522056
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 482040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	a0, 50
	li	a1, 50
	li	a2, 2
	li	t6, 402008
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 442024
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 402008
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 321976
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 952(sp)
	li	t6, 241952
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a3, 0
	j	.LBB8_217
.LBB8_155:                               # %label_155
	xori	t0, s7, -1
	sltu	t0, x0, t0
	sb	t0, 951(sp)
	lbu	t0, 951(sp)
	sb	t0, 950(sp)
	lbu	t0, 950(sp)
	add	t0, t0, x0
	sb	t0, 203(sp)
	j	.LBB8_157
.LBB8_156:                               # %label_156
	li	t0, 0
	sb	t0, 949(sp)
	lbu	t0, 949(sp)
	add	t0, t0, x0
	sb	t0, 203(sp)
.LBB8_157:                               # %label_157
	add	t0, s6, x0
	sw	t0, 196(sp)
	lbu	t0, 203(sp)
	beqz	t0, .LBB8_164
.LBB8_163:                               # %label_163
	addiw	t0, s6, 1
	sw	t0, 944(sp)
	lw	t0, 944(sp)
	add	t0, t0, x0
	sw	t0, 196(sp)
.LBB8_164:                               # %label_164
	li	t6, 682264
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	sd	t0, 936(sp)
	ld	t0, 936(sp)
	lw	t0, 0(t0)
	sw	t0, 932(sp)
	lw	t1, 932(sp)
	addw	t0, s3, t1
	sw	t0, 928(sp)
	li	t6, 682200
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	sd	t0, 920(sp)
	ld	t0, 920(sp)
	lw	t0, 0(t0)
	sw	t0, 916(sp)
	lw	t1, 916(sp)
	addw	t0, s2, t1
	sw	t0, 912(sp)
	addiw	t0, a4, 1
	sw	t0, 908(sp)
	lw	t0, 928(sp)
	add	s3, t0, x0
	lw	t0, 912(sp)
	add	s2, t0, x0
	lw	t0, 908(sp)
	add	a4, t0, x0
	lw	t0, 196(sp)
	add	s6, t0, x0
	j	.LBB8_124
.LBB8_217:                               # %label_217
	sltiu	t0, a3, 100
	sb	t0, 907(sp)
	lbu	t0, 907(sp)
	beqz	t0, .LBB8_219
.LBB8_218:                               # %label_218
	add	t0, a3, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 281960
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	sd	t2, 896(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	ld	t0, 896(sp)
	li	t6, 241952
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 400
	call	builtin_memcpy
	li	t6, 1003008
	add	t6, sp, t6
	ld	t0, 0(t6)
	addiw	t0, t0, 1
	sw	t0, 892(sp)
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	lw	t0, 892(sp)
	add	a3, t0, x0
	j	.LBB8_217
.LBB8_219:                               # %label_219
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	ld	t0, 952(sp)
	li	t6, 281960
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 321976
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 880(sp)
	ld	t0, 880(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 321976
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 872(sp)
	ld	t0, 872(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 361992
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 321976
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 522056
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 442024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 361992
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.3
	sb	a0, 871(sp)
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	lbu	t0, 871(sp)
	beqz	t0, .LBB8_236
.LBB8_235:                               # %label_235
	li	a3, 0
	li	a2, 0
	j	.LBB8_239
.LBB8_236:                               # %label_236
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 241512
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 241512
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a5, 0
	li	a1, 0
	j	.LBB8_268
.LBB8_239:                               # %label_239
	slti	t0, a2, 50
	sb	t0, 870(sp)
	lbu	t0, 870(sp)
	beqz	t0, .LBB8_241
.LBB8_240:                               # %label_240
	li	a1, 0
	add	a4, a3, x0
	j	.LBB8_245
.LBB8_241:                               # %label_241
	li	t1, 1000000000
	remw	t0, a3, t1
	sw	t0, 864(sp)
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	lw	a0, 864(sp)
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	j	.LBB8_236
.LBB8_245:                               # %label_245
	slti	t0, a1, 50
	sb	t0, 863(sp)
	lbu	t0, 863(sp)
	beqz	t0, .LBB8_247
.LBB8_246:                               # %label_246
	li	t6, 361992
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 848(sp)
	add	t0, a2, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 848(sp)
	add	t2, t1, t0
	sd	t2, 840(sp)
	add	t0, a1, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 840(sp)
	add	t2, t1, t0
	sd	t2, 832(sp)
	ld	t0, 832(sp)
	lw	t0, 0(t0)
	sw	t0, 828(sp)
	lw	t1, 828(sp)
	addw	t0, a4, t1
	sw	t0, 824(sp)
	lw	t0, 824(sp)
	li	t6, 1000000000
	and	t0, t0, t6
	sw	t0, 820(sp)
	addiw	t0, a1, 1
	sw	t0, 816(sp)
	lw	t0, 820(sp)
	add	a4, t0, x0
	lw	t0, 816(sp)
	add	a1, t0, x0
	j	.LBB8_245
.LBB8_247:                               # %label_247
	addiw	t0, a2, 1
	sw	t0, 812(sp)
	lw	t0, 812(sp)
	add	a2, t0, x0
	add	a3, a4, x0
	j	.LBB8_239
.LBB8_268:                               # %label_268
	li	t6, 5000
	slt	t0, a5, t6
	sb	t0, 811(sp)
	lbu	t0, 811(sp)
	beqz	t0, .LBB8_270
.LBB8_269:                               # %label_269
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 800(sp)
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 800(sp)
	add	t2, t1, t0
	sd	t2, 792(sp)
	ld	t0, 792(sp)
	lw	t0, 0(t0)
	sw	t0, 788(sp)
	lw	t1, 788(sp)
	addw	t0, a1, t1
	sw	t0, 784(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 776(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 768(sp)
	ld	t0, 768(sp)
	lw	t0, 0(t0)
	sw	t0, 764(sp)
	lw	t0, 764(sp)
	addiw	t0, t0, 1
	sw	t0, 760(sp)
	ld	t0, 776(sp)
	lw	t1, 760(sp)
	sw	t1, 0(t0)
	addiw	t0, a5, 1
	sw	t0, 756(sp)
	lw	t0, 784(sp)
	add	a1, t0, x0
	lw	t0, 756(sp)
	add	a5, t0, x0
	j	.LBB8_268
.LBB8_270:                               # %label_270
	li	a6, 0
	li	a2, 0
.LBB8_286:                               # %label_286
	li	t6, 5000
	slt	t0, a6, t6
	sb	t0, 755(sp)
	lbu	t0, 755(sp)
	beqz	t0, .LBB8_288
.LBB8_287:                               # %label_287
	li	t1, 11241
	mulw	t0, a6, t1
	sw	t0, 748(sp)
	lw	t0, 748(sp)
	li	t6, 12345
	addw	t0, t0, t6
	sw	t0, 744(sp)
	lw	t0, 744(sp)
	li	t1, 5000
	remw	t0, t0, t1
	sw	t0, 740(sp)
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 728(sp)
	lw	t0, 740(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 728(sp)
	add	t2, t1, t0
	sd	t2, 720(sp)
	ld	t0, 720(sp)
	lw	t0, 0(t0)
	sw	t0, 716(sp)
	lw	t1, 716(sp)
	addw	t0, a2, t1
	sw	t0, 712(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 704(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 696(sp)
	ld	t0, 696(sp)
	lw	t0, 0(t0)
	sw	t0, 692(sp)
	lw	t0, 692(sp)
	addiw	t0, t0, 1
	sw	t0, 688(sp)
	ld	t0, 704(sp)
	lw	t1, 688(sp)
	sw	t1, 0(t0)
	addiw	t0, a6, 1
	sw	t0, 684(sp)
	lw	t0, 712(sp)
	add	a2, t0, x0
	lw	t0, 684(sp)
	add	a6, t0, x0
	j	.LBB8_286
.LBB8_288:                               # %label_288
	li	a7, 0
	li	a3, 0
.LBB8_309:                               # %label_309
	slti	t0, a7, 1000
	sb	t0, 683(sp)
	lbu	t0, 683(sp)
	beqz	t0, .LBB8_311
.LBB8_310:                               # %label_310
	li	t1, 5
	mulw	t0, a7, t1
	sw	t0, 676(sp)
	lw	t0, 676(sp)
	li	t1, 5000
	remw	t0, t0, t1
	sw	t0, 672(sp)
	li	t6, 842408
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 664(sp)
	lw	t0, 672(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 664(sp)
	add	t2, t1, t0
	sd	t2, 656(sp)
	ld	t0, 656(sp)
	lw	t0, 0(t0)
	sw	t0, 652(sp)
	lw	t1, 652(sp)
	addw	t0, a3, t1
	sw	t0, 648(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 640(sp)
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 632(sp)
	ld	t0, 632(sp)
	lw	t0, 0(t0)
	sw	t0, 628(sp)
	lw	t0, 628(sp)
	addiw	t0, t0, 1
	sw	t0, 624(sp)
	ld	t0, 640(sp)
	lw	t1, 624(sp)
	sw	t1, 0(t0)
	addiw	t0, a7, 1
	sw	t0, 620(sp)
	lw	t0, 648(sp)
	add	a3, t0, x0
	lw	t0, 620(sp)
	add	a7, t0, x0
	j	.LBB8_309
.LBB8_311:                               # %label_311
	li	t1, 1000
	divw	t0, a1, t1
	add	t3, t0, x0
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1003016
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 1000
	divw	t0, t0, t1
	add	t3, t0, x0
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1003008
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 100
	divw	t0, t0, t1
	add	t3, t0, x0
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 241544
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 600(sp)
	ld	t0, 600(sp)
	lw	t0, 0(t0)
	sw	t0, 596(sp)
	lw	t0, 596(sp)
	li	t1, 1000
	divw	t0, t0, t1
	add	t3, t0, x0
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a0, 0
.LBB8_342:                               # %label_342
	li	t6, 10000
	sltu	t0, a0, t6
	sb	t0, 591(sp)
	lbu	t0, 591(sp)
	beqz	t0, .LBB8_344
.LBB8_343:                               # %label_343
	add	t0, a0, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 201472
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	sd	t2, 576(sp)
	ld	t0, 576(sp)
	li	t1, 42
	sw	t1, 0(t0)
	addiw	t0, a0, 1
	sw	t0, 572(sp)
	lw	t0, 572(sp)
	add	a0, t0, x0
	j	.LBB8_342
.LBB8_344:                               # %label_344
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 241480
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 201472
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 161432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 161464
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 161432
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 241480
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 161464
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 161464
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 560(sp)
	ld	t0, 560(sp)
	lw	t0, 0(t0)
	sw	t0, 556(sp)
	lw	t0, 556(sp)
	li	t1, 100
	divw	t0, t0, t1
	sw	t0, 552(sp)
	lw	a0, 552(sp)
	call	printlnInt
	li	t6, 121392
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 161400
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 121392
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t0, 0
	sw	t0, 148(sp)
	li	a1, 0
	li	a0, 0
.LBB8_362:                               # %label_362
	lw	t0, 148(sp)
	slti	t0, t0, 1000
	sb	t0, 551(sp)
	lbu	t0, 551(sp)
	beqz	t0, .LBB8_364
.LBB8_363:                               # %label_363
	lw	t0, 148(sp)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 161400
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	sd	t2, 536(sp)
	lw	t0, 148(sp)
	li	t1, 2
	remw	t0, t0, t1
	sw	t0, 532(sp)
	lw	t0, 532(sp)
	sltiu	t0, t0, 1
	sb	t0, 531(sp)
	lbu	t0, 531(sp)
	beq	x0, t0, .LBB8_363_jump_0
	j	.LBB8_372
.LBB8_363_jump_0:                               # %label_363_jump_0
	j	.LBB8_373
.LBB8_364:                               # %label_364
	li	t6, 1003080
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 81352
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 81384
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 81352
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 161400
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 81384
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 81384
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 520(sp)
	ld	t0, 520(sp)
	lw	t0, 0(t0)
	sw	t0, 516(sp)
	lw	t0, 516(sp)
	li	t1, 100
	divw	t0, t0, t1
	sw	t0, 512(sp)
	lw	a0, 512(sp)
	call	printlnInt
	li	t6, 41312
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 81320
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 41312
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 81320
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 504(sp)
	ld	t0, 504(sp)
	li	t1, 123
	sw	t1, 0(t0)
	ld	a0, 1272(sp)
	call	fn.12
	ld	t0, 1304(sp)
	ld	t1, 1272(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 81320
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1
	ld	a2, 1304(sp)
	call	fn.13
	li	t6, 81320
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 496(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 492(sp)
	lw	a0, 492(sp)
	call	printlnInt
	li	a0, 21999
	call	printlnInt
	li	t6, 1003080
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1003032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1003024
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1003016
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1003008
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1003000
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002992
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002984
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002976
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002888
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002880
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002872
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 1003048
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 1003040
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 1002968
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 1002960
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 1002952
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 1002944
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 1002936
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 1002928
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 1002920
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 1002912
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 1002904
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 1002896
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 1003088
	add	sp, sp, t6
	ret
.LBB8_372:                               # %label_372
	li	t0, 1
	sw	t0, 488(sp)
	li	s1, 1
	lw	t0, 488(sp)
	add	t0, t0, x0
	sw	t0, 132(sp)
	add	s0, a0, x0
	j	.LBB8_374
.LBB8_373:                               # %label_373
	li	t0, 2
	sw	t0, 484(sp)
	li	s0, 2
	lw	t0, 484(sp)
	add	t0, t0, x0
	sw	t0, 132(sp)
	add	s1, a1, x0
.LBB8_374:                               # %label_374
	ld	t0, 536(sp)
	lw	t1, 132(sp)
	sw	t1, 0(t0)
	lw	t0, 148(sp)
	addiw	t0, t0, 1
	sw	t0, 480(sp)
	lw	t0, 480(sp)
	add	t0, t0, x0
	sw	t0, 148(sp)
	add	a1, s1, x0
	add	a0, s0, x0
	j	.LBB8_362
.Lfunc_end8:
	.size	fn.0, .Lfunc_end8-fn.0
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -528
	sd	s0, 488(sp)
	sd	s1, 480(sp)
	j	.LBB9_0
.LBB9_0:                               # %label_0
	li	s0, 0
.LBB9_5:                               # %label_5
	addiw	t0, a1, -1
	add	a4, t0, x0
	slt	a3, s0, a4
	add	t0, a3, x0
	beqz	t0, .LBB9_7
.LBB9_6:                               # %label_6
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 160(sp)
	ld	t0, 160(sp)
	lw	t0, 0(t0)
	sw	t0, 156(sp)
	addiw	t0, s0, 1
	add	a2, t0, x0
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 144(sp)
	ld	t0, 144(sp)
	lw	t0, 0(t0)
	sw	t0, 140(sp)
	lw	t0, 156(sp)
	lw	t1, 140(sp)
	slt	a2, t1, t0
	add	t0, a2, x0
	beq	x0, t0, .LBB9_6_jump_0
	j	.LBB9_22
.LBB9_6_jump_0:                               # %label_6_jump_0
	j	.LBB9_23
.LBB9_7:                               # %label_7
	ld	s0, 488(sp)
	ld	s1, 480(sp)
	li	a0, 1
	addi	sp, sp, 528
	ret
.LBB9_22:                               # %label_22
	ld	s0, 488(sp)
	ld	s1, 480(sp)
	li	a0, 0
	addi	sp, sp, 528
	ret
.LBB9_23:                               # %label_23
	addiw	t0, s0, 1
	add	s1, t0, x0
	add	s0, s1, x0
	j	.LBB9_5
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.globl	fn.2                            # -- Begin function fn.2
	.p2align	1
	.type	fn.2,@function
fn.2:                                   # @fn.2
# %bb.0:                                # %alloca
	addi	sp, sp, -528
	sd	s0, 488(sp)
	sd	s1, 480(sp)
	j	.LBB10_0
.LBB10_0:                               # %label_0
	li	s0, 0
.LBB10_7:                               # %label_7
	slt	a3, s0, a2
	add	t0, a3, x0
	beqz	t0, .LBB10_9
.LBB10_8:                               # %label_8
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a1, t0
	sd	t2, 160(sp)
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	ld	t0, 160(sp)
	lw	t1, 148(sp)
	sw	t1, 0(t0)
	addiw	t0, s0, 1
	add	s1, t0, x0
	add	s0, s1, x0
	j	.LBB10_7
.LBB10_9:                               # %label_9
	ld	s0, 488(sp)
	ld	s1, 480(sp)
	li	a0, 0
	addi	sp, sp, 528
	ret
.Lfunc_end10:
	.size	fn.2, .Lfunc_end10-fn.2
                                        # -- End function
	.globl	fn.3                            # -- Begin function fn.3
	.p2align	1
	.type	fn.3,@function
fn.3:                                   # @fn.3
# %bb.0:                                # %alloca
	addi	sp, sp, -800
	sd	s0, 760(sp)
	sd	s1, 752(sp)
	sd	s2, 680(sp)
	sd	s4, 664(sp)
	sd	s5, 656(sp)
	sd	s6, 648(sp)
	sd	s7, 640(sp)
	j	.LBB11_0
.LBB11_0:                               # %label_0
	addi	t0, a0, 0
	sd	t0, 440(sp)
	ld	t0, 440(sp)
	lw	t0, 0(t0)
	sw	t0, 436(sp)
	addi	t0, a1, 4
	sd	t0, 424(sp)
	ld	t0, 424(sp)
	lw	t0, 0(t0)
	sw	t0, 420(sp)
	lw	t0, 436(sp)
	lw	t1, 420(sp)
	sub	t0, t0, t1
	sltu	s0, x0, t0
	add	t0, s0, x0
	beqz	t0, .LBB11_14
.LBB11_13:                               # %label_13
	ld	s0, 760(sp)
	ld	s1, 752(sp)
	ld	s2, 680(sp)
	ld	s4, 664(sp)
	ld	s5, 656(sp)
	ld	s6, 648(sp)
	ld	s7, 640(sp)
	li	a0, 0
	addi	sp, sp, 800
	ret
.LBB11_14:                               # %label_14
	addi	t0, a2, 4
	sd	t0, 408(sp)
	addi	t0, a0, 4
	sd	t0, 400(sp)
	ld	t0, 400(sp)
	lw	t0, 0(t0)
	sw	t0, 396(sp)
	ld	t0, 408(sp)
	lw	t1, 396(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 0
	sd	t0, 384(sp)
	addi	t0, a1, 0
	sd	t0, 376(sp)
	ld	t0, 376(sp)
	lw	t0, 0(t0)
	sw	t0, 372(sp)
	ld	t0, 384(sp)
	lw	t1, 372(sp)
	sw	t1, 0(t0)
	li	a5, 0
	li	s0, 0
.LBB11_26:                               # %label_26
	addi	t0, a0, 4
	sd	t0, 360(sp)
	ld	t0, 360(sp)
	lw	t0, 0(t0)
	sw	t0, 356(sp)
	lw	t1, 356(sp)
	slt	s7, a5, t1
	add	t0, s7, x0
	beqz	t0, .LBB11_28
.LBB11_27:                               # %label_27
	li	a4, 0
	add	s1, s0, x0
	j	.LBB11_35
.LBB11_28:                               # %label_28
	ld	s0, 760(sp)
	ld	s1, 752(sp)
	ld	s2, 680(sp)
	ld	s4, 664(sp)
	ld	s5, 656(sp)
	ld	s6, 648(sp)
	ld	s7, 640(sp)
	li	a0, 1
	addi	sp, sp, 800
	ret
.LBB11_35:                               # %label_35
	addi	t0, a1, 0
	sd	t0, 344(sp)
	ld	t0, 344(sp)
	lw	t0, 0(t0)
	sw	t0, 340(sp)
	lw	t1, 340(sp)
	slt	s6, a4, t1
	add	t0, s6, x0
	beqz	t0, .LBB11_37
.LBB11_36:                               # %label_36
	addi	t0, a2, 8
	sd	t0, 328(sp)
	add	t0, a5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 328(sp)
	add	t2, t1, t0
	sd	t2, 320(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 320(sp)
	add	t2, t1, t0
	sd	t2, 312(sp)
	ld	t0, 312(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	a3, 0
	j	.LBB11_50
.LBB11_37:                               # %label_37
	addiw	t0, a5, 1
	add	a6, t0, x0
	add	a5, a6, x0
	add	s0, s1, x0
	j	.LBB11_26
.LBB11_50:                               # %label_50
	addi	t0, a0, 0
	sd	t0, 296(sp)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 292(sp)
	lw	t1, 292(sp)
	slt	s5, a3, t1
	add	t0, s5, x0
	beqz	t0, .LBB11_52
.LBB11_51:                               # %label_51
	addi	t0, a2, 8
	sd	t0, 280(sp)
	add	t0, a5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 280(sp)
	add	t2, t1, t0
	sd	t2, 272(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 272(sp)
	add	t2, t1, t0
	sd	t2, 264(sp)
	addi	t0, a2, 8
	sd	t0, 256(sp)
	add	t0, a5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 256(sp)
	add	t2, t1, t0
	sd	t2, 248(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 248(sp)
	add	t2, t1, t0
	sd	t2, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 236(sp)
	addi	t0, a0, 8
	sd	t0, 224(sp)
	add	t0, a5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 224(sp)
	add	t2, t1, t0
	sd	t2, 216(sp)
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 216(sp)
	add	t2, t1, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 204(sp)
	addi	t0, a1, 8
	sd	t0, 192(sp)
	add	t0, a3, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 192(sp)
	add	t2, t1, t0
	sd	t2, 184(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 184(sp)
	add	t2, t1, t0
	sd	t2, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 172(sp)
	lw	t0, 204(sp)
	lw	t1, 172(sp)
	mulw	t0, t0, t1
	add	s4, t0, x0
	lw	t0, 236(sp)
	addw	t0, t0, s4
	sw	t0, 164(sp)
	ld	t0, 264(sp)
	lw	t1, 164(sp)
	sw	t1, 0(t0)
	addiw	t0, a3, 1
	add	s2, t0, x0
	add	a3, s2, x0
	j	.LBB11_50
.LBB11_52:                               # %label_52
	addiw	t0, a4, 1
	add	a7, t0, x0
	add	a4, a7, x0
	add	s1, a3, x0
	j	.LBB11_35
.Lfunc_end11:
	.size	fn.3, .Lfunc_end11-fn.3
                                        # -- End function
	.globl	fn.4                            # -- Begin function fn.4
	.p2align	1
	.type	fn.4,@function
fn.4:                                   # @fn.4
# %bb.0:                                # %alloca
	addi	sp, sp, -640
	sd	s0, 600(sp)
	sd	s1, 592(sp)
	li	t6, 260
	add	t6, t6, sp
	sd	t6, 280(sp)
	li	t6, 228
	add	t6, t6, sp
	sd	t6, 248(sp)
	j	.LBB12_0
.LBB12_0:                               # %label_0
	sd	ra, 632(sp)
	sd	a0, 584(sp)
	sd	a1, 576(sp)
	ld	a0, 248(sp)
	call	fn.12
	ld	t0, 280(sp)
	ld	t1, 248(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	ld	a0, 584(sp)
	ld	a1, 576(sp)
	ld	a2, 280(sp)
	call	fn.21
	ld	t0, 576(sp)
	li	t1, 2
	remw	t0, t0, t1
	add	s1, t0, x0
	sltiu	s1, s1, 1
	ld	ra, 632(sp)
	ld	a0, 584(sp)
	ld	a1, 576(sp)
	add	t0, s1, x0
	beqz	t0, .LBB12_14
.LBB12_13:                               # %label_13
	li	t1, 2
	divuw	t0, a1, t1
	add	s0, t0, x0
	addiw	t0, s0, -1
	sw	t0, 212(sp)
	lw	t0, 212(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 200(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 196(sp)
	li	t1, 2
	divuw	t0, a1, t1
	add	s0, t0, x0
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 184(sp)
	ld	t0, 184(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 196(sp)
	lw	t1, 180(sp)
	addw	t0, t0, t1
	add	s0, t0, x0
	li	t1, 2
	divw	t0, s0, t1
	add	s0, t0, x0
	add	s0, s0, x0
	add	t0, s0, x0
	sw	t0, 140(sp)
	j	.LBB12_15
.LBB12_14:                               # %label_14
	li	t1, 2
	divuw	t0, a1, t1
	add	s0, t0, x0
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	add	s0, t0, x0
	add	t0, s0, x0
	sw	t0, 140(sp)
.LBB12_15:                               # %label_15
	lw	a0, 140(sp)
	ld	s0, 600(sp)
	ld	s1, 592(sp)
	addi	sp, sp, 640
	ret
.Lfunc_end12:
	.size	fn.4, .Lfunc_end12-fn.4
                                        # -- End function
	.globl	fn.5                            # -- Begin function fn.5
	.p2align	1
	.type	fn.5,@function
fn.5:                                   # @fn.5
# %bb.0:                                # %alloca
	addi	sp, sp, -640
	sd	s1, 592(sp)
	sd	s2, 520(sp)
	j	.LBB13_0
.LBB13_0:                               # %label_0
	addi	t0, a3, 0
	sd	t0, 280(sp)
	addi	t0, a3, 0
	sd	t0, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 268(sp)
	addiw	t0, t0, 1
	sw	t0, 264(sp)
	ld	t0, 280(sp)
	lw	t1, 264(sp)
	sw	t1, 0(t0)
	li	t0, 0
	sw	t0, 132(sp)
.LBB13_15:                               # %label_15
	lw	t0, 132(sp)
	slt	s2, t0, a1
	add	t0, s2, x0
	beqz	t0, .LBB13_17
.LBB13_16:                               # %label_16
	addi	t0, a3, 12
	sd	t0, 248(sp)
	addi	t0, a3, 12
	sd	t0, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 236(sp)
	lw	t0, 236(sp)
	addiw	t0, t0, 1
	sw	t0, 232(sp)
	ld	t0, 248(sp)
	lw	t1, 232(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 224(sp)
	addi	t0, a3, 4
	sd	t0, 216(sp)
	ld	t0, 216(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	lw	t0, 212(sp)
	addiw	t0, t0, 1
	sw	t0, 208(sp)
	ld	t0, 224(sp)
	lw	t1, 208(sp)
	sw	t1, 0(t0)
	lw	t0, 132(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 200(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 196(sp)
	lw	t0, 196(sp)
	sub	t0, t0, a2
	sltiu	a5, t0, 1
	add	t0, a5, x0
	beq	x0, t0, .LBB13_16_jump_0
	j	.LBB13_39
.LBB13_16_jump_0:                               # %label_16_jump_0
	j	.LBB13_40
.LBB13_17:                               # %label_17
	addi	t0, a3, 16
	sd	t0, 184(sp)
	addi	t0, a3, 16
	sd	t0, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 172(sp)
	lw	t0, 172(sp)
	addw	t0, t0, a1
	sw	t0, 168(sp)
	ld	t0, 184(sp)
	lw	t1, 168(sp)
	sw	t1, 0(t0)
	ld	s1, 592(sp)
	ld	s2, 520(sp)
	li	a0, -1
	addi	sp, sp, 640
	ret
.LBB13_39:                               # %label_39
	addi	t0, a3, 16
	sd	t0, 160(sp)
	addi	t0, a3, 16
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	lw	t1, 132(sp)
	addw	t0, t0, t1
	add	s1, t0, x0
	addiw	t0, s1, 1
	sw	t0, 140(sp)
	ld	t0, 160(sp)
	lw	t1, 140(sp)
	sw	t1, 0(t0)
	lw	a0, 132(sp)
	ld	s1, 592(sp)
	ld	s2, 520(sp)
	addi	sp, sp, 640
	ret
.LBB13_40:                               # %label_40
	lw	t0, 132(sp)
	addiw	t0, t0, 1
	add	a4, t0, x0
	add	t0, a4, x0
	sw	t0, 132(sp)
	j	.LBB13_15
.Lfunc_end13:
	.size	fn.5, .Lfunc_end13-fn.5
                                        # -- End function
	.globl	fn.6                            # -- Begin function fn.6
	.p2align	1
	.type	fn.6,@function
fn.6:                                   # @fn.6
# %bb.0:                                # %alloca
	addi	sp, sp, -688
	sd	s0, 648(sp)
	sd	s1, 640(sp)
	sd	s2, 568(sp)
	sd	s3, 560(sp)
	sd	s5, 544(sp)
	sd	s7, 528(sp)
	j	.LBB14_0
.LBB14_0:                               # %label_0
	addi	t0, a3, 0
	sd	t0, 328(sp)
	addi	t0, a3, 0
	sd	t0, 320(sp)
	ld	t0, 320(sp)
	lw	t0, 0(t0)
	sw	t0, 316(sp)
	lw	t0, 316(sp)
	addiw	t0, t0, 1
	sw	t0, 312(sp)
	ld	t0, 328(sp)
	lw	t1, 312(sp)
	sw	t1, 0(t0)
	addiw	t0, a1, -1
	add	s1, t0, x0
	li	a4, 0
	add	s0, s1, x0
.LBB14_18:                               # %label_18
	slt	t0, s0, a4
	xori	s7, t0, 1
	add	t0, s7, x0
	beqz	t0, .LBB14_20
.LBB14_19:                               # %label_19
	subw	t0, s0, a4
	add	s5, t0, x0
	li	t1, 2
	divw	t0, s5, t1
	add	s5, t0, x0
	addw	t0, a4, s5
	sw	t0, 292(sp)
	addi	t0, a3, 12
	sd	t0, 280(sp)
	addi	t0, a3, 12
	sd	t0, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 268(sp)
	addiw	t0, t0, 1
	sw	t0, 264(sp)
	ld	t0, 280(sp)
	lw	t1, 264(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 256(sp)
	addi	t0, a3, 4
	sd	t0, 248(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	lw	t0, 244(sp)
	addiw	t0, t0, 1
	sw	t0, 240(sp)
	ld	t0, 256(sp)
	lw	t1, 240(sp)
	sw	t1, 0(t0)
	lw	t0, 292(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	sub	t0, t0, a2
	sltiu	s5, t0, 1
	add	t0, s5, x0
	beq	x0, t0, .LBB14_19_jump_0
	j	.LBB14_49
.LBB14_19_jump_0:                               # %label_19_jump_0
	j	.LBB14_50
.LBB14_20:                               # %label_20
	ld	s0, 648(sp)
	ld	s1, 640(sp)
	ld	s2, 568(sp)
	ld	s3, 560(sp)
	ld	s5, 544(sp)
	ld	s7, 528(sp)
	li	a0, -1
	addi	sp, sp, 688
	ret
.LBB14_49:                               # %label_49
	addi	t0, a3, 16
	sd	t0, 216(sp)
	addi	t0, a3, 16
	sd	t0, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 204(sp)
	lw	t0, 204(sp)
	addiw	t0, t0, 1
	sw	t0, 200(sp)
	ld	t0, 216(sp)
	lw	t1, 200(sp)
	sw	t1, 0(t0)
	lw	a0, 292(sp)
	ld	s0, 648(sp)
	ld	s1, 640(sp)
	ld	s2, 568(sp)
	ld	s3, 560(sp)
	ld	s5, 544(sp)
	ld	s7, 528(sp)
	addi	sp, sp, 688
	ret
.LBB14_50:                               # %label_50
	lw	t0, 292(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	slt	s3, t0, a2
	add	t0, s3, x0
	beq	x0, t0, .LBB14_50_jump_0
	j	.LBB14_65
.LBB14_50_jump_0:                               # %label_50_jump_0
	j	.LBB14_66
.LBB14_51:                               # %label_51
	addi	t0, a3, 16
	sd	t0, 176(sp)
	addi	t0, a3, 16
	sd	t0, 168(sp)
	ld	t0, 168(sp)
	lw	t0, 0(t0)
	sw	t0, 164(sp)
	lw	t0, 164(sp)
	addiw	t0, t0, 1
	sw	t0, 160(sp)
	ld	t0, 176(sp)
	lw	t1, 160(sp)
	sw	t1, 0(t0)
	add	a4, a5, x0
	add	s0, s1, x0
	j	.LBB14_18
.LBB14_65:                               # %label_65
	lw	t0, 292(sp)
	addiw	t0, t0, 1
	add	s2, t0, x0
	add	a5, s2, x0
	add	s1, s0, x0
	j	.LBB14_67
.LBB14_66:                               # %label_66
	lw	t0, 292(sp)
	addiw	t0, t0, -1
	add	a7, t0, x0
	add	s1, a7, x0
	add	a5, a4, x0
.LBB14_67:                               # %label_67
	j	.LBB14_51
.Lfunc_end14:
	.size	fn.6, .Lfunc_end14-fn.6
                                        # -- End function
	.globl	fn.7                            # -- Begin function fn.7
	.p2align	1
	.type	fn.7,@function
fn.7:                                   # @fn.7
# %bb.0:                                # %alloca
	li	t6, -121216
	add	sp, sp, t6
	li	t6, 121176
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 121168
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 121096
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 121088
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 121080
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 121072
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 121064
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 121056
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 121040
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 121032
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 121024
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 80848
	add	t6, t6, sp
	li	t0, 120856
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40832
	add	t6, t6, sp
	li	t0, 80840
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 824
	add	t6, t6, sp
	li	t0, 40824
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 416
	add	t6, t6, sp
	sd	t6, 816(sp)
	j	.LBB15_0
.LBB15_0:                               # %label_0
	li	t6, 80840
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 408(sp)
	li	t6, 121208
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	sd	t4, 0(t6)
	ld	t0, 816(sp)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	li	t6, 121208
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	s0, 0
.LBB15_14:                               # %label_14
	sltiu	a6, s0, 100
	add	t0, a6, x0
	beqz	t0, .LBB15_16
.LBB15_15:                               # %label_15
	add	t0, s0, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 40824
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	sd	t2, 392(sp)
	li	t6, 121208
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	sd	t4, 0(t6)
	ld	t0, 392(sp)
	ld	t1, 816(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 400
	call	builtin_memcpy
	addiw	t0, s0, 1
	add	s1, t0, x0
	li	t6, 121208
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	ld	t4, 0(t6)
	add	s0, s1, x0
	j	.LBB15_14
.LBB15_16:                               # %label_16
	li	t6, 121208
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	sd	t4, 0(t6)
	ld	t0, 408(sp)
	li	t6, 40824
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 80840
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 376(sp)
	ld	t0, 376(sp)
	li	t6, 121160
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 80840
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 368(sp)
	ld	t0, 368(sp)
	li	t6, 121152
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 120856
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 80840
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 121208
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	s5, 0
	li	a6, 0
	li	s0, 0
.LBB15_28:                               # %label_28
	slt	t0, s5, a0
	sb	t0, 367(sp)
	lbu	t0, 367(sp)
	beqz	t0, .LBB15_30
.LBB15_29:                               # %label_29
	li	s4, 0
	add	a7, a6, x0
	add	s1, s0, x0
	j	.LBB15_35
.LBB15_30:                               # %label_30
	li	t6, 121208
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120856
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 121208
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 121160
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 121152
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 121144
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 121136
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 121128
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 121120
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 121112
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 121104
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 121016
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 121008
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 121176
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 121168
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 121096
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 121088
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 121080
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 121072
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 121064
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 121056
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 121040
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 121032
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 121024
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 121216
	add	sp, sp, t6
	ret
.LBB15_35:                               # %label_35
	slt	t0, s4, a1
	sb	t0, 366(sp)
	lbu	t0, 366(sp)
	beqz	t0, .LBB15_37
.LBB15_36:                               # %label_36
	sltiu	t0, a2, 1
	sb	t0, 365(sp)
	lbu	t0, 365(sp)
	beq	x0, t0, .LBB15_36_jump_0
	j	.LBB15_43
.LBB15_36_jump_0:                               # %label_36_jump_0
	j	.LBB15_44
.LBB15_37:                               # %label_37
	addiw	t0, s5, 1
	add	s6, t0, x0
	add	s5, s6, x0
	add	a6, a7, x0
	add	s0, s1, x0
	j	.LBB15_28
.LBB15_43:                               # %label_43
	li	t6, 120856
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 352(sp)
	add	t0, s5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 352(sp)
	add	t2, t1, t0
	sd	t2, 344(sp)
	add	t0, s4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 344(sp)
	add	t2, t1, t0
	sd	t2, 336(sp)
	sub	t0, s5, s4
	sltiu	t0, t0, 1
	sb	t0, 335(sp)
	lbu	t0, 335(sp)
	beq	x0, t0, .LBB15_43_jump_0
	j	.LBB15_54
.LBB15_43_jump_0:                               # %label_43_jump_0
	j	.LBB15_55
.LBB15_44:                               # %label_44
	xori	t0, a2, 1
	sltiu	t0, t0, 1
	sb	t0, 334(sp)
	lbu	t0, 334(sp)
	beq	x0, t0, .LBB15_44_jump_0
	j	.LBB15_66
.LBB15_44_jump_0:                               # %label_44_jump_0
	j	.LBB15_67
.LBB15_45:                               # %label_45
	addiw	t0, s4, 1
	add	s7, t0, x0
	add	s4, s7, x0
	add	a7, s2, x0
	add	s1, a4, x0
	j	.LBB15_35
.LBB15_54:                               # %label_54
	li	t0, 1
	sw	t0, 324(sp)
	li	s3, 1
	lw	t0, 324(sp)
	add	t0, t0, x0
	sw	t0, 148(sp)
	add	a5, s1, x0
	j	.LBB15_56
.LBB15_55:                               # %label_55
	li	t0, 0
	sw	t0, 320(sp)
	li	a5, 0
	lw	t0, 320(sp)
	add	t0, t0, x0
	sw	t0, 148(sp)
	add	s3, a7, x0
.LBB15_56:                               # %label_56
	ld	t0, 336(sp)
	lw	t1, 148(sp)
	sw	t1, 0(t0)
	add	s2, s3, x0
	add	a4, a5, x0
	j	.LBB15_45
.LBB15_66:                               # %label_66
	li	t6, 120856
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 312(sp)
	add	t0, s5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 312(sp)
	add	t2, t1, t0
	sd	t2, 304(sp)
	add	t0, s4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 304(sp)
	add	t2, t1, t0
	sd	t2, 296(sp)
	li	t1, 17
	mulw	t0, s5, t1
	sw	t0, 292(sp)
	li	t1, 23
	mulw	t0, s4, t1
	sw	t0, 288(sp)
	lw	t0, 292(sp)
	lw	t1, 288(sp)
	addw	t0, t0, t1
	sw	t0, 284(sp)
	lw	t0, 284(sp)
	addiw	t0, t0, 13
	sw	t0, 280(sp)
	lw	t0, 280(sp)
	li	t1, 100
	remw	t0, t0, t1
	sw	t0, 276(sp)
	ld	t0, 296(sp)
	lw	t1, 276(sp)
	sw	t1, 0(t0)
	j	.LBB15_68
.LBB15_67:                               # %label_67
	xori	t0, a2, 2
	sltiu	t0, t0, 1
	sb	t0, 275(sp)
	lbu	t0, 275(sp)
	beq	x0, t0, .LBB15_67_jump_0
	j	.LBB15_83
.LBB15_67_jump_0:                               # %label_67_jump_0
	j	.LBB15_84
.LBB15_68:                               # %label_68
	add	s2, a7, x0
	add	a4, s1, x0
	j	.LBB15_45
.LBB15_83:                               # %label_83
	li	t6, 120856
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 264(sp)
	add	t0, s5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 264(sp)
	add	t2, t1, t0
	sd	t2, 256(sp)
	add	t0, s4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 256(sp)
	add	t2, t1, t0
	sd	t2, 248(sp)
	mulw	t0, s5, a1
	sw	t0, 244(sp)
	lw	t0, 244(sp)
	addw	t0, t0, s4
	sw	t0, 240(sp)
	lw	t0, 240(sp)
	addiw	t0, t0, 1
	sw	t0, 236(sp)
	ld	t0, 248(sp)
	lw	t1, 236(sp)
	sw	t1, 0(t0)
	j	.LBB15_85
.LBB15_84:                               # %label_84
	li	t6, 120856
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 224(sp)
	add	t0, s5, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 224(sp)
	add	t2, t1, t0
	sd	t2, 216(sp)
	add	t0, s4, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 216(sp)
	add	t2, t1, t0
	sd	t2, 208(sp)
	mulw	t0, s5, s5
	add	t4, t0, x0
	mulw	t0, s4, s4
	add	t3, t0, x0
	addw	t0, t4, t3
	add	s11, t0, x0
	mulw	t0, s5, s4
	add	s10, t0, x0
	addw	t0, s11, s10
	add	s9, t0, x0
	li	t1, 50
	remw	t0, s9, t1
	sw	t0, 184(sp)
	ld	t0, 208(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
.LBB15_85:                               # %label_85
	j	.LBB15_68
.Lfunc_end15:
	.size	fn.7, .Lfunc_end15-fn.7
                                        # -- End function
	.globl	fn.8                            # -- Begin function fn.8
	.p2align	1
	.type	fn.8,@function
fn.8:                                   # @fn.8
# %bb.0:                                # %alloca
	addi	sp, sp, -800
	sd	s0, 760(sp)
	sd	s1, 752(sp)
	sd	s3, 672(sp)
	sd	s4, 664(sp)
	sd	s5, 656(sp)
	sd	s6, 648(sp)
	sd	s7, 640(sp)
	j	.LBB16_0
.LBB16_0:                               # %label_0
	li	t0, 2
	mulw	t0, t0, a2
	add	s5, t0, x0
	addiw	t0, s5, 1
	add	s7, t0, x0
	li	t0, 2
	mulw	t0, t0, a2
	add	s5, t0, x0
	addiw	t0, s5, 2
	add	s6, t0, x0
	addi	t0, a3, 4
	sd	t0, 424(sp)
	addi	t0, a3, 4
	sd	t0, 416(sp)
	ld	t0, 416(sp)
	lw	t0, 0(t0)
	sw	t0, 412(sp)
	lw	t0, 412(sp)
	addiw	t0, t0, 1
	sw	t0, 408(sp)
	ld	t0, 424(sp)
	lw	t1, 408(sp)
	sw	t1, 0(t0)
	slt	s5, s7, a1
	add	s0, a2, x0
	add	t0, s5, x0
	beqz	t0, .LBB16_28
.LBB16_27:                               # %label_27
	addi	t0, a3, 12
	sd	t0, 392(sp)
	addi	t0, a3, 12
	sd	t0, 384(sp)
	ld	t0, 384(sp)
	lw	t0, 0(t0)
	sw	t0, 380(sp)
	lw	t0, 380(sp)
	addiw	t0, t0, 1
	sw	t0, 376(sp)
	ld	t0, 392(sp)
	lw	t1, 376(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 368(sp)
	addi	t0, a3, 4
	sd	t0, 360(sp)
	ld	t0, 360(sp)
	lw	t0, 0(t0)
	sw	t0, 356(sp)
	lw	t0, 356(sp)
	addiw	t0, t0, 2
	sw	t0, 352(sp)
	ld	t0, 368(sp)
	lw	t1, 352(sp)
	sw	t1, 0(t0)
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 344(sp)
	ld	t0, 344(sp)
	lw	t0, 0(t0)
	sw	t0, 340(sp)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 324(sp)
	lw	t0, 340(sp)
	lw	t1, 324(sp)
	slt	s4, t1, t0
	add	s1, a2, x0
	add	t0, s4, x0
	beq	x0, t0, .LBB16_27_jump_0
	j	.LBB16_50
.LBB16_27_jump_0:                               # %label_27_jump_0
	j	.LBB16_51
.LBB16_28:                               # %label_28
	slt	a7, s6, a1
	add	a4, s0, x0
	add	t0, a7, x0
	beq	x0, t0, .LBB16_28_jump_0
	j	.LBB16_56
.LBB16_28_jump_0:                               # %label_28_jump_0
	j	.LBB16_57
.LBB16_50:                               # %label_50
	add	s1, s7, x0
.LBB16_51:                               # %label_51
	add	s0, s1, x0
	j	.LBB16_28
.LBB16_56:                               # %label_56
	addi	t0, a3, 12
	sd	t0, 312(sp)
	addi	t0, a3, 12
	sd	t0, 304(sp)
	ld	t0, 304(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	lw	t0, 300(sp)
	addiw	t0, t0, 1
	sw	t0, 296(sp)
	ld	t0, 312(sp)
	lw	t1, 296(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 288(sp)
	addi	t0, a3, 4
	sd	t0, 280(sp)
	ld	t0, 280(sp)
	lw	t0, 0(t0)
	sw	t0, 276(sp)
	lw	t0, 276(sp)
	addiw	t0, t0, 2
	sw	t0, 272(sp)
	ld	t0, 288(sp)
	lw	t1, 272(sp)
	sw	t1, 0(t0)
	add	t0, s6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 264(sp)
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 260(sp)
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 248(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	lw	t0, 260(sp)
	lw	t1, 244(sp)
	slt	s3, t1, t0
	add	a5, s0, x0
	add	t0, s3, x0
	beq	x0, t0, .LBB16_56_jump_0
	j	.LBB16_79
.LBB16_56_jump_0:                               # %label_56_jump_0
	j	.LBB16_80
.LBB16_57:                               # %label_57
	sub	t0, a4, a2
	sltu	a6, x0, t0
	add	t0, a6, x0
	beq	x0, t0, .LBB16_57_jump_0
	j	.LBB16_85
.LBB16_57_jump_0:                               # %label_57_jump_0
	j	.LBB16_86
.LBB16_79:                               # %label_79
	add	a5, s6, x0
.LBB16_80:                               # %label_80
	add	a4, a5, x0
	j	.LBB16_57
.LBB16_85:                               # %label_85
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 228(sp)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 216(sp)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 204(sp)
	ld	t0, 216(sp)
	lw	t1, 204(sp)
	sw	t1, 0(t0)
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 192(sp)
	ld	t0, 192(sp)
	lw	t1, 228(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 8
	sd	t0, 184(sp)
	addi	t0, a3, 8
	sd	t0, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 172(sp)
	lw	t0, 172(sp)
	addiw	t0, t0, 1
	sw	t0, 168(sp)
	ld	t0, 184(sp)
	lw	t1, 168(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 160(sp)
	addi	t0, a3, 4
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	addiw	t0, t0, 4
	sw	t0, 144(sp)
	ld	t0, 160(sp)
	lw	t1, 144(sp)
	sw	t1, 0(t0)
	sd	ra, 792(sp)
	sd	a0, 744(sp)
	sd	a1, 736(sp)
	sd	a2, 728(sp)
	sd	a3, 720(sp)
	sd	a4, 712(sp)
	sd	a5, 704(sp)
	sd	a6, 696(sp)
	sd	a7, 688(sp)
	ld	a0, 744(sp)
	ld	a1, 736(sp)
	ld	a2, 712(sp)
	ld	a3, 720(sp)
	call	fn.8
	ld	ra, 792(sp)
	ld	a0, 744(sp)
	ld	a1, 736(sp)
	ld	a2, 728(sp)
	ld	a3, 720(sp)
	ld	a4, 712(sp)
	ld	a5, 704(sp)
	ld	a6, 696(sp)
	ld	a7, 688(sp)
.LBB16_86:                               # %label_86
	ld	s0, 760(sp)
	ld	s1, 752(sp)
	ld	s3, 672(sp)
	ld	s4, 664(sp)
	ld	s5, 656(sp)
	ld	s6, 648(sp)
	ld	s7, 640(sp)
	li	a0, 0
	addi	sp, sp, 800
	ret
.Lfunc_end16:
	.size	fn.8, .Lfunc_end16-fn.8
                                        # -- End function
	.globl	fn.9                            # -- Begin function fn.9
	.p2align	1
	.type	fn.9,@function
fn.9:                                   # @fn.9
# %bb.0:                                # %alloca
	addi	sp, sp, -768
	sd	s0, 728(sp)
	sd	s1, 720(sp)
	sd	s2, 648(sp)
	sd	s3, 640(sp)
	sd	s4, 632(sp)
	sd	s7, 608(sp)
	sd	s8, 600(sp)
	sd	s9, 592(sp)
	sd	s10, 584(sp)
	sd	s11, 576(sp)
	j	.LBB17_0
.LBB17_0:                               # %label_0
	addi	t0, a2, 0
	sd	t0, 408(sp)
	addi	t0, a2, 0
	sd	t0, 400(sp)
	ld	t0, 400(sp)
	lw	t0, 0(t0)
	sw	t0, 396(sp)
	lw	t0, 396(sp)
	addiw	t0, t0, 1
	sw	t0, 392(sp)
	ld	t0, 408(sp)
	lw	t1, 392(sp)
	sw	t1, 0(t0)
	li	a4, 0
	li	s11, 0
.LBB17_13:                               # %label_13
	addiw	t0, a1, -1
	add	s10, t0, x0
	slt	s9, a4, s10
	add	t0, s9, x0
	beqz	t0, .LBB17_15
.LBB17_14:                               # %label_14
	addiw	t0, a4, 1
	add	s8, t0, x0
	add	s1, s8, x0
	add	t3, a4, x0
	j	.LBB17_25
.LBB17_15:                               # %label_15
	addi	t0, a2, 16
	sd	t0, 368(sp)
	addi	t0, a2, 16
	sd	t0, 360(sp)
	ld	t0, 360(sp)
	lw	t0, 0(t0)
	sw	t0, 356(sp)
	mulw	t0, a1, a1
	add	t4, t0, x0
	lw	t0, 356(sp)
	addw	t0, t0, t4
	sw	t0, 348(sp)
	ld	t0, 368(sp)
	lw	t1, 348(sp)
	sw	t1, 0(t0)
	ld	s0, 728(sp)
	ld	s1, 720(sp)
	ld	s2, 648(sp)
	ld	s3, 640(sp)
	ld	s4, 632(sp)
	ld	s7, 608(sp)
	ld	s8, 600(sp)
	ld	s9, 592(sp)
	ld	s10, 584(sp)
	ld	s11, 576(sp)
	li	a0, 0
	addi	sp, sp, 768
	ret
.LBB17_25:                               # %label_25
	slt	s7, s1, a1
	add	t0, s7, x0
	beqz	t0, .LBB17_27
.LBB17_26:                               # %label_26
	addi	t0, a2, 12
	sd	t0, 336(sp)
	addi	t0, a2, 12
	sd	t0, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 324(sp)
	lw	t0, 324(sp)
	addiw	t0, t0, 1
	sw	t0, 320(sp)
	ld	t0, 336(sp)
	lw	t1, 320(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 312(sp)
	addi	t0, a2, 4
	sd	t0, 304(sp)
	ld	t0, 304(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	lw	t0, 300(sp)
	addiw	t0, t0, 2
	sw	t0, 296(sp)
	ld	t0, 312(sp)
	lw	t1, 296(sp)
	sw	t1, 0(t0)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 288(sp)
	ld	t0, 288(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	add	t0, t3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 284(sp)
	lw	t1, 268(sp)
	slt	s4, t0, t1
	add	a3, t3, x0
	add	t0, s4, x0
	beq	x0, t0, .LBB17_26_jump_0
	j	.LBB17_52
.LBB17_26_jump_0:                               # %label_26_jump_0
	j	.LBB17_53
.LBB17_27:                               # %label_27
	sub	t0, t3, a4
	sltu	s2, x0, t0
	add	s0, s11, x0
	add	t0, s2, x0
	beq	x0, t0, .LBB17_27_jump_0
	j	.LBB17_60
.LBB17_27_jump_0:                               # %label_27_jump_0
	j	.LBB17_61
.LBB17_52:                               # %label_52
	add	a3, s1, x0
.LBB17_53:                               # %label_53
	addiw	t0, s1, 1
	add	s3, t0, x0
	add	s1, s3, x0
	add	t3, a3, x0
	j	.LBB17_25
.LBB17_60:                               # %label_60
	add	t0, a4, x0
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
	add	t0, t3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 224(sp)
	ld	t0, 224(sp)
	lw	t0, 0(t0)
	sw	t0, 220(sp)
	ld	t0, 232(sp)
	lw	t1, 220(sp)
	sw	t1, 0(t0)
	add	t0, t3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t1, 244(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 8
	sd	t0, 200(sp)
	addi	t0, a2, 8
	sd	t0, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 1
	sw	t0, 184(sp)
	ld	t0, 200(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 176(sp)
	addi	t0, a2, 4
	sd	t0, 168(sp)
	ld	t0, 168(sp)
	lw	t0, 0(t0)
	sw	t0, 164(sp)
	lw	t0, 164(sp)
	addiw	t0, t0, 4
	sw	t0, 160(sp)
	ld	t0, 176(sp)
	lw	t1, 160(sp)
	sw	t1, 0(t0)
	lw	t0, 244(sp)
	add	s0, t0, x0
.LBB17_61:                               # %label_61
	addiw	t0, a4, 1
	add	a5, t0, x0
	add	a4, a5, x0
	add	s11, s0, x0
	j	.LBB17_13
.Lfunc_end17:
	.size	fn.9, .Lfunc_end17-fn.9
                                        # -- End function
	.globl	fn.10                            # -- Begin function fn.10
	.p2align	1
	.type	fn.10,@function
fn.10:                                   # @fn.10
# %bb.0:                                # %alloca
	addi	sp, sp, -496
	sd	s0, 456(sp)
	sd	s1, 448(sp)
	j	.LBB18_0
.LBB18_0:                               # %label_0
	li	t1, 1
	slt	s1, t1, a1
	add	t0, s1, x0
	beqz	t0, .LBB18_9
.LBB18_8:                               # %label_8
	addiw	t0, a1, -1
	add	s0, t0, x0
	sd	ra, 488(sp)
	sd	a0, 440(sp)
	sd	a1, 432(sp)
	sd	a2, 424(sp)
	ld	a0, 440(sp)
	li	a1, 0
	add	a2, s0, x0
	ld	a3, 424(sp)
	call	fn.19
	ld	ra, 488(sp)
	ld	a0, 440(sp)
	ld	a1, 432(sp)
	ld	a2, 424(sp)
.LBB18_9:                               # %label_9
	ld	s0, 456(sp)
	ld	s1, 448(sp)
	li	a0, 0
	addi	sp, sp, 496
	ret
.Lfunc_end18:
	.size	fn.10, .Lfunc_end18-fn.10
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	addi	sp, sp, -480
	j	.LBB19_0
.LBB19_0:                               # %label_0
	sd	ra, 472(sp)
	call	fn.0
	ld	ra, 472(sp)
	li	a0, 0
	addi	sp, sp, 480
	ret
.Lfunc_end19:
	.size	main, .Lfunc_end19-main
                                        # -- End function
	.globl	fn.12                            # -- Begin function fn.12
	.p2align	1
	.type	fn.12,@function
fn.12:                                   # @fn.12
# %bb.0:                                # %alloca
	addi	sp, sp, -560
	li	t6, 180
	add	t6, t6, sp
	sd	t6, 200(sp)
	j	.LBB20_0
.LBB20_0:                               # %label_0
	ld	t0, 200(sp)
	addi	t0, t0, 16
	sd	t0, 168(sp)
	ld	t0, 168(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 200(sp)
	addi	t0, t0, 12
	sd	t0, 160(sp)
	ld	t0, 160(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 200(sp)
	addi	t0, t0, 8
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 200(sp)
	addi	t0, t0, 4
	sd	t0, 144(sp)
	ld	t0, 144(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 200(sp)
	addi	t0, t0, 0
	sd	t0, 136(sp)
	ld	t0, 136(sp)
	li	t1, 0
	sw	t1, 0(t0)
	sd	ra, 552(sp)
	sd	a0, 504(sp)
	ld	t0, 504(sp)
	ld	t1, 200(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	ld	ra, 552(sp)
	ld	a0, 504(sp)
	li	a0, 0
	addi	sp, sp, 560
	ret
.Lfunc_end20:
	.size	fn.12, .Lfunc_end20-fn.12
                                        # -- End function
	.globl	fn.13                            # -- Begin function fn.13
	.p2align	1
	.type	fn.13,@function
fn.13:                                   # @fn.13
# %bb.0:                                # %alloca
	addi	sp, sp, -672
	sd	s0, 632(sp)
	sd	s1, 624(sp)
	sd	s2, 552(sp)
	sd	s3, 544(sp)
	sd	s4, 536(sp)
	sd	s5, 528(sp)
	j	.LBB21_0
.LBB21_0:                               # %label_0
	addi	t0, a2, 0
	sd	t0, 312(sp)
	addi	t0, a2, 0
	sd	t0, 304(sp)
	ld	t0, 304(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	lw	t0, 300(sp)
	addiw	t0, t0, 1
	sw	t0, 296(sp)
	ld	t0, 312(sp)
	lw	t1, 296(sp)
	sw	t1, 0(t0)
	li	t1, 2
	divw	t0, a1, t1
	add	s5, t0, x0
	addiw	t0, s5, -1
	add	s5, t0, x0
	add	s0, s5, x0
.LBB21_16:                               # %label_16
	slti	t0, s0, 0
	xori	s4, t0, 1
	add	t0, s4, x0
	beqz	t0, .LBB21_18
.LBB21_17:                               # %label_17
	sd	ra, 664(sp)
	sd	a0, 616(sp)
	sd	a1, 608(sp)
	sd	a2, 600(sp)
	sd	a3, 592(sp)
	sd	a4, 584(sp)
	sd	a7, 560(sp)
	ld	a0, 616(sp)
	ld	a1, 608(sp)
	add	a2, s0, x0
	ld	a3, 600(sp)
	call	fn.8
	addiw	t0, s0, -1
	add	s3, t0, x0
	ld	ra, 664(sp)
	ld	a0, 616(sp)
	ld	a1, 608(sp)
	ld	a2, 600(sp)
	ld	a3, 592(sp)
	ld	a4, 584(sp)
	ld	a7, 560(sp)
	add	s0, s3, x0
	j	.LBB21_16
.LBB21_18:                               # %label_18
	addiw	t0, a1, -1
	add	s2, t0, x0
	add	s1, s2, x0
.LBB21_29:                               # %label_29
	li	t1, 0
	slt	a7, t1, s1
	add	t0, a7, x0
	beqz	t0, .LBB21_31
.LBB21_30:                               # %label_30
	addi	t0, a0, 0
	sd	t0, 264(sp)
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 260(sp)
	addi	t0, a0, 0
	sd	t0, 248(sp)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 236(sp)
	ld	t0, 248(sp)
	lw	t1, 236(sp)
	sw	t1, 0(t0)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 224(sp)
	ld	t0, 224(sp)
	lw	t1, 260(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 8
	sd	t0, 216(sp)
	addi	t0, a2, 8
	sd	t0, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 204(sp)
	lw	t0, 204(sp)
	addiw	t0, t0, 1
	sw	t0, 200(sp)
	ld	t0, 216(sp)
	lw	t1, 200(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 192(sp)
	addi	t0, a2, 4
	sd	t0, 184(sp)
	ld	t0, 184(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 180(sp)
	addiw	t0, t0, 4
	sw	t0, 176(sp)
	ld	t0, 192(sp)
	lw	t1, 176(sp)
	sw	t1, 0(t0)
	sd	ra, 664(sp)
	sd	a0, 616(sp)
	sd	a1, 608(sp)
	sd	a2, 600(sp)
	sd	a3, 592(sp)
	sd	a4, 584(sp)
	sd	a7, 560(sp)
	ld	a0, 616(sp)
	add	a1, s1, x0
	li	a2, 0
	ld	a3, 600(sp)
	call	fn.8
	addiw	t0, s1, -1
	add	a4, t0, x0
	sd	a4, 584(sp)
	ld	ra, 664(sp)
	ld	a0, 616(sp)
	ld	a1, 608(sp)
	ld	a2, 600(sp)
	ld	a3, 592(sp)
	ld	a4, 584(sp)
	ld	a7, 560(sp)
	add	s1, a4, x0
	j	.LBB21_29
.LBB21_31:                               # %label_31
	addi	t0, a2, 16
	sd	t0, 160(sp)
	addi	t0, a2, 16
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	mulw	t0, a1, a1
	add	a3, t0, x0
	lw	t0, 148(sp)
	addw	t0, t0, a3
	sw	t0, 140(sp)
	ld	t0, 160(sp)
	lw	t1, 140(sp)
	sw	t1, 0(t0)
	ld	s0, 632(sp)
	ld	s1, 624(sp)
	ld	s2, 552(sp)
	ld	s3, 544(sp)
	ld	s4, 536(sp)
	ld	s5, 528(sp)
	li	a0, 0
	addi	sp, sp, 672
	ret
.Lfunc_end21:
	.size	fn.13, .Lfunc_end21-fn.13
                                        # -- End function
	.globl	fn.14                            # -- Begin function fn.14
	.p2align	1
	.type	fn.14,@function
fn.14:                                   # @fn.14
# %bb.0:                                # %alloca
	li	t6, -121024
	add	sp, sp, t6
	li	t6, 120984
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 120904
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 120896
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 120888
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 120880
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 120872
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 120864
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 120856
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 120848
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 120840
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 120832
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 80640
	add	t6, t6, sp
	li	t0, 120664
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40608
	add	t6, t6, sp
	li	t0, 80632
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 600
	add	t6, t6, sp
	li	t0, 40600
	add	t0, sp, t0
	sd	t6, 0(t0)
	j	.LBB22_0
.LBB22_0:                               # %label_0
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 592(sp)
	li	t6, 121016
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120968
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120960
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120952
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120944
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120936
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120928
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120824
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120816
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120808
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 40600
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	ld	t0, 592(sp)
	li	t6, 40600
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 20
	sd	t0, 584(sp)
	ld	t0, 584(sp)
	li	t6, 120960
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	sd	t0, 576(sp)
	ld	t0, 576(sp)
	li	t1, 0
	sb	t1, 0(t0)
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 568(sp)
	ld	t0, 568(sp)
	li	t1, 999999
	sw	t1, 0(t0)
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 560(sp)
	ld	t0, 560(sp)
	li	t1, -999999
	sw	t1, 0(t0)
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 552(sp)
	ld	t0, 552(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 80632
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 544(sp)
	ld	t0, 544(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 80632
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 121016
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120968
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120960
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120952
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120944
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120936
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120928
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120824
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120816
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120808
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s0, 0
.LBB22_18:                               # %label_18
	slt	t0, s0, a1
	sb	t0, 543(sp)
	lbu	t0, 543(sp)
	beqz	t0, .LBB22_20
.LBB22_19:                               # %label_19
	sltiu	t0, a0, 1
	sb	t0, 542(sp)
	lbu	t0, 542(sp)
	beq	x0, t0, .LBB22_19_jump_0
	j	.LBB22_27
.LBB22_19_jump_0:                               # %label_19_jump_0
	j	.LBB22_28
.LBB22_20:                               # %label_20
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 528(sp)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 520(sp)
	ld	t0, 520(sp)
	lw	t0, 0(t0)
	sw	t0, 516(sp)
	lw	t0, 516(sp)
	divw	t0, t0, a1
	sw	t0, 512(sp)
	ld	t0, 528(sp)
	lw	t1, 512(sp)
	sw	t1, 0(t0)
	li	t6, 121016
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120968
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120960
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120952
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120944
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120936
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120928
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120912
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120824
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120816
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120808
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120952
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 121016
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120968
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120960
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120952
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120944
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120936
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120928
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120912
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120824
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120816
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120808
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 120984
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 120904
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 120896
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 120888
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 120880
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 120872
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 120864
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 120856
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 120848
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 120840
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 120832
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 121024
	add	sp, sp, t6
	ret
.LBB22_27:                               # %label_27
	li	t1, 11047
	mulw	t0, s0, t1
	sw	t0, 508(sp)
	lw	t0, 508(sp)
	li	t6, 12345
	addw	t0, t0, t6
	sw	t0, 504(sp)
	lw	t0, 504(sp)
	li	t1, 100000
	remw	t0, t0, t1
	sw	t0, 500(sp)
	lw	t0, 500(sp)
	add	t0, t0, x0
	sw	t0, 496(sp)
	lw	t0, 496(sp)
	add	t0, t0, x0
	sw	t0, 172(sp)
	j	.LBB22_29
.LBB22_28:                               # %label_28
	xori	t0, a0, 1
	sltiu	t0, t0, 1
	sb	t0, 495(sp)
	lbu	t0, 495(sp)
	beq	x0, t0, .LBB22_28_jump_0
	j	.LBB22_37
.LBB22_28_jump_0:                               # %label_28_jump_0
	j	.LBB22_38
.LBB22_29:                               # %label_29
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	sd	t0, 480(sp)
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 480(sp)
	add	t2, t1, t0
	sd	t2, 472(sp)
	ld	t0, 472(sp)
	lw	t1, 172(sp)
	sw	t1, 0(t0)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 464(sp)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 456(sp)
	ld	t0, 456(sp)
	lw	t0, 0(t0)
	sw	t0, 452(sp)
	lw	t0, 452(sp)
	lw	t1, 172(sp)
	addw	t0, t0, t1
	sw	t0, 448(sp)
	ld	t0, 464(sp)
	lw	t1, 448(sp)
	sw	t1, 0(t0)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 440(sp)
	ld	t0, 440(sp)
	lw	t0, 0(t0)
	sw	t0, 436(sp)
	lw	t0, 172(sp)
	lw	t1, 436(sp)
	slt	a5, t0, t1
	add	t0, a5, x0
	beq	x0, t0, .LBB22_29_jump_0
	j	.LBB22_176
.LBB22_29_jump_0:                               # %label_29_jump_0
	j	.LBB22_177
.LBB22_37:                               # %label_37
	li	t1, 3
	mulw	t0, s0, t1
	sw	t0, 428(sp)
	lw	t0, 428(sp)
	addiw	t0, t0, 7
	sw	t0, 424(sp)
	lw	t0, 424(sp)
	add	t0, t0, x0
	sw	t0, 420(sp)
	lw	t0, 420(sp)
	add	a7, t0, x0
	j	.LBB22_39
.LBB22_38:                               # %label_38
	xori	t0, a0, 2
	sltiu	t0, t0, 1
	sb	t0, 419(sp)
	lbu	t0, 419(sp)
	beq	x0, t0, .LBB22_38_jump_0
	j	.LBB22_46
.LBB22_38_jump_0:                               # %label_38_jump_0
	j	.LBB22_47
.LBB22_39:                               # %label_39
	add	t0, a7, x0
	sw	t0, 172(sp)
	j	.LBB22_29
.LBB22_46:                               # %label_46
	subw	t0, a1, s0
	sw	t0, 412(sp)
	lw	t0, 412(sp)
	li	t1, 5
	mulw	t0, t0, t1
	sw	t0, 408(sp)
	lw	t0, 408(sp)
	addiw	t0, t0, 13
	sw	t0, 404(sp)
	lw	t0, 404(sp)
	add	t0, t0, x0
	sw	t0, 400(sp)
	lw	t0, 400(sp)
	add	s2, t0, x0
	j	.LBB22_48
.LBB22_47:                               # %label_47
	xori	t0, a0, 3
	sltiu	t0, t0, 1
	sb	t0, 399(sp)
	lbu	t0, 399(sp)
	beq	x0, t0, .LBB22_47_jump_0
	j	.LBB22_57
.LBB22_47_jump_0:                               # %label_47_jump_0
	j	.LBB22_58
.LBB22_48:                               # %label_48
	add	a7, s2, x0
	j	.LBB22_39
.LBB22_57:                               # %label_57
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 392(sp)
	lw	t1, 392(sp)
	slt	t0, s0, t1
	sb	t0, 391(sp)
	lbu	t0, 391(sp)
	beq	x0, t0, .LBB22_57_jump_0
	j	.LBB22_64
.LBB22_57_jump_0:                               # %label_57_jump_0
	j	.LBB22_65
.LBB22_58:                               # %label_58
	xori	t0, a0, 4
	sltiu	t0, t0, 1
	sb	t0, 390(sp)
	lbu	t0, 390(sp)
	beq	x0, t0, .LBB22_58_jump_0
	j	.LBB22_79
.LBB22_58_jump_0:                               # %label_58_jump_0
	j	.LBB22_80
.LBB22_59:                               # %label_59
	add	s2, s3, x0
	j	.LBB22_48
.LBB22_64:                               # %label_64
	li	t1, 4
	mulw	t0, s0, t1
	sw	t0, 384(sp)
	lw	t0, 384(sp)
	add	t0, t0, x0
	sw	t0, 380(sp)
	lw	t0, 380(sp)
	add	t0, t0, x0
	sw	t0, 160(sp)
	j	.LBB22_66
.LBB22_65:                               # %label_65
	subw	t0, a1, s0
	sw	t0, 376(sp)
	lw	t0, 376(sp)
	li	t1, 4
	mulw	t0, t0, t1
	sw	t0, 372(sp)
	lw	t0, 372(sp)
	add	t0, t0, x0
	sw	t0, 368(sp)
	lw	t0, 368(sp)
	add	t0, t0, x0
	sw	t0, 160(sp)
.LBB22_66:                               # %label_66
	lw	t0, 160(sp)
	add	t0, t0, x0
	sw	t0, 364(sp)
	lw	t0, 364(sp)
	add	s3, t0, x0
	j	.LBB22_59
.LBB22_79:                               # %label_79
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 360(sp)
	lw	t1, 360(sp)
	slt	t0, s0, t1
	sb	t0, 359(sp)
	lbu	t0, 359(sp)
	beq	x0, t0, .LBB22_79_jump_0
	j	.LBB22_86
.LBB22_79_jump_0:                               # %label_79_jump_0
	j	.LBB22_87
.LBB22_80:                               # %label_80
	xori	t0, a0, 5
	sltiu	t0, t0, 1
	sb	t0, 358(sp)
	lbu	t0, 358(sp)
	beq	x0, t0, .LBB22_80_jump_0
	j	.LBB22_105
.LBB22_80_jump_0:                               # %label_80_jump_0
	j	.LBB22_106
.LBB22_81:                               # %label_81
	add	s3, s4, x0
	j	.LBB22_59
.LBB22_86:                               # %label_86
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 352(sp)
	lw	t0, 352(sp)
	subw	t0, t0, s0
	sw	t0, 348(sp)
	lw	t0, 348(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 344(sp)
	lw	t0, 344(sp)
	add	t0, t0, x0
	sw	t0, 340(sp)
	lw	t0, 340(sp)
	add	t0, t0, x0
	sw	t0, 152(sp)
	j	.LBB22_88
.LBB22_87:                               # %label_87
	li	t1, 2
	divw	t0, a1, t1
	sw	t0, 336(sp)
	lw	t1, 336(sp)
	subw	t0, s0, t1
	sw	t0, 332(sp)
	lw	t0, 332(sp)
	li	t1, 3
	mulw	t0, t0, t1
	sw	t0, 328(sp)
	lw	t0, 328(sp)
	add	t0, t0, x0
	sw	t0, 324(sp)
	lw	t0, 324(sp)
	add	t0, t0, x0
	sw	t0, 152(sp)
.LBB22_88:                               # %label_88
	lw	t0, 152(sp)
	add	t0, t0, x0
	sw	t0, 320(sp)
	lw	t0, 320(sp)
	add	s4, t0, x0
	j	.LBB22_81
.LBB22_105:                               # %label_105
	li	t1, 2
	mulw	t0, s0, t1
	sw	t0, 316(sp)
	li	t1, 10
	remw	t0, s0, t1
	sw	t0, 312(sp)
	lw	t0, 312(sp)
	xori	t0, t0, 5
	sltiu	t0, t0, 1
	sb	t0, 311(sp)
	lbu	t0, 311(sp)
	sw	t0, 304(sp)
	lw	t0, 304(sp)
	li	t1, 100
	mulw	t0, t0, t1
	sw	t0, 300(sp)
	lw	t0, 316(sp)
	lw	t1, 300(sp)
	addw	t0, t0, t1
	sw	t0, 296(sp)
	lw	t0, 296(sp)
	add	t0, t0, x0
	sw	t0, 292(sp)
	lw	t0, 292(sp)
	add	s5, t0, x0
	j	.LBB22_107
.LBB22_106:                               # %label_106
	xori	t0, a0, 6
	sltiu	t0, t0, 1
	sb	t0, 291(sp)
	lbu	t0, 291(sp)
	beq	x0, t0, .LBB22_106_jump_0
	j	.LBB22_119
.LBB22_106_jump_0:                               # %label_106_jump_0
	j	.LBB22_120
.LBB22_107:                               # %label_107
	add	s4, s5, x0
	j	.LBB22_81
.LBB22_119:                               # %label_119
	li	t1, 10
	divw	t0, s0, t1
	sw	t0, 284(sp)
	lw	t0, 284(sp)
	li	t1, 7
	mulw	t0, t0, t1
	sw	t0, 280(sp)
	lw	t0, 280(sp)
	addiw	t0, t0, 23
	sw	t0, 276(sp)
	lw	t0, 276(sp)
	add	t0, t0, x0
	sw	t0, 272(sp)
	lw	t0, 272(sp)
	add	s6, t0, x0
	j	.LBB22_121
.LBB22_120:                               # %label_120
	xori	t0, a0, 7
	sltiu	t0, t0, 1
	sb	t0, 271(sp)
	lbu	t0, 271(sp)
	beq	x0, t0, .LBB22_120_jump_0
	j	.LBB22_129
.LBB22_120_jump_0:                               # %label_120_jump_0
	j	.LBB22_130
.LBB22_121:                               # %label_121
	add	s5, s6, x0
	j	.LBB22_107
.LBB22_129:                               # %label_129
	li	t1, 2
	remw	t0, s0, t1
	sw	t0, 264(sp)
	lw	t0, 264(sp)
	sltiu	t0, t0, 1
	sb	t0, 263(sp)
	lbu	t0, 263(sp)
	beq	x0, t0, .LBB22_129_jump_0
	j	.LBB22_135
.LBB22_129_jump_0:                               # %label_129_jump_0
	j	.LBB22_136
.LBB22_130:                               # %label_130
	mulw	t0, s0, s0
	add	t4, t0, x0
	li	t1, 7
	mulw	t0, s0, t1
	add	t3, t0, x0
	addw	t0, t4, t3
	add	s11, t0, x0
	addiw	t0, s11, 17
	add	s10, t0, x0
	li	t1, 1000
	remw	t0, s10, t1
	add	s9, t0, x0
	add	s8, s9, x0
	add	s7, s8, x0
.LBB22_131:                               # %label_131
	add	s6, s7, x0
	j	.LBB22_121
.LBB22_135:                               # %label_135
	add	t0, s0, x0
	sw	t0, 232(sp)
	lw	t0, 232(sp)
	add	t0, t0, x0
	sw	t0, 132(sp)
	j	.LBB22_137
.LBB22_136:                               # %label_136
	subw	t0, a1, s0
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	add	t0, t0, x0
	sw	t0, 224(sp)
	lw	t0, 224(sp)
	add	t0, t0, x0
	sw	t0, 132(sp)
.LBB22_137:                               # %label_137
	lw	t0, 132(sp)
	add	t5, t0, x0
	add	s7, t5, x0
	j	.LBB22_131
.LBB22_176:                               # %label_176
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	sd	t0, 208(sp)
	ld	t0, 208(sp)
	lw	t1, 172(sp)
	sw	t1, 0(t0)
.LBB22_177:                               # %label_177
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 200(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 196(sp)
	lw	t0, 172(sp)
	lw	t1, 196(sp)
	slt	a4, t1, t0
	add	t0, a4, x0
	beqz	t0, .LBB22_185
.LBB22_184:                               # %label_184
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	sd	t0, 184(sp)
	ld	t0, 184(sp)
	lw	t1, 172(sp)
	sw	t1, 0(t0)
.LBB22_185:                               # %label_185
	addiw	t0, s0, 1
	add	a3, t0, x0
	add	s0, a3, x0
	j	.LBB22_18
.Lfunc_end22:
	.size	fn.14, .Lfunc_end22-fn.14
                                        # -- End function
	.globl	fn.15                            # -- Begin function fn.15
	.p2align	1
	.type	fn.15,@function
fn.15:                                   # @fn.15
# %bb.0:                                # %alloca
	addi	sp, sp, -784
	sd	s0, 744(sp)
	sd	s1, 736(sp)
	sd	s2, 664(sp)
	sd	s3, 656(sp)
	sd	s4, 648(sp)
	sd	s7, 624(sp)
	sd	s8, 616(sp)
	sd	s9, 608(sp)
	sd	s10, 600(sp)
	j	.LBB23_0
.LBB23_0:                               # %label_0
	addi	t0, a2, 0
	sd	t0, 424(sp)
	addi	t0, a2, 0
	sd	t0, 416(sp)
	ld	t0, 416(sp)
	lw	t0, 0(t0)
	sw	t0, 412(sp)
	lw	t0, 412(sp)
	addiw	t0, t0, 1
	sw	t0, 408(sp)
	ld	t0, 424(sp)
	lw	t1, 408(sp)
	sw	t1, 0(t0)
	li	a7, 0
	li	s0, 0
.LBB23_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 404(sp)
	lw	t1, 404(sp)
	slt	t0, a7, t1
	sb	t0, 403(sp)
	lbu	t0, 403(sp)
	beqz	t0, .LBB23_15
.LBB23_14:                               # %label_14
	li	a6, 0
	li	a4, 0
	add	s1, s0, x0
	j	.LBB23_22
.LBB23_15:                               # %label_15
	addi	t0, a2, 16
	sd	t0, 392(sp)
	addi	t0, a2, 16
	sd	t0, 384(sp)
	ld	t0, 384(sp)
	lw	t0, 0(t0)
	sw	t0, 380(sp)
	mulw	t0, a1, a1
	add	t5, t0, x0
	lw	t0, 380(sp)
	addw	t0, t0, t5
	sw	t0, 372(sp)
	ld	t0, 392(sp)
	lw	t1, 372(sp)
	sw	t1, 0(t0)
	ld	s0, 744(sp)
	ld	s1, 736(sp)
	ld	s2, 664(sp)
	ld	s3, 656(sp)
	ld	s4, 648(sp)
	ld	s7, 624(sp)
	ld	s8, 616(sp)
	ld	s9, 608(sp)
	ld	s10, 600(sp)
	li	a0, 0
	addi	sp, sp, 784
	ret
.LBB23_22:                               # %label_22
	subw	t0, a1, a7
	sw	t0, 368(sp)
	lw	t0, 368(sp)
	addiw	t0, t0, -1
	sw	t0, 364(sp)
	lw	t1, 364(sp)
	slt	t4, a6, t1
	add	t0, t4, x0
	beqz	t0, .LBB23_24
.LBB23_23:                               # %label_23
	addi	t0, a2, 12
	sd	t0, 352(sp)
	addi	t0, a2, 12
	sd	t0, 344(sp)
	ld	t0, 344(sp)
	lw	t0, 0(t0)
	sw	t0, 340(sp)
	lw	t0, 340(sp)
	addiw	t0, t0, 1
	sw	t0, 336(sp)
	ld	t0, 352(sp)
	lw	t1, 336(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 328(sp)
	addi	t0, a2, 4
	sd	t0, 320(sp)
	ld	t0, 320(sp)
	lw	t0, 0(t0)
	sw	t0, 316(sp)
	lw	t0, 316(sp)
	addiw	t0, t0, 2
	sw	t0, 312(sp)
	ld	t0, 328(sp)
	lw	t1, 312(sp)
	sw	t1, 0(t0)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 304(sp)
	ld	t0, 304(sp)
	lw	t0, 0(t0)
	sw	t0, 300(sp)
	addiw	t0, a6, 1
	add	s10, t0, x0
	add	t0, s10, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 288(sp)
	ld	t0, 288(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	lw	t0, 300(sp)
	lw	t1, 284(sp)
	slt	s9, t1, t0
	add	a5, a4, x0
	add	a3, s1, x0
	add	t0, s9, x0
	beq	x0, t0, .LBB23_23_jump_0
	j	.LBB23_53
.LBB23_23_jump_0:                               # %label_23_jump_0
	j	.LBB23_54
.LBB23_24:                               # %label_24
	li	t0, 1
	subw	t0, t0, a4
	add	s3, t0, x0
	add	t0, s3, x0
	beq	x0, t0, .LBB23_24_jump_0
	j	.LBB23_89
.LBB23_24_jump_0:                               # %label_24_jump_0
	j	.LBB23_90
.LBB23_53:                               # %label_53
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 256(sp)
	addiw	t0, a6, 1
	add	s8, t0, x0
	add	t0, s8, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 236(sp)
	ld	t0, 256(sp)
	lw	t1, 236(sp)
	sw	t1, 0(t0)
	addiw	t0, a6, 1
	add	s7, t0, x0
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 224(sp)
	ld	t0, 224(sp)
	lw	t1, 268(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 8
	sd	t0, 216(sp)
	addi	t0, a2, 8
	sd	t0, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 204(sp)
	lw	t0, 204(sp)
	addiw	t0, t0, 1
	sw	t0, 200(sp)
	ld	t0, 216(sp)
	lw	t1, 200(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 192(sp)
	addi	t0, a2, 4
	sd	t0, 184(sp)
	ld	t0, 184(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 180(sp)
	addiw	t0, t0, 4
	sw	t0, 176(sp)
	ld	t0, 192(sp)
	lw	t1, 176(sp)
	sw	t1, 0(t0)
	li	a5, 1
	lw	t0, 268(sp)
	add	a3, t0, x0
.LBB23_54:                               # %label_54
	addiw	t0, a6, 1
	add	s4, t0, x0
	add	a6, s4, x0
	add	a4, a5, x0
	add	s1, a3, x0
	j	.LBB23_22
.LBB23_89:                               # %label_89
	j	.LBB23_15
.LBB23_90:                               # %label_90
	addiw	t0, a7, 1
	add	s2, t0, x0
	add	a7, s2, x0
	add	s0, s1, x0
	j	.LBB23_13
.Lfunc_end23:
	.size	fn.15, .Lfunc_end23-fn.15
                                        # -- End function
	.globl	fn.16                            # -- Begin function fn.16
	.p2align	1
	.type	fn.16,@function
fn.16:                                   # @fn.16
# %bb.0:                                # %alloca
	addi	sp, sp, -528
	sd	s0, 488(sp)
	sd	s1, 480(sp)
	sd	s2, 408(sp)
	j	.LBB24_0
.LBB24_0:                               # %label_0
	li	s1, 0
	li	s0, 0
.LBB24_8:                               # %label_8
	slt	s2, s0, a1
	add	t0, s2, x0
	beqz	t0, .LBB24_10
.LBB24_9:                               # %label_9
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 160(sp)
	ld	t0, 160(sp)
	lw	t0, 0(t0)
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	subw	t0, t0, a2
	add	a7, t0, x0
	mulw	t0, a7, a7
	add	a6, t0, x0
	addw	t0, s1, a6
	add	a5, t0, x0
	addiw	t0, s0, 1
	add	a4, t0, x0
	add	s1, a5, x0
	add	s0, a4, x0
	j	.LBB24_8
.LBB24_10:                               # %label_10
	divw	t0, s1, a1
	sw	t0, 136(sp)
	lw	a0, 136(sp)
	ld	s0, 488(sp)
	ld	s1, 480(sp)
	ld	s2, 408(sp)
	addi	sp, sp, 528
	ret
.Lfunc_end24:
	.size	fn.16, .Lfunc_end24-fn.16
                                        # -- End function
	.globl	fn.17                            # -- Begin function fn.17
	.p2align	1
	.type	fn.17,@function
fn.17:                                   # @fn.17
# %bb.0:                                # %alloca
	addi	sp, sp, -832
	sd	s0, 792(sp)
	sd	s1, 784(sp)
	sd	s4, 696(sp)
	sd	s5, 688(sp)
	sd	s6, 680(sp)
	sd	s7, 672(sp)
	sd	s8, 664(sp)
	j	.LBB25_0
.LBB25_0:                               # %label_0
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 472(sp)
	ld	t0, 472(sp)
	lw	t0, 0(t0)
	sw	t0, 468(sp)
	addiw	t0, a1, -1
	add	s5, t0, x0
	addi	t0, a3, 4
	sd	t0, 456(sp)
	addi	t0, a3, 4
	sd	t0, 448(sp)
	ld	t0, 448(sp)
	lw	t0, 0(t0)
	sw	t0, 444(sp)
	lw	t0, 444(sp)
	addiw	t0, t0, 1
	sw	t0, 440(sp)
	ld	t0, 456(sp)
	lw	t1, 440(sp)
	sw	t1, 0(t0)
	li	s6, 0
	add	s1, a1, x0
	add	s7, s5, x0
.LBB25_24:                               # %label_24
	slt	s4, s1, a2
	add	t0, s4, x0
	beqz	t0, .LBB25_26
.LBB25_25:                               # %label_25
	addi	t0, a3, 12
	sd	t0, 424(sp)
	addi	t0, a3, 12
	sd	t0, 416(sp)
	ld	t0, 416(sp)
	lw	t0, 0(t0)
	sw	t0, 412(sp)
	lw	t0, 412(sp)
	addiw	t0, t0, 1
	sw	t0, 408(sp)
	ld	t0, 424(sp)
	lw	t1, 408(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 400(sp)
	addi	t0, a3, 4
	sd	t0, 392(sp)
	ld	t0, 392(sp)
	lw	t0, 0(t0)
	sw	t0, 388(sp)
	lw	t0, 388(sp)
	addiw	t0, t0, 1
	sw	t0, 384(sp)
	ld	t0, 400(sp)
	lw	t1, 384(sp)
	sw	t1, 0(t0)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 376(sp)
	ld	t0, 376(sp)
	lw	t0, 0(t0)
	sw	t0, 372(sp)
	lw	t0, 372(sp)
	lw	t1, 468(sp)
	slt	t0, t1, t0
	xori	a7, t0, 1
	add	a4, s7, x0
	add	s0, s6, x0
	add	t0, a7, x0
	beq	x0, t0, .LBB25_25_jump_0
	j	.LBB25_48
.LBB25_25_jump_0:                               # %label_25_jump_0
	j	.LBB25_49
.LBB25_26:                               # %label_26
	addiw	t0, s7, 1
	add	s8, t0, x0
	add	t0, s8, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 352(sp)
	ld	t0, 352(sp)
	lw	t0, 0(t0)
	sw	t0, 348(sp)
	addiw	t0, s7, 1
	add	s8, t0, x0
	add	t0, s8, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 336(sp)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 324(sp)
	ld	t0, 336(sp)
	lw	t1, 324(sp)
	sw	t1, 0(t0)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 312(sp)
	ld	t0, 312(sp)
	lw	t1, 348(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 8
	sd	t0, 304(sp)
	addi	t0, a3, 8
	sd	t0, 296(sp)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 292(sp)
	lw	t0, 292(sp)
	addiw	t0, t0, 1
	sw	t0, 288(sp)
	ld	t0, 304(sp)
	lw	t1, 288(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 280(sp)
	addi	t0, a3, 4
	sd	t0, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 268(sp)
	addiw	t0, t0, 4
	sw	t0, 264(sp)
	ld	t0, 280(sp)
	lw	t1, 264(sp)
	sw	t1, 0(t0)
	addiw	t0, s7, 1
	sw	t0, 260(sp)
	lw	a0, 260(sp)
	ld	s0, 792(sp)
	ld	s1, 784(sp)
	ld	s4, 696(sp)
	ld	s5, 688(sp)
	ld	s6, 680(sp)
	ld	s7, 672(sp)
	ld	s8, 664(sp)
	addi	sp, sp, 832
	ret
.LBB25_48:                               # %label_48
	addiw	t0, s7, 1
	add	a6, t0, x0
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 248(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 232(sp)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 224(sp)
	ld	t0, 224(sp)
	lw	t0, 0(t0)
	sw	t0, 220(sp)
	ld	t0, 232(sp)
	lw	t1, 220(sp)
	sw	t1, 0(t0)
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t1, 244(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 8
	sd	t0, 200(sp)
	addi	t0, a3, 8
	sd	t0, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 1
	sw	t0, 184(sp)
	ld	t0, 200(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
	addi	t0, a3, 4
	sd	t0, 176(sp)
	addi	t0, a3, 4
	sd	t0, 168(sp)
	ld	t0, 168(sp)
	lw	t0, 0(t0)
	sw	t0, 164(sp)
	lw	t0, 164(sp)
	addiw	t0, t0, 4
	sw	t0, 160(sp)
	ld	t0, 176(sp)
	lw	t1, 160(sp)
	sw	t1, 0(t0)
	add	a4, a6, x0
	lw	t0, 244(sp)
	add	s0, t0, x0
.LBB25_49:                               # %label_49
	addiw	t0, s1, 1
	add	a5, t0, x0
	add	s1, a5, x0
	add	s7, a4, x0
	add	s6, s0, x0
	j	.LBB25_24
.Lfunc_end25:
	.size	fn.17, .Lfunc_end25-fn.17
                                        # -- End function
	.globl	fn.18                            # -- Begin function fn.18
	.p2align	1
	.type	fn.18,@function
fn.18:                                   # @fn.18
# %bb.0:                                # %alloca
	addi	sp, sp, -768
	sd	s0, 728(sp)
	sd	s1, 720(sp)
	sd	s2, 648(sp)
	sd	s5, 624(sp)
	sd	s6, 616(sp)
	sd	s7, 608(sp)
	sd	s8, 600(sp)
	sd	s9, 592(sp)
	sd	s11, 576(sp)
	j	.LBB26_0
.LBB26_0:                               # %label_0
	addi	t0, a2, 0
	sd	t0, 408(sp)
	addi	t0, a2, 0
	sd	t0, 400(sp)
	ld	t0, 400(sp)
	lw	t0, 0(t0)
	sw	t0, 396(sp)
	lw	t0, 396(sp)
	addiw	t0, t0, 1
	sw	t0, 392(sp)
	ld	t0, 408(sp)
	lw	t1, 392(sp)
	sw	t1, 0(t0)
	li	s1, 1
.LBB26_13:                               # %label_13
	slt	t3, s1, a1
	add	t0, t3, x0
	beqz	t0, .LBB26_15
.LBB26_14:                               # %label_14
	add	t0, s1, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 376(sp)
	ld	t0, 376(sp)
	lw	t0, 0(t0)
	sw	t0, 372(sp)
	addiw	t0, s1, -1
	add	s11, t0, x0
	addi	t0, a2, 4
	sd	t0, 360(sp)
	addi	t0, a2, 4
	sd	t0, 352(sp)
	ld	t0, 352(sp)
	lw	t0, 0(t0)
	sw	t0, 348(sp)
	lw	t0, 348(sp)
	addiw	t0, t0, 1
	sw	t0, 344(sp)
	ld	t0, 360(sp)
	lw	t1, 344(sp)
	sw	t1, 0(t0)
	add	s0, s11, x0
	j	.LBB26_33
.LBB26_15:                               # %label_15
	addi	t0, a2, 16
	sd	t0, 336(sp)
	addi	t0, a2, 16
	sd	t0, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 324(sp)
	mulw	t0, a1, a1
	add	t5, t0, x0
	lw	t0, 324(sp)
	addw	t0, t0, t5
	sw	t0, 316(sp)
	ld	t0, 336(sp)
	lw	t1, 316(sp)
	sw	t1, 0(t0)
	ld	s0, 728(sp)
	ld	s1, 720(sp)
	ld	s2, 648(sp)
	ld	s5, 624(sp)
	ld	s6, 616(sp)
	ld	s7, 608(sp)
	ld	s8, 600(sp)
	ld	s9, 592(sp)
	ld	s11, 576(sp)
	li	a0, 0
	addi	sp, sp, 768
	ret
.LBB26_33:                               # %label_33
	slti	t0, s0, 0
	xori	s9, t0, 1
	add	t0, s9, x0
	beq	x0, t0, .LBB26_33_jump_0
	j	.LBB26_38
.LBB26_33_jump_0:                               # %label_33_jump_0
	j	.LBB26_39
.LBB26_34:                               # %label_34
	addi	t0, a2, 12
	sd	t0, 304(sp)
	addi	t0, a2, 12
	sd	t0, 296(sp)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 292(sp)
	lw	t0, 292(sp)
	addiw	t0, t0, 1
	sw	t0, 288(sp)
	ld	t0, 304(sp)
	lw	t1, 288(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 280(sp)
	addi	t0, a2, 4
	sd	t0, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 268(sp)
	addiw	t0, t0, 2
	sw	t0, 264(sp)
	ld	t0, 280(sp)
	lw	t1, 264(sp)
	sw	t1, 0(t0)
	addiw	t0, s0, 1
	add	s2, t0, x0
	add	t0, s2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 248(sp)
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 236(sp)
	ld	t0, 248(sp)
	lw	t1, 236(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 224(sp)
	addi	t0, a2, 4
	sd	t0, 216(sp)
	ld	t0, 216(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	lw	t0, 212(sp)
	addiw	t0, t0, 2
	sw	t0, 208(sp)
	ld	t0, 224(sp)
	lw	t1, 208(sp)
	sw	t1, 0(t0)
	addiw	t0, s0, -1
	add	a6, t0, x0
	add	s0, a6, x0
	j	.LBB26_33
.LBB26_35:                               # %label_35
	addiw	t0, s0, 1
	add	a5, t0, x0
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 192(sp)
	ld	t0, 192(sp)
	lw	t1, 372(sp)
	sw	t1, 0(t0)
	addi	t0, a2, 4
	sd	t0, 184(sp)
	addi	t0, a2, 4
	sd	t0, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 172(sp)
	lw	t0, 172(sp)
	addiw	t0, t0, 1
	sw	t0, 168(sp)
	ld	t0, 184(sp)
	lw	t1, 168(sp)
	sw	t1, 0(t0)
	addiw	t0, s1, 1
	add	a3, t0, x0
	add	s1, a3, x0
	j	.LBB26_13
.LBB26_38:                               # %label_38
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	lw	t1, 372(sp)
	slt	s7, t1, t0
	add	s8, s7, x0
	add	s5, s8, x0
	j	.LBB26_40
.LBB26_39:                               # %label_39
	li	s6, 0
	add	s5, s6, x0
.LBB26_40:                               # %label_40
	add	t0, s5, x0
	beq	x0, t0, .LBB26_40_jump_0
	j	.LBB26_34
.LBB26_40_jump_0:                               # %label_40_jump_0
	j	.LBB26_35
.Lfunc_end26:
	.size	fn.18, .Lfunc_end26-fn.18
                                        # -- End function
	.globl	fn.19                            # -- Begin function fn.19
	.p2align	1
	.type	fn.19,@function
fn.19:                                   # @fn.19
# %bb.0:                                # %alloca
	addi	sp, sp, -560
	sd	s0, 520(sp)
	sd	s1, 512(sp)
	j	.LBB27_0
.LBB27_0:                               # %label_0
	addi	t0, a3, 0
	sd	t0, 200(sp)
	addi	t0, a3, 0
	sd	t0, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 1
	sw	t0, 184(sp)
	ld	t0, 200(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
	slt	a5, a1, a2
	add	t0, a5, x0
	beqz	t0, .LBB27_18
.LBB27_17:                               # %label_17
	subw	t0, a2, a1
	add	s1, t0, x0
	li	t1, 2
	divw	t0, s1, t1
	add	s1, t0, x0
	addw	t0, a1, s1
	add	a4, t0, x0
	sd	ra, 552(sp)
	sd	a0, 504(sp)
	sd	a1, 496(sp)
	sd	a2, 488(sp)
	sd	a3, 480(sp)
	sd	a4, 472(sp)
	sd	a5, 464(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 472(sp)
	ld	a3, 480(sp)
	call	fn.19
	ld	t0, 472(sp)
	addiw	t0, t0, 1
	add	s1, t0, x0
	ld	a0, 504(sp)
	add	a1, s1, x0
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	call	fn.19
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 472(sp)
	ld	a3, 488(sp)
	ld	a4, 480(sp)
	call	fn.22
	ld	ra, 552(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	ld	a4, 472(sp)
	ld	a5, 464(sp)
.LBB27_18:                               # %label_18
	addi	t0, a3, 16
	sd	t0, 152(sp)
	addi	t0, a3, 16
	sd	t0, 144(sp)
	ld	t0, 144(sp)
	lw	t0, 0(t0)
	sw	t0, 140(sp)
	subw	t0, a2, a1
	add	s0, t0, x0
	addiw	t0, s0, 1
	add	s0, t0, x0
	lw	t0, 140(sp)
	addw	t0, t0, s0
	sw	t0, 128(sp)
	ld	t0, 152(sp)
	lw	t1, 128(sp)
	sw	t1, 0(t0)
	ld	s0, 520(sp)
	ld	s1, 512(sp)
	li	a0, 0
	addi	sp, sp, 560
	ret
.Lfunc_end27:
	.size	fn.19, .Lfunc_end27-fn.19
                                        # -- End function
	.globl	fn.20                            # -- Begin function fn.20
	.p2align	1
	.type	fn.20,@function
fn.20:                                   # @fn.20
# %bb.0:                                # %alloca
	addi	sp, sp, -560
	sd	s0, 520(sp)
	sd	s1, 512(sp)
	j	.LBB28_0
.LBB28_0:                               # %label_0
	addi	t0, a3, 0
	sd	t0, 200(sp)
	addi	t0, a3, 0
	sd	t0, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 1
	sw	t0, 184(sp)
	ld	t0, 200(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
	slt	a5, a1, a2
	add	t0, a5, x0
	beqz	t0, .LBB28_18
.LBB28_17:                               # %label_17
	sd	ra, 552(sp)
	sd	a0, 504(sp)
	sd	a1, 496(sp)
	sd	a2, 488(sp)
	sd	a3, 480(sp)
	sd	a4, 472(sp)
	sd	a5, 464(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	call	fn.17
	add	a4, a0, x0
	sd	a4, 472(sp)
	ld	t0, 472(sp)
	addiw	t0, t0, -1
	add	s1, t0, x0
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	add	a2, s1, x0
	ld	a3, 480(sp)
	call	fn.20
	ld	t0, 472(sp)
	addiw	t0, t0, 1
	add	s1, t0, x0
	ld	a0, 504(sp)
	add	a1, s1, x0
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	call	fn.20
	ld	ra, 552(sp)
	ld	a0, 504(sp)
	ld	a1, 496(sp)
	ld	a2, 488(sp)
	ld	a3, 480(sp)
	ld	a4, 472(sp)
	ld	a5, 464(sp)
.LBB28_18:                               # %label_18
	addi	t0, a3, 16
	sd	t0, 160(sp)
	addi	t0, a3, 16
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	subw	t0, a2, a1
	add	s0, t0, x0
	addiw	t0, s0, 1
	add	s0, t0, x0
	lw	t0, 148(sp)
	addw	t0, t0, s0
	sw	t0, 136(sp)
	ld	t0, 160(sp)
	lw	t1, 136(sp)
	sw	t1, 0(t0)
	ld	s0, 520(sp)
	ld	s1, 512(sp)
	li	a0, 0
	addi	sp, sp, 560
	ret
.Lfunc_end28:
	.size	fn.20, .Lfunc_end28-fn.20
                                        # -- End function
	.globl	fn.21                            # -- Begin function fn.21
	.p2align	1
	.type	fn.21,@function
fn.21:                                   # @fn.21
# %bb.0:                                # %alloca
	addi	sp, sp, -496
	sd	s0, 456(sp)
	sd	s1, 448(sp)
	j	.LBB29_0
.LBB29_0:                               # %label_0
	li	t1, 1
	slt	s1, t1, a1
	add	t0, s1, x0
	beqz	t0, .LBB29_9
.LBB29_8:                               # %label_8
	addiw	t0, a1, -1
	add	s0, t0, x0
	sd	ra, 488(sp)
	sd	a0, 440(sp)
	sd	a1, 432(sp)
	sd	a2, 424(sp)
	ld	a0, 440(sp)
	li	a1, 0
	add	a2, s0, x0
	ld	a3, 424(sp)
	call	fn.20
	ld	ra, 488(sp)
	ld	a0, 440(sp)
	ld	a1, 432(sp)
	ld	a2, 424(sp)
.LBB29_9:                               # %label_9
	ld	s0, 456(sp)
	ld	s1, 448(sp)
	li	a0, 0
	addi	sp, sp, 496
	ret
.Lfunc_end29:
	.size	fn.21, .Lfunc_end29-fn.21
                                        # -- End function
	.globl	fn.22                            # -- Begin function fn.22
	.p2align	1
	.type	fn.22,@function
fn.22:                                   # @fn.22
# %bb.0:                                # %alloca
	addi	sp, sp, -944
	sd	s0, 904(sp)
	sd	s1, 896(sp)
	sd	s2, 824(sp)
	sd	s3, 816(sp)
	sd	s4, 808(sp)
	sd	s5, 800(sp)
	sd	s6, 792(sp)
	sd	s7, 784(sp)
	sd	s8, 776(sp)
	sd	s10, 760(sp)
	sd	s11, 752(sp)
	j	.LBB30_0
.LBB30_0:                               # %label_0
	subw	t0, a2, a1
	add	t3, t0, x0
	addiw	t0, t3, 1
	add	t5, t0, x0
	subw	t0, a3, a2
	add	t4, t0, x0
	li	t0, 10000
	subw	t0, t0, t5
	add	t3, t0, x0
	li	a5, 0
.LBB30_26:                               # %label_26
	slt	t0, a5, t5
	sb	t0, 575(sp)
	lbu	t0, 575(sp)
	beqz	t0, .LBB30_28
.LBB30_27:                               # %label_27
	addw	t0, t3, a5
	add	s11, t0, x0
	add	t0, s11, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 560(sp)
	addw	t0, a1, a5
	add	s10, t0, x0
	add	t0, s10, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 544(sp)
	ld	t0, 544(sp)
	lw	t0, 0(t0)
	sw	t0, 540(sp)
	ld	t0, 560(sp)
	lw	t1, 540(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 528(sp)
	addi	t0, a4, 4
	sd	t0, 520(sp)
	ld	t0, 520(sp)
	lw	t0, 0(t0)
	sw	t0, 516(sp)
	lw	t0, 516(sp)
	addiw	t0, t0, 2
	sw	t0, 512(sp)
	ld	t0, 528(sp)
	lw	t1, 512(sp)
	sw	t1, 0(t0)
	addiw	t0, a5, 1
	add	s8, t0, x0
	add	a5, s8, x0
	j	.LBB30_26
.LBB30_28:                               # %label_28
	li	a6, 0
	li	s8, 0
	add	a5, a1, x0
.LBB30_52:                               # %label_52
	slt	t0, a6, t5
	sb	t0, 507(sp)
	lbu	t0, 507(sp)
	beq	x0, t0, .LBB30_52_jump_0
	j	.LBB30_58
.LBB30_52_jump_0:                               # %label_52_jump_0
	j	.LBB30_59
.LBB30_53:                               # %label_53
	addi	t0, a4, 12
	sd	t0, 496(sp)
	addi	t0, a4, 12
	sd	t0, 488(sp)
	ld	t0, 488(sp)
	lw	t0, 0(t0)
	sw	t0, 484(sp)
	lw	t0, 484(sp)
	addiw	t0, t0, 1
	sw	t0, 480(sp)
	ld	t0, 496(sp)
	lw	t1, 480(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 472(sp)
	addi	t0, a4, 4
	sd	t0, 464(sp)
	ld	t0, 464(sp)
	lw	t0, 0(t0)
	sw	t0, 460(sp)
	lw	t0, 460(sp)
	addiw	t0, t0, 2
	sw	t0, 456(sp)
	ld	t0, 472(sp)
	lw	t1, 456(sp)
	sw	t1, 0(t0)
	addw	t0, t3, a6
	sw	t0, 452(sp)
	lw	t0, 452(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 440(sp)
	ld	t0, 440(sp)
	lw	t0, 0(t0)
	sw	t0, 436(sp)
	addiw	t0, a2, 1
	sw	t0, 432(sp)
	lw	t0, 432(sp)
	addw	t0, t0, s8
	sw	t0, 428(sp)
	lw	t0, 428(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 416(sp)
	ld	t0, 416(sp)
	lw	t0, 0(t0)
	sw	t0, 412(sp)
	lw	t0, 436(sp)
	lw	t1, 412(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 411(sp)
	lbu	t0, 411(sp)
	beq	x0, t0, .LBB30_53_jump_0
	j	.LBB30_93
.LBB30_53_jump_0:                               # %label_53_jump_0
	j	.LBB30_94
.LBB30_54:                               # %label_54
	add	s2, a6, x0
	add	s0, a5, x0
	j	.LBB30_127
.LBB30_58:                               # %label_58
	slt	t0, s8, t4
	sb	t0, 410(sp)
	lbu	t0, 410(sp)
	sb	t0, 409(sp)
	lbu	t0, 409(sp)
	add	t0, t0, x0
	sb	t0, 151(sp)
	j	.LBB30_60
.LBB30_59:                               # %label_59
	li	t0, 0
	sb	t0, 408(sp)
	lbu	t0, 408(sp)
	add	t0, t0, x0
	sb	t0, 151(sp)
.LBB30_60:                               # %label_60
	lbu	t0, 151(sp)
	beq	x0, t0, .LBB30_60_jump_0
	j	.LBB30_53
.LBB30_60_jump_0:                               # %label_60_jump_0
	j	.LBB30_54
.LBB30_93:                               # %label_93
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 400(sp)
	addw	t0, t3, a6
	sw	t0, 396(sp)
	lw	t0, 396(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 384(sp)
	ld	t0, 384(sp)
	lw	t0, 0(t0)
	sw	t0, 380(sp)
	ld	t0, 400(sp)
	lw	t1, 380(sp)
	sw	t1, 0(t0)
	addiw	t0, a6, 1
	sw	t0, 376(sp)
	lw	t0, 376(sp)
	add	a7, t0, x0
	add	s0, s8, x0
	j	.LBB30_95
.LBB30_94:                               # %label_94
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 368(sp)
	addiw	t0, a2, 1
	sw	t0, 364(sp)
	lw	t0, 364(sp)
	addw	t0, t0, s8
	sw	t0, 360(sp)
	lw	t0, 360(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 352(sp)
	ld	t0, 352(sp)
	lw	t0, 0(t0)
	sw	t0, 348(sp)
	ld	t0, 368(sp)
	lw	t1, 348(sp)
	sw	t1, 0(t0)
	addiw	t0, s8, 1
	sw	t0, 344(sp)
	lw	t0, 344(sp)
	add	s0, t0, x0
	add	a7, a6, x0
.LBB30_95:                               # %label_95
	addi	t0, a4, 4
	sd	t0, 336(sp)
	addi	t0, a4, 4
	sd	t0, 328(sp)
	ld	t0, 328(sp)
	lw	t0, 0(t0)
	sw	t0, 324(sp)
	lw	t0, 324(sp)
	addiw	t0, t0, 1
	sw	t0, 320(sp)
	ld	t0, 336(sp)
	lw	t1, 320(sp)
	sw	t1, 0(t0)
	addiw	t0, a5, 1
	sw	t0, 316(sp)
	lw	t0, 316(sp)
	add	a5, t0, x0
	add	a6, a7, x0
	add	s8, s0, x0
	j	.LBB30_52
.LBB30_127:                               # %label_127
	slt	t0, s2, t5
	sb	t0, 315(sp)
	lbu	t0, 315(sp)
	beqz	t0, .LBB30_129
.LBB30_128:                               # %label_128
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 304(sp)
	addw	t0, t3, s2
	sw	t0, 300(sp)
	lw	t0, 300(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 288(sp)
	ld	t0, 288(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	ld	t0, 304(sp)
	lw	t1, 284(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 272(sp)
	addi	t0, a4, 4
	sd	t0, 264(sp)
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 260(sp)
	lw	t0, 260(sp)
	addiw	t0, t0, 2
	sw	t0, 256(sp)
	ld	t0, 272(sp)
	lw	t1, 256(sp)
	sw	t1, 0(t0)
	addiw	t0, s2, 1
	add	s7, t0, x0
	addiw	t0, s0, 1
	add	s6, t0, x0
	add	s2, s7, x0
	add	s0, s6, x0
	j	.LBB30_127
.LBB30_129:                               # %label_129
	add	s1, s8, x0
	add	a5, s0, x0
.LBB30_152:                               # %label_152
	slt	s5, s1, t4
	add	t0, s5, x0
	beqz	t0, .LBB30_154
.LBB30_153:                               # %label_153
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 232(sp)
	addiw	t0, a2, 1
	add	s3, t0, x0
	addw	t0, s3, s1
	add	s3, t0, x0
	add	t0, s3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 216(sp)
	ld	t0, 216(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	ld	t0, 232(sp)
	lw	t1, 212(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 200(sp)
	addi	t0, a4, 4
	sd	t0, 192(sp)
	ld	t0, 192(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	lw	t0, 188(sp)
	addiw	t0, t0, 2
	sw	t0, 184(sp)
	ld	t0, 200(sp)
	lw	t1, 184(sp)
	sw	t1, 0(t0)
	addiw	t0, s1, 1
	add	s4, t0, x0
	addiw	t0, a5, 1
	add	s3, t0, x0
	add	s1, s4, x0
	add	a5, s3, x0
	j	.LBB30_152
.LBB30_154:                               # %label_154
	ld	s0, 904(sp)
	ld	s1, 896(sp)
	ld	s2, 824(sp)
	ld	s3, 816(sp)
	ld	s4, 808(sp)
	ld	s5, 800(sp)
	ld	s6, 792(sp)
	ld	s7, 784(sp)
	ld	s8, 776(sp)
	ld	s10, 760(sp)
	ld	s11, 752(sp)
	li	a0, 0
	addi	sp, sp, 944
	ret
.Lfunc_end30:
	.size	fn.22, .Lfunc_end30-fn.22
                                        # -- End function

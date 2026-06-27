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
	li	t6, -1002592
	add	sp, sp, t6
	li	t6, 1002496
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 1002504
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 1002512
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 1002520
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 1002528
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 1002536
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 1002544
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 1002552
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 1002560
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 1002568
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 1002576
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 1002584
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 128
	add	t6, t6, sp
	sd	t6, 144(sp)
	li	t6, 152
	add	t6, t6, sp
	sd	t6, 168(sp)
	li	t6, 208
	add	t6, t6, sp
	li	t0, 40232
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40240
	add	t6, t6, sp
	li	t0, 80264
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80272
	add	t6, t6, sp
	li	t0, 120272
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 120280
	add	t6, t6, sp
	li	t0, 160280
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160300
	add	t6, t6, sp
	li	t0, 160320
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160332
	add	t6, t6, sp
	li	t0, 160352
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160380
	add	t6, t6, sp
	li	t0, 160400
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160412
	add	t6, t6, sp
	li	t0, 160432
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160444
	add	t6, t6, sp
	li	t0, 160464
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160476
	add	t6, t6, sp
	li	t0, 160496
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 160512
	add	t6, t6, sp
	li	t0, 200536
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 200544
	add	t6, t6, sp
	li	t0, 240568
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 240576
	add	t6, t6, sp
	li	t0, 280576
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 280584
	add	t6, t6, sp
	li	t0, 320584
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320596
	add	t6, t6, sp
	li	t0, 320616
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320628
	add	t6, t6, sp
	li	t0, 320648
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320676
	add	t6, t6, sp
	li	t0, 320696
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320708
	add	t6, t6, sp
	li	t0, 320728
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320748
	add	t6, t6, sp
	li	t0, 320768
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320780
	add	t6, t6, sp
	li	t0, 320800
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 320864
	add	t6, t6, sp
	li	t0, 360888
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 360896
	add	t6, t6, sp
	li	t0, 400920
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 400928
	add	t6, t6, sp
	li	t0, 440928
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 440936
	add	t6, t6, sp
	li	t0, 480936
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 480944
	add	t6, t6, sp
	li	t0, 520952
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 520960
	add	t6, t6, sp
	li	t0, 560968
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 560976
	add	t6, t6, sp
	li	t0, 600984
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 600992
	add	t6, t6, sp
	li	t0, 641000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 641008
	add	t6, t6, sp
	li	t0, 681016
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 681024
	add	t6, t6, sp
	li	t0, 721032
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 721040
	add	t6, t6, sp
	li	t0, 761040
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 761048
	add	t6, t6, sp
	li	t0, 761448
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 761556
	add	t6, t6, sp
	li	t0, 761576
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 761588
	add	t6, t6, sp
	li	t0, 761608
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 761816
	add	t6, t6, sp
	li	t0, 801816
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 801824
	add	t6, t6, sp
	li	t0, 841824
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 841852
	add	t6, t6, sp
	li	t0, 841872
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 841884
	add	t6, t6, sp
	li	t0, 841904
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 841928
	add	t6, t6, sp
	li	t0, 881928
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 881936
	add	t6, t6, sp
	li	t0, 921936
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 921972
	add	t6, t6, sp
	li	t0, 921992
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 922004
	add	t6, t6, sp
	li	t0, 922024
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 922032
	add	t6, t6, sp
	li	t0, 962032
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 962040
	add	t6, t6, sp
	li	t0, 1002040
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1002052
	add	t6, t6, sp
	li	t0, 1002072
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1002084
	add	t6, t6, sp
	li	t0, 1002104
	add	t0, sp, t0
	sd	t6, 0(t0)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21001
	call	printlnInt
	ld	t0, 168(sp)
	addi	s1, t0, 0
	li	t1, 100
	sw	t1, 0(s1)
	ld	t0, 168(sp)
	addi	s1, t0, 4
	li	t1, 500
	sw	t1, 0(s1)
	ld	t0, 168(sp)
	addi	s1, t0, 8
	li	t1, 1000
	sw	t1, 0(s1)
	ld	t0, 168(sp)
	addi	s1, t0, 12
	li	t1, 2000
	sw	t1, 0(s1)
	ld	t0, 144(sp)
	ld	t1, 168(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 16
	call	builtin_memcpy
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a0, 0
	li	t0, 0
	li	t6, 1002120
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002136
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002152
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002168
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002184
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002200
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002216
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002232
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002248
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002264
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002280
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002296
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002312
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002328
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t0, 0
	li	t6, 1002344
	add	t6, sp, t6
	sd	t0, 0(t6)
.LBB8_7:                               # %label_7
	slti	t0, a0, 4
	sb	t0, 176(sp)
	lbu	t0, 176(sp)
	beqz	t0, .LBB8_9
.LBB8_8:                               # %label_8
	add	t0, a0, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 144(sp)
	add	t2, t1, t0
	sd	t2, 184(sp)
	ld	t0, 184(sp)
	lw	s1, 0(t0)
	li	t1, 100
	mulw	t0, a0, t1
	sw	t0, 192(sp)
	lw	t1, 192(sp)
	li	t6, 21000
	addw	t0, t1, t6
	sw	t0, 196(sp)
	lw	t0, 196(sp)
	addiw	t0, t0, 10
	sw	t0, 200(sp)
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	lw	a0, 200(sp)
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s0, 0
	li	t6, 1002120
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002112
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002136
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002128
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002152
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002144
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002168
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002160
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002184
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002176
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002200
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002192
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002216
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002232
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002224
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002248
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002240
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002264
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002256
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002280
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002272
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002296
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002288
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002312
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002304
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002328
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002320
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002344
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002336
	add	t6, sp, t6
	sd	t0, 0(t6)
	j	.LBB8_21
.LBB8_9:                               # %label_9
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 0
	li	a1, 5000
	li	t6, 240568
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 240568
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 320584
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 280576
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 320584
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a1, t0, 24
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 280576
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 5000
	call	fn.2
	li	t6, 320648
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 320616
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 320648
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 280576
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 320616
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a1, 0
	li	a0, 0
	li	s1, 0
	li	t0, 0
	li	t6, 1002372
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_124
.LBB8_21:                               # %label_21
	slti	t0, s0, 8
	sb	t0, 204(sp)
	lbu	t0, 204(sp)
	beqz	t0, .LBB8_23
.LBB8_22:                               # %label_22
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	add	a0, s0, x0
	add	a1, s1, x0
	li	t6, 80264
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 40232
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 80264
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 160280
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 160280
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 40232
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 160288
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160288
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	a1, 0(t6)
	add	a2, s1, x0
	call	fn.2
	li	t6, 160352
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 160320
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 160352
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	li	t6, 160320
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.15
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	call	fn.1
	li	t6, 160360
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 160360
	add	t6, sp, t6
	lbu	t1, 0(t6)
	li	t0, 1
	subw	t0, t0, t1
	li	t6, 160361
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t2, 160361
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB8_22_jump_0
	j	.LBB8_50
.LBB8_22_jump_0:                               # %label_22_jump_0
	j	.LBB8_51
.LBB8_23:                               # %label_23
	addiw	a7, a0, 1
	add	a0, a7, x0
	li	t6, 1002112
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002120
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002128
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002136
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002144
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002152
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002160
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002168
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002176
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002184
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002192
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002200
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002208
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002216
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002224
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002232
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002240
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002248
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002256
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002264
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002280
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002288
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002296
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002304
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002312
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002320
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002328
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002336
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002344
	add	t6, sp, t6
	sd	t0, 0(t6)
	j	.LBB8_7
.LBB8_50:                               # %label_50
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21901
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_51:                               # %label_51
	li	t6, 40232
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 160368
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 160368
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	a1, 0(t6)
	add	a2, s1, x0
	call	fn.2
	li	t6, 160432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 160400
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 160432
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	li	t6, 160400
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	call	fn.1
	li	t6, 160440
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 160440
	add	t6, sp, t6
	lbu	t1, 0(t6)
	li	t0, 1
	subw	t5, t0, t1
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	add	t0, t5, x0
	beqz	t0, .LBB8_71
.LBB8_70:                               # %label_70
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21902
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_71:                               # %label_71
	li	t6, 40232
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t4, t0, 24
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	a1, 0(t6)
	add	a2, s1, x0
	call	fn.2
	li	t6, 160496
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 160464
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 160496
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	li	t6, 160464
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 120272
	add	t6, sp, t6
	ld	a0, 0(t6)
	add	a1, s1, x0
	call	fn.1
	add	t3, a0, x0
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t0, 1
	subw	s11, t0, t1
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	add	t0, s11, x0
	beqz	t0, .LBB8_91
.LBB8_90:                               # %label_90
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	a0, 21903
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
.LBB8_91:                               # %label_91
	li	t6, 160320
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s10, t0, 12
	lw	s9, 0(s10)
	li	t1, 100
	divw	s8, s9, t1
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	add	a0, s8, x0
	call	printlnInt
	li	t6, 160400
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s7, t0, 12
	lw	s6, 0(s7)
	li	t1, 100
	divw	s5, s6, t1
	add	a0, s5, x0
	call	printlnInt
	li	t6, 160464
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s4, t0, 12
	lw	s3, 0(s4)
	li	t1, 100
	divw	t0, s3, t1
	li	t6, 160504
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 160504
	add	t6, sp, t6
	lw	a0, 0(t6)
	call	printlnInt
	addiw	s2, s0, 1
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002336
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002304
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002288
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002256
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002224
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002176
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002144
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120272
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002128
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160288
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002112
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160320
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002160
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160368
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002192
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160400
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002240
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	t0, t4, x0
	li	t6, 1002272
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 160464
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002320
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	s0, s2, x0
	j	.LBB8_21
.LBB8_124:                               # %label_124
	li	t6, 1002372
	add	t6, sp, t6
	lw	t0, 0(t6)
	slti	t0, t0, 1000
	li	t6, 320656
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 320656
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_126
.LBB8_125:                               # %label_125
	li	t6, 1002372
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 73
	mulw	t0, t0, t1
	li	t6, 320660
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320660
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 29
	li	t6, 320664
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320664
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100000
	remw	t0, t0, t1
	li	t6, 320668
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 320728
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 320696
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 320728
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 320736
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 320736
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 320668
	add	t6, sp, t6
	lw	a2, 0(t6)
	li	t6, 320696
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.5
	li	t6, 320744
	add	t6, sp, t6
	sw	a0, 0(t6)
	li	t6, 320800
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 320768
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 320800
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 280576
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 5000
	li	t6, 320668
	add	t6, sp, t6
	lw	a2, 0(t6)
	li	t6, 320768
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.6
	add	s0, a0, x0
	li	t6, 320744
	add	t6, sp, t6
	lw	t0, 0(t6)
	xori	t0, t0, -1
	sltu	t0, x0, t0
	li	t6, 320808
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t2, 320808
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB8_125_jump_0
	j	.LBB8_155
.LBB8_125_jump_0:                               # %label_125_jump_0
	j	.LBB8_156
.LBB8_126:                               # %label_126
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002408
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 1000
	divw	a4, t0, t1
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t1, 1000
	divw	a4, s1, t1
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	a0, 1
	li	a1, 300
	li	t6, 400920
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.14
	li	t6, 360888
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 400920
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 360888
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a5, t0, 24
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 360888
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a4, t0, 0
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	a4, 0(t0)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 300
	li	t6, 1002440
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.16
	add	a6, a0, x0
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 480936
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 440928
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 480936
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 360888
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a4, t0, 24
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 440928
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	a2, 300
	call	fn.2
	li	t6, 440928
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 300
	call	fn.4
	add	a5, a0, x0
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 360888
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a4, t0, 0
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	a4, 0(t0)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002456
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 1000
	divw	a4, t0, t1
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002448
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	a0, 50
	li	a1, 50
	li	a2, 1
	li	t6, 560968
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 520952
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 560968
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	a0, 50
	li	a1, 50
	li	a2, 2
	li	t6, 641000
	add	t6, sp, t6
	ld	a3, 0(t6)
	call	fn.7
	li	t6, 600984
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 641000
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 721032
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s0, t0, 8
	li	t6, 761448
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t0, 0
	li	t6, 1002376
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_217
.LBB8_155:                               # %label_155
	xori	t0, s0, -1
	sltu	t0, x0, t0
	li	t6, 320810
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 320810
	add	t6, sp, t6
	lbu	t0, 0(t6)
	li	t6, 320809
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 320809
	add	t6, sp, t6
	lbu	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 320812
	add	t6, sp, t6
	sb	t0, 0(t6)
	j	.LBB8_157
.LBB8_156:                               # %label_156
	li	t0, 0
	li	t6, 320811
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 320811
	add	t6, sp, t6
	lbu	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 320812
	add	t6, sp, t6
	sb	t0, 0(t6)
.LBB8_157:                               # %label_157
	add	t0, a1, x0
	li	t6, 1002352
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t2, 320812
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_164
.LBB8_163:                               # %label_163
	addiw	t0, a1, 1
	li	t6, 320816
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320816
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002352
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB8_164:                               # %label_164
	li	t6, 320696
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	li	t6, 320824
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 320824
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 320832
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320832
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, a0, t1
	li	t6, 320836
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320768
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 16
	li	t6, 320840
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 320840
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 320848
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320848
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s1, t1
	li	t6, 320852
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002372
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 320856
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 320836
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	a0, t0, x0
	li	t6, 320852
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s1, t0, x0
	li	t6, 320856
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002372
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002352
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	a1, t0, x0
	j	.LBB8_124
.LBB8_217:                               # %label_217
	li	t6, 1002376
	add	t6, sp, t6
	lw	t0, 0(t6)
	sltiu	t0, t0, 100
	li	t6, 761456
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761456
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_219
.LBB8_218:                               # %label_218
	li	t6, 1002376
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 761040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761464
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 761464
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 761448
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 400
	call	builtin_memcpy
	li	t6, 1002376
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761472
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 761472
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002376
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_217
.LBB8_219:                               # %label_219
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 761040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, s0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 721032
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761480
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761480
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 721032
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	li	t6, 761488
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761488
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 0
	sw	t1, 0(t0)
	li	t6, 681016
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 721032
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 520952
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 600984
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 681016
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.3
	li	t6, 761496
	add	t6, sp, t6
	sb	a0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t2, 761496
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_236
.LBB8_235:                               # %label_235
	li	s1, 0
	li	t0, 0
	li	t6, 1002380
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s0, 0
	j	.LBB8_239
.LBB8_236:                               # %label_236
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 761608
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 761608
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t0, 0
	li	t6, 1002368
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s0, 0
	j	.LBB8_268
.LBB8_239:                               # %label_239
	li	t6, 1002380
	add	t6, sp, t6
	lw	t0, 0(t6)
	slti	t0, t0, 50
	li	t6, 761497
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761497
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_241
.LBB8_240:                               # %label_240
	li	t0, 0
	li	t6, 1002384
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	a0, s1, x0
	j	.LBB8_245
.LBB8_241:                               # %label_241
	li	t1, 1000000000
	remw	t0, s1, t1
	li	t6, 761548
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 761548
	add	t6, sp, t6
	lw	a0, 0(t6)
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	j	.LBB8_236
.LBB8_245:                               # %label_245
	li	t6, 1002384
	add	t6, sp, t6
	lw	t0, 0(t6)
	slti	t0, t0, 50
	li	t6, 761498
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761498
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_247
.LBB8_246:                               # %label_246
	li	t6, 681016
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 761504
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002380
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 761504
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761512
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 1002384
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 761512
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761520
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 761520
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761528
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761528
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, a0, t1
	li	t6, 761532
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761532
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 1000000000
	and	t0, t0, t6
	li	t6, 761536
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002384
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761540
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761536
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	a0, t0, x0
	li	t6, 761540
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002384
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_245
.LBB8_247:                               # %label_247
	li	t6, 1002380
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761544
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761544
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002380
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	s1, a0, x0
	li	t6, 1002384
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s0, t0, x0
	j	.LBB8_239
.LBB8_268:                               # %label_268
	li	t6, 1002368
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 5000
	slt	t0, t0, t6
	li	t6, 761616
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761616
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_270
.LBB8_269:                               # %label_269
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 761624
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 1002368
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 761624
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761632
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 761632
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761640
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761640
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s0, t1
	li	t6, 761644
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761648
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761656
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761656
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761664
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761664
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761668
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761648
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 761668
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 1002368
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761672
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761644
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s0, t0, x0
	li	t6, 761672
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002368
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_268
.LBB8_270:                               # %label_270
	li	t0, 0
	li	t6, 1002364
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s1, 0
.LBB8_286:                               # %label_286
	li	t6, 1002364
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 5000
	slt	t0, t0, t6
	li	t6, 761676
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761676
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_288
.LBB8_287:                               # %label_287
	li	t6, 1002364
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 11241
	mulw	t0, t0, t1
	li	t6, 761680
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761680
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 12345
	addw	t0, t0, t6
	li	t6, 761684
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761684
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5000
	remw	t0, t0, t1
	li	t6, 761688
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 761696
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761688
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 761696
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761704
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 761704
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761712
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761712
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s1, t1
	li	t6, 761716
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761720
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761728
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761728
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761736
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761736
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761740
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761720
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 761740
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 1002364
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761744
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761716
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s1, t0, x0
	li	t6, 761744
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002364
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_286
.LBB8_288:                               # %label_288
	li	t0, 0
	li	t6, 1002360
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	a0, 0
.LBB8_309:                               # %label_309
	li	t6, 1002360
	add	t6, sp, t6
	lw	t0, 0(t6)
	slti	t0, t0, 1000
	li	t6, 761748
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 761748
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_311
.LBB8_310:                               # %label_310
	li	t6, 1002360
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5
	mulw	t0, t0, t1
	li	t6, 761752
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761752
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5000
	remw	t0, t0, t1
	li	t6, 761756
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 200536
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 24
	li	t6, 761760
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761756
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 761760
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 761768
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 761768
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761776
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761776
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, a0, t1
	li	t6, 761780
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761784
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	li	t6, 761792
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 761792
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 761800
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761800
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761804
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761784
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 761804
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	li	t6, 1002360
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 761808
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 761780
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	a0, t0, x0
	li	t6, 761808
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002360
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_309
.LBB8_311:                               # %label_311
	li	t1, 1000
	divw	a3, s0, t1
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t1, 1000
	divw	a3, s1, t1
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002408
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 100
	divw	a3, t0, t1
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 761576
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a3, t0, 4
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	a3, 0(t0)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 1000
	divw	a3, t0, t1
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t0, 0
	li	t6, 1002388
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB8_342:                               # %label_342
	li	t6, 1002388
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 10000
	sltu	t0, t0, t6
	li	t6, 841832
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 841832
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_344
.LBB8_343:                               # %label_343
	li	t6, 1002388
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 841824
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 841840
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 841840
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 42
	sw	t1, 0(t0)
	li	t6, 1002388
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 841848
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 841848
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002388
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_342
.LBB8_344:                               # %label_344
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 801816
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 841824
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 841904
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 841872
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 841904
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 801816
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 841872
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.21
	li	t6, 841872
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 12
	li	t6, 841912
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 841912
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	t0, 0(t0)
	li	t6, 841920
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 841920
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100
	divw	t0, t0, t1
	li	t6, 841924
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 841924
	add	t6, sp, t6
	lw	a0, 0(t6)
	call	printlnInt
	li	t6, 921936
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 881928
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 921936
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t0, 0
	li	t6, 1002356
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	s1, 0
	li	s0, 0
.LBB8_362:                               # %label_362
	li	t6, 1002356
	add	t6, sp, t6
	lw	t0, 0(t6)
	slti	t0, t0, 1000
	li	t6, 921944
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 921944
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB8_364
.LBB8_363:                               # %label_363
	li	t6, 1002356
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 881928
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t1, t0
	li	t6, 1002356
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 2
	remw	t0, t0, t1
	li	t6, 921948
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 921948
	add	t6, sp, t6
	lw	t0, 0(t6)
	sltiu	t0, t0, 1
	li	t6, 921952
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 921952
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB8_363_jump_0
	j	.LBB8_372
.LBB8_363_jump_0:                               # %label_363_jump_0
	j	.LBB8_373
.LBB8_364:                               # %label_364
	li	t6, 1002400
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 922024
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 921992
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 922024
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 881928
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1000
	li	t6, 921992
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.10
	li	t6, 921992
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a2, t0, 12
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	a2, 0(t0)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 100
	divw	a2, t0, t1
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	t6, 1002040
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 962032
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 1002040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 962032
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a2, t0, 0
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t1, 123
	sw	t1, 0(t0)
	li	t6, 1002104
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	fn.12
	li	t6, 1002072
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 1002104
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	li	t6, 962032
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	a1, 1
	li	t6, 1002072
	add	t6, sp, t6
	ld	a2, 0(t6)
	call	fn.13
	li	t6, 962032
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a2, t0, 0
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	t0, 0(t6)
	lw	a2, 0(t0)
	li	t6, 1002424
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a0, 0(t6)
	call	printlnInt
	li	a0, 21999
	call	printlnInt
	li	t6, 1002400
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 1002408
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 1002416
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 1002424
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 1002432
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 1002440
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 1002448
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 1002456
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 1002464
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 1002472
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 1002480
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 1002488
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 1002496
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 1002504
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 1002512
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 1002520
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 1002528
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 1002536
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 1002544
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 1002552
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 1002560
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 1002568
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 1002576
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 1002584
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 1002592
	add	sp, sp, t6
	ret
.LBB8_372:                               # %label_372
	li	t0, 1
	li	t6, 921956
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t0, 1
	li	t6, 1002392
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 921956
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 921964
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	t0, s0, x0
	li	t6, 1002396
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB8_374
.LBB8_373:                               # %label_373
	li	t0, 2
	li	t6, 921960
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t0, 2
	li	t6, 1002396
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 921960
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 921964
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	t0, s1, x0
	li	t6, 1002392
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB8_374:                               # %label_374
	li	t6, 921964
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(a0)
	li	t6, 1002356
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 921968
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 921968
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 1002356
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 1002392
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s1, t0, x0
	li	t6, 1002396
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s0, t0, x0
	j	.LBB8_362
.Lfunc_end8:
	.size	fn.0, .Lfunc_end8-fn.0
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -112
	sd	s0, 96(sp)
	j	.LBB9_0
.LBB9_0:                               # %label_0
	li	a2, 0
.LBB9_5:                               # %label_5
	addiw	s0, a1, -1
	slt	t5, a2, s0
	add	t0, t5, x0
	beqz	t0, .LBB9_7
.LBB9_6:                               # %label_6
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t4, a0, t0
	lw	t3, 0(t4)
	addiw	a6, a2, 1
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a0, t0
	lw	a5, 0(a7)
	slt	a4, a5, t3
	add	t0, a4, x0
	beq	x0, t0, .LBB9_6_jump_0
	j	.LBB9_22
.LBB9_6_jump_0:                               # %label_6_jump_0
	j	.LBB9_23
.LBB9_7:                               # %label_7
	ld	s0, 96(sp)
	li	a0, 1
	addi	sp, sp, 112
	ret
.LBB9_22:                               # %label_22
	ld	s0, 96(sp)
	li	a0, 0
	addi	sp, sp, 112
	ret
.LBB9_23:                               # %label_23
	addiw	a3, a2, 1
	add	a2, a3, x0
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
	slt	t3, a3, a2
	add	t0, t3, x0
	beqz	t0, .LBB10_9
.LBB10_8:                               # %label_8
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a1, t0
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	t0, 0(a6)
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a7)
	addiw	a4, a3, 1
	add	a3, a4, x0
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
	addi	sp, sp, -320
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
	sd	s11, 312(sp)
	j	.LBB11_0
.LBB11_0:                               # %label_0
	addi	a3, a0, 0
	lw	a4, 0(a3)
	addi	a3, a1, 4
	lw	a3, 0(a3)
	sub	t0, a4, a3
	sltu	a3, x0, t0
	add	t0, a3, x0
	beqz	t0, .LBB11_14
.LBB11_13:                               # %label_13
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
	ld	s11, 312(sp)
	li	a0, 0
	addi	sp, sp, 320
	ret
.LBB11_14:                               # %label_14
	addi	s8, a2, 4
	addi	s7, a0, 4
	lw	t0, 0(s7)
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(s8)
	addi	s8, a2, 0
	addi	s7, a1, 0
	lw	t0, 0(s7)
	sw	t0, 4(sp)
	lw	t1, 4(sp)
	sw	t1, 0(s8)
	li	a7, 0
	li	a3, 0
.LBB11_26:                               # %label_26
	addi	t0, a0, 4
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 16(sp)
	lw	t1, 16(sp)
	slt	t0, a7, t1
	sb	t0, 20(sp)
	lbu	t0, 20(sp)
	beqz	t0, .LBB11_28
.LBB11_27:                               # %label_27
	li	a6, 0
	add	a4, a3, x0
	j	.LBB11_35
.LBB11_28:                               # %label_28
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
	ld	s11, 312(sp)
	li	a0, 1
	addi	sp, sp, 320
	ret
.LBB11_35:                               # %label_35
	addi	t0, a1, 0
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 32(sp)
	lw	t1, 32(sp)
	slt	t0, a6, t1
	sb	t0, 36(sp)
	lbu	t0, 36(sp)
	beqz	t0, .LBB11_37
.LBB11_36:                               # %label_36
	addi	t0, a2, 8
	sd	t0, 40(sp)
	add	t0, a7, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 40(sp)
	add	t2, t1, t0
	sd	t2, 48(sp)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 48(sp)
	add	t2, t1, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	li	t1, 0
	sw	t1, 0(t0)
	li	a5, 0
	j	.LBB11_50
.LBB11_37:                               # %label_37
	addiw	t3, a7, 1
	add	a7, t3, x0
	add	a3, a4, x0
	j	.LBB11_26
.LBB11_50:                               # %label_50
	addi	t0, a0, 0
	sd	t0, 64(sp)
	ld	t0, 64(sp)
	lw	t0, 0(t0)
	sw	t0, 72(sp)
	lw	t1, 72(sp)
	slt	t0, a5, t1
	sb	t0, 76(sp)
	lbu	t0, 76(sp)
	beqz	t0, .LBB11_52
.LBB11_51:                               # %label_51
	addi	t0, a2, 8
	sd	t0, 80(sp)
	add	t0, a7, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 80(sp)
	add	t2, t1, t0
	sd	t2, 88(sp)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 88(sp)
	add	t2, t1, t0
	sd	t2, 96(sp)
	addi	t0, a2, 8
	sd	t0, 104(sp)
	add	t0, a7, x0
	li	t1, 400
	mul	t0, t0, t1
	ld	t1, 104(sp)
	add	t2, t1, t0
	sd	t2, 112(sp)
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 112(sp)
	add	t2, t1, t0
	sd	t2, 120(sp)
	ld	t0, 120(sp)
	lw	t0, 0(t0)
	sw	t0, 128(sp)
	addi	s11, a0, 8
	add	t0, a7, x0
	li	t1, 400
	mul	t0, t0, t1
	add	s10, s11, t0
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s9, s10, t0
	lw	s6, 0(s9)
	addi	s5, a1, 8
	add	t0, a5, x0
	li	t1, 400
	mul	t0, t0, t1
	add	s4, s5, t0
	add	t0, a6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s3, s4, t0
	lw	s2, 0(s3)
	mulw	s1, s6, s2
	lw	t0, 128(sp)
	addw	t0, t0, s1
	sw	t0, 132(sp)
	ld	t0, 96(sp)
	lw	t1, 132(sp)
	sw	t1, 0(t0)
	addiw	t5, a5, 1
	add	a5, t5, x0
	j	.LBB11_50
.LBB11_52:                               # %label_52
	addiw	t4, a6, 1
	add	a6, t4, x0
	add	a4, a5, x0
	j	.LBB11_35
.Lfunc_end11:
	.size	fn.3, .Lfunc_end11-fn.3
                                        # -- End function
	.globl	fn.4                            # -- Begin function fn.4
	.p2align	1
	.type	fn.4,@function
fn.4:                                   # @fn.4
# %bb.0:                                # %alloca
	addi	sp, sp, -256
	sd	s0, 232(sp)
	sd	s1, 240(sp)
	li	t6, 132
	add	t6, t6, sp
	sd	t6, 152(sp)
	li	t6, 164
	add	t6, t6, sp
	sd	t6, 184(sp)
	j	.LBB12_0
.LBB12_0:                               # %label_0
	sd	ra, 200(sp)
	sd	a0, 208(sp)
	sd	a1, 216(sp)
	sd	a2, 224(sp)
	ld	a0, 184(sp)
	call	fn.12
	ld	t0, 152(sp)
	ld	t1, 184(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	ld	a0, 208(sp)
	ld	a1, 216(sp)
	ld	a2, 152(sp)
	call	fn.21
	ld	t0, 216(sp)
	li	t1, 2
	remw	a2, t0, t1
	sd	a2, 224(sp)
	ld	t0, 224(sp)
	sltiu	a2, t0, 1
	sd	a2, 224(sp)
	ld	ra, 200(sp)
	ld	a0, 208(sp)
	ld	a1, 216(sp)
	ld	a2, 224(sp)
	add	t0, a2, x0
	beqz	t0, .LBB12_14
.LBB12_13:                               # %label_13
	li	t1, 2
	divuw	s0, a1, t1
	addiw	t0, s0, -1
	sw	t0, 192(sp)
	lw	t0, 192(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s1, 0(s0)
	li	t1, 2
	divuw	s0, a1, t1
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s0, 0(s0)
	addw	s0, s1, s0
	li	t1, 2
	divw	s0, s0, t1
	add	s0, s0, x0
	add	t0, s0, x0
	sw	t0, 196(sp)
	j	.LBB12_15
.LBB12_14:                               # %label_14
	li	t1, 2
	divuw	s0, a1, t1
	add	t0, s0, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	s0, 0(s0)
	add	s0, s0, x0
	add	t0, s0, x0
	sw	t0, 196(sp)
.LBB12_15:                               # %label_15
	lw	a0, 196(sp)
	ld	s0, 232(sp)
	ld	s1, 240(sp)
	addi	sp, sp, 256
	ret
.Lfunc_end12:
	.size	fn.4, .Lfunc_end12-fn.4
                                        # -- End function
	.globl	fn.5                            # -- Begin function fn.5
	.p2align	1
	.type	fn.5,@function
fn.5:                                   # @fn.5
# %bb.0:                                # %alloca
	addi	sp, sp, -192
	sd	s0, 112(sp)
	sd	s1, 120(sp)
	sd	s3, 128(sp)
	sd	s4, 136(sp)
	sd	s5, 144(sp)
	sd	s6, 152(sp)
	sd	s7, 160(sp)
	sd	s9, 168(sp)
	sd	s10, 176(sp)
	j	.LBB13_0
.LBB13_0:                               # %label_0
	addi	s10, a3, 0
	addi	s7, a3, 0
	lw	s7, 0(s7)
	addiw	t0, s7, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(s10)
	li	t0, 0
	sw	t0, 20(sp)
.LBB13_15:                               # %label_15
	lw	t0, 20(sp)
	slt	s6, t0, a1
	add	t0, s6, x0
	beqz	t0, .LBB13_17
.LBB13_16:                               # %label_16
	addi	s5, a3, 12
	addi	s4, a3, 12
	lw	s3, 0(s4)
	addiw	t0, s3, 1
	sw	t0, 4(sp)
	lw	t1, 4(sp)
	sw	t1, 0(s5)
	addi	s1, a3, 4
	addi	s0, a3, 4
	lw	t5, 0(s0)
	addiw	t0, t5, 1
	sw	t0, 8(sp)
	lw	t1, 8(sp)
	sw	t1, 0(s1)
	lw	t0, 20(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	a7, 0(t3)
	sub	t0, a7, a2
	sltiu	a6, t0, 1
	add	t0, a6, x0
	beq	x0, t0, .LBB13_16_jump_0
	j	.LBB13_39
.LBB13_16_jump_0:                               # %label_16_jump_0
	j	.LBB13_40
.LBB13_17:                               # %label_17
	addi	a4, a3, 16
	addi	s9, a3, 16
	lw	s9, 0(s9)
	addw	t0, s9, a1
	sw	t0, 16(sp)
	lw	t1, 16(sp)
	sw	t1, 0(a4)
	ld	s0, 112(sp)
	ld	s1, 120(sp)
	ld	s3, 128(sp)
	ld	s4, 136(sp)
	ld	s5, 144(sp)
	ld	s6, 152(sp)
	ld	s7, 160(sp)
	ld	s9, 168(sp)
	ld	s10, 176(sp)
	li	a0, -1
	addi	sp, sp, 192
	ret
.LBB13_39:                               # %label_39
	addi	a4, a3, 16
	addi	s9, a3, 16
	lw	s9, 0(s9)
	lw	t1, 20(sp)
	addw	s9, s9, t1
	addiw	t0, s9, 1
	sw	t0, 12(sp)
	lw	t1, 12(sp)
	sw	t1, 0(a4)
	lw	a0, 20(sp)
	ld	s0, 112(sp)
	ld	s1, 120(sp)
	ld	s3, 128(sp)
	ld	s4, 136(sp)
	ld	s5, 144(sp)
	ld	s6, 152(sp)
	ld	s7, 160(sp)
	ld	s9, 168(sp)
	ld	s10, 176(sp)
	addi	sp, sp, 192
	ret
.LBB13_40:                               # %label_40
	lw	t0, 20(sp)
	addiw	a5, t0, 1
	add	t0, a5, x0
	sw	t0, 20(sp)
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
	sd	s1, 176(sp)
	sd	s2, 184(sp)
	sd	s3, 192(sp)
	sd	s4, 200(sp)
	sd	s5, 208(sp)
	sd	s6, 216(sp)
	sd	s7, 224(sp)
	sd	s8, 232(sp)
	sd	s9, 240(sp)
	sd	s10, 248(sp)
	j	.LBB14_0
.LBB14_0:                               # %label_0
	addi	a7, a3, 0
	addi	t5, a3, 0
	lw	t5, 0(t5)
	addiw	t0, t5, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a7)
	addiw	a7, a1, -1
	li	t4, 0
	add	t3, a7, x0
.LBB14_18:                               # %label_18
	slt	t0, t3, t4
	xori	t0, t0, 1
	sb	t0, 4(sp)
	lbu	t0, 4(sp)
	beqz	t0, .LBB14_20
.LBB14_19:                               # %label_19
	subw	t0, t3, t4
	sw	t0, 8(sp)
	lw	t0, 8(sp)
	li	t1, 2
	divw	t0, t0, t1
	sw	t0, 12(sp)
	lw	t1, 12(sp)
	addw	t0, t4, t1
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
	addi	t0, a3, 4
	sd	t0, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	addiw	t0, t0, 1
	sw	t0, 68(sp)
	ld	t0, 48(sp)
	lw	t1, 68(sp)
	sw	t1, 0(t0)
	lw	t0, 16(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	s10, a0, t0
	lw	a6, 0(s10)
	sub	t0, a6, a2
	sltiu	a5, t0, 1
	add	t0, a5, x0
	beq	x0, t0, .LBB14_19_jump_0
	j	.LBB14_49
.LBB14_19_jump_0:                               # %label_19_jump_0
	j	.LBB14_50
.LBB14_20:                               # %label_20
	ld	s1, 176(sp)
	ld	s2, 184(sp)
	ld	s3, 192(sp)
	ld	s4, 200(sp)
	ld	s5, 208(sp)
	ld	s6, 216(sp)
	ld	s7, 224(sp)
	ld	s8, 232(sp)
	ld	s9, 240(sp)
	ld	s10, 248(sp)
	li	a0, -1
	addi	sp, sp, 256
	ret
.LBB14_49:                               # %label_49
	addi	a4, a3, 16
	addi	s9, a3, 16
	lw	s9, 0(s9)
	addiw	t0, s9, 1
	sw	t0, 72(sp)
	lw	t1, 72(sp)
	sw	t1, 0(a4)
	lw	a0, 16(sp)
	ld	s1, 176(sp)
	ld	s2, 184(sp)
	ld	s3, 192(sp)
	ld	s4, 200(sp)
	ld	s5, 208(sp)
	ld	s6, 216(sp)
	ld	s7, 224(sp)
	ld	s8, 232(sp)
	ld	s9, 240(sp)
	ld	s10, 248(sp)
	addi	sp, sp, 256
	ret
.LBB14_50:                               # %label_50
	lw	t0, 16(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	s8, a0, t0
	lw	s7, 0(s8)
	slt	s6, s7, a2
	add	t0, s6, x0
	beq	x0, t0, .LBB14_50_jump_0
	j	.LBB14_65
.LBB14_50_jump_0:                               # %label_50_jump_0
	j	.LBB14_66
.LBB14_51:                               # %label_51
	addi	s3, a3, 16
	addi	s2, a3, 16
	lw	s1, 0(s2)
	addiw	t0, s1, 1
	sw	t0, 76(sp)
	lw	t1, 76(sp)
	sw	t1, 0(s3)
	add	t4, t5, x0
	add	t3, a7, x0
	j	.LBB14_18
.LBB14_65:                               # %label_65
	lw	t0, 16(sp)
	addiw	s5, t0, 1
	add	t5, s5, x0
	add	a7, t3, x0
	j	.LBB14_67
.LBB14_66:                               # %label_66
	lw	t0, 16(sp)
	addiw	s4, t0, -1
	add	a7, s4, x0
	add	t5, t4, x0
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
	li	t6, -120800
	add	sp, sp, t6
	li	t6, 120712
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 120720
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 120728
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 120736
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 120744
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 120752
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 120760
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 120768
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 120776
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 120784
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 120792
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 0
	add	t6, t6, sp
	li	t0, 40008
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40016
	add	t6, t6, sp
	li	t0, 80024
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80040
	add	t6, t6, sp
	li	t0, 120040
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 120048
	add	t6, t6, sp
	li	t0, 120448
	add	t0, sp, t0
	sd	t6, 0(t0)
	j	.LBB15_0
.LBB15_0:                               # %label_0
	li	t6, 80024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 80032
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 120616
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 400
	call	builtin_memset
	li	t6, 120616
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s1, 0
.LBB15_14:                               # %label_14
	sltiu	t0, s1, 100
	li	t6, 120456
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120456
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB15_16
.LBB15_15:                               # %label_15
	add	t0, s1, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 120040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a5, t1, t0
	li	t6, 120616
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 400
	call	builtin_memcpy
	addiw	a4, s1, 1
	li	t6, 120656
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120616
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	ld	t5, 0(t6)
	add	s1, a4, x0
	j	.LBB15_14
.LBB15_16:                               # %label_16
	li	t6, 120616
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 80032
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120040
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 80024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s11, t0, 4
	li	t6, 120624
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(s11)
	li	t6, 80024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s11, t0, 0
	li	t6, 120632
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(s11)
	li	t6, 40008
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 80024
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 120616
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	s0, 0
	li	s1, 0
	li	a4, 0
.LBB15_28:                               # %label_28
	slt	t0, s0, a0
	li	t6, 120457
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120457
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB15_30
.LBB15_29:                               # %label_29
	li	t5, 0
	add	s11, s1, x0
	add	a5, a4, x0
	j	.LBB15_35
.LBB15_30:                               # %label_30
	li	t6, 120616
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 40008
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40008
	call	builtin_memcpy
	li	t6, 120616
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120624
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120632
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120640
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120648
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120656
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120664
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120672
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120680
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120688
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120696
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120704
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 120712
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 120720
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 120728
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 120736
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 120744
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 120752
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 120760
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 120768
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 120776
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 120784
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 120792
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 120800
	add	sp, sp, t6
	ret
.LBB15_35:                               # %label_35
	slt	t0, t5, a1
	li	t6, 120458
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120458
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB15_37
.LBB15_36:                               # %label_36
	sltiu	t0, a2, 1
	li	t6, 120459
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120459
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB15_36_jump_0
	j	.LBB15_43
.LBB15_36_jump_0:                               # %label_36_jump_0
	j	.LBB15_44
.LBB15_37:                               # %label_37
	addiw	s2, s0, 1
	add	s0, s2, x0
	add	s1, s11, x0
	add	a4, a5, x0
	j	.LBB15_28
.LBB15_43:                               # %label_43
	li	t6, 40008
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 120464
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	t0, s0, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 120464
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120472
	add	t6, sp, t6
	sd	t2, 0(t6)
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 120472
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a4, t1, t0
	sub	t0, s0, t5
	sltiu	t0, t0, 1
	li	t6, 120480
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120480
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB15_43_jump_0
	j	.LBB15_54
.LBB15_43_jump_0:                               # %label_43_jump_0
	j	.LBB15_55
.LBB15_44:                               # %label_44
	xori	t0, a2, 1
	sltiu	t0, t0, 1
	li	t6, 120496
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120496
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB15_44_jump_0
	j	.LBB15_66
.LBB15_44_jump_0:                               # %label_44_jump_0
	j	.LBB15_67
.LBB15_45:                               # %label_45
	addiw	s3, t5, 1
	add	t5, s3, x0
	add	s11, t3, x0
	add	a5, a6, x0
	j	.LBB15_35
.LBB15_54:                               # %label_54
	li	t0, 1
	li	t6, 120484
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t4, 1
	li	t6, 120484
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120492
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	a7, a5, x0
	j	.LBB15_56
.LBB15_55:                               # %label_55
	li	t0, 0
	li	t6, 120488
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	a7, 0
	li	t6, 120488
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120492
	add	t6, sp, t6
	sw	t0, 0(t6)
	add	t4, s11, x0
.LBB15_56:                               # %label_56
	li	t6, 120492
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(a4)
	add	t3, t4, x0
	add	a6, a7, x0
	j	.LBB15_45
.LBB15_66:                               # %label_66
	li	t6, 40008
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 120504
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	t0, s0, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 120504
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120512
	add	t6, sp, t6
	sd	t2, 0(t6)
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 120512
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120520
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t1, 17
	mulw	t0, s0, t1
	li	t6, 120528
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t1, 23
	mulw	t0, t5, t1
	li	t6, 120532
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120528
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 120532
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, t0, t1
	li	t6, 120536
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120536
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 13
	li	t6, 120540
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120540
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100
	remw	t0, t0, t1
	li	t6, 120544
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120520
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120544
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	j	.LBB15_68
.LBB15_67:                               # %label_67
	xori	t0, a2, 2
	sltiu	t0, t0, 1
	li	t6, 120548
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120548
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB15_67_jump_0
	j	.LBB15_83
.LBB15_67_jump_0:                               # %label_67_jump_0
	j	.LBB15_84
.LBB15_68:                               # %label_68
	add	t3, s11, x0
	add	a6, a5, x0
	j	.LBB15_45
.LBB15_83:                               # %label_83
	li	t6, 40008
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 120552
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	t0, s0, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 120552
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120560
	add	t6, sp, t6
	sd	t2, 0(t6)
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 120560
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120568
	add	t6, sp, t6
	sd	t2, 0(t6)
	mulw	t0, s0, a1
	li	t6, 120576
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120576
	add	t6, sp, t6
	lw	t0, 0(t6)
	addw	t0, t0, t5
	li	t6, 120580
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120580
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 1
	li	t6, 120584
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120568
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 120584
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(t0)
	j	.LBB15_85
.LBB15_84:                               # %label_84
	li	t6, 40008
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 8
	li	t6, 120592
	add	t6, sp, t6
	sd	t0, 0(t6)
	add	t0, s0, x0
	li	t1, 400
	mul	t0, t0, t1
	li	t6, 120592
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	t2, t1, t0
	li	t6, 120600
	add	t6, sp, t6
	sd	t2, 0(t6)
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	li	t6, 120600
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	s10, t1, t0
	mulw	s9, s0, s0
	mulw	s8, t5, t5
	addw	s7, s9, s8
	mulw	s6, s0, t5
	addw	s5, s7, s6
	li	t1, 50
	remw	t0, s5, t1
	li	t6, 120608
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120608
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(s10)
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
	addi	sp, sp, -352
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
	sd	s11, 336(sp)
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
	slt	s3, s6, a1
	add	s7, a2, x0
	add	t0, s3, x0
	beqz	t0, .LBB16_28
.LBB16_27:                               # %label_27
	addi	s2, a3, 12
	addi	a6, a3, 12
	lw	a6, 0(a6)
	addiw	t0, a6, 1
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(s2)
	addi	s2, a3, 4
	addi	a6, a3, 4
	lw	a6, 0(a6)
	addiw	t0, a6, 2
	sw	t0, 136(sp)
	lw	t1, 136(sp)
	sw	t1, 0(s2)
	add	t0, s6, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	s2, 0(a6)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a6, a0, t0
	lw	a6, 0(a6)
	slt	a6, a6, s2
	add	s8, a2, x0
	add	t0, a6, x0
	beq	x0, t0, .LBB16_27_jump_0
	j	.LBB16_50
.LBB16_27_jump_0:                               # %label_27_jump_0
	j	.LBB16_51
.LBB16_28:                               # %label_28
	slt	t3, s5, a1
	add	s9, s7, x0
	add	t0, t3, x0
	beq	x0, t0, .LBB16_28_jump_0
	j	.LBB16_56
.LBB16_28_jump_0:                               # %label_28_jump_0
	j	.LBB16_57
.LBB16_50:                               # %label_50
	add	s8, s6, x0
.LBB16_51:                               # %label_51
	add	s7, s8, x0
	j	.LBB16_28
.LBB16_56:                               # %label_56
	addi	a5, a3, 12
	addi	a4, a3, 12
	lw	a4, 0(a4)
	addiw	t0, a4, 1
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(a5)
	addi	a5, a3, 4
	addi	a4, a3, 4
	lw	a4, 0(a4)
	addiw	t0, a4, 2
	sw	t0, 144(sp)
	lw	t1, 144(sp)
	sw	t1, 0(a5)
	add	t0, s5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a5, 0(a4)
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a4, 0(a4)
	slt	a4, a4, a5
	add	s10, s7, x0
	add	t0, a4, x0
	beq	x0, t0, .LBB16_56_jump_0
	j	.LBB16_79
.LBB16_56_jump_0:                               # %label_56_jump_0
	j	.LBB16_80
.LBB16_57:                               # %label_57
	sub	t0, s9, a2
	sltu	s11, x0, t0
	add	t0, s11, x0
	beq	x0, t0, .LBB16_57_jump_0
	j	.LBB16_85
.LBB16_57_jump_0:                               # %label_57_jump_0
	j	.LBB16_86
.LBB16_79:                               # %label_79
	add	s10, s5, x0
.LBB16_80:                               # %label_80
	add	s9, s10, x0
	j	.LBB16_57
.LBB16_85:                               # %label_85
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t0, 0(s0)
	sw	t0, 148(sp)
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	add	t0, s9, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a7, a0, t0
	lw	t0, 0(a7)
	sw	t0, 152(sp)
	lw	t1, 152(sp)
	sw	t1, 0(s0)
	add	t0, s9, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t1, 148(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 8
	addi	s1, a3, 8
	lw	s1, 0(s1)
	addiw	t0, s1, 1
	sw	t0, 156(sp)
	lw	t1, 156(sp)
	sw	t1, 0(s0)
	addi	s0, a3, 4
	addi	s1, a3, 4
	lw	s1, 0(s1)
	addiw	t0, s1, 4
	sw	t0, 160(sp)
	lw	t1, 160(sp)
	sw	t1, 0(s0)
	sd	ra, 168(sp)
	sd	a0, 176(sp)
	sd	a1, 184(sp)
	sd	a2, 192(sp)
	sd	a3, 200(sp)
	sd	a4, 208(sp)
	sd	a5, 216(sp)
	sd	a6, 224(sp)
	sd	a7, 232(sp)
	sd	t3, 240(sp)
	ld	a0, 176(sp)
	ld	a1, 184(sp)
	add	a2, s9, x0
	ld	a3, 200(sp)
	call	fn.8
	ld	ra, 168(sp)
	ld	a0, 176(sp)
	ld	a1, 184(sp)
	ld	a2, 192(sp)
	ld	a3, 200(sp)
	ld	a4, 208(sp)
	ld	a5, 216(sp)
	ld	a6, 224(sp)
	ld	a7, 232(sp)
	ld	t3, 240(sp)
.LBB16_86:                               # %label_86
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
	ld	s11, 336(sp)
	li	a0, 0
	addi	sp, sp, 352
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
	addi	s2, a2, 0
	addi	s5, a2, 0
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
	lw	t1, 4(sp)
	slt	t0, s7, t1
	sb	t0, 8(sp)
	lbu	t0, 8(sp)
	beqz	t0, .LBB17_15
.LBB17_14:                               # %label_14
	addiw	t0, s7, 1
	sw	t0, 12(sp)
	lw	t0, 12(sp)
	add	s4, t0, x0
	add	s5, s7, x0
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
	slt	t0, s4, a1
	sb	t0, 16(sp)
	lbu	t0, 16(sp)
	beqz	t0, .LBB17_27
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
	add	t0, s4, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	add	t0, s5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 88(sp)
	ld	t0, 88(sp)
	lw	t0, 0(t0)
	sw	t0, 96(sp)
	lw	t0, 80(sp)
	lw	t1, 96(sp)
	slt	t0, t0, t1
	sb	t0, 100(sp)
	add	s6, s5, x0
	lbu	t0, 100(sp)
	beq	x0, t0, .LBB17_26_jump_0
	j	.LBB17_52
.LBB17_26_jump_0:                               # %label_26_jump_0
	j	.LBB17_53
.LBB17_27:                               # %label_27
	sub	t0, s5, s7
	sltu	t0, x0, t0
	sb	t0, 108(sp)
	add	s3, s2, x0
	lbu	t0, 108(sp)
	beq	x0, t0, .LBB17_27_jump_0
	j	.LBB17_60
.LBB17_27_jump_0:                               # %label_27_jump_0
	j	.LBB17_61
.LBB17_52:                               # %label_52
	add	s6, s4, x0
.LBB17_53:                               # %label_53
	addiw	t0, s4, 1
	sw	t0, 104(sp)
	lw	t0, 104(sp)
	add	s4, t0, x0
	add	s5, s6, x0
	j	.LBB17_25
.LBB17_60:                               # %label_60
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 128(sp)
	add	t0, s5, x0
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
	add	t0, s5, x0
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
	add	s3, t0, x0
.LBB17_61:                               # %label_61
	addiw	a4, s7, 1
	add	s7, a4, x0
	add	s2, s3, x0
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
	sd	s0, 160(sp)
	sd	s1, 168(sp)
	j	.LBB18_0
.LBB18_0:                               # %label_0
	li	t1, 1
	slt	s1, t1, a1
	add	t0, s1, x0
	beqz	t0, .LBB18_9
.LBB18_8:                               # %label_8
	addiw	s0, a1, -1
	sd	ra, 128(sp)
	sd	a0, 136(sp)
	sd	a1, 144(sp)
	sd	a2, 152(sp)
	ld	a0, 136(sp)
	li	a1, 0
	add	a2, s0, x0
	ld	a3, 152(sp)
	call	fn.19
	ld	ra, 128(sp)
	ld	a0, 136(sp)
	ld	a1, 144(sp)
	ld	a2, 152(sp)
.LBB18_9:                               # %label_9
	ld	s0, 160(sp)
	ld	s1, 168(sp)
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
	addi	sp, sp, -64
	li	t6, 4
	add	t6, t6, sp
	sd	t6, 24(sp)
	j	.LBB20_0
.LBB20_0:                               # %label_0
	ld	t0, 24(sp)
	addi	a1, t0, 16
	li	t1, 0
	sw	t1, 0(a1)
	ld	t0, 24(sp)
	addi	a1, t0, 12
	li	t1, 0
	sw	t1, 0(a1)
	ld	t0, 24(sp)
	addi	a1, t0, 8
	li	t1, 0
	sw	t1, 0(a1)
	ld	t0, 24(sp)
	addi	a1, t0, 4
	li	t1, 0
	sw	t1, 0(a1)
	ld	t0, 24(sp)
	addi	a1, t0, 0
	li	t1, 0
	sw	t1, 0(a1)
	sd	ra, 32(sp)
	sd	a0, 40(sp)
	sd	a1, 48(sp)
	ld	t0, 40(sp)
	ld	t1, 24(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 20
	call	builtin_memcpy
	ld	ra, 32(sp)
	ld	a0, 40(sp)
	ld	a1, 48(sp)
	li	a0, 0
	addi	sp, sp, 64
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
	addi	s0, a2, 0
	addi	t4, a2, 0
	lw	t4, 0(t4)
	addiw	t0, t4, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s0)
	li	t1, 2
	divw	s0, a1, t1
	addiw	s0, s0, -1
	add	s1, s0, x0
.LBB21_16:                               # %label_16
	slti	t0, s1, 0
	xori	t0, t0, 1
	sb	t0, 132(sp)
	lbu	t0, 132(sp)
	beqz	t0, .LBB21_18
.LBB21_17:                               # %label_17
	sd	ra, 184(sp)
	sd	a0, 192(sp)
	sd	a1, 200(sp)
	sd	a2, 208(sp)
	sd	a3, 216(sp)
	sd	a4, 224(sp)
	sd	a5, 232(sp)
	sd	a6, 240(sp)
	sd	a7, 248(sp)
	sd	t3, 256(sp)
	sd	t4, 264(sp)
	sd	t5, 272(sp)
	ld	a0, 192(sp)
	ld	a1, 200(sp)
	add	a2, s1, x0
	ld	a3, 208(sp)
	call	fn.8
	addiw	t0, s1, -1
	sw	t0, 136(sp)
	ld	ra, 184(sp)
	ld	a0, 192(sp)
	ld	a1, 200(sp)
	ld	a2, 208(sp)
	ld	a3, 216(sp)
	ld	a4, 224(sp)
	ld	a5, 232(sp)
	ld	a6, 240(sp)
	ld	a7, 248(sp)
	ld	t3, 256(sp)
	ld	t4, 264(sp)
	ld	t5, 272(sp)
	lw	t0, 136(sp)
	add	s1, t0, x0
	j	.LBB21_16
.LBB21_18:                               # %label_18
	addiw	t0, a1, -1
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	add	a3, t0, x0
.LBB21_29:                               # %label_29
	li	t1, 0
	slt	t0, t1, a3
	sb	t0, 144(sp)
	lbu	t0, 144(sp)
	beqz	t0, .LBB21_31
.LBB21_30:                               # %label_30
	addi	t0, a0, 0
	sd	t0, 152(sp)
	ld	t0, 152(sp)
	lw	t0, 0(t0)
	sw	t0, 160(sp)
	addi	t5, a0, 0
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t3, a0, t0
	lw	t0, 0(t3)
	sw	t0, 164(sp)
	lw	t1, 164(sp)
	sw	t1, 0(t5)
	add	t0, a3, x0
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
	sd	a4, 224(sp)
	sd	a5, 232(sp)
	sd	a6, 240(sp)
	sd	a7, 248(sp)
	sd	t3, 256(sp)
	sd	t4, 264(sp)
	sd	t5, 272(sp)
	ld	a0, 192(sp)
	ld	a1, 216(sp)
	li	a2, 0
	ld	a3, 208(sp)
	call	fn.8
	ld	t0, 216(sp)
	addiw	a7, t0, -1
	sd	a7, 248(sp)
	ld	ra, 184(sp)
	ld	a0, 192(sp)
	ld	a1, 200(sp)
	ld	a2, 208(sp)
	ld	a3, 216(sp)
	ld	a4, 224(sp)
	ld	a5, 232(sp)
	ld	a6, 240(sp)
	ld	a7, 248(sp)
	ld	t3, 256(sp)
	ld	t4, 264(sp)
	ld	t5, 272(sp)
	add	a3, a7, x0
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
	li	t6, -120560
	add	sp, sp, t6
	li	t6, 120464
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 120472
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 120480
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 120488
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 120496
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 120504
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 120512
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 120520
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 120528
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 120536
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 120544
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 0
	add	t6, t6, sp
	li	t0, 40024
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 40032
	add	t6, t6, sp
	li	t0, 80056
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 80064
	add	t6, t6, sp
	li	t0, 120064
	add	t0, sp, t0
	sd	t6, 0(t0)
	j	.LBB22_0
.LBB22_0:                               # %label_0
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 24
	li	t6, 120368
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120384
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120392
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120400
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120408
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120416
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120424
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120432
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120440
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120456
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120064
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 40000
	call	builtin_memset
	li	t6, 120064
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, s9, x0
	add	a1, t1, x0
	li	a2, 40000
	call	builtin_memcpy
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 20
	li	t6, 120384
	add	t6, sp, t6
	ld	t1, 0(t6)
	sw	t1, 0(s9)
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 16
	li	t1, 0
	sb	t1, 0(s9)
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 12
	li	t1, 999999
	sw	t1, 0(s9)
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 8
	li	t1, -999999
	sw	t1, 0(s9)
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 4
	li	t1, 0
	sw	t1, 0(s9)
	li	t6, 80056
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s9, t0, 0
	li	t1, 0
	sw	t1, 0(s9)
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 80056
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 120368
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120384
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120392
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120400
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120408
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120416
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120424
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120432
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120440
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120456
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	a3, 0
.LBB22_18:                               # %label_18
	slt	t0, a3, a1
	li	t6, 120072
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120072
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beqz	t0, .LBB22_20
.LBB22_19:                               # %label_19
	sltiu	t0, a0, 1
	li	t6, 120073
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120073
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_19_jump_0
	j	.LBB22_27
.LBB22_19_jump_0:                               # %label_19_jump_0
	j	.LBB22_28
.LBB22_20:                               # %label_20
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a5, t0, 0
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a4, t0, 4
	lw	a4, 0(a4)
	divw	t0, a4, a1
	li	t6, 120360
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120360
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(a5)
	li	t6, 120368
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 120384
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 120392
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 120400
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 120408
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 120416
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 120424
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 120432
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 120440
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 120456
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t6, 120392
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 40024
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 40024
	call	builtin_memcpy
	li	t6, 120368
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 120376
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 120384
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 120392
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 120400
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 120408
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 120416
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 120424
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 120432
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 120440
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 120448
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 120456
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 120464
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 120472
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 120480
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 120488
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 120496
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 120504
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 120512
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 120520
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 120528
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 120536
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 120544
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 120560
	add	sp, sp, t6
	ret
.LBB22_27:                               # %label_27
	li	t1, 11047
	mulw	t0, a3, t1
	li	t6, 120076
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120076
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 12345
	addw	t0, t0, t6
	li	t6, 120080
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120080
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100000
	remw	t0, t0, t1
	li	t6, 120084
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120084
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120088
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120088
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120352
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_29
.LBB22_28:                               # %label_28
	xori	t0, a0, 1
	sltiu	t0, t0, 1
	li	t6, 120092
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120092
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_28_jump_0
	j	.LBB22_37
.LBB22_28_jump_0:                               # %label_28_jump_0
	j	.LBB22_38
.LBB22_29:                               # %label_29
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s10, t0, 24
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s8, s10, t0
	li	t6, 120352
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(s8)
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s7, t0, 4
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s6, t0, 4
	lw	s5, 0(s6)
	li	t6, 120352
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, s5, t1
	li	t6, 120356
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120356
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(s7)
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s3, t0, 12
	lw	s2, 0(s3)
	li	t6, 120352
	add	t6, sp, t6
	lw	t0, 0(t6)
	slt	s1, t0, s2
	add	t0, s1, x0
	beq	x0, t0, .LBB22_29_jump_0
	j	.LBB22_176
.LBB22_29_jump_0:                               # %label_29_jump_0
	j	.LBB22_177
.LBB22_37:                               # %label_37
	li	t1, 3
	mulw	t0, a3, t1
	li	t6, 120096
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120096
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 7
	li	t6, 120100
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120100
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120104
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120104
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s11, t0, x0
	j	.LBB22_39
.LBB22_38:                               # %label_38
	xori	t0, a0, 2
	sltiu	t0, t0, 1
	li	t6, 120108
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120108
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_38_jump_0
	j	.LBB22_46
.LBB22_38_jump_0:                               # %label_38_jump_0
	j	.LBB22_47
.LBB22_39:                               # %label_39
	add	t0, s11, x0
	li	t6, 120352
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_29
.LBB22_46:                               # %label_46
	subw	t0, a1, a3
	li	t6, 120112
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120112
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 5
	mulw	t0, t0, t1
	li	t6, 120116
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120116
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 13
	li	t6, 120120
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120120
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120124
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120124
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120348
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_48
.LBB22_47:                               # %label_47
	xori	t0, a0, 3
	sltiu	t0, t0, 1
	li	t6, 120128
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120128
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_47_jump_0
	j	.LBB22_57
.LBB22_47_jump_0:                               # %label_47_jump_0
	j	.LBB22_58
.LBB22_48:                               # %label_48
	li	t6, 120348
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	s11, t0, x0
	j	.LBB22_39
.LBB22_57:                               # %label_57
	li	t1, 2
	divw	t0, a1, t1
	li	t6, 120132
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120132
	add	t6, sp, t6
	lw	t1, 0(t6)
	slt	t0, a3, t1
	li	t6, 120136
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120136
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_57_jump_0
	j	.LBB22_64
.LBB22_57_jump_0:                               # %label_57_jump_0
	j	.LBB22_65
.LBB22_58:                               # %label_58
	xori	t0, a0, 4
	sltiu	t0, t0, 1
	li	t6, 120168
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120168
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_58_jump_0
	j	.LBB22_79
.LBB22_58_jump_0:                               # %label_58_jump_0
	j	.LBB22_80
.LBB22_59:                               # %label_59
	li	t6, 120344
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120348
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_48
.LBB22_64:                               # %label_64
	li	t1, 4
	mulw	t0, a3, t1
	li	t6, 120140
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120140
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120144
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120144
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120160
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_66
.LBB22_65:                               # %label_65
	subw	t0, a1, a3
	li	t6, 120148
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120148
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 4
	mulw	t0, t0, t1
	li	t6, 120152
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120152
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120156
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120156
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120160
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB22_66:                               # %label_66
	li	t6, 120160
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120164
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120164
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120344
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_59
.LBB22_79:                               # %label_79
	li	t1, 2
	divw	t0, a1, t1
	li	t6, 120172
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120172
	add	t6, sp, t6
	lw	t1, 0(t6)
	slt	t0, a3, t1
	li	t6, 120176
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120176
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_79_jump_0
	j	.LBB22_86
.LBB22_79_jump_0:                               # %label_79_jump_0
	j	.LBB22_87
.LBB22_80:                               # %label_80
	xori	t0, a0, 5
	sltiu	t0, t0, 1
	li	t6, 120220
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120220
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_80_jump_0
	j	.LBB22_105
.LBB22_80_jump_0:                               # %label_80_jump_0
	j	.LBB22_106
.LBB22_81:                               # %label_81
	li	t6, 120340
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120344
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_59
.LBB22_86:                               # %label_86
	li	t1, 2
	divw	t0, a1, t1
	li	t6, 120180
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120180
	add	t6, sp, t6
	lw	t0, 0(t6)
	subw	t0, t0, a3
	li	t6, 120184
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120184
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 3
	mulw	t0, t0, t1
	li	t6, 120188
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120188
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120192
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120192
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120212
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_88
.LBB22_87:                               # %label_87
	li	t1, 2
	divw	t0, a1, t1
	li	t6, 120196
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120196
	add	t6, sp, t6
	lw	t1, 0(t6)
	subw	t0, a3, t1
	li	t6, 120200
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120200
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 3
	mulw	t0, t0, t1
	li	t6, 120204
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120204
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120208
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120208
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120212
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB22_88:                               # %label_88
	li	t6, 120212
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120216
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120216
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120340
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_81
.LBB22_105:                               # %label_105
	li	t1, 2
	mulw	t0, a3, t1
	li	t6, 120224
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t1, 10
	remw	t0, a3, t1
	li	t6, 120228
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120228
	add	t6, sp, t6
	lw	t0, 0(t6)
	xori	t0, t0, 5
	sltiu	t0, t0, 1
	li	t6, 120232
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t6, 120232
	add	t6, sp, t6
	lbu	t0, 0(t6)
	li	t6, 120236
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120236
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 100
	mulw	t0, t0, t1
	li	t6, 120240
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120224
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 120240
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, t0, t1
	li	t6, 120244
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120244
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120248
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120248
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120336
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_107
.LBB22_106:                               # %label_106
	xori	t0, a0, 6
	sltiu	t0, t0, 1
	li	t6, 120252
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120252
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_106_jump_0
	j	.LBB22_119
.LBB22_106_jump_0:                               # %label_106_jump_0
	j	.LBB22_120
.LBB22_107:                               # %label_107
	li	t6, 120336
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120340
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_81
.LBB22_119:                               # %label_119
	li	t1, 10
	divw	t0, a3, t1
	li	t6, 120256
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120256
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 7
	mulw	t0, t0, t1
	li	t6, 120260
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120260
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 23
	li	t6, 120264
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120264
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120268
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120268
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120332
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_121
.LBB22_120:                               # %label_120
	xori	t0, a0, 7
	sltiu	t0, t0, 1
	li	t6, 120272
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120272
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_120_jump_0
	j	.LBB22_129
.LBB22_120_jump_0:                               # %label_120_jump_0
	j	.LBB22_130
.LBB22_121:                               # %label_121
	li	t6, 120332
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120336
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_107
.LBB22_129:                               # %label_129
	li	t1, 2
	remw	t0, a3, t1
	li	t6, 120276
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120276
	add	t6, sp, t6
	lw	t0, 0(t6)
	sltiu	t0, t0, 1
	li	t6, 120280
	add	t6, sp, t6
	sb	t0, 0(t6)
	li	t2, 120280
	add	t2, t2, sp
	lbu	t0, 0(t2)
	beq	x0, t0, .LBB22_129_jump_0
	j	.LBB22_135
.LBB22_129_jump_0:                               # %label_129_jump_0
	j	.LBB22_136
.LBB22_130:                               # %label_130
	mulw	t0, a3, a3
	li	t6, 120304
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t1, 7
	mulw	t0, a3, t1
	li	t6, 120308
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120304
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t6, 120308
	add	t6, sp, t6
	lw	t1, 0(t6)
	addw	t0, t0, t1
	li	t6, 120312
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120312
	add	t6, sp, t6
	lw	t0, 0(t6)
	addiw	t0, t0, 17
	li	t6, 120316
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120316
	add	t6, sp, t6
	lw	t0, 0(t6)
	li	t1, 1000
	remw	t0, t0, t1
	li	t6, 120320
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120320
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120324
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120324
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120328
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB22_131:                               # %label_131
	li	t6, 120328
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120332
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_121
.LBB22_135:                               # %label_135
	add	t0, a3, x0
	li	t6, 120284
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120284
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120296
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_137
.LBB22_136:                               # %label_136
	subw	t0, a1, a3
	li	t6, 120288
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120288
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120292
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120292
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120296
	add	t6, sp, t6
	sw	t0, 0(t6)
.LBB22_137:                               # %label_137
	li	t6, 120296
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120300
	add	t6, sp, t6
	sw	t0, 0(t6)
	li	t6, 120300
	add	t6, sp, t6
	lw	t0, 0(t6)
	add	t0, t0, x0
	li	t6, 120328
	add	t6, sp, t6
	sw	t0, 0(t6)
	j	.LBB22_131
.LBB22_176:                               # %label_176
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	s0, t0, 12
	li	t6, 120352
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(s0)
.LBB22_177:                               # %label_177
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t5, t0, 8
	lw	t4, 0(t5)
	li	t6, 120352
	add	t6, sp, t6
	lw	t0, 0(t6)
	slt	t3, t4, t0
	add	t0, t3, x0
	beqz	t0, .LBB22_185
.LBB22_184:                               # %label_184
	li	t6, 40024
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	a7, t0, 8
	li	t6, 120352
	add	t6, sp, t6
	lw	t1, 0(t6)
	sw	t1, 0(a7)
.LBB22_185:                               # %label_185
	addiw	a6, a3, 1
	add	a3, a6, x0
	j	.LBB22_18
.Lfunc_end22:
	.size	fn.14, .Lfunc_end22-fn.14
                                        # -- End function
	.globl	fn.15                            # -- Begin function fn.15
	.p2align	1
	.type	fn.15,@function
fn.15:                                   # @fn.15
# %bb.0:                                # %alloca
	addi	sp, sp, -384
	sd	s0, 296(sp)
	sd	s1, 304(sp)
	sd	s2, 312(sp)
	sd	s3, 320(sp)
	sd	s4, 328(sp)
	sd	s5, 336(sp)
	sd	s6, 344(sp)
	sd	s8, 352(sp)
	sd	s9, 360(sp)
	sd	s10, 368(sp)
	j	.LBB23_0
.LBB23_0:                               # %label_0
	addi	a3, a2, 0
	addi	a4, a2, 0
	lw	a4, 0(a4)
	addiw	t0, a4, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a3)
	li	s0, 0
	li	t4, 0
	li	a6, 0
	li	a3, 0
.LBB23_13:                               # %label_13
	addiw	t0, a1, -1
	sw	t0, 4(sp)
	lw	t1, 4(sp)
	slt	t0, s0, t1
	sb	t0, 8(sp)
	lbu	t0, 8(sp)
	beqz	t0, .LBB23_15
.LBB23_14:                               # %label_14
	li	t5, 0
	li	a7, 0
	add	a4, a3, x0
	j	.LBB23_22
.LBB23_15:                               # %label_15
	addi	s3, a2, 16
	addi	s1, a2, 16
	lw	s2, 0(s1)
	mulw	s1, a1, a1
	addw	t0, s2, s1
	sw	t0, 196(sp)
	lw	t1, 196(sp)
	sw	t1, 0(s3)
	ld	s0, 296(sp)
	ld	s1, 304(sp)
	ld	s2, 312(sp)
	ld	s3, 320(sp)
	ld	s4, 328(sp)
	ld	s5, 336(sp)
	ld	s6, 344(sp)
	ld	s8, 352(sp)
	ld	s9, 360(sp)
	ld	s10, 368(sp)
	li	a0, 0
	addi	sp, sp, 384
	ret
.LBB23_22:                               # %label_22
	subw	t0, a1, s0
	sw	t0, 12(sp)
	lw	t0, 12(sp)
	addiw	t0, t0, -1
	sw	t0, 16(sp)
	lw	t1, 16(sp)
	slt	t0, t5, t1
	sb	t0, 20(sp)
	lbu	t0, 20(sp)
	beqz	t0, .LBB23_24
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
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 72(sp)
	ld	t0, 72(sp)
	lw	t0, 0(t0)
	sw	t0, 80(sp)
	addiw	t0, t5, 1
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 88(sp)
	ld	t0, 88(sp)
	lw	t0, 0(t0)
	sw	t0, 100(sp)
	lw	t0, 80(sp)
	lw	t1, 100(sp)
	slt	t0, t1, t0
	sb	t0, 104(sp)
	add	t3, a7, x0
	add	a5, a4, x0
	lbu	t0, 104(sp)
	beq	x0, t0, .LBB23_23_jump_0
	j	.LBB23_53
.LBB23_23_jump_0:                               # %label_23_jump_0
	j	.LBB23_54
.LBB23_24:                               # %label_24
	li	t0, 1
	subw	s5, t0, a7
	add	t0, s5, x0
	beq	x0, t0, .LBB23_24_jump_0
	j	.LBB23_89
.LBB23_24_jump_0:                               # %label_24_jump_0
	j	.LBB23_90
.LBB23_53:                               # %label_53
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 128(sp)
	addiw	t0, t5, 1
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
	addiw	t0, t5, 1
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
	addi	t0, a2, 8
	sd	t0, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 184(sp)
	lw	t0, 184(sp)
	addiw	t0, t0, 1
	sw	t0, 188(sp)
	ld	t0, 168(sp)
	lw	t1, 188(sp)
	sw	t1, 0(t0)
	addi	s10, a2, 4
	addi	s9, a2, 4
	lw	s8, 0(s9)
	addiw	t0, s8, 4
	sw	t0, 192(sp)
	lw	t1, 192(sp)
	sw	t1, 0(s10)
	li	t3, 1
	lw	t0, 120(sp)
	add	a5, t0, x0
.LBB23_54:                               # %label_54
	addiw	s6, t5, 1
	add	t5, s6, x0
	add	a7, t3, x0
	add	a4, a5, x0
	j	.LBB23_22
.LBB23_89:                               # %label_89
	j	.LBB23_15
.LBB23_90:                               # %label_90
	addiw	s4, s0, 1
	add	s0, s4, x0
	add	t4, t5, x0
	add	a6, a7, x0
	add	a3, a4, x0
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
	sd	s1, 104(sp)
	j	.LBB24_0
.LBB24_0:                               # %label_0
	li	a4, 0
	li	a3, 0
.LBB24_8:                               # %label_8
	slt	s1, a3, a1
	add	t0, s1, x0
	beqz	t0, .LBB24_10
.LBB24_9:                               # %label_9
	add	t0, a3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	lw	t5, 0(s0)
	subw	t4, t5, a2
	mulw	t3, t4, t4
	addw	a7, a4, t3
	addiw	a6, a3, 1
	add	a4, a7, x0
	add	a3, a6, x0
	j	.LBB24_8
.LBB24_10:                               # %label_10
	divw	t0, a4, a1
	sw	t0, 0(sp)
	lw	a0, 0(sp)
	ld	s0, 96(sp)
	ld	s1, 104(sp)
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
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	a4, a0, t0
	lw	a6, 0(a4)
	addiw	a5, a1, -1
	addi	a4, a3, 4
	addi	s7, a3, 4
	lw	s7, 0(s7)
	addiw	t0, s7, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a4)
	li	a4, 0
	add	t3, a1, x0
	add	s7, a5, x0
.LBB25_24:                               # %label_24
	slt	t0, t3, a2
	sb	t0, 4(sp)
	lbu	t0, 4(sp)
	beqz	t0, .LBB25_26
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
	add	t0, t3, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	slt	t0, a6, t0
	xori	t0, t0, 1
	sb	t0, 68(sp)
	add	t4, s7, x0
	add	a7, a4, x0
	lbu	t0, 68(sp)
	beq	x0, t0, .LBB25_25_jump_0
	j	.LBB25_48
.LBB25_25_jump_0:                               # %label_25_jump_0
	j	.LBB25_49
.LBB25_26:                               # %label_26
	addiw	t5, s7, 1
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t0, 0(t5)
	sw	t0, 136(sp)
	addiw	t5, s7, 1
	add	t0, t5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	s0, a0, t0
	add	t0, a2, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t5, a0, t0
	lw	t0, 0(t5)
	sw	t0, 140(sp)
	lw	t1, 140(sp)
	sw	t1, 0(s0)
	add	t0, a2, x0
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
	addiw	t0, s7, 1
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
.LBB25_48:                               # %label_48
	addiw	t0, s7, 1
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
	add	t0, t3, x0
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
	add	t0, t3, x0
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
	add	t4, t0, x0
	lw	t0, 88(sp)
	add	a7, t0, x0
.LBB25_49:                               # %label_49
	addiw	s2, t3, 1
	add	t3, s2, x0
	add	s7, t4, x0
	add	a4, a7, x0
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
	addi	a3, a2, 0
	addi	s10, a2, 0
	lw	s10, 0(s10)
	addiw	t0, s10, 1
	sw	t0, 0(sp)
	lw	t1, 0(sp)
	sw	t1, 0(a3)
	li	a5, 1
.LBB26_13:                               # %label_13
	slt	t0, a5, a1
	sb	t0, 4(sp)
	lbu	t0, 4(sp)
	beqz	t0, .LBB26_15
.LBB26_14:                               # %label_14
	add	t0, a5, x0
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
	add	a4, t0, x0
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
	slti	t0, a4, 0
	xori	t0, t0, 1
	sb	t0, 48(sp)
	lbu	t0, 48(sp)
	beq	x0, t0, .LBB26_33_jump_0
	j	.LBB26_38
.LBB26_33_jump_0:                               # %label_33_jump_0
	j	.LBB26_39
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
	add	t0, a4, x0
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
	add	a4, s5, x0
	j	.LBB26_33
.LBB26_35:                               # %label_35
	addiw	s3, a4, 1
	add	t0, s3, x0
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
	add	a5, t4, x0
	j	.LBB26_13
.LBB26_38:                               # %label_38
	add	t0, a4, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 56(sp)
	ld	t0, 56(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	lw	t0, 64(sp)
	lw	t1, 16(sp)
	slt	t0, t1, t0
	sb	t0, 68(sp)
	lbu	t0, 68(sp)
	sb	t0, 49(sp)
	lbu	t0, 49(sp)
	add	t0, t0, x0
	sb	t0, 70(sp)
	j	.LBB26_40
.LBB26_39:                               # %label_39
	li	t0, 0
	sb	t0, 69(sp)
	lbu	t0, 69(sp)
	add	t0, t0, x0
	sb	t0, 70(sp)
.LBB26_40:                               # %label_40
	lbu	t0, 70(sp)
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
	addi	sp, sp, -240
	sd	s0, 208(sp)
	sd	s1, 216(sp)
	sd	s2, 224(sp)
	j	.LBB27_0
.LBB27_0:                               # %label_0
	addi	s2, a3, 0
	addi	a7, a3, 0
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s2)
	slt	a7, a1, a2
	add	t0, a7, x0
	beqz	t0, .LBB27_18
.LBB27_17:                               # %label_17
	subw	a5, a2, a1
	li	t1, 2
	divw	a5, a5, t1
	addw	a6, a1, a5
	sd	ra, 136(sp)
	sd	a0, 144(sp)
	sd	a1, 152(sp)
	sd	a2, 160(sp)
	sd	a3, 168(sp)
	sd	a4, 176(sp)
	sd	a5, 184(sp)
	sd	a6, 192(sp)
	sd	a7, 200(sp)
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 192(sp)
	ld	a3, 168(sp)
	call	fn.19
	ld	t0, 192(sp)
	addiw	a5, t0, 1
	sd	a5, 184(sp)
	ld	a0, 144(sp)
	ld	a1, 184(sp)
	ld	a2, 160(sp)
	ld	a3, 168(sp)
	call	fn.19
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 192(sp)
	ld	a3, 160(sp)
	ld	a4, 168(sp)
	call	fn.22
	ld	ra, 136(sp)
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 160(sp)
	ld	a3, 168(sp)
	ld	a4, 176(sp)
	ld	a5, 184(sp)
	ld	a6, 192(sp)
	ld	a7, 200(sp)
.LBB27_18:                               # %label_18
	addi	a4, a3, 16
	addi	s0, a3, 16
	lw	s1, 0(s0)
	subw	s0, a2, a1
	addiw	s0, s0, 1
	addw	t0, s1, s0
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(a4)
	ld	s0, 208(sp)
	ld	s1, 216(sp)
	ld	s2, 224(sp)
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
	sd	s0, 208(sp)
	sd	s1, 216(sp)
	sd	s2, 224(sp)
	j	.LBB28_0
.LBB28_0:                               # %label_0
	addi	s2, a3, 0
	addi	a7, a3, 0
	lw	a7, 0(a7)
	addiw	t0, a7, 1
	sw	t0, 128(sp)
	lw	t1, 128(sp)
	sw	t1, 0(s2)
	slt	a7, a1, a2
	add	t0, a7, x0
	beqz	t0, .LBB28_18
.LBB28_17:                               # %label_17
	sd	ra, 136(sp)
	sd	a0, 144(sp)
	sd	a1, 152(sp)
	sd	a2, 160(sp)
	sd	a3, 168(sp)
	sd	a4, 176(sp)
	sd	a5, 184(sp)
	sd	a6, 192(sp)
	sd	a7, 200(sp)
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 160(sp)
	ld	a3, 168(sp)
	call	fn.17
	add	a6, a0, x0
	sd	a6, 192(sp)
	ld	t0, 192(sp)
	addiw	a5, t0, -1
	sd	a5, 184(sp)
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 184(sp)
	ld	a3, 168(sp)
	call	fn.20
	ld	t0, 192(sp)
	addiw	a5, t0, 1
	sd	a5, 184(sp)
	ld	a0, 144(sp)
	ld	a1, 184(sp)
	ld	a2, 160(sp)
	ld	a3, 168(sp)
	call	fn.20
	ld	ra, 136(sp)
	ld	a0, 144(sp)
	ld	a1, 152(sp)
	ld	a2, 160(sp)
	ld	a3, 168(sp)
	ld	a4, 176(sp)
	ld	a5, 184(sp)
	ld	a6, 192(sp)
	ld	a7, 200(sp)
.LBB28_18:                               # %label_18
	addi	a4, a3, 16
	addi	s0, a3, 16
	lw	s1, 0(s0)
	subw	s0, a2, a1
	addiw	s0, s0, 1
	addw	t0, s1, s0
	sw	t0, 132(sp)
	lw	t1, 132(sp)
	sw	t1, 0(a4)
	ld	s0, 208(sp)
	ld	s1, 216(sp)
	ld	s2, 224(sp)
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
	sd	s0, 160(sp)
	sd	s1, 168(sp)
	j	.LBB29_0
.LBB29_0:                               # %label_0
	li	t1, 1
	slt	s1, t1, a1
	add	t0, s1, x0
	beqz	t0, .LBB29_9
.LBB29_8:                               # %label_8
	addiw	s0, a1, -1
	sd	ra, 128(sp)
	sd	a0, 136(sp)
	sd	a1, 144(sp)
	sd	a2, 152(sp)
	ld	a0, 136(sp)
	li	a1, 0
	add	a2, s0, x0
	ld	a3, 152(sp)
	call	fn.20
	ld	ra, 128(sp)
	ld	a0, 136(sp)
	ld	a1, 144(sp)
	ld	a2, 152(sp)
.LBB29_9:                               # %label_9
	ld	s0, 160(sp)
	ld	s1, 168(sp)
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
	sd	s0, 456(sp)
	sd	s1, 464(sp)
	sd	s3, 472(sp)
	sd	s4, 480(sp)
	sd	s5, 488(sp)
	sd	s7, 496(sp)
	sd	s8, 504(sp)
	sd	s10, 512(sp)
	sd	s11, 520(sp)
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
	lw	t1, 0(sp)
	slt	t0, a7, t1
	sb	t0, 8(sp)
	lbu	t0, 8(sp)
	beqz	t0, .LBB30_28
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
	add	a7, s8, x0
	j	.LBB30_26
.LBB30_28:                               # %label_28
	li	t3, 0
	li	s8, 0
	add	a7, a1, x0
.LBB30_52:                               # %label_52
	lw	t1, 0(sp)
	slt	t0, t3, t1
	sb	t0, 68(sp)
	lbu	t0, 68(sp)
	beq	x0, t0, .LBB30_52_jump_0
	j	.LBB30_58
.LBB30_52_jump_0:                               # %label_52_jump_0
	j	.LBB30_59
.LBB30_53:                               # %label_53
	addi	t0, a4, 12
	sd	t0, 80(sp)
	addi	t0, a4, 12
	sd	t0, 88(sp)
	ld	t0, 88(sp)
	lw	t0, 0(t0)
	sw	t0, 96(sp)
	lw	t0, 96(sp)
	addiw	t0, t0, 1
	sw	t0, 100(sp)
	ld	t0, 80(sp)
	lw	t1, 100(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 104(sp)
	addi	t0, a4, 4
	sd	t0, 112(sp)
	ld	t0, 112(sp)
	lw	t0, 0(t0)
	sw	t0, 120(sp)
	lw	t0, 120(sp)
	addiw	t0, t0, 2
	sw	t0, 124(sp)
	ld	t0, 104(sp)
	lw	t1, 124(sp)
	sw	t1, 0(t0)
	addw	t0, s11, t3
	sw	t0, 136(sp)
	lw	t0, 136(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 128(sp)
	ld	t0, 128(sp)
	lw	t0, 0(t0)
	sw	t0, 140(sp)
	addiw	t0, a2, 1
	sw	t0, 152(sp)
	lw	t0, 152(sp)
	addw	t0, t0, s8
	sw	t0, 156(sp)
	lw	t0, 156(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 144(sp)
	ld	t0, 144(sp)
	lw	t0, 0(t0)
	sw	t0, 160(sp)
	lw	t0, 140(sp)
	lw	t1, 160(sp)
	slt	t0, t1, t0
	xori	t0, t0, 1
	sb	t0, 164(sp)
	lbu	t0, 164(sp)
	beq	x0, t0, .LBB30_53_jump_0
	j	.LBB30_93
.LBB30_53_jump_0:                               # %label_53_jump_0
	j	.LBB30_94
.LBB30_54:                               # %label_54
	add	t5, t3, x0
	add	a5, a7, x0
	j	.LBB30_127
.LBB30_58:                               # %label_58
	lw	t1, 4(sp)
	slt	t0, s8, t1
	sb	t0, 70(sp)
	lbu	t0, 70(sp)
	sb	t0, 69(sp)
	lbu	t0, 69(sp)
	add	t0, t0, x0
	sb	t0, 72(sp)
	j	.LBB30_60
.LBB30_59:                               # %label_59
	li	t0, 0
	sb	t0, 71(sp)
	lbu	t0, 71(sp)
	add	t0, t0, x0
	sb	t0, 72(sp)
.LBB30_60:                               # %label_60
	lbu	t0, 72(sp)
	beq	x0, t0, .LBB30_60_jump_0
	j	.LBB30_53
.LBB30_60_jump_0:                               # %label_60_jump_0
	j	.LBB30_54
.LBB30_93:                               # %label_93
	add	t0, a7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 168(sp)
	addw	t0, s11, t3
	sw	t0, 184(sp)
	lw	t0, 184(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 176(sp)
	ld	t0, 176(sp)
	lw	t0, 0(t0)
	sw	t0, 188(sp)
	ld	t0, 168(sp)
	lw	t1, 188(sp)
	sw	t1, 0(t0)
	addiw	t0, t3, 1
	sw	t0, 192(sp)
	lw	t0, 192(sp)
	add	t4, t0, x0
	add	a5, s8, x0
	j	.LBB30_95
.LBB30_94:                               # %label_94
	add	t0, a7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 200(sp)
	addiw	t0, a2, 1
	sw	t0, 216(sp)
	lw	t0, 216(sp)
	addw	t0, t0, s8
	sw	t0, 220(sp)
	lw	t0, 220(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 208(sp)
	ld	t0, 208(sp)
	lw	t0, 0(t0)
	sw	t0, 224(sp)
	ld	t0, 200(sp)
	lw	t1, 224(sp)
	sw	t1, 0(t0)
	addiw	t0, s8, 1
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	add	a5, t0, x0
	add	t4, t3, x0
.LBB30_95:                               # %label_95
	addi	t0, a4, 4
	sd	t0, 232(sp)
	addi	t0, a4, 4
	sd	t0, 240(sp)
	ld	t0, 240(sp)
	lw	t0, 0(t0)
	sw	t0, 248(sp)
	lw	t0, 248(sp)
	addiw	t0, t0, 1
	sw	t0, 252(sp)
	ld	t0, 232(sp)
	lw	t1, 252(sp)
	sw	t1, 0(t0)
	addiw	t0, a7, 1
	sw	t0, 256(sp)
	lw	t0, 256(sp)
	add	a7, t0, x0
	add	t3, t4, x0
	add	s8, a5, x0
	j	.LBB30_52
.LBB30_127:                               # %label_127
	lw	t1, 0(sp)
	slt	t0, t5, t1
	sb	t0, 260(sp)
	lbu	t0, 260(sp)
	beqz	t0, .LBB30_129
.LBB30_128:                               # %label_128
	add	t0, a5, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 264(sp)
	addw	t0, s11, t5
	sw	t0, 280(sp)
	lw	t0, 280(sp)
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	ld	t0, 264(sp)
	lw	t1, 284(sp)
	sw	t1, 0(t0)
	addi	t0, a4, 4
	sd	t0, 288(sp)
	addi	t0, a4, 4
	sd	t0, 296(sp)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 304(sp)
	lw	t0, 304(sp)
	addiw	t0, t0, 2
	sw	t0, 308(sp)
	ld	t0, 288(sp)
	lw	t1, 308(sp)
	sw	t1, 0(t0)
	addiw	t0, t5, 1
	sw	t0, 312(sp)
	addiw	t0, a5, 1
	sw	t0, 316(sp)
	lw	t0, 312(sp)
	add	t5, t0, x0
	lw	t0, 316(sp)
	add	a5, t0, x0
	j	.LBB30_127
.LBB30_129:                               # %label_129
	add	a6, s8, x0
	add	a7, a5, x0
.LBB30_152:                               # %label_152
	lw	t1, 4(sp)
	slt	t0, a6, t1
	sb	t0, 320(sp)
	lbu	t0, 320(sp)
	beqz	t0, .LBB30_154
.LBB30_153:                               # %label_153
	add	t0, a7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 328(sp)
	addiw	t0, a2, 1
	sw	t0, 344(sp)
	lw	t0, 344(sp)
	addw	s7, t0, a6
	add	t0, s7, x0
	li	t1, 4
	mul	t0, t0, t1
	add	t2, a0, t0
	sd	t2, 336(sp)
	ld	t0, 336(sp)
	lw	t0, 0(t0)
	sw	t0, 348(sp)
	ld	t0, 328(sp)
	lw	t1, 348(sp)
	sw	t1, 0(t0)
	addi	s5, a4, 4
	addi	s4, a4, 4
	lw	s3, 0(s4)
	addiw	t0, s3, 2
	sw	t0, 352(sp)
	lw	t1, 352(sp)
	sw	t1, 0(s5)
	addiw	s1, a6, 1
	addiw	s0, a7, 1
	add	a6, s1, x0
	add	a7, s0, x0
	j	.LBB30_152
.LBB30_154:                               # %label_154
	ld	s0, 456(sp)
	ld	s1, 464(sp)
	ld	s3, 472(sp)
	ld	s4, 480(sp)
	ld	s5, 488(sp)
	ld	s7, 496(sp)
	ld	s8, 504(sp)
	ld	s10, 512(sp)
	ld	s11, 520(sp)
	li	a0, 0
	addi	sp, sp, 528
	ret
.Lfunc_end30:
	.size	fn.22, .Lfunc_end30-fn.22
                                        # -- End function

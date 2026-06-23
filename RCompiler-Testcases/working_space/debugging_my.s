	.text
	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0"
	.file	"builtin.c"
	.globl	print                           # -- Begin function print
	.p2align	1
	.type	print,@function
print:                                  # @print
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
	sd	a0, -24(s0)
	ld	a1, -24(s0)
	lui	a0, %hi(.L.str)
	addi	a0, a0, %lo(.L.str)
	call	printf
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	print, .Lfunc_end0-print
                                        # -- End function
	.globl	println                         # -- Begin function println
	.p2align	1
	.type	println,@function
println:                                # @println
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
	sd	a0, -24(s0)
	ld	a1, -24(s0)
	lui	a0, %hi(.L.str.1)
	addi	a0, a0, %lo(.L.str.1)
	call	printf
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	println, .Lfunc_end1-println
                                        # -- End function
	.globl	printInt                        # -- Begin function printInt
	.p2align	1
	.type	printInt,@function
printInt:                               # @printInt
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x11 killed $x10
	sw	a0, -20(s0)
	lw	a1, -20(s0)
	lui	a0, %hi(.L.str.2)
	addi	a0, a0, %lo(.L.str.2)
	call	printf
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end2:
	.size	printInt, .Lfunc_end2-printInt
                                        # -- End function
	.globl	printlnInt                      # -- Begin function printlnInt
	.p2align	1
	.type	printlnInt,@function
printlnInt:                             # @printlnInt
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x11 killed $x10
	sw	a0, -20(s0)
	lw	a1, -20(s0)
	lui	a0, %hi(.L.str.3)
	addi	a0, a0, %lo(.L.str.3)
	call	printf
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end3:
	.size	printlnInt, .Lfunc_end3-printlnInt
                                        # -- End function
	.globl	getString                       # -- Begin function getString
	.p2align	1
	.type	getString,@function
getString:                              # @getString
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
	li	a0, 256
	call	malloc
	sd	a0, -24(s0)
	ld	a1, -24(s0)
	lui	a0, %hi(.L.str)
	addi	a0, a0, %lo(.L.str)
	call	scanf
	ld	a0, -24(s0)
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end4:
	.size	getString, .Lfunc_end4-getString
                                        # -- End function
	.globl	getInt                          # -- Begin function getInt
	.p2align	1
	.type	getInt,@function
getInt:                                 # @getInt
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
	lui	a0, %hi(.L.str.2)
	addi	a0, a0, %lo(.L.str.2)
	addi	a1, s0, -20
	call	scanf
	lw	a0, -20(s0)
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end5:
	.size	getInt, .Lfunc_end5-getInt
                                        # -- End function
	.globl	builtin_memset                  # -- Begin function builtin_memset
	.p2align	1
	.type	builtin_memset,@function
builtin_memset:                         # @builtin_memset
# %bb.0:
	addi	sp, sp, -32
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	sd	s0, 16(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x13 killed $x12
                                        # kill: def $x13 killed $x11
	sd	a0, -24(s0)
	sw	a1, -28(s0)
	sw	a2, -32(s0)
	ld	a0, -24(s0)
	lw	a1, -28(s0)
	lw	a2, -32(s0)
	call	memset
	ld	ra, 24(sp)                      # 8-byte Folded Reload
	ld	s0, 16(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end6:
	.size	builtin_memset, .Lfunc_end6-builtin_memset
                                        # -- End function
	.globl	builtin_memcpy                  # -- Begin function builtin_memcpy
	.p2align	1
	.type	builtin_memcpy,@function
builtin_memcpy:                         # @builtin_memcpy
# %bb.0:
	addi	sp, sp, -48
	sd	ra, 40(sp)                      # 8-byte Folded Spill
	sd	s0, 32(sp)                      # 8-byte Folded Spill
	addi	s0, sp, 48
                                        # kill: def $x13 killed $x12
	sd	a0, -24(s0)
	sd	a1, -32(s0)
	sw	a2, -36(s0)
	ld	a0, -24(s0)
	ld	a1, -32(s0)
	lw	a2, -36(s0)
	call	memcpy
	ld	ra, 40(sp)                      # 8-byte Folded Reload
	ld	s0, 32(sp)                      # 8-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end7:
	.size	builtin_memcpy, .Lfunc_end7-builtin_memcpy
                                        # -- End function

	.globl	main                            # -- Begin function main
	.p2align	1
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %alloca
	li	t6, -10224
	add	sp, sp, t6
	li	t6, 10184
	add	t6, sp, t6
	sd	s0, 0(t6)
	li	t6, 10176
	add	t6, sp, t6
	sd	s1, 0(t6)
	li	t6, 10104
	add	t6, sp, t6
	sd	s2, 0(t6)
	li	t6, 10096
	add	t6, sp, t6
	sd	s3, 0(t6)
	li	t6, 10088
	add	t6, sp, t6
	sd	s4, 0(t6)
	li	t6, 10080
	add	t6, sp, t6
	sd	s5, 0(t6)
	li	t6, 10072
	add	t6, sp, t6
	sd	s6, 0(t6)
	li	t6, 10064
	add	t6, sp, t6
	sd	s7, 0(t6)
	li	t6, 10056
	add	t6, sp, t6
	sd	s8, 0(t6)
	li	t6, 10048
	add	t6, sp, t6
	sd	s9, 0(t6)
	li	t6, 10040
	add	t6, sp, t6
	sd	s10, 0(t6)
	li	t6, 10032
	add	t6, sp, t6
	sd	s11, 0(t6)
	li	t6, 9192
	add	t6, t6, sp
	li	t0, 9992
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 8384
	add	t6, t6, sp
	li	t0, 9184
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 7576
	add	t6, t6, sp
	li	t0, 8376
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 6768
	add	t6, t6, sp
	li	t0, 7568
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 5960
	add	t6, t6, sp
	li	t0, 6760
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 5152
	add	t6, t6, sp
	li	t0, 5952
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 4344
	add	t6, t6, sp
	li	t0, 5144
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 3536
	add	t6, t6, sp
	li	t0, 4336
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 2728
	add	t6, t6, sp
	li	t0, 3528
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1920
	add	t6, t6, sp
	li	t0, 2720
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 1112
	add	t6, t6, sp
	sd	t6, 1912(sp)
	li	t6, 304
	add	t6, t6, sp
	sd	t6, 1104(sp)
	li	t6, 292
	add	t6, t6, sp
	sd	t6, 296(sp)
	li	t6, 276
	add	t6, t6, sp
	sd	t6, 280(sp)
	li	t6, 260
	add	t6, t6, sp
	sd	t6, 264(sp)
	li	t6, 244
	add	t6, t6, sp
	sd	t6, 248(sp)
	li	t6, 224
	add	t6, t6, sp
	sd	t6, 232(sp)
	li	t6, 208
	add	t6, t6, sp
	sd	t6, 216(sp)
	li	t6, 192
	add	t6, t6, sp
	sd	t6, 200(sp)
	li	t6, 176
	add	t6, t6, sp
	sd	t6, 184(sp)
	li	t6, 160
	add	t6, t6, sp
	sd	t6, 168(sp)
	li	t6, 144
	add	t6, t6, sp
	sd	t6, 152(sp)
	j	.LBB8_0
.LBB8_0:                               # %label_0
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 9184
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 9992
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 9184
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 7568
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, -1
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 8376
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 7568
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 5952
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, -1
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 6760
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 5952
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 4336
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, -1
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 5144
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 4336
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 2720
	add	t6, sp, t6
	ld	t0, 0(t6)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	li	t6, 3528
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 2720
	add	t6, sp, t6
	ld	t1, 0(t6)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	ld	t0, 1104(sp)
	add	a0, t0, x0
	li	a1, 0
	li	a2, 800
	call	builtin_memset
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	ld	t0, 1912(sp)
	ld	t1, 1104(sp)
	add	a0, t0, x0
	add	a1, t1, x0
	li	a2, 800
	call	builtin_memcpy
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	ld	t0, 296(sp)
	li	t1, 0
	sw	t1, 0(t0)
	ld	t0, 280(sp)
	li	t1, -1
	sw	t1, 0(t0)
	ld	t0, 264(sp)
	li	t1, 0
	sw	t1, 0(t0)
	j	.LBB8_15
.LBB8_15:                               # %label_15
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 140(sp)
	lw	t0, 140(sp)
	slti	a3, t0, 5
	add	t0, a3, x0
	beq	x0, t0, .LBB8_15_jump_0
	j	.LBB8_16
.LBB8_15_jump_0:                               # %label_15_jump_0
	j	.LBB8_17
.LBB8_16:                               # %label_16
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 132(sp)
	lw	t0, 132(sp)
	li	t1, 17
	mulw	t0, t0, t1
	add	a2, t0, x0
	li	t1, 23
	addw	t0, a2, t1
	sw	t0, 124(sp)
	ld	t0, 248(sp)
	ld	t1, 124(sp)
	sw	t1, 0(t0)
	ld	t0, 232(sp)
	li	t6, 9992
	add	t6, sp, t6
	ld	t1, 0(t6)
	sd	t1, 0(t0)
	ld	t0, 232(sp)
	ld	t0, 0(t0)
	sd	t0, 112(sp)
	ld	t0, 216(sp)
	li	t6, 8376
	add	t6, sp, t6
	ld	t1, 0(t6)
	sd	t1, 0(t0)
	ld	t0, 216(sp)
	ld	t0, 0(t0)
	sd	t0, 104(sp)
	ld	t0, 200(sp)
	li	t6, 6760
	add	t6, sp, t6
	ld	t1, 0(t6)
	sd	t1, 0(t0)
	ld	t0, 200(sp)
	ld	t0, 0(t0)
	sd	t0, 96(sp)
	ld	t0, 184(sp)
	li	t6, 5144
	add	t6, sp, t6
	ld	t1, 0(t6)
	sd	t1, 0(t0)
	ld	t0, 184(sp)
	ld	t0, 0(t0)
	sd	t0, 88(sp)
	ld	t0, 168(sp)
	li	t6, 3528
	add	t6, sp, t6
	ld	t1, 0(t6)
	sd	t1, 0(t0)
	ld	t0, 168(sp)
	ld	t0, 0(t0)
	sd	t0, 80(sp)
	ld	t0, 152(sp)
	ld	t1, 1912(sp)
	sd	t1, 0(t0)
	ld	t0, 152(sp)
	ld	t0, 0(t0)
	sd	t0, 72(sp)
	ld	t0, 280(sp)
	lw	t0, 0(t0)
	sw	t0, 68(sp)
	ld	t0, 248(sp)
	lw	t0, 0(t0)
	sw	t0, 64(sp)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 60(sp)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	lw	t0, 60(sp)
	sw	t0, -228(sp)
	ld	a0, 112(sp)
	ld	a1, 104(sp)
	ld	a2, 96(sp)
	ld	a3, 88(sp)
	ld	a4, 80(sp)
	ld	a5, 72(sp)
	lw	a6, 68(sp)
	lw	a7, 64(sp)
	call	fn.1
	sw	a0, 56(sp)
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	ld	t0, 280(sp)
	ld	t1, 56(sp)
	sw	t1, 0(t0)
	ld	t0, 296(sp)
	lw	t0, 0(t0)
	sw	t0, 52(sp)
	lw	t0, 52(sp)
	li	t1, 1
	addw	t0, t0, t1
	sw	t0, 48(sp)
	ld	t0, 296(sp)
	ld	t1, 48(sp)
	sw	t1, 0(t0)
	ld	t0, 264(sp)
	lw	t0, 0(t0)
	sw	t0, 44(sp)
	lw	t0, 44(sp)
	li	t1, 1
	addw	t0, t0, t1
	sw	t0, 40(sp)
	ld	t0, 264(sp)
	ld	t1, 40(sp)
	sw	t1, 0(t0)
	j	.LBB8_15
.LBB8_17:                               # %label_17
	ld	t0, 280(sp)
	lw	t0, 0(t0)
	sw	t0, 36(sp)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	lw	a0, 36(sp)
	call	printlnInt
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 9992
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 0
	sd	t0, 24(sp)
	ld	t0, 24(sp)
	lw	t0, 0(t0)
	sw	t0, 20(sp)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	lw	a0, 20(sp)
	call	printlnInt
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 9992
	add	t6, sp, t6
	ld	t0, 0(t6)
	addi	t0, t0, 4
	sd	t0, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 4(sp)
	li	t6, 10216
	add	t6, sp, t6
	sd	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	sd	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	sd	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	sd	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	sd	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	sd	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	sd	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	sd	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	sd	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	sd	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	sd	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	sd	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	sd	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	sd	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	sd	t5, 0(t6)
	li	t0, 10000
	add	t0, sp, t0
	sd	t6, 0(t0)
	lw	a0, 4(sp)
	call	printlnInt
	li	t6, 10216
	add	t6, sp, t6
	ld	ra, 0(t6)
	li	t6, 10208
	add	t6, sp, t6
	ld	t0, 0(t6)
	li	t6, 10200
	add	t6, sp, t6
	ld	t1, 0(t6)
	li	t6, 10192
	add	t6, sp, t6
	ld	t2, 0(t6)
	li	t6, 10168
	add	t6, sp, t6
	ld	a0, 0(t6)
	li	t6, 10160
	add	t6, sp, t6
	ld	a1, 0(t6)
	li	t6, 10152
	add	t6, sp, t6
	ld	a2, 0(t6)
	li	t6, 10144
	add	t6, sp, t6
	ld	a3, 0(t6)
	li	t6, 10136
	add	t6, sp, t6
	ld	a4, 0(t6)
	li	t6, 10128
	add	t6, sp, t6
	ld	a5, 0(t6)
	li	t6, 10120
	add	t6, sp, t6
	ld	a6, 0(t6)
	li	t6, 10112
	add	t6, sp, t6
	ld	a7, 0(t6)
	li	t6, 10024
	add	t6, sp, t6
	ld	t3, 0(t6)
	li	t6, 10016
	add	t6, sp, t6
	ld	t4, 0(t6)
	li	t6, 10008
	add	t6, sp, t6
	ld	t5, 0(t6)
	li	t6, 10000
	add	t6, sp, t6
	ld	t6, 0(t6)
	li	t6, 10184
	add	t6, sp, t6
	ld	s0, 0(t6)
	li	t6, 10176
	add	t6, sp, t6
	ld	s1, 0(t6)
	li	t6, 10104
	add	t6, sp, t6
	ld	s2, 0(t6)
	li	t6, 10096
	add	t6, sp, t6
	ld	s3, 0(t6)
	li	t6, 10088
	add	t6, sp, t6
	ld	s4, 0(t6)
	li	t6, 10080
	add	t6, sp, t6
	ld	s5, 0(t6)
	li	t6, 10072
	add	t6, sp, t6
	ld	s6, 0(t6)
	li	t6, 10064
	add	t6, sp, t6
	ld	s7, 0(t6)
	li	t6, 10056
	add	t6, sp, t6
	ld	s8, 0(t6)
	li	t6, 10048
	add	t6, sp, t6
	ld	s9, 0(t6)
	li	t6, 10040
	add	t6, sp, t6
	ld	s10, 0(t6)
	li	t6, 10032
	add	t6, sp, t6
	ld	s11, 0(t6)
	li	a0, 0
	li	t6, 10224
	add	sp, sp, t6
	ret
.Lfunc_end8:
	.size	main, .Lfunc_end8-main
                                        # -- End function
	.globl	fn.1                            # -- Begin function fn.1
	.p2align	1
	.type	fn.1,@function
fn.1:                                   # @fn.1
# %bb.0:                                # %alloca
	addi	sp, sp, -880
	sd	s0, 840(sp)
	sd	s1, 832(sp)
	sd	s2, 760(sp)
	sd	s3, 752(sp)
	sd	s4, 744(sp)
	sd	s5, 736(sp)
	sd	s6, 728(sp)
	sd	s7, 720(sp)
	sd	s8, 712(sp)
	sd	s9, 704(sp)
	sd	s10, 696(sp)
	sd	s11, 688(sp)
	li	t6, 632
	add	t6, t6, sp
	sd	t6, 640(sp)
	li	t6, 616
	add	t6, t6, sp
	sd	t6, 624(sp)
	li	t6, 600
	add	t6, t6, sp
	sd	t6, 608(sp)
	li	t6, 584
	add	t6, t6, sp
	sd	t6, 592(sp)
	li	t6, 568
	add	t6, t6, sp
	sd	t6, 576(sp)
	li	t6, 552
	add	t6, t6, sp
	sd	t6, 560(sp)
	li	t6, 540
	add	t6, t6, sp
	sd	t6, 544(sp)
	li	t6, 524
	add	t6, t6, sp
	sd	t6, 528(sp)
	li	t6, 508
	add	t6, t6, sp
	sd	t6, 512(sp)
	li	t6, 492
	add	t6, t6, sp
	sd	t6, 496(sp)
	li	t6, 479
	add	t6, t6, sp
	sd	t6, 480(sp)
	j	.LBB9_0
.LBB9_0:                               # %label_0
	ld	t0, 640(sp)
	sd	a0, 0(t0)
	ld	t0, 624(sp)
	sd	a1, 0(t0)
	ld	t0, 608(sp)
	sd	a2, 0(t0)
	ld	t0, 592(sp)
	sd	a3, 0(t0)
	ld	t0, 576(sp)
	sd	a4, 0(t0)
	ld	t0, 560(sp)
	sd	a5, 0(t0)
	ld	t0, 544(sp)
	sw	a6, 0(t0)
	ld	t0, 528(sp)
	sw	a7, 0(t0)
	ld	t0, 512(sp)
	ld	t1, 652(sp)
	sw	t1, 0(t0)
	ld	t0, 640(sp)
	ld	t0, 0(t0)
	sd	t0, 464(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 460(sp)
	lw	t0, 460(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 464(sp)
	add	t2, t1, t0
	sd	t2, 448(sp)
	ld	t0, 528(sp)
	lw	t0, 0(t0)
	sw	t0, 444(sp)
	ld	t0, 448(sp)
	ld	t1, 444(sp)
	sw	t1, 0(t0)
	ld	t0, 624(sp)
	ld	t0, 0(t0)
	sd	t0, 432(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 428(sp)
	lw	t0, 428(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 432(sp)
	add	t2, t1, t0
	sd	t2, 416(sp)
	ld	t0, 416(sp)
	li	t1, -1
	sw	t1, 0(t0)
	ld	t0, 608(sp)
	ld	t0, 0(t0)
	sd	t0, 408(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 404(sp)
	lw	t0, 404(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 408(sp)
	add	t2, t1, t0
	sd	t2, 392(sp)
	ld	t0, 392(sp)
	li	t1, -1
	sw	t1, 0(t0)
	ld	t0, 592(sp)
	ld	t0, 0(t0)
	sd	t0, 384(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 380(sp)
	lw	t0, 380(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 384(sp)
	add	t2, t1, t0
	sd	t2, 368(sp)
	ld	t0, 368(sp)
	li	t1, -1
	sw	t1, 0(t0)
	ld	t0, 576(sp)
	ld	t0, 0(t0)
	sd	t0, 360(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 356(sp)
	lw	t0, 356(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 360(sp)
	add	t2, t1, t0
	sd	t2, 344(sp)
	ld	t0, 344(sp)
	li	t1, 1
	sw	t1, 0(t0)
	ld	t0, 560(sp)
	ld	t0, 0(t0)
	sd	t0, 336(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 332(sp)
	lw	t0, 332(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 336(sp)
	add	t2, t1, t0
	sd	t2, 320(sp)
	ld	t0, 320(sp)
	li	t1, 1
	sw	t1, 0(t0)
	ld	t0, 544(sp)
	lw	t0, 0(t0)
	sw	t0, 316(sp)
	lw	t0, 316(sp)
	xori	t0, t0, -1
	sltiu	s4, t0, 1
	add	t0, s4, x0
	beq	x0, t0, .LBB9_0_jump_0
	j	.LBB9_39
.LBB9_0_jump_0:                               # %label_0_jump_0
	j	.LBB9_40
.LBB9_39:                               # %label_39
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 308(sp)
	lw	a0, 308(sp)
	ld	s0, 840(sp)
	ld	s1, 832(sp)
	ld	s2, 760(sp)
	ld	s3, 752(sp)
	ld	s4, 744(sp)
	ld	s5, 736(sp)
	ld	s6, 728(sp)
	ld	s7, 720(sp)
	ld	s8, 712(sp)
	ld	s9, 704(sp)
	ld	s10, 696(sp)
	ld	s11, 688(sp)
	addi	sp, sp, 880
	ret
.LBB9_40:                               # %label_40
	ld	t0, 544(sp)
	lw	t0, 0(t0)
	sw	t0, 304(sp)
	ld	t0, 496(sp)
	ld	t1, 304(sp)
	sw	t1, 0(t0)
	ld	t0, 480(sp)
	li	t1, 0
	sb	t1, 0(t0)
	j	.LBB9_45
.LBB9_45:                               # %label_45
	ld	t0, 480(sp)
	lbu	t0, 0(t0)
	sb	t0, 303(sp)
	lbu	t1, 303(sp)
	li	t0, 1
	subw	t0, t0, t1
	add	s3, t0, x0
	add	t0, s3, x0
	beq	x0, t0, .LBB9_45_jump_0
	j	.LBB9_46
.LBB9_45_jump_0:                               # %label_45_jump_0
	j	.LBB9_47
.LBB9_46:                               # %label_46
	ld	t0, 528(sp)
	lw	t0, 0(t0)
	sw	t0, 296(sp)
	ld	t0, 640(sp)
	ld	t0, 0(t0)
	sd	t0, 288(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 284(sp)
	lw	t0, 284(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 288(sp)
	add	t2, t1, t0
	sd	t2, 272(sp)
	ld	t0, 272(sp)
	lw	t0, 0(t0)
	sw	t0, 268(sp)
	lw	t0, 296(sp)
	lw	t1, 268(sp)
	slt	s2, t0, t1
	add	t0, s2, x0
	beq	x0, t0, .LBB9_46_jump_0
	j	.LBB9_56
.LBB9_46_jump_0:                               # %label_46_jump_0
	j	.LBB9_57
.LBB9_47:                               # %label_47
	ld	t0, 544(sp)
	lw	t0, 0(t0)
	sw	t0, 260(sp)
	lw	a0, 260(sp)
	ld	s0, 840(sp)
	ld	s1, 832(sp)
	ld	s2, 760(sp)
	ld	s3, 752(sp)
	ld	s4, 744(sp)
	ld	s5, 736(sp)
	ld	s6, 728(sp)
	ld	s7, 720(sp)
	ld	s8, 712(sp)
	ld	s9, 704(sp)
	ld	s10, 696(sp)
	ld	s11, 688(sp)
	addi	sp, sp, 880
	ret
.LBB9_56:                               # %label_56
	ld	t0, 624(sp)
	ld	t0, 0(t0)
	sd	t0, 248(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 244(sp)
	lw	t0, 244(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 248(sp)
	add	t2, t1, t0
	sd	t2, 232(sp)
	ld	t0, 232(sp)
	lw	t0, 0(t0)
	sw	t0, 228(sp)
	lw	t0, 228(sp)
	xori	t0, t0, -1
	sltiu	s1, t0, 1
	add	t0, s1, x0
	beq	x0, t0, .LBB9_56_jump_0
	j	.LBB9_64
.LBB9_56_jump_0:                               # %label_56_jump_0
	j	.LBB9_65
.LBB9_57:                               # %label_57
	ld	t0, 608(sp)
	ld	t0, 0(t0)
	sd	t0, 216(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 212(sp)
	lw	t0, 212(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 216(sp)
	add	t2, t1, t0
	sd	t2, 200(sp)
	ld	t0, 200(sp)
	lw	t0, 0(t0)
	sw	t0, 196(sp)
	lw	t0, 196(sp)
	xori	t0, t0, -1
	sltiu	s0, t0, 1
	add	t0, s0, x0
	beq	x0, t0, .LBB9_57_jump_0
	j	.LBB9_84
.LBB9_57_jump_0:                               # %label_57_jump_0
	j	.LBB9_85
.LBB9_58:                               # %label_58
	j	.LBB9_45
.LBB9_64:                               # %label_64
	ld	t0, 624(sp)
	ld	t0, 0(t0)
	sd	t0, 184(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 180(sp)
	lw	t0, 180(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 184(sp)
	add	t2, t1, t0
	sd	t2, 168(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 164(sp)
	ld	t0, 168(sp)
	ld	t1, 164(sp)
	sw	t1, 0(t0)
	ld	t0, 592(sp)
	ld	t0, 0(t0)
	sd	t0, 152(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 148(sp)
	lw	t0, 148(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 152(sp)
	add	t2, t1, t0
	sd	t2, 136(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 132(sp)
	ld	t0, 136(sp)
	ld	t1, 132(sp)
	sw	t1, 0(t0)
	ld	t0, 480(sp)
	li	t1, 1
	sb	t1, 0(t0)
	j	.LBB9_66
.LBB9_65:                               # %label_65
	ld	t0, 624(sp)
	ld	t0, 0(t0)
	sd	t0, 120(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 116(sp)
	lw	t0, 116(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 120(sp)
	add	t2, t1, t0
	sd	t2, 104(sp)
	ld	t0, 104(sp)
	lw	t0, 0(t0)
	sw	t0, 100(sp)
	ld	t0, 496(sp)
	ld	t1, 100(sp)
	sw	t1, 0(t0)
	j	.LBB9_66
.LBB9_66:                               # %label_66
	j	.LBB9_58
.LBB9_84:                               # %label_84
	ld	t0, 608(sp)
	ld	t0, 0(t0)
	sd	t0, 88(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 84(sp)
	lw	t0, 84(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 88(sp)
	add	t2, t1, t0
	sd	t2, 72(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 68(sp)
	ld	t0, 72(sp)
	ld	t1, 68(sp)
	sw	t1, 0(t0)
	ld	t0, 592(sp)
	ld	t0, 0(t0)
	sd	t0, 56(sp)
	ld	t0, 512(sp)
	lw	t0, 0(t0)
	sw	t0, 52(sp)
	lw	t0, 52(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 56(sp)
	add	t2, t1, t0
	sd	t2, 40(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 36(sp)
	ld	t0, 40(sp)
	ld	t1, 36(sp)
	sw	t1, 0(t0)
	ld	t0, 480(sp)
	li	t1, 1
	sb	t1, 0(t0)
	j	.LBB9_86
.LBB9_85:                               # %label_85
	ld	t0, 608(sp)
	ld	t0, 0(t0)
	sd	t0, 24(sp)
	ld	t0, 496(sp)
	lw	t0, 0(t0)
	sw	t0, 20(sp)
	lw	t0, 20(sp)
	li	t1, 4
	mul	t0, t0, t1
	ld	t1, 24(sp)
	add	t2, t1, t0
	sd	t2, 8(sp)
	ld	t0, 8(sp)
	lw	t0, 0(t0)
	sw	t0, 4(sp)
	ld	t0, 496(sp)
	ld	t1, 4(sp)
	sw	t1, 0(t0)
	j	.LBB9_86
.LBB9_86:                               # %label_86
	j	.LBB9_58
.Lfunc_end9:
	.size	fn.1, .Lfunc_end9-fn.1
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"%s"
	.size	.L.str, 3

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"%s\n"
	.size	.L.str.1, 4

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"%d"
	.size	.L.str.2, 3

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"%d\n"
	.size	.L.str.3, 4

	.ident	"livandan's compiler 1.0"
	.section	".note.GNU-stack","",@progbits

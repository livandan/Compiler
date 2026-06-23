; ModuleID = 'builtin.c'
source_filename = "builtin.c"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv64-unknown-unknown-elf"

@.str = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@.str.2 = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: noinline nounwind optnone
define dso_local void @print(ptr noundef %0) #0 {
  %2 = alloca ptr, align 4
  store ptr %0, ptr %2, align 4
  %3 = load ptr, ptr %2, align 4
  %4 = call i32 (ptr, ...) @printf(ptr noundef @.str, ptr noundef %3)
  ret void
}

declare dso_local i32 @printf(ptr noundef, ...) #1

; Function Attrs: noinline nounwind optnone
define dso_local void @println(ptr noundef %0) #0 {
  %2 = alloca ptr, align 4
  store ptr %0, ptr %2, align 4
  %3 = load ptr, ptr %2, align 4
  %4 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, ptr noundef %3)
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local void @printInt(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = call i32 (ptr, ...) @printf(ptr noundef @.str.2, i32 noundef %3)
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local void @printlnInt(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  %4 = call i32 (ptr, ...) @printf(ptr noundef @.str.3, i32 noundef %3)
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local ptr @getString() #0 {
  %1 = alloca ptr, align 4
  %2 = call ptr @malloc(i32 noundef 256) #5
  store ptr %2, ptr %1, align 4
  %3 = load ptr, ptr %1, align 4
  %4 = call i32 (ptr, ...) @scanf(ptr noundef @.str, ptr noundef %3)
  %5 = load ptr, ptr %1, align 4
  ret ptr %5
}

; Function Attrs: allocsize(0)
declare dso_local ptr @malloc(i32 noundef) #2

declare dso_local i32 @scanf(ptr noundef, ...) #1

; Function Attrs: noinline nounwind optnone
define dso_local i32 @getInt() #0 {
  %1 = alloca i32, align 4
  %2 = call i32 (ptr, ...) @scanf(ptr noundef @.str.2, ptr noundef %1)
  %3 = load i32, ptr %1, align 4
  ret i32 %3
}

; Function Attrs: noinline nounwind optnone
define dso_local ptr @builtin_memset(ptr noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca ptr, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store ptr %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %7 = load ptr, ptr %4, align 4
  %8 = load i32, ptr %5, align 4
  %9 = trunc i32 %8 to i8
  %10 = load i32, ptr %6, align 4
  call void @llvm.memset.p0.i32(ptr align 1 %7, i8 %9, i32 %10, i1 false)
  ret ptr %7
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i32(ptr nocapture writeonly, i8, i32, i1 immarg) #3

; Function Attrs: noinline nounwind optnone
define dso_local ptr @builtin_memcpy(ptr noundef %0, ptr noundef %1, i32 noundef %2) #0 {
  %4 = alloca ptr, align 4
  %5 = alloca ptr, align 4
  %6 = alloca i32, align 4
  store ptr %0, ptr %4, align 4
  store ptr %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %7 = load ptr, ptr %4, align 4
  %8 = load ptr, ptr %5, align 4
  %9 = load i32, ptr %6, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 1 %7, ptr align 1 %8, i32 %9, i1 false)
  ret ptr %7
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i32(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i32, i1 immarg) #4

attributes #0 = { noinline nounwind optnone "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+a,+c,+m,+relax,-d,-e,-experimental-zacas,-experimental-zcmop,-experimental-zfbfmin,-experimental-zicfilp,-experimental-zicfiss,-experimental-zimop,-experimental-ztso,-experimental-zvfbfmin,-experimental-zvfbfwma,-f,-h,-smaia,-smepmp,-ssaia,-svinval,-svnapot,-svpbmt,-v,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-za128rs,-za64rs,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zcmp,-zcmt,-zdinx,-zfa,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zicsr,-zifencei,-zihintntl,-zihintpause,-zihpm,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zvbb,-zvbc,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+a,+c,+m,+relax,-d,-e,-experimental-zacas,-experimental-zcmop,-experimental-zfbfmin,-experimental-zicfilp,-experimental-zicfiss,-experimental-zimop,-experimental-ztso,-experimental-zvfbfmin,-experimental-zvfbfwma,-f,-h,-smaia,-smepmp,-ssaia,-svinval,-svnapot,-svpbmt,-v,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-za128rs,-za64rs,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zcmp,-zcmt,-zdinx,-zfa,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zicsr,-zifencei,-zihintntl,-zihintpause,-zihpm,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zvbb,-zvbc,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #2 = { allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv32" "target-features"="+32bit,+a,+c,+m,+relax,-d,-e,-experimental-zacas,-experimental-zcmop,-experimental-zfbfmin,-experimental-zicfilp,-experimental-zicfiss,-experimental-zimop,-experimental-ztso,-experimental-zvfbfmin,-experimental-zvfbfwma,-f,-h,-smaia,-smepmp,-ssaia,-svinval,-svnapot,-svpbmt,-v,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-za128rs,-za64rs,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zcmp,-zcmt,-zdinx,-zfa,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zicsr,-zifencei,-zihintntl,-zihintpause,-zihpm,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-zmmul,-zvbb,-zvbc,-zve32f,-zve32x,-zve64d,-zve64f,-zve64x,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl128b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl32b,-zvl4096b,-zvl512b,-zvl64b,-zvl65536b,-zvl8192b" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{i32 8, !"SmallDataLimit", i32 8}
!4 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}


define void @main() {
alloca:
	%var.0 = alloca [200 x i32]
	%var.1 = alloca [200 x i32]
	%var.2 = alloca [200 x i32]
	%var.3 = alloca [200 x i32]
	%var.4 = alloca [200 x i32]
	%var.5 = alloca [200 x i32]
	%var.6 = alloca [200 x i32]
	%var.7 = alloca [200 x i32]
	%var.8 = alloca [200 x i32]
	%var.9 = alloca [200 x i32]
	%var.10 = alloca [200 x i32]
	%var.11 = alloca [200 x i32]
	%var.12 = alloca i32
	%var.13 = alloca i32
	%var.14 = alloca i32
	%var.20 = alloca i32
	%var.24 = alloca ptr
	%var.26 = alloca ptr
	%var.28 = alloca ptr
	%var.30 = alloca ptr
	%var.32 = alloca ptr
	%var.34 = alloca ptr
	br label %label_0
label_0:
	call void @builtin_memset(ptr %var.1, i32 0, i32 800)
	call void @builtin_memcpy(ptr %var.0, ptr %var.1, i32 800)
	call void @builtin_memset(ptr %var.3, i32 -1, i32 800)
	call void @builtin_memcpy(ptr %var.2, ptr %var.3, i32 800)
	call void @builtin_memset(ptr %var.5, i32 -1, i32 800)
	call void @builtin_memcpy(ptr %var.4, ptr %var.5, i32 800)
	call void @builtin_memset(ptr %var.7, i32 -1, i32 800)
	call void @builtin_memcpy(ptr %var.6, ptr %var.7, i32 800)
	call void @builtin_memset(ptr %var.9, i32 0, i32 800)
	call void @builtin_memcpy(ptr %var.8, ptr %var.9, i32 800)
	call void @builtin_memset(ptr %var.11, i32 0, i32 800)
	call void @builtin_memcpy(ptr %var.10, ptr %var.11, i32 800)
	store i32 0, ptr %var.12
	store i32 -1, ptr %var.13
	store i32 0, ptr %var.14
	br label %label_15
label_15:
	%var.18 = load i32, ptr %var.14
	%var.19 = icmp slt i32 %var.18, 5
	br i1 %var.19, label %label_16, label %label_17
label_16:
	%var.21 = load i32, ptr %var.14
	%var.22 = mul i32 %var.21, 17
	%var.23 = add i32 %var.22, 23
	store i32 %var.23, ptr %var.20
	store ptr %var.0, ptr %var.24
	%var.25 = load ptr, ptr %var.24
	store ptr %var.2, ptr %var.26
	%var.27 = load ptr, ptr %var.26
	store ptr %var.4, ptr %var.28
	%var.29 = load ptr, ptr %var.28
	store ptr %var.6, ptr %var.30
	%var.31 = load ptr, ptr %var.30
	store ptr %var.8, ptr %var.32
	%var.33 = load ptr, ptr %var.32
	store ptr %var.10, ptr %var.34
	%var.35 = load ptr, ptr %var.34
	%var.36 = load i32, ptr %var.13
	%var.37 = load i32, ptr %var.20
	%var.38 = load i32, ptr %var.12
	%var.39 = call i32 @fn.1(ptr %var.25, ptr %var.27, ptr %var.29, ptr %var.31, ptr %var.33, ptr %var.35, i32 %var.36, i32 %var.37, i32 %var.38)
	store i32 %var.39, ptr %var.13
	%var.40 = load i32, ptr %var.12
	%var.41 = add i32 %var.40, 1
	store i32 %var.41, ptr %var.12
	%var.42 = load i32, ptr %var.14
	%var.43 = add i32 %var.42, 1
	store i32 %var.43, ptr %var.14
	br label %label_15
label_17:
	%var.44 = load i32, ptr %var.13
	call void @printlnInt(i32 %var.44)
	%var.45 = getelementptr [200 x i32], ptr %var.0, i32 0, i32 0
	%var.46 = load i32, ptr %var.45
	call void @printlnInt(i32 %var.46)
	%var.47 = getelementptr [200 x i32], ptr %var.0, i32 0, i32 1
	%var.48 = load i32, ptr %var.47
	call void @printlnInt(i32 %var.48)
	ret void
}

define i32 @fn.1(ptr %var.0, ptr %var.1, ptr %var.2, ptr %var.3, ptr %var.4, ptr %var.5, i32 %var.6, i32 %var.7, i32 %var.8) {
alloca:
	%var.9 = alloca ptr
	%var.10 = alloca ptr
	%var.11 = alloca ptr
	%var.12 = alloca ptr
	%var.13 = alloca ptr
	%var.14 = alloca ptr
	%var.15 = alloca i32
	%var.16 = alloca i32
	%var.17 = alloca i32
	%var.42 = alloca i32
	%var.44 = alloca i1
	br label %label_0
label_0:
	store ptr %var.0, ptr %var.9
	store ptr %var.1, ptr %var.10
	store ptr %var.2, ptr %var.11
	store ptr %var.3, ptr %var.12
	store ptr %var.4, ptr %var.13
	store ptr %var.5, ptr %var.14
	store i32 %var.6, ptr %var.15
	store i32 %var.7, ptr %var.16
	store i32 %var.8, ptr %var.17
	%var.18 = load ptr, ptr %var.9
	%var.20 = load i32, ptr %var.17
	%var.19 = getelementptr [200 x i32], ptr %var.18, i32 0, i32 %var.20
	%var.21 = load i32, ptr %var.16
	store i32 %var.21, ptr %var.19
	%var.22 = load ptr, ptr %var.10
	%var.24 = load i32, ptr %var.17
	%var.23 = getelementptr [200 x i32], ptr %var.22, i32 0, i32 %var.24
	store i32 -1, ptr %var.23
	%var.25 = load ptr, ptr %var.11
	%var.27 = load i32, ptr %var.17
	%var.26 = getelementptr [200 x i32], ptr %var.25, i32 0, i32 %var.27
	store i32 -1, ptr %var.26
	%var.28 = load ptr, ptr %var.12
	%var.30 = load i32, ptr %var.17
	%var.29 = getelementptr [200 x i32], ptr %var.28, i32 0, i32 %var.30
	store i32 -1, ptr %var.29
	%var.31 = load ptr, ptr %var.13
	%var.33 = load i32, ptr %var.17
	%var.32 = getelementptr [200 x i32], ptr %var.31, i32 0, i32 %var.33
	store i32 1, ptr %var.32
	%var.34 = load ptr, ptr %var.14
	%var.36 = load i32, ptr %var.17
	%var.35 = getelementptr [200 x i32], ptr %var.34, i32 0, i32 %var.36
	store i32 1, ptr %var.35
	%var.37 = load i32, ptr %var.15
	%var.38 = icmp eq i32 %var.37, -1
	br i1 %var.38, label %label_39, label %label_40
label_39:
	%var.41 = load i32, ptr %var.17
	ret i32 %var.41
label_40:
	%var.43 = load i32, ptr %var.15
	store i32 %var.43, ptr %var.42
	store i1 0, ptr %var.44
	br label %label_45
label_45:
	%var.48 = load i1, ptr %var.44
	%var.49 = sub i1 1, %var.48
	br i1 %var.49, label %label_46, label %label_47
label_46:
	%var.50 = load i32, ptr %var.16
	%var.51 = load ptr, ptr %var.9
	%var.53 = load i32, ptr %var.42
	%var.52 = getelementptr [200 x i32], ptr %var.51, i32 0, i32 %var.53
	%var.54 = load i32, ptr %var.52
	%var.55 = icmp slt i32 %var.50, %var.54
	br i1 %var.55, label %label_56, label %label_57
label_47:
	%var.99 = load i32, ptr %var.15
	ret i32 %var.99
label_56:
	%var.59 = load ptr, ptr %var.10
	%var.61 = load i32, ptr %var.42
	%var.60 = getelementptr [200 x i32], ptr %var.59, i32 0, i32 %var.61
	%var.62 = load i32, ptr %var.60
	%var.63 = icmp eq i32 %var.62, -1
	br i1 %var.63, label %label_64, label %label_65
label_57:
	%var.79 = load ptr, ptr %var.11
	%var.81 = load i32, ptr %var.42
	%var.80 = getelementptr [200 x i32], ptr %var.79, i32 0, i32 %var.81
	%var.82 = load i32, ptr %var.80
	%var.83 = icmp eq i32 %var.82, -1
	br i1 %var.83, label %label_84, label %label_85
label_58:
	br label %label_45
label_64:
	%var.67 = load ptr, ptr %var.10
	%var.69 = load i32, ptr %var.42
	%var.68 = getelementptr [200 x i32], ptr %var.67, i32 0, i32 %var.69
	%var.70 = load i32, ptr %var.17
	store i32 %var.70, ptr %var.68
	%var.71 = load ptr, ptr %var.12
	%var.73 = load i32, ptr %var.17
	%var.72 = getelementptr [200 x i32], ptr %var.71, i32 0, i32 %var.73
	%var.74 = load i32, ptr %var.42
	store i32 %var.74, ptr %var.72
	store i1 1, ptr %var.44
	br label %label_66
label_65:
	%var.75 = load ptr, ptr %var.10
	%var.77 = load i32, ptr %var.42
	%var.76 = getelementptr [200 x i32], ptr %var.75, i32 0, i32 %var.77
	%var.78 = load i32, ptr %var.76
	store i32 %var.78, ptr %var.42
	br label %label_66
label_66:
	br label %label_58
label_84:
	%var.87 = load ptr, ptr %var.11
	%var.89 = load i32, ptr %var.42
	%var.88 = getelementptr [200 x i32], ptr %var.87, i32 0, i32 %var.89
	%var.90 = load i32, ptr %var.17
	store i32 %var.90, ptr %var.88
	%var.91 = load ptr, ptr %var.12
	%var.93 = load i32, ptr %var.17
	%var.92 = getelementptr [200 x i32], ptr %var.91, i32 0, i32 %var.93
	%var.94 = load i32, ptr %var.42
	store i32 %var.94, ptr %var.92
	store i1 1, ptr %var.44
	br label %label_86
label_85:
	%var.95 = load ptr, ptr %var.11
	%var.97 = load i32, ptr %var.42
	%var.96 = getelementptr [200 x i32], ptr %var.95, i32 0, i32 %var.97
	%var.98 = load i32, ptr %var.96
	store i32 %var.98, ptr %var.42
	br label %label_86
label_86:
	br label %label_58
}


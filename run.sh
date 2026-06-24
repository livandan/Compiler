#!/bin/bash

#cmake --build cmake-build-debug
#./cmake-build-debug/IR_test

#IR_success_count=0
#
#for INDEX in {1..50}; do
#  echo "compiling ${INDEX}.ll into elf..."
#  clang --target=riscv64-unknown-elf -O0 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.ll" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.elf"
#  if [ $? -eq 0 ]; then
#    qemu-riscv64 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.elf" < "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" > "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out"
#    if [ $? -eq 0 ]; then
#      diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
#      if [ $? -eq 0 ]; then
#        echo "!!!!!!!!!!!!!! ${INDEX} success!"
#        ((IR_success_count++))
#      else
#        echo "********************************************************************************** ${INDEX} failed in diff"
#      fi
#    else
#      echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${INDEX} failed in executing qemu"
#    fi
#  else
#    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ${INDEX} failed in generating elf"
#  fi
#done

#echo "compiling debugging.ll into elf..."
#clang --target=riscv64-unknown-elf -O0 "RCompiler-Testcases/working_space/debugging.ll" -o "RCompiler-Testcases/working_space/debugging.elf"
#if [ $? -eq 0 ]; then
#  qemu-riscv64 "RCompiler-Testcases/working_space/debugging.elf" < "RCompiler-Testcases/working_space/debugging.in" > "RCompiler-Testcases/working_space/debugging_my_output.out"
#  if [ $? -eq 0 ]; then
#    diff "RCompiler-Testcases/working_space/debugging.out" "RCompiler-Testcases/working_space/debugging_my_output.out" -Z
#    if [ $? -eq 0 ]; then
#      echo "!!!!!!!!!!!!!! success!"
#    else
#      echo "********************************************************************************** failed in diff"
#    fi
#  else
#    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ failed in executing qemu"
#  fi
#else
#  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ failed in generating elf"
#fi

echo "============================= Codegen Tests Begins ============================="

IR_1_success_count=0

for INDEX in {1..50}; do
  riscv64-linux-gnu-gcc -march=rv64gc -mabi=lp64d -static "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my.s" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my.elf"
  if [ $? -eq 0 ]; then
    qemu-riscv64 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my.elf" < "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" > "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out"
    if [ $? -eq 0 ]; then
      diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
      if [ $? -eq 0 ]; then
        echo "!!!!!!!!!!!!!! ${INDEX} success!"
        ((IR_1_success_count++))
      else
        echo "********************************************************************************** ${INDEX} failed in diff"
      fi
    else
      echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${INDEX} failed in executing qemu"
    fi
  else
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ${INDEX} failed in generating elf"
  fi
done

#echo "IR generating tests: ${IR_success_count} success out of 50"

echo "IR-1 tests: ${IR_1_success_count} success out of 50"

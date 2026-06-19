#!/bin/bash

#cmake --build cmake-build-debug
#./cmake-build-debug/IR_test

IR_success_count=0

for INDEX in {1..50}; do
  echo "compiling ${INDEX}.ll into assembly..."
  clang -S --target=riscv32-unknown-elf -O0 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.ll" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.s"
  if [ $? -eq 0 ]; then
    sed -i 's/@plt//g' "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.s"
    reimu -f="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.s" -i="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" -s=200000000
    if [ $? -eq 0 ]; then
      diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
      if [ $? -eq 0 ]; then
        echo "!!!!!!!!!!!!!! ${INDEX} success!"
        ((IR_success_count++))
      else
        echo "********************************************************************************** ${INDEX} failed in diff"
      fi
    else
      echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${INDEX} failed in executing reimu"
    fi
  else
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ${INDEX} failed in generating .s"
  fi
done

echo "IR generating tests: ${IR_success_count} success out of 50"


#echo "compiling debugging.ll into assembly..."
#clang -S --target=riscv32-unknown-elf -O0 "RCompiler-Testcases/working_space/debugging.ll" -o "RCompiler-Testcases/working_space/debugging.s"
#if [ $? -eq 0 ]; then
#  sed -i 's/@plt//g' "RCompiler-Testcases/working_space/debugging.s"
#  reimu -f="RCompiler-Testcases/working_space/debugging.s" -i="RCompiler-Testcases/working_space/debugging.in" -o "RCompiler-Testcases/working_space/debugging_my_output.out" -s=200000000
#  if [ $? -eq 0 ]; then
#    diff "RCompiler-Testcases/working_space/debugging.out" "RCompiler-Testcases/working_space/debugging_my_output.out" -Z
#    if [ $? -eq 0 ]; then
#      echo "!!!!!!!!!!!!!! success!"
#    else
#      echo "********************************************************************************** failed in diff"
#    fi
#  else
#    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ failed in executing reimu"
#  fi
#else
#  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ failed in generating .s"
#fi

echo ""
echo ""
echo ""
echo ""
echo "============================= Small Tests ==========================="

success_count=0
total_count=0

for IN_FILE in RCompiler-Testcases/working_space/t*.in; do
  BASENAME=$(basename "$IN_FILE" .in)
  PREFIX="RCompiler-Testcases/working_space/${BASENAME}"
  S_FILE="${PREFIX}_mem2reg.s"
  OUT_FILE="${PREFIX}.out"
  MY_OUT_FILE="${PREFIX}_my_output.out"

  if [ ! -f "$S_FILE" ]; then
    echo "-------- ${BASENAME} skipped (no _mem2reg.s)"
    continue
  fi
  ((total_count++))

  timeout 15s reimu -f="$S_FILE" -i="$IN_FILE" -o="$MY_OUT_FILE" -s=200000000
  if [ $? -eq 0 ]; then
    diff "$MY_OUT_FILE" "$OUT_FILE" -Z
    if [ $? -eq 0 ]; then
      ((success_count++))
      echo "${BASENAME} success!!!"
    else
      echo "-------- ${BASENAME} failed in diff"
    fi
  else
    echo "-------- ${BASENAME} failed in executing reimu"
  fi
done

echo ""
echo "Small tests: ${success_count} success out of ${total_count}"

echo ""
echo ""
echo ""
echo ""
echo "============================= Codegen Tests Begins ============================="

code_gen_success_count=0
mem2reg_success_count=0

for INDEX in {1..50}; do
  timeout 15s reimu -f="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.s" -i="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" -s=200000000
  if [ $? -eq 0 ]; then
    diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
    if [ $? -eq 0 ]; then
      echo "!!!!!!!!!!!!!! ${INDEX} success!"
      ((code_gen_success_count++))
      ((mem2reg_success_count++))
    else
      echo "********************************************************************************** ${INDEX} failed in diff"
      clang -S --target=riscv32-unknown-elf -O0 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.ll" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.s"
      if [ $? -eq 0 ]; then
        timeout 15s reimu -f="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.s" -i="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" -s=200000000
        if [ $? -eq 0 ]; then
          diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
          if [ $? -eq 0 ]; then
            echo "!!!!!!!!!!!!!! ${INDEX} success in generating mem2reg!"
            ((mem2reg_success_count++))
          else
            echo "------------failed"
          fi
        else
          echo "------------failed"
        fi
      else
        echo "------------failed"
      fi
    fi
  else
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${INDEX} failed in executing reimu"
    clang -S --target=riscv32-unknown-elf -O0 "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.ll" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.s"
    if [ $? -eq 0 ]; then
      timeout 15s reimu -f="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_mem2reg.s" -i="RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.in" -o "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" -s=200000000
      if [ $? -eq 0 ]; then
        diff "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}_my_output.out" "RCompiler-Testcases/IR-1/src/comprehensive${INDEX}/comprehensive${INDEX}.out" -Z
        if [ $? -eq 0 ]; then
          echo "!!!!!!!!!!!!!! ${INDEX} success in generating mem2reg!"
          ((mem2reg_success_count++))
        else
          echo "------------failed"
        fi
      else
        echo "------------failed"
      fi
    else
      echo "------------failed"
    fi
  fi
done

echo "codegen tests: ${code_gen_success_count} success out of 50"
echo "mem2reg tests: ${mem2reg_success_count} success out of 50"

# Plan: RV32 → RV64 Migration

## Overview

Migrate the compiler target from RV32 to RV64, and switch from the `reimu` simulator to `qemu-riscv64` for testing.

## Key Principles

Per `RV32toRV64.md`:
- **Integer operations**: Use `*w` variants (e.g., `addw`, `mulw`) — operate on lower 32 bits, sign-extend result to 64 bits
- **Pointer operations**: Keep non-`w` variants (`add`, `addi`) — full 64-bit operations
- **Register saves**: Use `sd`/`ld` (8 bytes per register instead of 4)
- **Pointer memory**: Use `sd`/`ld` (8 bytes, 64-bit pointers)
- **Integer memory**: Keep `sw`/`lw` (4 bytes, sign-extended in registers)
- **Comparisons/branches/bitwise ops**: No change (work correctly on 64-bit registers with sign-extended values)
- **`isize`/`usize`**: Keep as 4 bytes (data guarantee: results stay in 32-bit range)

---

## Step 1: Add new RISC-V instruction types

**File**: `codegen/include/code_generator.h`

Add new entries to the `RISCVInstructionType` enum:
- `r_addw_`, `r_subw_`, `r_addiw_` — integer add/sub with word truncation
- `r_sllw_`, `r_srlw_`, `r_sraw_` — integer shifts (word)
- `r_slliw_`, `r_srliw_`, `r_sraiw_` — integer immediate shifts (word)
- `r_mulw_`, `r_divw_`, `r_divuw_`, `r_remw_`, `r_remuw_` — integer mul/div/rem (word)
- `r_ld_`, `r_sd_` — load/store doubleword (64-bit for pointers and register saves)

Update validation ranges in helper methods:
- `PushArithmetic_R`: expand range from `<= 10` to include `r_addw_` through `r_sraw_`
- `PushArithmetic_I`: add cases for `r_addiw_`, `r_slliw_`, `r_srliw_`, `r_sraiw_` (same logic as existing, just with new mnemonics)
- `PushExtended`: expand range to include `r_mulw_` through `r_remuw_`
- `PushMemory_I`: expand range to include `r_ld_`
- `PushMemory_S`: expand range to include `r_sd_`

---

## Step 2: Update type sizing for 64-bit pointers

**File**: `codegen/src/code_generator.cpp`, function `GetSize()`

```cpp
case pointer_type: {
  return {8, true};  // was {4, true} — pointers are now 64-bit
}
```

`isize_type` and `usize_type` remain `{4, true}`.

---

## Step 3: Update stack frame layout

**File**: `codegen/src/code_generator.cpp`

### 3a. `MemAlloc()` — register save area size
```cpp
space = 224;  // was 112 — 28 registers × 8 bytes each
```

### 3b. `MemAlloc()` — stack alignment
```cpp
space = (space + 7) / 8 * 8;  // was (space + 3) / 4 * 4 — align to 8 bytes
```

### 3c. `RegSavedLocation()` — register save offsets
```cpp
int CodeGenerator::RegSavedLocation(const int func_id, const int reg_id) const {
  const int stack_space = RISCV_functions_[func_id].stack_space_;
  if (reg_id == 1) {
    return stack_space - 8;  // was -4
  }
  if (reg_id <= 4) {
    CodegenThrow(...);
  }
  return stack_space - 8 * (reg_id - 3);  // was 4 * (reg_id - 3)
}
```

### 3d. Pointer variables on stack

Since `GetSize(pointer_type)` now returns `{8, true}`, all pointer-typed alloca/load/call results automatically get 8 bytes of stack space. The existing `MemAlloc` logic handles this via `GetSize()`.

---

## Step 4: Update register save/restore instructions

**File**: `codegen/src/code_generator.cpp`, function `Generate()`

### 4a. Prologue (save callee-save registers)
```cpp
bb0.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);  // was r_sw_
```

### 4b. Epilogue (restore before return)
All callee-save register restores in `value_ret_`, `variable_ret_`, `void_ret_`:
```cpp
r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);  // was r_lw_
```

### 4c. Caller-save spill/reload around function calls

In `non_void_call_`, `void_call_`, `builtin_call_`, `builtin_memset_`, `builtin_memcpy_`:
- Save: `PushMemory_S(r_sd_, ...)` instead of `r_sw_`
- Restore: `PushMemory_I(r_ld_, ...)` instead of `r_lw_`

### 4d. VariableAssignment memcpy path (for struct/array moves)
The caller-save spill/reload inside the memcpy setup blocks:
- Save: `PushMemory_S(r_sd_, ...)` instead of `r_sw_`
- Restore: `PushMemory_I(r_ld_, ...)` instead of `r_lw_`

### 4e. Load with large types (struct/array copy via memcpy)
In `load_` and `variable_store_` large-type paths:
- Save: `PushMemory_S(r_sd_, ...)` instead of `r_sw_`
- Restore: `PushMemory_I(r_ld_, ...)` instead of `r_lw_`

---

## Step 5: Switch integer operations to `*w` variants

**File**: `codegen/src/code_generator.cpp`, function `Generate()`

### 5a. Binary operations (two_var, var_const, const_var)

| Old | New |
|-----|-----|
| `PushArithmetic_R(r_add_, ...)` | `PushArithmetic_R(r_addw_, ...)` |
| `PushArithmetic_R(r_sub_, ...)` | `PushArithmetic_R(r_subw_, ...)` |
| `PushArithmetic_R(r_sll_, ...)` | `PushArithmetic_R(r_sllw_, ...)` |
| `PushArithmetic_R(r_sra_, ...)` | `PushArithmetic_R(r_sraw_, ...)` |
| `PushExtended(r_mul_, ...)` | `PushExtended(r_mulw_, ...)` |
| `PushExtended(r_div_, ...)` | `PushExtended(r_divw_, ...)` |
| `PushExtended(r_divu_, ...)` | `PushExtended(r_divuw_, ...)` |
| `PushExtended(r_rem_, ...)` | `PushExtended(r_remw_, ...)` |
| `PushExtended(r_remu_, ...)` | `PushExtended(r_remuw_, ...)` |

`and`, `or`, `xor` do NOT change (no `w` variants exist — bitwise ops on 64-bit registers work correctly with sign-extended values).

### 5b. Shift immediate in variable_store

```cpp
r_block.PushArithmetic_I(r_srliw_, src_reg, src_reg, 8);  // was r_srli_
```

### 5c. GEP (pointer arithmetic) — keep non-w

`get_element_ptr_by_value_` and `get_element_ptr_by_variable_` use `r_addi_`/`r_add_` for pointer offset calculation. These stay as-is (64-bit pointer arithmetic).

### 5d. SP adjustment — keep non-w

All `PushArithmetic_I(r_addi_, 2, ...)` and `PushReturn` stay as `addi`/`add` (SP is a 64-bit pointer).

### 5e. VariableAssignment for pointer types

Add handling for `type_size == 8` (pointer types now 8 bytes):
- Load from stack: `PushMemory_I(r_ld_, ...)`
- Store to stack: `PushMemory_S(r_sd_, ...)`
- Register-register move: `PushArithmetic_R(r_add_, ...)` (keep non-w for 64-bit values)

---

## Step 6: Update instruction printer

**File**: `codegen/src/code_generator.cpp`, function `Print()`

Add cases for all new instruction types:

| Type | Mnemonic | Print helper |
|------|----------|-------------|
| `r_addw_` | `addw` | `Print_AR` |
| `r_subw_` | `subw` | `Print_AR` |
| `r_addiw_` | `addiw` | `Print_AI` |
| `r_sllw_` | `sllw` | `Print_AR` |
| `r_srlw_` | `srlw` | `Print_AR` |
| `r_sraw_` | `sraw` | `Print_AR` |
| `r_slliw_` | `slliw` | `Print_AI` |
| `r_srliw_` | `srliw` | `Print_AI` |
| `r_sraiw_` | `sraiw` | `Print_AI` |
| `r_mulw_` | `mulw` | `Print_AR` |
| `r_divw_` | `divw` | `Print_AR` |
| `r_divuw_` | `divuw` | `Print_AR` |
| `r_remw_` | `remw` | `Print_AR` |
| `r_remuw_` | `remuw` | `Print_AR` |
| `r_ld_` | `ld` | `Print_MI` |
| `r_sd_` | `sd` | `Print_MS` |

---

## Step 7: Rewrite builtin functions for RV64

**Files**:
- `RCompiler-Testcases/IR-1/builtin/builtin_fn.txt` — builtin assembly functions
- `RCompiler-Testcases/IR-1/builtin/builtin_str.txt` — format strings
- `RCompiler-Testcases/IR-1/builtin/builtin.s` — combined file (used by reimu, will be regenerated for RV64)

**Approach**: Write a small C file with the builtins, compile to RV64 assembly:

```bash
clang -S --target=riscv64-unknown-elf -O0 -march=rv64gc builtin_rv64.c -o builtin_fn.txt
```

The `builtin_str.txt` just needs the `.attribute` line updated to `"rv64i2p1_m2p0_a2p1_c2p0"` — the format strings themselves don't change.

---

## Step 8: Update run.sh for qemu-riscv64

**File**: `run.sh`

### IR tests (line 6-28):
```bash
# Old: clang -S --target=riscv32 + reimu
# New: clang compiles to ELF, qemu runs it
clang --target=riscv64-unknown-elf -O0 input.ll -o output.elf
qemu-riscv64 output.elf < input.in > output.out
```

### Codegen tests (line 53-70):
```bash
# Old: reimu -f=my.s
# New: assemble + link, then qemu
clang --target=riscv64-unknown-elf -O0 my_output.s -o my_output.elf
qemu-riscv64 my_output.elf < input.in > my_output.out
diff my_output.out expected.out
```

---

## Step 9: Verify test infrastructure

- `test/codegen_test.cpp` — calls `CodeGenerator::Generate()` + `Output()`, which now produce RV64 `.s`. No source changes needed.
- `CMakeLists.txt` — no changes needed (register_allocator already listed).

---

## File Changes Summary

| File | Changes |
|------|---------|
| `codegen/include/code_generator.h` | New enum values, updated Push* validation ranges |
| `codegen/src/code_generator.cpp` | GetSize, MemAlloc, RegSavedLocation, Generate (w-variants, sd/ld), Print (new mnemonics), VariableAssignment (8-byte case) |
| `RCompiler-Testcases/IR-1/builtin/builtin_fn.txt` | Regenerate for RV64 |
| `RCompiler-Testcases/IR-1/builtin/builtin_str.txt` | Update .attribute line |
| `RCompiler-Testcases/IR-1/builtin/builtin.s` | Regenerate for RV64 |
| `run.sh` | Replace reimu with clang+qemu-riscv64 pipeline |

---

## Testing After Migration

```bash
# Rebuild
cmake -S . -B cmake-build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build cmake-build-debug

# Run codegen tests (generates _my.s files)
./cmake-build-debug/codegen_tests

# Test a single case end-to-end with qemu
clang --target=riscv64-unknown-elf -O0 \
  RCompiler-Testcases/IR-1/src/comprehensive1/comprehensive1_my.s \
  -o /tmp/test.elf
qemu-riscv64 /tmp/test.elf \
  < RCompiler-Testcases/IR-1/src/comprehensive1/comprehensive1.in \
  > /tmp/test.out
diff /tmp/test.out RCompiler-Testcases/IR-1/src/comprehensive1/comprehensive1.out

# Run all tests
bash run.sh
```

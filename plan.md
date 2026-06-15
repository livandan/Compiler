# Plan: mem2reg + Register Allocation

## Current State

The compiler pipeline is: `.rx` → Lexer → Parser → Semantic → IR → Codegen → RISC-V `.s`

**How variables work today:**
- IR generator emits `alloca` for every variable (params, let-bindings, loop vars, temporaries)
- All alloca'd slots live in `IRFunctionNode::alloca_instructions_`
- Codegen's `MemAlloc()` assigns every IR variable a **stack slot only** — `location_[var_id]` is always `{false, stack_offset}`, i.e. nothing ever lives in a register aside from scratch regs (x5/x6) and function parameters passed in a0-a7
- Every operation follows: load operands from stack → compute → store result to stack
- This works correctly but produces verbose, slow code

## Phase 1: mem2reg (IR-level promotion)

**Where**: Operates on `IRFunctionNode`'s blocks and alloca list — after IR generation, before codegen.  
**Goal**: Eliminate alloca/load/store for scalar variables that never have their address taken, replacing them with direct value references and phi nodes.

### Step 1.1 — Identify promotable allocas

For each `alloca` in `IRFunctionNode::alloca_instructions_` with result_id `A`, scan all instructions in all blocks. If **any** use of `A` falls into the "prohibits promotion" category below, the alloca is not promotable. Otherwise it is promotable.

The analysis distinguishes three roles a variable ID can play in an instruction:
- **As a pointer operand** — `A` appears directly as `pointer_` (or `destination_` in memcpy), meaning the instruction accesses memory through `A`.
- **As a stored/loaded value** — `A` appears as `result_id_` in a load/store, or as an operand in arithmetic/calls/phs — this happens when `A` is a load result from the alloca, not the alloca itself. This is handled by `ReplaceAllUses` and does **not** affect promotability of the alloca.
- **As the alloca identity** — `A` being the alloca pointer itself. Only the "pointer operand" usage matters for promotability.

---

#### Per-instruction-type analysis

##### `load_`
- **pointer_ = A**: The canonical case. Loading a scalar value from the alloca. **Permitted.**
- **result_id_ = A**: Cannot happen — `A` is a pointer, `load_` produces a scalar, not a pointer-to-pointer.
- **Verdict**: Permitted. The load result is later replaced with the reaching definition.

##### `ptr_load_`
- **pointer_ = A**: Loads a pointer value from the alloca. Semantically equivalent to `load_` but for pointer-typed variables. **Should be permitted** for pointer-typed alloca, but currently conservatively **prohibited** (treated as address-taken, since the alloca stores a pointer that could escape). Could be relaxed later.
- **Verdict**: Conservatively prohibited. A pointer-typed alloca stays on the stack.

##### `variable_store_`
- **pointer_ = A**: Storing a variable's value into the alloca. This is a definition (reaching def). **Permitted.**
- **result_id_ = A**: Cannot happen — `A` is a pointer, not a scalar value.
- **Verdict**: Permitted. The stored variable ID becomes the new reaching definition.

##### `value_store_`
- **pointer_ = A**: Storing a literal constant into the alloca. **Prohibited** in the current conservative implementation, because replacing a load with a constant requires changing instruction types (e.g. `two_var_binary_operation_` → `var_const_binary_operation_`), creating a complex rewrite matrix. Could be relaxed: all uses of the load result would need to switch to their const-variant instruction types.
- **Verdict**: Conservatively prohibited. Allocas initialized with constants stay on the stack.

##### `ptr_store_`
- **pointer_ = A**: Storing a pointer value into the alloca. For pointer-typed alloca this is the store counterpart to `ptr_load_`. Currently **prohibited** (same rationale as `ptr_load_`).
- **result_id_ = A**: The alloca's address is being stored into another memory location — **address has escaped**. Definitely **prohibited** (though unlikely in practice for scalar allocas in this IR).
- **Verdict**: Prohibited.

##### `get_element_ptr_by_value_` / `get_element_ptr_by_variable_`
- **pointer_ = A**: The alloca is being indexed as an aggregate (array/struct). **Prohibited** — scalars don't have elements.
- **result_id_ = A**: An element pointer derived from `A` is stored somewhere — **address has escaped**. **Prohibited.**
- **index_ = A** (variable variant only): `A` would need to be a load result (integer used as index), not the alloca itself. Doesn't affect promotability of the alloca. Permitted for the load replacement.
- **Verdict**: Prohibited if `pointer_` or `result_id_` matches `A`.

##### `conditional_br_`
- **condition_id_ = A**: `A` would be a load result (i1 bool), not the alloca pointer. Does not affect promotability. Handled by `ReplaceAllUses`.
- **Verdict**: Does not affect alloca promotability.

##### `unconditional_br_`
- Only references block labels. **Verdict**: Irrelevant.

##### `value_ret_` / `variable_ret_` / `void_ret_`
- Return instructions. `result_id_` in `variable_ret_` could be a load result → handled by `ReplaceAllUses`. **Verdict**: Does not affect alloca promotability.

##### `alloca_`
- The instruction being analyzed. **Verdict**: This is the target of promotion, not a usage.

##### `two_var_binary_operation_` / `var_const_binary_operation_` / `const_var_binary_operation_`
- Operands could be load results → handled by `ReplaceAllUses` (var→var replacement). If the replacement is a constant (from `value_store_`), the instruction type would need changing — this is why `value_store_` is conservatively prohibited in the promotability check.
- **Verdict**: Does not affect alloca promotability.

##### `two_var_icmp_` / `var_const_icmp_` / `const_var_icmp_`
- Operands could be load results → handled by `ReplaceAllUses`. Same constant-replacement concern as binary ops.
- **Verdict**: Does not affect alloca promotability.

##### `non_void_call_` / `void_call_` / `builtin_call_`
- **function_call_arguments_**: If a `FunctionCallArgument` has `is_variable_ == true` and `value_ == A`, and the argument is a pointer type, then `A` (the alloca pointer) is being passed to a function — **address has escaped, prohibited**. If the argument is a scalar type, this would mean `A` is a load result, not the alloca itself → permitted.
- `result_id_` (non_void/builtin): Could be a load result from the alloca which is then stored → handled by replacement.
- **Current implementation note**: The `IsPromotable` check does not scan `function_call_arguments_`. This is a known gap — in practice allocas are not directly passed as call arguments in this IR (values are loaded first).
- **Verdict**: Does not affect alloca promotability in practice, but should scan arguments for completeness.

##### `phi_`
- Operands could be load results → handled by step 6 in `PromoteAlloca` (re-scan phi operands with replacement map).
- The phi result itself is a NEW variable introduced during promotion.
- **Verdict**: Does not affect alloca promotability.

##### `value_select_ii_` through `variable_select_vv_`
- Condition and value operands could be load results → handled by `ReplaceAllUses`.
- **Verdict**: Does not affect alloca promotability.

##### `builtin_memset_`
- **pointer_ = A**: The alloca is being bulk-initialized by memset. This is an aggregate operation (used for array/struct zero-init). **Prohibited** — implies the alloca is not a simple scalar.
- **Verdict**: Prohibited.

##### `builtin_memcpy_`
- **pointer_ = A** (source): The alloca's content is being copied out — implies aggregate usage. **Prohibited.**
- **destination_ = A**: The alloca is the target of a bulk copy — aggregate usage. **Prohibited** (but the current `IsPromotable` does not check `destination_` — a known gap; in practice memcpy is only used on arrays/structs which are already excluded by the scalar-only check).
- **Verdict**: Prohibited.

---

#### Summary of promotability criteria

| Role of alloca `A` in instruction | Permitted? | Notes |
|---|---|---|
| `pointer_` of `load_` | Yes | Canonical scalar load |
| `pointer_` of `variable_store_` | Yes | Canonical scalar store (definition) |
| `pointer_` of `value_store_` | **No** (conservative) | Constants require instruction-type rewrite on replacement |
| `pointer_` of `ptr_load_` | **No** (conservative) | Pointer-typed alloca; could be relaxed |
| `pointer_` of `ptr_store_` | **No** | Address semantics differ from scalar store |
| `result_id_` of `ptr_store_` | **No** | Address of alloca escapes |
| `pointer_` of `get_element_ptr_*` | **No** | Aggregate indexing — not a scalar |
| `result_id_` of `get_element_ptr_*` | **No** | Derived pointer — address escapes |
| `pointer_` of `builtin_memset_` | **No** | Bulk aggregate operation |
| `pointer_` / `destination_` of `builtin_memcpy_` | **No** | Bulk aggregate operation |
| Call argument (as pointer) | **No** | Address escapes to callee |
| `condition_id_`, `operand_*_id_`, call argument (as scalar), `index_` in GEP-by-variable | N/A | These are load results, not the alloca itself. Handled by `ReplaceAllUses` |

**Current implementation**: Promotes allocas that only appear as `pointer_` in `load_` and `variable_store_`, have at least one `variable_store_`, and have zero `value_store_`. All other usage patterns result in the alloca staying on the stack.

### Step 1.2 — Build def-use chains per promotable alloca

For each promotable alloca with result_id `A`:
- Collect all **stores** to `A` (instructions where `pointer_ == A`): record `{block_id, instruction_index, stored_value_id_or_constant}`
- Collect all **loads** from `A` (instructions where `pointer_ == A`): record `{block_id, instruction_index, load_result_id}`

### Step 1.3 — Insert phi nodes at iterated dominance frontiers

For allocas with **multiple reaching definitions** across different blocks:
- Compute the **dominance frontier** for each basic block containing a store
- Use the standard SSA construction algorithm (Cytron et al.): iteratively place phi nodes at the dominance frontier of blocks that define the variable, until a fixed point
- Insert `phi_` IR instructions into those blocks (the IR already supports phi instructions — `IRBlock::AddPhi`)

### Step 1.4 — Rename uses

Walk the dominator tree, maintaining a stack of current reaching definitions for each promotable alloca:
- When visiting a store: push the stored value, continue
- When visiting a load: replace the load's uses with the current top-of-stack value
- When visiting a phi: the phi itself becomes the new definition for this block
- After visiting a block: pop definitions pushed in this block

### Step 1.5 — Cleanup

- Remove the promoted alloca from `alloca_instructions_`
- Remove the now-dead `load_` and `store_` instructions from their blocks
- The phi instructions inserted in step 1.3 remain — they are already handled by the existing `PhiToMove()` pass in codegen

**New file**: `IR/include/mem2reg.h`, `IR/src/mem2reg.cpp`  
**Integration point**: Called from `codegen_test.cpp` (and eventually `FrontEndRunner`) after IR generation, before `CodeGenerator` construction.

---

## Phase 2: Register Allocation (codegen-level)

**Where**: Inside `CodeGenerator`, after `MemAlloc()` but before instruction translation in `Generate()`.  
**Goal**: Assign RISC-V registers to IR variables that are still on the stack (including those not promoted by mem2reg), spilling only when necessary.

### Step 2.1 — Liveness analysis

For each function, compute live-in / live-out sets for each basic block:

- For each block, walk instructions **backwards**
- Initially: a variable is live-out if it is used in any successor block (or if it's live-in to a successor)
- `def`: an instruction's `result_id_` defines a variable
- `use`: an instruction's `operand_1_id_`, `operand_2_id_`, `condition_id_`, `pointer_`, etc. use variables
- Propagate: `live_in[B] = use[B] ∪ (live_out[B] − def[B])`, `live_out[B] = ∪_{S∈succ(B)} live_in[S]`
- Iterate to fixed point

### Step 2.2 — Build interference graph

Two variables **interfere** if they are simultaneously live at any program point:

- Within a block: a variable defined at instruction `i` interferes with all variables live at `i+1` (except itself if also a use at `i`)
- Across blocks: use live-in/live-out sets
- Also add interferences for pre-colored registers (a0-a7 for arguments, a0 for return value, sp/x2, ra/x1, etc.)

### Step 2.3 — Graph coloring allocation

**Available registers for allocation** (RISC-V 32):
- Caller-saved: t0-t2 (x5-x7), t3-t6 (x28-x31), a0-a7 (x10-x17) — total 16
- Callee-saved: s0-s11 (x8-x9, x18-x27) — total 12
- Reserved: x0 (zero), x1 (ra), x2 (sp), x3 (gp), x4 (tp)
- Total allocatable: 28 registers, but a0-a7 overlap with parameter passing so be conservative — start with ~20 general-purpose allocatable regs
- Registers already used for parameter passing in the current function are pre-colored

**Algorithm**: Chaitin-style graph coloring
1. Simplify: repeatedly pick a node with degree < k (where k = number of available registers) and push it onto a stack
2. If all nodes have degree ≥ k, pick a spill candidate (heuristic: lowest spill cost = variable with fewest uses/defs, or one that is not involved in loops), mark it for spilling, remove it, and continue
3. Select: pop nodes from the stack, assign each a color (register) different from its neighbors
4. For spill candidates: assign a stack slot

### Step 2.4 — Update location map and insert spill code

- Update `RISCVFunctionNode::location_[var_id]` to `{true, reg_id}` for variables assigned a register
- For spilled variables: `{false, stack_offset}` as before (reuse the existing stack allocation in `MemAlloc`, but move them to dedicated spill slots if needed)
- Insert load-before-use / store-after-def spill code around instructions that reference spilled variables

### Step 2.5 — Handle move instructions and block boundaries

- The existing `MoveInstruction` infrastructure (phi elimination via `AssignmentGraph`) already works with the `location_` map — after register allocation, `VariableAssignment()` will naturally prefer register-to-register moves when both src and dest are in registers
- At block boundaries: reconcile live-in expectations — if a variable is in different registers (or spilled) in predecessor vs successor, insert moves

**Modified file**: `codegen/include/code_generator.h`, `codegen/src/code_generator.cpp`  
**New file**: `codegen/include/register_allocator.h`, `codegen/src/register_allocator.cpp`

---

## Integration & Testing

### CMakeLists.txt changes

Add new source files:
- `IR/src/mem2reg.cpp` to `IR_tests` and `codegen_tests` targets
- `codegen/src/register_allocator.cpp` to `codegen_tests` target

### Testing strategy

- Existing `codegen_tests` runs all 50 comprehensive test cases through the full pipeline and diffs output — this is the primary correctness gate
- Add unit tests in `test/` for mem2reg in isolation (verify alloca elimination counts, phi insertion)
- The `run.sh` script can validate end-to-end with `reimu` simulator

### Execution order within a single run

```
Parse → Semantic → IR Generate
  → mem2reg (new: promote scalars, insert phis)
  → CodeGenerator::Generate()
    → PhiToMove()
    → MemAlloc()
    → Liveness analysis (new)
    → Register allocation (new: color + spill)
    → Instruction translation (existing, now respects location_ register assignments)
    → Output
```

---

## Risks & Simplifications

1. **mem2reg is IR-only**: It only promotes scalar allocas (int/bool/ptr). Arrays and structs stay on the stack — they need address access for field/element GEPs.
2. **No SSA deconstruction needed**: Phi nodes are already handled by `PhiToMove()` before codegen, so mem2reg can insert phi instructions freely.
3. **Block ordering**: The IR uses integer block IDs (labels). The dominance frontier computation needs a CFG — this is straightforward since each block ends with a branch/return.
4. **Conservative spill cost**: For a course compiler, a simple spill heuristic (spill the variable with the longest live range or fewest uses) is acceptable. No need for iterative spilling with rematerialization.
5. **Pre-colored registers must be respected**: a0 is used for return values, a0-a7 for call arguments. These constraints are already encoded in `GetParamPassPos()`.

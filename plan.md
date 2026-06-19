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

**Where**: Runs on `IRFunctionNode` after IR generation, before codegen.  
**Goal**: Promote scalar allocas (int, bool, ptr) into SSA variables by
eliminating their alloca/load/store and inserting phi instructions.

### What gets promoted

An alloca is promotable if its address never escapes — it is only
used as the `pointer_` of plain `load_`, `ptr_load_`,
`variable_store_`, `value_store_`, or `ptr_store_`.  Any other use
(GEP, memset, memcpy, passing to a call, or the alloca's result_id
appearing as a stored value) blocks promotion.

In practice this means loop counters, temporaries, and most local
scalars are promoted; arrays and structs stay on the stack.

### Algorithm overview

1. **Build CFG and compute dominators**  
   Every block's successors and the Lengauer-Tarjan dominator tree
   are built once per function.

2. **For each promotable alloca:**
   - Collect all stores (definitions) and loads (uses) to that alloca
     across all blocks.
   - **Place phi instructions** at the iterated dominance frontier of
     the definition blocks, so every path's reaching definition
     arrives at the correct merge point.
   - **Rename (SSA construction)**: walk the dominator tree
     depth-first.  When a store is seen, push its stored value onto
     a reaching-def stack; when a load is seen, record the stack top
     as its replacement.  Both the load and store are marked dead.
   - **Fill phi operands**: each phi's conditions are rebuilt from the
     block-exit reaching definitions of its predecessor blocks.
   - **Replace uses**: every old load result is replaced with its
     reaching definition (a variable, constant, or undef→0).
     Trivially constant binary ops and icmps are folded on the spot.

3. **Cleanup**: all promoted alloca instructions are removed, all
   dead loads/stores are dropped, and phis whose result is never
   referenced are iteratively pruned.

**Implementation**: `IR/include/mem2reg.h`, `IR/src/mem2reg.cpp`  
**Integration**: called from test harness (`codegen_test.cpp` /
`mem2reg_test.cpp`) right after IR generation and before
`CodeGenerator`.

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

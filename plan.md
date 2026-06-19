# Plan: mem2reg + Register Allocation

## Current State

The compiler pipeline is: `.rx` → Lexer → Parser → Semantic → IR → Codegen → RISC-V `.s`

**How variables work today:**
- IR generator emits `alloca` for every variable (params, let-bindings, loop vars, temporaries)
- All alloca'd slots live in `IRFunctionNode::alloca_instructions_`
- Codegen's `MemAlloc()` assigns every IR variable a **stack slot only** — `location_[var_id]` is always `{false, stack_offset}`, i.e. nothing ever lives in a register aside from scratch regs (x5/x6) and function parameters passed in a0-a7
- Every operation follows: load operands from stack → compute → store result to stack
- This works correctly but produces verbose, slow code

---

## Phase 1: mem2reg (IR-level promotion)

**Status: DONE.** Implemented in `IR/include/mem2reg.h`, `IR/src/mem2reg.cpp`.

### What got promoted

An alloca is promotable if its address never escapes — it is only
used as the `pointer_` of plain `load_`, `ptr_load_`,
`variable_store_`, `value_store_`, or `ptr_store_`. Any other use
(GEP, memset, memcpy, passing to a call, or the alloca's result_id
appearing as a stored value) blocks promotion.

In practice this means loop counters, temporaries, and most local
scalars are promoted; arrays and structs stay on the stack.

### Algorithm

1. **Build CFG and compute dominators** — Lengauer-Tarjan dominator tree per function.
2. **For each promotable alloca:** Place phi at iterated dominance frontier, rename via dominator-tree walk, fill phi operands, replace uses.
3. **Cleanup**: remove dead load/store/alloca, prune dead phis.

### Post-mem2reg IR state

After mem2reg, the IR contains two categories of variables:

| Category | Storage | Type | Examples |
|----------|---------|------|----------|
| **Stack-bound** (still alloca'd) | Must be on stack | arrays, structs, non-scalar temporaries | `[i32; 10]`, struct literals |
| **Virtual registers** (promoted / SSA temporaries) | Candidate for regalloc | int, bool, ptr | loop counters, icmp results, phi results, binary-op results |

The register allocator only allocates the second category. Stack-bound variables keep their `MemAlloc()`-assigned stack slots.

---

## Phase 2: Register Allocation (codegen-level)

**Where**: Inside `CodeGenerator`, after `PhiToMove()` and `MemAlloc()` (which still handles stack-bound variables) but before instruction translation in `Generate()`.

**New files**: `codegen/include/register_allocator.h`, `codegen/src/register_allocator.cpp`

### Step 1 — Liveness Analysis

For each function, compute `live_in` / `live_out` sets for every basic block.
These sets contain **variable IDs** (int) that represent virtual registers
from the IR (scalar temporaries and promoted alloca results).

**Data-flow equations** (backward problem):

```
live_out[B] = ⋃_{S ∈ succ[B]} live_in[S]
live_in[B]  = use[B] ∪ (live_out[B] − def[B])
```

Where for each IR instruction `I` in block `B`:

- **def(I)** = `I.result_id_` (if the instruction produces a result), for these instruction types:
  `two_var_binary_operation_`, `var_const_binary_operation_`, `const_var_binary_operation_`,
  `load_`, `ptr_load_`, `non_void_call_`, `get_element_ptr_by_value_`,
  `get_element_ptr_by_variable_`, `two_var_icmp_`, `var_const_icmp_`, `const_var_icmp_`,
  all `select_*` variants, `builtin_call_` (with result)

- **use(I)** = all variable IDs referenced as operands:
  - `operand_1_id_`, `operand_2_id_` (binary ops, icmp, select)
  - `condition_id_` (conditional_br, select)
  - `pointer_` (load, store, GEP, builtin_memset/memcpy)
  - `destination_` (builtin_memcpy)
  - `index_` (get_element_ptr_by_variable_)
  - `result_id_` in `variable_ret_`, `variable_store_`, `ptr_store_`
  - `function_call_arguments_[].value_` (when `is_variable_` is true)

**Algorithm**: Iterate to fixed point. Initialize all `live_in`/`live_out` to empty,
then repeatedly apply the data-flow equations until no set changes.
Use a worklist algorithm for efficiency: only revisit a block's predecessors
when its `live_in` changes.

**Special case — phi instructions**: Phi instructions live in `IRBlock::phi_instructions_`.
A phi `%r = phi [%v1, blockA], [%v2, blockB]` means:
- `%r` is defined at the start of the current block
- `%v1` is used at the end of blockA, `%v2` is used at the end of blockB
- Therefore: `%v1 ∈ live_out[blockA]`, `%v2 ∈ live_out[blockB]`, `%r ∈ def` of current block

### Step 2 — Build the Interference (Conflict) Graph

**Nodes**: Every virtual register (scalar-typed variable) that appears in any
`live_in` / `live_out` set, plus pre-colored physical registers.
Stack-bound variables (alloca'd arrays/structs) are excluded — they never live in registers.

**Interference definition**: Two variables **interfere** if they are simultaneously
live at any program point, OR if one is a pre-colored register that must not be
aliased.

**Construction algorithm**:

1. **Within each block** — walk instructions **backwards**.
   Maintain a `currently_live` set, initialized to `live_out[B]`.
   At instruction `i` (going backwards):
   - The result of instruction `i` (`def(i)`) interferes with every variable in
     `currently_live` (except itself if it is also a use at `i` — because a
     variable can be both def and use in the same instruction, e.g. `%1 = add %1, %2`).
   - Remove `def(i)` from `currently_live`, add `use(i)` to `currently_live`.

2. **Across blocks** — for each block B, every pair of variables in `live_in[B]`
   (or `live_out[B]`) can interfere if their live ranges overlap. The within-block
   analysis already handles this transitively, but explicit edge addition for
   `live_in`/`live_out` sets ensures correctness.

3. **Pre-colored registers** — add nodes for pre-colored physical registers:
   - `a0` (x10): return value register for non-void calls
   - `a0`–`a7` (x10–x17): argument registers for calls
   - `sp` (x2), `ra` (x1), `zero` (x0), `gp` (x3), `tp` (x4): reserved

   Pre-colored register nodes interfere with each other and with every virtual
   register whose live range spans a point where that physical register is
   reserved (e.g. a virtual register live across a call interferes with `a0`–`a7`
   because the call may clobber them).

4. **Move edges** — record move-related pairs (from `PhiToMove()` generating
   `MoveInstruction`s, and from phi instructions). These edges are NOT interferences;
   they are hints that two variables would benefit from sharing the same register.

**Data structure**:
```cpp
class InterferenceGraph {
  int node_count_;  // virtual registers + pre-colored
  std::vector<std::set<int>> adjacency_;  // interference edges
  std::vector<std::set<int>> move_edges_; // move-related edges (coalescing candidates)
  std::set<int> pre_colored_;  // nodes that are physical registers
  std::map<int, int> node_to_reg_; // for pre-colored: var_id -> physical reg
  std::set<int> stack_bound_; // variables that MUST stay on stack (excluded from graph)
};
```

### Step 3 — Graph Coloring (Chaitin-Briggs Algorithm)

**K = number of allocatable registers.**

Available RISC-V registers (32 total, 5 reserved):

| Regs | ABI | Type | Notes |
|------|-----|------|-------|
| x0 | zero | reserved | hardwired zero |
| x1 | ra | reserved | return address |
| x2 | sp | reserved | stack pointer |
| x3 | gp | reserved | global pointer |
| x4 | tp | reserved | thread pointer |
| x5–x7 | t0–t2 | caller-saved | scratch — codegen needs x5/x6 for spills/immediates |
| x8–x9 | s0–s1 | callee-saved | need save/restore in prologue/epilogue |
| x10–x17 | a0–a7 | caller-saved | args + return value; usable when not live across calls |
| x18–x27 | s2–s11 | callee-saved | need save/restore in prologue/epilogue |
| x28–x31 | t3–t6 | caller-saved | general purpose |

**Recommended K ≈ 20–24** — reserve x5/x6 as scratch for the codegen,
use the rest for allocation. Callee-saved registers (x8–x9, x18–x27) that are
actually used are saved/restored in the prologue/epilogue (infrastructure
already exists in `alloca_block_`).

The allocator tracks which callee-saved registers it actually uses and emits
save/restore only for those (currently the code always saves all 12 callee-saved
regs — this can be optimized).

**Main loop**:

```
worklist = { all virtual register nodes }
while (worklist not empty) {

  // ---- SIMPLIFY ----
  // Repeatedly remove nodes with degree < K and push them onto the stack.
  // These nodes will trivially get a color during the select phase.
  while (exists node in worklist with degree < K) {
    pick such a node n
    push n onto select_stack (marked "unspilled")
    remove n from graph (edges to/from n are removed, neighbor degrees decrease)
    remove n from worklist
  }

  if (worklist is empty) break;

  // ---- COALESCE ----
  // Try to combine move-related nodes to reduce the number of moves.
  // Only consider move edges where both ends are still in worklist.
  bool coalesced = false;
  for each move edge (u, v) where u, v ∈ worklist:
    if (BriggsTest(u, v) || GeorgeTest(u, v)):
      coalesce(u, v)   // merge v into u (or vice versa)
      coalesced = true
      break            // restart simplify

  if (coalesced) continue;

  // ---- FREEZE ----
  // If we cannot coalesce, pick a move-related node with degree < K
  // and "freeze" its move edges — give up on coalescing it, turning
  // move edges into regular interference edges so it becomes low-degree.
  bool froze = false;
  for each move-related node n in worklist:
    if (degree(n) < K):
      freeze all move edges incident to n
      // Move edges become interferences so n can be picked by simplify
      froze = true
      break

  if (froze) continue;

  // ---- SELECT SPILL ----
  // All remaining nodes have degree ≥ K and no more coalescing/freezing
  // is possible. Pick a spill candidate.
  n = selectSpillCandidate(worklist)
  push n onto select_stack (marked "spilled")
  remove n from graph
  remove n from worklist
}
```

#### Coalescing rules

**Briggs test** (conservative, safe): Coalesce `u` and `v` if the combined node
`uv` has fewer than K neighbors of **significant degree** (degree ≥ K).
If the combined node has < K high-degree neighbors, it will be simplifiable
after coalescing.

```
BriggsTest(u, v):
  combined_neighbors = neighbors(u) ∪ neighbors(v)
  significant_count = count of n ∈ combined_neighbors where degree(n) ≥ K
  return significant_count < K
```

**George test** (optimistic, based on one node's neighborhood): Coalesce `u` and `v`
if every neighbor `t` of `u` either already interferes with `v`, or has degree < K.
This works well when one of the nodes has very low degree.

```
GeorgeTest(u, v):  // coalesce u into v
  for each neighbor t of u:
    if t already interferes with v: continue     // OK
    if degree(t) < K: continue                   // t is simplifiable
    return false                                 // would block t
  return true
```

#### Spill heuristics

When forced to spill, pick the node that minimizes spill cost:

```
spill_cost(n) = (sum of use/def frequencies) / degree(n)
```

where "use/def frequency" weights each use/def of `n` by the loop nesting depth
(10^loop_depth — each loop level multiplies cost by 10, approximating iteration count).

A simpler alternative: pick the node with the lowest `use_count / degree(n)` ratio
— variables used infrequently but with high degree (interfering with many others)
are cheap to spill and free up many neighbors.

#### Select (color assignment)

Pop nodes from `select_stack` in reverse order:

```
while (select_stack not empty):
  n = pop(select_stack)
  if n is marked "spilled":
    // Try to color anyway — neighbors may have used fewer colors than K
    if a color is available for n:
      assign that color (register) to n
    else:
      mark n for actual spilling (assign stack slot)
  else:
    // Find the first color not used by any neighbor
    color = smallest c ∈ {0..K-1} not used by neighbor_colors
    assign color to n
```

Map colors to physical registers via a fixed color-to-register table
(e.g. color 0 → t0, color 1 → t1, ..., spilling into callee-saved regs
after caller-saved regs are exhausted).

### Step 4 — Update location map and spill code

After coloring, update `RISCVFunctionNode::location_[var_id]`:

- **Variables assigned a register**: `location_[var_id] = {true, phys_reg_number}`
- **Variables assigned a stack slot**: `location_[var_id] = {false, spill_slot_offset}`
  (spill slots are allocated from `stack_space_`, interleaved with existing
  alloca'd variables)

**Spill code insertion**: For each instruction that references a spilled variable:
- Before using a spilled variable: insert a load from its spill slot into a
  scratch register (x5 or x6)
- After defining a spilled variable: insert a store from the result register
  into its spill slot

This is simplified by the fact that the existing codegen already handles
the `location_` map correctly: `VariableAssignment()` and `ValueAssignment()`
already load from stack when `location_[id].first == false` and store to
stack when the destination is on the stack. So **no spill-code insertion pass
is needed** — the existing instruction-translation logic naturally handles it.

**What changes in `Generate()`**: After register allocation, many variables
now have `location_[id].first == true` with real register numbers (not just
a0-a7 for params). The existing `case two_var_binary_operation_:` etc. already
check `location_[id].first` and emit register-to-register operations when both
operands are in registers. The codegen automatically becomes more efficient.

### Step 5 — Coalesce-induced move elimination

After register allocation, variables that were coalesced share the same
physical register. Any `MoveInstruction` between coalesced variables becomes
a no-op (same register → same register) and can be deleted.

For move-related variables that were NOT coalesced but ended up with the
same color (by luck, during select), insert `mv rd, rs` instructions instead
of load-from-stack / store-to-stack.

The existing `PhiToMove()` infrastructure handles this:
- `VariableAssignment()` already emits `r_add_ rd, rs, x0` (equivalent to `mv`)
  when both src and dest are in registers.

### Step 6 — Optimize callee-saved register usage

After coloring, we know exactly which callee-saved registers are used.
Instead of unconditionally saving/restoring all 12 (x8–x9, x18–x27),
save/restore only those actually assigned by the allocator.

Track: `std::set<int> used_callee_saved_regs;`

In the `alloca_block_` prologue, save only `used_callee_saved_regs`.
In each return sequence, restore only `used_callee_saved_regs`.
Adjust `stack_space_` accordingly (currently hardcoded 112 = 28×4 bytes;
reduce to only the actually-needed save area).

---

## Integration & Execution Order

```
Parse → Semantic → IR Generate
  → mem2reg (already done: promote scalars, insert phis)
  → CodeGenerator::Generate()
    → PhiToMove()              (existing: phi → assignment graph → moves)
    → MemAlloc()               (modified: only handle stack-bound variables)
    → LivenessAnalysis()       (new)
    → BuildInterferenceGraph() (new)
    → GraphColoring()          (new: simplify/coalesce/freeze/spill/select)
    → UpdateLocationMap()      (new: write register/stack assignments)
    → Instruction translation  (existing: already respects location_ map)
    → Output()
```

### MemAlloc modifications

`MemAlloc()` currently assigns stack slots to ALL variables. After register
allocation, it should only assign stack slots to:

1. **Callee-saved register save area** (but sized after regalloc knows which
   callee-saved regs are actually used)
2. **Parameters that must be on the stack** (arrays, structs, or when a-registers
   are exhausted)
3. **Alloca'd variables that are NOT promotable** (arrays, structs — their `alloca_instructions_`
   entries that survived mem2reg)
4. **Temporaries with non-scalar types** (array/struct temporaries from GEP, select, etc.)

Scalar variables (int, bool, ptr) are left for the register allocator to handle.
If a scalar gets spilled, a spill slot is allocated from `stack_space_`.

Since `MemAlloc` currently also determines `stack_space_`, we need to split it:

```
MemAlloc(func_id):
  // Phase A: stack-bound allocation
  allocate_callee_save_area()        // may adjust later
  allocate_stack_params()
  allocate_non_promotable_allocas()
  allocate_non_scalar_temporaries()

  // Phase B (after regalloc):
  allocate_spill_slots_for_spilled_vars()
  finalize_stack_space()
```

---

## Data Structures (new file: `codegen/include/register_allocator.h`)

```cpp
class RegisterAllocator {
public:
  // Input: IR function, output: updated location_ map
  RegisterAllocator(const IRFunctionNode &ir_func,
                    RISCVFunctionNode &riscv_func,
                    const std::vector<IRStructNode> &ir_structs);

  void Run();  // main entry point

private:
  void ComputeLiveness();
  void BuildInterferenceGraph();

  // Chaitin-Briggs phases
  void Simplify();
  bool Coalesce();
  void Freeze();
  void SelectSpill();
  void AssignColors();

  // Helpers
  int  GetDegree(int node);
  bool BriggsTest(int u, int v);
  bool GeorgeTest(int u, int v);
  void CoalesceNodes(int u, int v);
  int  SelectSpillCandidate();
  void UpdateLocationMap();

  const IRFunctionNode &ir_func_;
  RISCVFunctionNode &riscv_func_;

  // CFG
  std::map<int, std::set<int>> successors_;
  std::map<int, std::set<int>> predecessors_;

  // Liveness
  std::map<int, std::set<int>> live_in_;   // block_id -> set of var_ids
  std::map<int, std::set<int>> live_out_;

  // Interference graph
  std::set<int> nodes_;                    // all virtual register var_ids
  std::map<int, std::set<int>> adj_;       // interference edges
  std::map<int, std::set<int>> move_edges_; // coalescing hints
  std::set<int> pre_colored_;              // physical register nodes

  // Worklists
  std::set<int> worklist_;                 // nodes not yet processed
  std::vector<int> select_stack_;          // nodes removed (in order)
  std::vector<bool> spilled_;              // per-node: was spilled?

  // Result
  std::map<int, int> color_;              // var_id -> color (physical reg or -1 for spill)
  std::map<int, int> spill_slot_;         // var_id -> stack offset for spilled vars

  // Available registers
  static constexpr int K = 20;            // number of allocatable registers
  std::vector<int> allocatable_regs_;     // physical register numbers

  // Registers reserved as scratch for codegen
  static constexpr int SCRATCH_REG_1 = 5;  // t0
  static constexpr int SCRATCH_REG_2 = 6;  // t1
};
```

---

## File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `codegen/include/register_allocator.h` | **New** | Register allocator class declaration |
| `codegen/src/register_allocator.cpp` | **New** | Register allocator implementation |
| `codegen/include/code_generator.h` | Modify | Add `RegisterAllocator` member/call |
| `codegen/src/code_generator.cpp` | Modify | Split `MemAlloc()`, call `RegisterAllocator::Run()` before translation |
| `CMakeLists.txt` | Modify | Add `register_allocator.cpp` to build |

---

## Testing Strategy

1. **Unit tests** — Add `register_allocator_test.cpp` that tests individual phases
   (liveness on simple functions, interference graph construction, coloring on
   known graphs) using Google Test.

2. **Existing `codegen_tests`** — The 50 comprehensive test cases are the primary
   correctness gate. Run `bash run.sh` to validate end-to-end correctness.

3. **Incremental validation** —
   - First, implement liveness without changing allocation: verify liveness
     sets are computed correctly (can print debug info).
   - Then, implement the full allocator with a high K (easy coloring): verify
     output is correct with all variables in registers.
   - Then, reduce K to exercise spill logic: verify correctness under spilling.

---

## Risks & Mitigations

1. **Phi-to-move interaction**: After mem2reg inserts phis and `PhiToMove()`
   converts them to `MoveInstruction`s, the register allocator must handle
   move edges correctly. These move instructions are already stored in
   `RISCVBlock::move_instructions_` before register allocation runs, so we
   can scan them during graph construction.

2. **Scratch register conflicts**: The codegen currently uses x5 and x6 as
   scratch for loading operands, computing addresses, etc. If x5/x6 are
   used as scratch, they must not be allocated to any variable whose live
   range spans a point where scratch registers are used. Since scratch usage
   is very short (load-compute-store within one instruction translation),
   and the scratch registers are "borrowed" only momentarily, we can simply
   reserve x5 and x6 from the allocatable pool (K excludes them).

3. **Caller-saved registers across calls**: Variables live across a call
   cannot reside in caller-saved registers (a0-a7, t0-t6) because the callee
   may clobber them. The existing code saves ALL caller-saved registers before
   each call. So caller-saved registers ARE safe to use — the save/restore
   around calls protects them. No special handling needed.

4. **a0 as return register**: The return value of a function must be in a0.
   For `variable_ret_` instructions, if the variable is in a register, we may
   need a `mv a0, reg` before the return. The existing `variable_ret_` handler
   does `r_addi_ a0, reg, 0` if the variable is in a register — this already works.

5. **Arrays and structs always on stack**: Variables with array or struct type
   are never considered for register allocation. The `MemAlloc()` assigns them
   stack slots as before. This is correct: GEP operations need memory addresses.

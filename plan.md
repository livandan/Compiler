# Compiler Optimization Plan

Ranked by significance × ease-of-achievement for **this compiler** specifically.
Each entry is tagged: **Impact** (code-size reduction), **Difficulty** (engineering effort),
and **Category** (where the change goes: codegen asm → register allocator → IR).

Key findings from current ASM output (comprehensive21: 13,102 lines, 117 calls):
- **1,756** a0-a7 save/restores (13.4% of file) — full spill around every call
- **2,647** `li t6,<large>` patterns (20.2%) — materializing large stack offsets
- **579** redundant `add x,y,x0` (4.4%) — should be `mv`
- **670** t-reg save/restores around calls

---

## Phase 1: Low-Hanging Fruit (High Impact / Low Difficulty)

### 1.1 Call-Save Consolidation — Deferred + Per-Register Lazy Save/Restore ✅ **DONE**
- **Impact**: ★★★★★ (13.4% of comprehensive21; 60%+ of per-call overhead eliminated)
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Assembly Code Generation (`code_generator.cpp`)
- **What**: Currently every `call` is wrapped in save-all/restore-all of a0-a7, t3-t5, ra.
  Instead: mark a-regs as "dirty" after a call, restore lazily on next use, flush remaining
  dirty regs only at block exits (branch/jump/return). Between back-to-back calls,
  skip the intermediate restore+save entirely.
- **Actual results**: Total asm −21.6% (365k→287k lines). comprehensive21 −40.0% (13.1k→7.9k).
  All 50 tests pass.
- **Reference**: optimize.md "Call-Save Consolidation" Phase 2-3

### 1.2 Peephole: Compare Instruction Optimization ✅ **DONE**
- **Impact**: ★★★☆☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation (`code_generator.cpp`)
- **What**: `==`/`!=` → `sub`+`sltiu`/`sltu` (2 insns instead of 3-4). `==0` → `sltiu` (1 insn).
  `!=0` → `sltu x0`. `==0`/`!=0` checks fire BEFORE `VariableToReg`.
- **Actual results**: `==0`/`!=0` comparisons reduced from 2 insns to 1 insn.
  `two_var_icmp_` `==`/`!=` uses `sub`+`sltiu`/`sltu` pattern. All 50 tests pass.
- **Reference**: optimize.md "Compare" + "Compare peephole ordering"

### 1.3 Peephole: Immediate Folding in Arithmetic ✅ **DONE**
- **Impact**: ★★★★☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation (`code_generator.cpp`)
- **What**: When one operand of `+`/`-`/`&`/`|`/`^` fits in 12-bit signed immediate,
  fold into `addi`/`andi`/`ori`/`xori` instead of `li`+`op`. Commutative `+` also
  folds `c + x` when constant is operand1.
- **Actual results**: `var_const` ops (`add`/`sub`/`and`/`or`/`xor`/`shl`/`ashr`) and
  commutative `const_var` ops (`add`/`and`/`or`/`xor`) fold constants directly into
  I-type instructions when they fit in 12 bits. All 50 tests pass.
- **Reference**: optimize.md "Immediate folding" + "Commutative operand1"

### 1.4 Redundant Jump Elimination ✅ **DONE**
- **Impact**: ★★☆☆☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation (`code_generator.cpp`)
- **What**: Elide `j` to immediately-following block. For branches where one target is the
  fall-through block, skip the trailing `j` or invert to `beqz`/`bnez` for fall-through.
- **Actual results**: Unconditional jumps to the next block are skipped. Conditional branches
  use direct `beqz`/`bnez` when one target is the fall-through, saving one jump per
  applicable branch. All 50 tests pass.
- **Reference**: optimize.md "Redundant Jump Elimination" + "Branch Codegen Simplification"

---

## Phase 2: Register Allocator Upgrades (High Impact / Medium Difficulty)

### 2.1 Color Pool Expansion — Add a0-a7 to Allocatable Pool
- **Impact**: ★★★★☆ (doubles register pool from 12 to 19+)
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Register Allocator (`register_allocator.cpp`)
- **What**: Currently only s0-s11 are available for coloring. Add a0-a7 with proper
  precolored-interference modeling for function parameters. Far fewer spills to stack.
- **Reference**: optimize.md "Color Pool Expansion"

### 2.2 Leaf Function Optimization Bundle
- **Impact**: ★★★☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: Register Allocator + Stack Frame
- **What**: (a) Detect leaf functions (no calls, including builtin_memcpy/memset).
  (b) Skip call-save area entirely. (c) Prefer t5 + unused a-regs over s-regs →
  zero s-reg save/restore. (d) Tightened save area: `8 + 8×a_reg_used_cnt` instead of 72.
- **Reference**: optimize.md "Leaf Function Frame Elimination" + "Leaf Function Register Preference" + "Tightened Save Area"

### 2.3 Packed Save Area
- **Impact**: ★★★☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: Stack Frame
- **What**: Remove t-reg slots from save area, pack a-regs + ra at offsets 8-72 instead
  of scattered 8-120. Frame size −48 bytes per non-leaf function.
- **Reference**: optimize.md "Packed Save Area"

---

## Phase 3: Move & Store Elimination (Medium Impact / Medium Difficulty)

### 3.1 Briggs Conservative Move Coalescing
- **Impact**: ★★★☆☆ (comprehensive21: 579 redundant moves)
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Register Allocator
- **What**: Before coloring, merge move-related virtual register pairs if they don't
  interfere AND merged node has degree < K. Eliminates `mv` instructions directly.
- **Reference**: optimize.md "Briggs Conservative Move Coalescing"

### 3.2 Deferred kMemory Stores
- **Impact**: ★★★☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: Assembly Code Generation
- **What**: Defer `sd` for `RegToVariable(kMemory, ...)`. If `VariableToReg` later requests
  the same address, reuse the register directly (skip the `ld`). Flush before any
  instruction overwrites the register. Eliminates store-then-immediate-reload patterns.
- **Reference**: optimize.md "Deferred kMemory Stores"

### 3.3 Call Result Direct Use
- **Impact**: ★★☆☆☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation
- **What**: After a call, a0 holds the return value. Use a0 directly in `RegToVariable`
  instead of `mv` to a temp first. Saves ~1 `mv` per non-void call.
- **Reference**: optimize.md "Call Result Direct Use"

---

## Phase 4: Constant & Offset Optimization (Medium-High Impact / Medium Difficulty)

### 4.1 Constant Cache for Large Immediates (t3/t4)
- **Impact**: ★★★★☆ (comprehensive21: 2,647 `li t6,<large>` = 20.2% of file)
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Assembly Code Generation
- **What**: Pre-scan each function for >12-bit constants by frequency. Load top 2 into
  t3/t4 at function entry. All stack-offset address computations check the cache first,
  turning `li t6, 1003080; add t6, sp, t6; sd ra, 0(t6)` into `add t6, sp, t3; sd ra, 0(t6)`.
  Cached immediates survive calls via `li` reload. Scan includes IR operands AND stack offsets.
- **Est. savings**: comprehensive21: ~2,500 `li t6` eliminated → −19%
- **Reference**: optimize.md "Constant Cache (t3/t4)"

### 4.2 Peephole: Power-of-2 Strength Reduction
- **Impact**: ★★☆☆☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation
- **What**: `li+mulw` → `slliw`, `li+divuw` → `srliw`, `li+remuw` → `andi`,
  GEP with power-of-2 elem_size → `slli` instead of `li+mul`.
- **Reference**: optimize.md "GEP with power-of-2" + "Power-of-2 strength reduction"

### 4.3 Peephole: Constant Negation Folding
- **Impact**: ★☆☆☆☆
- **Difficulty**: ★☆☆☆☆ (Very Low)
- **Category**: Assembly Code Generation
- **What**: `li N; neg rd, rs` → single `li rd, -N`.
- **Reference**: optimize.md "Constant negation"

### 4.4 GEP Chain Folding
- **Impact**: ★★★☆☆
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Assembly Code Generation (post-RA peephole on RISC-V instructions)
- **What**: Walk backward from true terminals through single-use GEP intermediates,
  collapsing chains like `addi rd, base, 8; addi rd, rd, 8` → `addi rd, base, 16`.
  Zero-offset GEP(const 0) → `mv rd, ptrval`.
- **Reference**: optimize.md "GEP Chain Folding"

---

## Phase 5: Control Flow Optimizations (Lower Impact / Low Difficulty)

### 5.1 Block Layout Reordering (DFS-based)
- **Impact**: ★★☆☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: Assembly Code Generation
- **What**: DFS-based ordering: place jump-target next; for branches, prefer false-target
  fall-through (so `bnez`/`beqz` takes the common path). Eliminates unnecessary `j`.
- **Reference**: optimize.md "Block Layout Reordering"

### 5.2 Empty Block Elimination + next_block_map_
- **Impact**: ★★☆☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: Assembly Code Generation
- **What**: Skip empty blocks when computing fall-through targets. Eliminate truly empty
  blocks, thread jump chains, merge phi-only blocks.
- **Reference**: optimize.md "Empty Block Elimination" + "Empty Block Awareness"

---

## Phase 6: IR-Level Optimizations (High Impact / High Difficulty)

These require significant infrastructure (SSA construction, dominator analysis,
IR transformation passes). Listed in order of increasing difficulty.

### 6.1 Array Repeat Initialization with Loop Blocks
- **Impact**: ★★★☆☆
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: IR Generation (`IR/`)
- **What**: Replace unrolled `[val; N]` array init with a compact 4-block loop
  (header/body/end). O(N)→O(1) IR instructions for initialization.
- **Reference**: optimize.md "Array Repeat Initialization"

### 6.2 Running Pointer Strength Reduction (inside loops)
- **Impact**: ★★★☆☆
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: IR Generation
- **What**: Replace `GEP(base, idx, elem_size)` in array-init loops with running pointer
  chain (`ptr += elem_size`). Eliminates `li+mul+add` per iteration.
- **Reference**: optimize.md "Running pointer strength reduction"

### 6.3 Branch Condition Optimization
- **Impact**: ★★☆☆☆
- **Difficulty**: ★★☆☆☆ (Low-Medium)
- **Category**: IR Generation
- **What**: When comparison/lazy-boolean is used as `if`/`while` condition, emit branch
  on comparison result directly instead of storing to memory then loading back.
  Uses a `BranchContext` carrying true/false labels through expression handlers.
- **Reference**: optimize.md "Branch Condition Optimization"

### 6.4 RVO and Direct-Write for Struct/Array Literals
- **Impact**: ★★☆☆☆ (struct/array-heavy programs only)
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: IR Generation
- **What**: `let` RHS struct/array literal → write directly into target instead of
  temp+memcpy. Return struct/array → skip memcpy when expression already targets
  the return buffer pointer.
- **Reference**: optimize.md "RVO and Direct-Write for Struct/Array Literals"

### 6.5 Function Inlining
- **Impact**: ★★★★☆
- **Difficulty**: ★★★★☆ (High)
- **Category**: IR Optimization Pass
- **What**: Inline small functions (< 50 IR instructions) at call sites. Clones callee
  blocks, renames locals, redirects allocas to caller's entry block, splits blocks at
  call sites, rewrites returns as jumps to continuation blocks.
- **Reference**: optimize.md "Function Inlining"

### 6.6 SCCP (Sparse Conditional Constant Propagation)
- **Impact**: ★★★☆☆ (folds constants, removes unreachable code)
- **Difficulty**: ★★★★★ (Very High — requires SSA form with phi nodes)
- **Category**: IR Optimization Pass
- **What**: Wegman-Zadeck SCCP on SSA-form IR. Tracks constant lattice values per variable
  and executability per block. Folds constant arithmetic/compare/select, converts
  constant-condition branches to unconditional jumps.
- **Reference**: optimize.md "SCCP"

### 6.7 mem2reg (Memory to Register Promotion via SSA)
- **Impact**: ★★★★★ (Transformative — all stack allocas become SSA registers)
- **Difficulty**: ★★★★★ (Very High — full SSA construction pipeline)
- **Category**: IR Optimization Pass
- **What**: Promote allocas (only accessed via load/store) to SSA registers. Requires:
  dominator tree + dominance frontiers, phi insertion at iterated dominance frontiers,
  variable renaming in dominator-tree order, load/store→register replacement.
  This is the single most transformative IR optimization — it converts memory traffic
  into SSA registers, enabling all subsequent SSA-based passes.
- **Reference**: optimize.md "Liveness Analysis & SSA Construction Performance"
  (reference compiler already had mem2reg; performance section describes refinements)

### 6.8 Deferred Stack Address Assignment (Post-RA)
- **Impact**: ★★★☆☆
- **Difficulty**: ★★★☆☆ (Medium)
- **Category**: Stack Frame (codegen)
- **What**: Record alloca sizes without assigning addresses during IR→codegen. After
  register allocation promotes scalars to registers, only remaining kMemory variables
  receive contiguous stack addresses. Promoted variables never occupy stack space.
- **Reference**: optimize.md "Deferred Stack Address Assignment"

---

## Summary: Recommended Execution Order

| # | Optimization | Impact | Difficulty | Est. Savings (comprehensive21) |
|---|-------------|--------|-----------|-------------------------------|
| 1.1 | Call-Save Lazy Deferral | ★★★★★ | ★★★☆☆ | 13-18% |
| 1.2 | Compare Peephole | ★★★☆☆ | ★☆☆☆☆ | 1-2% |
| 1.3 | Immediate Folding | ★★★★☆ | ★☆☆☆☆ | 3-5% |
| 1.4 | Redundant Jump Elim | ★★☆☆☆ | ★☆☆☆☆ | 0.5-1% |
| 2.1 | Color Pool (a0-a7) | ★★★★☆ | ★★★☆☆ | 5-10% |
| 2.2 | Leaf Func Opt Bundle | ★★★☆☆ | ★★☆☆☆ | 2-5% |
| 2.3 | Packed Save Area | ★★★☆☆ | ★★☆☆☆ | 1-2% |
| 3.1 | Move Coalescing | ★★★☆☆ | ★★★☆☆ | 3-5% |
| 3.2 | Deferred kMemory | ★★★☆☆ | ★★☆☆☆ | 1-3% |
| 3.3 | Call Result Direct Use | ★★☆☆☆ | ★☆☆☆☆ | 0.5% |
| 4.1 | Constant Cache (t3/t4) | ★★★★☆ | ★★★☆☆ | 10-19% |
| 4.2 | Pow2 Strength Reduction | ★★☆☆☆ | ★☆☆☆☆ | 0.5-1% |
| 4.3 | Constant Negation | ★☆☆☆☆ | ★☆☆☆☆ | <0.5% |
| 4.4 | GEP Chain Folding | ★★★☆☆ | ★★★☆☆ | 2-5% |
| 5.1 | Block Layout | ★★☆☆☆ | ★★☆☆☆ | 1-2% |
| 5.2 | Empty Block Elim | ★★☆☆☆ | ★★☆☆☆ | 0.5-1% |
| 6.1 | Array Loop Init | ★★★☆☆ | ★★★☆☆ | varies |
| 6.2 | Pointer Strength Red. | ★★★☆☆ | ★★★☆☆ | varies |
| 6.3 | Branch Condition Opt | ★★☆☆☆ | ★★☆☆☆ | 0.5-1% |
| 6.4 | RVO / Direct-Write | ★★☆☆☆ | ★★★☆☆ | varies |
| 6.5 | Function Inlining | ★★★★☆ | ★★★★☆ | 5-15% |
| 6.6 | SCCP | ★★★☆☆ | ★★★★★ | 3-8% |
| 6.7 | mem2reg / SSA | ★★★★★ | ★★★★★ | 20-40% |
| 6.8 | Deferred Stack Addr | ★★★☆☆ | ★★★☆☆ | 3-5% |

### Key Takeaways:

1. **Do Phase 1 immediately** — pure codegen changes with outsized payback.
   Phase 1.1 alone could reduce comprehensive21 from 13k to ~11k lines.

2. **Phase 2-3 are the sweet spot** — moderate engineering for major gain.
   Together they could bring comprehensive21 under 9k lines.

3. **Phase 4.1 (constant cache) is the next high-leverage item** — 20% of comprehensive21
   is `li t6,<large>` for stack offset materialization. A 2-register cache cuts this in half.

4. **Phase 5 is polish** — small wins individually, zero-risk to implement.

5. **Phase 6 items are semester-project-scale** — especially mem2reg (6.7) requires
   building a full SSA construction pipeline (dominance frontiers, phi placement,
   renaming). But it's also the most transformative single optimization in any compiler.

### Estimated cumulative reduction path (comprehensive21: 13,102 lines):
- After Phase 1: ~10,500 (−20%)
- After Phase 2-3: ~8,000 (−24%)
- After Phase 4: ~6,500 (−19%)
- After Phase 5: ~6,200 (−5%)
- After Phase 6.1-6.4: ~5,500 (−11%)
- After Phase 6.5 (inlining): ~4,700 (−15%)
- After Phase 6.6-6.7 (SCCP + mem2reg): potentially ~3,000-4,000 (transformative)

Final estimate: a 3-4× code size reduction is achievable if all phases are completed.

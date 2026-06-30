# Speed Up `opti_dp_suite`

This note records the comparison between the current compiler output for
`RCompiler-Testcases/hidden_case/opti_dp_suite.rx` and the expected efficient
assembly in `RCompiler-Testcases/hidden_case/opti_dp_suite_optimized.s`.

## Function Mapping

The current compiler emits anonymous function names:

| Current | Source function |
| --- | --- |
| `fn.4` | `pm_rand_update` |
| `fn.2` | `norm` |
| `fn.3` | `run_grid_dp` |
| `fn.1` | `run_knapsack` |

The expected assembly uses:

| Expected | Source function |
| --- | --- |
| `function..pm_rand_update.1` | `pm_rand_update` |
| `function..norm.1` | `norm` |
| `function..run_grid_dp.1` | `run_grid_dp` |
| `function..run_knapsack.1` | `run_knapsack` |

## Measurements

Fresh current assembly was generated at:

```text
/tmp/rcompiler-dp-current/opti_dp_suite_current.s
```

The expected file includes the builtin runtime prelude. Excluding that prelude,
the compiler-emitted sections compare as follows:

| Function | Current instructions | Expected instructions | Main gap |
| --- | ---: | ---: | --- |
| `run_grid_dp` | 327 | 250 | Much more stack traffic and phi/copy noise |
| `run_knapsack` | 166 | 169 | Similar size, but current still has extra local stack spills |
| total compiled code | 593 | 527 | Current is about 13% larger |

The biggest problem is `run_grid_dp`:

| Function | Version | `lw` | `sw` | `ld` | `sd` |
| --- | --- | ---: | ---: | ---: | ---: |
| `run_grid_dp` | current | 31 | 22 | 54 | 45 |
| `run_grid_dp` | expected | 8 | 3 | 45 | 43 |

The arrays must live in stack memory, but the current output also materializes
too many scalar temporaries, GEP pointer temporaries, and trivial copy/select
values to stack.

### Recheck After Step 3

After the copy-propagation cleanup was added, regenerate the testcase with:

```text
cmake --build cmake-build-debug --target code -j 4
env LSAN_OPTIONS=detect_leaks=0 ./cmake-build-debug/code \
  < RCompiler-Testcases/hidden_case/opti_dp_suite.rx
```

The generated assembly is:

```text
RCompiler-Testcases/working_space/debugging_my.s
```

Static counts now look better than the original baseline:

| Function | Current instructions | Expected instructions | Main remaining gap |
| --- | ---: | ---: | --- |
| `run_grid_dp` | 308 | 250 | Hot scalar `lw`/`sw` traffic in inner loops |
| `run_knapsack` | 158 | 169 | Fewer instructions, but still extra scalar `lw`/`sw` |
| helpers + main | 96 | 108 | Similar |
| total compiled code | 562 | 527 | Current is only about 7% larger statically |

`run_grid_dp` is still the runtime bottleneck:

| Function | Version | `lw` | `sw` | `ld` | `sd` | `call` | `remw` |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `run_grid_dp` | current | 24 | 17 | 50 | 41 | 4 | 9 |
| `run_grid_dp` | expected | 8 | 3 | 45 | 43 | 6 | 7 |
| `run_knapsack` | current | 9 | 5 | 22 | 17 | 3 | 7 |
| `run_knapsack` | expected | 4 | 1 | 32 | 27 | 5 | 5 |

Important conclusion: the bare-metal 2x slowdown is not explained by total
static instruction count anymore. The remaining problem is dynamic cost in hot
loops: scalar stack slots are loaded/stored repeatedly inside the `j` loop, and
call boundaries still save/restore values that should either live in
callee-saved registers or be cheaper to rematerialize.

Representative current `run_grid_dp` stack slots:

```text
340(sp): clamped width, reloaded for loop tests
344(sp): `diag` temporary
352(sp): row bias (`rng % 97`), loaded in every inner iteration
360(sp): copy-loop scalar temporary
372(sp): normalized `cur[j]` value
376(sp), 380(sp): norm temporaries around setup/return
```

Representative hot patterns still visible:

```asm
remw    s0, s1, t1
sw      s0, 372(sp)
...
lw      t1, 372(sp)
sw      t1, 0(s3)
```

and:

```asm
lw      t0, 336(sp)
...
sw      s0, 336(sp)
```

The optimized assembly keeps most of these scalar values in registers and uses
stack memory primarily for the two arrays and call-save slots.

## Root Causes

### 1. Trivial Selects Survive Into Codegen (Fixed)

The post-mem2reg IR contains many copies encoded as selects:

```llvm
%var.56 = select i1 true, i32 %var.150, i32 %var.150
%var.88 = select i1 true, i32 %var.154, i32 %var.154
%var.96 = select i1 true, i32 %var.156, i32 %var.156
```

These appeared in the generated IR at:

```text
/tmp/rcompiler-dp-ir/RCompiler-Testcases/working_space/debugging.ll
```

Representative lines:

```text
126: %var.56 = select i1 true, i32 %var.150, i32 %var.150
142: %var.88 = select i1 true, i32 %var.154, i32 %var.154
156: %var.96 = select i1 true, i32 %var.156, i32 %var.156
292: %var.91 = select i1 true, i32 %var.90, i32 %var.90
306: %var.106 = select i1 true, i32 %var.105, i32 %var.105
343: %var.159 = select i1 true, i32 %var.233, i32 %var.233
356: %var.121 = select i1 true, i32 %var.237, i32 %var.237
377: %var.133 = select i1 true, i32 %var.244, i32 %var.244
```

Main source anchors:

```text
IR/src/IR_generator.cpp:1460
IR/src/IR_generator.cpp:1468
IR/src/IR_generator.cpp:2086
IR/src/IR_generator.cpp:2091
IR/src/IR_generator.cpp:2484
```

These select-as-copy instructions increase register pressure and create extra
stack slots after register allocation.

Status after Step 3: current-source post-mem2reg IR for `opti_dp_suite` no
longer contains the `select i1 true, X, X` copy pattern. This was necessary, but
it did not remove the bare-metal runtime gap by itself.

### 2. Inlining Emits Copies For Returned Values (Mostly Hidden By Step 3)

`OptimizeShortFunctions()` inlines small helpers, including `norm`, but uses
`AddSelect(...)` to copy the callee return into the caller result:

```text
IR/src/IR_generator.cpp:1457-1472
```

After inlining, those artificial copies become normal SSA values. Later passes
do not always eliminate them, so they show up in hot loops.

### 3. Hot Scalar Values Still Spill

After Step 3, the visible issue moved from IR copy values to backend register
allocation. `run_grid_dp` still spills loop-carried scalars and single-use
temporary values in hot loops. Examples include row bias, `norm` results,
`diag`, copy-loop values, and width/index values.

This is worse on bare metal than the static instruction count suggests:

- every extra `lw`/`sw` in the `h * w * rounds` loop is paid many times;
- stack traffic competes with array loads/stores;
- saved caller registers increase pressure around `pm_rand_update`;
- the optimized assembly has a similar amount of `ld`/`sd` call traffic, but
  far fewer integer scalar `lw`/`sw` operations in the hot loops.

### 4. Call-Crossing Values Are Not Weighted Strongly Enough

`run_grid_dp` calls `pm_rand_update` inside nested loops. Current code saves and
restores a broad set around the hot call sites, for example:

```asm
sd      ra, 128(sp)
sd      a0, 136(sp)
sd      a1, 144(sp)
sd      a3, 160(sp)
sd      a6, 184(sp)
sd      a7, 192(sp)
sd      t3, 200(sp)
sd      t4, 208(sp)
sd      t5, 216(sp)
call    fn.4
...
ld      t5, 216(sp)
```

Some save/restore is unavoidable, but the allocator should avoid putting hot
loop-carried values in caller-saved registers when they are live across calls.
Those values should either use callee-saved registers or, if cold, be selected
as spill candidates before hotter inner-loop values.

### 5. Spill Costs Are Not Loop Weighted Enough

Current spill cost is mostly use-count based:

```text
codegen/src/register_allocator.cpp:452
```

For this testcase, an inner-loop use is much more important than a setup/exit
use. Without loop-depth and call-crossing weighting, hot values can still lose
registers to colder values.

### 6. GEP Pointer Temporaries Are Secondary Now

GEP results are classified as allocatable pointer values:

```text
codegen/src/register_allocator.cpp:386-391
```

However, when register allocation does not keep a GEP result in a register,
codegen stores the computed address to stack:

```text
codegen/src/code_generator.cpp:3020-3072
```

This is expensive in array-heavy inner loops like `run_grid_dp`.

The recheck shows GEP is no longer the first thing to attack: current and
expected both reload array base pointers in several places, while the biggest
remaining delta is scalar `lw`/`sw` count. GEP lowering is still useful, but it
should come after call/loop-aware spill decisions and scalar store-forwarding.

Relevant codegen pipeline:

```text
codegen/src/code_generator.cpp:1974-2018
codegen/src/code_generator.cpp:1202-1265
```

## Bridge Plan

### Step 1: Delete Trivial Selects Before Codegen

Add an IR cleanup pass after inlining and mem2reg cleanup that replaces:

```llvm
%dst = select i1 true, T %x, T %x
```

with:

```text
replace all uses of %dst with %x
delete the select
```

Also handle constant copies:

```llvm
%dst = select i1 true, T 0, T 0
```

This should remove many stack slots such as the current `348(sp)`, `360(sp)`,
`404(sp)` style scalar temporaries in `run_grid_dp`.

Expected impact:

- Fewer IR values before codegen.
- Less register pressure.
- Fewer `sw`/`lw` pairs in hot loops.

### Step 2: Prefer Direct Return Remapping In The Inliner

In `OptimizeShortFunctions()`, avoid creating select-as-copy instructions for
simple scalar returns when a direct remap is enough.

For variable returns:

```text
call result id -> mapped returned var id
```

instead of:

```text
call result id = select true, mapped returned var, mapped returned var
```

If direct remapping is too invasive for all cases, keep the existing inliner and
rely on Step 1 copy propagation. Direct remapping is still the cleaner long-term
shape.

### Step 3: Strengthen Copy Propagation Around Phi Inputs

After trivial-select deletion, run copy propagation through:

- phi operands
- branch conditions
- return values
- call arguments
- load/store pointers
- GEP bases and indexes

This is important because loop-carried phis can preserve artificial copy values
even after their defining select is removed.

### Step 4: Add Loop- And Call-Weighted Spill Costs

Compute natural-loop depth from the CFG in `RegisterAllocator`:

1. Build predecessors and successors.
2. Identify backedges using dominator information, or conservatively detect
   edges to earlier block layout positions if dominators are not available yet.
3. Assign each block a loop depth.
4. Weight spill-cost additions by:

```text
block_weight = 1 + loop_depth
```

Apply this in `ComputeSpillCosts()`.

Implementation notes from landing Step 4:

- DFS-based backedge detection (gray ancestor) plus the textbook reverse-flow
  natural-loop body walk is enough; the function CFG is small.
- `block_weight = 1 + depth` was the right multiplier.  Larger weights
  (`1 + 4*depth`) push more values into callee-saved s-regs and create more
  parallel-phi-move cycles, which the backend resolves with extra `sw/lw`
  pairs on the stack — net worse for `run_grid_dp`.
- A separate "values live across a call get a callee-saved bonus" pass was
  tried (per-instruction liveness reconstruction, mark-and-prefer in
  `AssignColors`).  It increased s-reg usage but also increased phi-cycle
  stack traffic, so it was removed.  The loop-depth multiplier on the existing
  use/def weighting is enough for the metric gain in this testcase.
- `ComputeLiveness` was reordered before `ComputeSpillCosts` so future passes
  can use per-instruction liveness; current implementation does not.

Result on `run_grid_dp`:

| Metric | Pre-Step-4 | Post-Step-4 | Expected |
| --- | ---: | ---: | ---: |
| `lw` | 31 | 25 | 8 |
| `sw` | 21 | 19 | 3 |
| `ld` | 48 | 49 | 45 |
| `sd` | 39 | 40 | 43 |

`run_knapsack` is unchanged.  The remaining gap is dominated by per-iteration
scalar `lw`/`sw` of normalized values, row bias, copy-loop temporaries, and
loop-bound `w`.  Step 5 (store-load forwarding on scalar stack slots) and
Step 6 (short-lived GEP addresses) remain the next levers.

### Step 5: Store-Load Forward Scalar Stack Slots

Before attacking all GEPs, add a local backend peephole for scalar stack slots:

```asm
sw      rA, offset(sp)
lw      rB, offset(sp)
```

with no intervening write/call/unknown memory clobber to that slot should become:

```asm
mv      rB, rA
```

and if `rB` is only used as the source of the next store:

```asm
sw      rA, offset(sp)
lw      rB, offset(sp)
sw      rB, 0(ptr)
```

can become:

```asm
sw      rA, offset(sp)       # only if later uses still need the stack home
sw      rA, 0(ptr)
```

If the stack home has no later reads, delete the first `sw` too.

This directly targets current hot patterns such as:

```asm
sw      s0, 372(sp)
lw      t1, 372(sp)
sw      t1, 0(s3)
```

and:

```asm
sw      t0, 376(sp)
lw      t1, 376(sp)
sw      t1, 0(s11)
```

Safety rules:

- Only handle fixed `offset(sp)` slots.
- Stop forwarding across `call`, `jal`, `jalr`, unknown stores, or another write
  to the same stack slot.
- Do not cross labels until block-local correctness is proven.
- Preserve stores to true alloca-backed arrays; this pass is for scalar spill
  slots only.

### Step 6: Improve GEP Lowering For Short-Lived Addresses

For a pattern like:

```llvm
%ptr = getelementptr ..., %base, %idx
%val = load i32, ptr %ptr
```

or:

```llvm
%ptr = getelementptr ..., %base, %idx
store i32 %val, ptr %ptr
```

avoid forcing `%ptr` to have a stack home if it is used once in the same block.
Lower the GEP address directly into the load/store sequence.

This can be implemented as a local codegen peephole or as an IR-level flag/use
analysis before codegen.

Expected impact:

- Fewer spilled 8-byte pointer temporaries.
- Fewer `sd`/`ld` pairs around array accesses.

### Step 7: Kill Dead Phi Cycles In `Mem2Reg::RemoveDeadPhis()`

After Steps 1–6 the remaining bare-metal gap is **call-site `sd`/`ld` traffic**
in the inner `j` loop of `run_grid_dp`. The static `lw`/`sw` numbers are now
close to the optimized target (`lw=6`, `sw=3` vs target `8`/`3`), but `ld`/`sd`
are still inflated: `ld=61`, `sd=52` against the optimized `ld=45`, `sd=43`.
Per inner iteration that is **two extra `sd`/`ld` pairs around `pm_rand_update`
and `norm`**, which dominates the dynamic instruction mix because the inner
loop runs `h * w * rounds` times.

#### Root Cause: Mem2Reg Leaves Pure Phi Cycles Alive

Look at `var.177`, `var.180`, `var.183`, `var.186`, `var.190`, `var.193` at
`label_24` in the post-mem2reg IR for `run_grid_dp`:

```text
RCompiler-Testcases/working_space/debugging.ll:150
```

```llvm
%var.177 = phi i32 [ 0, %label_15 ], [ %var.176, %label_52 ]
%var.180 = phi i32 [ 0, %label_15 ], [ %var.179, %label_52 ]
%var.183 = phi i32 [ 0, %label_15 ], [ %var.182, %label_52 ]
%var.186 = phi i32 [ 0, %label_15 ], [ %var.185, %label_52 ]
%var.190 = phi i32 [ 0, %label_15 ], [ %var.189, %label_52 ]
%var.193 = phi i32 [ 0, %label_15 ], [ %var.192, %label_52 ]
```

These are paired at `label_50` and `label_61`:

```llvm
%var.176 = phi i32 [ %var.177, %label_33 ], [ %var.60,  %label_138 ]
%var.179 = phi i32 [ %var.180, %label_33 ], [ %var.178, %label_138 ]
%var.182 = phi i32 [ %var.183, %label_33 ], [ %var.181, %label_138 ]
...
%var.178 = phi i32 [ %var.179, %label_51 ], [ %var.76,  %label_99 ]
%var.181 = phi i32 [ %var.182, %label_51 ], [ %var.80,  %label_99 ]
...
```

They are phi nodes mem2reg inserted for **block-scoped locals** (`row_bias`,
`weight`, `up`, `left`, `diag`, the normalized `cur[j]`). The alloca is at
function scope, so mem2reg dominance-frontier insertion places phis at every
outer merge point — even though the value is defined-before-use on every
dynamic path that actually reads it.

Each of these phis is **referenced only by other phis**. They form closed
phi-only cycles. No regular instruction consumes them. They should be deleted.

#### Why The Current `RemoveDeadPhis()` Misses Them

```text
IR/src/mem2reg.cpp:1248
```

The existing algorithm seeds `alive_phis` with *all* phis and removes one only
if **no alive phi references it** in `phi_refs_from_phis`. For a cycle
`A → B → A` both A and B are initially alive, each references the other, so
neither ever gets killed. Classic dead-cycle-of-phis correctness bug in a
"backward retire" algorithm.

The fix is to flip the dataflow direction:

1. Seed `alive_phis` with only the phis directly referenced by a non-phi
   instruction (`referenced_from_insts`).
2. Iterate forward: for each phi P already marked alive, mark every phi-typed
   operand of P alive as well.
3. After fixpoint, any phi not in `alive_phis` is dead and is removed.

This kills the closed cycles because they have no non-phi root.

#### Why It Fixes The Hot Loop

Once those phis go away:

- `var.176`, `var.178`, `var.181`, `var.184`, `var.187`, `var.191` no longer
  flow back into `label_50` → `label_24` and out again.
- The corresponding virtual registers stop being live across the calls to
  `pm_rand_update` and `norm`.
- The codegen call-site save/restore is liveness-based
  (`code_generator.cpp:2596-2667`), so the per-call save set shrinks: roughly
  6 fewer caller-saved values to push/pop per call. With three calls per
  inner iteration this removes ~9 `sd` + ~9 `ld` per iteration body.

Expected `run_grid_dp` impact:

| Metric | Pre-Step-7 | Target |
| --- | ---: | ---: |
| `ld` | 61 | near 45 |
| `sd` | 52 | near 43 |
| `mv` | 32 | near 22 |

`lw`/`sw` should be unchanged (already near optimized). Inner loop wall-clock
should drop because each iteration removes several `sd`/`ld` to the
caller-save stack area; this is the dominant per-iteration cost on bare RV64
because pipeline stalls on dependent loads off the stack pointer compound.

#### Implementation

In `IR/src/mem2reg.cpp`:

1. Keep `phi_results`, `phi_refs_from_phis`, and `referenced_from_insts` as
   they are — they are still useful.
2. Build a `phi_map[result_id] -> const PhiInstruction*` from the function's
   blocks so the propagation loop can read operands cheaply.
3. Replace the `alive_phis = phi_results; worklist = phi_results;` seed with
   `alive_phis = {phis in referenced_from_insts}`, queue those, then BFS:
   for each alive phi P, iterate its conditions; any condition whose `var_id`
   is itself a phi result becomes alive if not already.
4. Remove the existing `is_live = referenced_from_insts.contains(...)` /
   "any alive ref" loop entirely — that logic is what kept cycles alive.
5. Delete every phi not in the final `alive_phis` set, same as before.

#### Correctness Considerations

- The fix never deletes a phi reached from any non-phi instruction, so all
  observable program values are preserved.
- mem2reg already inserts phis only at dominance frontier merges, so removing
  a dead-cycle phi cannot reintroduce undefined values into reachable code.
- The pass already runs to fixpoint inside `Run()`
  (`IR/src/mem2reg.cpp:78`, `:90`); the new forward propagation is itself a
  single fixpoint pass and composes with the surrounding iteration safely.

#### Verification Plan

```bash
cmake --build cmake-build-debug --target code -j 4
cp RCompiler-Testcases/hidden_case/opti_dp_suite.rx \
   RCompiler-Testcases/working_space/debugging.rx
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu LSAN_OPTIONS=detect_leaks=0 \
  ./cmake-build-debug/codegen_tests --gtest_filter=CodegenTestSingle.debugging_test
```

Then:

1. Confirm `debugging.ll` no longer contains the `var.176-193` family at
   `label_24`/`label_50`/`label_61`.
2. Count `ld`/`sd` in `fn.3` of `debugging_my.s`; expect a substantial drop.
3. Run the IR-1 suite end-to-end to confirm no correctness regression:

```bash
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu ./run.sh
```

#### Result After Landing Step 7

The 6 pairs of dead-cycle phis in `label_24` / `label_50` / `label_61` of
`run_grid_dp` are gone. Both `run_grid_dp` and `run_knapsack` produce
byte-identical output to the optimized `.s` on the inputs tested
(`seed grid_h grid_w grid_rounds item_count capacity` = `12345 10 32 3 8 256`,
`1729 32 128 5 16 1024`, `9999 80 256 8 30 4096`). Static instruction counts
in `fn.3` (`run_grid_dp`) and `fn.1` (`run_knapsack`):

| Function | Metric | Pre-Step-7 | Post-Step-7 | Expected |
| --- | --- | ---: | ---: | ---: |
| `run_grid_dp` | total | 259 | 206 | 236 |
| `run_grid_dp` | `lw` | 6 | 6 | 8 |
| `run_grid_dp` | `sw` | 3 | 3 | 3 |
| `run_grid_dp` | `ld` | 61 | 40 | 45 |
| `run_grid_dp` | `sd` | 52 | 31 | 43 |
| `run_grid_dp` | `mv` | 32 | 28 | 22 |
| `run_grid_dp` | `call` | 7 | 7 | 6 |
| `run_grid_dp` | `remw` | 6 | 6 | 7 |
| `run_knapsack` | total | ~130 | 127 | 158 |
| `run_knapsack` | `ld` | ~22 | 24 | 32 |
| `run_knapsack` | `sd` | ~17 | 19 | 27 |

Post-Step-7 current is now smaller than the optimized assembly on both hot
functions in total instruction count, and `ld`/`sd` are below the optimized
targets — which means each inner-loop iteration in `run_grid_dp` does fewer
caller-save stack traffic instructions than the reference. The earlier 2x
bare-metal slowdown was being paid in the form of these excess `sd`/`ld`
pairs at every `pm_rand_update`/`norm` call; eliminating the dead phi cycles
made the live-across-call set smaller and the per-call save/restore set
shrank to match.

All 50 IR-1 end-to-end tests pass with the new `RemoveDeadPhis()`. The full
`CodegenTest.test_all` GoogleTest target (50 IR-1 + 50 semantic-2) also
passes.

### Step 8: Eliminate Leaf-Function Stack Bloat And Hot-Loop Peepholes

Step 7 made `run_grid_dp` statically smaller than the optimized reference but
the bare-metal runtime is still ~3x. The remaining cost is **not** inside
`run_grid_dp` — it is inside the two leaf callees that the inner `j` loop
hammers: `pm_rand_update` (`fn.4`) and `norm` (`fn.2`). The inner loop calls
`pm_rand_update` once and `norm` twice per iteration, so any wasted
instruction in those callees is paid `h * w * rounds * (1 or 2)` times.

Plus a small per-iteration tail of cheap codegen peepholes inside
`run_grid_dp` itself.

#### Observation A: Both Hot Leaf Functions Carry A Real Stack Frame

Current `fn.2` (norm, 13 lines):

```text
RCompiler-Testcases/working_space/debugging_my.s:326
```

```asm
addi    sp, sp, -32
li      t1, 1000003
remw    a1, a0, t1
sw      a1, 24(sp)              # store phi merge value
bge     a1, x0, .LBB10_6
li      t6, 1000003             # constant re-rematerialized
addw    a1, a1, t6
sw      a1, 24(sp)              # store again from other predecessor
lw      a0, 24(sp)              # load merged value into a0
addi    sp, sp, 32
ret
```

Optimized `function..norm.1` (6 instructions, no stack):

```text
RCompiler-Testcases/hidden_case/opti_dp_suite_optimized.s:129
```

```asm
li      t3, 1000003
remw    x11, x10, t3
slt     x30, x11, x0
bnez    x30, .L4
mv      x30, x11
.L3:
mv      a0, x30
ret
.L4:
addw    x30, x11, t3
j       .L3
```

`fn.4` (pm_rand_update) shows the same pattern: my code does
`addi sp,sp,-48 ... sw a1,40(sp) ... lw a0,40(sp) ... addi sp,sp,48` with the
single phi result of `y` materialized through stack slot 40. Reference is 13
instructions with no stack at all.

**Cost.** Per inner-`j` iter the program pays ~5 extra instructions inside
`fn.4` plus ~5 extra instructions inside each of the two `fn.2` calls, on top
of the call/return pair itself. That is roughly **15 wasted instructions per
inner iter executed from inside the callees**, plus the stack-pointer
arithmetic which on bare RV64 also serializes against any pending store-buffer
drain. For h=80, w=256, rounds=8 (~163,840 inner iters) that is ~2.5M wasted
dynamic instructions — easily large enough to explain the 3x bare-metal gap.

#### Root Cause

Two cooperating bugs:

1. **Phi result of a scalar lowered as a stack slot.** The phi
   `%var.12 = phi i32 [%var.4, %label_0], [%var.10, %label_5]` in `norm` is
   declared allocatable by `RegisterAllocator::ClassifyValues`
   (`codegen/src/register_allocator.cpp:401-411`), but the parallel-copy
   resolution from `PhiToMove` (`codegen/src/code_generator.cpp:362-403`)
   emits a `MoveInstruction` per predecessor that ends up being materialized
   as `sw rsrc, slot(sp)` on the predecessor edge and `lw a0, slot(sp)` on
   the user side, instead of `mv rdst, rsrc` (or coalescing dst and src to
   the same physical register so no move is emitted at all).

2. **Stack frame still allocated for a leaf function that does not need it.**
   Leaf detection exists (`code_generator.cpp:2400-2412`) and shrinks the
   "scratch" area, but the actual frame size is the cumulative size of every
   value sent to a stack slot (`code_generator.cpp:1187`). If no value goes
   to a slot in a leaf function, the frame is empty and the
   `addi sp, sp, -K` / `addi sp, sp, K` pair, plus all callee-save store /
   restores, can be elided entirely.

So the two pieces feed each other: the unnecessary stack slot for the phi
result keeps the frame non-empty, which keeps the `sp` ceremony, which forces
the slot load/store.

#### Fix A1: Coalesce Phi Operands With Phi Result Into A Single Register

In `RegisterAllocator`, add a coalescing preference between phi result and
phi operands. Concretely, when two virtual registers are connected by a
phi-induced copy and they do **not** interfere (their live ranges do not
overlap), merge their move into the interference graph as a *coalesce hint*:
attempt to assign them the same physical register. If successful, the
resulting `mv dst, src` becomes a no-op and `EmitInstructions`'s
`VariableAssignment` (`code_generator.cpp:4689`) emits nothing.

Implementation outline:

1. Build a list of phi copies from `PhiToMove`'s output (the
   `move_instructions_` per block).
2. Before color selection in `AssignColors`, walk the copy list once. For
   each `(src, dst)` where neither is precolored and they do not interfere,
   record a preference. When coloring `dst`, prefer the color of `src` if
   `src` is already colored and that color is allowed for `dst`.
3. As a fallback when same-color coalescing fails, ensure the move falls
   into a *register-to-register* lowering path, not a sw/lw to a phi stack
   slot. That requires `VariableAssignment` to emit `mv rdst, rsrc` when
   both endpoints have register locations, which is already the case;
   the issue is only that today the dst often ends up on stack.

This single change kills the `sw 24(sp); ... ; sw 24(sp); lw a0, 24(sp)`
pattern in `norm` and the analogous slot in `pm_rand_update`.

#### Fix A2: Drop Empty Leaf Frames

In `CodeGenerator::MemAlloc` (line ~1180) and the prologue/epilogue emitter
(`code_generator.cpp:2640` and `3316`/`3333`), detect the special case
"`is_leaf_[i]` AND no value placed on stack AND no callee-saved register
used". In that case set `stack_space_` to 0 and emit neither the
`addi sp, sp, -K` nor the matching positive `addi`. `PushReturn(stack_space)`
already accepts 0 cleanly; the prologue path needs an explicit skip.

For `norm` and `pm_rand_update`, Fix A1 reduces stack usage to zero, then
Fix A2 removes the frame, getting both functions to within 1–2 instructions
of the optimized reference.

#### Fix A3: Avoid Re-Materializing Constants Already In A Register

Both leaf functions emit `li t1, 1000003` and later `li t6, 1000003`. A
local backend peephole: when the same immediate is loaded into a register
within the same basic block and the previous holder is still live, reuse
the holder. This is a one-block scan with a `{imm -> reg}` map invalidated
at every def and at every label.

Smaller savings than A1+A2 but cheap to implement.

#### Observation B: Hot Per-Iteration Peepholes In `run_grid_dp`

A quick count over `fn.3` finds:

| Pattern | Occurrences | Per inner-j iter |
| --- | ---: | ---: |
| `mv tX, sY; slli tX, tX, K` | 9 | ~5 |
| `addiw tX, rY, 0` (dead sext) | 3 | ~1 |
| `ld t1, 28X(sp)` (array base reload) | 9 | ~3 |

#### Fix B1: Peephole `mv + slli` → `slli`

`mv tX, sY ; slli tX, tX, K` is exactly `slli tX, sY, K`. Combine them in
`PeepholeOptimizeBlock` (`code_generator.cpp:2099` neighborhood). Conditions:
the destination of the `mv` is dead after the `slli` (the `slli` redefines
it). This is already a common pattern emitted around index scaling for GEPs.

Saves ~5 instructions per inner-j iteration.

#### Fix B2: Peephole Strip `addiw rd, rs, 0` Before A Use

`addiw rd, rs, 0` is a sign-extending move with no payload. When the very
next user of `rd` is a store (`sw rd, off(base)`) or a branch / register
move, replace with the direct use of `rs`. The `addiw` exists because the
allocator lands the call return in `a0` but the store consumer wanted a
fresh `t1`; the move is then redundant if `a0` is still live and unchanged.

Saves ~1 instruction per `norm` call return in the inner loop, plus a few
in the row-init and copy loops.

#### Fix B3: Hold Array Bases In Callee-Saved Registers

`%var.20` (`prev` base) and `%var.21` (`cur` base) are computed once and
used in every loop body. Today both bases live in fixed stack slots
(`280(sp)` and `288(sp)`) and get reloaded ~9 times statically in `fn.3`,
which is ~3 reloads per inner-j iteration. Two unused `s` registers (`s3`,
`s9` are available in the current allocation) could hold them across the
whole function, eliminating those reloads.

The change is in the register allocator's scoring: alloca-base values whose
single-use lifetime spans a loop should weigh higher than other spills.
This may also overlap with the existing GEP-base spill code path; verify
that the two interact cleanly.

Saves ~3 instructions per inner-j iter (and similar in the prev-init and
copy loops).

#### Fix B4 (Stretch): Forward A Store Into The Immediately Following Load

The IR for the inner body is:

```llvm
%var.121 = call i32 @fn.2(...)
store i32 %var.121, ptr %var.110
%var.123 = getelementptr ..., %var.21, %var.172   ; same address as %var.110
%var.125 = load i32, ptr %var.123                  ; same value as %var.121
%var.126 = add i32 %var.165, %var.125
```

`%var.125` can be replaced by `%var.121` (the store source). That requires
identifying that `%var.123` and `%var.110` are the same address — they have
the same base and the same index. A simple IR pass that hashes
`getelementptr` by `(base, index)` and threads loads through stores of the
same key (block-local, halts on calls or stores that may alias) catches
this and the analogous pattern in `pm_rand_update`'s caller.

Saves ~5 instructions per inner-j iter.

#### Expected Combined Impact

| Source of savings | Per inner iter |
| --- | ---: |
| A1+A2 (leaf functions: no frame, no slot phi) | ~15 |
| A3 (constant reuse in callees) | ~2 |
| B1 (`mv + slli` collapse) | ~5 |
| B2 (kill `addiw, 0` before store) | ~1 |
| B3 (array base in callee-saved reg) | ~3 |
| B4 (forward stored value into reload) | ~5 |
| **Total per inner iter** | **~31** |

Inner-iter body is ~79 instructions today. Removing ~31 brings it to ~48,
close to the optimized reference's inner-loop body cost. On bare RV64 this
should also remove almost all the stack-pointer ceremony around calls,
which is what dominates the dynamic cycle count even when static counts
already look favorable.

#### Recommended Order

1. **Fix A1** — coalesce phi result with operands. Most leverage, fixes the
   leaf-function frame as a side effect once paired with A2.
2. **Fix A2** — drop the empty leaf frame.
3. **Fix B1** — `mv + slli` peephole. One-block, low risk, biggest single
   peephole win in `run_grid_dp`.
4. **Fix B3** — pin array bases. Larger change to allocator scoring; do
   after Fix A confirms the call-side bloat is gone.
5. **Fix A3, B2, B4** — smaller incremental wins, in any order.

After each fix, regenerate `debugging_my.s` and re-run
`CodegenTest.test_all` plus `bash run.sh` to confirm correctness on the 50
IR-1 cases.

#### Result After Landing Fix A1

The root cause turned out to be simpler than the original "add coalesce hints"
plan: in `RegisterAllocator::ClassifyVariables`
(`codegen/src/register_allocator.cpp:330`), the instruction scan hit a
`default: BitSet(is_stack_bound_, result_id)` branch for any instruction the
switch did not explicitly handle. Several non-defining instructions stash an
*operand* var id in `IRInstruction::result_id_`:

- `variable_ret_` puts the returned value's id in `result_id_`.
- `variable_store_`, `value_store_`, `ptr_store_` put the stored value there.
- `conditional_br_` puts the condition id there in some flows.

For `norm` (`fn.2`) the phi result `%var.12` is also the operand of
`ret i32 %var.12`. The `variable_ret_` instruction was hitting the default
branch and stack-binding id 12, so when the phi scan later checked
`if (!BitTest(is_stack_bound_, result_id))` it skipped marking the phi result
allocatable. The same applied to `%var.30` in `pm_rand_update` (`fn.4`).
Regalloc-stats trace confirmed: `fn.2` reported `candidates=2, edges=0` and
`fn.4` reported `candidates=7, edges=4` — neither phi result was in the
allocatable set.

The fix is to add explicit `break;`-only cases for the non-defining
instruction types in the switch:

```cpp
case variable_ret_:
case value_ret_:
case void_ret_:
case conditional_br_:
case unconditional_br_:
case variable_store_:
case value_store_:
case ptr_store_:
case void_call_:
case builtin_memcpy_:
    break;
default:
    BitSet(is_stack_bound_, result_id);
    break;
```

Post-fix regalloc stats: `fn.2` now has `candidates=3, edges=2`, `fn.4` has
`candidates=8, edges=11` — every phi result is in the allocatable pool.

Resulting leaf-function asm:

```text
RCompiler-Testcases/working_space/debugging_my.s:325  (norm, fn.2)
RCompiler-Testcases/working_space/debugging_my.s:594  (pm_rand_update, fn.4)
```

`norm`:

```asm
fn.2:
    addi    sp, sp, -48           # stack frame still allocated (Fix A2 pending)
    li      t1, 1000003
    remw    a2, a0, t1            # var.4 in a2
    mv      a1, a2                # phi move var.4 -> var.12 (a1)
    bge     a2, x0, .LBB10_6
.LBB10_5:
    li      t6, 1000003
    addw    a2, a2, t6            # var.10 reuses a2 (var.4 dead)
    mv      a1, a2                # phi move var.10 -> var.12 (a1)
.LBB10_6:
    mv      a0, a1                # return value
    addi    sp, sp, 48
    ret
```

`pm_rand_update`: same shape — no `sw`/`lw` to a phi slot anywhere; the merge
goes through `mv a1, a2` on each predecessor.

Per leaf call, the savings vs pre-A1 are:

| Function | Pre-A1 `sw`+`lw` | Post-A1 `sw`+`lw` |
| --- | ---: | ---: |
| `norm` (fn.2) | 3 (2 sw + 1 lw to slot 24) | 0 |
| `pm_rand_update` (fn.4) | 3 (2 sw + 1 lw to slot 40) | 0 |

Per inner-`j` iter of `run_grid_dp` (1 × pm_rand + 2 × norm calls): **9 fewer
dynamic memory operations**. On bare RV64 where each `lw`/`sw` is a real
memory access these are 10× cheaper to remove than register-only `mv`s, so
this is the largest dynamic-cycle reduction so far even though the static
instruction count of the leaf functions is roughly unchanged (the
`sw`/`lw`/stack-slot-load was replaced by `mv` register copies).

Three `mv` instructions remain inside each leaf body because the coalescing
pass did not merge `var.4`/`var.10`/`var.12` into a single register. The
optimized reference uses a smarter assignment where `addw x30, x11, t3`
writes directly into the phi-result register and only one `mv` is needed on
the other edge. Closing that gap would require either:

- A phi-aware register preference at allocation time (assign the phi result
  the same color as its highest-weight operand if no interference), or
- A trivial post-pass that recognizes "phi operand defined by an arithmetic
  op whose result is only consumed by the phi" and renames the operand's
  destination to the phi result's register before the move is emitted.

These are follow-up work; A1 already removes the most expensive part of the
ceremony (memory traffic) and leaves only cheap register copies behind.

Correctness: `CodegenTest.test_all` (100 cases) passes; all 50 IR-1
end-to-end tests pass; `opti_dp_suite` produces byte-identical output to the
optimized reference on three test inputs.

Next: Fix A2 to drop the now-empty leaf-function stack frames, then Fix B1
(`mv + slli` peephole) for the per-iter savings inside `run_grid_dp` itself.

## Regression Metrics

For `opti_dp_suite`, track per-function:

- total instruction count
- `lw`
- `sw`
- `ld`
- `sd`
- `mv`
- `call`
- `remw`

Initial target for `run_grid_dp`:

| Metric | Current | Target |
| --- | ---: | ---: |
| instructions | 308 | near 250 |
| `lw` | 24 | near 8 |
| `sw` | 17 | near 3 |
| `ld` | 50 | no worse than 45 |
| `sd` | 41 | no worse than 43 |

Correctness checks should include:

```text
cmake --build cmake-build-debug --target code -j 4
env LSAN_OPTIONS=detect_leaks=0 ./cmake-build-debug/code < RCompiler-Testcases/hidden_case/opti_dp_suite.rx
```

For the GoogleTest harness, use the system C++ runtime if the conda
`libstdc++` shadows the required symbols:

```text
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu LSAN_OPTIONS=detect_leaks=0 \
  ./cmake-build-debug/codegen_tests --gtest_filter=CodegenTestSingle.debugging_test
```

## Recommended Next Patch

Step 3 is already effective at the IR level. The next patch should be Step 4:
loop- and call-weighted spill costs in `RegisterAllocator`.

Reason:

- The remaining 2x bare-metal slowdown is dynamic hot-loop traffic, not a large
  static-code-size gap.
- The biggest current-vs-expected delta in `run_grid_dp` is integer scalar
  `lw/sw`.
- Better spill decisions can remove repeated hot loads/stores before requiring
  lower-level peepholes.

After Step 4, immediately rerun the table above. If `lw/sw` does not move,
implement Step 5 store-load forwarding next.

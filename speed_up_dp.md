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

### Step 7: Recheck Call-Site Save Sets After Cleanup

After Steps 4 to 6, recompute assembly metrics. If save/restore traffic is still
high around `pm_rand_update`, inspect call-site liveness and make sure only
actually live caller-saved registers are saved at each call.

Do not start here unless Step 4 does not move the numbers. Current call-save
sets are already liveness-based, but allocator choices still make too many hot
values cross calls in caller-saved registers or spill slots.

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

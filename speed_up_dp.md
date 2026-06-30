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

## Root Causes

### 1. Trivial Selects Survive Into Codegen

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

### 2. Inlining Emits Copies For Returned Values

`OptimizeShortFunctions()` inlines small helpers, including `norm`, but uses
`AddSelect(...)` to copy the callee return into the caller result:

```text
IR/src/IR_generator.cpp:1457-1472
```

After inlining, those artificial copies become normal SSA values. Later passes
do not always eliminate them, so they show up in hot loops.

### 3. GEP Pointer Temporaries Still Spill

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

### 4. Spill Costs Are Not Loop Weighted Enough

Current spill cost is mostly use-count based:

```text
codegen/src/register_allocator.cpp:452
```

For this testcase, an inner-loop use is much more important than a setup/exit
use. Without loop-depth weighting, hot values can still lose registers to colder
values.

### 5. Call Save/Restore Interacts With Stack-Backed Temps

`run_grid_dp` calls `pm_rand_update` inside loops. Some save/restore traffic is
unavoidable, but current scalar stack spills make the call boundaries worse.

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

### Step 4: Add Loop-Weighted Spill Costs

Compute natural-loop depth from the CFG in `RegisterAllocator`:

1. Build predecessors and successors.
2. Identify backedges using dominator information, or conservatively detect
   edges to earlier block layout positions if dominators are not available yet.
3. Assign each block a loop depth.
4. Weight spill-cost additions by:

```text
block_weight = 1 + 4 * loop_depth
```

Apply this in `ComputeSpillCosts()`.

Give extra weight to:

- GEP result values
- GEP base pointers
- array indexes in GEPs
- loop-carried phi results and phi sources
- values live across calls inside loops

Expected impact:

- Hot loop indexes and array addresses stay in registers more often.
- Cold setup/exit temporaries become better spill candidates.

### Step 5: Improve GEP Lowering For Short-Lived Addresses

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

### Step 6: Recheck Call-Site Save Sets After Cleanup

After Steps 1 to 5, recompute assembly metrics. If save/restore traffic is still
high around `pm_rand_update`, inspect call-site liveness and make sure only
actually live caller-saved registers are saved at each call.

Do not start here. The current visible problem is mostly artificial scalar and
pointer temporaries leaking into stack traffic.

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
| instructions | 327 | near 250 |
| `lw` | 31 | near 8 |
| `sw` | 22 | near 3 |

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

## Recommended First Patch

Start with Step 1: trivial-select deletion plus use replacement.

This is the most localized and lowest-risk change. It directly targets bad IR
visible in the DP testcase, should reduce stack traffic before register
allocation, and gives a clean metric to verify before changing allocator
heuristics.

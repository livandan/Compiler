# Enable Small-Function Inline Plan

## Goal

Enable every non-recursive function with at most 32 IR instructions to be inlined, while keeping every `IR-1` and `hidden_case` testcase correct and compiled within 30 seconds.

The target policy is:

- Inline candidate limit: `instruction_count <= 32`.
- Recursive call chains are never inlined.
- Non-recursive call chains are allowed to inline through multiple rounds until no eligible callsite remains.
- Temporary caller-size guards should be removed or raised high enough that they do not block valid small helpers in the required tests.

## Current Problem

The conservative inline guard avoids backend compile-time blowups, but it also blocks useful helpers such as `reduce_value(x:i32)` in `RCompiler-Testcases/hidden_case/opti_bytecode_vm_interpreter.rx`.

The main timeout risk is not the inline decision itself. Once small functions are aggressively expanded, large functions expose several superlinear backend costs:

- `CodeGenerator::Generate()` has post-register-allocation liveness around calls implemented with `std::set` / `std::map` unions and copies.
- The earlier stack-slot / call-crossing analysis in `code_generator.cpp` also uses set-based liveness.
- `RegisterAllocator` already has bitset liveness and interference support, but parts of coalescing still do linear adjacency scans and repeated global degree recomputation.

The plan is therefore to make the backend scale better first, then relax the inline guard.

## Baseline And Measurement

Use targeted timing before and after each phase:

```bash
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu RCOMPILER_TIMING=1 RX_REGALLOC_STATS=1 ./run.sh
```

Track at least these cases:

- `RCompiler-Testcases/IR-1/semantic-2/comprehensive29.rx`
- `RCompiler-Testcases/IR-1/semantic-2/comprehensive31.rx`
- `RCompiler-Testcases/hidden_case/opti_bytecode_vm_interpreter.rx`

Useful numbers to record per testcase:

- IR instruction count before and after inline.
- Number of basic blocks after inline.
- `codegen_generate` time.
- Register allocator liveness / interference / coloring time.
- Total testcase compile time.

The important acceptance threshold is per-testcase compile time under 30 seconds, not just total `run.sh` time.

## Phase 1: Make Inline Eligibility Correct

Keep the inline pass simple and deterministic:

- Build a call graph between functions.
- Compute strongly connected components.
- Mark every function in a recursive SCC as non-inlineable.
- Also mark a self-recursive function as non-inlineable.
- Count candidate body instructions after local IR construction.
- Allow inline when:
  - callee exists,
  - callee is not recursive,
  - callee instruction count is at most 32,
  - callee is not an external/runtime function.

Implementation details that must stay correct:

- Split the callsite block before inserting callee body.
- Remap all callee temporaries and labels to fresh ids.
- Remap supported instructions consistently, including calls, GEP, memcpy/memset-style operations, loads, stores, branches, and returns.
- Preserve phi semantics by keeping predecessor labels valid after block splitting.
- Ensure `var_id_` is advanced beyond every newly created block label and temporary.

At this stage, a temporary caller-growth guard is acceptable only as a safety valve while backend complexity is being fixed.

## Phase 2: Replace Post-RA Call Liveness Sets With Bitsets

The high-value optimization is the post-register-allocation liveness pass in `CodeGenerator::Generate()`.

Current issue:

- Live variable sets are represented as `std::set<int>`.
- Worklist propagation repeatedly copies sets.
- Successor and predecessor relations are stored in ordered maps.
- `live_after_caller_regs` stores a set per instruction, although only caller-saved register membership is needed.

Planned replacement:

- Compress variable ids to dense bit positions for the current function.
- Represent `block_defs`, `block_uses`, `live_in`, and `live_out` as `vector<uint64_t>`.
- Use `or`, `andnot`, and equality checks over machine words.
- Precompute predecessor vectors once instead of scanning all blocks to find predecessors.
- Use a byte/vector flag for worklist membership.
- Store live caller-saved registers as a small integer mask, for example `uint32_t`, instead of `std::set<int>`.

Expected effect:

- Liveness propagation becomes roughly `O((blocks + edges) * bitset_words)` instead of repeated tree-set union/copy costs.
- Per-instruction call-save information becomes cheap to store and query.
- Large inline-heavy functions should stop spending most of compile time in `codegen_generate`.

## Phase 3: Replace Stack-Slot Liveness Sets With Bitsets

There is another set-based dataflow pass before final assembly emission, used for stack-slot allocation and call-crossing variable scoring.

Apply the same conversion:

- Dense variable numbering per function.
- Bitset `def`, `use`, `live_in`, `live_out`.
- Fast iteration over set bits using `ctz`/`popcount` style loops.
- Keep spill-weight and call-crossing counters as arrays indexed by dense variable id.

This matters because aggressive inline increases the number of locals and call-adjacent live ranges. Even if register allocation is efficient, this earlier analysis can still become the new bottleneck.

## Phase 4: Reduce Register Allocator Coalescing Cost

`RegisterAllocator` already uses bitsets for liveness and duplicate interference prevention. The next improvements should focus on the remaining linear paths.

Default rule:

- Preserve assembly quality unless a measured compile-time blocker cannot be fixed by quality-preserving changes.
- Do not skip coalescing by default. Skipping coalescing can leave more `mv` / phi-copy instructions in the final assembly, so it is a fallback only.

Quality-preserving planned changes:

- Replace adjacency scans such as "does `u` interfere with `v`" with `BitTest(interference_bits_[u], v)`.
- Use the same bitset check inside George-style coalescing tests.
- Avoid recomputing all current degrees after every coalesce. Recompute only touched nodes or maintain degrees incrementally.
- Deduplicate move edges earlier, or maintain a move-edge bitset to avoid repeated work. If move frequency is later used for priority, keep a separate weight/count instead of discarding that information.

Implementation order:

1. Convert all remaining interference-membership checks in coalescing/coloring to `interference_bits_`.
2. Use bitset membership in George/Briggs conservative coalescing tests.
3. Deduplicate move edges while preserving optional frequency/weight information.
4. Avoid global current-degree recomputation; update only touched nodes or maintain degrees incrementally.

Fallback only if still needed:

- Add a conservative coalescing budget for huge functions only after the quality-preserving changes above have been measured and are insufficient:
  - if move-edge count or active node count crosses a threshold, skip expensive coalescing and proceed to simplify/select;
  - this may reduce assembly quality slightly, so it must be disabled by default or guarded by a clearly justified threshold.

Any budget should be based on measured data from `RX_REGALLOC_STATS`, not guessed blindly. Record the static assembly impact, especially `mv`, load/store, and total instruction counts, before accepting it.

## Phase 5: Relax Inline Guard Incrementally

After backend bitset work is in place, test inline expansion in several configurations:

1. Current guarded mode.
2. Caller instruction guard raised to a moderate value, for example 1500.
3. Caller instruction guard raised further, for example 3000.
4. No caller instruction guard, with a fixed inline round cap.
5. No caller instruction guard, fixed-point inline for all eligible non-recursive functions.

For each configuration, record:

- Correctness result for `IR-1`.
- Correctness result for `hidden_case`.
- Slowest testcase compile time.
- Whether `reduce_value(x:i32)` and similar small helpers are actually inlined.

The final configuration should be the least restrictive one that keeps every required testcase under 30 seconds.

## Phase 6: Validation

Correctness checks:

```bash
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu ./run.sh
```

Performance checks:

```bash
env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu RCOMPILER_TIMING=1 RX_REGALLOC_STATS=1 ./run.sh
```

Targeted checks:

- Compile `opti_bytecode_vm_interpreter.rx` and verify that the generated output no longer contains a real call to `reduce_value`.
- Compile `comprehensive29.rx` and `comprehensive31.rx` repeatedly, because these are likely to expose backend superlinear behavior.
- Check that every single testcase stays below 30 seconds.

## Risks

- Bitset liveness must preserve phi-edge semantics. Phi uses belong to predecessor edges, not simply to the top of the successor block.
- Call-save liveness only needs caller-saved physical registers after register allocation, but the variable-to-register mapping must be exact.
- Skipping or budgeting coalescing can increase move instructions. This is acceptable only if runtime quality remains good enough for the tests.
- Removing all caller-growth protection can still create unavoidable code-size growth in synthetic call graphs. If needed, keep a very high global instruction budget as a hard safety guard, but it should not block required small helpers.

## Success Criteria

This plan is complete when:

- Every non-recursive function with at most 32 IR instructions is eligible for inline.
- Recursive SCCs and self-recursive functions are excluded.
- `reduce_value(x:i32)` in `hidden_case/opti_bytecode_vm_interpreter.rx` is inlined.
- `IR-1` and `hidden_case` pass correctness tests.
- Each testcase compiles within 30 seconds.
- Timing output shows no dominant superlinear hotspot in codegen liveness or register allocator coalescing for the known heavy cases.

# Register Allocation Notes

This document describes the current register allocator in
`codegen/src/register_allocator.cpp` and the main correctness/quality findings
from reviewing it.

## Pipeline Position

Codegen runs in this order:

1. `PhiToMove()` converts IR phis into predecessor-block move instructions.
2. `MemAlloc()` gives every value an initial stack home.
3. `RegisterAllocator::Run()` promotes selected scalar virtual registers.
4. `AnalyzeUsedRegisters()` records real register usage.
5. `CompactStackFrame()` rewrites stack offsets.
6. Instruction selection emits final RISC-V code and then emits phi moves before
   each terminator.

The allocator does not rewrite IR. It only changes
`RISCVFunctionNode::location_` from stack locations to physical-register
locations where coloring succeeds.

## Physical Register Model

Reserved registers are never allocated:

- `x0` zero
- `x1` return address
- `x2` stack pointer
- `x3` global pointer
- `x4` thread pointer

Scratch registers are also excluded from allocation:

- `x5`, `x6`, `x7`, `x31`

For non-leaf functions, the allocator may use all non-reserved,
non-scratch registers. For leaf functions, it prefers caller-saved registers
first, then callee-saved registers.

Parameter registers already assigned by `MemAlloc()` are removed from the
available pool so parameters do not overlap with newly colored temporaries.

## Variable Classification

Allocatable values are scalar IR results:

- integer-like values
- booleans
- enum values
- pointers from loads/GEPs
- scalar phi results, except pointer phis are still currently stack-bound

Stack-bound values include:

- alloca results
- aggregate values
- most unsupported/unknown result forms
- direct-branch compare results that are lowered directly into branch
  instructions

Huge functions use a candidate cap: if variable/block/instruction thresholds are
too large, only the top 1024 scored scalar candidates remain allocatable and all
other scalar values keep stack homes. This is a deliberate compile-time guard,
but it also explains low-quality assembly in very large functions.

## Liveness

Liveness is per basic block and stored as dense bitsets indexed by IR variable
id. The allocator now computes upward-exposed uses: an operand becomes a block
use only if the block has not already defined the same allocatable value.

Phi sources are treated as edge uses on their predecessor blocks. Phi results
are defs at the beginning of the phi block.

The fixed-point equation is:

```text
live_out[B] = union(live_in[S] for S in successors[B])
live_in[B]  = block_uses[B] union (live_out[B] - block_defs[B])
```

## Interference Graph

Interference is an adjacency-vector graph with a bitset matrix used only to
avoid duplicate edges while building. The graph only contains currently
allocatable nodes.

For each block, the allocator walks instructions backwards:

1. Start from `live_out`.
2. Add phi-move sources and deferred branch operands that are needed after
   phi moves.
3. Add edges from each def to all currently live values.
4. Remove defs, then add uses.
5. Add phi-result interference at the block start.

Move edges are recorded separately for phi-induced variable moves. They drive
coalescing but are not themselves real interference unless liveness requires it.

## Coloring

Coloring is Chaitin-Briggs style:

1. Simplify non-move-related low-degree nodes.
2. Try move coalescing with Briggs and George conservative tests.
3. Freeze remaining low-degree move-related nodes.
4. Select spill candidates by largest current degree.
5. Pop the select stack and assign the first available physical register.

Spills are optimistic. A selected spill still receives a register if one is
available during assignment; otherwise it remains in its stack home.

## Correctness Findings

The core graph-coloring rule is structurally sound for the current IR: if two
allocatable values are live at the same time, an edge is added and coloring keeps
them in different physical registers.

Two issues were found and fixed:

1. `PhiToMove()` emitted literal phi moves before variable phi moves on the same
   predecessor block. That could violate parallel-copy semantics when a literal
   phi overwrote a value read by another phi on the same edge. Literal phi moves
   are now emitted after all variable phi copies.
2. Block liveness previously treated every operand as a block use, even if the
   same value was defined earlier in the block. That was conservative for
   correctness but inflated live-in/live-out sets and created unnecessary
   interference edges. Uses are now only upward-exposed.

## Remaining Quality/Scaling Risks

1. Pointer phis are still stack-bound in `ClassifyVariables()`. This is likely a
   major source of loop-base reloads and poor GEP-heavy assembly.
2. `LimitRegisterAllocationCandidates()` protects compilation time by dropping
   most candidates in huge functions. That is safe, but assembly quality can
   degrade sharply when a hot value loses candidacy.
3. Interference construction is still proportional to the sum of live-set sizes
   at defs. Dense live ranges or large phi-move blocks can still become
   expensive.
4. Move coalescing is conservative and does not prioritize move frequency or loop
   hotness, so unnecessary phi moves may remain.
5. Spill selection uses degree only. It does not account for use count, loop
   depth, rematerialization, or stack-offset cost.

## Plan: Remove the Candidate Cap and Improve Spill Choice

Raising `kMaxCandidates` to 81920 did not cause compile-time timeout, and the
generated assembly changed little. For the current IR-1 and hidden-case
workload, that strongly suggests the fixed 1024 cap is not the necessary
compile-time guard and is also not the main remaining performance bottleneck.

The next plan is therefore to remove the top-N candidate limit and focus on
better spill decisions.

1. Remove the fixed 1024 candidate cap from
   `LimitRegisterAllocationCandidates()`.

   The allocator should allow all classified scalar candidates to participate in
   liveness, interference construction, coalescing, and coloring. Do not replace
   1024 with another large magic constant such as 81920.

2. Keep lightweight register-allocation statistics under a debug flag:
   - original allocatable candidate count
   - block count, instruction count, and phi-move count
   - liveness time
   - interference graph time
   - coloring time
   - interference edge count

   These stats are still useful as a safety check. If a future hidden testcase
   exposes a true pathological compile-time case, it should be handled with a
   measured fallback, not with an unconditional candidate cap.

3. Replace the current spill candidate policy. The current implementation picks
   the node with the largest current interference degree:

   ```text
   spill_candidate = argmax(current_degree)
   ```

   This can spill hot loop variables just because they interfere with many
   values. A better first model is:

   ```text
   spill_priority = spill_cost / max(1, current_degree)
   spill_candidate = argmin(spill_priority)
   ```

   Here, `spill_cost` estimates how expensive it would be to leave the value on
   the stack, while `current_degree` estimates how much register pressure is
   relieved by spilling it.

4. Add a spill-cost estimate for each allocatable value before coloring. The
   estimate should reward values that are expensive to reload or store:
   - normal use: small positive weight
   - def: smaller positive weight
   - loop-depth weighted use or def
   - phi result and phi source, especially loop-carried phis
   - pointer values used as GEP bases
   - pointer values used by `load`, `store`, `memcpy`, and `memset`
   - branch conditions
   - call arguments

   A simple first version can use:

   ```text
   block_weight = 1 + 4 * loop_depth
   ```

   and then multiply use/def weights by `block_weight`. If loop detection is not
   available yet, start with unweighted use counts and phi/pointer bonuses, then
   add loop weights later.

5. Prefer dynamic spill selection over static pre-sorting for the first
   implementation.

   A pre-sorted spill order is possible, but the best denominator is
   `current_degree`, and that changes during simplify/coalesce/freeze. The first
   version should keep the existing O(N) scan in `SelectSpillCandidate()` and
   compute:

   ```text
   score(node) = spill_cost[node] / max(1, current_degree[node])
   ```

   Then choose the lowest score among nodes still in `in_worklist_`. This is
   more accurate and the extra O(N) scan is not the expensive part of the
   allocator.

6. Enable pointer phi allocation. `ClassifyVariables()` currently keeps pointer
   phis stack-bound by excluding `pointer_type` phi results. Pointer phis should
   become allocatable scalar values with size 8. This is likely more important
   than simply adding more scalar temporaries to the candidate set.

7. Benchmark changes phase by phase:
   - full IR-1 correctness
   - hidden-case correctness
   - per-testcase compile time, with every testcase below 30 seconds
   - assembly metrics for instruction count, loads, stores, and `mv`

Recommended implementation order:

1. Remove the fixed 1024 candidate cap and keep all scalar candidates.
2. Add register-allocation timing and size statistics.
3. Add `spill_cost_` storage and compute a first use/def/phi/pointer cost.
4. Change `SelectSpillCandidate()` from largest degree to lowest
   `spill_cost / degree`.
5. Enable pointer phi allocation.
6. Add loop-depth weighting if the first spill-cost model is stable.

## Verification

Ran:

```sh
LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu ./run.sh
```

Result:

```text
IR-1 tests: 50 success out of 50
```

The `codegen_tests` stage also passed both tests. The environment still prints a
LeakSanitizer warning about running under ptrace; this was present before these
changes and does not prevent the script from completing the IR-1 assembly
checks.

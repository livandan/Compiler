# Compile-Time Performance Optimization Plan

Analysis of the rx-Compiler's **running time complexity** — where the compiler spends
CPU cycles during compilation, and which parts have poor algorithmic scaling.

**Last updated:** 2026-06-26 (re-analysis after mem2reg O(N²)→O(N) optimization)

---

## Overall Pipeline & Where Time Goes

```
Source (.rx) → Lexer → Tokens → Parser → AST → Semantic → IR → Codegen → Assembly (.s)
                  |          |        |        |        |         |
               O(N)·C    O(N)·E    O(N·D)  O(N·D)  O(N)✓    O(V²)★
                lexer    parser    scope   type     mem2reg   reg-alloc
```

**Key:** `N` = source size, `C` = constant blowup (~12× per token), `E` = exception overhead,
`D` = nesting depth, `V` = variable count, ★ = dominant remaining bottleneck, ✓ = optimized

The dominant O(N²) mem2reg bottleneck has been **eliminated** (commit `e10f241`).
The primary remaining compile-time costs are:
1. **Register allocator** — O(V²) graph operations with `std::set`/`std::map`
2. **Lexer** — ~12× constant factor per token (10 regex calls + 2 manual scanners)
3. **Parser** — exception-based backtracking (thousands of throw/catch per file)

---

## 1. Lexer — O(N) with ~12× Constant Blowup Per Token

**Status: UNCHANGED** — no optimizations applied since initial analysis.

### 1.1 Brute-Force Longest-Match: 12 Token Pattern Attempts Per Position

**File:** [regex_matcher.cpp:260-331](lexer/src/regex_matcher.cpp#L260-L331) — `GetNext()`

For **every single input token**, all 12 match methods are tried in sequence:

1. `MatchIdentifierOrKeyword()` — boost::regex
2. `MatchCharLiteral()` — boost::regex
3. `MatchStringLiteral()` — boost::regex
4. `MatchRawStringLiteral()` — manual scanner
5. `MatchCStringLiteral()` — boost::regex
6. `MatchRawCStringLiteral()` — manual scanner
7. `MatchIntegerLiteral()` — boost::regex
8. `MatchPunctuation()` — boost::regex
9. `MatchReservedToken()` — boost::regex
10. `MatchWhitespace()` — boost::regex
11. `MatchLineComments()` — boost::regex
12. `MatchBlockComments()` — manual scanner

**Complexity:** O(N) asymptotically (ptr_ advances monotonically), but the per-token
constant factor is ~10 `boost::regex_search` calls + 2 manual scanners. For a file
with 10,000 tokens, that's ~120,000 regex engine invocations — most of which fail
immediately because the input doesn't match (e.g., trying to match an identifier as
a string literal). There is **no short-circuit dispatch** — no switch on first
character to skip obviously inapplicable matchers.

**The `[\s]*` bug:** The whitespace pattern uses `*` (zero-or-more) instead of `+`
(one-or-more), so it **always succeeds** with a zero-length match at every position.

### 1.2 Per-Token String Copying in MatchResult

**File:** [regex_matcher.cpp:11-12](lexer/src/regex_matcher.cpp#L11-L12)

Every match copies the matched text into `MatchResult::matched_str_` (`std::string`).
In `GetNext()`, the copy happens **again** each time a "longer" match supersedes the
current best (`result = tmp`). Each `Token` constructor then copies the string a third
time ([tokenizer.cpp:9](lexer/src/tokenizer.cpp#L9)). For a 100KB source file, this is
~3× total source size in string copies. No move semantics are used anywhere.

### 1.3 GetIntType() Called in Loop Condition

**File:** [token.cpp:27-88](lexer/src/token.cpp#L27-L88) — `GetInt()`

`GetIntType()` (which calls `str_.substr()` to create temporary heap strings) is
invoked in the `for`-loop condition of every integer conversion loop iteration.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 1.1a | **First-char dispatch**: switch on `str_[ptr_]` to try only matching patterns (e.g., `r` → raw string, `"` → string, digit → integer, letter → identifier/keyword, `/` → comment, etc.) | ~10× per-token speedup |
| 1.1b | Fix `STR_WHITESPACE` to `[\s]+` | Eliminates one always-successful regex call per token |
| 1.2 | Use `std::string_view` / offset+length in `MatchResult` instead of copying; add move constructor to `Token` | ~3× fewer string allocs |
| 1.3 | Cache `GetIntType()` result in a member variable | Negligible but zero-cost fix |
| 1.x | Replace boost::regex with hand-written DFA/scanner for simple patterns (identifier, integer, whitespace) | Eliminates regex engine overhead entirely |

---

## 2. Parser — O(N) with Exception-Based Backtracking

**Status: UNCHANGED** — no optimizations applied since initial analysis.

### 2.1 C++ Exceptions as Control Flow (Dominant Cost)

The parser uses `throw ""` / `catch (...)` for **routine parsing disambiguation**.
There are 45 `catch` blocks and 47 `throw` statements across ~3,200 lines of parser
code. C++ exception handling triggers stack unwinding and RTTI propagation, which is
thousands of CPU cycles per throw.

**Hotspots (exceptions per parse unit):**

| Pattern | Location | Frequency |
|---------|----------|-----------|
| Struct-expr trial for every expression leaf | [expression.cpp:735-742](parser/src/expression.cpp#L735-L742) | 1 throw per identifier reference |
| Statement vs Item disambiguation | [statements.cpp:59-64](parser/src/statements.cpp#L59-L64) | 1 throw per non-item statement |
| End-of-statements detection | [statements.cpp:13-17](parser/src/statements.cpp#L13-L17) | 1 throw per block |
| SelfParam vs normal params | [functions.cpp:9-24](parser/src/functions.cpp#L9-L24) | 1 throw per function |
| Trailing-comma in lists | expression.cpp, structs.cpp, enumerations.cpp | 1 throw per comma-separated list |

**Total:** For a file with N identifier references, S statements, B blocks, and F functions,
the parser throws approximately `N + S + B + F + L` exceptions (where L = number of
comma-separated lists). For a 10,000-token file, this can easily be **hundreds to
thousands of exceptions**.

### 2.2 Per-Node Heap Allocation (No Arena)

**File:** [node.cpp:39-217](parser/src/node.cpp#L39-L217) — `AddChild()`

Every AST node (including punctuation tokens, keywords, literals) is individually
`new`'d. There is no memory pool or arena allocator. During backtracking (exception
throws), partially-constructed subtrees are allocated then immediately freed via
`Restore()` ([node.cpp:365-373](parser/src/node.cpp#L365-L373)), which iterates and
`delete`s each child. For a 10,000-token file, this means ≥10,000 heap allocations.

### 2.3 Linear Keyword Blacklist Checking

**Files:** [leaf_node.cpp:9-21](parser/src/leaf_node.cpp#L9-L21), [type.cpp:33-44](parser/src/type.cpp#L33-L44), [path.cpp:34-47](parser/src/path.cpp#L34-L47)

The same ~45 Rust keywords are checked via chained `||` string comparisons in three
separate places. Each identifier/type/path node does up to 45 string comparisons.
A `static const std::unordered_set<std::string>` would make this O(1) amortized.

### 2.4 Linear Operator Matching in GetInfix

**File:** [expression.cpp:112-218](parser/src/expression.cpp#L112-L218)

`GetInfix()` does a linear chain of ~25 string comparisons per infix operator in the
Pratt loop. This is O(K) per operator where K = number of operators, not a scaling
issue, but adds constant overhead.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 2.1 | Replace `throw ""` / `catch (...)` with a `Result<T, Error>` type or boolean return + error propagation | Eliminates stack unwinding overhead (~1000× faster branch) |
| 2.2 | Use a bump-pointer arena allocator for AST nodes | Reduces allocation cost from malloc to pointer bump; bulk-free on destruction |
| 2.3 | Replace chained `\|\|` keyword checks with `static const std::unordered_set<std::string>` | O(K) → O(1) per check |
| 2.4 | Replace linear `GetInfix` with a `static const std::unordered_map<std::string, InfixInfo>` | O(K) → O(1) per operator |

---

## 3. Semantic Analysis — O(N·D) Scope Walking + O(M·S) Associated Item Scanning

**Status: UNCHANGED** — no optimizations applied since initial analysis.

### 3.1 Scope Chain Walking Per Lookup (O(N·D), Worst-Case O(N²))

**File:** [visitor_frame.h:48-67](semantic/include/visitor_frame.h#L48-L67) — `FindInValue()`, `FindInType()`

Every name reference traverses the full parent-pointer chain from current scope to
root. With N name references across a program at average depth D, total cost is
**O(N·D)**. In deeply nested code (e.g., 100 nested brace blocks), D = O(N), making
this **O(N²)**.

**Call sites (each does a full scope chain walk):**
- `PathInExpression` → `FindInValue` / `FindInType` (every variable/type reference)
- `TypePath` → `FindInType` (every type annotation)
- `StructExpression` → `FindInType`
- `CallExpression` → `FindInValue` (every function call)
- `Implementation` → `FindInType`

There is **no memoization** — looking up the same name twice from the same scope
walks the chain twice. Each level uses `std::unordered_map::contains()` (O(1) expected),
so the per-call cost is O(D). The cumulative cost across all lookups is O(N·D).

### 3.2 Linear Scan of All Associated Items at Every Call Site (O(M·S))

**File:** [value_type.cpp:1384-1423](semantic/src/value_type.cpp#L1384-L1423) and similar

For struct methods, the guard check that triggers lazy type-visiting scans **all S
associated items** to find any that are still unvisited:

```cpp
for (const auto &item : struct_ptr->associated_items_) {
    if (item.second.node->integrated_type_ == nullptr || ...) {
        // lazy-visit ALL associated items (another O(S) inner loop)
        break;
    }
}
```

If a struct has S methods called M times total, cost is **O(M·S)**. When both scale
with program size, this is **O(N²)**. Same pattern appears at four locations:
- [value_type.cpp:811-851](semantic/src/value_type.cpp#L811-L851) — qualified path
- [value_type.cpp:1256-1289](semantic/src/value_type.cpp#L1256-L1289) — call_expr
- [value_type.cpp:1384-1423](semantic/src/value_type.cpp#L1384-L1423) — method_call_expr
- [value_type.cpp:1499-1508](semantic/src/value_type.cpp#L1499-L1508) — field_expr

### 3.3 O(N) Array Literal Expansion During Semantic Analysis

**File:** [value_type.cpp:919-921](semantic/src/value_type.cpp#L919-L921)

`[expr; N]` array repeat syntax creates N copies of `Value` in a vector at
semantic-analysis time. Each `Value` copy may recursively copy maps and strings.
For `[0; 100000]`, this is 100,000 deep copies of `Value` objects.

### 3.4 Excessive shared_ptr<IntegratedType> Allocations

Nearly every expression handler calls `std::make_shared<IntegratedType>()`, which
heap-allocates and initializes a `possible_types` hash set (with all 4 integer types)
even for non-integer types like `bool`, `unit`, `char`. There are ~45+ distinct
allocation sites across [value_type.cpp](semantic/src/value_type.cpp). No flyweight
or interning — a type like `i32` referenced 50 times creates 50 separate `IntegratedType`
objects.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 3.1 | Add per-ScopeNode `resolved_names` cache (`unordered_map<string, ScopeNodeContent>`) that memoizes chain-walk results; invalidate on new symbol insertion | O(N·D) → O(N) |
| 3.2 | Replace linear scan guard with a `bool all_items_visited_` flag on struct types | O(M·S) → O(M) |
| 3.3 | Defer array repeat expansion to IR/codegen; store `(expr, count)` as a lazy thunk | O(array_size) → O(1) at semantic time |
| 3.4 | Use an object pool or pre-allocated `IntegratedType` for common types (i32, bool, unit, etc.) | Fewer heap allocations |

---

## 4. IR Generation & Mem2Reg — ~~Primary O(N²) Bottleneck~~ → Resolved

**Status: OPTIMIZED** — commit `e10f241` ("opti: mem2reg O(N²)→O(N)") added
use-lists and worklist-based dead-phi elimination, eliminating the three dominant
O(N²) patterns.

### 4.1 ✓ IsPromotable: O(N²) → O(uses) — FIXED

**File:** [mem2reg.cpp:423-488](IR/src/mem2reg.cpp#L423-L488)

**Before:** Scanned every instruction in every block per alloca → O(A·I) = O(N²).
**After:** Looks up `use_list_[alloca_id]` (built once in O(I+P)) and only visits
use sites → O(uses(alloca)). Total across all allocas: **O(N)**.

### 4.2 ✓ CollectStoresAndLoads: O(N²) → O(uses) — FIXED

**File:** [mem2reg.cpp:505-546](IR/src/mem2reg.cpp#L505-L546) — inline in `PromoteAlloca()`

**Before:** Full-IR scan per alloca → O(A·I) = O(N²).
**After:** Uses `use_list_[alloca_id]` → O(uses(alloca)). Total: **O(N)**.

### 4.3 ✓ ReplaceAllUses: O(N²) → O(uses) — FIXED

**File:** [mem2reg.cpp:714-741](IR/src/mem2reg.cpp#L714-L741)

**Before:** Full-IR scan per replaced value → O(L·I) = O(N²).
**After:** Uses `use_list_[old_id]` → O(uses(old_id)). Also handles phi conditions
via use-lists, eliminating an entire separate O(P) phi-rescan step. Total: **O(N)**.

### 4.4 ✓ RemoveDeadPhis: O(P·I) → O(I+P) — FIXED

**File:** [mem2reg.cpp:1187-1345](IR/src/mem2reg.cpp#L1187-L1345)

**Before:** Fixed-point iteration re-scanning all instructions each iteration →
O(P·(I+P)).
**After:** Worklist-based single-pass approach: build phi-reference map (O(P)), scan
instructions once (O(I)), then worklist propagation (O(P)). Total: **O(I+P)**.

### 4.5 New: BuildUseList — O(I+P) Foundation

**File:** [mem2reg.cpp:285-417](IR/src/mem2reg.cpp#L285-L417)

This single O(N) scan is the foundation enabling all the above fixes. It visits every
phi instruction and regular instruction exactly once, recording `UseSite{block_id,
is_phi, index}` into `use_list_[var_id]` for every variable ID referenced.

### 4.6 AddPhi: Linear Search by result_id (O(P²) Per Block) — REMAINS

**File:** [IR_generator.h:268-297](IR/include/IR_generator.h#L268-L297) — `IRBlock::AddPhi()`

Each phi insertion linearly scans `phi_instructions_` by `result_id`. For P phi nodes
in a block, total insertion cost is 1+2+...+P = **O(P²)**. In practice P is small
(few phi nodes per block), but this is an easy fix.

### 4.7 ComputeDominanceFrontier (O(B²)) — REMAINS

**File:** [mem2reg.cpp:262-279](IR/src/mem2reg.cpp#L262-L279)

Standard dominance frontier algorithm. For blocks with multiple predecessors, the inner
`while` loop walks up the dominator tree. Worst-case **O(B²)**. Standard for SSA
construction; acceptable for typical CFGs.

### 4.8 GetPreviousBlockHelper: DFS Per Short-Circuit/If-Else (O(B²) Total) — REMAINS

**File:** [IR_generator.cpp](IR/src/IR_generator.cpp) — `GetPreviousBlockHelper()`

Called for every if-else merge and short-circuit logic operator (`&&`, `||`). Each call
does a recursive DFS from `start_block` following control-flow edges. For D levels of
nesting, total is **O(D·B)**, worst-case **O(B²)**.

### 4.9 Minor: Alloca Type Lookup (O(A) Per Promotable Alloca) — REMAINS

**File:** [mem2reg.cpp:556-562](IR/src/mem2reg.cpp#L556-L562)

```cpp
for (const auto &ai : func_->alloca_instructions_) {
    if (ai.result_id_ == alloca_id) { alloca_type = ai.result_type_; break; }
}
```

Linear scan of all alloca instructions to find the type for each promotable alloca.
With P promotable allocas: O(A·P). A is typically small but a trivial `map<int,
shared_ptr<IntegratedType>>` lookup table built once would eliminate this.

### 4.10 Minor: std::set instead of std::unordered_set — REMAINS

Several internal sets (`phi_blocks`, `phi_result_ids`, `phi_results`, `alive_phis`,
`worklist`, `referenced_from_insts`) use `std::set` (O(log N)) rather than
`std::unordered_set` (O(1) amortized). Not quadratic but adds log-factor overhead.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 4.6 | Add `std::unordered_map<int, int> phi_index_by_result_id_` to `IRBlock` for O(1) phi lookup | O(P²) → O(P) per block |
| 4.8 | Cache previous-block results per (start, target) pair if called repeatedly | O(B²) → O(B) |
| 4.9 | Build a `map<int, shared_ptr<IntegratedType>>` for alloca types once in `RunOnFunction` | O(A·P) → O(A) |
| 4.10 | Replace `std::set` with `std::unordered_set` for internal mem2reg sets | O(log N) → O(1) |

---

## 5. Code Generation & Register Allocation — Primary Remaining O(V²) Bottleneck

**Status: MOSTLY UNCHANGED** — core algorithms unchanged. The "remove wasteful move"
commit (9a62988) improved assembly quality (compute directly into destination register
for binary ops) but did not change the register allocator's algorithmic complexity.

### 5.1 Liveness Analysis: O(B·I·V log V) with std::set Operations

**File:** [register_allocator.cpp:190-404](codegen/src/register_allocator.cpp#L190-L404)

The worklist-based dataflow analysis uses `std::set<int>` for liveness sets
(`live_in_`, `live_out_`, `block_defs_`, `block_uses_` — all `map<int, set<int>>`
at [register_allocator.h:57-62](codegen/include/register_allocator.h#L57-L62)).
Each iteration does:
- **Set union** over all successors: O(V log V) insertions per block
- **Set difference** (live_out \ defs): O(V log V) per block
- **Set comparison** (new ≠ old): O(V) per block

For I iterations (up to CFG depth in worst case) with B blocks: **O(B·I·V log V)**.

### 5.2 Interference Graph: O(I·V) Def-Live Pairing + O(M²) Cross-Move

**File:** [register_allocator.cpp:559-571](codegen/src/register_allocator.cpp#L559-L571)

```cpp
for (int def : inst_defs) {
    for (int live : currently_live) {   // nested: |defs| × |currently_live|
        interference_[def].insert(live);    // O(log V) each
        interference_[live].insert(def);
    }
}
```

At the bottom of blocks where many variables are simultaneously live, this is
**O(V²)** pair insertions, each a `std::set::insert` (O(log V)).

**Cross-move interference** ([register_allocator.cpp:663-692](codegen/src/register_allocator.cpp#L663-L692)):
nested `for (i) for (j = i+1)` over M move instructions in a block → **O(M²)**.

**Phi-result mutual interference** ([register_allocator.cpp:600-607](codegen/src/register_allocator.cpp#L600-L607)):
nested `for (r1) for (r2)` over P phi results in a block → **O(P²)**.

### 5.3 Simplify: O(V²) Worst-Case Node Removal

**File:** [register_allocator.cpp:768-801](codegen/src/register_allocator.cpp#L768-L801)

In dense interference graphs where few nodes have degree < K, each outer iteration
removes only a few nodes, scanning the entire remaining worklist (`std::set<int>`)
each time → **O(V²)** worst-case. Uses `current_degree_` cache for O(1) degree lookup
([register_allocator.cpp:729-739](codegen/src/register_allocator.cpp#L729-L739)).

### 5.4 AssignColors Validation Pass: O(E) = O(V²)

**File:** [register_allocator.cpp:1028-1043](codegen/src/register_allocator.cpp#L1028-L1043)

After coloring, every interference edge is traversed to verify no adjacent nodes share
a color. For dense graphs, this is O(V²). Debug-only; removable in release builds.

### 5.5 GetSize() / GetAlignment() Without Caching

**File:** [code_generator.cpp:44-99](codegen/src/code_generator.cpp#L44-L99) — `GetSize()`,
[code_generator.cpp:101-133](codegen/src/code_generator.cpp#L101-L133) — `GetAlignment()`

Both recursively compute struct field layout **without caching**. Called from:
- `MemAlloc` for every alloca, parameter, and IR result ([code_generator.cpp:171-276](codegen/src/code_generator.cpp#L171-L276))
- Instruction emission for `two_var_binary_operation_`, `variable_store_`, etc.
- `VariableAssignment` for stack-to-register moves

For F-field structs accessed V times: **O(F·V)** instead of O(F) with caching.

### 5.6 Coalescing Implemented But Disabled

**File:** [register_allocator.cpp:806](codegen/src/register_allocator.cpp#L806)

`Coalesce()` immediately returns `false`, with Briggs and George conservative tests
fully implemented but disabled. Enabling it would reduce the number of move instructions
and the interference graph density, speeding up both Simplify and AssignColors.

### 5.7 PhiToMove / EliminateCycles: O(N·E) Per Function

**File:** [code_generator.h:386-440](codegen/include/code_generator.h#L386-L440)

`AssignmentGraph::EliminateCycles` loops `while (true)` with each iteration scanning
all `max_n_` nodes (where `max_n_ = var_id << 1`). For a fully-cyclic phi-move graph,
each iteration removes one edge via a temporary variable → **O(N·E)**. The graph
pre-allocates `var_id << 1` nodes even when only a small fraction are used.

### 5.8 Data Structures: std::map / std::set Throughout

All register allocator data structures use tree-based containers:

| Structure | Type | Location |
|-----------|------|----------|
| `live_in_`, `live_out_` | `map<int, set<int>>` | [register_allocator.h:57-58](codegen/include/register_allocator.h#L57-L58) |
| `block_defs_`, `block_uses_` | `map<int, set<int>>` | [register_allocator.h:61-62](codegen/include/register_allocator.h#L61-L62) |
| `interference_` | `map<int, set<int>>` | [register_allocator.h:72](codegen/include/register_allocator.h#L72) |
| `move_edges_` | `map<int, set<int>>` | [register_allocator.h:73](codegen/include/register_allocator.h#L73) |
| `allocatable_vars_` | `set<int>` | [register_allocator.h:65](codegen/include/register_allocator.h#L65) |
| `worklist_` | `set<int>` | [register_allocator.h:78](codegen/include/register_allocator.h#L78) |
| `location_` | `map<int, pair<bool, int>>` | [code_generator.h:339](codegen/include/code_generator.h#L339) |

Since variable IDs are contiguous integers starting from 0 within each function,
all of these could be `vector<bool>` (bitset), `vector<int>`, or `vector<vector<int>>`
with O(1) indexing instead of O(log V) tree operations.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 5.1 | **Use bitsets** (`vector<uint64_t>` or `boost::dynamic_bitset`) for liveness sets — union/intersection/difference become single-word bitwise operations | O(V log V) → O(V/64) per set operation |
| 5.2 | **Use index-based vectors** (`vector<vector<int>>`) for interference graph instead of `map<int, set<int>>` — variable IDs are already dense integers | O(log V) → O(1) per edge insertion/lookup |
| 5.8 | Replace `set<int>` allocatable_vars_ / worklist_ with `vector<bool>` presence + `vector<int>` list | O(log V) → O(1) membership |
| 5.4 | Remove or `#ifndef NDEBUG`-guard the AssignColors validation pass | Eliminates O(E) overhead in release |
| 5.5 | Memoize `GetSize()` / `GetAlignment()` by `IntegratedType*` in a `static unordered_map` | O(F·V) → O(F) |
| 5.6 | Debug and enable coalescing | Reduces graph density → faster coloring |
| 5.7 | Allocate `AssignmentGraph` nodes lazily based on actual phi variable count | Reduces EliminateCycles scan size |

---

## Summary: Ranked Impact on Compile Time

Each item ranked by estimated contribution to total compile time for the current 50-test
IR-1 batch, **after** the mem2reg O(N²)→O(N) optimization.

| Rank | Component | Issue | Current Complexity | Target | Est. Speedup |
|------|-----------|-------|--------------------|--------|-------------|
| **1** | Register Allocator | 5.1+5.2+5.8: std::set/map-based liveness + interference (use bitsets + index vectors) | O(V log V) set ops | O(V/64) bitwise | **2–4×** |
| **2** | Lexer | 1.1: 12 pattern attempts per token (first-char dispatch) | 12× per token | 2–3× per token | **2–4×** |
| **3** | Parser | 2.1: Exception-based backtracking | ~1000 cycles/throw | ~1 cycle/branch | **1.5–3×** |
| **4** | Semantic | 3.1+3.2: Scope walking + linear associated-item scans | O(N·D) + O(M·S) | O(N) | **1.2–2×** |
| **5** | Parser | 2.2: Per-node heap allocation (arena) | malloc per node | bump pointer | **1.2–1.5×** |
| **6** | IR Gen | 4.8: GetPreviousBlockHelper DFS | O(D·B) per call | cached O(1) | **1.1–1.3×** |
| 7 | Codegen | 5.5: Uncached GetSize | O(F·V) | O(F) | marginal |
| 8 | IR Gen | 4.6: AddPhi linear search | O(P²) per block | O(P) | marginal |
| 9 | Codegen | 5.6: Enable coalescing | Reduces graph density | — | marginal |
| 10 | Semantic | 3.4: IntegratedType pooling | ~45+ alloc sites | pool | marginal |
| 11 | Mem2Reg | 4.9+4.10: Minor std::set + alloca lookup | O(log N) factor | O(1) | marginal |

### Changes from Previous Analysis

The mem2reg optimization (commit `e10f241`) was the single most impactful change,
eliminating three O(N²) patterns that were previously ranked #1. Specifically:

| Section | Issue | Previous | Current |
|---------|-------|----------|---------|
| ~~4.1~~ | ~~IsPromotable full-IR scan per alloca~~ | **O(N²)** | ✓ O(N) |
| ~~4.2~~ | ~~CollectStoresAndLoads full-IR scan per alloca~~ | **O(N²)** | ✓ O(N) |
| ~~4.3~~ | ~~ReplaceAllUses full-IR scan per replaced value~~ | **O(N²)** | ✓ O(N) |
| ~~4.5~~ | ~~RemoveDeadPhis fixed-point full re-scans~~ | **O(P·I)** | ✓ O(I+P) |

The **register allocator** is now the #1 remaining bottleneck, followed by the
**lexer constant factor** and **parser exception overhead**.

### Recommended Implementation Order

1. **Register allocator bitsets + index vectors** — The #1 remaining bottleneck.
   Replace `std::set<int>` with bitsets for liveness, `vector<vector<int>>` for
   interference graph. Major speedup for functions with many variables.

2. **Lexer first-char dispatch** — Easy to implement, high payoff. Replace the
   12-way brute-force `GetNext()` with a `switch` on the first character.

3. **Parser exception elimination** — Replace `throw`/`catch` with a result-type
   return (`optional`/`expected`). Touches many files but each change is mechanical.

4. **Semantic caching** — Add resolved-name memoization and an `all_items_visited_` flag.

5. **Arena allocator** — Invest in a bump-pointer arena for AST nodes.

6. **Codegen GetSize caching** — Memoize struct layout computation.

7. **IR minor fixes** — AddPhi hash map, GetPreviousBlockHelper caching.

### Interaction with plan.md

The existing [plan.md](plan.md) targets **code-size reduction** (assembly output
optimization). This plan targets **compile-time reduction** (how fast the compiler
runs). The two are complementary:

- The mem2reg O(N²)→O(N) fix (Section 4) was a prerequisite for [plan.md Phase 6.7](plan.md)
  (mem2reg/SSA) to be usable without exploding compile time. Now that it's done,
  further mem2reg improvements are viable.
- [plan.md Phase 3.1](plan.md) (move coalescing) is implemented but disabled
  ([register_allocator.cpp:806](codegen/src/register_allocator.cpp#L806)). Enabling it
  (Section 5.6 here) helps both compile-time (less graph density) and code-size.
- [plan.md Phase 6.1](plan.md) (array loop init) would mitigate Section 3.3's O(N)
  array expansion during semantic analysis.


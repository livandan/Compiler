# Compile-Time Performance Optimization Plan

Analysis of the rx-Compiler's **running time complexity** — where the compiler spends
CPU cycles during compilation, and which parts have poor algorithmic scaling.

---

## Overall Pipeline & Where Time Goes

```
Source (.rx) → Lexer → Tokens → Parser → AST → Semantic → IR → Codegen → Assembly (.s)
                  |          |        |        |        |         |
               O(N)·C    O(N)·E    O(N·D)  O(N·D)  O(N²)★   O(V²)★
                lexer    parser    scope   type     mem2reg   reg-alloc
```

**Key:** `N` = source size, `C` = constant blowup, `E` = exception overhead,
`D` = nesting depth, `V` = variable count, ★ = dominant bottleneck

The compiler is **asymptotically O(N) through the IR generation step** (with
sub-quadratic constant factors), then hits **O(N²) bottlenecks in mem2reg and
register allocation**, which dominate compile time for large programs.

---

## 1. Lexer — O(N) with ~12× Constant Blowup Per Token

### 1.1 Brute-Force Longest-Match: 12 Token Pattern Attempts Per Position

**File:** [regex_matcher.cpp](IR/src/../lexer/src/regex_matcher.cpp#L260-L331) — `GetNext()`

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
a string literal).

**The `[\s]*` bug:** The whitespace pattern uses `*` (zero-or-more) instead of `+`
(one-or-more), so it **always succeeds** with a zero-length match at every position.

### 1.2 Per-Token String Copying in MatchResult

**File:** [regex_matcher.cpp](IR/src/../lexer/src/regex_matcher.cpp#L11-L12)

Every match copies the matched text into `MatchResult::matched_str_` (`std::string`).
In `GetNext()`, the copy happens **again** each time a "longer" match supersedes the
current best (`result = tmp`). Each `Token` constructor then copies the string a third
time. For a 100KB source file, this is ~3× total source size in string copies.

### 1.3 GetIntType() Called in Loop Condition

**File:** [token.cpp](IR/src/../lexer/src/token.cpp#L27-L88) — `GetInt()`

`GetIntType()` (which calls `str_.substr()` to create temporary heap strings) is
invoked in the `for`-loop condition of every integer conversion loop iteration.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 1.1a | **First-char dispatch**: switch on `str_[ptr_]` to try only matching patterns (e.g., `r` → raw string, `"` → string, digit → integer, letter → identifier/keyword, etc.) | ~10× per-token speedup |
| 1.1b | Fix `STR_WHITESPACE` to `[\s]+` | Eliminates one always-successful regex call per token |
| 1.2 | Use `std::string_view` / offset+length in `MatchResult` instead of copying | ~3× fewer string allocs |
| 1.3 | Cache `GetIntType()` result in a member variable | Negligible but zero-cost fix |
| 1.x | Replace boost::regex with hand-written DFA/scanner | Eliminates regex engine overhead entirely |

---

## 2. Parser — O(N) with Exception-Based Backtracking

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
A `std::unordered_set<std::string>` would make this O(1) amortized.

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
walks the chain twice.

### 3.2 Linear Scan of All Associated Items at Every Call Site (O(M·S))

**File:** [value_type.cpp:1384-1423](semantic/src/value_type.cpp#L1384-L1423) and similar

For struct methods, the guard check that triggers lazy type-visiting scans **all S
associated items** to find any that are still unvisited:

```cpp
for (const auto &item : struct_ptr->associated_items_) {
    if (item.second.node->integrated_type_ == nullptr || ...) {
        // lazy-visit ALL associated items
        break;
    }
}
```

If a struct has S methods called M times total, cost is **O(M·S)**. When both scale
with program size, this is **O(N²)**. Same pattern in `path_in_expr`, `call_expr`,
`field_expr`, and `struct_expr`.

### 3.3 O(N) Array Literal Expansion During Semantic Analysis

**File:** [value_type.cpp:919-921](semantic/src/value_type.cpp#L919-L921)

`[expr; N]` array repeat syntax creates N copies of `Value` in a vector at
semantic-analysis time. Each `Value` copy may recursively copy maps and strings.
For `[0; 100000]`, this is 100,000 deep copies of `Value` objects.

### 3.4 Excessive shared_ptr<IntegratedType> Allocations

Nearly every expression handler calls `std::make_shared<IntegratedType>()`, which
heap-allocates and initializes a `possible_types` hash set (with all 4 integer types)
even for non-integer types like `bool`, `unit`, `char`.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 3.1 | Add per-ScopeNode `resolved_names` cache (`unordered_map<string, ScopeNodeContent>`) that memoizes chain-walk results; invalidate on new symbol insertion | O(N·D) → O(N) |
| 3.2 | Replace linear scan guard with a `bool all_items_visited_` flag on struct types | O(M·S) → O(M) |
| 3.3 | Defer array repeat expansion to IR/codegen; store `(expr, count)` as a lazy thunk | O(array_size) → O(1) at semantic time |
| 3.4 | Use an object pool or pre-allocated `IntegratedType` for common types (i32, bool, unit, etc.) | Fewer heap allocations |

---

## 4. IR Generation & Mem2Reg — **Primary O(N²) Bottleneck**

### 4.1 IsPromotable: Full IR Scan Per Alloca (O(A·I) = O(N²))

**File:** [mem2reg.cpp](IR/src/mem2reg.cpp) — `Mem2Reg::IsPromotable()`

For **each alloca** (A total), the function scans **every instruction in every block**
(I total) plus **every phi condition in every block** to check for prohibited uses.
Cost: **O(A·I)**. With A and I both proportional to program size N, this is **O(N²)**.

### 4.2 PromoteAlloca — CollectStoresAndLoads: Another Full Scan Per Alloca (O(A·I))

**File:** [mem2reg.cpp](IR/src/mem2reg.cpp) — Step 1 of `PromoteAlloca()`

Each alloca triggers a scan of all instructions to find matching stores/loads.
Same O(A·I) = O(N²) pattern as IsPromotable.

### 4.3 ReplaceAllUses: Full IR Scan Per Replaced Value (O(L·I) = O(N²))

**File:** [mem2reg.cpp](IR/src/mem2reg.cpp) — `Mem2Reg::ReplaceAllUses()`

For **each old value ID** being replaced, the function scans all blocks, all phi
conditions, and all instructions to find and replace uses. If L values are replaced,
cost is **O(L·I)**. With L proportional to I, this is **O(N²)**.

### 4.4 AddPhi: Linear Search by result_id Per Phi Insertion (O(P²) Per Block)

**File:** [IR_generator.h:268-297](IR/include/IR_generator.h#L268-L297) — `IRBlock::AddPhi()`

Each phi insertion linearly scans `phi_instructions_` by `result_id`. For P phi nodes
in a block, total insertion cost is 1+2+...+P = **O(P²)**. When many allocas converge
in the same loop header, P is large.

### 4.5 RemoveDeadPhis: Fixed-Point Iteration with Full Re-Scans (O(P·I))

**File:** [mem2reg.cpp](IR/src/mem2reg.cpp) — `Mem2Reg::RemoveDeadPhis()`

The dead-phi elimination loops to a fixed point, rescanning all instructions on each
iteration. In pathological phi-dependency chains, up to P iterations → **O(P·I)**.

### 4.6 ComputeDominanceFrontier (O(B²))

**File:** [mem2reg.cpp](IR/src/mem2reg.cpp) — Standard dominance frontier algorithm.

For blocks with multiple predecessors, the inner `while` loop walks up the dominator
tree. Worst-case **O(B²)** for programs with deeply nested merge structures.

### 4.7 GetPreviousBlockHelper: DFS Per Short-Circuit/If-Else (O(B²) Total)

**File:** [IR_generator.cpp](IR/src/IR_generator.cpp) — `GetPreviousBlockHelper()`

Called for every if-else merge and short-circuit logic operator (`&&`, `||`). Each call
does a recursive DFS from `start_block` following control-flow edges. For D levels of
nesting, total is **O(D·B)**, worst-case **O(B²)**.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 4.1+4.2+4.3 | **Build a use-list (def-use chain)**: maintain a reverse mapping `var_id → [{block, instr_idx, operand_idx}]` updated on each IR instruction creation. `IsPromotable`, `CollectStoresAndLoads`, and `ReplaceAllUses` all become O(uses) instead of O(I_total) | O(N²) → O(N) for mem2reg core |
| 4.4 | Add `std::unordered_map<int, int> phi_index_by_result_id_` to `IRBlock` for O(1) phi lookup | O(P²) → O(P) per block |
| 4.5 | Use worklist-based dead-phi elimination: only re-check users of a deleted phi, not all instructions | O(P·I) → O(P + users) |
| 4.6 | Dominance frontier computation is standard O(B²); acceptable for typical CFGs | — |
| 4.7 | Cache previous-block results per (start, target) pair if called repeatedly | O(B²) → O(B) |

---

## 5. Code Generation & Register Allocation — O(V²) Graph Coloring

### 5.1 Liveness Analysis: O(B·I·V log V) with Set Operations

**File:** [register_allocator.cpp:190-404](codegen/src/register_allocator.cpp#L190-L404)

The worklist-based dataflow analysis uses `std::set<int>` for liveness sets. Each
iteration does:
- **Set union** over all successors: O(V log V) insertions per block
- **Set difference** (live_out \ defs): O(V log V) per block
- **Set comparison** (new ≠ old): O(V) per block

For I iterations (up to CFG depth in worst case) with B blocks: **O(B·I·V log V)**.
For large functions with many variables, this is a significant cost.

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

Cross-move interference ([register_allocator.cpp:663-692](codegen/src/register_allocator.cpp#L663-L692)):
nested `for (i) for (j = i+1)` over M move instructions in a block → **O(M²)**.

### 5.3 Simplify: O(V²) Worst-Case Node Removal

**File:** [register_allocator.cpp:768-801](codegen/src/register_allocator.cpp#L768-L801)

In dense interference graphs where few nodes have degree < K, each outer iteration
removes only a few nodes, scanning the entire remaining worklist each time →
**O(V²)** worst-case.

### 5.4 AssignColors Validation Pass: O(E) = O(V²)

**File:** [register_allocator.cpp:1028-1043](codegen/src/register_allocator.cpp#L1028-L1043)

After coloring, every interference edge is traversed to verify no adjacent nodes share
a color. For dense graphs, this is O(V²).

### 5.5 GetSize() / GetAlignment() Without Caching

**File:** [code_generator.cpp:44-99](codegen/src/code_generator.cpp#L44-L99)

`GetSize()` recursively computes struct field layout each time it's called, with
**no caching**. Called once per alloca, parameter, and IR result — if many variables
share the same struct type, the same layout is recomputed each time. For F-field
structs accessed V times: **O(F·V)** instead of O(F).

### 5.6 Coalescing Implemented But Disabled

**File:** [register_allocator.cpp:806](codegen/src/register_allocator.cpp#L806)

`Coalesce()` immediately returns `false`, with Briggs and George conservative tests
fully implemented but disabled ("coalescing may introduce subtle bugs"). Enabling
it would reduce the number of move instructions and the interference graph density.

### Recommended Fixes

| # | Fix | Complexity Gain |
|---|-----|----------------|
| 5.1 | Use bitsets (`std::bitset<MAX_VARS>` or `boost::dynamic_bitset`) instead of `std::set<int>` for liveness sets — union/intersection become single-word bitwise operations | O(V log V) → O(V/64) per operation |
| 5.2 | Use adjacency vectors (`vector<vector<int>>`) instead of `map<int, set<int>>` for interference graph | O(log V) → O(1) per edge insertion |
| 5.3 | Simplify is bounded by graph density; acceptable for typical code | — |
| 5.4 | Remove validation pass in release builds (debug-only) | Eliminates O(E) overhead |
| 5.5 | Memoize `GetSize()` / `GetAlignment()` by `IntegratedType*` in a `std::unordered_map` | O(F·V) → O(F) |
| 5.6 | Debug and enable coalescing | Reduces graph density → faster coloring |

---

## Summary: Ranked Impact on Compile Time

Each item ranked by estimated contribution to total compile time for a large (50-test)
batch run.

| Rank | Component | Issue | Complexity | Est. Speedup |
|------|-----------|-------|-----------|-------------|
| **1** | Mem2Reg | 4.1+4.2+4.3: Repeated full-IR scans per alloca | O(N²) → O(N) | **3–10×** |
| **2** | Register Allocator | 5.1: std::set-based liveness (use bitsets) | O(V log V) → O(V/64) | **2–5×** |
| **3** | Lexer | 1.1: 12 pattern attempts per token (first-char dispatch) | 12× → 2–3× per token | **2–4×** |
| **4** | Parser | 2.1: Exception-based backtracking | ~1000 cycles/throw → ~1 cycle/branch | **1.5–3×** |
| **5** | Semantic | 3.1+3.2: Scope walking + linear associated-item scans | O(N·D) → O(N) | **1.2–2×** |
| **6** | Register Allocator | 5.2: O(V²) interference graph insertion (use vectors) | O(log V) → O(1) per insert | **1.2–1.5×** |
| **7** | Parser | 2.2: Per-node heap allocation (arena) | malloc → bump pointer | **1.1–1.3×** |
| 8 | Codegen | 5.5: Uncached GetSize | O(F·V) → O(F) | marginal |
| 9 | IR Gen | 4.4: AddPhi linear search | O(P²) → O(P) | marginal |
| 10 | Codegen | 5.6: Enable coalescing | Reduces graph density | marginal |

### Recommended Implementation Order

1. **Mem2Reg use-lists** — The single highest-impact fix. Building def-use chains transforms
   the dominant O(N²) bottleneck into O(N). This alone may cut compile time by 50–70%.

2. **Lexer first-char dispatch** — Easy to implement, high payoff. Replace the 12-way
   brute-force attempt with a `switch` on the first character to only try matching
   patterns.

3. **Register allocator bitsets** — Replace `std::set<int>` liveness with bitsets for
   union/intersection/difference operations. Major speedup for large functions.

4. **Parser exception elimination** — Replace `throw`/`catch` with a result-type return.
   Touches many files but each change is mechanical.

5. **Semantic caching** — Add resolved-name memoization and an `all_items_visited_` flag.

6. **Arena allocator** — Invest in a bump-pointer arena for AST nodes to eliminate
   per-node malloc overhead.

### Interaction with Existing plan.md

The existing [plan.md](plan.md) targets **code-size reduction** (assembly output
optimization). This plan targets **compile-time reduction** (how fast the compiler
runs). The two are complementary:

- **plan.md Phase 6.7 (mem2reg)** would actually *increase* compile time under the
  current O(N²) implementation. Fixing the O(N²) patterns in this plan's Section 4
  is a prerequisite for enabling mem2reg without exploding compile time.
- **plan.md Phase 3.1 (move coalescing)** is already implemented but disabled
  ([register_allocator.cpp:806](codegen/src/register_allocator.cpp#L806)). Enabling it
  (Section 5.6 here) helps both plans.
- **plan.md Phase 6.1 (array loop init)** would mitigate Section 3.3's O(N) array
  expansion during semantic analysis.


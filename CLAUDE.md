# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A compiler for a simplified Rust-like language (`.rx` source files) targeting RISC-V 32-bit. This is a course project (ACM Class 2025). The compiler produces custom IR (LLVM-like), then translates it to RISC-V assembly, executed via the `reimu` simulator.

## Build & Test

```bash
# Configure and build
cmake -S . -B cmake-build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build cmake-build-debug

# Run individual test suites
./cmake-build-debug/semantic_tests    # Parser + semantic analysis
./cmake-build-debug/IR_tests          # Through IR generation (outputs .ll files)
./cmake-build-debug/codegen_tests     # Through RISC-V codegen (outputs .s files)

# Full pipeline test (IR → clang → reimu → diff)
bash run.sh
```

Tests use Google Test. Test cases live in `RCompiler-Testcases/` (`.rx` source, `.ll` expected IR, `.in` input, `.out` expected output). Individual test runs can be done via `--gtest_filter`:

```bash
./cmake-build-debug/IR_tests --gtest_filter="IRTestSingle.*"
./cmake-build-debug/codegen_tests --gtest_filter="CodegenTestSingle.*"
```

## Architecture: Compiler Pipeline

```
Source (.rx) → Lexer → Tokens → Parser → AST → Semantic (SymbolVisitor → ValueTypeVisitor)
                                                      ↓
                                              IRVisitor (→ .ll output)
                                                      ↓
                                              CodeGenerator (→ .s RISC-V output)
```

### 1. Lexer (`lexer/`)

`Tokenizer` converts source text into `Token` objects using `boost::regex` (via `regex_matcher.cpp`), with manual handling for raw string literals, raw C-string literals, and block comments.

### 2. Parser (`parser/`)

`Builder` drives parsing and returns the root `Crate*` AST node. Uses **Pratt Parsing** for expression-with-infix, **top-down parsing** for everything else. AST nodes extend the `Node` base class (`node.h`). The AST is a tree where parents point to children (`children_`, `type_` vectors). `NodeType` enum (in `node.h`) categorizes every AST node variant.

### 3. Semantic Analysis (`semantic/`)

Two visitor passes managed by `VisitorManager`:

- **SymbolVisitor** (`scope.h/cpp`) — Builds a scope tree. Scope node pointers go child→parent (opposite of AST). Each AST node holds a `scope_node_` pointer back to its scope. `ScopeNode` has separate `type_namespace` and `value_namespace` maps (Rust-style name resolution).
- **ValueTypeVisitor** (`value_type.h/cpp`) — Type inference/checking. Each AST node gets an `IntegratedType` (wrapping `BasicType`, mutability, integer width resolution, array/pointer element types, struct/enum references).

The `Visitor` base class (`visitor_frame.h`) defines a pure virtual `Visit()` for every AST node type. New visitors extend this.

### 4. IR Generation (`IR/`)

`IRVisitor` (extends `Visitor`) walks the AST and populates internal IR structures: `IRFunction`, `IRBlock`, `IRInstruction`. The IR is a custom three-address-code with ~30 instruction types (binary ops, branches, calls, loads/stores, phi, select, etc.) defined in `IR_generator.h`. The `Output()` method prints LLVM-like `.ll` text.

### 5. Code Generation (`codegen/`)

`CodeGenerator` takes the IR structures from `IRVisitor` (`GetIRFunctions()`, `GetIRStructs()`, `GetMainFuncID()`) and translates them to RISC-V 32-bit assembly. Handles register allocation, stack frame layout (alloca space + spilled params + variables), and move instruction resolution before jumps. `Output()` writes RISC-V `.s` text.

### Entry Point (`front_end_entry/`)

`FrontEndRunner::Run()` orchestrates the full pipeline: Tokenize → Parse → Semantic check → IR generate → Output IR. The `codegen_test.cpp` manually adds the CodeGenerator step after IR generation.

## Key Design Patterns

- **Visitor pattern**: All passes (Symbol, ValueType, IR, Codegen) are visitors over the AST. The `Visitor` base class in `visitor_frame.h` has one Visit method per AST node type. New passes add new visitor subclasses.
- **IntegratedType**: A shared_ptr-held type descriptor on every AST node, representing resolved/partially-resolved types including integer width (i32/u32/isize/usize), constness, mutability, and compound type info.
- **Value**: A union-like struct on AST nodes for compile-time constant values (integers, strings, arrays, structs).
- **Scope resolution**: `ScopeNode::FindInType()` / `FindInValue()` walk the parent chain (child→parent scope tree) to resolve names.

## Important Constraints (from RCompiler-FAQ)

- Source code limited to 1MB; only ASCII ≤ 127
- No macros, closures, `for` loops (iterator), `?` operator, Turbofish, lifetime annotations, unsafe
- No panic-recovery required (UB includes division by zero, out-of-bounds access)
- Identifiers: first char must be alphabetic, rest alphanumeric/underscore, case-sensitive, ≤ 64 chars
- Only C++-style non-doc comments (`//` and `/* */`)
- Evaluation order: left-to-right for operands

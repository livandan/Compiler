#ifndef REGISTER_ALLOCATOR_H
#define REGISTER_ALLOCATOR_H

#include "IR_generator.h"
#include "code_generator.h"
#include <map>
#include <vector>
#include <cstdint>

class RegisterAllocator {
public:
  RegisterAllocator(const IRFunctionNode &ir_func,
                    RISCVFunctionNode &riscv_func,
                    bool is_leaf = false);
  void Run();

private:
  // Step 0: Initialize vectors/bitsets
  void ComputeMaxVarId();
  void InitializeVectors();

  // Step 1: Build CFG and compute liveness
  void BuildCFG();
  void ComputeLiveness();
  void ComputeSpillCosts();
  void RebuildAllocatableNodes();

  // Step 2: Build the interference graph
  void BuildInterferenceGraph();
  void AddInterference(int lhs, int rhs);

  // Step 3: Chaitin-Briggs graph coloring
  void ColorGraph();

  // Coloring sub-phases
  void Simplify();
  bool Coalesce();
  void Freeze();
  void SelectSpill();
  void AssignColors();

  // Helpers
  static bool IsScalarType(const std::shared_ptr<IntegratedType> &type);
  int  GetDegree(int node) const;
  int  GetSignificantDegree(int node, int k) const;
  bool BriggsTest(int u, int v, int k) const;
  bool GeorgeTest(int u, int v, int k) const;
  void CoalesceNodes(int u, int v);
  int  SelectSpillCandidate() const;
  void UpdateLocationMap();

  // Classify variables
  void ClassifyVariables();

  // ---- Bitset helpers (all inline, operate on bitset_words_ words) ----
  // Each helper silently ignores out-of-range ids because some IR
  // instruction fields are overloaded (e.g. result_id_ holds a size
  // in builtin_memset_, not a variable id).
  void BitSet(std::vector<uint64_t> &bs, int id) const {
    if (id < 0 || id > max_var_id_) return;
    bs[static_cast<size_t>(id) >> 6] |= (1ULL << (static_cast<size_t>(id) & 63));
  }
  void BitClear(std::vector<uint64_t> &bs, int id) const {
    if (id < 0 || id > max_var_id_) return;
    bs[static_cast<size_t>(id) >> 6] &= ~(1ULL << (static_cast<size_t>(id) & 63));
  }
  bool BitTest(const std::vector<uint64_t> &bs, int id) const {
    if (id < 0 || id > max_var_id_) return false;
    return (bs[static_cast<size_t>(id) >> 6] >> (static_cast<size_t>(id) & 63)) & 1ULL;
  }
  void BitOr(std::vector<uint64_t> &dest, const std::vector<uint64_t> &src) const {
    for (int i = 0; i < bitset_words_; ++i) dest[i] |= src[i];
  }
  void BitSubtract(std::vector<uint64_t> &dest, const std::vector<uint64_t> &src) const {
    for (int i = 0; i < bitset_words_; ++i) dest[i] &= ~src[i];
  }
  bool BitEqual(const std::vector<uint64_t> &a, const std::vector<uint64_t> &b) const {
    for (int i = 0; i < bitset_words_; ++i) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  std::vector<uint64_t> MakeBitSet() const {
    return std::vector<uint64_t>(bitset_words_, 0);
  }

  const IRFunctionNode &ir_func_;
  RISCVFunctionNode &riscv_func_;
  bool is_leaf_;

  // ---- Sizing ----
  int max_var_id_ = -1;
  int bitset_words_ = 0;

  // ---- CFG (block-indexed, B is small so map is fine) ----
  std::map<int, std::vector<int>> successors_;
  std::map<int, std::vector<int>> predecessors_;

  // ---- Liveness: per-block bitsets ----
  std::map<int, std::vector<uint64_t>> live_in_;
  std::map<int, std::vector<uint64_t>> live_out_;
  std::map<int, std::vector<uint64_t>> block_defs_;
  std::map<int, std::vector<uint64_t>> block_uses_;

  // ---- Classification bitsets ----
  std::vector<uint64_t> is_allocatable_;
  std::vector<uint64_t> is_stack_bound_;
  std::vector<int> var_size_;           // 0 = not set, 4 or 8
  std::vector<int> allocatable_nodes_;
  std::vector<long long> spill_cost_;

  // ---- Interference graph: adjacency lists ----
  std::vector<std::vector<int>> interference_;
  // Used only while initially building interference_ to avoid inserting the
  // same edge many times before the final adjacency-list cleanup.
  std::vector<std::vector<uint64_t>> interference_bits_;
  std::vector<std::vector<int>> move_edges_;

  // ---- Chaitin-Briggs worklists (bitsets + plain vectors) ----
  std::vector<uint64_t> in_worklist_;
  std::vector<uint64_t> is_spilled_;
  std::vector<uint64_t> in_move_related_;
  std::vector<int> current_degree_;     // -1 = not in worklist
  std::vector<int> select_stack_;
  std::vector<int> coalesced_rep_;      // -1 = not coalesced
  std::vector<int> assignment_;         // -2 = unassigned, -1 = spill, >=0 = phys reg

  // ---- Scratch bitset reused in dataflow loop ----
  std::vector<uint64_t> scratch_bs_;

  // ---- Available physical registers ----
  std::vector<int> allocatable_regs_;

  static constexpr int SCRATCH_REGS[] = {5, 6, 7, 31}; // t0, t1, t2, t6

  static bool IsReservedReg(int reg) {
    return reg == 0 || reg == 1 || reg == 2 || reg == 3 || reg == 4;
  }

  static bool IsScratchReg(int reg) {
    return reg == 5 || reg == 6 || reg == 7 || reg == 31;
  }
};

#endif

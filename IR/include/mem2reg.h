#ifndef MEM2REG_H
#define MEM2REG_H

#include "IR_generator.h"
#include <map>
#include <vector>
#include <set>
#include <unordered_map>

void Mem2RegThrow(const std::string &err_info);

// A reaching definition: a variable ID, a constant value, or nothing (undef).
struct ReachingDef {
  bool valid = false;
  bool is_constant = false; // true if the reaching def is a literal constant
  int var_id = -1;          // valid when valid && !is_constant
  int const_value = 0;      // valid when valid && is_constant

  static ReachingDef Var(int id) {
    ReachingDef d;
    d.valid = true;
    d.is_constant = false;
    d.var_id = id;
    return d;
  }
  static ReachingDef Const(int val) {
    ReachingDef d;
    d.valid = true;
    d.is_constant = true;
    d.const_value = val;
    return d;
  }
  static ReachingDef Undef() {
    ReachingDef d;
    d.valid = false;
    return d;
  }
};

// A use-site of a variable: records where a variable ID is referenced,
// so we can visit only the relevant instructions instead of scanning all.
struct UseSite {
  int block_id;
  bool is_phi;  // true → phi_instructions_, false → instructions_
  int index;    // index within the vector
};

class Mem2Reg {
public:
  explicit Mem2Reg(IRVisitor &IR_generator);
  void Run();

private:
  void RunOnFunction(IRFunctionNode &func);

  // --- CFG ---
  void BuildCFG();

  // --- Lengauer-Tarjan dominator algorithm ---
  void ComputeDominators();
  void DFS(int block_id);
  int Find(int v_idx);
  void Union(int u_idx, int v_idx);

  // --- Dominance frontier ---
  void ComputeDominanceFrontier();

  // --- Use-list: O(1) access to all use sites of a variable ---
  // Built once per function; transforms O(N²) full-IR scans into O(uses)
  // lookups for IsPromotable, CollectStoresAndLoads, and ReplaceAllUses.
  void BuildUseList();

  // --- Alloca promotion analysis ---
  bool IsPromotable(int alloca_id) const;

  // --- SSA construction for one alloca ---
  bool PromoteAlloca(int alloca_id);

  // --- Instruction rewriting helpers ---
  void ReplaceAllUses(int old_id, const ReachingDef &new_def);

  // --- Cleanup ---
  void RemoveDeadInstructions() const;
  void RemoveDeadPhis();
  void SimplifyCFG();
  bool SimplifyPhiCopies();
  bool PropagateCopyAliases();
  bool RemoveTrivialSelects();
  bool EliminateTrivialPhis();
  bool MergePhiOnlyBlock();

  std::vector<IRFunctionNode> &functions_;
  // ========== per-function state (reset for each function) ==========
  IRFunctionNode *func_ = nullptr;
  int entry_block_ = -1;
  std::map<int, std::set<int>> successors_;
  std::map<int, std::set<int>> predecessors_;

  // --- Use-list: var_id → list of use sites ---
  std::map<int, std::vector<UseSite>> use_list_;

  // --- LT state ---
  std::vector<int> vertex_;
  std::map<int, int> dfn_;
  std::map<int, int> parent_block_;
  std::map<int, int> idom_;
  std::map<int, std::set<int>> dom_frontier_;
  std::map<int, std::vector<int>> dom_children_;

  // LT working arrays (indexed by DFS number, 1-indexed)
  int n_ = 0;
  std::vector<int> semi_;
  std::vector<int> label_;
  std::vector<int> ancestor_;
  std::vector<std::vector<int>> bucket_;

  // --- Promotion state for current alloca ---
  struct StoreInfo {
    int inst_idx;
    int value_id;
    bool is_constant;
  };
  std::map<int, std::vector<StoreInfo>> stores_of_alloca_;
  struct LoadInfo {
    int inst_idx;
    int load_result_id;
  };
  std::map<int, std::vector<LoadInfo>> loads_of_alloca_;
  int current_alloca_id_ = -1;
};

#endif // MEM2REG_H

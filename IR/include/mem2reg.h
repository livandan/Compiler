#ifndef MEM2REG_H
#define MEM2REG_H

#include "IR_generator.h"
#include <map>
#include <vector>
#include <set>

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

  // --- Alloca promotion analysis ---
  // Returns true if the alloca is a scalar whose address is never taken outside load/store.
  bool IsPromotable(int alloca_id) const;

  // --- SSA construction for one alloca ---
  // Returns true if the alloca was promoted, false if the pass bailed out
  // (in which case the alloca is left intact).
  bool PromoteAlloca(int alloca_id);

  // --- Instruction rewriting helpers ---
  // Replace every use of old_id with new_def (variable or constant) in all instructions of func_.
  void ReplaceAllUses(int old_id, const ReachingDef &new_def) const;

  // --- Cleanup ---
  void RemoveDeadInstructions() const;
  void RemoveDeadPhis() const;

  std::vector<IRFunctionNode> &functions_;
  // ========== per-function state (reset for each function) ==========
  IRFunctionNode *func_ = nullptr;
  int entry_block_ = -1;
  std::map<int, std::set<int>> successors_;
  std::map<int, std::set<int>> predecessors_;

  // --- LT state ---
  // dfs number → block_id
  std::vector<int> vertex_;        // 1-indexed (vertex_[1] = entry block)
  // block_id → dfs number (0 means unvisited)
  std::map<int, int> dfn_;
  // block_id → parent block_id in DFS tree
  std::map<int, int> parent_block_;
  // block_id → immediate dominator block_id
  std::map<int, int> idom_;
  // block_id → set of block_ids in its dominance frontier
  std::map<int, std::set<int>> dom_frontier_;
  // Children in dominator tree (for renaming traversal)
  std::map<int, std::vector<int>> dom_children_;

  // LT working arrays (indexed by DFS number, 1-indexed)
  int n_ = 0;  // number of reachable blocks
  std::vector<int> semi_;     // semi-dominator (as dfs number)
  std::vector<int> label_;    // vertex with minimum sdom on path
  std::vector<int> ancestor_; // forest for path compression
  std::vector<std::vector<int>> bucket_; // bucket[v] = vertices whose sdom is v

  // --- Promotion state for current alloca ---
  // block_id → list of stores to this alloca
  struct StoreInfo {
    int inst_idx;
    int value_id;     // variable ID (if !is_constant) or constant value (if is_constant)
    bool is_constant;  // true when the stored value is a literal constant (from value_store_)
  };
  std::map<int, std::vector<StoreInfo>> stores_of_alloca_;
  // block_id → list of loads from this alloca
  struct LoadInfo {
    int inst_idx;
    int load_result_id;
  };
  std::map<int, std::vector<LoadInfo>> loads_of_alloca_;
  int current_alloca_id_ = -1;
};

#endif // MEM2REG_H

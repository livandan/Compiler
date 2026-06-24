#ifndef REGISTER_ALLOCATOR_H
#define REGISTER_ALLOCATOR_H

#include "IR_generator.h"
#include "code_generator.h"
#include <map>
#include <set>
#include <vector>

class RegisterAllocator {
public:
  RegisterAllocator(const IRFunctionNode &ir_func,
                    RISCVFunctionNode &riscv_func);
  void Run();

private:
  // Step 1: Build CFG and compute liveness
  void BuildCFG();
  void ComputeLiveness();

  // Step 2: Build the interference graph
  void BuildInterferenceGraph();

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

  const IRFunctionNode &ir_func_;
  RISCVFunctionNode &riscv_func_;

  // CFG
  std::map<int, std::vector<int>> successors_;
  std::map<int, std::vector<int>> predecessors_;

  // Liveness
  std::map<int, std::set<int>> live_in_;
  std::map<int, std::set<int>> live_out_;

  // Per-block def/use sets (computed once during liveness)
  std::map<int, std::set<int>> block_defs_;
  std::map<int, std::set<int>> block_uses_;

  // Variables that could be in registers (scalar, not stack-bound)
  std::set<int> allocatable_vars_;
  std::map<int, int> var_size_;  // var_id -> size in bytes (4 for int, 8 for pointer)

  // Variables that must stay on stack (alloca'd, non-scalar)
  std::set<int> stack_bound_vars_;

  // Interference graph
  std::map<int, std::set<int>> interference_; // node -> {interfering nodes}
  std::map<int, std::set<int>> move_edges_;   // node -> {move-related nodes}

  // Chaitin-Briggs worklists
  std::set<int> worklist_;          // nodes not yet processed
  std::vector<int> select_stack_;   // removed nodes, in order
  std::map<int, bool> is_spilled_;  // node -> marked for spilling?
  // Cached degree of each node within the *current* worklist. Updated
  // incrementally as nodes leave the worklist so GetDegree is O(1).
  std::map<int, int> current_degree_;

  // Move-related nodes that still have move edges
  std::set<int> move_related_;      // nodes with at least one move edge

  // Coalescing: coalesced_rep_[v] = u means v was merged into u
  std::map<int, int> coalesced_rep_;

  // Result
  std::map<int, int> assignment_;   // var_id -> physical register, or -1 for spill
  std::map<int, int> spill_slot_;   // var_id -> stack offset for spilled vars

  // Available physical registers for allocation
  std::vector<int> allocatable_regs_;

  // Scratch registers reserved for codegen (not allocatable)
  static constexpr int SCRATCH_REGS[] = {5, 6, 7, 31}; // t0, t1, t2, t6

  static bool IsReservedReg(int reg) {
    return reg == 0 || reg == 1 || reg == 2 || reg == 3 || reg == 4;
  }

  static bool IsScratchReg(int reg) {
    return reg == 5 || reg == 6 || reg == 7 || reg == 31;
  }
};

#endif

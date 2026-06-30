#include "mem2reg.h"
#include <algorithm>
#include <functional>
#include <map>
#include <stack>

void Mem2RegThrow(const std::string &err_info) {
  std::cerr << "[Mem2Reg Error] " << err_info << '\n';
  throw "";
}

Mem2Reg::Mem2Reg(IRVisitor &IR_generator) : functions_(IR_generator.functions_) {}

// ============================================================================
// Public entry point
// ============================================================================

void Mem2Reg::Run() {
  for (auto &func : functions_) {
    RunOnFunction(func);
  }
}

// ============================================================================
// Per-function driver
// ============================================================================

void Mem2Reg::RunOnFunction(IRFunctionNode &func) {
  func_ = &func;
  if (func_->blocks_.empty()) {
    Mem2RegThrow("The function has no block.");
  }

  BuildCFG();
  if (successors_.empty()) return;

  ComputeDominators();
  ComputeDominanceFrontier();

  // --- Build use-list: one O(N) scan, then all subsequent lookups are O(uses) ---
  BuildUseList();

  // Collect promotable alloca ids
  std::vector<int> promotable_alloca_ids;
  for (const auto &alloca_inst : func_->alloca_instructions_) {
    int alloca_id = alloca_inst.result_id_;
    if (IsPromotable(alloca_id)) {
      promotable_alloca_ids.push_back(alloca_id);
    }
  }

  // Promote each alloca. PromoteAlloca may bail out (e.g., it discovers the
  // phi fan-in would exceed the IR's 2-operand phi capacity). When that
  // happens, the alloca is left intact, so we must NOT remove it from the
  // alloca list.
  std::set<int> actually_promoted;
  for (int alloca_id : promotable_alloca_ids) {
    if (PromoteAlloca(alloca_id)) {
      actually_promoted.insert(alloca_id);
    }
  }

  // Remove the promoted alloca instructions from alloca list
  {
    std::vector<IRInstruction> remaining;
    for (auto &inst : func_->alloca_instructions_) {
      if (!actually_promoted.contains(inst.result_id_)) {
        remaining.push_back(inst);
      }
    }
    func_->alloca_instructions_ = std::move(remaining);
  }

  // Remove dead load/store instructions
  RemoveDeadInstructions();

  // After promotion, some phis may be dead — their result is never read.
  RemoveDeadPhis();

  SimplifyCFG();
  SimplifyPhiCopies();
  while (RemoveTrivialSelects()) {
    BuildUseList();
    RemoveDeadPhis();
    SimplifyCFG();
    SimplifyPhiCopies();
  }
}

// ============================================================================
// CFG construction
// ============================================================================

void Mem2Reg::BuildCFG() {
  successors_.clear();
  predecessors_.clear();
  entry_block_ = func_->blocks_.begin()->first;

  for (const auto &[block_id, block] : func_->blocks_) {
    successors_[block_id]; // ensure entry exists
    if (block.instructions_.empty()) {
      Mem2RegThrow("The block has no instruction.");
    }
    const auto &last = block.instructions_.back();
    switch (last.instruction_type_) {
      case unconditional_br_: {
        successors_[block_id].insert(last.destination_);
        break;
      }
      case conditional_br_: {
        successors_[block_id].insert(last.if_true_);
        successors_[block_id].insert(last.if_false_);
        break;
      }
      default:
        // return, etc. — no successors
        break;
    }
  }

  // Build predecessors from successors
  for (const auto &[block_id, succ_set] : successors_) {
    for (int succ : succ_set) {
      predecessors_[succ].insert(block_id);
    }
    // Ensure every block exists in predecessors_ even if it has none
    predecessors_[block_id];
  }
}

// ============================================================================
// Lengauer–Tarjan dominator algorithm
// ============================================================================

void Mem2Reg::ComputeDominators() {
  // --- Phase 1: DFS numbering ---
  dfn_.clear();
  vertex_.clear();
  vertex_.push_back(0); // dummy at index 0 (1-indexed)
  parent_block_.clear();
  n_ = 0;

  DFS(entry_block_);

  // Allocate LT arrays
  semi_.assign(n_ + 1, 0);
  label_.assign(n_ + 1, 0);
  ancestor_.assign(n_ + 1, 0);
  bucket_.assign(n_ + 1, std::vector<int>());
  std::vector idom_dfn(n_ + 1, 0); // idom as DFS numbers

  // Initialize
  for (int i = 1; i <= n_; ++i) {
    semi_[i] = i;
    label_[i] = i;
  }

  // --- Phase 2: process vertices in reverse DFS order ---
  for (int i = n_; i >= 2; --i) {
    int w = vertex_[i]; // block_id with DFS number i
    int w_dfn = i;

    // For each predecessor v of w in the CFG
    for (int v : predecessors_[w]) {
      int v_dfn = dfn_[v];
      if (v_dfn == 0) {
        Mem2RegThrow("Unexpected unreachable block.");
      }
      int u = Find(v_dfn); // returns DFS number with minimal semi
      if (semi_[u] < semi_[w_dfn]) {
        semi_[w_dfn] = semi_[u];
      }
    }

    bucket_[semi_[w_dfn]].push_back(w_dfn);
    Union(dfn_[parent_block_[w]], w_dfn); // LINK(parent[w], w)

    // Process bucket of parent[w]
    int p_dfn = dfn_[parent_block_[w]];
    for (int v_dfn : bucket_[p_dfn]) {
      int u = Find(v_dfn);
      if (semi_[u] < semi_[v_dfn]) {
        idom_dfn[v_dfn] = u;
      } else {
        idom_dfn[v_dfn] = p_dfn;
      }
    }
    bucket_[p_dfn].clear();
  }

  // --- Phase 3: resolve idoms ---
  for (int i = 2; i <= n_; ++i) {
    int w_dfn = i;
    if (idom_dfn[w_dfn] != semi_[w_dfn]) {
      idom_dfn[w_dfn] = idom_dfn[idom_dfn[w_dfn]];
    }
  }

  idom_dfn[1] = 0; // entry has no idom

  // Convert idom from DFS numbers to block_ids
  idom_.clear();
  dom_children_.clear();
  for (int i = 1; i <= n_; ++i) {
    int block = vertex_[i];
    if (idom_dfn[i] != 0) {
      idom_[block] = vertex_[idom_dfn[i]];
    } else {
      idom_[block] = -1; // entry block
    }
    dom_children_[block]; // ensure entry exists
  }
  for (int i = 1; i <= n_; ++i) {
    int block = vertex_[i];
    if (idom_dfn[i] != 0) {
      int idom_block = vertex_[idom_dfn[i]];
      dom_children_[idom_block].push_back(block);
    }
  }
}

void Mem2Reg::DFS(const int block_id) {
  dfn_[block_id] = ++n_;
  vertex_.push_back(block_id);

  for (int succ : successors_[block_id]) {
    if (dfn_[succ] == 0) { // not yet visited
      parent_block_[succ] = block_id;
      DFS(succ);
    }
  }
}

int Mem2Reg::Find(const int v_idx) {
  // v_idx is a DFS number
  if (ancestor_[v_idx] == 0) {
    return label_[v_idx];
  }
  // Compress path
  int root = v_idx;
  std::vector<int> path;
  while (ancestor_[root] != 0) {
    path.push_back(root);
    root = ancestor_[root];
  }
  // Process path in reverse (from ancestor down)
  for (auto it = path.rbegin(); it != path.rend(); ++it) {
    int x = *it;
    int a = ancestor_[x];
    if (a != 0 && ancestor_[a] != 0) {
      if (semi_[label_[a]] < semi_[label_[x]]) {
        label_[x] = label_[a];
      }
      ancestor_[x] = ancestor_[a];
    }
  }
  if (semi_[label_[ancestor_[v_idx]]] < semi_[label_[v_idx]]) {
    return label_[ancestor_[v_idx]];
  }
  return label_[v_idx];
}

void Mem2Reg::Union(int u_dfn, int v_dfn) {
  // LINK(u, v): make u (DFS number) the ancestor of v (DFS number)
  ancestor_[v_dfn] = u_dfn;
}

// ============================================================================
// Dominance frontier
// ============================================================================

void Mem2Reg::ComputeDominanceFrontier() {
  dom_frontier_.clear();
  for (const auto &[block_id, _] : func_->blocks_) {
    dom_frontier_[block_id]; // ensure set exists
  }

  for (const auto &[b, preds] : predecessors_) {
    if (preds.size() < 2) continue;
    for (const int p : preds) {
      int runner = p;
      while (idom_.contains(runner) && idom_[runner] != -1 &&
             runner != idom_[b]) {
        dom_frontier_[runner].insert(b);
        runner = idom_[runner];
      }
    }
  }
}

// ============================================================================
// Build use-list — one O(N) scan for all subsequent O(uses) lookups
// ============================================================================

void Mem2Reg::BuildUseList() {
  use_list_.clear();

  for (auto &[block_id, block] : func_->blocks_) {
    // --- Phi instructions ---
    for (int pi = 0; pi < static_cast<int>(block.phi_instructions_.size()); ++pi) {
      for (const auto &cond : block.phi_instructions_[pi].conditions) {
        if (!cond.is_const && cond.var_id != 0) {
          use_list_[cond.var_id].push_back({block_id, true, pi});
        }
      }
    }

    // --- Regular instructions ---
    for (int ii = 0; ii < static_cast<int>(block.instructions_.size()); ++ii) {
      const auto &inst = block.instructions_[ii];
      switch (inst.instruction_type_) {
        case two_var_binary_operation_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case var_const_binary_operation_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          break;
        }
        case const_var_binary_operation_: {
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case conditional_br_: {
          use_list_[inst.condition_id_].push_back({block_id, false, ii});
          break;
        }
        case variable_ret_: {
          use_list_[inst.result_id_].push_back({block_id, false, ii});
          break;
        }
        case load_:
        case ptr_load_: {
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        case variable_store_:
        case ptr_store_: {
          use_list_[inst.result_id_].push_back({block_id, false, ii});
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        case value_store_: {
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        case get_element_ptr_by_value_: {
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        case get_element_ptr_by_variable_: {
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          use_list_[inst.index_].push_back({block_id, false, ii});
          break;
        }
        case two_var_icmp_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case var_const_icmp_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          break;
        }
        case const_var_icmp_: {
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case non_void_call_:
        case void_call_:
        case builtin_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              use_list_[arg.value_].push_back({block_id, false, ii});
            }
          }
          break;
        }
        case value_select_ii_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case value_select_iv_: {
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          break;
        }
        case value_select_vi_: {
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case variable_select_ii_: {
          use_list_[inst.condition_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case variable_select_iv_: {
          use_list_[inst.condition_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_1_id_].push_back({block_id, false, ii});
          break;
        }
        case variable_select_vi_: {
          use_list_[inst.condition_id_].push_back({block_id, false, ii});
          use_list_[inst.operand_2_id_].push_back({block_id, false, ii});
          break;
        }
        case variable_select_vv_: {
          use_list_[inst.condition_id_].push_back({block_id, false, ii});
          break;
        }
        case builtin_memset_: {
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        case builtin_memcpy_: {
          use_list_[inst.destination_].push_back({block_id, false, ii});
          use_list_[inst.pointer_].push_back({block_id, false, ii});
          break;
        }
        default:
          break;
      }
    }
  }
}

// ============================================================================
// Promotability check — O(uses_of_alloca) via use-list
// ============================================================================

bool Mem2Reg::IsPromotable(const int alloca_id) const {
  auto it = use_list_.find(alloca_id);
  if (it == use_list_.end()) return true; // no uses → trivially promotable

  for (const auto &site : it->second) {
    if (site.is_phi) {
      // Phi condition references the alloca pointer → prohibited
      return false;
    }

    const auto &inst = func_->blocks_.at(site.block_id).instructions_[site.index];
    switch (inst.instruction_type_) {
      case variable_ret_:
      case variable_store_:
      case ptr_store_: {
        if (inst.result_id_ == alloca_id) return false;
        break;
      }
      case get_element_ptr_by_value_:
      case get_element_ptr_by_variable_:
      case builtin_memset_: {
        if (inst.pointer_ == alloca_id) return false;
        break;
      }
      case builtin_memcpy_: {
        if (inst.destination_ == alloca_id || inst.pointer_ == alloca_id) return false;
        break;
      }
      case non_void_call_:
      case void_call_: {
        for (const auto &argument : inst.function_call_arguments_) {
          if (argument.is_variable_ && argument.value_ == alloca_id) return false;
        }
        break;
      }
      case value_select_ii_: {
        if (inst.condition_id_ == 0 && inst.operand_2_id_ == alloca_id) return false;
        if (inst.condition_id_ != 0 && inst.operand_1_id_ == alloca_id) return false;
        break;
      }
      case value_select_iv_: {
        if (inst.condition_id_ != 0 && inst.operand_1_id_ == alloca_id) return false;
        break;
      }
      case value_select_vi_: {
        if (inst.condition_id_ == 0 && inst.operand_2_id_ == alloca_id) return false;
        break;
      }
      case variable_select_ii_: {
        if (inst.operand_2_id_ == alloca_id) return false;
        if (inst.operand_1_id_ == alloca_id) return false;
        break;
      }
      case variable_select_iv_: {
        if (inst.operand_1_id_ == alloca_id) return false;
        break;
      }
      case variable_select_vi_: {
        if (inst.operand_2_id_ == alloca_id) return false;
        break;
      }
      default:;
    }
  }
  return true;
}

// ============================================================================
// Promote a single alloca
// ============================================================================

bool Mem2Reg::PromoteAlloca(int alloca_id) {
  current_alloca_id_ = alloca_id;
  stores_of_alloca_.clear();
  loads_of_alloca_.clear();

  // --- Step 1: Collect stores and loads via use-list (O(uses) instead of O(I)) ---
  // Gather all blocks that contain a store (definition) to this alloca.
  // Handles: variable_store_, value_store_, ptr_store_ (all have pointer_ == alloca_id)
  // Loads: load_, ptr_load_ (all have pointer_ == alloca_id)
  std::set<int> def_blocks;

  auto it = use_list_.find(alloca_id);
  if (it != use_list_.end()) {
    for (const auto &site : it->second) {
      if (site.is_phi) continue; // would've been caught by IsPromotable

      const auto &inst = func_->blocks_.at(site.block_id).instructions_[site.index];
      switch (inst.instruction_type_) {
        case variable_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[site.block_id].push_back(
                {site.index, inst.result_id_, false});
            def_blocks.insert(site.block_id);
          }
          break;
        }
        case value_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[site.block_id].push_back(
                {site.index, inst.result_id_, true});
            def_blocks.insert(site.block_id);
          }
          break;
        }
        case ptr_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[site.block_id].push_back(
                {site.index, inst.result_id_, false});
            def_blocks.insert(site.block_id);
          }
          break;
        }
        case load_:
        case ptr_load_: {
          if (inst.pointer_ == alloca_id) {
            loads_of_alloca_[site.block_id].push_back({site.index, inst.result_id_});
          }
          break;
        }
        default:;
      }
    }
  }

  if (def_blocks.empty()) return true; // nothing to promote

  // --- Step 2: Place phi nodes ---
  std::set<int> phi_blocks;
  std::set<int> phi_result_ids;
  std::vector worklist(def_blocks.begin(), def_blocks.end());

  // Cache the alloca type
  std::shared_ptr<IntegratedType> alloca_type = nullptr;
  for (const auto &ai : func_->alloca_instructions_) {
    if (ai.result_id_ == alloca_id) {
      alloca_type = ai.result_type_;
      break;
    }
  }

  while (!worklist.empty()) {
    int x = worklist.back();
    worklist.pop_back();
    for (int y : dom_frontier_[x]) {
      if (phi_blocks.contains(y)) continue;
      int phi_result_id = func_->var_id_++;
      phi_result_ids.insert(phi_result_id);
      // Insert phi with one placeholder condition; Step 4 will rebuild the
      // conditions vector to have exactly one entry per predecessor of Y.
      func_->blocks_[y].AddPhi(phi_result_id, alloca_type, -1, -1, false);
      phi_blocks.insert(y);
      worklist.push_back(y);
    }
  }

  // --- Step 3: Rename variables ---
  std::stack<ReachingDef> reaching_stack;
  std::map<int, ReachingDef> replacement_map; // old load_result_id → reaching def
  std::map<int, ReachingDef> block_exit_defs; // block_id → def at block exit

  std::function<void(int)> rename_dfs = [&](int block_id) {
    int push_count = 0;
    auto &block_insts = func_->blocks_[block_id].instructions_;

    // Process phi instructions in this block — their results are new defs
    for (auto &inst : func_->blocks_[block_id].phi_instructions_) {
      if (phi_result_ids.contains(inst.result_id)) {
        reaching_stack.push(ReachingDef::Var(inst.result_id));
        push_count++;
      }
    }

    // Process instructions in order
    for (auto &inst : block_insts) {
      if (inst.pointer_ != alloca_id) continue;

      switch (inst.instruction_type_) {
        case variable_store_: {
          reaching_stack.push(ReachingDef::Var(inst.result_id_));
          push_count++;
          inst.instruction_type_ = unknown_;
          break;
        }
        case value_store_: {
          reaching_stack.push(ReachingDef::Const(inst.result_id_));
          push_count++;
          inst.instruction_type_ = unknown_;
          break;
        }
        case ptr_store_: {
          reaching_stack.push(ReachingDef::Var(inst.result_id_));
          push_count++;
          inst.instruction_type_ = unknown_;
          break;
        }
        case load_:
        case ptr_load_: {
          ReachingDef current = reaching_stack.top();
          replacement_map[inst.result_id_] = current;
          inst.instruction_type_ = unknown_;
          break;
        }
        default:;
      }
    }

    // Record the reaching definition at the end of this block
    block_exit_defs[block_id] = reaching_stack.top();

    // Recurse into dominator tree children
    for (int child : dom_children_[block_id]) {
      rename_dfs(child);
    }

    // Pop definitions pushed in this block
    while (push_count-- > 0) {
      reaching_stack.pop();
    }
  };

  reaching_stack.push(ReachingDef::Undef());
  rename_dfs(entry_block_);

  // --- Step 4: Fill phi operands using block_exit_defs ---
  for (int block_id : phi_blocks) {
    auto preds = std::vector(predecessors_[block_id].begin(), predecessors_[block_id].end());

    for (auto &inst : func_->blocks_[block_id].phi_instructions_) {
      if (!phi_result_ids.contains(inst.result_id)) continue;
      std::vector<PhiCondition> rebuilt;
      rebuilt.reserve(preds.size());
      for (const int p : preds) {
        ReachingDef def = block_exit_defs.contains(p) ? block_exit_defs[p] : ReachingDef::Undef();
        if (def.valid && !def.is_constant) {
          rebuilt.emplace_back(p, false, 0, def.var_id);
        } else if (def.valid) {
          rebuilt.emplace_back(p, true, def.const_value, -1);
        } else {
          // Undef path → literal 0
          rebuilt.emplace_back(p, true, 0, -1);
        }
      }
      inst.conditions = std::move(rebuilt);
      break;
    }
  }

  // --- Step 4.5: Update use-list with new phi conditions ---
  // Newly created phis may reference variable IDs (store values) that are load
  // results from OTHER allocas.  Those other allocas' ReplaceAllUses (Step 5)
  // must visit these phi conditions, so we register them in the use-list now.
  for (int block_id : phi_blocks) {
    for (int pi = 0; pi < static_cast<int>(func_->blocks_[block_id].phi_instructions_.size()); ++pi) {
      const auto &inst = func_->blocks_[block_id].phi_instructions_[pi];
      if (!phi_result_ids.contains(inst.result_id)) continue;
      for (const auto &cond : inst.conditions) {
        if (!cond.is_const && cond.var_id != 0) {
          use_list_[cond.var_id].push_back({block_id, true, pi});
        }
      }
    }
  }

  // --- Step 5: Replace all uses of load results with their reaching defs ---
  // Uses the use-list for O(uses) replacement instead of O(I) full scan.
  // The use-list now includes both original uses AND the phi conditions just
  // registered in Step 4.5, so cross-alloca phi references are also updated.
  for (const auto &[old_id, new_def] : replacement_map) {
    if (new_def.valid) {
      ReplaceAllUses(old_id, new_def);
    } else {
      // undef → literal 0
      ReplaceAllUses(old_id, ReachingDef::Const(0));
    }
  }

  current_alloca_id_ = -1;
  return true;
}

// Forward declarations for helper functions used by ReplaceAllUses
static void ReplaceVarWithVar(IRInstruction &inst, int old_id, int new_id);
static void ReplacePhiVarWithVar(PhiInstruction &inst, int old_id, int new_id);
static void ReplaceVarWithConst(IRInstruction &inst, int old_id, int const_val);
static void ReplacePhiVarWithConst(PhiInstruction &inst, int old_id, int const_val);
static void ReplaceAllPhiResultUsesInFunction(IRFunctionNode &func, int old_id,
    const ReachingDef &new_def);
static std::map<int, ReachingDef> BuildPhiValueMap(const IRBlock &block,
    int predecessor_block);

// ============================================================================
// Replace all uses of old_id with new_def — O(uses) via use-list
// ============================================================================

void Mem2Reg::ReplaceAllUses(const int old_id, const ReachingDef &new_def) {
  auto it = use_list_.find(old_id);
  if (it == use_list_.end()) return; // no uses

  for (const auto &site : it->second) {
    if (site.is_phi) {
      auto &inst = func_->blocks_.at(site.block_id).phi_instructions_[site.index];
      if (!new_def.is_constant) {
        ReplacePhiVarWithVar(inst, old_id, new_def.var_id);
        // Register this use in the target variable's use-list so that
        // subsequent alloca promotions see the updated reference.
        use_list_[new_def.var_id].push_back(site);
      } else {
        ReplacePhiVarWithConst(inst, old_id, new_def.const_value);
      }
    } else {
      auto &inst = func_->blocks_.at(site.block_id).instructions_[site.index];
      if (!new_def.is_constant) {
        ReplaceVarWithVar(inst, old_id, new_def.var_id);
        // Register this use in the target variable's use-list so that
        // subsequent alloca promotions see the updated reference.
        use_list_[new_def.var_id].push_back(site);
      } else {
        ReplaceVarWithConst(inst, old_id, new_def.const_value);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Helper: replace old_id with new_id (both variables) in a single instruction
// ---------------------------------------------------------------------------
void ReplaceVarWithVar(IRInstruction &inst, int old_id, int new_id) {
  // Generic pointer_ field replacement for instructions that have one
  switch (inst.instruction_type_) {
    case load_:
    case ptr_load_:
    case variable_store_:
    case value_store_:
    case ptr_store_:
    case get_element_ptr_by_value_:
    case get_element_ptr_by_variable_:
    case builtin_memset_: {
      if (inst.pointer_ == old_id) inst.pointer_ = new_id;
      break;
    }
    default:;
  }

  switch (inst.instruction_type_) {
    case two_var_binary_operation_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case var_const_binary_operation_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      break;
    }
    case const_var_binary_operation_: {
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case conditional_br_: {
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case variable_ret_: {
      if (inst.result_id_ == old_id) inst.result_id_ = new_id;
      break;
    }
    case variable_store_:
    case ptr_store_: {
      if (inst.result_id_ == old_id) inst.result_id_ = new_id;
      break;
    }
    case get_element_ptr_by_variable_: {
      if (inst.index_ == old_id) inst.index_ = new_id;
      break;
    }
    case two_var_icmp_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case var_const_icmp_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      break;
    }
    case const_var_icmp_: {
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case non_void_call_:
    case void_call_:
    case builtin_call_: {
      for (auto &arg : inst.function_call_arguments_) {
        if (arg.is_variable_ && arg.value_ == old_id) {
          arg.value_ = new_id;
        }
      }
      break;
    }
    case variable_select_ii_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case variable_select_iv_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case variable_select_vi_: {
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case variable_select_vv_: {
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case value_select_ii_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case value_select_iv_: {
      if (inst.operand_1_id_ == old_id) inst.operand_1_id_ = new_id;
      break;
    }
    case value_select_vi_: {
      if (inst.operand_2_id_ == old_id) inst.operand_2_id_ = new_id;
      break;
    }
    case value_select_vv_: {
      // Both operands are literal; no variable to replace.
      break;
    }
    case builtin_memcpy_: {
      if (inst.destination_ == old_id) inst.destination_ = new_id;
      if (inst.pointer_ == old_id) inst.pointer_ = new_id;
      break;
    }
    default:
      break;
  }
}
void ReplacePhiVarWithVar(PhiInstruction &inst, int old_id, int new_id) {
  for (auto &condition : inst.conditions) {
    if (!condition.is_const && condition.var_id == old_id) {
      condition.var_id = new_id;
    }
  }
}

// ---------------------------------------------------------------------------
// Constant-folding helpers for ReplaceVarWithConst
// ---------------------------------------------------------------------------
static int FoldBinaryOp(BinaryOperator op, int lhs, int rhs) {
  switch (op) {
    case add_:  return lhs + rhs;
    case sub_:  return lhs - rhs;
    case mul_:  return lhs * rhs;
    case udiv_: return rhs != 0 ? static_cast<int>(static_cast<unsigned>(lhs) / static_cast<unsigned>(rhs)) : 0;
    case sdiv_: return rhs != 0 ? lhs / rhs : 0;
    case urem_: return rhs != 0 ? static_cast<int>(static_cast<unsigned>(lhs) % static_cast<unsigned>(rhs)) : 0;
    case srem_: return rhs != 0 ? lhs % rhs : 0;
    case shl_:  return lhs << rhs;
    case ashr_: return lhs >> rhs;
    case and_:  return lhs & rhs;
    case or_:   return lhs | rhs;
    case xor_:  return lhs ^ rhs;
  }
  return 0;
}

static bool FoldIcmp(IcmpCond cond, int lhs, int rhs) {
  switch (cond) {
    case equal_:                  return lhs == rhs;
    case not_equal_:              return lhs != rhs;
    case unsigned_greater_than_:  return static_cast<unsigned>(lhs) >  static_cast<unsigned>(rhs);
    case unsigned_greater_equal_: return static_cast<unsigned>(lhs) >= static_cast<unsigned>(rhs);
    case unsigned_less_than_:     return static_cast<unsigned>(lhs) <  static_cast<unsigned>(rhs);
    case unsigned_less_equal_:    return static_cast<unsigned>(lhs) <= static_cast<unsigned>(rhs);
    case signed_greater_than_:    return lhs >  rhs;
    case signed_greater_equal_:   return lhs >= rhs;
    case signed_less_than_:       return lhs <  rhs;
    case signed_less_equal_:      return lhs <= rhs;
  }
  return false;
}

// Helper: replace the instruction with a constant assignment to its result_id.
static void ReplaceInstWithConst(IRInstruction &inst, int folded_val) {
  if (inst.instruction_type_ == var_const_icmp_ || inst.instruction_type_ == const_var_icmp_) {
    auto bool_copy = std::make_shared<IntegratedType>(*inst.result_type_);
    bool_copy->basic_type = bool_type;
    bool_copy->is_int = false;
    inst.result_type_ = bool_copy;
    inst.another_type_ = bool_copy;
  }
  inst.instruction_type_ = value_select_vv_;
  inst.condition_id_ = 1;          // true → pick operand_1
  inst.operand_1_id_ = folded_val;
  inst.operand_2_id_ = folded_val;
}

// ---------------------------------------------------------------------------
// Helper: replace old_id with a constant in a single instruction
// ---------------------------------------------------------------------------
void ReplaceVarWithConst(IRInstruction &inst, int old_id, int const_val) {
  switch (inst.instruction_type_) {
    // --- Binary operations ---
    case two_var_binary_operation_: {
      if (inst.operand_1_id_ == old_id) {
        inst.instruction_type_ = const_var_binary_operation_;
        inst.operand_1_id_ = const_val;
      } else if (inst.operand_2_id_ == old_id) {
        inst.instruction_type_ = var_const_binary_operation_;
        inst.operand_2_id_ = const_val;
      }
      break;
    }
    case var_const_binary_operation_: {
      if (inst.operand_1_id_ == old_id) {
        int folded = FoldBinaryOp(inst.operator_, const_val, inst.operand_2_id_);
        ReplaceInstWithConst(inst, folded);
      }
      break;
    }
    case const_var_binary_operation_: {
      if (inst.operand_2_id_ == old_id) {
        int folded = FoldBinaryOp(inst.operator_, inst.operand_1_id_, const_val);
        ReplaceInstWithConst(inst, folded);
      }
      break;
    }
    // --- ICMP ---
    case two_var_icmp_: {
      if (inst.operand_1_id_ == old_id) {
        inst.instruction_type_ = const_var_icmp_;
        inst.operand_1_id_ = const_val;
      } else if (inst.operand_2_id_ == old_id) {
        inst.instruction_type_ = var_const_icmp_;
        inst.operand_2_id_ = const_val;
      }
      break;
    }
    case var_const_icmp_: {
      if (inst.operand_1_id_ == old_id) {
        int folded = FoldIcmp(inst.icmp_condition_, const_val, inst.operand_2_id_) ? 1 : 0;
        ReplaceInstWithConst(inst, folded);
      }
      break;
    }
    case const_var_icmp_: {
      if (inst.operand_2_id_ == old_id) {
        int folded = FoldIcmp(inst.icmp_condition_, inst.operand_1_id_, const_val) ? 1 : 0;
        ReplaceInstWithConst(inst, folded);
      }
      break;
    }
    // --- Return ---
    case variable_ret_: {
      if (inst.result_id_ == old_id) {
        inst.instruction_type_ = value_ret_;
        inst.result_id_ = const_val;
      }
      break;
    }
    // --- Store ---
    case variable_store_:
    case ptr_store_: {
      if (inst.result_id_ == old_id) {
        inst.instruction_type_ = value_store_;
        inst.result_id_ = const_val;
      }
      break;
    }
    // --- Conditional branch ---
    case conditional_br_: {
      if (inst.condition_id_ == old_id) {
        inst.instruction_type_ = unconditional_br_;
        inst.destination_ = (const_val != 0) ? inst.if_true_ : inst.if_false_;
      }
      break;
    }
    // --- GEP index ---
    case get_element_ptr_by_variable_: {
      if (inst.index_ == old_id) {
        inst.instruction_type_ = get_element_ptr_by_value_;
        inst.index_ = const_val;
      }
      break;
    }
    // --- Call arguments ---
    case non_void_call_:
    case void_call_:
    case builtin_call_: {
      for (auto &arg : inst.function_call_arguments_) {
        if (arg.is_variable_ && arg.value_ == old_id) {
          arg.is_variable_ = false;
          arg.value_ = const_val;
        }
      }
      break;
    }
    // --- Select: replace variable operand with constant ---
    case value_select_ii_: {
      if (inst.condition_id_ != 0 && inst.operand_1_id_ == old_id) {
        inst.operand_1_id_ = const_val;
        inst.operand_2_id_ = const_val;
        inst.instruction_type_ = value_select_vv_;
      }
      if (inst.condition_id_ == 0 && inst.operand_2_id_ == old_id) {
        inst.operand_1_id_ = const_val;
        inst.operand_2_id_ = const_val;
        inst.instruction_type_ = value_select_vv_;
      }
      break;
    }
    case value_select_iv_: {
      if (inst.condition_id_ != 0 && inst.operand_1_id_ == old_id) {
        inst.operand_1_id_ = const_val;
        inst.operand_2_id_ = const_val;
        inst.instruction_type_ = value_select_vv_;
      }
      break;
    }
    case value_select_vi_: {
      if (inst.condition_id_ == 0 && inst.operand_2_id_ == old_id) {
        inst.operand_1_id_ = const_val;
        inst.operand_2_id_ = const_val;
        inst.instruction_type_ = value_select_vv_;
      }
      break;
    }
    case variable_select_ii_: {
      if (inst.condition_id_ == old_id) {
        if (const_val == 0) {
          inst.condition_id_ = 0;
          if (inst.operand_2_id_ == old_id) {
            inst.operand_1_id_ = const_val;
            inst.operand_2_id_ = const_val;
            inst.instruction_type_ = value_select_vv_;
          } else {
            inst.operand_1_id_ = inst.operand_2_id_;
            inst.instruction_type_ = value_select_ii_;
          }
        } else {
          inst.condition_id_ = 1;
          if (inst.operand_1_id_ == old_id) {
            inst.operand_1_id_ = const_val;
            inst.operand_2_id_ = const_val;
            inst.instruction_type_ = value_select_vv_;
          } else {
            inst.operand_2_id_ = inst.operand_1_id_;
            inst.instruction_type_ = value_select_ii_;
          }
        }
      } else {
        if (inst.operand_1_id_ == old_id && inst.operand_2_id_ == old_id) {
          inst.operand_1_id_ = const_val;
          inst.operand_2_id_ = const_val;
          inst.instruction_type_ = variable_select_vv_;
        } else if (inst.operand_1_id_ == old_id) {
          inst.operand_1_id_ = const_val;
          inst.instruction_type_ = variable_select_vi_;
        } else if (inst.operand_2_id_ == old_id) {
          inst.operand_2_id_ = const_val;
          inst.instruction_type_ = variable_select_iv_;
        }
      }
      break;
    }
    case variable_select_iv_: {
      if (inst.condition_id_ == old_id) {
        if (const_val == 0) {
          inst.condition_id_ = 0;
          inst.operand_1_id_ = inst.operand_2_id_;
          inst.instruction_type_ = value_select_vv_;
        } else {
          inst.condition_id_ = 1;
          if (inst.operand_1_id_ == old_id) {
            inst.operand_1_id_ = const_val;
            inst.operand_2_id_ = const_val;
            inst.instruction_type_ = value_select_vv_;
          } else {
            inst.operand_2_id_ = inst.operand_1_id_;
            inst.instruction_type_ = value_select_ii_;
          }
        }
      } else {
        if (inst.operand_1_id_ == old_id) {
          inst.operand_1_id_ = const_val;
          inst.instruction_type_ = variable_select_vv_;
        }
      }
      break;
    }
    case variable_select_vi_: {
      if (inst.condition_id_ == old_id) {
        if (const_val == 0) {
          inst.condition_id_ = 0;
          if (inst.operand_2_id_ == old_id) {
            inst.operand_1_id_ = const_val;
            inst.operand_2_id_ = const_val;
            inst.instruction_type_ = value_select_vv_;
          } else {
            inst.operand_1_id_ = inst.operand_2_id_;
            inst.instruction_type_ = value_select_ii_;
          }
        } else {
          inst.condition_id_ = 1;
          inst.operand_2_id_ = inst.operand_1_id_;
          inst.instruction_type_ = value_select_vv_;
        }
      } else {
        if (inst.operand_2_id_ == old_id) {
          inst.operand_2_id_ = const_val;
          inst.instruction_type_ = variable_select_vv_;
        }
      }
      break;
    }
    case variable_select_vv_: {
      if (inst.condition_id_ == old_id) {
        if (const_val == 0) {
          inst.condition_id_ = 0;
          inst.operand_1_id_ = inst.operand_2_id_;
          inst.instruction_type_ = value_select_vv_;
        } else {
          inst.condition_id_ = 1;
          inst.operand_2_id_ = inst.operand_1_id_;
          inst.instruction_type_ = value_select_vv_;
        }
      }
      break;
    }
    default:;
  }
}
void ReplacePhiVarWithConst(PhiInstruction &inst, int old_id, int const_val) {
  for (auto &condition : inst.conditions) {
    if (!condition.is_const && condition.var_id == old_id) {
      condition.is_const = true;
      condition.value = const_val;
    }
  }
}

static void ReplaceAllPhiResultUsesInFunction(IRFunctionNode &func, const int old_id,
    const ReachingDef &new_def) {
  for (auto &[block_id, block] : func.blocks_) {
    for (auto &phi : block.phi_instructions_) {
      if (new_def.is_constant) {
        ReplacePhiVarWithConst(phi, old_id, new_def.const_value);
      } else {
        ReplacePhiVarWithVar(phi, old_id, new_def.var_id);
      }
    }
    for (auto &instruction : block.instructions_) {
      if (new_def.is_constant) {
        ReplaceVarWithConst(instruction, old_id, new_def.const_value);
      } else {
        ReplaceVarWithVar(instruction, old_id, new_def.var_id);
      }
    }
  }
}

static std::map<int, ReachingDef> BuildPhiValueMap(const IRBlock &block,
    const int predecessor_block) {
  std::map<int, ReachingDef> values;
  for (const auto &phi : block.phi_instructions_) {
    ReachingDef value = ReachingDef::Undef();
    for (const auto &condition : phi.conditions) {
      if (condition.from_block_id != predecessor_block) {
        continue;
      }
      value = condition.is_const
          ? ReachingDef::Const(condition.value)
          : ReachingDef::Var(condition.var_id);
      break;
    }
    values[phi.result_id] = value.valid ? value : ReachingDef::Const(0);
  }
  return values;
}

// ============================================================================
// Remove dead load/store instructions (those marked unknown_)
// ============================================================================

void Mem2Reg::RemoveDeadInstructions() const {
  for (auto &[block_id, block] : func_->blocks_) {
    std::vector<IRInstruction> remaining;
    for (const auto &inst : block.instructions_) {
      if (inst.instruction_type_ != unknown_) {
        remaining.push_back(inst);
      }
    }
    block.instructions_ = std::move(remaining);
  }
}

// ============================================================================
// Remove dead phis — worklist-based for O(uses) instead of O(P·I) per iteration
// ============================================================================

void Mem2Reg::RemoveDeadPhis() {
  // Step 1: Collect all phi result ids and build a reverse-reference map:
  // phi result → set of phi result_ids that reference it (among phis only).
  // Also collect all phi results referenced from regular instructions.

  std::set<int> phi_results;
  // phi_result → which other phi results reference it (so when we delete
  // that phi, we know which phis to re-check)
  std::map<int, std::set<int>> phi_refs_from_phis;
  // phi result ids that are referenced from at least one regular instruction
  std::set<int> referenced_from_insts;

  for (const auto &[block_id, block] : func_->blocks_) {
    for (const auto &inst : block.phi_instructions_) {
      phi_results.insert(inst.result_id);
    }
  }

  // Scan phi conditions to build phi_refs_from_phis
  for (const auto &[block_id, block] : func_->blocks_) {
    for (const auto &inst : block.phi_instructions_) {
      for (const auto &cond : inst.conditions) {
        if (!cond.is_const && cond.var_id != 0) {
          if (phi_results.contains(cond.var_id)) {
            phi_refs_from_phis[cond.var_id].insert(inst.result_id);
          }
        }
      }
    }
  }

  // Scan regular instructions for phi references
  for (const auto &[block_id, block] : func_->blocks_) {
    for (const auto &inst : block.instructions_) {
      auto consider = [&](int var_id, bool is_var) {
        if (is_var && var_id != 0 && phi_results.contains(var_id)) {
          referenced_from_insts.insert(var_id);
        }
      };
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_:
          consider(inst.operand_1_id_, true);
          consider(inst.operand_2_id_, true);
          break;
        case var_const_binary_operation_:
        case var_const_icmp_:
          consider(inst.operand_1_id_, true);
          break;
        case const_var_binary_operation_:
        case const_var_icmp_:
          consider(inst.operand_2_id_, true);
          break;
        case conditional_br_:
          consider(inst.condition_id_, true);
          break;
        case variable_ret_:
        case variable_store_:
        case ptr_store_:
          consider(inst.result_id_, true);
          break;
        case get_element_ptr_by_variable_:
          consider(inst.index_, true);
          break;
        case non_void_call_:
        case void_call_:
        case builtin_call_:
          for (const auto &arg : inst.function_call_arguments_) {
            consider(arg.value_, arg.is_variable_);
          }
          break;
        case value_select_ii_:
          consider(inst.operand_1_id_, true);
          consider(inst.operand_2_id_, true);
          break;
        case value_select_iv_:
          consider(inst.operand_1_id_, true);
          break;
        case value_select_vi_:
          consider(inst.operand_2_id_, true);
          break;
        case variable_select_ii_:
          consider(inst.condition_id_, true);
          consider(inst.operand_1_id_, true);
          consider(inst.operand_2_id_, true);
          break;
        case variable_select_iv_:
          consider(inst.condition_id_, true);
          consider(inst.operand_1_id_, true);
          break;
        case variable_select_vi_:
          consider(inst.condition_id_, true);
          consider(inst.operand_2_id_, true);
          break;
        case variable_select_vv_:
          consider(inst.condition_id_, true);
          break;
        case builtin_memcpy_:
          consider(inst.destination_, true);
          consider(inst.pointer_, true);
          break;
        default:;
      }
    }
  }

  // Worklist: phis that need re-checking (initially all of them)
  std::set<int> worklist = phi_results;
  std::set<int> alive_phis = phi_results; // currently alive

  while (!worklist.empty()) {
    // Pop one phi to check
    int candidate = *worklist.begin();
    worklist.erase(worklist.begin());

    if (!alive_phis.contains(candidate)) continue; // already removed

    // A phi is dead if nothing references it
    bool is_live = referenced_from_insts.contains(candidate);
    if (!is_live) {
      // Check if another alive phi references it
      auto ref_it = phi_refs_from_phis.find(candidate);
      if (ref_it != phi_refs_from_phis.end()) {
        for (int ref : ref_it->second) {
          if (alive_phis.contains(ref)) {
            is_live = true;
            break;
          }
        }
      }
    }

    if (!is_live) {
      // Remove this phi
      alive_phis.erase(candidate);

      // Any phi that referenced this now-dead phi may itself become dead
      auto ref_it = phi_refs_from_phis.find(candidate);
      if (ref_it != phi_refs_from_phis.end()) {
        for (int ref : ref_it->second) {
          if (alive_phis.contains(ref)) {
            worklist.insert(ref);
          }
        }
      }
    }
  }

  // Remove dead phis from blocks
  for (auto &[block_id, block] : func_->blocks_) {
    std::vector<PhiInstruction> remaining;
    for (const auto &inst : block.phi_instructions_) {
      if (alive_phis.contains(inst.result_id)) {
        remaining.push_back(inst);
      }
    }
    block.phi_instructions_ = std::move(remaining);
  }
}

void Mem2Reg::SimplifyCFG() {
  auto build_preds = [&]() {
    std::map<int, std::set<int>> preds;
    for (const auto &[block_id, block] : func_->blocks_) {
      preds[block_id];
      if (block.instructions_.empty()) continue;
      const auto &last = block.instructions_.back();
      if (last.instruction_type_ == unconditional_br_) {
        preds[last.destination_].insert(block_id);
      } else if (last.instruction_type_ == conditional_br_) {
        preds[last.if_true_].insert(block_id);
        preds[last.if_false_].insert(block_id);
      }
    }
    return preds;
  };

  auto redirect_successor_phi = [&](const int target, const int old_pred,
      const std::set<int> &new_preds) {
    auto target_it = func_->blocks_.find(target);
    if (target_it == func_->blocks_.end()) return;
    for (auto &phi : target_it->second.phi_instructions_) {
      std::vector<PhiCondition> rebuilt;
      for (const auto &condition : phi.conditions) {
        if (condition.from_block_id != old_pred) {
          rebuilt.push_back(condition);
          continue;
        }
        for (const int pred : new_preds) {
          PhiCondition redirected = condition;
          redirected.from_block_id = pred;
          rebuilt.push_back(redirected);
        }
      }
      phi.conditions = std::move(rebuilt);
    }
  };

  bool changed = true;
  while (changed) {
    changed = false;

    const int entry = func_->blocks_.begin()->first;
    std::set<int> reachable;
    std::vector<int> stack;
    stack.push_back(entry);
    while (!stack.empty()) {
      const int block_id = stack.back();
      stack.pop_back();
      if (reachable.contains(block_id) || !func_->blocks_.contains(block_id)) continue;
      reachable.insert(block_id);
      const auto &block = func_->blocks_.at(block_id);
      if (block.instructions_.empty()) continue;
      const auto &last = block.instructions_.back();
      if (last.instruction_type_ == unconditional_br_) {
        stack.push_back(last.destination_);
      } else if (last.instruction_type_ == conditional_br_) {
        stack.push_back(last.if_true_);
        stack.push_back(last.if_false_);
      }
    }

    for (auto it = func_->blocks_.begin(); it != func_->blocks_.end();) {
      if (reachable.contains(it->first)) {
        ++it;
      } else {
        it = func_->blocks_.erase(it);
        changed = true;
      }
    }
    if (changed) {
      for (auto &[block_id, block] : func_->blocks_) {
        for (auto &phi : block.phi_instructions_) {
          std::vector<PhiCondition> kept;
          for (const auto &condition : phi.conditions) {
            if (reachable.contains(condition.from_block_id)) {
              kept.push_back(condition);
            }
          }
          phi.conditions = std::move(kept);
        }
      }
      continue;
    }

    const auto preds = build_preds();
    for (const auto &[block_id, block] : func_->blocks_) {
      if (block_id == entry || !block.phi_instructions_.empty() ||
          block.instructions_.size() != 1) {
        continue;
      }
      const auto &branch = block.instructions_.front();
      if (branch.instruction_type_ != unconditional_br_) {
        continue;
      }
      const int target = branch.destination_;
      if (target == block_id || !func_->blocks_.contains(target)) {
        continue;
      }
      const auto pred_it = preds.find(block_id);
      if (pred_it == preds.end() || pred_it->second.empty()) {
        continue;
      }

      // Do not merge away a critical-edge split block if the target has phis:
      // the backend stores phi moves on predecessor blocks, not per edge.
      if (!func_->blocks_.at(target).phi_instructions_.empty()) {
        bool has_critical_pred = false;
        for (const int pred : pred_it->second) {
          const auto &pred_block = func_->blocks_.at(pred);
          if (!pred_block.instructions_.empty() &&
              pred_block.instructions_.back().instruction_type_ == conditional_br_) {
            has_critical_pred = true;
            break;
          }
        }
        if (has_critical_pred) {
          continue;
        }
      }

      for (const int pred : pred_it->second) {
        auto &pred_last = func_->blocks_[pred].instructions_.back();
        if (pred_last.instruction_type_ == unconditional_br_) {
          if (pred_last.destination_ == block_id) pred_last.destination_ = target;
        } else if (pred_last.instruction_type_ == conditional_br_) {
          if (pred_last.if_true_ == block_id) pred_last.if_true_ = target;
          if (pred_last.if_false_ == block_id) pred_last.if_false_ = target;
        }
      }
      redirect_successor_phi(target, block_id, pred_it->second);
      func_->blocks_.erase(block_id);
      changed = true;
      break;
    }
  }

  RemoveDeadPhis();
}

bool Mem2Reg::EliminateTrivialPhis() {
  bool changed = false;

  auto same_def = [](const ReachingDef &lhs, const ReachingDef &rhs) {
    if (lhs.valid != rhs.valid || lhs.is_constant != rhs.is_constant) {
      return false;
    }
    if (!lhs.valid) {
      return true;
    }
    return lhs.is_constant ? lhs.const_value == rhs.const_value
                           : lhs.var_id == rhs.var_id;
  };

  for (auto &[block_id, block] : func_->blocks_) {
    for (auto it = block.phi_instructions_.begin();
         it != block.phi_instructions_.end();) {
      const int result_id = it->result_id;
      bool have_replacement = false;
      bool is_trivial = true;
      ReachingDef replacement = ReachingDef::Undef();

      for (const auto &condition : it->conditions) {
        if (!condition.is_const && condition.var_id == result_id) {
          continue;
        }

        const ReachingDef incoming = condition.is_const
            ? ReachingDef::Const(condition.value)
            : ReachingDef::Var(condition.var_id);
        if (!have_replacement) {
          replacement = incoming;
          have_replacement = true;
        } else if (!same_def(replacement, incoming)) {
          is_trivial = false;
          break;
        }
      }

      // Variable-to-variable trivial phis can perturb the current register
      // allocator enough to lose code quality. Constant phis are still useful:
      // they unlock constant folding and dead-phi cascades without introducing
      // a new live variable.
      if (is_trivial && have_replacement && replacement.is_constant) {
        ReplaceAllPhiResultUsesInFunction(*func_, result_id, replacement);
        it = block.phi_instructions_.erase(it);
        changed = true;
      } else {
        ++it;
      }
    }
  }

  return changed;
}

bool Mem2Reg::RemoveTrivialSelects() {
  bool changed = false;

  struct SelectReplacement {
    bool found = false;
    ReachingDef replacement = ReachingDef::Undef();
  };

  auto get_select_replacement = [](const IRInstruction &instruction) {
    SelectReplacement result;
    switch (instruction.instruction_type_) {
      case value_select_ii_: {
        result.found = true;
        result.replacement = instruction.condition_id_ == 0
            ? ReachingDef::Var(instruction.operand_2_id_)
            : ReachingDef::Var(instruction.operand_1_id_);
        break;
      }
      case value_select_iv_: {
        result.found = true;
        result.replacement = instruction.condition_id_ == 0
            ? ReachingDef::Const(instruction.operand_2_id_)
            : ReachingDef::Var(instruction.operand_1_id_);
        break;
      }
      case value_select_vi_: {
        result.found = true;
        result.replacement = instruction.condition_id_ == 0
            ? ReachingDef::Var(instruction.operand_2_id_)
            : ReachingDef::Const(instruction.operand_1_id_);
        break;
      }
      case value_select_vv_: {
        result.found = true;
        result.replacement = instruction.condition_id_ == 0
            ? ReachingDef::Const(instruction.operand_2_id_)
            : ReachingDef::Const(instruction.operand_1_id_);
        break;
      }
      case variable_select_ii_: {
        if (instruction.operand_1_id_ == instruction.operand_2_id_) {
          result.found = true;
          result.replacement = ReachingDef::Var(instruction.operand_1_id_);
        }
        break;
      }
      case variable_select_iv_: {
        // No same-value proof is possible across variable vs literal operands.
        break;
      }
      case variable_select_vi_: {
        // No same-value proof is possible across literal vs variable operands.
        break;
      }
      case variable_select_vv_: {
        if (instruction.operand_1_id_ == instruction.operand_2_id_) {
          result.found = true;
          result.replacement = ReachingDef::Const(instruction.operand_1_id_);
        }
        break;
      }
      default:
        break;
    }
    return result;
  };

  auto count_definitions = [&]() {
    std::map<int, int> definition_count;
    auto add_definition = [&](const int id) {
      if (id >= 0) {
        ++definition_count[id];
      }
    };

    for (int parameter_id = 0;
         parameter_id < static_cast<int>(func_->parameter_types_.size());
         ++parameter_id) {
      add_definition(parameter_id);
    }
    for (const auto &instruction : func_->alloca_instructions_) {
      add_definition(instruction.result_id_);
    }
    for (const auto &[block_id, block] : func_->blocks_) {
      for (const auto &phi : block.phi_instructions_) {
        add_definition(phi.result_id);
      }
      for (const auto &instruction : block.instructions_) {
        switch (instruction.instruction_type_) {
          case two_var_binary_operation_:
          case var_const_binary_operation_:
          case const_var_binary_operation_:
          case load_:
          case ptr_load_:
          case get_element_ptr_by_value_:
          case get_element_ptr_by_variable_:
          case two_var_icmp_:
          case var_const_icmp_:
          case const_var_icmp_:
          case non_void_call_:
          case builtin_call_:
          case value_select_ii_:
          case value_select_iv_:
          case value_select_vi_:
          case value_select_vv_:
          case variable_select_ii_:
          case variable_select_iv_:
          case variable_select_vi_:
          case variable_select_vv_: {
            add_definition(instruction.result_id_);
            break;
          }
          default:
            break;
        }
      }
    }
    return definition_count;
  };

  while (true) {
    BuildUseList();
    const auto definition_count = count_definitions();
    bool removed_one = false;

    for (auto &[block_id, block] : func_->blocks_) {
      for (auto &instruction : block.instructions_) {
        const auto replacement = get_select_replacement(instruction);
        if (!replacement.found) {
          continue;
        }
        const auto definition_it = definition_count.find(instruction.result_id_);
        if (definition_it == definition_count.end() || definition_it->second != 1) {
          continue;
        }
        if (!replacement.replacement.is_constant &&
            replacement.replacement.var_id == instruction.result_id_) {
          continue;
        }
        if (replacement.replacement.is_constant && instruction.result_type_ != nullptr &&
            instruction.result_type_->basic_type == pointer_type) {
          continue;
        }
        ReplaceAllUses(instruction.result_id_, replacement.replacement);
        instruction.instruction_type_ = unknown_;
        changed = true;
        removed_one = true;
        break;
      }
      if (removed_one) {
        break;
      }
    }

    if (!removed_one) {
      break;
    }
    RemoveDeadInstructions();
  }

  return changed;
}

bool Mem2Reg::MergePhiOnlyBlock() {
  auto build_preds = [&]() {
    std::map<int, std::set<int>> preds;
    for (const auto &[block_id, block] : func_->blocks_) {
      preds[block_id];
      if (block.instructions_.empty()) continue;
      const auto &last = block.instructions_.back();
      if (last.instruction_type_ == unconditional_br_) {
        preds[last.destination_].insert(block_id);
      } else if (last.instruction_type_ == conditional_br_) {
        preds[last.if_true_].insert(block_id);
        preds[last.if_false_].insert(block_id);
      }
    }
    return preds;
  };

  auto phi_uses_var = [](const PhiInstruction &phi, const int var_id) {
    for (const auto &condition : phi.conditions) {
      if (!condition.is_const && condition.var_id == var_id) {
        return true;
      }
    }
    return false;
  };

  auto instruction_uses_var = [](const IRInstruction &instruction, const int var_id) {
    auto is_var = [var_id](const int candidate) {
      return candidate == var_id;
    };
    switch (instruction.instruction_type_) {
      case two_var_binary_operation_:
      case two_var_icmp_:
        return is_var(instruction.operand_1_id_) || is_var(instruction.operand_2_id_);
      case var_const_binary_operation_:
      case var_const_icmp_:
        return is_var(instruction.operand_1_id_);
      case const_var_binary_operation_:
      case const_var_icmp_:
        return is_var(instruction.operand_2_id_);
      case conditional_br_:
        return is_var(instruction.condition_id_);
      case variable_ret_:
        return is_var(instruction.result_id_);
      case load_:
      case ptr_load_:
        return is_var(instruction.pointer_);
      case variable_store_:
      case ptr_store_:
        return is_var(instruction.result_id_) || is_var(instruction.pointer_);
      case value_store_:
      case get_element_ptr_by_value_:
      case builtin_memset_:
        return is_var(instruction.pointer_);
      case get_element_ptr_by_variable_:
        return is_var(instruction.pointer_) || is_var(instruction.index_);
      case non_void_call_:
      case void_call_:
      case builtin_call_:
        for (const auto &argument : instruction.function_call_arguments_) {
          if (argument.is_variable_ && is_var(argument.value_)) {
            return true;
          }
        }
        return false;
      case value_select_ii_:
        return is_var(instruction.operand_1_id_) || is_var(instruction.operand_2_id_);
      case value_select_iv_:
        return is_var(instruction.operand_1_id_);
      case value_select_vi_:
        return is_var(instruction.operand_2_id_);
      case variable_select_ii_:
        return is_var(instruction.condition_id_) ||
            is_var(instruction.operand_1_id_) || is_var(instruction.operand_2_id_);
      case variable_select_iv_:
        return is_var(instruction.condition_id_) || is_var(instruction.operand_1_id_);
      case variable_select_vi_:
        return is_var(instruction.condition_id_) || is_var(instruction.operand_2_id_);
      case variable_select_vv_:
        return is_var(instruction.condition_id_);
      case builtin_memcpy_:
        return is_var(instruction.destination_) || is_var(instruction.pointer_);
      default:
        return false;
    }
  };

  const int entry = func_->blocks_.begin()->first;
  const auto preds = build_preds();

  for (auto block_it = func_->blocks_.begin(); block_it != func_->blocks_.end();
       ++block_it) {
    const int block_id = block_it->first;
    auto &block = block_it->second;
    if (block_id == entry || block.phi_instructions_.empty() ||
        block.instructions_.size() != 1) {
      continue;
    }

    const auto &branch = block.instructions_.front();
    if (branch.instruction_type_ != unconditional_br_) {
      continue;
    }
    const int target = branch.destination_;
    if (target == block_id || !func_->blocks_.contains(target)) {
      continue;
    }

    const auto pred_it = preds.find(block_id);
    if (pred_it == preds.end() || pred_it->second.size() != 1 ||
        pred_it->second.contains(block_id) || pred_it->second.contains(target)) {
      continue;
    }

    // Keep critical-edge split blocks. Phi moves are stored on predecessor
    // blocks in the backend, so a conditional predecessor must retain a
    // dedicated edge block when the successor has phis.
    bool has_only_unconditional_preds = true;
    for (const int pred : pred_it->second) {
      const auto pred_block_it = func_->blocks_.find(pred);
      if (pred_block_it == func_->blocks_.end() ||
          pred_block_it->second.instructions_.empty()) {
        has_only_unconditional_preds = false;
        break;
      }
      const auto &pred_last = pred_block_it->second.instructions_.back();
      if (pred_last.instruction_type_ != unconditional_br_ ||
          pred_last.destination_ != block_id) {
        has_only_unconditional_preds = false;
        break;
      }
    }
    if (!has_only_unconditional_preds) {
      continue;
    }

    std::set<int> block_phi_results;
    for (const auto &phi : block.phi_instructions_) {
      block_phi_results.insert(phi.result_id);
    }

    bool all_uses_are_target_edge_phis = true;
    for (const int result_id : block_phi_results) {
      for (const auto &[scan_block_id, scan_block] : func_->blocks_) {
        for (const auto &phi : scan_block.phi_instructions_) {
          if (!phi_uses_var(phi, result_id)) {
            continue;
          }
          bool allowed = scan_block_id == target;
          if (allowed) {
            allowed = false;
            for (const auto &condition : phi.conditions) {
              if (!condition.is_const && condition.var_id == result_id &&
                  condition.from_block_id == block_id) {
                allowed = true;
                break;
              }
            }
          }
          if (!allowed) {
            all_uses_are_target_edge_phis = false;
            break;
          }
        }
        if (!all_uses_are_target_edge_phis) break;
        for (const auto &instruction : scan_block.instructions_) {
          if (instruction_uses_var(instruction, result_id)) {
            all_uses_are_target_edge_phis = false;
            break;
          }
        }
        if (!all_uses_are_target_edge_phis) break;
      }
      if (!all_uses_are_target_edge_phis) break;
    }
    if (!all_uses_are_target_edge_phis) {
      continue;
    }

    std::map<int, std::map<int, ReachingDef>> edge_values;
    for (const int pred : pred_it->second) {
      edge_values[pred] = BuildPhiValueMap(block, pred);
    }

    auto &target_block = func_->blocks_[target];
    for (auto &phi : target_block.phi_instructions_) {
      std::vector<PhiCondition> rebuilt;
      for (const auto &condition : phi.conditions) {
        if (condition.from_block_id != block_id) {
          rebuilt.push_back(condition);
          continue;
        }

        ReachingDef edge_value = condition.is_const
            ? ReachingDef::Const(condition.value)
            : ReachingDef::Var(condition.var_id);
        for (const int pred : pred_it->second) {
          ReachingDef pred_value = edge_value;
          if (pred_value.valid && !pred_value.is_constant &&
              edge_values[pred].contains(pred_value.var_id)) {
            pred_value = edge_values[pred][pred_value.var_id];
          }
          if (!pred_value.valid) {
            pred_value = ReachingDef::Const(0);
          }
          if (pred_value.is_constant) {
            rebuilt.emplace_back(pred, true, pred_value.const_value, -1);
          } else {
            rebuilt.emplace_back(pred, false, 0, pred_value.var_id);
          }
        }
      }
      phi.conditions = std::move(rebuilt);
    }

    for (const int pred : pred_it->second) {
      auto &pred_last = func_->blocks_[pred].instructions_.back();
      pred_last.destination_ = target;
    }
    func_->blocks_.erase(block_id);
    return true;
  }

  return false;
}

void Mem2Reg::SimplifyPhiCopies() {
  bool changed = true;
  while (changed) {
    changed = false;
    if (EliminateTrivialPhis()) {
      RemoveDeadPhis();
      SimplifyCFG();
      changed = true;
      continue;
    }
    if (MergePhiOnlyBlock()) {
      RemoveDeadPhis();
      SimplifyCFG();
      changed = true;
    }
  }
}

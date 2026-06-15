#include "mem2reg.h"
#include <algorithm>
#include <functional>
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

  // Collect promotable alloca ids
  std::vector<int> promotable_alloca_ids;
  for (const auto &alloca_inst : func_->alloca_instructions_) {
    int alloca_id = alloca_inst.result_id_;
    if (IsPromotable(alloca_id)) {
      promotable_alloca_ids.push_back(alloca_id);
    }
  }

  // Promote each alloca
  for (int alloca_id : promotable_alloca_ids) {
    PromoteAlloca(alloca_id);
  }

  // Remove the promoted alloca instructions from alloca list
  {
    const std::set promoted_set(promotable_alloca_ids.begin(),
                                     promotable_alloca_ids.end());
    std::vector<IRInstruction> remaining;
    for (auto &inst : func_->alloca_instructions_) {
      if (!promoted_set.contains(inst.result_id_)) {
        remaining.push_back(inst);
      }
    }
    func_->alloca_instructions_ = std::move(remaining);
  }

  // Remove dead load/store instructions
  RemoveDeadInstructions();
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
// Promotability check — see plan.md step 1.1 for the per-instruction rationale
// ============================================================================

bool Mem2Reg::IsPromotable(const int alloca_id) const {
  for (const auto &[block_id, block] : func_->blocks_) {
    for (const auto &inst : block.instructions_) {
      switch (inst.instruction_type_) {
        // case two_var_binary_operation_:
        // case var_const_binary_operation_:
        // case const_var_binary_operation_:
        // case conditional_br_:
        // case unconditional_br_:
        // case value_ret_:
        // case void_ret_:
        // case alloca_:
        // case load_:
        // case ptr_load_:
        // case value_store_:
        // case builtin_call_:
        // case two_var_icmp_:
        // case var_const_icmp_:
        // case const_var_icmp_:
        // case value_select_vv_:
        // case variable_select_vv_:
        case variable_ret_:
        case variable_store_:
        case ptr_store_: {
          if (inst.result_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case get_element_ptr_by_value_:
        case get_element_ptr_by_variable_:
        case builtin_memset_: {
          if (inst.pointer_ == alloca_id) {
            return false;
          }
          break;
        }
        case builtin_memcpy_: {
          if (inst.destination_ == alloca_id || inst.pointer_ == alloca_id) {
            return false;
          }
          break;
        }
        case non_void_call_:
        case void_call_: {
          for (const auto &argument : inst.function_call_arguments_) {
            if (argument.is_variable_ && argument.value_ == alloca_id) {
              return false;
            }
          }
          break;
        }
        case phi_: {
          if ((inst.function_name_ & 0b10) == 0 && inst.operand_1_id_ == alloca_id) {
            return false;
          }
          if ((inst.function_name_ & 0b01) == 0 && inst.operand_2_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case value_select_ii_: {
          if (inst.condition_id_ == 0 && inst.operand_2_id_ == alloca_id) {
            return false;
          }
          if (inst.condition_id_ != 0 && inst.operand_1_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case value_select_iv_: {
          if (inst.condition_id_ != 0 && inst.operand_1_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case value_select_vi_: {
          if (inst.condition_id_ == 0 && inst.operand_2_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case variable_select_ii_: {
          if (inst.operand_2_id_ == alloca_id) {
            return false;
          }
          if (inst.operand_1_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case variable_select_iv_: {
          if (inst.operand_1_id_ == alloca_id) {
            return false;
          }
          break;
        }
        case variable_select_vi_: {
          if (inst.operand_2_id_ == alloca_id) {
            return false;
          }
          break;
        }
        default:;
      }
    }
  }
  return true;
}

// ============================================================================
// Promote a single alloca
// ============================================================================

void Mem2Reg::PromoteAlloca(int alloca_id) {
  current_alloca_id_ = alloca_id;
  stores_of_alloca_.clear();
  loads_of_alloca_.clear();

  // --- Step 1: Collect stores and loads ---
  // Gather all blocks that contain a store (definition) to this alloca.
  // Handles: variable_store_, value_store_, ptr_store_ (all have pointer_ == alloca_id)
  // Loads: load_, ptr_load_ (all have pointer_ == alloca_id)
  std::set<int> def_blocks;

  for (auto &[block_id, block] : func_->blocks_) {
    for (int idx = 0; idx < static_cast<int>(block.instructions_.size()); ++idx) {
      const auto &inst = block.instructions_[idx];
      switch (inst.instruction_type_) {
        case variable_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[block_id].push_back(
                {idx, inst.result_id_, false});
            def_blocks.insert(block_id);
          }
          break;
        }
        case value_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[block_id].push_back(
                {idx, inst.result_id_, true});
            def_blocks.insert(block_id);
          }
          break;
        }
        case ptr_store_: {
          if (inst.pointer_ == alloca_id) {
            stores_of_alloca_[block_id].push_back(
                {idx, inst.result_id_, false});
            def_blocks.insert(block_id);
          }
          break;
        }
        case load_:
        case ptr_load_: {
          if (inst.pointer_ == alloca_id) {
            loads_of_alloca_[block_id].push_back({idx, inst.result_id_});
          }
          break;
        }
        default:;
      }
    }
  }

  if (def_blocks.empty()) return; // nothing to promote

  // --- Step 2: Place phi nodes ---
  std::set<int> phi_blocks;
  std::set<int> phi_result_ids;
  std::vector<int> worklist(def_blocks.begin(), def_blocks.end());

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
      if (!phi_blocks.count(y)) {
        int phi_result_id = func_->var_id_++;
        phi_result_ids.insert(phi_result_id);
        // Insert phi with sentinels -1 for unfilled operands
        func_->blocks_[y].instructions_.insert(
            func_->blocks_[y].instructions_.begin(),
            IRInstruction(phi_, phi_result_id, add_, alloca_type, 0, 0,
                          0, -1, -1, 0, 0, equal_, 0));
        phi_blocks.insert(y);
        worklist.push_back(y);
      }
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
    for (auto &inst : block_insts) {
      if (inst.instruction_type_ == phi_ &&
          phi_result_ids.count(inst.result_id_)) {
        reaching_stack.push(ReachingDef::Var(inst.result_id_));
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
    auto &insts = func_->blocks_[block_id].instructions_;
    auto preds = std::vector<int>(predecessors_[block_id].begin(),
                                  predecessors_[block_id].end());

    for (auto &inst : insts) {
      if (inst.instruction_type_ == phi_ &&
          phi_result_ids.count(inst.result_id_)) {
        if (preds.size() >= 1) {
          int p0 = preds[0];
          inst.if_true_ = p0;
          ReachingDef def0 = block_exit_defs.count(p0)
              ? block_exit_defs[p0] : ReachingDef::Undef();
          if (def0.valid && !def0.is_constant) {
            inst.operand_1_id_ = def0.var_id;
            inst.function_name_ &= ~0b10; // operand1 is variable
          } else if (def0.valid) {
            inst.operand_1_id_ = def0.const_value;
            inst.function_name_ |= 0b10;  // operand1 is literal
          }
        }
        if (preds.size() >= 2) {
          int p1 = preds[1];
          inst.if_false_ = p1;
          ReachingDef def1 = block_exit_defs.count(p1)
              ? block_exit_defs[p1] : ReachingDef::Undef();
          if (def1.valid && !def1.is_constant) {
            inst.operand_2_id_ = def1.var_id;
            inst.function_name_ &= ~0b01; // operand2 is variable
          } else if (def1.valid) {
            inst.operand_2_id_ = def1.const_value;
            inst.function_name_ |= 0b01;  // operand2 is literal
          }
        }
        break;
      }
    }
  }

  // --- Step 5: Replace all uses of load results with their reaching defs ---
  for (const auto &[old_id, new_def] : replacement_map) {
    if (new_def.valid) {
      ReplaceAllUses(old_id, new_def);
    }
  }

  // --- Step 6: Re-scan phis to apply the replacement map ---
  for (int block_id : phi_blocks) {
    for (auto &inst : func_->blocks_[block_id].instructions_) {
      if (inst.instruction_type_ == phi_ &&
          phi_result_ids.count(inst.result_id_)) {
        // operand 1
        if (!(inst.function_name_ & 0b10) &&
            replacement_map.count(inst.operand_1_id_)) {
          const ReachingDef &def = replacement_map[inst.operand_1_id_];
          if (!def.is_constant) {
            inst.operand_1_id_ = def.var_id;
          } else {
            inst.operand_1_id_ = def.const_value;
            inst.function_name_ |= 0b10;
          }
        }
        // operand 2
        if (!(inst.function_name_ & 0b01) &&
            replacement_map.count(inst.operand_2_id_)) {
          const ReachingDef &def = replacement_map[inst.operand_2_id_];
          if (!def.is_constant) {
            inst.operand_2_id_ = def.var_id;
          } else {
            inst.operand_2_id_ = def.const_value;
            inst.function_name_ |= 0b01;
          }
        }
      }
    }
  }

  current_alloca_id_ = -1;
}

// Forward declarations for helper functions used by ReplaceAllUses
static void ReplaceVarWithVar(IRInstruction &inst, int old_id, int new_id);
static void ReplaceVarWithConst(IRInstruction &inst, int old_id, int const_val);

// ============================================================================
// Replace all uses of old_id with new_def (variable or constant)
// ============================================================================

void Mem2Reg::ReplaceAllUses(const int old_id, const ReachingDef &new_def) const {
  for (auto &[block_id, block] : func_->blocks_) {
    for (auto &inst : block.instructions_) {
      if (!new_def.is_constant) {
        // --- Variable replacement: simple ID substitution ---
        int new_id = new_def.var_id;
        ReplaceVarWithVar(inst, old_id, new_id);
      } else {
        // --- Constant replacement: may change instruction type ---
        int const_val = new_def.const_value;
        ReplaceVarWithConst(inst, old_id, const_val);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Helper: replace old_id with new_id (both variables) in a single instruction
// ---------------------------------------------------------------------------
void ReplaceVarWithVar(IRInstruction &inst, int old_id, int new_id) {
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
    case variable_store_: {
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
    case phi_: {
      if (!(inst.function_name_ & 0b10) && inst.operand_1_id_ == old_id)
        inst.operand_1_id_ = new_id;
      if (!(inst.function_name_ & 0b01) && inst.operand_2_id_ == old_id)
        inst.operand_2_id_ = new_id;
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
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case value_select_iv_: {
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case value_select_vi_: {
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
      break;
    }
    case value_select_vv_: {
      if (inst.condition_id_ == old_id) inst.condition_id_ = new_id;
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
        // operand_2_id_ stays as the other variable
      } else if (inst.operand_2_id_ == old_id) {
        inst.instruction_type_ = var_const_binary_operation_;
        inst.operand_2_id_ = const_val;
        // operand_1_id_ stays as the other variable
      }
      break;
    }
    case var_const_binary_operation_: {
      if (inst.operand_1_id_ == old_id) {
        // Both operands become constants — fold? Not mem2reg's job.
        // Leave as-is; the const operand is already const.
      }
      break;
    }
    case const_var_binary_operation_: {
      if (inst.operand_2_id_ == old_id) {
        // Both operands become constants — leave as-is.
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
    // --- Return ---
    case variable_ret_: {
      if (inst.result_id_ == old_id) {
        inst.instruction_type_ = value_ret_;
        inst.result_id_ = const_val;
      }
      break;
    }
    // --- Store ---
    case variable_store_: {
      if (inst.result_id_ == old_id) {
        inst.instruction_type_ = value_store_;
        inst.result_id_ = const_val;
      }
      break;
    }
    // --- Conditional branch ---
    case conditional_br_: {
      if (inst.condition_id_ == old_id) {
        // Constant condition: fold to unconditional branch
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
    // --- Phi ---
    case phi_: {
      if (!(inst.function_name_ & 0b10) && inst.operand_1_id_ == old_id) {
        inst.operand_1_id_ = const_val;
        inst.function_name_ |= 0b10; // mark as literal
      }
      if (!(inst.function_name_ & 0b01) && inst.operand_2_id_ == old_id) {
        inst.operand_2_id_ = const_val;
        inst.function_name_ |= 0b01; // mark as literal
      }
      break;
    }
    // --- Select: variable → value select ---
    case variable_select_ii_: {
      if (inst.condition_id_ == old_id) {
        inst.instruction_type_ = value_select_ii_;
        inst.condition_id_ = const_val;
      }
      if (inst.operand_1_id_ == old_id) {
        inst.instruction_type_ = value_select_ii_;
        inst.operand_1_id_ = const_val;
      }
      if (inst.operand_2_id_ == old_id) {
        inst.instruction_type_ = value_select_ii_;
        inst.operand_2_id_ = const_val;
      }
      break;
    }
    case variable_select_iv_: {
      if (inst.condition_id_ == old_id) {
        inst.instruction_type_ = value_select_iv_;
        inst.condition_id_ = const_val;
      }
      if (inst.operand_1_id_ == old_id) {
        inst.instruction_type_ = value_select_iv_;
        inst.operand_1_id_ = const_val;
      }
      break;
    }
    case variable_select_vi_: {
      if (inst.condition_id_ == old_id) {
        inst.instruction_type_ = value_select_vi_;
        inst.condition_id_ = const_val;
      }
      if (inst.operand_2_id_ == old_id) {
        inst.instruction_type_ = value_select_vi_;
        inst.operand_2_id_ = const_val;
      }
      break;
    }
    case variable_select_vv_: {
      if (inst.condition_id_ == old_id) {
        inst.instruction_type_ = value_select_vv_;
        inst.condition_id_ = const_val;
      }
      break;
    }
    default:
      break;
  }
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

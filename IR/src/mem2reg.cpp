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
  // This happens when, e.g., an alloca has stores+loads in the same descendant
  // block (the phi at the dominance frontier was needed for SSA correctness
  // but its value is shadowed by the local store before any load reads it).
  // Iteratively remove dead phis.
  RemoveDeadPhis();
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
    for (const auto &inst : block.phi_instructions_) {
      for (const auto &condition : inst.conditions) {
        if (!condition.is_const && condition.var_id == alloca_id) {
          return false;
        }
      }
    }
    for (const auto &inst : block.instructions_) {
      switch (inst.instruction_type_) {
        case variable_ret_:
        case variable_store_:
        case ptr_store_: {
          if (inst.result_id_ == alloca_id) {
            std::cerr << "[m2r] alloca " << alloca_id << " NOT promotable: result_id matches in "
                      << static_cast<int>(inst.instruction_type_) << " at block " << block_id << "\n";
            return false;
          }
          break;
        }
        case get_element_ptr_by_value_:
        case get_element_ptr_by_variable_:
        case builtin_memset_: {
          if (inst.pointer_ == alloca_id) {
            std::cerr << "[m2r] alloca " << alloca_id << " NOT promotable: pointer matches in gep/memset\n";
            return false;
          }
          break;
        }
        case builtin_memcpy_: {
          if (inst.destination_ == alloca_id || inst.pointer_ == alloca_id) {
            std::cerr << "[m2r] alloca " << alloca_id << " NOT promotable: used in memcpy\n";
            return false;
          }
          break;
        }
        case non_void_call_:
        case void_call_: {
          for (const auto &argument : inst.function_call_arguments_) {
            if (argument.is_variable_ && argument.value_ == alloca_id) {
              std::cerr << "[m2r] alloca " << alloca_id << " NOT promotable: passed to call as variable arg\n";
              return false;
            }
          }
          break;
        }
        // case phi_: {
        //   if ((inst.function_name_ & 0b10) == 0 && inst.operand_1_id_ == alloca_id) {
        //     return false;
        //   }
        //   if ((inst.function_name_ & 0b01) == 0 && inst.operand_2_id_ == alloca_id) {
        //     return false;
        //   }
        //   break;
        // }
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

bool Mem2Reg::PromoteAlloca(int alloca_id) {
  current_alloca_id_ = alloca_id;
  stores_of_alloca_.clear();
  loads_of_alloca_.clear();
  std::cerr << "[m2r] PromoteAlloca: alloca_id=" << alloca_id << "\n";

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

  if (def_blocks.empty()) return true; // nothing to promote (no stores, but loads may exist)

  // --- Step 1.5: Pruned-SSA liveness precomputation ---
  // A phi at block Y is only useful if the alloca is *loaded* somewhere in
  // Y's dom-tree subtree (Y itself or any descendant). Otherwise the phi is
  // dead — its result is never read — and inserting it would force bogus
  // operands on the "undef" predecessor paths.
  //
  // We compute live_load_in_subtree[Y] = true iff some block in {Y ∪ dom-descendants(Y)}
  // contains a load of this alloca. Bottom-up over the dom tree.

  // First, the set of blocks that themselves load this alloca.
  std::set<int> blocks_that_load;
  for (const auto &[block_id, block] : func_->blocks_) {
    for (const auto &inst : block.instructions_) {
      if ((inst.instruction_type_ == load_ || inst.instruction_type_ == ptr_load_)
          && inst.pointer_ == alloca_id) {
        blocks_that_load.insert(block_id);
        break;
      }
    }
  }

  // Bottom-up computation via post-order of the dom tree. We process dom-tree
  // nodes in reverse DFN order — this guarantees children are processed before
  // their parents.
  std::map<int, bool> live_load_in_subtree;
  for (int i = static_cast<int>(vertex_.size()) - 1; i >= 1; --i) {
    int b = vertex_[i];
    bool any = blocks_that_load.contains(b);
    for (int child : dom_children_[b]) {
      if (live_load_in_subtree[child]) any = true;
    }
    live_load_in_subtree[b] = any;
  }

  // --- Step 1.6: Bail-out check for unsupported phi fan-in ---
  // This IR's phi instruction has exactly two operand slots (one per predecessor
  // label). If any *live* phi block (after pruning) would have more than two
  // predecessors, we cannot represent the phi correctly — so we skip promotion
  // for this alloca entirely.
  //
  // We compute the iterated dominance frontier, intersect with live blocks
  // (pruned SSA), and check the predecessor count.
  {
    std::set<int> iter_df;
    std::vector wl(def_blocks.begin(), def_blocks.end());
    while (!wl.empty()) {
      int x = wl.back();
      wl.pop_back();
      for (int y : dom_frontier_[x]) {
        if (!iter_df.contains(y)) {
          iter_df.insert(y);
          wl.push_back(y);
        }
      }
    }
    for (int y : iter_df) {
      // Pruned SSA: a phi at Y is only useful if the alloca is loaded somewhere
      // in Y's dom-tree subtree. Otherwise it's dead and we can skip it.
      if (!live_load_in_subtree[y]) continue;
      const auto it = predecessors_.find(y);
      if (it != predecessors_.end() && it->second.size() > 2) {
        std::cerr << "[m2r]   alloca " << alloca_id
                  << ": NOT promotable — live iterated DF block " << y << " has "
                  << it->second.size() << " predecessors (phi supports only 2)\n";
        return false;
      }
    }
  }

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
      if (!phi_blocks.contains(y)) {
        int phi_result_id = func_->var_id_++;
        phi_result_ids.insert(phi_result_id);
        std::cerr << "[m2r]   alloca " << alloca_id << ": inserting phi result="
                  << phi_result_id << " at block " << y << " (DF of block " << x << ")\n";
        // Insert phi with sentinels -1 for unfilled operands
        func_->blocks_[y].AddPhi(phi_result_id, alloca_type, -1, -1, false);
        // func_->blocks_[y].instructions_.insert(
        //     func_->blocks_[y].instructions_.begin(),
        //     IRInstruction(phi_, phi_result_id, add_, alloca_type, 0, 0,
        //                   0, -1, -1, 0, 0, equal_, 0));
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
    std::cerr << "[m2r]     rename_dfs visited block " << block_id
              << ": exit_def.valid=" << reaching_stack.top().valid
              << (reaching_stack.top().valid ? (reaching_stack.top().is_constant
                  ? (", const=" + std::to_string(reaching_stack.top().const_value))
                  : (", var=" + std::to_string(reaching_stack.top().var_id))) : "")
              << "\n";

    // Recurse into dominator tree children
    for (int child : dom_children_[block_id]) {
      std::cerr << "[m2r]       block " << block_id << " -> child " << child << "\n";
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
      if (phi_result_ids.contains(inst.result_id)) {
        std::cerr << "[m2r]   alloca " << alloca_id << ": filling phi result="
                  << inst.result_id << " at block " << block_id
                  << " (preds=";
        for (int p : preds) std::cerr << " " << p;
        std::cerr << ")\n";
        if (preds.size() != inst.conditions.size()) {
          Mem2RegThrow("Mismatched pred & phi conditions size!");
        }
        for (const auto p : preds) {
          int i = 0;
          for (; i < inst.conditions.size(); ++i) {
            if (inst.conditions[i].from_block_id == -1) {
              break;
            }
          }
          if (i == inst.conditions.size()) {
            Mem2RegThrow("No undecided condition to be complete!");
          }
          inst.conditions[i].from_block_id = p;
          ReachingDef def = block_exit_defs.contains(p) ? block_exit_defs[p] : ReachingDef::Undef();
          if (def.valid && !def.is_constant) {
            inst.conditions[i].var_id = def.var_id;
            inst.conditions[i].is_const = false;
            std::cerr << "[m2r]     condition " << i << " from pred " << p << ": var " << def.var_id << "\n";
          } else if (def.valid) {
            inst.conditions[i].value = def.const_value;
            inst.conditions[i].is_const = true;
            std::cerr << "[m2r]     condition " << i << " from pred " << p << ": const " << def.const_value << "\n";
          } else {
            // Undef path — represent as %var.-1 rather than
            // leaving the default, which would otherwise be misread as var.0.
            inst.conditions[i].value = 0;
            inst.conditions[i].var_id = -1;
            inst.conditions[i].is_const = false;
            std::cerr << "[m2r]     condition " << i << " from pred " << p << ": UNDEF -> %var.-1\n";
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
    for (auto &inst : func_->blocks_[block_id].phi_instructions_) {
      if (phi_result_ids.contains(inst.result_id)) {
        for (auto &condition : inst.conditions) {
          if (!condition.is_const && replacement_map.contains(condition.var_id)) {
            const ReachingDef &def = replacement_map[condition.var_id];
            if (!def.is_constant) {
              condition.var_id = def.var_id;
            } else {
              condition.value = def.const_value;
              condition.is_const = true;
            }
          }
        }
        // // operand 1
        // if (!(inst.function_name_ & 0b10) &&
        //     replacement_map.count(inst.operand_1_id_)) {
        //   const ReachingDef &def = replacement_map[inst.operand_1_id_];
        //   if (!def.is_constant) {
        //     inst.operand_1_id_ = def.var_id;
        //   } else {
        //     inst.operand_1_id_ = def.const_value;
        //     inst.function_name_ |= 0b10;
        //   }
        // }
        // // operand 2
        // if (!(inst.function_name_ & 0b01) &&
        //     replacement_map.count(inst.operand_2_id_)) {
        //   const ReachingDef &def = replacement_map[inst.operand_2_id_];
        //   if (!def.is_constant) {
        //     inst.operand_2_id_ = def.var_id;
        //   } else {
        //     inst.operand_2_id_ = def.const_value;
        //     inst.function_name_ |= 0b01;
        //   }
        // }
      }
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

// ============================================================================
// Replace all uses of old_id with new_def (variable or constant)
// ============================================================================

void Mem2Reg::ReplaceAllUses(const int old_id, const ReachingDef &new_def) const {
  for (auto &[block_id, block] : func_->blocks_) {
    for (auto &inst : block.phi_instructions_) {
      if (!new_def.is_constant) {
        int new_id = new_def.var_id;
        ReplacePhiVarWithVar(inst, old_id, new_id);
      } else {
        int const_val = new_def.const_value;
        ReplacePhiVarWithConst(inst, old_id, const_val);
      }
    }
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
    // case phi_: {
    //   if (!(inst.function_name_ & 0b10) && inst.operand_1_id_ == old_id)
    //     inst.operand_1_id_ = new_id;
    //   if (!(inst.function_name_ & 0b01) && inst.operand_2_id_ == old_id)
    //     inst.operand_2_id_ = new_id;
    //   break;
    // }
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
    // For value_select_*: condition is a LITERAL (0 or 1), so condition_id_
    // is never a variable to replace. The OPERANDS (operand_1_id_ / operand_2_id_)
    // are variables, and we must replace them.
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
  // if (!(inst.function_name_ & 0b10) && inst.operand_1_id_ == old_id)
  //   inst.operand_1_id_ = new_id;
  // if (!(inst.function_name_ & 0b01) && inst.operand_2_id_ == old_id)
  //   inst.operand_2_id_ = new_id;
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
// Uses value_select_ii_ with condition=1 and both operands set to the constant.
static void ReplaceInstWithConst(IRInstruction &inst, int folded_val) {
  if (inst.instruction_type_ == var_const_icmp_ || inst.instruction_type_ == const_var_icmp_) {
    inst.result_type_->basic_type = bool_type;
    inst.result_type_->is_int = false;
    inst.another_type_ = inst.result_type_;
  }
  inst.instruction_type_ = value_select_vv_;
  inst.condition_id_ = 1;          // true → pick operand_1
  inst.operand_1_id_ = folded_val;
  inst.operand_2_id_ = folded_val;
  // result_type_ / another_type_  stay as-is (the original result type)
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
        // Both operands are now constants → fold
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
        // Both operands are now constants → fold to 0 or 1
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
    // case phi_: {
    //   if (!(inst.function_name_ & 0b10) && inst.operand_1_id_ == old_id) {
    //     inst.operand_1_id_ = const_val;
    //     inst.function_name_ |= 0b10;
    //   }
    //   if (!(inst.function_name_ & 0b01) && inst.operand_2_id_ == old_id) {
    //     inst.operand_2_id_ = const_val;
    //     inst.function_name_ |= 0b01;
    //   }
    //   break;
    // }
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

// Iterate to fixed point: remove phis whose result is never referenced by
// any other instruction (including other phis). Removing one phi may make
// another phi unused, so loop until no changes.
void Mem2Reg::RemoveDeadPhis() const {
  bool changed = true;
  while (changed) {
    changed = false;
    // Collect the set of phi result ids in this function.
    std::set<int> phi_results;
    for (const auto &[block_id, block] : func_->blocks_) {
      for (const auto &inst : block.phi_instructions_) {
        phi_results.insert(inst.result_id);
      }
    }
    // Collect the set of phi result ids that are *referenced* by some other
    // instruction. A phi references another phi if one of its variable operands
    // equals that phi's result id.
    std::set<int> referenced;
    auto consider = [&](int var_id, bool is_var) {
      // Only count variable references; literals are not variable ids.
      if (is_var && var_id != 0) referenced.insert(var_id);
    };
    for (const auto &[block_id, block] : func_->blocks_) {
      for (const auto &inst : block.phi_instructions_) {
        for (const auto &condition : inst.conditions) {
          consider(condition.var_id, !condition.is_const);
        }
      }
      for (const auto &inst : block.instructions_) {
        // Skip phi itself for the operand check below — we look at uses FROM
        // other instructions (and FROM phis at different positions).
        switch (inst.instruction_type_) {
          case two_var_binary_operation_:
          case two_var_icmp_:
            consider(inst.operand_1_id_, true);
            consider(inst.operand_2_id_, true);
            break;
          case var_const_binary_operation_:
          case const_var_binary_operation_:
          case var_const_icmp_:
          case const_var_icmp_:
            consider(inst.operand_1_id_, true);
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
            consider(inst.condition_id_, true);
            break;
          case value_select_iv_:
            consider(inst.condition_id_, true);
            break;
          case value_select_vi_:
            consider(inst.condition_id_, true);
            break;
          case value_select_vv_:
            consider(inst.condition_id_, true);
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
    // Remove phis whose result is unreferenced.
    for (auto &[block_id, block] : func_->blocks_) {
      std::vector<PhiInstruction> remaining;
      for (const auto &inst : block.phi_instructions_) {
        if (phi_results.contains(inst.result_id) &&
            !referenced.contains(inst.result_id)) {
          changed = true;
          continue;
        }
        remaining.push_back(inst);
      }
      block.phi_instructions_ = std::move(remaining);
    }
  }
}

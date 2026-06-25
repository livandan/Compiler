#include "register_allocator.h"
#include <algorithm>
#include <cassert>
#include <iostream>
#include <queue>

RegisterAllocator::RegisterAllocator(const IRFunctionNode &ir_func,
                                     RISCVFunctionNode &riscv_func,
                                     bool is_leaf)
    : ir_func_(ir_func), riscv_func_(riscv_func), is_leaf_(is_leaf) {

  // Build the pool of allocatable physical registers.
  // Reserved: x0(zero), x1(ra), x2(sp), x3(gp), x4(tp)
  // Scratch:  x5(t0), x6(t1), x7(t2), x31(t6)
  //
  // For leaf functions (no calls), prefer caller-saved registers first
  // (a0-a7, t3-t5) since they are never clobbered and don't need
  // prologue/epilogue save/restore.  This allows small leaf functions
  // to compile with zero callee-saved register overhead.
  if (is_leaf) {
    // Caller-saved first: a0-a7 (10-17), t3-t5 (28-30)
    for (int r = 10; r <= 17; ++r) allocatable_regs_.push_back(r);
    for (int r = 28; r <= 30; ++r) allocatable_regs_.push_back(r);
    // Then callee-saved: s0-s1 (8-9), s2-s11 (18-27)
    allocatable_regs_.push_back(8);
    allocatable_regs_.push_back(9);
    for (int r = 18; r <= 27; ++r) allocatable_regs_.push_back(r);
  } else {
    for (int r = 0; r < 32; ++r) {
      if (!IsReservedReg(r) && !IsScratchReg(r)) {
        allocatable_regs_.push_back(r);
      }
    }
  }
}

void RegisterAllocator::Run() {
  ClassifyVariables();
  BuildCFG();
  ComputeLiveness();
  BuildInterferenceGraph();
  ColorGraph();
  UpdateLocationMap();
}

// ============================================================================
// Step 0: Classify variables
// ============================================================================

bool RegisterAllocator::IsScalarType(const std::shared_ptr<IntegratedType> &type) {
  if (!type) return false;
  switch (type->basic_type) {
    case bool_type:
    case i32_type:
    case u32_type:
    case isize_type:
    case usize_type:
    case enumeration_type:
    case pointer_type:
      return true;
    default:
      return false;
  }
}

void RegisterAllocator::ClassifyVariables() {
  // Alloca'd variables MUST stay on the stack (their address may be taken).
  for (const auto &alloca : ir_func_.alloca_instructions_) {
    stack_bound_vars_.insert(alloca.result_id_);
  }

  // Remove parameter-assigned registers from the allocatable pool.
  int num_params = static_cast<int>(ir_func_.parameter_types_.size());
  for (int i = 0; i < num_params; ++i) {
    if (riscv_func_.location_.count(i) && riscv_func_.location_[i].first) {
      int reg = riscv_func_.location_[i].second;
      auto it = std::find(allocatable_regs_.begin(), allocatable_regs_.end(), reg);
      if (it != allocatable_regs_.end()) {
        allocatable_regs_.erase(it);
      }
    }
  }

  // Scan all blocks for variables.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    for (const auto &inst : block.instructions_) {
      int result_id = inst.result_id_;

      // load_ and ptr_load_ results always stay on stack. After mem2reg,
      // remaining loads read from non-promotable allocas; their types
      // may not be safe for register promotion.
      if (inst.instruction_type_ == load_ || inst.instruction_type_ == ptr_load_) {
        if (result_id > 0) {
          stack_bound_vars_.insert(result_id);
        }
        continue;
      }

      // GEP results (pointer computations) stay on stack for safety.
      // Their register paths are fragile and easily broken.
      if (inst.instruction_type_ == get_element_ptr_by_value_ ||
          inst.instruction_type_ == get_element_ptr_by_variable_) {
        if (result_id > 0) {
          stack_bound_vars_.insert(result_id);
        }
        continue;
      }

      // Check if the instruction produces a result and classify it.
      // Only allocate registers for the safest types: binary ops, icmp,
      // select, and non-void calls.  Everything else stays on stack.
      if (result_id > 0 && !stack_bound_vars_.count(result_id)) {
        switch (inst.instruction_type_) {
          case two_var_binary_operation_:
          case var_const_binary_operation_:
          case const_var_binary_operation_:
          case two_var_icmp_:
          case var_const_icmp_:
          case const_var_icmp_:
          case value_select_ii_: case value_select_iv_:
          case value_select_vi_: case value_select_vv_:
          case variable_select_ii_: case variable_select_iv_:
          case variable_select_vi_: case variable_select_vv_:
          case non_void_call_:
          case builtin_call_:
            if (IsScalarType(inst.result_type_)) {
              allocatable_vars_.insert(result_id);
              var_size_[result_id] = (inst.result_type_->basic_type == pointer_type) ? 8 : 4;
            } else {
              stack_bound_vars_.insert(result_id);
            }
            break;
          default:
            stack_bound_vars_.insert(result_id);
            break;
        }
      }
    }
    // Handle phi instructions — only int/bool phis get registers.
    for (const auto &phi : block.phi_instructions_) {
      int result_id = phi.result_id;
      if (!stack_bound_vars_.count(result_id)) {
        if (IsScalarType(phi.type) && phi.type->basic_type != pointer_type) {
          allocatable_vars_.insert(result_id);
        } else {
          stack_bound_vars_.insert(result_id);
        }
      }
      // Phi results are handled by the final pass below.
    }
  }
  // NOTE: Missing location_ entries for phi results and promoted allocas
  // are handled by a new loop in MemAlloc (see code_generator.cpp).
}

// ============================================================================
// Step 1: Build CFG
// ============================================================================

void RegisterAllocator::BuildCFG() {
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    if (block.instructions_.empty()) {
      continue;
    }
    const auto &last = block.instructions_.back();
    switch (last.instruction_type_) {
      case conditional_br_: {
        successors_[block_id].push_back(last.if_true_);
        successors_[block_id].push_back(last.if_false_);
        predecessors_[last.if_true_].push_back(block_id);
        predecessors_[last.if_false_].push_back(block_id);
        break;
      }
      case unconditional_br_: {
        successors_[block_id].push_back(last.destination_);
        predecessors_[last.destination_].push_back(block_id);
        break;
      }
      default: {
        break;
      }
    }
  }
}

// ============================================================================
// Step 2: Compute liveness
// ============================================================================

void RegisterAllocator::ComputeLiveness() {
  // Compute def/use sets for each block.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    std::set<int> &defs = block_defs_[block_id];
    std::set<int> &uses = block_uses_[block_id];

    for (const auto &inst : block.instructions_) {
      // Collect uses
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
          uses.insert(inst.operand_1_id_);
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        case var_const_binary_operation_:
          uses.insert(inst.operand_1_id_);
          defs.insert(inst.result_id_);
          break;
        case const_var_binary_operation_:
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        case conditional_br_:
          uses.insert(inst.condition_id_);
          break;
        case variable_ret_:
          uses.insert(inst.result_id_);
          break;
        case load_:
        case ptr_load_:
          uses.insert(inst.pointer_);
          defs.insert(inst.result_id_);
          break;
        case variable_store_:
          uses.insert(inst.result_id_);
          uses.insert(inst.pointer_);
          break;
        case value_store_:
          uses.insert(inst.pointer_);
          break;
        case ptr_store_:
          uses.insert(inst.pointer_);
          uses.insert(inst.result_id_);
          break;
        case get_element_ptr_by_value_:
          uses.insert(inst.pointer_);
          defs.insert(inst.result_id_);
          break;
        case get_element_ptr_by_variable_:
          uses.insert(inst.pointer_);
          uses.insert(inst.index_);
          defs.insert(inst.result_id_);
          break;
        case two_var_icmp_:
          uses.insert(inst.operand_1_id_);
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        case var_const_icmp_:
          uses.insert(inst.operand_1_id_);
          defs.insert(inst.result_id_);
          break;
        case const_var_icmp_:
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        case non_void_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              uses.insert(arg.value_);
            }
          }
          defs.insert(inst.result_id_);
          break;
        }
        case void_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              uses.insert(arg.value_);
            }
          }
          break;
        }
        case builtin_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              uses.insert(arg.value_);
            }
          }
          if (inst.function_name_ == 2) {
            defs.insert(inst.result_id_);
          }
          break;
        }
        case value_select_ii_: {
          if (inst.condition_id_ == 0) {
            uses.insert(inst.operand_2_id_);
          } else {
            uses.insert(inst.operand_1_id_);
          }
          defs.insert(inst.result_id_);
          break;
        }
        case value_select_iv_: {
          if (inst.condition_id_ != 0) {
            uses.insert(inst.operand_1_id_);
          }
          defs.insert(inst.result_id_);
          break;
        }
        case value_select_vi_: {
          if (inst.condition_id_ == 0) {
            uses.insert(inst.operand_2_id_);
          }
          defs.insert(inst.result_id_);
          break;
        }
        case value_select_vv_: {
          defs.insert(inst.result_id_);
          break;
        }
        case variable_select_ii_: {
          uses.insert(inst.condition_id_);
          uses.insert(inst.operand_1_id_);
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        }
        case variable_select_vv_: {
          uses.insert(inst.condition_id_);
          defs.insert(inst.result_id_);
          break;
        }
        case variable_select_iv_: {
          uses.insert(inst.condition_id_);
          uses.insert(inst.operand_1_id_);
          defs.insert(inst.result_id_);
          break;
        }
        case variable_select_vi_: {
          uses.insert(inst.condition_id_);
          uses.insert(inst.operand_2_id_);
          defs.insert(inst.result_id_);
          break;
        }
        case builtin_memset_:
          uses.insert(inst.pointer_);
          break;
        case builtin_memcpy_:
          uses.insert(inst.destination_);
          uses.insert(inst.pointer_);
          break;
        default:
          break;
      }
    }

    // Handle phi instructions: the result is a def in this block.
    // The source operands are uses in the PREDECESSOR blocks.
    for (const auto &phi : block.phi_instructions_) {
      defs.insert(phi.result_id);
      for (const auto &cond : phi.conditions) {
        if (!cond.is_const) {
          block_uses_[cond.from_block_id].insert(cond.var_id);
        }
      }
    }
  }

  // Initialize live_in/live_out to empty.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    live_in_[block_id] = {};
    live_out_[block_id] = {};
  }

  // Worklist algorithm: iterate to fixed point.
  std::queue<int> worklist;
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    worklist.push(block_id);
  }

  while (!worklist.empty()) {
    int block_id = worklist.front();
    worklist.pop();

    // live_out[B] = union of live_in of all successors
    std::set<int> new_live_out;
    if (successors_.count(block_id)) {
      for (int succ : successors_.at(block_id)) {
        if (live_in_.count(succ)) {
          new_live_out.insert(live_in_[succ].begin(), live_in_[succ].end());
        }
      }
    }

    // live_in[B] = use[B] ∪ (live_out[B] - def[B])
    std::set<int> new_live_in = block_uses_[block_id];
    for (int v : new_live_out) {
      if (!block_defs_[block_id].count(v)) {
        new_live_in.insert(v);
      }
    }

    if (new_live_in != live_in_[block_id]) {
      live_in_[block_id] = new_live_in;
      live_out_[block_id] = new_live_out;
      // Add predecessors to worklist.
      if (predecessors_.count(block_id)) {
        for (int pred : predecessors_.at(block_id)) {
          worklist.push(pred);
        }
      }
    }
  }
}

// ============================================================================
// Step 3: Build the interference graph
// ============================================================================

void RegisterAllocator::BuildInterferenceGraph() {
  // Initialize: each allocatable var gets an empty adjacency set.
  for (int v : allocatable_vars_) {
    interference_[v] = {};
    move_edges_[v] = {};
  }

  // Within each block: walk instructions backwards.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    // Start with variables live-out of this block.
    std::set<int> currently_live;
    if (live_out_.count(block_id)) {
      for (int v : live_out_.at(block_id)) {
        if (allocatable_vars_.count(v)) {
          currently_live.insert(v);
        }
      }
    }
    // Phi-induced moves at the end of this block use their sources. Those
    // sources are live at end-of-block (after regular instructions, before
    // the moves), so they must interfere with any variable defined in this
    // block. Without this, a phi source defined-in-block (e.g. an SSA phi
    // result) and a sibling phi source computed by a regular instruction
    // can be coalesced into the same register, corrupting one of the moves.
    if (riscv_func_.blocks_.count(block_id)) {
      for (const auto &mv : riscv_func_.blocks_.at(block_id).move_instructions_) {
        if (!mv.src_is_value_ && allocatable_vars_.count(mv.src_)) {
          currently_live.insert(mv.src_);
        }
      }
    }
    // The conditional-branch condition is loaded AFTER phi moves run (the
    // "deferred load" pattern in code_generator.cpp). So the condition
    // variable is live across the phi moves: any phi-move destination must
    // interfere with the condition, or the move clobbers it. Treat the
    // condition as live at end-of-block here so phi-move dests (and anything
    // else defined in the block) get the right interference.
    if (!block.instructions_.empty()) {
      const auto &last = block.instructions_.back();
      if (last.instruction_type_ == conditional_br_ &&
          last.condition_id_ > 0 &&
          allocatable_vars_.count(last.condition_id_)) {
        currently_live.insert(last.condition_id_);
      }
    }
    // Phi-move destinations are written at end-of-block. They must interfere
    // with everything alive at that point (sources of other moves, the
    // conditional condition still pending the deferred load, and anything
    // else passing through in live_out). Account for that here — the
    // per-instruction backward walk below only handles defs from regular
    // instructions, never the phi-move dests themselves.
    // Exception: a move's destination does NOT interfere with its own source
    // (coalescing src and dest is fine: same register means the move is a
    // no-op, which preserves semantics for a single move).
    if (riscv_func_.blocks_.count(block_id)) {
      for (const auto &mv : riscv_func_.blocks_.at(block_id).move_instructions_) {
        int dest = mv.dest_;
        if (!allocatable_vars_.count(dest)) continue;
        int own_src = (!mv.src_is_value_) ? mv.src_ : -1;
        for (int live : currently_live) {
          if (live != dest && live != own_src) {
            interference_[dest].insert(live);
            interference_[live].insert(dest);
          }
        }
      }
    }

    // Walk instructions from bottom to top.
    for (auto inst_it = block.instructions_.rbegin();
         inst_it != block.instructions_.rend(); ++inst_it) {
      const auto &inst = *inst_it;

      // Collect defs and uses for this instruction.
      std::set<int> inst_defs, inst_uses;
      int result_id = inst.result_id_;

      // --- Collect uses ---
      auto add_use = [&](int id) {
        if (id > 0 && allocatable_vars_.count(id)) inst_uses.insert(id);
      };
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
          add_use(inst.operand_1_id_); add_use(inst.operand_2_id_); break;
        case var_const_binary_operation_: add_use(inst.operand_1_id_); break;
        case const_var_binary_operation_: add_use(inst.operand_2_id_); break;
        case conditional_br_: add_use(inst.condition_id_); break;
        case variable_ret_: add_use(inst.result_id_); break;
        case load_: case ptr_load_: add_use(inst.pointer_); break;
        case variable_store_:
          add_use(inst.result_id_); add_use(inst.pointer_); break;
        case value_store_:
          add_use(inst.pointer_); break;
        case ptr_store_:
          add_use(inst.result_id_); add_use(inst.pointer_); break;
        case get_element_ptr_by_value_:
          add_use(inst.pointer_); break;
        case get_element_ptr_by_variable_:
          add_use(inst.pointer_); add_use(inst.index_); break;
        case two_var_icmp_:
          add_use(inst.operand_1_id_); add_use(inst.operand_2_id_); break;
        case var_const_icmp_: add_use(inst.operand_1_id_); break;
        case const_var_icmp_: add_use(inst.operand_2_id_); break;
        case non_void_call_: case void_call_: case builtin_call_:
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) add_use(arg.value_);
          }
          break;
        case value_select_ii_:
          add_use(inst.operand_1_id_); add_use(inst.operand_2_id_); break;
        case value_select_iv_: add_use(inst.operand_1_id_); break;
        case value_select_vi_: add_use(inst.operand_2_id_); break;
        case variable_select_ii_: case variable_select_vv_:
          add_use(inst.condition_id_);
          add_use(inst.operand_1_id_); add_use(inst.operand_2_id_); break;
        case variable_select_iv_:
          add_use(inst.condition_id_); add_use(inst.operand_1_id_); break;
        case variable_select_vi_:
          add_use(inst.condition_id_); add_use(inst.operand_2_id_); break;
        case builtin_memset_: add_use(inst.pointer_); break;
        case builtin_memcpy_: add_use(inst.destination_); add_use(inst.pointer_); break;
        default: break;
      }

      // --- Collect defs ---
      switch (inst.instruction_type_) {
        case two_var_binary_operation_: case var_const_binary_operation_:
        case const_var_binary_operation_: case non_void_call_:
        case two_var_icmp_: case var_const_icmp_: case const_var_icmp_:
        case load_: case ptr_load_:
        case get_element_ptr_by_value_: case get_element_ptr_by_variable_:
        case value_select_ii_: case value_select_iv_: case value_select_vi_:
        case value_select_vv_:
        case variable_select_ii_: case variable_select_iv_:
        case variable_select_vi_: case variable_select_vv_:
          if (result_id > 0 && allocatable_vars_.count(result_id)) {
            inst_defs.insert(result_id);
          }
          break;
        case builtin_call_:
          if (inst.function_name_ == 2 && result_id > 0 &&
              allocatable_vars_.count(result_id)) {
            inst_defs.insert(result_id);
          }
          break;
        case alloca_:
          // alloca stays on stack, never in register.
          break;
        default: break;
      }

      // Add interference: def interferes with everything currently live
      // (except itself if it's also a use — a variable can be both def and use
      // in the same instruction like %1 = add %1, %2).
      for (int def : inst_defs) {
        for (int live : currently_live) {
          if (def != live) {
            interference_[def].insert(live);
            interference_[live].insert(def);
          }
        }
      }

      // Update currently_live: remove defs, add uses.
      for (int def : inst_defs) {
        currently_live.erase(def);
      }
      for (int use : inst_uses) {
        if (allocatable_vars_.count(use)) {
          currently_live.insert(use);
        }
      }
    }

    // At the block start: handle phi definitions.
    // For each phi, the result is defined here. It interferes with everything
    // in currently_live (which should approximate live_in), EXCEPT its own
    // source operands (to allow coalescing).
    //
    // First, collect all phi result ids in this block so we can make them
    // mutually interfere — two phi results defined at the same block start
    // must never share a register, otherwise the move instructions that
    // resolve them can overwrite each other (the second move clobbers the
    // first one's destination).
    std::set<int> block_phi_results;
    for (const auto &phi : block.phi_instructions_) {
      if (allocatable_vars_.count(phi.result_id)) {
        block_phi_results.insert(phi.result_id);
      }
    }
    for (int r1 : block_phi_results) {
      for (int r2 : block_phi_results) {
        if (r1 != r2) {
          interference_[r1].insert(r2);
          interference_[r2].insert(r1);
        }
      }
    }

    for (const auto &phi : block.phi_instructions_) {
      int result_id = phi.result_id;
      if (!allocatable_vars_.count(result_id)) continue;

      // Collect source var_ids for this phi.
      std::set<int> sources;
      for (const auto &cond : phi.conditions) {
        if (!cond.is_const && cond.var_id > 0 && allocatable_vars_.count(cond.var_id)) {
          sources.insert(cond.var_id);
        }
      }

      // Add interference with everything currently live, except sources.
      for (int live : currently_live) {
        if (live != result_id && !sources.count(live)) {
          interference_[result_id].insert(live);
          interference_[live].insert(result_id);
        }
      }

      // The phi result is "defined" at block start, so it's now live going
      // backwards into predecessors. But for the backward analysis of THIS
      // block, we've reached the start, so we stop.
    }
  }

  // Add move edges from MoveInstructions (phi-to-move conversion).
  for (const auto &[block_id, r_block] : riscv_func_.blocks_) {
    for (const auto &mv : r_block.move_instructions_) {
      if (mv.src_is_value_) continue; // constant moves don't create move edges
      int src = mv.src_;
      int dest = mv.dest_;
      if (allocatable_vars_.count(src) && allocatable_vars_.count(dest)) {
        move_edges_[src].insert(dest);
        move_edges_[dest].insert(src);
        move_related_.insert(src);
        move_related_.insert(dest);
        // Force interference between move source and destination so the
        // register allocator never puts them in the same physical register.
        // Without this, a phi source and its result can land in the same reg
        // (their live ranges don't overlap in the standard sense), turning
        // the move into a no-op and leaving the loop variable unchanged.
        interference_[src].insert(dest);
        interference_[dest].insert(src);
      }
    }
    // Add cross-interference between moves in the same block:
    // the destination of one move must not share a register with the source
    // of another move, because all phi moves at a block boundary execute
    // simultaneously (parallel copy). Without this, the first move can
    // overwrite a register that the second move still needs to read from.
    // Constant moves (src_is_value_) participate as destinations only; their
    // destination must also interfere with other moves' sources to avoid the
    // li that materializes the constant clobbering a source still to be read.
    for (size_t i = 0; i < r_block.move_instructions_.size(); ++i) {
      const auto &mv_i = r_block.move_instructions_[i];
      for (size_t j = i + 1; j < r_block.move_instructions_.size(); ++j) {
        const auto &mv_j = r_block.move_instructions_[j];
        int di = mv_i.dest_;
        int dj = mv_j.dest_;
        // dest of i interferes with src of j (if j is a var move).
        if (!mv_j.src_is_value_) {
          int sj = mv_j.src_;
          if (allocatable_vars_.count(di) && allocatable_vars_.count(sj) && di != sj) {
            interference_[di].insert(sj);
            interference_[sj].insert(di);
          }
        }
        // dest of j interferes with src of i (if i is a var move).
        if (!mv_i.src_is_value_) {
          int si = mv_i.src_;
          if (allocatable_vars_.count(dj) && allocatable_vars_.count(si) && dj != si) {
            interference_[dj].insert(si);
            interference_[si].insert(dj);
          }
        }
        // Also make all destinations mutually interfere (two phi results
        // defined at the same block start must never share a register).
        if (allocatable_vars_.count(di) && allocatable_vars_.count(dj) && di != dj) {
          interference_[di].insert(dj);
          interference_[dj].insert(di);
        }
      }
    }
  }
}

// ============================================================================
// Step 4: Chaitin-Briggs graph coloring
// ============================================================================

int RegisterAllocator::GetDegree(int node) const {
  auto it = current_degree_.find(node);
  if (it == current_degree_.end()) return 0;
  return it->second;
}

int RegisterAllocator::GetSignificantDegree(int node, int k) const {
  if (!interference_.count(node)) return 0;
  int count = 0;
  for (int neighbor : interference_.at(node)) {
    if (worklist_.count(neighbor) && GetDegree(neighbor) >= k) {
      ++count;
    }
  }
  return count;
}

void RegisterAllocator::ColorGraph() {
  int K = static_cast<int>(allocatable_regs_.size());

  // Initialize worklist with all allocatable variables.
  for (int v : allocatable_vars_) {
    worklist_.insert(v);
  }
  select_stack_.clear();
  is_spilled_.clear();

  // Initialize cached degrees: number of interference neighbors that are
  // currently in worklist_. Updated incrementally as nodes leave worklist_.
  current_degree_.clear();
  for (int v : worklist_) {
    int deg = 0;
    auto it = interference_.find(v);
    if (it != interference_.end()) {
      for (int neighbor : it->second) {
        if (worklist_.count(neighbor)) ++deg;
      }
    }
    current_degree_[v] = deg;
  }

  while (!worklist_.empty()) {
    // ---- SIMPLIFY ----
    Simplify();
    if (worklist_.empty()) break;

    // ---- COALESCE ----
    if (Coalesce()) continue;

    // ---- FREEZE ----
    Freeze();
    // After freeze, some move edges become interference edges. Since we
    // only freeze when deg < K AND move-related, the node should become
    // simplifiable. Try simplify again.
    Simplify();
    if (worklist_.empty()) break;

    // ---- SELECT SPILL ----
    // If we're still stuck, we need to spill something.
    // But first, check if we made any progress.
    // If no progress was made in the last iteration, force a spill.
    SelectSpill();
  }

  // ---- ASSIGN COLORS ----
  AssignColors();
}

void RegisterAllocator::Simplify() {
  int K = static_cast<int>(allocatable_regs_.size());
  bool changed = true;
  while (changed) {
    changed = false;
    std::vector<int> to_remove;
    for (int node : worklist_) {
      if (GetDegree(node) < K) {
        to_remove.push_back(node);
      }
    }
    for (int node : to_remove) {
      select_stack_.push_back(node);
      is_spilled_[node] = false;
      worklist_.erase(node);
      // Decrement cached degree of each neighbor that is still in worklist_.
      auto it = interference_.find(node);
      if (it != interference_.end()) {
        for (int neighbor : it->second) {
          if (worklist_.count(neighbor)) {
            auto dit = current_degree_.find(neighbor);
            if (dit != current_degree_.end() && dit->second > 0) {
              --dit->second;
            }
          }
        }
      }
      current_degree_.erase(node);
      // Also remove this node from move_related_ (it's no longer in worklist).
      move_related_.erase(node);
      changed = true;
    }
  }
}

bool RegisterAllocator::Coalesce() {
  // Disabled for debugging — coalescing may introduce subtle bugs.
  return false;
}

bool RegisterAllocator::BriggsTest(int u, int v, int k) const {
  // Coalesce is safe if the combined node has < k neighbors of significant degree.
  std::set<int> combined_neighbors;
  if (interference_.count(u)) {
    combined_neighbors.insert(interference_.at(u).begin(),
                              interference_.at(u).end());
  }
  if (interference_.count(v)) {
    combined_neighbors.insert(interference_.at(v).begin(),
                              interference_.at(v).end());
  }
  // Remove u and v themselves.
  combined_neighbors.erase(u);
  combined_neighbors.erase(v);

  int significant = 0;
  for (int n : combined_neighbors) {
    if (worklist_.count(n) && GetDegree(n) >= k) {
      ++significant;
    }
  }
  return significant < k;
}

bool RegisterAllocator::GeorgeTest(int u, int v, int k) const {
  // Coalesce u into v if every neighbor t of u either already interferes
  // with v, or has degree < k.
  if (!interference_.count(u)) return true;
  for (int t : interference_.at(u)) {
    if (t == v) continue;
    if (!worklist_.count(t)) continue;
    // Check if t already interferes with v.
    if (interference_.count(v) && interference_.at(v).count(t)) {
      continue; // OK
    }
    // Check if t has degree < k (simplifiable).
    if (GetDegree(t) < k) {
      continue; // OK
    }
    return false; // t would be blocked
  }
  return true;
}

void RegisterAllocator::CoalesceNodes(int u, int v) {
  // Merge v into u. After coalescing, u represents the combined variable.
  // v is removed from worklist; all edges of v transfer to u.

  // Transfer interference edges from v to u.
  if (interference_.count(v)) {
    for (int neighbor : interference_.at(v)) {
      if (neighbor != u) {
        interference_[u].insert(neighbor);
        interference_[neighbor].insert(u);
        interference_[neighbor].erase(v);
      }
    }
  }

  // Transfer move edges from v to u.
  if (move_edges_.count(v)) {
    for (int neighbor : move_edges_.at(v)) {
      if (neighbor != u) {
        move_edges_[u].insert(neighbor);
        move_edges_[neighbor].insert(u);
        move_edges_[neighbor].erase(v);
      }
    }
  }

  // Remove v from move_edges_ of u.
  move_edges_[u].erase(v);

  // Remove v from the graph.
  interference_.erase(v);
  move_edges_.erase(v);
  worklist_.erase(v);
  move_related_.erase(v);

  // If u no longer has move edges, remove from move_related_.
  if (move_edges_[u].empty()) {
    move_related_.erase(u);
  }

  // Record coalescing: v maps to u (v's register = u's register).
  coalesced_rep_[v] = u;
}

void RegisterAllocator::Freeze() {
  int K = static_cast<int>(allocatable_regs_.size());

  // Find a move-related node with degree < K and freeze its move edges.
  for (int node : move_related_) {
    if (!worklist_.count(node)) continue;
    if (GetDegree(node) < K) {
      // Freeze: convert all move edges of this node into interference edges.
      if (move_edges_.count(node)) {
        auto move_neighbors = move_edges_[node]; // copy (we'll modify move_edges_)
        for (int neighbor : move_neighbors) {
          // Remove the move edge.
          move_edges_[node].erase(neighbor);
          if (move_edges_.count(neighbor)) {
            move_edges_[neighbor].erase(node);
            if (move_edges_[neighbor].empty()) {
              move_related_.erase(neighbor);
            }
          }
        }
      }
      move_edges_.erase(node);
      move_related_.erase(node);
      return; // Freeze one node per iteration.
    }
  }
}

void RegisterAllocator::SelectSpill() {
  // Pick a spill candidate from the worklist.
  int spill_node = SelectSpillCandidate();
  if (spill_node < 0) {
    // Fallback: pick any node.
    spill_node = *worklist_.begin();
  }
  select_stack_.push_back(spill_node);
  is_spilled_[spill_node] = true;
  worklist_.erase(spill_node);
  // Decrement cached degree of each neighbor that is still in worklist_.
  auto it = interference_.find(spill_node);
  if (it != interference_.end()) {
    for (int neighbor : it->second) {
      if (worklist_.count(neighbor)) {
        auto dit = current_degree_.find(neighbor);
        if (dit != current_degree_.end() && dit->second > 0) {
          --dit->second;
        }
      }
    }
  }
  current_degree_.erase(spill_node);
  move_related_.erase(spill_node);
}

int RegisterAllocator::SelectSpillCandidate() const {
  // Heuristic: pick the node with the highest degree.
  // Higher degree means removing it frees up more neighbors.
  int best_node = -1;
  int best_degree = -1;
  for (int node : worklist_) {
    int deg = GetDegree(node);
    if (deg > best_degree) {
      best_degree = deg;
      best_node = node;
    }
  }
  return best_node;
}

void RegisterAllocator::AssignColors() {
  int K = static_cast<int>(allocatable_regs_.size());

  // Track which physical registers are already assigned to each node's neighbors.
  // We use a temporary map for colors assigned during this phase.
  std::map<int, int> node_color; // node -> physical register (-1 = spill)

  while (!select_stack_.empty()) {
    int node = select_stack_.back();
    select_stack_.pop_back();

    // Check if this node was coalesced into another.
    if (coalesced_rep_.count(node)) {
      int rep = coalesced_rep_[node];
      if (node_color.count(rep)) {
        node_color[node] = node_color[rep];
      }
      continue;
    }

    // Find colors used by neighbors.
    std::set<int> used_colors;
    if (interference_.count(node)) {
      for (int neighbor : interference_.at(node)) {
        if (node_color.count(neighbor) && node_color[neighbor] >= 0) {
          used_colors.insert(node_color[neighbor]);
        }
        // Also check if neighbor was coalesced and its rep has a color.
        if (coalesced_rep_.count(neighbor)) {
          int rep = coalesced_rep_[neighbor];
          if (node_color.count(rep) && node_color[rep] >= 0) {
            used_colors.insert(node_color[rep]);
          }
        }
      }
    }

    // Handle spilled nodes: try to assign a color anyway (optimistic coloring).
    // If no color available, it stays spilled.
    int assigned_color = -1;
    for (int color_idx = 0; color_idx < K; ++color_idx) {
      int reg = allocatable_regs_[color_idx];
      if (!used_colors.count(reg)) {
        assigned_color = reg;
        break;
      }
    }

    if (is_spilled_[node] && assigned_color < 0) {
      // Truly spilled: no color available.
      node_color[node] = -1;
    } else {
      node_color[node] = assigned_color;
    }
  }

  // Persist the results.
  for (const auto &[node, color] : node_color) {
    assignment_[node] = color;
  }

  // Debug: verify that no interfering nodes share the same (non-negative) color.
  int bad = 0;
  for (const auto &[u, neighbors] : interference_) {
    if (!node_color.count(u) || node_color.at(u) < 0) continue;
    int cu = node_color.at(u);
    for (int v : neighbors) {
      if (!node_color.count(v) || node_color.at(v) < 0) continue;
      if (cu == node_color.at(v)) {
        // if (bad < 5) {
        //   std::cerr << "[RegAlloc CONFLICT] nodes " << u << " and " << v
        //             << " both assigned reg " << cu << std::endl;
        // }
        ++bad;
      }
    }
  }
  // if (bad > 0) {
  //   std::cerr << "[RegAlloc CONFLICT] total conflicting pairs: " << bad << std::endl;
  // }
}

// ============================================================================
// Step 5: Update location map
// ============================================================================

void RegisterAllocator::UpdateLocationMap() {
  int promoted = 0;
  for (int var : allocatable_vars_) {
    if (stack_bound_vars_.count(var)) continue;

    if (assignment_.count(var)) {
      int reg = assignment_[var];
      if (reg >= 0) {
        riscv_func_.location_[var] = {true, reg};
        ++promoted;
        // std::cerr << "[RegAlloc] var " << var << " -> reg " << reg << std::endl;
      } else if (reg == -1) {
        if (riscv_func_.location_.count(var)) {
          riscv_func_.location_[var].first = false;
        } else {
          int size = var_size_.count(var) ? var_size_[var] : 4;
          if (size == 8 && riscv_func_.stack_space_ % 8 != 0) {
            riscv_func_.stack_space_ = (riscv_func_.stack_space_ + 7) / 8 * 8;
          }
          riscv_func_.location_[var] = {false, riscv_func_.stack_space_};
          riscv_func_.stack_space_ += size;
        }
      }
    }
  }
  // if (promoted > 0) {
  //   std::cerr << "[RegAlloc] promoted " << promoted << " vars to registers" << std::endl;
  // }

  // Resolve coalesced variables.
  for (const auto &[var, rep] : coalesced_rep_) {
    if (stack_bound_vars_.count(var)) continue;
    if (assignment_.count(rep) && assignment_[rep] >= 0) {
      riscv_func_.location_[var] = {true, assignment_[rep]};
    } else {
      if (riscv_func_.location_.count(var)) {
        riscv_func_.location_[var].first = false;
      }
    }
  }
}

#include "register_allocator.h"
#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <queue>

namespace {

bool IsIcmpInstruction(const IRInstructionType type) {
  return type == two_var_icmp_ || type == var_const_icmp_ ||
      type == const_var_icmp_;
}

void AddUse(std::map<int, int> &use_count, const int id) {
  if (id > 0) {
    ++use_count[id];
  }
}

std::map<int, int> CountVariableUses(const IRFunctionNode &function) {
  std::map<int, int> use_count;
  for (const auto &[block_id, block] : function.blocks_) {
    for (const auto &phi : block.phi_instructions_) {
      for (const auto &condition : phi.conditions) {
        if (!condition.is_const) {
          AddUse(use_count, condition.var_id);
        }
      }
    }
    for (const auto &inst : block.instructions_) {
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_:
          AddUse(use_count, inst.operand_1_id_);
          AddUse(use_count, inst.operand_2_id_);
          break;
        case var_const_binary_operation_:
        case var_const_icmp_:
          AddUse(use_count, inst.operand_1_id_);
          break;
        case const_var_binary_operation_:
        case const_var_icmp_:
          AddUse(use_count, inst.operand_2_id_);
          break;
        case conditional_br_:
          AddUse(use_count, inst.condition_id_);
          break;
        case variable_ret_:
          AddUse(use_count, inst.result_id_);
          break;
        case load_:
        case ptr_load_:
        case value_store_:
        case builtin_memset_:
          AddUse(use_count, inst.pointer_);
          break;
        case variable_store_:
        case ptr_store_:
          AddUse(use_count, inst.result_id_);
          AddUse(use_count, inst.pointer_);
          break;
        case get_element_ptr_by_value_:
          AddUse(use_count, inst.pointer_);
          break;
        case get_element_ptr_by_variable_:
          AddUse(use_count, inst.pointer_);
          AddUse(use_count, inst.index_);
          break;
        case non_void_call_:
        case void_call_:
        case builtin_call_:
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              AddUse(use_count, arg.value_);
            }
          }
          break;
        case value_select_ii_:
          AddUse(use_count, inst.operand_1_id_);
          AddUse(use_count, inst.operand_2_id_);
          break;
        case value_select_iv_:
          AddUse(use_count, inst.operand_1_id_);
          break;
        case value_select_vi_:
          AddUse(use_count, inst.operand_2_id_);
          break;
        case variable_select_ii_:
          AddUse(use_count, inst.condition_id_);
          AddUse(use_count, inst.operand_1_id_);
          AddUse(use_count, inst.operand_2_id_);
          break;
        case variable_select_iv_:
          AddUse(use_count, inst.condition_id_);
          AddUse(use_count, inst.operand_1_id_);
          break;
        case variable_select_vi_:
          AddUse(use_count, inst.condition_id_);
          AddUse(use_count, inst.operand_2_id_);
          break;
        case variable_select_vv_:
          AddUse(use_count, inst.condition_id_);
          break;
        case builtin_memcpy_:
          AddUse(use_count, inst.destination_);
          AddUse(use_count, inst.pointer_);
          break;
        default:
          break;
      }
    }
  }
  return use_count;
}

std::map<int, IRInstruction> FindDirectBranchIcmps(const IRFunctionNode &function) {
  std::map<int, IRInstruction> result;
  const auto use_count = CountVariableUses(function);
  for (const auto &[block_id, block] : function.blocks_) {
    const auto &instructions = block.instructions_;
    if (instructions.size() < 2) {
      continue;
    }
    const auto &branch = instructions.back();
    const auto &cmp = instructions[instructions.size() - 2];
    if (branch.instruction_type_ != conditional_br_ ||
        !IsIcmpInstruction(cmp.instruction_type_) ||
        cmp.result_id_ != branch.condition_id_) {
      continue;
    }
    const auto use_it = use_count.find(cmp.result_id_);
    if (use_it != use_count.end() && use_it->second == 1) {
      result.emplace(block_id, cmp);
    }
  }
  return result;
}

bool RegAllocStatsEnabled() {
  const char *flag = std::getenv("RX_REGALLOC_STATS");
  return flag != nullptr && flag[0] != '\0' && flag[0] != '0';
}

long long MonotonicMillis() {
  timespec ts{};
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return static_cast<long long>(ts.tv_sec) * 1000LL + ts.tv_nsec / 1000000LL;
}

} // namespace

RegisterAllocator::RegisterAllocator(const IRFunctionNode &ir_func,
                                     RISCVFunctionNode &riscv_func,
                                     bool is_leaf)
    : ir_func_(ir_func), riscv_func_(riscv_func), is_leaf_(is_leaf) {

  // Build the pool of allocatable physical registers.
  if (is_leaf) {
    // Caller-saved first: a0-a7 (10-17), t3-t5 (28-30)
    for (int r = 10; r <= 17; ++r) allocatable_regs_.push_back(r);
    for (int r = 28; r <= 30; ++r) allocatable_regs_.push_back(r);
    // Then callee-saved: s0-s1 (8-9), s2-s11 (18-27)
    allocatable_regs_.push_back(8);
    allocatable_regs_.push_back(9);
    for (int r = 18; r <= 27; ++r) allocatable_regs_.push_back(r);
  } else {
    // Non-leaf functions pay once for callee-saved registers in the
    // prologue/epilogue, while caller-saved registers may need traffic around
    // every call. Prefer s-registers first, then use caller-saved registers for
    // remaining short-lived pressure.
    allocatable_regs_.push_back(8);
    allocatable_regs_.push_back(9);
    for (int r = 18; r <= 27; ++r) allocatable_regs_.push_back(r);
    for (int r = 10; r <= 17; ++r) allocatable_regs_.push_back(r);
    for (int r = 28; r <= 30; ++r) allocatable_regs_.push_back(r);
  }

  ComputeMaxVarId();
  InitializeVectors();
}

void RegisterAllocator::Run() {
  ClassifyVariables();
  BuildCFG();
  const int original_candidate_count = static_cast<int>(allocatable_nodes_.size());

  int instruction_count = 0;
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    instruction_count += static_cast<int>(block.instructions_.size());
    instruction_count += static_cast<int>(block.phi_instructions_.size());
  }
  int phi_move_count = 0;
  for (const auto &[block_id, block] : riscv_func_.blocks_) {
    phi_move_count += static_cast<int>(block.move_instructions_.size());
  }

  ComputeSpillCosts();

  const bool dump_stats = RegAllocStatsEnabled();
  const long long liveness_start = MonotonicMillis();
  ComputeLiveness();
  const long long liveness_end = MonotonicMillis();
  const long long interference_start = MonotonicMillis();
  BuildInterferenceGraph();
  const long long interference_end = MonotonicMillis();
  long long interference_edge_count = 0;
  if (dump_stats) {
    for (int v : allocatable_nodes_) {
      interference_edge_count += static_cast<long long>(interference_[v].size());
    }
    interference_edge_count /= 2;
  }
  const long long coloring_start = MonotonicMillis();
  ColorGraph();
  const long long coloring_end = MonotonicMillis();

  if (dump_stats) {
    std::cerr << "[regalloc] candidates=" << original_candidate_count
              << " blocks=" << ir_func_.blocks_.size()
              << " instructions=" << instruction_count
              << " phi_moves=" << phi_move_count
              << " live_ms=" << (liveness_end - liveness_start)
              << " interference_ms=" << (interference_end - interference_start)
              << " coloring_ms=" << (coloring_end - coloring_start)
              << " edges=" << interference_edge_count
              << '\n';
  }

  UpdateLocationMap();
}

// ============================================================================
// Bitset infrastructure helpers
// ============================================================================

void RegisterAllocator::ComputeMaxVarId() {
  max_var_id_ = ir_func_.var_id_ - 1;

  // Scan phi results and move instructions which may have been added
  // by mem2reg / PhiToMove after the initial var_id_ accounting.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    for (const auto &phi : block.phi_instructions_) {
      if (phi.result_id > max_var_id_) max_var_id_ = phi.result_id;
      for (const auto &cond : phi.conditions) {
        if (!cond.is_const && cond.var_id > max_var_id_) max_var_id_ = cond.var_id;
      }
    }
  }
  for (const auto &[block_id, r_block] : riscv_func_.blocks_) {
    for (const auto &mv : r_block.move_instructions_) {
      if (mv.dest_ > max_var_id_) max_var_id_ = mv.dest_;
      if (!mv.src_is_value_ && mv.src_ > max_var_id_) max_var_id_ = mv.src_;
    }
  }

  // Guard: bitset_words_ must be at least 1, even for empty functions.
  if (max_var_id_ < 0) max_var_id_ = 0;
  bitset_words_ = (max_var_id_ + 64) / 64;
}

void RegisterAllocator::InitializeVectors() {
  int n = max_var_id_ + 1;

  // Classification
  is_allocatable_ = MakeBitSet();
  is_stack_bound_ = MakeBitSet();
  var_size_.assign(n, 0);
  spill_cost_.assign(n, 1);
  allocatable_nodes_.clear();

  // Interference graph
  interference_.assign(n, {});
  interference_bits_.assign(n, MakeBitSet());
  move_edges_.assign(n, {});

  // Coloring state
  in_worklist_ = MakeBitSet();
  is_spilled_ = MakeBitSet();
  in_move_related_ = MakeBitSet();
  current_degree_.assign(n, -1);
  select_stack_.clear();
  coalesced_rep_.assign(n, -1);
  assignment_.assign(n, -2);

  // Scratch bitset
  scratch_bs_ = MakeBitSet();

  // Liveness — one bitset per block
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    live_in_[block_id] = MakeBitSet();
    live_out_[block_id] = MakeBitSet();
    block_defs_[block_id] = MakeBitSet();
    block_uses_[block_id] = MakeBitSet();
  }
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

void RegisterAllocator::RebuildAllocatableNodes() {
  allocatable_nodes_.clear();
  for (int v = 0; v <= max_var_id_; ++v) {
    if (BitTest(is_allocatable_, v)) {
      allocatable_nodes_.push_back(v);
    }
  }
}

void RegisterAllocator::ClassifyVariables() {
  const auto direct_branch_icmps = FindDirectBranchIcmps(ir_func_);
  // Alloca'd variables MUST stay on the stack.
  for (const auto &alloca : ir_func_.alloca_instructions_) {
    BitSet(is_stack_bound_, alloca.result_id_);
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

      if (result_id > 0 && !BitTest(is_stack_bound_, result_id)) {
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
              BitSet(is_allocatable_, result_id);
              var_size_[result_id] = (inst.result_type_->basic_type == pointer_type) ? 8 : 4;
            } else {
              BitSet(is_stack_bound_, result_id);
            }
            break;
          case load_:
            if (IsScalarType(inst.result_type_)) {
              BitSet(is_allocatable_, result_id);
              var_size_[result_id] = (inst.result_type_->basic_type == pointer_type) ? 8 : 4;
            } else {
              BitSet(is_stack_bound_, result_id);
            }
            break;
          case ptr_load_:
            // Always loads a pointer (8 bytes).
            BitSet(is_allocatable_, result_id);
            var_size_[result_id] = 8;
            break;
          case get_element_ptr_by_value_:
          case get_element_ptr_by_variable_:
            // GEP produces a pointer (8 bytes). result_type_ here is the
            // *aggregate* type being indexed, not the pointer result type.
            BitSet(is_allocatable_, result_id);
            var_size_[result_id] = 8;
            break;
          default:
            BitSet(is_stack_bound_, result_id);
            break;
        }
      }
    }
    // Handle phi instructions.
    for (const auto &phi : block.phi_instructions_) {
      int result_id = phi.result_id;
      if (!BitTest(is_stack_bound_, result_id)) {
        if (IsScalarType(phi.type)) {
          BitSet(is_allocatable_, result_id);
          var_size_[result_id] = (phi.type->basic_type == pointer_type) ? 8 : 4;
        } else {
          BitSet(is_stack_bound_, result_id);
        }
      }
    }
  }
  for (const auto &[block_id, cmp] : direct_branch_icmps) {
    BitClear(is_allocatable_, cmp.result_id_);
    BitSet(is_stack_bound_, cmp.result_id_);
    if (cmp.result_id_ >= 0 && cmp.result_id_ < var_size_.size()) {
      var_size_[cmp.result_id_] = 0;
    }
  }
  RebuildAllocatableNodes();
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

void RegisterAllocator::ComputeSpillCosts() {
  std::fill(spill_cost_.begin(), spill_cost_.end(), 1);
  auto add_use_score = [&](int id, int amount = 1) {
    if (id > 0 && BitTest(is_allocatable_, id)) {
      spill_cost_[id] += amount;
    }
  };
  auto add_def_score = [&](int id, int amount = 1) {
    if (id > 0 && BitTest(is_allocatable_, id)) {
      spill_cost_[id] += amount;
    }
  };

  for (const auto &[block_id, block] : ir_func_.blocks_) {
    for (const auto &inst : block.instructions_) {
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
          add_use_score(inst.operand_1_id_, 3);
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case var_const_binary_operation_:
          add_use_score(inst.operand_1_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case const_var_binary_operation_:
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case conditional_br_:
          add_use_score(inst.condition_id_, 4);
          break;
        case variable_ret_:
          add_use_score(inst.result_id_, 4);
          break;
        case load_:
        case ptr_load_:
          add_use_score(inst.pointer_, 5);
          add_def_score(inst.result_id_, 2);
          break;
        case variable_store_:
        case ptr_store_:
          add_use_score(inst.result_id_, 4);
          add_use_score(inst.pointer_, 5);
          break;
        case value_store_:
          add_use_score(inst.pointer_, 5);
          break;
        case get_element_ptr_by_value_:
          add_use_score(inst.pointer_, 8);
          add_def_score(inst.result_id_, 2);
          break;
        case get_element_ptr_by_variable_:
          add_use_score(inst.pointer_, 8);
          add_use_score(inst.index_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case two_var_icmp_:
          add_use_score(inst.operand_1_id_, 3);
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case var_const_icmp_:
          add_use_score(inst.operand_1_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case const_var_icmp_:
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case non_void_call_:
        case void_call_:
        case builtin_call_:
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) add_use_score(arg.value_, 4);
          }
          if (inst.instruction_type_ == non_void_call_ ||
              (inst.instruction_type_ == builtin_call_ && inst.function_name_ == 2)) {
            add_def_score(inst.result_id_, 2);
          }
          break;
        case value_select_ii_:
          add_use_score(inst.operand_1_id_, 3);
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case value_select_iv_:
          add_use_score(inst.operand_1_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case value_select_vi_:
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case value_select_vv_:
          add_def_score(inst.result_id_, 2);
          break;
        case variable_select_ii_:
          add_use_score(inst.condition_id_, 4);
          add_use_score(inst.operand_1_id_, 3);
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case variable_select_vv_:
          add_use_score(inst.condition_id_, 4);
          add_def_score(inst.result_id_, 2);
          break;
        case variable_select_iv_:
          add_use_score(inst.condition_id_, 4);
          add_use_score(inst.operand_1_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case variable_select_vi_:
          add_use_score(inst.condition_id_, 4);
          add_use_score(inst.operand_2_id_, 3);
          add_def_score(inst.result_id_, 2);
          break;
        case builtin_memset_:
          add_use_score(inst.pointer_, 6);
          break;
        case builtin_memcpy_:
          add_use_score(inst.destination_, 6);
          add_use_score(inst.pointer_, 6);
          break;
        default:
          break;
      }
    }
    for (const auto &phi : block.phi_instructions_) {
      const int phi_weight = (phi.type && phi.type->basic_type == pointer_type) ? 8 : 4;
      add_def_score(phi.result_id, phi_weight);
      for (const auto &cond : phi.conditions) {
        if (!cond.is_const) add_use_score(cond.var_id, phi_weight);
      }
    }
  }
  for (const auto &[block_id, block] : riscv_func_.blocks_) {
    for (const auto &mv : block.move_instructions_) {
      const int move_weight = (mv.type_ && mv.type_->basic_type == pointer_type) ? 8 : 4;
      add_def_score(mv.dest_, move_weight);
      if (!mv.src_is_value_) add_use_score(mv.src_, move_weight);
    }
  }

  RebuildAllocatableNodes();
}

// ============================================================================
// Step 2: Compute liveness (bitset-based dataflow)
// ============================================================================

void RegisterAllocator::ComputeLiveness() {
  const auto direct_branch_icmps = FindDirectBranchIcmps(ir_func_);
  auto set_if_allocatable = [&](std::vector<uint64_t> &bs, int id) {
    if (id > 0 && BitTest(is_allocatable_, id)) {
      BitSet(bs, id);
    }
  };
  // --- Phase 1: Compute per-block def/use bitsets ---
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    std::vector<uint64_t> &defs = block_defs_[block_id];
    std::vector<uint64_t> &uses = block_uses_[block_id];
    auto add_use = [&](int id) {
      if (id > 0 && BitTest(is_allocatable_, id) && !BitTest(defs, id)) {
        BitSet(uses, id);
      }
    };
    auto add_def = [&](int id) {
      if (id > 0 && BitTest(is_allocatable_, id)) {
        BitSet(defs, id);
      }
    };

    for (const auto &inst : block.instructions_) {
      // Collect uses and defs for this instruction.
      switch (inst.instruction_type_) {
        case two_var_binary_operation_:
          add_use(inst.operand_1_id_);
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        case var_const_binary_operation_:
          add_use(inst.operand_1_id_);
          add_def(inst.result_id_);
          break;
        case const_var_binary_operation_:
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        case conditional_br_:
          add_use(inst.condition_id_);
          break;
        case variable_ret_:
          add_use(inst.result_id_);
          break;
        case load_:
        case ptr_load_:
          add_use(inst.pointer_);
          add_def(inst.result_id_);
          break;
        case variable_store_:
          add_use(inst.result_id_);
          add_use(inst.pointer_);
          break;
        case value_store_:
          add_use(inst.pointer_);
          break;
        case ptr_store_:
          add_use(inst.pointer_);
          add_use(inst.result_id_);
          break;
        case get_element_ptr_by_value_:
          add_use(inst.pointer_);
          add_def(inst.result_id_);
          break;
        case get_element_ptr_by_variable_:
          add_use(inst.pointer_);
          add_use(inst.index_);
          add_def(inst.result_id_);
          break;
        case two_var_icmp_:
          add_use(inst.operand_1_id_);
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        case var_const_icmp_:
          add_use(inst.operand_1_id_);
          add_def(inst.result_id_);
          break;
        case const_var_icmp_:
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        case non_void_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              add_use(arg.value_);
            }
          }
          add_def(inst.result_id_);
          break;
        }
        case void_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              add_use(arg.value_);
            }
          }
          break;
        }
        case builtin_call_: {
          for (const auto &arg : inst.function_call_arguments_) {
            if (arg.is_variable_) {
              add_use(arg.value_);
            }
          }
          if (inst.function_name_ == 2) {
            add_def(inst.result_id_);
          }
          break;
        }
        case value_select_ii_: {
          if (inst.condition_id_ == 0) {
            add_use(inst.operand_2_id_);
          } else {
            add_use(inst.operand_1_id_);
          }
          add_def(inst.result_id_);
          break;
        }
        case value_select_iv_: {
          if (inst.condition_id_ != 0) {
            add_use(inst.operand_1_id_);
          }
          add_def(inst.result_id_);
          break;
        }
        case value_select_vi_: {
          if (inst.condition_id_ == 0) {
            add_use(inst.operand_2_id_);
          }
          add_def(inst.result_id_);
          break;
        }
        case value_select_vv_: {
          add_def(inst.result_id_);
          break;
        }
        case variable_select_ii_: {
          add_use(inst.condition_id_);
          add_use(inst.operand_1_id_);
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        }
        case variable_select_vv_: {
          add_use(inst.condition_id_);
          add_def(inst.result_id_);
          break;
        }
        case variable_select_iv_: {
          add_use(inst.condition_id_);
          add_use(inst.operand_1_id_);
          add_def(inst.result_id_);
          break;
        }
        case variable_select_vi_: {
          add_use(inst.condition_id_);
          add_use(inst.operand_2_id_);
          add_def(inst.result_id_);
          break;
        }
        case builtin_memset_:
          add_use(inst.pointer_);
          break;
        case builtin_memcpy_:
          add_use(inst.destination_);
          add_use(inst.pointer_);
          break;
        default:
          break;
      }
    }
    const auto direct_cmp = direct_branch_icmps.find(block_id);
    if (direct_cmp != direct_branch_icmps.end()) {
      BitClear(defs, direct_cmp->second.result_id_);
      switch (direct_cmp->second.instruction_type_) {
        case two_var_icmp_:
          add_use(direct_cmp->second.operand_1_id_);
          add_use(direct_cmp->second.operand_2_id_);
          break;
        case var_const_icmp_:
          add_use(direct_cmp->second.operand_1_id_);
          break;
        case const_var_icmp_:
          add_use(direct_cmp->second.operand_2_id_);
          break;
        default:
          break;
      }
    }

    // Handle phi instructions: result is a def in this block.
    for (const auto &phi : block.phi_instructions_) {
      add_def(phi.result_id);
    }
  }

  // Phi source operands are uses on their incoming predecessor edge. They are
  // upward-exposed only when the predecessor block did not define that value.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    for (const auto &phi : block.phi_instructions_) {
      for (const auto &cond : phi.conditions) {
        if (cond.is_const || cond.var_id <= 0 || !BitTest(is_allocatable_, cond.var_id)) {
          continue;
        }
        const auto pred_defs = block_defs_.find(cond.from_block_id);
        if (pred_defs != block_defs_.end() && BitTest(pred_defs->second, cond.var_id)) {
          continue;
        }
        BitSet(block_uses_[cond.from_block_id], cond.var_id);
      }
    }
  }

  // --- Phase 2: Worklist dataflow iteration ---
  std::queue<int> worklist;
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    worklist.push(block_id);
  }

  while (!worklist.empty()) {
    int block_id = worklist.front();
    worklist.pop();

    // new_live_out = union of successor live_ins
    std::vector<uint64_t> new_live_out = MakeBitSet();
    if (successors_.count(block_id)) {
      for (int succ : successors_.at(block_id)) {
        if (live_in_.count(succ)) {
          BitOr(new_live_out, live_in_[succ]);
        }
      }
    }

    // new_live_in = block_uses ∪ (new_live_out − block_defs)
    // Compute: scratch = new_live_out; scratch -= block_defs; scratch |= block_uses
    std::vector<uint64_t> &scratch = scratch_bs_;
    // copy new_live_out into scratch
    for (int i = 0; i < bitset_words_; ++i) scratch[i] = new_live_out[i];
    BitSubtract(scratch, block_defs_[block_id]);
    BitOr(scratch, block_uses_[block_id]);

    const bool live_in_changed = !BitEqual(scratch, live_in_[block_id]);
    const bool live_out_changed = !BitEqual(new_live_out, live_out_[block_id]);
    if (live_in_changed || live_out_changed) {
      live_in_[block_id] = scratch;  // copy scratch back
      // Reset scratch for next use
      scratch = MakeBitSet();
      live_out_[block_id] = std::move(new_live_out);
      if (live_in_changed && predecessors_.count(block_id)) {
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
  const auto direct_branch_icmps = FindDirectBranchIcmps(ir_func_);
  interference_bits_.assign(max_var_id_ + 1, MakeBitSet());

  // Within each block: walk instructions backwards.
  for (const auto &[block_id, block] : ir_func_.blocks_) {
    // Start with variables live-out of this block, filtered by allocatable.
    std::vector<uint64_t> currently_live = MakeBitSet();
    if (live_out_.count(block_id)) {
      for (int i = 0; i < bitset_words_; ++i) {
        currently_live[i] = live_out_.at(block_id)[i];
      }
    }

    // Phi-induced moves use their sources; those are live at end-of-block.
    if (riscv_func_.blocks_.count(block_id)) {
      for (const auto &mv : riscv_func_.blocks_.at(block_id).move_instructions_) {
        if (!mv.src_is_value_ && mv.src_ > 0 && BitTest(is_allocatable_, mv.src_)) {
          BitSet(currently_live, mv.src_);
        }
      }
    }

    // The conditional-branch condition is loaded AFTER phi moves run.
    if (!block.instructions_.empty()) {
      const auto &last = block.instructions_.back();
      const auto direct_cmp = direct_branch_icmps.find(block_id);
      if (direct_cmp != direct_branch_icmps.end()) {
        auto add_branch_use = [&](int id) {
          if (id > 0 && BitTest(is_allocatable_, id)) {
            BitSet(currently_live, id);
          }
        };
        switch (direct_cmp->second.instruction_type_) {
          case two_var_icmp_:
            add_branch_use(direct_cmp->second.operand_1_id_);
            add_branch_use(direct_cmp->second.operand_2_id_);
            break;
          case var_const_icmp_:
            add_branch_use(direct_cmp->second.operand_1_id_);
            break;
          case const_var_icmp_:
            add_branch_use(direct_cmp->second.operand_2_id_);
            break;
          default:
            break;
        }
      } else if (last.instruction_type_ == conditional_br_ &&
          last.condition_id_ > 0 &&
          BitTest(is_allocatable_, last.condition_id_)) {
        BitSet(currently_live, last.condition_id_);
      }
    }

    // Phi-move destinations interfere with currently_live (except own source).
    if (riscv_func_.blocks_.count(block_id)) {
      for (const auto &mv : riscv_func_.blocks_.at(block_id).move_instructions_) {
        int dest = mv.dest_;
        if (dest <= 0 || !BitTest(is_allocatable_, dest)) continue;
        int own_src = (!mv.src_is_value_ && mv.src_ > 0) ? mv.src_ : -1;
        // Iterate set bits in currently_live
        for (int w = 0; w < bitset_words_; ++w) {
          uint64_t word = currently_live[w];
          while (word) {
            int bit = __builtin_ctzll(word);
            int live = w * 64 + bit;
            if (live != own_src) {
              AddInterference(dest, live);
            }
            word &= word - 1;
          }
        }
      }
    }

    // Walk instructions from bottom to top.
    for (auto inst_it = block.instructions_.rbegin();
         inst_it != block.instructions_.rend(); ++inst_it) {
      const auto &inst = *inst_it;

      // Collect defs and uses for this instruction (tiny, use vector).
      std::vector<int> inst_defs, inst_uses;
      int result_id = inst.result_id_;

      // --- Collect uses ---
      auto add_use = [&](int id) {
        if (id > 0 && BitTest(is_allocatable_, id)) inst_uses.push_back(id);
      };
      const auto direct_cmp_for_block = direct_branch_icmps.find(block_id);
      const bool skipped_direct_cmp =
          direct_cmp_for_block != direct_branch_icmps.end() &&
          IsIcmpInstruction(inst.instruction_type_) &&
          inst.result_id_ == direct_cmp_for_block->second.result_id_;
      if (!skipped_direct_cmp) {
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
          case variable_select_ii_:
            add_use(inst.condition_id_);
            add_use(inst.operand_1_id_); add_use(inst.operand_2_id_); break;
          case variable_select_vv_:
            add_use(inst.condition_id_); break;
          case variable_select_iv_:
            add_use(inst.condition_id_); add_use(inst.operand_1_id_); break;
          case variable_select_vi_:
            add_use(inst.condition_id_); add_use(inst.operand_2_id_); break;
          case builtin_memset_: add_use(inst.pointer_); break;
          case builtin_memcpy_: add_use(inst.destination_); add_use(inst.pointer_); break;
          default: break;
        }
      }

      // --- Collect defs ---
      if (!skipped_direct_cmp) {
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
            if (result_id > 0 && BitTest(is_allocatable_, result_id)) {
              inst_defs.push_back(result_id);
            }
            break;
          case builtin_call_:
            if (inst.function_name_ == 2 && result_id > 0 &&
                BitTest(is_allocatable_, result_id)) {
              inst_defs.push_back(result_id);
            }
            break;
          case alloca_:
            break;
          default: break;
        }
      }

      // Add interference: def interferes with everything currently live
      // (except itself if it's also a use).
      for (int def : inst_defs) {
        for (int w = 0; w < bitset_words_; ++w) {
          uint64_t word = currently_live[w];
          while (word) {
            int bit = __builtin_ctzll(word);
            int live = w * 64 + bit;
            AddInterference(def, live);
            word &= word - 1;
          }
        }
      }

      // Update currently_live: remove defs, add uses.
      for (int def : inst_defs) {
        BitClear(currently_live, def);
      }
      for (int use : inst_uses) {
        BitSet(currently_live, use);
      }
    }

    // Each phi result interferes with currently_live (except its sources).
    for (const auto &phi : block.phi_instructions_) {
      int phi_result = phi.result_id;
      if (phi_result <= 0 || !BitTest(is_allocatable_, phi_result)) continue;

      // Collect source var_ids for this phi.
      std::vector<int> sources;
      for (const auto &cond : phi.conditions) {
        if (!cond.is_const && cond.var_id > 0 && BitTest(is_allocatable_, cond.var_id)) {
          sources.push_back(cond.var_id);
        }
      }

      // Add interference with everything currently live, except sources.
      for (int w = 0; w < bitset_words_; ++w) {
        uint64_t word = currently_live[w];
        while (word) {
          int bit = __builtin_ctzll(word);
          int live = w * 64 + bit;
          if (live == phi_result) { word &= word - 1; continue; }
          bool is_source = false;
          for (int s : sources) { if (live == s) { is_source = true; break; } }
          if (!is_source) AddInterference(phi_result, live);
          word &= word - 1;
        }
      }
    }
  }

  // Add move edges from MoveInstructions (phi-to-move conversion).
  for (const auto &[block_id, r_block] : riscv_func_.blocks_) {
    for (const auto &mv : r_block.move_instructions_) {
      if (mv.src_is_value_) continue;
      int src = mv.src_;
      int dest = mv.dest_;
      if (src > 0 && dest > 0 &&
          BitTest(is_allocatable_, src) && BitTest(is_allocatable_, dest)) {
        move_edges_[src].push_back(dest);
        move_edges_[dest].push_back(src);
        BitSet(in_move_related_, src);
        BitSet(in_move_related_, dest);
      }
    }
    // Cross-interference between moves in the same block.  The previous
    // pairwise loop generated O(m^2) duplicate edges for large phi fan-in.
    // The constraints depend only on the unique source and destination sets.
    std::vector<uint64_t> move_dests = MakeBitSet();
    for (const auto &mv : r_block.move_instructions_) {
      if (mv.dest_ > 0 && BitTest(is_allocatable_, mv.dest_)) {
        BitSet(move_dests, mv.dest_);
      }
    }
    for (int w = 0; w < bitset_words_; ++w) {
      uint64_t dest_word = move_dests[w];
      while (dest_word) {
        int dest_bit = __builtin_ctzll(dest_word);
        int dest = w * 64 + dest_bit;
        for (const auto &mv : r_block.move_instructions_) {
          if (mv.src_is_value_ || mv.src_ <= 0 || !BitTest(is_allocatable_, mv.src_)) {
            continue;
          }
          if (mv.dest_ == dest && mv.src_ == dest) continue;
          if (mv.dest_ == dest) continue;
          AddInterference(dest, mv.src_);
        }
        uint64_t later_dests = dest_word & ~(1ULL << dest_bit);
        while (later_dests) {
          int other_bit = __builtin_ctzll(later_dests);
          AddInterference(dest, w * 64 + other_bit);
          later_dests &= later_dests - 1;
        }
        for (int dw = w + 1; dw < bitset_words_; ++dw) {
          uint64_t other_word = move_dests[dw];
          while (other_word) {
            int other_bit = __builtin_ctzll(other_word);
            AddInterference(dest, dw * 64 + other_bit);
            other_word &= other_word - 1;
          }
        }
        dest_word &= dest_word - 1;
      }
    }
  }

  // Keep adjacency order stable for coloring.  AddInterference already
  // prevents duplicate edges, so this is linear in the selected candidate set.
  for (int v : allocatable_nodes_) {
    auto &adj = interference_[v];
    if (adj.empty()) continue;
    std::sort(adj.begin(), adj.end());
  }

}

void RegisterAllocator::AddInterference(const int lhs, const int rhs) {
  if (lhs <= 0 || rhs <= 0 || lhs == rhs) return;
  if (lhs > max_var_id_ || rhs > max_var_id_) return;
  if (!BitTest(is_allocatable_, lhs) || !BitTest(is_allocatable_, rhs)) return;
  if (BitTest(interference_bits_[lhs], rhs)) return;
  BitSet(interference_bits_[lhs], rhs);
  BitSet(interference_bits_[rhs], lhs);
  interference_[lhs].push_back(rhs);
  interference_[rhs].push_back(lhs);
}

// ============================================================================
// Step 4: Chaitin-Briggs graph coloring
// ============================================================================

int RegisterAllocator::GetDegree(int node) const {
  return current_degree_[node];
}

int RegisterAllocator::GetSignificantDegree(int node, int k) const {
  int count = 0;
  for (int neighbor : interference_[node]) {
    if (BitTest(in_worklist_, neighbor) && current_degree_[neighbor] >= k) {
      ++count;
    }
  }
  return count;
}

void RegisterAllocator::ColorGraph() {
  int K = static_cast<int>(allocatable_regs_.size());

  // Initialize worklist with all allocatable variables.
  for (int v : allocatable_nodes_) {
    if (BitTest(is_allocatable_, v)) {
      BitSet(in_worklist_, v);
    }
  }
  select_stack_.clear();

  // Initialize cached degrees.
  for (int v : allocatable_nodes_) {
    if (BitTest(in_worklist_, v)) {
      int deg = 0;
      for (int neighbor : interference_[v]) {
        if (BitTest(in_worklist_, neighbor)) ++deg;
      }
      current_degree_[v] = deg;
    }
  }

  while (true) {
    // Check if worklist is empty
    bool any = false;
    for (int v : allocatable_nodes_) {
      if (BitTest(in_worklist_, v)) { any = true; break; }
    }
    if (!any) break;

    // ---- SIMPLIFY ----
    Simplify();
    // Check again
    any = false;
    for (int v : allocatable_nodes_) {
      if (BitTest(in_worklist_, v)) { any = true; break; }
    }
    if (!any) break;

    // ---- COALESCE ----
    if (Coalesce()) continue;

    // ---- FREEZE ----
    Freeze();
    // After freeze, try simplify again.
    Simplify();
    any = false;
    for (int v : allocatable_nodes_) {
      if (BitTest(in_worklist_, v)) { any = true; break; }
    }
    if (!any) break;

    // ---- SELECT SPILL ----
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
    for (int node : allocatable_nodes_) {
      if (!BitTest(in_worklist_, node)) continue;
      if (current_degree_[node] < 0) continue;
      if (BitTest(in_move_related_, node) && !move_edges_[node].empty()) continue;
      if (current_degree_[node] < K) {
        changed = true;
        select_stack_.push_back(node);
        BitClear(is_spilled_, node);  // ensure not marked spilled
        BitClear(in_worklist_, node);
        // Decrement cached degree of each neighbor still in worklist.
        for (int neighbor : interference_[node]) {
          if (BitTest(in_worklist_, neighbor) && current_degree_[neighbor] > 0) {
            --current_degree_[neighbor];
          }
        }
        current_degree_[node] = -1;
        BitClear(in_move_related_, node);
      }
    }
  }
}

bool RegisterAllocator::Coalesce() {
  const int K = static_cast<int>(allocatable_regs_.size());

  for (int u : allocatable_nodes_) {
    if (!BitTest(in_worklist_, u)) continue;

    auto neighbors = move_edges_[u];
    for (int v : neighbors) {
      if (!BitTest(in_worklist_, v)) continue;

      // Real interference means both values are simultaneously live and cannot
      // share a register.  Move edges alone are not interference.
      bool interferes = false;
      for (int n : interference_[u]) {
        if (n == v) {
          interferes = true;
          break;
        }
      }
      if (interferes) {
        auto &u_moves = move_edges_[u];
        u_moves.erase(std::remove(u_moves.begin(), u_moves.end(), v), u_moves.end());
        auto &v_moves = move_edges_[v];
        v_moves.erase(std::remove(v_moves.begin(), v_moves.end(), u), v_moves.end());
        if (u_moves.empty()) BitClear(in_move_related_, u);
        if (v_moves.empty()) BitClear(in_move_related_, v);
        continue;
      }

      // Keep the lower-degree node as the representative when possible; this
      // usually preserves the already-friendly color pressure of the graph.
      int rep = u;
      int merged = v;
      if (current_degree_[v] < current_degree_[u]) {
        rep = v;
        merged = u;
      }

      if (BriggsTest(rep, merged, K) &&
          GeorgeTest(rep, merged, K) &&
          GeorgeTest(merged, rep, K)) {
        CoalesceNodes(rep, merged);
        return true;
      }
    }
  }

  return false;
}

bool RegisterAllocator::BriggsTest(int u, int v, int k) const {
  // Count combined neighbors using a seen marker.
  std::vector<uint64_t> seen = MakeBitSet();
  int significant = 0;
  auto check = [&](int n) {
    if (n == u || n == v) return;
    if (BitTest(seen, n)) return;
    BitSet(seen, n);
    if (BitTest(in_worklist_, n) && current_degree_[n] >= k) ++significant;
  };
  for (int n : interference_[u]) check(n);
  for (int n : interference_[v]) check(n);
  return significant < k;
}

bool RegisterAllocator::GeorgeTest(int u, int v, int k) const {
  for (int t : interference_[u]) {
    if (t == v) continue;
    if (!BitTest(in_worklist_, t)) continue;
    // Check if t already interferes with v.
    bool interferes = false;
    for (int n : interference_[v]) {
      if (n == t) { interferes = true; break; }
    }
    if (interferes) continue;
    // Check if t has degree < k (simplifiable).
    if (current_degree_[t] < k) continue;
    return false;
  }
  return true;
}

void RegisterAllocator::CoalesceNodes(int u, int v) {
  // Merge v into u.
  // Transfer interference edges from v to u.
  for (int neighbor : interference_[v]) {
    if (neighbor != u) {
      if (!BitTest(interference_bits_[u], neighbor)) {
        BitSet(interference_bits_[u], neighbor);
        BitSet(interference_bits_[neighbor], u);
        interference_[u].push_back(neighbor);
      }
      // Remove v from neighbor's list
      auto &nlist = interference_[neighbor];
      nlist.erase(std::remove(nlist.begin(), nlist.end(), v), nlist.end());
      if (neighbor != u &&
          std::find(nlist.begin(), nlist.end(), u) == nlist.end()) {
        nlist.push_back(u);
      }
      BitClear(interference_bits_[neighbor], v);
    }
  }
  interference_bits_[v] = MakeBitSet();

  // Transfer move edges from v to u.
  for (int neighbor : move_edges_[v]) {
    if (neighbor != u) {
      if (std::find(move_edges_[u].begin(), move_edges_[u].end(), neighbor)
          == move_edges_[u].end()) {
        move_edges_[u].push_back(neighbor);
      }
      if (std::find(move_edges_[neighbor].begin(), move_edges_[neighbor].end(), u)
          == move_edges_[neighbor].end()) {
        move_edges_[neighbor].push_back(u);
      }
      auto &nlist = move_edges_[neighbor];
      nlist.erase(std::remove(nlist.begin(), nlist.end(), v), nlist.end());
    }
  }

  // Remove v from move_edges_ of u.
  auto &ulist = move_edges_[u];
  ulist.erase(std::remove(ulist.begin(), ulist.end(), v), ulist.end());

  // Remove v from the graph.
  interference_[v].clear();
  move_edges_[v].clear();
  BitClear(in_worklist_, v);
  BitClear(in_move_related_, v);

  // If u no longer has move edges, remove from move_related_.
  if (move_edges_[u].empty()) {
    BitClear(in_move_related_, u);
  } else {
    BitSet(in_move_related_, u);
  }

  // Record coalescing: v maps to u.
  coalesced_rep_[v] = u;

  for (int node : allocatable_nodes_) {
    if (!BitTest(in_worklist_, node)) continue;
    int degree = 0;
    for (int neighbor : interference_[node]) {
      if (BitTest(in_worklist_, neighbor)) ++degree;
    }
    current_degree_[node] = degree;
  }
}

void RegisterAllocator::Freeze() {
  int K = static_cast<int>(allocatable_regs_.size());

  // Find a move-related node with degree < K and freeze its move edges.
  for (int node : allocatable_nodes_) {
    if (!BitTest(in_move_related_, node)) continue;
    if (!BitTest(in_worklist_, node)) continue;
    if (current_degree_[node] >= K) continue;

    // Freeze: convert all move edges of this node into nothing
    // (they're already interference edges, just remove the move edges).
    auto move_neighbors = move_edges_[node]; // copy
    for (int neighbor : move_neighbors) {
      // Remove the move edge from neighbor.
      auto &nlist = move_edges_[neighbor];
      nlist.erase(std::remove(nlist.begin(), nlist.end(), node), nlist.end());
      if (nlist.empty()) {
        BitClear(in_move_related_, neighbor);
      }
    }
    move_edges_[node].clear();
    BitClear(in_move_related_, node);
    return; // Freeze one node per iteration.
  }
}

void RegisterAllocator::SelectSpill() {
  int spill_node = SelectSpillCandidate();
  if (spill_node < 0) {
    // Fallback: pick any node still in worklist.
    for (int v : allocatable_nodes_) {
      if (BitTest(in_worklist_, v)) { spill_node = v; break; }
    }
  }
  if (spill_node < 0) return; // shouldn't happen

  select_stack_.push_back(spill_node);
  BitSet(is_spilled_, spill_node);
  BitClear(in_worklist_, spill_node);
  // Decrement cached degree of each neighbor still in worklist.
  for (int neighbor : interference_[spill_node]) {
    if (BitTest(in_worklist_, neighbor) && current_degree_[neighbor] > 0) {
      --current_degree_[neighbor];
    }
  }
  current_degree_[spill_node] = -1;
  BitClear(in_move_related_, spill_node);
}

int RegisterAllocator::SelectSpillCandidate() const {
  int best_node = -1;
  long long best_cost = 0;
  int best_degree = 1;
  for (int node : allocatable_nodes_) {
    if (!BitTest(in_worklist_, node)) continue;
    const int deg = std::max(1, current_degree_[node]);
    const long long cost = node >= 0 && node < static_cast<int>(spill_cost_.size())
        ? spill_cost_[node]
        : 1;
    if (best_node < 0 ||
        cost * static_cast<long long>(best_degree) <
            best_cost * static_cast<long long>(deg) ||
        (cost * static_cast<long long>(best_degree) ==
             best_cost * static_cast<long long>(deg) &&
         current_degree_[node] > current_degree_[best_node])) {
      best_cost = cost;
      best_degree = deg;
      best_node = node;
    }
  }
  return best_node;
}

void RegisterAllocator::AssignColors() {
  int K = static_cast<int>(allocatable_regs_.size());

  // node_color: -2 = unassigned, -1 = spill, >=0 = physical register
  std::vector<int> node_color(max_var_id_ + 1, -2);

  while (!select_stack_.empty()) {
    int node = select_stack_.back();
    select_stack_.pop_back();

    // Check if this node was coalesced into another.
    if (coalesced_rep_[node] >= 0) {
      int rep = coalesced_rep_[node];
      if (node_color[rep] >= -1) {
        node_color[node] = node_color[rep];
      }
      continue;
    }

    // Find colors used by neighbors.
    std::vector<bool> used_colors(K, false);
    for (int neighbor : interference_[node]) {
      if (node_color[neighbor] >= 0) {
        // Map physical register back to color index
        int reg = node_color[neighbor];
        for (int ci = 0; ci < K; ++ci) {
          if (allocatable_regs_[ci] == reg) { used_colors[ci] = true; break; }
        }
      }
      // Also check coalesced neighbors.
      int rep = coalesced_rep_[neighbor];
      if (rep >= 0 && node_color[rep] >= 0) {
        int reg = node_color[rep];
        for (int ci = 0; ci < K; ++ci) {
          if (allocatable_regs_[ci] == reg) { used_colors[ci] = true; break; }
        }
      }
    }

    // Handle spilled nodes: try to assign a color anyway (optimistic coloring).
    int assigned_color = -1;
    for (int ci = 0; ci < K; ++ci) {
      if (!used_colors[ci]) {
        assigned_color = allocatable_regs_[ci];
        break;
      }
    }

    if (BitTest(is_spilled_, node) && assigned_color < 0) {
      node_color[node] = -1;
    } else {
      node_color[node] = assigned_color;
    }
  }

  auto find_rep = [&](int var) {
    int rep = var;
    while (rep >= 0 && rep <= max_var_id_ && coalesced_rep_[rep] >= 0) {
      rep = coalesced_rep_[rep];
    }
    return rep;
  };

  for (int v : allocatable_nodes_) {
    if (coalesced_rep_[v] < 0) continue;
    const int rep = find_rep(v);
    if (rep >= 0 && rep <= max_var_id_ && node_color[rep] >= -1) {
      node_color[v] = node_color[rep];
    }
  }

  // Persist the results.
  for (int v : allocatable_nodes_) {
    if (node_color[v] >= -1) {
      assignment_[v] = node_color[v];
    }
  }
}

// ============================================================================
// Step 5: Update location map
// ============================================================================

void RegisterAllocator::UpdateLocationMap() {
  for (int var : allocatable_nodes_) {
    if (!BitTest(is_allocatable_, var)) continue;
    if (BitTest(is_stack_bound_, var)) continue;

    if (assignment_[var] >= 0) {
      riscv_func_.location_[var] = {true, assignment_[var]};
    } else if (assignment_[var] == -1) {
      if (riscv_func_.location_.count(var)) {
        riscv_func_.location_[var].first = false;
      } else {
        int size = var_size_[var] > 0 ? var_size_[var] : 4;
        if (size == 8 && riscv_func_.stack_space_ % 8 != 0) {
          riscv_func_.stack_space_ = (riscv_func_.stack_space_ + 7) / 8 * 8;
        }
        riscv_func_.location_[var] = {false, riscv_func_.stack_space_};
        riscv_func_.stack_space_ += size;
      }
    }
  }

  // Resolve coalesced variables.
  for (int var : allocatable_nodes_) {
    if (coalesced_rep_[var] < 0) continue;
    if (BitTest(is_stack_bound_, var)) continue;
    int rep = var;
    while (rep >= 0 && rep <= max_var_id_ && coalesced_rep_[rep] >= 0) {
      rep = coalesced_rep_[rep];
    }
    if (assignment_[rep] >= 0) {
      riscv_func_.location_[var] = {true, assignment_[rep]};
    } else {
      if (riscv_func_.location_.count(var)) {
        riscv_func_.location_[var].first = false;
      }
    }
  }
}

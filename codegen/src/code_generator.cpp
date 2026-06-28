#include "code_generator.h"
#include "register_allocator.h"
#include "fstream"
#include "item.h"
#include <algorithm>
#include <cstdint>
#include <queue>
#include <set>
#include <vector>

enum saver {no_saver, caller_save, callee_save};
const std::map<int, saver> register_saver = {
  {0, no_saver}, {1, caller_save}, {2, no_saver},
  {3, no_saver}, {4, no_saver}, {5, caller_save},
  {6, caller_save}, {7, caller_save}, {8, callee_save},
  {9, callee_save}, {10, caller_save}, {11, caller_save},
  {12, caller_save}, {13, caller_save}, {14, caller_save},
  {15, caller_save}, {16, caller_save}, {17, caller_save},
  {18, callee_save}, {19, callee_save}, {20, callee_save},
  {21, callee_save}, {22, callee_save}, {23, callee_save},
  {24, callee_save}, {25, callee_save}, {26, callee_save},
  {27, callee_save}, {28, caller_save}, {29, caller_save},
  {30, caller_save}, {31, caller_save}
};

static bool IsCallerSavedReg(int reg) {
  const auto it = register_saver.find(reg);
  return it != register_saver.end() && it->second == caller_save;
}

static int AlignUp(int value, int alignment) {
  return (value + alignment - 1) / alignment * alignment;
}

static bool IsPowerOfTwo(const int value) {
  return value > 0 && (value & (value - 1)) == 0;
}

static int Log2Int(int value) {
  int result = 0;
  while (value > 1) {
    value >>= 1;
    ++result;
  }
  return result;
}

static bool TryEmitMulConst32(RISCVBlock &block, const int dest_reg,
    const int src_reg, const int constant, const int tmp_reg) {
  if (constant == 0) {
    block.PushLi(dest_reg, 0);
    return true;
  }
  if (constant == 1) {
    block.PushArithmetic_R(r_add_, dest_reg, src_reg, 0);
    return true;
  }
  if (constant == -1) {
    block.PushArithmetic_R(r_subw_, dest_reg, 0, src_reg);
    return true;
  }

  const bool negative = constant < 0;
  const int abs_constant = negative ? -constant : constant;
  if (IsPowerOfTwo(abs_constant)) {
    block.PushArithmetic_I(r_slliw_, dest_reg, src_reg, Log2Int(abs_constant));
    if (negative) {
      block.PushArithmetic_R(r_subw_, dest_reg, 0, dest_reg);
    }
    return true;
  }

  if (IsPowerOfTwo(abs_constant + 1)) {
    block.PushArithmetic_I(r_slliw_, tmp_reg, src_reg, Log2Int(abs_constant + 1));
    block.PushArithmetic_R(r_subw_, dest_reg, tmp_reg, src_reg);
    if (negative) {
      block.PushArithmetic_R(r_subw_, dest_reg, 0, dest_reg);
    }
    return true;
  }

  if (IsPowerOfTwo(abs_constant - 1)) {
    block.PushArithmetic_I(r_slliw_, tmp_reg, src_reg, Log2Int(abs_constant - 1));
    block.PushArithmetic_R(r_addw_, dest_reg, tmp_reg, src_reg);
    if (negative) {
      block.PushArithmetic_R(r_subw_, dest_reg, 0, dest_reg);
    }
    return true;
  }

  int first_bit = -1;
  int second_bit = -1;
  int bit_count = 0;
  for (int bit = 0; bit < 31; ++bit) {
    if ((abs_constant & (1 << bit)) == 0) {
      continue;
    }
    if (first_bit == -1) {
      first_bit = bit;
    } else if (second_bit == -1) {
      second_bit = bit;
    }
    ++bit_count;
  }
  if (bit_count == 2) {
    if (second_bit == 0) {
      block.PushArithmetic_R(r_add_, tmp_reg, src_reg, 0);
    } else {
      block.PushArithmetic_I(r_slliw_, tmp_reg, src_reg, second_bit);
    }
    if (first_bit == 0) {
      block.PushArithmetic_R(r_add_, dest_reg, src_reg, 0);
    } else {
      block.PushArithmetic_I(r_slliw_, dest_reg, src_reg, first_bit);
    }
    block.PushArithmetic_R(r_addw_, dest_reg, dest_reg, tmp_reg);
    if (negative) {
      block.PushArithmetic_R(r_subw_, dest_reg, 0, dest_reg);
    }
    return true;
  }

  return false;
}

static bool IsIcmpInstruction(const IRInstructionType type) {
  return type == two_var_icmp_ || type == var_const_icmp_ ||
      type == const_var_icmp_;
}

static bool IsDirectLabelBranch(const RISCVInstruction &inst) {
  if (inst.instruction_type_ == r_beqz_ || inst.instruction_type_ == r_bnez_) {
    return true;
  }
  return inst.imm_ == 1 &&
      (inst.instruction_type_ == r_beq_ || inst.instruction_type_ == r_bge_ ||
       inst.instruction_type_ == r_bgeu_ || inst.instruction_type_ == r_blt_ ||
       inst.instruction_type_ == r_bltu_ || inst.instruction_type_ == r_bne_);
}

static bool IsUnconditionalJump(const RISCVInstruction &inst) {
  return inst.instruction_type_ == r_j_;
}

static int ConservativeInstructionBytes(const RISCVInstruction &inst) {
  switch (inst.instruction_type_) {
    case r_li_:
    case r_la_:
    case r_call_:
      return 8;
    default:
      return 4;
  }
}

static int ConservativeBlockBytes(const RISCVBlock &block) {
  int bytes = 0;
  for (const auto &inst : block.instructions_) {
    bytes += ConservativeInstructionBytes(inst);
  }
  for (const auto &jump : block.jump_blocks_) {
    bytes += ConservativeInstructionBytes(jump);
  }
  return bytes;
}

static std::vector<int> ComputeBlockLayout(const IRFunctionNode &function) {
  std::vector<int> layout;
  layout.reserve(function.blocks_.size());
  std::set<int> placed;

  auto numeric_next = [&](const int block_id) {
    const auto it = function.blocks_.upper_bound(block_id);
    return it == function.blocks_.end() ? -1 : it->first;
  };

  auto choose_successor = [&](const int block_id) {
    const auto block_it = function.blocks_.find(block_id);
    if (block_it == function.blocks_.end() || block_it->second.instructions_.empty()) {
      return -1;
    }

    const auto &last = block_it->second.instructions_.back();
    if (last.instruction_type_ == unconditional_br_) {
      return placed.contains(last.destination_) ? -1 : last.destination_;
    }
    if (last.instruction_type_ != conditional_br_) {
      return -1;
    }

    const int true_target = last.if_true_;
    const int false_target = last.if_false_;
    const bool true_open = !placed.contains(true_target) && function.blocks_.contains(true_target);
    const bool false_open = !placed.contains(false_target) && function.blocks_.contains(false_target);
    if (!true_open && !false_open) {
      return -1;
    }
    if (true_open && !false_open) {
      return true_target;
    }
    if (!true_open && false_open) {
      return false_target;
    }

    const int next = numeric_next(block_id);
    if (true_target == next) {
      return true_target;
    }
    if (false_target == next) {
      return false_target;
    }

    // When neither successor is already the lexical next block, prefer the
    // false edge as the fall-through. Direct branch lowering can then test for
    // the true edge without an extra unconditional jump.
    return false_target;
  };

  auto append_trace = [&](int start) {
    while (start != -1 && function.blocks_.contains(start) && !placed.contains(start)) {
      layout.push_back(start);
      placed.insert(start);
      start = choose_successor(start);
    }
  };

  if (!function.blocks_.empty()) {
    append_trace(function.blocks_.begin()->first);
  }
  for (const auto &[block_id, block] : function.blocks_) {
    append_trace(block_id);
  }
  return layout;
}

void CodegenThrow(const std::string &err_info) {
  // std::cerr << "[Codegen Error] " << err_info << '\n';
  throw "";
}

RISCVInstructionType CodeGenerator::GetLoadInst(const std::shared_ptr<IntegratedType> &type) {
  if (type->basic_type == bool_type) return r_lbu_;
  if (type->basic_type == pointer_type) return r_ld_;
  return r_lw_;
}

RISCVInstructionType CodeGenerator::GetStoreInst(const std::shared_ptr<IntegratedType> &type) {
  if (type->basic_type == bool_type) return r_sb_;
  if (type->basic_type == pointer_type) return r_sd_;
  return r_sw_;
}

std::pair<int, bool> CodeGenerator::GetSize(const std::shared_ptr<IntegratedType> &type) const {
  switch (type->basic_type) {
    case bool_type: {
      return {1, false};
    }
    case i32_type:
    case u32_type:
    case isize_type:
    case usize_type:
    case enumeration_type: {
      return {4, true};
    }
    case pointer_type: {
      return {8, true};
    }
    case array_type: {
      const auto element_size = GetSize(type->element_type);
      return {static_cast<int>(type->size * element_size.first), element_size.second};
    }
    case struct_type: {
      bool has_int = false;
      auto item_index_map = dynamic_cast<Struct *>(type->struct_node)->field_item_index_;
      auto item_info_map = dynamic_cast<Struct *>(type->struct_node)->field_items_;
      std::vector<int> sizes(item_index_map.size());
      std::vector<bool> element_basic_types(item_index_map.size());
      for (const auto &[name, index] : item_index_map) {
        const auto &item_info = item_info_map[name];
        const auto &[item_size, is_aligned] = GetSize(item_info.node->integrated_type_);
        sizes[index] = item_size;
        element_basic_types[index] = is_aligned;
        if (is_aligned) {
          has_int = true;
        }
      }
      int total_size = 0;
      if (has_int) {
        for (int i = 0; i < sizes.size(); ++i) {
          if (element_basic_types[i]) {
            total_size = (total_size + 3) / 4 * 4;
          }
          total_size += sizes[i];
        }
        total_size = (total_size + 3) / 4 * 4;
      } else {
        for (const int element_size : sizes) {
          total_size += element_size;
        }
      }
      return {total_size, has_int};
    }
    default: {
      CodegenThrow("Invalid type to get size.");
    }
  }
  return {0, false};
}

int CodeGenerator::GetAlignment(const std::shared_ptr<IntegratedType> &type) const {
  switch (type->basic_type) {
    case bool_type: {
      return 1;
    }
    case i32_type:
    case u32_type:
    case isize_type:
    case usize_type:
    case enumeration_type: {
      return 4;
    }
    case pointer_type: {
      return 8;
    }
    case array_type: {
      return GetAlignment(type->element_type);
    }
    case struct_type: {
      int max_align = 1;
      auto item_info_map = dynamic_cast<Struct *>(type->struct_node)->field_items_;
      for (const auto &[name, item] : item_info_map) {
        int a = GetAlignment(item.node->integrated_type_);
        if (a > max_align) max_align = a;
      }
      return max_align;
    }
    default: {
      CodegenThrow("Invalid type to get alignment.");
    }
  }
  return 4;
}

std::pair<bool, int> CodeGenerator::GetParamPassPos(const int function_id, const int param_id) const {
  if (RISCV_functions_[function_id].location_.at(param_id).first) {
    return RISCV_functions_[function_id].location_.at(param_id);
  }
  return {false, -(RISCV_functions_[function_id].stack_space_ - RISCV_functions_[function_id].location_.at(param_id).second)};
} // {true, reg_id} or {false, neg_offset}

void CodeGenerator::PhiToMove() {
  struct PendingValueMove {
    int block_id;
    int src;
    int dest;
    const std::shared_ptr<IntegratedType> *type;
  };

  for (int i = 0; i < IR_functions_.size(); ++i) {
    std::map<BlockJumping, AssignmentGraph> assign_relations;
    std::vector<PendingValueMove> value_moves;
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      for (const auto &instruction : block.phi_instructions_) {
        const int dest_var_id = instruction.result_id;
        const auto &type = instruction.type;
        for (const auto &condition : instruction.conditions) {
          if (condition.is_const) { // is literal value
            value_moves.push_back({condition.from_block_id, condition.value,
                dest_var_id, &type});
          } else {
            if (!assign_relations.contains({condition.from_block_id, block_id})) {
              assign_relations.insert(std::pair<BlockJumping, AssignmentGraph>(
                  {condition.from_block_id, block_id}, AssignmentGraph(IR_functions_[i].var_id_ << 1)));
            }
            assign_relations[{condition.from_block_id, block_id}].AddEdge(condition.var_id,
                dest_var_id, type);
          }
        }
      }
    }
    int tmp_var_id = IR_functions_[i].var_id_;
    for (auto &[block_jump, graph] : assign_relations) {
      graph.EliminateCycles(block_jump, tmp_var_id, RISCV_functions_[i].blocks_);
    }
    // Literal phi moves do not read any predecessor value, so emit them after
    // all variable phi copies. This preserves parallel-copy semantics when a
    // literal phi writes a variable that another phi reads on the same edge.
    for (const auto &move : value_moves) {
      RISCV_functions_[i].blocks_[move.block_id].PushMove(*move.type, true,
          move.src, move.dest);
    }
  }
}

void CodeGenerator::MemAlloc(const int func_id) {
  int &space = RISCV_functions_[func_id].stack_space_;
  // Non-leaf functions need space for: 28×8=224 save slots + 128 temp area = 352.
  // Leaf functions (no calls): skip the 128-byte temp save area (no nested
  // memcpy), saving 128 bytes per leaf function.  Save area stays at 28×8=224
  // because the register allocator may still use any allocatable reg.
  space = is_leaf_[func_id] ? 224 : 352;
  int used_register = 0; // a-registers
  for (int i = 0; i < IR_functions_[func_id].parameter_types_.size(); ++i) {
    if (used_register == 8 || IR_functions_[func_id].parameter_types_[i]->basic_type == array_type
        || IR_functions_[func_id].parameter_types_[i]->basic_type == struct_type) {
      const auto [need_space, need_alignment] = GetSize(IR_functions_[func_id].parameter_types_[i]);
      space += GetSize(IR_functions_[func_id].parameter_types_[i]).first;
      if (need_alignment && space % need_space != 0) {
        space = space - space % need_space + need_space;
      }
      RISCV_functions_[func_id].location_[i] = {false, space};
    } else {
      RISCV_functions_[func_id].location_[i] = {true, used_register + 10};
      used_register++;
    }
  }
  for (const auto &instruction : IR_functions_[func_id].alloca_instructions_) {
    space += 8;
    space = (space + 7) / 8 * 8;
    RISCV_functions_[func_id].location_[instruction.result_id_] = {false, space};
    alloca_var_ids_[func_id].insert(instruction.result_id_);
    space += GetSize(instruction.result_type_).first;
  }
  for (const auto &[block_id, block] : IR_functions_[func_id].blocks_) {
    for (const auto &instruction : block.instructions_) {
      if (instruction.instruction_type_ == two_var_binary_operation_
          || instruction.instruction_type_ == var_const_binary_operation_
          || instruction.instruction_type_ == const_var_binary_operation_
          || instruction.instruction_type_ == load_
          || instruction.instruction_type_ == non_void_call_
          || (instruction.instruction_type_ == builtin_call_ && instruction.function_name_ == 2)) {
        const auto [need_space, need_alignment] = GetSize(instruction.result_type_);
        space += need_space;
        if (need_alignment && space % need_space != 0) {
          space = space - space % need_space + need_space;
        }
        RISCV_functions_[func_id].location_[instruction.result_id_] = {false, space};
      } else if (instruction.instruction_type_ == value_select_ii_
          || instruction.instruction_type_ == value_select_iv_
          || instruction.instruction_type_ == value_select_vi_
          || instruction.instruction_type_ == value_select_vv_
          || instruction.instruction_type_ == variable_select_ii_
          || instruction.instruction_type_ == variable_select_iv_
          || instruction.instruction_type_ == variable_select_vi_
          || instruction.instruction_type_ == variable_select_vv_) {
        if (!instruction.result_type_->is_int && instruction.result_type_->basic_type != pointer_type
            && instruction.result_type_->basic_type != bool_type) {
          CodegenThrow("The type in the select instruction is neither int nor bool! Check and polish the interpretation to enable select instruction to handle other types!");
        }
        const auto [need_space, need_alignment] = GetSize(instruction.result_type_);
        space += need_space;
        if (need_alignment && space % need_space != 0) {
          space = space - space % need_space + need_space;
        }
        RISCV_functions_[func_id].location_[instruction.result_id_] = {false, space};
      } else if (instruction.instruction_type_ == ptr_load_
          || instruction.instruction_type_ == get_element_ptr_by_value_
          || instruction.instruction_type_ == get_element_ptr_by_variable_) {
        space += 8;
        if (space % 8 != 0) {
          space = space - space % 8 + 8;
        }
        RISCV_functions_[func_id].location_[instruction.result_id_] = {false, space};
      } else if (instruction.instruction_type_ == two_var_icmp_
          || instruction.instruction_type_ == var_const_icmp_
          || instruction.instruction_type_ == const_var_icmp_) {
        space += 1;
        RISCV_functions_[func_id].location_[instruction.result_id_] = {false, space};
      }
    }
  }
  for (const auto &[block_id, block] : IR_functions_[func_id].blocks_) {
    for (const auto &mv_instruction : RISCV_functions_[func_id].blocks_[block_id].move_instructions_) {
      if (!RISCV_functions_[func_id].location_.contains(mv_instruction.dest_)) {
        const auto [need_space, need_alignment] = GetSize(mv_instruction.type_);
        space += need_space;
        if (need_alignment && space % need_space != 0) {
          space = space - space % need_space + need_space;
        }
        RISCV_functions_[func_id].location_[mv_instruction.dest_] = {false, space};
      }
    }
  }
  // Reserve 128 bytes at the bottom of the frame (sp+0..127) for the
  // TempCallerSaveSlot used during nested memcpy calls. Because the
  // intermediate offsets are flipped (final = total - intermediate), this
  // reservation must be added AFTER all variables are allocated so the
  // smallest final offset (for the variable with the largest intermediate)
  // is still >= 128.
  // Leaf functions have no calls ⇒ no nested memcpy ⇒ skip temp area.
  if (!is_leaf_[func_id]) {
    space += 128;
  }
  space = (space + 15) / 16 * 16;  // RV64 ABI: 16-byte stack alignment
  for (const auto [var_id, location] : RISCV_functions_[func_id].location_) {
    if (!location.first) {
      RISCV_functions_[func_id].location_[var_id].second = space - RISCV_functions_[func_id].location_[var_id].second;
    }
  }
}

void CodeGenerator::CompactStackFrame(const int func_id) {
  auto &riscv_func = RISCV_functions_[func_id];
  const auto &ir_func = IR_functions_[func_id];
  struct StackSlot {
    int size = 0;
    int alignment = 1;
    bool is_alloca_pointer = false;
    bool is_pointer_like = false;
    bool used_around_call = false;
    long long hotness = 0;
  };
  struct PayloadSlot {
    int alloca_id = 0;
    int size = 0;
    int alignment = 1;
  };
  std::map<int, StackSlot> stack_slots;
  std::vector<PayloadSlot> payload_slots;
  std::map<int, long long> hotness;

  auto add_score = [&](const int var_id, const long long amount) {
    if (var_id > 0) {
      hotness[var_id] += amount;
    }
  };

  std::map<int, std::vector<int>> successors;
  std::map<int, int> block_depth;
  std::map<int, int> block_weight;
  for (const auto &[block_id, block] : ir_func.blocks_) {
    block_depth[block_id] = 0;
    if (block.instructions_.empty()) continue;
    const auto &last = block.instructions_.back();
    if (last.instruction_type_ == conditional_br_) {
      successors[block_id].push_back(last.if_true_);
      successors[block_id].push_back(last.if_false_);
    } else if (last.instruction_type_ == unconditional_br_) {
      successors[block_id].push_back(last.destination_);
    }
  }
  for (const auto &[from, succs] : successors) {
    for (int to : succs) {
      if (to > from) continue;
      for (const auto &[block_id, block] : ir_func.blocks_) {
        if (block_id >= to && block_id <= from) {
          ++block_depth[block_id];
        }
      }
    }
  }
  for (const auto &[block_id, block] : ir_func.blocks_) {
    const int depth = block_depth[block_id];
    block_weight[block_id] = 1 + depth * 8 + depth * depth * 4;
  }

  for (const auto &instruction : ir_func.alloca_instructions_) {
    add_score(instruction.result_id_, 200);
  }
  for (const auto &[block_id, block] : ir_func.blocks_) {
    const int weight = block_weight[block_id];
    for (const auto &phi : block.phi_instructions_) {
      add_score(phi.result_id, 4LL * weight);
      for (const auto &condition : phi.conditions) {
        if (!condition.is_const) {
          add_score(condition.var_id, 4LL * block_weight[condition.from_block_id]);
        }
      }
    }
    for (const auto &instruction : block.instructions_) {
      auto add_def = [&](int var_id, long long amount = 4) {
        add_score(var_id, amount * weight);
      };
      auto add_use = [&](int var_id, long long amount = 6) {
        add_score(var_id, amount * weight);
      };

      switch (instruction.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_:
          add_use(instruction.operand_1_id_);
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case var_const_binary_operation_:
        case var_const_icmp_:
          add_use(instruction.operand_1_id_);
          add_def(instruction.result_id_);
          break;
        case const_var_binary_operation_:
        case const_var_icmp_:
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case conditional_br_:
          add_use(instruction.condition_id_, 8);
          break;
        case variable_ret_:
          add_use(instruction.result_id_, 8);
          break;
        case load_:
        case ptr_load_:
          add_use(instruction.pointer_, 12);
          add_def(instruction.result_id_);
          break;
        case variable_store_:
        case ptr_store_:
          add_use(instruction.result_id_);
          add_use(instruction.pointer_, 12);
          break;
        case value_store_:
        case builtin_memset_:
          add_use(instruction.pointer_, 12);
          break;
        case get_element_ptr_by_value_:
          add_use(instruction.pointer_, 12);
          add_def(instruction.result_id_, 6);
          break;
        case get_element_ptr_by_variable_:
          add_use(instruction.pointer_, 12);
          add_use(instruction.index_);
          add_def(instruction.result_id_, 6);
          break;
        case non_void_call_:
        case void_call_:
        case builtin_call_:
          for (const auto &argument : instruction.function_call_arguments_) {
            if (argument.is_variable_) {
              add_use(argument.value_, 8);
            }
          }
          if (instruction.instruction_type_ == non_void_call_ ||
              (instruction.instruction_type_ == builtin_call_ && instruction.function_name_ == 2)) {
            add_def(instruction.result_id_);
          }
          break;
        case value_select_ii_:
          add_use(instruction.operand_1_id_);
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case value_select_iv_:
          add_use(instruction.operand_1_id_);
          add_def(instruction.result_id_);
          break;
        case value_select_vi_:
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case value_select_vv_:
          add_def(instruction.result_id_);
          break;
        case variable_select_ii_:
          add_use(instruction.condition_id_, 8);
          add_use(instruction.operand_1_id_);
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case variable_select_iv_:
          add_use(instruction.condition_id_, 8);
          add_use(instruction.operand_1_id_);
          add_def(instruction.result_id_);
          break;
        case variable_select_vi_:
          add_use(instruction.condition_id_, 8);
          add_use(instruction.operand_2_id_);
          add_def(instruction.result_id_);
          break;
        case variable_select_vv_:
          add_use(instruction.condition_id_, 8);
          add_def(instruction.result_id_);
          break;
        case builtin_memcpy_:
          add_use(instruction.destination_, 12);
          add_use(instruction.pointer_, 12);
          break;
        default:
          break;
      }
    }
    for (const auto &mv_instruction : riscv_func.blocks_[block_id].move_instructions_) {
      add_score(mv_instruction.dest_, 4LL * weight);
      if (!mv_instruction.src_is_value_) {
        add_score(mv_instruction.src_, 4LL * weight);
      }
    }
  }

  std::map<int, std::set<int>> block_defs;
  std::map<int, std::set<int>> block_uses;
  std::map<int, std::set<int>> live_in;
  std::map<int, std::set<int>> live_out;
  auto record_use = [&](std::set<int> &defs, std::set<int> &uses, const int var_id) {
    if (var_id > 0 && !defs.contains(var_id)) {
      uses.insert(var_id);
    }
  };
  auto record_def = [&](std::set<int> &defs, const int var_id) {
    if (var_id > 0) {
      defs.insert(var_id);
    }
  };
  auto record_call_argument_uses = [&](std::set<int> &defs, std::set<int> &uses,
      const std::vector<FunctionCallArgument> &arguments) {
    for (const auto &argument : arguments) {
      if (argument.is_variable_) {
        record_use(defs, uses, argument.value_);
      }
    }
  };

  for (const auto &[block_id, block] : ir_func.blocks_) {
    std::set<int> defs;
    std::set<int> uses;
    for (const auto &instruction : block.instructions_) {
      switch (instruction.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_:
          record_use(defs, uses, instruction.operand_1_id_);
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case var_const_binary_operation_:
        case var_const_icmp_:
          record_use(defs, uses, instruction.operand_1_id_);
          record_def(defs, instruction.result_id_);
          break;
        case const_var_binary_operation_:
        case const_var_icmp_:
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case conditional_br_:
          record_use(defs, uses, instruction.condition_id_);
          break;
        case variable_ret_:
          record_use(defs, uses, instruction.result_id_);
          break;
        case load_:
        case ptr_load_:
          record_use(defs, uses, instruction.pointer_);
          record_def(defs, instruction.result_id_);
          break;
        case variable_store_:
        case ptr_store_:
          record_use(defs, uses, instruction.result_id_);
          record_use(defs, uses, instruction.pointer_);
          break;
        case value_store_:
        case builtin_memset_:
          record_use(defs, uses, instruction.pointer_);
          break;
        case get_element_ptr_by_value_:
          record_use(defs, uses, instruction.pointer_);
          record_def(defs, instruction.result_id_);
          break;
        case get_element_ptr_by_variable_:
          record_use(defs, uses, instruction.pointer_);
          record_use(defs, uses, instruction.index_);
          record_def(defs, instruction.result_id_);
          break;
        case non_void_call_:
          record_call_argument_uses(defs, uses, instruction.function_call_arguments_);
          record_def(defs, instruction.result_id_);
          break;
        case void_call_:
          record_call_argument_uses(defs, uses, instruction.function_call_arguments_);
          break;
        case builtin_call_:
          record_call_argument_uses(defs, uses, instruction.function_call_arguments_);
          if (instruction.function_name_ == 2) {
            record_def(defs, instruction.result_id_);
          }
          break;
        case value_select_ii_:
          record_use(defs, uses, instruction.operand_1_id_);
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case value_select_iv_:
          record_use(defs, uses, instruction.operand_1_id_);
          record_def(defs, instruction.result_id_);
          break;
        case value_select_vi_:
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case value_select_vv_:
          record_def(defs, instruction.result_id_);
          break;
        case variable_select_ii_:
          record_use(defs, uses, instruction.condition_id_);
          record_use(defs, uses, instruction.operand_1_id_);
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case variable_select_iv_:
          record_use(defs, uses, instruction.condition_id_);
          record_use(defs, uses, instruction.operand_1_id_);
          record_def(defs, instruction.result_id_);
          break;
        case variable_select_vi_:
          record_use(defs, uses, instruction.condition_id_);
          record_use(defs, uses, instruction.operand_2_id_);
          record_def(defs, instruction.result_id_);
          break;
        case variable_select_vv_:
          record_use(defs, uses, instruction.condition_id_);
          record_def(defs, instruction.result_id_);
          break;
        case builtin_memcpy_:
          record_use(defs, uses, instruction.destination_);
          record_use(defs, uses, instruction.pointer_);
          break;
        default:
          break;
      }
    }
    for (const auto &phi : block.phi_instructions_) {
      record_def(defs, phi.result_id);
      for (const auto &condition : phi.conditions) {
        if (!condition.is_const) {
          block_uses[condition.from_block_id].insert(condition.var_id);
        }
      }
    }
    block_uses[block_id].insert(uses.begin(), uses.end());
    block_defs[block_id] = std::move(defs);
    live_in[block_id] = {};
    live_out[block_id] = {};
  }

  std::queue<int> live_worklist;
  for (const auto &[block_id, block] : ir_func.blocks_) {
    live_worklist.push(block_id);
  }
  while (!live_worklist.empty()) {
    const int block_id = live_worklist.front();
    live_worklist.pop();
    std::set<int> new_live_out;
    for (int succ : successors[block_id]) {
      new_live_out.insert(live_in[succ].begin(), live_in[succ].end());
    }
    std::set<int> new_live_in = block_uses[block_id];
    for (int id : new_live_out) {
      if (!block_defs[block_id].contains(id)) {
        new_live_in.insert(id);
      }
    }
    if (new_live_in != live_in[block_id] || new_live_out != live_out[block_id]) {
      live_in[block_id] = std::move(new_live_in);
      live_out[block_id] = std::move(new_live_out);
      for (const auto &[pred, succs] : successors) {
        if (std::find(succs.begin(), succs.end(), block_id) != succs.end()) {
          live_worklist.push(pred);
        }
      }
    }
  }

  std::set<int> call_crossing_vars;
  for (const auto &[block_id, block] : ir_func.blocks_) {
    std::set<int> live = live_out[block_id];
    const auto move_it = riscv_func.blocks_.find(block_id);
    if (move_it != riscv_func.blocks_.end()) {
      for (const auto &mv : move_it->second.move_instructions_) {
        if (!mv.src_is_value_ && mv.src_ > 0) {
          live.insert(mv.src_);
        }
      }
    }
    const int weight = block_weight[block_id];
    for (int inst_index = static_cast<int>(block.instructions_.size()) - 1;
         inst_index >= 0; --inst_index) {
      const auto &instruction = block.instructions_[inst_index];
      if (instruction.instruction_type_ == non_void_call_ ||
          instruction.instruction_type_ == void_call_ ||
          instruction.instruction_type_ == builtin_call_ ||
          instruction.instruction_type_ == builtin_memset_ ||
          instruction.instruction_type_ == builtin_memcpy_) {
        for (int id : live) {
          if (id > 0) {
            call_crossing_vars.insert(id);
            add_score(id, 10LL * weight);
          }
        }
      }

      std::set<int> defs;
      std::set<int> uses;
      switch (instruction.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_:
          uses.insert(instruction.operand_1_id_);
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case var_const_binary_operation_:
        case var_const_icmp_:
          uses.insert(instruction.operand_1_id_);
          defs.insert(instruction.result_id_);
          break;
        case const_var_binary_operation_:
        case const_var_icmp_:
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case conditional_br_:
          uses.insert(instruction.condition_id_);
          break;
        case variable_ret_:
          uses.insert(instruction.result_id_);
          break;
        case load_:
        case ptr_load_:
          uses.insert(instruction.pointer_);
          defs.insert(instruction.result_id_);
          break;
        case variable_store_:
        case ptr_store_:
          uses.insert(instruction.result_id_);
          uses.insert(instruction.pointer_);
          break;
        case value_store_:
        case builtin_memset_:
          uses.insert(instruction.pointer_);
          break;
        case get_element_ptr_by_value_:
          uses.insert(instruction.pointer_);
          defs.insert(instruction.result_id_);
          break;
        case get_element_ptr_by_variable_:
          uses.insert(instruction.pointer_);
          uses.insert(instruction.index_);
          defs.insert(instruction.result_id_);
          break;
        case non_void_call_:
          for (const auto &arg : instruction.function_call_arguments_) {
            if (arg.is_variable_) uses.insert(arg.value_);
          }
          defs.insert(instruction.result_id_);
          break;
        case void_call_:
          for (const auto &arg : instruction.function_call_arguments_) {
            if (arg.is_variable_) uses.insert(arg.value_);
          }
          break;
        case builtin_call_:
          for (const auto &arg : instruction.function_call_arguments_) {
            if (arg.is_variable_) uses.insert(arg.value_);
          }
          if (instruction.function_name_ == 2) defs.insert(instruction.result_id_);
          break;
        case value_select_ii_:
          uses.insert(instruction.operand_1_id_);
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case value_select_iv_:
          uses.insert(instruction.operand_1_id_);
          defs.insert(instruction.result_id_);
          break;
        case value_select_vi_:
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case value_select_vv_:
          defs.insert(instruction.result_id_);
          break;
        case variable_select_ii_:
          uses.insert(instruction.condition_id_);
          uses.insert(instruction.operand_1_id_);
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case variable_select_iv_:
          uses.insert(instruction.condition_id_);
          uses.insert(instruction.operand_1_id_);
          defs.insert(instruction.result_id_);
          break;
        case variable_select_vi_:
          uses.insert(instruction.condition_id_);
          uses.insert(instruction.operand_2_id_);
          defs.insert(instruction.result_id_);
          break;
        case variable_select_vv_:
          uses.insert(instruction.condition_id_);
          defs.insert(instruction.result_id_);
          break;
        case builtin_memcpy_:
          uses.insert(instruction.destination_);
          uses.insert(instruction.pointer_);
          break;
        default:
          break;
      }
      for (int def : defs) live.erase(def);
      for (int use : uses) {
        if (use > 0) live.insert(use);
      }
    }
  }

  auto remember_stack_var = [&](int var_id, int size, int alignment, bool pointer_like) {
    const auto it = riscv_func.location_.find(var_id);
    if (it == riscv_func.location_.end() || it->second.first) return;
    auto existing = stack_slots.find(var_id);
    if (existing != stack_slots.end() && existing->second.is_alloca_pointer) return;
    stack_slots[var_id] = {size, alignment, false, pointer_like,
        call_crossing_vars.contains(var_id), hotness[var_id]};
  };

  auto remember_alloca = [&](int var_id, int data_size, int data_alignment) {
    const auto it = riscv_func.location_.find(var_id);
    if (it == riscv_func.location_.end() || it->second.first) return;
    stack_slots[var_id] = {8, 8, true, true, call_crossing_vars.contains(var_id),
        hotness[var_id] + 1000};
    payload_slots.push_back({var_id, data_size, data_alignment});
  };

  for (int i = 0; i < ir_func.parameter_types_.size(); ++i) {
    const auto size = GetSize(ir_func.parameter_types_[i]).first;
    remember_stack_var(i, size, GetAlignment(ir_func.parameter_types_[i]),
        ir_func.parameter_types_[i]->basic_type == pointer_type);
  }
  for (const auto &instruction : ir_func.alloca_instructions_) {
    const int data_size = GetSize(instruction.result_type_).first;
    remember_alloca(instruction.result_id_, data_size, GetAlignment(instruction.result_type_));
  }
  for (const auto &[block_id, block] : ir_func.blocks_) {
    for (const auto &instruction : block.instructions_) {
      switch (instruction.instruction_type_) {
        case two_var_binary_operation_:
        case var_const_binary_operation_:
        case const_var_binary_operation_:
        case load_:
        case non_void_call_:
        case value_select_ii_:
        case value_select_iv_:
        case value_select_vi_:
        case value_select_vv_:
        case variable_select_ii_:
        case variable_select_iv_:
        case variable_select_vi_:
        case variable_select_vv_: {
          const auto size = GetSize(instruction.result_type_).first;
          remember_stack_var(instruction.result_id_, size, GetAlignment(instruction.result_type_),
              instruction.result_type_->basic_type == pointer_type);
          break;
        }
        case builtin_call_: {
          if (instruction.function_name_ == 2) {
            const auto size = GetSize(instruction.result_type_).first;
            remember_stack_var(instruction.result_id_, size, GetAlignment(instruction.result_type_),
                instruction.result_type_->basic_type == pointer_type);
          }
          break;
        }
        case ptr_load_:
        case get_element_ptr_by_value_:
        case get_element_ptr_by_variable_: {
          remember_stack_var(instruction.result_id_, 8, 8, true);
          break;
        }
        case two_var_icmp_:
        case var_const_icmp_:
        case const_var_icmp_: {
          remember_stack_var(instruction.result_id_, 1, 1, false);
          break;
        }
        default:
          break;
      }
    }
    for (const auto &mv_instruction : riscv_func.blocks_[block_id].move_instructions_) {
      const auto size = GetSize(mv_instruction.type_).first;
      remember_stack_var(mv_instruction.dest_, size, GetAlignment(mv_instruction.type_),
          mv_instruction.type_->basic_type == pointer_type);
    }
  }

  int offset = is_leaf_[func_id] ? 0 : 128;
  alloca_data_offsets_[func_id].clear();
  bool has_stack_parameters = false;
  for (int i = 0; i < ir_func.parameter_types_.size(); ++i) {
    const auto loc_it = riscv_func.location_.find(i);
    if (loc_it != riscv_func.location_.end() && !loc_it->second.first) {
      has_stack_parameters = true;
      break;
    }
  }

  auto &save_offsets = reg_save_offsets_[func_id];
  save_offsets.clear();
  const int save_area_start = offset;
  for (int reg : used_caller_regs_[func_id]) {
    offset = AlignUp(offset, 8);
    save_offsets[reg] = offset;
    offset += 8;
  }
  for (int reg : used_callee_regs_[func_id]) {
    if (save_offsets.contains(reg)) continue;
    offset = AlignUp(offset, 8);
    save_offsets[reg] = offset;
    offset += 8;
  }
  const int save_area_size = offset - save_area_start;

  std::set<int> placed_slots;
  std::vector<int> slot_ids;
  slot_ids.reserve(stack_slots.size());
  for (const auto &[var_id, slot] : stack_slots) {
    slot_ids.push_back(var_id);
  }
  auto hotter_slot_first = [&](int lhs, int rhs) {
    const auto &left = stack_slots[lhs];
    const auto &right = stack_slots[rhs];
    if (left.used_around_call != right.used_around_call) {
      return left.used_around_call > right.used_around_call;
    }
    if (left.hotness != right.hotness) return left.hotness > right.hotness;
    if (left.size != right.size) return left.size < right.size;
    return lhs < rhs;
  };
  std::sort(slot_ids.begin(), slot_ids.end(), hotter_slot_first);

  auto place_stack_slot = [&](int var_id) {
    const auto &slot = stack_slots[var_id];
    offset = AlignUp(offset, slot.alignment);
    riscv_func.location_[var_id].second = offset;
    offset += slot.size;
    placed_slots.insert(var_id);
  };

  constexpr int kImmediateWindowEnd = 2048;
  auto try_place_hot_window = [&](auto predicate) {
    for (int var_id : slot_ids) {
      if (placed_slots.contains(var_id)) continue;
      const auto &slot = stack_slots[var_id];
      if (!predicate(slot)) continue;
      const int aligned_offset = AlignUp(offset, slot.alignment);
      if (aligned_offset + slot.size <= kImmediateWindowEnd) {
        place_stack_slot(var_id);
      }
    }
  };

  try_place_hot_window([](const StackSlot &slot) {
    return slot.is_alloca_pointer;
  });
  try_place_hot_window([](const StackSlot &slot) {
    return !slot.is_alloca_pointer && !slot.is_pointer_like && slot.size <= 8;
  });
  try_place_hot_window([](const StackSlot &slot) {
    return !slot.is_alloca_pointer && slot.is_pointer_like && slot.size <= 8;
  });
  try_place_hot_window([](const StackSlot &slot) {
    return !slot.is_alloca_pointer && slot.size <= 16;
  });

  for (int var_id : slot_ids) {
    if (!placed_slots.contains(var_id)) {
      place_stack_slot(var_id);
    }
  }

  for (const auto &payload : payload_slots) {
    offset = AlignUp(offset, payload.alignment);
    alloca_data_offsets_[func_id][payload.alloca_id] = offset;
    offset += payload.size;
  }

  if (has_stack_parameters) {
    offset += AlignUp(save_area_size, 16);
  }
  riscv_func.stack_space_ = AlignUp(offset, 16);
}

int CodeGenerator::RegSavedLocation(const int func_id, const int reg_id) const {
  const auto it = reg_save_offsets_[func_id].find(reg_id);
  if (it == reg_save_offsets_[func_id].end()) {
    CodegenThrow("Register has no saving space in the stack.");
  }
  return it->second;
}

// Temp save area at sp+[0..127] for protecting outer save during nested call setup.
// Maps caller-saved register to a slot in this 128-byte area (16 regs × 8 bytes).
static int TempCallerSaveSlot(int reg_id) {
  static const int order[] = {1,5,6,7,10,11,12,13,14,15,16,17,28,29,30,31};
  for (int i = 0; i < 16; ++i)
    if (order[i] == reg_id) return i * 8;
  return -1;
}

void CodeGenerator::VariableAssignment(const int func_id, RISCVBlock &r_block, const int var_dest,
    const int var_src, const std::shared_ptr<IntegratedType> &type,
    const std::set<int> *live_caller_regs) {
  const auto [dest_in_reg, dest_location] = RISCV_functions_[func_id].location_[var_dest];
  const auto [src_in_reg, src_location] = RISCV_functions_[func_id].location_[var_src];
  if (dest_in_reg && src_in_reg && dest_location == src_location) {
    return;
  }
  auto [type_size, need_alignment] = GetSize(type);
  // Alloca result vars store a pointer (8 bytes), not the element type size
  if (alloca_var_ids_[func_id].count(var_src)) type_size = 8;
  if (alloca_var_ids_[func_id].count(var_dest)) type_size = 8;
  if (type_size == 1) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_lbu_, 5, src_location, 2);
      src_data_reg = 5;
    } else if (registers_saved_[func_id] && IsCallerSavedReg(src_location)) {
      r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(func_id, src_location), 2);
      r_block.PushArithmetic_I(r_andi_, 5, 5, 0xff);  // extract low byte
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
      if (registers_saved_[func_id] && IsCallerSavedReg(dest_location)) {
        r_block.PushMemory_S(r_sd_, dest_location, RegSavedLocation(func_id, dest_location), 2);
      }
    } else {
      r_block.PushMemory_S(r_sb_, src_data_reg, dest_location, 2);
    }
  } else if (type_size == 4 && need_alignment) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_lw_, 5, src_location, 2);
      src_data_reg = 5;
    } else if (registers_saved_[func_id] && IsCallerSavedReg(src_location)) {
      r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(func_id, src_location), 2);
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
      if (registers_saved_[func_id] && IsCallerSavedReg(dest_location)) {
        r_block.PushMemory_S(r_sd_, dest_location, RegSavedLocation(func_id, dest_location), 2);
      }
    } else {
      r_block.PushMemory_S(CodeGenerator::GetStoreInst(type), src_data_reg, dest_location, 2);
    }
  } else if (type_size == 8) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_ld_, 5, src_location, 2);
      src_data_reg = 5;
    } else if (registers_saved_[func_id] && IsCallerSavedReg(src_location)) {
      r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(func_id, src_location), 2);
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
      if (registers_saved_[func_id] && IsCallerSavedReg(dest_location)) {
        r_block.PushMemory_S(r_sd_, dest_location, RegSavedLocation(func_id, dest_location), 2);
      }
    } else {
      r_block.PushMemory_S(r_sd_, src_data_reg, dest_location, 2);
    }
  } else {
    if (src_in_reg || dest_in_reg) {
      CodegenThrow("Unexpected type in the register!");
    }
    std::set<int> regs_to_save = live_caller_regs ? *live_caller_regs : used_caller_regs_[func_id];
    regs_to_save.insert(1);
    SaveCallerRegs(func_id, r_block, regs_to_save);
    r_block.PushArithmetic_I(r_addi_, 11, 2, src_location);
    r_block.PushArithmetic_I(r_addi_, 10, 2, dest_location);
    r_block.PushLi(12, type_size);
    r_block.PushCall(true, 7);
    RestoreCallerRegs(func_id, r_block, regs_to_save);
  }
}
void CodeGenerator::ValueAssignment(const int func_id, RISCVBlock &r_block, const int var_dest,
    const int value_src, const std::shared_ptr<IntegratedType> &type) {
  if (type->is_int) {
    if (RISCV_functions_[func_id].location_[var_dest].first) {
      const int dest_reg = RISCV_functions_[func_id].location_[var_dest].second;
      r_block.PushLi(dest_reg, value_src);
      if (registers_saved_[func_id] && IsCallerSavedReg(dest_reg)) {
        r_block.PushMemory_S(r_sd_, dest_reg, RegSavedLocation(func_id, dest_reg), 2);
      }
    } else {
      r_block.PushLi(5, value_src);
      if (type->basic_type == pointer_type) {
        r_block.PushMemory_S(r_sd_, 5, RISCV_functions_[func_id].location_[var_dest].second, 2);
      } else {
        r_block.PushMemory_S(r_sw_, 5, RISCV_functions_[func_id].location_[var_dest].second, 2);
      }
    }
  } else if (type->basic_type == bool_type) {
    if (RISCV_functions_[func_id].location_[var_dest].first) {
      const int dest_reg = RISCV_functions_[func_id].location_[var_dest].second;
      r_block.PushLi(dest_reg, value_src);
      if (registers_saved_[func_id] && IsCallerSavedReg(dest_reg)) {
        r_block.PushMemory_S(r_sd_, dest_reg, RegSavedLocation(func_id, dest_reg), 2);
      }
    } else {
      r_block.PushLi(5, value_src);
      r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[func_id].location_[var_dest].second, 2);
    }
  } else {
    CodegenThrow("Invalid type to be selected as an invariable.");
  }
}

void CodeGenerator::AnalyzeUsedRegisters() {
  used_callee_regs_.resize(IR_functions_.size());
  used_caller_regs_.resize(IR_functions_.size());
  for (int i = 0; i < IR_functions_.size(); ++i) {
    for (const auto &[var_id, loc] : RISCV_functions_[i].location_) {
      if (loc.first) {  // variable is in a register
        const int reg = loc.second;
        const auto it = register_saver.find(reg);
        if (it != register_saver.end()) {
          if (it->second == callee_save) {
            used_callee_regs_[i].insert(reg);
          } else if (it->second == caller_save) {
            used_caller_regs_[i].insert(reg);
          }
        }
      }
    }
    // x1 (ra) is always live across calls — the `call` instruction overwrites it.
    // It is not allocatable so it will never appear in location_.  Add it unconditionally.
    used_caller_regs_[i].insert(1);
  }
}

void CodeGenerator::SaveCallerRegs(int func_id, RISCVBlock &r_block) {
  SaveCallerRegs(func_id, r_block, used_caller_regs_[func_id]);
}

void CodeGenerator::SaveCallerRegs(int func_id, RISCVBlock &r_block, const std::set<int> &regs) {
  for (int reg : regs) {
    if (!used_caller_regs_[func_id].contains(reg)) continue;
    r_block.PushMemory_S(r_sd_, reg, RegSavedLocation(func_id, reg), 2);
  }
}

void CodeGenerator::RestoreCallerRegs(int func_id, RISCVBlock &r_block, int exclude_reg) {
  RestoreCallerRegs(func_id, r_block, used_caller_regs_[func_id], exclude_reg);
}

void CodeGenerator::RestoreCallerRegs(int func_id, RISCVBlock &r_block, const std::set<int> &regs,
    int exclude_reg) {
  for (int reg : regs) {
    if (reg == exclude_reg) continue;
    if (!used_caller_regs_[func_id].contains(reg)) continue;
    r_block.PushMemory_I(r_ld_, reg, RegSavedLocation(func_id, reg), 2);
  }
}

void CodeGenerator::FlushSavedRegisters(int func_id, RISCVBlock &r_block) {
  if (!registers_saved_[func_id]) return;
  for (int reg : used_caller_regs_[func_id]) {
    r_block.PushMemory_I(r_ld_, reg, RegSavedLocation(func_id, reg), 2);
  }
  registers_saved_[func_id] = false;
}

static bool InstructionUsesReg(const RISCVInstruction &inst, int reg) {
  switch (inst.instruction_type_) {
    case r_add_: case r_sub_: case r_and_: case r_or_: case r_xor_:
    case r_sll_: case r_srl_: case r_sra_: case r_slt_: case r_sltu_:
    case r_addw_: case r_subw_: case r_sllw_: case r_srlw_: case r_sraw_:
    case r_mul_: case r_div_: case r_divu_: case r_rem_: case r_remu_:
    case r_mulw_: case r_divw_: case r_divuw_: case r_remw_: case r_remuw_:
      return inst.rs1_ == reg || inst.rs2_ == reg;
    case r_addi_: case r_andi_: case r_ori_: case r_xori_:
    case r_slli_: case r_srli_: case r_srai_: case r_slti_: case r_sltiu_:
    case r_addiw_: case r_slliw_: case r_srliw_: case r_sraiw_:
    case r_jalr_: case r_jr_: case r_mv_: case r_neg_: case r_not_:
    case r_lb_: case r_lbu_: case r_lh_: case r_lhu_: case r_lw_: case r_ld_:
      return inst.rs1_ == reg;
    case r_sb_: case r_sh_: case r_sw_: case r_sd_:
      return inst.rs1_ == reg || inst.rs2_ == reg;
    case r_beq_: case r_bge_: case r_bgeu_: case r_blt_: case r_bltu_: case r_bne_:
      return inst.rs1_ == reg || inst.rs2_ == reg;
    case r_beqz_: case r_bnez_:
      return inst.rs1_ == reg;
    default:
      return false;
  }
}

static bool InstructionDefsReg(const RISCVInstruction &inst, int reg) {
  switch (inst.instruction_type_) {
    case r_add_: case r_sub_: case r_and_: case r_or_: case r_xor_:
    case r_sll_: case r_srl_: case r_sra_: case r_slt_: case r_sltu_:
    case r_addi_: case r_andi_: case r_ori_: case r_xori_:
    case r_slli_: case r_srli_: case r_srai_: case r_slti_: case r_sltiu_:
    case r_lb_: case r_lbu_: case r_lh_: case r_lhu_: case r_lw_:
    case r_jal_: case r_jalr_: case r_auipc_: case r_lui_: case r_la_:
    case r_li_: case r_mv_: case r_neg_: case r_not_:
    case r_addw_: case r_subw_: case r_addiw_:
    case r_sllw_: case r_srlw_: case r_sraw_:
    case r_slliw_: case r_srliw_: case r_sraiw_:
    case r_mul_: case r_div_: case r_divu_: case r_rem_: case r_remu_:
    case r_mulw_: case r_divw_: case r_divuw_: case r_remw_: case r_remuw_:
    case r_ld_:
      return inst.rd_ == reg;
    case r_call_:
      return reg == 1 || (reg >= 5 && reg <= 7) ||
          (reg >= 10 && reg <= 17) || (reg >= 28 && reg <= 31);
    default:
      return false;
  }
}

static bool RegisterUsedBeforeDef(const std::vector<RISCVInstruction> &instructions,
    const int begin, const int reg) {
  for (int i = begin; i < static_cast<int>(instructions.size()); ++i) {
    const auto &inst = instructions[i];
    if (InstructionUsesReg(inst, reg)) {
      return true;
    }
    if (InstructionDefsReg(inst, reg)) {
      return false;
    }
    if (inst.instruction_type_ == r_j_ || inst.instruction_type_ == r_ret_ ||
        inst.instruction_type_ == r_beq_ || inst.instruction_type_ == r_bge_ ||
        inst.instruction_type_ == r_bgeu_ || inst.instruction_type_ == r_blt_ ||
        inst.instruction_type_ == r_bltu_ || inst.instruction_type_ == r_bne_ ||
        inst.instruction_type_ == r_beqz_ || inst.instruction_type_ == r_bnez_) {
      return false;
    }
  }
  return false;
}

static std::uint32_t RegisterMask(const int reg) {
  return reg >= 0 && reg < 32 ? (1u << reg) : 0;
}

static std::uint32_t ToRegisterMask(const std::set<int> &regs) {
  std::uint32_t result = 0;
  for (int reg : regs) {
    result |= RegisterMask(reg);
  }
  return result;
}

struct RegUseDefMasks {
  std::uint32_t uses = 0;
  std::uint32_t defs = 0;
};

static RegUseDefMasks InstructionRegUseDefMasks(const RISCVInstruction &inst) {
  RegUseDefMasks result;
  switch (inst.instruction_type_) {
    case r_add_: case r_sub_: case r_and_: case r_or_: case r_xor_:
    case r_sll_: case r_srl_: case r_sra_: case r_slt_: case r_sltu_:
    case r_addw_: case r_subw_: case r_sllw_: case r_srlw_: case r_sraw_:
    case r_mul_: case r_div_: case r_divu_: case r_rem_: case r_remu_:
    case r_mulw_: case r_divw_: case r_divuw_: case r_remw_: case r_remuw_:
      result.uses = RegisterMask(inst.rs1_) | RegisterMask(inst.rs2_);
      result.defs = RegisterMask(inst.rd_);
      break;
    case r_addi_: case r_andi_: case r_ori_: case r_xori_:
    case r_slli_: case r_srli_: case r_srai_: case r_slti_: case r_sltiu_:
    case r_addiw_: case r_slliw_: case r_srliw_: case r_sraiw_:
    case r_jalr_: case r_mv_: case r_neg_: case r_not_:
    case r_lb_: case r_lbu_: case r_lh_: case r_lhu_: case r_lw_: case r_ld_:
      result.uses = RegisterMask(inst.rs1_);
      result.defs = RegisterMask(inst.rd_);
      break;
    case r_jr_:
      result.uses = RegisterMask(inst.rs1_);
      break;
    case r_sb_: case r_sh_: case r_sw_: case r_sd_:
      result.uses = RegisterMask(inst.rs1_) | RegisterMask(inst.rs2_);
      break;
    case r_beq_: case r_bge_: case r_bgeu_: case r_blt_: case r_bltu_: case r_bne_:
      result.uses = RegisterMask(inst.rs1_) | RegisterMask(inst.rs2_);
      break;
    case r_beqz_: case r_bnez_:
      result.uses = RegisterMask(inst.rs1_);
      break;
    case r_jal_: case r_auipc_: case r_lui_: case r_la_: case r_li_:
      result.defs = RegisterMask(inst.rd_);
      break;
    case r_call_:
      result.defs = RegisterMask(1) | RegisterMask(5) | RegisterMask(6) |
          RegisterMask(7) | RegisterMask(10) | RegisterMask(11) |
          RegisterMask(12) | RegisterMask(13) | RegisterMask(14) |
          RegisterMask(15) | RegisterMask(16) | RegisterMask(17) |
          RegisterMask(28) | RegisterMask(29) | RegisterMask(30) |
          RegisterMask(31);
      break;
    default:
      break;
  }
  return result;
}

static std::vector<RegUseDefMasks> ComputeRegUseDefMasks(
    const std::vector<RISCVInstruction> &instructions) {
  std::vector<RegUseDefMasks> result;
  result.reserve(instructions.size());
  for (const auto &inst : instructions) {
    result.push_back(InstructionRegUseDefMasks(inst));
  }
  return result;
}

static std::vector<std::uint32_t> ComputeRegNeededBeforeDefMasks(
    const std::vector<RISCVInstruction> &instructions,
    const std::vector<RegUseDefMasks> &reg_masks,
    const std::set<int> &live_out_regs) {
  const std::uint32_t live_out_mask = ToRegisterMask(live_out_regs);
  std::vector<std::uint32_t> needed(instructions.size() + 1, 0);
  needed[instructions.size()] = live_out_mask;

  for (int i = static_cast<int>(instructions.size()) - 1; i >= 0; --i) {
    const auto &inst = instructions[i];
    if (inst.instruction_type_ == r_j_ || inst.instruction_type_ == r_ret_ ||
        IsDirectLabelBranch(inst)) {
      needed[i] = reg_masks[i].uses | live_out_mask;
    } else {
      needed[i] = (needed[i + 1] & ~reg_masks[i].defs) | reg_masks[i].uses;
    }
  }
  return needed;
}

static bool HasRestoreSavePeepholeCandidates(
    const std::vector<RISCVInstruction> &instructions) {
  bool has_restore_load = false;
  bool has_stack_store = false;
  for (const auto &inst : instructions) {
    if (inst.instruction_type_ == r_ld_ && inst.rs1_ == 2 &&
        IsCallerSavedReg(inst.rd_)) {
      has_restore_load = true;
    } else if (inst.instruction_type_ == r_sd_ && inst.rs1_ == 2) {
      has_stack_store = true;
    }
    if (has_restore_load && has_stack_store) {
      return true;
    }
  }
  return false;
}

static void CollectIRDefUse(const IRInstruction &inst, std::set<int> &defs, std::set<int> &uses) {
  auto add_def = [&](int id) {
    if (id > 0) defs.insert(id);
  };
  auto add_use = [&](int id) {
    if (id >= 0) uses.insert(id);
  };

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
    case ptr_store_:
      add_use(inst.result_id_);
      add_use(inst.pointer_);
      break;
    case value_store_:
      add_use(inst.pointer_);
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
    case non_void_call_:
      for (const auto &arg : inst.function_call_arguments_) {
        if (arg.is_variable_) add_use(arg.value_);
      }
      add_def(inst.result_id_);
      break;
    case void_call_:
      for (const auto &arg : inst.function_call_arguments_) {
        if (arg.is_variable_) add_use(arg.value_);
      }
      break;
    case builtin_call_:
      for (const auto &arg : inst.function_call_arguments_) {
        if (arg.is_variable_) add_use(arg.value_);
      }
      if (inst.function_name_ == 2) add_def(inst.result_id_);
      break;
    case value_select_ii_:
      add_use(inst.operand_1_id_);
      add_use(inst.operand_2_id_);
      add_def(inst.result_id_);
      break;
    case value_select_iv_:
      add_use(inst.operand_1_id_);
      add_def(inst.result_id_);
      break;
    case value_select_vi_:
      add_use(inst.operand_2_id_);
      add_def(inst.result_id_);
      break;
    case value_select_vv_:
      add_def(inst.result_id_);
      break;
    case variable_select_ii_:
      add_use(inst.condition_id_);
      add_use(inst.operand_1_id_);
      add_use(inst.operand_2_id_);
      add_def(inst.result_id_);
      break;
    case variable_select_vv_:
      add_use(inst.condition_id_);
      add_def(inst.result_id_);
      break;
    case variable_select_iv_:
      add_use(inst.condition_id_);
      add_use(inst.operand_1_id_);
      add_def(inst.result_id_);
      break;
    case variable_select_vi_:
      add_use(inst.condition_id_);
      add_use(inst.operand_2_id_);
      add_def(inst.result_id_);
      break;
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

static void AddIRUseCount(std::map<int, int> &use_count, const int id) {
  if (id > 0) {
    ++use_count[id];
  }
}

static std::map<int, int> CountIRVariableUses(const IRFunctionNode &function) {
  std::map<int, int> use_count;
  for (const auto &[block_id, block] : function.blocks_) {
    for (const auto &phi : block.phi_instructions_) {
      for (const auto &condition : phi.conditions) {
        if (!condition.is_const) {
          AddIRUseCount(use_count, condition.var_id);
        }
      }
    }
    for (const auto &inst : block.instructions_) {
      std::set<int> defs;
      std::set<int> uses;
      CollectIRDefUse(inst, defs, uses);
      for (int use : uses) {
        AddIRUseCount(use_count, use);
      }
    }
  }
  return use_count;
}

static std::map<int, IRInstruction> FindDirectBranchIcmps(const IRFunctionNode &function) {
  std::map<int, IRInstruction> result;
  const auto use_count = CountIRVariableUses(function);
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

void CodeGenerator::PeepholeOptimizeBlock(RISCVBlock &r_block,
    const std::set<int> &live_out_regs) const {
  std::vector<RISCVInstruction> optimized;
  optimized.reserve(r_block.instructions_.size());
  std::vector<char> removed_indices(r_block.instructions_.size(), 0);

  if (HasRestoreSavePeepholeCandidates(r_block.instructions_)) {
    const auto reg_masks = ComputeRegUseDefMasks(r_block.instructions_);
    const auto reg_needed_before_def =
        ComputeRegNeededBeforeDefMasks(r_block.instructions_, reg_masks, live_out_regs);

    std::vector<int> pending_restore_offset(32, 0);
    std::vector<int> pending_restore_index(32, -1);
    std::uint32_t pending_mask = 0;
    auto clear_pending_mask = [&](std::uint32_t mask) {
      mask &= pending_mask;
      const std::uint32_t clear_mask = mask;
      while (mask != 0) {
        const int reg = __builtin_ctz(mask);
        pending_restore_index[reg] = -1;
        mask &= mask - 1;
      }
      pending_mask &= ~clear_mask;
    };
    auto clear_pending_offset = [&](const int offset) {
      std::uint32_t clear_mask = 0;
      std::uint32_t scan_mask = pending_mask;
      while (scan_mask != 0) {
        const int reg = __builtin_ctz(scan_mask);
        if (pending_restore_offset[reg] == offset) {
          clear_mask |= RegisterMask(reg);
        }
        scan_mask &= scan_mask - 1;
      }
      pending_mask &= ~clear_mask;
    };

    for (int i = 0; i < static_cast<int>(r_block.instructions_.size()); ++i) {
      const auto &inst = r_block.instructions_[i];
      if (inst.instruction_type_ == r_call_ || inst.instruction_type_ == r_j_ ||
          inst.instruction_type_ == r_ret_ || IsDirectLabelBranch(inst)) {
        pending_mask = 0;
        continue;
      }

      if (inst.instruction_type_ == r_sd_ && inst.rs1_ == 2) {
        const int reg = inst.rs2_;
        const std::uint32_t reg_mask = RegisterMask(reg);
        if ((pending_mask & reg_mask) != 0 && pending_restore_offset[reg] == inst.imm_ &&
            (reg_needed_before_def[i + 1] & reg_mask) == 0) {
          removed_indices[pending_restore_index[reg]] = 1;
          removed_indices[i] = 1;
        }
        clear_pending_offset(inst.imm_);
        clear_pending_mask(reg_masks[i].uses | reg_masks[i].defs);
        continue;
      }

      if (inst.instruction_type_ == r_ld_ && inst.rs1_ == 2) {
        clear_pending_offset(inst.imm_);
        clear_pending_mask(reg_masks[i].uses | reg_masks[i].defs);
        if (IsCallerSavedReg(inst.rd_)) {
          pending_restore_offset[inst.rd_] = inst.imm_;
          pending_restore_index[inst.rd_] = i;
          pending_mask |= RegisterMask(inst.rd_);
        }
        continue;
      }

      clear_pending_mask(reg_masks[i].uses | reg_masks[i].defs);
    }
  }

  auto emit = [&](RISCVInstruction inst) {
    if (inst.instruction_type_ == r_add_ && inst.rs2_ == 0) {
      inst.instruction_type_ = r_mv_;
      inst.rs2_ = -1;
    } else if (inst.instruction_type_ == r_add_ && inst.rs1_ == 0) {
      inst.instruction_type_ = r_mv_;
      inst.rs1_ = inst.rs2_;
      inst.rs2_ = -1;
    } else if (inst.instruction_type_ == r_addi_ && inst.imm_ == 0) {
      inst.instruction_type_ = r_mv_;
      inst.imm_ = -1;
    }
    if (inst.instruction_type_ == r_mv_ && inst.rd_ == inst.rs1_) {
      return;
    }
    optimized.push_back(inst);
  };

  for (int i = 0; i < r_block.instructions_.size(); ++i) {
    if (removed_indices[i]) {
      continue;
    }
    RISCVInstruction inst = r_block.instructions_[i];

    if (inst.instruction_type_ == r_li_ &&
        i + 1 < static_cast<int>(r_block.instructions_.size())) {
      const RISCVInstruction &next = r_block.instructions_[i + 1];
      if (next.instruction_type_ == r_add_) {
        int other_reg = -1;
        if (next.rs1_ == inst.rd_ && next.rs2_ != inst.rd_) {
          other_reg = next.rs2_;
        } else if (next.rs2_ == inst.rd_ && next.rs1_ != inst.rd_) {
          other_reg = next.rs1_;
        }
        if (other_reg != -1 && inst.imm_ >= -2048 && inst.imm_ <= 2047 &&
            (next.rd_ == inst.rd_ ||
             !RegisterUsedBeforeDef(r_block.instructions_, i + 2, inst.rd_))) {
          emit(RISCVInstruction(r_addi_, next.rd_, other_reg, -1, inst.imm_, -1));
          ++i;
          continue;
        }
      }
    }

    if (inst.instruction_type_ == r_addiw_ &&
        i + 1 < static_cast<int>(r_block.instructions_.size())) {
      const RISCVInstruction &next = r_block.instructions_[i + 1];
      if ((next.instruction_type_ == r_add_ && next.rs1_ == inst.rd_ && next.rs2_ == 0) ||
          next.instruction_type_ == r_mv_) {
        const bool is_move_back =
            next.rd_ == inst.rs1_ &&
            ((next.instruction_type_ == r_add_ && next.rs1_ == inst.rd_ && next.rs2_ == 0) ||
             (next.instruction_type_ == r_mv_ && next.rs1_ == inst.rd_));
        bool tmp_dead = !live_out_regs.contains(inst.rd_);
        if (is_move_back) {
          for (int j = i + 2; j < r_block.instructions_.size(); ++j) {
            const RISCVInstruction &later = r_block.instructions_[j];
            if (InstructionUsesReg(later, inst.rd_)) {
              tmp_dead = false;
              break;
            }
            if (InstructionDefsReg(later, inst.rd_)) {
              break;
            }
          }
        }
        if (is_move_back && tmp_dead) {
          inst.rd_ = inst.rs1_;
          emit(inst);
          ++i;
          continue;
        }
      }
    }

    emit(inst);
  }

  r_block.instructions_ = std::move(optimized);
}

void CodeGenerator::SaveCallerRegsToTemp(int func_id, RISCVBlock &r_block) {
  for (int reg : used_caller_regs_[func_id]) {
    r_block.PushMemory_I(r_ld_, 31, RegSavedLocation(func_id, reg), 2);
    r_block.PushMemory_S(r_sd_, 31, TempCallerSaveSlot(reg), 2);
  }
}

void CodeGenerator::RestoreCallerRegsFromTemp(int func_id, RISCVBlock &r_block) {
  for (int reg : used_caller_regs_[func_id]) {
    r_block.PushMemory_I(r_ld_, 31, TempCallerSaveSlot(reg), 2);
    r_block.PushMemory_S(r_sd_, 31, RegSavedLocation(func_id, reg), 2);
  }
}

void CodeGenerator::SaveCalleeRegs(int func_id, RISCVBlock &r_block) {
  for (int reg : used_callee_regs_[func_id]) {
    r_block.PushMemory_S(r_sd_, reg, RegSavedLocation(func_id, reg), 2);
  }
}

void CodeGenerator::RestoreCalleeRegs(int func_id, RISCVBlock &r_block) {
  for (int reg : used_callee_regs_[func_id]) {
    r_block.PushMemory_I(r_ld_, reg, RegSavedLocation(func_id, reg), 2);
  }
}

void CodeGenerator::RelaxFarBranches(const int func_id) {
  auto &riscv_func = RISCV_functions_[func_id];

  std::map<int, int> next_block_map;
  {
    int prev_id = -1;
    for (const int block_id : block_layouts_[func_id]) {
      if (prev_id != -1) {
        next_block_map[prev_id] = block_id;
      }
      prev_id = block_id;
    }
  }

  constexpr int kBranchRange = 4096;
  bool changed = true;
  while (changed) {
    changed = false;

    std::map<int, int> block_start;
    int pc = ConservativeBlockBytes(riscv_func.alloca_block_);
    for (const int block_id : block_layouts_[func_id]) {
      block_start[block_id] = pc;
      pc += ConservativeBlockBytes(riscv_func.blocks_.at(block_id));
    }

    for (const int block_id : block_layouts_[func_id]) {
      auto &block = riscv_func.blocks_[block_id];
      int offset = 0;
      for (int inst_index = 0; inst_index < static_cast<int>(block.instructions_.size()); ++inst_index) {
        auto &inst = block.instructions_[inst_index];
        if (!IsDirectLabelBranch(inst)) {
          offset += ConservativeInstructionBytes(inst);
          continue;
        }

        const int target = inst.label_;
        const int branch_pc = block_start[block_id] + offset;
        const int target_pc = block_start.contains(target) ? block_start[target] : branch_pc;
        const int distance = target_pc - branch_pc;
        if (distance >= -kBranchRange && distance <= kBranchRange - 2) {
          offset += ConservativeInstructionBytes(inst);
          continue;
        }

        const int long_target = inst.label_;
        inst.label_ = static_cast<int>(block.jump_blocks_.size());
        inst.imm_ = -1;

        if (inst.instruction_type_ == r_beqz_) {
          inst.instruction_type_ = r_beq_;
          inst.rs2_ = 0;
        } else if (inst.instruction_type_ == r_bnez_) {
          inst.instruction_type_ = r_bne_;
          inst.rs2_ = 0;
        }

        const bool has_existing_skip =
            inst_index + 1 < static_cast<int>(block.instructions_.size()) &&
            IsUnconditionalJump(block.instructions_[inst_index + 1]);
        if (!has_existing_skip) {
          const auto next_it = next_block_map.find(block_id);
          if (next_it == next_block_map.end()) {
            CodegenThrow("Cannot relax far branch without a fall-through target.");
          }
          block.instructions_.insert(block.instructions_.begin() + inst_index + 1,
              RISCVInstruction(r_j_, -1, -1, -1, -1, next_it->second));
        }

        block.jump_blocks_.push_back(
            RISCVInstruction(r_j_, -1, -1, -1, -1, long_target));
        changed = true;
        break;
      }
      if (changed) break;
    }
  }
}

void CodeGenerator::Generate() {
  RISCV_functions_.resize(IR_functions_.size());
  alloca_var_ids_.resize(IR_functions_.size());
  alloca_data_offsets_.resize(IR_functions_.size());
  block_layouts_.resize(IR_functions_.size());
  for (int i = 0; i < IR_functions_.size(); ++i) {
    block_layouts_[i] = ComputeBlockLayout(IR_functions_[i]);
  }
  PhiToMove();

  // Detect leaf functions (no calls — builtin or user) before MemAlloc
  // so the stack frame can be sized accordingly.
  is_leaf_.resize(IR_functions_.size(), true);
  for (int i = 0; i < IR_functions_.size(); ++i) {
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      for (const auto &inst : block.instructions_) {
        if (inst.instruction_type_ == non_void_call_ ||
            inst.instruction_type_ == void_call_ ||
            inst.instruction_type_ == builtin_call_) {
          is_leaf_[i] = false;
          break;
        }
      }
      if (!is_leaf_[i]) break;
    }
  }

  for (int i = 0; i < IR_functions_.size(); ++i) {
    MemAlloc(i);
  }
  // Register allocation: promote scalars from stack to registers.
  for (int i = 0; i < IR_functions_.size(); ++i) {
    RegisterAllocator reg_alloc(IR_functions_[i], RISCV_functions_[i], is_leaf_[i]);
    reg_alloc.Run();
  }
  // Determine which registers actually hold variables after RA.
  AnalyzeUsedRegisters();
  reg_save_offsets_.resize(IR_functions_.size());
  for (int i = 0; i < IR_functions_.size(); ++i) {
    CompactStackFrame(i);
  }
  registers_saved_.assign(IR_functions_.size(), false);
  for (int i = 0; i < IR_functions_.size(); ++i) {
    const auto direct_branch_icmps = FindDirectBranchIcmps(IR_functions_[i]);
    std::map<int, std::set<int>> block_defs;
    std::map<int, std::set<int>> block_uses;
    std::map<int, std::set<int>> live_in_vars;
    std::map<int, std::set<int>> live_out_vars;
    std::map<int, std::vector<int>> successors;
    std::map<int, std::vector<int>> predecessors;
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      std::set<int> defs;
      std::set<int> uses;
      for (int inst_index = 0; inst_index < static_cast<int>(block.instructions_.size()); ++inst_index) {
        const auto &instruction = block.instructions_[inst_index];
        std::set<int> inst_defs;
        std::set<int> inst_uses;
        CollectIRDefUse(instruction, inst_defs, inst_uses);
        for (int use : inst_uses) {
          if (!defs.contains(use)) uses.insert(use);
        }
        for (int def : inst_defs) {
          defs.insert(def);
        }
      }
      for (const auto &phi : block.phi_instructions_) {
        defs.insert(phi.result_id);
        for (const auto &condition : phi.conditions) {
          if (!condition.is_const) {
            block_uses[condition.from_block_id].insert(condition.var_id);
          }
        }
      }
      for (int use : uses) {
        block_uses[block_id].insert(use);
      }
      block_defs[block_id] = std::move(defs);
      live_in_vars[block_id] = {};
      live_out_vars[block_id] = {};

      if (!block.instructions_.empty()) {
        const auto &last = block.instructions_.back();
        if (last.instruction_type_ == conditional_br_) {
          successors[block_id].push_back(last.if_true_);
          successors[block_id].push_back(last.if_false_);
          predecessors[last.if_true_].push_back(block_id);
          predecessors[last.if_false_].push_back(block_id);
        } else if (last.instruction_type_ == unconditional_br_) {
          successors[block_id].push_back(last.destination_);
          predecessors[last.destination_].push_back(block_id);
        }
      }
    }
    std::queue<int> live_worklist;
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      live_worklist.push(block_id);
    }
    while (!live_worklist.empty()) {
      const int block_id = live_worklist.front();
      live_worklist.pop();
      std::set<int> new_live_out;
      for (int succ : successors[block_id]) {
        new_live_out.insert(live_in_vars[succ].begin(), live_in_vars[succ].end());
      }
      std::set<int> new_live_in = block_uses[block_id];
      for (int id : new_live_out) {
        if (!block_defs[block_id].contains(id)) {
          new_live_in.insert(id);
        }
      }
      if (new_live_in != live_in_vars[block_id] ||
          new_live_out != live_out_vars[block_id]) {
        live_in_vars[block_id] = std::move(new_live_in);
        live_out_vars[block_id] = std::move(new_live_out);
        for (int pred : predecessors[block_id]) {
          live_worklist.push(pred);
        }
      }
    }
    std::map<int, std::set<int>> live_out_regs;
    for (const auto &[block_id, vars] : live_out_vars) {
      for (int var : vars) {
        const auto it = RISCV_functions_[i].location_.find(var);
        if (it != RISCV_functions_[i].location_.end() && it->second.first) {
          live_out_regs[block_id].insert(it->second.second);
        }
      }
    }

    auto vars_to_caller_regs = [&](const std::set<int> &vars) {
      std::set<int> regs;
      for (int var : vars) {
        const auto it = RISCV_functions_[i].location_.find(var);
        if (it != RISCV_functions_[i].location_.end() && it->second.first &&
            IsCallerSavedReg(it->second.second)) {
          regs.insert(it->second.second);
        }
      }
      return regs;
    };

    std::map<int, std::vector<std::set<int>>> live_after_caller_regs;
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      std::set<int> live = live_out_vars[block_id];
      const auto move_it = RISCV_functions_[i].blocks_.find(block_id);
      if (move_it != RISCV_functions_[i].blocks_.end()) {
        for (const auto &mv : move_it->second.move_instructions_) {
          if (!mv.src_is_value_ && mv.src_ >= 0) {
            live.insert(mv.src_);
          }
        }
      }

      auto &after = live_after_caller_regs[block_id];
      after.resize(block.instructions_.size());
      for (int inst_index = static_cast<int>(block.instructions_.size()) - 1;
           inst_index >= 0; --inst_index) {
        after[inst_index] = vars_to_caller_regs(live);
        std::set<int> defs;
        std::set<int> uses;
        CollectIRDefUse(block.instructions_[inst_index], defs, uses);
        for (int def : defs) {
          live.erase(def);
        }
        live.insert(uses.begin(), uses.end());
      }
    }

    // bool busy_registers[32] = {false};
    const int stack_space = RISCV_functions_[i].stack_space_;
    // alloca
    auto &bb0 = RISCV_functions_[i].alloca_block_;
    // move sp & store registers
    bb0.PushArithmetic_I(r_addi_, 2, 2, -stack_space);
    SaveCalleeRegs(i, bb0);
    for (const auto &instruction : IR_functions_[i].alloca_instructions_) {
      const int allocated_start_addr_offset = alloca_data_offsets_[i].at(instruction.result_id_);
      bb0.PushArithmetic_I(r_addi_, 31, 2, allocated_start_addr_offset);
      // reg31 keeps the real address of the data
      bb0.PushMemory_S(r_sd_, 31, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
    }
    FlushSavedRegisters(i, bb0);
    PeepholeOptimizeBlock(bb0, {});
    // Build next_block_map from the final block layout so branch lowering sees
    // the same fall-throughs that Output() will emit.
    std::map<int, int> next_block_map;
    {
      int prev_id = -1;
      for (const int b_id : block_layouts_[i]) {
        if (prev_id != -1) {
          next_block_map[prev_id] = b_id;
        }
        prev_id = b_id;
      }
    }

    auto current_call_save_regs = [&](int block_id, int inst_index) {
      std::set<int> regs = live_after_caller_regs[block_id][inst_index];
      regs.insert(1);
      return regs;
    };
    auto add_argument_setup_save_regs = [&](std::set<int> &regs,
        const std::vector<FunctionCallArgument> &arguments, const auto &param_pass_pos) {
      std::set<int> modified_reg;
      for (int arg_id = 0; arg_id < static_cast<int>(arguments.size()); ++arg_id) {
        const auto [passed_by_reg, unused] = param_pass_pos(arg_id);
        if (passed_by_reg) {
          continue;
        }
        const auto &arg = arguments[arg_id];
        if (!arg.is_variable_) {
          continue;
        }
        const auto loc_it = RISCV_functions_[i].location_.find(arg.value_);
        if (loc_it == RISCV_functions_[i].location_.end()) {
          continue;
        }
        if (loc_it->second.first) {
          const int var_reg = loc_it->second.second;
          if (IsCallerSavedReg(var_reg) && modified_reg.contains(var_reg)) {
            regs.insert(var_reg);
          }
        } else {
          const auto [data_size, need_alignment] = GetSize(arg.type_);
          if (data_size != 1 && !(data_size == 4 && need_alignment)) {
            modified_reg.insert(used_caller_regs_[i].begin(), used_caller_regs_[i].end());
          }
        }
      }

      for (int arg_id = 0; arg_id < static_cast<int>(arguments.size()); ++arg_id) {
        const auto [passed_by_reg, reg_id] = param_pass_pos(arg_id);
        if (!passed_by_reg) {
          continue;
        }
        const auto &arg = arguments[arg_id];
        if (arg.is_variable_) {
          const auto loc_it = RISCV_functions_[i].location_.find(arg.value_);
          if (loc_it != RISCV_functions_[i].location_.end() && loc_it->second.first) {
            const int var_reg = loc_it->second.second;
            if (IsCallerSavedReg(var_reg) && modified_reg.contains(var_reg)) {
              regs.insert(var_reg);
            }
          }
        }
        if (IsCallerSavedReg(reg_id)) {
          modified_reg.insert(reg_id);
        }
      }
    };
    auto erase_result_reg = [&](std::set<int> &regs, int result_id) {
      const auto it = RISCV_functions_[i].location_.find(result_id);
      if (it != RISCV_functions_[i].location_.end() && it->second.first &&
          IsCallerSavedReg(it->second.second)) {
        regs.erase(it->second.second);
      }
    };
    auto deferred_load_typed_operand = [&](RISCVBlock &r_block, int var_id,
        int scratch_reg, const std::shared_ptr<IntegratedType> &type) {
      const auto &loc = RISCV_functions_[i].location_.at(var_id);
      if (loc.first) {
        r_block.deferred_load_.push_back(
            RISCVInstruction(r_mv_, scratch_reg, loc.second, -1, -1, -1));
      } else {
        r_block.deferred_load_.push_back(
            RISCVInstruction(CodeGenerator::GetLoadInst(type), scratch_reg, 2, -1,
                loc.second, -1));
      }
    };
    auto emit_direct_label_branch = [&](RISCVBlock &r_block, RISCVInstructionType type,
        int lhs_reg, int rhs_reg, int target) {
      r_block.instructions_.push_back(
          RISCVInstruction(type, -1, lhs_reg, rhs_reg, 1, target));
    };
    auto branch_for_condition = [](IcmpCond cond) {
      switch (cond) {
        case equal_: return r_beq_;
        case not_equal_: return r_bne_;
        case unsigned_greater_than_: return r_bltu_;
        case unsigned_greater_equal_: return r_bgeu_;
        case unsigned_less_than_: return r_bltu_;
        case unsigned_less_equal_: return r_bgeu_;
        case signed_greater_than_: return r_blt_;
        case signed_greater_equal_: return r_bge_;
        case signed_less_than_: return r_blt_;
        case signed_less_equal_: return r_bge_;
      }
      return r_beq_;
    };
    auto invert_condition = [](IcmpCond cond) {
      switch (cond) {
        case equal_: return not_equal_;
        case not_equal_: return equal_;
        case unsigned_greater_than_: return unsigned_less_equal_;
        case unsigned_greater_equal_: return unsigned_less_than_;
        case unsigned_less_than_: return unsigned_greater_equal_;
        case unsigned_less_equal_: return unsigned_greater_than_;
        case signed_greater_than_: return signed_less_equal_;
        case signed_greater_equal_: return signed_less_than_;
        case signed_less_than_: return signed_greater_equal_;
        case signed_less_equal_: return signed_greater_than_;
      }
      return equal_;
    };
    auto emit_direct_compare_branch = [&](RISCVBlock &r_block, const IRInstruction &cmp,
        int true_target, int false_target, int fallthrough_target) {
      IcmpCond cond = cmp.icmp_condition_;
      int target = true_target;
      int followup_jump = -1;
      if (true_target == fallthrough_target) {
        cond = invert_condition(cond);
        target = false_target;
      } else if (false_target != fallthrough_target) {
        followup_jump = false_target;
      }

      int lhs_reg = 5;
      int rhs_reg = 6;
      if (cmp.instruction_type_ == two_var_icmp_) {
        deferred_load_typed_operand(r_block, cmp.operand_1_id_, lhs_reg, cmp.result_type_);
        deferred_load_typed_operand(r_block, cmp.operand_2_id_, rhs_reg, cmp.result_type_);
      } else if (cmp.instruction_type_ == var_const_icmp_) {
        deferred_load_typed_operand(r_block, cmp.operand_1_id_, lhs_reg, cmp.result_type_);
        if (cmp.operand_2_id_ == 0) {
          rhs_reg = 0;
        } else {
          r_block.deferred_load_.push_back(
              RISCVInstruction(r_li_, rhs_reg, -1, -1, cmp.operand_2_id_, -1));
        }
      } else if (cmp.instruction_type_ == const_var_icmp_) {
        if (cmp.operand_1_id_ == 0) {
          lhs_reg = 0;
        } else {
          r_block.deferred_load_.push_back(
              RISCVInstruction(r_li_, lhs_reg, -1, -1, cmp.operand_1_id_, -1));
        }
        deferred_load_typed_operand(r_block, cmp.operand_2_id_, rhs_reg, cmp.result_type_);
      } else {
        CodegenThrow("Invalid compare instruction for direct branch.");
      }

      RISCVInstructionType branch_type = branch_for_condition(cond);
      switch (cond) {
        case unsigned_greater_than_:
        case signed_greater_than_:
          std::swap(lhs_reg, rhs_reg);
          break;
        case unsigned_less_equal_:
        case signed_less_equal_:
          std::swap(lhs_reg, rhs_reg);
          break;
        default:
          break;
      }
      emit_direct_label_branch(r_block, branch_type, lhs_reg, rhs_reg, target);
      if (followup_jump != -1) {
        r_block.PushJ(followup_jump);
      }
    };
    // blocks
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      auto &r_block = RISCV_functions_[i].blocks_[block_id];
      for (int inst_index = 0; inst_index < static_cast<int>(block.instructions_.size()); ++inst_index) {
        const auto &instruction = block.instructions_[inst_index];
        switch (instruction.instruction_type_) {
          case two_var_binary_operation_: {
            int first_var_register = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            int second_var_register = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            const bool dest_in_reg = RISCV_functions_[i].location_[instruction.result_id_].first;
            // Compute directly into the destination register when it is in a
            // register; otherwise fall back to the scratch register (t0 = 5).
            const int dest_reg = dest_in_reg
                ? RISCV_functions_[i].location_[instruction.result_id_].second
                : 5;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, first_var_register, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 5, first_var_register, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              first_var_register = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(first_var_register)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, first_var_register), 2);
              first_var_register = 5;
            }
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, second_var_register, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 6, second_var_register, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              second_var_register = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(second_var_register)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, second_var_register), 2);
              second_var_register = 6;
            }
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_R(r_addw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case sub_: {
                r_block.PushArithmetic_R(r_subw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case mul_: {
                r_block.PushExtended(r_mulw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case udiv_: {
                r_block.PushExtended(r_divuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushExtended(r_divw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushExtended(r_remuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushExtended(r_remw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushArithmetic_R(r_sllw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case ashr_: {
                r_block.PushArithmetic_R(r_sraw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case and_: {
                r_block.PushArithmetic_R(r_and_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case or_: {
                r_block.PushArithmetic_R(r_or_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_R(r_xor_, dest_reg, first_var_register, second_var_register);
                break;
              }
              default:;
            }
            if (dest_in_reg) {
              if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                r_block.PushMemory_S(r_sd_, dest_reg, RegSavedLocation(i, dest_reg), 2);
              }
            } else {
              const int result_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 5, result_offset, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_S(r_sb_, 5, result_offset, 2);
              } else {
                CodegenThrow("Invalid binary operation result type.");
              }
            }
            break;
          }
          case var_const_binary_operation_: {
            int first_var_register = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            constexpr int second_var_register = 6;
            const bool dest_in_reg = RISCV_functions_[i].location_[instruction.result_id_].first;
            const int dest_reg = dest_in_reg
                ? RISCV_functions_[i].location_[instruction.result_id_].second
                : 5;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, first_var_register, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 5, first_var_register, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              first_var_register = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(first_var_register)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, first_var_register), 2);
              first_var_register = 5;
            }
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_I(r_addiw_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              case sub_: {
                r_block.PushArithmetic_I(r_addiw_, dest_reg, first_var_register, -instruction.operand_2_id_);
                break;
              }
              case mul_: {
                if (!TryEmitMulConst32(r_block, dest_reg, first_var_register,
                    instruction.operand_2_id_, second_var_register)) {
                  r_block.PushLi(second_var_register, instruction.operand_2_id_);
                  r_block.PushExtended(r_mulw_, dest_reg, first_var_register, second_var_register);
                }
                break;
              }
              case udiv_: {
                r_block.PushLi(second_var_register, instruction.operand_2_id_);
                r_block.PushExtended(r_divuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushLi(second_var_register, instruction.operand_2_id_);
                r_block.PushExtended(r_divw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushLi(second_var_register, instruction.operand_2_id_);
                r_block.PushExtended(r_remuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushLi(second_var_register, instruction.operand_2_id_);
                r_block.PushExtended(r_remw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushArithmetic_I(r_slliw_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              case ashr_: {
                r_block.PushArithmetic_I(r_sraiw_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              case and_: {
                r_block.PushArithmetic_I(r_andi_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              case or_: {
                r_block.PushArithmetic_I(r_ori_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_I(r_xori_, dest_reg, first_var_register, instruction.operand_2_id_);
                break;
              }
              default:;
            }
            if (dest_in_reg) {
              if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                r_block.PushMemory_S(r_sd_, dest_reg, RegSavedLocation(i, dest_reg), 2);
              }
            } else {
              const int result_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 5, result_offset, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_S(r_sb_, 5, result_offset, 2);
              } else {
                CodegenThrow("Invalid binary operation result type.");
              }
            }
            break;
          }
          case const_var_binary_operation_: {
            constexpr int first_var_register = 5;
            int second_var_register = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            const bool dest_in_reg = RISCV_functions_[i].location_[instruction.result_id_].first;
            const int dest_reg = dest_in_reg
                ? RISCV_functions_[i].location_[instruction.result_id_].second
                : 5;
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, second_var_register, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 6, second_var_register, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              second_var_register = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(second_var_register)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, second_var_register), 2);
              second_var_register = 6;
            }
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_I(r_addiw_, dest_reg, second_var_register, instruction.operand_1_id_);
                break;
              }
              case sub_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushArithmetic_R(r_subw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case mul_: {
                if (!TryEmitMulConst32(r_block, dest_reg, second_var_register,
                    instruction.operand_1_id_, first_var_register)) {
                  r_block.PushLi(first_var_register, instruction.operand_1_id_);
                  r_block.PushExtended(r_mulw_, dest_reg, first_var_register, second_var_register);
                }
                break;
              }
              case udiv_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushExtended(r_divuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushExtended(r_divw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushExtended(r_remuw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushExtended(r_remw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushArithmetic_R(r_sllw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case ashr_: {
                r_block.PushLi(first_var_register, instruction.operand_1_id_);
                r_block.PushArithmetic_R(r_sraw_, dest_reg, first_var_register, second_var_register);
                break;
              }
              case and_: {
                r_block.PushArithmetic_I(r_andi_, dest_reg, second_var_register, instruction.operand_1_id_);
                break;
              }
              case or_: {
                r_block.PushArithmetic_I(r_ori_, dest_reg, second_var_register, instruction.operand_1_id_);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_I(r_xori_, dest_reg, second_var_register, instruction.operand_1_id_);
                break;
              }
              default:;
            }
            if (dest_in_reg) {
              if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                r_block.PushMemory_S(r_sd_, dest_reg, RegSavedLocation(i, dest_reg), 2);
              }
            } else {
              const int result_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 5, result_offset, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_S(r_sb_, 5, result_offset, 2);
              } else {
                CodegenThrow("Invalid binary operation result type.");
              }
            }
            break;
          }
          case conditional_br_: {
            const auto direct_cmp = direct_branch_icmps.find(block_id);
            if (direct_cmp != direct_branch_icmps.end()) {
              FlushSavedRegisters(i, r_block);
              int next_blk = -1;
              auto it = next_block_map.find(block_id);
              if (it != next_block_map.end()) next_blk = it->second;
              emit_direct_compare_branch(r_block, direct_cmp->second,
                  instruction.if_true_, instruction.if_false_, next_blk);
              break;
            }
            // NOTE: phi-induced moves for the branch targets are emitted in
            // the post-block pass *after* the regular instructions, just
            // before the terminator. Those moves clobber scratch registers
            // (5, 6, 7), so we must load the condition INTO a scratch
            // register AFTER the moves run — otherwise the moves will
            // clobber it and the branch will see a stale value.
            //
            // We therefore stash the load + branch on a separate
            // "deferred terminator" stream that the post-block pass emits
            // after the moves.
            FlushSavedRegisters(i, r_block);
            bool cond_in_reg = RISCV_functions_[i].location_[instruction.condition_id_].first;
            int cond_home = RISCV_functions_[i].location_[instruction.condition_id_].second;
            if (cond_in_reg) {
              // If condition is in a caller-saved register, we just flushed
              // so the hardware register is valid.  Use it directly.
              r_block.deferred_load_.push_back(
                  RISCVInstruction(r_add_, 5, cond_home, 0, -1, -1));
            } else {
              // lbu t0, cond_home(sp) — defer it.
              r_block.deferred_load_.push_back(
                  RISCVInstruction(r_lbu_, 5, 2, -1, cond_home, -1));
            }
            int next_blk = -1;
            auto it = next_block_map.find(block_id);
            if (it != next_block_map.end()) next_blk = it->second;
            if (instruction.if_true_ == next_blk) {
              // True target is the fall-through block.  Branch directly to
              // the false target when condition is false (r5 == 0), fall
              // through to the next block (true target) otherwise.
              // Use beqz (direct label) instead of PushControl_B (trampoline
              // via jump_blocks_) so the fall-through path lands on the next
              // block, not on the jump-block trampolines.
              r_block.instructions_.push_back(
                  RISCVInstruction(r_beqz_, -1, 5, -1, -1, instruction.if_false_));
            } else if (instruction.if_false_ == next_blk) {
              // False target is the fall-through block.  Branch directly to
              // the true target when condition is true (r5 != 0).
              r_block.instructions_.push_back(
                  RISCVInstruction(r_bnez_, -1, 5, -1, -1, instruction.if_true_));
            } else {
              r_block.PushControl_B(r_beq_, 0, 5, instruction.if_false_);
              r_block.PushJ(instruction.if_true_);
            }
            break;
          }
          case unconditional_br_: {
            FlushSavedRegisters(i, r_block);
            int next_blk = -1;
            auto it = next_block_map.find(block_id);
            if (it != next_block_map.end()) next_blk = it->second;
            if (instruction.destination_ != next_blk) {
              r_block.PushJ(instruction.destination_);
            }
            break;
          }
          case value_ret_: {
            FlushSavedRegisters(i, r_block);
            RestoreCalleeRegs(i, r_block);
            r_block.PushLi(10, instruction.result_id_);
            r_block.PushReturn(stack_space);
            break;
          }
          case variable_ret_: {
            FlushSavedRegisters(i, r_block);
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              r_block.PushArithmetic_I(r_addi_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 0);
            } else if (instruction.result_type_->is_int) {
              r_block.PushMemory_I(r_lw_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            } else if (instruction.result_type_->basic_type == pointer_type) {
              r_block.PushMemory_I(r_ld_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            } else if (instruction.result_type_->basic_type == bool_type) {
              r_block.PushMemory_I(r_lbu_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            } else {
              CodegenThrow("Invalid result type to be passed in register a0.");
            }
            RestoreCalleeRegs(i, r_block);
            r_block.PushReturn(stack_space);
            break;
          }
          case void_ret_: {
            FlushSavedRegisters(i, r_block);
            RestoreCalleeRegs(i, r_block);
            r_block.PushLi(10, 0);
            r_block.PushReturn(stack_space);
            break;
          }
          case load_: {
            const auto [load_size, need_alignment] = GetSize(instruction.result_type_);
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const auto result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
              if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
                r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                src_register = 5;
              } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
                r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
                src_register = 5;
              }
              if (load_size == 1) {
                r_block.PushMemory_I(r_lbu_, result_reg, 0, src_register);
              } else if (load_size == 4 && need_alignment) {
                r_block.PushMemory_I(r_lw_, result_reg, 0, src_register);
              } else if (load_size == 8) {
                r_block.PushMemory_I(r_ld_, result_reg, 0, src_register);
              } else {
                CodegenThrow("Unexpectedly loaded strange data into register.");
              }
              if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
              }
            } else {
              const auto result_address_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
              // move data from the space that starts from *pointer to that starts from result address
              if (load_size == 1) {
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lbu_, 5, 0, src_register);
                r_block.PushMemory_S(r_sb_, 5, result_address_offset, 2);
              } else if (load_size == 4 && need_alignment) {
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lw_, 5, 0, src_register);
                r_block.PushMemory_S(r_sw_, 5, result_address_offset, 2);
              } else if (load_size == 8) {
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushMemory_I(r_ld_, 5, 0, src_register);
                r_block.PushMemory_S(r_sd_, 5, result_address_offset, 2);
              } else {
                std::set<int> call_save_regs = current_call_save_regs(block_id, inst_index);
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (RISCV_functions_[i].location_[instruction.pointer_].first &&
                    IsCallerSavedReg(src_register)) {
                  call_save_regs.insert(src_register);
                }
                SaveCallerRegs(i, r_block, call_save_regs);
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushArithmetic_R(r_add_, 11, 0, src_register);
                r_block.PushArithmetic_I(r_addi_, 10, 2, result_address_offset);
                r_block.PushLi(12, load_size);
                r_block.PushCall(true, 7);
                RestoreCallerRegs(i, r_block, call_save_regs);
              }
            }
            break;
          }
          case ptr_load_: {
            int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
              r_block.PushMemory_I(r_ld_, 5, src_register, 2);
              src_register = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_register), 2);
              src_register = 5;
            }
            // src_register keeps the real address that the pointer points to
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const auto result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushMemory_I(r_ld_, result_reg, 0, src_register);
              if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
              }
            } else {
              const auto result_address = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushMemory_I(r_ld_, 5, 0, src_register);
              r_block.PushMemory_S(r_sd_, 5, result_address, 2);
            }
            break;
          }
          case variable_store_: {
            const auto [store_size, need_alignment] = GetSize(instruction.result_type_);
            if (RISCV_functions_[i].location_[instruction.result_id_].first) { // the data to be stored is already in a src_reg
              const auto src_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
              if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                dest_reg = 5;
              } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
                dest_reg = 5;
              }
              int data_reg = src_reg;
              if (registers_saved_[i] && IsCallerSavedReg(src_reg)) {
                r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, src_reg), 2);
                data_reg = 6;
              }
              // dest_reg keeps the real address that the pointer points to
              if (store_size == 1) {
                r_block.PushMemory_S(r_sb_, data_reg, 0, dest_reg);
              } else if (store_size == 4 && need_alignment) {
                r_block.PushMemory_S(r_sw_, data_reg, 0, dest_reg);
              } else if (store_size == 8) {
                r_block.PushMemory_S(r_sd_, data_reg, 0, dest_reg);
              } else {
                for (int b = 0; b < store_size; ++b) {
                  r_block.PushMemory_S(r_sb_, data_reg, b, dest_reg);
                  r_block.PushArithmetic_I(r_srliw_, data_reg, data_reg, 8);
                }
              }
            } else { // the data to be stored is in the memory
              if (store_size == 1) {
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lbu_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                r_block.PushMemory_S(r_sb_, 6, 0, dest_reg);
              } else if (store_size == 4 && need_alignment) {
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lw_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                r_block.PushMemory_S(r_sw_, 6, 0, dest_reg);
              } else if (store_size == 8) {
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushMemory_I(r_ld_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                r_block.PushMemory_S(r_sd_, 6, 0, dest_reg);
              } else {
                std::set<int> call_save_regs = current_call_save_regs(block_id, inst_index);
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (RISCV_functions_[i].location_[instruction.pointer_].first &&
                    IsCallerSavedReg(dest_reg)) {
                  call_save_regs.insert(dest_reg);
                }
                SaveCallerRegs(i, r_block, call_save_regs);
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
                  r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushArithmetic_R(r_add_, 10, 0, dest_reg); // process it first to prevent the content of dest_register from being modified
                r_block.PushArithmetic_I(r_addi_, 11, 2, RISCV_functions_[i].location_[instruction.result_id_].second);
                r_block.PushLi(12, store_size);
                r_block.PushCall(true, 7);
                RestoreCallerRegs(i, r_block, call_save_regs);
              }
            }
            break;
          }
          case value_store_: {
            const auto [store_size, need_alignment] = GetSize(instruction.result_type_);
            auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
              r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
              dest_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
              dest_reg = 5;
            }
            // dest_reg keeps the real address that the pointer points to
            r_block.PushLi(6, instruction.result_id_); // reg6 keeps the value that need to be stored
            if (store_size == 1) {
              r_block.PushMemory_S(r_sb_, 6, 0, dest_reg);
            } else if (store_size == 4) {
              r_block.PushMemory_S(r_sw_, 6, 0, dest_reg);
            } else {
              r_block.PushMemory_S(r_sd_, 6, 0, dest_reg);
            }
            break;
          }
          case ptr_store_: {
            auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
              r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
              dest_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(dest_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_reg), 2);
              dest_reg = 5;
            }
            // dest_reg keeps the real address that the pointer points to
            if (RISCV_functions_[i].location_[instruction.result_id_].first) { // the data to be stored is already in a src_reg
              const auto src_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              int data_reg = src_reg;
              if (registers_saved_[i] && IsCallerSavedReg(src_reg)) {
                r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, src_reg), 2);
                data_reg = 6;
              }
              r_block.PushMemory_S(r_sd_, data_reg, 0, dest_reg);
            } else { // the data to be stored is in the memory
              r_block.PushMemory_I(r_ld_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
              r_block.PushMemory_S(r_sd_, 6, 0, dest_reg);
            }
            break;
          }
          case get_element_ptr_by_value_: { // pointer: array/struct ptr; result_id: element ptr; result_type: array/struct type
            const int index = instruction.index_;
            int offset = 0;
            if (instruction.result_type_->basic_type == array_type) {
              auto [element_size, need_alignment] = GetSize(instruction.result_type_->element_type);
              offset = index * (need_alignment ? (element_size + 3) / 4 * 4 : element_size);
            } else { // instruction.result_type_->basic_type == struct_type
              const int struct_id = instruction.result_type_->struct_node->IR_ID_;
              for (int j = 0; j < index; ++j) {
                auto [element_size, need_alignment] = GetSize(IR_structs_[struct_id].element_type_[j]);
                if (need_alignment) {
                  offset = (offset + 3) / 4 * 4;
                }
                offset += element_size;
              }
              if (GetSize(IR_structs_[struct_id].element_type_[index]).second) {
                offset = (offset + 3) / 4 * 4;
              }
            }
            int pointer_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              r_block.PushMemory_I(r_ld_, 5, pointer_reg, 2);
              pointer_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(pointer_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, pointer_reg), 2);
              pointer_reg = 5;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              int result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_I(r_addi_, result_reg, pointer_reg, offset);
              if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
              }
            } else {
              r_block.PushArithmetic_I(r_addi_, 5, pointer_reg, offset);
              r_block.PushMemory_S(r_sd_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            }
            break;
          }
          case get_element_ptr_by_variable_: { // pointer: array/struct ptr; result_id: element ptr; result_type: array/struct type
            // We must NOT clobber the index variable's home register, because
            // (after mem2reg) the same variable may be referenced by a later
            // instruction in a different block. Always move/copy the index
            // value into a scratch register first.
            int index_var_reg = RISCV_functions_[i].location_[instruction.index_].second;
            const bool index_in_reg = RISCV_functions_[i].location_[instruction.index_].first;
            if (index_in_reg) {
              if (registers_saved_[i] && IsCallerSavedReg(index_var_reg)) {
                r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, index_var_reg), 2);
              } else {
                // Copy from the home register into t0 (=5) without modifying the home reg.
                r_block.PushArithmetic_R(r_add_, 5, index_var_reg, 0);
              }
            } else {
              r_block.PushMemory_I(r_lw_, 5, index_var_reg, 2);
            }
            auto [element_size, need_alignment] = GetSize(instruction.result_type_->element_type);
            if (need_alignment) {
              element_size = (element_size + 3) / 4 * 4;
            }
            if (element_size == 1) {
              // offset is already the index value in reg 5
            } else if (IsPowerOfTwo(element_size)) {
              r_block.PushArithmetic_I(r_slli_, 5, 5, Log2Int(element_size));
            } else {
              // reg 6 holds element_size, then is reused for pointer load below.
              // The offset is computed in reg 5 (which is a scratch).
              r_block.PushLi(6, element_size);
              r_block.PushExtended(r_mul_, 5, 5, 6);
            }
            // the offset is stored in reg 5
            int pointer_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              // pointer is on stack; load into reg 6 (reg 6 is now free, element_size no longer needed)
              r_block.PushMemory_I(r_ld_, 6, pointer_reg, 2);
              pointer_reg = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(pointer_reg)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, pointer_reg), 2);
              pointer_reg = 6;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              int result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg, pointer_reg, 5);
              if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
              }
            } else {
              // result is on stack; we need a scratch for the add result.
              // reg 5 holds the offset, reg 6 holds the pointer (or it's the home reg).
              // Use reg 7 as scratch for the add.
              r_block.PushArithmetic_R(r_add_, 7, pointer_reg, 5);
              r_block.PushMemory_S(r_sd_, 7, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            }
            break;
          }
          case two_var_icmp_: {
            const auto direct_cmp = direct_branch_icmps.find(block_id);
            if (direct_cmp != direct_branch_icmps.end() &&
                direct_cmp->second.result_id_ == instruction.result_id_) {
              break;
            }
            int op1_reg = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            int op2_reg = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, op1_reg, 2);
              op1_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(op1_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, op1_reg), 2);
              op1_reg = 5;
            }
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, op2_reg, 2);
              op2_reg = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(op2_reg)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, op2_reg), 2);
              op2_reg = 6;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                r_block.PushArithmetic_R(r_sub_, 5, op1_reg, op2_reg); // if %op1 == %op2, reg5 <- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case not_equal_: {
                r_block.PushArithmetic_R(r_sub_, 5, op1_reg, op2_reg); // if %op1 != %op2, reg5 <x- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, op2_reg, op1_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_equal_: {
                r_block.PushArithmetic_R(r_sltu_, 5, op1_reg, op2_reg); // reg5 <- 1 iff %op1 < %op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, op1_reg, op2_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_equal_: {
                r_block.PushArithmetic_R(r_sltu_, 5, op2_reg, op1_reg); // reg5 <- 1 iff %op2 < %op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_slt_, 5, op2_reg, op1_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_equal_: {
                r_block.PushArithmetic_R(r_slt_, 5, op1_reg, op2_reg); // reg5 <- 1 iff %op1 < %op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_slt_, 5, op1_reg, op2_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_equal_: {
                r_block.PushArithmetic_R(r_slt_, 5, op2_reg, op1_reg); // reg5 <- 1 iff %op2 < %op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              default:;
            }
            break;
          }
          case var_const_icmp_: {
            const auto direct_cmp = direct_branch_icmps.find(block_id);
            if (direct_cmp != direct_branch_icmps.end() &&
                direct_cmp->second.result_id_ == instruction.result_id_) {
              break;
            }
            int op1_reg = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, op1_reg, 2);
              op1_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(op1_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, op1_reg), 2);
              op1_reg = 5;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                if (instruction.operand_2_id_ == 0) {
                  // ==0 peephole: sltiu rd, op1_reg, 1  (1 insn instead of 2)
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, 1);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_I(r_sltiu_, 5, op1_reg, 1);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, op1_reg, instruction.operand_2_id_); // if %op1 == op2, reg5 <- 0
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                }
                break;
              }
              case not_equal_: {
                if (instruction.operand_2_id_ == 0) {
                  // !=0 peephole: sltu rd, x0, op1_reg  (1 insn instead of 2)
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, op1_reg);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_R(r_sltu_, 5, 0, op1_reg);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, op1_reg, instruction.operand_2_id_); // if %op1 != op2, reg5 <x- 0
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                }
                break;
              }
              case unsigned_greater_than_: {
                constexpr int op2_reg = 6;
                r_block.PushLi(op2_reg, instruction.operand_2_id_);
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, op2_reg, op1_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_equal_: {
                r_block.PushArithmetic_I(r_sltiu_, 5, op1_reg, instruction.operand_2_id_); // reg5 <- 1 iff %op1 < op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, instruction.operand_2_id_);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, op1_reg, instruction.operand_2_id_);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_equal_: {
                constexpr int op2_reg = 6;
                r_block.PushLi(6, instruction.operand_2_id_);
                r_block.PushArithmetic_R(r_sltu_, 5, op2_reg, op1_reg); // reg5 <- 1 iff op2 < %op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_than_: {
                constexpr int op2_reg = 6;
                r_block.PushLi(op2_reg, instruction.operand_2_id_);
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_slt_, 5, op2_reg, op1_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_equal_: {
                r_block.PushArithmetic_I(r_slti_, 5, op1_reg, instruction.operand_2_id_); // reg5 <- 1 iff %op1 < op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_slti_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, instruction.operand_2_id_);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_slti_, 5, op1_reg, instruction.operand_2_id_);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_equal_: {
                constexpr int op2_reg = 6;
                r_block.PushLi(6, instruction.operand_2_id_);
                r_block.PushArithmetic_R(r_slt_, 5, op2_reg, op1_reg); // reg5 <- 1 iff op2 < %op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              default:;
            }
            break;
          }
          case const_var_icmp_: {
            const auto direct_cmp = direct_branch_icmps.find(block_id);
            if (direct_cmp != direct_branch_icmps.end() &&
                direct_cmp->second.result_id_ == instruction.result_id_) {
              break;
            }
            int op2_reg = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, op2_reg, 2);
              op2_reg = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(op2_reg)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, op2_reg), 2);
              op2_reg = 6;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                if (instruction.operand_1_id_ == 0) {
                  // ==0 peephole: sltiu rd, op2_reg, 1  (1 insn instead of 2)
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, 1);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_I(r_sltiu_, 5, op2_reg, 1);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, op2_reg, instruction.operand_1_id_); // if op1 == %op2, reg5 <- 0
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                }
                break;
              }
              case not_equal_: {
                if (instruction.operand_1_id_ == 0) {
                  // !=0 peephole: sltu rd, x0, op2_reg  (1 insn instead of 2)
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, op2_reg);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_R(r_sltu_, 5, 0, op2_reg);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, op2_reg, instruction.operand_1_id_); // if op1 != %op2, reg5 <x- 0
                  if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                    r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                    if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                      r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                    }
                  } else {
                    r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                    r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                  }
                }
                break;
              }
              case unsigned_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, instruction.operand_1_id_);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, op2_reg, instruction.operand_1_id_);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_equal_: {
                constexpr int op1_reg = 5;
                r_block.PushLi(op1_reg, instruction.operand_1_id_);
                r_block.PushArithmetic_R(r_sltu_, 5, op1_reg, op2_reg); // reg5 <- 1 iff op1 < %op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_than_: {
                constexpr int op1_reg = 5;
                r_block.PushLi(op1_reg, instruction.operand_1_id_);
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, op1_reg, op2_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_equal_: {
                r_block.PushArithmetic_I(r_sltiu_, 5, op2_reg, instruction.operand_1_id_); // reg5 <- 1 iff %op2 < op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_slti_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, instruction.operand_1_id_);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_slti_, 5, op2_reg, instruction.operand_1_id_);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_equal_: {
                constexpr int op1_reg = 5;
                r_block.PushLi(op1_reg, instruction.operand_1_id_);
                r_block.PushArithmetic_R(r_slt_, 5, op1_reg, op2_reg); // reg5 <- 1 iff op1 < %op2
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_than_: {
                constexpr int op1_reg = 5;
                r_block.PushLi(op1_reg, instruction.operand_1_id_);
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_R(r_slt_, 5, op1_reg, op2_reg);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_equal_: {
                r_block.PushArithmetic_I(r_slti_, 5, op2_reg, instruction.operand_1_id_); // reg5 <- 1 iff %op2 < op1
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_xori_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                  if (registers_saved_[i] && IsCallerSavedReg(RISCV_functions_[i].location_[instruction.result_id_].second)) {
                    r_block.PushMemory_S(r_sd_, RISCV_functions_[i].location_[instruction.result_id_].second, RegSavedLocation(i, RISCV_functions_[i].location_[instruction.result_id_].second), 2);
                  }
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              default:;
            }
            break;
          }
          case non_void_call_: {
            const auto &arguments = instruction.function_call_arguments_;
            std::set<int> restore_regs = current_call_save_regs(block_id, inst_index);
            erase_result_reg(restore_regs, instruction.result_id_);
            std::set<int> call_save_regs = restore_regs;
            add_argument_setup_save_regs(call_save_regs, arguments, [&](int arg_id) {
              return GetParamPassPos(instruction.function_name_, arg_id);
            });
            SaveCallerRegs(i, r_block, call_save_regs);
            std::set<int> modified_reg;
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, neg_offset] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                if (arguments[j].is_variable_) {
                  const int var_id = arguments[j].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (modified_reg.contains(var_reg) || (registers_saved_[i] && IsCallerSavedReg(var_reg))) {
                      r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, var_reg), 2);
                      if (arguments[j].type_->is_int) {
                        r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == pointer_type) {
                        r_block.PushMemory_S(r_sd_, 5, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == bool_type) {
                        r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                      } else {
                        CodegenThrow("Invalid type to be passed from a register in non_void_call.");
                      }
                    } else { // not modified
                      if (arguments[j].type_->is_int) {
                        r_block.PushMemory_S(r_sw_, var_reg, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == pointer_type) {
                        r_block.PushMemory_S(r_sd_, var_reg, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == bool_type) {
                        r_block.PushMemory_S(r_sb_, var_reg, neg_offset, 2);
                      } else {
                        CodegenThrow("Invalid type to be passed from a register in non_void_call.");
                      }
                    }
                  } else { // the variable is stored in the memory
                    const int var_address_offset = RISCV_functions_[i].location_[var_id].second;
                    const auto [data_size, need_alignment] = GetSize(arguments[j].type_);
                    if (data_size == 1) {
                      r_block.PushMemory_I(r_lb_, 5, var_address_offset, 2);
                      r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                    } else if (data_size == 4 && need_alignment) {
                      r_block.PushMemory_I(r_lw_, 5, var_address_offset, 2);
                      r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                    } else {
                      r_block.PushArithmetic_I(r_addi_, 10, 2, neg_offset);
                      r_block.PushArithmetic_I(r_addi_, 11, 2, var_address_offset);
                      r_block.PushLi(12, data_size);
                      r_block.PushCall(true, 7);
                      for (int reg : used_caller_regs_[i]) {
                        modified_reg.insert(reg);
                      }
                    }
                  }
                } else {
                  const int value = arguments[j].value_;
                  r_block.PushLi(5, value);
                  if (arguments[j].type_->is_int) {
                    r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                  } else if (arguments[j].type_->basic_type == pointer_type) {
                    r_block.PushMemory_S(r_sd_, 5, neg_offset, 2);
                  } else if (arguments[j].type_->basic_type == bool_type) {
                    r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                  } else {
                    CodegenThrow("Invalid type to be passed as a value in non_void_call.");
                  }
                }
              }
            }
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, reg_id] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                continue;
              }
              if (arguments[j].is_variable_) {
                const int var_id = arguments[j].value_;
                if (RISCV_functions_[i].location_[var_id].first) {
                  const int var_reg = RISCV_functions_[i].location_[var_id].second;
                  if (modified_reg.contains(var_reg)) {
                    r_block.PushMemory_I(r_ld_, reg_id, RegSavedLocation(i, var_reg), 2);
                  } else { // not modified
                    r_block.PushArithmetic_R(r_add_, reg_id, var_reg, 0);
                  }
                } else { // the variable is stored in the memory
                  const int var_address_offset = RISCV_functions_[i].location_[var_id].second;
                  if (arguments[j].type_->is_int) {
                    r_block.PushMemory_I(r_lw_, reg_id, var_address_offset, 2);
                  } else if (arguments[j].type_->basic_type == pointer_type) {
                    r_block.PushMemory_I(r_ld_, reg_id, var_address_offset, 2);
                  } else if (arguments[j].type_->basic_type == bool_type) {
                    r_block.PushMemory_I(r_lb_, reg_id, var_address_offset, 2);
                  } else {
                    CodegenThrow("Invalid type to be passed to a register in non_void_call.");
                  }
                }
              } else {
                const int value = arguments[j].value_;
                r_block.PushLi(reg_id, value);
              }
              modified_reg.insert(reg_id);
            }
            r_block.PushCall(false, instruction.function_name_);
            int result_reg = -1;
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg, 10, 0);
            } else {
              const auto [result_size, need_alignment] = GetSize(instruction.result_type_);
              if (result_size == 1) {
                r_block.PushMemory_S(r_sb_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
              } else if (result_size == 4 && need_alignment) {
                r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
              } else if (result_size == 8) {
                r_block.PushMemory_S(r_sd_, 10, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
              } else {
                CodegenThrow("Invalid return type in non_void_call.");
              }
            }
            RestoreCallerRegs(i, r_block, restore_regs, result_reg);
            break;
          }
          case void_call_: {
            const auto &arguments = instruction.function_call_arguments_;
            std::set<int> restore_regs = current_call_save_regs(block_id, inst_index);
            std::set<int> call_save_regs = restore_regs;
            add_argument_setup_save_regs(call_save_regs, arguments, [&](int arg_id) {
              return GetParamPassPos(instruction.function_name_, arg_id);
            });
            SaveCallerRegs(i, r_block, call_save_regs);
            std::set<int> modified_reg;
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, neg_offset] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                if (arguments[j].is_variable_) {
                  const int var_id = arguments[j].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (modified_reg.contains(var_reg) || (registers_saved_[i] && IsCallerSavedReg(var_reg))) {
                      r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, var_reg), 2);
                      if (arguments[j].type_->is_int) {
                        r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == pointer_type) {
                        r_block.PushMemory_S(r_sd_, 5, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == bool_type) {
                        r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                      } else {
                        CodegenThrow("Invalid type to be passed from a register in void_call.");
                      }
                    } else { // not modified
                      if (arguments[j].type_->is_int) {
                        r_block.PushMemory_S(r_sw_, var_reg, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == pointer_type) {
                        r_block.PushMemory_S(r_sd_, var_reg, neg_offset, 2);
                      } else if (arguments[j].type_->basic_type == bool_type) {
                        r_block.PushMemory_S(r_sb_, var_reg, neg_offset, 2);
                      } else {
                        CodegenThrow("Invalid type to be passed from a register in void_call.");
                      }
                    }
                  } else { // the variable is stored in the memory
                    const int var_address_offset = RISCV_functions_[i].location_[var_id].second;
                    const auto [data_size, need_alignment] = GetSize(arguments[j].type_);
                    if (data_size == 1) {
                      r_block.PushMemory_I(r_lb_, 5, var_address_offset, 2);
                      r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                    } else if (data_size == 4 && need_alignment) {
                      r_block.PushMemory_I(r_lw_, 5, var_address_offset, 2);
                      r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                    } else {
                      r_block.PushArithmetic_I(r_addi_, 10, 2, neg_offset);
                      r_block.PushArithmetic_I(r_addi_, 11, 2, var_address_offset);
                      r_block.PushLi(12, data_size);
                      r_block.PushCall(true, 7);
                      for (int reg : used_caller_regs_[i]) {
                        modified_reg.insert(reg);
                      }
                    }
                  }
                } else {
                  const int value = arguments[j].value_;
                  r_block.PushLi(5, value);
                  if (arguments[j].type_->is_int) {
                    r_block.PushMemory_S(r_sw_, 5, neg_offset, 2);
                  } else if (arguments[j].type_->basic_type == pointer_type) {
                    r_block.PushMemory_S(r_sd_, 5, neg_offset, 2);
                  } else if (arguments[j].type_->basic_type == bool_type) {
                    r_block.PushMemory_S(r_sb_, 5, neg_offset, 2);
                  } else {
                    CodegenThrow("Invalid type to be passed as a value in void_call.");
                  }
                }
              }
            }
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, reg_id] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                continue;
              }
              if (arguments[j].is_variable_) {
                const int var_id = arguments[j].value_;
                if (RISCV_functions_[i].location_[var_id].first) {
                  const int var_reg = RISCV_functions_[i].location_[var_id].second;
                  if (modified_reg.contains(var_reg)) {
                    r_block.PushMemory_I(r_ld_, reg_id, RegSavedLocation(i, var_reg), 2);
                  } else { // not modified
                    r_block.PushArithmetic_R(r_add_, reg_id, var_reg, 0);
                  }
                } else { // the variable is stored in the memory
                  const int var_address_offset = RISCV_functions_[i].location_[var_id].second;
                  if (arguments[j].type_->is_int) {
                    r_block.PushMemory_I(r_lw_, reg_id, var_address_offset, 2);
                  } else if (arguments[j].type_->basic_type == pointer_type) {
                    r_block.PushMemory_I(r_ld_, reg_id, var_address_offset, 2);
                  } else if (arguments[j].type_->basic_type == bool_type) {
                    r_block.PushMemory_I(r_lb_, reg_id, var_address_offset, 2);
                  } else {
                    CodegenThrow("Invalid type to be passed to a register in void_call.");
                  }
                }
              } else {
                const int value = arguments[j].value_;
                r_block.PushLi(reg_id, value);
              }
              modified_reg.insert(reg_id);
            }
            r_block.PushCall(false, instruction.function_name_);
            RestoreCallerRegs(i, r_block, restore_regs);
            break;
          }
          case builtin_call_: {
            switch (instruction.function_name_) {
              case 0: { // printInt
                const auto &arguments = instruction.function_call_arguments_;
                std::set<int> restore_regs = current_call_save_regs(block_id, inst_index);
                std::set<int> call_save_regs = restore_regs;
                add_argument_setup_save_regs(call_save_regs, arguments, [](int) {
                  return std::pair<bool, int>{true, 10};
                });
                SaveCallerRegs(i, r_block, call_save_regs);
                if (arguments[0].is_variable_) {
                  const int var_id = arguments[0].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (registers_saved_[i] && IsCallerSavedReg(var_reg)) {
                      r_block.PushMemory_I(r_ld_, 10, RegSavedLocation(i, var_reg), 2);
                    } else {
                      r_block.PushArithmetic_R(r_add_, 10, var_reg, 0);
                    }
                  } else {
                    const int var_offset = RISCV_functions_[i].location_[var_id].second;
                    // %var must be an int
                    r_block.PushMemory_I(r_lw_, 10, var_offset, 2);
                  }
                } else {
                  r_block.PushLi(10, arguments[0].value_);
                }
                r_block.PushCall(true, 2);
                RestoreCallerRegs(i, r_block, restore_regs);
                break;
              }
              case 1: { // printlnInt
                const auto &arguments = instruction.function_call_arguments_;
                std::set<int> restore_regs = current_call_save_regs(block_id, inst_index);
                std::set<int> call_save_regs = restore_regs;
                add_argument_setup_save_regs(call_save_regs, arguments, [](int) {
                  return std::pair<bool, int>{true, 10};
                });
                SaveCallerRegs(i, r_block, call_save_regs);
                if (arguments[0].is_variable_) {
                  const int var_id = arguments[0].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (registers_saved_[i] && IsCallerSavedReg(var_reg)) {
                      r_block.PushMemory_I(r_ld_, 10, RegSavedLocation(i, var_reg), 2);
                    } else {
                      r_block.PushArithmetic_R(r_add_, 10, var_reg, 0);
                    }
                  } else {
                    const int var_offset = RISCV_functions_[i].location_[var_id].second;
                    // %var must be an int
                    r_block.PushMemory_I(r_lw_, 10, var_offset, 2);
                  }
                } else {
                  r_block.PushLi(10, arguments[0].value_);
                }
                r_block.PushCall(true, 3);
                RestoreCallerRegs(i, r_block, restore_regs);
                break;
              }
              case 2: { // getInt
                std::set<int> call_save_regs = current_call_save_regs(block_id, inst_index);
                erase_result_reg(call_save_regs, instruction.result_id_);
                SaveCallerRegs(i, r_block, call_save_regs);
                r_block.PushCall(true, 5);
                int result_reg = -1;
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
                  r_block.PushArithmetic_R(r_add_, result_reg, 10, 0);
                  if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                    r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
                  }
                } else {
                  const int result_var_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
                  r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 10, result_var_offset, 2);
                }
                RestoreCallerRegs(i, r_block, call_save_regs, result_reg);
                break;
              }
              default:;
            }
            break;
          }
          case phi_: {
            CodegenThrow("Unexpected phi instruction in block.instructions");
            break;
          }
          case value_select_ii_: {
            if (instruction.condition_id_ == 0) {
              VariableAssignment(i, r_block, instruction.result_id_, instruction.operand_2_id_, instruction.another_type_);
            } else {
              VariableAssignment(i, r_block, instruction.result_id_, instruction.operand_1_id_, instruction.result_type_);
            }
            break;
          }
          case value_select_iv_: {
            if (instruction.condition_id_ == 0) {
              ValueAssignment(i, r_block, instruction.result_id_, instruction.operand_2_id_, instruction.another_type_);
            } else {
              VariableAssignment(i, r_block, instruction.result_id_, instruction.operand_1_id_, instruction.result_type_);
            }
            break;
          }
          case value_select_vi_: {
            if (instruction.condition_id_ == 0) {
              VariableAssignment(i, r_block, instruction.result_id_, instruction.operand_2_id_, instruction.another_type_);
            } else {
              ValueAssignment(i, r_block, instruction.result_id_, instruction.operand_1_id_, instruction.result_type_);
            }
            break;
          }
          case value_select_vv_: {
            if (instruction.condition_id_ == 0) {
              ValueAssignment(i, r_block, instruction.result_id_, instruction.operand_2_id_, instruction.another_type_);
            } else {
              ValueAssignment(i, r_block, instruction.result_id_, instruction.operand_1_id_, instruction.result_type_);
            }
            break;
          }
          case variable_select_ii_:
          case variable_select_iv_:
          case variable_select_vi_: {
            CodegenThrow("Unexpected variable select instruction.");
            break;
          }
          case variable_select_vv_: {
            // %var.result_id <- %var.condition ? 1 : 0
            int src_reg = RISCV_functions_[i].location_[instruction.condition_id_].second;
            if (!RISCV_functions_[i].location_[instruction.condition_id_].first) {
              r_block.PushMemory_I(r_lbu_, 5, src_reg, 2);
              src_reg = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(src_reg)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, src_reg), 2);
              src_reg = 5;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const int result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg, src_reg, 0);
              if (registers_saved_[i] && IsCallerSavedReg(result_reg)) {
                r_block.PushMemory_S(r_sd_, result_reg, RegSavedLocation(i, result_reg), 2);
              }
            } else if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
              r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), src_reg, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            } else {
              r_block.PushMemory_S(r_sb_, src_reg, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            }
            break;
          }
          case builtin_memset_: {
            std::set<int> call_save_regs = current_call_save_regs(block_id, inst_index);
            const auto ptr_it = RISCV_functions_[i].location_.find(instruction.pointer_);
            if (ptr_it != RISCV_functions_[i].location_.end() && ptr_it->second.first &&
                IsCallerSavedReg(ptr_it->second.second) &&
                call_save_regs.contains(ptr_it->second.second)) {
              call_save_regs.insert(ptr_it->second.second);
            }
            SaveCallerRegs(i, r_block, call_save_regs);
            int dest_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              r_block.PushMemory_I(r_ld_, 5, dest_register, 2);
              dest_register = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(dest_register)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_register), 2);
              dest_register = 5;
            }
            r_block.PushArithmetic_R(r_add_, 10, dest_register, 0);
            r_block.PushLi(11, instruction.operand_1_id_ == 0 ? 0 : -1);
            r_block.PushLi(12, instruction.result_id_);
            r_block.PushCall(true, 6); // call memset
            RestoreCallerRegs(i, r_block, call_save_regs);
            break;
          }
          case builtin_memcpy_: {
            std::set<int> call_save_regs = current_call_save_regs(block_id, inst_index);
            const auto dest_it = RISCV_functions_[i].location_.find(instruction.destination_);
            if (dest_it != RISCV_functions_[i].location_.end() && dest_it->second.first &&
                IsCallerSavedReg(dest_it->second.second) &&
                call_save_regs.contains(dest_it->second.second)) {
              call_save_regs.insert(dest_it->second.second);
            }
            const auto src_it = RISCV_functions_[i].location_.find(instruction.pointer_);
            if (src_it != RISCV_functions_[i].location_.end() && src_it->second.first &&
                IsCallerSavedReg(src_it->second.second) &&
                call_save_regs.contains(src_it->second.second)) {
              call_save_regs.insert(src_it->second.second);
            }
            SaveCallerRegs(i, r_block, call_save_regs);
            int dest_register = RISCV_functions_[i].location_[instruction.destination_].second;
            if (!RISCV_functions_[i].location_[instruction.destination_].first) {
              r_block.PushMemory_I(r_ld_, 5, dest_register, 2);
              dest_register = 5;
            } else if (registers_saved_[i] && IsCallerSavedReg(dest_register)) {
              r_block.PushMemory_I(r_ld_, 5, RegSavedLocation(i, dest_register), 2);
              dest_register = 5;
            }
            int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              r_block.PushMemory_I(r_ld_, 6, src_register, 2);
              src_register = 6;
            } else if (registers_saved_[i] && IsCallerSavedReg(src_register)) {
              r_block.PushMemory_I(r_ld_, 6, RegSavedLocation(i, src_register), 2);
              src_register = 6;
            }
            if (src_register == 10) {
              r_block.PushArithmetic_R(r_add_, 6, src_register, 0);
              src_register = 6;
            }
            r_block.PushArithmetic_R(r_add_, 10, dest_register, 0);
            r_block.PushArithmetic_R(r_add_, 11, src_register, 0);
            r_block.PushLi(12, instruction.result_id_);
            r_block.PushCall(true, 7); // call memcpy
            RestoreCallerRegs(i, r_block, call_save_regs);
            break;
          }
          default:;
        }
      }
      std::vector<RISCVInstruction> jump_instructions;
      while (!r_block.instructions_.empty() &&
          ((r_block.instructions_.back().instruction_type_ >= 28 && r_block.instructions_.back().instruction_type_ <= 35)
          || (r_block.instructions_.back().instruction_type_ >= 46 && r_block.instructions_.back().instruction_type_ <= 50)
          || r_block.instructions_.back().instruction_type_ == 57)) {
        jump_instructions.push_back(r_block.instructions_.back());
        r_block.instructions_.pop_back();
      }
      // Emit phi-induced moves (these clobber scratch registers 5/6/7).
      for (const auto &mv_instruction : r_block.move_instructions_) {
        const auto [dest_in_reg, dest_location] = RISCV_functions_[i].location_[mv_instruction.dest_];
        if (mv_instruction.src_is_value_) {
          if (dest_in_reg) {
            r_block.PushLi(dest_location, mv_instruction.src_);
          } else if (mv_instruction.type_->basic_type == bool_type) {
            r_block.PushLi(5, mv_instruction.src_);
            r_block.PushMemory_S(r_sb_, 5, dest_location, 2);
          } else {
            r_block.PushLi(5, mv_instruction.src_);
            r_block.PushMemory_S(CodeGenerator::GetStoreInst(mv_instruction.type_), 5, dest_location, 2);
          }
        } else { // the src is a variable
          VariableAssignment(i, r_block, mv_instruction.dest_, mv_instruction.src_, mv_instruction.type_);
        }
      }
      // Now emit deferred loads (e.g., the conditional branch's condition
      // reload) so they execute after the moves and before the terminator.
      for (const auto &def : r_block.deferred_load_) {
        if ((def.instruction_type_ == r_lb_ || def.instruction_type_ == r_lbu_ ||
             def.instruction_type_ == r_lh_ || def.instruction_type_ == r_lhu_ ||
             def.instruction_type_ == r_lw_ || def.instruction_type_ == r_ld_) &&
            def.rs1_ == 2 &&
            (def.imm_ < -2048 || def.imm_ > 2047)) {
          // Large stack offset - use LI+ADD+load sequence.
          r_block.PushLi(7, def.imm_);
          r_block.PushArithmetic_R(r_add_, 7, 7, 2);
          r_block.instructions_.push_back(
              RISCVInstruction(def.instruction_type_, def.rd_, 7, -1, 0, -1));
        } else {
          r_block.instructions_.push_back(def);
        }
      }
      while (!jump_instructions.empty()) {
        r_block.instructions_.push_back(jump_instructions.back());
        jump_instructions.pop_back();
      }
      PeepholeOptimizeBlock(r_block, live_out_regs[block_id]);
    }
    RelaxFarBranches(i);
  }
}

void CodeGenerator::PrintReg(std::ofstream &file, const int reg) const {
  switch (reg) {
    case 0: {
      file << "x0";
      break;
    }
    case 1: {
      file << "ra";
      break;
    }
    case 2: {
      file << "sp";
      break;
    }
    case 3: {
      file << "gp";
      break;
    }
    case 4: {
      file << "tp";
      break;
    }
    case 5:
    case 6:
    case 7: {
      file << "t" << reg - 5;
      break;
    }
    case 8:
    case 9: {
      file << "s" << reg - 8;
      break;
    }
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
    case 16:
    case 17: {
      file << "a" << reg - 10;
      break;
    }
    case 18:
    case 19:
    case 20:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
    case 26:
    case 27: {
      file << "s" << reg - 16;
      break;
    }
    case 28:
    case 29:
    case 30:
    case 31: {
      file << "t" << reg - 25;
      break;
    }
    default:;
  }
}

void CodeGenerator::PrintLabel(std::ofstream &file, const int label, const int func_id) const {
  file << ".LBB" << func_id << "_" << label;
}

void CodeGenerator::PrintJumpLabel(std::ofstream &file, const int block_label,
    const int jump_label, const int func_id) const {
  file << ".LBB" << func_id << "_" << block_label << "_jump_" << jump_label;
}

void CodeGenerator::Print_AR(std::ofstream &file, const RISCVInstruction &instruction) const {
  PrintReg(file, instruction.rd_);
  file << ", ";
  PrintReg(file, instruction.rs1_);
  file << ", ";
  PrintReg(file, instruction.rs2_);
}

void CodeGenerator::Print_AI(std::ofstream &file, const RISCVInstruction &instruction) const {
  PrintReg(file, instruction.rd_);
  file << ", ";
  PrintReg(file, instruction.rs1_);
  file << ", " << instruction.imm_;
}

void CodeGenerator::Print_MI(std::ofstream &file, const RISCVInstruction &instruction) const {
  PrintReg(file, instruction.rd_);
  file << ", " << instruction.imm_ << "(";
  PrintReg(file, instruction.rs1_);
  file << ")";
}

void CodeGenerator::Print_MS(std::ofstream &file, const RISCVInstruction &instruction) const {
  PrintReg(file, instruction.rs2_);
  file << ", " << instruction.imm_ << "(";
  PrintReg(file, instruction.rs1_);
  file << ")";
}

void CodeGenerator::Print_B(std::ofstream &file, const RISCVInstruction &instruction,
    const int func_id, const int block_id) const {
  PrintReg(file, instruction.rs1_);
  file << ", ";
  PrintReg(file, instruction.rs2_);
  file << ", ";
  if (instruction.imm_ == 1) {
    PrintLabel(file, instruction.label_, func_id);
  } else {
    PrintJumpLabel(file, block_id, instruction.label_, func_id);
  }
}

namespace {

const char *InvertBranchMnemonic(const RISCVInstructionType type) {
  switch (type) {
    case r_beq_: return "bne";
    case r_bge_: return "blt";
    case r_bgeu_: return "bltu";
    case r_blt_: return "bge";
    case r_bltu_: return "bgeu";
    case r_bne_: return "beq";
    default: return "beq";
  }
}

} // namespace

void CodeGenerator::Print(std::ofstream &file, const RISCVInstruction &instruction,
    const int func_id, const int block_id) const {
  file << '\t';
  switch (instruction.instruction_type_) {
    case r_add_: {
      file << "add\t";
      Print_AR(file, instruction);
      break;
    }
    case r_sub_: {
      file << "sub\t";
      Print_AR(file, instruction);
      break;
    }
    case r_and_: {
      file << "and\t";
      Print_AR(file, instruction);
      break;
    }
    case r_or_: {
      file << "or\t";
      Print_AR(file, instruction);
      break;
    }
    case r_xor_: {
      file << "xor\t";
      Print_AR(file, instruction);
      break;
    }
    case r_sll_: {
      file << "sll\t";
      Print_AR(file, instruction);
      break;
    }
    case r_srl_: {
      file << "srl\t";
      Print_AR(file, instruction);
      break;
    }
    case r_sra_: {
      file << "sra\t";
      Print_AR(file, instruction);
      break;
    }
    case r_slt_: {
      file << "slt\t";
      Print_AR(file, instruction);
      break;
    }
    case r_sltu_: {
      file << "sltu\t";
      Print_AR(file, instruction);
      break;
    }
    case r_addi_: {
      file << "addi\t";
      Print_AI(file, instruction);
      break;
    }
    case r_andi_: {
      file << "andi\t";
      Print_AI(file, instruction);
      break;
    }
    case r_ori_: {
      file << "ori\t";
      Print_AI(file, instruction);
      break;
    }
    case r_xori_: {
      file << "xori\t";
      Print_AI(file, instruction);
      break;
    }
    case r_slli_: {
      file << "slli\t";
      Print_AI(file, instruction);
      break;
    }
    case r_srli_: {
      file << "srli\t";
      Print_AI(file, instruction);
      break;
    }
    case r_srai_: {
      file << "srai\t";
      Print_AI(file, instruction);
      break;
    }
    case r_slti_: {
      file << "slti\t";
      Print_AI(file, instruction);
      break;
    }
    case r_sltiu_: {
      file << "sltiu\t";
      Print_AI(file, instruction);
      break;
    }
    case r_lb_: {
      file << "lb\t";
      Print_MI(file, instruction);
      break;
    }
    case r_lbu_: {
      file << "lbu\t";
      Print_MI(file, instruction);
      break;
    }
    case r_lh_: {
      file << "lh\t";
      Print_MI(file, instruction);
      break;
    }
    case r_lhu_: {
      file << "lhu\t";
      Print_MI(file, instruction);
      break;
    }
    case r_lw_: {
      file << "lw\t";
      Print_MI(file, instruction);
      break;
    }
    case r_sb_: {
      file << "sb\t";
      Print_MS(file, instruction);
      break;
    }
    case r_sh_: {
      file << "sh\t";
      Print_MS(file, instruction);
      break;
    }
    case r_sw_: {
      file << "sw\t";
      Print_MS(file, instruction);
      break;
    }
    case r_beq_:
    case r_bge_:
    case r_bgeu_:
    case r_blt_:
    case r_bltu_:
    case r_bne_: {
      if (instruction.imm_ == 1) {
        switch (instruction.instruction_type_) {
          case r_beq_: file << "beq\t"; break;
          case r_bge_: file << "bge\t"; break;
          case r_bgeu_: file << "bgeu\t"; break;
          case r_blt_: file << "blt\t"; break;
          case r_bltu_: file << "bltu\t"; break;
          case r_bne_: file << "bne\t"; break;
          default: break;
        }
        Print_B(file, instruction, func_id, block_id);
      } else {
        file << InvertBranchMnemonic(instruction.instruction_type_) << '\t';
        PrintReg(file, instruction.rs1_);
        file << ", ";
        PrintReg(file, instruction.rs2_);
        file << ", 1f\n\tla\tt2, ";
        PrintJumpLabel(file, block_id, instruction.label_, func_id);
        file << "\n\tjr\tt2\n1:";
      }
      break;
    }
    case r_jal_: {
      file << "jal\t";
      PrintReg(file, instruction.rd_);
      file << ", ";
      PrintLabel(file, instruction.label_, func_id);
      break;
    }
    case r_jalr_: {
      file << "jalr\t";
      Print_AI(file, instruction);
      break;
    }
    case r_auipc_: {
      file << "auipc\t";
      PrintReg(file, instruction.rd_);
      file << ", " << instruction.imm_;
      break;
    }
    case r_lui_: {
      file << "lui\t";
      PrintReg(file, instruction.rd_);
      file << ", " << instruction.imm_;
      break;
    }
    case r_ebreak_: {
      file << "ebreak";
      break;
    }
    case r_ecall_: {
      file << "ecall";
      break;
    }
    case r_mul_: {
      file << "mul\t";
      Print_AR(file, instruction);
      break;
    }
    case r_div_: {
      file << "div\t";
      Print_AR(file, instruction);
      break;
    }
    case r_divu_: {
      file << "divu\t";
      Print_AR(file, instruction);
      break;
    }
    case r_rem_: {
      file << "rem\t";
      Print_AR(file, instruction);
      break;
    }
    case r_remu_: {
      file << "remu\t";
      Print_AR(file, instruction);
      break;
    }
    case r_exit_: {
      file << "exit";
      break;
    }
    case r_beqz_: {
      file << "bnez\t";
      PrintReg(file, instruction.rs1_);
      file << ", 1f\n\tla\tt2, ";
      PrintLabel(file, instruction.label_, func_id);
      file << "\n\tjr\tt2\n1:";
      break;
    }
    case r_bnez_: {
      file << "beqz\t";
      PrintReg(file, instruction.rs1_);
      file << ", 1f\n\tla\tt2, ";
      PrintLabel(file, instruction.label_, func_id);
      file << "\n\tjr\tt2\n1:";
      break;
    }
    case r_j_: {
      file << "j\t";
      PrintLabel(file, instruction.label_, func_id);
      break;
    }
    case r_jal_ra_: {
      file << "jal\t";
      PrintLabel(file, instruction.label_, func_id);
      break;
    }
    case r_jr_: {
      file << "jr\t";
      PrintReg(file, instruction.rs1_);
      break;
    }
    case r_la_: {
      file << "la\t";
      PrintReg(file, instruction.rd_);
      file << ", ";
      PrintLabel(file, instruction.label_, func_id);
      break;
    }
    case r_li_: {
      file << "li\t";
      PrintReg(file, instruction.rd_);
      file << ", " << instruction.imm_;
      break;
    }
    case r_mv_: {
      file << "mv\t";
      PrintReg(file, instruction.rd_);
      file << ", ";
      PrintReg(file, instruction.rs1_);
      break;
    }
    case r_neg_: {
      file << "neg\t";
      PrintReg(file, instruction.rd_);
      file << ", ";
      PrintReg(file, instruction.rs1_);
      break;
    }
    case r_nop_: {
      file << "nop";
      break;
    }
    case r_not_: {
      file << "not\t";
      PrintReg(file, instruction.rd_);
      file << ", ";
      PrintReg(file, instruction.rs1_);
      break;
    }
    case r_ret_: {
      file << "ret";
      break;
    }
    case r_addw_: {
      file << "addw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_subw_: {
      file << "subw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_addiw_: {
      file << "addiw\t";
      Print_AI(file, instruction);
      break;
    }
    case r_sllw_: {
      file << "sllw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_srlw_: {
      file << "srlw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_sraw_: {
      file << "sraw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_slliw_: {
      file << "slliw\t";
      Print_AI(file, instruction);
      break;
    }
    case r_srliw_: {
      file << "srliw\t";
      Print_AI(file, instruction);
      break;
    }
    case r_sraiw_: {
      file << "sraiw\t";
      Print_AI(file, instruction);
      break;
    }
    case r_mulw_: {
      file << "mulw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_divw_: {
      file << "divw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_divuw_: {
      file << "divuw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_remw_: {
      file << "remw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_remuw_: {
      file << "remuw\t";
      Print_AR(file, instruction);
      break;
    }
    case r_ld_: {
      file << "ld\t";
      Print_MI(file, instruction);
      break;
    }
    case r_sd_: {
      file << "sd\t";
      Print_MS(file, instruction);
      break;
    }
    case r_call_: {
      file << "call\t";
      if (instruction.rd_) { // builtin
        switch (instruction.label_) {
          case 0: {
            file << "print";
            break;
          }
          case 1: {
            file << "println";
            break;
          }
          case 2: {
            file << "printInt";
            break;
          }
          case 3: {
            file << "printlnInt";
            break;
          }
          case 4: {
            file << "getString";
            break;
          }
          case 5: {
            file << "getInt";
            break;
          }
          case 6: {
            file << "builtin_memset";
            break;
          }
          case 7: {
            file << "builtin_memcpy";
            break;
          }
        }
      } else {
        file << "fn." << instruction.label_;
      }
      break;
    }
    default:;
  }
  file << '\n';
}

void CodeGenerator::Output(std::ofstream &output_file) const {
  // Switch back to .text section — builtin.s may have switched to .rodata
  // for string constants, and all generated code must be in .text (executable).
  output_file << "	.text\n";
  for (int i = 0, current_func_id = 8; i < RISCV_functions_.size(); ++i, ++current_func_id) {
    output_file << "	.globl	";
    if (i == main_func_id_) {
      output_file << "main                            # -- Begin function main\n"
          << "	.p2align	1\n"
          << "	.type	main,@function\n"
          << "main:                                   # @main\n";
    } else {
      output_file << "fn." << i << "                            # -- Begin function fn." << i
          << "\n	.p2align	1"
          << "\n	.type	fn." << i << ",@function\n"
          << "fn." << i << ":                                   # @fn." << i << '\n';
    }
    output_file << "# %bb.0:                                # %alloca\n";
    for (const auto &instruction : RISCV_functions_[i].alloca_block_.instructions_) {
      Print(output_file, instruction, current_func_id, -1);
    }
    std::map<int, int> next_block_map;
    {
      int prev_id = -1;
      for (const int block_id : block_layouts_[i]) {
        if (prev_id != -1) {
          next_block_map[prev_id] = block_id;
        }
        prev_id = block_id;
      }
    }
    for (const int block_label : block_layouts_[i]) {
      const auto &block = RISCV_functions_[i].blocks_.at(block_label);
      output_file << ".LBB" << current_func_id << '_' << block_label
          << ":                               # %label_" << block_label << '\n';
      for (int inst_index = 0; inst_index < static_cast<int>(block.instructions_.size()); ++inst_index) {
        const auto &instruction = block.instructions_[inst_index];
        const bool terminal_fallthrough_jump =
            inst_index + 1 == static_cast<int>(block.instructions_.size()) &&
            instruction.instruction_type_ == r_j_ &&
            block.jump_blocks_.empty() &&
            next_block_map.contains(block_label) &&
            instruction.label_ == next_block_map[block_label];
        if (terminal_fallthrough_jump) {
          continue;
        }
        Print(output_file, instruction, current_func_id, block_label);
      }
      for (int j = 0; j < block.jump_blocks_.size(); ++j) {
        output_file << ".LBB" << current_func_id << '_' << block_label << "_jump_" << j
            << ":                               # %label_" << block_label << "_jump_" << j << '\n';
        Print(output_file, block.jump_blocks_[j], current_func_id, block_label);
      }
    }
    output_file << ".Lfunc_end" << current_func_id << ":\n";
    if (i == main_func_id_) {
      output_file << "	.size	main, .Lfunc_end" << current_func_id
          << "-main\n                                        # -- End function\n";
    } else {
      output_file << "	.size	fn." << i << ", .Lfunc_end" << current_func_id << "-fn." << i
          << "\n                                        # -- End function\n";
    }
  }
}

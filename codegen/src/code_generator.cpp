#include "code_generator.h"
#include "register_allocator.h"
#include "fstream"
#include "item.h"
#include <set>

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
  for (int i = 0; i < IR_functions_.size(); ++i) {
    std::map<BlockJumping, AssignmentGraph> assign_relations;
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      for (const auto &instruction : block.phi_instructions_) {
        const int dest_var_id = instruction.result_id;
        const auto &type = instruction.type;
        for (const auto &condition : instruction.conditions) {
          if (condition.is_const) { // is literal value
            RISCV_functions_[i].blocks_[condition.from_block_id].PushMove(type,
                true, condition.value, dest_var_id);
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
  }
}

void CodeGenerator::MemAlloc(const int func_id) {
  int &space = RISCV_functions_[func_id].stack_space_;
  space = 224; // 28 * 8 bytes for register saving
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
  space = (space + 15) / 16 * 16;  // RV64 ABI: 16-byte stack alignment
  for (const auto [var_id, location] : RISCV_functions_[func_id].location_) {
    if (!location.first) {
      RISCV_functions_[func_id].location_[var_id].second = space - RISCV_functions_[func_id].location_[var_id].second;
    }
  }
}

int CodeGenerator::RegSavedLocation(const int func_id, const int reg_id) const {
  const int stack_space = RISCV_functions_[func_id].stack_space_;
  if (reg_id == 1) {
    return stack_space - 8;
  }
  if (reg_id <= 4) {
    CodegenThrow("x0, x2, x3 and x4 have no saving space in the stack.");
  }
  return stack_space - 8 * (reg_id - 3);
}

void CodeGenerator::VariableAssignment(const int func_id, RISCVBlock &r_block, const int var_dest,
    const int var_src, const std::shared_ptr<IntegratedType> &type) {
  const auto [dest_in_reg, dest_location] = RISCV_functions_[func_id].location_[var_dest];
  const auto [src_in_reg, src_location] = RISCV_functions_[func_id].location_[var_src];
  auto [type_size, need_alignment] = GetSize(type);
  // Alloca result vars store a pointer (8 bytes), not the element type size
  if (alloca_var_ids_[func_id].count(var_src)) type_size = 8;
  if (alloca_var_ids_[func_id].count(var_dest)) type_size = 8;
  if (type_size == 1) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_lbu_, 5, src_location, 2);
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
    } else {
      r_block.PushArithmetic_R(r_add_, 5, src_data_reg, 0);
      r_block.PushMemory_S(r_sb_, 5, dest_location, 2);
    }
  } else if (type_size == 4 && need_alignment) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_lw_, 5, src_location, 2);
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
    } else {
      r_block.PushArithmetic_R(r_add_, 5, src_data_reg, 0);
      r_block.PushMemory_S(CodeGenerator::GetStoreInst(type), 5, dest_location, 2);
    }
  } else if (type_size == 8) {
    int src_data_reg = src_location;
    if (!src_in_reg) {
      r_block.PushMemory_I(r_ld_, 5, src_location, 2);
      src_data_reg = 5;
    }
    if (dest_in_reg) {
      r_block.PushArithmetic_R(r_add_, dest_location, src_data_reg, 0);
    } else {
      r_block.PushArithmetic_R(r_add_, 5, src_data_reg, 0);
      r_block.PushMemory_S(r_sd_, 5, dest_location, 2);
    }
  } else {
    if (src_in_reg || dest_in_reg) {
      CodegenThrow("Unexpected type in the register!");
    }
    for (int x = 0; x < 32; ++x) {
      if (register_saver.at(x) == caller_save) {
        r_block.PushMemory_S(r_sd_, x, RegSavedLocation(func_id, x), 2);
      }
    }
    r_block.PushArithmetic_I(r_addi_, 11, 2, src_location);
    r_block.PushArithmetic_I(r_addi_, 10, 2, dest_location);
    r_block.PushLi(12, type_size);
    r_block.PushCall(true, 7);
    for (int x = 0; x < 32; ++x) {
      if (register_saver.at(x) == caller_save) {
        r_block.PushMemory_I(r_ld_, x, RegSavedLocation(func_id, x), 2);
      }
    }
  }
}
void CodeGenerator::ValueAssignment(const int func_id, RISCVBlock &r_block, const int var_dest,
    const int value_src, const std::shared_ptr<IntegratedType> &type) {
  if (type->is_int) {
    if (RISCV_functions_[func_id].location_[var_dest].first) {
      r_block.PushLi(RISCV_functions_[func_id].location_[var_dest].second, value_src);
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
      r_block.PushLi(RISCV_functions_[func_id].location_[var_dest].second, value_src);
    } else {
      r_block.PushLi(5, value_src);
      r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[func_id].location_[var_dest].second, 2);
    }
  } else {
    CodegenThrow("Invalid type to be selected as an invariable.");
  }
}

void CodeGenerator::Generate() {
  RISCV_functions_.resize(IR_functions_.size());
  alloca_var_ids_.resize(IR_functions_.size());
  PhiToMove();
  for (int i = 0; i < IR_functions_.size(); ++i) {
    MemAlloc(i);
  }
  // Register allocation: promote scalars from stack to registers.
  for (int i = 0; i < IR_functions_.size(); ++i) {
    RegisterAllocator reg_alloc(IR_functions_[i], RISCV_functions_[i]);
    reg_alloc.Run();
  }
  for (int i = 0; i < IR_functions_.size(); ++i) {
    // bool busy_registers[32] = {false};
    const int stack_space = RISCV_functions_[i].stack_space_;
    // alloca
    auto &bb0 = RISCV_functions_[i].alloca_block_;
    // move sp & store registers
    bb0.PushArithmetic_I(r_addi_, 2, 2, -stack_space);
    for (int x = 0; x < 32; ++x) {
      if (register_saver.at(x) == callee_save) {
        bb0.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
      }
    }
    for (const auto &instruction : IR_functions_[i].alloca_instructions_) {
      const int allocated_start_addr_offset = RISCV_functions_[i].location_[instruction.result_id_].second
          - GetSize(instruction.result_type_).first;
      bb0.PushLi(31, allocated_start_addr_offset);
      bb0.PushArithmetic_R(r_add_, 31, 31, 2);
      // reg31 keeps the real address of the data
      bb0.PushMemory_S(r_sd_, 31, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
    }
    bb0.PushJ(IR_functions_[i].blocks_.begin()->first);
    // blocks
    for (const auto &[block_id, block] : IR_functions_[i].blocks_) {
      auto &r_block = RISCV_functions_[i].blocks_[block_id];
      for (const auto &instruction : block.instructions_) {
        switch (instruction.instruction_type_) {
          case two_var_binary_operation_: {
            int first_var_register = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            int second_var_register = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, RISCV_functions_[i].location_[instruction.operand_1_id_].second, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 5, RISCV_functions_[i].location_[instruction.operand_1_id_].second, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              first_var_register = 5;
            }
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, RISCV_functions_[i].location_[instruction.operand_2_id_].second, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 6, RISCV_functions_[i].location_[instruction.operand_2_id_].second, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              second_var_register = 6;
            }
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_R(r_addw_, 5, first_var_register, second_var_register);
                break;
              }
              case sub_: {
                r_block.PushArithmetic_R(r_subw_, 5, first_var_register, second_var_register);
                break;
              }
              case mul_: {
                r_block.PushExtended(r_mulw_, 5, first_var_register, second_var_register);
                break;
              }
              case udiv_: {
                r_block.PushExtended(r_divuw_, 5, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushExtended(r_divw_, 5, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushExtended(r_remuw_, 5, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushExtended(r_remw_, 5, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushArithmetic_R(r_sllw_, 5, first_var_register, second_var_register);
                break;
              }
              case ashr_: {
                r_block.PushArithmetic_R(r_sraw_, 5, first_var_register, second_var_register);
                break;
              }
              case and_: {
                r_block.PushArithmetic_R(r_and_, 5, first_var_register, second_var_register);
                break;
              }
              case or_: {
                r_block.PushArithmetic_R(r_or_, 5, first_var_register, second_var_register);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_R(r_xor_, 5, first_var_register, second_var_register);
                break;
              }
              default:;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const int result_reg_id = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg_id, 5, 0);
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
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, RISCV_functions_[i].location_[instruction.operand_1_id_].second, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 5, RISCV_functions_[i].location_[instruction.operand_1_id_].second, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              first_var_register = 5;
            }
            r_block.PushLi(second_var_register, instruction.operand_2_id_);
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_R(r_addw_, 5, first_var_register, second_var_register);
                break;
              }
              case sub_: {
                r_block.PushArithmetic_R(r_subw_, 5, first_var_register, second_var_register);
                break;
              }
              case mul_: {
                r_block.PushExtended(r_mulw_, 5, first_var_register, second_var_register);
                break;
              }
              case udiv_: {
                r_block.PushExtended(r_divuw_, 5, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushExtended(r_divw_, 5, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushExtended(r_remuw_, 5, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushExtended(r_remw_, 5, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushArithmetic_R(r_sllw_, 5, first_var_register, second_var_register);
                break;
              }
              case ashr_: {
                r_block.PushArithmetic_R(r_sraw_, 5, first_var_register, second_var_register);
                break;
              }
              case and_: {
                r_block.PushArithmetic_R(r_and_, 5, first_var_register, second_var_register);
                break;
              }
              case or_: {
                r_block.PushArithmetic_R(r_or_, 5, first_var_register, second_var_register);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_R(r_xor_, 5, first_var_register, second_var_register);
                break;
              }
              default:;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const int result_reg_id = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg_id, 5, 0);
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
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
                r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, RISCV_functions_[i].location_[instruction.operand_2_id_].second, 2);
              } else if (instruction.result_type_->basic_type == bool_type) {
                r_block.PushMemory_I(r_lbu_, 6, RISCV_functions_[i].location_[instruction.operand_2_id_].second, 2);
              } else {
                CodegenThrow("Invalid binary operator type.");
              }
              second_var_register = 6;
            }
            r_block.PushLi(first_var_register, instruction.operand_1_id_);
            switch (instruction.operator_) {
              case add_: {
                r_block.PushArithmetic_R(r_addw_, 5, first_var_register, second_var_register);
                break;
              }
              case sub_: {
                r_block.PushArithmetic_R(r_subw_, 5, first_var_register, second_var_register);
                break;
              }
              case mul_: {
                r_block.PushExtended(r_mulw_, 5, first_var_register, second_var_register);
                break;
              }
              case udiv_: {
                r_block.PushExtended(r_divuw_, 5, first_var_register, second_var_register);
                break;
              }
              case sdiv_: {
                r_block.PushExtended(r_divw_, 5, first_var_register, second_var_register);
                break;
              }
              case urem_: {
                r_block.PushExtended(r_remuw_, 5, first_var_register, second_var_register);
                break;
              }
              case srem_: {
                r_block.PushExtended(r_remw_, 5, first_var_register, second_var_register);
                break;
              }
              case shl_: {
                r_block.PushArithmetic_R(r_sllw_, 5, first_var_register, second_var_register);
                break;
              }
              case ashr_: {
                r_block.PushArithmetic_R(r_sraw_, 5, first_var_register, second_var_register);
                break;
              }
              case and_: {
                r_block.PushArithmetic_R(r_and_, 5, first_var_register, second_var_register);
                break;
              }
              case or_: {
                r_block.PushArithmetic_R(r_or_, 5, first_var_register, second_var_register);
                break;
              }
              case xor_: {
                r_block.PushArithmetic_R(r_xor_, 5, first_var_register, second_var_register);
                break;
              }
              default:;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const int result_reg_id = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg_id, 5, 0);
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
            bool cond_in_reg = RISCV_functions_[i].location_[instruction.condition_id_].first;
            int cond_home = RISCV_functions_[i].location_[instruction.condition_id_].second;
            if (cond_in_reg) {
              // mv t0, cond_home — defer it so it runs after the moves.
              r_block.deferred_load_.push_back(
                  RISCVInstruction(r_add_, 5, cond_home, 0, -1, -1));
            } else {
              // lbu t0, cond_home(sp) — defer it.
              r_block.deferred_load_.push_back(
                  RISCVInstruction(r_lbu_, 5, 2, -1, cond_home, -1));
            }
            r_block.PushControl_B(r_beq_, 0, 5, instruction.if_false_);
            r_block.PushJ(instruction.if_true_);
            break;
          }
          case unconditional_br_: {
            r_block.PushJ(instruction.destination_);
            break;
          }
          case value_ret_: {
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == callee_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
            r_block.PushLi(10, instruction.result_id_);
            r_block.PushReturn(stack_space);
            break;
          }
          case variable_ret_: {
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
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == callee_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
            r_block.PushReturn(stack_space);
            break;
          }
          case void_ret_: {
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == callee_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
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
            } else {
              const auto result_address_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
              // move data from the space that starts from *pointer to that starts from result address
              if (load_size == 1) {
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
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
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lw_, 5, 0, src_register);
                r_block.PushMemory_S(r_sw_, 5, result_address_offset, 2);
              } else if (load_size == 8) {
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushMemory_I(r_ld_, 5, 0, src_register);
                r_block.PushMemory_S(r_sd_, 5, result_address_offset, 2);
              } else {
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                  }
                }
                int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, src_register, 2);
                  src_register = 5;
                }
                // src_register keeps the real address that the pointer points to
                r_block.PushArithmetic_R(r_add_, 11, 0, src_register);
                r_block.PushArithmetic_I(r_addi_, 10, 2, result_address_offset);
                r_block.PushLi(12, load_size);
                r_block.PushCall(true, 7);
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                  }
                }
              }
            }
            break;
          }
          case ptr_load_: {
            int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // src_register actually stores the pointer's relative address to sp
              r_block.PushMemory_I(r_ld_, 5, src_register, 2);
              src_register = 5;
            }
            // src_register keeps the real address that the pointer points to
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              const auto result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushMemory_I(r_ld_, result_reg, 0, src_register);
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
              }
              // dest_reg keeps the real address that the pointer points to
              if (store_size == 1) {
                r_block.PushMemory_S(r_sb_, src_reg, 0, dest_reg);
              } else if (store_size == 4 && need_alignment) {
                r_block.PushMemory_S(r_sw_, src_reg, 0, dest_reg);
              } else if (store_size == 8) {
                r_block.PushMemory_S(r_sd_, src_reg, 0, dest_reg);
              } else {
                for (int b = 0; b < store_size; ++b) {
                  r_block.PushMemory_S(r_sb_, src_reg, b, dest_reg);
                  r_block.PushArithmetic_I(r_srliw_, src_reg, src_reg, 8);
                }
              }
            } else { // the data to be stored is in the memory
              if (store_size == 1) {
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
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
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushMemory_I(r_lw_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                r_block.PushMemory_S(r_sw_, 6, 0, dest_reg);
              } else if (store_size == 8) {
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushMemory_I(r_ld_, 6, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                r_block.PushMemory_S(r_sd_, 6, 0, dest_reg);
              } else {
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                  }
                }
                auto dest_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
                if (!RISCV_functions_[i].location_[instruction.pointer_].first) { // dest_reg actually stores the pointer's relative address to sp
                  r_block.PushMemory_I(r_ld_, 5, dest_reg, 2);
                  dest_reg = 5;
                }
                // dest_reg keeps the real address that the pointer points to
                r_block.PushArithmetic_R(r_add_, 10, 0, dest_reg); // process it first to prevent the content of dest_register from being modified
                r_block.PushArithmetic_I(r_addi_, 11, 2, RISCV_functions_[i].location_[instruction.result_id_].second);
                r_block.PushLi(12, store_size);
                r_block.PushCall(true, 7);
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                  }
                }
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
            }
            // dest_reg keeps the real address that the pointer points to
            if (RISCV_functions_[i].location_[instruction.result_id_].first) { // the data to be stored is already in a src_reg
              const auto src_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushMemory_S(r_sd_, src_reg, 0, dest_reg);
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
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              int result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_I(r_addi_, result_reg, pointer_reg, offset);
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
              // Copy from the home register into t0 (=5) without modifying the home reg.
              r_block.PushArithmetic_R(r_add_, 5, index_var_reg, 0);
            } else {
              r_block.PushMemory_I(r_lw_, 5, index_var_reg, 2);
            }
            auto [element_size, need_alignment] = GetSize(instruction.result_type_->element_type);
            if (need_alignment) {
              element_size = (element_size + 3) / 4 * 4;
            }
            // reg 6 holds element_size, then is reused for pointer load below.
            // The offset is computed in reg 5 (which is a scratch).
            r_block.PushLi(6, element_size);
            r_block.PushExtended(r_mul_, 5, 5, 6);
            // the offset is stored in reg 5
            int pointer_reg = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              // pointer is on stack; load into reg 6 (reg 6 is now free, element_size no longer needed)
              r_block.PushMemory_I(r_ld_, 6, pointer_reg, 2);
              pointer_reg = 6;
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              int result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
              r_block.PushArithmetic_R(r_add_, result_reg, pointer_reg, 5);
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
            int op1_reg = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            int op2_reg = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, op1_reg, 2);
              op1_reg = 5;
            }
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, op2_reg, 2);
              op2_reg = 6;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                r_block.PushArithmetic_R(r_xor_, 5, op1_reg, op2_reg); // if %op1 == %op2, reg5 <- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case not_equal_: {
                r_block.PushArithmetic_R(r_xor_, 5, op1_reg, op2_reg); // if %op1 != %op2, reg5 <x- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_slt_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, op2_reg);
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
            int op1_reg = RISCV_functions_[i].location_[instruction.operand_1_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_1_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 5, op1_reg, 2);
              op1_reg = 5;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                r_block.PushArithmetic_I(r_xori_, 5, op1_reg, instruction.operand_2_id_); // if %op1 == op2, reg5 <- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case not_equal_: {
                r_block.PushArithmetic_I(r_xori_, 5, op1_reg, instruction.operand_2_id_); // if %op1 != op2, reg5 <x- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_than_: {
                constexpr int op2_reg = 6;
                r_block.PushLi(op2_reg, instruction.operand_2_id_);
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, op1_reg);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, instruction.operand_2_id_);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_less_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_slti_, RISCV_functions_[i].location_[instruction.result_id_].second, op1_reg, instruction.operand_2_id_);
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
            int op2_reg = RISCV_functions_[i].location_[instruction.operand_2_id_].second;
            if (!RISCV_functions_[i].location_[instruction.operand_2_id_].first) {
              r_block.PushMemory_I(CodeGenerator::GetLoadInst(instruction.result_type_), 6, op2_reg, 2);
              op2_reg = 6;
            }
            switch (instruction.icmp_condition_) {
              case equal_: {
                r_block.PushArithmetic_I(r_xori_, 5, op2_reg, instruction.operand_1_id_); // if op1 == %op2, reg5 <- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, 5, 1);
                } else {
                  r_block.PushArithmetic_I(r_sltiu_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case not_equal_: {
                r_block.PushArithmetic_I(r_xori_, 5, op2_reg, instruction.operand_1_id_); // if op1 != %op2, reg5 <x- 0
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_R(r_sltu_, RISCV_functions_[i].location_[instruction.result_id_].second, 0, 5);
                } else {
                  r_block.PushArithmetic_R(r_sltu_, 5, 0, 5);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case unsigned_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_sltiu_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, instruction.operand_1_id_);
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
                } else {
                  r_block.PushArithmetic_I(r_xori_, 5, 5, 1);
                  r_block.PushMemory_S(r_sb_, 5, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
                }
                break;
              }
              case signed_greater_than_: {
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  r_block.PushArithmetic_I(r_slti_, RISCV_functions_[i].location_[instruction.result_id_].second, op2_reg, instruction.operand_1_id_);
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
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
              }
            }
            const auto &arguments = instruction.function_call_arguments_;
            std::set<int> modified_reg;
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, neg_offset] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                if (arguments[j].is_variable_) {
                  const int var_id = arguments[j].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (modified_reg.contains(var_reg)) {
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
                      for (int x = 0; x < 32; ++x) {
                        if (register_saver.at(x) == caller_save) {
                          r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                        }
                      }
                      r_block.PushArithmetic_I(r_addi_, 10, 2, neg_offset);
                      r_block.PushArithmetic_I(r_addi_, 11, 2, var_address_offset);
                      r_block.PushLi(12, data_size);
                      r_block.PushCall(true, 7);
                      for (int x = 0; x < 32; ++x) {
                        if (register_saver.at(x) == caller_save) {
                          r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                        }
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
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save && x != result_reg) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
            break;
          }
          case void_call_: {
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
              }
            }
            const auto &arguments = instruction.function_call_arguments_;
            std::set<int> modified_reg;
            for (int j = 0; j < arguments.size(); ++j) {
              const auto [passed_by_reg, neg_offset] = GetParamPassPos(instruction.function_name_, j);
              if (!passed_by_reg) {
                if (arguments[j].is_variable_) {
                  const int var_id = arguments[j].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    if (modified_reg.contains(var_reg)) {
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
                      for (int x = 0; x < 32; ++x) {
                        if (register_saver.at(x) == caller_save) {
                          r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                        }
                      }
                      r_block.PushArithmetic_I(r_addi_, 10, 2, neg_offset);
                      r_block.PushArithmetic_I(r_addi_, 11, 2, var_address_offset);
                      r_block.PushLi(12, data_size);
                      r_block.PushCall(true, 7);
                      for (int x = 0; x < 32; ++x) {
                        if (register_saver.at(x) == caller_save) {
                          r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                        }
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
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
            break;
          }
          case builtin_call_: {
            switch (instruction.function_name_) {
              case 0: { // printInt
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                  }
                }
                const auto &arguments = instruction.function_call_arguments_;
                if (arguments[0].is_variable_) {
                  const int var_id = arguments[0].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    r_block.PushArithmetic_R(r_add_, 10, var_reg, 0);
                  } else {
                    const int var_offset = RISCV_functions_[i].location_[var_id].second;
                    // %var must be an int
                    r_block.PushMemory_I(r_lw_, 10, var_offset, 2);
                  }
                } else {
                  r_block.PushLi(10, arguments[0].value_);
                }
                r_block.PushCall(true, 2);
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                  }
                }
                break;
              }
              case 1: { // printlnInt
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                  }
                }
                const auto &arguments = instruction.function_call_arguments_;
                if (arguments[0].is_variable_) {
                  const int var_id = arguments[0].value_;
                  if (RISCV_functions_[i].location_[var_id].first) {
                    const int var_reg = RISCV_functions_[i].location_[var_id].second;
                    r_block.PushArithmetic_R(r_add_, 10, var_reg, 0);
                  } else {
                    const int var_offset = RISCV_functions_[i].location_[var_id].second;
                    // %var must be an int
                    r_block.PushMemory_I(r_lw_, 10, var_offset, 2);
                  }
                } else {
                  r_block.PushLi(10, arguments[0].value_);
                }
                r_block.PushCall(true, 3);
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                  }
                }
                break;
              }
              case 2: { // getInt
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save) {
                    r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
                  }
                }
                r_block.PushCall(true, 5);
                int result_reg = -1;
                if (RISCV_functions_[i].location_[instruction.result_id_].first) {
                  result_reg = RISCV_functions_[i].location_[instruction.result_id_].second;
                  r_block.PushArithmetic_R(r_add_, result_reg, 10, 0);
                } else {
                  const int result_var_offset = RISCV_functions_[i].location_[instruction.result_id_].second;
                  r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), 10, result_var_offset, 2);
                }
                for (int x = 0; x < 32; ++x) {
                  if (register_saver.at(x) == caller_save && x != result_reg) {
                    r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
                  }
                }
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
            }
            if (RISCV_functions_[i].location_[instruction.result_id_].first) {
              r_block.PushArithmetic_R(r_add_, RISCV_functions_[i].location_[instruction.result_id_].second, src_reg, 0);
            } else if (instruction.result_type_->is_int || instruction.result_type_->basic_type == pointer_type) {
              r_block.PushMemory_S(CodeGenerator::GetStoreInst(instruction.result_type_), src_reg, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            } else {
              r_block.PushMemory_S(r_sb_, src_reg, RISCV_functions_[i].location_[instruction.result_id_].second, 2);
            }
            break;
          }
          case builtin_memset_: {
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
              }
            }
            int dest_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              r_block.PushMemory_I(r_ld_, 5, dest_register, 2);
              dest_register = 5;
            }
            r_block.PushArithmetic_R(r_add_, 10, dest_register, 0);
            r_block.PushLi(11, instruction.operand_1_id_ == 0 ? 0 : -1);
            r_block.PushLi(12, instruction.result_id_);
            r_block.PushCall(true, 6); // call memset
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
            break;
          }
          case builtin_memcpy_: {
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_S(r_sd_, x, RegSavedLocation(i, x), 2);
              }
            }
            int dest_register = RISCV_functions_[i].location_[instruction.destination_].second;
            if (!RISCV_functions_[i].location_[instruction.destination_].first) {
              r_block.PushMemory_I(r_ld_, 5, dest_register, 2);
              dest_register = 5;
            }
            int src_register = RISCV_functions_[i].location_[instruction.pointer_].second;
            if (!RISCV_functions_[i].location_[instruction.pointer_].first) {
              r_block.PushMemory_I(r_ld_, 6, src_register, 2);
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
            for (int x = 0; x < 32; ++x) {
              if (register_saver.at(x) == caller_save) {
                r_block.PushMemory_I(r_ld_, x, RegSavedLocation(i, x), 2);
              }
            }
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
        if (def.instruction_type_ == r_lbu_ && def.rs1_ == 2 &&
            (def.imm_ < -2048 || def.imm_ > 2047)) {
          // Large stack offset — use LI+ADD+LB sequence.
          r_block.PushLi(7, def.imm_);
          r_block.PushArithmetic_R(r_add_, 7, 7, 2);
          r_block.instructions_.push_back(
              RISCVInstruction(r_lbu_, def.rd_, 7, -1, 0, -1));
        } else {
          r_block.instructions_.push_back(def);
        }
      }
      while (!jump_instructions.empty()) {
        r_block.instructions_.push_back(jump_instructions.back());
        jump_instructions.pop_back();
      }
    }
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
  PrintJumpLabel(file, block_id, instruction.label_, func_id);
}

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
    case r_beq_: {
      file << "beq\t";
      Print_B(file, instruction, func_id, block_id);
      break;
    }
    case r_bge_: {
      file << "bge\t";
      Print_B(file, instruction, func_id, block_id);
      break;
    }
    case r_bgeu_: {
      file << "bgeu\t";
      Print_B(file, instruction, func_id, block_id);
      break;
    }
    case r_blt_: {
      file << "blt\t";
      Print_B(file, instruction, func_id, block_id);
      break;
    }
    case r_bltu_: {
      file << "bltu\t";
      Print_B(file, instruction, func_id, block_id);
      break;
    }
    case r_bne_: {
      file << "bne\t";
      Print_B(file, instruction, func_id, block_id);
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
      file << "beqz\t";
      PrintReg(file, instruction.rs1_);
      file << ", ";
      PrintLabel(file, instruction.label_, func_id);
      break;
    }
    case r_bnez_: {
      file << "bnez\t";
      PrintReg(file, instruction.rs1_);
      file << ", ";
      PrintLabel(file, instruction.label_, func_id);
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
    for (const auto &[block_label, block] : RISCV_functions_[i].blocks_) {
      output_file << ".LBB" << current_func_id << '_' << block_label
          << ":                               # %label_" << block_label << '\n';
      for (const auto &instruction : block.instructions_) {
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
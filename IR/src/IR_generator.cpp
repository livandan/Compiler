#include "IR_generator.h"
#include "item.h"
#include "expression.h"
#include "statements.h"
#include "fstream"
#include <algorithm>
#include <map>
#include <set>
#include <vector>

void IRThrow(const std::string &err_info) {
  std::cerr << "[IR Error] " << err_info << '\n';
  throw "";
}

namespace {

void AddUse(std::map<int, int> &use_count, const int var_id) {
  if (var_id >= 0) {
    ++use_count[var_id];
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
    for (const auto &instruction : block.instructions_) {
      switch (instruction.instruction_type_) {
        case two_var_binary_operation_:
        case two_var_icmp_: {
          AddUse(use_count, instruction.operand_1_id_);
          AddUse(use_count, instruction.operand_2_id_);
          break;
        }
        case var_const_binary_operation_:
        case var_const_icmp_: {
          AddUse(use_count, instruction.operand_1_id_);
          break;
        }
        case const_var_binary_operation_:
        case const_var_icmp_: {
          AddUse(use_count, instruction.operand_2_id_);
          break;
        }
        case conditional_br_: {
          AddUse(use_count, instruction.condition_id_);
          break;
        }
        case variable_ret_: {
          AddUse(use_count, instruction.result_id_);
          break;
        }
        case load_:
        case ptr_load_: {
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case variable_store_: {
          AddUse(use_count, instruction.result_id_);
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case value_store_: {
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case ptr_store_: {
          AddUse(use_count, instruction.result_id_);
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case get_element_ptr_by_value_: {
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case get_element_ptr_by_variable_: {
          AddUse(use_count, instruction.pointer_);
          AddUse(use_count, instruction.index_);
          break;
        }
        case non_void_call_:
        case void_call_:
        case builtin_call_: {
          for (const auto &argument : instruction.function_call_arguments_) {
            if (argument.is_variable_) {
              AddUse(use_count, argument.value_);
            }
          }
          break;
        }
        case value_select_ii_:
        case value_select_iv_:
        case value_select_vi_:
        case value_select_vv_:
        case variable_select_ii_:
        case variable_select_iv_:
        case variable_select_vi_:
        case variable_select_vv_: {
          if (instruction.instruction_type_ == variable_select_ii_ ||
              instruction.instruction_type_ == variable_select_iv_ ||
              instruction.instruction_type_ == variable_select_vi_ ||
              instruction.instruction_type_ == variable_select_vv_) {
            AddUse(use_count, instruction.condition_id_);
          }
          if (instruction.instruction_type_ == value_select_ii_ ||
              instruction.instruction_type_ == value_select_iv_ ||
              instruction.instruction_type_ == variable_select_ii_ ||
              instruction.instruction_type_ == variable_select_iv_) {
            AddUse(use_count, instruction.operand_1_id_);
          }
          if (instruction.instruction_type_ == value_select_ii_ ||
              instruction.instruction_type_ == value_select_vi_ ||
              instruction.instruction_type_ == variable_select_ii_ ||
              instruction.instruction_type_ == variable_select_vi_) {
            AddUse(use_count, instruction.operand_2_id_);
          }
          break;
        }
        case builtin_memset_: {
          AddUse(use_count, instruction.pointer_);
          break;
        }
        case builtin_memcpy_: {
          AddUse(use_count, instruction.destination_);
          AddUse(use_count, instruction.pointer_);
          break;
        }
        default:
          break;
      }
    }
  }
  return use_count;
}

std::set<int> CollectAllocaIds(const IRFunctionNode &function) {
  std::set<int> alloca_ids;
  for (const auto &instruction : function.alloca_instructions_) {
    alloca_ids.insert(instruction.result_id_);
  }
  return alloca_ids;
}

void ReplaceUse(int &var_id, const int from, const int to) {
  if (var_id == from) {
    var_id = to;
  }
}

void ReplaceInstructionUses(IRInstruction &instruction, const int from, const int to) {
  switch (instruction.instruction_type_) {
    case two_var_binary_operation_:
    case two_var_icmp_: {
      ReplaceUse(instruction.operand_1_id_, from, to);
      ReplaceUse(instruction.operand_2_id_, from, to);
      break;
    }
    case var_const_binary_operation_:
    case var_const_icmp_: {
      ReplaceUse(instruction.operand_1_id_, from, to);
      break;
    }
    case const_var_binary_operation_:
    case const_var_icmp_: {
      ReplaceUse(instruction.operand_2_id_, from, to);
      break;
    }
    case conditional_br_: {
      ReplaceUse(instruction.condition_id_, from, to);
      break;
    }
    case variable_ret_: {
      ReplaceUse(instruction.result_id_, from, to);
      break;
    }
    case load_:
    case ptr_load_: {
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case variable_store_: {
      ReplaceUse(instruction.result_id_, from, to);
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case value_store_: {
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case ptr_store_: {
      ReplaceUse(instruction.result_id_, from, to);
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case get_element_ptr_by_value_: {
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case get_element_ptr_by_variable_: {
      ReplaceUse(instruction.pointer_, from, to);
      ReplaceUse(instruction.index_, from, to);
      break;
    }
    case non_void_call_:
    case void_call_:
    case builtin_call_: {
      for (auto &argument : instruction.function_call_arguments_) {
        if (argument.is_variable_) {
          ReplaceUse(argument.value_, from, to);
        }
      }
      break;
    }
    case value_select_ii_:
    case value_select_iv_:
    case value_select_vi_:
    case value_select_vv_:
    case variable_select_ii_:
    case variable_select_iv_:
    case variable_select_vi_:
    case variable_select_vv_: {
      if (instruction.instruction_type_ == variable_select_ii_ ||
          instruction.instruction_type_ == variable_select_iv_ ||
          instruction.instruction_type_ == variable_select_vi_ ||
          instruction.instruction_type_ == variable_select_vv_) {
        ReplaceUse(instruction.condition_id_, from, to);
      }
      if (instruction.instruction_type_ == value_select_ii_ ||
          instruction.instruction_type_ == value_select_iv_ ||
          instruction.instruction_type_ == variable_select_ii_ ||
          instruction.instruction_type_ == variable_select_iv_) {
        ReplaceUse(instruction.operand_1_id_, from, to);
      }
      if (instruction.instruction_type_ == value_select_ii_ ||
          instruction.instruction_type_ == value_select_vi_ ||
          instruction.instruction_type_ == variable_select_ii_ ||
          instruction.instruction_type_ == variable_select_vi_) {
        ReplaceUse(instruction.operand_2_id_, from, to);
      }
      break;
    }
    case builtin_memset_: {
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    case builtin_memcpy_: {
      ReplaceUse(instruction.destination_, from, to);
      ReplaceUse(instruction.pointer_, from, to);
      break;
    }
    default:
      break;
  }
}

void ReplacePhiUses(PhiInstruction &instruction, const int from, const int to) {
  for (auto &condition : instruction.conditions) {
    if (!condition.is_const) {
      ReplaceUse(condition.var_id, from, to);
    }
  }
}

void ReplaceAllUses(IRFunctionNode &function, const int from, const int to) {
  for (auto &[block_id, block] : function.blocks_) {
    for (auto &phi : block.phi_instructions_) {
      ReplacePhiUses(phi, from, to);
    }
    for (auto &instruction : block.instructions_) {
      ReplaceInstructionUses(instruction, from, to);
    }
  }
}

bool TryForwardReturnSlot(IRFunctionNode &function) {
  if (function.return_type_ == nullptr ||
      (function.return_type_->basic_type != array_type &&
       function.return_type_->basic_type != struct_type) ||
      function.parameter_types_.empty()) {
    return false;
  }
  for (int i = 0; i + 1 < function.parameter_types_.size(); ++i) {
    if (function.parameter_types_[i]->basic_type == pointer_type) {
      return false;
    }
  }

  const int return_ptr_id = static_cast<int>(function.parameter_types_.size() - 1);
  const auto alloca_ids = CollectAllocaIds(function);
  const auto use_count = CountVariableUses(function);
  const auto return_use = use_count.find(return_ptr_id);
  if (return_use == use_count.end() || return_use->second != 1) {
    return false;
  }

  int return_block_id = -1;
  int copy_index = -1;
  int source_ptr_id = -1;
  for (auto &[block_id, block] : function.blocks_) {
    auto &instructions = block.instructions_;
    if (instructions.size() < 2) {
      continue;
    }
    const int maybe_copy_index = static_cast<int>(instructions.size()) - 2;
    const auto &copy = instructions[maybe_copy_index];
    const auto &ret = instructions.back();
    if (copy.instruction_type_ == builtin_memcpy_ &&
        ret.instruction_type_ == void_ret_ &&
        copy.destination_ == return_ptr_id &&
        copy.pointer_ != return_ptr_id &&
        alloca_ids.contains(copy.pointer_)) {
      if (return_block_id != -1) {
        return false;
      }
      return_block_id = block_id;
      copy_index = maybe_copy_index;
      source_ptr_id = copy.pointer_;
    }
  }
  if (return_block_id == -1) {
    return false;
  }

  ReplaceAllUses(function, source_ptr_id, return_ptr_id);
  auto &instructions = function.blocks_[return_block_id].instructions_;
  instructions.erase(instructions.begin() + copy_index);
  return true;
}

bool IsAggregateReturnToTemp(const IRInstruction &call_instruction,
    const IRInstruction &copy_instruction, const std::set<int> &alloca_ids,
    const std::map<int, int> &use_count) {
  if (call_instruction.instruction_type_ != void_call_ ||
      copy_instruction.instruction_type_ != builtin_memcpy_ ||
      call_instruction.function_call_arguments_.empty()) {
    return false;
  }

  const auto &return_argument = call_instruction.function_call_arguments_.back();
  if (!return_argument.is_variable_ || return_argument.type_ == nullptr ||
      return_argument.type_->basic_type != pointer_type ||
      return_argument.value_ != copy_instruction.pointer_ ||
      copy_instruction.destination_ == copy_instruction.pointer_ ||
      !alloca_ids.contains(copy_instruction.pointer_)) {
    return false;
  }
  for (int i = 0; i + 1 < call_instruction.function_call_arguments_.size(); ++i) {
    const auto &argument = call_instruction.function_call_arguments_[i];
    if (argument.is_variable_ && argument.value_ == copy_instruction.destination_) {
      return false;
    }
  }

  const auto use_it = use_count.find(copy_instruction.pointer_);
  return use_it != use_count.end() && use_it->second == 2;
}

bool IsMemsetTempCopiedToDest(const IRInstruction &set_instruction,
    const IRInstruction &copy_instruction, const std::set<int> &alloca_ids,
    const std::map<int, int> &use_count) {
  if (set_instruction.instruction_type_ != builtin_memset_ ||
      copy_instruction.instruction_type_ != builtin_memcpy_ ||
      set_instruction.pointer_ != copy_instruction.pointer_ ||
      set_instruction.result_id_ != copy_instruction.result_id_ ||
      copy_instruction.destination_ == copy_instruction.pointer_ ||
      !alloca_ids.contains(copy_instruction.pointer_)) {
    return false;
  }

  const auto use_it = use_count.find(copy_instruction.pointer_);
  return use_it != use_count.end() && use_it->second == 2;
}

bool IsMemcpyForwardable(const IRInstruction &first_copy,
    const IRInstruction &second_copy, const std::set<int> &alloca_ids,
    const std::map<int, int> &use_count) {
  if (first_copy.instruction_type_ != builtin_memcpy_ ||
      second_copy.instruction_type_ != builtin_memcpy_ ||
      first_copy.destination_ != second_copy.pointer_ ||
      first_copy.result_id_ != second_copy.result_id_ ||
      second_copy.destination_ == second_copy.pointer_ ||
      !alloca_ids.contains(second_copy.pointer_)) {
    return false;
  }

  const auto use_it = use_count.find(second_copy.pointer_);
  return use_it != use_count.end() && use_it->second == 2;
}

bool IsScalarIRType(const std::shared_ptr<IntegratedType> &type) {
  if (type == nullptr) {
    return false;
  }
  switch (type->basic_type) {
    case bool_type:
    case i32_type:
    case u32_type:
    case isize_type:
    case usize_type:
    case enumeration_type:
    case pointer_type:
    case unit_type:
      return true;
    default:
      return false;
  }
}

bool IsInlineTerminator(const IRInstructionType type) {
  return type == conditional_br_ || type == unconditional_br_ ||
      type == value_ret_ || type == variable_ret_ || type == void_ret_;
}

std::vector<int> InstructionSuccessors(const IRInstruction &instruction) {
  if (instruction.instruction_type_ == conditional_br_) {
    return {instruction.if_true_, instruction.if_false_};
  }
  if (instruction.instruction_type_ == unconditional_br_) {
    return {instruction.destination_};
  }
  return {};
}

bool HasCycleFromBlock(const IRFunctionNode &function, const int block_id,
    std::map<int, int> &color) {
  color[block_id] = 1;
  const auto block_it = function.blocks_.find(block_id);
  if (block_it == function.blocks_.end() || block_it->second.instructions_.empty()) {
    color[block_id] = 2;
    return false;
  }
  for (const int succ : InstructionSuccessors(block_it->second.instructions_.back())) {
    if (!function.blocks_.contains(succ)) {
      continue;
    }
    if (color[succ] == 1) {
      return true;
    }
    if (color[succ] == 0 && HasCycleFromBlock(function, succ, color)) {
      return true;
    }
  }
  color[block_id] = 2;
  return false;
}

bool HasCFGCycle(const IRFunctionNode &function) {
  std::map<int, int> color;
  for (const auto &[block_id, block] : function.blocks_) {
    color[block_id] = 0;
  }
  for (const auto &[block_id, block] : function.blocks_) {
    if (color[block_id] == 0 && HasCycleFromBlock(function, block_id, color)) {
      return true;
    }
  }
  return false;
}

bool IsInlineSafeInstruction(const IRInstruction &instruction) {
  switch (instruction.instruction_type_) {
    case two_var_binary_operation_:
    case var_const_binary_operation_:
    case const_var_binary_operation_:
    case conditional_br_:
    case unconditional_br_:
    case value_ret_:
    case variable_ret_:
    case void_ret_:
    case load_:
    case ptr_load_:
    case variable_store_:
    case value_store_:
    case ptr_store_:
    case two_var_icmp_:
    case var_const_icmp_:
    case const_var_icmp_:
    case value_select_ii_:
    case value_select_iv_:
    case value_select_vi_:
    case value_select_vv_:
    case variable_select_ii_:
    case variable_select_iv_:
    case variable_select_vi_:
    case variable_select_vv_:
      return true;
    default:
      return false;
  }
}

struct InlineCandidateInfo {
  bool eligible = false;
  bool is_single_block = false;
  int instruction_count = 0;
  int block_count = 0;
  int conditional_branch_count = 0;
};

InlineCandidateInfo AnalyzeInlineCandidate(const IRFunctionNode &function) {
  InlineCandidateInfo info;
  info.block_count = static_cast<int>(function.blocks_.size());
  if (!IsScalarIRType(function.return_type_)) {
    return info;
  }
  for (const auto &type : function.parameter_types_) {
    if (!IsScalarIRType(type) || type->basic_type == unit_type) {
      return info;
    }
  }
  if (function.blocks_.empty() || HasCFGCycle(function)) {
    return info;
  }

  info.instruction_count = static_cast<int>(function.alloca_instructions_.size());
  int return_count = 0;
  const int entry_block = function.blocks_.begin()->first;
  for (const auto &alloca : function.alloca_instructions_) {
    if (!IsScalarIRType(alloca.result_type_) || alloca.result_type_->basic_type == unit_type) {
      return info;
    }
  }
  for (const auto &[block_id, block] : function.blocks_) {
    if (block.instructions_.empty()) {
      return info;
    }
    if (block_id == entry_block && !block.phi_instructions_.empty()) {
      return info;
    }
    for (const auto &phi : block.phi_instructions_) {
      if (!IsScalarIRType(phi.type) || phi.type->basic_type == unit_type) {
        return info;
      }
      ++info.instruction_count;
    }
    for (int i = 0; i < static_cast<int>(block.instructions_.size()); ++i) {
      const auto &instruction = block.instructions_[i];
      if (!IsInlineSafeInstruction(instruction)) {
        return info;
      }
      if (instruction.instruction_type_ == non_void_call_ ||
          instruction.instruction_type_ == void_call_ ||
          instruction.instruction_type_ == builtin_call_) {
        return info;
      }
      if (IsInlineTerminator(instruction.instruction_type_) &&
          i + 1 != static_cast<int>(block.instructions_.size())) {
        return info;
      }
      if (instruction.instruction_type_ == conditional_br_) {
        ++info.conditional_branch_count;
      }
      if (instruction.instruction_type_ == variable_ret_ ||
          instruction.instruction_type_ == value_ret_ ||
          instruction.instruction_type_ == void_ret_) {
        ++return_count;
      }
      ++info.instruction_count;
    }
  }
  if (return_count != 1) {
    return info;
  }

  info.is_single_block = info.block_count == 1;
  info.eligible = (info.is_single_block && info.instruction_count <= 12) ||
      (!info.is_single_block && info.block_count <= 4 &&
       info.conditional_branch_count <= 1 && info.instruction_count <= 16);
  return info;
}

std::map<int, int> CountFunctionCalls(const std::vector<IRFunctionNode> &functions) {
  std::map<int, int> call_count;
  for (const auto &function : functions) {
    for (const auto &[block_id, block] : function.blocks_) {
      for (const auto &instruction : block.instructions_) {
        if (instruction.instruction_type_ == non_void_call_ ||
            instruction.instruction_type_ == void_call_) {
          ++call_count[instruction.function_name_];
        }
      }
    }
  }
  return call_count;
}

int CountFunctionInstructions(const IRFunctionNode &function) {
  int instruction_count = static_cast<int>(function.alloca_instructions_.size());
  for (const auto &[block_id, block] : function.blocks_) {
    instruction_count += static_cast<int>(block.phi_instructions_.size());
    instruction_count += static_cast<int>(block.instructions_.size());
  }
  return instruction_count;
}

int CountCallsInFunction(const IRFunctionNode &function) {
  int call_count = 0;
  for (const auto &[block_id, block] : function.blocks_) {
    for (const auto &instruction : block.instructions_) {
      if (instruction.instruction_type_ == non_void_call_ ||
          instruction.instruction_type_ == void_call_) {
        ++call_count;
      }
    }
  }
  return call_count;
}

bool ShouldInlineCall(const IRFunctionNode &caller, const int caller_id,
    const int main_function_id, const InlineCandidateInfo &callee_info,
    const int total_callee_call_count) {
  if (!callee_info.eligible) {
    return false;
  }
  if (callee_info.is_single_block) {
    return total_callee_call_count == 1 || callee_info.instruction_count <= 12;
  }

  const int caller_instruction_count = CountFunctionInstructions(caller);
  if (total_callee_call_count == 1 && caller_instruction_count <= 80) {
    return true;
  }

  const bool small_wrapper = caller_id != main_function_id &&
      !HasCFGCycle(caller) &&
      caller.blocks_.size() <= 2 &&
      caller_instruction_count <= 48 &&
      CountCallsInFunction(caller) <= 2;
  return small_wrapper && callee_info.instruction_count <= 16;
}

} // namespace

void IRVisitor::AddFunction(const std::shared_ptr<IntegratedType> &return_type) {
  functions_.push_back(IRFunctionNode(return_type));
}
void IRVisitor::AddStruct() {
  structs_.push_back(IRStructNode());
}

std::pair<int, bool> IRVisitor::GetTypeSize(const std::shared_ptr<IntegratedType> &type) {
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
      const auto element_size = GetTypeSize(type->element_type);
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
        const auto &[item_size, is_aligned] = GetTypeSize(item_info.node->integrated_type_);
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
      IRThrow("Invalid type to get size.");
    }
  }
  return {0, false};
}

Expression *IRVisitor::GetDirectAggregateInitializer(Node *node) const {
  auto *expression = dynamic_cast<Expression *>(node);
  if (expression == nullptr) {
    return nullptr;
  }
  if (expression->GetExprType() == grouped_expr && expression->children_.size() >= 2) {
    return GetDirectAggregateInitializer(expression->children_[1]);
  }
  if (expression->GetExprType() == array_expr || expression->GetExprType() == struct_expr) {
    return expression;
  }
  return nullptr;
}

void IRVisitor::InitializeAggregateInto(Node *node, const int ptr_id) {
  if (auto *initializer = GetDirectAggregateInitializer(node)) {
    RecursiveInitialize(initializer, ptr_id);
    node->IR_var_ID_ = ptr_id;
    node->IR_ID_ = -1;
    return;
  }
  node->Accept(this);
}

void IRVisitor::RecursiveInitialize(const Node *expression_ptr, const int ptr_id) {
  auto &function = functions_[wrapping_functions_.back()];
  const auto &integrated_type = expression_ptr->integrated_type_;
  if (integrated_type->basic_type == array_type) {
    const auto basic_type = integrated_type->element_type->basic_type; // the type of the elements of the array
    if (basic_type == char_type || basic_type == str_type || basic_type == string_type) {
      IRThrow("Invalid type in IR.");
    }
    if (expression_ptr->children_.size() != 5 ||
        dynamic_cast<LeafNode *>(expression_ptr->children_[2])->GetContent().GetStr() != ";") { // [(Expression (, Expression)* ,?)?]
      for (int i = 0; i < integrated_type->size; ++i) {
        const int element_ptr_id = function.var_id_++;
        function.blocks_[block_stack_.back()].AddGetElementPtrByValue(element_ptr_id, integrated_type, ptr_id, i);
        // %element_ptr_id <- *expression_ptr->children_[2 * i + 1]
        if (basic_type == pointer_type) {
          expression_ptr->children_[2 * i + 1]->Accept(this);
          function.blocks_[block_stack_.back()].AddVariableStore(integrated_type->element_type,
              expression_ptr->children_[2 * i + 1]->IR_var_ID_, element_ptr_id);
        } else if (basic_type == array_type || basic_type == struct_type) {
          InitializeAggregateInto(expression_ptr->children_[2 * i + 1], element_ptr_id);
          if (expression_ptr->children_[2 * i + 1]->IR_var_ID_ != element_ptr_id) {
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinMemcpy(
                GetTypeSize(expression_ptr->children_[2 * i + 1]->integrated_type_).first,
                element_ptr_id, expression_ptr->children_[2 * i + 1]->IR_var_ID_);
          }
        } else if (!expression_ptr->children_[2 * i + 1]->integrated_type_->is_const) {
          expression_ptr->children_[2 * i + 1]->Accept(this);
          if (expression_ptr->children_[2 * i + 1]->IR_ID_ == -1 &&
              expression_ptr->children_[2 * i + 1]->IR_var_ID_ != -1) {
            expression_ptr->children_[2 * i + 1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                expression_ptr->children_[2 * i + 1]->IR_ID_, expression_ptr->children_[2 * i + 1]->integrated_type_,
                expression_ptr->children_[2 * i + 1]->IR_var_ID_);
          }
          function.blocks_[block_stack_.back()].AddVariableStore(integrated_type->element_type,
              expression_ptr->children_[2 * i + 1]->IR_ID_, element_ptr_id);
        } else {
          function.blocks_[block_stack_.back()].AddValueStore(integrated_type->element_type,
              static_cast<int>(expression_ptr->children_[2 * i + 1]->value_.int_value), element_ptr_id);
        }
      }
    } else { // [Expression; Expression]
      if (basic_type == pointer_type) {
        expression_ptr->children_[1]->Accept(this);
        for (int i = 0; i < integrated_type->size; ++i) {
          const int element_ptr_id = function.var_id_++;
          function.blocks_[block_stack_.back()].AddGetElementPtrByValue(element_ptr_id, integrated_type, ptr_id, i);
          function.blocks_[block_stack_.back()].AddVariableStore(integrated_type->element_type,
              expression_ptr->children_[1]->IR_var_ID_, element_ptr_id);
        }
      } else if (basic_type == array_type || basic_type == struct_type) {
        expression_ptr->children_[1]->Accept(this);
        if (expression_ptr->children_[1]->IR_var_ID_ != -1) {
          const int rounds = static_cast<int>(integrated_type->size);
          const int var_in_loop = function.var_id_++;
          function.AddAlloca(var_in_loop, expression_ptr->children_[3]->integrated_type_);
          function.blocks_[block_stack_.back()].AddValueStore(expression_ptr->children_[3]->integrated_type_,
              0, var_in_loop);
          // initialize elements in loop structure
          const int condition_check = function.var_id_++;
          function.blocks_[condition_check] = IRBlock();
          const int loop_begin = function.var_id_++;
          function.blocks_[loop_begin] = IRBlock();
          const int loop_end = function.var_id_++;
          function.blocks_[loop_end] = IRBlock();
          wrapping_loops_.push_back({condition_check, loop_end});
          function.blocks_[block_stack_.back()].AddUnconditionalBranch(condition_check);
          // complete condition_check
          block_stack_.back() = condition_check;
          const int loaded_var_in_loop = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(loaded_var_in_loop,
            expression_ptr->children_[3]->integrated_type_, var_in_loop);
          const int compare_result = function.var_id_++;
          function.blocks_[block_stack_.back()].AddVarConstIcmp(compare_result, unsigned_less_than_,
              expression_ptr->children_[3]->integrated_type_, loaded_var_in_loop, rounds);
          function.blocks_[block_stack_.back()].AddConditionalBranch(compare_result,
              loop_begin, loop_end);
          // complete loop_begin
          block_stack_.back() = loop_begin;
          const int element_ptr = function.var_id_++;
          const int loaded_index = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(loaded_index,
              expression_ptr->children_[3]->integrated_type_, var_in_loop);
          function.blocks_[block_stack_.back()].AddGetElementPtrByVariable(element_ptr,
              expression_ptr->integrated_type_, ptr_id, loaded_index);
          function.blocks_[block_stack_.back()].AddBuiltinMemcpy(
              GetTypeSize(expression_ptr->integrated_type_->element_type).first,
              element_ptr, expression_ptr->children_[1]->IR_var_ID_);
          // *var_in_loop += 1
          const int original_value = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(original_value,
              expression_ptr->children_[3]->integrated_type_, var_in_loop);
          const int temp_add_result = function.var_id_++;
          function.blocks_[block_stack_.back()].AddVarConstBinaryOperation(expression_ptr->children_[3]->integrated_type_,
              add_, temp_add_result, original_value, 1);
          function.blocks_[block_stack_.back()].AddVariableStore(expression_ptr->children_[3]->integrated_type_,
              temp_add_result, var_in_loop);
          function.blocks_[block_stack_.back()].AddUnconditionalBranch(condition_check);
          // loop end
          block_stack_.back() = loop_end;
          wrapping_loops_.pop_back();
        } else {
          IRThrow("Array/struct without pointer cannot be memcpy.");
        }
      } else if (!expression_ptr->children_[1]->integrated_type_->is_const) {
        expression_ptr->children_[1]->Accept(this);
        if (expression_ptr->children_[1]->IR_ID_ == -1 &&
            expression_ptr->children_[1]->IR_var_ID_ != -1) {
          expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
              expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
              expression_ptr->children_[1]->IR_var_ID_);
        }
        for (int i = 0; i < integrated_type->size; ++i) {
          const int element_ptr_id = function.var_id_++;
          function.blocks_[block_stack_.back()].AddGetElementPtrByValue(element_ptr_id, integrated_type, ptr_id, i);
          function.blocks_[block_stack_.back()].AddVariableStore(integrated_type->element_type,
              expression_ptr->children_[1]->IR_ID_, element_ptr_id);
        }
      } else {
        if (expression_ptr->children_[1]->value_.int_value == 0) {
          const auto type_size = GetTypeSize(expression_ptr->integrated_type_);
          function.blocks_[block_stack_.back()].AddBuiltinMemset(type_size.first, false, ptr_id);
        } else if (expression_ptr->children_[1]->value_.int_value == -1) {
          const auto type_size = GetTypeSize(expression_ptr->integrated_type_);
          function.blocks_[block_stack_.back()].AddBuiltinMemset(type_size.first, true, ptr_id);
        } else {
          const int rounds = static_cast<int>(integrated_type->size);
          const int var_in_loop = function.var_id_++;
          function.AddAlloca(var_in_loop, expression_ptr->children_[3]->integrated_type_);
          function.blocks_[block_stack_.back()].AddValueStore(expression_ptr->children_[3]->integrated_type_,
              0, var_in_loop);
          // initialize elements in loop structure
          const int condition_check = function.var_id_++;
          function.blocks_[condition_check] = IRBlock();
          const int loop_begin = function.var_id_++;
          function.blocks_[loop_begin] = IRBlock();
          const int loop_end = function.var_id_++;
          function.blocks_[loop_end] = IRBlock();
          wrapping_loops_.push_back({condition_check, loop_end});
          function.blocks_[block_stack_.back()].AddUnconditionalBranch(condition_check);
          // complete condition_check
          block_stack_.back() = condition_check;
          const int loaded_var_in_loop = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(loaded_var_in_loop,
            expression_ptr->children_[3]->integrated_type_, var_in_loop);
          const int compare_result = function.var_id_++;
          function.blocks_[block_stack_.back()].AddVarConstIcmp(compare_result, unsigned_less_than_,
              expression_ptr->children_[3]->integrated_type_, loaded_var_in_loop, rounds);
          function.blocks_[block_stack_.back()].AddConditionalBranch(compare_result,
              loop_begin, loop_end);
          // complete loop_begin
          block_stack_.back() = loop_begin;
          const int element_ptr = function.var_id_++;
          const int loaded_index = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(loaded_index,
              expression_ptr->children_[3]->integrated_type_, var_in_loop);
          function.blocks_[block_stack_.back()].AddGetElementPtrByVariable(element_ptr,
              expression_ptr->integrated_type_, ptr_id, loaded_index);
          function.blocks_[block_stack_.back()].AddValueStore(integrated_type->element_type,
                static_cast<int>(expression_ptr->children_[1]->value_.int_value), element_ptr);
          // *var_in_loop += 1
          const int original_value = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(original_value,
              expression_ptr->children_[3]->integrated_type_, var_in_loop);
          const int temp_add_result = function.var_id_++;
          function.blocks_[block_stack_.back()].AddVarConstBinaryOperation(expression_ptr->children_[3]->integrated_type_,
              add_, temp_add_result, original_value, 1);
          function.blocks_[block_stack_.back()].AddVariableStore(expression_ptr->children_[3]->integrated_type_,
              temp_add_result, var_in_loop);
          function.blocks_[block_stack_.back()].AddUnconditionalBranch(condition_check);
          // loop end
          block_stack_.back() = loop_end;
          wrapping_loops_.pop_back();
        }
      }
    }
  } else if (integrated_type->basic_type == struct_type) {
    if (expression_ptr->children_.size() == 3) {
      IRThrow("Empty struct expression!");
    }
    const auto struct_expr_fields = expression_ptr->children_[2];
    const auto struct_def_ptr = dynamic_cast<Struct *>(integrated_type->struct_node);
    for (int i = 0; i < struct_def_ptr->field_item_index_.size(); ++i) {
      // i-th struct_expr_field: struct_expr_fields->children_[2 * i]
      const std::string &item_name = dynamic_cast<LeafNode *>(struct_expr_fields->children_[2 * i]
          ->children_[0])->GetContent().GetStr();
      const int item_index = struct_def_ptr->field_item_index_[item_name];
      const int target_item_id = function.var_id_++;
      const auto item_expr_ptr = dynamic_cast<Expression *>(struct_expr_fields->children_[2 * i]->children_[2]);
      function.blocks_[block_stack_.back()].AddGetElementPtrByValue(target_item_id, integrated_type, ptr_id, item_index);
      // %target_item_id <- *item_expr_ptr
      const auto basic_type = item_expr_ptr->integrated_type_->basic_type;
      if (basic_type == char_type || basic_type == str_type || basic_type == string_type) {
        IRThrow("Invalid type in IR.");
      }
      if (basic_type == pointer_type) {
        struct_expr_fields->children_[2 * i]->children_[2]->Accept(this);
        function.blocks_[block_stack_.back()].AddVariableStore(item_expr_ptr->integrated_type_,
            struct_expr_fields->children_[2 * i]->children_[2]->IR_var_ID_, target_item_id);
      } else if (basic_type == array_type || basic_type == struct_type) {
        InitializeAggregateInto(struct_expr_fields->children_[2 * i]->children_[2], target_item_id);
        if (struct_expr_fields->children_[2 * i]->children_[2]->IR_var_ID_ != target_item_id) {
          function.blocks_[block_stack_.back()].AddBuiltinMemcpy(
              GetTypeSize(struct_expr_fields->children_[2 * i]->children_[2]->integrated_type_).first,
              target_item_id, struct_expr_fields->children_[2 * i]->children_[2]->IR_var_ID_);
        }
      } else if (!item_expr_ptr->integrated_type_->is_const) {
        struct_expr_fields->children_[2 * i]->children_[2]->Accept(this);
        if (struct_expr_fields->children_[2 * i]->children_[2]->IR_ID_ == -1 &&
            struct_expr_fields->children_[2 * i]->children_[2]->IR_var_ID_ != -1) {
          struct_expr_fields->children_[2 * i]->children_[2]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
              struct_expr_fields->children_[2 * i]->children_[2]->IR_ID_,
              struct_expr_fields->children_[2 * i]->children_[2]->integrated_type_,
              struct_expr_fields->children_[2 * i]->children_[2]->IR_var_ID_);
        }
        function.blocks_[block_stack_.back()].AddVariableStore(item_expr_ptr->integrated_type_,
            struct_expr_fields->children_[2 * i]->children_[2]->IR_ID_, target_item_id);
      } else {
        function.blocks_[block_stack_.back()].AddValueStore(item_expr_ptr->integrated_type_,
            static_cast<int>(item_expr_ptr->value_.int_value), target_item_id);
      }
    }
  } else {
    IRThrow("Recursive initializing shouldn't be used except when initalizing array or struct.");
  }
}

void IRVisitor::DeclareItems(const std::shared_ptr<ScopeNode> &new_scope) {
  for (const auto &it : new_scope->type_namespace) {
    if (it.second.node_type == type_struct) {
      it.second.node->IR_ID_ = static_cast<int>(structs_.size());
      AddStruct();
      for (const auto &associated_item :
          dynamic_cast<Struct *>(it.second.node)->associated_items_) {
        if (associated_item.second.node_type == type_function) {
          associated_item.second.node->IR_ID_ = static_cast<int>(functions_.size());
          AddFunction(associated_item.second.node->integrated_type_);
        }
      }
    }
  }
  for (const auto &it : new_scope->value_namespace) {
    if (it.second.node_type == type_function && it.second.node != nullptr) {
      it.second.node->IR_ID_ = static_cast<int>(functions_.size());
      AddFunction(it.second.node->integrated_type_);
      if (main_function_id_ == -1 &&
          dynamic_cast<LeafNode *>(it.second.node->children_[1])->GetContent().GetStr() == "main") {
        main_function_id_ = it.second.node->IR_ID_;
      }
    }
  }
}

int IRVisitor::GetBlockValue(Node *visited_statements_ptr, const std::shared_ptr<IntegratedType> &expected_type) {
  if (expected_type->basic_type == unit_type || visited_statements_ptr->integrated_type_->basic_type == never_type) {
    return -1;
  }
  const int variable_id = functions_[wrapping_functions_.back()].var_id_++;
  if (visited_statements_ptr->type_.back() == type_expression) {
    if (visited_statements_ptr->children_.back()->integrated_type_->is_const) {
      const int value = static_cast<int>(visited_statements_ptr->children_.back()->value_.int_value);
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b111,
          variable_id, 1, expected_type, value, expected_type, value);
    } else {
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b100,
          variable_id, 1, expected_type,
          visited_statements_ptr->children_.back()->IR_ID_,
          expected_type, visited_statements_ptr->children_.back()->IR_ID_);
    }
  } else { // expression statement
    functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b100,
        variable_id, 1, expected_type,
        visited_statements_ptr->children_.back()->children_[0]->IR_ID_,
        expected_type, visited_statements_ptr->children_.back()->children_[0]->IR_ID_);
  }
  return variable_id;
}

Expression *IRVisitor::GetLogicalNode(Node *node) const {
  auto *expression = dynamic_cast<Expression *>(node);
  if (expression == nullptr) {
    return nullptr;
  }
  if (expression->GetExprType() == grouped_expr && expression->children_.size() >= 2) {
    return GetLogicalNode(expression->children_[1]);
  }
  const Infix infix = expression->GetExprInfix();
  if (infix == logic_and || infix == logic_or) {
    return expression;
  }
  return nullptr;
}

int IRVisitor::EnsureValue(Node *expression_ptr) {
  expression_ptr->Accept(this);
  if (expression_ptr->IR_ID_ == -1 && expression_ptr->IR_var_ID_ != -1) {
    expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
    functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
        expression_ptr->IR_ID_, expression_ptr->integrated_type_, expression_ptr->IR_var_ID_);
  }
  return expression_ptr->IR_ID_;
}

void IRVisitor::EmitConditionBranch(Node *condition_ptr, const int true_branch,
    const int false_branch) {
  if (auto *logic_expression = GetLogicalNode(condition_ptr)) {
    EmitLogicalBranch(logic_expression, true_branch, false_branch);
    return;
  }
  const int condition_id = EnsureValue(condition_ptr);
  functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddConditionalBranch(
      condition_id, true_branch, false_branch);
}

void IRVisitor::EmitLogicalBranch(Expression *expression_ptr, const int true_branch,
    const int false_branch) {
  auto &function = functions_[wrapping_functions_.back()];
  const auto &current_instructions = function.blocks_[block_stack_.back()].instructions_;
  if (!current_instructions.empty()) {
    const auto last_instruction_type = current_instructions.back().instruction_type_;
    if (last_instruction_type == value_ret_ || last_instruction_type == variable_ret_ ||
        last_instruction_type == void_ret_ || last_instruction_type == conditional_br_ ||
        last_instruction_type == unconditional_br_) {
      IRThrow("Cannot emit logical expression after a terminated block.");
    }
  }

  struct LogicalTask {
    Node *node;
    int begin;
    int if_true;
    int if_false;
  };
  std::vector<LogicalTask> tasks;
  tasks.push_back({expression_ptr, block_stack_.back(), true_branch, false_branch});

  for (int i = 0; i < tasks.size(); ++i) {
    auto [node, begin, if_true, if_false] = tasks[i];
    auto *logic_expression = GetLogicalNode(node);
    if (logic_expression != nullptr) {
      const int right_begin = function.var_id_++;
      function.blocks_[right_begin] = IRBlock();
      if (logic_expression->GetExprInfix() == logic_and) {
        tasks.push_back({logic_expression->children_[0], begin, right_begin, if_false});
        tasks.push_back({logic_expression->children_[1], right_begin, if_true, if_false});
      } else {
        tasks.push_back({logic_expression->children_[0], begin, if_true, right_begin});
        tasks.push_back({logic_expression->children_[1], right_begin, if_true, if_false});
      }
      continue;
    }

    block_stack_.back() = begin;
    if (node->integrated_type_->is_const) {
      function.blocks_[begin].AddUnconditionalBranch(
          node->value_.int_value ? if_true : if_false);
      continue;
    }
    const int value_id = EnsureValue(node);
    function.blocks_[block_stack_.back()].AddConditionalBranch(value_id, if_true, if_false);
  }
}

void IRVisitor::EmitLogicalExpression(Expression *expression_ptr) {
  auto &function = functions_[wrapping_functions_.back()];
  const int true_branch = function.var_id_++;
  function.blocks_[true_branch] = IRBlock();
  const int false_branch = function.var_id_++;
  function.blocks_[false_branch] = IRBlock();
  const int merged_label = function.var_id_++;
  EmitLogicalBranch(expression_ptr, true_branch, false_branch);
  function.blocks_[true_branch].AddUnconditionalBranch(merged_label);
  function.blocks_[false_branch].AddUnconditionalBranch(merged_label);
  function.blocks_[merged_label] = IRBlock();
  block_stack_.back() = merged_label;
  expression_ptr->IR_ID_ = function.var_id_++;
  function.blocks_[block_stack_.back()].AddPhi(expression_ptr->IR_ID_,
      expression_ptr->integrated_type_, 1, true_branch, true);
  function.blocks_[block_stack_.back()].AddPhi(expression_ptr->IR_ID_,
      expression_ptr->integrated_type_, 0, false_branch, true);
}

void IRVisitor::OptimizeAggregateCopies() {
  for (auto &function : functions_) {
    bool changed = false;
    do {
      changed = false;
      if (TryForwardReturnSlot(function)) {
        changed = true;
      }
      const auto alloca_ids = CollectAllocaIds(function);
      const auto use_count = CountVariableUses(function);
      for (auto &[block_id, block] : function.blocks_) {
        auto &instructions = block.instructions_;
        for (int i = 0; i + 1 < instructions.size();) {
          auto &first = instructions[i];
          auto &second = instructions[i + 1];
          if (IsAggregateReturnToTemp(first, second, alloca_ids, use_count)) {
            first.function_call_arguments_.back().value_ = second.destination_;
            instructions.erase(instructions.begin() + i + 1);
            changed = true;
            continue;
          }
          if (IsMemsetTempCopiedToDest(first, second, alloca_ids, use_count)) {
            first.pointer_ = second.destination_;
            instructions.erase(instructions.begin() + i + 1);
            changed = true;
            continue;
          }
          if (IsMemcpyForwardable(first, second, alloca_ids, use_count)) {
            second.pointer_ = first.pointer_;
            instructions.erase(instructions.begin() + i);
            changed = true;
            continue;
          }
          ++i;
        }
      }
    } while (changed);

    const auto use_count = CountVariableUses(function);
    std::vector<IRInstruction> remaining_allocas;
    remaining_allocas.reserve(function.alloca_instructions_.size());
    for (const auto &instruction : function.alloca_instructions_) {
      if (use_count.contains(instruction.result_id_)) {
        remaining_allocas.push_back(instruction);
      }
    }
    function.alloca_instructions_ = std::move(remaining_allocas);
  }
}

void IRVisitor::OptimizeShortFunctions() {
  bool changed = false;
  int inline_rounds = 0;
  do {
    changed = false;
    ++inline_rounds;
    const auto function_call_count = CountFunctionCalls(functions_);
    std::map<int, InlineCandidateInfo> inline_candidates;
    for (int func_id = 0; func_id < static_cast<int>(functions_.size()); ++func_id) {
      if (func_id == main_function_id_) {
        continue;
      }
      const auto call_it = function_call_count.find(func_id);
      if (call_it == function_call_count.end() || call_it->second == 0) {
        continue;
      }
      auto info = AnalyzeInlineCandidate(functions_[func_id]);
      if (info.eligible) {
        inline_candidates[func_id] = info;
      }
    }
    if (inline_candidates.empty()) {
      break;
    }

    for (int caller_id = 0; caller_id < static_cast<int>(functions_.size()); ++caller_id) {
      auto &caller = functions_[caller_id];
      std::vector<int> original_block_ids;
      original_block_ids.reserve(caller.blocks_.size());
      for (const auto &[block_id, block] : caller.blocks_) {
        original_block_ids.push_back(block_id);
      }

      for (const int original_block_id : original_block_ids) {
        auto original_it = caller.blocks_.find(original_block_id);
        if (original_it == caller.blocks_.end()) {
          continue;
        }
        const IRBlock original_block = original_it->second;
        bool block_changed = false;
        IRBlock rebuilt_block;
        rebuilt_block.phi_instructions_ = original_block.phi_instructions_;
        caller.blocks_[original_block_id] = std::move(rebuilt_block);

        int current_block_id = original_block_id;
        auto *current_block = &caller.blocks_[current_block_id];

        auto update_successor_phis = [&](const int old_pred, const int new_pred) {
          if (old_pred == new_pred || current_block->instructions_.empty()) {
            return;
          }
          for (const int successor : InstructionSuccessors(current_block->instructions_.back())) {
            auto successor_it = caller.blocks_.find(successor);
            if (successor_it == caller.blocks_.end()) {
              continue;
            }
            for (auto &phi : successor_it->second.phi_instructions_) {
              for (auto &condition : phi.conditions) {
                if (condition.from_block_id == old_pred) {
                  condition.from_block_id = new_pred;
                }
              }
            }
          }
        };

        auto inline_call = [&](const IRInstruction &call_instruction) {
          const auto &callee = functions_[call_instruction.function_name_];
          std::map<int, int> var_map;
          for (int arg_id = 0; arg_id < static_cast<int>(call_instruction.function_call_arguments_.size());
               ++arg_id) {
            const auto &argument = call_instruction.function_call_arguments_[arg_id];
            if (argument.is_variable_) {
              var_map[arg_id] = argument.value_;
            } else {
              const int temp_id = caller.var_id_++;
              current_block->AddSelect(0b111, temp_id, 1, callee.parameter_types_[arg_id],
                  argument.value_, callee.parameter_types_[arg_id], argument.value_);
              var_map[arg_id] = temp_id;
            }
          }
          for (const auto &alloca : callee.alloca_instructions_) {
            const int new_id = caller.var_id_++;
            var_map[alloca.result_id_] = new_id;
            auto cloned_alloca = alloca;
            cloned_alloca.result_id_ = new_id;
            caller.alloca_instructions_.push_back(cloned_alloca);
          }

          std::map<int, int> block_map;
          const int callee_entry = callee.blocks_.begin()->first;
          for (const auto &[callee_block_id, block] : callee.blocks_) {
            block_map[callee_block_id] =
                (callee_block_id == callee_entry) ? current_block_id : caller.var_id_++;
          }
          const int after_block_id = caller.var_id_++;

          auto map_var = [&](const int old_id) {
            if (old_id < 0) {
              return old_id;
            }
            const auto mapped = var_map.find(old_id);
            if (mapped != var_map.end()) {
              return mapped->second;
            }
            const int new_id = caller.var_id_++;
            var_map[old_id] = new_id;
            return new_id;
          };

          auto map_instruction = [&](IRInstruction instruction) {
            switch (instruction.instruction_type_) {
              case two_var_binary_operation_:
              case two_var_icmp_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case var_const_binary_operation_:
              case var_const_icmp_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                break;
              case const_var_binary_operation_:
              case const_var_icmp_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case conditional_br_:
                instruction.condition_id_ = map_var(instruction.condition_id_);
                instruction.if_true_ = block_map.at(instruction.if_true_);
                instruction.if_false_ = block_map.at(instruction.if_false_);
                break;
              case unconditional_br_:
                instruction.destination_ = block_map.at(instruction.destination_);
                break;
              case load_:
              case ptr_load_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.pointer_ = map_var(instruction.pointer_);
                break;
              case variable_store_:
              case ptr_store_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.pointer_ = map_var(instruction.pointer_);
                break;
              case value_store_:
                instruction.pointer_ = map_var(instruction.pointer_);
                break;
              case value_select_ii_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case value_select_iv_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                break;
              case value_select_vi_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case value_select_vv_:
                instruction.result_id_ = map_var(instruction.result_id_);
                break;
              case variable_select_ii_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.condition_id_ = map_var(instruction.condition_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case variable_select_iv_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.condition_id_ = map_var(instruction.condition_id_);
                instruction.operand_1_id_ = map_var(instruction.operand_1_id_);
                break;
              case variable_select_vi_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.condition_id_ = map_var(instruction.condition_id_);
                instruction.operand_2_id_ = map_var(instruction.operand_2_id_);
                break;
              case variable_select_vv_:
                instruction.result_id_ = map_var(instruction.result_id_);
                instruction.condition_id_ = map_var(instruction.condition_id_);
                break;
              default:
                break;
            }
            return instruction;
          };

          caller.blocks_[after_block_id] = IRBlock();
          for (const auto &[callee_block_id, callee_block] : callee.blocks_) {
            const int target_block_id = block_map.at(callee_block_id);
            auto &target_block = caller.blocks_[target_block_id];
            if (target_block_id != current_block_id) {
              target_block = IRBlock();
            }
            if (callee_block_id != callee_entry) {
              for (const auto &phi : callee_block.phi_instructions_) {
                PhiInstruction mapped_phi(map_var(phi.result_id), phi.type);
                for (const auto &condition : phi.conditions) {
                  if (condition.is_const) {
                    mapped_phi.conditions.push_back(PhiCondition(
                        block_map.at(condition.from_block_id), true, condition.value, -1));
                  } else {
                    mapped_phi.conditions.push_back(PhiCondition(
                        block_map.at(condition.from_block_id), false, 0, map_var(condition.var_id)));
                  }
                }
                target_block.phi_instructions_.push_back(mapped_phi);
              }
            }
            for (const auto &instruction : callee_block.instructions_) {
              if (instruction.instruction_type_ == value_ret_) {
                if (call_instruction.instruction_type_ == non_void_call_) {
                  target_block.AddSelect(0b111, call_instruction.result_id_, 1,
                      call_instruction.result_type_, instruction.result_id_,
                      call_instruction.result_type_, instruction.result_id_);
                }
                target_block.AddUnconditionalBranch(after_block_id);
              } else if (instruction.instruction_type_ == variable_ret_) {
                if (call_instruction.instruction_type_ == non_void_call_) {
                  const int mapped_ret = map_var(instruction.result_id_);
                  target_block.AddSelect(0b100, call_instruction.result_id_, 1,
                      call_instruction.result_type_, mapped_ret,
                      call_instruction.result_type_, mapped_ret);
                }
                target_block.AddUnconditionalBranch(after_block_id);
              } else if (instruction.instruction_type_ == void_ret_) {
                target_block.AddUnconditionalBranch(after_block_id);
              } else {
                target_block.instructions_.push_back(map_instruction(instruction));
              }
            }
          }
          current_block_id = after_block_id;
          current_block = &caller.blocks_[current_block_id];
        };

        for (const auto &instruction : original_block.instructions_) {
          if ((instruction.instruction_type_ == non_void_call_ ||
               instruction.instruction_type_ == void_call_) &&
              instruction.function_name_ != caller_id &&
              inline_candidates.contains(instruction.function_name_)) {
            const auto &callee = functions_[instruction.function_name_];
            const auto call_count_it = function_call_count.find(instruction.function_name_);
            const int callee_call_count = (call_count_it == function_call_count.end()) ? 0 :
                call_count_it->second;
            const auto &candidate_info = inline_candidates.at(instruction.function_name_);
            if (instruction.function_call_arguments_.size() == callee.parameter_types_.size() &&
                ((instruction.instruction_type_ == non_void_call_ &&
                  callee.return_type_->basic_type != unit_type) ||
                 (instruction.instruction_type_ == void_call_ &&
                  callee.return_type_->basic_type == unit_type)) &&
                ShouldInlineCall(caller, caller_id, main_function_id_, candidate_info,
                    callee_call_count)) {
              inline_call(instruction);
              block_changed = true;
              changed = true;
              continue;
            }
          }
          current_block->instructions_.push_back(instruction);
        }

        if (block_changed) {
          update_successor_phis(original_block_id, current_block_id);
          if (current_block->instructions_.empty()) {
            current_block->AddVoidReturn();
          }
        } else {
          caller.blocks_[original_block_id] = original_block;
        }
      }
    }
  } while (changed && inline_rounds < 3);
}

int IRVisitor::GetPreviousBlockHelper(const int func_id, const int start_block, const int target_block,
    std::set<int> &visited_block) const {
  const auto &last_instruction = functions_[func_id].blocks_.at(start_block).instructions_.back();
  if (last_instruction.instruction_type_ == unconditional_br_) {
    const int next_block = last_instruction.destination_;
    if (next_block == target_block) {
      return start_block;
    }
    if (visited_block.contains(next_block)) {
      return -1;
    }
    visited_block.insert(next_block);
    return GetPreviousBlockHelper(func_id, next_block, target_block, visited_block);
  }
  if (functions_[func_id].blocks_.at(start_block).instructions_.back().instruction_type_ == conditional_br_) {
    const int block1 = last_instruction.if_true_, block2 = last_instruction.if_false_;
    if (visited_block.contains(block1) && visited_block.contains(block2)) {
      return -1;
    }
    if (visited_block.contains(block1)) { // block2 has not been visited
      visited_block.insert(block2);
      return GetPreviousBlockHelper(func_id, block2, target_block, visited_block);
    }
    if (visited_block.contains(block2)) { // block1 has not been visited
      visited_block.insert(block1);
      return GetPreviousBlockHelper(func_id, block1, target_block, visited_block);
    }
    // block1 and block2 all not been visited
    visited_block.insert(block1);
    const int ans1 = GetPreviousBlockHelper(func_id, block1, target_block, visited_block);
    if (ans1 != -1 || visited_block.contains(block2)) {
      return ans1;
    }
    visited_block.insert(block2);
    return GetPreviousBlockHelper(func_id, block2, target_block, visited_block);
  }
  return -1;
}

int IRVisitor::GetPreviousBlock(const int func_id, const int start_block, const int target_block) const {
  std::set<int> visited_block;
  visited_block.insert(start_block);
  return GetPreviousBlockHelper(func_id, start_block, target_block, visited_block);
}

void IRVisitor::Visit(Trait *trait_ptr) {}
void IRVisitor::Visit(Implementation *implementation_ptr) {}
void IRVisitor::Visit(Enumeration *enumeration_ptr) {}
void IRVisitor::Visit(Keyword *keyword_ptr) {}
void IRVisitor::Visit(Identifier *identifier_ptr) {}
void IRVisitor::Visit(Punctuation *punctuation_ptr) {}
void IRVisitor::Visit(FunctionReturnType *function_return_type_ptr) {}
void IRVisitor::Visit(RawStringLiteral *raw_string_literal_ptr) {}
void IRVisitor::Visit(CStringLiteral *c_string_literal_ptr) {}
void IRVisitor::Visit(RawCStringLiteral *raw_c_string_literal_ptr) {}
void IRVisitor::Visit(StructFields *struct_fields_ptr) {}
void IRVisitor::Visit(StructField *struct_field_ptr) {}
void IRVisitor::Visit(EnumVariants *enum_variants_ptr) {}
void IRVisitor::Visit(AssociatedItem *associated_item_ptr) {}
void IRVisitor::Visit(Type *type_ptr) {}
void IRVisitor::Visit(Pattern *pattern_ptr) {}
void IRVisitor::Visit(ReferencePattern *reference_pattern_ptr) {}
void IRVisitor::Visit(IdentifierPattern *identifier_pattern_ptr) {}
void IRVisitor::Visit(ReferenceType *reference_type_ptr) {}
void IRVisitor::Visit(ArrayType *array_type_ptr) {}
void IRVisitor::Visit(UnitType *unit_type_ptr) {}
void IRVisitor::Visit(FunctionParameters *function_parameters_ptr) {}
void IRVisitor::Visit(SelfParam *self_param_ptr) {}
void IRVisitor::Visit(FunctionParam *function_param_ptr) {}
void IRVisitor::Visit(ShorthandSelf *shorthand_self_ptr) {}
void IRVisitor::Visit(ConstantItem *constant_item_ptr) {}
void IRVisitor::Visit(TypePath *type_path_ptr) {}
void IRVisitor::Visit(PathInExpression *path_in_expression_ptr) {}
void IRVisitor::Visit(PathExprSegment *path_expr_segment_ptr) {}
void IRVisitor::Visit(StructExprFields *struct_expr_fields_ptr) {}
void IRVisitor::Visit(StructExprField *struct_expr_field_ptr) {}
void IRVisitor::Visit(CharLiteral *char_literal_ptr) {}
void IRVisitor::Visit(IntegerLiteral *integer_literal_ptr) {}
void IRVisitor::Visit(Crate *crate_ptr) {
  // collect and declare the structs and functions
  DeclareItems(crate_ptr->scope_node_);
  for (const auto &it : crate_ptr->children_) {
    if (it->type_[0] == type_struct) {
      it->Accept(this);
    }
  }
  for (const auto &it : crate_ptr->children_) {
    it->Accept(this);
  }
  OptimizeAggregateCopies();
  OptimizeShortFunctions();
  OptimizeAggregateCopies();
}
void IRVisitor::Visit(Item *item_ptr) {
  item_ptr->children_[0]->Accept(this);
}
void IRVisitor::Visit(Struct *struct_ptr) {
  auto &struct_elements = structs_[struct_ptr->IR_ID_].element_type_;
  if (struct_elements.empty()) {
    for (const auto &it : struct_ptr->field_items_) {
      const auto element_type = it.second.node->integrated_type_;
      const int element_index = static_cast<int>(struct_elements.size());
      struct_elements.push_back(element_type);
      struct_ptr->field_item_index_[it.first] = element_index;
    }
  } else {
    for (const auto &associated_item :
      struct_ptr->associated_items_) {
      if (associated_item.second.node_type == type_function) {
        associated_item.second.node->Accept(this);
      }
    }
  }
}
void IRVisitor::Visit(Function *function_ptr) {
  const int function_id = function_ptr->IR_ID_;
  wrapping_functions_.push_back(function_id);
  block_stack_.push_back(0);
  functions_[wrapping_functions_.back()].blocks_[0] = IRBlock();
  int function_parameters_index = -1;
  int block_expression_index = -1;
  for (int i = 0; i < function_ptr->children_.size(); ++i) {
    if (function_ptr->type_[i] == type_function_parameters) {
      function_parameters_index = i;
    } else if (function_ptr->type_[i] == type_block_expression) {
      block_expression_index = i;
    }
  }
  // visit parameters
  if (function_parameters_index == -1) {
    if (function_ptr->integrated_type_->basic_type == array_type ||
          function_ptr->integrated_type_->basic_type == struct_type) {
      auto &function_parameter_types = functions_[function_id].parameter_types_;
      functions_[wrapping_functions_.back()].var_id_ += 1;
      function_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      const auto return_ptr_type = std::make_shared<IntegratedType>(pointer_type,
          false, false, false, true, 0);
      return_ptr_type->element_type = function_ptr->integrated_type_;
      function_parameter_types.push_back(return_ptr_type);
    }
  } else {
    if (function_ptr->integrated_type_->basic_type == array_type ||
        function_ptr->integrated_type_->basic_type == struct_type) {
      auto &function_parameter_types = functions_[function_id].parameter_types_;
      functions_[wrapping_functions_.back()].var_id_ +=
          static_cast<int>((function_ptr->children_[function_parameters_index]->children_.size() + 1) / 2) + 1;
      for (int j = 0; j < function_ptr->children_[function_parameters_index]->children_.size(); j += 2) {
        function_ptr->children_[function_parameters_index]->children_[j]->IR_var_ID_
            = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].AddAlloca(function_ptr->children_[function_parameters_index]
            ->children_[j]->IR_var_ID_, function_ptr->children_[function_parameters_index]->children_[j]->integrated_type_);
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableStore(function_ptr->
            children_[function_parameters_index]->children_[j]->integrated_type_, j / 2,
            function_ptr->children_[function_parameters_index]->children_[j]->IR_var_ID_);
        function_ptr->children_[function_parameters_index]->children_[j]->IR_ID_ =
            static_cast<int>(function_parameter_types.size());
        function_parameter_types.push_back(function_ptr->children_[function_parameters_index]
            ->children_[j]->integrated_type_);
      }
      function_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      const auto return_ptr_type = std::make_shared<IntegratedType>(pointer_type,
          false, false, false, true, 0);
      return_ptr_type->element_type = function_ptr->integrated_type_;
      function_parameter_types.push_back(return_ptr_type);
    } else {
      auto &function_parameter_types = functions_[function_id].parameter_types_;
      functions_[wrapping_functions_.back()].var_id_ +=
          static_cast<int>((function_ptr->children_[function_parameters_index]->children_.size() + 1) / 2);
      for (int j = 0; j < function_ptr->children_[function_parameters_index]->children_.size(); j += 2) {
        function_ptr->children_[function_parameters_index]->children_[j]->IR_var_ID_
            = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].AddAlloca(function_ptr->children_[function_parameters_index]
            ->children_[j]->IR_var_ID_, function_ptr->children_[function_parameters_index]->children_[j]->integrated_type_);
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableStore(function_ptr->
            children_[function_parameters_index]->children_[j]->integrated_type_, j / 2,
            function_ptr->children_[function_parameters_index]->children_[j]->IR_var_ID_);
        function_ptr->children_[function_parameters_index]->children_[j]->IR_ID_ =
            static_cast<int>(function_parameter_types.size());
        function_parameter_types.push_back(function_ptr->children_[function_parameters_index]
            ->children_[j]->integrated_type_);
      }
    }
  }
  // visit block expression
  DeclareItems(function_ptr->children_[block_expression_index]->scope_node_);
  function_ptr->children_[block_expression_index]->Accept(this);

  // handle return
  if (functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].instructions_.empty()) {
    if (function_ptr->integrated_type_->basic_type == array_type ||
        function_ptr->integrated_type_->basic_type == struct_type) {
      const int ptr_index = static_cast<int>(functions_[wrapping_functions_.back()].parameter_types_.size() - 1);
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinMemcpy(
          GetTypeSize(function_ptr->integrated_type_).first,
          ptr_index, function_ptr->children_[block_expression_index]->IR_var_ID_);
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
    } else if (function_ptr->children_[block_expression_index]->IR_ID_ == -1) {
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
    } else {
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableReturn(
          function_ptr->integrated_type_, function_ptr->children_[block_expression_index]->IR_ID_);
    }
  } else {
    const auto type = functions_[wrapping_functions_.back()].blocks_[block_stack_.back()]
      .instructions_.back().instruction_type_;
    if (type != conditional_br_ && type != unconditional_br_ && type != value_ret_
        && type != variable_ret_ && type != void_ret_) {
      if (function_ptr->integrated_type_->basic_type == array_type ||
        function_ptr->integrated_type_->basic_type == struct_type) {
        const int ptr_index = static_cast<int>(functions_[wrapping_functions_.back()].parameter_types_.size() - 1);
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinMemcpy(
            GetTypeSize(function_ptr->integrated_type_).first,
            ptr_index, function_ptr->children_[block_expression_index]->IR_var_ID_);
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
      } else if (function_ptr->children_[block_expression_index]->IR_ID_ == -1) {
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
      } else {
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableReturn(
            function_ptr->integrated_type_, function_ptr->children_[block_expression_index]->IR_ID_);
      }
    }
  }
  wrapping_functions_.pop_back();
  block_stack_.pop_back();
}
void IRVisitor::Visit(BlockExpression *block_expression_ptr) {
  if (block_expression_ptr->type_[1] == type_statements) {
    block_expression_ptr->children_[1]->Accept(this);
  }
  block_expression_ptr->IR_ID_ = block_expression_ptr->children_[1]->IR_ID_;
  block_expression_ptr->IR_var_ID_ = block_expression_ptr->children_[1]->IR_var_ID_;
}
void IRVisitor::Visit(Statements *statements_ptr) {
  for (int i = 0; i < statements_ptr->children_.size(); ++i) {
    if (statements_ptr->type_[i] == type_statement &&
        statements_ptr->children_[i]->type_[0] == type_item &&
        statements_ptr->children_[i]->children_[0]->type_[0] == type_struct) {
      statements_ptr->children_[i]->Accept(this);
    }
  }
  for (int i = 0; i + 1 < statements_ptr->children_.size(); ++i) { // visit statement
    statements_ptr->children_[i]->Accept(this);
  }
  if (statements_ptr->type_.back() == type_expression) {
    const auto basic_type = statements_ptr->children_.back()->integrated_type_->basic_type;
    if (basic_type == array_type || basic_type == struct_type) {
      statements_ptr->children_.back()->Accept(this);
      statements_ptr->IR_ID_ = statements_ptr->children_.back()->IR_ID_;
      statements_ptr->IR_var_ID_ = statements_ptr->children_.back()->IR_var_ID_;
    } else if (basic_type == pointer_type || !statements_ptr->children_.back()->integrated_type_->is_const) {
      statements_ptr->children_.back()->Accept(this);
      if (statements_ptr->children_.back()->IR_ID_ == -1 &&
          statements_ptr->children_.back()->IR_var_ID_ != -1) {
        statements_ptr->children_.back()->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
            statements_ptr->children_.back()->IR_ID_, statements_ptr->children_.back()->integrated_type_,
            statements_ptr->children_.back()->IR_var_ID_);
      }
      statements_ptr->IR_ID_ = statements_ptr->children_.back()->IR_ID_;
    } else {
      statements_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      functions_[wrapping_functions_.back()].AddAlloca(statements_ptr->IR_var_ID_,
          statements_ptr->children_.back()->integrated_type_);
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddValueStore(
          statements_ptr->children_.back()->integrated_type_,
          static_cast<int>(statements_ptr->children_.back()->value_.int_value),
          statements_ptr->IR_var_ID_);
      statements_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
          statements_ptr->IR_ID_, statements_ptr->children_.back()->integrated_type_,
          statements_ptr->IR_var_ID_);
    }
  } else {
    statements_ptr->children_.back()->Accept(this);
    statements_ptr->IR_ID_ = statements_ptr->children_.back()->IR_ID_;
  }
}
void IRVisitor::Visit(Statement *statement_ptr) {
  statement_ptr->children_[0]->Accept(this);
  if (statement_ptr->type_[0] == type_expression_statement) {
    statement_ptr->IR_ID_ = statement_ptr->children_[0]->IR_ID_;
  }
}
void IRVisitor::Visit(LetStatement *let_statement_ptr) {
  auto &function = functions_[wrapping_functions_.back()];
  if (function.blocks_.empty()) {
    function.blocks_[0] = IRBlock();
    ++function.var_id_;
  }
  let_statement_ptr->children_[1]->IR_var_ID_ = function.var_id_++;
  function.AddAlloca(let_statement_ptr->children_[1]->IR_var_ID_, let_statement_ptr->children_[1]->integrated_type_);
  if (let_statement_ptr->children_[1]->integrated_type_->is_int ||
      let_statement_ptr->children_[1]->integrated_type_->basic_type == bool_type ||
      let_statement_ptr->children_[1]->integrated_type_->basic_type == enumeration_type) {
    if (let_statement_ptr->children_[5]->integrated_type_->is_const) {
      function.blocks_[block_stack_.back()].AddValueStore(let_statement_ptr->children_[1]->integrated_type_,
          static_cast<int>(let_statement_ptr->children_[5]->value_.int_value), let_statement_ptr->children_[1]->IR_var_ID_);
    } else {
      let_statement_ptr->children_[5]->Accept(this);
      if (let_statement_ptr->children_[5]->IR_ID_ == -1 &&
          let_statement_ptr->children_[5]->IR_var_ID_ != -1) {
        let_statement_ptr->children_[5]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
            let_statement_ptr->children_[5]->IR_ID_, let_statement_ptr->children_[5]->integrated_type_,
            let_statement_ptr->children_[5]->IR_var_ID_);
      }
      function.blocks_[block_stack_.back()].AddVariableStore(let_statement_ptr->children_[1]->integrated_type_,
          let_statement_ptr->children_[5]->IR_ID_, let_statement_ptr->children_[1]->IR_var_ID_);
    }
  } else if (let_statement_ptr->children_[1]->integrated_type_->basic_type == array_type ||
      let_statement_ptr->children_[1]->integrated_type_->basic_type == struct_type) {
    InitializeAggregateInto(let_statement_ptr->children_[5], let_statement_ptr->children_[1]->IR_var_ID_);
    if (let_statement_ptr->children_[5]->IR_var_ID_ != let_statement_ptr->children_[1]->IR_var_ID_) {
      function.blocks_[block_stack_.back()].AddBuiltinMemcpy(
          GetTypeSize(let_statement_ptr->children_[1]->integrated_type_).first,
          let_statement_ptr->children_[1]->IR_var_ID_, let_statement_ptr->children_[5]->IR_var_ID_);
    }
  } else if (let_statement_ptr->children_[1]->integrated_type_->basic_type == pointer_type) {
    let_statement_ptr->children_[5]->Accept(this);
    if (let_statement_ptr->children_[5]->IR_var_ID_ != -1) {
      let_statement_ptr->children_[1]->IR_var_ID_ = let_statement_ptr->children_[5]->IR_var_ID_;
    } else {
      function.blocks_[block_stack_.back()].AddVariableStore(let_statement_ptr->children_[1]->integrated_type_,
          let_statement_ptr->children_[5]->IR_ID_, let_statement_ptr->children_[1]->IR_var_ID_);
    }
  } else {
    IRThrow("There is a basic type that not implemented in LetStatement!");
  }
}
void IRVisitor::Visit(ExpressionStatement *expression_statement_ptr) {
  const auto expr_type = expression_statement_ptr->integrated_type_->basic_type;
  if (expr_type == array_type || expr_type == struct_type || expr_type == pointer_type
      || !expression_statement_ptr->children_[0]->integrated_type_->is_const) {
    expression_statement_ptr->children_[0]->Accept(this);
    if (expression_statement_ptr->children_.size() == 1) {
      expression_statement_ptr->IR_var_ID_ = expression_statement_ptr->children_[0]->IR_var_ID_;
      expression_statement_ptr->IR_ID_ = expression_statement_ptr->children_[0]->IR_ID_;
    }
  } else if (expression_statement_ptr->children_.size() == 1) {
    expression_statement_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
    functions_[wrapping_functions_.back()].AddAlloca(expression_statement_ptr->IR_var_ID_,
        expression_statement_ptr->integrated_type_);
    functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddValueStore(
        expression_statement_ptr->integrated_type_, static_cast<int>(expression_statement_ptr
        ->children_[0]->value_.int_value), expression_statement_ptr->IR_var_ID_);
    expression_statement_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
    functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
        expression_statement_ptr->IR_ID_, expression_statement_ptr->integrated_type_,
        expression_statement_ptr->IR_var_ID_);
  }
}
void IRVisitor::Visit(StringLiteral *string_literal_ptr) {
  IRThrow("String is not implemented.");
}
void IRVisitor::Visit(Expression *expression_ptr) {
  switch (expression_ptr->GetExprType()) {
    case block_expr: {
      if (expression_ptr->children_.size() == 3) {
        DeclareItems(expression_ptr->children_[1]->scope_node_);
        expression_ptr->children_[1]->Accept(this);
        expression_ptr->IR_ID_ = GetBlockValue(expression_ptr->children_[1], expression_ptr->integrated_type_);
      }
      break;
    }
    case infinite_loop_expr: {
      const int loop_begin = functions_[wrapping_functions_.back()].var_id_++;
      functions_[wrapping_functions_.back()].blocks_[loop_begin] = IRBlock();
      const int loop_end = functions_[wrapping_functions_.back()].var_id_++;
      functions_[wrapping_functions_.back()].blocks_[loop_end] = IRBlock();
      if (expression_ptr->integrated_type_->basic_type != unit_type &&
          expression_ptr->integrated_type_->basic_type != never_type) {
        expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      }
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
          AddUnconditionalBranch(loop_begin);
      // complete loop_begin
      block_stack_.back() = loop_begin;
      wrapping_loops_.push_back({loop_begin, loop_end, expression_ptr->IR_ID_,
          wrapping_functions_.back()});
      if (expression_ptr->children_.size() == 3) {
        IRThrow("Empty indefinite loop!");
      }
      DeclareItems(expression_ptr->children_[2]->scope_node_);
      expression_ptr->children_[2]->Accept(this);
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
          AddUnconditionalBranch(loop_begin);
      wrapping_loops_.pop_back();
      block_stack_.back() = loop_end;
      break;
    }
    case predicate_loop_expr: {
      if (expression_ptr->children_[2]->integrated_type_->is_const) {
        if (expression_ptr->children_[2]->value_.int_value == 1) { // infinite loop
          const int loop_begin = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[loop_begin] = IRBlock();
          const int loop_end = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[loop_end] = IRBlock();
          if (expression_ptr->integrated_type_->basic_type != unit_type &&
              expression_ptr->integrated_type_->basic_type != never_type) {
            expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          }
          wrapping_loops_.push_back({loop_begin, loop_end, expression_ptr->IR_ID_,
              wrapping_functions_.back()});
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
              AddUnconditionalBranch(loop_begin);
          // loop_begin
          block_stack_.back() = loop_begin;
          if (expression_ptr->children_.size() == 7) {
            DeclareItems(expression_ptr->children_[5]->scope_node_);
            expression_ptr->children_[5]->Accept(this);
          } else {
            IRThrow("Empty indefinite loop!");
          }
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
              AddUnconditionalBranch(loop_begin);
          // loop_end
          block_stack_.back() = loop_end;
          wrapping_loops_.pop_back();
        } else { // skip
          break;
        }
      } else {
        const int condition_check = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[condition_check] = IRBlock();
        const int loop_begin = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[loop_begin] = IRBlock();
        const int loop_end = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[loop_end] = IRBlock();
        wrapping_loops_.push_back({condition_check, loop_end});
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
            AddUnconditionalBranch(condition_check);
        // complete condition_check
        block_stack_.back() = condition_check;
        EmitConditionBranch(expression_ptr->children_[2], loop_begin, loop_end);
        // complete loop_begin
        block_stack_.back() = loop_begin;
        if (expression_ptr->children_.size() == 7) {
          DeclareItems(expression_ptr->children_[5]->scope_node_);
          expression_ptr->children_[5]->Accept(this);
        }
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
            AddUnconditionalBranch(condition_check);
        block_stack_.back() = loop_end;
        wrapping_loops_.pop_back();
      }
      break;
    }
    case if_expr: {
      if (expression_ptr->children_.size() == 6) { // empty block, skip
        break;
      }
      if (expression_ptr->children_.size() == 7) { // only "if" branch
        if (expression_ptr->children_[2]->integrated_type_->is_const) {
          if (expression_ptr->children_[2]->value_.int_value == 0) { // always false, skip if_expr
            break;
          }
          // always true
          DeclareItems(expression_ptr->children_[5]->scope_node_);
          expression_ptr->children_[5]->Accept(this);
        } else { // whether enter "if" block depends on the condition expression
          const int if_block_id = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[if_block_id] = IRBlock();
          const int exit_if_block_id = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[exit_if_block_id] = IRBlock();
          EmitConditionBranch(expression_ptr->children_[2], if_block_id, exit_if_block_id);
          // complete if_label_block
          block_stack_.back() = if_block_id;
          DeclareItems(expression_ptr->children_[5]->scope_node_);
          expression_ptr->children_[5]->Accept(this);
          if (functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].instructions_.empty()) {
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
            block_stack_.back() = exit_if_block_id;
          } else {
            const auto last_instruction_type = functions_[wrapping_functions_.back()].
              blocks_[block_stack_.back()].instructions_.back().instruction_type_;
            if (last_instruction_type == value_ret_ || last_instruction_type == variable_ret_ ||
                last_instruction_type == void_ret_ || last_instruction_type == conditional_br_ ||
                last_instruction_type == unconditional_br_) { // the if block has ended
              block_stack_.back() = exit_if_block_id;
            } else {
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
              block_stack_.back() = exit_if_block_id;
            }
          }
        }
      } else { // has "else" branch
        if (expression_ptr->children_[2]->integrated_type_->is_const) {
          if (expression_ptr->children_[2]->value_.int_value == 1) { // always true
            if (expression_ptr->type_[5] == type_punctuation) { // empty "if" block
              break;
            }
            DeclareItems(expression_ptr->children_[5]->scope_node_);
            expression_ptr->children_[5]->Accept(this);
            expression_ptr->IR_ID_ = GetBlockValue(expression_ptr->children_[5], expression_ptr->integrated_type_);
          } else { // always false
            expression_ptr->children_.back()->Accept(this);
            expression_ptr->IR_ID_ = expression_ptr->children_.back()->IR_ID_;
          }
        } else { // entering which block depends on condition expression
          const int if_block_id = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[if_block_id] = IRBlock();
          const int else_block_id = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[else_block_id] = IRBlock();
          const int exit_if_block_id = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[exit_if_block_id] = IRBlock();
          // jump conditionally
          EmitConditionBranch(expression_ptr->children_[2], if_block_id, else_block_id);
          // complete if_label_block
          block_stack_.back() = if_block_id;
          DeclareItems(expression_ptr->children_[5]->scope_node_);
          expression_ptr->children_[5]->Accept(this);
          const int if_block_value = GetBlockValue(expression_ptr->children_[5], expression_ptr->integrated_type_);
          bool if_returns = true;
          if (functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].instructions_.empty()) {
            if_returns = false;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
          } else {
            const auto last_instruction_type_in_if = functions_[wrapping_functions_.back()].
              blocks_[block_stack_.back()].instructions_.back().instruction_type_;
            if (last_instruction_type_in_if != value_ret_ && last_instruction_type_in_if != variable_ret_ &&
                last_instruction_type_in_if != void_ret_ && last_instruction_type_in_if != conditional_br_ &&
                last_instruction_type_in_if != unconditional_br_) {
              if_returns = false;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
            }
          }
          // complete else_label_block
          block_stack_.back() = else_block_id;
          expression_ptr->children_.back()->Accept(this);
          bool else_returns = true;
          if (functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].instructions_.empty()) {
            else_returns = false;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
          } else {
            const auto last_instruction_type_in_else = functions_[wrapping_functions_.back()].
              blocks_[block_stack_.back()].instructions_.back().instruction_type_;
            if (last_instruction_type_in_else != value_ret_ && last_instruction_type_in_else != variable_ret_ &&
                last_instruction_type_in_else != void_ret_ && last_instruction_type_in_else != conditional_br_ &&
                last_instruction_type_in_else != unconditional_br_) {
              else_returns = false;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddUnconditionalBranch(exit_if_block_id);
            }
          }
          // back together
          if (if_returns && else_returns) {
            // remove block with index exit_if_block_id
            functions_[wrapping_functions_.back()].blocks_.erase(exit_if_block_id);
          } else {
            block_stack_.back() = exit_if_block_id;
            if (if_block_value != -1 && expression_ptr->children_.back()->IR_ID_ != -1) {
              expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              const int if_end_block = GetPreviousBlock(wrapping_functions_.back(), if_block_id,
                  exit_if_block_id);
              const int else_end_block = GetPreviousBlock(wrapping_functions_.back(), else_block_id,
                  exit_if_block_id);
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPhi(
                  expression_ptr->IR_ID_, expression_ptr->integrated_type_,
                  if_block_value, if_end_block, false);
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPhi(
                  expression_ptr->IR_ID_, expression_ptr->integrated_type_,
                  expression_ptr->children_.back()->IR_ID_, else_end_block, false);
              // functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b000,
              //     expression_ptr->IR_ID_, expression_ptr->children_[2]->IR_ID_,
              //     expression_ptr->integrated_type_, if_block_value,
              //     expression_ptr->integrated_type_, expression_ptr->children_.back()->IR_ID_);
            } else if (if_block_value != -1) {
              expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b100,
                  expression_ptr->IR_ID_, 1, expression_ptr->integrated_type_, if_block_value,
                  expression_ptr->integrated_type_, if_block_value);
            } else if (expression_ptr->children_.back()->IR_ID_ != -1) {
              expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddSelect(0b100,
                  expression_ptr->IR_ID_, 0, expression_ptr->integrated_type_, expression_ptr->children_.back()->IR_ID_,
                  expression_ptr->integrated_type_, expression_ptr->children_.back()->IR_ID_);
            }
            // If two blocks all returned, there shouldn't be select instruction.
          }
        }
      }
      break;
    }
    case literal_expr: {
      switch (expression_ptr->type_[0]) {
        case type_keyword:
        case type_integer_literal: {
          expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddValueStore(expression_ptr->integrated_type_,
              static_cast<int>(expression_ptr->value_.int_value), expression_ptr->IR_var_ID_);
          break;
        }
        case type_char_literal:
        case type_string_literal:
        case type_raw_string_literal:
        case type_c_string_literal:
        case type_raw_c_string_literal: {
          IRThrow("Invalid literal type in IR.");
          break;
        }
        default:;
      }
      break;
    }
    case path_in_expr: {
      expression_ptr->IR_var_ID_ = expression_ptr->GetDefInfo().node->IR_var_ID_;
      break;
    }
    case grouped_expr: {
      expression_ptr->children_[1]->Accept(this);
      expression_ptr->IR_ID_ = expression_ptr->children_[1]->IR_ID_;
      expression_ptr->IR_var_ID_ = expression_ptr->children_[1]->IR_var_ID_;
      break;
    }
    case array_expr:
    case struct_expr: {
      expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
      functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
      RecursiveInitialize(expression_ptr, expression_ptr->IR_var_ID_);
      break;
    }
    case index_expr: {
      expression_ptr->children_[0]->Accept(this);
      if (expression_ptr->children_[0]->integrated_type_->basic_type == array_type) {
        if (expression_ptr->children_[0]->IR_var_ID_ == -1) {
          IRThrow("Cannot get the element of a value.");
        }
        expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        if (expression_ptr->children_[1]->integrated_type_->is_const) {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByValue(
              expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_,
              expression_ptr->children_[0]->IR_var_ID_, static_cast<int>(expression_ptr->children_[1]->value_.int_value));
        } else {
          expression_ptr->children_[1]->Accept(this);
          if (expression_ptr->children_[1]->IR_ID_ == -1 &&
              expression_ptr->children_[1]->IR_var_ID_ != -1) {
            expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                expression_ptr->children_[1]->IR_var_ID_);
          }
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByVariable(
              expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_,
              expression_ptr->children_[0]->IR_var_ID_, expression_ptr->children_[1]->IR_ID_);
        }
      } else { // expression_ptr->children_[0]->integrated_type_->basic_type == pointer_type
        if (expression_ptr->children_[0]->IR_var_ID_ == -1) {
          IRThrow("Cannot dereference a value.");
        }
        const int dereferenced_id = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPtrLoad(dereferenced_id,
            expression_ptr->children_[0]->IR_var_ID_);
        expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        if (expression_ptr->children_[1]->integrated_type_->is_const) {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByValue(
              expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_->element_type,
              dereferenced_id, static_cast<int>(expression_ptr->children_[1]->value_.int_value));
        } else {
          expression_ptr->children_[1]->Accept(this);
          if (expression_ptr->children_[1]->IR_ID_ == -1 &&
              expression_ptr->children_[1]->IR_var_ID_ != -1) {
            expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                expression_ptr->children_[1]->IR_var_ID_);
          }
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByVariable(
              expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_->element_type,
              dereferenced_id, expression_ptr->children_[1]->IR_ID_);
        }
      }
      break;
    }
    case call_expr: {
      if (expression_ptr->GetDefInfo().node == nullptr) { // builtin
        std::string function_name = dynamic_cast<LeafNode *>(expression_ptr->children_[0]->children_[0])
            ->GetContent().GetStr();
        if (function_name == "printInt") {
          std::vector<FunctionCallArgument> argument_list(1);
          if (expression_ptr->children_[1]->children_[0]->integrated_type_->is_const) {
            argument_list[0].type_ = expression_ptr->children_[1]->children_[0]->integrated_type_;
            argument_list[0].is_variable_ = false;
            argument_list[0].value_ = static_cast<int>(expression_ptr->children_[1]->children_[0]->value_.int_value);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinCall(-1,
                nullptr, 0, argument_list);
          } else {
            expression_ptr->children_[1]->children_[0]->Accept(this);
            if (expression_ptr->children_[1]->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->children_[0]->IR_ID_,
                  expression_ptr->children_[1]->children_[0]->integrated_type_,
                  expression_ptr->children_[1]->children_[0]->IR_var_ID_);
            }
            argument_list[0].type_ = expression_ptr->children_[1]->children_[0]->integrated_type_;
            argument_list[0].is_variable_ = true;
            argument_list[0].value_ = expression_ptr->children_[1]->children_[0]->IR_ID_;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinCall(-1,
                nullptr, 0, argument_list);
          }
        } else if (function_name == "printlnInt") {
          std::vector<FunctionCallArgument> argument_list(1);
          if (expression_ptr->children_[1]->children_[0]->integrated_type_->is_const) {
            argument_list[0].type_ = expression_ptr->children_[1]->children_[0]->integrated_type_;
            argument_list[0].is_variable_ = false;
            argument_list[0].value_ = static_cast<int>(expression_ptr->children_[1]->children_[0]->value_.int_value);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinCall(-1,
                nullptr, 1, argument_list);
          } else {
            expression_ptr->children_[1]->children_[0]->Accept(this);
            if (expression_ptr->children_[1]->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->children_[0]->IR_ID_,
                  expression_ptr->children_[1]->children_[0]->integrated_type_,
                  expression_ptr->children_[1]->children_[0]->IR_var_ID_);
            }
            argument_list[0].type_ = expression_ptr->children_[1]->children_[0]->integrated_type_;
            argument_list[0].is_variable_ = true;
            argument_list[0].value_ = expression_ptr->children_[1]->children_[0]->IR_ID_;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinCall(-1,
                nullptr, 1, argument_list);
          }
        } else if (function_name == "getInt") {
          expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinCall(
              expression_ptr->IR_ID_, expression_ptr->integrated_type_, 2);
        } else if (function_name == "exit") {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
        } else {
          IRThrow("Invalid builtin (including print, println and getString).");
        }
      } else { // not builtin
        std::vector<FunctionCallArgument> argument_list;
        if (expression_ptr->children_.size() == 2) { // has call_params
          for (int i = 0; i < expression_ptr->children_[1]->children_.size(); i += 2) {
            const auto basic_type = expression_ptr->children_[1]->children_[i]->integrated_type_->basic_type;
            if (!expression_ptr->children_[1]->children_[i]->integrated_type_->is_const ||
                basic_type == array_type || basic_type == struct_type || basic_type == pointer_type) {
              expression_ptr->children_[1]->children_[i]->Accept(this);
              if (expression_ptr->children_[1]->children_[i]->IR_ID_ == -1 &&
                  expression_ptr->children_[1]->children_[i]->IR_var_ID_ != -1) {
                expression_ptr->children_[1]->children_[i]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[1]->children_[i]->IR_ID_,
                    expression_ptr->children_[1]->children_[i]->integrated_type_,
                    expression_ptr->children_[1]->children_[i]->IR_var_ID_);
              }
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[1]
                  ->children_[i]->integrated_type_, true,
                  expression_ptr->children_[1]->children_[i]->IR_ID_));
            } else {
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[1]
                  ->children_[i]->integrated_type_, false,
                  static_cast<int>(expression_ptr->children_[1]->children_[i]->value_.int_value)));
            }
          }
        }
        if (expression_ptr->integrated_type_->basic_type == array_type ||
            expression_ptr->integrated_type_->basic_type == struct_type) {
          expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
          const auto return_ptr_type = std::make_shared<IntegratedType>(pointer_type,
              false, false, false, true, 0);
          return_ptr_type->element_type = expression_ptr->integrated_type_;
          argument_list.push_back(FunctionCallArgument(return_ptr_type, true, expression_ptr->IR_var_ID_));
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidCall(
              expression_ptr->GetDefInfo().node->IR_ID_, argument_list);
        } else if (expression_ptr->integrated_type_->basic_type == unit_type) { // void call
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidCall(
              expression_ptr->GetDefInfo().node->IR_ID_, argument_list);
        } else { // non-void call
          expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddNonVoidCall(
              expression_ptr->IR_ID_, expression_ptr->integrated_type_,
              expression_ptr->GetDefInfo().node->IR_ID_, argument_list);
        }
      }
      break;
    }
    case method_call_expr: {
      if (expression_ptr->GetDefInfo().node == nullptr) { // builtin
        IRThrow("There is no builtin method in IR testcases.");
      } else { // not builtin
        std::vector<FunctionCallArgument> argument_list;
        const auto function_def_node = expression_ptr->GetDefInfo().node;
        if (expression_ptr->children_[0]->integrated_type_->basic_type == pointer_type) {
          switch (function_def_node->children_[3]->children_[0]->children_[0]->children_.size()) {
            case 1: { // self
              expression_ptr->children_[0]->Accept(this);
              if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                  expression_ptr->children_[0]->IR_var_ID_ != -1) {
                expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                    expression_ptr->children_[0]->IR_var_ID_);
              }
              const int loaded_reference_self_id = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  loaded_reference_self_id, expression_ptr->children_[0]->integrated_type_->element_type,
                  expression_ptr->children_[0]->IR_ID_);
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[0]->integrated_type_,
                  true, loaded_reference_self_id));
              break;
            }
            case 2:
            case 3: { // &self or &mut self
              expression_ptr->children_[0]->Accept(this);
              if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                  expression_ptr->children_[0]->IR_var_ID_ != -1) {
                expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                    expression_ptr->children_[0]->IR_var_ID_);
              }
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[0]->integrated_type_,
                  true, expression_ptr->children_[0]->IR_ID_));
              break;
            }
            default:;
          }
        } else {
          switch (function_def_node->children_[3]->children_[0]->children_[0]->children_.size()) {
            case 1: { // self
              expression_ptr->children_[0]->Accept(this);
              if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                  expression_ptr->children_[0]->IR_var_ID_ != -1) {
                expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                    expression_ptr->children_[0]->IR_var_ID_);
              }
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[0]->integrated_type_,
                  true, expression_ptr->children_[0]->IR_ID_));
              break;
            }
            case 2:
            case 3: { // &self or &mut self
              expression_ptr->children_[0]->Accept(this);
              if (expression_ptr->children_[0]->IR_var_ID_ == -1) {
                IRThrow("The 'self' is not a left value and cannot be borrowed.");
              }
              std::shared_ptr<IntegratedType> target_type;
              if (functions_[function_def_node->IR_ID_].parameter_types_.empty()) {
                for (int i = 0; i < function_def_node->children_.size(); ++i) {
                  if (function_def_node->type_[i] == type_function_parameters) {
                    target_type = function_def_node->children_[i]->children_[0]->integrated_type_;
                    break;
                  }
                }
              } else {
                target_type = functions_[function_def_node->IR_ID_].parameter_types_[0];
              }
              argument_list.push_back(FunctionCallArgument(target_type, true,
                  expression_ptr->children_[0]->IR_var_ID_));
              break;
            }
            default:;
          }
        }
        if (expression_ptr->children_.size() == 3) {
          for (int i = 0; i < expression_ptr->children_[2]->children_.size(); i += 2) {
            const auto basic_type = expression_ptr->children_[2]->children_[i]->integrated_type_->basic_type;
            if (!expression_ptr->children_[2]->children_[i]->integrated_type_->is_const ||
                basic_type == array_type || basic_type == struct_type || basic_type == pointer_type) {
              expression_ptr->children_[2]->children_[i]->Accept(this);
              if (expression_ptr->children_[2]->children_[i]->IR_ID_ == -1 &&
                  expression_ptr->children_[2]->children_[i]->IR_var_ID_ != -1) {
                expression_ptr->children_[2]->children_[i]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[2]->children_[i]->IR_ID_, expression_ptr->children_[2]->children_[i]->integrated_type_,
                    expression_ptr->children_[2]->children_[i]->IR_var_ID_);
              }
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[2]
                  ->children_[i]->integrated_type_, true,
                  expression_ptr->children_[2]->children_[i]->IR_ID_));
            } else {
              argument_list.push_back(FunctionCallArgument(expression_ptr->children_[2]
                  ->children_[i]->integrated_type_, false,
                  static_cast<int>(expression_ptr->children_[2]->children_[i]->value_.int_value)));
            }
          }
        }
        if (expression_ptr->integrated_type_->basic_type == array_type ||
            expression_ptr->integrated_type_->basic_type == struct_type) {
          expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
          const auto return_ptr_type = std::make_shared<IntegratedType>(pointer_type,
              false, false, false, true, 0);
          return_ptr_type->element_type = expression_ptr->integrated_type_;
          argument_list.push_back(FunctionCallArgument(return_ptr_type, true, expression_ptr->IR_var_ID_));
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidCall(
              expression_ptr->GetDefInfo().node->IR_ID_, argument_list);
        } else if (expression_ptr->integrated_type_->basic_type == unit_type) { // void call
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidCall(
              function_def_node->IR_ID_, argument_list);
        } else { // non-void call
          expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddNonVoidCall(
              expression_ptr->IR_ID_, expression_ptr->integrated_type_,
              function_def_node->IR_ID_, argument_list);
        }
      }
      break;
    }
    case field_expr: {
      expression_ptr->children_[0]->Accept(this);
      if (expression_ptr->children_[0]->integrated_type_->basic_type == struct_type) {
        const auto struct_ptr = dynamic_cast<Struct *>(expression_ptr->children_[0]->integrated_type_->struct_node);
        const std::string identifier_name = dynamic_cast<LeafNode *>(expression_ptr->children_[1]->
            children_[0]->children_[0])->GetContent().GetStr();
        expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        const int item_index = struct_ptr->field_item_index_[identifier_name];
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByValue(
            expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_,
            expression_ptr->children_[0]->IR_var_ID_, item_index);
      } else { // expression_ptr->children_[0]->integrated_type_->basic_type == pointer_type
        expression_ptr->children_[0]->Accept(this);
        const int dereferenced_id = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPtrLoad(dereferenced_id,
            expression_ptr->children_[0]->IR_var_ID_);
        const auto struct_ptr = dynamic_cast<Struct *>(expression_ptr->children_[0]
            ->integrated_type_->element_type->struct_node);
        const std::string identifier_name = dynamic_cast<LeafNode *>(expression_ptr->children_[1]->
            children_[0]->children_[0])->GetContent().GetStr();
        expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        const int item_index = struct_ptr->field_item_index_[identifier_name];
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddGetElementPtrByValue(
            expression_ptr->IR_var_ID_, expression_ptr->children_[0]->integrated_type_->element_type,
            dereferenced_id, item_index);
      }
      break;
    }
    case continue_expr: {
      functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
          AddUnconditionalBranch(wrapping_loops_.back().begin);
      break;
    }
    case break_expr: {
      if (expression_ptr->children_.size() == 1) {
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
            AddUnconditionalBranch(wrapping_loops_.back().end);
      } else {
        const auto basic_type = expression_ptr->children_[1]->integrated_type_->basic_type;
        if (expression_ptr->children_[1]->integrated_type_->is_const &&
            (expression_ptr->children_[1]->integrated_type_->is_int || basic_type == bool_type
            || basic_type == enumeration_type)) {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
              AddSelect(0b111, wrapping_loops_.back().var_id, 1,
              expression_ptr->children_[1]->integrated_type_,
              static_cast<int>(expression_ptr->children_[1]->value_.int_value),
              expression_ptr->children_[1]->integrated_type_,
              static_cast<int>(expression_ptr->children_[1]->value_.int_value));
        } else {
          expression_ptr->children_[1]->Accept(this);
          if (expression_ptr->children_[1]->IR_ID_ == -1 &&
              expression_ptr->children_[1]->IR_var_ID_ != -1) {
            expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                expression_ptr->children_[1]->IR_var_ID_);
          }
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
              AddSelect(0b100, wrapping_loops_.back().var_id, 1,
              expression_ptr->children_[1]->integrated_type_, expression_ptr->children_[1]->IR_ID_,
              expression_ptr->children_[1]->integrated_type_, expression_ptr->children_[1]->IR_ID_);
        }
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].
            AddUnconditionalBranch(wrapping_loops_.back().end);
      }
      break;
    }
    case return_expr: {
      if (expression_ptr->children_.size() == 1) {
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
      } else {
        const auto basic_type = expression_ptr->children_[1]->integrated_type_->basic_type;
        if ((expression_ptr->children_[1]->integrated_type_->is_int || basic_type == bool_type ||
            basic_type == enumeration_type) && expression_ptr->children_[1]->integrated_type_->is_const) {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddValueReturn(
              expression_ptr->children_[1]->integrated_type_,
              static_cast<int>(expression_ptr->children_[1]->value_.int_value));
        } else {
          expression_ptr->children_[1]->Accept(this);
          if (expression_ptr->children_[1]->integrated_type_->basic_type == array_type ||
              expression_ptr->children_[1]->integrated_type_->basic_type == struct_type) {
            const int ptr_index = static_cast<int>(functions_[wrapping_functions_.back()].parameter_types_.size() - 1);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinMemcpy(
                GetTypeSize(expression_ptr->children_[1]->integrated_type_).first,
                ptr_index, expression_ptr->children_[1]->IR_var_ID_);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVoidReturn();
          } else {
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
              expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableReturn(
                expression_ptr->children_[1]->integrated_type_, expression_ptr->children_[1]->IR_ID_);
          }
        }
      }
      break;
    }
    case prefix_expr: {
      std::string prefix = dynamic_cast<LeafNode *>(expression_ptr->children_[0])
          ->GetContent().GetStr();
      if (prefix == "-") {
        expression_ptr->children_[1]->Accept(this);
        if (expression_ptr->children_[1]->IR_ID_ == -1 &&
            expression_ptr->children_[1]->IR_var_ID_ != -1) {
          expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
              expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
              expression_ptr->children_[1]->IR_var_ID_);
        }
        expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddConstVarBinaryOperation(
            expression_ptr->integrated_type_, sub_, expression_ptr->IR_ID_, 0,
            expression_ptr->children_[1]->IR_ID_);
      } else if (prefix == "*") {
        expression_ptr->children_[1]->Accept(this);
        if (expression_ptr->children_[1]->IR_ID_ == -1 &&
            expression_ptr->children_[1]->IR_var_ID_ != -1) {
          expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
              expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
              expression_ptr->children_[1]->IR_var_ID_);
        }
        expression_ptr->IR_var_ID_ = expression_ptr->children_[1]->IR_ID_;
      } else if (prefix == "!") {
        expression_ptr->children_[1]->Accept(this);
        if (expression_ptr->children_[1]->IR_ID_ == -1 &&
            expression_ptr->children_[1]->IR_var_ID_ != -1) {
          expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
              expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
              expression_ptr->children_[1]->IR_var_ID_);
        }
        expression_ptr->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
        if (expression_ptr->integrated_type_->basic_type == bool_type) {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddConstVarBinaryOperation(
              expression_ptr->integrated_type_, sub_, expression_ptr->IR_ID_,
              1, expression_ptr->children_[1]->IR_ID_);
        } else {
          functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVarConstBinaryOperation(
              expression_ptr->integrated_type_, xor_, expression_ptr->IR_ID_,
              expression_ptr->children_[1]->IR_ID_, -1);
        }
      } else if (prefix == "&") {
        auto content_expr_ptr = expression_ptr->children_.back();
        const auto basic_type = content_expr_ptr->integrated_type_->basic_type;
        if (content_expr_ptr->integrated_type_->is_int || basic_type == bool_type ||
            basic_type == enumeration_type || basic_type == struct_type || basic_type == array_type) {
          content_expr_ptr->Accept(this);
          if (content_expr_ptr->IR_var_ID_ == -1) {
            const int new_left_value = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].AddAlloca(new_left_value, content_expr_ptr->integrated_type_);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableStore(
                content_expr_ptr->integrated_type_, content_expr_ptr->IR_ID_, new_left_value);
            expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPtrStore(new_left_value,
                expression_ptr->IR_var_ID_);
          } else {
            // the struct/array value has an allocated ptr %content_expr->IR_var_ID_
            expression_ptr->IR_var_ID_ = functions_[wrapping_functions_.back()].var_id_++;
            functions_[wrapping_functions_.back()].AddAlloca(expression_ptr->IR_var_ID_, expression_ptr->integrated_type_);
            // store the ptr %content_expr->IR_var_ID_ into %expression_ptr->IR_var_ID_
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddPtrStore(content_expr_ptr->IR_var_ID_,
                expression_ptr->IR_var_ID_);
          }
        } else {
          IRThrow("Invalid type for borrow expression in IR.");
        }
      } else if (prefix == "&&") {
        IRThrow("There is no && in IR testcases.");
      }
      break;
    }
    case call_params: {
      break;
    }
    default: { // operator_expr
      auto &function = functions_[wrapping_functions_.back()];
      BinaryOperator binary_operator;
      IcmpCond icmp_cond;
      int status; // 0: binary operation; 1: comparison; 2: ignore it; 3: compute and assign;
      switch (expression_ptr->GetExprInfix()) {
        case add: {
          binary_operator = add_;
          status = 0;
          break;
        }
        case minus: {
          binary_operator = sub_;
          status = 0;
          break;
        }
        case multiply: {
          binary_operator = mul_;
          status = 0;
          break;
        }
        case divide: {
          if (expression_ptr->integrated_type_->basic_type == u32_type ||
              expression_ptr->integrated_type_->basic_type == usize_type) { // unsigned division
            binary_operator = udiv_;
          } else { // signed division
            binary_operator = sdiv_;
          }
          status = 0;
          break;
        }
        case mod: {
          if (expression_ptr->integrated_type_->basic_type == u32_type ||
              expression_ptr->integrated_type_->basic_type == usize_type) { // unsigned rem
            binary_operator = urem_;
          } else { // signed rem
            binary_operator = srem_;
          }
          status = 0;
          break;
        }
        case bitwise_and: {
          binary_operator = and_;
          status = 0;
          break;
        }
        case bitwise_or: {
          binary_operator = or_;
          status = 0;
          break;
        }
        case bitwise_xor: {
          binary_operator = xor_;
          status = 0;
          break;
        }
        case left_shift: {
          binary_operator = shl_;
          status = 0;
          break;
        }
        case right_shift: {
          binary_operator = ashr_;
          status = 0;
          break;
        }
        case is_equal: {
          icmp_cond = equal_;
          status = 1;
          break;
        }
        case is_not_equal: {
          icmp_cond = not_equal_;
          status = 1;
          break;
        }
        case is_bigger: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
              expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) { // unsigned greater than
            icmp_cond = unsigned_greater_than_;
          } else { // signed greater than
            icmp_cond = signed_greater_than_;
          }
          status = 1;
          break;
        }
        case is_smaller: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
              expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) { // unsigned less than
            icmp_cond = unsigned_less_than_;
          } else { // signed less than
            icmp_cond = signed_less_than_;
          }
          status = 1;
          break;
        }
        case is_not_smaller: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
              expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) { // unsigned greater equal
            icmp_cond = unsigned_greater_equal_;
          } else { // signed greater equal
            icmp_cond = signed_greater_equal_;
          }
          status = 1;
          break;
        }
        case is_not_bigger: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
              expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) { // unsigned less equal
            icmp_cond = unsigned_less_equal_;
          } else { // signed less equal
            icmp_cond = signed_less_equal_;
          }
          status = 1;
          break;
        }
        case logic_or: {
          status = 2;
          EmitLogicalExpression(expression_ptr);
          break;
        }
        case logic_and: {
          status = 2;
          EmitLogicalExpression(expression_ptr);
          break;
        }
        case assign: {
          status = 2;
          expression_ptr->children_[0]->Accept(this);
          const int variable_id = expression_ptr->children_[0]->IR_var_ID_;
          const auto basic_type = expression_ptr->children_[1]->integrated_type_->basic_type;
          if (expression_ptr->children_[1]->integrated_type_->is_int ||
              basic_type == bool_type || basic_type == enumeration_type) {
            if (expression_ptr->children_[1]->integrated_type_->is_const) {
              function.blocks_[block_stack_.back()].AddValueStore(expression_ptr->children_[0]->integrated_type_,
                  static_cast<int>(expression_ptr->children_[1]->value_.int_value), variable_id);
            } else {
              expression_ptr->children_[1]->Accept(this);
              if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                  expression_ptr->children_[1]->IR_var_ID_ != -1) {
                expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
                functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                    expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                    expression_ptr->children_[1]->IR_var_ID_);
              }
              function.blocks_[block_stack_.back()].AddVariableStore(expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[1]->IR_ID_, variable_id);
            }
          } else if (basic_type == array_type || basic_type == struct_type) {
            InitializeAggregateInto(expression_ptr->children_[1], variable_id);
            if (expression_ptr->children_[1]->IR_var_ID_ != -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != variable_id) {
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddBuiltinMemcpy(
                  GetTypeSize(expression_ptr->children_[0]->integrated_type_).first,
                  variable_id, expression_ptr->children_[1]->IR_var_ID_);
            } else if (expression_ptr->children_[1]->IR_var_ID_ == variable_id) {
            } else {
              // todo: remove after complete function that returns array/struct
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableStore(
                  expression_ptr->children_[1]->integrated_type_, expression_ptr->children_[1]->IR_ID_,
                  variable_id);
            }
          } else if (basic_type == pointer_type) {
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddVariableStore(
                expression_ptr->children_[1]->integrated_type_, expression_ptr->children_[1]->IR_ID_,
                variable_id);
          }
          break;
        }
        case add_assign: {
          binary_operator = add_;
          status = 3;
          break;
        }
        case minus_assign: {
          binary_operator = sub_;
          status = 3;
          break;
        }
        case multiply_assign: {
          binary_operator = mul_;
          status = 3;
          break;
        }
        case divide_assign: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
                expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) {
            binary_operator = udiv_;
          } else {
            binary_operator = sdiv_;
          }
          status = 3;
          break;
        }
        case mod_assign: {
          if (expression_ptr->children_[0]->integrated_type_->basic_type == u32_type ||
                expression_ptr->children_[0]->integrated_type_->basic_type == usize_type) {
            binary_operator = urem_;
          } else {
            binary_operator = srem_;
          }
          status = 3;
          break;
        }
        case bitwise_and_assign: {
          binary_operator = and_;
          status = 3;
          break;
        }
        case bitwise_or_assign: {
          binary_operator = or_;
          status = 3;
          break;
        }
        case bitwise_xor_assign: {
          binary_operator = xor_;
          status = 3;
          break;
        }
        case left_shift_assign: {
          binary_operator = shl_;
          status = 3;
          break;
        }
        case right_shift_assign: {
          binary_operator = ashr_;
          status = 3;
          break;
        }
        case type_cast: {
          status = 2;
          // expression_ptr->children[0]->integrated_type->is_const is always false, otherwise the whole expression is const.
          if (expression_ptr->children_[0]->integrated_type_->is_int) {
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = expression_ptr->children_[0]->IR_ID_;
          } else { // expression_ptr->children_[0]->integrated_type_->basic_type == bool_type
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddSelect(0b011, expression_ptr->IR_ID_,
                expression_ptr->children_[0]->IR_ID_, expression_ptr->integrated_type_,
                1, expression_ptr->integrated_type_, 0);
          }
          break;
        }
        default:;
      }
      switch (status) {
        case 0: { // binary operation
          if (expression_ptr->children_[0]->integrated_type_->is_const) { // const op var
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddConstVarBinaryOperation(expression_ptr->integrated_type_,
                binary_operator, expression_ptr->IR_ID_, static_cast<int>(expression_ptr->children_[0]->value_.int_value),
                expression_ptr->children_[1]->IR_ID_);
          } else if (expression_ptr->children_[1]->integrated_type_->is_const) { // var op const
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddVarConstBinaryOperation(expression_ptr->integrated_type_,
                binary_operator, expression_ptr->IR_ID_, expression_ptr->children_[0]->IR_ID_,
                static_cast<int>(expression_ptr->children_[1]->value_.int_value));
          } else { // var op var
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddTwoVarBinaryOperation(expression_ptr->integrated_type_,
                binary_operator, expression_ptr->IR_ID_, expression_ptr->children_[0]->IR_ID_,
                expression_ptr->children_[1]->IR_ID_);
          }
          break;
        }
        case 1: { // comparison
          if (expression_ptr->children_[0]->integrated_type_->is_const) { // const <icmp_cond> var
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddConstVarIcmp(expression_ptr->IR_ID_, icmp_cond,
                expression_ptr->children_[0]->integrated_type_,
                static_cast<int>(expression_ptr->children_[0]->value_.int_value),
                expression_ptr->children_[1]->IR_ID_);
          } else if (expression_ptr->children_[1]->integrated_type_->is_const) { // var <icmp_cond> const
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddVarConstIcmp(expression_ptr->IR_ID_, icmp_cond,
                expression_ptr->children_[0]->integrated_type_,
                expression_ptr->children_[0]->IR_ID_,
                static_cast<int>(expression_ptr->children_[1]->value_.int_value));
          } else { // var <icmp_cond> var
            expression_ptr->children_[0]->Accept(this);
            if (expression_ptr->children_[0]->IR_ID_ == -1 &&
                expression_ptr->children_[0]->IR_var_ID_ != -1) {
              expression_ptr->children_[0]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[0]->IR_ID_, expression_ptr->children_[0]->integrated_type_,
                  expression_ptr->children_[0]->IR_var_ID_);
            }
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            expression_ptr->IR_ID_ = function.var_id_++;
            function.blocks_[block_stack_.back()].AddTwoVarIcmp(expression_ptr->IR_ID_, icmp_cond,
                expression_ptr->children_[0]->integrated_type_, expression_ptr->children_[0]->IR_ID_,
                expression_ptr->children_[1]->IR_ID_);
          }
          break;
        }
        case 2: { // ignore
          break;
        }
        case 3: { // compute and assign
          expression_ptr->children_[0]->Accept(this);
          const int pointer_id = expression_ptr->children_[0]->IR_var_ID_;
          const int loaded_var_id = function.var_id_++;
          function.blocks_[block_stack_.back()].AddLoad(loaded_var_id,
              expression_ptr->children_[0]->integrated_type_, pointer_id);
          const int temp_result_id = function.var_id_++;
          if (expression_ptr->children_[1]->integrated_type_->is_const) {
            function.blocks_[block_stack_.back()].AddVarConstBinaryOperation(
                expression_ptr->children_[0]->integrated_type_, binary_operator, temp_result_id,
                loaded_var_id, static_cast<int>(expression_ptr->children_[1]->value_.int_value));
          } else {
            expression_ptr->children_[1]->Accept(this);
            if (expression_ptr->children_[1]->IR_ID_ == -1 &&
                expression_ptr->children_[1]->IR_var_ID_ != -1) {
              expression_ptr->children_[1]->IR_ID_ = functions_[wrapping_functions_.back()].var_id_++;
              functions_[wrapping_functions_.back()].blocks_[block_stack_.back()].AddLoad(
                  expression_ptr->children_[1]->IR_ID_, expression_ptr->children_[1]->integrated_type_,
                  expression_ptr->children_[1]->IR_var_ID_);
            }
            function.blocks_[block_stack_.back()].AddTwoVarBinaryOperation(
                expression_ptr->children_[0]->integrated_type_, binary_operator, temp_result_id,
                loaded_var_id, expression_ptr->children_[1]->IR_ID_);
          }
          function.blocks_[block_stack_.back()].AddVariableStore(expression_ptr->children_[0]->integrated_type_,
              temp_result_id, pointer_id);
          break;
        }
        default: {
          IRThrow("Unknown status.");
        }
      }
    }
  }
}

void IRVisitor::OutputType(std::ofstream &file, const std::shared_ptr<IntegratedType> &integrated_type) {
  switch (integrated_type->basic_type) {
    case bool_type: {
      file << "i1";
      break;
    }
    case i32_type:
    case u32_type:
    case isize_type:
    case usize_type:
    case enumeration_type: {
      file << "i32";
      break;
    }
    case array_type: {
      file << '[' << integrated_type->size << " x ";
      OutputType(file, integrated_type->element_type);
      file << ']';
      break;
    }
    case struct_type: {
      file << "%struct." << integrated_type->struct_node->IR_ID_;
      break;
    }
    case pointer_type: {
      file << "ptr";
      break;
    }
    default:;
  }
}

void IRVisitor::Print(std::ofstream &file, const IRInstruction &instruction) {
  file << '\t';
  switch (instruction.instruction_type_) {
    case two_var_binary_operation_: {
      file << "%var." << instruction.result_id_ << " = ";
      switch (instruction.operator_) {
        case add_: {
          file << "add";
          break;
        }
        case sub_: {
          file << "sub";
          break;
        }
        case mul_: {
          file << "mul";
          break;
        }
        case udiv_: {
          file << "udiv";
          break;
        }
        case sdiv_: {
          file << "sdiv";
          break;
        }
        case urem_: {
          file << "urem";
          break;
        }
        case srem_: {
          file << "srem";
          break;
        }
        case shl_: {
          file << "shl";
          break;
        }
        case ashr_: {
          file << "ashr";
          break;
        }
        case and_: {
          file << "and";
          break;
        }
        case or_: {
          file << "or";
          break;
        }
        case xor_: {
          file << "xor";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", %var." << instruction.operand_2_id_;
      break;
    }
    case var_const_binary_operation_: {
      file << "%var." << instruction.result_id_ << " = ";
      switch (instruction.operator_) {
        case add_: {
          file << "add";
          break;
        }
        case sub_: {
          file << "sub";
          break;
        }
        case mul_: {
          file << "mul";
          break;
        }
        case udiv_: {
          file << "udiv";
          break;
        }
        case sdiv_: {
          file << "sdiv";
          break;
        }
        case urem_: {
          file << "urem";
          break;
        }
        case srem_: {
          file << "srem";
          break;
        }
        case shl_: {
          file << "shl";
          break;
        }
        case ashr_: {
          file << "ashr";
          break;
        }
        case and_: {
          file << "and";
          break;
        }
        case or_: {
          file << "or";
          break;
        }
        case xor_: {
          file << "xor";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", " << instruction.operand_2_id_;
      break;
    }
    case const_var_binary_operation_: {
      file << "%var." << instruction.result_id_ << " = ";
      switch (instruction.operator_) {
        case add_: {
          file << "add";
          break;
        }
        case sub_: {
          file << "sub";
          break;
        }
        case mul_: {
          file << "mul";
          break;
        }
        case udiv_: {
          file << "udiv";
          break;
        }
        case sdiv_: {
          file << "sdiv";
          break;
        }
        case urem_: {
          file << "urem";
          break;
        }
        case srem_: {
          file << "srem";
          break;
        }
        case shl_: {
          file << "shl";
          break;
        }
        case ashr_: {
          file << "ashr";
          break;
        }
        case and_: {
          file << "and";
          break;
        }
        case or_: {
          file << "or";
          break;
        }
        case xor_: {
          file << "xor";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.operand_1_id_ << ", %var." << instruction.operand_2_id_;
      break;
    }
    case conditional_br_: {
      file << "br i1 %var." << instruction.condition_id_ << ", label %label_" <<
          instruction.if_true_ << ", label %label_" << instruction.if_false_;
      break;
    }
    case unconditional_br_: {
      file << "br label %label_" << instruction.destination_;
      break;
    }
    case value_ret_: {
      file << "ret ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.result_id_;
      break;
    }
    case variable_ret_: {
      file << "ret ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.result_id_;
      break;
    }
    case void_ret_: {
      file << "ret void";
      break;
    }
    case alloca_: {
      file << "%var." << instruction.result_id_ << " = alloca ";
      OutputType(file, instruction.result_type_);
      break;
    }
    case load_: {
      file << "%var." << instruction.result_id_ << " = load ";
      OutputType(file, instruction.result_type_);
      file << ", ptr %var." << instruction.pointer_;
      break;
    }
    case ptr_load_: {
      file << "%var." << instruction.result_id_ <<
          " = load ptr, ptr %var." << instruction.pointer_;
      break;
    }
    case variable_store_: {
      file << "store ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.result_id_ << ", ptr %var." << instruction.pointer_;
      break;
    }
    case value_store_: {
      file << "store ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.result_id_ << ", ptr %var." << instruction.pointer_;
      break;
    }
    case ptr_store_: {
      file << "store ptr %var." << instruction.result_id_
          << ", ptr %var." << instruction.pointer_;
      break;
    }
    case get_element_ptr_by_value_: {
      file << "%var." << instruction.result_id_ << " = getelementptr ";
      OutputType(file, instruction.result_type_);
      file << ", ptr %var." << instruction.pointer_ << ", i32 0, i32 " << instruction.index_;
      break;
    }
    case get_element_ptr_by_variable_: {
      file << "%var." << instruction.result_id_ << " = getelementptr ";
      OutputType(file, instruction.result_type_);
      file << ", ptr %var." << instruction.pointer_ << ", i32 0, i32 %var." << instruction.index_;
      break;
    }
    case two_var_icmp_: {
      file << "%var." << instruction.result_id_ << " = icmp ";
      switch (instruction.icmp_condition_) {
        case equal_: {
          file << "eq";
          break;
        }
        case not_equal_: {
          file << "ne";
          break;
        }
        case unsigned_greater_than_: {
          file << "ugt";
          break;
        }
        case unsigned_greater_equal_: {
          file << "uge";
          break;
        }
        case unsigned_less_than_: {
          file << "ult";
          break;
        }
        case unsigned_less_equal_: {
          file << "ule";
          break;
        }
        case signed_greater_than_: {
          file << "sgt";
          break;
        }
        case signed_greater_equal_: {
          file << "sge";
          break;
        }
        case signed_less_than_: {
          file << "slt";
          break;
        }
        case signed_less_equal_: {
          file << "sle";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", %var." <<
          instruction.operand_2_id_;
      break;
    }
    case var_const_icmp_: {
      file << "%var." << instruction.result_id_ << " = icmp ";
      switch (instruction.icmp_condition_) {
        case equal_: {
          file << "eq";
          break;
        }
        case not_equal_: {
          file << "ne";
          break;
        }
        case unsigned_greater_than_: {
          file << "ugt";
          break;
        }
        case unsigned_greater_equal_: {
          file << "uge";
          break;
        }
        case unsigned_less_than_: {
          file << "ult";
          break;
        }
        case unsigned_less_equal_: {
          file << "ule";
          break;
        }
        case signed_greater_than_: {
          file << "sgt";
          break;
        }
        case signed_greater_equal_: {
          file << "sge";
          break;
        }
        case signed_less_than_: {
          file << "slt";
          break;
        }
        case signed_less_equal_: {
          file << "sle";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", " <<
          instruction.operand_2_id_;
      break;
    }
    case const_var_icmp_: {
      file << "%var." << instruction.result_id_ << " = icmp ";
      switch (instruction.icmp_condition_) {
        case equal_: {
          file << "eq";
          break;
        }
        case not_equal_: {
          file << "ne";
          break;
        }
        case unsigned_greater_than_: {
          file << "ugt";
          break;
        }
        case unsigned_greater_equal_: {
          file << "uge";
          break;
        }
        case unsigned_less_than_: {
          file << "ult";
          break;
        }
        case unsigned_less_equal_: {
          file << "ule";
          break;
        }
        case signed_greater_than_: {
          file << "sgt";
          break;
        }
        case signed_greater_equal_: {
          file << "sge";
          break;
        }
        case signed_less_than_: {
          file << "slt";
          break;
        }
        case signed_less_equal_: {
          file << "sle";
          break;
        }
        default:;
      }
      file << " ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.operand_1_id_ << ", %var." <<
          instruction.operand_2_id_;
      break;
    }
    case non_void_call_: {
      file << "%var." << instruction.result_id_ << " = call ";
      OutputType(file, instruction.result_type_);
      file << " @fn." << instruction.function_name_ << "(";
      for (int i = 0; i < instruction.function_call_arguments_.size(); ++i) {
        OutputType(file, instruction.function_call_arguments_[i].type_);
        file << " ";
        if (instruction.function_call_arguments_[i].is_variable_) {
          file << "%var." << instruction.function_call_arguments_[i].value_;
        } else {
          file << instruction.function_call_arguments_[i].value_;
        }
        if (i < instruction.function_call_arguments_.size() - 1) {
          file << ", ";
        }
      }
      file << ")";
      break;
    }
    case void_call_: {
      file << "call void @fn." << instruction.function_name_ << "(";
      for (int i = 0; i < instruction.function_call_arguments_.size(); ++i) {
        OutputType(file, instruction.function_call_arguments_[i].type_);
        file << " ";
        if (instruction.function_call_arguments_[i].is_variable_) {
          file << "%var." << instruction.function_call_arguments_[i].value_;
        } else {
          file << instruction.function_call_arguments_[i].value_;
        }
        if (i < instruction.function_call_arguments_.size() - 1) {
          file << ", ";
        }
      }
      file << ")";
      break;
    }
    case builtin_call_: {
      switch (instruction.function_name_) {
        case 0: { // printInt
          file << "call void @printInt(";
          for (int i = 0; i < instruction.function_call_arguments_.size(); ++i) {
            OutputType(file, instruction.function_call_arguments_[i].type_);
            file << " ";
            if (instruction.function_call_arguments_[i].is_variable_) {
              file << "%var." << instruction.function_call_arguments_[i].value_;
            } else {
              file << instruction.function_call_arguments_[i].value_;
            }
            if (i < instruction.function_call_arguments_.size() - 1) {
              file << ", ";
            }
          }
          file << ")";
          break;
        }
        case 1: { // printlnInt
          file << "call void @printlnInt(";
          for (int i = 0; i < instruction.function_call_arguments_.size(); ++i) {
            OutputType(file, instruction.function_call_arguments_[i].type_);
            file << " ";
            if (instruction.function_call_arguments_[i].is_variable_) {
              file << "%var." << instruction.function_call_arguments_[i].value_;
            } else {
              file << instruction.function_call_arguments_[i].value_;
            }
            if (i < instruction.function_call_arguments_.size() - 1) {
              file << ", ";
            }
          }
          file << ")";
          break;
        }
        case 2: { // getInt
          file << "%var." << instruction.result_id_ << " = call ";
          OutputType(file, instruction.result_type_);
          file << " @getInt(";
          for (int i = 0; i < instruction.function_call_arguments_.size(); ++i) {
            OutputType(file, instruction.function_call_arguments_[i].type_);
            file << " ";
            if (instruction.function_call_arguments_[i].is_variable_) {
              file << "%var." << instruction.function_call_arguments_[i].value_;
            } else {
              file << instruction.function_call_arguments_[i].value_;
            }
            if (i < instruction.function_call_arguments_.size() - 1) {
              file << ", ";
            }
          }
          file << ")";
          break;
        }
        default:;
      }
      break;
    }
    case value_select_ii_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      if (instruction.condition_id_ == 0) {
        file << "false, ";
        OutputType(file, instruction.another_type_);
        file << " %var." << instruction.operand_2_id_ << ", ";
        OutputType(file, instruction.another_type_);
        file << " %var." << instruction.operand_2_id_;
      } else {
        file << "true, ";
        OutputType(file, instruction.result_type_);
        file << " %var." << instruction.operand_1_id_ << ", ";
        OutputType(file, instruction.result_type_);
        file << " %var." << instruction.operand_1_id_;
      }
      break;
    }
    case value_select_iv_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      if (instruction.condition_id_ == 0) {
        file << "false, ";
        OutputType(file, instruction.another_type_);
        file << " " << instruction.operand_2_id_ << ", ";
        OutputType(file, instruction.another_type_);
        file << " " << instruction.operand_2_id_;
      } else {
        file << "true, ";
        OutputType(file, instruction.result_type_);
        file << " %var." << instruction.operand_1_id_ << ", ";
        OutputType(file, instruction.result_type_);
        file << " %var." << instruction.operand_1_id_;
      }
      break;
    }
    case value_select_vi_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      if (instruction.condition_id_ == 0) {
        file << "false, ";
        OutputType(file, instruction.another_type_);
        file << " %var." << instruction.operand_2_id_ << ", ";
        OutputType(file, instruction.another_type_);
        file << " %var." << instruction.operand_2_id_;
      } else {
        file << "true, ";
        OutputType(file, instruction.result_type_);
        file << " " << instruction.operand_1_id_ << ", ";
        OutputType(file, instruction.result_type_);
        file << " " << instruction.operand_1_id_;
      }
      break;
    }
    case value_select_vv_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      if (instruction.condition_id_ == 0) {
        file << "false, ";
        OutputType(file, instruction.another_type_);
        file << " " << instruction.operand_2_id_ << ", ";
        OutputType(file, instruction.another_type_);
        file << " " << instruction.operand_2_id_;
      } else {
        file << "true, ";
        OutputType(file, instruction.result_type_);
        file << " " << instruction.operand_1_id_ << ", ";
        OutputType(file, instruction.result_type_);
        file << " " << instruction.operand_1_id_;
      }
      break;
    }
    case variable_select_ii_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      file << "%var." << instruction.condition_id_;
      file << ", ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", ";
      OutputType(file, instruction.another_type_);
      file << " %var." << instruction.operand_2_id_;
      break;
    }
    case variable_select_iv_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      file << "%var." << instruction.condition_id_;
      file << ", ";
      OutputType(file, instruction.result_type_);
      file << " %var." << instruction.operand_1_id_ << ", ";
      OutputType(file, instruction.another_type_);
      file << " " << instruction.operand_2_id_;
      break;
    }
    case variable_select_vi_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      file << "%var." << instruction.condition_id_;
      file << ", ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.operand_1_id_ << ", ";
      OutputType(file, instruction.another_type_);
      file << " %var." << instruction.operand_2_id_;
      break;
    }
    case variable_select_vv_: {
      file << "%var." << instruction.result_id_ << " = select i1 ";
      file << "%var." << instruction.condition_id_;
      file << ", ";
      OutputType(file, instruction.result_type_);
      file << " " << instruction.operand_1_id_ << ", ";
      OutputType(file, instruction.another_type_);
      file << " " << instruction.operand_2_id_;
      break;
    }
    case builtin_memset_: {
      file << "call void @builtin_memset(ptr %var." << instruction.pointer_ << ", i32 "
          << (instruction.operand_1_id_ == 0 ? 0 : -1) << ", i32 " << instruction.result_id_ << ")";
      break;
    }
    case builtin_memcpy_: {
      file << "call void @builtin_memcpy(ptr %var." << instruction.destination_
          << ", ptr %var." << instruction.pointer_ << ", i32 " << instruction.result_id_ << ")";
      break;
    }
    default:;
  }
  file << '\n';
}

void IRVisitor::PrintPhi(std::ofstream &file, const PhiInstruction &instruction) {
  file << "	%var." << instruction.result_id << " = phi ";
  OutputType(file, instruction.type);
  // For pointer-typed phis, an undef operand is encoded as literal 0
  // (set by mem2reg). Emit it as `null` rather than integer 0 to satisfy
  // LLVM's type checker on `phi ptr`.
  const bool is_ptr_phi = instruction.type && instruction.type->basic_type == pointer_type;
  if (instruction.conditions[0].is_const) { // the first value is literal value
    if (is_ptr_phi && instruction.conditions[0].value == 0) {
      file << " [ null, %label_" << instruction.conditions[0].from_block_id << " ]";
    } else {
      file << " [ " << instruction.conditions[0].value << ", %label_" << instruction.conditions[0].from_block_id << " ]";
    }
  } else {
    file << " [ %var." << instruction.conditions[0].var_id << ", %label_" << instruction.conditions[0].from_block_id << " ]";
  }
  for (int i = 1; i < instruction.conditions.size(); ++i) {
    if (instruction.conditions[i].is_const) { // is literal value
      if (is_ptr_phi && instruction.conditions[i].value == 0) {
        file << ", [ null, %label_" << instruction.conditions[i].from_block_id << " ]";
      } else {
        file << ", [ " << instruction.conditions[i].value << ", %label_" << instruction.conditions[i].from_block_id << " ]";
      }
    } else {
      file << ", [ %var." << instruction.conditions[i].var_id << ", %label_" << instruction.conditions[i].from_block_id << " ]";
    }
  }
  file << '\n';
}

void IRVisitor::Output(std::ofstream &file) {
  // output struct definitions
  for (int i = 0; i < structs_.size(); ++i) {
    file << "%struct." << i << " = type { ";
    for (int j = 0; j < structs_[i].element_type_.size(); ++j) {
      OutputType(file, structs_[i].element_type_[j]);
      if (j < structs_[i].element_type_.size() - 1) {
        file << ',';
      }
      file << ' ';
    }
    file << "}\n";
  }
  file << '\n';
  // output function definitions with blocks in it
  for (int i = 0; i < functions_.size(); ++i) {
    file << "define ";
    if (functions_[i].return_type_->basic_type == unit_type ||
        functions_[i].return_type_->basic_type == array_type ||
        functions_[i].return_type_->basic_type == struct_type) {
      file << "void";
    } else {
      OutputType(file, functions_[i].return_type_);
    }
    if (i == main_function_id_) {
      file << " @main(";
    } else {
      file << " @fn." << i << '(';
    }
    for (int j = 0; j < functions_[i].parameter_types_.size(); ++j) {
      OutputType(file, functions_[i].parameter_types_[j]);
      file << " %var." << j;
      if (j < functions_[i].parameter_types_.size() - 1) {
        file << ", ";
      }
    }
    file << ") {\n";
    // print alloca
    file << "alloca:\n";
    for (const auto &alloca_instruction : functions_[i].alloca_instructions_) {
      Print(file, alloca_instruction);
    }
    file << "\tbr label %label_" << functions_[i].blocks_.begin()->first << '\n';
    // print blocks
    for (const auto &[block_label, block] : functions_[i].blocks_) {
      file << "label_" << block_label << ":\n";
      for (const auto &phi_instruction : block.phi_instructions_) {
        PrintPhi(file, phi_instruction);
      }
      for (const auto &instruction : block.instructions_) {
        Print(file, instruction);
      }
    }
    file << "}\n\n";
  }
}

const std::vector<IRFunctionNode> &IRVisitor::GetIRFunctions() const {
  return this->functions_;
}

const std::vector<IRStructNode> &IRVisitor::GetIRStructs() const {
  return this->structs_;
}

int IRVisitor::GetMainFuncID() const {
  return this->main_function_id_;
}

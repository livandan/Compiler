#include "code_generator.h"
#include "fstream"
#include "item.h"

void CodegenThrow(const std::string &err_info) {
  std::cerr << "[Codegen Error] " << err_info << '\n';
  throw "";
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
    case enumeration_type:
    case pointer_type: {
      return {4, true};
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

int CodeGenerator::ComputeStackSpace(int func_id) const {
  int space = 120; // 30 * 4 bytes for register saving
  int remained_register = 8; // a-registers
  for (const auto &instruction : IR_functions_[func_id].alloca_instructions_) {
    if (!remained_register || instruction.result_type_->basic_type == array_type
        || instruction.result_type_->basic_type == struct_type) {
      space += GetSize(instruction.result_type_).first;
      space += 4;
    } else {
      remained_register--;
    }
  }
  for (const auto &[block_id, block] : IR_functions_[func_id].blocks_) {
    for (const auto &instruction : block.instructions_) {
      if (instruction.instruction_type_ == two_var_binary_operation_
          || instruction.instruction_type_ == var_const_binary_operation_
          || instruction.instruction_type_ == const_var_binary_operation_
          || instruction.instruction_type_ == load_
          || instruction.instruction_type_ == ptr_load_) {
        space += GetSize(instruction.result_type_).first;
      } else if (instruction.instruction_type_ == get_element_ptr_by_value_
          || instruction.instruction_type_ == get_element_ptr_by_variable_) {
        space += 4;
      } else if (instruction.instruction_type_ == two_var_icmp_
          || instruction.instruction_type_ == var_const_icmp_
          || instruction.instruction_type_ == const_var_icmp_) {
        space += 1;
      }
    }
  }
  return space;
}

void CodeGenerator::Generate() {
  RISCV_functions_.resize(IR_functions_.size());
  for (int i = 0; i < IR_functions_.size(); ++i) {
    const int space = ComputeStackSpace(i);
    RISCV_functions_[i].stack_space_ = space;
  }
}

void CodeGenerator::Output(std::ofstream &output_file) const {
  std::ifstream builtin_fn("../RCompiler-Testcases/IR-1/builtin/builtin_fn.txt");
  std::ifstream builtin_str("../RCompiler-Testcases/IR-1/builtin/builtin_str.txt");
  std::string line_in_file;
  if (builtin_fn.is_open()) {
    if (output_file.is_open()) {
      while (std::getline(builtin_fn, line_in_file)) {
        output_file << line_in_file << '\n';
      }
      builtin_fn.close();
    } else {
      std::cerr << "Cannot open output file!\n";
      builtin_fn.close();
      return;
    }
  } else {
    std::cerr << "Cannot open builtin functions file!\n";
    return;
  }
  output_file << "\n";

  for (int i = 0; i < RISCV_functions_.size(); ++i) {
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
    output_file << "	.cfi_startproc\n"
        << "# %bb.0:                                # %alloca\n";
    // todo: output instructions in %bb.0

    for (const auto &[block_label, block] : IR_functions_[i].blocks_) {
      output_file << ".LBB" << current_func_id_ << '_' << block_label
          << ":                               # %label_" << block_label << '\n';
      // todo: output instructions in order
    }
    output_file << '\n';
  }

  if (builtin_str.is_open()) {
    while (std::getline(builtin_str, line_in_file)) {
      output_file << line_in_file << '\n';
    }
    builtin_str.close();
  } else {
    std::cerr << "Cannot open builtin string file!\n";
  }
  output_file.close();
}
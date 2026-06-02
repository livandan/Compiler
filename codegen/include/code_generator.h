#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include "IR_generator.h"

enum RISCVInstructionType {
  r_none_, r_add_, r_sub_, r_and_, r_or_, r_xor_, r_sll_, r_srl_, r_sra_,
  r_slt_, r_sltu_, r_addi_, r_andi_, r_ori_, r_xori_, r_slli_, r_srli_,
  r_srai_, r_slti_, r_sltiu_, r_lb_, r_lbu_, r_lh_, r_lhu_, r_lw_, r_sb_,
  r_sh_, r_sw_, r_beq_, r_bge_, r_bgeu_, r_blt_, r_bltu_, r_bne_, r_jal_,
  r_jalr_, r_auipc_, r_lui_, r_ebreak_, r_ecall_, r_mul_, r_div_, r_divu_,
  r_rem_, r_remu_, r_exit_, r_beqz_, r_bnez_, r_j_, r_jal_ra_, r_jr_,
  r_la_, r_li_, r_mv_, r_neg_, r_nop_, r_not_, r_ret_, r_call_
};

struct RISCVInstruction {
  RISCVInstructionType instruction_type_;
  int rd_, rs1_, rs2_, imm_, label_;
  RISCVInstruction(const RISCVInstructionType type, const int rd,
      const int rs1, const int rs2, const int imm, const int label) :
      instruction_type_(type), rd_(rd), rs1_(rs1), rs2_(rs2),
      imm_(imm), label_(label) {}
};

void CodegenThrow(const std::string &err_info);

struct RISCVBlock {
  std::vector<RISCVInstruction> instructions_;
  void PushArithmetic_R(const RISCVInstructionType type, const int rd, const int rs1, const int rs2) {
    if (type < 1 || type > 10) {
      CodegenThrow("Incorrectly use PushArithmetic_R(...).");
    }
    instructions_.push_back(RISCVInstruction(type, rd, rs1, rs2, -1, -1));
  }
  void PushArithmetic_I(const RISCVInstructionType type, const int rd, const int rs1, const int imm) {
    switch (type) {
      case r_addi_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_add_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_andi_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_and_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_ori_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_or_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_xori_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_xor_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_slli_: {
        if (imm < 0) {
          CodegenThrow("Invalid slli.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sll_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_srli_: {
        if (imm < 0) {
          CodegenThrow("Invalid srli.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_srl_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_srai_: {
        if (imm < 0) {
          CodegenThrow("Invalid srai.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sra_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_slti_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_slt_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      case r_sltiu_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sltu_, rd, rs1, 31, -1, -1));
        }
        break;
      }
      default: {
        CodegenThrow("Incorrectly use PushArithmetic_I(...).");
      }
    }
  }
  void PushMemory_I(const RISCVInstructionType type, const int rd, const int imm, const int rs1) {
    if (type < 20 || type > 24) {
      CodegenThrow("Incorrectly use PushMemory_I(...).");
    }
    if (imm >= -2048 && imm <= 2047) {
      instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
    } else {
      instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, 31, rs1, 31, -1, -1));
      instructions_.push_back(RISCVInstruction(type, rd, 31, -1, 0, -1));
    }
  }
  void PushMemory_S(const RISCVInstructionType type, const int rs2, const int imm, const int rs1) {
    if (type < 25 || type > 27) {
      CodegenThrow("Incorrectly use PushMemory_S(...).");
    }
    if (imm >= -2048 && imm <= 2047) {
      instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, imm, -1));
    } else {
      instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, 31, rs1, 31, -1, -1));
      instructions_.push_back(RISCVInstruction(type, -1, 31, rs2, 0, -1));
    }
  }
  void PushControl_B(const RISCVInstructionType type, const int rs1, const int rs2, const int label) {
    if (type < 28 || type > 33) {
      CodegenThrow("Incorrectly use PushControl_B(...).");
    }
    instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, -1, label));
  }
  void PushExtended(const  RISCVInstructionType type, const int rd, const int rs1, const int rs2) {
    if (type < 40 || type > 44) {
      CodegenThrow("Incorrectly use PushExtended(...).");
    }
    instructions_.push_back(RISCVInstruction(type, rd, rs1, rs2, -1, -1));
  }
  void PushJal(const int rd, const int label) {
    instructions_.push_back(RISCVInstruction(r_jal_, rd, -1, -1, -1, label));
  }
  void PushJalr(const int rd, const int rs1, const int imm) {
    if (imm >= -2048 && imm <= 2047) {
      instructions_.push_back(RISCVInstruction(r_jalr_, rd, rs1, -1, imm, -1));
    } else {
      instructions_.push_back(RISCVInstruction(r_li_, 31, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, 31, rs1, 31, -1, -1));
      instructions_.push_back(RISCVInstruction(r_jalr_, rd, 31, -1, 0, -1));
    }
  }
  void PushLi(const int rd, const int imm) {
    instructions_.push_back(RISCVInstruction(r_li_, rd, -1, -1, imm, -1));
  }
  void PushReturn(const int released_stack_space) {
    if (released_stack_space < 2048) {
      PushMemory_I(r_lw_, 1, released_stack_space - 4, 2);
      PushArithmetic_I(r_addi_, 2, 2, released_stack_space);
    } else if (released_stack_space < 2052) {
      PushMemory_I(r_lw_, 1, released_stack_space - 4, 2);
      PushLi(31, released_stack_space);
      PushArithmetic_R(r_add_, 2, 2, 31);
    } else {
      PushLi(31, released_stack_space - 4);
      PushArithmetic_R(r_add_, 31, 2, 31);
      PushMemory_I(r_lw_, 1, 0, 31);
      PushLi(31, released_stack_space);
      PushArithmetic_R(r_add_, 2, 2, 31);
    }
    instructions_.push_back(RISCVInstruction(r_ret_, -1, -1, -1, -1, -1));
  }
  void PushJ(const int block_label_id) {
    instructions_.push_back(RISCVInstruction(r_j_, -1, -1, -1, -1, block_label_id));
  }
  void PushCall(const bool is_builtin, const int func_id) {
    instructions_.push_back(RISCVInstruction(r_call_, is_builtin ? 1 : 0, -1, -1, -1, func_id));
  } // builtin: 1-print; 2-println; 3-printInt; 4-printlnInt; 5-getString; 6-getInt; 7-builtin_memset; 8-builtin_memcpy
};

struct RISCVFunctionNode {
  explicit RISCVFunctionNode(const int stack_space = 0) : stack_space_(stack_space) {}
  int stack_space_;
  RISCVBlock alloca_block_;
  std::map<int, RISCVBlock> blocks_;
  std::map<int, std::pair<bool, int>> location_; // int, bool, int: var_id, is_in_register, location
};

struct ParameterPassPosition {
  bool passed_in_reg = false;
  int reg_id = -1;
  int neg_offset = 0;
};

class CodeGenerator {
public:
  explicit CodeGenerator(const std::vector<IRFunctionNode> &functions,
      const std::vector<IRStructNode> &structs, const int main_func_id)
      : IR_functions_(functions), IR_structs_(structs), main_func_id_(main_func_id) {}
  [[nodiscard]] std::pair<bool, int> GetParamPassPos(int function_id, int param_id) const;
  void MemAlloc(int func_id);
  [[nodiscard]] int RegSavedLocation(int func_id, int reg_id) const; // return the relative address to the stack pointer
  void VariableAssignment(int func_id, RISCVBlock &r_block, int var_dest, int var_src, const std::shared_ptr<IntegratedType> &type); // %var_dest <- %var_src
  void ValueAssignment(int func_id, RISCVBlock &r_block, int var_dest, int value_src, const std::shared_ptr<IntegratedType> &type); // %var_dest <- value_src
  [[nodiscard]] std::pair<int, bool> GetSize(const std::shared_ptr<IntegratedType> &type) const;
  void Generate();
  void Output(std::ofstream &output_file) const;
private:
  const std::vector<IRFunctionNode> &IR_functions_;
  const std::vector<IRStructNode> &IR_structs_;
  std::vector<RISCVFunctionNode> RISCV_functions_;
  const int main_func_id_;
};

#endif
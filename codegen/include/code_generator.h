#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include "IR_generator.h"

enum RISCVInstructionType {
  r_none_, r_add_, r_sub_, r_and_, r_or_, r_xor_, r_sll_, r_srl_, r_sra_,
  r_slt_, r_sltu_, r_addi_, r_andi_, r_ori_, r_xori_, r_slli_, r_srli_,
  r_srai_, r_slti_, r_sltiu_, r_lb_, r_lbu_, r_lh_, r_lhu_, r_lw_, r_sb_,
  r_sh_, r_sw_, r_beq_, r_bge_, r_bgeu_, r_blt_, r_bltu_, r_bne_, r_jal_,
  r_jalr_, r_auipc_, r_lui_, r_ebreak_, r_ecall_, r_mul_, r_exit_
};

struct RISCVInstruction {
  RISCVInstructionType instruction_type_;
  int rd_, rs1_, rs2_, imm_, label_;
  RISCVInstruction(const RISCVInstructionType type, const int rd,
      const int rs1, const int rs2, const int imm, const int label) :
      instruction_type_(type), rd_(rd), rs1_(rs1), rs2_(rs2),
      imm_(imm), label_(label) {}
};

struct RISCVBlock {
  std::vector<RISCVInstruction> instructions_;
  void PushArithmetic_R(const RISCVInstructionType type, const int rd, const int rs1, const int rs2) {
    instructions_.push_back(RISCVInstruction(type, rd, rs1, rs2, -1, -1));
  }
  void PushArithmetic_I(const RISCVInstructionType type, const int rd, const int rs1, const int imm) {
    instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
  }
  void PushMemory_I(const RISCVInstructionType type, const int rd, const int imm, const int rs1) {
    instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
  }
  void PushMemory_S(const RISCVInstructionType type, const int rs2, const int imm, const int rs1) {
    instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, imm, -1));
  }
  void PushControl_B(const RISCVInstructionType type, const int rs1, const int rs2, const int label) {
    instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, -1, label));
  }
  void PushJal(const int rd, const int label) {
    instructions_.push_back(RISCVInstruction(r_jal_, rd, -1, -1, -1, label));
  }
  void PushJalr(const int rd, const int rs1, const int imm) {
    instructions_.push_back(RISCVInstruction(r_jalr_, rd, rs1, -1, imm, -1));
  }
  void PushAuipc(const int rd, const int immu) {
    instructions_.push_back(RISCVInstruction(r_auipc_, rd, -1, -1, immu, -1));
  }
  void PushLui(const int rd, const int immu) {
    instructions_.push_back(RISCVInstruction(r_lui_, rd, -1, -1, immu, -1));
  }
};

struct RISCVFunctionNode {
  int stack_space;
  std::vector<RISCVBlock> blocks_;
  std::map<int, int> location_;
};

class CodeGenerator {
public:
  explicit CodeGenerator(const std::vector<IRFunctionNode> &functions,
      const std::vector<IRStructNode> &structs, const int main_func_id)
      : IR_functions_(functions), IR_structs_(structs), main_func_id_(main_func_id) {}
  int ComputeStackSpace(int func_id) const;
  std::pair<int, bool> GetSize(const std::shared_ptr<IntegratedType> &type) const;
  void Generate();
  void Output(const std::string &filename) const;
private:
  const std::vector<IRFunctionNode> &IR_functions_;
  const std::vector<IRStructNode> &IR_structs_;
  const std::vector<RISCVFunctionNode> RISCV_functions_;
  const int main_func_id_;
  int current_func_id_ = 8;
};

#endif
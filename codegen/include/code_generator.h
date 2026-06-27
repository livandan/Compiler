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
  r_la_, r_li_, r_mv_, r_neg_, r_nop_, r_not_, r_ret_, r_call_,
  // RV64 word (32-bit) arithmetic — sign-extend result to 64 bits
  r_addw_, r_subw_, r_addiw_,
  r_sllw_, r_srlw_, r_sraw_,
  r_slliw_, r_srliw_, r_sraiw_,
  r_mulw_, r_divw_, r_divuw_, r_remw_, r_remuw_,
  // RV64 64-bit memory operations
  r_ld_, r_sd_
};

struct RISCVInstruction {
  RISCVInstructionType instruction_type_;
  int rd_, rs1_, rs2_, imm_, label_;
  RISCVInstruction(const RISCVInstructionType type, const int rd,
      const int rs1, const int rs2, const int imm, const int label) :
      instruction_type_(type), rd_(rd), rs1_(rs1), rs2_(rs2),
      imm_(imm), label_(label) {}
};

struct MoveInstruction {
  int src_, dest_;
  const std::shared_ptr<IntegratedType> &type_;
  bool src_is_value_;
  MoveInstruction(const int src, const int dest, const std::shared_ptr<IntegratedType> &type, const bool src_is_value)
      : src_(src), dest_(dest), type_(type), src_is_value_(src_is_value) {}
};

void CodegenThrow(const std::string &err_info);

struct RISCVBlock {
  std::vector<RISCVInstruction> instructions_;
  std::vector<MoveInstruction> move_instructions_;
  std::vector<RISCVInstruction> jump_blocks_;
  // Instructions to be emitted *after* the phi-induced moves but *before*
  // the block terminator (branches/jumps). Used by conditional branches to
  // ensure their condition load survives the moves (which clobber scratch
  // registers).
  std::vector<RISCVInstruction> deferred_load_;
  void PushArithmetic_R(const RISCVInstructionType type, const int rd, const int rs1, const int rs2) {
    if ((type < 1 || type > 10) && type != r_addw_ && type != r_subw_
        && type != r_sllw_ && type != r_srlw_ && type != r_sraw_) {
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
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_add_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_andi_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_and_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_ori_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_or_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_xori_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_xor_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_slli_: {
        if (imm < 0) {
          CodegenThrow("Invalid slli.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sll_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_srli_: {
        if (imm < 0) {
          CodegenThrow("Invalid srli.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_srl_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_srai_: {
        if (imm < 0) {
          CodegenThrow("Invalid srai.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sra_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_slti_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_slt_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_sltiu_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sltu_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_addiw_: {
        if (imm >= -2048 && imm <= 2047) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_addw_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_slliw_: {
        if (imm < 0) {
          CodegenThrow("Invalid slliw.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sllw_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_srliw_: {
        if (imm < 0) {
          CodegenThrow("Invalid srliw.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_srlw_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      case r_sraiw_: {
        if (imm < 0) {
          CodegenThrow("Invalid sraiw.");
        } else if (imm <= 15) {
          instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
        } else {
          int tmp_reg = 31;
          if (rs1 == tmp_reg) {
            tmp_reg = 5;
          }
          instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
          instructions_.push_back(RISCVInstruction(r_sraw_, rd, rs1, tmp_reg, -1, -1));
        }
        break;
      }
      default: {
        CodegenThrow("Incorrectly use PushArithmetic_I(...).");
      }
    }
  }
  void PushMemory_I(const RISCVInstructionType type, const int rd, const int imm, const int rs1) {
    if ((type < 20 || type > 24) && type != r_ld_) {
      CodegenThrow("Incorrectly use PushMemory_I(...).");
    }
    if (imm >= -2048 && imm <= 2047) {
      instructions_.push_back(RISCVInstruction(type, rd, rs1, -1, imm, -1));
    } else {
      int tmp_reg = 31;
      if (rs1 == tmp_reg) {
        tmp_reg = 5;
      }
      instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, tmp_reg, rs1, tmp_reg, -1, -1));
      instructions_.push_back(RISCVInstruction(type, rd, tmp_reg, -1, 0, -1));
    }
  }
  void PushMemory_S(const RISCVInstructionType type, const int rs2, const int imm, const int rs1) {
    if ((type < 25 || type > 27) && type != r_sd_) {
      CodegenThrow("Incorrectly use PushMemory_S(...).");
    }
    if (imm >= -2048 && imm <= 2047) {
      instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, imm, -1));
    } else {
      int tmp_reg = 31;
      if (rs1 == tmp_reg || rs2 == tmp_reg) {
        tmp_reg = 5;
      }
      if (rs1 == tmp_reg || rs2 == tmp_reg) {
        tmp_reg = 6;
      }
      instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, tmp_reg, rs1, tmp_reg, -1, -1));
      instructions_.push_back(RISCVInstruction(type, -1, tmp_reg, rs2, 0, -1));
    }
  }
  void PushControl_B(const RISCVInstructionType type, const int rs1, const int rs2, const int label) {
    if (type < 28 || type > 33) {
      CodegenThrow("Incorrectly use PushControl_B(...).");
    }
    instructions_.push_back(RISCVInstruction(type, -1, rs1, rs2, -1, static_cast<int>(jump_blocks_.size())));
    jump_blocks_.push_back(RISCVInstruction(r_j_, -1, -1, -1, -1, label));
  }
  void PushExtended(const  RISCVInstructionType type, const int rd, const int rs1, const int rs2) {
    if ((type < 40 || type > 44) && type != r_mulw_ && type != r_divw_
        && type != r_divuw_ && type != r_remw_ && type != r_remuw_) {
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
      int tmp_reg = 31;
      if (rs1 == tmp_reg) {
        tmp_reg = 5;
      }
      instructions_.push_back(RISCVInstruction(r_li_, tmp_reg, -1, -1, imm, -1));
      instructions_.push_back(RISCVInstruction(r_add_, tmp_reg, rs1, tmp_reg, -1, -1));
      instructions_.push_back(RISCVInstruction(r_jalr_, rd, tmp_reg, -1, 0, -1));
    }
  }
  void PushLi(const int rd, const int imm) {
    instructions_.push_back(RISCVInstruction(r_li_, rd, -1, -1, imm, -1));
  }
  void PushReturn(const int released_stack_space) {
    if (released_stack_space < 2048) {
      PushArithmetic_I(r_addi_, 2, 2, released_stack_space);
    } else {
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
  } // builtin: 0-print; 1-println; 2-printInt; 3-printlnInt; 4-getString; 5-getInt; 6-builtin_memset; 7-builtin_memcpy
  void PushMove(const std::shared_ptr<IntegratedType> &type, const bool src_is_value, const int src, const int dest) {
    move_instructions_.push_back(MoveInstruction(src, dest, type, src_is_value));
  }
};

struct RISCVFunctionNode {
  explicit RISCVFunctionNode(const int stack_space = 0) : stack_space_(stack_space) {}
  int stack_space_;
  RISCVBlock alloca_block_;
  std::map<int, RISCVBlock> blocks_;
  std::map<int, std::pair<bool, int>> location_; // int, bool, int: var_id, is_in_register, location
};

struct BlockJumping {
  int from, to;
  bool operator<(const BlockJumping &b) const {
    if (from < b.from) {
      return true;
    }
    if (from > b.from) {
      return false;
    }
    if (to < b.to) {
      return true;
    }
    return false;
  }
};

struct AssignmentGraph {
private:
  const int max_n_;
  struct Edge { // u -> v means v = u
    int to, next;
    const std::shared_ptr<IntegratedType> &type;
  };
  std::vector<int> heads_;
  std::vector<int> status_; // 0: not ready; 1: ready; 2: temporarily stored
  std::vector<Edge> edges_;
  std::map<int, int> tmp_store_;
public:
  AssignmentGraph() : max_n_(0) {
    CodegenThrow("The graph cannot be default constructed.");
  }
  explicit AssignmentGraph(const int max_n) : max_n_(max_n) {
    heads_.resize(max_n_);
    status_.resize(max_n_);
    // edges_.resize(0);
    for (int i = 0; i < max_n_; ++i) {
      heads_[i] = -1;
      status_[i] = 0;
    }
  }
  void AddEdge(const int src, const int dest, const std::shared_ptr<IntegratedType> &type) {
    edges_.push_back({dest, heads_[src], type});
    heads_[src] = static_cast<int>(edges_.size()) - 1;
  }
  void EliminateCycles(const BlockJumping block_jump, int &tmp_var_id, std::map<int, RISCVBlock> &blocks) {
    while (true) {
      for (int i = 0; i < max_n_; ++i) {
        for (int edge_id = heads_[i], previous_edge_id = -1; edge_id != -1; edge_id = edges_[edge_id].next) {
          const Edge &edge = edges_[edge_id];
          int src = i;
          if (status_[i] == 2) {
            src = tmp_store_[i];
          }
          if (status_[edge.to]) {
            blocks[block_jump.from].PushMove(edge.type, false, src, edge.to);
            if (previous_edge_id == -1) {
              heads_[i] = edge.next;
            } else {
              edges_[previous_edge_id].next = edge.next;
            }
          } else {
            previous_edge_id = edge_id;
          }
        }
      }
      bool finished = true;
      bool stuck = true;
      for (int i = 0; i < max_n_; ++i) {
        if (heads_[i] != -1) {
          finished = false;
        }
        if (status_[i] == 0) {
          if (heads_[i] == -1) {
            status_[i] = 1;
            stuck = false;
          }
        }
      }
      if (finished) {
        return;
      }
      if (stuck) {
        int to_be_stored = -1;
        for (int i = 0; i < max_n_; ++i) {
          if (heads_[i] != -1 && status_[i] == 0) {
            to_be_stored = i;
            break;
          }
        }
        if (to_be_stored == -1) {
          CodegenThrow("Assignment graph cycle could not be resolved.");
        }
        const int new_tmp = tmp_var_id++;
        blocks[block_jump.from].PushMove(edges_[heads_[to_be_stored]].type, false, to_be_stored, new_tmp);
        tmp_store_[to_be_stored] = new_tmp;
        status_[to_be_stored] = 2;
      }
    }
  }
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
  void Generate();
  void Output(std::ofstream &output_file) const;
private:
  [[nodiscard]] std::pair<bool, int> GetParamPassPos(int function_id, int param_id) const;
  void PhiToMove();
  void MemAlloc(int func_id);
  void CompactStackFrame(int func_id);
  [[nodiscard]] int RegSavedLocation(int func_id, int reg_id) const; // return the relative address to the stack pointer
  void VariableAssignment(int func_id, RISCVBlock &r_block, int var_dest, int var_src, const std::shared_ptr<IntegratedType> &type); // %var_dest <- %var_src
  void ValueAssignment(int func_id, RISCVBlock &r_block, int var_dest, int value_src, const std::shared_ptr<IntegratedType> &type); // %var_dest <- value_src
  [[nodiscard]] std::pair<int, bool> GetSize(const std::shared_ptr<IntegratedType> &type) const;
  [[nodiscard]] int GetAlignment(const std::shared_ptr<IntegratedType> &type) const;
  static RISCVInstructionType GetLoadInst(const std::shared_ptr<IntegratedType> &type);
  static RISCVInstructionType GetStoreInst(const std::shared_ptr<IntegratedType> &type);

  // Register save/restore helpers — use post-allocation info to save only
  // registers that actually hold live values instead of the whole ABI set.
  void AnalyzeUsedRegisters();
  void SaveCallerRegs(int func_id, RISCVBlock &r_block);
  void RestoreCallerRegs(int func_id, RISCVBlock &r_block, int exclude_reg = -1);
  void SaveCallerRegsToTemp(int func_id, RISCVBlock &r_block);
  void RestoreCallerRegsFromTemp(int func_id, RISCVBlock &r_block);
  void SaveCalleeRegs(int func_id, RISCVBlock &r_block);
  void RestoreCalleeRegs(int func_id, RISCVBlock &r_block);
  void FlushSavedRegisters(int func_id, RISCVBlock &r_block);
  void PeepholeOptimizeBlock(RISCVBlock &r_block, const std::set<int> &live_out_regs) const;
  // Returns the set of caller-saved registers (excluding ra) that are actually
  // assigned to variables after register allocation.  Call sites always save
  // ra+x1 regardless.
  [[nodiscard]] const std::set<int> &GetUsedCallerRegs(int func_id) const { return used_caller_regs_[func_id]; }
  [[nodiscard]] const std::set<int> &GetUsedCalleeRegs(int func_id) const { return used_callee_regs_[func_id]; }
  void PrintReg(std::ofstream &file, int reg) const;
  void PrintLabel(std::ofstream &file, int label, int func_id) const;
  void PrintJumpLabel(std::ofstream &file, int block_label, int jump_label, int func_id) const;
  void Print_AR(std::ofstream &file, const RISCVInstruction &instruction) const;
  void Print_AI(std::ofstream &file, const RISCVInstruction &instruction) const;
  void Print_MI(std::ofstream &file, const RISCVInstruction &instruction) const;
  void Print_MS(std::ofstream &file, const RISCVInstruction &instruction) const;
  void Print_B(std::ofstream &file, const RISCVInstruction &instruction, int func_id, int block_id) const;
  void Print(std::ofstream &file, const RISCVInstruction &instruction, int func_id, int block_id) const;
  const std::vector<IRFunctionNode> &IR_functions_;
  const std::vector<IRStructNode> &IR_structs_;
  std::vector<RISCVFunctionNode> RISCV_functions_;
  const int main_func_id_;
  std::vector<std::set<int>> alloca_var_ids_;  // [func_id] -> vars whose stack slot holds a pointer (alloca results)
  // Registers that actually hold variables after register allocation.
  // Computed by AnalyzeUsedRegisters() after RA runs.
  std::vector<std::set<int>> used_callee_regs_;  // callee-saved regs assigned to variables
  std::vector<std::set<int>> used_caller_regs_;  // caller-saved regs assigned to variables
  std::vector<std::map<int, int>> reg_save_offsets_;  // [func_id][reg] -> stack offset
  std::vector<bool> registers_saved_;  // per-function: caller-saved regs are currently in save slots
  std::vector<bool> is_leaf_;         // per-function: leaf (no calls)
};

#endif

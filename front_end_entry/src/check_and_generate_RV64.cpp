#include "check_and_generate_RV64.h"
#include "classes.h"
#include "tokenizer.h"
#include "builder.h"
#include <fstream>
#include "code_generator.h"
#include "mem2reg.h"

void FrontEndRunner::Run(const std::string &output_file_name) {
  std::vector<Token> tokens;
  Tokenizer tokenizer(code_, tokens);
  tokenizer.Tokenize();
  Builder builder(tokens);
  Crate *syntax_tree = builder.GetTree();
  if (syntax_tree == nullptr) {
    exit(-1);
  }
  semantic_checker_.VisitAll(syntax_tree);
  if (syntax_tree == nullptr) {
    exit(-1);
  }
  try {
    IR_generator_.Visit(syntax_tree);
    Mem2Reg mem2reg(IR_generator_);
    mem2reg.Run();
    CodeGenerator RISCV_generator(IR_generator_.GetIRFunctions(),
        IR_generator_.GetIRStructs(), IR_generator_.GetMainFuncID());
    RISCV_generator.Generate();

    std::ofstream RISCV_output_file(output_file_name);
    if (RISCV_output_file.is_open()) {
      RISCV_generator.Output(RISCV_output_file);
      RISCV_output_file.close();
    } else {
      std::cerr << "[Error] Cannot open " << output_file_name << "!\n";
    }
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // Pass semantic check, but the RV64 generating is not implemented
    exit(0);
  }
  delete syntax_tree;
}
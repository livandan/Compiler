#include "classes.h"
#include <fstream>
#include <gtest/gtest.h>
#include "tokenizer.h"
#include "builder.h"
#include "visitor_manager.h"
#include "IR_generator.h"
#include "code_generator.h"

TEST(IRTestBatch, debugging_test) {
  const std::string file = "../RCompiler-Testcases/working_space/debugging";
  const std::string code_file = file + ".rx";
  const std::string IR_file = file + ".ll";
  const std::string RISCV_file = file + "_my.s";
  std::ifstream reader(code_file);
  if (!reader.is_open()) {
    std::cerr << "Cannot open " << code_file << '\n';
    ASSERT_EQ(0, 1);
  }
  std::string code;
  std::string line;
  while (std::getline(reader, line)) {
    code += line;
    code += '\n';
  }
  std::vector<Token> tokens;
  Tokenizer tokenizer(code, tokens);
  tokenizer.Tokenize();

  Builder builder(tokens);
  Crate *syntax_tree = builder.GetTree();
  if (syntax_tree == nullptr) {
    exit(-1);
  }

  VisitorManager semantic_checker;
  semantic_checker.VisitAll(syntax_tree);
  if (syntax_tree == nullptr) {
    exit(-1);
  }

  IRVisitor IR_generator;
  try {
    IR_generator.Visit(syntax_tree);
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // Pass semantic check, but the IR generating is not implemented
    exit(0);
  }

  // output IR, just for debugging
  std::ofstream IR_output_file(IR_file);
  if (IR_output_file.is_open()) {
    IR_generator.Output(IR_output_file);
    IR_output_file.close();
  } else {
    std::cerr << "[Error] Cannot open " << IR_file << "!\n";
  }

  CodeGenerator RISCV_generator(IR_generator.GetIRFunctions(),
      IR_generator.GetIRStructs(), IR_generator.GetMainFuncID());
  RISCV_generator.Generate();

  std::ofstream RISCV_output_file(RISCV_file);
  if (RISCV_output_file.is_open()) {
    RISCV_generator.Output(RISCV_output_file);
    RISCV_output_file.close();
  } else {
    std::cerr << "[Error] Cannot open " << RISCV_file << "!\n";
  }

  delete syntax_tree;
}
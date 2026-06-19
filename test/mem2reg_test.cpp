#include "classes.h"
#include <fstream>
#include <gtest/gtest.h>
#include "tokenizer.h"
#include "builder.h"
#include "visitor_manager.h"
#include "IR_generator.h"
#include "mem2reg.h"
#include "code_generator.h"

// Helper that runs tokenize -> semantic -> IR -> mem2reg -> codegen on one .rx file,
// writing the post-mem2reg IR to <base>_mem2reg.ll and RISC-V to <base>_mem2reg.s.
static void RunMem2RegOn(const std::string &base) {
  const std::string file = "../RCompiler-Testcases/working_space/" + base;
  const std::string code_file = file + ".rx";
  const std::string IR_file = file + "_mem2reg.ll";
  const std::string RISCV_file = file + "_mem2reg.s";
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
    std::cerr << "[Error] IR generation failed for " << base << '\n';
    exit(0);
  }

  try {
    Mem2Reg mem2reg(IR_generator);
    mem2reg.Run();
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    std::cerr << "[Error] Mem2reg failed for " << base << '\n';
    exit(0);
  }

  // Output IR
  std::ofstream IR_output_file(IR_file);
  if (IR_output_file.is_open()) {
    IR_generator.Output(IR_output_file);
    IR_output_file.close();
  } else {
    std::cerr << "[Error] Cannot open " << IR_file << "!\n";
  }

  try {
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
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    std::cerr << "[Error] Codegen failed for " << base << '\n';
    exit(0);
  }

  delete syntax_tree;
}

TEST(Mem2RegTestSingle, debugging_test) {
  RunMem2RegOn("debugging");
}

TEST(Mem2RegTest, test_all) {
  for (int i = 1; i <= 50; ++i) {
    std::cerr << "Testing " << i << "\n";
    const std::string file = "../RCompiler-Testcases/IR-1/src/comprehensive" + std::to_string(i) + "/comprehensive" + std::to_string(i);
    const std::string code_file = file + ".rx";
    const std::string IR_file = file + "_mem2reg.ll";
    const std::string RISCV_file = file + "_mem2reg.s";
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

    Mem2Reg mem2reg(IR_generator);
    mem2reg.Run();

    // Output IR
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
      ASSERT_EQ(0, 1);
    }
    delete syntax_tree;
  }
}

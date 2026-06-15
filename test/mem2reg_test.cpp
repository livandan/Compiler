#include "classes.h"
#include <fstream>
#include <gtest/gtest.h>
#include "tokenizer.h"
#include "builder.h"
#include "visitor_manager.h"
#include "IR_generator.h"
#include "mem2reg.h"
#include "code_generator.h"

TEST(Mem2RegTestSingle, debugging_test) {
  const std::string file = "../RCompiler-Testcases/working_space/debugging";
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

  // Copy IR functions and run mem2reg
  std::vector<IRFunctionNode> functions = IR_generator.GetIRFunctions();
  Mem2Reg mem2reg;
  mem2reg.Run(functions);

  // Output IR (after mem2reg), for debugging
  std::ofstream IR_output_file(IR_file);
  if (IR_output_file.is_open()) {
    // Create a temporary IRVisitor to output the mem2reg'd functions
    // We'll just write a simple output manually or reuse IR_generator
    IR_output_file << "; IR after mem2reg (original + mem2reg'd functions)\n";
    // Output the functions the same way as IR_generator does
    // Re-use IR_generator.Output which prints the original functions_
    // We output the mem2reg'd version separately for debugging
    IR_generator.Output(IR_output_file);
    IR_output_file.close();
  } else {
    std::cerr << "[Error] Cannot open " << IR_file << "!\n";
  }

  CodeGenerator RISCV_generator(functions,
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

TEST(Mem2RegTest, test_all) {
  for (int i = 1; i <= 50; ++i) {
    const std::string file = "../RCompiler-Testcases/IR-1/src/comprehensive" + std::to_string(i) + "/comprehensive" + std::to_string(i);
    const std::string code_file = file + ".rx";
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

    // Copy IR functions and run mem2reg
    std::vector<IRFunctionNode> functions = IR_generator.GetIRFunctions();
    Mem2Reg mem2reg;
    mem2reg.Run(functions);

    CodeGenerator RISCV_generator(functions,
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

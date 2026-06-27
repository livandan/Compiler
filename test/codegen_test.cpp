#include "classes.h"
#include <fstream>
#include <gtest/gtest.h>
#include "tokenizer.h"
#include "builder.h"
#include "visitor_manager.h"
#include "IR_generator.h"
#include "code_generator.h"
#include "mem2reg.h"

static void RunMem2RegOn(const std::string &base) {
  const std::string file = "RCompiler-Testcases/" + base;
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
    // std::cerr << "[Error] IR generation failed for " << base << '\n';
    return;
  }

  try {
    Mem2Reg mem2reg(IR_generator);
    mem2reg.Run();
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // std::cerr << "[Error] Mem2reg failed for " << base << '\n';
    return;
  }

  // Output IR
  std::ofstream IR_output_file(IR_file);
  if (IR_output_file.is_open()) {
    IR_generator.Output(IR_output_file);
    IR_output_file.close();
  } else {
    // std::cerr << "[Error] Cannot open " << IR_file << "!\n";
  }

  try {
    CodeGenerator RISCV_generator(IR_generator.GetIRFunctions(),
        IR_generator.GetIRStructs(), IR_generator.GetMainFuncID());
    RISCV_generator.Generate();

    std::ofstream RISCV_output_file(RISCV_file);
    if (RISCV_output_file.is_open()) {
      // Prepend the builtin assembly so the .s file is self-contained for
      // local testing (link + run via reimu without an extra concat step).
      std::ifstream builtin("RCompiler-Testcases/IR-1/builtin/builtin.s");
      if (builtin.is_open()) {
        RISCV_output_file << builtin.rdbuf() << '\n';
        builtin.close();
      } else {
        // std::cerr << "[Warning] Cannot open builtin.s; output will be missing"
        //              " the runtime stubs.\n";
      }
      RISCV_generator.Output(RISCV_output_file);
      RISCV_output_file.close();
    } else {
      // std::cerr << "[Error] Cannot open " << RISCV_file << "!\n";
    }
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // std::cerr << "[Error] Codegen failed for " << base << '\n';
    return;
  }
  delete syntax_tree;
}

// TEST(CodegenTestSingle, sementic2_single_test) {
//   std::string test_id = "1";
//   const std::string file = "semantic-2/src/comprehensive" + test_id + "/comprehensive" + test_id;
//   RunMem2RegOn(file);
// }

TEST(CodegenTestSingle, debugging_test) {
  const std::string file = "working_space/debugging";
  RunMem2RegOn(file);
}

TEST(CodegenTest, test_all) {
  for (int i = 1; i <= 50; ++i) {
    const std::string file = "IR-1/src/comprehensive" + std::to_string(i) + "/comprehensive" + std::to_string(i);
    RunMem2RegOn(file);
  }
  for (int i = 1; i <= 50; ++i) {
    const std::string file = "semantic-2/src/comprehensive" + std::to_string(i) + "/comprehensive" + std::to_string(i);
    RunMem2RegOn(file);
  }
}
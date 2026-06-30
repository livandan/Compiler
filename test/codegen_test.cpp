#include "classes.h"
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <gtest/gtest.h>
#include <iomanip>
#include <system_error>
#include <utility>
#include "tokenizer.h"
#include "builder.h"
#include "visitor_manager.h"
#include "IR_generator.h"
#include "code_generator.h"
#include "mem2reg.h"

namespace {

struct StageTimer {
  explicit StageTimer(std::string base)
      : base_(std::move(base)), enabled_(std::getenv("RCOMPILER_TIMING") != nullptr),
        start_(Now()), last_(start_) {}

  void Mark(const std::string &name) {
    if (!enabled_) {
      return;
    }
    const auto now = Now();
    stages_.push_back({name, Ms(last_, now)});
    last_ = now;
  }

  void AddCounter(const std::string &name, const long long value) {
    if (enabled_) {
      counters_.push_back({name, value});
    }
  }

  void Print() const {
    if (!enabled_) {
      return;
    }
    const auto total_ms = Ms(start_, Now());
    std::cerr << "[timing] " << base_;
    std::cerr << std::fixed << std::setprecision(3);
    for (const auto &[name, value] : stages_) {
      std::cerr << ' ' << name << "_ms=" << value;
    }
    std::cerr << " total_ms=" << total_ms;
    for (const auto &[name, value] : counters_) {
      std::cerr << ' ' << name << '=' << value;
    }
    std::cerr << '\n';
  }

private:
  static timespec Now() {
    timespec ts{};
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts;
  }

  static double Ms(const timespec &begin, const timespec &end) {
    return (static_cast<double>(end.tv_sec - begin.tv_sec) * 1000.0)
        + (static_cast<double>(end.tv_nsec - begin.tv_nsec) / 1000000.0);
  }

  std::string base_;
  bool enabled_;
  timespec start_;
  timespec last_;
  std::vector<std::pair<std::string, double>> stages_;
  std::vector<std::pair<std::string, long long>> counters_;
};

static long long CountIRInstructions(const IRVisitor &IR_generator) {
  long long count = 0;
  for (const auto &function : IR_generator.GetIRFunctions()) {
    count += static_cast<long long>(function.alloca_instructions_.size());
    for (const auto &[block_id, block] : function.blocks_) {
      count += static_cast<long long>(block.phi_instructions_.size());
      count += static_cast<long long>(block.instructions_.size());
    }
  }
  return count;
}

static long long CountIRBlocks(const IRVisitor &IR_generator) {
  long long count = 0;
  for (const auto &function : IR_generator.GetIRFunctions()) {
    count += static_cast<long long>(function.blocks_.size());
  }
  return count;
}

static long long FileSizeOrMinusOne(const std::string &path) {
  std::error_code ec;
  const auto size = std::filesystem::file_size(path, ec);
  if (ec) {
    return -1;
  }
  return static_cast<long long>(size);
}

} // namespace

static void RunMem2RegOn(const std::string &base) {
  StageTimer timer(base);
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
  timer.Mark("read");
  timer.AddCounter("source_bytes", static_cast<long long>(code.size()));
  std::vector<Token> tokens;
  Tokenizer tokenizer(code, tokens);
  tokenizer.Tokenize();
  timer.Mark("tokenize");
  timer.AddCounter("tokens", static_cast<long long>(tokens.size()));

  Builder builder(tokens);
  Crate *syntax_tree = builder.GetTree();
  timer.Mark("parse");
  if (syntax_tree == nullptr) {
    exit(-1);
  }

  VisitorManager semantic_checker;
  semantic_checker.VisitAll(syntax_tree);
  timer.Mark("semantic");
  if (syntax_tree == nullptr) {
    exit(-1);
  }

  IRVisitor IR_generator;
  try {
    IR_generator.Visit(syntax_tree);
    timer.Mark("ir_generate");
    timer.AddCounter("ir_functions", static_cast<long long>(IR_generator.GetIRFunctions().size()));
    timer.AddCounter("ir_blocks", CountIRBlocks(IR_generator));
    timer.AddCounter("ir_insts_before_mem2reg", CountIRInstructions(IR_generator));
    const auto &inline_stats = IR_generator.GetInlineStats();
    timer.AddCounter("inline_rounds", inline_stats.rounds);
    timer.AddCounter("inline_callsites", inline_stats.callsites_inlined);
    timer.AddCounter("inline_eligible_functions", inline_stats.eligible_functions);
    timer.AddCounter("ir_insts_before_inline", inline_stats.instructions_before);
    timer.AddCounter("ir_insts_after_inline", inline_stats.instructions_after);
    timer.AddCounter("ir_blocks_before_inline", inline_stats.blocks_before);
    timer.AddCounter("ir_blocks_after_inline", inline_stats.blocks_after);
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // std::cerr << "[Error] IR generation failed for " << base << '\n';
    timer.Print();
    return;
  }

  try {
    Mem2Reg mem2reg(IR_generator);
    mem2reg.Run();
    timer.Mark("mem2reg");
    timer.AddCounter("ir_insts_after_mem2reg", CountIRInstructions(IR_generator));
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // std::cerr << "[Error] Mem2reg failed for " << base << '\n';
    timer.Print();
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
  timer.Mark("ir_output");
  timer.AddCounter("ir_output_bytes", FileSizeOrMinusOne(IR_file));

  try {
    CodeGenerator RISCV_generator(IR_generator.GetIRFunctions(),
        IR_generator.GetIRStructs(), IR_generator.GetMainFuncID());
    RISCV_generator.Generate();
    timer.Mark("codegen_generate");

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
    timer.Mark("asm_output");
    timer.AddCounter("asm_output_bytes", FileSizeOrMinusOne(RISCV_file));
  } catch (...) {
    delete syntax_tree;
    syntax_tree = nullptr;
    // std::cerr << "[Error] Codegen failed for " << base << '\n';
    timer.Print();
    return;
  }
  delete syntax_tree;
  timer.Mark("cleanup");
  timer.Print();
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

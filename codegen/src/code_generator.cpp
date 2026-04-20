#include "code_generator.h"
#include "fstream"

void CodeGenerator::Generate(const std::string &filename) {
  std::ifstream builtin_fn("../RCompiler-Testcases/IR-1/builtin/builtin_fn.txt");
  std::ifstream builtin_str("../RCompiler-Testcases/IR-1/builtin/builtin_str.txt");
  std::ofstream output_file(filename);
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

  // todo: generate the code of non-builtin functions
  for (int i = 0; i < functions_.size(); ++i) {

  }

  if (builtin_str.is_open()) {
    while (std::getline(builtin_str, line_in_file)) {
      output_file << line_in_file << '\n';
    }
    builtin_str.close();
  } else {
    std::cerr << "Cannot open builtin string file!\n";
  }
}
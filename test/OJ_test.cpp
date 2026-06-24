#include "classes.h"
#include "check_and_generate_RV64.h"
#include <fstream>

int main() {
  std::string code;
  std::string line;
  while (std::getline(std::cin, line)) {
    code += line;
    code += '\n';
  }
  FrontEndRunner runner(code);
  runner.Run("RCompiler-Testcases/working_space/debugging_my.s");
}
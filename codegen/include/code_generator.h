#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include "IR_generator.h"

class CodeGenerator {
public:
  explicit CodeGenerator(const std::vector<IRFunctionNode> &functions, const std::vector<IRStructNode> &structs)
      : functions_(functions), structs_(structs) {}
  void Generate(const std::string &filename);
private:
  const std::vector<IRFunctionNode> &functions_;
  const std::vector<IRStructNode> &structs_;
};

#endif
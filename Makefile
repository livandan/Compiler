.PHONY: build run

build:
	@mkdir -p build
	@cd build && cmake .. && cmake --build .

run:
	@./build/code
	@cat RCompiler-Testcases/IR-1/builtin/builtin.s >&2
	@cat RCompiler-Testcases/working_space/debugging_my.s
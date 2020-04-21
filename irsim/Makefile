OBJ_DIR := build
ANTLR_SRCS := IRBaseVisitor.cpp IRLexer.cpp IRParser.cpp IRVisitor.cpp
ANTLR_SRCS := $(addprefix $(OBJ_DIR)/, $(ANTLR_SRCS))
SRCS := irsim.cc main.cc
SRCS += $(shell find libfmt/ -name "*.cc")
OBJS := $(patsubst %.cc,$(OBJ_DIR)/%.o,$(SRCS))
BIN := $(OBJ_DIR)/irsim

.DEFAULT_GOAL := $(BIN)
CXXFLAGS := -Iinclude -std=c++17 -O0 -ggdb3 -Wall -MMD
-include $(OBJS:.o=.d)

$(ANTLR_SRCS): IR.g4
	antlr4 -runtime -Dlanguage=Cpp -no-listener -visitor -o $(OBJ_DIR) $<

$(BIN): $(OBJS)
	@echo "+ LNK $@"
	@g++ $^ -o $@

$(OBJ_DIR)/%.o: %.cc
	@echo "+ CC $<"
	@mkdir -p $(@D)
	@g++ -c $(CXXFLAGS) $< -o $@

run: $(BIN)
	@$(BIN) test/sgn.ir

gdb: $(BIN)
	gdb --args $(BIN) test/add.ir

clean:
	rm -rf $(OBJ_DIR)

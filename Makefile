# libco Makefile (refactored)
#
# 目录布局：
#   src/      协程库源码与头文件
#   example/  使用示例
#   bench/    基准测试
#   build/    全部构建产物（已 gitignore）
#     ├── obj/    目标文件
#     ├── lib/    libcolib.a / libcolib.{so,dylib}
#     └── bin/    example_* 与 bench_* 可执行文件
#
# 常用命令：
#   make            # 构建全部（库 + 示例 + 基准）
#   make lib        # 仅构建静态库与动态库
#   make examples   # 仅构建示例
#   make bench      # 仅构建基准
#   make clean      # 清理 build/

SRC_DIR     := src
EXAMPLE_DIR := example
BENCH_DIR   := bench
BUILD_DIR   := build
OBJ_DIR     := $(BUILD_DIR)/obj
LIB_DIR     := $(BUILD_DIR)/lib
BIN_DIR     := $(BUILD_DIR)/bin

CXX ?= c++
CC  ?= cc
AR  ?= ar

UNAME := $(shell uname -s)

CXXFLAGS += -g -O2 -Wall -pipe -D_GNU_SOURCE -D_REENTRANT -fPIC \
            -Wno-deprecated -I$(SRC_DIR)

ifeq ($(UNAME),Darwin)
  SO_EXT    := dylib
  SO_LDFLAGS := -dynamiclib
else
  SO_EXT    := so
  SO_LDFLAGS := -shared
  LDLIBS    += -ldl
endif
LDLIBS += -lpthread

# ---------------------------------------------------------------------------
# 库源文件（与上游编译顺序一致）
LIB_SRCS := $(SRC_DIR)/co_epoll.cpp \
            $(SRC_DIR)/co_routine.cpp \
            $(SRC_DIR)/co_hook_sys_call.cpp \
            $(SRC_DIR)/coctx_swap.S \
            $(SRC_DIR)/coctx.cpp \
            $(SRC_DIR)/co_comm.cpp

LIB_OBJS   := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(filter %.cpp,$(LIB_SRCS))) \
              $(patsubst $(SRC_DIR)/%.S,$(OBJ_DIR)/%.o,$(filter %.S,$(LIB_SRCS)))
LIB_STATIC := $(LIB_DIR)/libcolib.a
LIB_SHARED := $(LIB_DIR)/libcolib.$(SO_EXT)

# 示例与基准
EXAMPLE_SRCS := $(wildcard $(EXAMPLE_DIR)/*.cpp)
EXAMPLE_BINS := $(patsubst $(EXAMPLE_DIR)/%.cpp,$(BIN_DIR)/%,$(EXAMPLE_SRCS))

BENCH_SRCS := $(wildcard $(BENCH_DIR)/*.cpp)
BENCH_BINS := $(patsubst $(BENCH_DIR)/%.cpp,$(BIN_DIR)/%,$(BENCH_SRCS))

.PHONY: all lib examples bench clean help

all: lib examples bench

lib: $(LIB_STATIC) $(LIB_SHARED)

examples: $(EXAMPLE_BINS)

bench: $(BENCH_BINS)

$(LIB_STATIC): $(LIB_OBJS) | $(LIB_DIR)
	$(AR) -rc $@ $^

$(LIB_SHARED): $(LIB_OBJS) | $(LIB_DIR)
	$(CXX) $(SO_LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.S | $(OBJ_DIR)
	$(CC) $(CXXFLAGS) -c $< -o $@

$(EXAMPLE_BINS): $(BIN_DIR)/%: $(EXAMPLE_DIR)/%.cpp $(LIB_STATIC) | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $< $(LIB_STATIC) $(LDLIBS) -o $@

$(BENCH_BINS): $(BIN_DIR)/%: $(BENCH_DIR)/%.cpp $(LIB_STATIC) | $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $< $(LIB_STATIC) $(LDLIBS) -o $@

$(OBJ_DIR) $(LIB_DIR) $(BIN_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Targets: all | lib | examples | bench | clean"
	@echo "  lib      -> $(LIB_STATIC) $(LIB_SHARED)"
	@echo "  examples -> $(EXAMPLE_BINS)"
	@echo "  bench    -> $(BENCH_BINS)"

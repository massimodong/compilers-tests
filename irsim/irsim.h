#ifndef IRSIM_H
#define IRSIM_H

#include <iostream>
#include <limits.h>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "fmt/printf.h"

namespace irsim {

template <class T>
int ptr_hi(const T *ptr) {
  return static_cast<int>(
      reinterpret_cast<uintptr_t>(ptr) >> 32);
}

template <class T>
int ptr_lo(const T *ptr) {
  return static_cast<int>(reinterpret_cast<uintptr_t>(ptr));
}

template <class T>
T *lohi_to_ptr(uint32_t lo, uint32_t hi) {
  uintptr_t ptr = ((uint64_t)hi << 32) | lo;
  return reinterpret_cast<T *>(ptr);
}

/* clang-format off */
enum class Exception {
  IF, LOAD, STORE, DIV_ZERO, TIMEOUT, OOM, ABORT, INVOP, EOF_OCCUR, NO_EXCEPT,
};

enum class Stmt {
  begin,
  label = Stmt::begin,
  func, assign, add, sub, mul, div, takeaddr, deref,
  deref_assign, goto_, branch, ret, dec, arg, call,
  param, read, write,
  end,
};

enum class Opc {
  abort, // as 0
  inst_begin,
  helper, // native call
  arg, param, lai, la, ld, st, inc_esp, li, mov, add, sub,
  mul, div, br, cond_br, lt, le, eq, ge, gt, ne, alloca,
  call, ret, read, write,
  quit,
};
/* clang-format on */

using TransitionBlock = std::array<int, 4 * 1024>;

class ProgramInput {
  std::istream *is;
  std::vector<int> *vec;

  friend class Program;

public:
  ProgramInput(std::istream &is) : is(&is), vec(nullptr) {}
  ProgramInput(std::vector<int> &vec)
      : is(nullptr), vec(&vec) {}
  ProgramInput(const ProgramInput &that) = default;

  int read() {
    if (vec) {
      auto ret = vec->back();
      vec->pop_back();
      return ret;
    } else {
      int ret;
      //fmt::printf("please input a number: ");
      (*is) >> ret;
      return ret;
    }
  }
  bool eof() {
      return is->eof();
  }
};

class ProgramOutput {
  std::ostream *os;
  std::vector<int> *vec;

  friend class Program;

public:
  ProgramOutput(std::ostream &os) : os(&os), vec(nullptr) {}
  ProgramOutput(std::vector<int> &vec)
      : os(nullptr), vec(&vec) {}
  ProgramOutput(const ProgramOutput &that) = default;

  void write(int v) {
    if (vec) {
      vec->push_back(v);
    } else {
      (*os) << v << "\n";
    }
  }
};

class ProgramIO : public ProgramInput,
                  public ProgramOutput {
public:
  ProgramIO(ProgramInput in, ProgramOutput out)
      : ProgramInput(in), ProgramOutput(out) {}
};

class Program {
  ProgramIO io;

  unsigned memory_limit;
  unsigned insts_limit;

  unsigned inst_counter;

  std::vector<std::unique_ptr<TransitionBlock>> codes;
  TransitionBlock *curblk;
  int *textptr;

  std::vector<std::unique_ptr<int[]>> mempool;

  /* running context */
  std::vector<int> stack;
  int *esp;
  int *curf;

  friend class Compiler;

public:
  Exception exception;

public:
  Program()
      : io(std::cin, std::cout),
        memory_limit(4 * 1024 * 1024), insts_limit(-1u) {
    exception = Exception::NO_EXCEPT;
    inst_counter = 0;
    curblk = new TransitionBlock;
    codes.push_back(
        std::unique_ptr<TransitionBlock>(curblk));
    textptr = &curblk->at(0);

    curf = gen_inst(Opc::quit, Opc::quit);
  }

  void setMemoryLimit(unsigned lim) { memory_limit = lim; }

  void setInstsLimit(unsigned lim) { insts_limit = lim; }

  unsigned getInstCounter() const { return inst_counter; }

  void setIO(ProgramIO io) { this->io = io; }
  void setInput(ProgramInput in) {
    static_cast<ProgramInput &>(this->io) = in;
  }
  void setOutput(ProgramOutput out) {
    static_cast<ProgramOutput &>(this->io) = out;
  }

  int *get_textptr() const { return textptr; }
  void check_eof(unsigned N) {
    if (textptr + N + 2 >= &(*curblk)[curblk->size()]) {
      curblk = new TransitionBlock;
      codes.push_back(
          std::unique_ptr<TransitionBlock>(curblk));
      *textptr++ = (int)Opc::br;
      *textptr++ = ptr_lo(&(curblk->at(0)));
      *textptr++ = ptr_hi(&(curblk->at(0)));
      textptr = &curblk->at(0);
    }
  }

  template <class... Args>
  int *gen_inst(Opc opc, Args... args) {
    constexpr unsigned N = sizeof...(args);
    check_eof(N + 1);
    auto oldptr = textptr;
    *textptr++ = (int)opc;
    for (int v :
        std::array<int, N>{static_cast<int>(args)...}) {
      *textptr++ = v;
    }

#ifdef DEBUG
    fmt::printf(
        "  %p: %s", fmt::ptr(oldptr), opc_to_string[opc]);
    for (int v :
        std::array<int, N>{static_cast<int>(args)...}) {
      fmt::printf("0x%x ", v);
    }
    fmt::printf("\n");
#endif
    return oldptr;
  }

  int *gen_call(int *target) {
    return gen_inst(
        Opc::call, ptr_lo(target), ptr_hi(target));
  }

  int *gen_br(int *target) {
    return gen_inst(
        Opc::br, ptr_lo(target), ptr_hi(target));
  }

  int *gen_cond_br(int cond, int *target) {
    return gen_inst(
        Opc::cond_br, cond, ptr_lo(target), ptr_hi(target));
  }

  int run(int *eip);
};

class Compiler {
  int stack_size;
  int args_size;

  std::map<std::string, int> vars;
  std::map<std::string, int *> funcs;
  std::map<std::string, int *> labels;

  std::map<int, bool> temps;

  std::map<std::string, std::vector<int *>> backfill_labels;

  std::vector<int *> backfill_args;

  static std::map<Stmt,
      bool (Compiler::*)(Program *, const std::string &)>
      handlers;

  static constexpr int m1[] = {1};
  static constexpr int m2[] = {1, 2};
  static constexpr int m3[] = {1, 2, 3};
  static constexpr int m4[] = {1, 2, 3, 4};

  int primary_exp(Program *prog, const std::string &tok,
      int to = INT_MAX);

  bool handle_label(Program *, const std::string &line);
  bool handle_func(Program *, const std::string &line);
  bool handle_assign(Program *, const std::string &line);
  bool handle_arith(Program *, const std::string &line);
  bool handle_takeaddr(Program *, const std::string &line);
  bool handle_deref(Program *, const std::string &line);
  bool handle_deref_assign(
      Program *, const std::string &line);
  bool handle_goto_(Program *, const std::string &line);
  bool handle_branch(Program *, const std::string &line);
  bool handle_ret(Program *, const std::string &line);
  bool handle_dec(Program *, const std::string &line);
  bool handle_arg(Program *, const std::string &line);
  bool handle_call(Program *, const std::string &line);
  bool handle_param(Program *, const std::string &line);
  bool handle_read(Program *, const std::string &line);
  bool handle_write(Program *, const std::string &line);

public:
  Compiler() { clear_env(); }

  void clear_env() {
    stack_size = 1;
    args_size = -2;
    vars.clear();
    labels.clear();
  }

  int *getFunction(const std::string &fname) {
    return funcs[fname];
  }

  int getVar(const std::string &name, unsigned size = 1) {
    auto it = vars.find(name);
    if (it == vars.end()) {
      std::tie(it, std::ignore) = vars.insert(
          std::pair<std::string, int>{name, stack_size});
      stack_size += size;
    }
    return it->second;
  }

  void clearTemps() {
    for (auto &kvpair : temps) kvpair.second = false;
  }

  int newTemp() {
    for (auto &kvpair : temps) {
      if (!kvpair.second) {
        kvpair.second = true;
        return kvpair.first;
      }
    }

    auto tmp = stack_size++;
    temps[tmp] = true;
    return tmp;
  }

  int newArg() {
    stack_size++;
    return stack_size - 1;
  }

  int getRet() { return -1; }

  int getParam(const std::string &name) {
    auto it = vars.find(name);
    if (it == vars.end())
      std::tie(it, std::ignore) = vars.insert(
          std::pair<std::string, int>{name, args_size--});
    return it->second;
  }

  std::unique_ptr<Program> compile(std::istream &is);
};

} // namespace irsim

template <>
struct fmt::formatter<irsim::Exception> {
  constexpr auto parse(format_parse_context& ctx) { return ctx.begin(); }

  template <typename FormatContext>
  auto format(const irsim::Exception& d, FormatContext& ctx) {
    switch (d) {
    case irsim::Exception::IF:
      return format_to(ctx.out(), "IF");
    case irsim::Exception::LOAD:
      return format_to(ctx.out(), "LOAD");
    case irsim::Exception::STORE:
      return format_to(ctx.out(), "STORE");
    case irsim::Exception::DIV_ZERO:
      return format_to(ctx.out(), "DIV_ZERO");
    case irsim::Exception::TIMEOUT:
      return format_to(ctx.out(), "TIMEOUT");
    case irsim::Exception::OOM:
      return format_to(ctx.out(), "OOM");
    case irsim::Exception::ABORT:
      return format_to(ctx.out(), "ABORT");
    case irsim::Exception::INVOP:
      return format_to(ctx.out(), "INVOP");
    case irsim::Exception::EOF_OCCUR:
      return format_to(ctx.out(), "EOF occured");
    case irsim::Exception::NO_EXCEPT:
      return format_to(ctx.out(), "0");
    };
    return format_to(ctx.out(), "???");
  }
};

#endif

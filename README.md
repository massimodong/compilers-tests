# CI4C--\_Compiler

![Run Tests](https://github.com/zhengzangw/CI4C--_Compiler/workflows/Run%20Tests/badge.svg)

基于 [compilers-tests](https://github.com/massimodong/compilers-tests) 魔改的编译原理实验持续集成方案。

## 使用方法

第一次运行

```bash
./autotest.sh path_to_parser_binary
```

之后运行无需参数即可测试

```bash
./autotest.sh
```

参数含义如下

| 参数         | 作用                 |
| ------------ | -------------------- |
| -h --help    | 帮助信息             |
| -q --quiet   | 静默输出             |
| -t test_num  | 选择测试集，默认为 1 |
| -n file_name | 选择单个测试文件测试 |

## 添加测试集

在 `tests` 目录下添加 `tests-n` 目录，并在 `checks` 文件夹下提供 `check-n.sh` 文件（定义 `check` 函数供比较，错误应返回 1，正确返回 0），即可添加测试集。

每个测试用例应包含形如 `yourtest.cmm` 和 `yourtest.out` 的两个文件。

## 测试函数

### Lab 1

对于没有词法/语法错误的输入，会检查输出是否严格相同。

对于有词法/语法错误的输入，只会检查是否报错了。

## 本地持续集成

由于实验规定不能修改 Code 目录中的 Makfile，可以在 Lab 目录中新建 `makefile`，在原来的 makefile 基础上做以下修改，并对应修改 `clean` 命令中的参数即可。

```diff
SRC = Code
CFILES = $(shell find ./$(SRC)/ -name "*.c")
LFILE = $(shell find ./$(SRC)/ -name "*.l")
YFILE = $(shell find ./$(SRC)/ -name "*.y")
LFC = $(shell find ./$(SRC)/ -name "*.l" | sed s/[^/]*\\.l/lex.yy.c/)
YFC = $(shell find ./$(SRC)/ -name "*.y" | sed s/[^/]*\\.y/syntax.tab.c/)
```

将 `CI4C--_Compiler` 下载到本地后，新建 `test1` 伪目标，修改 `CI` 变量的值到脚本路径即可通过 `make test1` 进行测试。

## Github 持续集成

Github 持续集成可以让每次有新测试数据的时候在 github 上自动地执行测试脚本。

Fork 本仓库后，在仓库中设置如下 secrets：

1. `LAB_REPO` 编译器实验代码仓库目录，如 username/reponame
2. `GITHUB_PAT` GitHub Prosonal Access Token with repo access

前往 Actions 页面启用即可。

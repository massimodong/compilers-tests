# compilers-tests

We are now on Lab3. Switch to branch `L1` or `L1-hard` for Lab1. Switch to branch `L2` for Lab2.

编译原理 Lab3 一键测试脚本。

使用方法：

第一次运行执行 `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。  
之后只需要执行 `./run.sh`。 

# IR 模拟器说明

脚本执行需要实现一个 CLI 的 IR 模拟器 `irsim.py`：

- 模拟器接受一个参数：IR 文件路径
- 对于 READ/WRITE 指令，从标准输入读取，输出到标准输出。
- 对于模拟器本身的相关输出，均输出到标准错误输出。

目前 `irsim.py` 没有实现。

# 添加测试文件

请添加 `test.cmm` 和 `test.in` 两个文件。其中

* `test.cmm` 是源码文件
* `test.in` 是程序执行时输入的数据文件

测试脚本采取以下策略进行测试：

1. 使用 GCC 编译 CMM 源码，使用数据文件作为标准输入执行编译后的二进制文件，得到输出结果作为标准输出。
   - `template.c` 中包含了 GCC 编译的模板 C 代码，目前其提供了一个基础的 `read/write` 实现。
2. 调用你的编译器编译 CMM 源码得到中间代码，使用数据文件作为标准输入调用 `irsim.py` 运行 IR，得到输出结果作为实际输出。
3. 比对标准输出和实际输出

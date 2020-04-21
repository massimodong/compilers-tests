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
* `test.json` 是答案描述文件，格式为

```
[
    [input1, output1, ret_val1],
    [input2, output2, ret_val2],
    ...
    [inputk, outputk, ret_valk]
]
```
input和output分别对应输入和输出，也为**列表**，且列表的所有成员均为**整型数**
示例：(tests/naive.json)
```
[
    [[], [2, 0, 1, 7], 0]
]
```
意为，naive.cmm编译成.ir后，仅有一组测试，
该组测试的输入为空，输出为2 0 1 7四个数字。最顶层的main函数应该返回0（由于irsim没有对应接口，目前ret_val被忽略）

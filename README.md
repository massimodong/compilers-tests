# compilers-tests

We are now on Lab4. Switch to branch `L1` or `L1-hard` for Lab1. Switch to branch `L2` for Lab2. Switch to branch `L3` for Lab3.

编译原理 Lab4 一键测试脚本。

使用方法：

请先安装`spim`模拟器。  
第一次运行执行 `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。 
之后只需要执行 `./run.sh`。 

## 添加测试文件

请添加 `test.cmm` 和 `test.json` 两个文件。其中

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
该组测试的输入为空，输出为2 0 1 7四个数字。最顶层的main函数应该返回0（由于irsim没有对应接口，它的返回值是解释器的返回值，表示的是解释器是否遇到问题。所以，目前ret_val实际上会被忽略）

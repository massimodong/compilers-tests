# compilers-tests

We are now on Lab2. Switch to branch `L1` or `L1-hard` for Lab1.

编译原理 Lab2 一键测试脚本。

使用方法：  
第一次运行执行 `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。  
之后只需要执行 `./run.sh`。  
对于没有词法/语法错误的输入，会检查输出是否严格相同。  
对于有词法/语法错误的输入，只会检查是否报错了。

# 添加测试文件

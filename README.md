# compilers-tests

使用方法： `./run.sh path_to_parser_binary` 。`path_to_binary` 为编译好的 parser 文件。
对于没有词法/语法错误的输入，会检查输出是否严格相同。
对于有词法/语法错误的输入，只会检查是否报错了。

# 添加测试文件
在 `tests` 目录下添加 `yourtest.cmm` 和 `yourtest.out` 两个文件。

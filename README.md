# compilers-tests

编译原理 Lab1 一键测试脚本。

使用方法： `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。
对于没有词法/语法错误的输入，会检查输出是否严格相同。
对于有词法/语法错误的输入，只会检查是否报错了。

# 添加测试文件
在 `tests` 目录下添加 `yourtest.cmm` 和 `yourtest.out` 两个文件。

# 配置自动化测试

前往仓库设置如下 secrets：

1. `LAB_REPO` 实验代码仓库目录

2. `GITHUB_PAT` GitHub Prosonal Access Token

若不想启用功能，可进入 “设置->Action” 内禁用之。
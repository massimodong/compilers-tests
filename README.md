# compilers-tests

编译原理 Lab1 一键测试脚本。

使用方法：  
第一次运行执行 `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。  
之后只需要执行 `./run.sh`。  
对于没有词法/语法错误的输入，会检查输出是否严格相同。  
对于有词法/语法错误的输入，只会检查是否报错了。

# 添加测试文件
在 `tests` 目录下添加 `yourtest.cmm` 和 `yourtest.out` 两个文件。  
建议**每个文件只包含最多一个语法/词法错误**，因为测试脚本只会检查你的程序有没有报错。

# 配置自动化测试
通过启用自动化测试，你可以每次有新测试数据的时候在 github 上自动地执行测试脚本。

前往仓库设置如下 secrets：

1. `LAB_REPO` 编译器实验代码仓库目录，如 username/reponame

2. `GITHUB_PAT` GitHub Prosonal Access Token with repo access

若不想启用功能，进入 “设置->Action” 内禁用之。

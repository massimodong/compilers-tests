# compilers-tests

We are now on Lab2. Switch to branch `L1` or `L1-hard` for Lab1.

编译原理 Lab2 一键测试脚本。

使用方法：  
第一次运行执行 `./run.sh path_to_parser_binary` 。`path_to_parser_binary` 为编译好的 parser 文件。  
之后只需要执行 `./run.sh`。  

# 添加测试文件
请添加 `test.cmm` 和 `test.json` 两个文件。其中

* `test.cmm` 是输入文件
* `test.json` 是答案描述文件，格式为
```
{
  "require": {
    "e1": [[e1_1, l1_1], [e1_2, l1_2], ...],
    "e2": [[e2_1, l2_1], [e2_2, l2_2], ...],
    ...
    "ek": [[ek_1, lk_1], [ek_2, lk_2], ...]
  },
  "allow": [[ea_1, la_1], [ea_2, la_2], ...]
}
```
`require`为必须报告的错误，有k个错误，对于第i个错误，你需要输出至少一行`Error type ei_j at Line li_j: [说明文字].`

`allow`为允许你报的其他连带错误。

示例：
```
{
  "require": {
    "a": [[1, 4], [1, 5]],
    "b": [[2, 10]]
  },
  "allow": [[5,4], [6, 4]]
}
```
你可以输出
```
Error type 1 at Line 5: [说明文字].
Error type 2 at Line 10: [说明文字].
Error type 5 at Line 4: [说明文字].
```
或者
```
Error type 1 at Line 4: [说明文字].
Error type 2 at Line 10: [说明文字].
```

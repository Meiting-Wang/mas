cls
cd "X:\exercise\Stata\mas\"
cap pr drop _all
cap mkdir mydir1
cap mkdir mydir2

// set trace on
*----------------单个文件测试---------------
mas using read.tex, saving(write.tex) m(This) s(XX) replace //将 "read.tex" 中的 "This" 替换为 "XX"，并写入 "write.tex" 中
mas using "read.tex", saving("write.tex") m("This") s("XX") replace //同上
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") replace //将 "read.tex" 中的 "This" "this" "\phi" 分别替换为 "XX" "YY" "b[1]"，并写入 "write.tex" 中
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) replace //含义同上，但只是选择了原文件的 7-13 行进行操作
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es) replace //含义同上，但删除了多余的空格
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es bl) replace //含义同上，但删除了多余的空行
mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re replace //含义同上，但采用的是正则表达式匹配模式
mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re b replace //含义同上，但只在 Stata 界面上报告了读入和写入文件的简单的信息
mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re qui replace //含义同上，但没有在 Stata 界面上报告结果
! del "write.tex" //删除生成的文件


*-----------------多个文件测试----------------
mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace //对当前目录下符合 "read*.tex" 的文件做查找替换操作。保存文件的命令格式为 "pre_原文件名.原后缀名"
mas using "read*.tex", saving(,post("_post")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名_post.原后缀名"
mas using "read*.tex", saving(,post(".txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名.txt"
mas using "read*.tex", saving(,post("_post.txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名_post.txt"
mas using "read*.tex", saving(,pre(pre_) post("_post")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "pre_原文件名_post.原后缀名"
mas using "read*.tex", saving(,pre(pre_) post("_post.txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "pre_原文件名_post.txt"
! del "pre_*" "*.txt" "*_post.*" //删除生成的文件


*--------------带路径文件的测试-----------
mas using ".\read.tex", saving("write.tex") m("This") s("XX") replace
mas using ".\read.tex", saving(".\mydir1\write.tex") m("This") s("XX") replace
mas using ".\read.tex", saving("..\write.tex") m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre("..\")) m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre("..\pre_")) m("This") s("XX") replace
mas using ".\mydir1\read*.tex", saving(,pre(".\mydir2\")) m("sentence") s("YY") replace
mas using "X:\exercise\Stata\mas\read*.tex", saving(,pre("X:\exercise\Stata\mas\mydir2\")) m("sentence") s("YYY") replace
! del "write.tex" ".\mydir1\write.tex" "..\write.tex" //删除生成的文件
! del ".\mydir1\read*.tex" "..\read*.tex" "..\pre_read*.tex" ".\mydir2\read*.tex" //删除生成的文件
! del "X:\exercise\Stata\mas\mydir2\read*.tex" //删除生成的文件


*---------------replace 和 append 测试(含有 match 和 substitute)-----------
* 单个文件的 replace 和 append
mas using "read.tex", saving("write.tex") m("This") s("XX") replace
mas using "read.tex", saving("write.tex") m("sentence") s("YY") l(6/9) append
! del "write.tex" //删除生成的文件

* 多个文件的 replace 和 append
mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace
mas using "read*.tex", saving(,pre("pre_")) m("sentence") s("YY") l(2/7) append
! del "pre_read*.tex" //删除生成的文件


*-----------------只复制或附加文件(不含有 match 和 substitute)--------------
mas using "read.tex", saving("write.tex") replace //复制文件
mas using "read.tex", saving("write.tex") l(7/11) replace //选择特定的行进行复制
mas using "read.tex", saving("write.tex") l(12/17) append //选择特定的行进行附加
! del "write.tex"


*-----------------只删除空行或多余的空格(不含有 match 和 substitute)--------------
mas using "read.tex", saving("write.tex") d(es) replace //删除多余的空格
mas using "read.tex", saving("write.tex") d(bl) replace //删除空行
mas using "read.tex", saving("write.tex") d(es bl) replace //删除空行和多余的空格
mas using "read.tex", saving("write.tex") d(es bl) l(5/9) replace //删除空行和多余的空格
! del "write.tex"


*------------获得返回值--------------
mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace
return list //获得返回值
! del ".\mydir1\read*.tex" //删除生成的文件


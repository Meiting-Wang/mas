# Stata 新命令：mas——文本文件内容的匹配与替换

> 作者：王美庭  
> Email: wangmeiting92@gmail.com

## 一、引言

我们的 .txt、.do、.tex、.m、.sh、.bat、.gitignore、.gitconfig 等都是文本文件。有时候我们需要对其中的内容进行查找替换（常用快捷键为 ctrl + h）,而我们又希望将其自动化，即只需要一些命令语句，即可实现对特定文件的特定内容实现替换。基于此目的，我们便书写了 `mas`（match and substitute）命令，该命令具有以下特点：

- 操作流程为：读入特定文件的特定内容，对这些内容进行匹配替换后，再将其写入新的文件中。
- 支持同时对一个或多个文件进行匹配替换。
- 支持同时对文件内容的一个或多个条目进行匹配替换
- 支持选择特定的行进行匹配替换
- 支持删除多余的空格（删除每一行首尾的空格以及将每一行句中的连续空格替换为单个空格）
- 支持删除空行（一行中若只有空格或 tab 也会被归为空行）
- 支持使用正则表达式
- 写入文件时支持`replace`和`append`选项
- 使用命令后会在 Stata 界面上呈现以下内容：（1）匹配条目和替换条目的对应关系；（2）关于读入和写入文件的简约信息（含读入文件的文件名、写入文件的文件名、对应文件内容发生更改的总行数）；（3）关于读入和写入文件的详细信息（对每一组读入文件和写入文件都报告了以下信息：文件名的对应关系；匹配到的内容于读入文件中所在的具体行数；前者于写入文件中所在的具体行数）
- 使用命令后运行`return list`可以得到以下返回值：（1）读入文件所在的路径；（2）写入文件所在的路径；（3）读入文件的文件名；（4）写入文件的文件名；（5）带路径的读入文件的文件名；（6）带路径的写入文件的文件名。

总之，该命令旨在将重复繁琐的 ctrl+h 变成程式化命令语句。个人花很多心血写这个命令的原因之一是要将 .tex 中的方程组变成 mata 中可以识别的方程组，从而大量缩小了重复劳动时间、缓解了强迫症和减少了在对方程进行变更时的出错率（尤其在当方程组很多时）。

## 二、命令的安装

`mas`及本人其他命令的代码都托管于 GitHub 上，读者可随时下载安装这些命令。

你可以通过系统自带的`net`命令进行安装：

```stata
net install mas, from("https://raw.githubusercontent.com/Meiting-Wang/mas/main")
```

也可以通过`github`外部命令进行安装（`github`命令本身可以通过`net install github, from("https://haghish.github.io/github/")`进行安装）：

```stata
github install Meiting-Wang/mas
```

## 三、语法与选项

### （一）命令语法

```stata
mas using filenames, saving(filenames) match(string) substitute(string) [lines(numlist) delete(string) regex quietly replace append]
```

> - `using`中的`filenames`: 输入要读入的文件名的格式，如`read.tex`、`read*.tex`、`..\read.tex`、`.\mydir1\read*.tex`、`X:\exercise\Stata\fas\read*.tex`等。如果文件名或路径有空格，则需加上双引号。
> - `saving(filenames)`：输入要写入的文件名的格式。其还包含`pre(string)`和`post(string)`两个子选项，用于当写入的文件为多个时直接在原文件（读入文件）名称的基础加上前缀（prefix）或后缀（postfix）进行命名。这里值得注意的是，为保证命名的唯一性，当操作的文件有多个时，必须采用子选项的形式。该选项的合法写法可以有`saving(write.tex)`、`saving(..\write.tex)`、`saving(c:\windows\write.tex)`、`saving(,pre(pre_))`、`saving(,pre(.\mydir\))`、`saving(,post(_post))`、`saving(,post(.txt))`、`saving(,post(_post.txt))`、`saving(,pre(pre_) post(_post))`、`saving(,pre(pre_) post(_post.txt))`

### （二）选项

- `match(string)`: 可以设置一个或多个匹配条目。若有多个匹配条目，则每个条目必须加上双引号。
- `substitute(string)`: 可以设置一个或多个要替换匹配条目的内容（这里条目的数量必须与匹配条目的数量相等）。若有多个条目，则每个条目必须加上双引号。
- `lines(numlist)`：选择文本文件中特定行数的内容进行如上操作。
- `delete(string)`：可以删除空行（当输入`blank_lines`或`bl`时）或多余的空格（当输入`extra_space`或`es`时）。
- `regex`：可以采用正则表达式进行匹配替换。如果采用该模式，则`match(string)`和`substitute(string)`选项的输入必须要符合正则表达式的规范。
- `quietly`：可以选择不在 Stata 界面上报告命令运行的结果。
- `replace`：如果`saving(filenames)`中的文件名已存在，则替换之。
- `append`：如果`saving(filenames)`中的文件名已存在，则附加之。

> 该命令的部分选项可以缩写，详情可以在安装完命令之后`help mas`。

## 四、实例

```stata
*-----------------单个文件的示例-----------------
mas using read.tex, saving(write.tex) m(This) s(XX) replace //将 "read.tex" 中的 "This" 替换为 "XX"，并写入 "write.tex" 中
mas using "read.tex", saving("write.tex") m("This") s("XX") replace //同上
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") replace //将 "read.tex" 中的 "This" "this" "\phi" 分别替换为 "XX" "YY" "b[1]"，并写入 "write.tex" 中
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) replace //含义同上，但只是选择了原文件的 7-13 行进行操作
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es) replace //含义同上，但删除了多余的空格
mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es bl) replace //含义同上，但删除了多余的空行
mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re replace //含义同上，但采用的是正则表达式匹配模式
mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re qui replace //含义同上，但没有在 Stata 界面上报告结果


*---------------------多个文件的示例------------------------
mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace //对当前目录下符合 "read*.tex" 的文件做查找替换操作。保存文件的命令格式为 "pre_原文件名.原后缀名"
mas using "read*.tex", saving(,post("_post")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名_post.原后缀名"
mas using "read*.tex", saving(,post(".txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名.txt"
mas using "read*.tex", saving(,post("_post.txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "原文件名_post.txt"
mas using "read*.tex", saving(,pre(pre_) post("_post")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "pre_原文件名_post.原后缀名"
mas using "read*.tex", saving(,pre(pre_) post("_post.txt")) m("This") s("XX") replace //含义同上，但保存文件的命令格式为 "pre_原文件名_post.txt"


*------------------------带路径文件的示例-------------
mas using ".\read.tex", saving("write.tex") m("This") s("XX") replace
mas using ".\read.tex", saving(".\mydir1\write.tex") m("This") s("XX") replace
mas using ".\read.tex", saving("..\write.tex") m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre("..\")) m("This") s("XX") replace
mas using ".\read*.tex", saving(,pre("..\pre_")) m("This") s("XX") replace
mas using ".\mydir1\read*.tex", saving(,pre(".\mydir2\")) m("sentence") s("YY") replace
mas using "X:\exercise\Stata\mas\read*.tex", saving(,pre("X:\exercise\Stata\mas\mydir2\")) m("sentence") s("YYY") replace


*--------------------replace 和 append 示例-----------------
* 单个文件的 replace 和 append
mas using "read.tex", saving("write.tex") m("This") s("XX") replace
mas using "read.tex", saving("write.tex") m("sentence") s("YY") l(6/9) append

* 多个文件的 replace 和 append
mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace
mas using "read*.tex", saving(,pre("pre_")) m("sentence") s("YY") l(2/7) append


*----------------------获得返回值-------------------------------
mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace
return list
```

## 五、输出展示

```stata
mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace
```

```stata
---------------------------------------------------------------------------------------------------
Match and substitute information(normal mode)
---------------------------------------------------------------------------------------------------
group1: "This"    →    "XX"
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
Brief information for the read and written files
---------------------------------------------------------------------------------------------------
The files that have been read:
  ".\read.tex" ".\read2.tex" ".\read3.tex"

The files that have been written:
  ".\mydir1\read.tex" ".\mydir1\read2.tex" ".\mydir1\read3.tex"

The total number of lines whose content has changed (based on match and substitute, not delete):
  3 1 2
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
Detailed information for the read and written files
---------------------------------------------------------------------------------------------------
From read file to written file: ".\read.tex" → ".\mydir1\read.tex"
Specific matched line numbers in read file: 3, 7, 9
Specific substituted line numbers in written file: 3, 7, 9

From read file to written file: ".\read2.tex" → ".\mydir1\read2.tex"
Specific matched line numbers in read file: 3
Specific substituted line numbers in written file: 3

From read file to written file: ".\read3.tex" → ".\mydir1\read3.tex"
Specific matched line numbers in read file: 1, 3
Specific substituted line numbers in written file: 1, 3
---------------------------------------------------------------------------------------------------
```

```stata
return list
```

```stata
macros:
          r(using_dir) : ".\"
         r(saving_dir) : ".\mydir1\"
        r(using_files) : ""read.tex" "read2.tex" "read3.tex""
       r(saving_files) : ""read.tex" "read2.tex" "read3.tex""
    r(raw_using_files) : "".\read.tex" ".\read2.tex" ".\read3.tex""
   r(raw_saving_files) : "".\mydir1\read.tex" ".\mydir1\read2.tex" ".\mydir1\read3.tex""
```

> 点击【阅读原文】可进入该命令的 github 项目。
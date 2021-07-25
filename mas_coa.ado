* Description: This is a sub-program for mas.ado, aiming at copying or appending text files from one place to another.
* Author: Meiting Wang, doctor, Institute for Economic and Social Research, Jinan University
* Email: wangmeiting92@gmail.com
* Created on July 18, 2021
* Updated on July 25, 2021


program define mas_coa
version 16.0

syntax using/, saving(string) [replace append Lines(numlist integer >0 ascending)]


*-----------------前期程序---------------------
* 错误信息处理
if ("`replace'" != "") & ("`append'" != "") {
	dis `"{error:Option {bf:`replace'} and {bf:`append'} cannot exist at the same time}"'
	error 9999
} //不能同时输入 replace 和 append 选项


* 如果 lines 非空，提取其所选取的最大行号
if ustrregexm("`lines'","(\d+)$") {
	local max_num_of_select_lines = ustrregexs(1)
}


* 初始值
local linenum_read = 0 //读取文件时所进行到的行数
local linenum_write = 0 //写入文件时所进行到的行数



*---------------------------主程序-----------------------------
*file 命令的前端
tempname handle1 handle2
qui file open `handle1' using `"`using'"', read text
qui file open `handle2' using `"`saving'"', write text `replace' `append'

if "`append'" != "" {
	file write `handle2' _n
} //append 选项如果存在，则在写入文件之前新起一行


*文章的读取与写入
file read `handle1' line
while r(eof) == 0 {
	if "`lines'" == "" { //I.没有选定具体行号进行复制或附加的情况
		local linenum_read = `linenum_read' + 1
		local linenum_write = `linenum_write' + 1
		file write `handle2' `"`line'"'
		file read `handle1' line
		if r(eof) == 0 {
			file write `handle2' _n
		} //如果下一行不是文本末端，才对上一行加上 newline
	}
	else { //II.有选定具体行号进行复制或附加的情况
		local linenum_read = `linenum_read' + 1
		if ustrregexm("`lines'","\b`linenum_read'\b") { //如果linenum_read与lines匹配上了，则执行复制或附加，并写入saving文件中
			local linenum_write = `linenum_write' + 1
			file write `handle2' `"`line'"' `=cond(`linenum_read'==`max_num_of_select_lines',"","_n")'
		}
		file read `handle1' line
	}
}

if "`lines'" != "" {
	if `max_num_of_select_lines' > `linenum_read' {
		dis as error `"The selected maximum number of lines exceeds the maximum line of file {bf:"`saving'"}."'
		error 9999
	}
} //如果所选行数的最大值超过了文件本身的最大行数，则报错

*file 命令的末端
file close `handle1'
file close `handle2'

end

* Description: A main program in mas.ado, is to perform query and replace operations on text files
* Author: Meiting Wang, doctor, Institute for Economic and Social Research, Jinan University
* Email: wangmeiting92@gmail.com
* Created on July 15, 2021



program define mas_main, rclass
version 16.0

syntax using/, saving(string) ///
	Match(string asis) Substitute(string asis) ///
	[replace append Lines(numlist integer >0 ascending) ///
	Delete(string) REgex]

/*
*******引言
该命令可以被单独拿来使用，用于实现单个文本文件的查找替换

*******命令使用注意事项
- 不可替换双引号或生成双引号
- string 选项中，如果双引号不配对，则会默认报错
- match 和 substitute 的 string 在不使用双引号时仅为一组。如需多组替换，为避免混淆，每组必须使用双引号。即允许类似 hello world、"hello world"、"hello world" "abc" "def"的出现，但不允许类似 "hello world" abc def 字符串的出现。
- match 的组别数与 substitute 的组别数必须一致，即有多少个查找就必须有多少个替换。
- 为使得 查找替换有意义，match 不允许出现空字符的情况。而 substitute 允许空字符的存在，用于对特定字符串的删除。
- 本程序编程过程中提取出了 match1-match... 和 substitute1-substitute...
- 删除空行时，如果某一行中仅有空格或tab，也会被视作为空行。
- 删除空行时只有原先是空行的会被删除，替换之后成为空行的会被保留
- 这个命令一次性仅仅只能读取单个文件和写入单个文件
- using 支持包含路径的文件名。路径或文件名包含空格时必须要使用双引号，否则默认下syntax using本身就会报错
- saving 支持包含路径的文件名。路径或文件名包含空格时可以不使用双引号，但为了与Stata中使用字符串的习俗一致，还是建议使用双引用将包含空格的路径文件名囊括。
*/



*--------------------------前期程序------------------------------
* 错误信息处理
preserve
clear
qui set obs 1
gen v = fileread(`"`using'"') //fileread函数里面的文件名可以包含路径，但无论其中是否包含空格都必须使用双引号
if ustrregexm(`"`=v[1]'"',"^\s*$") {
	dis as error "The read file is empty"
	restore
	error 9999
}
restore //这里可以保证所读取的文件存在且含有可见字符

if ~ustrregexm(`"`match'"',`"^\s*((("[^"]+?")(\s+("[^"]+?"))*)|([^"]+))\s*$"') {
	dis as error "match option syntax error"
	error 9999
} //设定输入时 match 需符合特定的格式

if ~ustrregexm(`"`substitute'"',`"^\s*((("[^"]*?")(\s+("[^"]*?"))*)|([^"]*))\s*$"') {
	dis as error "substitute option syntax error"
	error 9999
} //设定输入时 substitute 需符合特定的格式

if "`delete'" != "" {
	if ~ustrregexm("`delete'","^\s*(((blank_lines|bl)(\s+(extra_spaces|es))?)|((extra_spaces|es)(\s+(blank_lines|bl))?))\s*$") {
		dis as error "delete option syntax error"
		error 9999
	} //设定输入时 delete 需符合特定的格式
}

if ("`replace'" != "") & ("`append'" != "") {
	dis `"{error:Option {bf:`replace'} and {bf:`append'} cannot exist at the same time}"'
	error 9999
} //不能同时输入 replace 和 append 选项



* match 和 substitute 语句处理
if ~ustrregexm(`"`match'"',`"""') {
	local match `""`match'""'
} //如果 match 没有双引号，则为其加上双引号(为单组)

if ~ustrregexm(`"`substitute'"',`"""') {
	local substitute `""`substitute'""'
} //如果 substitute 没有双引号，则为其加上双引号(为单组)

local groups_of_match = ustrlen(ustrregexra(`"`match'"',`"[^"]"',"")) / 2
local groups_of_substitute = ustrlen(ustrregexra(`"`substitute'"',`"[^"]"',"")) / 2

if `groups_of_match' != `groups_of_substitute' {
	dis as error "Groups of match and groups of substitute are not equal"
	error 9999
}

local i = 1
foreach s of local match {
	local match`i' "`s'"
	local i = `i' + 1
} //提取 match1-match...

local i = 1
foreach s of local substitute {
	local substitute`i' "`s'"
	local i = `i' + 1
} //提取 substitute1-substitute...


* 如果 lines 非空，提取其所选取的最大行号
if "`lines'" != "" {
	qui dis ustrregexm("`lines'","(\d+)$")
	local max_num_of_select_lines = ustrregexs(1)
}


* 初始值
local linenum_read = 0 //读取文件时所进行到的行数
local linenum_write = 0 //写入文件时所进行到的行数
local lines_changed_for_original "" //后面用于返回内容发生变化的具体行数(应对于原文件)
local lines_changed_for_generated "" //后面用于返回内容发生变化的具体行数(应对于生成文件)
local lines_total_change_num = 0 //后面用于返回被更改内容的总行数




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
	local linenum_read = `linenum_read' + 1

	if "`lines'" == "" { //没有选定具体行号进行替换的情况

		if ustrregexm("`delete'","\b(bl|blank_lines)\b") {
			if ustrregexm(`"`line'"',"^\s*$") {
				file read `handle1' line
				continue
			} //在 bl 设定下，如果对应行仅含不可见字符，则后面不写入
		}

		local change_status = 0
		local linenum_write = `linenum_write' + 1

		forvalues i = 1/`groups_of_match' {
			if "`regex'" != "" {
				local change_status = `change_status' + ustrregexm(`"`line'"',"`match`i''")
				local line = ustrregexra(`"`line'"',"`match`i''","`substitute`i''")
			}
			else {
				local change_status = `change_status' + ustrpos(`"`line'"',"`match`i''")
				local line = usubinstr(`"`line'"',"`match`i''","`substitute`i''",.)
			}
		}

		if `change_status' > 0 {
			local lines_changed_for_original "`lines_changed_for_original'`linenum_read', "
			local lines_changed_for_generated "`lines_changed_for_generated'`linenum_write', "
			local lines_total_change_num = `lines_total_change_num' + 1
		}

		if ustrregexm("`delete'","\b(es|extra_spaces)\b") {
			local line = strtrim(ustrregexra(`"`line'"',"\s+"," "))
		} //在 es 设定下，如果对应行有多余空白，则删除之
		file write `handle2' `"`line'"'

		file read `handle1' line
		if r(eof) == 0 {
			file write `handle2' _n
		} //如果下一行不是文本末端，才对上一行加上 newline

	}
	else { //选择了具体行号进行替换的情况
		if ustrregexm("`delete'","\b(bl|blank_lines)\b") {
			if ustrregexm(`"`line'"',"^\s*$") {
				file read `handle1' line
				continue
			} //在 bl 设定下，如果对应行仅含不可见字符，则后面不写入
		}

		if ustrregexm("`lines'","\b`linenum_read'\b") {
			local change_status = 0
			local linenum_write = `linenum_write' + 1

			forvalues i = 1/`groups_of_match' {
				if "`regex'" != "" {
					local change_status = `change_status' + ustrregexm(`"`line'"',"`match`i''")
					local line = ustrregexra(`"`line'"',"`match`i''","`substitute`i''")
				}
				else {
					local change_status = `change_status' + ustrpos(`"`line'"',"`match`i''")
					local line = usubinstr(`"`line'"',"`match`i''","`substitute`i''",.)
				}
			}

			if `change_status' > 0 {
				local lines_changed_for_original "`lines_changed_for_original'`linenum_read', "
				local lines_changed_for_generated "`lines_changed_for_generated'`linenum_write', "
				local lines_total_change_num = `lines_total_change_num' + 1
			}
			
			if ustrregexm("`delete'","\b(es|extra_spaces)\b") {
				local line = strtrim(ustrregexra(`"`line'"',"\s+"," "))
			} //在 es 设定下，如果对应行有多余空白，则删除之
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

local lines_changed_for_original = ustrregexra("`lines_changed_for_original'",", $","")
local lines_changed_for_generated = ustrregexra("`lines_changed_for_generated'",", $","")

*file 命令的末端
file close `handle1'
file close `handle2'



*---------------------------返回值----------------------------
return local lines_total_change_num = `lines_total_change_num' //返回被更改内容的总行数
return local lines_changed_for_generated "`lines_changed_for_generated'" //返回内容发生变化的具体行数(应对于生成文件)
return local lines_changed_for_original "`lines_changed_for_original'" //返回内容发生变化的具体行数(应对于原文件)
end

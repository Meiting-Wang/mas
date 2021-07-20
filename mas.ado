* Description: Perform matching and substituting operations on text files and it has a sub-program which name is mas_main.ado
* Author: Meiting Wang, doctor, Institute for Economic and Social Research, Jinan University
* Email: wangmeiting92@gmail.com
* Created on July 15, 2021



program define mas, rclass
version 16.0

syntax using/, saving(string asis) ///
	Match(passthru) Substitute(passthru) ///
	[replace append Lines(passthru) ///
	Delete(passthru) REgex QUIetly]
/*
*****编程注意事项
- 子程序 mas_main.ado 有对 match、substitute、lines、delete、replace、append 选项语法的判断，所以主程序无需对它们的语法进行正误判断
- `raw_dirname' `pre_str_pdot' `pre_str_pndot' 的设定都是为了解决 Stata 字符串中 \ 有时会消失的bug
*/


*--------------------前期程序----------------------
* using 语句的预处理
if ~ustrregexm("`using'","(/)|(\\)") {
	local dirname "."
	local pattern "`using'"
}
else if ustrregexm("`using'","^([^/\\].*[/\\])([^/\\]+)$") {
	local dirname = ustrregexs(1) //最后带有/或\
	local pattern = ustrregexs(2)
	local raw_dirname = ustrregexra("`dirname'","(\\)$","\\\\") //便于后面生成 using1-using...(解决bug)
}
else {
	dis "{error:fn syntax error}"
	error 9999
}


local using_str: dir "`dirname'" files "`pattern'", respectcase //所得 using_str 中的每个文件名都带有双引号
if `"`using_str'"' == "" {
	dis `"{error:files "`using'" not found}"'
	error 9999
} //以保证确实有文件能被处理

local i = 0
local raw_using_str ""
foreach s of local using_str {
	local i = `i' + 1
	local using`i' "`s'"
	local raw_using`i' "`raw_dirname'`s'"
	local raw_using_str `"`raw_using_str'"`raw_using`i''" "'
} //生成raw_using1-raw_using...(不含有双引号)
local raw_using_str = strtrim(`"`raw_using_str'"')
local using_num = `i' //记录要被进行查找替换的文件数


* saving 语句的预处理
local saving_re_str1 `"\s*"?[^\,\(\)]+"?\s*"' //支持 |xx.tex| |"xx yy.tex"| |.\mydir\write.tex| 
local saving_re_str2 `"\s*pre\(([^\(\)]+)\)\s*"' //支持 |pre(xx)| |pre("xx")| |pre(xx yy)| |pre("xx yy")| |".\mydir\write.tex"|
local saving_re_str3 `"\s*post\(([^\(\)]+)\)\s*"' //除了支持类似于 saving_re_str2 的模式，还额外支持 |post(.do)| |post(".do")| |post(xx.do)| |post("xx.do")| |post(xx yy.do)| |post("xx yy.do")|


if ~ustrregexm(`"`saving'"',`"^(`saving_re_str1')|(\s*,((`saving_re_str2')|(`saving_re_str3')){1,2})$"') {
	dis "{error:saving option syntax error}"
	error 9999
} //保证输出的saving符合特定的语法。支持比如 |xx.tex| |,pre(pre)| |,post(post)| |,post(.tex)| |,pre(pre) post(post)| |,pre(pre) post(.tex)| |,pre(pre) post(post.tex)| 等

if (`using_num' > 1) & (~ustrregexm(`"`saving'"',"\,")) {
	dis "{error:The number of files processed is greater than 1, so pre or post mode should be used in {bf:saving} option}"
	error 9999
} //以保证当处理文件数大于 1 时，saving 应当采用 pre 或 post 模式

if ~ustrregexm(`"`saving'"',"\,") { //此时`using_num'必定为 1，所以saving只有一个
	local raw_saving1 `saving'
	if ustrregexm("`raw_saving1'","^(.+(/|\\))([^/\\]+)$") {
		local saving_dir = ustrregexs(1)
	}
}
else {
	if ustrregexm(`"`saving'"',"pre\((.+?)\)") {
		local pre_str = ustrregexra(`"`=ustrregexs(1)'"',`"(^\s*")|("\s*$)"',"") //去除pre可能包含的双引号
		if ustrregexm("`pre_str'","(.+(/|\\))([^/\\]*)") {
			local saving_dir = ustrregexs(1)
		}
		local pre_str_pdot = ustrregexra("`pre_str'","(\\)$","\\\\") //便于后面生成 saving1-saving...(解决bug1)
		local pre_str_pndot = ustrregexra("`pre_str'","(\\)","\\\\") //便于后面生成 saving1-saving...(解决bug2)
		local pre_str_pndot = ustrregexra("`pre_str_pndot'","(\\)$","\\\\") //便于后面生成 saving1-saving...(解决bug2)
	}
	if ustrregexm(`"`saving'"',"post\((.+?)\)") {
		local post_str = ustrregexra(`"`=ustrregexs(1)'"',`"(^\s*")|("\s*$)"',"") //去除post可能包含的双引号
	}

	forvalues i = 1/`using_num' {
		if ustrregexm(`"`post_str'"',"\.") {
			local raw_saving`i' `"`pre_str_pdot'`=ustrregexra(`"`using`i''"',`"\.[a-z]+?$"',`""')'`post_str'"'
		}
		else {
			local raw_saving`i' = ustrregexra(`"`using`i''"',`"^([^\.]+)(\.[^\.]+)$"',`"`pre_str_pndot'$1`post_str'$2"')
		}
	}
} //生成raw_saving1-raw_saving...(不含有双引号)

local saving_str "" //用于输出全部的 saving
local raw_saving_str "" //用于输出全部的 raw_saving
forvalues i = 1/`using_num' {
	local saving`i' = ustrregexra("`raw_saving`i''","^.+(/|\\)","")
	local saving_str `"`saving_str'"`saving`i''" "'
	local raw_saving_str `"`raw_saving_str'"`raw_saving`i''" "'
} //生成saving1-saving...
local saving_str = strtrim(`"`saving_str'"')
local raw_saving_str = strtrim(`"`raw_saving_str'"')

if ustrregexm(`"`saving_str'"',`"("\w.*\w").+?\1"') {
	dis `"{error:The generated file name like {bf:`=ustrregexs(1)'} is duplicated. Please reset the {bf:pre()} or {bf:post()}.}"'
	error 9999
}


*--------------------主程序----------------------
* 文件内容的查找与替换
local lines_total_change_num_str "" //用于在整体上记录各个文件内容发生变化的行数
forvalues i = 1/`using_num' {
	mas_main using "`raw_using`i''", saving("`raw_saving`i''") `match' `substitute' `replace' `append' `lines' `delete' `regex'
	local lines_changed_for_original`i' "`r(lines_changed_for_original)'" //返回第`i'个文件内容发生变化的具体行数(应对于原文件)
	local lines_changed_for_generated`i' "`r(lines_changed_for_generated)'" //返回第`i'个文件内容发生变化的具体行数(应对于生成文件)
	local lines_total_change_num`i' = `r(lines_total_change_num)' //返回第`i'个文件被更改内容的总行数
	local lines_total_change_num_str "`lines_total_change_num_str'`lines_total_change_num`i'' "
}
local lines_total_change_num_str = strtrim("`lines_total_change_num_str'")


*---------------------返回值---------------------
return local raw_saving_files `"`raw_saving_str'"'
return local raw_using_files `"`raw_using_str'"'
return local saving_files `"`saving_str'"'
return local using_files `"`using_str'"'
return local saving_dir "`saving_dir'"
return local using_dir "`dirname'"


*-----------------------结果的输出--------------------
if "`quietly'" != "" {
	exit
} //如果含有 quietly 选项，则不输出以下结果


*查找与替换组别输出
local match = ustrregexra(`"`match'"',"(^match\(\s*)|(\s*\)$)","")
local substitute = ustrregexra(`"`substitute'"',"(^substitute\(\s*)|(\s*\)$)","")
if ~ustrregexm(`"`match'"',`"""') {
	local match `""`match'""'
}
if ~ustrregexm(`"`substitute'"',`"""') {
	local substitute `""`substitute'""'
}
local groups_of_match = ustrlen(ustrregexra(`"`match'"',`"[^"]"',"")) / 2

local i = 1
local match_len_str ""
foreach s of local match {
	local match`i' "`s'"
	local match_len_str `"`match_len_str'`=ustrlen("`match`i''")', "'
	local i = `i' + 1
} //提取 match1-match...
local match_len_str = ustrregexra(`"`match_len_str'"',"\, $","")

if `groups_of_match' == 1 {
	local matchi_len_max = ustrlen("`match1'")
}
else {
	local matchi_len_max = max(`match_len_str')
} //计算match`i'最大length

local col1 = 10+`matchi_len_max'+5
local col2 = `col1' + 5

local i = 1
foreach s of local substitute {
	local substitute`i' "`s'"
	local i = `i' + 1
} //提取 substitute1-substitute...

dis as text _n "{hline}"
dis as text `"{bf:Match and substitute information(`=cond(`=strmatch("`regex'","regex")',"regex mode","normal mode")')}"'
dis as text "{hline}"
forvalues i = 1/`groups_of_match' {
	dis as text `"group`i': {result:"`match`i''"}{col `col1'}→{col `col2'}{result:"`substitute`i''"}"'
}
dis as text "{hline}" _n


*文件读写简略信息输出
#delimit ; 
dis as text _n
	"{hline}" _n
	"{bf:Brief information for the read and written files}" _n
	"{hline}" _n

	"The files that have been read:" _n 
	_col(3) `"{result:`raw_using_str'}"' _n(2)

	"The files that have been written:" _n 
	_col(3) `"{result:`raw_saving_str'}"' _n(2)

	"The total number of lines whose content has changed (based on match and substitute, not delete):" _n
	_col(3) "{result:`lines_total_change_num_str'}" _n
	"{hline}" _n(2)
;
#delimit cr


*文件读写详细信息输出
dis as text "{hline}"
dis as text "{bf:Detailed information for the read and written files}"
dis as text "{hline}"
forvalues i = 1/`using_num' {
	dis as text `"From read file to written file: {result:"`raw_using`i''"} → {result:"`raw_saving`i''"}"'
	dis as text "Specific matched line numbers in read file: {result:`lines_changed_for_original`i''}"
	dis as text "Specific substituted line numbers in written file: {result:`lines_changed_for_generated`i''}" `=cond(`i'!=`using_num',"_n","")'
}
dis as text "{hline}"

end

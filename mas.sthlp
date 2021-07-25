{smcl}
{right:Created time: July 18, 2021}
{right:Updated time: July 25, 2021}
{* -----------------------------title------------------------------------ *}{...}
{p 0 14 2}
{bf:[W-14] mas} {hline 2} Perform matching and substituting operations on text files. You can view source code in {browse "https://github.com/Meiting-Wang/mas":github}.


{* -----------------------------Syntax------------------------------------ *}{...}
{title:Syntax}

{p 8 10 2}
{cmd:mas} {bf:using} {it:{help filenames}}, {opth saving:(filenames)} [ ///{break}
{opth m:atch(strings:string)} {opth s:ubstitute(strings:string)} {opth l:ines(numlist)} {opth d:elete(string)} ///{break}
{opt k:eepall} {opt re:gex} {opt qui:etly} {opt b:rief} {opt replace} {opt append} ]


{* -----------------------------Contents------------------------------------ *}{...}
{title:Contents}

{p 4 4 2}
{help mas##Description:Description}{break}
{help mas##Options:Options}{break}
{help mas##Examples:Examples}{break}
{help mas##Author:Author}


{* -----------------------------Description------------------------------------ *}{...}
{marker Description}{title:Description}

{p 4 4 2}
{cmd:mas} can read the "using filenames", and then write the read content into the "saving filenames" after matching and substituting operations. The filenames should be the name of the text files such as {bf:.txt}, {bf:.tex}, {bf:.do}, {bf:.sh}, etc. 

{p 4 6 2}
It can not only achieve one or more matching replacements, but also{break}
(1) select specific lines to execute;{break}
(2) delete extra spaces or blank lines;{break}
(3) use regex mode;{break}
(4) support wildcards and path when input filenames;{break}
(5) have a lot result in {bf:r()} for later programming use.

{p 4 4 2}
It is worth noting that "using filenames" and "saving filenames" should not be the same and this command can only be used in version 16.0 or later.


{* -----------------------------Options------------------------------------ *}{...}
{marker Options}{title:Options}

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opth saving:(filenames)}}Set the filenames to be written, which supports paths. If {bf:using} includes multiple files, sub-options {opth pre:(strings:string)} or {opth post:(strings:string)} should be used.{p_end}
{synopt :{opth m:atch(strings:string)}}Set the content to be matched. One or more items are supported. If there are more than one item, each item needs to be surrounded by double quotation marks.{p_end}
{synopt :{opth s:ubstitute(strings:string)}}Set the content to replace match items, and the number of this option items should be equal to the the number of {opt match} items. If there are more than one item, each item needs to be surrounded by double quotation marks.{p_end}
{synopt :{opth l:ines(numlist)}}Select specific lines to execute{p_end}
{synopt :{opth d:elete(strings:string)}}Can delete extra spaces(by {bf:extra_space} or {bf:es}) or extra lines(by {bf:blank_lines} or {bf:bl}).{p_end}
{synopt :{opt k:eepall}}If you select specific lines to match and substitute, this option will additionally copy the remaining lines to the new file. In other words, under this option, the selected line will be matched and substituted, and the unselected line will be copied directly.{p_end}
{synopt :{opt re:gex}}Choose to use regex mode to match and substitute. If this option is not set, the normal mode will be used by default.{p_end}
{synopt :{opt qui:etly}}Do not output the command execution result to the Stata interface.{p_end}
{synopt :{opt b:rief}}It only reports the simple information of the command execution result on Stata interface, instead of reporting the detailed information of each pair of reads and writes.{p_end}
{synopt :{opt replace}}Replace the "saving file" if the "saving file" exists.{p_end}
{synopt :{opt append}}Append the "saving file" if the "saving file" exists.{p_end}
{synoptline}


{* -----------------------------Examples------------------------------------ *}{...}
{marker Examples}{title:Examples}

{p 4 4 2}Single file operation{p_end}
{p 8 10 2}. {bf:mas using read.tex, saving(write.tex) m(This) s(XX) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "\phi") s("XX" "YY" "b[1]") l(7/13) d(es bl) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re b replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This" "this" "s[a-z]{6}e") s("XX" "YY" "b[1]") l(7/13) d(es bl) re qui replace}{p_end}

{p 4 4 2}Multiple files operations{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,post("_post")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,post(".txt")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,post("_post.txt")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,pre(pre_) post("_post")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,pre(pre_) post("_post.txt")) m("This") s("XX") replace}{p_end}

{p 4 4 2}File or files operation with path{p_end}
{p 8 10 2}. {bf:mas using ".\read.tex", saving("write.tex") m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\read.tex", saving(".\mydir1\write.tex") m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\read.tex", saving("..\write.tex") m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\read*.tex", saving(,pre("..\")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\read*.tex", saving(,pre("..\pre_")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using ".\mydir1\read*.tex", saving(,pre(".\mydir2\")) m("sentence") s("YY") replace}{p_end}
{p 8 10 2}. {bf:mas using "X:\exercise\Stata\fas\read*.tex", saving(,pre("X:\exercise\Stata\fas\mydir2\")) m("sentence") s("YYY") replace}{p_end}

{p 4 4 2}Replace and append operation after matching and substituting{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") m("sentence") s("YY") l(6/9) append}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,pre("pre_")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:mas using "read*.tex", saving(,pre("pre_")) m("sentence") s("YY") l(2/7) append}{p_end}

{p 4 4 2}Only copy files or append files, without matching and substituting{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") l(7/11) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") l(12/17) append}{p_end}

{p 4 4 2}Only delete blank lines or extra spaces, without matching and substituting{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") d(es) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") d(bl) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") d(es bl) replace}{p_end}
{p 8 10 2}. {bf:mas using "read.tex", saving("write.tex") d(es bl) l(5/9) replace}{p_end}

{p 4 4 2}Get the return value{p_end}
{p 8 10 2}. {bf:mas using ".\read*.tex", saving(,pre(".\mydir1\")) m("This") s("XX") replace}{p_end}
{p 8 10 2}. {bf:return list}{p_end}


{* -----------------------------Author------------------------------------ *}{...}
{marker Author}{title:Author}

{p 4 4 2}
Meiting Wang{break}
Institute for Economic and Social Research, Jinan University{break}
Guangzhou, China{break}
wangmeiting92@gmail.com


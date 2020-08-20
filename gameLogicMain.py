# -*- coding:utf8 -*-
# wrote by Meng Sun.
# 2019.4.2
# @dogrest All right reserved.
w=open("output.js","w")

#changeDic为替换字段，将in.txt 中的包含的 key 转换为changeDic[key]
#可以按照自己的需要增减相应的字段
changeDic={}
#语法上的替换
changeDic["   if "]="   if("
changeDic[" then"]="){"
changeDic["   end"]="   }"
changeDic["for "]="for("
changeDic[" do"]="){"
changeDic["elseif"]="}else if("
changeDic["~="]="!="
changeDic[" or "]="||"
changeDic["not "]="!"
changeDic["\tand "]="\t&&"#换行and情况
changeDic[" and "]="&&"
changeDic["{}"]="[]"

changeDic["--"]=" //"
changeDic["print"]="//Utils.ccLog"
changeDic[".."]="+"

changeDic["else\n"]="}else{\n"
changeDic["local"]="var"
changeDic["self._"]="this."
changeDic["self:"]="this."
changeDic["GameLogic:"]="this."
changeDic["GameShare."]="GameShareDef."
changeDic["Card."]="CardDef."
changeDic["GameOpcode."]="opcodes."


#处理for循环语句
#example:
#before:for(i = 1,GameShareDef.GAME_PLAYER){
#after: for(var i=1;i<GameShareDef.GAME_PLAYER;i++){
def HandleForSy(instr):
    if "for" not in instr:
        return instr
    if "1" not in instr:
        return instr
    #instr=Replace2(instr," ","")
    #提取i
    para=instr.split("=")[0].split("(")[-1]
    #提取GameShareDef.GAME_PLAYER
    limit=instr.split(",")[-1].split(")")[0]
    strBegin=instr.split("(")[0]
    strEnd=instr.split(")")[-1]
    resultStr=strBegin+"("
    resultStr=resultStr+"var "+para+"=0"+";"+para+"<"+limit+";"+para+"++"
    resultStr=resultStr+")"+strEnd
    return resultStr

#处理函数名
#before:    function GameLogic:handleFrameGameSceneOpcode(a,b,c){
#end:   this.handleFrameGameSceneOpcode:function(a,b,c){
def HandleFunctionDefine(instr):
    if "function" not in instr:
        return instr
    paraList=instr.split("(")[-1]
    functionName=instr.split(".")[-1].split("(")[0]
    headTabs=instr.split("function")
    resultStr="this."+functionName+":function("+paraList+"{"+"\n";
    return resultStr;

def Replace2(instr,replacedStr,newStr):
    if replacedStr in instr:
        instr=instr.replace(replacedStr,newStr)
    return instr

#添加分号
def AddSemicolon(instr):
    if "funtion " in instr:
        return instr
    if "{" in instr:
        return instr
    if "if(" in instr:
        return instr
    if "for(" in instr:
        return instr
    if "}" in instr:
        return instr
    if instr=="end" or instr=="end\n":
        return instr
    resultStr=instr.split("\n")[0]
    resultStr=resultStr+";\n"
    return resultStr
#

for i in open("input.lua"):
    if len(i.strip())!=0:
        for key in changeDic:
            i=Replace2(i,key,changeDic[key])
        i=HandleForSy(i)
        i=HandleFunctionDefine(i)
        i=AddSemicolon(i)
    if i=="end":
        i="}"
    if i=="end\n":
        i="},"
    
    w.write(i)

        
w.close()
    

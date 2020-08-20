# -*- coding:cp936 -*-
# wrote by Meng Sun.
# 2019.4.2
# @dogrest All right reserved.
w=open("output.lua","w")


#table.insert(_res,_cards[i]);
#_res.push(_cards[i]);
def TableInsertToPush(inStr):
    if "table.insert(" not in inStr:
        inStr=inStr
    else:
        table1=inStr.split(',')[0].split('(')[-1]
        charu=inStr.split(',')[-1].split(')')[0]
        head=inStr.split("table.insert")[0]
        resultStr=head+table1+".push("+charu+");\n"
        inStr=resultStr
    return inStr

#for(j,v in ipairs(lessThanCards)){
#for(var j=0;j<lessThanCards.length;j++)
#{
#   v=lessThanCards[i];
def IpairsToIt(inStr):
    resultStr=inStr
    if "ipairs" not in inStr:
        return resultStr
    head=inStr.split("for")[0]
    index=inStr.split("in ipairs")[0].split("(")[-1].split(",")[0]
    value=inStr.split("in ipairs")[0].split("(")[-1].split(",")[-1]
    listName=inStr.split("ipairs(")[-1].split(")")[0]
    resultStr=head+"for(var "+index+"=0;"+index+"<"
    resultStr=resultStr+listName+".length;"+index+"++)"#"{\n"
    if "{" not in inStr:
        resultStr=resultStr+"\n"
    else:
        resultStr=resultStr+"{\n"
    resultStr=resultStr+head+"\tvar "+value+"="+listName+"["+index+"];\n"
    return resultStr
    
#var tmpTra2 = clone(tractor2);;
#var tmpTra2 = tractor.concat();
def CloneToConcat(inStr):
    resultStr=inStr
    if "clone" not in inStr:
        return resultStr
    head=inStr.split("clone")[0]
    tail=inStr.split(")")[-1]
    targitList=inStr.split("(")[-1].split(")")[0]
    resultStr=head+targitList+".concat()"+tail
    return resultStr

#table.insertto(a,b)
#a=a.concat(b)
def InserttoConcat(inStr):
    resultStr=inStr
    if "insertto" not in inStr:
        return resultStr
    if len(inStr.split(","))>2:
        return resultStr
    head=inStr.split("table")[0]
    tail=inStr.split(")")[-1]
    para1=inStr.split("(")[-1].split(',')[0]
    para2=inStr.split(",")[-1].split(')')[0]
    resultStr=head+para1+"="+para1+".concat("+para2+")"+tail
    return resultStr

#table.sort(a,b);
#a.sort(this.b.bind(this));
def TableSorttosrot(inStr):
    resultStr=inStr
    if "table.sort" not in inStr:
        return resultStr
    head=inStr.split("table.sort")[0]
    tail=inStr.split(")")[-1]
    para1=inStr.split("(")[-1].split(',')[0]
    para2=inStr.split(",")[-1].split(')')[0]
    resultStr=head+para1+".sort(this."+para2+".bind(this))"+tail
    return resultStr

for i in open("input.lua"):
    #i=TableInsertToPush(i)
    #i=IpairsToIt(i)
    #i=CloneToConcat(i)
    #i=InserttoConcat(i)
    i=TableSorttosrot(i)
    w.write(i)
w.close()
    

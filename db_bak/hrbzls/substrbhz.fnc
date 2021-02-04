CREATE OR REPLACE FUNCTION HRBZLS."SUBSTRBHZ" (P_STRING IN VARCHAR2,P_START IN INTEGER,P_LENGTH IN INTEGER)
 RETURN VARCHAR2
AS
 I BINARY_INTEGER :=0;
 J BINARY_INTEGER :=0;
 LS_CH VARCHAR2(1); --临时单元
 ishzfirst   boolean:=false;
 LS_RETURNSTR varchar2(32767);
BEGIN
--USED TO : 返回给定汉字串的子串
--INPUT ARGUMENTS: P_STRING - VARCHAR2 , 给定的汉字串
--               : P_START - INTEGER , 开始位置
--               : P_LENGTH - INTEGER , 子串长度
--RETURN VALUE : - VARCHAR2 , 给定的汉字串的子串,替换首位半汉字(如果存在)为空格
--SAMPLE1 : SELECT SubstrbHZ("A中华人民共和国",1,2) FROM DUAL;
-- : RESULT WILL BE : "A "
--SAMPLE2 : SELECT SubstrbHZ("A中华人民共和国",3,2) FROM DUAL;
-- : RESULT WILL BE : "  "

LS_RETURNSTR := '';
J:=(case when P_START=0 then 1 else P_START end)+P_LENGTH-1;
LOOP
EXIT WHEN I>LENGTHB(P_STRING) or lengthB(LS_RETURNSTR)=P_LENGTH; --依次处理P_STRING中每个字符
 LS_CH:=SUBSTRB(P_STRING , I , 1);
 IF ASCII(LS_CH)<128 THEN -- 非汉字
   if I>=P_START and I<=j then
      LS_RETURNSTR := LS_RETURNSTR||LS_CH; -- 不变
   end if;
 ELSE -- 是汉字
   ishzfirst := not ishzfirst;
   if I>=P_START and I<=j  then
      if not ishzfirst and (i=P_START or i=j) then
         LS_RETURNSTR := LS_RETURNSTR||' '; -- 替换空格
      else
         LS_RETURNSTR := LS_RETURNSTR||LS_CH; -- 不变
      end if;
   end if;
 END IF;
 I:=I+1;
END LOOP; -- 处理完毕

RETURN LS_RETURNSTR;
END SubstrbHZ;
/


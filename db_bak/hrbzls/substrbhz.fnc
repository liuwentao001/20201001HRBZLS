CREATE OR REPLACE FUNCTION HRBZLS."SUBSTRBHZ" (P_STRING IN VARCHAR2,P_START IN INTEGER,P_LENGTH IN INTEGER)
 RETURN VARCHAR2
AS
 I BINARY_INTEGER :=0;
 J BINARY_INTEGER :=0;
 LS_CH VARCHAR2(1); --��ʱ��Ԫ
 ishzfirst   boolean:=false;
 LS_RETURNSTR varchar2(32767);
BEGIN
--USED TO : ���ظ������ִ����Ӵ�
--INPUT ARGUMENTS: P_STRING - VARCHAR2 , �����ĺ��ִ�
--               : P_START - INTEGER , ��ʼλ��
--               : P_LENGTH - INTEGER , �Ӵ�����
--RETURN VALUE : - VARCHAR2 , �����ĺ��ִ����Ӵ�,�滻��λ�뺺��(�������)Ϊ�ո�
--SAMPLE1 : SELECT SubstrbHZ("A�л����񹲺͹�",1,2) FROM DUAL;
-- : RESULT WILL BE : "A "
--SAMPLE2 : SELECT SubstrbHZ("A�л����񹲺͹�",3,2) FROM DUAL;
-- : RESULT WILL BE : "  "

LS_RETURNSTR := '';
J:=(case when P_START=0 then 1 else P_START end)+P_LENGTH-1;
LOOP
EXIT WHEN I>LENGTHB(P_STRING) or lengthB(LS_RETURNSTR)=P_LENGTH; --���δ���P_STRING��ÿ���ַ�
 LS_CH:=SUBSTRB(P_STRING , I , 1);
 IF ASCII(LS_CH)<128 THEN -- �Ǻ���
   if I>=P_START and I<=j then
      LS_RETURNSTR := LS_RETURNSTR||LS_CH; -- ����
   end if;
 ELSE -- �Ǻ���
   ishzfirst := not ishzfirst;
   if I>=P_START and I<=j  then
      if not ishzfirst and (i=P_START or i=j) then
         LS_RETURNSTR := LS_RETURNSTR||' '; -- �滻�ո�
      else
         LS_RETURNSTR := LS_RETURNSTR||LS_CH; -- ����
      end if;
   end if;
 END IF;
 I:=I+1;
END LOOP; -- �������

RETURN LS_RETURNSTR;
END SubstrbHZ;
/


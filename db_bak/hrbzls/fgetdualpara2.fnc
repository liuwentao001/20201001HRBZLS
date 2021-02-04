CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA2" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  分隔符   VARCHAR2(30000);
  参数个数 number(10);
  表达式   VARCHAR2(30000);
  参数值   VARCHAR2(30000);
  具体参数1 VARCHAR2(30000);
  具体参数2 VARCHAR2(30000);
  具体参数3 VARCHAR2(30000);
  具体参数4 VARCHAR2(30000);
  具体参数5 VARCHAR2(30000);
  具体参数6 VARCHAR2(30000);
  具体参数7 VARCHAR2(30000);
  具体参数8 VARCHAR2(30000);
  具体参数9 VARCHAR2(30000);

  分隔符2  VARCHAR2(30000);
  分隔符3  VARCHAR2(30000);
  参数符号 VARCHAR2(30000);
BEGIN
  --分隔符 $
  --参数个数
  --表达式
  --参数值
  分隔符   := '♂';
  分隔符2  := '♀';
  分隔符3  := '☆';
  参数符号 := '@';
  参数个数 := tools.fmid(P_funpara, 1, 'N', 分隔符);
  表达式   := tools.fmid(P_funpara, 2, 'N', 分隔符);
  参数值   := tools.fmid(P_funpara, 3, 'N', 分隔符);

/*  for i in 1 .. 参数个数 loop
    具体参数 := tools.fmid(参数值, i+1, 'N', 分隔符2);
  end loop;*/

  if 表达式='1' then
    具体参数1 := tools.fmid(参数值, 2, 'N', 分隔符2);
   V_RET := fgetdualpara1(   具体参数1   );
  end if;


  RETURN V_RET;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


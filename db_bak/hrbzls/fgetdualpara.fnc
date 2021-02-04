CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  v_sql    VARCHAR2(30000);
  分隔符   VARCHAR2(30000);
  参数个数 number(10);
  表达式   VARCHAR2(30000);
  参数值   VARCHAR2(30000);
  具体参数 VARCHAR2(30000);
  替换     VARCHAR2(30000);
  被替换   VARCHAR2(30000);
  分隔符2  VARCHAR2(30000);
  分隔符3  VARCHAR2(30000);
  参数符号 VARCHAR2(30000);
BEGIN
  --分隔符 $
  --参数个数
  --表达式
  --参数值
  NULL;
  分隔符   := '♂';
  分隔符2  := '♀';
  分隔符3  := '☆';
  参数符号 := '#@#';
 /* 分隔符   := '#|#';
  分隔符2  := '#;#';
  分隔符3  := '#,#';
  参数符号 := '#@#';*/


  参数个数 := tools.fmid_sepmore(P_funpara, 1, 'N', 分隔符);
  表达式   := tools.fmid_sepmore(P_funpara, 2, 'N', 分隔符);
  参数值   := tools.fmid_sepmore(P_funpara, 3, 'N', 分隔符);

  for i in 1 .. 参数个数 loop
    具体参数 := tools.fmid_sepmore(参数值, i+1, 'N', 分隔符2);
    替换     := tools.fmid_sepmore(具体参数, 1, 'N', 分隔符3);
    被替换   := tools.fmid_sepmore(具体参数, 2, 'N', 分隔符3);
    表达式   := replace(表达式, 参数符号 || 被替换, 替换);
  end loop;


  v_sql := 表达式;
  execute immediate v_sql
    into V_RET;
  RETURN V_RET;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


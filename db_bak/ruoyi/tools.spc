CREATE OR REPLACE PACKAGE "TOOLS" IS

  -- AUTHOR  : 江浩
  -- CREATED : 2008-01-08 16:34:39
  -- PURPOSE : JH

  --抄表月份
  FUNCTION  FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2;
  
  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE;

  function  getmax(n1 in number,n2 in number) return number;

  function  getmin(n1 in number,n2 in number) return number;

END TOOLS;
/


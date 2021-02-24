﻿CREATE OR REPLACE PACKAGE "TOOLS" IS

  -- AUTHOR  : 江浩
  -- CREATED : 2008-01-08 16:34:39
  -- PURPOSE : JH

  --抄表月份
  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2;

  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

END TOOLS;
/


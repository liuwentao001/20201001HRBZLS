CREATE OR REPLACE PACKAGE BODY "TOOLS" IS

  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    --抄表月份
    RETURN FPARA(P_SMFID, '000009');
  END;

  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE AS
    XTRQ DATE;
  BEGIN
    SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYY/MM/DD')
      INTO XTRQ
      FROM DUAL;
    RETURN XTRQ;
  END;

  function getmax(n1 in number, n2 in number) return number is
  begin
    if nvl(n1, 0) >= nvl(n2, 0) then
      return nvl(n1, 0);
    else
      return nvl(n2, 0);
    end if;
  end getmax;

  function getmin(n1 in number, n2 in number) return number is
  begin
    if nvl(n1, 0) <= nvl(n2, 0) then
      return nvl(n1, 0);
    else
      return nvl(n2, 0);
    end if;
  end getmin;

END TOOLS;
/


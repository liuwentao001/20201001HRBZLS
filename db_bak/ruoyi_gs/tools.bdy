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

  function  getmax(n1 in number,n2 in number) return number
  is
  begin
      if nvl(n1,0) >= nvl(n2,0) then
         return nvl(n1,0);
      else
         return nvl(n2,0);
      end if;
  end getmax;

  function  getmin(n1 in number,n2 in number) return number
  is
  begin
      if nvl(n1,0) <= nvl(n2,0) then
         return nvl(n1,0);
      else
         return nvl(n2,0);
      end if;
  end getmin;

  function  fgetrecmonth(p_smfid in varchar2) return varchar2 is
  begin
  --应月份
    --return fpara(p_smfid,'000008');
      return to_char(sysdate, 'yyyy.mm'); --【哈尔滨】账务月份取自然月份
  end;
  
  function  fgetrecdate(p_smfid in varchar2) return date is
  begin
  --本期应收帐务日期
      return trunc(sysdate);
  end;
  
END TOOLS;
/


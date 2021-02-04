CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSZD" (P_ZDID in varchar2  )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT T.SCLVALUE
     INTO lret
     FROM SYSCHARLIST  T
    WHERE  T.SCLTYPE='银行缴费站点'
    AND T.SCLID=P_ZDID;
   Return lret;
exception when others then
   return null;
END  fGetSYSZD;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETINVSTATUS" (P_invo in varchar2  )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT invsname
     INTO lret
     FROM invoicestatus  T
    WHERE  T.invsid=P_invo;
   Return lret;
exception when others then
   return null;
END  fGetinvstatus;
/


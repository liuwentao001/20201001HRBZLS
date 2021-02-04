CREATE OR REPLACE FUNCTION HRBZLS."FGETWSNAME" (p_wsid in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT wsname
     INTO lret
     FROM workstation
    WHERE wsid  = p_wsid;
   Return lret;
exception when others then
   return null;
END;
/


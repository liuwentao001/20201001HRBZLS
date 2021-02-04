CREATE OR REPLACE FUNCTION HRBZLS."FGETBILLNAME01" (p_billtype in varchar2 )
  RETURN VARCHAR2
AS
  lret VARCHAR2(40);
BEGIN
   SELECT bmname
     INTO lret
     FROM billmain
    WHERE  bmtype = p_billtype ;
   Return lret;
exception when others then
   return null;
END;
/


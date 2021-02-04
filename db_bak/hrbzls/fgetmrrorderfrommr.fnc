CREATE OR REPLACE FUNCTION HRBZLS."FGETMRRORDERFROMMR" (p_mrid in varchar2 )
  RETURN number
AS
  lret    number(10);
BEGIN
   SELECT MRRORDER
     INTO lret
     FROM view_meterreadall
    WHERE mrid  = p_mrid  ;
   Return lret;
exception when others then
   return null;
END;
/


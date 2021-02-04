CREATE OR REPLACE FUNCTION HRBZLS."FGETMILB" (p_milb in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT decode(p_milb,'H','户表','D','总表')
     INTO lret
     FROM dual;
   Return lret;
exception when others then
   return null;
END;
/


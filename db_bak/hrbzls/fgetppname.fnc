CREATE OR REPLACE FUNCTION HRBZLS."FGETPPNAME" (p_ppid in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT ppname
     INTO lret
     FROM paypoints
    WHERE ppid  = p_ppid;
   Return lret;
exception when others then
   return null;
END;
/


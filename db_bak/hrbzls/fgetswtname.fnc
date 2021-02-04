CREATE OR REPLACE FUNCTION HRBZLS."FGETSWTNAME" (p_swtid in varchar2 )
	RETURN VARCHAR2
AS
	lret    VARCHAR2(20);
BEGIN
   SELECT sclvalue
     INTO lret
     FROM syscharlist
    WHERE sclid  = p_swtid;
   Return lret;
exception when others then
   return null;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETBFNAME_TM" (p_bfid in varchar2)
	RETURN VARCHAR2
AS
	lret    VARCHAR2(60);
BEGIN
   SELECT bfname
     INTO lret
     FROM bookframe
    WHERE bfid  = p_bfid;
   Return lret;
exception when others then
   return p_bfid;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETBFCLASS" (p_bfid in varchar2 )
	RETURN VARCHAR2
AS
	lret number;
BEGIN
   SELECT bfclass
     INTO lret
     FROM bookframe
    WHERE bfid  = p_bfid;
   Return lret;
exception when others then
   return null;
END;
/


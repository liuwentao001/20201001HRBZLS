CREATE OR REPLACE FUNCTION HRBZLS."FGETBFNAME" (p_bfid in varchar2,p_smfid in varchar2 )
	RETURN VARCHAR2
AS
	lret    VARCHAR2(60);
BEGIN
   SELECT bfname
     INTO lret
     FROM bookframe
    WHERE bfid  = p_bfid
    and BFSMFID = p_smfid ;
   Return lret;
exception when others then
   return p_bfid;
END;
/


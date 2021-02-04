CREATE OR REPLACE FUNCTION HRBZLS."FGETSMFNAME" (p_smfid in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT smfname
     INTO lret
     FROM sysmanaframe
    WHERE smfid  = p_smfid;
   Return lret;
exception when others then
   return null;
END;
/


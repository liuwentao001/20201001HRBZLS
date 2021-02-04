CREATE OR REPLACE FUNCTION HRBZLS."FGETOGMNAME" (p_group in varchar2,p_ogmid in varchar2 )
	RETURN VARCHAR2
AS
	lret    VARCHAR2(60);
BEGIN
   SELECT ogmname
     INTO lret
     FROM opergroupmod
    WHERE ogmid  = p_ogmid and ogmgid = p_group;
   Return lret;
exception when others then
   return null;
END;
/


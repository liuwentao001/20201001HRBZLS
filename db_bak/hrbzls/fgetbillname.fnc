CREATE OR REPLACE FUNCTION HRBZLS."FGETBILLNAME" (p_object in varchar2,p_billtype in varchar2 )
	RETURN VARCHAR2
AS
	lret VARCHAR2(40);
BEGIN
   SELECT bmname
     INTO lret
     FROM billmain
    WHERE bmuserobject = p_object
    and bmtype = p_billtype ;
   Return lret;
exception when others then
   return null;
END;
/


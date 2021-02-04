CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERDEPT" (p_oaid in varchar2 )
	RETURN VARCHAR2
AS
	lret    VARCHAR2(60);
BEGIN
   SELECT oadept
     INTO lret
     FROM operaccnt
    WHERE oaid  = p_oaid;
   Return lret;
exception when others then
   return null;
END;
/


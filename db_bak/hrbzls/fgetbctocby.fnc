CREATE OR REPLACE FUNCTION HRBZLS."FGETBCTOCBY" (p_bc in varchar2)
	RETURN VARCHAR2
AS
	lret VARCHAR2(40);
BEGIN
select BFRPER
into lret
from bookframe t
where  t.bfid=p_bc ;
   Return lret;
exception when others then
   return null;
END;
/


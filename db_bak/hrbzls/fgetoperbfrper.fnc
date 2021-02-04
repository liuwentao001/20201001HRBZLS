CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERBFRPER" (p_bfid in varchar2,p_bfclass in varchar2 )
	RETURN VARCHAR2
AS
	lret    VARCHAR2(60);
BEGIN
select max(bfrper) into lret from bookframe where bfpid = p_bfid and bfclass='3' and bfstatus ='Y';
   Return lret;
exception when others then
   return null;
END;
/


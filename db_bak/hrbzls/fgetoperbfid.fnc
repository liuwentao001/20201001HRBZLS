CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERBFID" (p_bfid in varchar2,p_bfclass in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
  if p_bfclass <> 3 then
  select count(*) into lret from bookframe where bfpid = p_bfid and bfstatus ='Y';
   Return lret;
  else
  select count(*) into lret from meterinfo where mibfid =p_bfid;
   Return lret;
   end if;
exception when others then
   return p_bfid;
END;
/


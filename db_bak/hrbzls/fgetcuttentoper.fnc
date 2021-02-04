CREATE OR REPLACE FUNCTION HRBZLS."FGETCUTTENTOPER" (p_pmicode in varchar2 )
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
  select distinct bfrper
    into lret
    from meterinfo mi, bookframe bf
   where mi.mibfid = bf.bfid
     and mi.micode = p_pmicode;
   Return lret;
exception when others then
   return p_pmicode;
END;
/


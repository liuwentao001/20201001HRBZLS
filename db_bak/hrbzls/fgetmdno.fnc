CREATE OR REPLACE FUNCTION HRBZLS."FGETMDNO" (p_miid in varchar2) RETURN VARCHAR2 AS
  lret VARCHAR2(60);
BEGIN
  SELECT mdno INTO lret FROM meterdoc WHERE mdmid = p_miid;
  Return lret;
exception
  when others then
    return null;
END;
/


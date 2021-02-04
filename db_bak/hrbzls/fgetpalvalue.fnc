CREATE OR REPLACE FUNCTION HRBZLS."FGETPALVALUE" (p_miid in varchar2) RETURN VARCHAR2 AS
  lret VARCHAR2(60);
BEGIN
  SELECT PALWAY * PALVALUE
    INTO lret
    FROM PRICEADJUSTLIST
   WHERE PALPIID = '02'
     AND PALTACTIC IN ('02', '07')
     AND PALSTATUS = 'Y'
     and PALMID = p_miid;
  Return lret;
exception
  when others then
    return null;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETSCLNAME" (p_type in varchar2,p_id in varchar)
  RETURN VARCHAR2
AS
  lret VARCHAR2(50);
BEGIN
   SELECT sclvalue
     INTO lret
     FROM syscharlist
    WHERE scltype = p_type
      and sclid = p_id;
   Return lret;
exception when others then
   return p_id;
END;
/


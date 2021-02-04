CREATE OR REPLACE FUNCTION HRBZLS."FGETWORKPRINTSET_WPSPTHID" (p_wpswsid in varchar2,
p_wpsitid in varchar2 )
  RETURN number
AS
  lret number(10);
BEGIN
   SELECT wpspthid
     INTO lret
     FROM workprintset t
    WHERE t.wpswsid=p_wpswsid  and t.wpsitid = p_wpsitid
  ;
   Return lret;
exception when others then
   return null;
END;
/


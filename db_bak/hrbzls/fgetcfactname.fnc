CREATE OR REPLACE FUNCTION HRBZLS."FGETCFACTNAME" (p_act in varchar2) RETURN VARCHAR2 AS
  lret VARCHAR2(40);
BEGIN
  select sclvalue
    INTO lret
    from syscharlist
   where scltype = '���ý��������'
     and sclid = p_act;
  Return lret;
exception
  when others then
    return null;
END;
/


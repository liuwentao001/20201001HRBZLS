CREATE OR REPLACE FUNCTION HRBZLS."FGETRECZNJMONEY_GTMX" (p_rlid in varchar2 )
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
       select (sum(pdje) + sum(pdznj)) pdje
       into v_ret
   from  paidlist, paiddetail
  where plid = p_rlid
    and plid = pdid;
      return v_ret;

END;
/


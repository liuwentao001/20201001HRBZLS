CREATE OR REPLACE FUNCTION HRBZLS."FGETRECZNJMONEY_GT" (p_rlid in varchar2 )
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
       select (sum(pdje) + sum(pdznj)) pdje
       into v_ret
   from payment, paidlist, paiddetail
  where pid = p_rlid
    and pid = plpid
    and plid = pdid;
      return v_ret;

END;
/


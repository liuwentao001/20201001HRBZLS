CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITMONEY_GTMX" (p_plid in varchar2 )
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
      select tools.fformatnum(sum(pdje), 2)
      into v_ret
  from payment, paidlist, paiddetail
 where plid = p_plid
   and pid = plpid
   and plid = pdid
   --and pdpiid = '01'
;
      return v_ret;

END;
/


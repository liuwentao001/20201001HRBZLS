CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITMONEY_GT" (p_pid in varchar2 )
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
      select connstr(tools.fformatnum(sum(pdje), 2))
      into v_ret
  from payment, paidlist, paiddetail
 where pid = p_pid
   and pid = plpid
   and plid = pdid
   and pdpiid = '01'
 group by pdpiid;
      return v_ret;

END;
/


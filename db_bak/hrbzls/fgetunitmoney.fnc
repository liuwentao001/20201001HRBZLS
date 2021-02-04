CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITMONEY" (p_rlid in varchar2 ) --返回入户直收01水量金额
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
      select sum(rdysje) into v_ret from (
  select tools.fformatnum(sum(rdysje), 2)
    rdysje
    from recdetail t
   where rdid = p_rlid
     and rdpiid = '01'
   group by rdpfid, t.rdpmdid);
  return v_ret;

END;
/


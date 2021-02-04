CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITPRICE" (p_rlid in varchar2 )--返回入户直收01单价
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
     select sum(rddj) into v_ret from (
  select tools.fformatnum(sum(rddj), 2)
    rddj
    from recdetail t
   where rdid = p_rlid
     and rdpiid = '01'
   group by rdpfid, t.rdpmdid);
  return v_ret;
END;
/


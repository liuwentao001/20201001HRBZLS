CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITPRICE_MX_WZZLS" (p_rlid in varchar2)
  RETURN VARCHAR2 AS
  v_ret varchar2(2000);
  v_dj number(10,2);
  i int;
  v_piid varchar2(50);
BEGIN
   v_dj := 0;
select tools.fformatnum(avg(dj), 2)
  into v_dj
  from (select sum(rdysdj * rdpmdscale) dj
          from reclist, recdetail
         where rlid = rdid
           and rlid = p_rlid
           and rdmethod = 'dj1');
   v_ret := to_char(v_dj,'0.00');
   return v_ret;
END;
/


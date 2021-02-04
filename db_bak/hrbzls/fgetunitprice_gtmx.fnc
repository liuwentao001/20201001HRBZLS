CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITPRICE_GTMX" (p_rlid in varchar2)
  RETURN VARCHAR2 AS
  v_ret varchar2(2000);

BEGIN
select tools.fformatnum(avg(dj),2) into v_ret from (
select sum(rdysdj*rdpmdscale) dj,sum(rdpmdscale)
  from reclist, recdetail
 where rlid = rdid
   and rlid = p_rlid
   and rdpiid = '01'
   and rdpmdscale<=1
union
select sum(case when rdysdj is null then 0 else rdysdj end) dj,sum(rdpmdscale)
  from reclist, recdetail
 where rlid = rdid
   and rlid = p_rlid
   and rdpiid = '01'
   and rdpmdscale>1
   );
   return v_ret;
END;
/


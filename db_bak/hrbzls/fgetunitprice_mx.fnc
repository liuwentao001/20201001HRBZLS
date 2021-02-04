CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITPRICE_MX" (p_rlid in varchar2,p_pdiid in varchar2,p_splitnum in int)
  RETURN VARCHAR2 AS
  v_ret varchar2(2000);
  v_dj number(10,2);
  i int;
  v_piid varchar2(50);
BEGIN
   v_dj := 0;
   for i in 1..p_splitnum loop
      v_piid := tools.fgetpara(p_pdiid,1,i);
      v_dj := v_dj + nvl(fGetUnitPrice_gtmx1(p_rlid,v_piid),0);
   end loop;
   v_ret := to_char(v_dj,'0.00');
   return v_ret;
END;
/


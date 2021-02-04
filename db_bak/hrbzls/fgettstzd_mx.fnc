CREATE OR REPLACE FUNCTION HRBZLS."FGETTSTZD_MX" (p_mid in varchar2,p_row in number) RETURN varchar2 AS
  v_getstr varchar2(4000);
  v_month varchar2(50);
  v_ecode number;
  v_rlsl number;
  v_rlje number(10,2);
BEGIN
  --停水通知单打印明细
  --设置查询第几行明细
  select rlmonth, rlecode, rlsl, rlje into v_month,v_ecode,v_rlsl,v_rlje
  from (select rownum no, rlmonth, rlecode, rlsl, rlje
          from reclist
         where RLPAIDFLAG = 'N'
           and rlje - RLPAIDJE > 0
           and rlcd = 'DE'
           and rlmid = p_mid
           order by rlmonth)
           where no = p_row;
  v_getstr := v_month||'     '||to_char(v_ecode)||'      '||to_char(v_rlsl)||'      '||to_char(v_rlje);
  RETURN v_getstr;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END ;
/


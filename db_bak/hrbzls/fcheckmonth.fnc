CREATE OR REPLACE FUNCTION HRBZLS."FCHECKMONTH" (p_month in varchar2) return varchar2 is
  v_flag varchar2(4);
begin
  --判断输入的年月是否是最近的六个月
  if p_month is not null then
     if to_date(p_month,'yyyy.mm')>add_months(sysdate, -7) and to_date(p_month,'yyyy.mm') <=sysdate then
       v_flag :='Y';
     else
       v_flag:='N';
     end if;
  end if;
  return v_flag;

exception when others then
  v_flag :='E';
  return v_flag;
end fcheckmonth;
/


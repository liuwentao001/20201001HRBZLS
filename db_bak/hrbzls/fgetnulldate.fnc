CREATE OR REPLACE FUNCTION HRBZLS."FGETNULLDATE" return date is
  v_date date;
  v_count number(2);
begin
  return null;
  /*select  add_months(to_date('000101','yyyymm'),-1) into v_date from dual;
  return v_date;*/

exception when others then
  return null;
end fgetnulldate;
/


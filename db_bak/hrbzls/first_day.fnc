CREATE OR REPLACE FUNCTION HRBZLS."FIRST_DAY" (p_date in date) return date as
-- p_type : Y 年份第一天 ，m 月份第一天，w 周第一天
--
  v_result date;
begin
  select trunc(p_date,'mm') into v_result from dual;
  return v_result;
end first_day;
/


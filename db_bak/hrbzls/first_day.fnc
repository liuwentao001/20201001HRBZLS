CREATE OR REPLACE FUNCTION HRBZLS."FIRST_DAY" (p_date in date) return date as
-- p_type : Y ��ݵ�һ�� ��m �·ݵ�һ�죬w �ܵ�һ��
--
  v_result date;
begin
  select trunc(p_date,'mm') into v_result from dual;
  return v_result;
end first_day;
/


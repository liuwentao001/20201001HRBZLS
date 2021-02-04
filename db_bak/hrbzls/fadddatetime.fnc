CREATE OR REPLACE FUNCTION HRBZLS."FADDDATETIME" (p_datetime in varchar2,p_num in number)
  return date is
  Result date;
  vdt    date;
begin
  vdt   := to_date(p_datetime,'yyyymmdd hh24:mi:ss');
  SELECT vdt+p_num
  INTO Result
  FROM DUAL ;

  RETURN(RESULT);
EXCEPTION WHEN OTHERS THEN
  return null;
end fadddatetime;
/


CREATE OR REPLACE FUNCTION HRBZLS."F_GET_REVERSE_STRING" (v_str varchar2,v_delimiter varchar2 default ',')
return varchar2
is
v_result varchar2(4000);
begin

   select wm_concat(column_value) into v_result
   from (
      select rownum rn,column_value from table( f_splitstringbydelimiter(v_str,v_delimiter))order by rn desc
   );
  return v_result;
end;
/


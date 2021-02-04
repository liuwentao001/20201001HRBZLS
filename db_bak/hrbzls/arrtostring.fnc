CREATE OR REPLACE FUNCTION HRBZLS."ARRTOSTRING"(p_in in arr) return varchar2 as
  v_ret varchar2(4000);
  num_i integer;
begin
  --ÖØ¸´È¡¼ÇÂ¼
  for num_i in 1 .. p_in.count loop
    v_ret := v_ret || ',' || p_in(num_i);
  end loop;
  v_ret := substr(v_ret, 2, length(v_ret));
  RETURN v_ret;
EXCEPTION
  WHEN OTHERS THEN
    return null;
end ARRTOSTRING;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETPYTS" (p_bfid in varchar2) return number
is
 v_ret number;
begin

  select nvl(BFDAY,0) into v_ret from bookframe bf where bf.bfid=p_bfid;
  return v_ret;
exception
    when others then
        return 0;
end;
/


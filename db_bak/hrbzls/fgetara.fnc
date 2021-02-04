CREATE OR REPLACE FUNCTION HRBZLS."FGETARA" (p_bfid in varchar2) return varchar2

 is
  ret varchar2(10);
begin

  select t.BFSAFID into ret from bookframe t where t.bfid = p_bfid;
  return ret;
exception
  when others then

    return p_bfid;
end;
/


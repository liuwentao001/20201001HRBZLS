CREATE OR REPLACE FUNCTION HRBZLS."F_GETOPERID" (p_opername in varchar2) return varchar2 is
    v_opername varchar2(20);
  begin
    begin
      select oper.oaid
        into v_opername
        from operaccnt oper
       where trim(oper.oaname) = trim(p_opername);
      return v_opername;
    exception
      when others then
        return 'system';
    end;
   end;
/


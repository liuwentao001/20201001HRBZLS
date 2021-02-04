CREATE OR REPLACE FUNCTION HRBZLS."FCHKISCBY" (p_oaid in varchar2) return varchar2
  is
  v_return varchar2(20) :='Y';
  v_count number;

  begin
    select count(*) into v_count from operaccntrole t where t.oaroaid = p_oaid;
    if v_count = 1 then
      select count(*) into v_count from operaccntrole t where t.oaroaid = p_oaid and t.oarrid = '08';
      if v_count = 1 then
        return 'N';
      end if;
    else
      return 'Y';
    end if;
    exception
      when others then
        return 'N';
  end;
/


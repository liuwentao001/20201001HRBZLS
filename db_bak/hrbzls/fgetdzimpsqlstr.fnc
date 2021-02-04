CREATE OR REPLACE FUNCTION HRBZLS."FGETDZIMPSQLSTR" (p_type in varchar2, p_bankid in varchar2)
  return varchar2 is
  v_retsql varchar2(20000);
begin
    if p_type is null then
      raise_application_error('-200002', '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error('-200002', '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_type = '01' then
      v_retsql := FPARA(substr(p_bankid, 1, 4), 'DZIMP');
    else
      return null;
    end if;
    return v_retsql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
end;
/


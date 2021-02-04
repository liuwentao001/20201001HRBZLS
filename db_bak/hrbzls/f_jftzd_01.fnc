CREATE OR REPLACE FUNCTION HRBZLS."F_JFTZD_01" (p_smpid in varchar2) return varchar2 is
  v_smppvalue varchar2(400);
begin

  begin
    select smppvalue
      into v_smppvalue
      from sysmanapara
     where smppid='ZH' and smpid = p_smpid;

    if v_smppvalue is not null then
      return v_smppvalue;
    end if;
  exception
    when others then
      return '银行账号为空，请检查';
  end;
end;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGTJFPARA" (p_mrid in varchar2, --������ˮ
                                     p_type in varchar2) return number is
  gp GDJFPRINTPARA%rowtype;
begin
  if p_type = '1' then
    select round(t.����ˮ�ѽ��ʽ��,2)
      into gp.����ˮ�ѽ��ʽ��      
      from GDJFPRINTPARA t
     where t.������ˮ = p_mrid;
    return gp.����ˮ�ѽ��ʽ��;
  end if;
  if p_type = '2' then
    select t.����Ԥ��
      into gp.����Ԥ��
      from GDJFPRINTPARA t
     where t.������ˮ = p_mrid;
    return gp.����Ԥ��;
  end if;

  return 0;

exception
  when others then
    return 0;

end;
/


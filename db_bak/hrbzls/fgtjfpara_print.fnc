CREATE OR REPLACE FUNCTION HRBZLS."FGTJFPARA_PRINT" (p_mrid in varchar2, --������ˮ
                                           p_pbatch in varchar2,--�ɷ����κ�
                                     p_type in varchar2) return number is
  gp GDJFPRINTPARA_print%rowtype;
begin
  if p_type = '1' then
    select t.����ˮ�ѽ��ʽ��
      into gp.����ˮ�ѽ��ʽ��
      from GDJFPRINTPARA_print t
     where t.������ˮ = p_mrid
     and t.���κ�=p_pbatch
     and  t.ˮ��+t.������>0 ;
    return gp.����ˮ�ѽ��ʽ��;
  end if;
  if p_type = '2' then
    select t.����Ԥ��
      into gp.����Ԥ��
      from GDJFPRINTPARA_print t
     where t.������ˮ = p_mrid
     and t.���κ�=p_pbatch
     and  t.ˮ��+t.������>0 ;
    return gp.����Ԥ��;
  end if;

  return 0;

exception
  when others then
    return 0;

end;
/


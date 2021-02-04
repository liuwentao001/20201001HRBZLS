CREATE OR REPLACE FUNCTION HRBZLS."FGTJFPARA_PRINT" (p_mrid in varchar2, --抄表流水
                                           p_pbatch in varchar2,--缴费批次号
                                     p_type in varchar2) return number is
  gp GDJFPRINTPARA_print%rowtype;
begin
  if p_type = '1' then
    select t.本期水费进帐金额
      into gp.本期水费进帐金额
      from GDJFPRINTPARA_print t
     where t.抄表流水 = p_mrid
     and t.批次号=p_pbatch
     and  t.水费+t.垃圾费>0 ;
    return gp.本期水费进帐金额;
  end if;
  if p_type = '2' then
    select t.本期预存
      into gp.本期预存
      from GDJFPRINTPARA_print t
     where t.抄表流水 = p_mrid
     and t.批次号=p_pbatch
     and  t.水费+t.垃圾费>0 ;
    return gp.本期预存;
  end if;

  return 0;

exception
  when others then
    return 0;

end;
/


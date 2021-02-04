CREATE OR REPLACE FUNCTION HRBZLS."FGTJFPARA" (p_mrid in varchar2, --抄表流水
                                     p_type in varchar2) return number is
  gp GDJFPRINTPARA%rowtype;
begin
  if p_type = '1' then
    select round(t.本期水费进帐金额,2)
      into gp.本期水费进帐金额      
      from GDJFPRINTPARA t
     where t.抄表流水 = p_mrid;
    return gp.本期水费进帐金额;
  end if;
  if p_type = '2' then
    select t.本期预存
      into gp.本期预存
      from GDJFPRINTPARA t
     where t.抄表流水 = p_mrid;
    return gp.本期预存;
  end if;

  return 0;

exception
  when others then
    return 0;

end;
/


CREATE OR REPLACE FUNCTION HRBZLS."F_SFQD_02" (p_mipriid in varchar2)
  return varchar2 is
  v_miid varchar2(400);
begin

  begin
       select connstr(mi.miid) into v_miid
                      from meterinfo mi
                      where mi.mipriflag = 'Y'
                      and mi.mipriid = p_mipriid
                    group by mi.mipriid ;


  if  v_miid is not null then
    return v_miid;
     end if;
      exception
     when others then
      return '合收表有错误';
  end;
end;
/


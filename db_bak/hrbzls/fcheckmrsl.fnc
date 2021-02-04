CREATE OR REPLACE FUNCTION HRBZLS."FCHECKMRSL" (p_mrid in varchar2, p_mrsl in number)
  return varchar2 is
  mi meterinfo%rowtype;
  mr meterread%rowtype;
begin

  begin
    select * into mr from meterread where mrid = p_mrid;
  exception
    when others then
      return '抄表计划不存在!';
  end;

  if p_mrsl > 20  and mr.MRLASTSL >0  and (abs(p_mrsl - mr.MRLASTSL) > mr.MRLASTSL or
     abs(p_mrsl - mr.MRLASTSL) < mr.MRLASTSL / 2) then
    return 'Y';
  elsif p_mrsl > 20 and mr.MRTHREESL>0  and  (abs(p_mrsl - mr.MRTHREESL) > mr.MRTHREESL or
        abs(p_mrsl - mr.MRTHREESL) < mr.MRTHREESL / 2) then
    return 'Y';
  elsif p_mrsl > 20 and mr.MRYEARSL>0  and  (abs(p_mrsl - mr.MRYEARSL) > mr.MRYEARSL or
        abs(p_mrsl - mr.MRYEARSL) < mr.MRYEARSL / 2) then
    return 'Y';
  else
    return 'N';
  end if;
exception
  when others then
    return '检查异常!';
end;
/


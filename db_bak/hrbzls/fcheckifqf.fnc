CREATE OR REPLACE FUNCTION HRBZLS."FCHECKIFQF" (p_miid in varchar2) return varchar2 is
  v_flag varchar2(4);
  v_count number(2);
begin
  --判断水表是否存在欠费
  if p_miid is not null then
     select count(*) into v_count
       from reclist
      where rlmid=p_miid
        and rlpaidflag='N' and rlcd='DE';
     if v_count > 0 then
        v_flag :='Y';
     else
       v_flag:='N';
     end if;
  end if;
  return v_flag;

exception when others then
  v_flag :='N';
  return v_flag;
end fcheckifqf;
/


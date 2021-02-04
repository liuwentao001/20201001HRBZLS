create or replace function hrbzls.fgetsjwsf(mipfid in varchar2, p_miid in varchar2) return number is
  v_pdwdj  number;
  V_PALVALUE number;
  V_PALSTARTMON number;
  V_PALENDMON   number;
  V_TODAY       number;
  v_count       number;
begin


  select count(*) into v_count from priceadjustlist where palmid=p_miid and PALSTATUS='Y';

  if v_count>0 then
    select nvl(PALVALUE,0),PALSTARTMON,PALENDMON INTO V_PALVALUE,V_PALSTARTMON,V_PALENDMON from priceadjustlist where palmid=p_miid and PALSTATUS='Y';
    select  extract(YEAR from sysdate )||'.'||extract(MONTH from sysdate ) into V_TODAY from dual;
      IF to_date(V_TODAY,'yyyy.mm') <to_date(V_PALSTARTMON,'yyyy.mm') AND to_date(V_TODAY,'yyyy.mm') > to_date(V_PALENDMON,'yyyy.mm') THEN
       V_PALVALUE := 0;
      END IF;
  else
      V_PALVALUE :=0;
  end if;
  select pddj into v_pdwdj from pricedetail where pdpfid=mipfid and pdpiid='02';

  return v_pdwdj+V_PALVALUE;
end fgetsjwsf;
/


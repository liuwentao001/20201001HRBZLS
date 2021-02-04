CREATE OR REPLACE FUNCTION HRBZLS."FGETRECMONEY_SY" (p_miid in varchar2,p_month in varchar2) return number is
  v_month       varchar2(7);
  v_money       number(12,3);
begin
  select max(t.rlmonth)
  into v_month
  from reclist t
  where t.rlmid = p_miid
  and   t.rlmonth < p_month
  and   t.rltrans = '1'
  and   t.rlpaidflag <> 'X'
  and   t.rlcd = 'DE';

  if v_month is null then
     v_money := 0;
  else
    select sum(t.rlje)
    into v_money
    from reclist t
    where t.rlmid = p_miid
    and   t.rlmonth = v_month
    and   t.rltrans = '1'
    and   t.rlpaidflag <> 'X'
    and   t.rlcd = 'DE';
  end if;

  return(v_money);
exception when others then
  raise_application_error(-20001,p_miid||','||p_month||','||sqlerrm);
end FGETRECMONEY_SY;
/


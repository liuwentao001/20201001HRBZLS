CREATE OR REPLACE FUNCTION HRBZLS."FGETRECQFMONEY_SY" (p_miid in varchar2,p_month in varchar2) return varchar2 is
  v_msg         varchar2(500);
  v_qfnum       number(5);
  v_money       number(12,3);
begin
  select count(RLID),sum(t.rlje - T.RLPAIDJE)
  into v_qfnum,v_money
  from reclist t
  where t.rlmid = p_miid
  and   t.rlmonth < p_month
  and   t.rlpaidflag in ('N','V','K','W')
  and   t.rlcd = 'DE'
  and   t.rlje - T.RLPAIDJE>0;

  if v_qfnum > 0 then
     v_msg := '�����ѷ����ۼ�Ƿ�ѹ� '||to_char(v_qfnum)||'��,�ܽ�� '||trim(to_char(v_money,'999999999990.00'))||'Ԫ';
  end if;

  return(v_msg);
end FGETRECQFMONEY_SY;
/


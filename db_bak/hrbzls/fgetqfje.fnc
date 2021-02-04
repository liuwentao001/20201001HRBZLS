CREATE OR REPLACE FUNCTION HRBZLS."FGETQFJE" (p_miid in varchar2) return number is
  v_money       number(12,3);
begin
  select sum(t.rlje - T.RLPAIDJE)
  into v_money
  from reclist t
  where t.rlmid = p_miid
  and   t.rlpaidflag in ('N','V','K','W')
  and   t.rlcd = 'DE'
  and   t.rlreverseflag = 'N'
  and   t.rlje >0
  and   t.rlje - T.RLPAIDJE>0;
  return v_money;
end fgetqfje;
/


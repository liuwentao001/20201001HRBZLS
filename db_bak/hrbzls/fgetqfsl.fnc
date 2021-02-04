CREATE OR REPLACE FUNCTION HRBZLS."FGETQFSL" (p_miid in varchar2) return number is

  v_qfsl       number(10);
begin
  select sum(rlsl)
  into v_qfsl
  from reclist t
  where t.rlmid = p_miid
  and   t.rlpaidflag in ('N','V','K','W')
  and   t.rlcd = 'DE'
  and   t.rlreverseflag = 'N'
  and   t.rlje >0
  and   t.rlje - T.RLPAIDJE>0;
  return v_qfsl;
end fgetqfsl;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETQFBS" (p_miid in varchar2) return number is
  v_qfnum       number(5);
begin
  select count(RLID)
  into v_qfnum
  from reclist t
  where t.rlmid = p_miid
  and   t.rlpaidflag in ('N','V','K','W')
  and   t.rlcd = 'DE'
  and   t.rlreverseflag = 'N'
  and   t.rlje >0
  and   t.rlje - T.RLPAIDJE>0;
  return v_qfnum;
end fgetqfbs;
/


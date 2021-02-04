CREATE OR REPLACE FUNCTION HRBZLS."SP_GETDJMX" (p_miuiid   varchar2,
                                      p_ETLSEQNO varchar2,
                                      p_i        number) return varchar2 is
  p_str  varchar2(200);
  p_rlsl varchar2(10);
  p_rddj varchar2(10);
  p_rdje varchar2(10);
  cursor cr is
    select to_char(sum(rdsl)),
           to_char(rddj, '0.00'),
           to_char(sum(rdje), '99990.00')
      from reclist r, meterinfo, recdetail, entrustlist
     where rlmid = miid
       and rlentrustbatch = etlbatch
       and etlseqno = p_ETLSEQNO
       and etlseqno = rlentrustseqno
       and rlpaidflag <> 'Y'
       and miuiid = p_miuiid
       and rdid = rlid
       and rdpiid = '04'
     group by rddj;
begin
  p_str := '@';
  open cr;
  loop
    fetch cr
      into p_rlsl, p_rddj, p_rdje;
    exit when cr%notfound or cr%notfound is null;
    p_str := p_str || rpad(p_rlsl, 11, ' ') || rpad(p_rddj, 11, ' ') ||
             rpad(p_rdje, 10, ' ') || '@';
  end loop;
  p_str := substr(p_str, instr(p_str,'@', case when p_i = 1 then 0 else 1 end, p_i) + 2, instr(p_str, '@', 1, p_i + 1) - instr(p_str, '@', case when p_i = 1 then 0 else 1 end, p_i) - 2);
  return p_str;
end;
/


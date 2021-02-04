create or replace function hrbzls.fgetwsfss(miid in varchar2) return number is
  v_rddj  number;
begin
   select rddj into v_rddj From recdetail where rdid in (select max(rlid)  From reclist  where rlmid =miid) and rdpiid ='02';
  return v_rddj;
end fgetwsfss;
/


create or replace function hrbzls.fgetwsf(mipfid in varchar2) return number is
  v_pdwdj  number;
begin
  select pddj into v_pdwdj from pricedetail where pdpfid=mipfid and pdpiid='02';
  return v_pdwdj;
end fgetwsf;
/


create or replace function hrbzls.fgetsf(mipfid in varchar2) return number is
  v_pddj  number;
begin
  select pddj into v_pddj from pricedetail where pdpfid=mipfid and pdpiid='01';
  return v_pddj;
end fgetsf;
/


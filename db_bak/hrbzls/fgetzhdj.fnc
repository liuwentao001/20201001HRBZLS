create or replace function hrbzls.fgetzhdj(mipfid in varchar2) return number is
  v_pfprice  number;
begin
  select pfprice into v_pfprice from priceframe where pfid=mipfid ;

  return v_pfprice;
end fgetzhdj;
/


create or replace function hrbzls.f_getifsp(p_pmid in varchar2) return varchar2 is
  ifsp varchar(4000);
begin
    select RLIFTAX into ifsp from reclist where rlmid=p_pmid;
  return ifsp;
end f_getifsp;
/


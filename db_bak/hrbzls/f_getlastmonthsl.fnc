CREATE OR REPLACE FUNCTION HRBZLS."F_GETLASTMONTHSL" (P_MIID varchar2)
  return number IS

  isl  number;
BEGIN
select tt.mrsl  into isl
  from (select rownum r, ta.*
          from (select *
                  from meterreadhis
                 where mrmid = P_MIID
                  and  mrsl>=0
                 order by mrmonth desc) ta) tt
 Where tt.r >= 1
   and tt.r < 2;
  return isl;
  EXCEPTION WHEN OTHERS THEN
   Return  0;
END f_GETLASTmonthSL;
/


CREATE OR REPLACE FUNCTION HRBZLS."F_CHARGEINVSEARCH_YC_OCX" (p_pbatch in varchar2,p_pmid in varchar2)
  RETURN number AS
  LCODE number(13,3);
BEGIN
null;
  select
sum( decode(pcd,'DE',1,-1 )*(ppayment - pchange) )
into LCODE
from payment t where pbatch=p_pbatch and (p_pmid is null or p_pmid=pmid  ) and ptrans='S' ;

  RETURN nvl(LCODE,0);
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."F_CHARGEINVSEARCH_SQMAVING_OCX" (p_pbatch in varchar2,p_mid in varchar2 )
  RETURN number AS
  LCODE number(13,3);
BEGIN

  select sum( tools.fmid( min( pid||'/'||replace( tools.fformatnum(pSAVINGQc, 2)   ,'-.','-0.') ) ,2,'N','/') )
into LCODE
from payment t where pbatch=p_pbatch and ( p_mid is null  or pmid=p_mid ) group by pmid ;


  RETURN LCODE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
/


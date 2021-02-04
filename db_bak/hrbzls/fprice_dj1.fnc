CREATE OR REPLACE FUNCTION HRBZLS."FPRICE_DJ1" (P_pfid IN VARCHAR2) RETURN number AS
  v_dj number(12,2);
BEGIN
 select sum(pddj) into v_dj  from pricedetail t where pdpscid=0 and pdpfid=P_pfid and pdmethod='dj1' ;
 return v_dj;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END;
/


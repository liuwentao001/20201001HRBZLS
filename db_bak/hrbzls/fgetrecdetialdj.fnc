CREATE OR REPLACE FUNCTION HRBZLS."FGETRECDETIALDJ" (p_rlid IN VARCHAR2)
  RETURN number

 AS
  P_PFPRICE number(12, 2);
BEGIN
 SELECT SUM(rddj) INTO P_PFPRICE from recdetail rd where rd.rdid=p_rlid;

  return P_PFPRICE;
exception
  when others then
    return null;
END;
/


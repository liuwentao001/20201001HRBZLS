CREATE OR REPLACE FUNCTION HRBZLS."FGETPDATE" (P_pbatch IN VARCHAR2) RETURN date AS
  ret date;
BEGIN
  SELECT pdate
    INTO ret
    FROM payment
   WHERE pbatch = P_pbatch
     and rownum = 1;
  return ret;
EXCEPTION
  WHEN OTHERS THEN
    RETURN sysdate;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTROLE"
   (Vid IN VARCHAR2,vrole IN VARCHAR2)
   Return CHAR
AS
   lret    number;
BEGIN
  SELECT COUNT(*) INTO lret FROM operaccntrole
  WHERE oaroaid =vid AND oarrid  = vrole;
  IF lret>0 THEN
    Return 'Y';
  Else
    Return 'N';
  END IF;
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/


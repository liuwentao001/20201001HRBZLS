CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTRFMETHOD"
   (Vid IN VARCHAR2,vfunc IN VARCHAR2,vmed IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
  SELECT COUNT(*) INTO lret FROM OPERACCNTRFMETHOD
  WHERE orfmrid  =vid AND orfmfid = vfunc AND orfmethod=vmed;
  IF lret>0 THEN
    SELECT ORFMTYPE INTO lvalue FROM OPERACCNTRFMETHOD
    WHERE orfmrid  =vid AND orfmfid = vfunc AND orfmethod=vmed;
    Return lvalue;
  Else
    SELECT COUNT(*) INTO lret FROM OPERRFMETHOD
     WHERE orfmrid in (select oarrid from operaccntrole where oaroaid = vid)
       AND orfmfid = vfunc AND orfmethod=vmed;
    IF lret>0 THEN
       Return 'Y';
    Else
       Return 'N';
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/


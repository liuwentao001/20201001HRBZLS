CREATE OR REPLACE FUNCTION HRBZLS."FCHKRFMETHOD"
   (Vid IN VARCHAR2,vfunc IN VARCHAR2,vmed IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
  If length(vid) = 2 or length(vid) = 3 Then
    SELECT COUNT(*) INTO lret FROM operrfmethod
    WHERE orfmrid=vid AND orfmfid = vfunc AND orfmethod=vmed;
    IF lret>0 THEN
      lvalue := 'Y';
    ELSE
      lvalue := 'N';
    END IF;
    Return lvalue;
  ELSE
    SELECT COUNT(*) INTO lret FROM operrfmethod
    WHERE orfmrid in (select oarrid from operaccntrole where oaroaid = vid) AND orfmfid = vfunc AND orfmethod=vmed;
    IF lret > 0 THEN
       lvalue := 'Y';
    ELSE
       lvalue := 'N';
    END IF;
    Return lvalue;
  END IF;
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/


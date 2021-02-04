CREATE OR REPLACE FUNCTION HRBZLS."FCHKACCNTROLEFUNC"
   (vid IN VARCHAR2,vcode IN VARCHAR2)
   Return Integer
AS
   lpcode Integer;
   ll_count Integer;
BEGIN
  SELECT count(*) INTO ll_count
    FROM operaccntrolefunc
   WHERE orfoaid =vid AND orffid = vcode;
  If ll_count >= 1 Then
    SELECT decode(orftype,'Y',1,0) INTO lpcode
      FROM operaccntrolefunc
     WHERE orfoaid =vid AND orffid = vcode;
    Return lpcode;
  Else
    SELECT COUNT(*) INTO lpcode
      FROM operrolefunc
     WHERE orfrid in (select oarrid from operaccntrole where oaroaid = vid) AND orffid = vcode;
    If lpcode >= 1 Then
       lpcode := 1;
       Return lpcode;
    Else
       lpcode := 0;
       Return lpcode;
    End If;
  End If;
EXCEPTION WHEN OTHERS THEN
   lpcode := 0;
   Return lpcode;
END;
/


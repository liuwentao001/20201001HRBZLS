CREATE OR REPLACE FUNCTION HRBZLS."FCHKROLEFUNC"
   (vid IN VARCHAR2,vcode IN VARCHAR2)
   Return Integer
AS
   lcount integer;
   lpcode Integer;
BEGIN
   If length(vid) = 2 or length(vid) = 3 Then
     SELECT COUNT(*) INTO lpcode FROM operrolefunc
      WHERE orfrid=vid AND orffid = vcode;
     Return lpcode;
   Else
     select count(oarrid) INTO lcount from operaccntrole where oaroaid = vid;
     If lcount>=1 Then
        SELECT COUNT(*) INTO lpcode FROM operrolefunc
         WHERE orfrid in (select oarrid from operaccntrole where oaroaid = vid) AND orffid = vcode;
        IF lpcode>=1 THEN
         Return 1;
        Else
         Return 0;
        END IF;
     Else
        Return 0;
     END IF;
   END IF;
EXCEPTION WHEN OTHERS THEN
   Return 0;
END;
/


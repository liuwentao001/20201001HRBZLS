CREATE OR REPLACE FUNCTION HRBZLS."FCHKSYSMANARELATION"
   (vsmfid1 IN VARCHAR2,vsmfid2 IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
     SELECT COUNT(*) INTO lret FROM SYSMANARELATION
	   WHERE SMRPKEY=vsmfid1 and SMRFKEY=vsmfid2;
	   IF lret>0 THEN
		    lvalue := 'Y';
	   ELSE
		    lvalue := 'N';
	   END IF;
   Return lvalue;
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/


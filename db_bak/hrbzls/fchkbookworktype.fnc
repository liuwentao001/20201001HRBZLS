CREATE OR REPLACE FUNCTION HRBZLS."FCHKBOOKWORKTYPE"
   (vmfpcode IN VARCHAR2,vbfid IN VARCHAR2,vwtid IN VARCHAR2,voperid IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
     SELECT COUNT(*) INTO lret FROM bookworktype
	   WHERE bwtmfpcode=vmfpcode and bwtbfid=vbfid and bwtwtid=vwtid and bwtoperid=voperid;
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


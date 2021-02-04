CREATE OR REPLACE FUNCTION HRBZLS."FCHKPRICEDETAIL"
   (vid1 IN VARCHAR2,vid2 IN VARCHAR2)
   Return CHAR
AS
   lret    number;
   lvalue  char(1);
BEGIN
     SELECT COUNT(*) INTO lret FROM pricedetail
	   WHERE pdpfid=vid1 and pdpiid=vid2;
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


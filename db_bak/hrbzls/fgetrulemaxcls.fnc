CREATE OR REPLACE FUNCTION HRBZLS."FGETRULEMAXCLS"
   (vruleid IN CHAR)
   Return Number
AS
   lmaxcls NUMBER(2);
BEGIN
	SELECT rulemaxcls INTO lmaxcls
	  FROM PUBRULE WHERE ruleid=vruleid;
   Return lmaxcls;
EXCEPTION WHEN OTHERS THEN
	lmaxcls := 3;
   Return lmaxcls;
END;
/


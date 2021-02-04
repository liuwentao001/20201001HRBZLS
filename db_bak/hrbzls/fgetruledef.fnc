CREATE OR REPLACE FUNCTION HRBZLS."FGETRULEDEF"
   (vruleid IN CHAR)
   Return VARCHAR2
AS
   ldef VARCHAR2(40);
BEGIN
	SELECT ruledef INTO ldef
	  FROM PUBRULE WHERE ruleid=vruleid;
   Return ldef;
EXCEPTION WHEN OTHERS THEN
	ldef := '';
   Return ldef;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FSEEOPERACCNTROLE"
   (Vid IN VARCHAR2)
   Return CHAR
AS
   lvalue  VARCHAR2(23);
BEGIN
  SELECT orname||'...'  INTO lvalue
  FROM (select oarrid from operaccntrole where oaroaid=Vid),operrole
  WHERE oarrid =orid and rownum<=1;
  Return lvalue;
EXCEPTION WHEN OTHERS THEN
   Return 'нч';
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FSYSMETERSTATUS"
   (Vid IN VARCHAR2)
   Return CHAR
AS
   lvalue  char(1);
BEGIN
  lvalue := 'N';
  SELECT t.smsmemo INTO lvalue FROM sysmeterstatus t
  WHERE t.smsid   =vid;
  Return lvalue;
EXCEPTION WHEN OTHERS THEN
   Return 'N';
END;
/


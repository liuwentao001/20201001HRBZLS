CREATE OR REPLACE FUNCTION HRBZLS."FGETPAYNAME" (p_code in varchar2)
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
BEGIN
   SELECT ciname
     INTO lret
     FROM custinfo
    WHERE cicode  = p_code;
   Return lret;
exception when others then
   return p_code;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERLOGID"
	RETURN VARCHAR2
AS
	lid    VARCHAR2(8);
BEGIN
   SELECT RTRIM(LTRIM(TO_CHAR(seq_operlogid.NEXTVAL,'00000000')))
      INTO lid
     FROM dual;
   Return lid;
exception when others then
   return null;
END;
/


CREATE OR REPLACE FUNCTION HRBZLS."FSYSPARA" (P_SPID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(4000);
BEGIN
 SELECT SPVALUE
 INTO LRET
 FROM SYSPARA
 WHERE SPID = P_SPID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

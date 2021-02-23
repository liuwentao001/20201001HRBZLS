CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSMANAPARA" (P_SMPID IN VARCHAR2,p_smppid  in varchar2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(40);
BEGIN
 SELECT SMPPVALUE
 INTO LRET
 FROM sysmanapara
 WHERE smpid  = P_SMPID and smppid =p_smppid ;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

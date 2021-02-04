CREATE OR REPLACE FUNCTION HRBZLS."FBCODE2SMFID" (P_BCODE IN VARCHAR2)
  RETURN VARCHAR2
AS
  result varchar2(10);
BEGIN
  select smfid
  into result
  from sysmanaframe,sysmanapara
  where smppid='BCODE' and
        smfflag='Y' and
        substr(smfid,1,2)='03' and
        smfid=smpid and
        smppvalue=P_BCODE;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN P_BCODE;
END;
/


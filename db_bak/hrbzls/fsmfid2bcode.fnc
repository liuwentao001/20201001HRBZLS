CREATE OR REPLACE FUNCTION HRBZLS."FSMFID2BCODE" (P_smfid IN VARCHAR2)
  RETURN VARCHAR2
AS
  result varchar2(10);
BEGIN
  select smppvalue
  into result
  from sysmanaframe,sysmanapara
  where smppid='BCODE' and
        smfflag='Y' and
        substr(smfid,1,2)='03' and
        smfid=smpid and
        smfid=P_smfid;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN P_smfid;
END;
/


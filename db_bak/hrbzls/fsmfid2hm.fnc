CREATE OR REPLACE FUNCTION HRBZLS."FSMFID2HM" (P_SMFID IN VARCHAR2)
  RETURN VARCHAR2
AS
  result varchar2(100);
BEGIN
  select smppvalue
  into result
  from sysmanaframe,sysmanapara
  where smppid='YHHM' and
        smfflag='Y' and fsysmanajcbm(smfid,1)='05' and
        smfid=smpid and
        smfid=P_SMFID;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN P_SMFID;
END;
/


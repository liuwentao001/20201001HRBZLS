CREATE OR REPLACE FUNCTION HRBZLS."FTSHHHM2SMFID" (P_HH IN VARCHAR2,P_HM IN VARCHAR2)
  RETURN VARCHAR2
AS
  result varchar2(10);
BEGIN
  select smfid
  into result
  from sysmanaframe,sysmanapara smp1,sysmanapara smp2
  where smp1.smppid='YHHH' and smp2.smppid='YHHM' and
        smfflag='Y' and fsysmanajcbm(smfid,1)='04' and
        smfid=smp1.smpid and smfid=smp2.smpid and
        smp1.smppvalue=P_HH and smp2.smppvalue=P_HM;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
/


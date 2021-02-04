CREATE OR REPLACE FUNCTION HRBZLS."FHH2HM" (P_HH IN VARCHAR2)
  RETURN VARCHAR2
AS
  result varchar2(64);
BEGIN
  select smp2.smppvalue
  into result
  from sysmanaframe,sysmanapara smp1,sysmanapara smp2
  where smp1.smppid='YHHH' and smp2.smppid='YHHM' and
        smfflag='Y' and fsysmanajcbm(smfid,1)='05' and
        smfid=smp1.smpid and smfid=smp2.smpid and
        smp1.smppvalue=P_HH;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
/


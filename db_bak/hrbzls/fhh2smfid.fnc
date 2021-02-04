CREATE OR REPLACE FUNCTION HRBZLS."FHH2SMFID" (P_HH IN VARCHAR2)--期初数据迁移时使用
  RETURN VARCHAR2
AS
  result varchar2(10);
BEGIN
  select smfid
  into result
  from sysmanaframe,sysmanapara smp1
  where smp1.smppid='YHHH' and
        smfflag='Y' and fsysmanajcbm(smfid,1)='05' and
        smfid=smp1.smpid and
        smp1.smppvalue=P_HH;

  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
/


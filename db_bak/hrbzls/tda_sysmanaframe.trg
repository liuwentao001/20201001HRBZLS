CREATE OR REPLACE TRIGGER HRBZLS."TDA_SYSMANAFRAME" AFTER DELETE
ON SYSMANAFRAME FOR EACH ROW
DECLARE
  INTEGRITY_ERROR  EXCEPTION;
  ERRNO            INTEGER;
  ERRMSG           CHAR(200);
  DUMMY            INTEGER;
  FOUND            BOOLEAN;
  vyhhh varchar2(2000);
  vyhhm varchar2(2000);
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  INTEGRITYPACKAGE.NEXTNESTLEVEL;

  --业务规则：（武汉需求，适用于标准版）
  --1、允许管理员不受约束的删除托收用户开户行架构节点（删除后将不会生成托收批次）
  --2、对于用户托收信息的处理：保留原行号行名，并添加删除日志，备业务人员查询时的理解，及时发起变更业务
  if SUBSTR(:OLD.SMFID,1,2)='05' then
    begin
    select smppvalue into vyhhh from sysmanapara where SMPID = :OLD.SMFID and smppid='YHHH';
    select smppvalue into vyhhm from sysmanapara where SMPID = :OLD.SMFID and smppid='YHHM';
    exception when others then
    null;
    end;
    update METERACCOUNT
       set mabankid=substr('['||vyhhh||']'||vyhhm||'(已于'||to_char(sysdate,'yymmdd')||'被删除)',1,30)--控制字段长度
     where mabankid=:OLD.SMFID;
  end if;

  --  DELETE ALL CHILDREN IN "SYSMANAPARA"
  DELETE SYSMANAPARA WHERE SMPID = :OLD.SMFID;
  DELETE SYSMANARELATION WHERE SMRPKEY=:OLD.SMFID OR SMRFKEY=:OLD.SMFID;
  DELETE APPLYCHARGEITEMLIST WHERE ACILMFPCODE=:OLD.SMFID;

  INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

--  ERRORS HANDLING
EXCEPTION WHEN INTEGRITY_ERROR THEN
  BEGIN
  INTEGRITYPACKAGE.INITNESTLEVEL;
  RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
  END;
END;
/


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

  --ҵ����򣺣��人���������ڱ�׼�棩
  --1���������Ա����Լ����ɾ�������û������мܹ��ڵ㣨ɾ���󽫲��������������Σ�
  --2�������û�������Ϣ�Ĵ�������ԭ�к������������ɾ����־����ҵ����Ա��ѯʱ����⣬��ʱ������ҵ��
  if SUBSTR(:OLD.SMFID,1,2)='05' then
    begin
    select smppvalue into vyhhh from sysmanapara where SMPID = :OLD.SMFID and smppid='YHHH';
    select smppvalue into vyhhm from sysmanapara where SMPID = :OLD.SMFID and smppid='YHHM';
    exception when others then
    null;
    end;
    update METERACCOUNT
       set mabankid=substr('['||vyhhh||']'||vyhhm||'(����'||to_char(sysdate,'yymmdd')||'��ɾ��)',1,30)--�����ֶγ���
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


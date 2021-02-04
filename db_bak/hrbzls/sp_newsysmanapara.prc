CREATE OR REPLACE PROCEDURE HRBZLS."SP_NEWSYSMANAPARA" (new_smfid IN VARCHAR2)
IS
  INTEGRITY_ERROR  EXCEPTION;
  ERRNO            INTEGER;
  ERRMSG           CHAR(200);

  rsmf sysmanaframe%rowtype;
  v    varchar2(10);
  vcmonth varchar2(7);
BEGIN
NULL;
  select * into rsmf from sysmanaframe where smfid=new_smfid;

  INSERT INTO sysmanapara(smpid, smppid, smppdesc, smppvalue, smpptype)
  select new_smfid, smppid, smppdesc, null, smpptype
  from sysmanapara
  where smpid = (select smfid
                   from sysmanaframe
                  where smfid<>new_smfid
                    and smfpid=rsmf.smfpid
                    and smfclass=rsmf.smfclass
                    and (smftype = rsmf.smftype or (smftype is null and rsmf.smftype is null))
                    and smfstatus='Y'
                    and rownum=1);
    commit;
EXCEPTION WHEN OTHERS THEN
  errno  := -20006;
  errmsg := '管理架构节点参数初始化错误.请联系系统管理员.';
  raise integrity_error;
END sp_newsysmanapara;
/


CREATE OR REPLACE TRIGGER HRBZLS."TUA_RECLIST" AFTER UPDATE
OF RLID,
 RLSMFID,
 RLCID,
 RLMSMFID,
 RLCSMFID,
 RLCSTATUS,
 RLMSFID,
 RLCALIBER,
 RLRTID,
 RLMSTATUS,
 RLMTYPE,
 RLTRANS,
 RLCD,
 RLYSCHARGETYPE,
 RLPAIDFLAG,
 RLREVERSEFLAG
ON RECLIST FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 V_fkfs payment.PPAYWAY%type;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 INTEGRITYPACKAGE.NEXTNESTLEVEL;
 -- MODIFY PARENT CODE OF "RECLIST" FOR ALL CHILDREN IN "recdetail"
 IF (UPDATING('RLID') AND :OLD.RLID != :NEW.RLID) THEN
 UPDATE recdetail
 SET RDID = :NEW.RLID
 WHERE RDID = :OLD.RLID;
 END IF;

 INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

 IF (UPDATING('RLPAIDFLAG') AND :OLD.RLPAIDFLAG != :NEW.RLPAIDFLAG) THEN
 begin
    select PPAYWAY into V_fkfs from payment p where p.pid=:new.rlpid;
  exception
     when others then
       null;
 end;
     update inv_info
      set BATCH =:new.RLPBATCH,
         FLAG =:new.RLPAIDFLAG,
         PID = :new.RLPID,
         FKFS = V_fkfs
      where RLID =:OLD.RLID
       and STATUS='0';
 end if;

 IF (UPDATING('RLREVERSEFLAG') AND :OLD.RLPAIDFLAG != :NEW.RLREVERSEFLAG) THEN
  begin
  select PPAYWAY into V_fkfs from payment p where p.pid=:new.rlpid;
  exception
     when others then
       null;
 end;
     update inv_info
      set
         REVERSEFLAG = :new.RLREVERSEFLAG,
         CZPER =:NEW.RLPAIDPER,
         CZDATE=:NEW.rlpaiddate
      where RLID =:OLD.RLID
       and STATUS='0';
 end if;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 BEGIN
 INTEGRITYPACKAGE.INITNESTLEVEL;
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
 END;
END;
/


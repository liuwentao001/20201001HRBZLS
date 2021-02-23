CREATE OR REPLACE TRIGGER HRBZLS."TUA_WORKSTATION" AFTER UPDATE
OF WSID
ON WORKSTATION FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 INTEGRITYPACKAGE.NEXTNESTLEVEL;
 -- MODIFY PARENT CODE OF "WORKSTATION" FOR ALL CHILDREN IN "WORKPRINTSET"
 IF (UPDATING('WSID') AND :OLD.WSID != :NEW.WSID) THEN
 UPDATE WORKPRINTSET
 SET WPSWSID = :NEW.WSID
 WHERE WPSWSID = :OLD.WSID;
 END IF;

 INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 BEGIN
 INTEGRITYPACKAGE.INITNESTLEVEL;
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
 END;
END;
/

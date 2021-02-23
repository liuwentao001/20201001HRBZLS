CREATE OR REPLACE TRIGGER HRBZLS."TDA_RECLIST" AFTER DELETE
ON RECLIST FOR EACH ROW
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
 -- DELETE ALL CHILDREN IN "recdetail"
 DELETE recdetail
 WHERE RDID = :OLD.RLID;

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

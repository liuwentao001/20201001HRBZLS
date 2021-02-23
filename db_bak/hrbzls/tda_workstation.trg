CREATE OR REPLACE TRIGGER HRBZLS."TDA_WORKSTATION" AFTER DELETE
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

 DELETE DYNDWPRINT
 WHERE (DYDPID, DYDPTYPE) IN
 (SELECT WPSPTHID,WPSITID  FROM WORKPRINTSET  WHERE  WPSWSID = :OLD.WSID) ;
 DELETE PRINTTEMPLATEHD
 WHERE  (PTHID,PTHITID)
 IN (SELECT WPSPTHID,WPSITID  FROM WORKPRINTSET  WHERE  WPSWSID = :OLD.WSID) ;


 -- DELETE ALL CHILDREN IN "WORKPRINTSET"
 DELETE WORKPRINTSET
 WHERE WPSWSID = :OLD.WSID;

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

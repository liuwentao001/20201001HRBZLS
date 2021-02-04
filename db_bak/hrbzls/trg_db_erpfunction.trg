CREATE OR REPLACE TRIGGER HRBZLS."TRG_DB_ERPFUNCTION" before DELETE
ON ERPFUNCTION FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;

BEGIN
if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    DELETE ERPFUNDOC
    WHERE  EDEFID = :OLD.EFID;
    DELETE erpfunctionpara
    WHERE  EFID = :OLD.EFID;

END;
/


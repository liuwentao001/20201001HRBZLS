CREATE OR REPLACE TRIGGER HRBZLS."TRG_IA_ERPFUNCTION" after insert
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
    INSERT INTO ERPFUNDOC (EDEFID) VALUES(:NEW.EFID);

END;
/


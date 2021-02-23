CREATE OR REPLACE TRIGGER HRBZLS."TIB_OPERACCNTROLEFUNC" BEFORE INSERT
ON OPERACCNTROLEFUNC FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "ERPFUNCTION"
 CURSOR CPK1_OPERACCNTROLEFUNC(VAR_ORFFID VARCHAR) IS
 SELECT 1
 FROM ERPFUNCTION
 WHERE EFID = VAR_ORFFID
 AND VAR_ORFFID IS NOT NULL;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OPERACCNT"
 CURSOR CPK2_OPERACCNTROLEFUNC(VAR_ORFOAID VARCHAR) IS
 SELECT 1
 FROM OPERACCNT
 WHERE OAID = VAR_ORFOAID
 AND VAR_ORFOAID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- PARENT "ERPFUNCTION" MUST EXIST WHEN INSERTING A CHILD IN "OPERACCNTROLEFUNC"
 IF :NEW.ORFFID IS NOT NULL THEN
 OPEN CPK1_OPERACCNTROLEFUNC(:NEW.ORFFID);
 FETCH CPK1_OPERACCNTROLEFUNC INTO DUMMY;
 FOUND := CPK1_OPERACCNTROLEFUNC%FOUND;
 close CPK1_OPERACCNTROLEFUNC;
 if not found then
 errno := -20002;
 errmsg := 'PARENT DOES NOT EXIST IN "ERPFUNCTION". CANNOT CREATE CHILD IN "OPERACCNTROLEFUNC".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "OPERACCNT" must exist when inserting a child in "OPERACCNTROLEFUNC"
 if :new.ORFOAID is not null then
 open CPK2_OPERACCNTROLEFUNC(:new.ORFOAID);
 fetch CPK2_OPERACCNTROLEFUNC into dummy;
 found := CPK2_OPERACCNTROLEFUNC%FOUND;
 CLOSE CPK2_OPERACCNTROLEFUNC;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OPERACCNT". CANNOT CREATE CHILD IN "OPERACCNTROLEFUNC".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

CREATE OR REPLACE TRIGGER HRBZLS."TUB_MACHINETYPE" BEFORE UPDATE
OF MTID
ON MACHINETYPE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "MACHINELIST"
 CURSOR CFK1_MACHINELIST(VAR_MTID VARCHAR) IS
 SELECT 1
 FROM MACHINELIST
 WHERE MLMACHINETYPE = VAR_MTID
 AND VAR_MTID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "MACHINETYPE" IF CHILDREN STILL EXIST IN "MACHINELIST"
 IF (UPDATING('MTID') AND :OLD.MTID != :NEW.MTID) THEN
 OPEN CFK1_MACHINELIST(:OLD.MTID);
 FETCH CFK1_MACHINELIST INTO DUMMY;
 FOUND := CFK1_MACHINELIST%FOUND;
 CLOSE CFK1_MACHINELIST;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "MACHINELIST". CANNOT MODIFY PARENT CODE IN "MACHINETYPE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

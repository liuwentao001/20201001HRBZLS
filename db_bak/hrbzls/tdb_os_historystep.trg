CREATE OR REPLACE TRIGGER HRBZLS."TDB_OS_HISTORYSTEP" BEFORE DELETE
ON OS_HISTORYSTEP FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "OS_CURRENTSTEP_PREV"
 CURSOR CFK1_OS_CURRENTSTEP_PREV(VAR_ID NUMBER) IS
 SELECT 1
 FROM OS_CURRENTSTEP_PREV
 WHERE PREVIOUS_ID = VAR_ID
 AND VAR_ID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "OS_HISTORYSTEP_PREV"
 CURSOR CFK2_OS_HISTORYSTEP_PREV(VAR_ID NUMBER) IS
 SELECT 1
 FROM OS_HISTORYSTEP_PREV
 WHERE ID = VAR_ID
 AND VAR_ID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "OS_HISTORYSTEP_PREV"
 CURSOR CFK3_OS_HISTORYSTEP_PREV(VAR_ID NUMBER) IS
 SELECT 1
 FROM OS_HISTORYSTEP_PREV
 WHERE PREVIOUS_ID = VAR_ID
 AND VAR_ID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "OS_HISTORYSTEP" IF CHILDREN STILL EXIST IN "OS_CURRENTSTEP_PREV"
 OPEN CFK1_OS_CURRENTSTEP_PREV(:OLD.ID);
 FETCH CFK1_OS_CURRENTSTEP_PREV INTO DUMMY;
 FOUND := CFK1_OS_CURRENTSTEP_PREV%FOUND;
 close CFK1_OS_CURRENTSTEP_PREV;
 if found then
 errno := -20006;
 errmsg := 'CHILDREN STILL EXIST IN "OS_CURRENTSTEP_PREV". CANNOT DELETE PARENT "OS_HISTORYSTEP".';
 raise integrity_error;
 end if;

 -- Cannot delete parent "OS_HISTORYSTEP" if children still exist in "OS_HISTORYSTEP_PREV"
 open CFK2_OS_HISTORYSTEP_PREV(:old.ID);
 fetch CFK2_OS_HISTORYSTEP_PREV into dummy;
 found := CFK2_OS_HISTORYSTEP_PREV%FOUND;
 CLOSE CFK2_OS_HISTORYSTEP_PREV;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "OS_HISTORYSTEP_PREV". CANNOT DELETE PARENT "OS_HISTORYSTEP".';
 RAISE INTEGRITY_ERROR;
 END IF;

 -- CANNOT DELETE PARENT "OS_HISTORYSTEP" IF CHILDREN STILL EXIST IN "OS_HISTORYSTEP_PREV"
 OPEN CFK3_OS_HISTORYSTEP_PREV(:OLD.ID);
 FETCH CFK3_OS_HISTORYSTEP_PREV INTO DUMMY;
 FOUND := CFK3_OS_HISTORYSTEP_PREV%FOUND;
 CLOSE CFK3_OS_HISTORYSTEP_PREV;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "OS_HISTORYSTEP_PREV". CANNOT DELETE PARENT "OS_HISTORYSTEP".';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

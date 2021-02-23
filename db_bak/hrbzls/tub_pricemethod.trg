CREATE OR REPLACE TRIGGER HRBZLS."TUB_PRICEMETHOD" BEFORE UPDATE
OF PMID
ON PRICEMETHOD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "PRICEDETAIL"
 CURSOR CFK1_PRICEDETAIL(VAR_PMID VARCHAR) IS
 SELECT 1
 FROM PRICEDETAIL
 WHERE PDMETHOD = VAR_PMID
 AND VAR_PMID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECDETAIL"
 CURSOR CFK2_RECDETAIL(VAR_PMID VARCHAR) IS
 SELECT 1
 FROM RECDETAIL
 WHERE RDMETHOD = VAR_PMID
 AND VAR_PMID IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "PRICEMETHOD" IF CHILDREN STILL EXIST IN "PRICEDETAIL"
 IF (UPDATING('PMID') AND :OLD.PMID != :NEW.PMID) THEN
 OPEN CFK1_PRICEDETAIL(:OLD.PMID);
 FETCH CFK1_PRICEDETAIL INTO DUMMY;
 FOUND := CFK1_PRICEDETAIL%FOUND;
 close CFK1_PRICEDETAIL;
 if found then
 errno := -20005;
 errmsg := 'CHILDREN STILL EXIST IN "PRICEDETAIL". CANNOT MODIFY PARENT CODE IN "PRICEMETHOD".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "PRICEMETHOD" if children still exist in "RECDETAIL"
 if (updating('PMID') and :old.PMID != :new.PMID) then
 open CFK2_RECDETAIL(:old.PMID);
 fetch CFK2_RECDETAIL into dummy;
 found := CFK2_RECDETAIL%FOUND;
 CLOSE CFK2_RECDETAIL;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECDETAIL". CANNOT MODIFY PARENT CODE IN "PRICEMETHOD".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

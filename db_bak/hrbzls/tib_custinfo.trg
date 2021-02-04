CREATE OR REPLACE TRIGGER HRBZLS."TIB_CUSTINFO" BEFORE INSERT
ON CUSTINFO FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSCUSTSTATUS"
    CURSOR CPK1_CUSTINFO(VAR_CISTATUS VARCHAR) IS
       SELECT 1
       FROM   SYSCUSTSTATUS
       WHERE  SCSID = VAR_CISTATUS
        AND   VAR_CISTATUS IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
    CURSOR CPK2_CUSTINFO(VAR_CISMFID VARCHAR) IS
       SELECT 1
       FROM   SYSMANAFRAME
       WHERE  SMFID = VAR_CISMFID
        AND   VAR_CISMFID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
    CURSOR CPK3_CUSTINFO(VAR_CISMFID VARCHAR) IS
       SELECT 1
       FROM   SYSMANAFRAME
       WHERE  SMFID = VAR_CISMFID
        AND   VAR_CISMFID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "SYSCUSTSTATUS" MUST EXIST WHEN INSERTING A CHILD IN "CUSTINFO"
    IF :NEW.CISTATUS IS NOT NULL THEN
       OPEN  CPK1_CUSTINFO(:NEW.CISTATUS);
       FETCH CPK1_CUSTINFO INTO DUMMY;
       FOUND := CPK1_CUSTINFO%FOUND;
       close CPK1_CUSTINFO;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "SYSCUSTSTATUS". CANNOT CREATE CHILD IN "CUSTINFO".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "SYSMANAFRAME" must exist when inserting a child in "CUSTINFO"
    if :new.CISMFID is not null then
       open  CPK2_CUSTINFO(:new.CISMFID);
       fetch CPK2_CUSTINFO into dummy;
       found := CPK2_CUSTINFO%FOUND;
       CLOSE CPK2_CUSTINFO;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT CREATE CHILD IN "CUSTINFO".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    --  PARENT "SYSMANAFRAME" MUST EXIST WHEN INSERTING A CHILD IN "CUSTINFO"
    IF :NEW.CISMFID IS NOT NULL THEN
       OPEN  CPK3_CUSTINFO(:NEW.CISMFID);
       FETCH CPK3_CUSTINFO INTO DUMMY;
       FOUND := CPK3_CUSTINFO%FOUND;
       CLOSE CPK3_CUSTINFO;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT CREATE CHILD IN "CUSTINFO".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    if  instr(:new.ciname,CHR(10)) > 0  then
       :new.ciname :=F_CHR10(:new.ciname);
     end if ;
     
      if  instr(:new.ciname2,CHR(10)) > 0  then
       :new.ciname2 :=F_CHR10(:new.ciname2);
     end if ;
      if  instr(:new.ciadr,CHR(10)) > 0  then
       :new.ciadr :=F_CHR10(:new.ciadr);
     end if ;
      if  instr(:new.CITEL1,CHR(10)) > 0  then
       :new.CITEL1 :=F_CHR10(:new.CITEL1);
     end if ;
     
       if  instr(:new.CITEL2,CHR(10)) > 0  then
       :new.CITEL2 :=F_CHR10(:new.CITEL2);
     end if ;
     
            if  instr(:new.CITEL3,CHR(10)) > 0  then
       :new.CITEL3 :=F_CHR10(:new.CITEL3);
     end if ;
     
       if  instr(:new.CICONNECTPER,CHR(10)) > 0  then
       :new.CICONNECTPER :=F_CHR10(:new.CICONNECTPER);
     end if ;
     
            if  instr(:new.CICONNECTTEL,CHR(10)) > 0  then
       :new.CICONNECTTEL :=F_CHR10(:new.CICONNECTTEL);
     end if ;
     
            if  instr(:new.CIMEMO,CHR(10)) > 0  then
       :new.CIMEMO :=F_CHR10(:new.CIMEMO);
     end if ;
 

--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/


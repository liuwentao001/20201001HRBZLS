CREATE OR REPLACE TRIGGER HRBZLS."TUB_ZNJADJUSTLIST" BEFORE UPDATE
OF ZALRLID,
   ZALPIID
ON ZNJADJUSTLIST FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    SEQ NUMBER;
    --  DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "RECLIST"
    CURSOR CPK1_ZNJADJUSTLIST(VAR_ZALRLID VARCHAR) IS
       SELECT 1
       FROM   RECLIST
       WHERE  RLID = VAR_ZALRLID
        AND   VAR_ZALRLID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
    --  PARENT "RECLIST" MUST EXIST WHEN UPDATING A CHILD IN "ZNJADJUSTLIST"
    IF (:NEW.ZALRLID IS NOT NULL) AND (SEQ = 0) THEN
       OPEN  CPK1_ZNJADJUSTLIST(:NEW.ZALRLID);
       FETCH CPK1_ZNJADJUSTLIST INTO DUMMY;
       FOUND := CPK1_ZNJADJUSTLIST%FOUND;
       CLOSE CPK1_ZNJADJUSTLIST;
       IF NOT FOUND THEN
          ERRNO  := -20003;
          ERRMSG := 'PARENT DOES NOT EXIST IN "RECLIST". CANNOT UPDATE CHILD IN "ZNJADJUSTLIST".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

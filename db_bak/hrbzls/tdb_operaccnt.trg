CREATE OR REPLACE TRIGGER HRBZLS."TDB_OPERACCNT" BEFORE DELETE
ON OPERACCNT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "BOOKFRAME"
    CURSOR CFK5_BOOKFRAME(VAR_OAID VARCHAR) IS
       SELECT 1
       FROM   BOOKFRAME
       WHERE  BFRPER = VAR_OAID
        AND   VAR_OAID IS NOT NULL;
     --mrrper meterread
      --mrrper meterreadhis
     --rlrper reclist

    cursor cfk5_meterread(var_oaid varchar) is
           select 1
           from meterread where mrrper=var_oaid and var_oaid is not null;
    cursor cfk5_meterreadhis(var_oaid varchar) is
           select 1
           from meterreadhis where mrrper=var_oaid and var_oaid is not null;
    cursor cfk5_reclist(var_oaid varchar) is
           select 1
           from reclist where rlrper=var_oaid and var_oaid is not null;



BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT DELETE PARENT "OPERACCNT" IF CHILDREN STILL EXIST IN "BOOKFRAME"
    OPEN  CFK5_BOOKFRAME(:OLD.OAID);
    FETCH CFK5_BOOKFRAME INTO DUMMY;
    FOUND := CFK5_BOOKFRAME%FOUND;
    CLOSE CFK5_BOOKFRAME;
    IF FOUND THEN
       ERRNO  := -20006;
       ERRMSG := 'CHILDREN STILL EXIST IN "BOOKFRAME". CANNOT DELETE PARENT "OPERACCNT".';
       RAISE INTEGRITY_ERROR;
    END IF;

    open cfk5_meterread(:old.oaid);
    fetch cfk5_meterread into dummy;
    found :=cfk5_meterread%found;
    if found then
      errno:=-20006;
      errmsg:='CHILDREN STILL EXIST IN ''METERREAD''. CANNOT DELETE PARENT ''OPERACCNT'' ';
      raise INTEGRITY_ERROR;
    end if;

    open cfk5_meterreadhis(:old.oaid);
    fetch cfk5_meterreadhis into dummy;
    found:=cfk5_meterreadhis%found;
    if found then
      errno:=-20006;
      errmsg:='CHILDREN STILL EXIST IN ''METERREADHIS''. CANNOT DELETE PARENT ''OPERACCNT'' ';
      raise INTEGRITY_ERROR;
    end if;

    open cfk5_reclist(:old.oaid);
    fetch cfk5_reclist into dummy;
    found:=cfk5_reclist%found;
    if found then
      errno:=-20006;
      errmsg:='CHILDREN STILL EXIST IN ''RECLIST''. CANNOT DELETE PARENT ''OPERACCNT'' ';
      raise INTEGRITY_ERROR;
    end if;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/


CREATE OR REPLACE TRIGGER HRBZLS."TIB_METERREAD" BEFORE INSERT
ON METERREAD FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "BOOKFRAME"
    CURSOR CPK1_METERREAD(VAR_MRBFID VARCHAR) IS
       SELECT 1
       FROM   BOOKFRAME
       WHERE  BFID = VAR_MRBFID
        AND   VAR_MRBFID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERFACE"
    CURSOR CPK2_METERREAD(VAR_MRFACE VARCHAR) IS
       SELECT 1
       FROM   METERFACE
       WHERE  MFID = VAR_MRFACE
        AND   VAR_MRFACE IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "MACHINEIOLOG"
    CURSOR CPK3_METERREAD(VAR_MROUTID VARCHAR) IS
       SELECT 1
       FROM   MACHINEIOLOG
       WHERE  MILID = VAR_MROUTID
        AND   VAR_MROUTID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
    CURSOR CPK4_METERREAD(VAR_MRSMFID VARCHAR) IS
       SELECT 1
       FROM   SYSMANAFRAME
       WHERE  SMFID = VAR_MRSMFID
        AND   VAR_MRSMFID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "READPRICE"
    CURSOR CPK5_METERREAD(VAR_MRRPID VARCHAR) IS
       SELECT 1
       FROM   READPRICE
       WHERE  RPID = VAR_MRRPID
        AND   VAR_MRRPID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERINFO"
    CURSOR CPK6_METERREAD(VAR_MRMPID VARCHAR) IS
       SELECT 1
       FROM   METERINFO
       WHERE  MICODE = VAR_MRMPID
        AND   VAR_MRMPID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERINFO"
    CURSOR CPK7_METERREAD(VAR_MRMID VARCHAR) IS
       SELECT 1
       FROM   METERINFO
       WHERE  MIID = VAR_MRMID
        AND   VAR_MRMID IS NOT NULL; 
    
    CURSOR CPK8_SYSMANAPARA(VAR_SMPID SYSMANAPARA.SMPID%TYPE ,VAR_MONTH VARCHAR) IS 
    select 1
  from SYSMANAPARA
 WHERE smpid = VAR_SMPID
   and SMPPID = '000005'
   AND  to_char(Add_months(to_date(substrb(smppvalue, 1, 4) ||
                                  substrb(smppvalue, 6, 2),
                                  'yyyymm'),
                          1),
               'yyyy.mm') >= VAR_MONTH;
  
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "BOOKFRAME" MUST EXIST WHEN INSERTING A CHILD IN "METERREAD"
    IF :NEW.MRBFID IS NOT NULL THEN
       OPEN  CPK1_METERREAD(:NEW.MRBFID);
       FETCH CPK1_METERREAD INTO DUMMY;
       FOUND := CPK1_METERREAD%FOUND;
       close CPK1_METERREAD;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "BOOKFRAME". CANNOT CREATE CHILD IN "METERREAD".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "METERFACE" must exist when inserting a child in "METERREAD"
    if :new.MRFACE is not null then
       open  CPK2_METERREAD(:new.MRFACE);
       fetch CPK2_METERREAD into dummy;
       found := CPK2_METERREAD%FOUND;
       CLOSE CPK2_METERREAD;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "METERFACE". CANNOT CREATE CHILD IN "METERREAD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    --  PARENT "MACHINEIOLOG" MUST EXIST WHEN INSERTING A CHILD IN "METERREAD"
    IF :NEW.MROUTID IS NOT NULL THEN
       OPEN  CPK3_METERREAD(:NEW.MROUTID);
       FETCH CPK3_METERREAD INTO DUMMY;
       FOUND := CPK3_METERREAD%FOUND;
       close CPK3_METERREAD;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "MACHINEIOLOG". CANNOT CREATE CHILD IN "METERREAD".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "SYSMANAFRAME" must exist when inserting a child in "METERREAD"
    if :new.MRSMFID is not null then
       open  CPK4_METERREAD(:new.MRSMFID);
       fetch CPK4_METERREAD into dummy;
       found := CPK4_METERREAD%FOUND;
       CLOSE CPK4_METERREAD;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT CREATE CHILD IN "METERREAD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    --  PARENT "READPRICE" MUST EXIST WHEN INSERTING A CHILD IN "METERREAD"
    IF :NEW.MRRPID IS NOT NULL THEN
       OPEN  CPK5_METERREAD(:NEW.MRRPID);
       FETCH CPK5_METERREAD INTO DUMMY;
       FOUND := CPK5_METERREAD%FOUND;
       close CPK5_METERREAD;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "READPRICE". CANNOT CREATE CHILD IN "METERREAD".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "METERINFO" must exist when inserting a child in "METERREAD"
    if :new.MRMPID is not null then
       open  CPK6_METERREAD(:new.MRMPID);
       fetch CPK6_METERREAD into dummy;
       found := CPK6_METERREAD%FOUND;
       CLOSE CPK6_METERREAD;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "METERINFO". CANNOT CREATE CHILD IN "METERREAD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    --  PARENT "METERINFO" MUST EXIST WHEN INSERTING A CHILD IN "METERREAD"
    IF :NEW.MRMID IS NOT NULL THEN
       OPEN  CPK7_METERREAD(:NEW.MRMID);
       FETCH CPK7_METERREAD INTO DUMMY;
       FOUND := CPK7_METERREAD%FOUND;
       CLOSE CPK7_METERREAD;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "METERINFO". CANNOT CREATE CHILD IN "METERREAD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;
   
  --20140819���ӣ���ǰ�����ⲻ�������ڴ���ϵͳ�趨�ĳ����·�����
     OPEN  CPK8_SYSMANAPARA(:NEW.MRSMFID, :NEW.MRMONTH);
     FETCH CPK8_SYSMANAPARA INTO DUMMY;
     FOUND := CPK8_SYSMANAPARA%FOUND;
     CLOSE CPK8_SYSMANAPARA;
     IF NOT FOUND THEN
        ERRNO  := -20002;
        ERRMSG := '����������������,��ǰ�������ϳ����·���ϵͳSYSMANAPARA�趨�·ݲ�һ��,��ȷ��';
        RAISE INTEGRITY_ERROR;
     END IF;

--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

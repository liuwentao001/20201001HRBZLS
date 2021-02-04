CREATE OR REPLACE TRIGGER HRBZLS."TIB_PRICEFRAME" BEFORE INSERT
ON PRICEFRAME FOR EACH ROW
DECLARE
  INTEGRITY_ERROR EXCEPTION;
  ERRNO  INTEGER;
  ERRMSG CHAR(200);
  DUMMY  INTEGER;
  FOUND  BOOLEAN;
  --PPS    PRICE_PROP%ROWTYPE;
  --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
  CURSOR CPK1_PRICEFRAME(VAR_PFSMFID VARCHAR) IS
    SELECT 1
      FROM SYSMANAFRAME
     WHERE SMFID = VAR_PFSMFID
       AND VAR_PFSMFID IS NOT NULL;
  /*CURSOR CPK2_PRICEFRAME(VAR_WATERTYPE VARCHAR) IS
    SELECT 1 FROM PRICE_PROP WHERE WATERTYPE = VAR_WATERTYPE;*/

BEGIN
  if nvl(fsyspara('data'), 'N') = 'Y' then
    return;
  end if;
  --  PARENT "SYSMANAFRAME" MUST EXIST WHEN INSERTING A CHILD IN "PRICEFRAME"
  IF :NEW.PFSMFID IS NOT NULL THEN
    OPEN CPK1_PRICEFRAME(:NEW.PFSMFID);
    FETCH CPK1_PRICEFRAME
      INTO DUMMY;
    FOUND := CPK1_PRICEFRAME%FOUND;
    CLOSE CPK1_PRICEFRAME;
    IF NOT FOUND THEN
      ERRNO  := -20002;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT CREATE CHILD IN "PRICEFRAME".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;
 /* IF :NEW.PFID IS NOT NULL THEN
    OPEN CPK2_PRICEFRAME(:NEW.PFID);
    FETCH CPK2_PRICEFRAME
      INTO DUMMY;
    FOUND := CPK2_PRICEFRAME%FOUND;
    CLOSE CPK2_PRICEFRAME;
    IF FOUND THEN
      ERRNO  := -20099;
      ERRMSG := 'PARENT DOES  EXIST IN "PRICE_drop". CANNOT CREATE .';
      RAISE INTEGRITY_ERROR;
    ELSE
      PPS.WATERTYPE   := :NEW.PFID;
      pps.watertype_b := :new.pfpid;
      pps.watertype_m := :new.pfid;
      pps.p0          := :new.pfprice;
      pps.s1 := case
                  when substr(:NEW.PFID, 1, 1) = 'A' THEN
                   '正常用水'
                  when substr(:NEW.PFID, 1, 1) = 'B' then
                   '企事业'
                  when substr(:NEW.PFID, 1, 1) = 'C' then
                   '商服业'
                  when substr(:NEW.PFID, 1, 1) = 'D' then
                   '宾馆餐饮'
                  when substr(:NEW.PFID, 1, 1) = 'E' then
                   '其它非居民'
                  when substr(:NEW.PFID, 1, 1) = 'F' then
                   '特业2'
                END;
      pps.s2 := case
                  when substr(:NEW.PFID, 1, 1) = 'A' THEN
                   '居民'
                  when substr(:NEW.PFID, 1, 1) IN ('E', 'F') then
                   '特业'
                  ELSE
                   '非居民'
                END;
      pps.p1          := 0;
      pps.p2          := 0;
      pps.p3          := 0;
      pps.p6          := 0;
      pps.p7          := 0;
      pps.p8          := 0;
      pps.p9          := 0;
      pps.p10         := 0;
      pps.p11         := 0;
      pps.p12         := 0;
      pps.p13         := 0;
      pps.p14         := 0;
      pps.p15         := 0;
      pps.p16         := 0;
      select pddj
        into pps.p4
        from pricedetail
       where pdpfid = :NEW.PFID
         and pdpiid = '01'; --水费
      select pddj
        into pps.p4
        from pricedetail
       where pdpfid = :NEW.PFID
         and pdpiid = '02'; --污水费
       insert into PRICE_PROP_SAMPLE values pps;
       pps.s1:=null;
       pps.s2:=null;
       insert into PRICE_PROP values pps;
       commit;
    END IF;
  END IF;*/
  --  ERRORS HANDLING
EXCEPTION
  WHEN INTEGRITY_ERROR THEN
    RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/


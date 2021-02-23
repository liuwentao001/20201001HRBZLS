CREATE OR REPLACE TRIGGER HRBZLS."tbi_st_meter_type" BEFORE INSERT
ON st_meter_type FOR EACH ROW

BEGIN
 IF :NEW.id IS NULL THEN
      SELECT  SEQ_ST_METER_TYPE.NEXTVAL  INTO :new.id from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/

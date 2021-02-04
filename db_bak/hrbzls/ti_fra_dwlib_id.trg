CREATE OR REPLACE TRIGGER HRBZLS."TI_fra_dwlib_id" BEFORE INSERT
ON fra_dwlib FOR EACH ROW
BEGIN
 IF :NEW.id IS NULL THEN
      SELECT  fgetsequence('FRA_SRD') INTO :new.id from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/


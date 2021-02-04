CREATE OR REPLACE TRIGGER HRBZLS."pbparmtemp_test" BEFORE INSERT
ON pbparmtemp_test FOR EACH ROW

BEGIN
 IF :NEW.C1 IS NULL THEN
      SELECT  fgetsequence('KPI_DEFINE') INTO :new.c1 from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/


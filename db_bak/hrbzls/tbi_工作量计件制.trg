CREATE OR REPLACE TRIGGER HRBZLS."TBI_�������Ƽ���" BEFORE INSERT
ON �������Ƽ��� FOR EACH ROW

BEGIN
 IF :NEW.ID IS NULL THEN
      SELECT  seq_�������Ƽ���.nextval INTO :new.ID from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/


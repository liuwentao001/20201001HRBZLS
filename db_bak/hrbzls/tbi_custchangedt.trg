CREATE OR REPLACE TRIGGER HRBZLS."TBI_CUSTCHANGEDT"
  BEFORE INSERT or update ON CUSTCHANGEDT
  FOR EACH ROW
DECLARE

BEGIN
  --解决批量赋值立户转预立户时未触发事件导致用户状态与水表状态不一致的问题
  --只有立户和预立户转化时触发赋值
/*  IF :NEW.CISTATUS<>:NEW.MISTATUS THEN
    IF :NEW.CISTATUS IN ('1','2') AND :NEW.MISTATUS IN ('1','2')  AND :NEW.CISTATUS<>:NEW.MISTATUS THEN
      :NEW.MISTATUS := :NEW.CISTATUS;
    END IF;
  END IF;*/
 if inserting then
       if :new.miyl4 is not null then
         :new.miyl4 :=substrb(:new.miyl4,1,20);
       end if ;
      --临时解决免抄户维护后是否计费标志为空的问题
      IF :NEW.MIIFCHARGE IS NULL THEN
        SELECT MIIFCHARGE
          INTO :NEW.MIIFCHARGE
          FROM METERINFO
         WHERE MIID = :NEW.MIID;
      END IF;
      --临时解决免抄户维护后开户名空的问题（前台注释了取值，取值时批量模式会报错）
      IF :NEW.MAACCOUNTNAME IS NULL THEN
        SELECT MAACCOUNTNAME
          INTO :NEW.MAACCOUNTNAME
          FROM METERACCOUNT
         WHERE MAMID = :NEW.MIID;
      END IF;
        --临时解决免抄户维护后用户性质为空的问题
      IF :NEW.MICOLUMN4 IS NULL THEN
        SELECT MICOLUMN4
          INTO :NEW.MICOLUMN4
          FROM METERINFO
         WHERE MIID = :NEW.MIID;
      END IF; 
  end if ;
END;
/


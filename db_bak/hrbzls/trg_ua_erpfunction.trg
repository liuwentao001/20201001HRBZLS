CREATE OR REPLACE TRIGGER HRBZLS."Trg_uA_ERPFUNCTION" AFTER update
ON ERPFUNCTION FOR EACH ROW
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    if updating('EFNAME')  THEN
      UPDATE erpfunctionpara T SET T.EFNAME=:NEW.EFNAME WHERE T.EFID=:OLD.EFID ;
    END IF;
END;
/


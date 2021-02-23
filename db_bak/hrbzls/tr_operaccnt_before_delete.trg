CREATE OR REPLACE TRIGGER HRBZLS."TR_OPERACCNT_BEFORE_DELETE" BEFORE DELETE
  ON OPERACCNT
  FOR EACH ROW

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  DELETE FROM OPERACCNTPARA
   WHERE OAPOAID=:OLD.oaid ;
END;
/

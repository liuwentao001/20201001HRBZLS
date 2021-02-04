CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_DAILYREC"
  before insert on HIS_DAILYrec
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_DAILYrec.NEXTVAL INTO :NEW.drid FROM DUAL;

end TIB_HIS_DAILYrec;
/


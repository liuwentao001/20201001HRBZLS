CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_MONTHLYREC"
  before insert on HIS_MONTHLYrec
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_MONTHLYrec.NEXTVAL INTO :NEW.mrid FROM DUAL;

end TIB_HIS_MONTHLYrec;
/


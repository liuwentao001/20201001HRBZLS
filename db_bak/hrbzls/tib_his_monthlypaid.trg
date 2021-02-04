CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_MONTHLYPAID"
  before insert on HIS_MONTHLYpaid
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_MONTHLYpaid.NEXTVAL INTO :NEW.mpid FROM DUAL;

end TIB_HIS_MONTHLYpaid;
/


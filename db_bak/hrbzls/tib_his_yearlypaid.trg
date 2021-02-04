CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_YEARLYPAID"
  before insert on HIS_YEARLYpaid
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_YEARLYpaid.NEXTVAL INTO :NEW.ypid FROM DUAL;

end TIB_HIS_YEARLYpaid;
/


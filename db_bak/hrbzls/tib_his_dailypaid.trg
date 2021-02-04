CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_DAILYPAID"
  before insert on HIS_DAILYpaid
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_DAILYpaid.NEXTVAL INTO :NEW.dpid FROM DUAL;

end TIB_HIS_DAILYpaid;
/


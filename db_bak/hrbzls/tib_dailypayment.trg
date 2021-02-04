CREATE OR REPLACE TRIGGER HRBZLS."TIB_DAILYPAYMENT"
  before insert on dailypayment
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT    lpad(SEQ_DailyPayment.Nextval,10,'0')   INTO   :NEW.dpid   FROM   DUAL;
end TIB_DAILYPAYMENT;
/


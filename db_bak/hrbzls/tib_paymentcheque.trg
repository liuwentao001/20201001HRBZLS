CREATE OR REPLACE TRIGGER HRBZLS."TIB_PAYMENTCHEQUE"
  before insert on paymentcheque
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT   seq_paymentcheque.nextval    INTO   :NEW.pcid   FROM   DUAL;

end TIB_PAYMENTCHEQUE;
/


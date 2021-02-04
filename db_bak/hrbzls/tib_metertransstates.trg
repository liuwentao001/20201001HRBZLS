CREATE OR REPLACE TRIGGER HRBZLS."TIB_METERTRANSSTATES"
  before insert on metertransstates
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT    lpad(SEQ_METERtransstates.Nextval,10,'0')   INTO   :NEW.mtsid   FROM   DUAL;
end TIB_METERtransstates;
/


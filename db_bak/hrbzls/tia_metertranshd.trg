CREATE OR REPLACE TRIGGER HRBZLS."TIA_METERTRANSHD"
  after insert on metertranshd
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  insert into metertransstates(mtsno,mtsshdate,mtsshflag,mtsshper,mtscredate)
  values(:new.mthno,:new.mthcredate,'N',:new.mthcreper,:new.mthcredate);
end TIA_Metertranshd;
/


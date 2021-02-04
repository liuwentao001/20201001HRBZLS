CREATE OR REPLACE TRIGGER HRBZLS."TIB_HIS_YEARLYREC"
  before insert on HIS_YEARLYrec
  for each row
declare
  -- local variables here
begin
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT SEQ_HIS_YEARLYrec.NEXTVAL INTO :NEW.yrid FROM DUAL;

end TIB_HIS_YEARLYrec;
/


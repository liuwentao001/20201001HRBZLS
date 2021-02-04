CREATE OR REPLACE TRIGGER HRBZLS."TIB_BOOKFRAME_after" after update
ON BOOKFRAME FOR EACH ROW
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 null;
END;
/


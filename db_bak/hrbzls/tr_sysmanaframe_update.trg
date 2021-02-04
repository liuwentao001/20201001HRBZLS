CREATE OR REPLACE TRIGGER HRBZLS."TR_SYSMANAFRAME_UPDATE"
AFTER UPDATE ON   sysmanaframe
FOR EACH ROW




BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  if  :OLD.smfid='1' or :OLD.smfid='2' or
      :OLD.smfid='3' or :OLD.smfid='4' then
     raise_application_error(-20012,'系统管理级次不允许修改');
  end if;
END ;
/


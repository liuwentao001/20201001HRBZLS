CREATE OR REPLACE TRIGGER HRBZLS."TR_SYSMANAFRAME_UPDATE"
AFTER UPDATE ON   sysmanaframe
FOR EACH ROW




BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  if  :OLD.smfid='1' or :OLD.smfid='2' or
      :OLD.smfid='3' or :OLD.smfid='4' then
     raise_application_error(-20012,'ϵͳ�����β������޸�');
  end if;
END ;
/


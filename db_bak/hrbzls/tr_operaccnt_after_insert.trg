CREATE OR REPLACE TRIGGER HRBZLS."TR_OPERACCNT_AFTER_INSERT" AFTER insert
  ON OPERACCNT
  FOR EACH ROW

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  insert into OPERACCNTPARA
  values (
  :new.oaid,
  'INVFRAME',
  'O',
  'Y',
  '��̨��Ʊ'
  );
   insert into OPERACCNTPARA
  values (
  :new.oaid,
  '110',
  '0',
  'Y',
  'ΥԼ�������'
  );
  insert into OPERACCNTPARA
  values (
  :new.oaid,
  '108',
  '0',
  'Y',
  'ˮ���������'
  );
END;
/


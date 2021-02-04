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
  '柜台发票'
  );
   insert into OPERACCNTPARA
  values (
  :new.oaid,
  '110',
  '0',
  'Y',
  '违约审批额度'
  );
  insert into OPERACCNTPARA
  values (
  :new.oaid,
  '108',
  '0',
  'Y',
  '水量调整额度'
  );
END;
/


CREATE OR REPLACE TRIGGER HRBZLS."TRG_SAVING_METERINFO" AFTER UPDATE
OF MISAVING
ON METERINFO FOR EACH ROW
DECLARE
 VCOUNT NUMBER;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  SELECT count(T.PID) INTO VCOUNT  FROM PAYMENT T WHERE T.PID=:NEW.MIPAYMENTID;
  if VCOUNT=0 THEN
      INSERT INTO CHK_RESULT
      VALUES
        (
            SEQ_CHK_LIST.NEXTVAL,
            SYSDATE,
            'Ԥ����',
            '��ʵ�ռ�¼�ı�ˮ��Ԥ�棡',
            '',
            :NEW.MIID,
            '',
            '',
            '�ڳ�:'||to_char(:OLD.MISAVING)||' ��ĩ:'||to_char(:NEW.MISAVING),
             ''
             );
     END IF;
END;
/


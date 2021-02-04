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
            '预存检查',
            '无实收记录改变水表预存！',
            '',
            :NEW.MIID,
            '',
            '',
            '期初:'||to_char(:OLD.MISAVING)||' 期末:'||to_char(:NEW.MISAVING),
             ''
             );
     END IF;
END;
/


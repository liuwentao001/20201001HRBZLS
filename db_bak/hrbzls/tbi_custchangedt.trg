CREATE OR REPLACE TRIGGER HRBZLS."TBI_CUSTCHANGEDT"
  BEFORE INSERT or update ON CUSTCHANGEDT
  FOR EACH ROW
DECLARE

BEGIN
  --���������ֵ����תԤ����ʱδ�����¼������û�״̬��ˮ��״̬��һ�µ�����
  --ֻ��������Ԥ����ת��ʱ������ֵ
/*  IF :NEW.CISTATUS<>:NEW.MISTATUS THEN
    IF :NEW.CISTATUS IN ('1','2') AND :NEW.MISTATUS IN ('1','2')  AND :NEW.CISTATUS<>:NEW.MISTATUS THEN
      :NEW.MISTATUS := :NEW.CISTATUS;
    END IF;
  END IF;*/
 if inserting then
       if :new.miyl4 is not null then
         :new.miyl4 :=substrb(:new.miyl4,1,20);
       end if ;
      --��ʱ����Ⳮ��ά�����Ƿ�Ʒѱ�־Ϊ�յ�����
      IF :NEW.MIIFCHARGE IS NULL THEN
        SELECT MIIFCHARGE
          INTO :NEW.MIIFCHARGE
          FROM METERINFO
         WHERE MIID = :NEW.MIID;
      END IF;
      --��ʱ����Ⳮ��ά���󿪻����յ����⣨ǰ̨ע����ȡֵ��ȡֵʱ����ģʽ�ᱨ��
      IF :NEW.MAACCOUNTNAME IS NULL THEN
        SELECT MAACCOUNTNAME
          INTO :NEW.MAACCOUNTNAME
          FROM METERACCOUNT
         WHERE MAMID = :NEW.MIID;
      END IF;
        --��ʱ����Ⳮ��ά�����û�����Ϊ�յ�����
      IF :NEW.MICOLUMN4 IS NULL THEN
        SELECT MICOLUMN4
          INTO :NEW.MICOLUMN4
          FROM METERINFO
         WHERE MIID = :NEW.MIID;
      END IF; 
  end if ;
END;
/


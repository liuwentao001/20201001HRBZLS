CREATE OR REPLACE PROCEDURE HRBZLS."SP_METERINFO_STORE"(P_QFH     IN VARCHAR2, --Ǧ��
                                                 P_STOREID IN VARCHAR2, --�ֿ���
                                                 P_MIID    IN VARCHAR2, --�û����
                                                 P_CALIBER IN NUMBER, --�ھ�
                                                 P_BRAND   IN VARCHAR2, --Ʒ��
                                                 P_MODEL   IN VARCHAR2, --���ͺ�
                                                 P_STATUS  IN VARCHAR2, -- ��״̬
                                                 P_QSBSM   IN VARCHAR2, --���������
                                                 P_JSBSM   IN VARCHAR2, --������ֹ��
                                                 P_QSR     IN DATE, --�ܼ�������
                                                 P_RKPC    IN VARCHAR2, --�������
                                                 P_RKDH    IN VARCHAR2, --��ⵥ��
                                                 P_ROOMID  IN VARCHAR2, --�ⷿ���
                                                 MSG       OUT VARCHAR2) IS

  V_DO      VARCHAR2(100);
  V_QTY     NUMBER;
  V_ISTRUE1 NUMBER;
  V_ISTRUE2 NUMBER;
  V_ISTRUE3 NUMBER;
  V_SBTH    VARCHAR2(6);
  V_EBTH    VARCHAR2(6);
  V_STR     VARCHAR2(7);
  V_QFH     VARCHAR2(40);
  V_OPER    VARCHAR2(20);
BEGIN
  IF P_CALIBER IS NULL THEN
    MSG := '��ھ�������Ϊ��ֵ!';
    RETURN;
  END IF;

  IF P_QSBSM IS NULL AND P_JSBSM IS NULL THEN
    MSG := '�����������¼����ʼֹ������ţ����������¼���������Ż�ֹ��!';
    RETURN;
  END IF;

  V_OPER := FGETPBOPER;

  V_QTY := TO_NUMBER(P_JSBSM) - TO_NUMBER(P_QSBSM) + 1;

  /*1 һ����
  2 ������
  3 �Ѱ�װ
  4 �ɱ�
  5 ����
  6 ����
  7 ����*/

  IF P_STATUS = '1' THEN
    -- 0���
    V_DO := '���ܿ�';
  
    --��������Ψһ��
    SELECT COUNT(BSM)
      INTO V_ISTRUE1
      FROM ST_METERINFO_STORE
     WHERE STOREID = TRIM(P_STOREID)
       AND BSM >= TRIM(P_QSBSM)
       AND BSM <= TRIM(P_JSBSM);
  
    --���Ǧ���Ψһ��
    SELECT COUNT(QFH)
      INTO V_ISTRUE2
      FROM ST_METERINFO_STORE
     WHERE QFH = TRIM(P_QFH);
    ---------------
    SELECT COUNT(QFH)
      INTO V_ISTRUE3
      FROM ST_METERINFO_STORE
     WHERE TO_NUMBER(QFH) >= TRIM(P_QFH)
       AND TO_NUMBER(QFH) <= TRIM(P_QFH) + V_QTY - 1;
  
    V_QFH := P_QFH;
    --�����Ψһ�����
    IF V_ISTRUE1 = 0 AND V_ISTRUE2 = 0 AND V_ISTRUE3 = 0 THEN
      V_STR  := SUBSTR(P_QSBSM, 1, 7);
      V_SBTH := SUBSTR(P_QSBSM, 8, 6);
      V_EBTH := SUBSTR(P_JSBSM, 8, 6);
      FOR I IN V_SBTH .. V_EBTH LOOP
        INSERT INTO ST_METERINFO_STORE
          (QFH,
           STOREID,
           MIID,
           CALIBER,
           BRAND,
           MODEL,
           STATUS,
           STATUSDATE,
           CYCCHKDATE,
           STOCKDATE,
           BSM,
           RKBATCH,
           RKDNO,
           STOREROOMID,
           RKMAN,
           MAINMAN,
           MAINDATE)
        VALUES
          (V_QFH,
           P_STOREID,
           P_MIID,
           P_CALIBER,
           P_BRAND,
           P_MODEL,
           '1',
           SYSDATE,
           P_QSR,
           SYSDATE,
           V_STR || LPAD(I, 6, '0'),
           P_RKPC,
           P_RKDH,
           P_ROOMID,
           V_OPER,
           V_OPER,
           SYSDATE);
        V_QFH := V_QFH + 1;
      END LOOP;
      --�ж�ÿ���Ƿ���ӳɹ�
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
    commit;
    ELSIF V_ISTRUE1 > 0 THEN
      MSG := '�ñ�����δ��������ܿ�ı����룡';
    ELSIF V_ISTRUE2 > 0 THEN
      MSG := '��Ǧ����Ѵ��ڣ��������룡';
    ELSIF V_ISTRUE3 > 0 THEN
      MSG := '����Ǧ��������д��ڣ��������룡';
    END IF;
  END IF;
 exception 
   when others then
      MSG := 'N';
      rollback;
     return ;
END;
/


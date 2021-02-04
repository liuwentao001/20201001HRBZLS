CREATE OR REPLACE PROCEDURE HRBZLS."SP_CBJPROSSING" (P_OPERTYPE    IN VARCHAR2, --��������
                                           P_OPER        IN VARCHAR2, --����Ա
                                           P_OPERAGENTID IN VARCHAR2, --����Ա����Ӫҵ��
                                           P_BATCH       IN VARCHAR2, --��������
                                           P_MACHINNO    IN VARCHAR2, --��������
                                           P_CMBFIDSTR   IN VARCHAR2, --��ᴮ��ʽ��:'110','002'
                                           P_TYPE        IN VARCHAR2, --��������
                                           P_COMMIT      IN VARCHAR2, --�Ƿ��ύ��־
                                           O_TAIL        OUT VARCHAR2 --������Ϣ
                                           ) AS

  TYPE MY_C IS REF CURSOR;
  C_MR MY_C;

  V_RECMONTH      VARCHAR2(7);
  V_COUNT         NUMBER(10);
  V_TYPE          VARCHAR2(1000);
  V_RET          VARCHAR2(1000);
  V_SQL VARCHAR2(32000);
  INOUTNOXD_ERR EXCEPTION; --001���������뷢�����ݲ���
  OUTHADOUT_ERR EXCEPTION; --002��ѡ��Ҫ�����ĳ��������������ݷ���
  OUTHADSL_ERR EXCEPTION; --003��ѡ��Ҫ����������������ˮ��¼��
  OUTHADJE_ERR EXCEPTION; --004��ѡ��Ҫ����������������ˮ�����
  INHADNO_ERR EXCEPTION; --005���볭������û����Ҫ���µ�����
BEGIN
  /*
  --�������������
  --20090109 BY WY
  --P_OPERTYPE :'01' �������ݵ��뵽�����,
  --02��������ݵ��뵽���ݿ�,03ȡ����������
  --04��鷢����������,05��鵼�볭������
  --O_TAIL '001'���������뷢�����ݲ���,
  --002��ѡ��Ҫ�����ĳ��������������ݷ���,
  --003��ѡ��Ҫ����������������ˮ��¼��
  --004��ѡ��Ҫ����������������ˮ�����
  */
  --���������д��
  V_RECMONTH := TOOLS.FGETRECMONTH(P_OPERAGENTID);
  IF P_OPERTYPE = '01' THEN
    --����ﳭ������ȫ������
    IF P_TYPE = '1' THEN
      V_TYPE := ' AND 1=1 ';
    END IF;
    --����ﳭ������δ������
    IF P_TYPE = '2' THEN
      V_TYPE := ' AND MRREADOK=''N'' ';
    END IF;
    --����ﳭ������δ����+�ѳ���(�ų������)����
    IF P_TYPE = '3' THEN
      V_TYPE := ' AND MRIFREC=''N'' ';
    END IF;

    V_SQL := 'UPDATE METERREAD T SET MROUTDATE=SYSDATE   WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MROUTID IS NULL ' || V_TYPE;
    EXECUTE IMMEDIATE V_SQL;

    /*SELECT COUNT(*)
      INTO V_COUNT
      FROM METERREAD
     WHERE MRMONTH = V_RECMONTH
       AND MROUTID = P_BATCH;
    MRCBJ.MROUTID := P_BATCH; --�������������ˮ��
    MRCBJ.MRCTRL1 := '01'; --������ͺ�
    MRCBJ.MRCTRL3 := P_MACHINNO; --��������
    MRCBJ.MRSMFID := P_OPERAGENTID; --��Ͻ��˾���
    MRCBJ.MRMONTH := V_RECMONTH; --�����·�
    MRCBJ.MRCTRL2 := '1'; --����ģʽ(1��·��2������Ա)
    --MRCBJ.MRCTRL3     := V_COUNT; --��������
    MRCBJ.MROUTDATE     := SYSDATE; --��������
    MRCBJ.MRCTRL4 := P_OPER; --���Ͳ���Ա
    --MRCBJ.MRCBJINDATE        :=       ;     --��������
    --MRCBJ.MRCBJINOPERATOR    :=       ;     --���ղ���Ա
    MRCBJ.MRCTRL5 := '0'; --��������
    --MRCBJ.MRCBJINORDER  := 0; --���ܴ���
    --MRCBJ.MRCBJOPER          :=       ;     --�����¼����Ա(����ʱȷ��)
    MRCBJ.MROUTFLAG  := 'O'; --��������״̬
    --MRCBJ.MRCBJFLAG   := 'Y'; --��Ч��־*/

 V_SQL := 'UPDATE METERREAD
           SET MROUTID =''' ||P_BATCH || ''',
           MRCTRL1 = '''||01||''',
           MROUTFLAG = '''||'Y'||''',
           MRCTRL3 =''' ||P_MACHINNO || ''',
           MRCTRL4 =''' ||P_OPER || ''',
           mrindate = sysdate ,
           MRSMFID =''' ||P_OPERAGENTID || ''',
           MRMONTH =''' ||V_RECMONTH || ''',
           MRCTRL2 = '''||1||''',MROUTDATE = SYSDATE,MRCTRL5 = '''||0||'''
           WHERE MRBFID IN (' || P_CMBFIDSTR ||') and MROUTFLAG = '''||'N'||''''|| V_TYPE;
    EXECUTE IMMEDIATE V_SQL;
    UPDATE METERREAD
    SET MROUTID = P_BATCH,
     MRCTRL1 = '01',
     MRCTRL3 = P_MACHINNO,
     MRSMFID = P_OPERAGENTID,
     MRMONTH = V_RECMONTH,
     MRCTRL2 = '1',
     MROUTDATE = SYSDATE,
     MRCTRL5 = '0'
     WHERE mrbfid in(P_CMBFIDSTR) and MROUTFLAG = 'N';
  END IF;

  --04��鷢����������,05��鵼�볭������,06���ȡ����������
  IF P_OPERTYPE = '04' THEN
    V_SQL := 'SELECT COUNT(*)   FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MROUTID IS NOT NULL   ';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;

    --��ѡ��Ҫ���������������з�����¼
    IF V_COUNT > 0 THEN
      V_RET := '002';

    END IF;
    V_SQL := 'SELECT COUNT(*)  FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MRREADOK=''Y''';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;
    --��ѡ��Ҫ����������������ˮ��¼��
    IF V_COUNT > 0 THEN
      IF V_RET='002' THEN
         V_RET := '003'; --����ˮ��¼��
      ELSE
         V_RET :='013';--ֻ��¼��ˮ�� û���ѷ���
      END IF;

    END IF;
    V_SQL := 'SELECT COUNT(*)  FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MRIFREC=''Y''';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;
    --��ѡ��Ҫ�������������������
    IF V_COUNT > 0 THEN
      IF V_RET='003' THEN
        V_RET := '004';   ---�з��� ��ˮ��¼�� �������
      ELSIF V_RET ='013' THEN
        V_RET := '014';   --��ˮ��¼�� �������

      END IF;
    END IF;
    IF V_RET IS NOT NULL THEN
       RAISE INOUTNOXD_ERR;
    END IF;

  END IF;

  IF P_COMMIT = 'Y' THEN
    COMMIT;
  END IF;
  O_TAIL := '000';
EXCEPTION
  WHEN INOUTNOXD_ERR THEN
    O_TAIL := V_RET;
  WHEN INHADNO_ERR THEN
    O_TAIL := '005';
  WHEN OTHERS THEN
    ROLLBACK;
    O_TAIL := '999';
END;
/


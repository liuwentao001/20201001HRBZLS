CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_PAY_TM" IS
  CURDATE DATE;

  --ʵʱǷ�ѽ���ΥԼ��
  --�����ܽ�����ΥԼ��
  FUNCTION GETREC(P_MID IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
    MI     METERINFO%ROWTYPE;
  BEGIN
    SELECT * INTO MI FROM METERINFO T WHERE MIID = P_MID;
    SELECT SUM(RLJE + GETZNJADJ(RLID,
                                RLJE,
                                RLGROUP,
                                RLZNDATE,
                                MI.MISMFID,
                                TRUNC(SYSDATE)))
      INTO RESULT
      FROM RECLIST T
     WHERE T.RLPAIDFLAG = 'N'
       AND RLCD = 'DE'
       AND RLOUTFLAG = 'N';

    RETURN NVL(RESULT, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --ʵʱǷ�ѽ��
  --�����ܽ�����ΥԼ��ͬʱ��2�����������Ӧ�ս�� �� ΥԼ��
  FUNCTION GETREC(P_MID   IN VARCHAR2,
                  P_RECJE OUT RECLIST.RLJE%TYPE,
                  P_ZNJ   OUT RECLIST.RLZNJ%TYPE) RETURN NUMBER IS

    RESULT NUMBER;
    MI     METERINFO%ROWTYPE;
  BEGIN

    SELECT * INTO MI FROM METERINFO T WHERE MIID = P_MID;

    SELECT NVL(SUM(T.RLJE), 0),
           NVL(SUM(GETZNJADJ(T.RLID,
                             T.RLJE,
                             T.RLGROUP,
                             T.RLZNDATE,
                             MI.MISMFID, --ʹ�õ�ǰӪҵ���ż���ΥԼ��
                             TRUNC(SYSDATE))),
               0)
      INTO P_RECJE, P_ZNJ
      FROM RECLIST T
     WHERE T.RLMID = P_MID
       AND T.RLPAIDFLAG = 'N'
       AND RLOUTFLAG = 'N';

    RESULT := P_RECJE + P_ZNJ;
    --����Ƿ���ܺ�
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --ȡ���ɽ���ޱ���
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --���ɽ����
                       P_SMFID   IN VARCHAR2, --Ӫҵ��
                       P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
                       ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPVALUE, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --ȡ���ɽ��������
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --���ɽ����
                     P_SMFID   IN VARCHAR2, --Ӫҵ��
                     P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
                     ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPDAY, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --Ӫҵ��
                  P_RLGROUP IN VARCHAR2, --Ӧ�շ��ʺ�
                  P_SDATE   IN DATE, --������'����'ΥԼ��
                  P_EDATE   IN DATE, --������'������'ΥԼ��
                  P_JE      IN NUMBER) --ΥԼ�𱾽�
   RETURN NUMBER IS
    VRESULT NUMBER := 0;
    V_DAY   NUMBER;
    V_SCALE NUMBER;
  BEGIN
    IF P_SDATE IS NULL OR P_EDATE IS NULL THEN
      RETURN 0;
    END IF;

    BEGIN
      IF ȫ��˾ͳһ��׼�����ɽ� = '1' THEN
        --ȡ������������������
        SELECT NVL(ZPVALUE, 0), NVL(ZPDAY, 0)
          INTO V_SCALE, V_DAY
          FROM ZNJPARME T
         WHERE ZPTYPE = ȫ��˾ͳһ��׼�����ɽ�
           AND (ZPTYPE = ȫ��˾ͳһ��׼�����ɽ�)
           AND ZPGROUP = P_RLGROUP
           AND ZPFLAG = 'Y';
      END IF;
      IF ȫ��˾ͳһ��׼�����ɽ� = '2' THEN
        --ȡ������������������
        SELECT NVL(ZPVALUE, 0), NVL(ZPDAY, 0)
          INTO V_SCALE, V_DAY
          FROM ZNJPARME T
         WHERE ZPTYPE = ȫ��˾ͳһ��׼�����ɽ�
           AND (ZPTYPE = ȫ��˾ͳһ��׼�����ɽ� AND ZPSMFID = P_SMFID)
           AND ZPGROUP = P_RLGROUP
           AND ZPFLAG = 'Y';
      END IF;
      --�ͽ���--�������յ��졢������ɷѵ���
      SELECT NVL(COUNT(*) - SUM(CALIFHOL) - V_DAY, 0)
        INTO VRESULT
        FROM CALENDAR
       WHERE CALDATE >= TRUNC(P_SDATE)
         AND CALDATE <= TRUNC(P_EDATE);

      --ȫ�ֿ�����������������
      IF VRESULT <= 0 THEN
        RETURN 0;
      ELSE
        --������ɽ�
        VRESULT := ROUND(VRESULT * NVL(P_JE, 0) * V_SCALE, 8);
        RETURN TRUNC(VRESULT, 2);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

  END;

  --ΥԼ����㣨���ڼ��չ��򣬺��������
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --Ӧ����ˮ
                     P_RLJE     IN NUMBER, --Ӧ�ս��
                     P_RLGROUP  IN NUMBER, --Ӧ�����
                     P_RLZNDATE IN DATE, --���ɽ�������
                     P_SMFID    VARCHAR2, --ˮ��Ӫҵ��
                     --P_RL
                     P_EDATE IN DATE --������'������'ΥԼ��
                     ) RETURN NUMBER IS
    CURSOR C_ZAL IS
      SELECT *
        FROM ZNJADJUSTLIST
       WHERE ZALRLID = P_RLID
         AND ZALSTATUS = 'Y'
         AND (TRUNC(SYSDATE) <= ZALZNDATE OR ZALZNDATE IS NULL);
    ZAL         ZNJADJUSTLIST%ROWTYPE;
    JE          NUMBER;
    V_MID       VARCHAR(10);
    V_RLMIEMAIL VARCHAR2(64);
  BEGIN
    BEGIN
      SELECT RLMID, RLMIEMAIL
        INTO V_MID, V_RLMIEMAIL
        FROM RECLIST RL
       WHERE RL.RLID = P_RLID;
      IF V_RLMIEMAIL IS NOT NULL THEN
        RETURN 0;
      END IF;
      IF F_GETIFZNJ(V_MID) = 'N' THEN
        RETURN 0;
      END IF;
    END;
    --�쳣����0
    JE := GETZNJ(P_SMFID, P_RLGROUP, P_RLZNDATE, P_EDATE, P_RLJE);
    OPEN C_ZAL;
    FETCH C_ZAL
      INTO ZAL;
    IF C_ZAL%FOUND THEN
      IF ZAL.ZALMETHOD = '1' THEN
        --Ŀ�������;
        JE := TOOLS.GETMAX(NVL(ZAL.ZALVALUE, JE), 0);
      ELSIF ZAL.ZALMETHOD = '2' THEN
        --����������;
        JE := TOOLS.GETMAX(JE * (1 + NVL(ZAL.ZALVALUE, 0)), 0);
      ELSIF ZAL.ZALMETHOD = '3' THEN
        --������;
        JE := TOOLS.GETMAX(JE + NVL(ZAL.ZALVALUE, 0), 0);
      ELSIF ZAL.ZALMETHOD = '4' THEN
        --������������
        JE := GETZNJ(P_SMFID, P_RLGROUP, ZAL.ZALDATE, P_EDATE, P_RLJE);
      END IF;
    END IF;
    CLOSE C_ZAL;

    RETURN JE;
  EXCEPTION
    WHEN OTHERS THEN

      RETURN 0;
  END;

  /*******************************************************************************************
  �µ����ʴ�������ɴ�����
  *******************************************************************************************/
  /*******************************************************************************************
  ��������F_PAY_CORE
  ��;���������ʹ��̣�����������ҵ�����յ��ñ�����ʵ��
  ������
  ����ֵ��
          000---�ɹ�
          ����--ʧ��
  ǰ��������
          ����ʱ��RECLIST_1METER_TMP�У�׼�������С����������ݡ�
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                      P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                      P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
                      P_RLJE     IN NUMBER, --Ӧ�ս��
                      P_ZNJ      IN NUMBER, --����ΥԼ��
                      P_SXF      IN NUMBER, --������
                      P_PAYJE    IN NUMBER, --ʵ���տ�
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                      P_PAYBATCH IN VARCHAR2, --�ɷ�������ˮ
                      P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                      P_INVNO    IN PAYMENT.PILID%TYPE, --��Ʊ��
                      P_PAYID    OUT PAYMENT.PID%TYPE --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                      ) RETURN VARCHAR2 IS
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������

    /*   V_REC_TOTAL NUMBER(10,2);     --��Ӧ��ˮ��
    V_ZNJ_TOTAL NUMBER(10,2);     --��ΥԼ��
    V_SXF_TOTAL NUMBER(10,2);     --��������*/

    ERR_JE EXCEPTION; --������
    NO_METER EXCEPTION; --��ָ��ˮ��
    ERR_REC EXCEPTION; --���ʴ������
    V_CALL NUMBER;

    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    --RL      RECLIST%ROWTYPE;
    --RD      RECDETAIL%ROWTYPE;
    VP       PAYMENT%ROWTYPE;
    V_TEMPRL RECLIST_1METER_TMP%ROWTYPE;
    --V_RDROW NUMBER(10);
    --�α��ڴ�˵��
    --ˮ����Ϣ
    CURSOR C_MI(VMID VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT; --����ֱ���׳�

    --������Ӧ�����˼�¼
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST RT
       WHERE RT.RLID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
       ORDER BY RT.RLGROUP
         FOR UPDATE NOWAIT; --����ֱ���׳�

    --������Ӧ����ϸ�˼�¼
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL T
       WHERE T.RDID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
         FOR UPDATE NOWAIT; --����ֱ���׳�

    -- ��д��ϸ���ɽ�������ʱ���¼
    CURSOR C_TEMPRL IS
      SELECT * FROM RECLIST_1METER_TMP;

  BEGIN
    V_RESULT := '000';
    --STEP 1: ���ˮ���
    V_STEP    := 1;
    V_PRC_MSG := '���ˮ���';

    --ȡˮ����Ϣ�����ر��α꣬�����£�
    OPEN C_MI(P_MIID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE NO_METER;
    END IF;

    SELECT T.* INTO CI FROM CUSTINFO T WHERE T.CIID = MI.MICID;

    ------STEP 10: �����ֽ��
    --��Χ��� ���������ʲ��ٽ���

    ------STEP 20: ��¼ʵ����
    V_STEP       := 20;
    V_PRC_MSG    := '��¼ʵ����';
    P_PAYID      := FGETSEQUENCE('PAYMENT'); --PAYMENT������ˮ��ÿ�����ʽ���һ����¼
    VP.PID       := P_PAYID;
    VP.PCID      := MI.MICID;
    VP.PCCODE    := CI.CICODE;
    VP.PMID      := MI.MIID;
    VP.PMCODE    := MI.MICODE;
    VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
    VP.PDATETIME := SYSDATE;
    VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
                        TO_CHAR(SYSDATE, 'yyyy.mm'));
    VP.PPOSITION := P_POSITION;

    VP.PTRANS := P_TRANS;
    VP.PCD    := '  ';
    VP.PPER   := P_OPER;
    -----����ֶθ�ֵ����Ҫע��------------------------------
    VP.PCHANGE     := 0;
    VP.PPAYMENT    := P_PAYJE;
    VP.PSAVINGQC   := MI.MISAVING;
    VP.PSPJE       := P_RLJE;
    VP.PSXF        := P_SXF;
    VP.PZNJ        := P_ZNJ;
    VP.PCHANGE     := 0;
    VP.PRCRECEIVED := VP.PPAYMENT - VP.PCHANGE;
    ---ÿ��PAYMENT��¼�еĽ���ϵΪ����2��
    --Ԥ����ĩ=ʵ��+Ԥ�����-Ӧ��ˮ��-������-ΥԼ��
    VP.PSAVINGQM := VP.PPAYMENT + VP.PSAVINGQC - VP.PSPJE - VP.PZNJ -
                    VP.PSXF;
    --Ԥ�汾�ڷ���=��ĩ-�ڳ�
    VP.PSAVINGBQ := VP.PSAVINGQM - VP.PSAVINGQC;
    ------���ϴ��򲻿�����䶯------------------------------------------------
    VP.PIFSAVING := (CASE
                      WHEN VP.PSAVINGBQ <> 0 THEN
                       'Y'
                      ELSE
                       'N'
                    END);
    VP.PPAYWAY   := P_FKFS;
    VP.PBATCH    := P_PAYBATCH;
    VP.PPAYEE    := P_OPER;
    VP.PPAYPOINT := P_PAYPOINT;
    VP.PSXF      := P_SXF;
    IF P_IFP = 'Y' THEN
      VP.PILID := P_INVNO; --��Ʊ��ˮ��
    END IF;
    VP.PFLAG := 'Y';
    VP.PZNJ  := P_ZNJ;

    VP.PREVERSEFLAG := 'N'; --������־='N'
    INSERT INTO PAYMENT VALUES VP;
    ------- END OF  ��¼ʵ����

    ----�Ƿ񵥽�Ԥ�棿Ƿ�ѽ��Ϊ0 ����Ϊ����Ԥ�棬���账��Ӧ��ϸ�ڣ�ֱ����ת
    IF P_RLJE = 0 THEN
      GOTO PAY_SAVING;
    END IF;

    -------STEP 30: Ӧ���������ʴ���
    V_STEP    := 30;
    V_PRC_MSG := 'Ӧ���������ʴ���';
    -------------------------------------
    --��Ϊǰ�������������ʼ�¼�����RECLIST_1METER_TMP��������ʱ�������ü��㴦��
    V_CALL := 0;
    V_CALL := F_PSET_RECLIST(P_PAYJE,
                             VP.PID,
                             MI.MISAVING,
                             VP.PDATE,
                             VP.PPER);
    IF V_CALL = 0 THEN
      RAISE ERR_REC;
    END IF;

    --�ٴ���ʱ����µ���ʽ��
    OPEN C_RL; --Ӧ�����˼���
    UPDATE RECLIST T
       SET (T.RLPID, --��Ӧ��PAYMENT ��ˮ
            T.RLPBATCH, --ʵ�����κ�
            T.RLPAIDFLAG, --���ʱ�־
            --T.RLPAIDJE,            --���ʽ��
            T.RLPAIDDATE, --��������
            T.RLPAIDPER, --�շ�Ա
            T.RLZNJ, --ΥԼ��
            T.RLPAIDJE, --�ɷѽ��
            T.RLSAVINGQC, --�ڳ�Ԥ��
            T.RLSAVINGQM, --��ĩԤ��
            T.RLSAVINGBQ, --���ڷ���
            T.RLPAIDMONTH) =
           (SELECT S.RLPID,
                   P_PAYBATCH,
                   'Y',
                   --T.RLJE,
                   VP.PDATE,
                   VP.PPER,
                   S.RLZNJ,
                   S.RLPAIDJE,
                   S.RLSAVINGQC,
                   S.RLSAVINGQM,
                   S.RLSAVINGBQ,
                   VP.PMONTH
              FROM RECLIST_1METER_TMP S
             WHERE T.RLID = S.RLID)
     WHERE T.RLID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RL;
    ----END OF  STEP 30: Ӧ���������ʴ���----------------------------------------------------------

    ---STEP 40: Ӧ����ϸ�����ʴ���----------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := 'Ӧ����ϸ�����ʴ���';
    -----------------------------------------
    OPEN C_RD; --Ӧ����ϸ�ʼ���
    UPDATE RECDETAIL T
       SET T.RDPAIDFLAG  = 'Y', --���ʱ�־
           T.RDPAIDDATE  = VP.PDATE, --��������
           T.RDPAIDMONTH = VP.PMONTH, --�����·�
           T.RDPAIDPER   = VP.PPER --�շ�Ա
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --Ӧ����ϸ�ʽ���


    /******************* ��д���ɽ�  by lgb 2012-06-01**********************************/
    OPEN C_RD; --���ɽ�����
    UPDATE RECDETAIL T
       SET T.RDZNJ = 0
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --Ӧ����ϸ�ʽ���

    OPEN C_RD; --��д���ɽ�
    OPEN C_TEMPRL;
    LOOP
      FETCH C_TEMPRL
        INTO V_TEMPRL;
      EXIT WHEN C_TEMPRL%NOTFOUND OR C_TEMPRL%NOTFOUND IS NULL;
      UPDATE RECDETAIL T
         SET T.RDZNJ =
             (SELECT S.RLZNJ FROM RECLIST_1METER_TMP S WHERE T.RDID = S.RLID)
       WHERE T.RDID = V_TEMPRL.RLID
         AND ROWNUM < 2;
    END LOOP;
    CLOSE C_TEMPRL;
    CLOSE C_RD; --Ӧ����ϸ�ʽ���

    ----END OF STEP 40: Ӧ����ϸ�����ʴ��� ------------------------------------------------

    <<PAY_SAVING>> --����Ԥ���ǩ

    ----STEP 50: Ԥ������-----------------------------------------------------------
    V_STEP    := 50;
    V_PRC_MSG := 'Ԥ������';
    --�жϱ���Ԥ���Ƿ�仯���б仯�ٸ���ˮ����Ϣ���������һЩЧ��
    IF VP.PSAVINGBQ <> 0 THEN
      UPDATE METERINFO T
         SET T.MISAVING = VP.PSAVINGQM, T.MIPAYMENTID = P_PAYID
       WHERE CURRENT OF C_MI;
      CLOSE C_MI;
    END IF;
    ----END OF  STEP 5: Ԥ������------------------------------------------------

    --STEP 60: �ύ����---------------------------------------------------------
    V_STEP    := 60;
    V_PRC_MSG := 'ˮ��ɷ��ύ';
    /*           IF P_COMMIT = 'Y' THEN
        COMMIT;
    END IF;   */

    RETURN V_RESULT;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('F_PAY_CORE', V_STEP, V_PRC_MSG, '');
      V_RESULT := '999';
      RETURN V_RESULT;
  END F_PAY_CORE;

  /*******************************************************************************************
  ��������F_PSET_RECLIST
  ��;�� �������ɺ������ʹ��̵��ã�����ǰ�������ʼ�¼���Ѿ��ڴ�RECLIST �п�������ʱ���У�����������ʱ������������ʴ���
  ����������󣬺������ʹ��̸�����ʱ�����RECLIST ���ﵽ�������Ŀ�ġ�
             ���������Ŀ�ģ����շѽ���Ԥ���������䵽Ӧ���ʼ�¼�ϣ������Ʊ����
  ���ӣ� Aˮ��3����Ƿ��110Ԫ���ڳ�Ԥ��30Ԫ�������շ�100Ԫ��ΥԼ��5Ԫ��Ӧ�����ʼ�¼���£�
  ----------------------------------------------------------------------------------------------------
   ��     ��       Ԥ��     �����շ�    Ӧ��ˮ��     ΥԼ��    Ԥ����ĩ   Ԥ�淢��
  ----------------------------------------------------------------------------------------------------
  2011.06        30        100           30             1               99             69
  -----------------------------------------------------------------------------------------------------
  2011.08        99         0              40             2                57           -42
  -----------------------------------------------------------------------------------------------------
  2011.10        57         0              40             2                15           -42
  -----------------------------------------------------------------------------------------------------
  ������P_PAYJE NUMBER��ʵ�ս��
           P_REMAIND NUMBER ��ǰԤ��
  ǰ��������RECLIST_1METER_TMP ��RLID, RLJE,RLZNJ ��RLSXF ��������ˡ�
  *******************************************************************************************/
  FUNCTION F_PSET_RECLIST(P_PAYJE   IN NUMBER, --ʵ�ս��
                          P_PID     IN PAYMENT.PID%TYPE, --ʵ����ˮ
                          P_REMAIND IN NUMBER, --��ǰԤ��
                          P_DATE    DATE, --��������
                          P_PPER    IN PAYMENT.PPER%TYPE --�տ�Ա
                          ) RETURN NUMBER AS
    --Ӧ����������ʱ���α�,��ԭӦ�����·�����
    CURSOR C_RL IS
      SELECT T.*
        FROM RECLIST_1METER_TMP T
       ORDER BY T.RLSCRRLMONTH, T.RLGROUP;

    V_RCOUNT NUMBER;
    V_RL     RECLIST%ROWTYPE;
    V_JE_TMP NUMBER; --��¼ʣ����
    V_QC     NUMBER;

  BEGIN
    V_RCOUNT := 0;

    OPEN C_RL;
    V_JE_TMP := P_PAYJE;
    V_QC     := P_REMAIND;
    LOOP
      FETCH C_RL
        INTO V_RL;

      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;

      ----����������¸�ֵ�����򲻿�����䶯--------------------------------------------------------------------
      V_RL.RLZNJ := NVL(V_RL.RLZNJ, 0);
      V_RL.RLSXF := NVL(V_RL.RLSXF, 0);

      V_RL.RLPAIDJE   := V_JE_TMP; --����Ӧ�ռ�¼ʱ���շѽ��
      V_RL.RLSAVINGQC := V_QC; --����Ӧ�ռ�¼ʱ��Ԥ���ڳ�
      --����Ӧ�ռ�¼���Ԥ����ĩ
      V_RL.RLSAVINGQM := V_RL.RLPAIDJE + V_RL.RLSAVINGQC - V_RL.RLJE -
                         V_RL.RLZNJ - V_RL.RLSXF;
      ----����Ӧ�ռ�¼ʱ��Ԥ�淢��
      V_RL.RLSAVINGBQ := V_RL.RLSAVINGQM - V_RL.RLSAVINGQC;

      V_JE_TMP := 0; --����һ���⣬����ÿ����ʵ�ս���0
      V_QC     := V_RL.RLSAVINGQM; --��һ����ĩ����Ϊ��һ���ڳ�
      ----�������------------------------------------------------------------------------------------------------

      ---������ʱӦ�ձ�
      UPDATE RECLIST_1METER_TMP T
         SET T.RLPAIDJE   = V_RL.RLPAIDJE,
             T.RLSAVINGQC = V_RL.RLSAVINGQC,
             T.RLSAVINGQM = V_RL.RLSAVINGQM,
             T.RLSAVINGBQ = V_RL.RLSAVINGBQ,
             T.RLPAIDFLAG = 'Y',
             T.RLPID      = P_PID,
             T.RLPAIDDATE = P_DATE,
             T.RLPAIDPER  = P_PPER
       WHERE T.RLID = V_RL.RLID;

      V_RCOUNT := V_RCOUNT + 1;
    END LOOP;

    RETURN V_RCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END F_PSET_RECLIST;

  /*******************************************************************************************
  ��������F_POS_1METER
  ��;����ֻˮ��ɷ�
      1������ɷ�ҵ�񣬵��ñ���������PAYMENT �м�һ����¼��һ��id��ˮ��һ������
      2�����ɷ�ҵ��ͨ��ѭ�����ñ�����ʵ��ҵ��һֻˮ��һ����¼�����ˮ��һ�����Ρ�
  ҵ�����
     1����ֻˮ����Ƿ��ȫ����������Ӧ��id����xxxxx,xxxxx,xxxxx| ��ʽ���P_RLIDS, ���ñ�����
     2�������еȴ��ջ������̨���е�ֻˮ���Ƿ��ȫ����P_RLIDS='ALL'
     3������Ԥ�棬P_RLJE=0
  �������μ���;˵��
     P_PAYBATCH='999999999',����ģ�����������κţ�����ֱ��ʹ��P_PAYBATCH��Ϊ���κ�
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                        P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                        P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
                        P_RLJE     IN NUMBER, --Ӧ���ܽ��
                        P_ZNJ      IN NUMBER, --����ΥԼ��
                        P_SXF      IN NUMBER, --������
                        P_PAYJE    IN NUMBER, --ʵ���տ�
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                        P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                        P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
                        P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                        P_INVNO    IN VARCHAR2, --��Ʊ��
                        P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��
                        ) RETURN VARCHAR2 AS
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_SRESULT VARCHAR2(3); --������
    V_NRESULT NUMBER; --������

    V_PAYID VARCHAR2(10); --���ص�ʵ������ˮ

    V_MINFO METERINFO%ROWTYPE;

    V_PAYBATCH PAYMENT.PBATCH%TYPE; -- ʵ����������ˮ

    V_LAST_PID PAYMENT.PID%TYPE;

    V_LAST_SAVING METERINFO.MISAVING%TYPE;

    ERR_CHK EXCEPTION; --���δͨ��
    ERR_RECID EXCEPTION; --Ӧ����ˮ����ʽ��
    ERR_PAY EXCEPTION; --���˴���
  BEGIN

    ----STEP 1: Ӧ����ˮID�ֽ⣬׼����ʱ������-------------------------------------
    V_STEP    := 1;
    V_PRC_MSG := 'Ӧ����ˮID�ֽ�';
    V_NRESULT := F_SET_REC_TMP(P_RLIDS, P_MIID);
    IF V_NRESULT <= 0 THEN
      RAISE ERR_RECID;
    END IF;
    ----END OF STEP 1:����������д���������ȫ������ʱ��׼����-------------------

    ----STEP 10:  ����ǰ������-------------------------------------
    V_STEP    := 10;
    V_PRC_MSG := '����ǰ������';

    --��ˮ�����ڣ���NO_DATA_FOUND ����
    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    V_NRESULT := F_CHK_LIST(P_RLJE, --Ӧ�ս��
                            P_ZNJ, --����ΥԼ��
                            P_SXF, --������
                            P_PAYJE, --ʵ���տ�
                            V_MINFO.MISAVING --��ǰԤ��
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;

    --���ˮ��Ԥ�������ϴ�ʵ�ռ�¼��Ԥ����ĩֵ�������
    --ȡ���һ��ʵ�ռ�¼
    SELECT MAX(T.PID), COUNT(T.PID)
      INTO V_LAST_PID, V_NRESULT
      FROM PAYMENT T
     WHERE T.PMID = P_MIID;
    --ȡʵ���ʵ�Ԥ����ĩֵ
    V_LAST_SAVING := 0;
    IF V_NRESULT > 0 THEN
      SELECT T.PSAVINGQM
        INTO V_LAST_SAVING
        FROM PAYMENT T
       WHERE T.PID = V_LAST_PID;
    END IF;
    --���Ԥ����ĩֵ��ˮ����Ϣ��Ԥ�����������¼�쳣
    IF V_LAST_SAVING <> V_MINFO.MISAVING THEN
      INSERT INTO CHK_RESULT
      VALUES
        (SEQ_CHK_LIST.NEXTVAL,
         SYSDATE,
         'Ԥ����',
         'ˮ����ϢԤ�����ʵ���ʱ�Ԥ����ĩ������',
         '',
         P_MIID,
         V_LAST_PID,
         '',
         'ˮ��Ԥ�����:' || TO_CHAR(V_MINFO.MISAVING) || '  ʵ����Ԥ����ĩ:' ||
         TO_CHAR(V_LAST_SAVING),
         '');
    END IF;
    ----END OF STEP 10:  ���ͨ��,���ҷ���ˮ�������Ϣ--------------

    ----STEP 20: ����׼����Ϊ���ú������ʹ���׼������------------------------------------------------
    V_STEP     := 20;
    V_PRC_MSG  := '����׼��';
    V_PAYBATCH := (CASE
                    WHEN P_PAYBATCH <> '9999999999' THEN
                     P_PAYBATCH
                    ELSE
                     FGETSEQUENCE('ENTRUSTLOG')
                  END);
    --�����������������Ҫ׼�����ڴ˽���

    ----END OF STEP 20: ���̵��ò���׼�����------------------------------------------------------------

    ----STEP 30: ���ú������ʹ�������-----------------------------------------------------
    V_STEP    := 30;
    V_PRC_MSG := '���ú������ʹ�������';
    V_SRESULT := F_PAY_CORE(P_POSITION, --�ɷѻ���
                            P_OPER, --�տ�Ա
                            P_MIID, --ˮ����
                            P_RLJE, --Ӧ�ս��
                            P_ZNJ, --����ΥԼ��
                            P_SXF, --������
                            P_PAYJE, --ʵ���տ�
                            P_TRANS, --�ɷ�����
                            P_FKFS, --���ʽ
                            P_PAYPOINT, --�ɷѵص�
                            V_PAYBATCH, --�ɷ�������ˮ
                            P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                            P_INVNO, --��Ʊ��
                            V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                            );
    IF V_SRESULT <> '000' THEN
      RAISE ERR_PAY;
    END IF;
    --END OF STEP 30: �������ʹ�����ϣ���̨���ݱ仯���£�-----------------
    --PAYMENT ��������һ����¼����¼ʵ����ˮ�ڴ�V_PAYID����
    --RECLIST �У��ڴ�P_RLIDS��ָ����Ӧ��ID�����������ʹ�����д���
    --RECDETAIL�У���ָ����Ӧ��ID��صļ�¼�����������ʹ�����д���
    --METERINFO �У���ָ��ˮ���P_MIID��صļ�¼��Ԥ�������
    ----------------------------------------------------------------------------------------
    ----STEP 40: �����ύ�����ݲ����ж��Ƿ��ύ---------------------------------------------------------
    IF TRIM(UPPER(P_COMMIT)) = 'Y' THEN
      COMMIT;
    END IF;
    ----END OF STEP 40: �����ύ���------------------------------------------------
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('F_POS_1METER', V_STEP, V_PRC_MSG, '');
      RETURN '999';
  END F_POS_1METER;

  /*******************************************************************************************
  ��������F_POS_MULT_M
  ��;��
      ���ɷѣ�ͨ��ѭ�����õ���ɷѹ���ʵ�֡�
  ҵ�����
     1����ֻˮ�����ʣ�֧��ˮ����ѡ�����·�
     2��ÿֻˮ��������Ԥ��仯���շѽ��=Ƿ�ѽ��
     3������ˮ������ʣ���PAYMENT�У�ͬһ��������ˮ��
  ������
  ǰ��������
      1������Ҫ�����ʲ�����ˮ��id��Ӧ������ˮid����Ӧ�ս�ΥԼ�������ѣ� �ڵ��ñ�����ǰ��
       �������ʱ�ӿڱ� PAY_PARA_TMP
      2��Ӧ������ˮ���ĸ�ʽ�����ĵ������ʹ��̵�˵����
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                        P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                        P_PAYJE    IN NUMBER, --��ʵ���տ���
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                        P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                        P_INVNO    IN VARCHAR2, --��Ʊ��
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    MID_COUNT NUMBER; --ˮ��ֻ��
    V_INP     NUMBER; --ѭ������

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --���˴���
    ERR_JE EXCEPTION; --������

    CURSOR C_M_PAY IS
      SELECT * FROM PAY_PARA_TMP RT;

  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    --����ͳһ���κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');
    V_BATCH := P_BATCH;
    V_TOTAL := 0;
    --���õ������ʹ��̣�������ˮ������ ����
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --���㵥ֻˮ���ʵ���տ���
      V_PAID_METER := V_PP.RLJE + V_PP.RLZNJ + V_PP.RLSXF;

      V_TOTAL := V_TOTAL + V_PAID_METER;

      ---��������---------------------------------------------------------------------------------
      V_RESULT := F_POS_1METER(P_POSITION, --�ɷѻ���
                               P_OPER, --�տ�Ա
                               V_PP.PLIDS, --Ӧ����ˮ��
                               V_PP.RLJE, --Ӧ���ܽ��
                               V_PP.RLZNJ, --����ΥԼ��
                               V_PP.RLSXF, --������
                               V_PAID_METER, -- ˮ��ʵ���տ�
                               P_TRANS, --�ɷ�����
                               V_PP.MID, --ˮ�����Ϻ�
                               P_FKFS, --���ʽ
                               P_PAYPOINT, --�ɷѵص�
                               V_BATCH, --�Զ�������������
                               P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                               P_INVNO, --��Ʊ��
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
    END LOOP;

    /*--ȫ��ˮ������ϣ���̨����Ӱ�����£�------------------------------------------------------
    1����PAYMENT���У������˺�ˮ��������ͬ�ļ�¼��ʵ���շѽ��=Ӧ�ɽ�ˮ�ѡ�ΥԼ�������ѵȣ�
          û��Ԥ��仯����Щ��¼����ͬ�����κš�
    2����Ӧ�����ˡ�RECLIST���У�ָ��ˮ��ָ����Ӧ�ռ�¼�����������ʹ�����д���û��Ԥ��ı仯
    3����Ӧ����ϸ��RECDETAIL ���У���RECLIST����ƥ��ļ�¼�����������ʹ�����д���
    ----------------------------------------------------------------------------------------------------*/
    --����ܽ���Ƿ���������򱨴�
    IF V_TOTAL <> P_PAYJE THEN
      RAISE ERR_JE;
    END IF;
    --һ�����ύ-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_M', V_INP, '���:' || V_PP.MID, '');
      RETURN '999';
  END F_POS_MULT_M;
  /*******************************************************************************************
  ��������F_POS_MULT_HS
  ��;�����ձ�ɷ�
  ҵ�����
     1����ֻˮ�����ʣ�ÿֻˮ�����ݿͻ���ѡ��Ľ�����ش�����ˮid
     2�����������ʣ��������ʽ����㵽������ĩ�����
     3����ʴ����ӱ�����Ԥ��ת�ӱ�Ԥ�棬�ӱ�Ԥ�����ʣ�
     4�����������ύ
  ������
  ǰ��������
      ˮ���ˮ���Ӧ��Ӧ������ˮ�����������ʱ�ӿڱ� PAY_PARA_TMP ��
  *******************************************************************************************/

  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                         P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --���������
                         P_PAYJE    IN NUMBER, --��ʵ���տ���
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                         P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         P_INVNO    IN VARCHAR2, --��Ʊ��
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS

    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    MID_COUNT NUMBER; --ˮ��ֻ��
    V_INP     NUMBER; --ѭ������

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --�������κ�
    ERR_PAY EXCEPTION; --���˴���

    V_NRESULT NUMBER; --������

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM PAY_PARA_TMP RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING > 0;
    V_PAYID PAYMENT.PID%TYPE;
  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    V_BATCH := P_BATCH;

    ---STEP 0: ���Ǻ��������Ԥ��ת��������ȥ---------------------------------------------------
    OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      V_NRESULT := F_REMAIND_TRANS1(MI.MIID, --ת��ˮ���

                                    P_MMID, --ת��ˮ�����Ϻ�
                                    MI.MISAVING, --ת�ƽ��=��ˮ�����ʽ��
                                    V_BATCH, --ʵ�����κ�
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: ������������---------------------------------------------------
    --�����������κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '������������';
    BEGIN
      SELECT RT.* INTO V_PP FROM PAY_PARA_TMP RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER(P_POSITION, --�ɷѻ���
                               P_OPER, --�տ�Ա
                               V_PP.PLIDS, --Ӧ����ˮ��
                               V_PP.RLJE, --Ӧ���ܽ��
                               V_PP.RLZNJ, --����ΥԼ��
                               V_PP.RLSXF, --������
                               P_PAYJE, -- ˮ��ʵ���տ�
                               P_TRANS, --�ɷ�����
                               V_PP.MID, --ˮ�����Ϻ�
                               P_FKFS, --���ʽ
                               P_PAYPOINT, --�ɷѵص�
                               V_BATCH,
                               P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                               P_INVNO, --��Ʊ��
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;

    ELSE
      --Ԥ�浽����
      ----��ת��Ԥ���ʵ����-----------------------------------------------------------------
      V_RESULT := F_PAY_CORE(P_POSITION, --�ɷѻ���
                             P_OPER, --�տ�Ա
                             P_MMID, --ˮ�����Ϻ�
                             0, --Ӧ�ս��
                             0, --����ΥԼ��
                             0, --������
                             P_PAYJE, --ʵ���տ�
                             PAYTRANS_YCDB, --�ɷ�����
                             P_FKFS, --���ʽ
                             P_PAYPOINT, --�ɷѵص�
                             P_BATCH, --�ɷ���������
                             'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                             '', --��Ʊ��
                             V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                             );

    END IF;
    ---end of  STEP 1: ---------------------------------------------------

    ---STEP 20: �����ӱ�����---------------------------------------------------
    V_STEP    := 20;
    V_PRC_MSG := '�����ӱ�����';
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --���㵥ֻˮ���ʵ���տ���
      V_PAID_METER := 0;
      V_TOTAL      := V_PP.RLJE + V_PP.RLSXF + V_PP.RLZNJ;

      ---STEP 21: Ԥ�����---------------------------------------------------
      V_STEP    := 21;
      V_PRC_MSG := '�����ӱ�����--Ԥ�����';
      --
      V_NRESULT := F_REMAIND_TRANS1(P_MMID, --ת��ˮ���
                                    V_PP.MID, --ת��ˮ�����Ϻ�
                                    V_TOTAL, --ת�ƽ��=��ˮ�����ʽ��
                                    V_BATCH, --ʵ�����κ�
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');
      ---END OF STEP 21 Ԥ�������ɣ���̨���ݽ��------------------------------------------
      -- ��PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
      --2����¼ͬһ�����κţ���ˮ�����ʵ����κ�һ����
      --�ӱ��ˮ����Ϣ�У�Ԥ��������ӣ����ӽ���������������Ľ��
      ------------------------------------------------------------------------------------------------
      ---STEP 22: �ӱ�����---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '�����ӱ�����--�ӱ�����';
      V_RESULT  := F_POS_1METER(P_POSITION, --�ɷѻ���
                                P_OPER, --�տ�Ա
                                V_PP.PLIDS, --Ӧ����ˮ��
                                V_PP.RLJE, --Ӧ���ܽ��
                                V_PP.RLZNJ, --����ΥԼ��
                                V_PP.RLSXF, --������
                                V_PAID_METER, -- ˮ��ʵ���տ�
                                P_TRANS, --�ɷ�����
                                V_PP.MID, --ˮ�����Ϻ�
                                P_FKFS, --���ʽ
                                P_PAYPOINT, --�ɷѵص�
                                V_BATCH,
                                P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                P_INVNO, --��Ʊ��
                                'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --һ�����ύ-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_HS',
                           V_STEP,
                           V_PRC_MSG,
                           'ˮ�����Ϻ�:' || V_PP.MID);
      RETURN '999';
  END F_POS_MULT_HS;

  /*******************************************************************************************
  ��������F_SET_REC_TMP
  ��;��Ϊ���ʺ��Ĺ���׼��������Ӧ������
  ������̣�
       1�������ȫ�����ʣ���ֱ�ӽ���Ӧ��¼��RECLIST��������ʱ��
       2������ǲ��ּ�¼���ʣ������Ӧ������ˮ����������RECLIST��������ʱ��
       3������ΥԼ�������ѵ�����ǰ����Ľ����Ϣ
  ������
       1���������ʣ�P_RLIDS Ӧ����ˮ������ʽ��XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| ���ŷָ�
       2��ȫ�����ʣ�_RLIDS='ALL'
       3��P_MIID  ˮ�����Ϻ�
  ����ֵ���ɹ�--Ӧ����ˮID������ʧ��--0
  *******************************************************************************************/
  FUNCTION F_SET_REC_TMP(P_RLIDS IN VARCHAR2, P_MIID IN VARCHAR2)
    RETURN NUMBER IS
    V_INP    NUMBER;
    V_RLIDS  VARCHAR2(1280);
    ID_COUNT NUMBER;
    STR_TMP  VARCHAR2(10);
    V_MINFO  METERINFO%ROWTYPE;
  BEGIN
    --���������ʱ��RECLIST_1METER_TMP----------------------------------------------------
    DELETE RECLIST_1METER_TMP;

    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    IF P_RLIDS = 'ALL' THEN
      --ȫ��Ƿ������
      INSERT INTO RECLIST_1METER_TMP
        (SELECT S.*
           FROM RECLIST S
          WHERE S.RLMID = P_MIID --��ˮ���ȫ��Ƿ��
            AND S.RLPAIDFLAG = 'N'
            AND S.RLJE > 0
            AND S.RLREVERSEFLAG = 'N');
    ELSE
      --����Ӧ������
      V_RLIDS := P_RLIDS || '|';
      --ȡID����
      ID_COUNT := TOOLS.FBOUNDPARA2(V_RLIDS);
      --������뵽��ʱ��
      FOR V_INP IN 1 .. ID_COUNT LOOP
        STR_TMP := TOOLS.FGETPARA(V_RLIDS, 1, V_INP);
        --------------------------------------------------------------------------------------
        --�Ƿ�˴�Ӧ��ֱ��ͨ����ȡ��IDֵ����Ӧ����Ϣ��RECLIST ��������ʱ��
        INSERT INTO RECLIST_1METER_TMP
          (SELECT S.*
             FROM RECLIST S
            WHERE S.RLID = STR_TMP
              AND S.RLMID = P_MIID --�˴�����ˮ�����Ϻŵ�������������ʡȥ�����ˮ�����ϵļ��
              AND S.RLPAIDFLAG = 'N'
              AND S.RLJE > 0
              AND S.RLREVERSEFLAG = 'N');
        --����ֻ����Ӧ��ID��
      --  INSERT INTO RECLIST_1METER_TMP (RLID) VALUES (STR_TMP);
      ---------------------------------------------------------------------------------------
      END LOOP;
    END IF;

    --ΥԼ������㵽��ʱ����
    UPDATE RECLIST_1METER_TMP T
       SET T.RLZNJ = GETZNJADJ(T.RLID,
                               T.RLJE,
                               T.RLGROUP,
                               T.RLZNDATE,
                               T.RLMSMFID,
                               TRUNC(SYSDATE));

    -- ���������ʱ���������ѣ������ѵļ����ڴ˽���
    /*         UPDATE  RECLIST_1METER_TMP T
    SET T.RLSXF=*/
    /*      COMMIT;  */
    RETURN ID_COUNT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN 0;
  END F_SET_REC_TMP;

  /*******************************************************************************************
  ��������F_CHK_LIST
  ��;������ǰ������
  ������ Ӧ�ɣ������ѣ�ΥԼ��ʵ�ս�Ԥ���ڳ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --Ӧ�ս��
                      P_ZNJ    IN NUMBER, --����ΥԼ��
                      P_SXF    IN NUMBER, --������
                      P_PAYJE  IN NUMBER, --ʵ���տ�
                      P_SAVING IN METERINFO.MISAVING%TYPE --ˮ�����Ϻ�
                      ) RETURN NUMBER IS

    V_REC_TOTAL NUMBER(10, 2); --��Ӧ��ˮ��
    V_ZNJ_TOTAL NUMBER(10, 2); --��ΥԼ��
    V_SXF_TOTAL NUMBER(10, 2); --��������

    ERR_NOMATCH EXCEPTION;
    ERR_JE EXCEPTION;
    ERR_METER EXCEPTION;

    V_RESULT NUMBER;
    V_MSG    VARCHAR2(200);
  BEGIN
    --����ʱ��������Ӧ��ˮ�ѣ���ΥԼ��
    SELECT NVL(SUM(T.RLJE), 0), NVL(SUM(T.RLZNJ), 0), NVL(SUM(T.RLSXF), 0)
      INTO V_REC_TOTAL, V_ZNJ_TOTAL, V_SXF_TOTAL
      FROM RECLIST_1METER_TMP T;

    --������ϵ
    IF P_RLJE <> V_REC_TOTAL OR P_ZNJ <> V_ZNJ_TOTAL OR
       P_SXF <> V_SXF_TOTAL THEN
      RAISE ERR_NOMATCH;
    END IF;
    --Ҫ���ڵ��ñ�����ǰ����Ҫ���ü�飬���˴���������һ�ν���ϵ�Ƚ�
    /*         IF P_PAYJE+P_SAVING<P_RLJE+P_ZNJ+P_SXF THEN
      RAISE ERR_JE;
    END IF;   */ ---���ڸ�Ԥ��ȡ��

    RETURN 0;
  EXCEPTION
    WHEN ERR_NOMATCH THEN
      RETURN - 1;
    WHEN ERR_JE THEN
      RETURN - 2;
  END F_CHK_LIST;

  /*******************************************************************************************
  ��������F_REMAIND_TRANS1
  ��;����2��ˮ��֮�����Ԥ��ת��
  ������ ת��ˮ��ţ�׼��ˮ��ţ����
  ҵ�����
     1�����ú������ʹ��̣�ˮ�ѽ��=0ʱΪ����Ԥ�棬
     2����PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
     3��2����¼ͬһ�����κ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --ת��ˮ���
                            P_MID_T    IN METERINFO.MIID%TYPE, --ˮ�����Ϻ�
                            P_JE       IN METERINFO.MISAVING%TYPE, --ת�ƽ��
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --ʵ�������κ�
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --�Ƿ��ύ
                            ) RETURN VARCHAR2 IS
    V_RESULT VARCHAR2(3);
    PM       PAYMENT%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    V_PAYID  PAYMENT.PID%TYPE;
    /*V_BATCH PAYMENT.PBATCH%TYPE;*/

    ERR_JE EXCEPTION;

  BEGIN
    --ȡת��ˮ���Ԥ����
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = P_MID_S;
    --���Դˮ��Ԥ��С��ת�����׳�����
    IF MI.MISAVING < P_JE THEN
      RAISE ERR_JE;
    END IF;

    V_RESULT := F_PAY_CORE(P_POSITION, --�ɷѻ���
                           P_OPER, --�տ�Ա
                           P_MID_S, --ˮ�����Ϻ�
                           0, --Ӧ�ս��
                           0, --����ΥԼ��
                           0, --������
                           -1 * P_JE, --ʵ���տ�
                           PAYTRANS_YCDB, --�ɷ�����
                           'XJ', --���ʽ
                           P_PAYPOINT, --�ɷѵص�
                           P_BATCH, --�ɷ���������
                           'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                           '', --��Ʊ��
                           V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                           );
    ----��ת��Ԥ���ʵ����-----------------------------------------------------------------
    V_RESULT := F_PAY_CORE(P_POSITION, --�ɷѻ���
                           P_OPER, --�տ�Ա
                           P_MID_T, --ˮ�����Ϻ�
                           0, --Ӧ�ս��
                           0, --����ΥԼ��
                           0, --������
                           P_JE, --ʵ���տ�
                           PAYTRANS_YCDB, --�ɷ�����
                           'XJ', --���ʽ
                           P_PAYPOINT, --�ɷѵص�
                           P_BATCH, --�ɷ���������
                           'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                           '', --��Ʊ��
                           V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                           );
    ------- END OF  Ԥ����� ����----------------------------------------------------------
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END F_REMAIND_TRANS1;

  /*******************************************************************************************
  ��������SP_AUTO_PAY
  ��;��
      ��ͨˮ���Զ�Ԥ��ֿ۽ɷ�
  ҵ�����

  ������  --ˮ���
  ǰ��������
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY(P_MIID IN METERINFO.MIID%TYPE) IS

    RL_INFO RECLIST%ROWTYPE; --Ӧ����Ϣ
    MINFO   METERINFO%ROWTYPE; --ˮ����Ϣ
    PM      PAYMENT%ROWTYPE; --ʵ����Ϣ
    RECJE   RECLIST.RLJE%TYPE; --Ӧ��ˮ��
    V_ZNJ   RECLIST.RLZNJ%TYPE; --Ӧ��ΥԼ��
    V_TOTAL NUMBER; --��Ƿ��

    V_SRESULT VARCHAR2(3);

    ERR_JE EXCEPTION;
  BEGIN
    --ˮ����Ϣ
    SELECT T.* INTO MINFO FROM METERINFO T WHERE T.MIID = P_MIID;
    --��ǰˮ����Ƿ��
    V_TOTAL := GETREC(P_MIID, RECJE, V_ZNJ);

    IF MINFO.MISAVING < V_TOTAL THEN
      RAISE ERR_JE;
    END IF;
    --����׼��
    PM.PPOSITION := MINFO.MISMFID;
    PM.PPER      := 'SYS';
    PM.PSPJE     := RECJE;
    PM.PZNJ      := V_ZNJ;
    PM.PSXF      := 0;
    PM.PPAYMENT  := 0;
    PM.PTRANS    := PAYTRANS_Ԥ��ֿ�;
    PM.PMID      := P_MIID;
    PM.PPAYWAY   := 'XJ';
    PM.PPAYPOINT := MINFO.MISMFID;
    PM.PBATCH    := FGETSEQUENCE('ENTRUSTLOG');

    --����ˮ������
    V_SRESULT := F_POS_1METER(PM.PPOSITION, --�ɷѻ���
                              PM.PPER, --�տ�Ա
                              'ALL', --Ӧ����ˮ����ȫ������
                              PM.PSPJE, --Ӧ���ܽ��
                              PM.PZNJ, --����ΥԼ��
                              PM.PSXF, --������
                              PM.PPAYMENT, --ʵ���տ�
                              PM.PTRANS, --�ɷ��£�                             
                              PM.PMID, --ˮ�����Ϻ�
                              PM.PPAYWAY, --���ʽ
                              PM.PPAYPOINT, --�ɷѵص�
                              PM.PBATCH, --��������
                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                              '',
                              'Y');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('SP_AUTO_PAY', 1, '', 'ˮ���:' || P_MIID);
  END SP_AUTO_PAY;

  /*******************************************************************************************
  ��������SP_AUTO_PAY_1REC
  ��;��
      ��ͨˮ��1��Ӧ�ռ�¼�Զ�Ԥ��ֿ۽ɷ�
  ҵ�����

  ������  --Ӧ����ˮid
  ǰ��������
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY_1REC(P_REC IN RECLIST%ROWTYPE) IS

    RL_INFO RECLIST%ROWTYPE; --Ӧ����Ϣ
    MINFO   METERINFO%ROWTYPE; --ˮ����Ϣ
    PM      PAYMENT%ROWTYPE; --ʵ����Ϣ
    RECJE   RECLIST.RLJE%TYPE; --Ӧ��ˮ��
    V_ZNJ   RECLIST.RLZNJ%TYPE; --Ӧ��ΥԼ��
    V_TOTAL NUMBER; --��Ƿ��

    V_SRESULT VARCHAR2(3);

    ERR_JE EXCEPTION;
  BEGIN
    --ˮ����Ϣ
    SELECT T.* INTO MINFO FROM METERINFO T WHERE T.MIID = P_REC.RLMID;

    IF MINFO.MISAVING < P_REC.RLJE THEN
      RAISE ERR_JE;
    END IF;

    --����׼��
    PM.PPOSITION := MINFO.MISMFID;
    PM.PPER      := 'SYS';
    PM.PSPJE     := RECJE;
    PM.PZNJ      := GETZNJADJ(P_REC.RLID, --Ӧ����ˮ
                              P_REC.RLJE, --Ӧ�ս��
                              P_REC.RLGROUP, --Ӧ�����
                              P_REC.RLZNDATE, --���ɽ�������
                              MINFO.MISMFID, --ˮ��Ӫҵ��
                              SYSDATE --������'������'ΥԼ��
                              );
    PM.PSXF      := 0;
    PM.PPAYMENT  := 0;
    PM.PTRANS    := PAYTRANS_Ԥ��ֿ�;
    PM.PMID      := P_REC.RLMID;
    PM.PPAYWAY   := 'XJ';
    PM.PPAYPOINT := MINFO.MISMFID;
    PM.PBATCH    := FGETSEQUENCE('ENTRUSTLOG');

    --����ˮ������
    V_SRESULT := F_POS_1METER(PM.PPOSITION, --�ɷѻ���
                              PM.PPER, --�տ�Ա
                              P_REC.RLID, --Ӧ����ˮ����
                              PM.PSPJE, --Ӧ���ܽ��
                              PM.PZNJ, --����ΥԼ��
                              PM.PSXF, --������
                              PM.PPAYMENT, --ʵ���տ�
                              PM.PTRANS, --�ɷ�����
                              PM.PMID, --ˮ�����Ϻ�
                              PM.PPAYWAY, --���ʽ
                              PM.PPAYPOINT, --�ɷѵص�
                              PM.PBATCH, --��������
                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                              '',
                              'Y');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('SP_AUTO_PAY_1REC',
                           1,
                           '',
                           'Ӧ����ˮ:' || P_REC.RLID);
  END SP_AUTO_PAY_1REC;

  /*******************************************************************************************
  ��������F_PAYBACK_BY_PMID
  ��;��ʵ�ճ���,��ʵ����ˮid����
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN PAYMENT.PID%TYPE,
                             P_POSITION IN PAYMENT.PPOSITION%TYPE,
                             P_OPER     IN PAYMENT.PPER%TYPE,
                             P_BATCH    IN PAYMENT.PBATCH%TYPE,
                             P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                             P_TRANS    IN PAYMENT.PTRANS%TYPE,
                             P_COMMIT   IN VARCHAR2) RETURN VARCHAR2 IS

    PM PAYMENT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������
    V_RECID  RECLIST.RLID%TYPE;

    ERR_SAVING EXCEPTION;
  BEGIN
    --STEP 1:ʵ���ʴ���----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := 'ʵ���ʴ���';
    --����Ƿ��з��������Ĵ�������¼
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PID = P_PAYID
       AND T.PREVERSEFLAG <> 'Y';

    --ȡˮ����Ϣ
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = PM.PMID;

    /*--��鵱ǰԤ���Ƿ񹻳�������,�������˳� [yujia 2012-02-08]
    IF PM.PSAVINGBQ>MI.MISAVING THEN
       RAISE ERR_SAVING;
    END IF;*/

    --׼��ʵ�ճ�������¼������
    PM.PPOSITION    := P_POSITION; --����
    PM.PPER         := P_OPER; --����
    PM.PSAVINGQC    := MI.MISAVING; --ȡ��ǰ
    PM.PSAVINGBQ    := 0 - PM.PSAVINGBQ; --ȡ��
    PM.PSAVINGQM    := MI.MISAVING + PM.PSAVINGBQ; --����
    PM.PPAYMENT     := 0 - PM.PPAYMENT; --ȡ��
    PM.PBATCH       := P_BATCH; --����
    PM.PPAYEE       := P_OPER; --����
    PM.PPAYPOINT    := P_PAYPOINT; --����
    PM.PSXF         := 0 - PM.PSXF; --ȡ��
    PM.PILID        := ''; --��
    PM.PZNJ         := 0 - PM.PZNJ; --ȡ��
    PM.PRCRECEIVED  := 0 - PM.PRCRECEIVED; --ȡ��
    PM.PSPJE        := 0 - PM.PSPJE; --ȡ��
    PM.PREVERSEFLAG := 'Y'; --Y
    PM.PSCRID       := PM.PID; --ԭ��¼.PID
    PM.PSCRTRANS    := PM.PTRANS; --ԭ��¼.PTRANS
    PM.PSCRMONTH    := PM.PMONTH; --ԭ��¼.PMONTH
    PM.PSCRDATE     := PM.PDATE; --ԭ��¼.PDATE
    ----���¼���������ֵһ��Ҫ������󣬺ʹ����й�
    PM.PID       := FGETSEQUENCE('PAYMENT'); --������
    PM.PDATE     := TOOLS.FGETPAYDATE(PM.PPOSITION); --SYSDATE
    PM.PDATETIME := SYSDATE; --SYSDATE
    PM.PMONTH    := TOOLS.FGETPAYMONTH(PM.PPOSITION); --��ǰ�·�
    PM.PTRANS    := P_TRANS; --����
    -----------------------------------------------------------------
    --�������ʵ�ո���¼
    INSERT INTO PAYMENT T VALUES PM;
    --ԭ��������¼���ϳ�����־
    UPDATE PAYMENT T SET T.PREVERSEFLAG = 'Y' WHERE T.PID = P_PAYID;
    --END OF STEP 1: ��������---------------------------------------------------
    --PAYMENT ��������һ������¼
    -- ��������¼�ĳ�����־ΪY
    ----------------------------------------------------------------------------------------

    --Ӧ���˴���--------------------------------------------------------------
    -----STEP 10: ���Ӹ�Ӧ�ռ�¼
    ------����ʱ���д����Ҫ���������Ӧ�����˺���ϸ�ʼ�¼
    ---�������ʱ��
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---������Ҫ���������Ӧ�����˼�¼
    V_STEP    := 10;
    V_PRC_MSG := '������Ҫ���������Ӧ�����˼�¼';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---������Ҫ���������Ӧ����ϸ�ʼ�¼
    V_STEP    := 11;
    V_PRC_MSG := '������Ҫ���������Ӧ����ϸ�ʼ�¼';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---��Ӧ��������ʱ����������¼�ĵ���
    V_STEP    := 12;
    V_PRC_MSG := '��Ӧ��������ʱ����������¼�ĵ���';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID          = FGETSEQUENCE('RECLIST'),
           T.RLMONTH       = PM.PMONTH, --��ǰ              �����·�
           T.RLDATE        = PM.PDATE, --��ǰ              ��������
           T.RLCHARGEPER   = PM.PPER, --ͬʵ��           �շ�Ա
           T.RLSL          = 0 - T.RLSL, --ȡ��              Ӧ��ˮ��
           T.RLJE          = 0 - T.RLJE, --ȡ��             Ӧ�ս��
           T.RLADDSL       = 0 - T.RLADDSL, --ȡ��             �ӵ�ˮ��
           T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
           T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
           T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�
           T.RLPAIDJE      = 0 - T.RLPAIDJE, --ȡ��              ���ʽ��
           T.RLPAIDFLAG    = 'Y', --Y                 ���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
           T.RLPAIDPER     = PM.PPER, --ͬʵ��           ������Ա
           T.RLPAIDDATE    = PM.PDATE, --ͬʵ��            ��������
           T.RLZNJ         = 0 - T.RLZNJ, --ȡ��             ΥԼ��
           T.RLDATETIME    = SYSDATE, --SYSDATE          ��������
           T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE    ԭ��������
           T.RLPID         = PM.PID, --��Ӧ�ĸ�ʵ����ˮ  ʵ����ˮ����payment.pid��Ӧ��
           T.RLPBATCH      = PM.PBATCH, --��Ӧ�ĸ�ʵ����ˮ  �ɷѽ������Σ���payment.PBATCH��Ӧ��
           T.RLSAVINGQC    = T.RLSAVINGQM, --����             �ڳ�Ԥ�棨����ʱ������
           T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --����             ����Ԥ�淢��������ʱ������
           T.RLSAVINGQM    = T.RLSAVINGQC + T.RLSAVINGBQ, --����             ��ĩԤ�棨����ʱ������
           T.RLREVERSEFLAG = 'Y', --Y                   ������־��NΪ������YΪ������
           T.RLSXF         = 0 - T.RLSXF;

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 13;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';

    ------
    INSERT INTO PBPARMTEMP_TEST T
      (SELECT S.RLID,
              S.RLSMFID,
              S.RLMONTH,
              S.RLDATE,
              S.RLCID,
              S.RLMID,
              S.RLMSMFID,
              S.RLCSMFID,
              S.RLCCODE,
              S.RLCHARGEPER,
              S.RLCPID,
              S.RLCCLASS,
              S.RLCFLAG,
              S.RLUSENUM,
              S.RLCNAME,
              S.RLCADR,
              S.RLMADR,
              S.RLCSTATUS,
              S.RLMTEL,
              S.RLTEL,
              S.RLBANKID,
              S.RLTSBANKID,
              S.RLACCOUNTNO,
              S.RLACCOUNTNAME,
              S.RLIFTAX,
              S.RLTAXNO,
              S.RLIFINV,
              S.RLMCODE,
              S.RLMPID,
              S.RLMCLASS,
              S.RLMFLAG,
              S.RLMSFID,
              S.RLDAY,
              S.RLBFID,
              S.RLPRDATE,
              S.RLRDATE,
              S.RLZNDATE,
              S.RLCALIBER,
              S.RLRTID,
              S.RLMSTATUS,
              S.RLMTYPE,
              S.RLMNO,
              S.RLSCODE,
              S.RLECODE,
              S.RLREADSL,
              S.RLINVMEMO,
              S.RLENTRUSTBATCH,
              S.RLENTRUSTSEQNO,
              S.RLOUTFLAG,
              S.RLTRANS,
              S.RLCD,
              S.RLYSCHARGETYPE,
              S.RLSL,
              S.RLJE,
              S.RLADDSL,
              S.RLSCRRLID,
              S.RLSCRRLTRANS,
              S.RLSCRRLMONTH,
              S.RLPAIDJE,
              S.RLPAIDFLAG,
              S.RLPAIDPER,
              S.RLPAIDDATE,
              S.RLMRID,
              S.RLMEMO,
              S.RLZNJ,
              S.RLLB,
              S.RLCNAME2,
              S.RLPFID,
              S.RLDATETIME,
              S.RLSCRRLDATE,
              S.RLPRIMCODE,
              S.RLPRIFLAG,
              S.RLRPER,
              S.RLSAFID,
              S.RLSCODECHAR,
              S.RLECODECHAR,
              S.RLILID,
              S.RLMIUIID,
              S.RLGROUP,
              S.RLPID,
              S.RLPBATCH,
              S.RLSAVINGQC,
              S.RLSAVINGBQ,
              S.RLSAVINGQM,
              S.RLREVERSEFLAG,
              S.RLBADFLAG,
              S.RLZNJREDUCFLAG,
              S.RLMISTID,
              S.RLMINAME,
              S.RLSXF,
              S.RLMIFACE2,
              S.RLMIFACE3,
              S.RLMIFACE4,
              S.RLMIIFCKF,
              S.RLMIGPS,
              S.RLMIQFH,
              S.RLMIBOX,
              S.RLMINAME2,
              S.RLMISEQNO,
              S.RLMISAVING
         FROM RECLIST_1METER_TMP S);
    COMMIT;
    ------

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---��Ӧ����ϸ��ʱ����������¼�ĵ���
    V_STEP    := 14;
    V_PRC_MSG := '��Ӧ����ϸ��ʱ����������¼�ĵ���';

    --һ���ֶε���
    UPDATE RECDETAIL_TMP T
       SET T.RDYSSL  = 0 - T.RDYSSL,
           T.RDYSJE  = 0 - T.RDYSJE,
           T.RDSL    = 0 - T.RDSL,
           T.RDJE    = 0 - T.RDJE,
           T.RDADJSL = 0 - T.RDADJSL,
           T.RDADJJE = 0 - T.RDADJJE,
           T.RDZNJ   = 0 - T.RDZNJ;
    --��ˮid����
    UPDATE RECDETAIL_TMP T
       SET T.RDID =
           (SELECT S.RLID
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLSCRRLID)
     WHERE T.RDID IN (SELECT RLSCRRLID FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);

    -----END OF  STEP 10: ���Ӹ�Ӧ�ռ�¼�������---------------------------------------

    -----STEP 20: ������Ӧ�ռ�¼--------------------------------------------------------------
    ------����ʱ���д����Ҫ���������Ӧ�����˺���ϸ�ʼ�¼
    ---�������ʱ��
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---������Ҫ���������Ӧ�����˼�¼
    V_STEP    := 20;
    V_PRC_MSG := '������Ҫ���������Ӧ�����˼�¼';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---������Ҫ���������Ӧ����ϸ�ʼ�¼
    V_STEP    := 21;
    V_PRC_MSG := '������Ҫ���������Ӧ����ϸ�ʼ�¼';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---��Ӧ��������ʱ����������¼�ĵ���
    V_STEP    := 22;
    V_PRC_MSG := '��Ӧ��������ʱ����������¼�ĵ���';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID          = FGETSEQUENCE('RECLIST'), --������
           T.RLMONTH       = PM.PMONTH, --��ǰ
           T.RLDATE        = PM.PDATE, --��ǰ
           T.RLCHARGEPER   = '', --��
           T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID
           T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS
           T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH
           T.RLPAIDFLAG    = 'N', --N
           T.RLPAIDPER     = '', --��
           T.RLPAIDDATE    = '', --��
           T.RLDATETIME    = SYSDATE, --SYSDATE
           T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE
           T.RLPID         = NULL, --��
           T.RLPBATCH      = NULL, --��
           T.RLSAVINGQC    = NULL, --��
           T.RLSAVINGBQ    = NULL, --��
           T.RLSAVINGQM    = NULL, --��
           T.RLREVERSEFLAG = 'N',
           T.RLPAIDJE      = 0,
           T.RLOUTFLAG     = 'N'; --N
    --        T.RLSXF         =NULL

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 23;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';
    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---��Ӧ����ϸ��ʱ����������¼�ĵ���
    V_STEP    := 14;
    V_PRC_MSG := '��Ӧ����ϸ��ʱ����������¼�ĵ���';

    UPDATE RECDETAIL_TMP T
       SET (T.RDID,
            T.RDPAIDFLAG,
            T.RDPAIDDATE,
            T.RDPAIDMONTH,
            T.RDPAIDPER,
            T.RDMONTH) =
           (SELECT S.RLID, 'N', NULL, NULL, NULL, S.RLMONTH
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLSCRRLID)
     WHERE T.RDID IN (SELECT RLSCRRLID FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);

    ----END OF STEP 20: ������Ӧ�ռ�¼  ������� ------------------------------------------
    ----STEP 30 ԭӦ�ռ�¼��������
    V_STEP    := 30;
    V_PRC_MSG := 'ԭӦ�ռ�¼��������';
    UPDATE RECLIST T
       SET T.RLREVERSEFLAG = 'Y'

     WHERE T.RLPID = P_PAYID
       AND T.RLPAIDFLAG = 'Y';
    --END OF  Ӧ���˴������--------------------------------------------------------------

    --STEP 40 ˮ������Ԥ��������--------------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := 'ˮ������Ԥ��������';
    UPDATE METERINFO T
       SET T.MISAVING = PM.PSAVINGQM, T.MIPAYMENTID = P_PAYID
     WHERE T.MIID = PM.PMID;
    -- END OF STEP 40 ˮ������Ԥ��������------------------------------------------------------------

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END F_PAYBACK_BY_PMID;

  /*******************************************************************************************
  ��������F_PAYBACK_BY_BANKNO
  ��;��ʵ�ճ���,��������ˮid����
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BANKNO(P_BSEQNO   IN PAYMENT.PBSEQNO%TYPE,
                               P_POSITION IN PAYMENT.PPOSITION%TYPE,
                               P_OPER     IN PAYMENT.PPER%TYPE,
                               P_BATCH    IN PAYMENT.PBATCH%TYPE,
                               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                               P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2 IS
    PM PAYMENT%ROWTYPE;
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������
    V_RECID  RECLIST.RLID%TYPE;

    ERR_SAVING EXCEPTION;
  BEGIN
    --STEP 1:ʵ���ʴ���----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := 'ʵ���ʴ���';
    --����Ƿ��з��������Ĵ�������¼
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PBSEQNO = P_BSEQNO
       AND T.PREVERSEFLAG <> 'Y';
    --����ʵ����ˮ ����
    V_RESULT := F_PAYBACK_BY_PMID(PM.PID,
                                  P_POSITION,
                                  P_OPER,
                                  P_BATCH,
                                  P_PAYPOINT,
                                  P_TRANS,
                                  'Y');
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '001';
    WHEN OTHERS THEN
      RETURN '009';
  END F_PAYBACK_BY_BANKNO;

  /*******************************************************************************************
  ��������F_PAYBACK_BATCH
  ��;��ʵ�ճ���,�����γ���
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                              P_POSITION IN PAYMENT.PPOSITION%TYPE,
                              P_OPER     IN PAYMENT.PPER%TYPE,
                              P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                              P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2 IS

    --���������ڴ�˵��

    CURSOR C_PM IS
      SELECT T.*
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH
         AND T.PREVERSEFLAG <> 'Y'
       ORDER BY T.PID DESC;

    PM        PAYMENT%ROWTYPE;
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������
    V_RECID  RECLIST.RLID%TYPE;

    V_BATCH PAYMENT.PID%TYPE;

    ERR_PAYBACK EXCEPTION;
  BEGIN
    --STEP 1:ʵ���ʴ���----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := 'ʵ���ʴ���';
    --����Ƿ��з��������Ĵ�������¼
    OPEN C_PM;
    LOOP
      FETCH C_PM
        INTO PM;
      EXIT WHEN C_PM%NOTFOUND OR C_PM%NOTFOUND IS NULL;

      --�������κ�
      V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
      --����ʵ����ˮ ����
      V_RESULT := F_PAYBACK_BY_PMID(PM.PID,
                                    P_POSITION,
                                    P_OPER,
                                    P_BATCH,
                                    P_PAYPOINT,
                                    P_TRANS,
                                    'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAYBACK;
      END IF;
    END LOOP;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BATCH);
    COMMIT;
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '001';
    WHEN OTHERS THEN
      RETURN '009';
  END F_PAYBACK_BY_BATCH;
  /*******************************************************************************************
  �����������ص����ݿ����

  /*-- Create table
  DROP  TABLE reclist_1meter_tmp;
  create global temporary table reclist_1meter_tmp  on commit delete rows
  as (select * from reclist s where s.rlid='1');

  -- Create table
  DROP  TABLE PAY_PARA_TMP;
  create global temporary table PAY_PARA_TMP  on commit delete rows
  as (select * from reclist s where s.rlid='1');

  -- Create table
  create table CHK_RESULT
  (
    ID         NUMBER not null,
    CHK_TIME   DATE,
    CHK_ITEM   VARCHAR2(100),
    CHK_RESULT VARCHAR2(100),
    PID        VARCHAR2(10),
    PARA       VARCHAR2(400),
    REMARK     VARCHAR2(1000)
  )
  tablespace USERS
    pctfree 10
    initrans 1
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );
  -- Add comments to the table
  comment on table CHK_RESULT
    is 'ҵ�����쳣�嵥';
  -- Add comments to the columns
  comment on column CHK_RESULT.ID
    is '��ˮ��';
  comment on column CHK_RESULT.CHK_TIME
    is '���ʱ��';
  comment on column CHK_RESULT.CHK_ITEM
    is '�����Ŀ';
  comment on column CHK_RESULT.PID
    is '��ص�id';
  comment on column CHK_RESULT.PARA
    is '��ز���˵��';
  comment on column CHK_RESULT.REMARK
    is '��ע';
  -- Create/Recreate primary, unique and foreign key constraints
  alter table CHK_RESULT
    add constraint PK_CHK_RESULT primary key (ID)
    using index
    tablespace USERS
    pctfree 10
    initrans 2
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );
  -- Create/Recreate indexes
  create index IDX_CHK_RESULT1 on CHK_RESULT (CHK_ITEM, CHK_TIME)
    tablespace USERS
    pctfree 10
    initrans 2
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );

  -- Create sequence
  create sequence SEQ_CHK_LIST
  minvalue 1
  maxvalue 9999999999
  start with 21
  increment by 1
  cache 20
  order;
  *******************************************************************************************/

----------------------------------------------------------------------------------------------------------

BEGIN
  CURDATE                := SYSDATE;
  ȫ��˾ͳһ��׼�����ɽ� := FSYSPARA('1090'); --ȫ��˾ͳһ��׼�����ɽ�(1),��Ӫҵ����׼�����ɽ�(2)
END;
/


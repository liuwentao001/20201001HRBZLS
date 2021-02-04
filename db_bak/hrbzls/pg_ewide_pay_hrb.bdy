CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_PAY_HRB" IS
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
    ZAL          ZNJADJUSTLIST%ROWTYPE;
    JE           NUMBER;
    V_MID        VARCHAR(10);
    V_RLMIEMAIL  VARCHAR2(64);
    V_RLOUTFLAG  RECLIST.RLOUTFLAG%TYPE;
    V_RLZNJ      RECLIST.RLZNJ%TYPE;
    V_RLJE       NUMBER(12, 3);
    V_MATSBANKID VARCHAR(10);
  BEGIN

    BEGIN
      SELECT RLMID, RL.RLZNJ
        INTO V_MID, V_RLZNJ
        FROM RECLIST RL
       WHERE RL.RLID = P_RLID;
    END;
    IF V_RLZNJ > 0 THEN
      RETURN V_RLZNJ;
    END IF;

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
    ELSE
      IF F_GETIFZNJ(V_MID) = 'N' THEN
        RETURN 0;
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
    v_para   syspara.spvalue%type;
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

/*
    VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
    VP.PDATETIME := SYSDATE;
    VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
                        TO_CHAR(SYSDATE, 'yyyy.mm'));*/

		--��� ��ĩ�Զ�Ԥ��ֿ� ����,����������ȡϵͳ����!
		if pg_auto_task.ISRUNNING('805') = 'Y' then
			v_para := nvl(FSYSPARA('Y001'),to_char(sysdate,'yyyymmddhh24miss'));
			VP.PDATE     := to_date(v_para,'yyyymmddhh24miss');
      VP.PDATETIME := to_date(v_para,'yyyymmddhh24miss');
      VP.PMONTH    := substr(v_para,1,4) || '.' || substr(v_para,5,2);
	  else
			VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
			VP.PDATETIME := SYSDATE;
			VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
													TO_CHAR(SYSDATE, 'yyyy.mm'));
	  end if;

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

    VP.PREVERSEFLAG := 'N'; --������־='N'
    VP.PSCRID       := VP.PID; --ԭʵ������ˮ��Ӧ�ճ�ʵ�����ĸ���ʱpayment.pscrid���գ���Ϊ����ʵ������ˮ�ţ����ڹ������뱻��Ĺ������������payment.pscridΪ�գ�
    VP.PSCRTRANS    := VP.PTRANS; --  ԭʵ�սɷ�����ʵ�ճ��������ĸ���ʱpayment.pscrtrans���գ���Ϊ����Ӧ�����������ڹ������뱻��Ĺ������������payment.pscrtransΪ�գ�
    VP.PSCRMONTH    := VP.PMONTH; --ԭʵ�����·ݣ�ʵ�ճ���������ʲ�����ʵ���ʣ��������ɸ�ʵ���ʵ�ԭʵ�����·��뱻����ʵ�����·���ͬ���磺a�û�2011��8�½�һ��ˮ�ѣ�����ˮ��˾��2011��9�·�����������⣬��Ҫ��ʵ�ճ�������ʵ�ճ���ʱ�����һ��2011��9�¸�ʵ�ʣ�2011��9�¸���ԭʵ�����·�Ϊ2011��8�£�
    VP.PSCRDATE     := VP.PDATE; --ԭʵ������

    IF P_IFP = 'Y' THEN
      VP.PILID := P_INVNO; --��Ʊ��ˮ��
    END IF;
    VP.PFLAG := 'Y';
    VP.PZNJ  := P_ZNJ;

    VP.PREVERSEFLAG := 'N'; --������־='N'
    VP.PPRIID := P_MIID;

    --�������ģ��ɷ� Ҫ����һ��������ˮ��(�����ܲ�����ȷ����)
    if P_TRANS = 'Q' then
      vp.pbseqno := to_char(sysdate,'yyyymmddhh24miss') || '#MN';
    end if;

    INSERT INTO PAYMENT VALUES VP;
    ------- END OF  ��¼ʵ����
    ----�ɷѻ��ɷѽ��С��Ƿ�ѽ����������Ԥ�洦��
   -- IF (substr(P_OPER,1,3) = 'ATM'AND VP.PSPJE+VP.PSXF+VP.PZNJ+NVL(MI.Misaving,0) > P_PAYJE) OR (substr(P_OPER,1,3) = 'ATM'AND P_RLJE = 0) THEN
  --    GOTO PAY_SAVING_ATM;
  --  END IF;
    ----�Ƿ񵥽�Ԥ�棿Ƿ�ѽ��Ϊ0 ����Ϊ����Ԥ�棬���账��Ӧ��ϸ�ڣ�ֱ����ת
    IF  P_RLJE = 0 THEN
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
   /* -----------------------------------------
    OPEN C_RD; --Ӧ����ϸ�ʼ���
    UPDATE RECDETAIL T
       SET T.RDPAIDFLAG  = 'Y', --���ʱ�־
           T.RDPAIDDATE  = VP.PDATE, --��������
           T.RDPAIDMONTH = VP.PMONTH, --�����·�
           T.RDPAIDPER   = VP.PPER --�շ�Ա
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --Ӧ����ϸ�ʽ���
    --add 2013.02.01  ����reclist_charge_01���е�rdpaidmonth�ֶ�
    OPEN C_RD;
    UPDATE RECLIST_CHARGE_01 T
       SET T.RDPAIDMONTH = VP.PMONTH
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD;
    --add 2013.02.01
    \******************* ��д���ɽ�  by lgb 2012-06-01**********************************\
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
*/
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

   FUNCTION F_PAY_CORE_test(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
    v_sysdate date ;
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
     select to_date('20150331220000','yyyymmddhh24miss') into v_sysdate from dual ;

    ------STEP 20: ��¼ʵ����
    V_STEP       := 20;
    V_PRC_MSG    := '��¼ʵ����';
    P_PAYID      := FGETSEQUENCE('PAYMENT'); --PAYMENT������ˮ��ÿ�����ʽ���һ����¼
    VP.PID       := P_PAYID;
    VP.PCID      := MI.MICID;
    VP.PCCODE    := CI.CICODE;
    VP.PMID      := MI.MIID;
    VP.PMCODE    := MI.MICODE;
  --  VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
   -- VP.PDATETIME := SYSDATE;
     VP.PDATE :=   v_sysdate ;
     VP.PDATETIME := v_sysdate;
       VP.PMONTH    :=TO_CHAR(v_sysdate, 'yyyy.mm');

/*    VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
                        TO_CHAR(SYSDATE, 'yyyy.mm'));*/
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

    VP.PREVERSEFLAG := 'N'; --������־='N'
    VP.PSCRID       := VP.PID; --ԭʵ������ˮ��Ӧ�ճ�ʵ�����ĸ���ʱpayment.pscrid���գ���Ϊ����ʵ������ˮ�ţ����ڹ������뱻��Ĺ������������payment.pscridΪ�գ�
    VP.PSCRTRANS    := VP.PTRANS; --  ԭʵ�սɷ�����ʵ�ճ��������ĸ���ʱpayment.pscrtrans���գ���Ϊ����Ӧ�����������ڹ������뱻��Ĺ������������payment.pscrtransΪ�գ�
    VP.PSCRMONTH    := VP.PMONTH; --ԭʵ�����·ݣ�ʵ�ճ���������ʲ�����ʵ���ʣ��������ɸ�ʵ���ʵ�ԭʵ�����·��뱻����ʵ�����·���ͬ���磺a�û�2011��8�½�һ��ˮ�ѣ�����ˮ��˾��2011��9�·�����������⣬��Ҫ��ʵ�ճ�������ʵ�ճ���ʱ�����һ��2011��9�¸�ʵ�ʣ�2011��9�¸���ԭʵ�����·�Ϊ2011��8�£�
    VP.PSCRDATE     := VP.PDATE; --ԭʵ������

    IF P_IFP = 'Y' THEN
      VP.PILID := P_INVNO; --��Ʊ��ˮ��
    END IF;
    VP.PFLAG := 'Y';
    VP.PZNJ  := P_ZNJ;

    VP.PREVERSEFLAG := 'N'; --������־='N'
    VP.PPRIID := P_MIID;
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
   /* -----------------------------------------
    OPEN C_RD; --Ӧ����ϸ�ʼ���
    UPDATE RECDETAIL T
       SET T.RDPAIDFLAG  = 'Y', --���ʱ�־
           T.RDPAIDDATE  = VP.PDATE, --��������
           T.RDPAIDMONTH = VP.PMONTH, --�����·�
           T.RDPAIDPER   = VP.PPER --�շ�Ա
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --Ӧ����ϸ�ʽ���
    --add 2013.02.01  ����reclist_charge_01���е�rdpaidmonth�ֶ�
    OPEN C_RD;
    UPDATE RECLIST_CHARGE_01 T
       SET T.RDPAIDMONTH = VP.PMONTH
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD;
    --add 2013.02.01
    \******************* ��д���ɽ�  by lgb 2012-06-01**********************************\
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
*/
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
  END F_PAY_CORE_test;

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

   if P_PAYJE < 0 then  --��Ԥ�� ʱĬ�� 20141124  hb
      V_RCOUNT := 1;
   end if ;

    RETURN V_RCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END F_PSET_RECLIST;

  /*******************************************************************************************
    ��������f_set_cr_reclist
    ��;�� �������ɺ���ʵ�ճ����ʹ��̵��ã�����ǰ��������Ӧ�ռ�¼��¼���Ѿ��ڴ�RECLIST �п�������ʱ���У�����������ʱ�����������������
    ����������󣬺��ĳ������̸�����ʱ�����RECLIST ���ﵽ��ݳ���Ŀ�ġ�
               ���������Ŀ�ģ�����������Ԥ���������䵽Ӧ���ʼ�¼�ϣ�Ԥ�����
    ���ӣ� Aˮ������Ƿ��110Ԫ���ڳ�Ԥ��30Ԫ�������շ�100Ԫ��ΥԼ��5Ԫ��Ӧ�ճ������¼���£�
    ----------------------------------------------------------------------------------------------------
     ��     ��       Ԥ��     �����շ�    Ӧ��ˮ��     ΥԼ��    Ԥ����ĩ   Ԥ�淢��
    ----------------------------------------------------------------------------------------------------
  ԭ  2011.06         30          100           110         5        15         15
  ��  2011.06         30         -100           -110       -5        15        -15
      -----------------------------------------------------------------------------------------------------
    ������pm ��ʵ�� ��
    *******************************************************************************************/

  FUNCTION F_SET_CR_RECLIST(PM IN PAYMENT%ROWTYPE --����ʵ��
                            ) RETURN NUMBER AS
    --Ӧ����������ʱ���α�,��ԭӦ�����·�����
    CURSOR C_RL IS
      SELECT T.*
        FROM RECLIST_1METER_TMP T
       ORDER BY T.RLSCRRLMONTH, T.RLGROUP;

    V_RCOUNT NUMBER;
    V_RL     RECLIST%ROWTYPE;
    V_QC     NUMBER;

  BEGIN
    V_RCOUNT := 0;

    OPEN C_RL;
    V_QC := PM.PSAVINGQM;
    LOOP
      FETCH C_RL
        INTO V_RL;

      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;

      --����Ӧ�ռ�¼���Ԥ����ĩ
      V_RL.RLSAVINGQM := V_QC;
      V_RL.RLSAVINGBQ := -V_RL.RLSAVINGBQ;
      V_RL.RLSAVINGQC := V_RL.RLSAVINGQM - V_RL.RLSAVINGBQ; --����Ӧ�ռ�¼ʱ��Ԥ���ڳ�
      ----����Ӧ�ռ�¼ʱ��Ԥ�淢��
      V_QC := V_RL.RLSAVINGQC; --��һ����ĩ����Ϊ��һ���ڳ�
      ----�������------------------------------------------------------------------------------------------------

      ---������ʱӦ�ձ�
      UPDATE RECLIST_1METER_TMP T
         SET T.RLID    = FGETSEQUENCE('RECLIST'),
             T.RLMONTH = TOOLS.FGETRECMONTH(T.RLMSMFID), --��ǰ              �����·�
             T.RLDATE  = TOOLS.FGETRECDATE(T.RLMSMFID), --��ǰ              ��������
             /* T.RLMONTH = PM.PMONTH, --��ǰ              �����·�
             T.RLDATE  = PM.PDATE, --��ǰ              ��������*/
             T.RLREADSL       = 0 - T.RLREADSL, --����ˮ��
             T.RLENTRUSTBATCH = NULL, --���մ�������
             T.RLENTRUSTSEQNO = NULL, -- ���մ�����ˮ��
             -- T.RLCHARGEPER   = PM.PPER, --ͬʵ��            �շ�Ա
             T.RLSL    = 0 - T.RLSL, --ȡ��              Ӧ��ˮ��
             T.RLJE    = 0 - T.RLJE, --ȡ��              Ӧ�ս��
             T.RLADDSL = 0 - T.RLADDSL, --ȡ��              �ӵ�ˮ��

             T.RLCOLUMN9  = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
             T.RLCOLUMN11 = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
             T.RLCOLUMN10 = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�
             T.RLCOLUMN5  = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������

             /*T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
             T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
             T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�*/
             T.RLPAIDJE = 0 - T.RLPAIDJE, --ȡ��              ���ʽ��
             --T.RLPAIDFLAG    = 'Y', --Y                 ���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
             T.RLPAIDPER  = PM.PPER, --ͬʵ��            ������Ա
             T.RLPAIDDATE = PM.PDATE, --ͬʵ��            ��������
             T.RLZNJ      = 0 - T.RLZNJ, --ȡ��              ΥԼ��
             T.RLDATETIME = SYSDATE, --SYSDATE           ��������

             /* T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������*/
             T.RLPID         = PM.PID, --��Ӧ�ĸ�ʵ����ˮ  ʵ����ˮ����payment.pid��Ӧ��
             T.RLPBATCH      = PM.PBATCH, --��Ӧ�ĸ�ʵ����ˮ  �ɷѽ������Σ���payment.PBATCH��Ӧ��
             T.RLSAVINGQC    = V_RL.RLSAVINGQC, --����              �ڳ�Ԥ�棨����ʱ������
             T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --����              ����Ԥ�淢��������ʱ������
             T.RLSAVINGQM    = V_RL.RLSAVINGQM, --����              ��ĩԤ�棨����ʱ������
             T.RLREVERSEFLAG = 'Y', --Y                   ������־��NΪ������YΪ������
             T.RLILID        = NULL, --��Ʊ��ˮ��
             T.RLMISAVING    = 0, --���ʱԤ��
             T.RLPRIORJE     = 0, --���֮ǰǷ��
             T.RLSXF         = 0 - T.RLSXF,
             T.RLPAIDMONTH   = TOOLS.FGETRECMONTH(T.RLMSMFID) --2014/06/01 ֣�˻� ��������¼�������·�Ϊ��ǰ�����·�
       WHERE T.RLID = V_RL.RLID;

      V_RCOUNT := V_RCOUNT + 1;
    END LOOP;

    RETURN V_RCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

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
                        P_COMMIT   IN VARCHAR2, --�����Ƿ��ύ��Y/N��
                        P_MMID     IN VARCHAR2
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
    IF  SUBSTR(P_OPER,1,3) = 'ATM' THEN
      GOTO PAY_SAVING_ATM;
    END IF;
    V_NRESULT := F_CHK_LIST(P_RLJE, --Ӧ�ս��
                            P_ZNJ, --����ΥԼ��
                            P_SXF, --������
                            P_PAYJE, --ʵ���տ�
                            V_MINFO.MISAVING --��ǰԤ��
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;
    <<PAY_SAVING_ATM>>
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
    --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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

FUNCTION F_POS_1METER_ZFB(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
                        P_COMMIT   IN VARCHAR2, --�����Ƿ��ύ��Y/N��
                        p_pbseqno  IN VARCHAR2,  --֧������ˮ
                        P_MMID     IN VARCHAR2
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
    IF  SUBSTR(P_OPER,1,3) = 'ATM' THEN
      GOTO PAY_SAVING_ATM;
    END IF; 
    V_NRESULT := F_CHK_LIST(P_RLJE, --Ӧ�ս��
                            P_ZNJ, --����ΥԼ��
                            P_SXF, --������
                            P_PAYJE, --ʵ���տ�
                            V_MINFO.MISAVING --��ǰԤ��
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;
    <<PAY_SAVING_ATM>>
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
    --���˼�¼���������
    UPDATE PAYMENT 
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;      
        --д�����н�����ˮ
    UPDATE PAYMENT 
    SET pbseqno=p_pbseqno
    WHERE PID=V_PAYID;                     
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
  END F_POS_1METER_ZFB;

 FUNCTION F_POS_1METER_WX(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
                        P_COMMIT   IN VARCHAR2, --�����Ƿ��ύ��Y/N��
                        p_pbseqno  IN VARCHAR2,  --������ˮ
                        P_MMID     IN VARCHAR2,
                        p_pwseqno  IN VARCHAR2,--΢����ˮ
                        p_date     IN VARCHAR2  --��������ʱ��
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
    IF  SUBSTR(P_OPER,1,3) = 'ATM' THEN
      GOTO PAY_SAVING_ATM;
    END IF; 
    V_NRESULT := F_CHK_LIST(P_RLJE, --Ӧ�ս��
                            P_ZNJ, --����ΥԼ��
                            P_SXF, --������
                            P_PAYJE, --ʵ���տ�
                            V_MINFO.MISAVING --��ǰԤ��
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;
    <<PAY_SAVING_ATM>>
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
    --���˼�¼���������
    UPDATE PAYMENT 
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;      
        --д��΢����ˮ
    UPDATE PAYMENT 
    SET PBSEQNO=p_pbseqno,
        PWSEQNO=p_pwseqno,
        PWDATE =p_date
    WHERE PID=V_PAYID;                     
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
  END F_POS_1METER_WX;



FUNCTION F_POS_1METER_test(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
                        P_COMMIT   IN VARCHAR2, --�����Ƿ��ύ��Y/N��
                        P_MMID     IN VARCHAR2
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
    V_SRESULT := F_PAY_CORE_test(P_POSITION, --�ɷѻ���
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
    --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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
  END F_POS_1METER_test;

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
       �������ʱ�ӿڱ� pay_para_tmp
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
    V_PP         pay_para_tmp%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --���˴���
    ERR_JE EXCEPTION; --������

    CURSOR C_M_PAY IS
      SELECT * FROM pay_para_tmp RT;

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
                               'N',
                               V_PP.MID);
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


  FUNCTION F_POS_MULT_M_test(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
    V_PP         pay_para_tmp%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --���˴���
    ERR_JE EXCEPTION; --������

    CURSOR C_M_PAY IS
      SELECT * FROM pay_para_tmp RT;

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
      V_RESULT := F_POS_1METER_test(P_POSITION, --�ɷѻ���
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
                               'N',
                               V_PP.MID);
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
  END F_POS_MULT_M_test;
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
      ˮ���ˮ���Ӧ��Ӧ������ˮ�����������ʱ�ӿڱ� pay_para_tmp ��
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
    V_PP         pay_para_tmp%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --�������κ�
    ERR_PAY EXCEPTION; --���˴���

    V_NRESULT NUMBER; --������

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM pay_para_tmp RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING <> 0; ----���Ƹ۸�Ԥ����Ҫ�����
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
                                    'N',
                                    P_MMID);

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: ������������---------------------------------------------------
    --�����������κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '������������';
    BEGIN
      SELECT RT.* INTO V_PP FROM pay_para_tmp RT WHERE RT.MID = P_MMID;
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
                               'N',
                               P_MMID);
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
                             'P', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                            -- PAYTRANS_YCDB, --�ɷ�����
                             P_FKFS, --���ʽ
                             P_PAYPOINT, --�ɷѵص�
                             P_BATCH, --�ɷ���������
                             'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                             '', --��Ʊ��
                             V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                             );
      --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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
                                    'N',
                                    P_MMID);
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
                                'U', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                              --  P_TRANS, --�ɷ�����
                                V_PP.MID, --ˮ�����Ϻ�
                                P_FKFS, --���ʽ
                                P_PAYPOINT, --�ɷѵص�
                                V_BATCH,
                                P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                P_INVNO, --��Ʊ��
                                'N',
                                P_MMID);
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --һ�����ύ-----------��ʱ����-----------------------------------------------
    --COMMIT;
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

FUNCTION F_POS_MULT_HS_ZFB(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                         P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --���������
                         P_PAYJE    IN NUMBER, --��ʵ���տ���
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                         P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         P_INVNO    IN VARCHAR2, --��Ʊ��
                         p_pbseqno  IN VARCHAR2, --֧������ˮ
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
    V_PP         pay_para_tmp%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --�������κ�
    ERR_PAY EXCEPTION; --���˴���

    V_NRESULT NUMBER; --������

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM pay_para_tmp RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING <> 0; ----���Ƹ۸�Ԥ����Ҫ�����
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
                                    'N',
                                    P_MMID);

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: ������������---------------------------------------------------
    --�����������κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '������������';
    BEGIN
      SELECT RT.* INTO V_PP FROM pay_para_tmp RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER_ZFB(P_POSITION, --�ɷѻ���
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
                               'N',
                               p_pbseqno, --֧������ˮ
                               P_MMID);
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
                             'B', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                            -- PAYTRANS_YCDB, --�ɷ����� 
                             P_FKFS, --���ʽ
                             P_PAYPOINT, --�ɷѵص�
                             P_BATCH, --�ɷ���������
                             'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                             '', --��Ʊ��
                             V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                             );
      --���˼�¼���������
    UPDATE PAYMENT 
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;   
            --д�����н�����ˮ
    UPDATE PAYMENT 
    SET pbseqno=p_pbseqno
    WHERE PID=V_PAYID;  
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
                                    'N',
                                    P_MMID);
      ---END OF STEP 21 Ԥ�������ɣ���̨���ݽ��------------------------------------------
      -- ��PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
      --2����¼ͬһ�����κţ���ˮ�����ʵ����κ�һ����
      --�ӱ��ˮ����Ϣ�У�Ԥ��������ӣ����ӽ���������������Ľ��
      ------------------------------------------------------------------------------------------------
      ---STEP 22: �ӱ�����---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '�����ӱ�����--�ӱ�����';
      V_RESULT  := F_POS_1METER_ZFB(P_POSITION, --�ɷѻ���
                                P_OPER, --�տ�Ա
                                V_PP.PLIDS, --Ӧ����ˮ��
                                V_PP.RLJE, --Ӧ���ܽ��
                                V_PP.RLZNJ, --����ΥԼ��
                                V_PP.RLSXF, --������
                                V_PAID_METER, -- ˮ��ʵ���տ�
                                'U', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                              --  P_TRANS, --�ɷ�����
                                V_PP.MID, --ˮ�����Ϻ�
                                P_FKFS, --���ʽ
                                P_PAYPOINT, --�ɷѵص�
                                V_BATCH,
                                P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                P_INVNO, --��Ʊ��
                                'N',
                                p_pbseqno,--֧������ˮ
                                P_MMID);
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --һ�����ύ-----------��ʱ����-----------------------------------------------
    --COMMIT;
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
  END F_POS_MULT_HS_ZFB;
  
  FUNCTION F_POS_MULT_HS_WX(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                         P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --���������
                         P_PAYJE    IN NUMBER, --��ʵ���տ���
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                         P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         P_INVNO    IN VARCHAR2, --��Ʊ��
                         p_pbseqno  IN VARCHAR2, --������ˮ
                         P_BATCH    IN VARCHAR2,
                         p_pwseqno  IN VARCHAR2,--΢����ˮ
                         p_date     IN VARCHAR2  --��������ʱ��
                        ) RETURN VARCHAR2 IS

    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    MID_COUNT NUMBER; --ˮ��ֻ��
    V_INP     NUMBER; --ѭ������

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         pay_para_tmp%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --�������κ�
    ERR_PAY EXCEPTION; --���˴���

    V_NRESULT NUMBER; --������

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM pay_para_tmp RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING <> 0; ----���Ƹ۸�Ԥ����Ҫ�����
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
                                    'N',
                                    P_MMID);

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: ������������---------------------------------------------------
    --�����������κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '������������';
    BEGIN
      SELECT RT.* INTO V_PP FROM pay_para_tmp RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER_WX(P_POSITION, --�ɷѻ���
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
                               'N',
                               p_pbseqno, --������ˮ
                               P_MMID,
                               p_pwseqno,--΢����ˮ
                               p_date);    --��������ʱ��
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
                             'B', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                            -- PAYTRANS_YCDB, --�ɷ����� 
                             P_FKFS, --���ʽ
                             P_PAYPOINT, --�ɷѵص�
                             P_BATCH, --�ɷ���������
                             'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                             '', --��Ʊ��
                             V_PAYID --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                             );
      --���˼�¼���������
    UPDATE PAYMENT 
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;   
            --д��΢����ˮ
    UPDATE PAYMENT 
    SET PBSEQNO=p_pbseqno,
        PWSEQNO=p_pwseqno,
        PWDATE =p_date
    WHERE PID=V_PAYID;  
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
                                    'N',
                                    P_MMID);
      ---END OF STEP 21 Ԥ�������ɣ���̨���ݽ��------------------------------------------
      -- ��PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
      --2����¼ͬһ�����κţ���ˮ�����ʵ����κ�һ����
      --�ӱ��ˮ����Ϣ�У�Ԥ��������ӣ����ӽ���������������Ľ��
      ------------------------------------------------------------------------------------------------
      ---STEP 22: �ӱ�����---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '�����ӱ�����--�ӱ�����';
      V_RESULT  := F_POS_1METER_WX(P_POSITION, --�ɷѻ���
                                P_OPER, --�տ�Ա
                                V_PP.PLIDS, --Ӧ����ˮ��
                                V_PP.RLJE, --Ӧ���ܽ��
                                V_PP.RLZNJ, --����ΥԼ��
                                V_PP.RLSXF, --������
                                V_PAID_METER, -- ˮ��ʵ���տ�
                                'U', -- by 20150420 ralph �ӱ�Ǯת�Ƶ�������
                              --  P_TRANS, --�ɷ�����
                                V_PP.MID, --ˮ�����Ϻ�
                                P_FKFS, --���ʽ
                                P_PAYPOINT, --�ɷѵص�
                                V_BATCH,
                                P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                P_INVNO, --��Ʊ��
                                'N',
                                p_pbseqno,--΢����ˮ
                                P_MMID,
                                p_pwseqno,--΢����ˮ
                                p_date);  --��������ʱ��
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    
    -----------------------------------------------------
    --һ�����ύ-----------��ʱ����-----------------------------------------------
    --COMMIT;
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
  END F_POS_MULT_HS_WX;

  

FUNCTION F_POS_MULT_HS_test(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
    V_PP         pay_para_tmp%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --�������κ�
    ERR_PAY EXCEPTION; --���˴���

    V_NRESULT NUMBER; --������

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM pay_para_tmp RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING <> 0; ----���Ƹ۸�Ԥ����Ҫ�����
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
                                    'N',
                                    P_MMID);

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: ������������---------------------------------------------------
    --�����������κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '������������';
    BEGIN
      SELECT RT.* INTO V_PP FROM pay_para_tmp RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER_test(P_POSITION, --�ɷѻ���
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
                               'N',
                               P_MMID);
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;

    ELSE
      --Ԥ�浽����
      ----��ת��Ԥ���ʵ����-----------------------------------------------------------------
      V_RESULT := F_PAY_CORE_test(P_POSITION, --�ɷѻ���
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
      --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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
                                    'N',
                                    P_MMID);
      ---END OF STEP 21 Ԥ�������ɣ���̨���ݽ��------------------------------------------
      -- ��PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
      --2����¼ͬһ�����κţ���ˮ�����ʵ����κ�һ����
      --�ӱ��ˮ����Ϣ�У�Ԥ��������ӣ����ӽ���������������Ľ��
      ------------------------------------------------------------------------------------------------
      ---STEP 22: �ӱ�����---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '�����ӱ�����--�ӱ�����';
      V_RESULT  := F_POS_1METER_test(P_POSITION, --�ɷѻ���
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
                                'N',
                                P_MMID);
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --һ�����ύ-----------��ʱ����-----------------------------------------------
    --COMMIT;
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
  END F_POS_MULT_HS_test;
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
  if P_RLJE >= 0 then  --20141124 add hb ��Ԥ�治���
     --������ϵ
    --ΥԼ����㲻�����
    IF P_RLJE <> V_REC_TOTAL OR /*P_ZNJ <> V_ZNJ_TOTAL OR*/
       P_SXF <> V_SXF_TOTAL THEN
      RAISE ERR_NOMATCH;
    END IF;
  end if    ;
     --20141124
/*    --������ϵ
    --ΥԼ����㲻�����
    IF P_RLJE <> V_REC_TOTAL OR \*P_ZNJ <> V_ZNJ_TOTAL OR*\
       P_SXF <> V_SXF_TOTAL THEN
      RAISE ERR_NOMATCH;
    END IF;*/
    --20141124


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
                            P_COMMIT   IN VARCHAR2, --�Ƿ��ύ
                            P_MMID     IN VARCHAR2
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
    --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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
     --���˼�¼���������
    UPDATE PAYMENT
    SET PPRIID=P_MMID
    WHERE PID=V_PAYID;
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
                              PM.PTRANS, --�ɷ�����
                              PM.PMID, --ˮ�����Ϻ�
                              PM.PPAYWAY, --���ʽ
                              PM.PPAYPOINT, --�ɷѵص�
                              PM.PBATCH, --��������
                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                              '',
                              'Y',
                              PM.PMID);
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
                              'Y',
                              PM.PMID);
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
    CQ CHEQUE%ROWTYPE;
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������
    V_RECID  RECLIST.RLID%TYPE;

    ERR_SAVING EXCEPTION;

    V_CALL NUMBER;
    V_COUNT NUMBER:=0;
    R1 RECLIST_1METER_TMP%ROWTYPE;
    RL1 RECLIST%ROWTYPE;

    /*�������³���֮�������·�Ϊ��ǰ�µ�BUG*/
     cursor c_sscz_list is
        select s.* from reclist_1meter_tmp s;

      v_sscz_list  reclist_1meter_tmp%rowtype;

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

    --֧Ʊ������,����ʱ��д��һ���ʸ�����֧Ʊ��cheque
    --�����д�����������˲�һ�¡����Բ���
      -- modify 201406708 hb
      --20160503 ����  PS  ԭ��ͬ��
      IF PM.PPAYWAY in ('ZP','MZ','DC','PS') THEN
          SELECT COUNT(CHEQUEID) INTO V_COUNT FROM CHEQUE   WHERE CHEQUEID=PM.PBATCH;
          IF V_COUNT> 0 THEN  --����ʱ��д�����ϣ����������������δд��
              select * into CQ from  CHEQUE   WHERE CHEQUEID=PM.PBATCH;
               CQ.CHEQUEID :=P_BATCH;
               cq.enteringtime :=sysdate;
               --cq.chequemoney:=0 - cq.chequemoney;
               cq.chequemoney:= 0 - PM.PPAYMENT;
               CQ.CHEQUECWNO :='';
               CQ.CHEQUEYXNO :='';
            --   if  cq.chequemoney > 0 then --ADD 20140905
               --   CQ.chequecrflag:='Y';
            --   else
                  CQ.chequecrflag:='Y';
                  CQ.CHEQUEMEMO:='ʵ�ճ���д��'; --ADD 20140905
             --  end if ;
               CQ.chequecrdate:=SYSDATE;
               CQ.chequecroper:=P_OPER;
               DELETE FROM cheque  WHERE CHEQUEID=CQ.CHEQUEID ;
               insert into cheque values CQ;
           END IF ;
       end if ;
     --end ֧Ʊ����

    --ȡˮ����Ϣ
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = PM.PMID;

    /*--��鵱ǰԤ���Ƿ񹻳�������,�������˳� [yujia 2012-02-08]
    IF PM.PSAVINGBQ>MI.MISAVING THEN
       RAISE ERR_SAVING;
    END IF;*/

    --׼��ʵ�ճ�������¼������
    PM.PPOSITION    := P_POSITION; --����
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  ���ʵ�ճ�����Ԥ��ֿۣ����û���дsystem���������ʳ�����
      --���û�5038003584���е����ʶ�300Ԫ��ϵͳ����Ԥ��ֿۣ�ֻ���û����г���������֮��ϵͳ��¼�����û��˺ţ���ʱ���շ�Ա����������
          PM.PPER         := 'SYSTEM'; --����
    else
          PM.PPER         := P_OPER; --����
    end if ;
    PM.PSAVINGQC    := MI.MISAVING; --ȡ��ǰ
    PM.PSAVINGBQ    := 0 - PM.PSAVINGBQ; --ȡ��
    PM.PSAVINGQM    := MI.MISAVING + PM.PSAVINGBQ; --����
    PM.PPAYMENT     := 0 - PM.PPAYMENT; --ȡ��
    PM.PBATCH       := P_BATCH; --����
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  ���ʵ�ճ�����Ԥ��ֿۣ����û���дsystem���������ʳ�����
      --���û�5038003584���е����ʶ�300Ԫ��ϵͳ����Ԥ��ֿۣ�ֻ���û����г���������֮��ϵͳ��¼�����û��˺ţ���ʱ���շ�Ա����������
           PM.PPAYEE        := 'SYSTEM'; --����
    else
             PM.PPAYEE       := P_OPER; --����
    end if ;

    pm.pchkdate     :=sysdate ; --������Ҫ���������ڼ�¼Ϊ��ǰ��ϵͳ�������� by 20150203 ralph
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
    PM.PID   := FGETSEQUENCE('PAYMENT'); --������
    PM.PDATE := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    ----���¼���������ֵһ��Ҫ������󣬺ʹ����й�
    PM.PID       := FGETSEQUENCE('PAYMENT'); --������
    PM.PDATE     := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    PM.PDATETIME := SYSDATE; --SYSDATE
    PM.PMONTH    := TOOLS.FGETRECMONTH(MI.MISMFID); --��ǰ�·�
    PM.PCHKNO := null ;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
    pm.TCHKDATE :=null;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
    pm.pdzdate :=null;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
   -- PM.PTRANS    := P_TRANS; --����  modify 20140625 hb ȡ��,�����ʱ��Ӧ��������ԭӦ������Ӧ����ȣ���������ⲿ����������²���
    -----------------------------------------------------------------
    --�������ʵ�ո���¼
    INSERT INTO PAYMENT T VALUES PM;
    --ԭ��������¼���ϳ�����־
    UPDATE PAYMENT T SET T.PREVERSEFLAG = 'Y' WHERE T.PID = P_PAYID;
    --END OF STEP 1: ��������---------------------------------------------------
    --PAYMENT ��������һ������¼
    -- ��������¼�ĳ�����־ΪY
    ----------------------------------------------------------------------------------------

/*         insert into cheque(chequeid, enteringtime, payername, payertel, chequetype, chequemoney, chargelocation, chargename, chargetime, chequecode, chequename, chequebankname, chequechargerid, chequememo, chequestatus, chequeoper, chequesdate, chequemcode, chequeflag, chequebankid, chequebankno, chequeyxno, chequecwno, chequecrflag, chequecrdate, chequecroper, cbankid, cbankname, cbankno )
           select '-'||SUBSTR(chequeid,2,9), SYSDATE, payername, payertel, chequetype, -chequemoney, chargelocation, chargename, SYSDATE, chequecode, chequename, chequebankname, chequechargerid, chequememo, chequestatus, P_OPER, chequesdate, chequemcode,chequeflag, chequebankid, chequebankno, chequeyxno, chequecwno, 'Y' , sysdate, P_OPER, cbankid, cbankname, cbankno
            from cheque
           WHERE CHEQUEID=P_BATCH;*/


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

   /* BEGIN
    SELECT * INTO R1 FROM RECLIST_1METER_TMP WHERE ROWNUM=1;
    SELECT S.* INTO RL1
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';
    EXCEPTION
    WHEN OTHERS THEN
         NULL;
    END;*/

    ---������Ҫ���������Ӧ����ϸ�ʼ�¼
    V_STEP    := 11;
    V_PRC_MSG := '������Ҫ���������Ӧ����ϸ�ʼ�¼';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    V_PRC_MSG := '��Ӧ��������ʱ����������¼�ĵ���';
    /* UPDATE RECLIST_1METER_TMP T
    SET T.RLID    = FGETSEQUENCE('RECLIST'),
        T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --��ǰ              �����·�
        T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --��ǰ              ��������
       \* T.RLMONTH = PM.PMONTH, --��ǰ              �����·�
        T.RLDATE  = PM.PDATE, --��ǰ              ��������*\
        T.RLREADSL     = 0 - T.RLREADSL ,--����ˮ��
        t.rlentrustbatch = null,--���մ�������
        t.rlentrustseqno = null,-- ���մ�����ˮ��
        -- T.RLCHARGEPER   = PM.PPER, --ͬʵ��            �շ�Ա
        T.RLSL          = 0 - T.RLSL, --ȡ��              Ӧ��ˮ��
        T.RLJE          = 0 - T.RLJE, --ȡ��              Ӧ�ս��
        T.RLADDSL       = 0 - T.RLADDSL, --ȡ��              �ӵ�ˮ��

        T.rlcolumn9     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
        T.rlcolumn11  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
        T.rlcolumn10  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�
        T.RLCOLUMN5   = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������

        \*T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
        T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
        T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�*\
        T.RLPAIDJE      = 0 - T.RLPAIDJE, --ȡ��              ���ʽ��
        --T.RLPAIDFLAG    = 'Y', --Y                 ���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
        T.RLPAIDPER     = PM.PPER, --ͬʵ��            ������Ա
        T.RLPAIDDATE    = PM.PDATE, --ͬʵ��            ��������
        T.RLZNJ         = 0 - T.RLZNJ, --ȡ��              ΥԼ��
        T.RLDATETIME    = SYSDATE, --SYSDATE           ��������

       \* T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������*\
        T.RLPID         = PM.PID, --��Ӧ�ĸ�ʵ����ˮ  ʵ����ˮ����payment.pid��Ӧ��
        T.RLPBATCH      = PM.PBATCH, --��Ӧ�ĸ�ʵ����ˮ  �ɷѽ������Σ���payment.PBATCH��Ӧ��
        T.RLSAVINGQC    = T.RLSAVINGQM + nvl(mi.misaving,0) , --����              �ڳ�Ԥ�棨����ʱ������
        T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --����              ����Ԥ�淢��������ʱ������
        T.RLSAVINGQM    = T.RLSAVINGQC + nvl(mi.misaving,0), --����              ��ĩԤ�棨����ʱ������
        T.RLREVERSEFLAG = 'Y', --Y                   ������־��NΪ������YΪ������
        t.rlilid        =null ,--��Ʊ��ˮ��
        t.rlmisaving    = 0,--���ʱԤ��
        t.rlpriorje     = 0,--���֮ǰǷ��
        T.RLSXF         = 0 - T.RLSXF;*/

    --����ʱӦ���ʸ�����
    V_CALL := F_SET_CR_RECLIST(PM);

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 13;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';

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
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��

    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);

    --add 2013.02.01  ��reclist_char_01������¼�ĵ���
    /*   for  i in (SELECT S.RDID FROM RECDETAIL_TMP S)
    LOOP
       sp_reclist_charge_01(i.RDID ,'1');
     END LOOP;*/
    --add 2013.02.01

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
       SET T.RLID    = FGETSEQUENCE('RECLIST'), --������
           T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --��ǰ              �����·�
           T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --��ǰ              ��������
           /*           T.RLMONTH       = PM.PMONTH, --��ǰ
           T.RLDATE        = PM.PDATE, --��ǰ*/
           --T.RLCHARGEPER   = '', --��

           T.RLCOLUMN5  = T.RLDATE, --�ϴ�Ӧ��������
           T.RLCOLUMN9  = T.RLID, --�ϴ�Ӧ������ˮ
           T.RLCOLUMN10 = T.RLMONTH, --�ϴ�Ӧ�����·�
           T.RLCOLUMN11 = T.RLTRANS, --�ϴ�Ӧ��������

           /*           T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID
           T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS
           T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH*/
           T.RLPAIDFLAG = 'N', --N
           T.RLPAIDPER  = '', --��
           T.RLPAIDDATE = '', --��
           T.RLDATETIME = SYSDATE, --SYSDATE
           /*           T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE*/
           T.RLPID         = NULL, --��
           T.RLPBATCH      = NULL, --��
           T.RLSAVINGQC    = 0, --��
           T.RLSAVINGBQ    = 0, --��
           T.RLSAVINGQM    = 0, --��
           T.RLREVERSEFLAG = 'N',
           T.RLPAIDJE      = 0,
           T.RLSXF         = 0, --������
           T.RLZNJ         = 0; --ΥԼ��
           --zb 2018-11-8
           --���ӷ�Ʊ��ʵ�գ�Ӧ������������״̬
           --T.RLOUTFLAG     = 'N'; --N

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 23;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);
    /*�������³���֮�������·�Ϊ��ǰ�µ�BUG*/
/*    open c_sscz_list;
    loop
      fetch c_sscz_list
        into v_sscz_list;
      exit when c_sscz_list%notfound or c_sscz_list%notfound is null;
        --ȡ��ʷ�����·�
        begin
          select mrmonth into  v_sscz_list.rlmonth from view_meterreadall where mrid=v_sscz_list.rlmrid;
        end;
        INSERT INTO RECLIST values v_sscz_list;
        end loop;
  close c_sscz_list;*/


    --���߼����˷�
    INSERT INTO RECLISTTEMPCZ
      (SELECT S.RLID, RLCOLUMN9 FROM RECLIST_1METER_TMP S);

    ---��Ӧ����ϸ��ʱ����������¼�ĵ���
    V_STEP    := 14;
    V_PRC_MSG := '��Ӧ����ϸ��ʱ����������¼�ĵ���';

    UPDATE RECDETAIL_TMP T
       SET (T.RDID,
            T.RDPAIDFLAG,
            T.RDPAIDDATE,
            T.RDPAIDMONTH,
            T.RDPAIDPER,
            T.RDMONTH,
            T.RDZNJ) =
           (SELECT S.RLID, 'N', NULL, NULL, NULL, S.RLMONTH, 0
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);
    --add 2013.02.01 ��reclist_charge_01���в�����Ӧ�ռ�¼
    /*   for  i in (SELECT S.RDID FROM RECDETAIL_TMP S)
     LOOP
      sp_reclist_charge_01(i.RDID ,'1');
    END LOOP;*/
    --add 2013.02.01
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
                                    V_BATCH,
                                    P_PAYPOINT,
                                    P_TRANS,
                                    'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAYBACK;
      END IF;
    END LOOP;

    --���֧Ʊ��Ĩ�ʡ�����
    IF PM.PPAYWAY in ('ZP','MZ','DC') THEN
       UPDATE CHEQUE
       SET chequecrflag='Y',
           chequecrdate=SYSDATE,
           chequecroper=P_OPER
       WHERE CHEQUEID=P_BATCH;
    END IF;

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BATCH);
     --�����ӷ�Ʊ
    P_SP_CANCEL(P_BATCH,'PBATCH',P_OPER);
    --COMMIT;
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
  DROP  TABLE pay_para_tmp;
  create global temporary table pay_para_tmp  on commit delete rows
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
--˰�����
FUNCTION fgettaxscale(P_PTYPE IN VARCHAR2) return number IS

begin
  if P_PTYPE is null then
     RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�۲���Ϊ��!');
  end if;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end fgettaxscale;
--ʵ��˰��
PROCEDURE SP_PAYTAX(P_BATCH IN VARCHAR2) IS

begin
NULL;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end SP_PAYTAX;

PROCEDURE P_SP_CANCEL(P_BATCH IN VARCHAR2,P_LX IN VARCHAR2,P_PER VARCHAR2) IS
  PM PAYMENT%ROWTYPE;
  V_ISBCNO    VARCHAR2(32);
  V_ISNO      VARCHAR2(12);
  o_errmsg    VARCHAR2(1000);
  O_CODE      VARCHAR2(100);
  V_FLAG      CHAR(1);
  CURSOR C_PM IS
      SELECT T.*
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH AND
             PPAYMENT<>0
         ;
  CURSOR C_PID IS
      
      SELECT isp.isbcno,isp.isno 
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp,PAYMENT p LEFT JOIN RECLIST R ON RLPID = PID
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and II.MICODE = P.PMID 
           AND ((ii.rlid = R.RLID and P_LX = 'PSEQNO' AND P.PSEQNO = P_BATCH) 
               OR (ii.PID = P.PID and P_LX = 'PID' AND P.PID = P_BATCH) 
               OR (ii.Ppbatch = P.PBATCH and P_LX = 'PBATCH' AND P.PBATCH = P_BATCH))
           AND II.ISID IS not NULL AND P.PREVERSEFLAG <> 'Y';
  
begin
  
/*SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and (II.MICODE = RLDE.RLMID AND ii.rlid = RLDE.RLID)
           AND II.ISID IS not NULL;
    IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
    pg_ewide_einvoice.p_cancel(V_ISBCNO,
                             V_ISNO,
                             o_code,
                             o_errmsg);
    END IF;*/

    IF P_LX = 'PID' THEN
      SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PID = P_BATCH
       AND T.PREVERSEFLAG <> 'Y';
      SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1' AND II.STATUS='0'
           and (II.MICODE = PM.PMID AND ii.PID = PM.PID)
           AND II.ISID IS not NULL;
      IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
        V_FLAG := '1';
        
        pg_ewide_einvoice.p_cancel_hrb(V_ISBCNO,
                                 V_ISNO,
                                 PM.PID,
                                 o_code,
                                 o_errmsg);
        if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                P_PER,
                                                2,
                                                'ʵ�ճ�����Ʊ����',
                                                o_errmsg);
      end if;
       ELSE
         V_FLAG := '2';
       END IF;
    END IF;
    
    IF P_LX = 'PBATCH' THEN
      BEGIN
      OPEN C_PM;
      LOOP
      FETCH C_PM
        INTO PM;
      EXIT WHEN C_PM%NOTFOUND OR C_PM%NOTFOUND IS NULL;
      BEGIN
      --1����ѯԭ�����Ƿ�Ʊ
      SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1' AND II.STATUS='0'
           and (II.MICODE = PM.PMID AND ii.pid = PM.PSCRID)
           AND II.ISID IS not NULL;
      --2���ѿ�Ʊ������Ϸ�Ʊ
      IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
        pg_ewide_einvoice.p_cancel_HRB(V_ISBCNO,
                                 V_ISNO,
                                 PM.PID,
                                 o_code,
                                 o_errmsg);
        /*pg_ewide_einvoice.p_cancel(V_ISBCNO,
                                 V_ISNO,
                                 o_code,
                                 o_errmsg);*/
        if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                P_PER,
                                                2,
                                                'ʵ�ճ�����Ʊ����',
                                                o_errmsg);
        end if;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      END LOOP;
      CLOSE C_PM;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          CLOSE C_PM;
      END;
      /*SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PBATCH = P_BATCH
       AND T.PREVERSEFLAG <> 'Y';
      SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and (II.MICODE = PM.PMID AND ii.Ppbatch = PM.PBATCH)
           AND II.ISID IS not NULL;
      IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
        V_FLAG := '1';
        pg_ewide_einvoice.p_cancel(V_ISBCNO,
                                 V_ISNO,
                                 o_code,
                                 o_errmsg);
        if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                P_PER,
                                                2,
                                                'ʵ�ճ�����Ʊ����',
                                                o_errmsg);
      end if;
       ELSE
         V_FLAG := '2';
       END IF;*/
    END IF;
    
    IF P_LX = 'PSEQNO' THEN
      SELECT T.*
      INTO PM
        FROM PAYMENT T
       WHERE T.PBSEQNO = P_BATCH
         AND T.PREVERSEFLAG <> 'Y';
      SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and (II.MICODE = PM.PMID AND ii.PID = PM.PID)
           AND II.ISID IS not NULL;
      IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
        V_FLAG := '1';
        pg_ewide_einvoice.p_cancel(V_ISBCNO,
                                 V_ISNO,
                                 o_code,
                                 o_errmsg);
        if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                P_PER,
                                                2,
                                                'ʵ�ճ�����Ʊ����',
                                                o_errmsg);
      end if;
       ELSE
         V_FLAG := '2';
       END IF;
    END IF;
    IF V_FLAG = '2' THEN
      OPEN C_PID;
    LOOP
      FETCH C_PID
        INTO V_ISBCNO,V_ISNO;
      EXIT WHEN C_PID%NOTFOUND OR C_PID%NOTFOUND IS NULL;
      pg_ewide_einvoice.p_cancel(V_ISBCNO,
                                 V_ISNO,
                                 o_code,
                                 o_errmsg);
     if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                P_PER,
                                                2,
                                                'ʵ�ճ�����Ʊ����',
                                                o_errmsg);
      end if;
      
     /* IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;*/
    END LOOP;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end P_SP_CANCEL;


BEGIN
  CURDATE                := SYSDATE;
  ȫ��˾ͳһ��׼�����ɽ� := FSYSPARA('1090'); --ȫ��˾ͳһ��׼�����ɽ�(1),��Ӫҵ����׼�����ɽ�(2)
END;
/


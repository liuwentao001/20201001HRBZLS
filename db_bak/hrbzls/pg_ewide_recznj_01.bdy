CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RECZNJ_01" IS

  CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN
    --���鷣���շ�
    IF P_DJLB = '7' THEN
      SP_RECZNJJM(P_BILLNO, P_PERSON, 'Y');
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE, P_BILLNO || '->1 ��Ч�ĵ������');
    END IF;
  END;
  --���ɽ����
  PROCEDURE SP_RECZNJJM(P_ZAHNO  IN VARCHAR2, --������ˮ
                        P_PER    IN VARCHAR2, --����Ա
                        P_COMMIT IN VARCHAR2 --�ύ��־
                        ) AS
    V_EXIST  NUMBER(10);
    ZNJDT    ZNJADJUSTDT%ROWTYPE;
    ZNJHD    ZNJADJUSTHD%ROWTYPE;
    ZNJL     ZNJADJUSTLIST%ROWTYPE;
    RL       RECLIST%ROWTYPE;
    RD       RECDETAIL%ROWTYPE;
    V_CHKSTR VARCHAR2(200);
    CURSOR C_ZNJADJUSTDT IS
      SELECT * FROM ZNJADJUSTDT WHERE ZADNO = P_ZAHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO ZNJHD FROM ZNJADJUSTHD WHERE ZAHNO = P_ZAHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END;
    --��������
    /*    v_chkstr :=f_chkznjed( P_PER ,znjhd.zahno   ) ;
    if v_chkstr <>'Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, v_chkstr);
    end if;*/
    IF ZNJHD.ZAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����������,��������!');
    END IF;
    IF ZNJHD.ZAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�������ȡ��,������!');
    END IF;
    ZNJHD.ZAHSHDATE := SYSDATE;
    OPEN C_ZNJADJUSTDT;
    LOOP
      FETCH C_ZNJADJUSTDT
        INTO ZNJDT;
      EXIT WHEN C_ZNJADJUSTDT%NOTFOUND OR C_ZNJADJUSTDT%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO RL FROM RECLIST WHERE RLID = ZNJDT.ZADRLID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  'Ӧ����ˮ��[' || ZNJDT.ZADRLID || ']������');
      END;
      IF RL.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                'Ӧ����ˮ��[' || RL.RLID || ']�ѽ��г����������������⣡');
      END IF;
      IF ZNJDT.ZADPIID = 'NA' THEN
        IF RL.RLPAIDFLAG <> 'N' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                  'Ӧ����ˮ��[' || RL.RLID || ']��Ϊ����״̬�����������⣡');
        END IF;

      END IF;
      IF RL.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                'Ӧ����ˮ��[' || RL.RLID ||
                                ']Ƿ����Ϣ�ѷ������пۿ���������⣡');
      END IF;
      UPDATE ZNJADJUSTLIST T
         SET ZALSTATUS = 'N'
       WHERE T.ZALRLID = ZNJDT.ZADRLID
         AND ZALSTATUS = 'Y';

      ZNJL.ZALRLID      := ZNJDT.ZADRLID; --����Ӧ����ˮ
      ZNJL.ZALPIID      := ZNJDT.ZADPIID; --���������Ŀ��ȫ��ΪNA��
      ZNJL.ZALMID       := ZNJDT.ZADMID; --ˮ����
      ZNJL.ZALMCODE     := ZNJDT.ZADMCODE; --ˮ���
      ZNJL.ZALMETHOD    := ZNJDT.ZADMETHOD; --���ⷽ����1��Ŀ������⣻2�����������⣻3�������⣻4�������������ڣ�
      ZNJL.ZALVALUE     := ZNJDT.ZADVALUE; --������/����ֵ
      ZNJL.ZALZNDATE    := ZNJDT.ZADZNDATE; --����Ŀ��������
      ZNJL.ZALDATE      := ZNJHD.ZAHSHDATE; --��������
      ZNJL.ZALPER       := P_PER; --������Ա
      ZNJL.ZALBILLNO    := ZNJDT.ZADNO; --���ⵥ�ݱ��
      ZNJL.ZALBILLROWNO := ZNJDT.ZADROWNO; --���ⵥ���к�
      ZNJL.ZALSTATUS    := 'Y'; --��Ч��־
      INSERT INTO ZNJADJUSTLIST VALUES ZNJL;

    END LOOP;
    CLOSE C_ZNJADJUSTDT;

    UPDATE ZNJADJUSTHD
       SET ZAHSHDATE = ZNJHD.ZAHSHDATE, ZAHSHPER = P_PER, ZAHSHFLAG = 'Y'
     WHERE ZAHNO = P_ZAHNO;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_ZAHNO);
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --���ɽ����ȡ��
  PROCEDURE SP_RECZNJJMCANCEL(P_ZAHNO  IN VARCHAR2, --������ˮ
                              P_PER    IN VARCHAR2, --����Ա
                              P_COMMIT IN VARCHAR2 --�ύ��־
                              ) AS
    V_EXIST NUMBER(10);
    ZNJDT   ZNJADJUSTDT%ROWTYPE;
    ZNJHD   ZNJADJUSTHD%ROWTYPE;
    ZNJL    ZNJADJUSTLIST%ROWTYPE;
    RL      RECLIST%ROWTYPE;

    CURSOR C_ZNJADJUSTDT IS
      SELECT * FROM ZNJADJUSTDT WHERE ZADNO = P_ZAHNO FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO ZNJHD FROM ZNJADJUSTHD WHERE ZAHNO = P_ZAHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
    END;
    IF ZNJHD.ZAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�������ȡ��,����ȡ�����!');
    END IF;
    IF ZNJHD.ZAHSHFLAG <> 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����������״̬,����ȡ�����!');
    END IF;
    ZNJHD.ZAHSHDATE := SYSDATE;
    OPEN C_ZNJADJUSTDT;
    LOOP
      FETCH C_ZNJADJUSTDT
        INTO ZNJDT;
      EXIT WHEN C_ZNJADJUSTDT%NOTFOUND OR C_ZNJADJUSTDT%NOTFOUND IS NULL;
      SELECT * INTO RL FROM RECLIST WHERE RLID = ZNJDT.ZADRLID;
      IF RL.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                'Ӧ����ˮ��[' || RL.RLID || ']�ѽ��г����������������⣡');
      END IF;
      IF ZNJDT.ZADPIID = 'NA' THEN
        IF RL.RLPAIDFLAG <> 'N' THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                  'Ӧ����ˮ��[' || RL.RLID || ']��Ϊ����״̬�����������⣡');
        END IF;
      ELSE

        BEGIN
          SELECT COUNT(RDID)
            INTO V_EXIST
            FROM RECDETAIL
           WHERE RDID = ZNJDT.ZADRLID
             AND RDPIID = ZNJDT.ZADPIID
             AND RDPAIDFLAG = 'Y';
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    'Ӧ����ˮ��[' || ZNJDT.ZADRLID || ']������');
        END;
        IF V_EXIST > 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '���Ϻ�[' || RL.RLMCODE || ']' || RL.RLMONTH || '�·�' ||
                                  'Ӧ����ˮ��[' || RL.RLID || ']��Ϊ����״̬�����������⣡');
        END IF;
      END IF;

      /*if rl.rloutflag='Y' then
         RAISE_APPLICATION_ERROR(ERRCODE,'���Ϻ�['||rl.rlMCODE||']'||rl.rlmonth||
         '�·�'||'Ӧ����ˮ��['||rl.rlid ||']Ƿ����Ϣ�ѷ������пۿ������ȡ�����⣡');
      end if;*/
    END LOOP;
    CLOSE C_ZNJADJUSTDT;
    --ȡ�����ɽ������Ϣ
    UPDATE ZNJADJUSTLIST
       SET ZALSTATUS = 'N'
     WHERE ZALBILLNO = P_ZAHNO
       AND ZALSTATUS = 'Y';
    --���µ�ͷ��Ϣ
    UPDATE ZNJADJUSTHD
       SET ZAHSHDATE = ZNJHD.ZAHSHDATE, ZAHSHPER = P_PER, ZAHSHFLAG = 'Q'
     WHERE ZAHNO = P_ZAHNO;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --������Ա�Ƿ����������
  FUNCTION F_CHKZNJED(P_OPER IN VARCHAR2, P_WYDNO IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_WYDZNJ   NUMBER(13, 3);
    V_WYDVALUE NUMBER(13, 3);
    V_OAPVALUE NUMBER(13, 3);
  BEGIN
    --��ѯ����Ա���
    SELECT T.OAPVALUE
      INTO V_OAPVALUE
      FROM OPERACCNTPARA T
     WHERE T.OAPTYPE = 'ZNJED'
       AND T.OAPOAID = P_OPER
       AND T.OAPFLAG = 'Y';

    --��ѯ��ͷ�������
    SELECT SUM(NVL(WYDZNJ, 0))
      INTO V_WYDZNJ
      FROM WYJADJUSTDT T
     WHERE WYDNO = P_WYDNO;
    --��ѯʵ�ʽ��
    SELECT SUM(NVL(T.WYDVALUE, 0))
      INTO V_WYDVALUE
      FROM WYJADJUSTHD T
     WHERE T.WYHNO = P_WYDNO;
    V_WYDZNJ := V_WYDZNJ - V_WYDVALUE;
    IF V_OAPVALUE >= V_WYDZNJ THEN
      RETURN 'Y';
    ELSE
      RETURN 'ʵ�ʼ�����Ϊ' || V_WYDZNJ || 'Ԫ�������ܼ�����Ϊ' || V_OAPVALUE || 'Ԫ';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '�쳣';
  END;
  --���ɽ���⹦��ʹ��
  PROCEDURE SP_ZNJJM_GETZNJLIST(P_CODE    IN VARCHAR2,
                                P_BFID    IN VARCHAR2,
                                P_MINDATE IN DATE,
                                P_MAXDATE IN DATE,
                                O_FLAG    OUT VARCHAR2) IS
    CURSOR C_RL IS
      SELECT RLID, RLMID, RLMCODE, RLZNDATE, RLJE, RLGROUP, RLSMFID, RLDATE
        FROM RECLIST A
       WHERE ((RLMCODE = P_CODE AND RLBFID = P_BFID) OR (RLMCODE = P_CODE) OR
             (RLBFID = P_BFID))
         AND (RLDATE >= P_MINDATE OR P_MINDATE IS NULL)
         AND (RLDATE <= P_MAXDATE OR P_MAXDATE IS NULL)
         AND RLCD = 'DE'
         AND RLPAIDFLAG IN ('N', 'V', 'K', 'W')
         AND RLOUTFLAG = 'N'
         AND A.RLREVERSEFLAG = 'N'
         AND RLJE > 0;

    V_ROW    NUMBER;
    V_RL     RECLIST%ROWTYPE;
    V_ZNJ    NUMBER(10, 2);
    V_ZNDATE VARCHAR2(20);
  BEGIN
    --�ͻ����룬��ᶼΪ��
    IF P_CODE IS NULL AND P_BFID IS NULL THEN
      O_FLAG := 'N';
      RETURN;
    END IF;

    --�жϿͻ�������ϵͳ�Ƿ����
    IF P_CODE IS NOT NULL THEN
      SELECT COUNT(*) INTO V_ROW FROM METERINFO WHERE MICODE = P_CODE;
      IF V_ROW <= 0 THEN
        O_FLAG := 'A';
        RETURN;
      END IF;
    END IF;

    --�жϱ���Ƿ�Ϊ����
    IF P_BFID IS NOT NULL THEN
      SELECT COUNT(*) INTO V_ROW FROM BOOKFRAME WHERE BFID = P_BFID;
      IF V_ROW <= 0 THEN
        O_FLAG := 'B';
        RETURN;
      END IF;
    END IF;

    --�α��ȡ��Ϣ�����ɽ����0��
    DELETE PBPARMTEMP;
    OPEN C_RL;
    LOOP
      FETCH C_RL
        INTO V_RL.RLID,
             V_RL.RLMID,
             V_RL.RLMCODE,
             V_RL.RLZNDATE,
             V_RL.RLJE,
             V_RL.RLGROUP,
             V_RL.RLSMFID,
             V_RL.RLDATE;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      --�������ɽ��㷨����
      V_ZNJ    := PG_EWIDE_PAY_01.GETZNJ(V_RL.RLSMFID,
                                         V_RL.RLGROUP,
                                         V_RL.RLZNDATE,
                                         SYSDATE,
                                         V_RL.RLJE);
      V_ZNDATE := TO_CHAR(V_RL.RLZNDATE, 'yyyy-mm-dd');
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5)
      VALUES
        (V_RL.RLID, V_RL.RLMCODE, V_RL.RLMID, V_ZNDATE, V_ZNJ);
    END LOOP;
    CLOSE C_RL;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  PROCEDURE ����ΥԼ����ⵥ��(P_ZASMFID    IN VARCHAR2, --Ӫҵ��
                      P_ZAHDEPT    IN VARCHAR2, -- ��������
                      P_ZAHCREPER  IN VARCHAR2, --������Ա
                      P_ZAHCREDATE IN VARCHAR2, --��������
                      P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                      P_ZAHNO      IN OUT VARCHAR2, --������ݺ�
                      P_ZNJ        IN NUMBER, --Ŀ����
                      P_COMMIT     IN VARCHAR2 --�ύ��־
                      ) IS

    V_ZAH ZNJADJUSTHD%ROWTYPE;
    V_ZAD ZNJADJUSTDT%ROWTYPE;
  BEGIN
    --���쵥ͷ
    IF P_ZAHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('110', V_ZAH.ZAHNO, 'N'); --������ˮ��
      P_ZAHNO := V_ZAH.ZAHNO;
    ELSE
      V_ZAH.ZAHNO := P_ZAHNO;
    END IF;

    V_ZAH.ZAHBH         := V_ZAH.ZAHNO; --���ݱ��
    V_ZAH.ZAHLB         := '7'; --�������
    V_ZAH.ZAHSOURCE     := '1'; --������Դ
    V_ZAH.ZAHSMFID      := P_ZASMFID; --Ӫ����˾
    V_ZAH.ZAHDEPT       := P_ZAHDEPT; --����
    V_ZAH.ZAHCREATEDATE := P_ZAHCREDATE; --��������
    V_ZAH.ZAHCREATEPER  := P_ZAHCREPER; --������Ա
    V_ZAH.ZAHSHDATE     := NULL; --�������
    V_ZAH.ZAHSHPER      := NULL; --�����Ա
    V_ZAH.ZAHSHFLAG     := 'N'; --��˱�־
    INSERT INTO ZNJADJUSTHD VALUES V_ZAH;
    --���쵥��
    V_ZAD.ZADNO        := V_ZAH.ZAHNO; --������ˮ��
    V_ZAD.ZADROWNO     := 1; --�к�
    V_ZAD.ZADRLID      := P_RL.RLID; --����Ӧ����ˮ
    V_ZAD.ZADPIID      := 'NA'; --���������Ŀ��ȫ��ΪNA��
    V_ZAD.ZADMID       := P_RL.RLMID; --ˮ����
    V_ZAD.ZADMCODE     := P_RL.RLMCODE; --ˮ���
    V_ZAD.ZADMETHOD    := '1'; --���ⷽ����1��Ŀ������⣻2�����������⣻3�������⣻4�������������ڣ�
    V_ZAD.ZADVALUE     := P_ZNJ; --������/����ֵ
    V_ZAD.ZADZNDATE    := NULL; --����Ŀ��������
    V_ZAD.ZADINTZNJ    := P_RL.RLZNJ; --Ӧ��ΥԼ���
    V_ZAD.ZADINTZNDATE := P_RL.RLZNDATE; --Ӧ��ΥԼ��������
    V_ZAD.ZADMEMO      := '�����˷�';
    INSERT INTO ZNJADJUSTDT VALUES V_ZAD;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
END;
/


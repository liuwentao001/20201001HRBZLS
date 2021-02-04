CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_INVMANAGE_01" IS

  --�ܲ���� zhangrong
  PROCEDURE HQINSTORE(P_IITYPE     IN CHAR, --Ʊ������
                      P_IIRECEIVER IN VARCHAR2, --�����Ա
                      P_IISMFID    IN VARCHAR2, --��ⵥλ
                      P_IIBCNO     IN VARCHAR2, --����
                      P_IISNO      IN VARCHAR2, --���
                      P_IIENO      IN VARCHAR2 --ֹ��
                      ) AS
  
    CURSOR C1(V_SNO VARCHAR2, V_ENO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO >= V_SNO
         AND ISNO <= V_ENO
         AND ISTYPE = P_IITYPE
         FOR UPDATE NOWAIT;
  
    SNONUM NUMBER;
    ENONUM NUMBER;
    I      NUMBER;
  
    RT_IS INVSTOCK%ROWTYPE;
  
  BEGIN
  
    --���Ʊ�Ŷ����Ƿ���������
    OPEN C1(P_IISNO, P_IIENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������Ѵ��ڸú�����е�Ʊ��');
    END IF;
    CLOSE C1;
  
    --����invin��
    INSERT INTO INVIN
    VALUES
      (SEQ_INVIN.NEXTVAL,
       P_IITYPE,
       SYSDATE,
       '',
       P_IIRECEIVER,
       P_IIBCNO,
       P_IISNO,
       P_IIENO,
       P_IISMFID);
  
    --ѭ������invstock��
    SNONUM := TO_NUMBER(P_IISNO);
    ENONUM := TO_NUMBER(P_IIENO);
    FOR I IN SNONUM .. ENONUM LOOP
      INSERT INTO INVSTOCK
      VALUES
        (SEQ_INVSTOCK.NEXTVAL,
         P_IIRECEIVER,
         P_IITYPE,
         P_IIBCNO,
         TRIM(TO_CHAR(I, '00000000')),
         '0',
         SYSDATE,
         P_IIRECEIVER,
         NULL,
         NULL,
         NULL,
         P_IISMFID,
         '',
         '',
         0,
         '',
         '',
         '',
         '',
         '',
         TRIM(P_IIBCNO || '.' || TRIM(TO_CHAR(I, '00000000'))),
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         P_IIRECEIVER,
         sysdate);
    
    END LOOP;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --�ֳܲ��� zhangrong
  PROCEDURE HQOUTSTORE(P_IOTYPE   IN CHAR, --Ʊ������
                       P_IOSENDER IN VARCHAR2, --������Ա
                       P_IOSMFID  IN VARCHAR2, --���ⵥλ
                       P_IOBCNO   IN VARCHAR2, --����
                       P_IOSNO    IN VARCHAR2, --���
                       P_IOENO    IN VARCHAR2 --ֹ��
                       ) AS
  
    CURSOR C1(V_SNO VARCHAR2, V_ENO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO >= V_SNO
         AND ISNO <= V_ENO
         AND ISSTATUS IN ('1', '2')
         AND ISTYPE = P_IOTYPE
         FOR UPDATE NOWAIT;
  
    CNT    NUMBER;
    SNONUM NUMBER;
    ENONUM NUMBER;
  
    RT_IS INVSTOCK%ROWTYPE;
  
  BEGIN
  
    SNONUM := TO_NUMBER(P_IOSNO);
    ENONUM := TO_NUMBER(P_IOENO);
  
    --���Ʊ�Ŷ����Ƿ��п���в����ڵ�
    SELECT COUNT(*)
      INTO CNT
      FROM INVSTOCK
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE
       AND ISPER = P_IOSENDER;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ú�����п���в����ڵ�Ʊ��');
    END IF;
  
    --���Ʊ�Ŷ����Ƿ�����ʹ�û������ϵ�
    OPEN C1(P_IOSNO, P_IOENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ú��������ʹ�û������ϵ�Ʊ��');
    END IF;
    CLOSE C1;
  
    --����invout��
    INSERT INTO INVOUT
    VALUES
      (SEQ_INVOUT.NEXTVAL,
       P_IOTYPE,
       SYSDATE,
       P_IOSENDER,
       NULL,
       P_IOBCNO,
       P_IOSNO,
       P_IOENO,
       P_IOSMFID);
  
    --ɾ��invstock������
    DELETE FROM INVSTOCK
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --Ʊ����� zhangrong
  PROCEDURE INSTORE(P_IITYPE     IN CHAR, --Ʊ������
                    P_IISENDER   IN VARCHAR2, --�ɷ���Ա
                    P_IIRECEIVER IN VARCHAR2, --��ȡ��Ա
                    P_IISMFID    IN VARCHAR2, --��ⵥλ
                    P_IIBCNO     IN VARCHAR2, --����
                    P_IISNO      IN VARCHAR2, --���
                    P_IIENO      IN VARCHAR2 --ֹ��
                    ) AS
  
    CURSOR C1(V_SNO VARCHAR2, V_ENO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO >= V_SNO
         AND ISNO <= V_ENO
         AND ISTYPE = P_IITYPE
         AND ISPER = P_IIRECEIVER
         FOR UPDATE NOWAIT;
    CURSOR C2(V_SNO VARCHAR2, V_ENO VARCHAR2) IS
      SELECT COUNT(*)
        FROM INVSTOCK
       WHERE ISNO >= V_SNO
         AND ISNO <= V_ENO
         AND ISTYPE = P_IITYPE
         AND ISPER = P_IISENDER
         AND ISSTATUS = '0';
    --for update nowait;
    CURSOR C3(V_SNO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO < V_SNO
         AND ISTYPE = P_IITYPE
         AND ISPER = P_IISENDER
         AND ISSTATUS = '0'
         FOR UPDATE NOWAIT;
  
    RT_IS  INVSTOCK%ROWTYPE;
    CNT    INTEGER;
    SNONUM NUMBER;
    ENONUM NUMBER;
  
  BEGIN
  
    IF P_IISENDER = P_IIRECEIVER THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����ɷ����Լ�');
    END IF;
  
    SNONUM := TO_NUMBER(P_IISNO);
    ENONUM := TO_NUMBER(P_IIENO);
  
    --���Ʊ�Ŷ����Ƿ���������
    OPEN C1(P_IISNO, P_IIENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���Ѵ��ڸú�����е�Ʊ�ݣ������ɷ�');
    END IF;
    CLOSE C1;
  
    --����ɷ���Ա�Ƿ���Ʊ�Ŷ���Ʊ�ݿɷ�
    OPEN C2(P_IISNO, P_IIENO);
    FETCH C2
      INTO CNT;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '�ɷ��˲����ڸú�����е�Ʊ�ݣ������ɷ�');
    END IF;
    CLOSE C2;
  
    --����ɷ���Ա�Ƿ�Ʊ�Ŵ�С�����ɷ�
    /*open c3(p_iisno);
    fetch c3
      into rt_is;
    if c3%found then
      raise_application_error(errcode,
                              '�ɷ��˱��밴��С�����Ʊ�Ž����ɷ�');
    end if;
    close c3;*/
  
    --����invin��
    INSERT INTO INVIN
    VALUES
      (SEQ_INVIN.NEXTVAL,
       P_IITYPE,
       SYSDATE,
       P_IISENDER,
       P_IIRECEIVER,
       P_IIBCNO,
       P_IISNO,
       P_IIENO,
       P_IISMFID);
  
    --�ı��������ˡ�Ӫҵ����״̬
    UPDATE INVSTOCK
       SET ISPSTATUS      = ISSTATUS,
           ISPSTATUSDATEP = ISSTATUSDATE,
           ISPTATUSPER    = ISSTATUSPER
     WHERE ISNO >= P_IISNO
       AND ISNO <= P_IIENO
       AND ISTYPE = P_IITYPE;
    UPDATE INVSTOCK
       SET ISSTATUSDATE = SYSDATE,
           ISSTATUSPER  = P_IISENDER,
           ISPER        = P_IIRECEIVER,
           ISSMFID      = P_IISMFID
     WHERE ISNO >= P_IISNO
       AND ISNO <= P_IIENO
       AND ISTYPE = P_IITYPE;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      IF C2%ISOPEN THEN
        CLOSE C2;
      END IF;
      IF C3%ISOPEN THEN
        CLOSE C3;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --Ʊ�ݳ��� zhangrong
  PROCEDURE OUTSTORE(P_IOTYPE     IN CHAR, --Ʊ������
                     P_IOSENDER   IN VARCHAR2, --�ɷ���Ա
                     P_IORECEIVER IN VARCHAR2, --������Ա
                     P_IOSMFID    IN VARCHAR2, --���ⵥλ
                     P_IOBCNO     IN VARCHAR2, --����
                     P_IOSNO      IN VARCHAR2, --���
                     P_IOENO      IN VARCHAR2 --ֹ��
                     ) AS
  
    CURSOR C1(V_SNO VARCHAR2, V_ENO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO >= V_SNO
         AND ISNO <= V_ENO
         AND ISSTATUS IN ('1', '2')
         AND ISTYPE = P_IOTYPE
         FOR UPDATE NOWAIT;
  
    CNT    NUMBER;
    SNONUM NUMBER;
    ENONUM NUMBER;
  
    RT_IS INVSTOCK%ROWTYPE;
  
  BEGIN
    IF P_IOSENDER = P_IORECEIVER THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������Ʊ���Լ�');
    END IF;
  
    SNONUM := TO_NUMBER(P_IOSNO);
    ENONUM := TO_NUMBER(P_IOENO);
  
    --���Ʊ�Ŷ����Ƿ��п���в����ڵ�
    SELECT COUNT(*)
      INTO CNT
      FROM INVSTOCK
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE
       AND ISPER = P_IOSENDER;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ú�����п���в����ڵ�Ʊ��');
    END IF;
  
    --���Ʊ�Ŷ����Ƿ�����ʹ�û������ϵ�
    OPEN C1(P_IOSNO, P_IOENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ú��������ʹ�û������ϵ�Ʊ��');
    END IF;
    CLOSE C1;
  
    --����invout��
    INSERT INTO INVOUT
    VALUES
      (SEQ_INVOUT.NEXTVAL,
       P_IOTYPE,
       SYSDATE,
       P_IOSENDER,
       P_IORECEIVER,
       P_IOBCNO,
       P_IOSNO,
       P_IOENO,
       P_IOSMFID);
  
    --�ı��������˺�״̬
    UPDATE INVSTOCK
       SET ISPSTATUS      = ISSTATUS,
           ISPSTATUSDATEP = ISSTATUSDATE,
           ISPTATUSPER    = ISSTATUSPER
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE;
    UPDATE INVSTOCK
       SET ISSTATUSDATE = SYSDATE,
           ISSTATUSPER  = P_IOSENDER,
           ISPER        = P_IORECEIVER,
           ISSMFID      = FSYSMANALBBM(FGETOPERDEPT(P_IORECEIVER), '1')
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --��¼��ӡƱ�� zhangrong
  PROCEDURE RECINVNO(P_ILNO     IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                     P_ILRLID   IN VARCHAR2, --Ӧ����ˮ(###|###|)
                     P_ILRDPIID IN VARCHAR2, --������Ŀ(###|###|)
                     P_ILJE     IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                     P_ILTYPE   IN CHAR, --Ʊ������
                     P_ILCD     IN CHAR, --�������
                     P_ILPER    IN VARCHAR2, --��Ʊ��
                     P_ILSTATUS IN CHAR, --Ʊ��״̬
                     P_ILSMFID  IN VARCHAR2 --�ֹ�˾
                     ) AS
  
    CURSOR C_IS(VILNO VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISNO = VILNO
         AND ISSTATUS = '0'
         AND ISTYPE = P_ILTYPE
         FOR UPDATE NOWAIT;
  
    CURSOR C_PI IS
      SELECT * FROM PRICEITEM;
  
    I NUMBER;
  
    RT_IS INVSTOCK%ROWTYPE;
    RI    RECINV%ROWTYPE;
    PI    PRICEITEM%ROWTYPE;
  
    VILNO     VARCHAR2(12);
    VILRLID   VARCHAR2(100);
    VILRDPIID VARCHAR2(100);
    VILJE     VARCHAR2(12);
    VILID     VARCHAR2(32);
    V_PIID    VARCHAR2(32);
  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_ILNO) LOOP
      VILNO := TOOLS.FGETPARA2(P_ILNO, I, 1);
    
      --��֤Ʊ���Ƿ����
      OPEN C_IS(VILNO);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��Ч��Ʊ���룺[' || VILNO || ']����������Ʊ�����Ƿ����');
      END IF;
      CLOSE C_IS;
    
      VILRLID   := TOOLS.FGETPARA2(P_ILRLID, I, 1);
      VILRDPIID := TOOLS.FGETPARA2(P_ILRDPIID, I, 1);
      VILJE     := TOOLS.FGETPARA2(P_ILJE, I, 1);
      SELECT SEQ_ILID.NEXTVAL INTO VILID FROM DUAL;
    
      --����INVOICELIST
      INSERT INTO INVOICELIST
        (ILID,
         ILTYPE,
         ILCD,
         ILBCNO,
         ILNO,
         ILMONTH,
         ILDATE,
         ILPER,
         ILJE,
         ILSTATUS,
         ILSTATUSDATE,
         ILSMFID,
         ILSTATUSPER,
         ILRLID,
         ILRDPIID,
         ILDATETIME)
      VALUES
        (VILID,
         P_ILTYPE,
         P_ILCD,
         NULL,
         VILNO,
         FPARA('020101', '000007'),
         TO_DATE(FPARA('020101', '000002'), 'yyyy.mm.dd'),
         P_ILPER,
         TO_NUMBER(VILJE),
         P_ILSTATUS,
         NULL,
         P_ILSMFID,
         NULL,
         VILRLID,
         VILRDPIID,
         SYSDATE);
    
      --����recinv
      IF VILRLID IS NOT NULL AND VILRDPIID IS NOT NULL THEN
        RI.RIILID := VILID;
        FOR I IN 1 .. TOOLS.FBOUNDPARA2(VILRLID) LOOP
          RI.RIRLID := FGETPARA3(VILRLID, 1, I);
          V_PIID    := FGETPARA3(VILRDPIID, 1, I);
        
          OPEN C_PI;
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;
          
            IF INSTR(V_PIID, PI.PIID) != 0 THEN
              RI.RIPIID := PI.PIID;
              INSERT INTO RECINV VALUES RI;
            END IF;
          
          END LOOP;
          CLOSE C_PI;
        END LOOP;
      END IF;
    
      --����invstock
      UPDATE INVSTOCK
         SET ISPSTATUS      = ISSTATUS,
             ISPSTATUSDATEP = ISSTATUSDATE,
             ISPTATUSPER    = ISSTATUSPER
       WHERE ISNO = VILNO
         AND ISTYPE = P_ILTYPE;
      UPDATE INVSTOCK
         SET ISSTATUS = '1', ISSTATUSDATE = SYSDATE, ISSTATUSPER = P_ILPER
       WHERE ISNO = VILNO
         AND ISTYPE = P_ILTYPE;
    
    END LOOP;
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_IS%ISOPEN THEN
        CLOSE C_IS;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --Ʊ���ս� zhangrong
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR) --Ʊ������
   AS
    CURSOR C1 IS
      SELECT OAID, FSYSMANALBBM(OADEPT, '1')
        FROM OPERACCNT, OPERACCNTROLE
       WHERE OAROAID = OAID
         AND OARRID IN ('03', '17', '19')
         FOR UPDATE NOWAIT;
    V_OAID      VARCHAR2(15); --����
    V_OASMFID   VARCHAR2(10); --Ӫҵ��
    V_LNUM      INTEGER; --������
    V_TNUM      INTEGER; --��Ʊ��
    V_SNUM      INTEGER; --ʹ����
    V_FNUM      INTEGER; --������
    V_CNT       INTEGER; --��¼��
    V_LASTQMNUM INTEGER; --������ĩ��������
    V_THISQMNUM INTEGER; --������ĩ��������
  
    V_THISDATE DATE; --����Ʊ������
  BEGIN
    SELECT TO_DATE(SMPPVALUE, 'yyyy.mm.dd')
      INTO V_THISDATE
      FROM SYSMANAPARA
     WHERE SMPID = '020105'
       AND SMPPID = '000002';
    OPEN C1;
    LOOP
      FETCH C1
        INTO V_OAID, V_OASMFID;
      EXIT WHEN C1%NOTFOUND OR C1%NOTFOUND IS NULL;
    
      --ȡ������
      SELECT NVL(SUM(TO_NUMBER(IIENO) - TO_NUMBER(IISNO) + 1), 0)
        INTO V_LNUM
        FROM INVIN
       WHERE IIRECEIVER = V_OAID
         AND IITYPE = P_INVTYPE
         AND TRUNC(IIDATE) = TRUNC(V_THISDATE);
    
      --ȡ��Ʊ��
      SELECT NVL(SUM(TO_NUMBER(IOENO) - TO_NUMBER(IOSNO) + 1), 0)
        INTO V_TNUM
        FROM INVOUT
       WHERE IOSENDER = V_OAID
         AND IOTYPE = P_INVTYPE
         AND TRUNC(IODATE) = TRUNC(V_THISDATE);
    
      --ȡʹ����
      SELECT COUNT(*)
        INTO V_SNUM
        FROM INVOICELIST
       WHERE ILPER = V_OAID
         AND ILTYPE = P_INVTYPE
         AND TRUNC(ILDATE) = TRUNC(V_THISDATE);
    
      --ȡ������
      SELECT COUNT(*)
        INTO V_FNUM
        FROM INVCANCEL
       WHERE ICPER = V_OAID
         AND ICTYPE = P_INVTYPE
         AND TRUNC(ICDATE) = TRUNC(V_THISDATE);
    
      --����/���� invdailybalance ��
      SELECT COUNT(*)
        INTO V_CNT
        FROM INVDAILYBALANCE
       WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
         AND IDBTYPE = P_INVTYPE
         AND IDBPER = V_OAID;
    
      IF V_CNT = 0 THEN
        --δ�����ս᣺�����¼
        BEGIN
          SELECT IDBQM
            INTO V_LASTQMNUM
            FROM INVDAILYBALANCE
           WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE - 1)
             AND IDBTYPE = P_INVTYPE
             AND IDBPER = V_OAID;
        EXCEPTION
          WHEN OTHERS THEN
            SELECT COUNT(ISNO)
              INTO V_LASTQMNUM
              FROM INVSTOCK
             WHERE ISPER = V_OAID
               AND ISTYPE = P_INVTYPE
               AND ISSTATUS = '0';
        END;
        V_THISQMNUM := V_LASTQMNUM + V_LNUM - V_TNUM - V_SNUM - V_FNUM;
      
        INSERT INTO INVDAILYBALANCE
        VALUES
          (V_THISDATE,
           V_OASMFID,
           V_OAID,
           V_LASTQMNUM,
           V_THISQMNUM,
           V_LNUM,
           V_TNUM,
           V_SNUM,
           V_FNUM,
           P_INVTYPE);
      
        --�������ս᣺���¼�¼
      ELSE
        UPDATE INVDAILYBALANCE
           SET IDBL  = V_LNUM,
               IDBT  = V_TNUM,
               IDBS  = V_SNUM,
               IDBF  = V_FNUM,
               IDBQM = IDBQC + V_LNUM - V_TNUM - V_SNUM - V_FNUM
         WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
           AND IDBPER = V_OAID
           AND IDBTYPE = P_INVTYPE;
      
      END IF;
    END LOOP;
  
    --����ս���ϸ
    DELETE FROM INVSTOCKDAILYBALANCE
     WHERE TRUNC(ISDBDATE) = TRUNC(V_THISDATE)
       AND ISDBTYPE = P_INVTYPE;
    INSERT INTO INVSTOCKDAILYBALANCE
      SELECT V_THISDATE,
             ISID,
             ISPER,
             ISTYPE,
             ISBCNO,
             NULL /*Ʊ�ݺ���*/,
             ISSTATUS,
             ISSTATUSDATE,
             ISSTATUSPER,
             ISPSTATUS,
             ISPSTATUSDATEP,
             ISPTATUSPER,
             ISSMFID,
             ST ISSNO,
             EN ISENO,
             TO_NUMBER(EN - ST + 1) ISNUM
        FROM (SELECT ISTYPE,
                     ISPER,
                     ISID,
                     ISSMFID,
                     ISBCNO,
                     ISSTATUS,
                     ISSTATUSDATE,
                     ISSTATUSPER,
                     ISPSTATUS,
                     ISPSTATUSDATEP,
                     ISPTATUSPER,
                     NVL(LAG(E) OVER(PARTITION BY ISTYPE,
                              ISSMFID,
                              ISPER,
                              ISSTATUS ORDER BY S),
                         MINN) ST,
                     NVL(S, MAXN) EN
                FROM (SELECT ISTYPE,
                             ISID,
                             ISPER,
                             ISSMFID,
                             ISSTATUS,
                             ISBCNO,
                             ISSTATUSDATE,
                             ISSTATUSPER,
                             ISPSTATUS,
                             ISPSTATUSDATEP,
                             ISPTATUSPER,
                             LAG(ISNO, 1) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS ORDER BY ISNO) S,
                             ISNO E,
                             MIN(ISNO) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS) MINN,
                             MAX(ISNO) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS) MAXN
                        FROM INVSTOCK
                       WHERE ISSTATUS = '0'
                         AND ISTYPE = P_INVTYPE)
               WHERE NVL(E - S - 1, 1) != 0);
  
    COMMIT;
    CLOSE C1;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --Ʊ���ս�_�ֶ�ִ�� zhangrong
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR, BALDATE VARCHAR2) --Ʊ������
   AS
    CURSOR C1 IS
      SELECT OAID, FSYSMANALBBM(OADEPT, '1')
        FROM OPERACCNT, OPERACCNTROLE
       WHERE OAROAID = OAID
         AND OARRID IN ('03', '17', '19')
         FOR UPDATE NOWAIT;
    V_OAID      VARCHAR2(15); --����
    V_OASMFID   VARCHAR2(10); --Ӫҵ��
    V_LNUM      INTEGER; --������
    V_TNUM      INTEGER; --��Ʊ��
    V_SNUM      INTEGER; --ʹ����
    V_FNUM      INTEGER; --������
    V_CNT       INTEGER; --��¼��
    V_LASTQMNUM INTEGER; --������ĩ��������
    V_THISQMNUM INTEGER; --������ĩ��������
  
    V_THISDATE DATE; --����Ʊ������
  BEGIN
    SELECT TO_DATE(BALDATE, 'yyyy.mm.dd') INTO V_THISDATE FROM DUAL;
    OPEN C1;
    LOOP
      FETCH C1
        INTO V_OAID, V_OASMFID;
      EXIT WHEN C1%NOTFOUND OR C1%NOTFOUND IS NULL;
    
      --ȡ������
      SELECT NVL(SUM(TO_NUMBER(IIENO) - TO_NUMBER(IISNO) + 1), 0)
        INTO V_LNUM
        FROM INVIN
       WHERE IIRECEIVER = V_OAID
         AND IITYPE = P_INVTYPE
         AND TRUNC(IIDATE) = TRUNC(V_THISDATE);
    
      --ȡ��Ʊ��
      SELECT NVL(SUM(TO_NUMBER(IOENO) - TO_NUMBER(IOSNO) + 1), 0)
        INTO V_TNUM
        FROM INVOUT
       WHERE IOSENDER = V_OAID
         AND IOTYPE = P_INVTYPE
         AND TRUNC(IODATE) = TRUNC(V_THISDATE);
    
      --ȡʹ����
      SELECT COUNT(*)
        INTO V_SNUM
        FROM INVOICELIST
       WHERE ILPER = V_OAID
         AND ILTYPE = P_INVTYPE
         AND TRUNC(ILDATE) = TRUNC(V_THISDATE);
    
      --ȡ������
      SELECT COUNT(*)
        INTO V_FNUM
        FROM INVCANCEL
       WHERE ICPER = V_OAID
         AND ICTYPE = P_INVTYPE
         AND TRUNC(ICDATE) = TRUNC(V_THISDATE);
    
      --����/���� invdailybalance ��
      SELECT COUNT(*)
        INTO V_CNT
        FROM INVDAILYBALANCE
       WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
         AND IDBTYPE = P_INVTYPE
         AND IDBPER = V_OAID;
    
      IF V_CNT = 0 THEN
        --δ�����ս᣺�����¼
        BEGIN
          SELECT IDBQM
            INTO V_LASTQMNUM
            FROM INVDAILYBALANCE
           WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE - 1)
             AND IDBTYPE = P_INVTYPE
             AND IDBPER = V_OAID;
        EXCEPTION
          WHEN OTHERS THEN
            SELECT COUNT(ISNO)
              INTO V_LASTQMNUM
              FROM INVSTOCK
             WHERE ISPER = V_OAID
               AND ISTYPE = P_INVTYPE
               AND ISSTATUS = '0';
        END;
        V_THISQMNUM := V_LASTQMNUM + V_LNUM - V_TNUM - V_SNUM - V_FNUM;
      
        INSERT INTO INVDAILYBALANCE
        VALUES
          (V_THISDATE,
           V_OASMFID,
           V_OAID,
           V_LASTQMNUM,
           V_THISQMNUM,
           V_LNUM,
           V_TNUM,
           V_SNUM,
           V_FNUM,
           P_INVTYPE);
      
        --�������ս᣺���¼�¼
      ELSE
        UPDATE INVDAILYBALANCE
           SET IDBL  = V_LNUM,
               IDBT  = V_TNUM,
               IDBS  = V_SNUM,
               IDBF  = V_FNUM,
               IDBQM = IDBQC + V_LNUM - V_TNUM - V_SNUM - V_FNUM
         WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
           AND IDBPER = V_OAID
           AND IDBTYPE = P_INVTYPE;
      
      END IF;
    END LOOP;
  
    --����ս���ϸ
    DELETE FROM INVSTOCKDAILYBALANCE
     WHERE TRUNC(ISDBDATE) = TRUNC(V_THISDATE)
       AND ISDBTYPE = P_INVTYPE;
    INSERT INTO INVSTOCKDAILYBALANCE
      SELECT V_THISDATE,
             ISID,
             ISPER,
             ISTYPE,
             ISBCNO,
             NULL /*Ʊ�ݺ���*/,
             ISSTATUS,
             ISSTATUSDATE,
             ISSTATUSPER,
             ISPSTATUS,
             ISPSTATUSDATEP,
             ISPTATUSPER,
             ISSMFID,
             ST ISSNO,
             EN ISENO,
             TO_NUMBER(EN - ST + 1) ISNUM
        FROM (SELECT ISTYPE,
                     ISPER,
                     ISID,
                     ISSMFID,
                     ISBCNO,
                     ISSTATUS,
                     ISSTATUSDATE,
                     ISSTATUSPER,
                     ISPSTATUS,
                     ISPSTATUSDATEP,
                     ISPTATUSPER,
                     NVL(LAG(E) OVER(PARTITION BY ISTYPE,
                              ISSMFID,
                              ISPER,
                              ISSTATUS ORDER BY S),
                         MINN) ST,
                     NVL(S, MAXN) EN
                FROM (SELECT ISTYPE,
                             ISID,
                             ISPER,
                             ISSMFID,
                             ISSTATUS,
                             ISBCNO,
                             ISSTATUSDATE,
                             ISSTATUSPER,
                             ISPSTATUS,
                             ISPSTATUSDATEP,
                             ISPTATUSPER,
                             LAG(ISNO, 1) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS ORDER BY ISNO) S,
                             ISNO E,
                             MIN(ISNO) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS) MINN,
                             MAX(ISNO) OVER(PARTITION BY ISTYPE, ISSMFID, ISPER, ISSTATUS) MAXN
                        FROM INVSTOCK
                       WHERE ISSTATUS = '0'
                         AND ISTYPE = P_INVTYPE)
               WHERE NVL(E - S - 1, 1) != 0);
  
    COMMIT;
    CLOSE C1;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C1%ISOPEN THEN
        CLOSE C1;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --δʹ��Ʊ������
  PROCEDURE CANCEL(P_ICPER   IN VARCHAR2, --Ʊ��������
                   P_ICSMFID IN VARCHAR2, --���ϵ�λ
                   P_ICTYPE  IN CHAR, --Ʊ������
                   P_ICNO    IN VARCHAR2 --Ʊ�ݱ��
                   ) AS
  
    V_CNT INTEGER; --��¼����
  BEGIN
    --��֤��Ʊ���Ƿ������
    SELECT COUNT(*)
      INTO V_CNT
      FROM INVSTOCK
     WHERE ISPER = P_ICPER
       AND ISTYPE = P_ICTYPE
       AND ISNO = P_ICNO
       AND ISSTATUS = '0';
    IF V_CNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ�Ų������ϣ�����Ʊ�������ˡ�Ʊ��״̬��Ʊ������');
    END IF;
  
    --����
    INSERT INTO INVCANCEL
    VALUES
      (SEQ_INVCANCEL.NEXTVAL,
       P_ICTYPE,
       SYSDATE,
       P_ICPER,
       P_ICNO,
       P_ICSMFID);
  
    --���¿��
    UPDATE INVSTOCK
       SET ISSTATUS = '2'
     WHERE ISPER = P_ICPER
       AND ISTYPE = P_ICTYPE
       AND ISNO = P_ICNO;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --��������ˮ
  --ȡ����Ҫʹ�÷�Ʊ�ţ�ϵͳ��ţ�
  FUNCTION FGETINVNO(P_PER    IN VARCHAR2, --����Ա
                     P_IITYPE IN VARCHAR2, --��Ʊ����
                     P_SNO    IN NUMBER --��Ʊ��ˮ��
                     ) RETURN NUMBER AS
  
    VCOUNT NUMBER(10);
    V_ISID NUMBER(10);
    CURSOR C_IT IS
      SELECT ISID
      
        FROM INVSTOCK T
       WHERE ISTYPE = P_IITYPE
         AND T.ISPER = P_PER
         AND T.ISSTATUS = '0'
       ORDER BY T.ISBCNO, T.ISNO;
    IT INVSTOCK%ROWTYPE;
  BEGIN
    IF P_SNO IS NULL THEN
      OPEN C_IT;
      FETCH C_IT
        INTO IT.ISID;
      NULL;
      CLOSE C_IT;
      RETURN IT.ISID;
    ELSE
      SELECT COUNT(*)
        INTO VCOUNT
        FROM INVSTOCK T
       WHERE ISTYPE = P_IITYPE
         AND T.ISPER = P_PER
         AND T.ISSTATUS = '0'
         AND T.ISID = P_SNO;
      IF VCOUNT >= 1 THEN
        SELECT T.ISID
          INTO V_ISID
          FROM INVSTOCK T
         WHERE ISTYPE = P_IITYPE
           AND T.ISPER = P_PER
           AND T.ISSTATUS = '0'
           AND T.ISID = P_SNO;
        RETURN V_ISID;
      ELSE
        NULL;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --��������ˮ
  --ȡ����Ҫʹ�÷�Ʊ��
  FUNCTION FGETINVNO_STR(P_PER    IN VARCHAR2, --����Ա
                         P_IITYPE IN VARCHAR2 --��Ʊ����
                         ) RETURN VARCHAR2 AS
    CURSOR C_IT IS
      SELECT ISNO
      
        FROM INVSTOCK T
       WHERE ISTYPE = P_IITYPE
         AND T.ISPER = P_PER
         AND T.ISSTATUS = '0'
       ORDER BY T.ISBCNO, T.ISNO;
    IT INVSTOCK%ROWTYPE;
  BEGIN
    OPEN C_IT;
    FETCH C_IT
      INTO IT.ISNO;
    NULL;
    CLOSE C_IT;
    RETURN IT.ISNO;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --��������ԱƱ����Ϣ
  FUNCTION FGETHADINV(P_PER IN VARCHAR2 --����Ա
                      
                      ) RETURN VARCHAR2 AS
    V_STR VARCHAR2(2000);
  BEGIN
    SELECT 'ˮ�ѷ�Ʊ�ţ�' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'S') ||
           '���ƣ�' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'S') || '�ţ�' ||
           '��ˮ�ѷ�Ʊ�ţ�' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'W') ||
           '���ƣ�' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'W') || '�ţ�'
      INTO V_STR
      FROM DUAL;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --��������ԱƱ����Ϣ[TS]
  FUNCTION FGETHADINVTS(P_PER IN VARCHAR2 --����Ա
                        
                        ) RETURN VARCHAR2 AS
    V_STR VARCHAR2(2000);
  BEGIN
    SELECT 'ˮ�ѷ�Ʊ�ţ�' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'T') ||
           '���ƣ�' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'T') || '�ţ�' ||
           '��ˮ�ѷ�Ʊ�ţ�' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'U') ||
           '���ƣ�' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'U') || '�ţ�'
      INTO V_STR
      FROM DUAL;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --��������ˮ
  --ȡ����Ҫʹ�÷�Ʊ�Ŵ��������Ự����

  FUNCTION FGETINVNO_TEMP(P_PER    IN VARCHAR2, --����Ա
                          P_IITYPE IN VARCHAR2, --��Ʊ����
                          P_COUNT  IN NUMBER, --Ҫȡ��Ʊ����
                          P_SNO    IN NUMBER -- ��Ʊ����
                          ) RETURN NUMBER AS
    I  NUMBER(10);
    IT INVSTOCK%ROWTYPE;
    CURSOR C_IT IS
      SELECT *
        INTO IT
        FROM INVSTOCK T
       WHERE ISTYPE = P_IITYPE
         AND T.ISPER = P_PER
         AND T.ISSTATUS = '0'
       ORDER BY T.ISBCNO, T.ISNO;
  
    CURSOR C_IT_NEW IS
      SELECT *
        INTO IT
        FROM INVSTOCK T
       WHERE ISTYPE = P_IITYPE
         AND T.ISPER = P_PER
         AND T.ISSTATUS = '0'
         AND T.ISID >= P_SNO
       ORDER BY T.ISBCNO, T.ISNO;
  
  BEGIN
    IF P_COUNT <= 0 THEN
      RETURN 0;
    END IF;
    DELETE PBPARMTEMPFORINV; -- PBPARMNNOCOMMIT;
  
    --δָ����Ʊ��
    IF P_SNO IS NULL THEN
      I := 0;
      OPEN C_IT;
      LOOP
        FETCH C_IT
          INTO IT;
        EXIT WHEN C_IT%NOTFOUND OR C_IT%NOTFOUND IS NULL;
        I := I + 1;
        INSERT INTO PBPARMTEMPFORINV (C1, C2) VALUES (IT.ISID, I);
        IF P_COUNT = I THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE C_IT;
      RETURN I;
    ELSE
      --�ƶ�Ʊ��
      I := 0;
      OPEN C_IT_NEW;
      LOOP
        FETCH C_IT_NEW
          INTO IT;
        EXIT WHEN C_IT_NEW%NOTFOUND OR C_IT_NEW%NOTFOUND IS NULL;
        I := I + 1;
        INSERT INTO PBPARMTEMPFORINV (C1, C2) VALUES (IT.ISID, I);
        IF P_COUNT = I THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE C_IT_NEW;
      RETURN I;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --��������ˮ
  --ȡ�Ự���� ��Ʊ��
  FUNCTION FGETINVNO_FROMTEMP(P_I IN NUMBER --�ڼ��ŷ�Ʊ
                              ) RETURN NUMBER AS
  
    V_INVNO NUMBER(10);
  
  BEGIN
    SELECT C1 INTO V_INVNO FROM PBPARMTEMPFORINV WHERE C2 = P_I;
    RETURN V_INVNO;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --��������ˮ
  --ȡ���÷�Ʊ������
  FUNCTION FGETINVCOUNT(P_PER    IN VARCHAR2, --����Ա
                        P_IITYPE IN VARCHAR2 --��Ʊ����
                        ) RETURN NUMBER AS
  
    V_COUNT NUMBER(10);
  BEGIN
  
    SELECT COUNT(ISNO)
      INTO V_COUNT
      FROM INVSTOCK T
     WHERE ISTYPE = P_IITYPE
       AND T.ISPER = P_PER
       AND T.ISSTATUS = '0';
    RETURN V_COUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --��¼��ӡƱ�� ����
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE RECINVNO_EZ(P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                        P_ILNO        IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                        P_ILRLID      IN VARCHAR2, --Ӧ����ˮ(###|###|)
                        P_ILRDPIID    IN VARCHAR2, --������Ŀ(###|###|)
                        P_ILJE        IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                        P_ILTYPE      IN CHAR, --Ʊ������
                        P_ILCD        IN CHAR, --�������
                        P_ILPER       IN VARCHAR2, --��Ʊ��
                        P_ILSTATUS    IN CHAR, --Ʊ��״̬
                        P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                        P_TRANS       IN VARCHAR2, --����
                        P_ISZZS       IN VARCHAR2 --��ֵ˰
                        ) AS
  
    CURSOR C_IS(VISID VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISID = VISID
         AND ISSTATUS = '0'
         AND ISTYPE = P_ILTYPE
         AND ISPER = P_ILPER;
  
    I NUMBER;
  
    RT_IS INVSTOCK%ROWTYPE;
  
    V_ISID    NUMBER(12);
    VILRLID   VARCHAR2(4000);
    VILRDPIID VARCHAR2(4000);
    VILJE     VARCHAR2(12);
    VILID     VARCHAR2(32);
    V_PIID    VARCHAR2(32);
  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_ILNO) LOOP
      V_ISID := TOOLS.FGETPARA2(P_ILNO, I, 1);
    
      --��֤Ʊ���Ƿ����
      OPEN C_IS(V_ISID);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��Ч��Ʊ���룺[' || V_ISID || ']����������Ʊ�����Ƿ����');
      END IF;
      CLOSE C_IS;
    
      VILRLID   := TOOLS.FGETPARA2(P_ILRLID, I, 1);
      VILRDPIID := TOOLS.FGETPARA2(P_ILRDPIID, I, 1);
      VILJE     := TOOLS.FGETPARA2(P_ILJE, I, 1);
    
      --����invstock
      UPDATE INVSTOCK
         SET ISPSTATUS      = RT_IS.ISPSTATUS,
             ISPSTATUSDATEP = RT_IS.ISPSTATUSDATEP,
             ISPTATUSPER    = RT_IS.ISPTATUSPER
       WHERE ISID = V_ISID
         AND ISTYPE = P_ILTYPE
         AND ISPER = P_ILPER;
      UPDATE INVSTOCK
         SET ISSTATUS     = '1',
             ISSTATUSDATE = SYSDATE,
             ISSTATUSPER  = P_ILPER,
             ISPRINTTYPE  = P_ISPRINTTYPE, --��ӡ��ʽ��1:ʵ�մ�ӡ����pbatch��2:ʵ��pid3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid)
             ISPRINTCD    = P_ILCD, --��de/cr
             ISPRINTJE    = VILJE, --Ʊ����
             ISPRINTTRANS = P_TRANS, --�������
             ISZZS        = P_ISZZS --��ֵ˰��־
       WHERE ISID = V_ISID
         AND ISTYPE = P_ILTYPE
         AND ISPER = P_ILPER;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_IS%ISOPEN THEN
        CLOSE C_IS;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE SP_FCHARGEINVREG(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER --��Ʊ��ˮ
                             )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    PL            PAIDLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
    CURSOR C_PBATCH_MX(AS_PBARCH VARCHAR2) IS
      SELECT * FROM PAYMENT WHERE PBATCH = AS_PBARCH ORDER BY PID;
    CURSOR C_PBATCH_MX_NO_S(AS_PBARCH VARCHAR2) IS
      SELECT *
        FROM PAYMENT
       WHERE PBATCH = AS_PBARCH
         AND PTRANS <> 'S'
       ORDER BY PID;
    CURSOR C_PBATCH_PLID_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM PAIDLIST T, PAYMENT T1
       WHERE PID = PLPID
         AND PID = AS_PID
       ORDER BY PID || PLID;
    CURSOR C_PBATCH_PLID_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.* FROM PAIDLIST T WHERE PLID = AS_PID;
    CURSOR C_RLID_PBPARMTEMP IS
      SELECT T.* FROM PBPARMTEMP T;
    CURSOR C_PBATCH_PID_MX IS
      SELECT T.* FROM PBPARMNNOCOMMIT_PRINT T;
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
    V_ISPRINTJE01 := 0;
    --���������δ�ӡ payment.pbatch
    IF P_ISPRINTTYPE = '1' THEN
      IF P_IFFPHP = 'H' THEN
        SELECT SUM((T.PPAYMENT - T.PCHANGE)),
               COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE, V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL  T,
               PAIDLIST   T1,
               PAIDDETAIL T2,
               PAYMENT    T3,
               METERINFO  T4
         WHERE PBATCH = P_ID
           AND PID = PLPID
           AND PLRLID = RDID
           AND PLID = PDID
           AND RDPIID = PDPIID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        ELSE
          IF V_COUNT1 > V_COUNT2 THEN
            SELECT PTRANS
              INTO V_TRNAS
              FROM PAYMENT T
             WHERE PBATCH = P_ID
               AND PTRANS <> 'S'
               AND ROWNUM = 1;
          ELSE
            V_TRNAS := 'S';
          END IF;
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��Ʊ����
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        RECINVNO_EZ(P_ISPRINTTYPE, --��ӡ��ʽ
                    V_ISID || '|', --Ʊ�ݺ���(###|###|)
                    P_ID || '|', --Ӧ����ˮ(###|###|)
                    '' || '|', --������Ŀ(###|###|)
                    V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                    P_ILTYPE, --Ʊ������
                    P_ISPRINTCD, --�������
                    P_PRINTER, --��Ʊ��
                    P_ILSTATUS, --Ʊ��״̬
                    P_ILSMFID, --�ֹ�˾
                    V_TRNAS,
                    V_ISZZS);
      
      ELSIF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM PAYMENT T, PAIDLIST T1
         WHERE PBATCH = P_ID
           AND PID = PLPID(+);
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO --��Ʊ��ˮ
                                        );
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I := 0;
      
        IF V_INVRETCOUNT = 1 THEN
        
          OPEN C_PBATCH_MX(P_ID);
          LOOP
            FETCH C_PBATCH_MX
              INTO PM;
            EXIT WHEN C_PBATCH_MX%NOTFOUND OR C_PBATCH_MX%NOTFOUND IS NULL;
          
            V_ISPRINTJE01 := 0;
          
            IF PM.PTRANS = 'S' THEN
              I      := I + 1;
              V_ISID := FGETINVNO_FROMTEMP(I);
              /* v_ilno      := fgetinvno(P_PRINTER, --����Ա
              p_iltype --��Ʊ����
              );*/
              IF V_ISID IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
              END IF;
            
              V_ISPRINTJE := PM.PPAYMENT - PM.PCHANGE;
            
              IF V_ISPRINTJE01 <> 0 THEN
                V_ISZZS := 'Y';
              
              ELSE
                V_ISZZS := 'N';
              END IF;
            
              RECINVNO_EZ('2', --��ӡ��ʽ
                          V_ISID || '|', --Ʊ�ݺ���(###|###|)
                          PM.PID || '|', --Ӧ����ˮ(###|###|)
                          '' || '|', --������Ŀ(###|###|)
                          V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                          P_ILTYPE, --Ʊ������
                          PM.PCD, --�������
                          P_PRINTER, --��Ʊ��
                          P_ILSTATUS, --Ʊ��״̬
                          P_ILSMFID, --�ֹ�˾
                          PM.PTRANS,
                          V_ISZZS);
            ELSE
            
              OPEN C_PBATCH_PLID_MX(PM.PID);
              LOOP
                FETCH C_PBATCH_PLID_MX
                  INTO PL;
                EXIT WHEN C_PBATCH_PLID_MX%NOTFOUND OR C_PBATCH_PLID_MX%NOTFOUND IS NULL;
                V_ISPRINTJE01 := 0;
                I             := I + 1;
              
                V_ISPRINTJE := PL.PLJE + PL.PLZNJ + PL.PLSAVINGBQ;
              
                --����ˮ�ѽ��  (��ֵ˰�û�)
                SELECT SUM(CASE
                             WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                              RDJE
                             ELSE
                              0
                           END)
                  INTO V_ISPRINTJE01
                  FROM RECDETAIL  T,
                       PAIDLIST   T1,
                       PAIDDETAIL T2,
                       PAYMENT    T3,
                       METERINFO  T4
                 WHERE PLID = PL.PLID
                   AND PLRLID = RDID
                   AND PLID = PDID
                   AND RDPIID = PDPIID
                   AND PID = PLPID
                   AND PMID = MIID;
              
                V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
              
                V_ISID := FGETINVNO_FROMTEMP(I);
                /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
                p_iltype --��Ʊ����
                );*/
                IF V_ISID IS NULL THEN
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                          '��Ʊ�����꣬����ȡ��Ʊ');
                END IF;
              
                IF V_ISPRINTJE01 <> 0 THEN
                  V_ISZZS := 'Y';
                
                ELSE
                
                  V_ISZZS := 'N';
                
                END IF;
              
                RECINVNO_EZ('3', --��ӡ��ʽ
                            V_ISID || '|', --Ʊ�ݺ���(###|###|)
                            PL.PLID || '|', --Ӧ����ˮ(###|###|)
                            '' || '|', --������Ŀ(###|###|)
                            V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                            P_ILTYPE, --Ʊ������
                            PL.PLCD, --�������
                            P_PRINTER, --��Ʊ��
                            P_ILSTATUS, --Ʊ��״̬
                            P_ILSMFID, --�ֹ�˾
                            PM.PTRANS,
                            V_ISZZS);
              END LOOP;
              CLOSE C_PBATCH_PLID_MX;
            END IF;
          END LOOP;
          CLOSE C_PBATCH_MX;
        ELSE
        
          ---��תԤ�油����Ʊ��ȥ
          V_PLID := '';
          V_YCJE := 0;
          SELECT COUNT(*)
            INTO V_COUNT
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS <> 'S';
          IF V_COUNT > 0 THEN
            SELECT MAX(PID || '@' || PMID || PTRANS || (PPAYMENT - PCHANGE))
              INTO V_PIDSTR
              FROM PAYMENT T
             WHERE PBATCH = P_ID;
            V_PID    := SUBSTR(V_PIDSTR, 1, 10);
            V_PMID   := SUBSTR(V_PIDSTR, 12, 10);
            V_PTRANS := SUBSTR(V_PIDSTR, 22, 1);
            V_YCJE   := TO_NUMBER(SUBSTR(V_PIDSTR, 23));
            IF V_PTRANS = 'S' THEN
              BEGIN
                SELECT MAX(PLID)
                  INTO V_PLID
                  FROM PAYMENT T, PAIDLIST T1
                 WHERE PID = PLPID
                   AND PBATCH = P_ID;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20010, '��Ʊ�쳣');
              END;
            END IF;
          END IF;
        
          OPEN C_PBATCH_MX_NO_S(P_ID);
          LOOP
            FETCH C_PBATCH_MX_NO_S
              INTO PM;
            EXIT WHEN C_PBATCH_MX_NO_S%NOTFOUND OR C_PBATCH_MX_NO_S%NOTFOUND IS NULL;
          
            V_ISPRINTJE01 := 0;
          
            OPEN C_PBATCH_PLID_MX(PM.PID);
            LOOP
              FETCH C_PBATCH_PLID_MX
                INTO PL;
              EXIT WHEN C_PBATCH_PLID_MX%NOTFOUND OR C_PBATCH_PLID_MX%NOTFOUND IS NULL;
              V_ISPRINTJE01 := 0;
              I             := I + 1;
            
              V_ISPRINTJE := PL.PLJE + PL.PLZNJ + PL.PLSAVINGBQ;
            
              --����ˮ�ѽ��  (��ֵ˰�û�)
              SELECT SUM(CASE
                           WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                            RDJE
                           ELSE
                            0
                         END)
                INTO V_ISPRINTJE01
                FROM RECDETAIL  T,
                     PAIDLIST   T1,
                     PAIDDETAIL T2,
                     PAYMENT    T3,
                     METERINFO  T4
               WHERE PLID = PL.PLID
                 AND PLRLID = RDID
                 AND PLID = PDID
                 AND RDPIID = PDPIID
                 AND PID = PLPID
                 AND PMID = MIID;
            
              V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
            
              V_ISID := FGETINVNO_FROMTEMP(I);
              /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
              p_iltype --��Ʊ����
              );*/
              IF V_ISID IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
              END IF;
            
              IF V_ISPRINTJE01 <> 0 THEN
                V_ISZZS := 'Y';
              
              ELSE
              
                V_ISZZS := 'N';
              
              END IF;
            
              IF V_PLID IS NOT NULL AND V_PLID = PL.PLID THEN
                RECINVNO_EZ('3', --��ӡ��ʽ
                            V_ISID || '|', --Ʊ�ݺ���(###|###|)
                            PL.PLID || '|', --Ӧ����ˮ(###|###|)
                            '' || '|', --������Ŀ(###|###|)
                            V_ISPRINTJE + V_YCJE || '|', --Ʊ�ݽ��(###|###|)
                            P_ILTYPE, --Ʊ������
                            PL.PLCD, --�������
                            P_PRINTER, --��Ʊ��
                            P_ILSTATUS, --Ʊ��״̬
                            P_ILSMFID, --�ֹ�˾
                            PM.PTRANS,
                            V_ISZZS);
              
              ELSE
              
                RECINVNO_EZ('3', --��ӡ��ʽ
                            V_ISID || '|', --Ʊ�ݺ���(###|###|)
                            PL.PLID || '|', --Ӧ����ˮ(###|###|)
                            '' || '|', --������Ŀ(###|###|)
                            V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                            P_ILTYPE, --Ʊ������
                            PL.PLCD, --�������
                            P_PRINTER, --��Ʊ��
                            P_ILSTATUS, --Ʊ��״̬
                            P_ILSMFID, --�ֹ�˾
                            PM.PTRANS,
                            V_ISZZS);
              
              END IF;
            
            END LOOP;
            CLOSE C_PBATCH_PLID_MX;
          
          END LOOP;
          CLOSE C_PBATCH_MX_NO_S;
        
        END IF;
      
      ELSIF P_IFFPHP = 'Z' THEN
      
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM PAYMENT T
         WHERE PTRANS <> 'S'
           AND PBATCH = P_ID;
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        V_ISID      := FGETINVNO_FROMTEMP(1);
      
        --�����м�����
        SP_PRINTINV_OCX(P_ID, 'Z');
        V_ISID := FGETINVNO_FROMTEMP(1);
      
        OPEN C_PBATCH_PID_MX;
        LOOP
          FETCH C_PBATCH_PID_MX
            INTO PPT;
          EXIT WHEN C_PBATCH_PID_MX%NOTFOUND OR C_PBATCH_PID_MX%NOTFOUND IS NULL;
          I := I + 1;
          --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PPT.C1;
        
          V_ISPRINTJE := PPT.C10;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          SELECT PID, PCD, PTRANS
            INTO PM.PID, PM.PCD, PM.PTRANS
            FROM PAYMENT T
           WHERE T.PMID = PPT.C1
             AND T.PBATCH = PPT.C5
             AND T.PTRANS <> 'S';
        
          RECINVNO_EZ('2', --��ӡ��ʽ
                      V_ISID || '|', --Ʊ�ݺ���(###|###|)
                      PM.PID || '|', --Ӧ����ˮ(###|###|)
                      '' || '|', --������Ŀ(###|###|)
                      V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                      P_ILTYPE, --Ʊ������
                      PM.PCD, --�������
                      P_PRINTER, --��Ʊ��
                      P_ILSTATUS, --Ʊ��״̬
                      P_ILSMFID, --�ֹ�˾
                      PM.PTRANS,
                      V_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_PID_MX;
      
        --------------------------
      
      END IF;
    END IF;
    ----������ʵ����ˮ��ӡ payment.pid ֻ��Ԥ��
    IF P_ISPRINTTYPE = '2' THEN
      V_ISPRINTJE01 := 0;
      SELECT SUM((T.PPAYMENT - T.PCHANGE))
        INTO V_ISPRINTJE
        FROM PAYMENT T
       WHERE PID = P_ID;
    
      V_ISID := FGETINVNO(P_PRINTER, --����Ա
                          P_ILTYPE, --��Ʊ����
                          P_SNO);
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      
      ELSE
      
        V_ISZZS := 'N';
      
      END IF;
    
      RECINVNO_EZ(P_ISPRINTTYPE, --��ӡ��ʽ
                  V_ISID || '|', --Ʊ�ݺ���(###|###|)
                  P_ID || '|', --Ӧ����ˮ(###|###|)
                  '' || '|', --������Ŀ(###|###|)
                  V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                  P_ILTYPE, --Ʊ������
                  P_ISPRINTCD, --�������
                  P_PRINTER, --��Ʊ��
                  P_ILSTATUS, --Ʊ��״̬
                  P_ILSMFID, --�ֹ�˾
                  'S',
                  V_ISZZS);
    
    END IF;
    ----������ʵ����ϸ��ˮ��ӡ paidlist.plid --��PLID��ӡ��ϸƱ
    IF P_ISPRINTTYPE = '3' THEN
      OPEN C_PBATCH_PLID_MX_ONE(P_ID);
      LOOP
        FETCH C_PBATCH_PLID_MX_ONE
          INTO PL;
        EXIT WHEN C_PBATCH_PLID_MX_ONE%NOTFOUND OR C_PBATCH_PLID_MX_ONE%NOTFOUND IS NULL;
      
        V_ISPRINTJE01 := 0;
      
        SELECT PTRANS
          INTO PM.PTRANS
          FROM PAYMENT, PAIDLIST
         WHERE PID = PLPID
           AND PLID = PL.PLID;
        V_ISPRINTJE := PL.PLJE + PL.PLZNJ + PL.PLSAVINGBQ;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL  T,
               PAIDLIST   T1,
               PAIDDETAIL T2,
               PAYMENT    T3,
               METERINFO  T4
         WHERE PLID = PL.PLID
           AND PLRLID = RDID
           AND PLID = PDID
           AND RDPIID = PDPIID
           AND PID = PLPID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��Ʊ����
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO_EZ('3', --��ӡ��ʽ
                    V_ISID || '|', --Ʊ�ݺ���(###|###|)
                    PL.PLID || '|', --Ӧ����ˮ(###|###|)
                    '' || '|', --������Ŀ(###|###|)
                    V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                    P_ILTYPE, --Ʊ������
                    PL.PLCD, --�������
                    P_PRINTER, --��Ʊ��
                    P_ILSTATUS, --Ʊ��״̬
                    P_ILSMFID, --�ֹ�˾
                    PM.PTRANS,
                    V_ISZZS);
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    END IF;
  
    --5:Ӧ����ˮrlid  �ṹ ###,###|###,###|###,###|
    --6:ʵ����ϸ rdid+rdpiid  �ṹ ###,01/02/03|###,01/02/03|###,01/02/03|
    IF P_ISPRINTTYPE = '5' THEN
      --v_invcount    number(10);
      --v_invretcount number(10);
      --���
      --��ӡԱ��Ʊ��
    
      --��Ʊ/��Ʊ
      IF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*) INTO V_INVCOUNT FROM PBPARMTEMP;
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '###û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
      
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVCOUNT > V_INVRETCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        END IF;
      
        I := 0;
        OPEN C_RLID_PBPARMTEMP;
        LOOP
          FETCH C_RLID_PBPARMTEMP
            INTO PPT;
          EXIT WHEN C_RLID_PBPARMTEMP%NOTFOUND OR C_RLID_PBPARMTEMP%NOTFOUND IS NULL;
        
          V_ISPRINTJE01 := 0;
        
          V_ISPRINTJE01 := 0;
          I             := I + 1;
        
          V_ISPRINTJE := TO_NUMBER(PPT.C6);
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, METERINFO T4
           WHERE RLID = RDID
             AND MIID = RLMID
             AND RLID = TRIM(PPT.C5);
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
          /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          
          ELSE
          
            V_ISZZS := 'N';
          
          END IF;
        
          RECINVNO_EZ('5', --��ӡ��ʽ
                      V_ISID || '|', --Ʊ�ݺ���(###|###|)
                      TRIM(PPT.C5) || '|', --Ӧ����ˮ(###|###|)
                      TRIM(PPT.C8) || '|', --������Ŀ(###|###|)
                      V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                      P_ILTYPE, --Ʊ������
                      P_ISPRINTCD, --�������
                      P_PRINTER, --��Ʊ��
                      P_ILSTATUS, --Ʊ��״̬
                      P_ILSMFID, --�ֹ�˾
                      'T',
                      V_ISZZS);
        
        END LOOP;
        CLOSE C_RLID_PBPARMTEMP;
      
      ELSIF P_IFFPHP = 'H' THEN
        SELECT SUM(TO_NUMBER(C7)),
               CONNSTR(C5),
               CONNSTR(C5 || ',' || REPLACE(C8, '/', '#'))
          INTO V_ISPRINTJE, V_RLIDSTR, V_RDPIIDSTR
          FROM PBPARMTEMP;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        BEGIN
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, METERINFO T4, PBPARMTEMP T5
           WHERE RLID = RDID
             AND RLMID = MIID
             AND RLID = TRIM(T5.C5);
        EXCEPTION
          WHEN OTHERS THEN
            V_ISPRINTJE01 := 0;
        END;
        -- raise_application_error(errcode, v_isprintje01 );
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
      
        RECINVNO_EZ(P_ISPRINTTYPE, --��ӡ��ʽ
                    V_ISID || '|', --Ʊ�ݺ���(###|###|)
                    V_RLIDSTR || '|', --Ӧ����ˮ(###|###|)
                    V_RDPIIDSTR || '|', --������Ŀ(###|###|)
                    V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                    P_ILTYPE, --Ʊ������
                    P_ISPRINTCD, --�������
                    P_PRINTER, --��Ʊ��
                    P_ILSTATUS, --Ʊ��״̬
                    P_ILSMFID, --�ֹ�˾
                    'T',
                    V_ISZZS);
      END IF;
    
    END IF;
  
    IF P_ISPRINTTYPE = '6' THEN
      OPEN C_PBATCH_PLID_MX_ONE(P_ID);
      LOOP
        FETCH C_PBATCH_PLID_MX_ONE
          INTO PL;
        EXIT WHEN C_PBATCH_PLID_MX_ONE%NOTFOUND OR C_PBATCH_PLID_MX_ONE%NOTFOUND IS NULL;
      
        V_ISPRINTJE01 := 0;
      
        SELECT PTRANS
          INTO PM.PTRANS
          FROM PAYMENT, PAIDLIST
         WHERE PID = PLPID
           AND PLID = PL.PLID;
        V_ISPRINTJE := PL.PLJE + PL.PLZNJ + PL.PLSAVINGBQ;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL  T,
               PAIDLIST   T1,
               PAIDDETAIL T2,
               PAYMENT    T3,
               METERINFO  T4
         WHERE PLID = PL.PLID
           AND PLRLID = RDID
           AND PLID = PDID
           AND RDPIID = PDPIID
           AND PID = PLPID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO_EZ('3', --��ӡ��ʽ
                    V_ISID || '|', --Ʊ�ݺ���(###|###|)
                    PL.PLID || '|', --Ӧ����ˮ(###|###|)
                    '' || '|', --������Ŀ(###|###|)
                    V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                    P_ILTYPE, --Ʊ������
                    PL.PLCD, --�������
                    P_PRINTER, --��Ʊ��
                    P_ILSTATUS, --Ʊ��״̬
                    P_ILSMFID, --�ֹ�˾
                    PM.PTRANS,
                    V_ISZZS);
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PBATCH_MX%ISOPEN THEN
        CLOSE C_PBATCH_MX;
      END IF;
      IF C_PBATCH_PLID_MX%ISOPEN THEN
        CLOSE C_PBATCH_PLID_MX;
      END IF;
      IF C_PBATCH_PLID_MX_ONE%ISOPEN THEN
        CLOSE C_PBATCH_PLID_MX_ONE;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  /*--����20110817
   procedure sp_fchargeinvreg(P_iffphp      in varchar2, --F��ƱH��Ʊ
                               p_id          in varchar2, --ʵ������
                               p_piid        in varchar2, --������Ŀ 01/02/03
                               p_ISPRINTTYPE in varchar2, --��ӡ��ʽ
                               p_iltype      in varchar2, --Ʊ������
                               P_PRINTER     IN VARCHAR2, --��ӡԱ
                               p_ilstatus    in VARCHAR2, --Ʊ��״̬
                               p_ilsmfid     IN VARCHAR2, --�ֹ�˾
                               p_ISPRINTCD   IN VARCHAR2 --�����
                               )
  
     is
      i             number(10);
      v_invcount    number(10);
      v_invretcount number(10);
      V_COUNT1      number(10);
      V_COUNT2      number(10);
      V_TRNAS       VARCHAR(10);
      v_isprintje01 number(13, 3);
      v_isid        invstock.isid%type;
      v_isprintje   invstock.isprintje %type;
      V_ISPRINTTYPE invstock.ISPRINTTYPE %type;
      PM            PAYMENT%ROWTYPE;
      Pl            paidlist%ROWTYPE;
      ppt           PBPARMTEMP%ROWTYPE;
      v_rlidstr varchar2(4000);
      v_rdpiidstr varchar2(4000);
    v_ISZZS VARCHAR(10);
      CURSOR C_PBATCH_MX(AS_PBARCH VARCHAR2) IS
        SELECT * FROM PAYMENT WHERE PBATCH = AS_PBARCH ORDER BY PID;
      CURSOR C_PBATCH_plid_MX(as_pid VARCHAR2) IS
        SELECT t.*
          FROM paidlist t, payment t1
         WHERE pid = plpid
           and pid = as_pid
         ORDER BY PID || plid;
      CURSOR C_PBATCH_plid_MX_one(as_pid VARCHAR2) IS
        SELECT t.* FROM paidlist t WHERE plid = as_pid;
      CURSOR C_rlid_PBPARMTEMP  IS
        SELECT t.* FROM PBPARMTEMP t ;
        CURSOR C_PBATCH_pid_MX  IS
        SELECT t.*
          FROM PBPARMNNOCOMMIT_PRINT T;
  
    begin
    v_isprintje01 :=0 ;
      --���������δ�ӡ payment.pbatch
      if p_ISPRINTTYPE = '1' then
        if P_iffphp = 'H' THEN
          SELECT SUM((T.PPAYMENT - T.PCHANGE)),
                 COUNT(*),
                 SUM(CASE
                       WHEN PTRANS = 'S' THEN
                        1
                       ELSE
                        0
                     END)
            INTO v_isprintje, V_COUNT1, V_COUNT2
            FROM PAYMENT T
           WHERE PBATCH = p_id;
          --����ˮ�ѽ��  (��ֵ˰�û�)
          select sum(CASE
                       WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                        rdje
                       ELSE
                        0
                     END)
            into v_isprintje01
            from recdetail  t,
                 paidlist   t1,
                 paiddetail t2,
                 PAYMENT    T3,
                 meterinfo  t4
           where PBATCH = p_id
             AND PID = PLPID
             and plrlid = rdid
             and plid = pdid
             and rdpiid = pdpiid
             and pmid = miid;
  
          v_isprintje := v_isprintje - v_isprintje01;
  
          IF V_COUNT1 < 1 THEN
            raise_application_error(errcode, 'û����Ҫ��ӡ�ķ�Ʊ');
          ELSE
            IF V_COUNT1 > V_COUNT2 THEN
              SELECT PTRANS
                INTO V_TRNAS
                FROM PAYMENT T
               WHERE PBATCH = p_id
                 AND PTRANS <> 'S'
                 AND ROWNUM = 1;
            ELSE
              V_TRNAS := 'S';
            END IF;
          END IF;
          v_isid := fgetinvno(P_PRINTER, --����Ա
                              p_iltype --��Ʊ����
                              );
          IF v_isid is null THEN
            raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
          if v_isprintje01<>0 THEN
             v_ISZZS :='Y' ;
          ELSE
             v_ISZZS :='N' ;
          END IF;
          recinvno_ez(p_ISPRINTTYPE, --��ӡ��ʽ
                      v_isid || '|', --Ʊ�ݺ���(###|###|)
                      p_id || '|', --Ӧ����ˮ(###|###|)
                      '' || '|', --������Ŀ(###|###|)
                      v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                      p_iltype, --Ʊ������
                      p_ISPRINTCD, --�������
                      P_PRINTER, --��Ʊ��
                      p_ilstatus, --Ʊ��״̬
                      p_ilsmfid, --�ֹ�˾
                      V_TRNAS,
                      v_ISZZS);
  
        ELSIF P_iffphp = 'F' THEN
  
          select count(*)
            into v_invcount
            from payment t, paidlist t1
           where pbatch = p_id
             and pid = plpid(+);
  
          v_invretcount := fgetinvno_temp(P_PRINTER, --����Ա
                                          p_iltype, --��Ʊ����
                                          v_invcount --Ҫȡ��Ʊ����
                                          );
          if v_invcount = 0 then
            raise_application_error(errcode, 'û����Ҫ��ӡ�ķ�Ʊ');
  
          end if;
          if v_invretcount < v_invcount then
            raise_application_error(errcode,
                                    '��Ʊ���ݲ���,��Ҫ��ӡ' || v_invcount || '�ţ�ʵ��ֻ��' ||
                                    v_invretcount || '��');
  
          end if;
          i := 0;
          OPEN C_PBATCH_MX(p_id);
          LOOP
            FETCH C_PBATCH_MX
              INTO PM;
            EXIT WHen C_PBATCH_MX%NOTFOUND OR C_PBATCH_MX%NOTFOUND IS NULL;
  
            v_isprintje01 :=0 ;
  
            IF PM.PTRANS = 'S' THEN
              i      := i + 1;
              v_isid := fgetinvno_fromtemp(i);
              \* v_ilno      := fgetinvno(P_PRINTER, --����Ա
              p_iltype --��Ʊ����
              );*\
              IF v_isid is null THEN
                raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
              END IF;
  
              v_isprintje := PM.PPAYMENT - PM.PCHANGE;
  
              if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
                 v_ISZZS :='N' ;
              END IF;
  
              recinvno_ez('2', --��ӡ��ʽ
                          v_isid || '|', --Ʊ�ݺ���(###|###|)
                          PM.PID || '|', --Ӧ����ˮ(###|###|)
                          '' || '|', --������Ŀ(###|###|)
                          v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                          p_iltype, --Ʊ������
                          PM.Pcd, --�������
                          P_PRINTER, --��Ʊ��
                          p_ilstatus, --Ʊ��״̬
                          p_ilsmfid, --�ֹ�˾
                          pm.ptrans,
                          v_ISZZS);
            ELSE
  
              OPEN C_PBATCH_plid_MX(pm.pid);
              LOOP
                FETCH C_PBATCH_plid_MX
                  INTO Pl;
                EXIT WHen C_PBATCH_plid_MX%NOTFOUND OR C_PBATCH_plid_MX%NOTFOUND IS NULL;
                v_isprintje01 :=0 ;
                i := i + 1;
  
                v_isprintje := Pl.plje + Pl.Plznj + pl.plsavingbq;
  
                --����ˮ�ѽ��  (��ֵ˰�û�)
                select sum(CASE
                             WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                              rdje
                             ELSE
                              0
                           END)
                  into v_isprintje01
                  from recdetail  t,
                       paidlist   t1,
                       paiddetail t2,
                       payment    t3,
                       meterinfo  t4
                 where plid = pl.plid
                   and plrlid = rdid
                   and plid = pdid
                   and rdpiid = pdpiid
                   and pid = plpid
                   and pmid = miid;
  
                v_isprintje := v_isprintje - v_isprintje01;
  
                v_isid := fgetinvno_fromtemp(i);
                \*v_ilno      := fgetinvno(P_PRINTER, --����Ա
                p_iltype --��Ʊ����
                );*\
                IF v_isid is null THEN
                  raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
                END IF;
  
                if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
  
                recinvno_ez('3', --��ӡ��ʽ
                            v_isid || '|', --Ʊ�ݺ���(###|###|)
                            pl.plid || '|', --Ӧ����ˮ(###|###|)
                            '' || '|', --������Ŀ(###|###|)
                            v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                            p_iltype, --Ʊ������
                            pl.plcd, --�������
                            P_PRINTER, --��Ʊ��
                            p_ilstatus, --Ʊ��״̬
                            p_ilsmfid, --�ֹ�˾
                            pm.ptrans,
                            v_ISZZS);
              END LOOP;
              CLOSE C_PBATCH_plid_MX;
            END IF;
          END LOOP;
          CLOSE C_PBATCH_MX;
  
      ELSIF P_iffphp = 'Z' THEN
  
          select count(*)
            into v_invcount
            from payment t
           where  PTRANS<>'S'   AND  pbatch = p_id
              ;
  
          v_invretcount := fgetinvno_temp(P_PRINTER, --����Ա
                                          p_iltype, --��Ʊ����
                                          v_invcount --Ҫȡ��Ʊ����
                                          );
          if v_invcount = 0 then
            raise_application_error(errcode, 'û����Ҫ��ӡ�ķ�Ʊ');
  
          end if;
          if v_invretcount < v_invcount then
            raise_application_error(errcode,
                                    '��Ʊ���ݲ���,��Ҫ��ӡ' || v_invcount || '�ţ�ʵ��ֻ��' ||
                                    v_invretcount || '��');
  
          end if;
          i := 0;
          v_isprintje :=0 ;
          v_isid := fgetinvno_fromtemp(1);
  
  --�����м�����
  SP_PRINTINV_OCX(p_id,'Z' );
  v_isid := fgetinvno_fromtemp(1);
  
              OPEN C_PBATCH_pid_MX ;
              LOOP
                FETCH C_PBATCH_pid_MX
                  INTO PPT;
                EXIT WHen C_PBATCH_pid_MX%NOTFOUND OR C_PBATCH_pid_MX%NOTFOUND IS NULL;
                i := i + 1;
                --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
                select MIIFTAX
                  into v_ISZZS
                  from
                       meterinfo  t4
                 where miid = ppt.c1 ;
  
                v_isprintje := ppt.c10 ;
  
                v_isid := fgetinvno_fromtemp(i);
  
                IF v_isid is null THEN
                  raise_application_error(errcode,'��' ||I||'��Ʊ�����꣬����ȡ��Ʊ');
                END IF;
  
          select pid ,pcd,PTRANS  INTO PM.PID,PM.PCD,PM.PTRANS
           from payment t
          where t.pmid=ppt.c1
          and t.pbatch=PPT.C5 and t.ptrans<>'S' ;
  
  
                recinvno_ez('2', --��ӡ��ʽ
                            v_isid || '|', --Ʊ�ݺ���(###|###|)
                             PM.PID|| '|', --Ӧ����ˮ(###|###|)
                            '' || '|', --������Ŀ(###|###|)
                            v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                            p_iltype, --Ʊ������
                            PM.PCD, --�������
                            P_PRINTER, --��Ʊ��
                            p_ilstatus, --Ʊ��״̬
                            p_ilsmfid, --�ֹ�˾
                            pm.ptrans,
                            v_ISZZS);
              END LOOP;
              CLOSE C_PBATCH_pid_MX;
  
            --------------------------
  
  
        END IF;
      end if;
      ----������ʵ����ˮ��ӡ payment.pid ֻ��Ԥ��
      if p_ISPRINTTYPE = '2' then
        v_isprintje01  := 0 ;
        SELECT SUM((T.PPAYMENT - T.PCHANGE))
          INTO v_isprintje
          FROM PAYMENT T
         WHERE pid = p_id;
  
  
        v_isid := fgetinvno(P_PRINTER, --����Ա
                            p_iltype --��Ʊ����
                            );
        IF v_isid is null THEN
          raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
  
        if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
        recinvno_ez(p_ISPRINTTYPE, --��ӡ��ʽ
                    v_isid || '|', --Ʊ�ݺ���(###|###|)
                    p_id || '|', --Ӧ����ˮ(###|###|)
                    '' || '|', --������Ŀ(###|###|)
                    v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                    p_iltype, --Ʊ������
                    p_ISPRINTCD, --�������
                    P_PRINTER, --��Ʊ��
                    p_ilstatus, --Ʊ��״̬
                    p_ilsmfid, --�ֹ�˾
                    'S',
                    v_ISZZS);
  
      end if;
      ----������ʵ����ϸ��ˮ��ӡ paidlist.plid --��PLID��ӡ��ϸƱ
      if p_ISPRINTTYPE = '3' then
        OPEN C_PBATCH_plid_MX_one(p_id);
        LOOP
          FETCH C_PBATCH_plid_MX_one
            INTO Pl;
          EXIT WHen C_PBATCH_plid_MX_one%NOTFOUND OR C_PBATCH_plid_MX_one%NOTFOUND IS NULL;
  
          v_isprintje01 :=0  ;
  
          select ptrans
            into pm.ptrans
            from payment, paidlist
           where pid = plpid
             and plid = pl.plid;
          v_isprintje := Pl.plje + Pl.Plznj + pl.plsavingbq;
  
          --����ˮ�ѽ��  (��ֵ˰�û�)
                select sum(CASE
                             WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                              rdje
                             ELSE
                              0
                           END)
                  into v_isprintje01
                  from recdetail  t,
                       paidlist   t1,
                       paiddetail t2,
                       payment    t3,
                       meterinfo  t4
                 where plid = pl.plid
                   and plrlid = rdid
                   and plid = pdid
                   and rdpiid = pdpiid
                   and pid = plpid
                   and pmid = miid;
  
                v_isprintje := v_isprintje - v_isprintje01;
  
  
          v_isid      := fgetinvno(P_PRINTER, --����Ա
                                   p_iltype --��Ʊ����
                                   );
          IF v_isid is null THEN
            raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
  
           if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
          recinvno_ez('3', --��ӡ��ʽ
                      v_isid || '|', --Ʊ�ݺ���(###|###|)
                      pl.plid || '|', --Ӧ����ˮ(###|###|)
                      '' || '|', --������Ŀ(###|###|)
                      v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                      p_iltype, --Ʊ������
                      pl.plcd, --�������
                      P_PRINTER, --��Ʊ��
                      p_ilstatus, --Ʊ��״̬
                      p_ilsmfid, --�ֹ�˾
                      pm.ptrans,
                      v_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_plid_MX_one;
      end if;
  
      --5:Ӧ����ˮrlid  �ṹ ###,###|###,###|###,###|
      --6:ʵ����ϸ rdid+rdpiid  �ṹ ###,01/02/03|###,01/02/03|###,01/02/03|
      if p_ISPRINTTYPE = '5' then
      --v_invcount    number(10);
      --v_invretcount number(10);
      --���
      --��ӡԱ��Ʊ��
  
      --��Ʊ/��Ʊ
       if P_iffphp = 'F' THEN
  
     select count(*) into v_invcount  from pbparmtemp;
     if v_invcount = 0 then
            raise_application_error(errcode, '###û����Ҫ��ӡ�ķ�Ʊ');
  
          end if;
    v_invretcount := fgetinvno_temp(P_PRINTER, --����Ա
                                          p_iltype, --��Ʊ����
                                          v_invcount --Ҫȡ��Ʊ����
                                          );
  
          if v_invcount = 0 then
            raise_application_error(errcode, 'û����Ҫ��ӡ�ķ�Ʊ');
  
          end if;
     if v_invcount > v_invretcount  then
        raise_application_error(errcode,
                                    '��Ʊ���ݲ���,��Ҫ��ӡ' || v_invcount || '�ţ�ʵ��ֻ��' ||
                                    v_invretcount || '��');
     END IF;
  
  
  
  
  
  
          i := 0;
          OPEN C_rlid_PBPARMTEMP;
          LOOP
            FETCH C_rlid_PBPARMTEMP
              INTO ppt;
            EXIT WHen C_rlid_PBPARMTEMP%NOTFOUND OR C_rlid_PBPARMTEMP%NOTFOUND IS NULL;
  
            v_isprintje01 :=0 ;
  
  
  
  
                v_isprintje01 :=0 ;
                i := i + 1;
  
                v_isprintje := to_number(ppt.c6 ) ;
  
                --����ˮ�ѽ��  (��ֵ˰�û�)
                select sum(CASE
                             WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                              rdje
                             ELSE
                              0
                           END)
                  into v_isprintje01
                  from recdetail  t,
                       RECLIST T1,
                       meterinfo  t4
                 where RLID=RDID
                 AND MIID=RLMID
                 and rlid=trim(ppt.c5 ) ;
  
                v_isprintje := v_isprintje - v_isprintje01;
  
                v_isid := fgetinvno_fromtemp(i);
                \*v_ilno      := fgetinvno(P_PRINTER, --����Ա
                p_iltype --��Ʊ����
                );*\
                IF v_isid is null THEN
                  raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
                END IF;
  
             if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
  
                recinvno_ez('5', --��ӡ��ʽ
                            v_isid || '|', --Ʊ�ݺ���(###|###|)
                            trim(ppt.c5)  || '|', --Ӧ����ˮ(###|###|)
                            trim(ppt.c8) || '|', --������Ŀ(###|###|)
                            v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                            p_iltype, --Ʊ������
                            p_ISPRINTCD, --�������
                            P_PRINTER, --��Ʊ��
                            p_ilstatus, --Ʊ��״̬
                            p_ilsmfid, --�ֹ�˾
                            'T',
                            v_ISZZS);
  
  
          END LOOP;
          CLOSE C_rlid_PBPARMTEMP;
  
  
  
        ELSIF P_iffphp = 'H' THEN
         SELECT SUM(to_number( c7) ),connstr( c5 ),connstr( c5||','|| REPLACE( c8,'/','#'))
            INTO v_isprintje ,v_rlidstr,v_rdpiidstr
            FROM PBPARMTEMP;
  
          --����ˮ�ѽ��  (��ֵ˰�û�)
          begin
          select sum(CASE
                       WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                        rdje
                       ELSE
                        0
                     END)
            into v_isprintje01
            from recdetail  t,
               reclist t1,
                 meterinfo  t4,
                 pbparmtemp t5
           where rlid=rdid
           and rlmid=miid
           and rlid=trim(t5.c5);
          exception when others then
          v_isprintje01 :=0;
          end ;
       -- raise_application_error(errcode, v_isprintje01 );
          v_isprintje := v_isprintje - v_isprintje01;
  
          IF V_COUNT1 < 1 THEN
            raise_application_error(errcode, 'û����Ҫ��ӡ�ķ�Ʊ');
  
          END IF;
          v_isid := fgetinvno(P_PRINTER, --����Ա
                              p_iltype --��Ʊ����
                              );
          IF v_isid is null THEN
            raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
          if v_isprintje01<>0 THEN
             v_ISZZS :='Y' ;
          ELSE
             v_ISZZS :='N' ;
          END IF;
  
  
  
          recinvno_ez(p_ISPRINTTYPE, --��ӡ��ʽ
                      v_isid || '|', --Ʊ�ݺ���(###|###|)
                      v_rlidstr || '|', --Ӧ����ˮ(###|###|)
                      v_rdpiidstr || '|', --������Ŀ(###|###|)
                      v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                      p_iltype, --Ʊ������
                      p_ISPRINTCD, --�������
                      P_PRINTER, --��Ʊ��
                      p_ilstatus, --Ʊ��״̬
                      p_ilsmfid, --�ֹ�˾
                      'T',
                      v_ISZZS);
        END IF;
  
  
      end if;
  
  
  
  
      if p_ISPRINTTYPE = '6' then
        OPEN C_PBATCH_plid_MX_one(p_id);
        LOOP
          FETCH C_PBATCH_plid_MX_one
            INTO Pl;
          EXIT WHen C_PBATCH_plid_MX_one%NOTFOUND OR C_PBATCH_plid_MX_one%NOTFOUND IS NULL;
  
          v_isprintje01 :=0  ;
  
          select ptrans
            into pm.ptrans
            from payment, paidlist
           where pid = plpid
             and plid = pl.plid;
          v_isprintje := Pl.plje + Pl.Plznj + pl.plsavingbq;
  
          --����ˮ�ѽ��  (��ֵ˰�û�)
                select sum(CASE
                             WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                              rdje
                             ELSE
                              0
                           END)
                  into v_isprintje01
                  from recdetail  t,
                       paidlist   t1,
                       paiddetail t2,
                       payment    t3,
                       meterinfo  t4
                 where plid = pl.plid
                   and plrlid = rdid
                   and plid = pdid
                   and rdpiid = pdpiid
                   and pid = plpid
                   and pmid = miid;
  
                v_isprintje := v_isprintje - v_isprintje01;
  
  
          v_isid      := fgetinvno(P_PRINTER, --����Ա
                                   p_iltype --��Ʊ����
                                   );
          IF v_isid is null THEN
            raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
  
           if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
          recinvno_ez('3', --��ӡ��ʽ
                      v_isid || '|', --Ʊ�ݺ���(###|###|)
                      pl.plid || '|', --Ӧ����ˮ(###|###|)
                      '' || '|', --������Ŀ(###|###|)
                      v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                      p_iltype, --Ʊ������
                      pl.plcd, --�������
                      P_PRINTER, --��Ʊ��
                      p_ilstatus, --Ʊ��״̬
                      p_ilsmfid, --�ֹ�˾
                      pm.ptrans,
                      v_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_plid_MX_one;
      end if;
  
  
  
    exception
      when others then
        if C_PBATCH_MX%isopen then
          close C_PBATCH_MX;
        end if;
        if C_PBATCH_plid_MX%isopen then
          close C_PBATCH_plid_MX;
        end if;
        if C_PBATCH_plid_MX_one%isopen then
          close C_PBATCH_plid_MX_one;
        end if;
  
        rollback;
        raise_application_error(errcode, sqlerrm);
  
    end;
  */
  --��������ˮ
  --��鷢Ʊ�Ƿ񹻴�
  FUNCTION FCHKINVFULL(P_PER    IN VARCHAR2, --����Ա
                       P_IITYPE IN VARCHAR2, --��Ʊ����
                       P_TYPE   IN VARCHAR2, --��ˮ�����
                       P_ID     IN VARCHAR2 --��ˮ��
                       ) RETURN NUMBER --�����Ƿ�Ʊ����
   AS
    V_INVCOUNT     NUMBER(10);
    V_INVHAVECOUNT NUMBER(10);
  BEGIN
    IF P_TYPE = '1' THEN
      SELECT COUNT(*)
        INTO V_INVCOUNT
        FROM PAYMENT T, PAIDLIST T1
       WHERE PBATCH = P_ID
         AND PID = PLPID;
    END IF;
    IF P_TYPE = '2' THEN
      SELECT COUNT(DISTINCT PMID)
        INTO V_INVCOUNT
        FROM PAYMENT T, PAIDLIST T1
       WHERE PBATCH = P_ID
         AND PID = PLPID;
    END IF;
    V_INVHAVECOUNT := FGETINVCOUNT(P_PER, --����Ա
                                   P_IITYPE --��Ʊ����
                                   );
    IF V_INVHAVECOUNT - V_INVCOUNT >= 0 THEN
      RETURN 0;
    ELSE
      RETURN V_INVCOUNT - V_INVHAVECOUNT;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN - 1;
  END;

  /*
  --����20110817
    function fchkinvfull(p_per    in varchar2, --����Ա
                         p_iitype in varchar2, --��Ʊ����
                         p_type   in varchar2, --��ˮ�����
                         p_id     in varchar2 --��ˮ��
                         ) return number --�����Ƿ�Ʊ����
     as
      v_invcount     number(10);
      v_invhavecount number(10);
    begin
      if p_type = '1' then
        select count(*)
          into v_invcount
          from payment t, paidlist t1
         where pbatch = p_id
           and pid = plpid(+);
      end if;
      if p_type = '2' then
        select count(DISTINCT PMID )
          into v_invcount
          from payment t, paidlist t1
         where pbatch = p_id
           and pid = plpid ;
      end if;
      v_invhavecount := fgetinvcount(p_per, --����Ա
                                     p_iitype --��Ʊ����
                                     );
      if v_invhavecount - v_invcount >= 0 then
        return 0;
      else
        return v_invcount - v_invhavecount;
      end if;
  
    exception
      when others then
        rollback;
        return - 1;
    end;
  
  */
  --��Ʊ״̬����
  PROCEDURE SP_CANCEL_HADPRINTNO(P_PER    IN VARCHAR2, --����Ա
                                 P_TYPE   IN VARCHAR2, --��Ʊ���
                                 P_STATUS IN VARCHAR2, --����״̬
                                 P_ID     IN VARCHAR2, --��ˮ��
                                 P_MODE   IN VARCHAR2, --��ˮ�����
                                 O_FLAG   OUT VARCHAR2 --����ֵ
                                 ) AS
    V_COUNT NUMBER(10);
    IT      INVSTOCK%ROWTYPE;
  BEGIN
    IF P_MODE = '1' THEN
      /*select count(*) into v_count from invstock t where t.isprinttype='1'
      and isprintid= p_id ;*/
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISPRINTTYPE = '1'
           AND ISSTATUS = '1'
           AND T.ISPCISNO = P_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISPRINTTYPE = '2'
           AND ISSTATUS = '1'
           AND T.ISPCISNO IN (SELECT PID FROM PAYMENT WHERE PBATCH = P_ID);
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISPRINTTYPE = '3'
           AND ISSTATUS = '1'
           AND T.ISPCISNO IN (SELECT PLID
                                FROM PAYMENT, PAIDLIST
                               WHERE PLPID = PID
                                 AND PBATCH = P_ID);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSIF P_MODE = '3' THEN
      --PLID
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISPRINTTYPE = '3'
           AND ISSTATUS = '1'
           AND T.ISPCISNO = P_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSIF P_MODE = '5' THEN
      --rlid + rdpiid
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISPRINTTYPE = '5'
           AND ISSTATUS = '1'
           AND T.ISPCISNO = P_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��֧�ִ��ִ���ʽ,�����룺' || P_MODE);
      O_FLAG := 'N';
    END IF;
    O_FLAG := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_FLAG := 'N';
      --raise_application_error(errcode, sqlerrm);
  END;
  FUNCTION FGETINVDWDETAILSTR(P_ID IN NUMBER) RETURN VARCHAR2 AS
    VRET VARCHAR2(1000);
  BEGIN
    SELECT ' datawindow.detail.height = ''' ||
           TRIM(TO_CHAR((MAX(PTDY + PTDHEIGHT) + 5))) || ''' '
      INTO VRET
      FROM PRINTTEMPLATEDT T
     WHERE PTDID = P_ID
       AND T.PTDX > 0
       AND T.PTDY > 0
       AND T.PTDHEIGHT > 0
       AND T.PTDWIDTH > 0;
    RETURN VRET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --ɾ����Ʊ
  PROCEDURE SP_INVMANG_DELETE(P_ISNOSTART   VARCHAR2, --��Ʊ���
                              P_ISNOEND     VARCHAR2, --��Ʊֹ��
                              P_ISBCNO      VARCHAR2, --��Ʊ����
                              P_ISSTATUSPER VARCHAR2, --״̬�����
                              P_MEMO        VARCHAR2, --��ע
                              MSG           OUT VARCHAR2) IS
    /*Ʊ�ݹ���ɾ��Ʊ��*/
    V_MSG   VARCHAR2(200);
    V_COUNT NUMBER;
  BEGIN
  
    V_MSG := 'N';
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
  
    --�޸ķ�Ʊ����ʱ�䣬�����ˣ�����Ʊ���״̬��
    IF P_ISNOSTART IS NOT NULL OR P_ISNOEND IS NOT NULL THEN
      SP_INVMANG_MODIFYSTATUS(P_ISNOSTART,
                              P_ISNOEND,
                              P_ISBCNO,
                              P_ISSTATUSPER,
                              4,
                              P_MEMO,
                              V_MSG);
    END IF;
  
    --������״̬������Y���򷵻�ɾ�����ɹ���Ϣ
    IF V_MSG <> 'Y' THEN
      MSG := V_MSG;
      RETURN;
    END IF;
  
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '��Ʊɾ��ʧ��!';
      RETURN;
    ELSIF P_ISNOEND IS NULL THEN
      /*��Ʊֹ��Ϊ�գ�����Ʊ��Ų�Ϊ��*/
      --��ӵ��������ݿ�
      INSERT INTO INVSTOCKHIS
        SELECT *
          FROM INVSTOCK
         WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
           AND ISBCNO = P_ISBCNO;
      --ɾ����ǰƱ����Ϣ
      DELETE FROM INVSTOCK
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISBCNO = P_ISBCNO;
      --�Ƿ�ɹ�
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
        RETURN;
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
    ELSIF P_ISNOSTART IS NULL THEN
      /*��Ʊ���Ϊ�գ�����Ʊֹ�Ų�Ϊ��*/
      INSERT INTO INVSTOCKHIS
        SELECT *
          FROM INVSTOCK
         WHERE ISNO = TRIM(TO_CHAR(P_ISNOEND, '00000000'))
           AND ISBCNO = P_ISBCNO;
      DELETE FROM INVSTOCK
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         AND ISBCNO = P_ISBCNO;
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
        RETURN;
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
    ELSE
    
      FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
        INSERT INTO INVSTOCKHIS
          SELECT *
            FROM INVSTOCK
           WHERE ISNO = TRIM(TO_CHAR(I, '00000000'))
             AND ISBCNO = P_ISBCNO;
        DELETE FROM INVSTOCK
         WHERE ISNO = TRIM(TO_CHAR(I, '00000000'))
           AND ISBCNO = P_ISBCNO;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      END LOOP;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      MSG := 'N';
  END;
  --�޸ķ�Ʊ״̬
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_ISNOSTART   VARCHAR2, --��Ʊ���
                                    P_ISNOEND     VARCHAR2, --��Ʊֹ��
                                    P_ISBCNO      VARCHAR2, --���κ�
                                    P_ISSTATUSPER VARCHAR2, --״̬�����Ա
                                    P_STATUS      NUMBER, --״̬2
                                    P_MEMO        VARCHAR2, --��ע
                                    MSG           OUT VARCHAR2) IS
    /*��Ʊ������Ʊ����2����Ʊ��ʼ��0����ʹ��1������3��ɾ��4*/
    V_ISSTATUS     VARCHAR2(12);
    V_ISSTATUSDATE DATE;
    V_ISSTATUSPER  VARCHAR2(12);
    V_COUNT        NUMBER;
    V_ISTRUE1      NUMBER;
    V_ISTRUE2      NUMBER;
    nsql           number;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISSTATUSPER IS NULL THEN
      MSG := '״̬�����Ա����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '��¼�뷢Ʊ��!';
      RETURN;
    ELSIF P_ISNOEND IS NULL THEN
      --��Ʊֹ��Ϊ�գ�����Ʊ��Ų�Ϊ��
      UPDATE INVSTOCK
         SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬  
             ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬���� 
             ISPTATUSPER    = ISSTATUSPER, --�ϴ�״̬��Ա 
             ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����, 4�˻�, 5����) 
             ISSTATUSDATE   = SYSDATE, --״̬���� 
             ISPRINTTYPE = CASE
                             WHEN P_STATUS = 0 THEN
                              NULL
                             ELSE
                              ISPRINTTYPE
                           END,
             --  isprintid      = case when P_status = 0 then null else isprintid end,
             --  isprintpiid    = case when P_status = 0 then null else isprintpiid end,
             ISPRINTCD = CASE
                           WHEN P_STATUS = 0 THEN
                            NULL
                           ELSE
                            ISPRINTCD
                         END,
             ISPRINTJE = CASE
                           WHEN P_STATUS = 0 THEN
                            NULL
                           ELSE
                            ISPRINTJE
                         END,
             --20120209
             ISMICODE = CASE
                          WHEN P_STATUS = 0 THEN
                           NULL
                          ELSE
                           ISMICODE
                        END,
             ISJE1 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE1
                     END,
             ISJE2 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE2
                     END,
             ISJE3 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE3
                     END,
             ISJE4 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE4
                     END,
             ISJE5 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE5
                     END,
             ISJE6 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE6
                     END,
             ISJE7 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE7
                     END,
             ISJE8 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE8
                     END,
             
             ISMEMO = CASE
                        WHEN P_STATUS = 0 THEN
                         NULL
                        ELSE
                         CASE
                           WHEN P_MEMO IS NULL THEN
                            ISMEMO
                           ELSE
                            P_MEMO
                         END
                      END,
             ISSTATUSPER = P_ISSTATUSPER --״̬��Ա 
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISBCNO = P_ISBCNO;
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
      IF P_STATUS = '5' THEN
        NULL;
      ELSE
        SP_UPDATERECOUTFLAG(P_ISBCNO,
                            TRIM(TO_CHAR(P_ISNOSTART, '00000000')));
        SP_DELETEISPCISNO(P_ISBCNO,
                          TRIM(TO_CHAR(P_ISNOSTART, '00000000')),
                          P_STATUS);
      END IF;
    ELSIF P_ISNOSTART IS NULL THEN
      --��Ʊ���Ϊ�գ�����Ʊֹ�Ų�Ϊ��
      /*update invstock
        set ispstatus      = isstatus,
            ispstatusdatep = isstatusdate,
            isptatusper    = isstatusper,
            isstatus     = p_status,
            isstatusdate = sysdate,
            ismemo = case when p_memo is null then ismemo else p_memo end,
            isstatusper  = p_isstatusper
      where isno = trim(to_char(p_isnoend,'00000000'))
        and isbcno = p_isbcno;*/
      UPDATE INVSTOCK
         SET ISPSTATUS      = ISSTATUS,
             ISPSTATUSDATEP = ISSTATUSDATE,
             ISPTATUSPER    = ISSTATUSPER,
             ISSTATUS       = P_STATUS,
             ISSTATUSDATE   = SYSDATE,
             ISPRINTTYPE = CASE
                             WHEN P_STATUS = 0 THEN
                              NULL
                             ELSE
                              ISPRINTTYPE
                           END,
             -- isprintid      = case when P_status = 0 then null else isprintid end,
             --   isprintpiid    = case when P_status = 0 then null else isprintpiid end,
             ISPRINTCD = CASE
                           WHEN P_STATUS = 0 THEN
                            NULL
                           ELSE
                            ISPRINTCD
                         END,
             ISPRINTJE = CASE
                           WHEN P_STATUS = 0 THEN
                            NULL
                           ELSE
                            ISPRINTJE
                         END,
             --20120209
             ISMICODE = CASE
                          WHEN P_STATUS = 0 THEN
                           NULL
                          ELSE
                           ISMICODE
                        END,
             ISJE1 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE1
                     END,
             ISJE2 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE2
                     END,
             ISJE3 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE3
                     END,
             ISJE4 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE4
                     END,
             ISJE5 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE5
                     END,
             ISJE6 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE6
                     END,
             ISJE7 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE7
                     END,
             ISJE8 = CASE
                       WHEN P_STATUS = 0 THEN
                        NULL
                       ELSE
                        ISJE8
                     END,
             
             ISMEMO = CASE
                        WHEN P_STATUS = 0 THEN
                         NULL
                        ELSE
                         CASE
                           WHEN P_MEMO IS NULL THEN
                            ISMEMO
                           ELSE
                            P_MEMO
                         END
                      END,
             ISSTATUSPER = P_ISSTATUSPER
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         AND ISBCNO = P_ISBCNO;
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        ROLLBACK;
        MSG := 'N';
        RETURN;
      END IF;
      IF P_STATUS = '5' THEN
        NULL;
      ELSE
        SP_UPDATERECOUTFLAG(P_ISBCNO, TRIM(TO_CHAR(P_ISNOEND, '00000000')));
        SP_DELETEISPCISNO(P_ISBCNO,
                          TRIM(TO_CHAR(P_ISNOEND, '00000000')),
                          P_STATUS);
      END IF;
    ELSE
      FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
        UPDATE INVSTOCK
           SET ISPSTATUS      = ISSTATUS,
               ISPSTATUSDATEP = ISSTATUSDATE,
               ISPTATUSPER    = ISSTATUSPER,
               ISSTATUS       = P_STATUS,
               ISSTATUSDATE   = SYSDATE,
               ISPRINTTYPE    = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISPRINTTYPE
                                END,
               -- isprintid      = case when P_status = 0 then null else isprintid end,
               -- isprintpiid    = case when P_status = 0 then null else isprintpiid end,
               ISPRINTCD = CASE
                             WHEN P_STATUS = 0 THEN
                              NULL
                             ELSE
                              ISPRINTCD
                           END,
               ISPRINTJE = CASE
                             WHEN P_STATUS = 0 THEN
                              NULL
                             ELSE
                              ISPRINTJE
                           END,
               
               --20120209
               ISMICODE = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISMICODE
                          END,
               ISJE1    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE1
                          END,
               ISJE2    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE2
                          END,
               ISJE3    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE3
                          END,
               ISJE4    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE4
                          END,
               ISJE5    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE5
                          END,
               ISJE6    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE6
                          END,
               ISJE7    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE7
                          END,
               ISJE8    = CASE
                            WHEN P_STATUS = 0 THEN
                             NULL
                            ELSE
                             ISJE8
                          END,
               
               ISMEMO      = CASE
                               WHEN P_STATUS = 0 THEN
                                NULL
                               ELSE
                                CASE
                                  WHEN P_MEMO IS NULL THEN
                                   ISMEMO
                                  ELSE
                                   P_MEMO
                                END
                             END,
               ISSTATUSPER = P_ISSTATUSPER
         WHERE ISNO = TRIM(TO_CHAR(I, '00000000'))
           AND ISBCNO = P_ISBCNO;
        nsql := SQL%ROWCOUNT;
        IF P_STATUS = '5' THEN
          NULL;
        ELSE
          SP_UPDATERECOUTFLAG(P_ISBCNO, TRIM(TO_CHAR(I, '00000000')));
          nsql := SQL%ROWCOUNT;
          SP_DELETEISPCISNO(P_ISBCNO,
                            TRIM(TO_CHAR(I, '00000000')),
                            P_STATUS);
          nsql := SQL%ROWCOUNT;
        END IF;
      END LOOP;
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        ROLLBACK;
        MSG := 'N';
        RETURN;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('sqlcode : ' || sqlcode);
      DBMS_OUTPUT.put_line('sqlerrm : ' || sqlerrm);
      ROLLBACK;
      MSG := 'N';
  END;

  --�޸ķ�Ʊ״̬
  PROCEDURE SP_INVMANG_MODIFYINV(P_ISNOSTART   VARCHAR2, --��Ʊ���
                                 P_ISNOEND     VARCHAR2, --��Ʊֹ��
                                 P_ISBCNO      VARCHAR2, --���κ�
                                 P_ISSTATUSPER VARCHAR2, --״̬�����Ա
                                 P_TYPE        VARCHAR2, --״̬2
                                 P_NUM         VARCHAR2, --��ע
                                 MSG           OUT VARCHAR2) IS
    /*��Ʊ������Ʊ����2����Ʊ��ʼ��0����ʹ��1������3��ɾ��4*/
    V_ISSTATUS     VARCHAR2(12);
    V_ISSTATUSDATE DATE;
    V_ISSTATUSPER  VARCHAR2(12);
    V_COUNT        NUMBER;
    V_ISTRUE1      NUMBER;
    V_ISTRUE2      NUMBER;
    V_INCLIST      INVSTOCK_TEMP%ROWTYPE;
  
    P_ISNOSTART_01 VARCHAR2(12);
    P_ISNOEND_01   VARCHAR2(12);
  
    P_ISNOSTART_02 VARCHAR2(12);
    P_ISNOEND_02   VARCHAR2(12);
  
    V_MSG VARCHAR2(12);
  
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISSTATUSPER IS NULL THEN
      MSG := '״̬�����Ա����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '��¼�뷢Ʊ��!';
      RETURN;
    END IF;
  
    --��ԭʼ���ݲ��뵽��ʱ����
    DELETE INVSTOCK_TEMP;
    INSERT INTO INVSTOCK_TEMP INTP
      SELECT *
        FROM INVSTOCK INST
       WHERE INST.ISBCNO = P_ISBCNO
         AND INST.ISNO >= P_ISNOSTART
         AND INST.ISNO <= P_ISNOEND;
  
    ---���Ƶ�����
    IF P_TYPE = '01' THEN
    
      IF TO_NUMBER(P_ISNOSTART) - TO_NUMBER(P_NUM) < 0 THEN
        MSG := '���Ƶ����ݲ�����������!';
        RETURN;
      END IF;
    
      FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
      
        SELECT *
          INTO V_INCLIST
          FROM INVSTOCK_TEMP INL
         WHERE INL.ISBCNO = P_ISBCNO
           AND INL.ISNO = TRIM(TO_CHAR(I, '00000000'));
      
        UPDATE INVSTOCK
           SET ISSTATUS     = V_INCLIST.ISSTATUS,
               ISSTATUSDATE = V_INCLIST.ISSTATUSDATE,
               ISSTATUSPER  = V_INCLIST.ISSTATUSPER,
               ISSMFID      = V_INCLIST.ISSMFID,
               ISPRINTTYPE  = V_INCLIST.ISPRINTTYPE,
               -- ISPRINTID    = v_inclist.ISPRINTID,
               -- ISPRINTPIID  = v_inclist.ISPRINTPIID,
               ISPRINTCD    = V_INCLIST.ISPRINTCD,
               ISPRINTJE    = V_INCLIST.ISPRINTJE,
               ISPRINTTRANS = V_INCLIST.ISPRINTTRANS,
               ISOUTPER     = V_INCLIST.ISOUTPER,
               ISOUTDATE    = V_INCLIST.ISOUTDATE,
               ISMEMO       = V_INCLIST.ISMEMO,
               ISZZS        = V_INCLIST.ISZZS
         WHERE ISNO = TRIM(TO_CHAR(I - TO_NUMBER(P_NUM), '00000000'))
           AND ISBCNO = P_ISBCNO;
        P_ISNOSTART_01 := TRIM(TO_CHAR(I + 1 - TO_NUMBER(P_NUM), '00000000'));
      END LOOP;
    
      --    p_isnostart_01 := to_char(to_number( p_isnostart +  p_num) -1, '00000000');
    
      SP_INVMANG_MODIFYSTATUS(P_ISNOSTART_01,
                              P_ISNOEND,
                              P_ISBCNO,
                              P_ISSTATUSPER,
                              0,
                              '��Ʊ��',
                              V_MSG);
    
      --���Ƶ�����
    ELSIF P_TYPE = '02' THEN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM INVSTOCK INVS
       WHERE INVS.ISBCNO = P_ISBCNO
         AND INVS.ISNO =
             TRIM(TO_CHAR(TO_NUMBER(P_ISNOEND) + TO_NUMBER(P_NUM),
                          '00000000'))
         AND INVS.ISSTATUS = '0';
    
      IF V_COUNT < 1 THEN
        MSG := '���Ƶ����ݲ�����������!';
        RETURN;
      END IF;
    
      FOR J IN P_ISNOSTART .. P_ISNOEND LOOP
      
        SELECT *
          INTO V_INCLIST
          FROM INVSTOCK_TEMP INL
         WHERE INL.ISBCNO = P_ISBCNO
           AND INL.ISNO = TRIM(TO_CHAR(J, '00000000'));
      
        UPDATE INVSTOCK
           SET ISSTATUS     = V_INCLIST.ISSTATUS,
               ISSTATUSDATE = V_INCLIST.ISSTATUSDATE,
               ISSTATUSPER  = V_INCLIST.ISSTATUSPER,
               ISSMFID      = V_INCLIST.ISSMFID,
               ISPRINTTYPE  = V_INCLIST.ISPRINTTYPE,
               -- ISPRINTID    = v_inclist.ISPRINTID,
               -- ISPRINTPIID  = v_inclist.ISPRINTPIID,
               ISPRINTCD    = V_INCLIST.ISPRINTCD,
               ISPRINTJE    = V_INCLIST.ISPRINTJE,
               ISPRINTTRANS = V_INCLIST.ISPRINTTRANS,
               ISOUTPER     = V_INCLIST.ISOUTPER,
               ISOUTDATE    = V_INCLIST.ISOUTDATE,
               ISMEMO       = V_INCLIST.ISMEMO,
               ISZZS        = V_INCLIST.ISZZS
         WHERE ISNO = TRIM(TO_CHAR(J + TO_NUMBER(P_NUM), '00000000'))
           AND ISBCNO = P_ISBCNO;
      END LOOP;
    
      P_ISNOEND_02 := TRIM(TO_CHAR(TO_NUMBER(P_ISNOSTART + P_NUM) - 1,
                                   '00000000'));
    
      SP_INVMANG_MODIFYSTATUS(P_ISNOSTART,
                              P_ISNOEND_02,
                              P_ISBCNO,
                              P_ISSTATUSPER,
                              0,
                              '��Ʊ��',
                              V_MSG);
    
    END IF;
  
    IF SQL%ROWCOUNT > 0 THEN
      MSG := 'Y';
    ELSE
      ROLLBACK;
      MSG := 'N';
      RETURN;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := 'N';
  END;

  PROCEDURE SP_INVMANG_ZLY(P_ISNOSTART   VARCHAR2, --��Ʊ���
                           P_ISNOEND     VARCHAR2, --��Ʊֹ��
                           P_ISBCNO      VARCHAR2, --���κ�
                           P_ISSTATUSPER VARCHAR2, --������Ա
                           P_STATUS      NUMBER, --״̬0
                           P_MEMO        VARCHAR2, --��ע
                           MSG           OUT VARCHAR2) IS
    /*��Ʊ������Ʊ����2����Ʊ��ʼ��0����ʹ��1������3��ɾ��4*/
    V_ISSTATUS     VARCHAR2(12);
    V_ISSTATUSDATE DATE;
    V_ISSTATUSPER  VARCHAR2(12);
    V_COUNT        NUMBER;
    V_ISTRUE1      NUMBER;
    V_ISTRUE2      NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISSTATUSPER IS NULL THEN
      MSG := '������Ա����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '��¼�뷢Ʊ��!';
      RETURN;
    END IF;
  
    --�жϸö�Ʊ�ݺ������û���Ѿ���ӡ������
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM INVSTOCK
       WHERE ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND
         AND ISBCNO = P_ISBCNO
         AND ISSTATUS <> '0';
    END;
  
    --��Ʊֹ��Ϊ�գ�����Ʊ��Ų�Ϊ��
    /* select count(*)
      into v_count
      from invstockhis inhis
     where isno >= p_isnostart
       and isno <= p_isnoend
       and isbcno = p_isbcno;
    
    if v_count = 0 then
      insert into invstockhis
        select *
          from invstock
         where isno >= p_isnostart
           and isno <= p_isnoend
           and isbcno = p_isbcno
           and  (isbcno,isno) not in
           (select isbcno,isno  from  invstockhis
           )
             ;
    end if;*/
    IF V_COUNT <= 0 THEN
      UPDATE INVSTOCK
         SET ISPER          = P_ISSTATUSPER,
             ISSTATUSDATE   = SYSDATE,
             ISSTATUSPER    = P_ISSTATUSPER,
             ISPSTATUS      = ISSTATUS,
             ISPSTATUSDATEP = ISSTATUSDATE,
             ISPTATUSPER    = ISSTATUSPER
       WHERE ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND
         AND ISBCNO = P_ISBCNO;
    END IF;
    IF SQL%ROWCOUNT > 0 THEN
      MSG := 'Y';
      COMMIT;
    ELSE
      MSG := 'N';
      RETURN;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := 'N';
  END;

  --������Ʊ
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --���κ�
                           P_ISPER     VARCHAR2, --��Ʊ��
                           P_ISTYPE    VARCHAR2, --��Ʊ���
                           P_ISNOSTART VARCHAR2, --��Ʊ���
                           P_ISNOEND   VARCHAR2, --��Ʊֹ��
                           P_OUTPER    VARCHAR2, --����Ʊ����
                           MSG         OUT VARCHAR2) IS
    /*��Ʊ������Ʊ*/
    V_ISTRUE1 NUMBER;
    V_ISTRUE2 NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISPER IS NULL THEN
      MSG := '��Ʊ�˲�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISTYPE IS NULL THEN
      MSG := '��Ʊ�������Ϊ��ֵ!';
      RETURN;
    END IF;
  
    IF P_ISNOSTART IS NULL OR P_ISNOEND IS NULL THEN
      MSG := '��¼����ʼ��Ʊ�ź���ֹ��Ʊ��!';
      RETURN;
    ELSE
      --��Ʊֹ��Ϊ�գ�����Ʊ��Ų�Ϊ��
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = P_ISBCNO
         AND ISNO >= TO_CHAR(P_ISNOSTART, '00000000')
         AND ISNO <= TO_CHAR(P_ISNOEND, '00000000');
    
      IF V_ISTRUE1 = 0 THEN
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          INSERT INTO INVSTOCK
            (ISID,
             ISBCNO,
             ISNO,
             ISPER,
             ISTYPE,
             ISSTATUSPER,
             ISOUTPER,
             ISSTATUSDATE,
             ISOUTDATE,
             ISSTATUS,
             ISPCISNO)
          VALUES
            (TO_CHAR(SEQ_INVSTOCK.NEXTVAL, '00000000'),
             P_ISBCNO,
             TRIM(TO_CHAR(I, '00000000')),
             P_ISPER,
             P_ISTYPE,
             P_ISPER,
             P_OUTPER,
             SYSDATE,
             SYSDATE,
             '0',
             TRIM(P_ISBCNO || '.' || TRIM(TO_CHAR(I, '00000000'))));
        END LOOP;
        --�ж�ÿ���Ƿ���ӳɹ�
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ���ȡ�ķ�Ʊ��';
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '��ȡʧ��!';
  END;

  PROCEDURE SP_SPTZ(P_ISBCNO      IN VARCHAR2, --���κ�
                    P_MINSOURCENO IN VARCHAR2,
                    P_MAXSOURCENO IN VARCHAR2,
                    P_MINDESTNO   IN VARCHAR2, --����Ŀ�귢Ʊ��ʼ��
                    P_MAXDESTNO   IN VARCHAR2, --����Ŀ��ԭ��Ʊ��ֹ��
                    P_TYPE        IN VARCHAR2) -- FPDT ��Ʊ�Ե�  FPTH ��Ʊ����
   IS
  
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    V_OUTMSG  VARCHAR2(300);
    V_COUNT   NUMBER;
    V_s       VARCHAR2(300);
    V_d       VARCHAR2(300);
    E_Ʊ��ռ�� EXCEPTION;
    V_ISNO VARCHAR2(12);
  BEGIN
    --�����ʱ��
    DELETE INVSTOCKSWAP;
    delete invstock_datatemp_h;
  
    V_COUNT := 0;
    SELECT COUNT(ISID), MIN(T.ISNO)
      INTO V_COUNT, V_ISNO
      FROM INVSTOCK T
     WHERE ISSTATUS = '1'
       AND T.ISID IN
           (SELECT T.ISID
              FROM INVSTOCK T
             WHERE T.ISBCNO = P_ISBCNO --Ŀ��
               AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
               AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))
            MINUS
            SELECT T.ISID
              FROM INVSTOCK T
             WHERE T.ISBCNO = P_ISBCNO --ԭ
               AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
               AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000')));
    /*IF V_COUNT > 0 THEN
      RAISE E_Ʊ��ռ��; 
    END IF;*/
    V_STEP    := 10;
    V_PRC_MSG := '��֯��Ʊ������ϵ';
  
    INSERT INTO INVSTOCKSWAP
      SELECT MAX(DECODE(V_TYPE, 'S', ISNO, NULL)) SOURCENO,
             MAX(DECODE(V_TYPE, 'D', ISNO, NULL)) DESTNO,
             MAX(DECODE(V_TYPE, 'S', ISID, NULL)) SOURCEID,
             MAX(DECODE(V_TYPE, 'D', ISID, NULL)) DESTID,
             0
        FROM (SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'S' V_TYPE
                FROM INVSTOCK T
               WHERE T.ISBCNO = P_ISBCNO --ԭ
                 AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                 AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))
              UNION
              SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'D' V_TYPE
                FROM INVSTOCK T
               WHERE T.ISBCNO = P_ISBCNO --Ŀ��
                 AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
                 AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000')))
       GROUP BY V_NUM
      UNION ALL
      SELECT MAX(DECODE(V_TYPE, 'S', ISNO, NULL)) SOURCENO,
             MAX(DECODE(V_TYPE, 'D', ISNO, NULL)) DESTNO,
             MAX(DECODE(V_TYPE, 'S', ISID, NULL)) SOURCEID,
             MAX(DECODE(V_TYPE, 'D', ISID, NULL)) DESTID,
             1
        FROM (SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'S' V_TYPE
                FROM (SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --ԭ
                         AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))
                      MINUS
                      SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --Ŀ��
                         AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))) T
              UNION
              SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'D' V_TYPE
                FROM (SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --Ŀ��
                         AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))
                      MINUS
                      SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --ԭ
                         AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))) T)
       GROUP BY V_NUM;
  
    IF UPPER(P_TYPE) = 'FPTH' THEN
      V_STEP    := 20;
      V_PRC_MSG := '��Ʊ';
    
      insert into invstock_datatemp_h
        select *
          from invstock
         where isid in (SELECT SOURCEID FROM INVSTOCKSWAP WHERE DTYPE = 0);
    
      UPDATE invstock_datatemp_h T
         SET T.ISNO  =
             (SELECT DESTNO
                FROM INVSTOCKSWAP
               WHERE SOURCEID = T.ISID
                 AND DTYPE = 0),
             T.ISMEMO = '�ֹ���Ʊ'
       WHERE T.ISID IN (SELECT SOURCEID FROM INVSTOCKSWAP WHERE DTYPE = 0)
         AND T.ISBCNO = P_ISBCNO;
    
      V_STEP := 201;
      insert into invstock_datatemp_h
        select *
          from invstock
         where isid in (SELECT DESTID FROM INVSTOCKSWAP WHERE DTYPE = 1);
    
      V_PRC_MSG := '���µ���������ƱΪδʹ��';
      UPDATE invstock_datatemp_h T
         SET T.ISNO =
             (SELECT SOURCENO
                FROM INVSTOCKSWAP
               WHERE DESTID = T.ISID
                 AND DTYPE = 1),
             --T.ISSTATUS = 0,
             T.ISMEMO = '�ֹ���Ʊ'
       WHERE T.ISID IN (SELECT DESTID FROM INVSTOCKSWAP WHERE DTYPE = 1)
         AND T.ISBCNO = P_ISBCNO;
    
      update invstock_datatemp_h T set ispcisno = isbcno || '.' || isno;
      delete INVSTOCK where isid in (select isid from invstock_datatemp_h);
    
      insert into INVSTOCK
        select * from invstock_datatemp_h;
    
      update inv_info t
         set ISPCISNO =
             (select ISPCISNO from invstock_datatemp_h where isid = t.isid)
       where isid in (select isid from invstock_datatemp_h);
    
      /*      UPDATE INVSTOCK T
               SET T.ISNO   = (SELECT DESTNO
                                 FROM INVSTOCKSWAP
                                WHERE SOURCEID = T.ISID
                                  AND DTYPE = 0),
                   T.ISMEMO = '�ֹ���Ʊ'
             WHERE T.ISID IN (SELECT SOURCEID FROM INVSTOCKSWAP WHERE DTYPE = 0)
               AND T.ISBCNO = P_ISBCNO;
            V_STEP    := 201;
            V_PRC_MSG := '���µ���������ƱΪδʹ��';
            UPDATE INVSTOCK T
               SET T.ISNO     = (SELECT SOURCENO
                                   FROM INVSTOCKSWAP
                                  WHERE DESTID = T.ISID
                                    AND DTYPE = 1),
                   --T.ISSTATUS = 0,
                   T.ISMEMO   = '�ֹ���Ʊ'
             WHERE T.ISID IN (SELECT DESTID FROM INVSTOCKSWAP WHERE DTYPE = 1)
               AND T.ISBCNO = P_ISBCNO;
      */
    END IF;
  
    IF UPPER(P_TYPE) = 'FPDD' THEN
      V_STEP    := 20;
      V_PRC_MSG := '��Ʊ';
    
      v_s := TRIM(TO_CHAR(P_MINSOURCENO, '00000000'));
      v_d := TRIM(TO_CHAR(P_MINDESTNO, '00000000'));
    
      insert into invstock_datatemp_h
        select *
          from invstock
         where isno = v_s
           and ISBCNO = P_ISBCNO;
      insert into invstock_datatemp_h
        select *
          from invstock
         where isno = v_d
           and ISBCNO = P_ISBCNO;
    
      --      commit;
    
      UPDATE invstock_datatemp_h T
         SET T.ISNO = v_s
       WHERE T.isid = (select isid
                         from INVSTOCK
                        where ISBCNO = P_ISBCNO
                          and ISNO = v_d);
      --              commit;
    
      UPDATE invstock_datatemp_h T
         SET T.ISNO = v_d
       WHERE T.isid = (select isid
                         from INVSTOCK
                        where ISBCNO = P_ISBCNO
                          and ISNO = v_s);
    
      --              commit;
    
      update invstock_datatemp_h T set ispcisno = isbcno || '.' || isno;
      --      commit;
      delete INVSTOCK where isid in (select isid from invstock_datatemp_h);
    
      insert into INVSTOCK
        select * from invstock_datatemp_h;
    
      update inv_info t
         set ISPCISNO =
             (select ISPCISNO from invstock_datatemp_h where isid = t.isid)
       where isid in (select isid from invstock_datatemp_h);
      --      commit;
    end if;
  
  EXCEPTION
    WHEN E_Ʊ��ռ�� THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ��[' || V_ISNO || ']' || '�Ѿ���ʹ�ã����ȶԸú�����е���');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              'ִ�в���[' || V_STEP || '],[' || V_PRC_MSG ||
                              '],���ִ���!');
  END;

  --��Ʊ��⡢�ַ������á��˻�
  PROCEDURE SP_STOCK(P_ISBCNO    VARCHAR2, --���κ�
                     P_ISSTOCKDO VARCHAR2, --�ֿ����
                     P_ISSMFID   VARCHAR2, --�ֿ�
                     P_ISPER     VARCHAR2, --��Ʊ��
                     P_ISTYPE    VARCHAR2, --��Ʊ���
                     P_ISNOSTART VARCHAR2, --��Ʊ���
                     P_ISNOEND   VARCHAR2, --��Ʊֹ��
                     P_OUTPER    VARCHAR2, --����Ʊ����
                     MSG         OUT VARCHAR2) IS
  
    V_ISPCISNO VARCHAR2(100);
    V_ROOT     VARCHAR2(100);
    V_do       VARCHAR2(100);
    V_qty      NUMBER;
    V_ISTRUE1  NUMBER;
    V_ISTRUE2  NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '��Ʊ���κŲ�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISPER IS NULL THEN
      MSG := '��Ʊ�˲�����Ϊ��ֵ!';
      RETURN;
    END IF;
    IF P_ISTYPE IS NULL THEN
      MSG := '��Ʊ�������Ϊ��ֵ!';
      RETURN;
    END IF;
  
    IF P_ISNOSTART IS NULL OR P_ISNOEND IS NULL THEN
      MSG := '��¼����ʼ��Ʊ�ź���ֹ��Ʊ��!';
      RETURN;
    END IF;
  
    V_qty  := to_number(P_ISNOEND) - to_number(P_ISNOSTART) + 1;
    V_ROOT := 'ROOT';
    --��Ʊֹ��Ϊ�գ�����Ʊ��Ų�Ϊ��
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '0' THEN
      -- 0���
      V_do := '���';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'));
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           V_ROOT,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          INSERT INTO INVSTOCK
            (ISID, --Ʊ����ˮ�� 
             ISBCNO, --���� 
             ISNO, --Ʊ�ݺ��� 
             ISPER, --��������� 
             ISTYPE, --Ʊ������ 
             ISSTATUSPER, --״̬��Ա 
             ISOUTPER, --����Ʊ���� 
             ISSTATUSDATE, --״̬���� 
             ISOUTDATE, --����ʱ�� 
             ISSTATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����, 4�˻�, 5����) 
             ISPCISNO, --Ʊ������||���� 
             ISSMFID, --��浥λ 
             ISSTOCKDO,
             ISSTOCKPER,
             ISSTOCKDATE) --�ֿ�״̬(0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������)
          VALUES
            (TO_CHAR(SEQ_INVSTOCK.NEXTVAL, '00000000'),
             P_ISBCNO,
             TRIM(TO_CHAR(I, '00000000')),
             P_ISPER,
             P_ISTYPE,
             P_ISPER,
             P_OUTPER,
             SYSDATE,
             SYSDATE,
             '0',
             V_ISPCISNO,
             V_ROOT,
             P_ISSTOCKDO,
             P_ISPER,
             SYSDATE);
        END LOOP;
      
        --�ж�ÿ���Ƿ���ӳɹ�
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '1' THEN
      -- 1�ַ�
      V_do := '�ַ�';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> 'ROOT' or ISSTATUS <> '0');
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           P_ISSMFID,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --״̬���� 
                 ISPER        = P_ISPER, --��������� 
                 ISSMFID      = P_ISSMFID, --��浥λ 
                 ISOUTPER     = P_OUTPER, --����Ʊ���� 
                 ISOUTDATE    = SYSDATE, --����ʱ�� 
                 ISSTOCKDO    = P_ISSTOCKDO --�ֿ�״̬(0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������)
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '2' THEN
      -- 22����
      V_do := '����';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> P_ISSMFID or ISSTATUS <> '0' or
             (ISSTOCKDO not in ('1', '3')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           P_ISSMFID,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --״̬���� 
                 ISSMFID      = P_ISSMFID, --��浥λ 
                 ISPER        = P_ISPER, --��������� 
                 ISOUTDATE    = SYSDATE, --����ʱ�� 
                 ISOUTPER     = P_OUTPER, --����Ʊ���� 
                 ISSTOCKDO    = P_ISSTOCKDO
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '5' THEN
      -- 5��������
      V_do := '��������';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSTATUS <> '0');
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           P_ISSMFID,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE,
                 ISPER        = P_ISPER,
                 ISOUTDATE    = SYSDATE,
                 ISOUTPER     = P_ISPER,
                 ISSMFID      = P_ISSMFID,
                 ISSTOCKDO    = P_ISSTOCKDO,
                 ISSTATUS     = '4'
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '3' THEN
      -- 3�˻�Ӫҵ��
      V_do := 'ʹ�õ�';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         AND (ISSMFID <> P_ISSMFID or ISSTOCKDO <> '2' or
             (ISSTATUS not in ('0', '2')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           P_ISSMFID,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --״̬���� 
                 --ISPER = P_ISPER,--��������� 
                 ISSMFID = P_ISSMFID, --��浥λ 
                 -- ISOUTDATE = SYSDATE,--����ʱ�� 
                 -- ISOUTPER = P_ISPER,--����Ʊ���� 
                 ISSTOCKDO = P_ISSTOCKDO
          --                 ISSTATUS = '4'
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
    /*0��⣻1�ַ���2���ã�3�˻�Ӫҵ��, 4�˻ع�˾��5��������*/
    IF P_ISSTOCKDO = '4' THEN
      -- 4�˻ع�˾
      V_do := '�˻ع�˾';
    
      --����������      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> P_ISSMFID or ISSTATUS not in ('0', '2', '4') or
             (ISSTOCKDO not in ('1', '3')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --���� INV_IO ��
        INSERT INTO INV_IO
          (IOID,
           IOTYPE,
           IODATE,
           IOSENDER,
           IORECEIVER,
           IOBCNO,
           IOSNO,
           IOENO,
           IOSMFID,
           ISSTOCKDO,
           QTY)
        VALUES
          (SEQ_INVOUT.NEXTVAL,
           P_ISTYPE,
           SYSDATE,
           P_ISPER,
           NULL,
           P_ISBCNO,
           P_ISNOSTART,
           P_ISNOEND,
           P_ISSMFID,
           P_ISSTOCKDO,
           v_qty);
      
        --Ʊ�ݷֲ�    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE,
                 ISPER        = P_ISPER,
                 ISSMFID      = 'ROOT',
                 -- ISOUTDATE = SYSDATE,
                 -- ISOUTPER = P_ISPER,
                 ISSTOCKDO = P_ISSTOCKDO
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '�����η�Ʊ����δ����ѱ�' || V_do || '�ķ�Ʊ��';
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '��ȡʧ��!';
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                         P_ID          IN VARCHAR2, --ʵ������
                         P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                         P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                         P_ILTYPE      IN VARCHAR2, --Ʊ������
                         P_PRINTER     IN VARCHAR2, --��ӡԱ
                         P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                         P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                         P_ISPRINTCD   IN VARCHAR2, --�������
                         P_SNO         IN NUMBER ----��Ʊ��ˮ
                         )
  
   IS
  
  BEGIN
  
    IF P_ISPRINTTYPE = '1' THEN
      NULL;
      IF P_IFFPHP = 'H' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_H_SF(P_IFFPHP, --F��ƱH��Ʊ
                              P_ID, --ʵ������
                              P_PIID, --������Ŀ 01/02/03
                              P_ISPRINTTYPE, --��ӡ��ʽ
                              P_ILTYPE, --Ʊ������
                              P_PRINTER, --��ӡԱ
                              P_ILSTATUS, --Ʊ��״̬
                              P_ILSMFID, --�ֹ�˾
                              P_ISPRINTCD, --�����
                              P_SNO --��ʼ��Ʊ��
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_H_WSF(P_IFFPHP, --F��ƱH��Ʊ
                               P_ID, --ʵ������
                               P_PIID, --������Ŀ 01/02/03
                               P_ISPRINTTYPE, --��ӡ��ʽ
                               P_ILTYPE, --Ʊ������
                               P_PRINTER, --��ӡԱ
                               P_ILSTATUS, --Ʊ��״̬
                               P_ILSMFID, --�ֹ�˾
                               P_ISPRINTCD, --�����
                               P_SNO --��ʼ��Ʊ��
                               );
        END IF;
      
      ELSIF P_IFFPHP = 'F' THEN
        --
        NULL;
        SP_CHARGEINV_1_F(P_IFFPHP, --F��ƱH��Ʊ
                         P_ID, --ʵ������
                         P_PIID, --������Ŀ 01/02/03
                         P_ISPRINTTYPE, --��ӡ��ʽ
                         P_ILTYPE, --Ʊ������
                         P_PRINTER, --��ӡԱ
                         P_ILSTATUS, --Ʊ��״̬
                         P_ILSMFID, --�ֹ�˾
                         P_ISPRINTCD, --�����
                         P_SNO --��ʼ��Ʊ��
                         );
      
      ELSIF P_IFFPHP = 'M' THEN
        NULL;
        SP_CHARGEINV_1_F_HSB(P_IFFPHP, --F��ƱH��Ʊ
                             P_ID, --ʵ������
                             P_PIID, --������Ŀ 01/02/03
                             P_ISPRINTTYPE, --��ӡ��ʽ
                             P_ILTYPE, --Ʊ������
                             P_PRINTER, --��ӡԱ
                             P_ILSTATUS, --Ʊ��״̬
                             P_ILSMFID, --�ֹ�˾
                             P_ISPRINTCD, --�����
                             P_SNO --��ʼ��Ʊ��
                             );
      
      ELSIF P_IFFPHP = 'G' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_G_SF(P_IFFPHP, --F��ƱH��Ʊ
                              P_ID, --ʵ������
                              P_PIID, --������Ŀ 01/02/03
                              P_ISPRINTTYPE, --��ӡ��ʽ
                              P_ILTYPE, --Ʊ������
                              P_PRINTER, --��ӡԱ
                              P_ILSTATUS, --Ʊ��״̬
                              P_ILSMFID, --�ֹ�˾
                              P_ISPRINTCD, --�����
                              P_SNO --��ʼ��Ʊ��
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_G_WSF(P_IFFPHP, --F��ƱH��Ʊ
                               P_ID, --ʵ������
                               P_PIID, --������Ŀ 01/02/03
                               P_ISPRINTTYPE, --��ӡ��ʽ
                               P_ILTYPE, --Ʊ������
                               P_PRINTER, --��ӡԱ
                               P_ILSTATUS, --Ʊ��״̬
                               P_ILSMFID, --�ֹ�˾
                               P_ISPRINTCD, --�����
                               P_SNO --��ʼ��Ʊ��
                               );
        
        END IF;
      
      ELSIF P_IFFPHP = 'Z' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_Z_SF(P_IFFPHP, --F��ƱH��Ʊ
                              P_ID, --ʵ������
                              P_PIID, --������Ŀ 01/02/03
                              P_ISPRINTTYPE, --��ӡ��ʽ
                              P_ILTYPE, --Ʊ������
                              P_PRINTER, --��ӡԱ
                              P_ILSTATUS, --Ʊ��״̬
                              P_ILSMFID, --�ֹ�˾
                              P_ISPRINTCD, --�����
                              P_SNO --��ʼ��Ʊ��
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_Z_WSF(P_IFFPHP, --F��ƱH��Ʊ
                               P_ID, --ʵ������
                               P_PIID, --������Ŀ 01/02/03
                               P_ISPRINTTYPE, --��ӡ��ʽ
                               P_ILTYPE, --Ʊ������
                               P_PRINTER, --��ӡԱ
                               P_ILSTATUS, --Ʊ��״̬
                               P_ILSMFID, --�ֹ�˾
                               P_ISPRINTCD, --�����
                               P_SNO --��ʼ��Ʊ��
                               );
        END IF;
      END IF;
      -- ������պ����յ��û��Ĵ�ӡ
    ELSIF P_ISPRINTTYPE = 'T' THEN
      NULL;
      SP_CHARGEINV_1_F_TS(P_IFFPHP, --F��ƱH��Ʊ
                          P_ID, --ʵ������
                          P_PIID, --������Ŀ 01/02/03
                          P_ISPRINTTYPE, --��ӡ��ʽ
                          P_ILTYPE, --Ʊ������
                          P_PRINTER, --��ӡԱ
                          P_ILSTATUS, --Ʊ��״̬
                          P_ILSMFID, --�ֹ�˾
                          P_ISPRINTCD, --�����
                          P_SNO --��ʼ��Ʊ��
                          );
      --������յ��û��Ĵ�ӡ
    ELSIF P_ISPRINTTYPE = 'I' THEN
      NULL;
      SP_CHARGEINV_1_F_ZS(P_IFFPHP, --F��ƱH��Ʊ
                          P_ID, --ʵ������
                          P_PIID, --������Ŀ 01/02/03
                          P_ISPRINTTYPE, --��ӡ��ʽ
                          P_ILTYPE, --Ʊ������
                          P_PRINTER, --��ӡԱ
                          P_ILSTATUS, --Ʊ��״̬
                          P_ILSMFID, --�ֹ�˾
                          P_ISPRINTCD, --�����
                          P_SNO --��ʼ��Ʊ��
                          );
      --��Դ�ӡ������
    
    ELSE
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_BAK(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER)
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
    CURSOR C_PBATCH_MX(AS_PBARCH VARCHAR2) IS
      SELECT * FROM PAYMENT WHERE PBATCH = AS_PBARCH ORDER BY PID;
    CURSOR C_PBATCH_MX_NO_S(AS_PBARCH VARCHAR2) IS
      SELECT *
        FROM PAYMENT
       WHERE PBATCH = AS_PBARCH
         AND PTRANS <> 'S'
       ORDER BY PID;
    CURSOR C_PBATCH_PLID_MX(AS_PBATCH VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PBATCH
       ORDER BY PID || RLID;
    CURSOR C_PBATCH_MRID_MX(AS_PBATCH VARCHAR2) IS
      SELECT SUM(RLPAIDJE) RLPAIDJE, RLMRID, TRIM(TO_CHAR(MAX(RLCD))) RLCD
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND RLREVERSEFLAG = 'N'
            --and RLMRID = as_MRID
         AND PBATCH = AS_PBATCH
       GROUP BY RLMRID;
    CURSOR C_PBATCH_MRID_MX_SF(AS_PBATCH VARCHAR2) IS
      SELECT SUM(RLPAIDJE) RLPAIDJE, RLMRID, TRIM(TO_CHAR(MAX(RLCD))) RLCD
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND RLREVERSEFLAG = 'N'
         AND (T.RLGROUP <> 2 OR RLGROUP IS NULL)
         AND PBATCH = AS_PBATCH
       GROUP BY RLMRID;
    CURSOR C_PBATCH_MRID_MX_WSF(AS_PBATCH VARCHAR2) IS
      SELECT SUM(RLPAIDJE) RLPAIDJE, RLMRID, TRIM(TO_CHAR(MAX(RLCD))) RLCD
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND RLREVERSEFLAG = 'N'
         AND T.RLGROUP = 2
         AND PBATCH = AS_PBATCH
       GROUP BY RLMRID;
    CURSOR C_PBATCH_RLID_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PID
       ORDER BY PID || RLID;
    CURSOR C_PBATCH_RLID_SF_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
       ORDER BY PID || RLID;
    CURSOR C_PBATCH_RLID_WSF_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PID
         AND RLGROUP = 2
       ORDER BY PID || RLID;
  
    CURSOR C_PBATCH_PID_SF_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PID = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
       ORDER BY PID || RLID;
    CURSOR C_PBATCH_PID_WSF_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PID = AS_PID
         AND RLGROUP = 2
       ORDER BY PID || RLID;
  
    CURSOR C_PBATCH_PLID_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.* FROM RECLIST T WHERE RLID = AS_PID;
    CURSOR C_PBATCH_MRID_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T
       WHERE RLMRID = AS_PID
         AND RLREVERSEFLAG = 'N';
    CURSOR C_PBATCH_MRID_MX_SF_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T
       WHERE RLMRID = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
         AND RLREVERSEFLAG = 'N';
    CURSOR C_PBATCH_MRID_MX_WSF_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T
       WHERE RLMRID = AS_PID
         AND RLGROUP = 2
         AND RLREVERSEFLAG = 'N';
    CURSOR C_RLID_PBPARMTEMP IS
      SELECT T.* FROM PBPARMTEMP T;
    CURSOR C_PBATCH_PID_MX IS
      SELECT T.* FROM PBPARMNNOCOMMIT_PRINT T;
    CURSOR C_PBATCH_PID_SF_MX(AS_PBATCH IN VARCHAR2) IS
      SELECT T.*
        FROM PAYMENT T, RECLIST T1
       WHERE PID = RLPID
         AND PBATCH = AS_PBATCH
         AND RLGROUP <> 2
          OR RLGROUP IS NULL;
    CURSOR C_PBATCH_PID_WSF_MX(AS_PBATCH IN VARCHAR2) IS
      SELECT T.*
        FROM PAYMENT T, RECLIST T1
       WHERE PID = RLPID
         AND PBATCH = AS_PBATCH
         AND RLGROUP = 2;
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
    V_ISPRINTJE01 := 0;
    --���������δ�ӡ payment.pbatch
    IF P_ISPRINTTYPE = '1' THEN
      IF P_IFFPHP = 'H' THEN
        SELECT SUM((PRCRECEIVED)),
               COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE, V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE PBATCH = P_ID
           AND PID = RLPID
           AND RLID = RDID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        ELSE
          IF V_COUNT1 > V_COUNT2 THEN
            SELECT PTRANS
              INTO V_TRNAS
              FROM PAYMENT T
             WHERE PBATCH = P_ID
               AND PTRANS <> 'S'
               AND ROWNUM = 1;
          ELSE
            V_TRNAS := 'S';
          END IF;
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          ID.IDID        := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
          ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
          ID.ISPRINTPIID := NULL; -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --�տ���
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND RLID = RDID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_RLID_SF_MX(P_ID);
          LOOP
            FETCH C_PBATCH_RLID_SF_MX
              INTO RL;
            EXIT WHEN C_PBATCH_RLID_SF_MX%NOTFOUND OR C_PBATCH_RLID_SF_MX%NOTFOUND IS NULL;
            NULL;
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_RLID_SF_MX;
        
          --��ˮ��
        
          V_ISID := FGETINVNO(P_PRINTER, --����Ա
                              'W', --��Ʊ����
                              P_SNO);
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --�տ���
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND RLID = RDID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   'W', --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_RLID_WSF_MX(P_ID);
          LOOP
            FETCH C_PBATCH_RLID_WSF_MX
              INTO RL;
            EXIT WHEN C_PBATCH_RLID_WSF_MX%NOTFOUND OR C_PBATCH_RLID_WSF_MX%NOTFOUND IS NULL;
            NULL;
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_RLID_WSF_MX;
        
        END IF;
      ELSIF P_IFFPHP = 'Hbak' THEN
        SELECT SUM((PRCRECEIVED)),
               COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE, V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE PBATCH = P_ID
           AND PID = RLPID
           AND RLID = RDID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        ELSE
          IF V_COUNT1 > V_COUNT2 THEN
            SELECT PTRANS
              INTO V_TRNAS
              FROM PAYMENT T
             WHERE PBATCH = P_ID
               AND PTRANS <> 'S'
               AND ROWNUM = 1;
          ELSE
            V_TRNAS := 'S';
          END IF;
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          ID.IDID        := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
          ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
          ID.ISPRINTPIID := NULL; -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_RLID_MX(P_ID);
          LOOP
            FETCH C_PBATCH_RLID_MX
              INTO RL;
            EXIT WHEN C_PBATCH_RLID_MX%NOTFOUND OR C_PBATCH_RLID_MX%NOTFOUND IS NULL;
            NULL;
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_RLID_MX;
        
        END IF;
        --��
      
      ELSIF P_IFFPHP = 'F' THEN
        --�ж��Ƿ�Ԥ��
        SELECT COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����Ԥ��
        V_ISPRINTJE01 := 0;
        IF V_COUNT2 = 1 AND V_COUNT1 = 1 THEN
          I      := I + 1;
          V_ISID := FGETINVNO_FROMTEMP(I);
          /* v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
          SELECT * INTO PM FROM PAYMENT T WHERE T.PBATCH = P_ID;
          V_ISPRINTJE := PM.PPAYMENT - PM.PCHANGE;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
          RECINVNO('2', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   PM.PID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   PM.PCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
          ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
          ID.ISPRINTPIID := NULL; -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
          --��ˮ��
          BEGIN
            SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
              INTO V_INVCOUNT, PM.PTRANS
              FROM PAYMENT T, RECLIST T1
             WHERE PBATCH = P_ID
               AND PID = RLPID;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        
          V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                          P_ILTYPE, --��Ʊ����
                                          V_INVCOUNT, --Ҫȡ��Ʊ����
                                          P_SNO);
          IF V_INVCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
          
          END IF;
          IF V_INVRETCOUNT < V_INVCOUNT THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                    V_INVRETCOUNT || '��');
          
          END IF;
          I := 0;
        
          V_ISPRINTJE01 := 0;
        
          OPEN C_PBATCH_PLID_MX(P_ID);
          LOOP
            FETCH C_PBATCH_PLID_MX
              INTO RL;
            EXIT WHEN C_PBATCH_PLID_MX%NOTFOUND OR C_PBATCH_PLID_MX%NOTFOUND IS NULL;
            V_ISPRINTJE01 := 0;
            I             := I + 1;
          
            V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
             ;
          
            --����ˮ�ѽ��  (��ֵ˰�û�)
            SELECT SUM(CASE
                         WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                          RDJE
                         ELSE
                          0
                       END)
              INTO V_ISPRINTJE01
              FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
             WHERE RLID = RDID
               AND RLID = RL.RLID
               AND PID = RLPID
               AND PMID = MIID;
          
            V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
          
            V_ISID := FGETINVNO_FROMTEMP(I);
            /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
            p_iltype --��Ʊ����
            );*/
            IF V_ISID IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
            END IF;
          
            IF V_ISPRINTJE01 <> 0 THEN
              V_ISZZS := 'Y';
            ELSE
              V_ISZZS := 'N';
            END IF;
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            RECINVNO('6', --��ӡ��ʽ
                     V_ISID || '|', --Ʊ�ݺ���(###|###|)
                     RL.RLID || '|', --Ӧ����ˮ(###|###|)
                     V_RDPIIDSTR || '|', --������Ŀ(###|###|)
                     V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                     P_ILTYPE, --Ʊ������
                     RL.RLCD, --�������
                     P_PRINTER, --��Ʊ��
                     P_ILSTATUS, --Ʊ��״̬
                     P_ILSMFID, --�ֹ�˾
                     PM.PTRANS,
                     V_ISZZS);
            ID.IDID      := V_ISID; -- Ʊ����ˮ��
            ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
          
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_PLID_MX;
        
        END IF;
      
      ELSIF P_IFFPHP = 'G' THEN
        --�ж��Ƿ�Ԥ��
      
        --����Ԥ��
      
        V_ISPRINTJE01 := 0;
        --��ˮ��
        BEGIN
          SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
            INTO V_INVCOUNT, PM.PTRANS
            FROM (SELECT MAX(RLMRID) RLMRID, MAX(PTRANS) PTRANS
                    FROM PAYMENT T, RECLIST T1
                   WHERE PBATCH = P_ID
                     AND T1.RLGROUP <> '2'
                     AND PID = RLPID
                   GROUP BY RLMRID);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I             := 0;
        V_ISPRINTJE01 := 0;
        OPEN C_PBATCH_MRID_MX_SF(P_ID);
        LOOP
          FETCH C_PBATCH_MRID_MX_SF
            INTO /*rl.RLPAIDJE , rl.RLMRID, rl.rlcd  ;*/ RL.RLPAIDJE,
                 RL.RLMRID,
                 RL.RLCD;
          EXIT WHEN C_PBATCH_MRID_MX_SF%NOTFOUND OR C_PBATCH_MRID_MX_SF%NOTFOUND IS NULL;
          V_ISPRINTJE01 := 0;
          I             := I + 1;
        
          V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
           ;
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE RLID = RDID
             AND RLREVERSEFLAG = 'N'
             AND RLMRID = RL.RLMRID
             AND RLGROUP <> '2'
             AND PID = RLPID
             AND PMID = MIID;
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
          /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   RL.RLMRID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   RL.RLCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_MRID_MX_SF_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_SF_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_SF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_SF_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- ��Ӧ��ˮ��
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RLONE.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PBATCH_MRID_MX_SF_ONE;
        
          UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RLONE.RLID;
        END LOOP;
        CLOSE C_PBATCH_MRID_MX_SF;
        ----STRAT@@@@@@@@@@@@@@@@@@@@@@@@@22222
      
        --�ж��Ƿ�Ԥ��
        --����Ԥ��
        V_ISPRINTJE01 := 0;
        --��ˮ��
        BEGIN
          SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
            INTO V_INVCOUNT, PM.PTRANS
            FROM (SELECT MAX(RLMRID) RLMRID, MAX(PTRANS) PTRANS
                    FROM PAYMENT T, RECLIST T1
                   WHERE PBATCH = P_ID
                     AND T1.RLGROUP = '2'
                     AND PID = RLPID
                   GROUP BY RLMRID);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        'W', --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I             := 0;
        V_ISPRINTJE01 := 0;
        OPEN C_PBATCH_MRID_MX_WSF(P_ID);
        LOOP
          FETCH C_PBATCH_MRID_MX_WSF
            INTO /*rl.RLPAIDJE , rl.RLMRID, rl.rlcd  ;*/ RL.RLPAIDJE,
                 RL.RLMRID,
                 RL.RLCD;
          EXIT WHEN C_PBATCH_MRID_MX_WSF%NOTFOUND OR C_PBATCH_MRID_MX_WSF%NOTFOUND IS NULL;
          V_ISPRINTJE01 := 0;
          I             := I + 1;
        
          V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
           ;
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE RLID = RDID
             AND RLREVERSEFLAG = 'N'
             AND RLMRID = RL.RLMRID
             AND RLGROUP = '2'
             AND PID = RLPID
             AND PMID = MIID;
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
          /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   RL.RLMRID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   'W', --Ʊ������
                   RL.RLCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_MRID_MX_WSF_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_WSF_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- ��Ӧ��ˮ��
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RLONE.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PBATCH_MRID_MX_WSF_ONE;
        
          UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RLONE.RLID;
        END LOOP;
        CLOSE C_PBATCH_MRID_MX_WSF;
        ----END@@@@@@@@@@@@@@@@@@@@@@@@@22222
      ELSIF P_IFFPHP = 'I' THEN
        --�ж��Ƿ�Ԥ��
        --����Ԥ��
        V_ISPRINTJE01 := 0;
        --��ˮ��
        BEGIN
          SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
            INTO V_INVCOUNT, PM.PTRANS
            FROM (SELECT MAX(RLMRID) RLMRID, MAX(PTRANS) PTRANS
                    FROM PAYMENT T, RECLIST T1
                   WHERE PBATCH = P_ID
                     AND PID = RLPID
                   GROUP BY RLMRID);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I             := 0;
        V_ISPRINTJE01 := 0;
        OPEN C_PBATCH_MRID_MX(P_ID);
        LOOP
          FETCH C_PBATCH_MRID_MX
            INTO /*rl.RLPAIDJE , rl.RLMRID, rl.rlcd  ;*/ RL.RLPAIDJE,
                 RL.RLMRID,
                 RL.RLCD;
          EXIT WHEN C_PBATCH_MRID_MX%NOTFOUND OR C_PBATCH_MRID_MX%NOTFOUND IS NULL;
          V_ISPRINTJE01 := 0;
          I             := I + 1;
        
          V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
           ;
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE RLID = RDID
             AND RLREVERSEFLAG = 'N'
             AND RLMRID = RL.RLMRID
             AND PID = RLPID
             AND PMID = MIID;
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
          /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   RL.RLMRID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   RL.RLCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_MRID_MX_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_ONE%NOTFOUND OR C_PBATCH_MRID_MX_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- ��Ӧ��ˮ��
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RLONE.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PBATCH_MRID_MX_ONE;
        
          UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
        END LOOP;
        CLOSE C_PBATCH_MRID_MX;
      
      ELSIF P_IFFPHP = 'Z' THEN
      
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM (SELECT PID, PBATCH
                  FROM PAYMENT T, RECLIST T1
                 WHERE T.PID = T1.RLPID
                   AND PTRANS <> 'S'
                   AND PBATCH = P_ID
                   AND (RLGROUP <> '2' OR RLGROUP IS NULL)
                 GROUP BY PID, PBATCH);
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        OPEN C_PBATCH_PID_SF_MX(P_ID);
        LOOP
          FETCH C_PBATCH_PID_SF_MX
            INTO PM;
          EXIT WHEN C_PBATCH_PID_SF_MX%NOTFOUND OR C_PBATCH_PID_SF_MX%NOTFOUND IS NULL;
          I := I + 1;
          --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PM.PMID;
        
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = PM.PID
             AND PID = RLPID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = PM.PID
             AND PID = RLPID
             AND PMID = MIID
             AND RLID = RDID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
          V_ISID      := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
          RECINVNO('2', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   PM.PID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   PM.PCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_PID_SF_MX_ONE(PM.PID);
          LOOP
            FETCH C_PBATCH_PID_SF_MX_ONE
              INTO RL;
            EXIT WHEN C_PBATCH_PID_SF_MX_ONE%NOTFOUND OR C_PBATCH_PID_SF_MX_ONE%NOTFOUND IS NULL;
            NULL;
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_PID_SF_MX_ONE;
        
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        END LOOP;
        CLOSE C_PBATCH_PID_SF_MX;
      
        --------------------------
      
        --��ˮ
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM (SELECT PID, PBATCH
                  FROM PAYMENT T, RECLIST T1
                 WHERE T.PID = T1.RLPID
                   AND PTRANS <> 'S'
                   AND PBATCH = P_ID
                   AND RLGROUP = '2'
                 GROUP BY PID, PBATCH);
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        'W', --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        OPEN C_PBATCH_PID_WSF_MX(P_ID);
        LOOP
          FETCH C_PBATCH_PID_WSF_MX
            INTO PM;
          EXIT WHEN C_PBATCH_PID_WSF_MX%NOTFOUND OR C_PBATCH_PID_WSF_MX%NOTFOUND IS NULL;
          I := I + 1;
          --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PM.PMID;
        
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = PM.PID
             AND PID = RLPID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = PM.PID
             AND PID = RLPID
             AND PMID = MIID
             AND RLID = RDID
             AND RLGROUP = '2';
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
          V_ISID      := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
          RECINVNO('2', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   PM.PID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   'W', --Ʊ������
                   PM.PCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          OPEN C_PBATCH_PID_WSF_MX_ONE(PM.PID);
          LOOP
            FETCH C_PBATCH_PID_WSF_MX_ONE
              INTO RL;
            EXIT WHEN C_PBATCH_PID_WSF_MX_ONE%NOTFOUND OR C_PBATCH_PID_WSF_MX_ONE%NOTFOUND IS NULL;
            NULL;
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RL.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
          
            ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_PID_WSF_MX_ONE;
        
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        END LOOP;
        CLOSE C_PBATCH_PID_WSF_MX;
      
        --------------------------
      
      ELSIF P_IFFPHP = 'Zbak' THEN
      
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM PAYMENT T
         WHERE PTRANS <> 'S'
           AND PBATCH = P_ID;
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        V_ISID      := FGETINVNO_FROMTEMP(1);
      
        --�����м�����
        SP_PRINTINV_OCX(P_ID, 'Z');
        V_ISID := FGETINVNO_FROMTEMP(1);
      
        OPEN C_PBATCH_PID_MX;
        LOOP
          FETCH C_PBATCH_PID_MX
            INTO PPT;
          EXIT WHEN C_PBATCH_PID_MX%NOTFOUND OR C_PBATCH_PID_MX%NOTFOUND IS NULL;
          I := I + 1;
          --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PPT.C1;
        
          V_ISPRINTJE := PPT.C10;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          SELECT PID, PCD, PTRANS
            INTO PM.PID, PM.PCD, PM.PTRANS
            FROM PAYMENT T
           WHERE T.PMID = PPT.C1
             AND T.PBATCH = PPT.C5
             AND T.PTRANS <> 'S';
        
          RECINVNO('2', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   PM.PID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   PM.PCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   PM.PTRANS,
                   V_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_PID_MX;
      
        --------------------------
      
      END IF;
    END IF;
    ----������ʵ����ˮ��ӡ payment.pid ֻ��Ԥ��
    IF P_ISPRINTTYPE = '2' THEN
      V_ISPRINTJE01 := 0;
      SELECT SUM((T.PPAYMENT - T.PCHANGE))
        INTO V_ISPRINTJE
        FROM PAYMENT T
       WHERE PID = P_ID;
    
      V_ISID := FGETINVNO(P_PRINTER, --����Ա
                          P_ILTYPE, --��Ʊ����
                          P_SNO);
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      
      ELSE
      
        V_ISZZS := 'N';
      
      END IF;
    
      RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               P_ID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               P_ISPRINTCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               'S',
               V_ISZZS);
    
    END IF;
    ----������ʵ����ϸ��ˮ��ӡ paidlist.plid --��PLID��ӡ��ϸƱ
    IF P_ISPRINTTYPE = '3' THEN
      OPEN C_PBATCH_PLID_MX_ONE(P_ID);
      LOOP
        FETCH C_PBATCH_PLID_MX_ONE
          INTO RL;
        EXIT WHEN C_PBATCH_PLID_MX_ONE%NOTFOUND OR C_PBATCH_PLID_MX_ONE%NOTFOUND IS NULL;
      
        V_ISPRINTJE01 := 0;
      
        SELECT PTRANS
          INTO PM.PTRANS
          FROM PAYMENT, RECLIST
         WHERE PID = RLPID
           AND RLID = RL.RLID;
        V_ISPRINTJE := RL.RLJE + RL.RLZNJ + RL.RLSAVINGBQ;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE RLID = RL.RLID
           AND RLID = RDID
           AND PID = RLPID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO('3', --��ӡ��ʽ
                 V_ISID || '|', --Ʊ�ݺ���(###|###|)
                 RL.RLID || '|', --Ӧ����ˮ(###|###|)
                 '' || '|', --������Ŀ(###|###|)
                 V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                 P_ILTYPE, --Ʊ������
                 RL.RLCD, --�������
                 P_PRINTER, --��Ʊ��
                 P_ILSTATUS, --Ʊ��״̬
                 P_ILSMFID, --�ֹ�˾
                 PM.PTRANS,
                 V_ISZZS);
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    END IF;
  
    --5:Ӧ����ˮrlid  �ṹ ###,###|###,###|###,###|
    --6:ʵ����ϸ rdid+rdpiid  �ṹ ###,01/02/03|###,01/02/03|###,01/02/03|
    IF P_ISPRINTTYPE = '5' THEN
      --v_invcount    number(10);
      --v_invretcount number(10);
      --���
      --��ӡԱ��Ʊ��
    
      --��Ʊ/��Ʊ
      IF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*) INTO V_INVCOUNT FROM PBPARMTEMP;
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '###û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                        P_ILTYPE, --��Ʊ����
                                        V_INVCOUNT, --Ҫȡ��Ʊ����
                                        P_SNO);
      
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        IF V_INVCOUNT > V_INVRETCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                  V_INVRETCOUNT || '��');
        END IF;
      
        I := 0;
        OPEN C_RLID_PBPARMTEMP;
        LOOP
          FETCH C_RLID_PBPARMTEMP
            INTO PPT;
          EXIT WHEN C_RLID_PBPARMTEMP%NOTFOUND OR C_RLID_PBPARMTEMP%NOTFOUND IS NULL;
        
          V_ISPRINTJE01 := 0;
        
          V_ISPRINTJE01 := 0;
          I             := I + 1;
        
          V_ISPRINTJE := TO_NUMBER(PPT.C6);
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, METERINFO T4
           WHERE RLID = RDID
             AND MIID = RLMID
             AND RLID = TRIM(PPT.C5);
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
          /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
          p_iltype --��Ʊ����
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          
          ELSE
          
            V_ISZZS := 'N';
          
          END IF;
        
          RECINVNO('5', --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   TRIM(PPT.C5) || '|', --Ӧ����ˮ(###|###|)
                   TRIM(PPT.C8) || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   'T',
                   V_ISZZS);
        
        END LOOP;
        CLOSE C_RLID_PBPARMTEMP;
      
      ELSIF P_IFFPHP = 'H' THEN
        SELECT SUM(TO_NUMBER(C7)),
               CONNSTR(C5),
               CONNSTR(C5 || ',' || REPLACE(C8, '/', '#'))
          INTO V_ISPRINTJE, V_RLIDSTR, V_RDPIIDSTR
          FROM PBPARMTEMP;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        BEGIN
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, METERINFO T4, PBPARMTEMP T5
           WHERE RLID = RDID
             AND RLMID = MIID
             AND RLID = TRIM(T5.C5);
        EXCEPTION
          WHEN OTHERS THEN
            V_ISPRINTJE01 := 0;
        END;
        -- raise_application_error(errcode, v_isprintje01 );
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��ʼ��Ʊ��
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
      
        RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                 V_ISID || '|', --Ʊ�ݺ���(###|###|)
                 V_RLIDSTR || '|', --Ӧ����ˮ(###|###|)
                 V_RDPIIDSTR || '|', --������Ŀ(###|###|)
                 V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                 P_ILTYPE, --Ʊ������
                 P_ISPRINTCD, --�������
                 P_PRINTER, --��Ʊ��
                 P_ILSTATUS, --Ʊ��״̬
                 P_ILSMFID, --�ֹ�˾
                 'T',
                 V_ISZZS);
      END IF;
    
    END IF;
  
    IF P_ISPRINTTYPE = '6' THEN
      OPEN C_PBATCH_PLID_MX_ONE(P_ID);
      LOOP
        FETCH C_PBATCH_PLID_MX_ONE
          INTO RL;
        EXIT WHEN C_PBATCH_PLID_MX_ONE%NOTFOUND OR C_PBATCH_PLID_MX_ONE%NOTFOUND IS NULL;
      
        V_ISPRINTJE01 := 0;
      
        SELECT PTRANS
          INTO PM.PTRANS
          FROM PAYMENT, RECLIST
         WHERE PID = RLPID
           AND RLID = RL.RLID;
        V_ISPRINTJE := RL.RLJE + RL.RLZNJ + RL.RLSAVINGBQ;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T,
               RECLIST   T1,
               
               PAYMENT   T3,
               METERINFO T4
         WHERE RLID = RDID
           AND PID = RLPID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��ʼ��Ʊ��
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RL.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
      
        RECINVNO('6', --��ӡ��ʽ
                 V_ISID || '|', --Ʊ�ݺ���(###|###|)
                 RL.RLID || '|', --Ӧ����ˮ(###|###|)
                 '' || '|', --������Ŀ(###|###|)
                 V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                 P_ILTYPE, --Ʊ������
                 RL.RLCD, --�������
                 P_PRINTER, --��Ʊ��
                 P_ILSTATUS, --Ʊ��״̬
                 P_ILSMFID, --�ֹ�˾
                 PM.PTRANS,
                 V_ISZZS);
      
        ID.IDID      := V_ISID; -- Ʊ����ˮ��
        ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
      
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RL.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
        UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    
      /*    i := 0;
      
                v_isprintje01 :=0 ;
      
      
                  OPEN C_PBATCH_plid_MX(p_id);
                  LOOP
                    FETCH C_PBATCH_plid_MX
                      INTO rl;
                    EXIT WHen C_PBATCH_plid_MX%NOTFOUND OR C_PBATCH_plid_MX%NOTFOUND IS NULL;
                    v_isprintje01 :=0 ;
                    i := i + 1;
      
                    v_isprintje := rl.RLPAIDJE\* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*\;
      
                    --����ˮ�ѽ��  (��ֵ˰�û�)
                    select sum(CASE
                                 WHEN MIIFTAX = 'Y' AND rdpiid = '01' THEN
                                  rdje
                                 ELSE
                                  0
                               END)
                      into v_isprintje01
                      from recdetail  t,
                           reclist   t1,
                           payment    t3,
                           meterinfo  t4
                     where  rlid = rdid
                       AND RLID=RL.RLID
                       and pid = rlpid
                       and pmid = miid;
      
                    v_isprintje := v_isprintje - v_isprintje01;
      
                    v_isid := fgetinvno_fromtemp(i);
                    \*v_ilno      := fgetinvno(P_PRINTER, --����Ա
                    p_iltype --��Ʊ����
                    );*\
                    IF v_isid is null THEN
                      raise_application_error(errcode, '��Ʊ�����꣬����ȡ��Ʊ');
                    END IF;
      
                    if v_isprintje01<>0 THEN
                     v_ISZZS :='Y' ;
                    ELSE
                       v_ISZZS :='N' ;
                    END IF;
      
                   SELECT  connstr( RDPIID) into v_rdpiidstr FROM (
                    select  DISTINCT  RDPIID FROM   recdetail t where
                    rdid=rl.rlid
                    and ( v_ISZZS='N' OR  (v_ISZZS='Y' AND RDPIID<>'01') )
                    );
      
                    recinvno('6', --��ӡ��ʽ
                                v_isid || '|', --Ʊ�ݺ���(###|###|)
                                rl.rlid || '|', --Ӧ����ˮ(###|###|)
                                v_rdpiidstr || '|', --������Ŀ(###|###|)
                                v_isprintje || '|', --Ʊ�ݽ��(###|###|)
                                p_iltype, --Ʊ������
                                rl.rlcd, --�������
                                P_PRINTER, --��Ʊ��
                                p_ilstatus, --Ʊ��״̬
                                p_ilsmfid, --�ֹ�˾
                                pm.ptrans,
                                v_ISZZS);
                    id.idid  :=v_isid ;-- Ʊ����ˮ��
                    id.idtype   :='01' ;-- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
                    id.idprintid   :=rl.rlid ;-- ��Ӧ��ˮ��
      
                  for i IN 1..tools.fmidn(v_rdpiidstr,'/')
                    loop
                      id.isprintpiid   :=tools.fmid(v_rdpiidstr,I,'N','/')   ;-- ������Ŀ
                    insert into invstockdetail values id;
                    update recdetail t set t.rdilid =v_isid
                    where rdid=rl.rlid and rdpiid=id.isprintpiid;
                  END LOOP;
                  update reclist t set t.rlilid = v_isid
                  where rlid=rl.rlid;
                  END LOOP;
                  CLOSE C_PBATCH_plid_MX;
      */
    END IF;
  
    IF P_ISPRINTTYPE = '7' THEN
      OPEN C_PBATCH_MRID_MX_ONE(P_ID);
      LOOP
        FETCH C_PBATCH_MRID_MX_ONE
          INTO RL;
        EXIT WHEN C_PBATCH_MRID_MX_ONE%NOTFOUND OR C_PBATCH_MRID_MX_ONE%NOTFOUND IS NULL;
      
        V_ISPRINTJE01 := 0;
      
        SELECT PTRANS
          INTO PM.PTRANS
          FROM PAYMENT, RECLIST
         WHERE PID = RLPID
           AND RLID = RL.RLID;
        V_ISPRINTJE := RL.RLJE + RL.RLZNJ + RL.RLSAVINGBQ;
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T,
               RECLIST   T1,
               
               PAYMENT   T3,
               METERINFO T4
         WHERE RLID = RDID
           AND PID = RLPID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��ʼ��Ʊ��
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RL.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
      
        RECINVNO('7', --��ӡ��ʽ
                 V_ISID || '|', --Ʊ�ݺ���(###|###|)
                 RL.RLID || '|', --Ӧ����ˮ(###|###|)
                 '' || '|', --������Ŀ(###|###|)
                 V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                 P_ILTYPE, --Ʊ������
                 RL.RLCD, --�������
                 P_PRINTER, --��Ʊ��
                 P_ILSTATUS, --Ʊ��״̬
                 P_ILSMFID, --�ֹ�˾
                 PM.PTRANS,
                 V_ISZZS);
      
        ID.IDID      := V_ISID; -- Ʊ����ˮ��
        ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
      
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RL.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
        UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
      END LOOP;
      CLOSE C_PBATCH_MRID_MX_ONE;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PBATCH_MX%ISOPEN THEN
        CLOSE C_PBATCH_MX;
      END IF;
      IF C_PBATCH_PLID_MX%ISOPEN THEN
        CLOSE C_PBATCH_PLID_MX;
      END IF;
      IF C_PBATCH_PLID_MX_ONE%ISOPEN THEN
        CLOSE C_PBATCH_PLID_MX_ONE;
      END IF;
      IF C_PBATCH_MRID_MX_ONE%ISOPEN THEN
        CLOSE C_PBATCH_MRID_MX_ONE;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_H_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                ) IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
    --
    V_PMCODE VARCHAR2(10);
    V_XZJE   NUMBER(13, 3);
    V_SFJE   NUMBER(13, 3);
    V_PWJE   NUMBER(13, 3);
    V_LJFJE  NUMBER(13, 3);
  
    CURSOR C_PBATCH_RLID_SF_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
       ORDER BY PID || RLID;
  
  BEGIN
    V_ISPRINTJE01 := 0;
    --���������δ�ӡ payment.pbatch
    IF P_ISPRINTTYPE = '1' THEN
      IF P_IFFPHP = 'H' THEN
        SELECT SUM((PPAYMENT - PCHANGE)),
               COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE, V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE PBATCH = P_ID
           AND PID = RLPID
           AND RLID = RDID
           AND PMID = MIID;
      
        V_ISPRINTJE := NVL(V_ISPRINTJE, 0) - NVL(V_ISPRINTJE01, 0);
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        ELSE
          IF V_COUNT1 > V_COUNT2 THEN
            SELECT PTRANS
              INTO V_TRNAS
              FROM PAYMENT T
             WHERE PBATCH = P_ID
               AND PTRANS <> 'S'
               AND ROWNUM = 1;
          ELSE
            V_TRNAS := 'S';
          END IF;
        END IF;
      
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��Ʊ��ˮ
                            );
      
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
        
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          INSERT INTO PBPARMTEMP
            (C1, C2, C3, C4, C5, C6, C7, C8)
          VALUES
            (V_ISID, P_ID, PM.PMCODE, V_ISPRINTJE, 0, 0, 0, 0);
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
          ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
          ID.ISPRINTPIID := NULL; -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
        
          SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
        
          UPDATE PAYMENT T
             SET T.PILID = IN_STOCK.ISPCISNO
           WHERE PID = PM.PID;
        
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --�տ���
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND RLID = RDID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          SELECT MAX(PMCODE) PMCODE,
                 SUM(RLJE),
                 SUM(DECODE(RLGROUP, 1, RLJE, 0)) SFJE,
                 0 PWF,
                 SUM(DECODE(RLGROUP, 3, RLJE, 0)) LJFJE
            INTO V_PMCODE, V_XZJE, V_SFJE, V_PWJE, V_LJFJE
            FROM RECLIST T1, PAYMENT T3
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL)
           GROUP BY PID;
        
          --
          INSERT INTO PBPARMTEMP
            (C1, C2, C3, C4, C5, C6, C7, C8)
          VALUES
            (V_ISID,
             P_ID,
             V_PMCODE,
             V_ISPRINTJE,
             V_XZJE,
             V_SFJE,
             V_PWJE,
             V_LJFJE);
        
          --ȡ�����־�������Ϣ
          SELECT PM.PTRANS
            INTO V_TRNAS
            FROM PAYMENT T
           WHERE T.PBATCH = P_ID
             AND ROWNUM = 1;
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          SELECT * INTO IN_STOCK FROM INVSTOCK ISK WHERE ISK.ISID = V_ISID;
        
          UPDATE RECLIST RL
             SET RL.RLILID = IN_STOCK.ISPCISNO
           WHERE RL.RLID IN
                 (SELECT RLID
                    FROM RECLIST RL, PAYMENT PM
                   WHERE PM.PBATCH = P_ID
                     AND PM.PID = RL.RLPID
                     AND (RLGROUP <> '2' OR RLGROUP IS NULL))
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
        END IF;
      END IF;
    
    END IF;
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      IF C_PBATCH_RLID_SF_MX%ISOPEN THEN
        CLOSE C_PBATCH_RLID_SF_MX;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_H_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --Ʊ����ˮ
                                 )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
    --
    V_PMCODE VARCHAR2(10);
    V_XZJE   NUMBER(13, 3);
    V_SFJE   NUMBER(13, 3);
    V_PWJE   NUMBER(13, 3);
    V_LJFJE  NUMBER(13, 3);
  
    CURSOR C_PBATCH_RLID_WSF_MX(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PBATCH = AS_PID
         AND RLGROUP = 2
       ORDER BY PID || RLID;
  
  BEGIN
    V_ISPRINTJE01 := 0;
    --���������δ�ӡ payment.pbatch
    IF P_ISPRINTTYPE = '1' THEN
      IF P_IFFPHP = 'H' THEN
        SELECT SUM((PPAYMENT - PCHANGE)),
               COUNT(*),
               SUM(CASE
                     WHEN PTRANS = 'S' THEN
                      1
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE, V_COUNT1, V_COUNT2
          FROM PAYMENT T
         WHERE PBATCH = P_ID;
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE PBATCH = P_ID
           AND PID = RLPID
           AND RLID = RDID
           AND PMID = MIID;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        IF V_COUNT1 < 1 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
        ELSE
          IF V_COUNT1 > V_COUNT2 THEN
            SELECT PTRANS
              INTO V_TRNAS
              FROM PAYMENT T
             WHERE PBATCH = P_ID
               AND PTRANS <> 'S'
               AND ROWNUM = 1;
          ELSE
            V_TRNAS := 'S';
          END IF;
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --����Ա
                            P_ILTYPE, --��Ʊ����
                            P_SNO --��Ʊ����
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
        
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          INSERT INTO PBPARMTEMP
            (C1, C2, C3, C4, C5, C6, C7, C8)
          VALUES
            (V_ISID, P_ID, PM.PMCODE, V_ISPRINTJE, 0, 0, 0, 0);
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   P_ILTYPE, --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
          ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
          ID.ISPRINTPIID := NULL; -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
        
          SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
        
          UPDATE PAYMENT T
             SET T.PILID = IN_STOCK.ISPCISNO
           WHERE PID = PM.PID;
        
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --��ˮ��
        
          V_ISID := FGETINVNO(P_PRINTER, --����Ա
                              'W', --��Ʊ����
                              P_SNO --��ʼ��Ʊ��
                              );
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
          END IF;
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --�տ���
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          --����ˮ�ѽ��  (��ֵ˰�û�)
          SELECT SUM(CASE
                       WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                        RDJE
                       ELSE
                        0
                     END)
            INTO V_ISPRINTJE01
            FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND RLID = RDID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
        
          --
          SELECT MAX(PMCODE) PMCODE,
                 SUM(RLJE),
                 SUM(0) SFJE,
                 SUM(DECODE(RLGROUP, 2, RLJE, 0)) PWF,
                 SUM(0) LJFJE
            INTO V_PMCODE, V_XZJE, V_SFJE, V_PWJE, V_LJFJE
            FROM RECLIST T1, PAYMENT T3
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND RLGROUP = '2'
           GROUP BY PID;
        
          --
          INSERT INTO PBPARMTEMP
            (C1, C2, C3, C4, C5, C6, C7, C8)
          VALUES
            (V_ISID,
             P_ID,
             V_PMCODE,
             V_ISPRINTJE,
             V_XZJE,
             V_SFJE,
             V_PWJE,
             V_LJFJE);
        
          --ȡ�����־�������Ϣ
          SELECT PM.PTRANS
            INTO V_TRNAS
            FROM PAYMENT T
           WHERE T.PBATCH = P_ID
             AND ROWNUM = 1;
        
          RECINVNO(P_ISPRINTTYPE, --��ӡ��ʽ
                   V_ISID || '|', --Ʊ�ݺ���(###|###|)
                   P_ID || '|', --Ӧ����ˮ(###|###|)
                   '' || '|', --������Ŀ(###|###|)
                   V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                   'W', --Ʊ������
                   P_ISPRINTCD, --�������
                   P_PRINTER, --��Ʊ��
                   P_ILSTATUS, --Ʊ��״̬
                   P_ILSMFID, --�ֹ�˾
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- Ʊ����ˮ��
          ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        
          ---
          SELECT * INTO IN_STOCK FROM INVSTOCK ISK WHERE ISK.ISID = V_ISID;
        
          UPDATE RECLIST RL
             SET RL.RLILID = IN_STOCK.ISPCISNO
           WHERE RL.RLID IN (SELECT RLID
                               FROM RECLIST RL, PAYMENT PM
                              WHERE PM.PBATCH = P_ID
                                AND PM.PID = RL.RLPID
                                AND RLGROUP = '2')
             AND RLGROUP = '2'
             AND RL.RLREVERSEFLAG = 'N';
        
          /* open C_PBATCH_RLID_WSF_MX(p_id);
          loop
            fetch C_PBATCH_RLID_WSF_MX
              into rl;
            EXIT WHen C_PBATCH_RLID_WSF_MX%NOTFOUND OR C_PBATCH_RLID_WSF_MX%NOTFOUND IS NULL;
            NULL;
            SELECT connstr(RDPIID)
              into v_rdpiidstr
              FROM (select DISTINCT RDPIID
                      FROM recdetail t
                     where rdid = rl.rlid
                       and (v_ISZZS = 'N' OR
                           (v_ISZZS = 'Y' AND RDPIID <> '01')));
          
            id.idprintid := rl.rlid; -- ��Ӧ��ˮ��
            for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
              id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- ������Ŀ
              insert into invstockdetail values id;
              update recdetail t
                 set t.rdilid = v_isid
               where rdid = rl.rlid
                 and rdpiid = id.isprintpiid;
            END LOOP;
            update reclist t set t.rlilid = v_isid where rlid = rl.rlid;
          end loop;
          close C_PBATCH_RLID_WSF_MX;*/
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_RLID_WSF_MX%ISOPEN THEN
        CLOSE C_PBATCH_RLID_WSF_MX;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER --Ʊ����ˮ
                             )
  
   IS
    I             NUMBER(10);
    J             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
  
    V_RLIDSTR   VARCHAR2(4000);
    V_RDPIIDSTR VARCHAR2(4000);
    V_ISZZS     VARCHAR(10);
  
    --һ�׸�ֵ������
    V_MRID  RECLIST.RLMRID%TYPE;
    V_MCODE RECLIST.RLMCODE%TYPE;
    V_PJE   INVSTOCK.ISPRINTJE%TYPE;
    V_ISJE1 INVSTOCK.ISJE1%TYPE;
    V_ISJE2 INVSTOCK.ISJE2%TYPE;
    V_ISJE3 INVSTOCK.ISJE1%TYPE;
    V_ISJE4 INVSTOCK.ISJE2%TYPE;
  
    CURSOR C_PBATCH_RL_MX(AS_PBATCH VARCHAR2, P_ILTYPE VARCHAR2) IS
      SELECT T.RLMRID,
             T.RLMCODE,
             NVL(DECODE(P_ILTYPE, 'S', SUM(T.RLPAIDJE), 'W', 0), 0) PLJE,
             
             NVL(DECODE(P_ILTYPE,
                        'S',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'W',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) RLJE,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 1, RLJE, 0))),
                 0) SFJE,
             
             NVL(DECODE(P_ILTYPE, 'W', SUM(DECODE(T.RLGROUP, 2, RLJE, 0))),
                 0) PSF,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 3, RLJE, 0))),
                 0) LJF
      
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND T1.PBATCH = AS_PBATCH
         AND T.RLMIEMAILFLAG = DECODE(P_ILTYPE, 'S', 'S', 'W')
       GROUP BY T.RLMRID, T.RLMCODE
       ORDER BY T.RLMRID, T.RLMCODE;
  
    /* CURSOR C_PBATCH_rl_new(as_pBATCH VARCHAR2,v_mrid varchar2 ) IS
    
    SELECT t.*
       FROM reclist t, payment t1
      WHERE pid = rlpid
        and t1.pbatch = as_pBATCH
        and t.rlmrid=v_mrid ;*/
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --�ж��Ƿ�Ԥ��
    SELECT COUNT(*),
           SUM(CASE
                 WHEN PTRANS = 'S' THEN
                  1
                 ELSE
                  0
               END)
      INTO V_COUNT1, V_COUNT2
      FROM PAYMENT T
     WHERE PBATCH = P_ID;
    --����Ԥ��
    V_ISPRINTJE01 := 0;
    J             := 0;
    IF V_COUNT2 = 1 AND V_COUNT1 = 1 THEN
    
      J      := J + 1;
      V_ISID := FGETINVNO_FROMTEMP(J);
      /* v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      SELECT * INTO PM FROM PAYMENT T WHERE T.PBATCH = P_ID;
      V_ISPRINTJE := PM.PPAYMENT - PM.PCHANGE;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5, C6, C7, C8)
      VALUES
        (V_ISID, P_ID, PM.PMCODE, V_ISPRINTJE, 0, 0, 0, 0);
    
      RECINVNO('7', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               PM.PID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               PM.PCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID        := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE      := '05'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�05��Ԥ�棩
      ID.IDPRINTID   := PM.PID; -- ��Ӧ��ˮ��
      ID.ISPRINTPIID := NULL; -- ������Ŀ
    
      INSERT INTO INVSTOCKDETAIL VALUES ID;
    
      --
      SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
    
      UPDATE PAYMENT T
         SET T.PILID = IN_STOCK.ISPCISNO
      
       WHERE PID = PM.PID;
    ELSE
    
      --��ˮ��
      BEGIN
      
        IF P_ILTYPE = 'S' THEN
        
          SELECT COUNT(DISTINCT(RLMRID)), TRIM(TO_CHAR(MAX('T')))
            INTO V_INVCOUNT, RL.RLYSCHARGETYPE
            FROM PAYMENT T, RECLIST T1
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND T1.RLGROUP <> '2';
        
        ELSE
        
          SELECT COUNT(DISTINCT(RLMRID)), TRIM(TO_CHAR(MAX('T')))
            INTO V_INVCOUNT, RL.RLYSCHARGETYPE
            FROM PAYMENT T, RECLIST T1
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND T1.RLGROUP = '2';
        
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                      P_ILTYPE, --��Ʊ����
                                      V_INVCOUNT, --Ҫȡ��Ʊ����
                                      P_SNO --��Ʊ����
                                      );
      IF V_INVCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
      
      END IF;
      IF V_INVRETCOUNT < V_INVCOUNT THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                                V_INVRETCOUNT || '��');
      
      END IF;
      I := 0;
    
      V_ISPRINTJE01 := 0;
    
      OPEN C_PBATCH_RL_MX(P_ID, P_ILTYPE);
      LOOP
        FETCH C_PBATCH_RL_MX
          INTO V_MRID, V_MCODE, V_PJE, V_ISJE1, V_ISJE2, V_ISJE3, V_ISJE4;
        EXIT WHEN C_PBATCH_RL_MX%NOTFOUND OR C_PBATCH_RL_MX%NOTFOUND IS NULL;
        V_ISPRINTJE01 := 0;
        I             := I + 1;
      
        V_ISPRINTJE := V_PJE; /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
      
        --����ˮ�ѽ��  (��ֵ˰�û�)
        SELECT SUM(CASE
                     WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                      RDJE
                     ELSE
                      0
                   END)
          INTO V_ISPRINTJE01
          FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
         WHERE RLID = RDID
           AND RLMRID = V_MRID
           AND PID = RLPID
           AND PMID = MIID
         GROUP BY RLMRID, RLMCODE;
      
        V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      
        V_ISID := FGETINVNO_FROMTEMP(I);
        /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
        p_iltype --��Ʊ����
        );*/
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
        END IF;
      
        --ȡ�����־�������Ϣ
        SELECT *
          INTO PM
          FROM PAYMENT T
         WHERE T.PBATCH = P_ID
           AND ROWNUM = 1;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
      
        /*  SELECT connstr(RDPIID)
            into v_rdpiidstr
            FROM (select DISTINCT RDPIID
                    FROM recdetail t
                   where rdid = rl.rlid
                     and (v_ISZZS = 'N' OR (v_ISZZS = 'Y' AND RDPIID <> '01')));
        */
      
        INSERT INTO PBPARMTEMP
          (C1, C2, C3, C4, C5, C6, C7, C8)
        VALUES
          (V_ISID,
           V_MRID,
           V_MCODE,
           V_PJE,
           V_ISJE1,
           V_ISJE2,
           V_ISJE3,
           V_ISJE4);
      
        RECINVNO('7', --��ӡ��ʽ
                 V_ISID || '|', --Ʊ�ݺ���(###|###|)
                 V_MRID || '|', --������ˮ(###|###|)
                 '' || '|', --������Ŀ(###|###|)
                 V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
                 P_ILTYPE, --Ʊ������
                 'DE', --�������
                 P_PRINTER, --��Ʊ��
                 P_ILSTATUS, --Ʊ��״̬
                 P_ILSMFID, --�ֹ�˾
                 PM.PTRANS,
                 V_ISZZS);
        ID.IDID      := V_ISID; -- Ʊ����ˮ��
        ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
        ID.IDPRINTID := V_MRID; -- ��Ӧ��ˮ��
      
        /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
          id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- ������Ŀ
          insert into invstockdetail values id;
          update reclist  t
             set t.rlilid = v_isid
           where rlmrid = rl.rlmrid
            ;
        END LOOP;*/
      
        SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
      
        IF P_ILTYPE = 'S' THEN
          UPDATE RECLIST T
             SET T.RLILID = IN_STOCK.ISPCISNO
           WHERE RLMRID = V_MRID
             AND T.RLGROUP <> 2
             AND T.RLREVERSEFLAG = 'N';
        ELSE
          UPDATE RECLIST T
             SET T.RLILID = IN_STOCK.ISPCISNO
           WHERE RLMRID = V_MRID
             AND T.RLGROUP = 2
             AND T.RLREVERSEFLAG = 'N';
        END IF;
      
        --  update reclist t set t.rlilid = v_isid where rlmrid = rl.rlmrid;
      END LOOP;
      CLOSE C_PBATCH_RL_MX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_RL_MX%ISOPEN THEN
        CLOSE C_PBATCH_RL_MX;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --����
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F_TS(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                )
  
   IS
    I             NUMBER(10);
    J             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
  
    V_RLIDSTR   VARCHAR2(4000);
    V_RDPIIDSTR VARCHAR2(4000);
    V_ISZZS     VARCHAR(10);
  
    --һ�׸�ֵ������
    V_MRID  RECLIST.RLMRID%TYPE;
    V_MCODE RECLIST.RLMCODE%TYPE;
    V_PJE   INVSTOCK.ISPRINTJE%TYPE;
    V_ISJE1 INVSTOCK.ISJE1%TYPE;
    V_ISJE2 INVSTOCK.ISJE2%TYPE;
    V_ISJE3 INVSTOCK.ISJE1%TYPE;
    V_ISJE4 INVSTOCK.ISJE2%TYPE;
  
    CURSOR C_PBATCH_RL_MX(AS_PBATCH VARCHAR2, P_ILTYPE VARCHAR2) IS
      SELECT T.RLMRID,
             T.RLMCODE,
             NVL(DECODE(P_ILTYPE,
                        'T',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'U',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) PLJE,
             NVL(DECODE(P_ILTYPE,
                        'T',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'U',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) RLJE,
             
             NVL(DECODE(P_ILTYPE, 'T', SUM(DECODE(T.RLGROUP, 1, RLJE, 0))),
                 0) SFJE,
             
             NVL(DECODE(P_ILTYPE, 'U', SUM(DECODE(T.RLGROUP, 2, RLJE, 0))),
                 0) PSF,
             
             NVL(DECODE(P_ILTYPE, 'T', SUM(DECODE(T.RLGROUP, 3, RLJE, 0))),
                 0) LJF
      
        FROM RECLIST T
       WHERE T.RLMIEMAIL = AS_PBATCH
         AND T.RLMIEMAILFLAG = DECODE(P_ILTYPE, 'T', 'S', 'W')
      --and t.rlyschargetype='T'
       GROUP BY T.RLMRID, T.RLMCODE
      
       ORDER BY T.RLMRID, T.RLMCODE;
  
    /* CURSOR C_PBATCH_rl_new(as_pBATCH VARCHAR2,v_mrid varchar2 ) IS
    
    SELECT t.*
       FROM reclist t, payment t1
      WHERE pid = rlpid
        and t1.pbatch = as_pBATCH
        and t.rlmrid=v_mrid ;*/
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --����Ԥ��
    V_ISPRINTJE01 := 0;
    J             := 0;
  
    --ˮ�Ѽ�¼
    BEGIN
    
      IF P_ILTYPE = 'T' THEN
      
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('T'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
           AND T1.RLGROUP <> '2';
      
      ELSE
      
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('T'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
           AND T1.RLGROUP = '2';
      
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    P_ILTYPE, --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���շ�Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
  
    I             := 0;
    V_ISPRINTJE01 := 0;
  
    OPEN C_PBATCH_RL_MX(P_ID, P_ILTYPE);
    LOOP
      FETCH C_PBATCH_RL_MX
        INTO V_MRID, V_MCODE, V_PJE, V_ISJE1, V_ISJE2, V_ISJE3, V_ISJE4;
      EXIT WHEN C_PBATCH_RL_MX%NOTFOUND OR C_PBATCH_RL_MX%NOTFOUND IS NULL;
    
      V_ISPRINTJE01 := 0;
      I             := I + 1;
    
      V_ISPRINTJE := V_PJE; /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
    
      --����ˮ�ѽ��  (��ֵ˰�û�)
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, METERINFO T4
       WHERE RLID = RDID
         AND RLMRID = V_MRID
         AND RLMID = MIID
       GROUP BY RLMRID, RLMCODE;
    
      ---��ֵ˰���ݵĴ���
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5, C6, C7, C8)
      VALUES
        (V_ISID,
         V_MRID,
         V_MCODE,
         V_PJE,
         V_ISJE1,
         V_ISJE2,
         V_ISJE3,
         V_ISJE4);
    
      RECINVNO('6', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               V_MRID || '|', --������ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               'DE', --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               P_ILTYPE,
               V_ISZZS);
      ID.IDID      := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
      ID.IDPRINTID := V_MRID; -- ��Ӧ��ˮ��
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- ������Ŀ
        insert into invstockdetail values id;
        update reclist  t
           set t.rlilid = v_isid
         where rlmrid = rl.rlmrid
          ;
      END LOOP;*/
    
      SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
    
      IF P_ILTYPE = 'T' THEN
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP <> 2
           AND T.RLREVERSEFLAG = 'N';
      ELSE
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP = 2
           AND T.RLREVERSEFLAG = 'N';
      END IF;
    
      --  update reclist t set t.rlilid = v_isid where rlmrid = rl.rlmrid;
    END LOOP;
  
    CLOSE C_PBATCH_RL_MX;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_RL_MX%ISOPEN THEN
        CLOSE C_PBATCH_RL_MX;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --����
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F_ZS(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                )
  
   IS
    I             NUMBER(10);
    J             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
  
    V_RLIDSTR   VARCHAR2(4000);
    V_RDPIIDSTR VARCHAR2(4000);
    V_ISZZS     VARCHAR(10);
  
    --һ�׸�ֵ������
    V_MRID  RECLIST.RLMRID%TYPE;
    V_MCODE RECLIST.RLMCODE%TYPE;
    V_PJE   INVSTOCK.ISPRINTJE%TYPE;
    V_ISJE1 INVSTOCK.ISJE1%TYPE;
    V_ISJE2 INVSTOCK.ISJE2%TYPE;
    V_ISJE3 INVSTOCK.ISJE1%TYPE;
    V_ISJE4 INVSTOCK.ISJE2%TYPE;
  
    CURSOR C_PBATCH_RL_MX(AS_PBATCH VARCHAR2, P_ILTYPE VARCHAR2) IS
      SELECT T.RLMRID,
             T.RLMCODE,
             NVL(DECODE(P_ILTYPE,
                        'S',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'W',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) PLJE,
             NVL(DECODE(P_ILTYPE,
                        'S',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'W',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) RLJE,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 1, RLJE, 0))),
                 0) SFJE,
             
             NVL(DECODE(P_ILTYPE, 'W', SUM(DECODE(T.RLGROUP, 2, RLJE, 0))),
                 0) PSF,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 3, RLJE, 0))),
                 0) LJF
      
        FROM RECLIST T
       WHERE T.RLMIEMAIL = AS_PBATCH
         AND T.RLMIEMAILFLAG = DECODE(P_ILTYPE, 'S', 'S', 'W')
       GROUP BY T.RLMRID, T.RLMCODE
       ORDER BY T.RLMRID, T.RLMCODE;
  
    /* CURSOR C_PBATCH_rl_new(as_pBATCH VARCHAR2,v_mrid varchar2 ) IS
    
    SELECT t.*
       FROM reclist t, payment t1
      WHERE pid = rlpid
        and t1.pbatch = as_pBATCH
        and t.rlmrid=v_mrid ;*/
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --����Ԥ��
    V_ISPRINTJE01 := 0;
    J             := 0;
  
    --ˮ�Ѽ�¼
    BEGIN
      /* select count(distinct(rlmrid)), trim(to_char(MAX('I')))
       into v_invcount, rl.rlyschargetype
       from reclist t1
      where rlmiemail = p_id;*/
      IF P_ILTYPE = 'S' THEN
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('I'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
              
           AND T1.RLGROUP <> '2';
      ELSE
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('I'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
           AND T1.RLGROUP = '2';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    P_ILTYPE, --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '���շ�Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
  
    I             := 0;
    V_ISPRINTJE01 := 0;
  
    OPEN C_PBATCH_RL_MX(P_ID, P_ILTYPE);
    LOOP
      FETCH C_PBATCH_RL_MX
        INTO V_MRID, V_MCODE, V_PJE, V_ISJE1, V_ISJE2, V_ISJE3, V_ISJE4;
      EXIT WHEN C_PBATCH_RL_MX%NOTFOUND OR C_PBATCH_RL_MX%NOTFOUND IS NULL;
    
      V_ISPRINTJE01 := 0;
      I             := I + 1;
    
      V_ISPRINTJE := V_PJE; /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
    
      --����ˮ�ѽ��  (��ֵ˰�û�)
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, METERINFO T4
       WHERE RLID = RDID
         AND RLMRID = V_MRID
         AND RLMID = MIID
       GROUP BY RLMRID, RLMCODE;
    
      ---��ֵ˰���ݵĴ���
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5, C6, C7, C8)
      VALUES
        (V_ISID,
         V_MRID,
         V_MCODE,
         V_PJE,
         V_ISJE1,
         V_ISJE2,
         V_ISJE3,
         V_ISJE4);
    
      RECINVNO('5', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               V_MRID || '|', --������ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               'DE', --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               P_ILTYPE,
               V_ISZZS);
      ID.IDID      := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
      ID.IDPRINTID := V_MRID; -- ��Ӧ��ˮ��
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- ������Ŀ
        insert into invstockdetail values id;
        update reclist  t
           set t.rlilid = v_isid
         where rlmrid = rl.rlmrid
          ;
      END LOOP;*/
    
      SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
    
      IF P_ILTYPE = 'S' THEN
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP <> 2
           AND T.RLREVERSEFLAG = 'N';
      ELSE
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP = 2
           AND T.RLREVERSEFLAG = 'N';
      END IF;
    
      --  update reclist t set t.rlilid = v_isid where rlmrid = rl.rlmrid;
    END LOOP;
  
    CLOSE C_PBATCH_RL_MX;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_RL_MX%ISOPEN THEN
        CLOSE C_PBATCH_RL_MX;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F_HSB(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --Ʊ����ˮ
                                 )
  
   IS
    I             NUMBER(10);
    J             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    IN_STOCK      INVSTOCK%ROWTYPE;
  
    V_RLIDSTR   VARCHAR2(4000);
    V_RDPIIDSTR VARCHAR2(4000);
    V_ISZZS     VARCHAR(10);
  
    --һ�׸�ֵ������
    V_MRID  RECLIST.RLMRID%TYPE;
    V_MCODE RECLIST.RLMCODE%TYPE;
    V_PJE   INVSTOCK.ISPRINTJE%TYPE;
    V_ISJE1 INVSTOCK.ISJE1%TYPE;
    V_ISJE2 INVSTOCK.ISJE2%TYPE;
    V_ISJE3 INVSTOCK.ISJE1%TYPE;
    V_ISJE4 INVSTOCK.ISJE2%TYPE;
  
    CURSOR C_PBATCH_RL_MX(AS_PBATCH VARCHAR2, P_ILTYPE VARCHAR2) IS
      SELECT T.RLMRID,
             T.RLMCODE,
             NVL(DECODE(P_ILTYPE, 'S', SUM(T.RLPAIDJE), 'W', 0), 0) PLJE,
             
             NVL(DECODE(P_ILTYPE,
                        'S',
                        SUM(DECODE(T.RLGROUP, 1, T.RLJE, 3, T.RLJE, 2, 0, 0)),
                        'W',
                        SUM(DECODE(T.RLGROUP, 1, 0, 3, 0, 2, T.RLJE, 0))),
                 0) RLJE,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 1, RLJE, 0))),
                 0) SFJE,
             
             NVL(DECODE(P_ILTYPE, 'W', SUM(DECODE(T.RLGROUP, 2, RLJE, 0))),
                 0) PSF,
             
             NVL(DECODE(P_ILTYPE, 'S', SUM(DECODE(T.RLGROUP, 3, RLJE, 0))),
                 0) LJF
      
        FROM RECLIST T
       WHERE T.RLMIEMAIL = AS_PBATCH
         AND T.RLMIEMAILFLAG = DECODE(P_ILTYPE, 'S', 'S', 'W')
       GROUP BY T.RLMRID, T.RLMCODE
       ORDER BY T.RLMRID, T.RLMCODE;
  
    /* CURSOR C_PBATCH_rl_new(as_pBATCH VARCHAR2,v_mrid varchar2 ) IS
    
    SELECT t.*
       FROM reclist t, payment t1
      WHERE pid = rlpid
        and t1.pbatch = as_pBATCH
        and t.rlmrid=v_mrid ;*/
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    BEGIN
      --��ˮ��
      IF P_ILTYPE = 'S' THEN
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('I'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
              
           AND T1.RLGROUP <> '2';
      ELSE
        SELECT COUNT(DISTINCT(RLMRID)), TRIM(MAX('I'))
          INTO V_INVCOUNT, RL.RLYSCHARGETYPE
          FROM RECLIST T1
         WHERE RLMIEMAIL = P_ID
           AND T1.RLGROUP = '2';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    P_ILTYPE, --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    
    END IF;
  
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
    I := 0;
  
    V_ISPRINTJE01 := 0;
  
    OPEN C_PBATCH_RL_MX(P_ID, P_ILTYPE);
    LOOP
      FETCH C_PBATCH_RL_MX
        INTO V_MRID, V_MCODE, V_PJE, V_ISJE1, V_ISJE2, V_ISJE3, V_ISJE4;
      EXIT WHEN C_PBATCH_RL_MX%NOTFOUND OR C_PBATCH_RL_MX%NOTFOUND IS NULL;
      V_ISPRINTJE01 := 0;
      I             := I + 1;
    
      V_ISPRINTJE := V_PJE; /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
    
      --����ˮ�ѽ��  (��ֵ˰�û�)
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, METERINFO T4
       WHERE RLID = RDID
         AND RLMRID = V_MRID
         AND RLMID = MIID
       GROUP BY RLMRID, RLMCODE;
    
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
    
      V_ISID := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      /*  SELECT connstr(RDPIID)
          into v_rdpiidstr
          FROM (select DISTINCT RDPIID
                  FROM recdetail t
                 where rdid = rl.rlid
                   and (v_ISZZS = 'N' OR (v_ISZZS = 'Y' AND RDPIID <> '01')));
      */
    
      INSERT INTO PBPARMTEMP
        (C1, C2, C3, C4, C5, C6, C7, C8)
      VALUES
        (V_ISID,
         V_MRID,
         V_MCODE,
         V_PJE,
         V_ISJE1,
         V_ISJE2,
         V_ISJE3,
         V_ISJE4);
    
      RECINVNO('7', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               V_MRID || '|', --������ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               'DE', --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
      ID.IDID      := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE    := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
      ID.IDPRINTID := V_MRID; -- ��Ӧ��ˮ��
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- ������Ŀ
        insert into invstockdetail values id;
        update reclist  t
           set t.rlilid = v_isid
         where rlmrid = rl.rlmrid
          ;
      END LOOP;*/
    
      SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
    
      IF P_ILTYPE = 'S' THEN
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP <> 2;
      ELSE
        UPDATE RECLIST T
           SET T.RLILID = IN_STOCK.ISPCISNO
         WHERE RLMRID = V_MRID
           AND T.RLGROUP = 2;
      END IF;
    
    END LOOP;
    CLOSE C_PBATCH_RL_MX;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_RL_MX%ISOPEN THEN
        CLOSE C_PBATCH_RL_MX;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_G_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
  
    CURSOR C_PBATCH_MRID_MX_SF(AS_PBATCH VARCHAR2) IS
      SELECT SUM(RLPAIDJE) RLPAIDJE, RLMRID, TRIM(TO_CHAR(MAX(RLCD))) RLCD
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND RLREVERSEFLAG = 'N'
         AND (T.RLGROUP <> 2 OR RLGROUP IS NULL)
         AND PBATCH = AS_PBATCH
       GROUP BY RLMRID;
  
    CURSOR C_PBATCH_MRID_MX_SF_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T
       WHERE RLMRID = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
         AND RLREVERSEFLAG = 'N';
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --�ж��Ƿ�Ԥ��
  
    --����Ԥ��
  
    V_ISPRINTJE01 := 0;
    --��ˮ��
    BEGIN
      SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
        INTO V_INVCOUNT, PM.PTRANS
        FROM (SELECT MAX(RLMRID) RLMRID, MAX(PTRANS) PTRANS
                FROM PAYMENT T, RECLIST T1
               WHERE PBATCH = P_ID
                 AND T1.RLGROUP <> '2'
                 AND PID = RLPID
               GROUP BY RLMRID);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    P_ILTYPE, --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
    I             := 0;
    V_ISPRINTJE01 := 0;
    OPEN C_PBATCH_MRID_MX_SF(P_ID);
    LOOP
      FETCH C_PBATCH_MRID_MX_SF
        INTO /*rl.RLPAIDJE , rl.RLMRID, rl.rlcd  ;*/ RL.RLPAIDJE,
             RL.RLMRID,
             RL.RLCD;
      EXIT WHEN C_PBATCH_MRID_MX_SF%NOTFOUND OR C_PBATCH_MRID_MX_SF%NOTFOUND IS NULL;
      V_ISPRINTJE01 := 0;
      I             := I + 1;
    
      V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
       ;
    
      --����ˮ�ѽ��  (��ֵ˰�û�)
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE RLID = RDID
         AND RLREVERSEFLAG = 'N'
         AND RLMRID = RL.RLMRID
         AND RLGROUP <> '2'
         AND PID = RLPID
         AND PMID = MIID;
    
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
    
      V_ISID := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      RECINVNO('7', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               RL.RLMRID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               RL.RLCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
      ID.IDID   := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
    
      OPEN C_PBATCH_MRID_MX_SF_ONE(RL.RLMRID);
      LOOP
        FETCH C_PBATCH_MRID_MX_SF_ONE
          INTO RLONE;
        EXIT WHEN C_PBATCH_MRID_MX_SF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_SF_ONE%NOTFOUND IS NULL;
        ID.IDPRINTID := RLONE.RLID; -- ��Ӧ��ˮ��
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RLONE.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RLONE.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
      
      END LOOP;
    
      CLOSE C_PBATCH_MRID_MX_SF_ONE;
    
      UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RLONE.RLID;
    END LOOP;
    CLOSE C_PBATCH_MRID_MX_SF;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_MRID_MX_SF%ISOPEN THEN
        CLOSE C_PBATCH_MRID_MX_SF;
      END IF;
      IF C_PBATCH_MRID_MX_SF_ONE%ISOPEN THEN
        CLOSE C_PBATCH_MRID_MX_SF_ONE;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_G_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --Ʊ����ˮ
                                 )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
    CURSOR C_PBATCH_MRID_MX_WSF(AS_PBATCH VARCHAR2) IS
      SELECT SUM(RLPAIDJE) RLPAIDJE, RLMRID, TRIM(TO_CHAR(MAX(RLCD))) RLCD
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND RLREVERSEFLAG = 'N'
         AND T.RLGROUP = 2
         AND PBATCH = AS_PBATCH
       GROUP BY RLMRID;
  
    CURSOR C_PBATCH_MRID_MX_WSF_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T
       WHERE RLMRID = AS_PID
         AND RLGROUP = 2
         AND RLREVERSEFLAG = 'N';
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --�ж��Ƿ�Ԥ��
  
    --����Ԥ��
    ----STRAT@@@@@@@@@@@@@@@@@@@@@@@@@22222
  
    --�ж��Ƿ�Ԥ��
    --����Ԥ��
    V_ISPRINTJE01 := 0;
    --��ˮ��
    BEGIN
      SELECT COUNT(*), TRIM(TO_CHAR(MAX(PTRANS)))
        INTO V_INVCOUNT, PM.PTRANS
        FROM (SELECT MAX(RLMRID) RLMRID, MAX(PTRANS) PTRANS
                FROM PAYMENT T, RECLIST T1
               WHERE PBATCH = P_ID
                 AND T1.RLGROUP = '2'
                 AND PID = RLPID
               GROUP BY RLMRID);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    'W', --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
    I             := 0;
    V_ISPRINTJE01 := 0;
    OPEN C_PBATCH_MRID_MX_WSF(P_ID);
    LOOP
      FETCH C_PBATCH_MRID_MX_WSF
        INTO /*rl.RLPAIDJE , rl.RLMRID, rl.rlcd  ;*/ RL.RLPAIDJE,
             RL.RLMRID,
             RL.RLCD;
      EXIT WHEN C_PBATCH_MRID_MX_WSF%NOTFOUND OR C_PBATCH_MRID_MX_WSF%NOTFOUND IS NULL;
      V_ISPRINTJE01 := 0;
      I             := I + 1;
    
      V_ISPRINTJE := RL.RLPAIDJE /* + rl.rlznj + rl.rlsavingbq + nvl(rl.RLSXF,0)*/
       ;
    
      --����ˮ�ѽ��  (��ֵ˰�û�)
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE RLID = RDID
         AND RLREVERSEFLAG = 'N'
         AND RLMRID = RL.RLMRID
         AND RLGROUP = '2'
         AND PID = RLPID
         AND PMID = MIID;
    
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
    
      V_ISID := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --����Ա
      p_iltype --��Ʊ����
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      RECINVNO('7', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               RL.RLMRID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               'W', --Ʊ������
               RL.RLCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
      ID.IDID   := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
    
      OPEN C_PBATCH_MRID_MX_WSF_ONE(RL.RLMRID);
      LOOP
        FETCH C_PBATCH_MRID_MX_WSF_ONE
          INTO RLONE;
        EXIT WHEN C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND IS NULL;
        ID.IDPRINTID := RLONE.RLID; -- ��Ӧ��ˮ��
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RLONE.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RLONE.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
      
      END LOOP;
    
      CLOSE C_PBATCH_MRID_MX_WSF_ONE;
    
      UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RLONE.RLID;
    END LOOP;
    CLOSE C_PBATCH_MRID_MX_WSF;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_MRID_MX_WSF%ISOPEN THEN
        CLOSE C_PBATCH_MRID_MX_WSF;
      END IF;
      IF C_PBATCH_MRID_MX_WSF_ONE%ISOPEN THEN
        CLOSE C_PBATCH_MRID_MX_WSF_ONE;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_Z_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --��Ʊ��ˮ
                                )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
  
    CURSOR C_PBATCH_PID_SF_MX(AS_PBATCH IN VARCHAR2) IS
      SELECT T.*
        FROM PAYMENT T, RECLIST T1
       WHERE PID = RLPID
         AND PBATCH = AS_PBATCH
         AND RLGROUP <> 2
          OR RLGROUP IS NULL;
  
    CURSOR C_PBATCH_PID_SF_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PID = AS_PID
         AND (RLGROUP <> 2 OR RLGROUP IS NULL)
       ORDER BY PID || RLID;
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    SELECT COUNT(*)
      INTO V_INVCOUNT
      FROM (SELECT PID, PBATCH
              FROM PAYMENT T, RECLIST T1
             WHERE T.PID = T1.RLPID
               AND PTRANS <> 'S'
               AND PBATCH = P_ID
               AND (RLGROUP <> '2' OR RLGROUP IS NULL)
             GROUP BY PID, PBATCH);
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    P_ILTYPE, --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ����
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
    I           := 0;
    V_ISPRINTJE := 0;
    OPEN C_PBATCH_PID_SF_MX(P_ID);
    LOOP
      FETCH C_PBATCH_PID_SF_MX
        INTO PM;
      EXIT WHEN C_PBATCH_PID_SF_MX%NOTFOUND OR C_PBATCH_PID_SF_MX%NOTFOUND IS NULL;
      I := I + 1;
      --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
      SELECT MIIFTAX INTO V_ISZZS FROM METERINFO T4 WHERE MIID = PM.PMID;
    
      SELECT SUM((RLPAIDJE))
        INTO V_ISPRINTJE
        FROM RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE PBATCH = P_ID
         AND PID = PM.PID
         AND PID = RLPID
         AND PMID = MIID
         AND (RLGROUP <> '2' OR RLGROUP IS NULL);
    
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE PBATCH = P_ID
         AND PID = PM.PID
         AND PID = RLPID
         AND PMID = MIID
         AND RLID = RDID
         AND (RLGROUP <> '2' OR RLGROUP IS NULL);
    
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
    
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
      RECINVNO('2', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               PM.PID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               P_ILTYPE, --Ʊ������
               PM.PCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID   := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
    
      OPEN C_PBATCH_PID_SF_MX_ONE(PM.PID);
      LOOP
        FETCH C_PBATCH_PID_SF_MX_ONE
          INTO RL;
        EXIT WHEN C_PBATCH_PID_SF_MX_ONE%NOTFOUND OR C_PBATCH_PID_SF_MX_ONE%NOTFOUND IS NULL;
        NULL;
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RL.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
      
        ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RL.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
        UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
      END LOOP;
      CLOSE C_PBATCH_PID_SF_MX_ONE;
    
      UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
    END LOOP;
    CLOSE C_PBATCH_PID_SF_MX;
  
    --------------------------
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PBATCH_PID_SF_MX%ISOPEN THEN
        CLOSE C_PBATCH_PID_SF_MX;
      END IF;
      IF C_PBATCH_PID_SF_MX_ONE%ISOPEN THEN
        CLOSE C_PBATCH_PID_SF_MX_ONE;
      END IF;
    
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_Z_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����,
                                 P_SNO         IN NUMBER ----��Ʊ��ˮ
                                 )
  
   IS
    I             NUMBER(10);
    V_INVCOUNT    NUMBER(10);
    V_INVRETCOUNT NUMBER(10);
    V_COUNT1      NUMBER(10);
    V_COUNT2      NUMBER(10);
    V_TRNAS       VARCHAR(10);
    V_ISPRINTJE01 NUMBER(13, 3);
    V_ISID        INVSTOCK.ISID%TYPE;
    V_ISPRINTJE   INVSTOCK.ISPRINTJE %TYPE;
    V_ISPRINTTYPE INVSTOCK.ISPRINTTYPE %TYPE;
    PM            PAYMENT%ROWTYPE;
    RL            RECLIST%ROWTYPE;
    RLONE         RECLIST%ROWTYPE;
    PPT           PBPARMTEMP%ROWTYPE;
    ID            INVSTOCKDETAIL%ROWTYPE;
    V_RLIDSTR     VARCHAR2(4000);
    V_RDPIIDSTR   VARCHAR2(4000);
    V_ISZZS       VARCHAR(10);
  
    CURSOR C_PBATCH_PID_WSF_MX(AS_PBATCH IN VARCHAR2) IS
      SELECT T.*
        FROM PAYMENT T, RECLIST T1
       WHERE PID = RLPID
         AND PBATCH = AS_PBATCH
         AND RLGROUP = 2;
  
    CURSOR C_PBATCH_PID_WSF_MX_ONE(AS_PID VARCHAR2) IS
      SELECT T.*
        FROM RECLIST T, PAYMENT T1
       WHERE PID = RLPID
         AND PID = AS_PID
         AND RLGROUP = 2
       ORDER BY PID || RLID;
  
    V_PIDSTR VARCHAR2(1000);
    V_PID    VARCHAR2(1000);
    V_PMID   VARCHAR2(1000);
    V_PTRANS VARCHAR2(1000);
    V_PLID   VARCHAR2(1000);
    V_YCJE   NUMBER(13, 3);
    V_COUNT  NUMBER(10);
  
  BEGIN
  
    --��ˮ
    SELECT COUNT(*)
      INTO V_INVCOUNT
      FROM (SELECT PID, PBATCH
              FROM PAYMENT T, RECLIST T1
             WHERE T.PID = T1.RLPID
               AND PTRANS <> 'S'
               AND PBATCH = P_ID
               AND RLGROUP = '2'
             GROUP BY PID, PBATCH);
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --����Ա
                                    'W', --��Ʊ����
                                    V_INVCOUNT, --Ҫȡ��Ʊ����
                                    P_SNO --��Ʊ
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'û����Ҫ��ӡ�ķ�Ʊ');
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���ݲ���,��Ҫ��ӡ' || V_INVCOUNT || '�ţ�ʵ��ֻ��' ||
                              V_INVRETCOUNT || '��');
    
    END IF;
    I           := 0;
    V_ISPRINTJE := 0;
    OPEN C_PBATCH_PID_WSF_MX(P_ID);
    LOOP
      FETCH C_PBATCH_PID_WSF_MX
        INTO PM;
      EXIT WHEN C_PBATCH_PID_WSF_MX%NOTFOUND OR C_PBATCH_PID_WSF_MX%NOTFOUND IS NULL;
      I := I + 1;
      --����ˮ�ѽ��  (��ֵ˰�û�) ��SP_PRINTINV_OCX �������Ѵ���
      SELECT MIIFTAX INTO V_ISZZS FROM METERINFO T4 WHERE MIID = PM.PMID;
    
      SELECT SUM((RLPAIDJE))
        INTO V_ISPRINTJE
        FROM RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE PBATCH = P_ID
         AND PID = PM.PID
         AND PID = RLPID
         AND PMID = MIID
         AND RLGROUP = '2';
    
      SELECT SUM(CASE
                   WHEN MIIFTAX = 'Y' AND RDPIID = '01' THEN
                    RDJE
                   ELSE
                    0
                 END)
        INTO V_ISPRINTJE01
        FROM RECDETAIL T, RECLIST T1, PAYMENT T3, METERINFO T4
       WHERE PBATCH = P_ID
         AND PID = PM.PID
         AND PID = RLPID
         AND PMID = MIID
         AND RLID = RDID
         AND RLGROUP = '2';
    
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
    
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��' || I || '��Ʊ�����꣬����ȡ��Ʊ');
      END IF;
      RECINVNO('2', --��ӡ��ʽ
               V_ISID || '|', --Ʊ�ݺ���(###|###|)
               PM.PID || '|', --Ӧ����ˮ(###|###|)
               '' || '|', --������Ŀ(###|###|)
               V_ISPRINTJE || '|', --Ʊ�ݽ��(###|###|)
               'W', --Ʊ������
               PM.PCD, --�������
               P_PRINTER, --��Ʊ��
               P_ILSTATUS, --Ʊ��״̬
               P_ILSMFID, --�ֹ�˾
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID   := V_ISID; -- Ʊ����ˮ��
      ID.IDTYPE := '01'; -- ��ӡ���01�ֽ�02���ۣ�03���գ�04�뻧ֱ�գ�01��Ԥ�棩
    
      OPEN C_PBATCH_PID_WSF_MX_ONE(PM.PID);
      LOOP
        FETCH C_PBATCH_PID_WSF_MX_ONE
          INTO RL;
        EXIT WHEN C_PBATCH_PID_WSF_MX_ONE%NOTFOUND OR C_PBATCH_PID_WSF_MX_ONE%NOTFOUND IS NULL;
        NULL;
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RL.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
      
        ID.IDPRINTID := RL.RLID; -- ��Ӧ��ˮ��
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- ������Ŀ
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE RECDETAIL T
             SET T.RDILID = V_ISID
           WHERE RDID = RL.RLID
             AND RDPIID = ID.ISPRINTPIID;
        END LOOP;
        UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
      END LOOP;
      CLOSE C_PBATCH_PID_WSF_MX_ONE;
    
      UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
    END LOOP;
    CLOSE C_PBATCH_PID_WSF_MX;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      IF C_PBATCH_PID_WSF_MX%ISOPEN THEN
        CLOSE C_PBATCH_PID_WSF_MX;
      END IF;
      IF C_PBATCH_PID_WSF_MX_ONE%ISOPEN THEN
        CLOSE C_PBATCH_PID_WSF_MX_ONE;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
  END;

  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE RECINVNO(P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                     P_ILNO        IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                     P_ILRLID      IN VARCHAR2, --Ӧ����ˮ(###|###|)
                     P_ILRDPIID    IN VARCHAR2, --������Ŀ(###|###|)
                     P_ILJE        IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                     P_ILTYPE      IN CHAR, --Ʊ������
                     P_ILCD        IN CHAR, --�������
                     P_ILPER       IN VARCHAR2, --��Ʊ��
                     P_ILSTATUS    IN CHAR, --Ʊ��״̬
                     P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                     P_TRANS       IN VARCHAR2, --����
                     P_ISZZS       IN VARCHAR2 --��ֵ˰
                     ) AS
  
    CURSOR C_IS(VISID VARCHAR2) IS
      SELECT *
        FROM INVSTOCK
       WHERE ISID = VISID
         AND ISSTATUS = '0'
         AND ISTYPE = P_ILTYPE
         AND ISPER = P_ILPER;
  
    I NUMBER;
  
    RT_IS   INVSTOCK%ROWTYPE;
    PB_TEMP PBPARMTEMP%ROWTYPE;
  
    V_ISID NUMBER(12);
    VILJE  VARCHAR2(12);
    VILID  VARCHAR2(32);
  
  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_ILNO) LOOP
      V_ISID := TOOLS.FGETPARA2(P_ILNO, I, 1);
    
      --��֤Ʊ���Ƿ����
      OPEN C_IS(V_ISID);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��Ч��Ʊ���룺[' || V_ISID || ']����������Ʊ�����Ƿ����');
      END IF;
      CLOSE C_IS;
    
      /* vilrlid   := tools.FGetPara2(p_ilrlid, i, 1);
       vilrdpiid := tools.FGetPara2(p_ilrdpiid, i, 1);
      */
    
      VILJE := TOOLS.FGETPARA2(P_ILJE, I, 1);
    
      --ȡ��ʱ���е���Ϣ
      SELECT�� *
        INTO PB_TEMP FROM PBPARMTEMP PBT WHERE PBT.C1 = V_ISID;
    
      UPDATE INVSTOCK
         SET ISPSTATUS      = RT_IS.ISPSTATUS,
             ISPSTATUSDATEP = RT_IS.ISPSTATUSDATEP,
             ISPTATUSPER    = RT_IS.ISPTATUSPER,
             ISSTATUS       = '1',
             ISSTATUSDATE   = SYSDATE,
             ISSTATUSPER    = P_ILPER,
             ISPRINTTYPE    = P_ISPRINTTYPE, --��ӡ��ʽ��1:ʵ�մ�ӡ����pbatch��2:ʵ��pid3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid)
             ISPRINTCD      = P_ILCD, --��de/cr
             ISPRINTJE      = VILJE, --Ʊ����
             ISPRINTTRANS   = P_TRANS, --�������
             ISZZS          = P_ISZZS, --��ֵ˰��
             ISMICODE       = PB_TEMP.C3,
             ISJE1          = PB_TEMP.C5,
             ISJE2          = PB_TEMP.C6,
             ISJE3          = PB_TEMP.C7,
             ISJE4          = PB_TEMP.C8
       WHERE ISID = V_ISID
         AND ISTYPE = P_ILTYPE
         AND ISPER = P_ILPER;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_IS%ISOPEN THEN
        CLOSE C_IS;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --����������޸� ��yujia ,2012-02-12 ��
  PROCEDURE SP_CANCEL(P_PER    IN VARCHAR2, --����Ա
                      P_TYPE   IN VARCHAR2, --��Ʊ���
                      P_STATUS IN VARCHAR2, --����״̬
                      P_ID     IN VARCHAR2, --��ˮ��
                      P_MODE   IN VARCHAR2, --��ˮ�����
                      O_FLAG   OUT VARCHAR2 --����ֵ
                      ) AS
    V_COUNT NUMBER(10);
    IT      INVSTOCK%ROWTYPE;
    PMINFO  PAYMENT%ROWTYPE;
  BEGIN
  
    --�ӽɷ�;���л����Ϣ
    IF P_MODE = '1' THEN
    
      SELECT COUNT(PM.PILID)
        INTO V_COUNT
        FROM PAYMENT PM
       WHERE PM.PBATCH = P_ID;
    
      IF V_COUNT >= 1 THEN
      
        BEGIN
        
          --yc
          UPDATE INVSTOCK T
             SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
                 ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
                 ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
                 ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
                 ISSTATUSDATE   = SYSDATE, --״̬����
                 ISSTATUSPER    = P_PER --״̬��Ա
           WHERE T.ISID IN (SELECT ISK.ISID
                              FROM PAYMENT PM, INVSTOCK ISK
                             WHERE PM.PILID = ISK.ISPCISNO
                               AND PM.PBATCH = P_ID
                            
                            );
        
          UPDATE PAYMENT SET PILID = NULL WHERE PBATCH = P_ID;
        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
      ELSE
        --xc
        BEGIN
          UPDATE INVSTOCK T
             SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
                 ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
                 ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
                 ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
                 ISSTATUSDATE   = SYSDATE, --״̬����
                 ISSTATUSPER    = P_PER --״̬��Ա
           WHERE T.ISID IN (SELECT ISK.ISID
                              FROM RECLIST RL, INVSTOCK ISK, PAYMENT PM
                             WHERE RL.RLILID = ISK.ISPCISNO
                               AND PM.PBATCH = P_ID
                               AND PM.PID = RL.RLPID
                            
                            );
        
          UPDATE RECLIST SET RLILID = NULL WHERE RLPBATCH = P_ID;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
      END IF;
    
      --�����սɷ�;���л����Ϣ
    ELSIF P_MODE = '6' THEN
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISID IN (SELECT ISK.ISID
                            FROM RECLIST RL, INVSTOCK ISK
                           WHERE RL.RLILID = ISK.ISPCISNO
                             AND ISK.ISPCISNO = P_ID);
      
        --���� entrustlist �ļ�Ʊ����
        UPDATE ENTRUSTLIST EL
           SET EL.ETLIFINV = 0
         WHERE EL.ETLRLID IN
               (SELECT RLID FROM RECLIST RL WHERE RL.RLILID = P_ID);
      
        --����reclist ��Ʊ��
        UPDATE RECLIST RL SET RL.RLILID = '' WHERE RL.RLILID = P_ID;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      --�����սɷ�;���л����Ϣ
    ELSIF P_MODE = '5' THEN
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --�ϴ�״̬
               ISPSTATUSDATEP = ISSTATUSDATE, --�ϴ�״̬����
               ISPTATUSPER    = ISSTATUSPER, --״̬��Ա
               ISSTATUS       = P_STATUS, --״̬(0δʹ�ã�1ʹ�ã�2���ϣ�3����)
               ISSTATUSDATE   = SYSDATE, --״̬����
               ISSTATUSPER    = P_PER --״̬��Ա
         WHERE T.ISID IN (SELECT ISK.ISID
                            FROM RECLIST RL, INVSTOCK ISK
                           WHERE RL.RLILID = ISK.ISPCISNO
                             AND ISK.ISPCISNO = P_ID
                          
                          );
      
        --����outflag
      
        UPDATE RECLIST RL
           SET RL.RLOUTFLAG = 'N', RL.RLYSCHARGETYPE = 'X'
         WHERE RL.RLILID = P_ID;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��֧�ִ��ִ���ʽ,�����룺' || P_MODE);
      O_FLAG := 'N';
    END IF;
    O_FLAG := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_FLAG := 'N';
      --raise_application_error(errcode, sqlerrm);
  END;

  PROCEDURE SP_SNO_MODEFY_FP(P_OLDISBCO IN VARCHAR2, --ԭ����
                             P_OLDISNO  IN VARCHAR2, --ԭ����
                             P_NEWISBCO IN VARCHAR2, --����״̬
                             P_NEWISNO  IN VARCHAR2, --��ˮ��
                             P_TYPE     IN VARCHAR2, --��ˮ��
                             P_OPER     IN VARCHAR2, --��ˮ�����
                             O_FLAG     OUT VARCHAR2 --����ֵ
                             ) AS
    V_COUNT  NUMBER(10);
    IT       INVSTOCK%ROWTYPE;
    MSG      VARCHAR2(100);
    INV_TEMP INVSTOCK_TEMP%ROWTYPE;
  BEGIN
    BEGIN
      --�ӽɷ�;���л����Ϣ
      IF P_NEWISBCO IS NULL THEN
        MSG := '�޸ĵķ�Ʊ���κŲ�����!';
        RETURN;
      END IF;
      IF P_NEWISNO IS NULL THEN
        MSG := '�޸ĵķ�Ʊ���벻����!';
        RETURN;
      END IF;
    
      SELECT COUNT(*)
        INTO V_COUNT
        FROM INVSTOCK ISK
       WHERE ISK.ISBCNO = P_NEWISBCO
         AND ISK.ISNO = P_NEWISNO
         AND ISK.ISTYPE = P_TYPE
         AND ISK.ISSTATUS = '0';
    END;
  
    IF V_COUNT <= 1 THEN
    
      --ͨ����ʱ�������ݵ�ת��
      DELETE INVSTOCK_TEMP;
      INSERT INTO INVSTOCK_TEMP INTP
        SELECT *
          FROM INVSTOCK INST
         WHERE INST.ISBCNO = P_OLDISBCO
           AND INST.ISNO = P_OLDISNO;
      --ȡֵ��Ϣ
      SELECT *
        INTO INV_TEMP
        FROM INVSTOCK_TEMP ISK_TEMP
       WHERE ISK_TEMP.ISBCNO = P_OLDISBCO
         AND ISK_TEMP.ISNO = P_OLDISNO
         AND ISK_TEMP.ISTYPE = P_TYPE;
    
      --�����º������Ϣ
      UPDATE INVSTOCK ISK
         SET ISK.ISSTATUS     = INV_TEMP.ISSTATUS,
             ISK.ISSTATUSDATE = INV_TEMP.ISSTATUSDATE,
             ISK.ISSTATUSPER  = INV_TEMP.ISSTATUSPER,
             ISK.ISPRINTTYPE  = INV_TEMP.ISPRINTTYPE,
             ISK.ISPRINTCD    = INV_TEMP.ISPRINTCD,
             ISK.ISPRINTJE    = INV_TEMP.ISPRINTJE,
             ISK.ISPRINTTRANS = INV_TEMP.ISPRINTTRANS,
             ISK.ISMEMO       = INV_TEMP.ISMEMO,
             ISK.ISZZS        = INV_TEMP.ISZZS,
             ISK.ISMICODE     = INV_TEMP.ISMICODE,
             ISK.ISJE1        = INV_TEMP.ISJE1,
             ISK.ISJE2        = INV_TEMP.ISJE2,
             ISK.ISJE3        = INV_TEMP.ISJE3,
             ISK.ISJE4        = INV_TEMP.ISJE4,
             ISK.ISJE5        = INV_TEMP.ISJE5,
             ISK.ISJE6        = INV_TEMP.ISJE6
       WHERE ISK.ISTYPE = P_TYPE
         AND ISK.ISBCNO = P_NEWISBCO
         AND ISK.ISNO = P_NEWISNO;
    
      --����ԭ�еķ�Ʊ�ĺ���
      UPDATE INVSTOCK ISK
         SET ISK.ISPSTATUS      = INV_TEMP.ISSTATUS,
             ISK.ISPSTATUSDATEP = INV_TEMP.ISSTATUSDATE,
             ISK.ISPTATUSPER    = INV_TEMP.ISSTATUSPER,
             ISK.ISSTATUS       = '0',
             ISK.ISMICODE       = '',
             ISK.ISZZS          = ''
       WHERE ISK.ISTYPE = P_TYPE
         AND ISK.ISBCNO = P_OLDISBCO
         AND ISK.ISNO = P_OLDISNO;
    
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��Ʊ���κ��룺' || P_NEWISBCO || P_NEWISNO);
      O_FLAG := 'N';
    END IF;
    O_FLAG := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_FLAG := 'N';
      --raise_application_error(errcode, sqlerrm);
  END;
  PROCEDURE SWAP_TO_INV(P_TYPE   IN VARCHAR2,
                        P_BATCH  IN VARCHAR2,
                        P_PBATCH IN OUT VARCHAR2) IS
  BEGIN
    NULL;
  END;

  --�ж��û��Ƿ�Ϊ�Ⳮ��                      
  FUNCTION fgetmeterstatus(P_CODE IN VARCHAR2 --�û���
                           ) RETURN VARCHAR2 as
    v_count number(10);
    v_ret   varchar2(2);
  begin
    v_count := 0;
    v_ret   := 'N';
    select count(*)
      into v_count
      from meterinfo
     where miid = P_CODE
       and mistatus in ('29', '30', '2');
    if v_count > 0 then
      v_ret := 'Y';
    end if;
    return v_ret;
  exception
    when others then
      return 'N';
  end fgetmeterstatus;

  --��̨��ӡ��ϸ����
  FUNCTION fgetinvdeatil_gt(P_BATCH IN VARCHAR2, --���κ�
                            P_TYPE  IN VARCHAR2, --����
                            P_ROW   IN NUMBER --����  
                            ) RETURN VARCHAR2 AS
    --����˵��
    --����1���շ�����payment��pbatch�ֶ�
    --����2��
    /*NY  ����
    BSS  ��ʾ��  
    SL  ˮ��
    DJ  ����
    SF  ˮ��
    WSF  ��ˮ�����
    WYJ  ΥԼ��
    XJ  С��*/
    --����3����������
  
    CURSOR C_RL IS
    SELECT rlprimcode, rlmonth, RLSCRRLMONTH,max(rlmrid) rlmrid,max(RLCID) RLCID,max(RLECODE) RLECODE,max(RLIFTAX) RLIFTAX,
      max(RLZNJ) RLZNJ
        FROM RECLIST
       WHERE RLPBATCH = P_BATCH 
       group by rlprimcode, rlmonth, RLSCRRLMONTH
       order by  RLSCRRLMONTH   desc;
     /* SELECT *
        FROM RECLIST
       WHERE RLPBATCH = P_BATCH
       ORDER BY RLDATE DESC, RLID DESC;*/
  
    RL    C_RL%ROWTYPE;
    V_STR VARCHAR2(2000);
    RD    VIEW_RECLIST_CHARGE%ROWTYPE;
    V_ROW NUMBER;
  
    V_RDPFID VARCHAR2(50);
    V_RDDJ   VARCHAR2(50);
    V_RDSL   VARCHAR2(50);
    V_RDZNJ  VARCHAR2(50);
    V_RDJE01 VARCHAR2(50);
    V_RDJE02 VARCHAR2(50);
    V_RDJE03 VARCHAR2(50);
    V_RDJE04 VARCHAR2(50);
    V_RDJE05 VARCHAR2(50);
    V_RDJE06 VARCHAR2(50);
    V_RDJE07 VARCHAR2(50);
    V_RDJE08 VARCHAR2(50);
    V_ZZSJE  NUMBER(12, 2);
    V_ROW1   number;
    v_count  number; 
    i1        number;
    v_xj      varchar2(50);
    v_jt     VARCHAR2(50);
   v_RDCLASS number;
   v_dqRDDJ    varchar2(50);
   v_WSDJ   varchar2(20);
  BEGIN
    V_STR := '';
    V_ROW := 1;
    V_ROW1 := P_ROW;
    OPEN C_RL;
    LOOP
      FETCH C_RL
        INTO RL;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      --SELECT * INTO RD FROM VIEW_RECLIST_CHARGE WHERE RDID=RL.RLID;
    
      SELECT CONNSTR(RDPFID),
             CONNSTR(RDDJ),
             CONNSTR(RDSL),
             CONNSTR(WSDJ),
             TOOLS.FFORMATNUM(SUM(ZSSJE), 2),
             CONNSTR(RDJE01),
             CONNSTR(wsje),
             CONNSTR(RDJE03),
             CONNSTR(RDJE04),
             CONNSTR(RDJE05),
             CONNSTR(RDJE06),
             CONNSTR(RDJE07),
             CONNSTR(RDJE08),
             count(*),
             CONNSTR(jt),
             CONNSTR(TOOLS.FFORMATNUM(RDJE01 + wsje,2) ) xj,
             max(RDCLASS),
             max(RDDJ),
             max(WSDJ)
        INTO V_RDPFID,
             V_RDDJ,
             V_RDSL,
             V_RDZNJ,
             V_ZZSJE,
             V_RDJE01,
             V_RDJE02,
             V_RDJE03,
             V_RDJE04,
             V_RDJE05,
             V_RDJE06,
             V_RDJE07,
             V_RDJE08,
             v_count,
             v_jt,
             v_xj,
             v_RDCLASS,
             v_dqRDDJ,
             v_WSDJ
        FROM (select *
                from (select RDPMDID,
                             RDPFID,
                             rdpiid,
                             RDCLASS,
                             CASE
                               WHEN RDCLASS = 1 THEN
                                '1��'
                               WHEN RDCLASS = 2 THEN
                                '2��'
                               WHEN RDCLASS = 3 THEN
                                '3��'
                               ELSE
                                '-'
                             END jt,
                             TOOLS.FFORMATNUM(MAX(NVL(RDDJ, 0)), 2) RDDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID, '01', RDsl, 0)), 0) RDSL,
                             TOOLS.FFORMATNUM(SUM(NVL(RDZNJ, 0)), 2) RDZNJ,
                             SUM(DECODE(RDPIID, '01', 0, RDJE)) ZSSJE,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDJE,
                                                         0)),
                                              2) RDJE01,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '02',
                                                         RDJE,
                                                         0)),
                                              2) RDJE02,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '03',
                                                         RDJE,
                                                         0)),
                                              2) RDJE03,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '04',
                                                         RDJE,
                                                         0)),
                                              2) RDJE04,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '05',
                                                         RDJE,
                                                         0)),
                                              2) RDJE05,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '06',
                                                         RDJE,
                                                         0)),
                                              2) RDJE06,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '07',
                                                         RDJE,
                                                         0)),
                                              2) RDJE07,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '08',
                                                         RDJE,
                                                         0)),
                                              2) RDJE08,
                             
                             TOOLS.FFORMATNUM(sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by RDPFID),2) WSDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID, '01', RDsl, 0)) *
                             sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by RDPFID),2) wsje
                        from recdetail
                       WHERE RDID in (SELECT rlid
                  FROM RECLIST
                 WHERE RLPBATCH = P_BATCH
                   and rlprimcode = RL.RLPRIMCODE
                   and rlmonth = RL.RLMONTH)
                       group by RDPMDID, rdpiid, RDPFID, RDCLASS
                       ORDER BY RDPMDID, rdpiid, RDCLASS desc)
               where rdpiid = '01'
                 and rownum <= V_ROW1);
      V_ROW1 := V_ROW1 - v_count;
      IF P_ROW < V_ROW THEN
        EXIT;
      END IF;
      IF P_TYPE = 'NY' THEN
        --����
        select mrmonth
          into RL.RLMONTH
          from view_meterreadall
         where mrid = RL.rlmrid;
        V_STR := V_STR || SUBSTR(NVL(RL.RLMONTH, '1990.01'), 1, 4) ||
                 SUBSTR(NVL(RL.RLMONTH, '1990.01'), 6, 2) || CHR(13);
         i1 := 2;
         for i1 in 2..v_count loop
           V_STR := V_STR || SUBSTR(NVL(RL.RLMONTH, '1990.01'), 1, 4) ||SUBSTR(NVL(RL.RLMONTH, '1990.01'), 6, 2) || CHR(13);
         end loop;  
      ELSIF P_TYPE = 'BSS' THEN
        --��ʾ��
        if FGETIFDZSB(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        elsif fgetmeterstatus(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        else
          V_STR := V_STR || RL.RLECODE || CHR(13);
        end if;
        i1 := 2;
         for i1 in 2..v_count loop
           V_STR := V_STR||CHR(13);
         end loop; 
      ELSIF P_TYPE = 'SL' THEN
        --V_STR := V_STR || RL.RLSL ||CHR(13);
        V_STR := V_STR || V_RDSL || CHR(13);
      ELSIF P_TYPE = 'DJ' THEN
        --V_STR := V_STR || tools.fformatnum(RD.DJ,2) ||CHR(13);
        V_STR := V_STR || V_RDDJ || CHR(13);
      ELSIF P_TYPE = 'SF' THEN
        --V_STR := V_STR || tools.fformatnum(RD.CHARGE1,2) ||CHR(13);
        V_STR := V_STR || V_RDJE01 || CHR(13);
      ELSIF P_TYPE = 'WSF' THEN
        --V_STR := V_STR || tools.fformatnum(RD.CHARGE2,2) ||CHR(13);
        V_STR := V_STR || V_RDJE02 || CHR(13);
      ELSIF P_TYPE = 'WYJ' THEN
        --V_STR := V_STR || tools.fformatnum(RL.RLZNJ,2) ||CHR(13);
        V_STR := V_STR || V_RDZNJ || CHR(13);
      ELSIF P_TYPE='JT' THEN
            --V_STR := V_STR || tools.fformatnum(RL.RLZNJ,2) ||CHR(13);
            V_STR := V_STR || v_jt ||CHR(13);
      ELSIF P_TYPE='DQDJ' THEN
          IF V_ROW = 1 THEN
             if v_RDCLASS = 0 then
                V_STR :=   v_dqRDDJ||'Ԫ' ||CHR(13);
             else
                 V_STR := '('||v_RDCLASS||'��)' || v_dqRDDJ||'Ԫ' ||CHR(13);
              end if;
          END IF;
      ELSIF P_TYPE='DJX' THEN
          IF V_ROW = 1 THEN
             V_STR :=  v_dqRDDJ + v_WSDJ   ||CHR(13);
          END IF;
      ELSIF P_TYPE = 'XJ' THEN
        IF RL.RLIFTAX = 'Y' /*and  rl.rlmid <> '3123016839' */
         THEN
          --��ֵ˰��Ʊ
          V_STR := V_STR || tools.fformatnum(V_ZZSJE + RL.RLZNJ, 2) ||
                   CHR(13);
        ELSE
          /*V_STR := V_STR || tools.fformatnum(RL.RLJE + RL.RLZNJ, 2) ||
                   CHR(13);*/
            V_STR := V_STR || v_xj ||  CHR(13);
        END IF;
      
      END IF;
      IF V_ROW1 < 1 THEN
        EXIT;
      END IF;
      V_ROW := V_ROW + 1;
    END LOOP;
    CLOSE C_RL;
  
    IF LENGTH(V_STR) > 1 THEN
      V_STR := SUBSTR(V_STR, 1, LENGTH(V_STR) - 1);
      V_STR := replace(V_STR,'/',CHR(13));
    END IF;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --���մ�ӡ��ϸ����
  FUNCTION fgetinvdeatil_zs(P_RLIDLIST IN VARCHAR2, --Ӧ����ˮ��
                            P_TYPE     IN VARCHAR2, --����
                            P_ROW      IN NUMBER --����  
                            ) RETURN VARCHAR2 AS
    --����˵��
    --����1���շ�����payment��pbatch�ֶ�
    --����2��
    /*NY  ����
    BSS  ��ʾ��  
    SL  ˮ��
    DJ  ����
    SF  ˮ��
    WSF  ��ˮ�����
    WYJ  ΥԼ��
    XJ  С��*/
    --����3����������
  
    /*CURSOR C_RL IS
    SELECT * FROM RECLIST 
    WHERE RLPBATCH=''
    ORDER BY RLDATE DESC;*/
  
    type cursor_type is ref cursor;
    C_RL cursor_type;
  
    RL         RECLIST%ROWTYPE;
    V_STR      VARCHAR2(2000);
    RD         VIEW_RECLIST_CHARGE%ROWTYPE;
    V_ROW      NUMBER;
    V_SQL      VARCHAR2(4000);
    I          NUMBER;
    V_RLID     VARCHAR2(20);
    V_RLIDLIST VARCHAR2(4000);
  
    V_RDPFID VARCHAR2(50);
    V_RDDJ   VARCHAR2(50);
    V_RDSL   VARCHAR2(50);
    V_RDZNJ  VARCHAR2(50);
    V_RDJE01 VARCHAR2(50);
    V_RDJE02 VARCHAR2(50);
    V_RDJE03 VARCHAR2(50);
    V_RDJE04 VARCHAR2(50);
    V_RDJE05 VARCHAR2(50);
    V_RDJE06 VARCHAR2(50);
    V_RDJE07 VARCHAR2(50);
    V_RDJE08 VARCHAR2(50);
    v_jt     VARCHAR2(50);
    V_ZZSJE  NUMBER(12, 2);
    V_ROW1   number;
    v_count  number;
    i1        number;
    v_xj      varchar2(50);
  BEGIN
    V_ROW := tools.fmidn(P_RLIDLIST, '/');
    FOR I IN 1 .. V_ROW LOOP
      V_RLID     := tools.fmid(P_RLIDLIST, I, 'Y', '/');
      V_RLIDLIST := V_RLIDLIST || '''' || V_RLID || ''',';
    END LOOP;
    V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
  
    V_SQL := 'SELECT * FROM RECLIST 
    WHERE RLID IN (' || V_RLIDLIST || ')
    ORDER BY RLDATE DESC,RLID DESC';
  
    V_STR  := '';
    V_ROW  := 1;
    V_ROW1 := P_ROW;
    OPEN C_RL FOR V_SQL;
    LOOP
      FETCH C_RL
        INTO RL;
      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
      --SELECT * INTO RD FROM VIEW_RECLIST_CHARGE WHERE RDID=RL.RLID;
    
      SELECT CONNSTR(RDPFID),
             CONNSTR(RDDJ),
             CONNSTR(RDSL),
             CONNSTR(WSDJ),
             TOOLS.FFORMATNUM(SUM(ZSSJE), 2),
             CONNSTR(RDJE01),
             CONNSTR(wsje),
             CONNSTR(RDJE03),
             CONNSTR(RDJE04),
             CONNSTR(RDJE05),
             CONNSTR(RDJE06),
             CONNSTR(RDJE07),
             CONNSTR(RDJE08),
             count(*),
             CONNSTR(jt),
             CONNSTR(TOOLS.FFORMATNUM(RDJE01 + wsje,2) ) xj
        INTO V_RDPFID,
             V_RDDJ,
             V_RDSL,
             V_RDZNJ,
             V_ZZSJE,
             V_RDJE01,
             V_RDJE02,
             V_RDJE03,
             V_RDJE04,
             V_RDJE05,
             V_RDJE06,
             V_RDJE07,
             V_RDJE08,
             v_count,
             v_jt,
             v_xj
        FROM (select *
                from (select RDPMDID,
                             RDPFID,
                             rdpiid,
                             RDCLASS,
                             CASE
                               WHEN RDCLASS = 1 THEN
                                '1��'
                               WHEN RDCLASS = 2 THEN
                                '2��'
                               WHEN RDCLASS = 3 THEN
                                '3��'
                               ELSE
                                '-'
                             END jt,
                             --TOOLS.FFORMATNUM(SUM(NVL(RDDJ, 0)), 2) RDDJ,
                             TOOLS.FFORMATNUM(max(NVL(RDDJ, 0)), 2) RDDJ,  --20170421�����漰�����ݼ���ͬ��Ӧ��2��ˮ����ϸ����ȡ��
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID, '01', RDsl, 0)), 0) RDSL,
                             TOOLS.FFORMATNUM(SUM(NVL(RDZNJ, 0)), 2) RDZNJ,
                             SUM(DECODE(RDPIID, '01', 0, RDJE)) ZSSJE,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDJE,
                                                         0)),
                                              2) RDJE01,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '02',
                                                         RDJE,
                                                         0)),
                                              2) RDJE02,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '03',
                                                         RDJE,
                                                         0)),
                                              2) RDJE03,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '04',
                                                         RDJE,
                                                         0)),
                                              2) RDJE04,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '05',
                                                         RDJE,
                                                         0)),
                                              2) RDJE05,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '06',
                                                         RDJE,
                                                         0)),
                                              2) RDJE06,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '07',
                                                         RDJE,
                                                         0)),
                                              2) RDJE07,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '08',
                                                         RDJE,
                                                         0)),
                                              2) RDJE08,
                             
                             TOOLS.FFORMATNUM(sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by RDPFID),2) WSDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID, '01', RDsl, 0)) *
                             sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by RDPFID),2) wsje
                        from recdetail
                       WHERE RDID = RL.RLID
                       group by RDPMDID, rdpiid, RDPFID, RDCLASS
                       ORDER BY RDPMDID, rdpiid, RDCLASS desc)
               where rdpiid = '01'
                 and rownum <= V_ROW1);
    
      IF P_ROW < V_ROW THEN
        EXIT;
      END IF;
      V_ROW1 := V_ROW1 - v_count;
      IF P_TYPE = 'NY' THEN
        --����
        if rl.rltrans <> '23' then
          --Ӫ��������ʱֱ��ץȡӦ�����·�
          select mrmonth
            into RL.RLMONTH
            from view_meterreadall
           where mrid = RL.rlmrid;
        end if;
        V_STR := V_STR || SUBSTR(NVL(RL.RLMONTH, '1990.01'), 1, 4) ||SUBSTR(NVL(RL.RLMONTH, '1990.01'), 6, 2) || CHR(13);
         i1 := 2;
         for i1 in 2..v_count loop
           V_STR := V_STR || SUBSTR(NVL(RL.RLMONTH, '1990.01'), 1, 4) ||SUBSTR(NVL(RL.RLMONTH, '1990.01'), 6, 2) || CHR(13);
         end loop;         
        
      ELSIF P_TYPE = 'BSS' THEN
        --��ʾ��
        if FGETIFDZSB(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        elsif fgetmeterstatus(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        else
          if nvl(TRIM(RL.RLMICOLUMN4), 'N') <> 'Y' AND rl.rltrans = '23' THEN
            --Ӫ��������ʱ���������δ����ʼָ�룬��Ʊ����ӡָʾ��
            V_STR := V_STR || '-' || CHR(13);
          else
            V_STR := V_STR || RL.RLECODE || CHR(13);
          end if;
        
        end if;
          i1 := 2;
         for i1 in 2..v_count loop
           V_STR := V_STR||CHR(13);
         end loop; 
      ELSIF P_TYPE = 'SL' THEN
        --V_STR := V_STR || RL.RLSL ||CHR(13);
        V_STR := V_STR || V_RDSL || CHR(13);
      ELSIF P_TYPE = 'DJ' THEN
        --V_STR := V_STR || tools.fformatnum(RD.DJ,2) ||CHR(13);
        V_STR := V_STR || V_RDDJ || CHR(13);
      ELSIF P_TYPE = 'SF' THEN
        --V_STR := V_STR || tools.fformatnum(RD.CHARGE1,2) ||CHR(13);
        V_STR := V_STR || V_RDJE01 || CHR(13);
      ELSIF P_TYPE = 'WSF' THEN
        --V_STR := V_STR || tools.fformatnum(RD.CHARGE2,2) ||CHR(13);
        V_STR := V_STR || V_RDJE02 || CHR(13);
      ELSIF P_TYPE = 'WYJ' THEN
        --V_STR := V_STR || tools.fformatnum(RL.RLZNJ,2) ||CHR(13);
        V_STR := V_STR || V_RDZNJ || CHR(13);
      ELSIF P_TYPE='JT' THEN
            --V_STR := V_STR || tools.fformatnum(RL.RLZNJ,2) ||CHR(13);
            V_STR := V_STR || v_jt ||CHR(13);
      ELSIF P_TYPE = 'XJ' THEN
        IF RL.RLIFTAX = 'Y' THEN
          --��ֵ˰��Ʊ
          V_STR := V_STR || tools.fformatnum(V_ZZSJE + RL.RLZNJ, 2) ||
                   CHR(13);
        ELSE
          /*V_STR := V_STR || tools.fformatnum(RL.RLJE + RL.RLZNJ, 2) ||
                   CHR(13);*/
            V_STR := V_STR || v_xj ||  CHR(13);
        END IF;
      
      END IF;
      V_ROW := V_ROW + 1;
      IF V_ROW1 < 1 THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE C_RL;
  
    IF LENGTH(V_STR) > 1 THEN
      V_STR := SUBSTR(V_STR, 1, LENGTH(V_STR) - 1);
      V_STR := replace(V_STR,'/',CHR(13));
    END IF;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --��ȡ���ջ���
  FUNCTION fgethscode(P_MIID IN VARCHAR2 --�ͻ�����  
                      ) RETURN varchar2 AS
  
    MI    METERINFO%ROWTYPE;
    V_RET varchar2(10);
  BEGIN
    SELECT MIPRIFLAG, MIPRIID
      INTO MI.MIPRIFLAG, MI.MIPRIID
      FROM METERINFO
     WHERE MIID = P_MIID;
    IF MI.MIPRIFLAG = 'Y' THEN
      SELECT COUNT(*)
        INTO V_RET
        FROM METERINFO
       WHERE MI.MIPRIFLAG = 'Y'
         AND MIPRIID = MI.MIPRIID;
    ELSE
      V_RET := '0';
    END IF;
  
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '0';
  END fgethscode;

  --��ȡ��ע��Ϣ                  
  FUNCTION fgetinvmemo(P_RLID IN VARCHAR2, --Ӧ����ˮ
                       P_TYPE IN VARCHAR2 --��ע����
                       ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(400);
  BEGIN
  
    IF UPPER(P_TYPE) = 'RLINVMEMO' THEN
      SELECT RLINVMEMO INTO V_RET FROM RECLIST WHERE RLID = P_RLID;
    END IF;
   
    IF UPPER(P_TYPE) = 'RLMEMO' THEN
      SELECT RLMEMO INTO V_RET FROM RECLIST WHERE RLID = P_RLID;
    END IF;
  
    IF UPPER(P_TYPE) = 'BFPPER' THEN
      SELECT FGETOPERNAME(bfrper) --20160530 ���շ�Ա�ĳɳ���Ա
        INTO V_RET
        FROM RECLIST, BOOKFRAME
       WHERE RLBFID = BFID
         AND RLID = P_RLID;
    END IF;
  
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fgetinvmemo;

  --��ȡ�û�ԭˮ�˱�ʶ��                   
  FUNCTION fgetcltno(P_MIID IN VARCHAR2 --�ͻ�����  
                     ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(20);
  BEGIN
    SELECT miemail INTO V_RET FROM METERINFO WHERE MIID = P_MIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '-';
  END fgetcltno;

  --��ȡ�û����˿��ţ�����+������ţ�                   
  FUNCTION fgetnewcardno(P_MIID IN VARCHAR2 --�ͻ�����  
                         ) RETURN VARCHAR2 as
    V_RET VARCHAR2(20);
  BEGIN
    SELECT mibfid || mirorder
      INTO V_RET
      FROM METERINFO
     WHERE MIID = P_MIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '-';
  END fgetnewcardno;

  --��ȡһ�������ĩԤ�����        
  FUNCTION fgethsqmsaving(P_MIID IN VARCHAR2 --�ͻ�����  
                          ) RETURN VARCHAR2 as
    v_priid VARCHAR2(10);
    V_RET   VARCHAR2(20);
  begin
    --����������
    SELECT mipriid INTO v_priid FROM METERINFO WHERE MIID = P_MIID;
    --������Ԥ�����
    SELECT misaving INTO V_RET FROM METERINFO WHERE MIID = v_priid;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '0';
  END fgethsqmsaving;

  --��Ʊ��ӡ��ϸ(һ�����)
  function fgethsinvdeatil(p_miid in varchar2 --�ͻ�����  
                           ) return varchar2 as
    cursor c_detail(v_code in varchar2) is
      select miid, mircodechar from meterinfo where mipriid = v_code;
  
    v_detail meterinfo%rowtype;
    p_code   varchar2(10);
    v_type   varchar2(20);
    v_str    varchar2(4000);
    v_row    number;
    v_column number;
    v_number number;
  
  begin
    null;
    v_number := 0;
    v_row    := 6; --������
    v_column := 3; --������
  
    select mipriid into p_code from meterinfo where miid = p_miid;
    open c_detail(p_code);
    loop
      fetch c_detail
        into v_detail.miid, v_detail.mircodechar;
      exit when c_detail%notfound or c_detail%notfound is null;
      /*    if v_detail.miid = p_miid then
        --v_type := '(��������)';
        v_type := null;
      else
        v_type := null;
      end if;*/
    
      if fgetmeterstatus(v_detail.miid) = 'Y' or
         FGETIFDZSB(v_detail.miid) = 'Y' then
        v_detail.mircodechar := '-';
      end if;
    
      v_number := v_number + 1;
    
      if v_number > (v_column * v_row) then
        exit;
      end if;
    
      if floor(v_number / v_column) = ceil(v_number / v_column) then
        v_str := v_str || v_detail.miid || '  :  ' ||
                 rpad(v_detail.mircodechar, 10, ' ') || chr(13);
      else
        v_str := v_str || v_detail.miid || '  :  ' ||
                 rpad(v_detail.mircodechar, 10, ' ');
      end if;
    
    end loop;
    close c_detail;
  
    if length(v_str) > 1 then
      v_str := substr(v_str, 1, length(v_str) - 1);
    end if;
    return v_str;
  exception
    when others then
      return null;
  end fgethsinvdeatil;

  --���뷢Ʊ��עrlinvmemo                 
  FUNCTION FGETTRANSLATE(P_RLTRANS   IN VARCHAR2, --Ӧ������
                         P_RLINVMEMO IN VARCHAR2 -- ��Ʊ��ע
                         ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(200);
  BEGIN
    --��������
    IF P_RLTRANS = '13' THEN
      SELECT SCLVALUE
        INTO V_RET
        FROM SYSCHARLIST
       WHERE SCLTYPE = '�������'
         AND SCLID = P_RLINVMEMO;
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '����';
  END FGETTRANSLATE;

  --�ɷ�����֧Ʊ����
  PROCEDURE SP_CHEQUE(P_BATCH    IN VARCHAR2, --�շ����κ� 
                      P_CODE     IN VARCHAR2, --�ͻ�����
                      P_SMFID    IN VARCHAR2, --Ӫҵ��
                      P_OPER     IN VARCHAR2, --�տ�Ա
                      P_STATUS   IN VARCHAR2, --֧Ʊ״̬
                      P_NO       IN VARCHAR2, --֧Ʊ��
                      P_BANKNAME IN VARCHAR2, --��������
                      P_BANKID   IN VARCHAR2, --�к�
                      P_BANKNO   IN VARCHAR2, --�����˺�
                      P_CWDH     IN VARCHAR2, --���񵥺�
                      P_TYPE     IN VARCHAR2 --��������
                      ) AS
  
    CQ         CHEQUE%ROWTYPE;
    CI         CUSTINFO%ROWTYPE;
    V_CODE     METERINFO.MIID%TYPE;
    V_JE       PAYMENT.PPAYMENT%TYPE;
    V_SMFID    PAYMENT.PPOSITION%TYPE;
    V_OPER     PAYMENT.PPER%TYPE;
    V_BANKID   VARCHAR2(100);
    V_BANKNAME VARCHAR2(100);
    V_BANKNO   VARCHAR2(100);
    V_PBATCH   VARCHAR2(20);
  BEGIN
    --�����˺�
    SELECT SMPPVALUE
      INTO V_BANKNO
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHZH';
    --��������
    SELECT SMPPVALUE
      INTO V_BANKNAME
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHYH';
    --�����к�
    SELECT SMPPVALUE
      INTO V_BANKID
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHHH';
  
    IF P_TYPE = 'ZP' THEN
      --1.������
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL OR P_STATUS IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���ɲ������ݣ�֧Ʊ�����쳣��');
      END IF;
    
      IF P_NO IS NULL OR P_BANKNAME IS NULL OR P_BANKID IS NULL OR
         P_BANKNO IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '֧Ʊ������Ϣδ��д,���飡');
      END IF;
      --2.��������
      SELECT MAX(PPRIID), SUM(PPAYMENT), MAX(PPER), MAX(PPOSITION)
        INTO V_CODE, V_JE, V_OPER, V_SMFID
        FROM PAYMENT
       WHERE PBATCH = P_BATCH;
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = V_CODE;
      CQ.chequeid        := P_BATCH;
      CQ.enteringtime    := SYSDATE;
      CQ.payername       := CI.CINAME;
      CQ.payertel        := CI.CIMTEL;
      CQ.chequetype      := 'ZP';
      CQ.chequemoney     := V_JE;
      CQ.chargelocation  := V_SMFID;
      CQ.chargename      := P_OPER;
      CQ.chargetime      := SYSDATE;
      CQ.chequechargerid := P_OPER;
      CQ.chequememo      := NULL;
      CQ.chequestatus    := 'N';
      CQ.chequeoper      := P_OPER;
      CQ.chequesdate     := SYSDATE;
      CQ.chequemcode     := P_CODE;
      CQ.chequecode      := P_NO;
      CQ.chequename      := CI.Ciname;
      CQ.chequebankname  := P_BANKNAME;
      CQ.CHEQUEBANKID    := P_BANKID;
      CQ.CHEQUEBANKNO    := P_BANKNO;
      CQ.CBANKID         := V_BANKID;
      CQ.CBANKNAME       := V_BANKNAME;
      CQ.CBANKNO         := V_BANKNO;
      CQ.CHEQUEFLAG      := 'N';
      CQ.CHEQUECRFLAG    := 'N';
      --SELECT * FROM PAYMENT WHERE PBATCH=P_BATCH;
    
      --3.��������
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'ZP'
       WHERE PBATCH = P_BATCH;
    
      --Ĩ�ʽ��˵�
    ELSIF P_TYPE = 'MZ' THEN
      --1.������
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����쳣��');
      END IF;
    
      --2.��������
      SELECT MAX(PPRIID), SUM(PPAYMENT), MAX(PPER), MAX(PPOSITION)
        INTO V_CODE, V_JE, V_OPER, V_SMFID
        FROM PAYMENT
       WHERE PBATCH = P_BATCH;
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = V_CODE;
      CQ.chequeid        := P_BATCH;
      CQ.enteringtime    := SYSDATE;
      CQ.payername       := CI.CINAME;
      CQ.payertel        := CI.CIMTEL;
      CQ.chequetype      := 'MZ';
      CQ.chequemoney     := V_JE;
      CQ.chargelocation  := V_SMFID;
      CQ.chargename      := P_OPER;
      CQ.chargetime      := SYSDATE;
      CQ.chequechargerid := P_OPER;
      CQ.chequememo      := NULL;
      CQ.chequestatus    := 'N';
      CQ.chequeoper      := P_OPER;
      CQ.chequesdate     := SYSDATE;
      CQ.chequemcode     := P_CODE;
      CQ.chequecode      := P_NO;
      CQ.chequename      := CI.Ciname;
      CQ.chequebankname  := P_BANKNAME;
      CQ.CHEQUEBANKID    := P_BANKID;
      CQ.CHEQUEBANKNO    := P_BANKNO;
      CQ.CBANKID         := V_BANKID;
      CQ.CBANKNAME       := V_BANKNAME;
      CQ.CBANKNO         := V_BANKNO;
      CQ.CHEQUEFLAG      := 'N';
      CQ.CHEQUECRFLAG    := 'N';
      --SELECT * FROM PAYMENT WHERE PBATCH=P_BATCH;
    
      --3.��������
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'MZ'
       WHERE PBATCH = P_BATCH;
    
      --������˵�
    ELSIF P_TYPE = 'DC' THEN
      --1.������
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����쳣��');
      END IF;
    
      --2.��������
      SELECT MAX(PPRIID), SUM(PPAYMENT), MAX(PPER), MAX(PPOSITION)
        INTO V_CODE, V_JE, V_OPER, V_SMFID
        FROM PAYMENT
       WHERE PBATCH = P_BATCH;
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = V_CODE;
      CQ.chequeid        := P_BATCH;
      CQ.enteringtime    := SYSDATE;
      CQ.payername       := CI.CINAME;
      CQ.payertel        := CI.CIMTEL;
      CQ.chequetype      := 'DC';
      CQ.chequemoney     := V_JE;
      CQ.chargelocation  := V_SMFID;
      CQ.chargename      := P_OPER;
      CQ.chargetime      := SYSDATE;
      CQ.chequechargerid := P_OPER;
      CQ.chequememo      := NULL;
      CQ.chequestatus    := 'N';
      CQ.chequeoper      := P_OPER;
      CQ.chequesdate     := SYSDATE;
      CQ.chequemcode     := P_CODE;
      CQ.chequecode      := P_NO;
      CQ.chequename      := CI.Ciname;
      CQ.chequebankname  := P_BANKNAME;
      CQ.CHEQUEBANKID    := P_BANKID;
      CQ.CHEQUEBANKNO    := P_BANKNO;
      CQ.CBANKID         := V_BANKID;
      CQ.CBANKNAME       := V_BANKNAME;
      CQ.CBANKNO         := V_BANKNO;
      CQ.CHEQUEFLAG      := 'N';
      CQ.CHEQUECRFLAG    := 'N';
      --SELECT * FROM PAYMENT WHERE PBATCH=P_BATCH;
    
      --3.��������
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'DC'
       WHERE PBATCH = P_BATCH;
    
    ELSIF P_TYPE = 'XJ' THEN
      --����������ӽ��˵�
      SELECT fgetsequence('ENTRUSTLOG') INTO V_PBATCH FROM DUAL;
      SELECT HXJJE INTO V_JE FROM STpaymentcwdzreghd where hno = P_CWDH;
      CQ.chequeid        := TRIM(V_PBATCH);
      CQ.enteringtime    := SYSDATE;
      CQ.payername       := NULL;
      CQ.payertel        := NULL;
      CQ.chequetype      := 'XJ';
      CQ.chequemoney     := V_JE;
      CQ.chargelocation  := P_SMFID;
      CQ.chargename      := V_OPER;
      CQ.chargetime      := SYSDATE;
      CQ.chequechargerid := NULL;
      CQ.chequememo      := '�������';
      CQ.chequestatus    := 'N';
      CQ.chequeoper      := V_OPER;
      CQ.chequesdate     := SYSDATE;
      CQ.chequemcode     := '';
      CQ.chequecode      := P_NO;
      CQ.chequename      := CI.Ciname;
    
      CQ.CHEQUEFLAG   := 'N';
      CQ.CHEQUECRFLAG := 'N';
    
      CQ.chequebankname := P_BANKNAME;
      CQ.CHEQUEBANKID   := P_BANKID;
      CQ.CHEQUEBANKNO   := P_BANKNO;
      CQ.CHEQUECWNO     := P_CWDH;
      CQ.CBANKID        := V_BANKID;
      CQ.CBANKNAME      := V_BANKNAME;
      CQ.CBANKNO        := V_BANKNO;
    
    END IF;
  
    IF CQ.chequetype = 'XJ' AND CQ.chequemoney = 0 AND
       CQ.chequememo = '�������' THEN
      --20140904 ADD
      NULL;
    ELSE
      INSERT INTO CHEQUE VALUES CQ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    
    --  RAISE_APPLICATION_ERROR(ERRCODE, P_BATCH||'---'||V_CODE);
  END SP_CHEQUE;

  PROCEDURE sp_������(P_ID   IN VARCHAR2, --���˵���ˮ
                    P_OPER IN VARCHAR2 --������
                    ) IS
    CQ CHEQUE%ROWTYPE;
  begin
    begin
      select * into CQ from CHEQUE WHERE CHEQUEID = P_ID;
    exception
      when others then
        RAISE_APPLICATION_ERROR(ERRCODE, '���˵���' || P_ID || '������!');
    end;
    /*--����Ƿ�������֧Ʊ
    IF CQ.CHEQUECRFLAG='Y' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '���˵���'||P_ID||'������!');
    END IF;*/
    --���µ��˱�־
    UPDATE CHEQUE
       SET CHEQUESTATUS = 'Y', --֧Ʊ״̬ 
           CHEQUEOPER   = P_OPER, --״̬�� 
           CHEQUESDATE  = SYSDATE, --״̬���� 
           CHEQUEFLAG   = 'Y' --֧Ʊ��Ʊ 
     WHERE CHEQUEID = P_ID;
    --���˺󣬻�дpayment��������
    UPDATE PAYMENT
       SET TCHKDATE = SYSDATE
     WHERE (PBATCH, PPAYWAY) IN
           (SELECT P.PDPID, CQ.CHEQUETYPE
              FROM STPAYMENTCWDZREGHD CW, PAY_DAILY_YXHD YX, PAY_DAILY_PID P
             WHERE CW.HNO = YX.PDHID
               AND YX.PDDID = P.PDHID
               AND CW.HNO = CQ.CHEQUECWNO);
  
  exception
    when others then
      rollback;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  end sp_������;

  PROCEDURE sp_������Ʊ(P_ID    IN VARCHAR2, --���˵���ˮ
                    P_SMFID IN VARCHAR, --Ӫҵ��
                    P_OPER  IN VARCHAR2 --��Ʊ��
                    ) IS
    v_ret varchar2(1000);
    CQ    CHEQUE%ROWTYPE;
  begin
    begin
      select * into CQ from CHEQUE WHERE CHEQUEID = P_ID;
    exception
      when others then
        RAISE_APPLICATION_ERROR(ERRCODE, '���˵���' || P_ID || '������!');
    end;
    IF CQ.CHEQUECRFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���˵���' || P_ID || '������!');
    END IF;
  
    IF CQ.CHEQUESTATUS = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '���˵���' || P_ID || '��ȷ�ϵ���!');
    END IF;
  
    v_ret := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(P_ID,
                                                P_SMFID,
                                                P_OPER,
                                                P_SMFID,
                                                'C');
  
    --���µ��˱�־
    UPDATE CHEQUE
       SET CHEQUECRFLAG = 'Y', --���ϱ�־ 
           CHEQUECROPER = P_OPER, --������ 
           CHEQUECRDATE = SYSDATE, --����ʱ�� 
           CHEQUEFLAG   = 'Y' --֧Ʊ��Ʊ 
     WHERE CHEQUEID = P_ID;
  
  exception
    when others then
      rollback;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  end sp_������Ʊ;

  --���ݷ�Ʊ�Ÿ���Ӧ�������־
  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --��Ʊ���κ�
                                P_ISNO  IN VARCHAR2 --��Ʊ��
                                ) AS
  
    INV       INV_INFO%ROWTYPE;
    INV_COUNT NUMBER;
    REC_COUNT NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      SELECT *
        INTO INV
        FROM INV_INFO
       WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      SELECT COUNT(*)
        INTO REC_COUNT
        FROM RECLIST
       WHERE RLMICOLUMN2 = INV.PPBATCH;
      IF REC_COUNT > 0 THEN
        IF INV.CPLX = 'I' THEN
          UPDATE RECLIST
             SET RLOUTFLAG = 'N', RLIFINV = 'N' --��ԭ�վݴ�ӡ��־
           WHERE RLMICOLUMN2 = INV.PPBATCH;
        END IF;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_UPDATERECOUTFLAG;

  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --��Ʊ���κ�
                              P_ISNO   IN VARCHAR2, --��Ʊ��
                              P_STATUS NUMBER) AS
    INV       INV_INFO%ROWTYPE;
    INV_COUNT NUMBER;
    v_STATUS  INV_INFO.Status%type;
  BEGIN
    if P_STATUS = 0 then
      --���ó�δʹ��
      v_STATUS := '0';
    elsif P_STATUS = 1 then
      --��ʹ��
      v_STATUS := '1';
    elsif P_STATUS = 2 then
      --��Ʊ����
      v_STATUS := '2';
    elsif P_STATUS = 3then --��Ʊ����
     v_STATUS := '3' ; elsif P_STATUS = 4 then
      --��Ʊ��ɾ��
      v_STATUS := '4';
    elsif P_STATUS = 5 then
      --��Ʊ����
      v_STATUS := '5';
    end if;
    /*  0 δʹ��
    1 ��ʹ��
    2 ����
    3 ����
    4 ��ɾ��
    5 ����*/
  
    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      -- DELETE INV_INFO WHERE ISPCISNO=P_BATCH||'.'||P_ISNO;
      --modify 20140630  ����Ϊ֮ǰ��Ʊ����ʱ�������ֱ��ɾ����ƱINV_INFO����.
      --�ָ���Ϊ�ѷ�Ʊ���ϸ���Ϊ����
      if P_STATUS = 0 then
        --���ó�δʹ��ʱ, ֱ��ɾ����ƱINV_INFO
        insert into inv_info_his
          (id,
           isid,
           ispcisno,
           dyfs,
           printnum,
           status,
           fkfs,
           cplx,
           cpfs,
           ppbatch,
           batch,
           flag,
           fkje,
           xzje,
           znj,
           sxf,
           jmje,
           qcsaving,
           qmsaving,
           bqsaving,
           czper,
           czdate,
           jzdid,
           cpje01,
           cpje02,
           cpje03,
           cpje04,
           cpje05,
           cpje06,
           cpje07,
           cpje08,
           cpje09,
           cpje10,
           memo01,
           memo02,
           mcode,
           poper,
           pdate,
           scode,
           ecode,
           month,
           rlid,
           pid,
           pmonth,
           fptype,
           reverseflag,
           cpje11,
           kpje,
           ISSTATUSMEMO,
           sl,
           rlcname,
           rlcadr,
           dj,
           dj1,
           dj2,
           dj3,
           dj4,
           dj5,
           dj6,
           dj7,
           dj8,
           dj9,
           yshj,
           yjbss,
           memo03,
           memo04,
           memo05,
           memo06,
           memo07,
           memo08,
           memo09,
           memo10,
           memo11,
           memo12,
           memo13,
           memo14,
           memo15,
           memo16,
           memo17,
           memo18,
           memo19,
           memo20)
          select id,
                 isid,
                 ispcisno,
                 dyfs,
                 printnum,
                 status,
                 fkfs,
                 cplx,
                 cpfs,
                 ppbatch,
                 batch,
                 flag,
                 fkje,
                 xzje,
                 znj,
                 sxf,
                 jmje,
                 qcsaving,
                 qmsaving,
                 bqsaving,
                 czper,
                 czdate,
                 jzdid,
                 cpje01,
                 cpje02,
                 cpje03,
                 cpje04,
                 cpje05,
                 cpje06,
                 cpje07,
                 cpje08,
                 cpje09,
                 cpje10,
                 memo01,
                 memo02,
                 mcode,
                 poper,
                 pdate,
                 scode,
                 ecode,
                 month,
                 rlid,
                 pid,
                 pmonth,
                 fptype,
                 reverseflag,
                 cpje11,
                 kpje,
                 statusmemo,
                 sl,
                 rlcname,
                 rlcadr,
                 dj,
                 dj1,
                 dj2,
                 dj3,
                 dj4,
                 dj5,
                 dj6,
                 dj7,
                 dj8,
                 dj9,
                 yshj,
                 yjbss,
                 memo03,
                 memo04,
                 memo05,
                 memo06,
                 memo07,
                 memo08,
                 memo09,
                 memo10,
                 memo11,
                 memo12,
                 memo13,
                 memo14,
                 memo15,
                 memo16,
                 memo17,
                 memo18,
                 memo19,
                 memo20
            from INV_INFO
           WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
        DELETE INV_INFO WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      ELSE
        update INV_INFO
           set STATUS = v_STATUS, statusmemo = '��Ʊ��������'
         WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_DELETEISPCISNO;

END;
/


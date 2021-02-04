CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_INVMANAGE_SP" IS

  --������Ʊ�Ƿ�������ˮ�����
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
        FROM INVSTOCK_SP
       WHERE ISTYPE = P_ISTYPE
         AND ISBCNO = P_ISBCNO
         AND ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND;

      IF V_ISTRUE1 = 0 THEN
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          INSERT INTO INVSTOCK_SP
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
             ISPCISNO,
             ISSMFID)
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
             TRIM(P_ISBCNO || '.' || TRIM(TO_CHAR(I, '00000000'))),
             FGETOPERDEPT(P_ISPER));
        END LOOP;
        --�ж�ÿ���Ƿ���ӳɹ�
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      ELSE
        MSG := 'Y';--'�����η�Ʊ����δ���' || V_ISTRUE1 || '���ѱ���ȡ�ķ�Ʊ��';
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '��ȡʧ��!' || SQLERRM;
  END;

  --��Ʊת��
  PROCEDURE SP_INVMANG_ZLY(P_INVTYPE     VARCHAR2,
                           P_ISNOSTART   VARCHAR2, --��Ʊ���
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
        FROM INVSTOCK_SP
       WHERE ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND
         AND ISBCNO = P_ISBCNO
         AND ISSTATUS <> '0'
         AND (ISTYPE = P_INVTYPE OR P_INVTYPE IS NULL);
    END;

    IF V_COUNT <= 0 THEN
      UPDATE INVSTOCK_SP
         SET ISPER          = P_ISSTATUSPER,
             ISSTATUSDATE   = SYSDATE,
             ISSTATUSPER    = P_ISSTATUSPER,
             ISPSTATUS      = ISSTATUS,
             ISPSTATUSDATEP = ISSTATUSDATE,
             ISPTATUSPER    = ISSTATUSPER,
             ISSTATUS       = '1'
       WHERE ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND
         AND ISBCNO = P_ISBCNO
         AND ISTYPE = P_INVTYPE;
    ELSE
      MSG := 'N';
      RETURN;
    END IF;
    IF SQL%ROWCOUNT > 0 THEN
      MSG := 'Y';
      --��˰�ӿڵ���ʱP_MEMOΪ'NOCOMMIT'�����ύ��
      IF P_MEMO IS NULL OR P_MEMO <> 'NOCOMMIT' THEN
        COMMIT;
      END IF;
    ELSE
      MSG := 'Y';
      RETURN;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := 'N';
  END;

  --�޸ķ�Ʊ״̬
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_INVTYPE     VARCHAR2,
                                    P_ISNOSTART   VARCHAR2, --��Ʊ���
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
      UPDATE INVSTOCK_SP
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
             ISPRINTCD      = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISPRINTCD
                              END,
             ISPRINTJE      = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISPRINTJE
                              END,
             ISMICODE       = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISMICODE
                              END,
             ISJE1          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE1
                              END,
             ISJE2          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE2
                              END,
             ISJE3          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE3
                              END,
             ISJE4          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE4
                              END,
             ISJE5          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE5
                              END,
             ISJE6          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE6
                              END,
             ISJE7          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE7
                              END,
             ISJE8          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE8
                              END,
             ISMEMO         = CASE
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
             ISSTATUSPER    = P_ISSTATUSPER
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISBCNO = P_ISBCNO
         AND ISTYPE = P_INVTYPE;

      IF P_STATUS = '5' THEN
        NULL;
      ELSE
        SP_UPDATERECOUTFLAG(P_ISBCNO,
                            TRIM(TO_CHAR(P_ISNOSTART, '00000000')));
        SP_DELETEISPCISNO(P_ISBCNO,
                          TRIM(TO_CHAR(P_ISNOSTART, '00000000')),
                          P_STATUS);
      END IF;

      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        MSG := 'N';
        RETURN;
      END IF;

    ELSIF P_ISNOSTART IS NULL THEN
      --��Ʊ���Ϊ�գ�����Ʊֹ�Ų�Ϊ��
      UPDATE INVSTOCK_SP
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
             ISPRINTCD      = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISPRINTCD
                              END,
             ISPRINTJE      = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISPRINTJE
                              END,
             ISMICODE       = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISMICODE
                              END,
             ISJE1          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE1
                              END,
             ISJE2          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE2
                              END,
             ISJE3          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE3
                              END,
             ISJE4          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE4
                              END,
             ISJE5          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE5
                              END,
             ISJE6          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE6
                              END,
             ISJE7          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE7
                              END,
             ISJE8          = CASE
                                WHEN P_STATUS = 0 THEN
                                 NULL
                                ELSE
                                 ISJE8
                              END,
             ISMEMO         = CASE
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
             ISSTATUSPER    = P_ISSTATUSPER
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         AND ISBCNO = P_ISBCNO
         AND ISTYPE = P_INVTYPE;

      IF P_STATUS = '5' THEN
        NULL;
      ELSE
        SP_UPDATERECOUTFLAG(P_ISBCNO, TRIM(TO_CHAR(P_ISNOEND, '00000000')));
        SP_DELETEISPCISNO(P_ISBCNO,
                          TRIM(TO_CHAR(P_ISNOSTART, '00000000')),
                          P_STATUS);
      END IF;

      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
      ELSE
        ROLLBACK;
        MSG := 'N';
        RETURN;
      END IF;

    ELSE
      --��Ʊ���ֹ�Ŷ���Ϊ��
      FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
        UPDATE INVSTOCK_SP
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
               ISPRINTCD      = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISPRINTCD
                                END,
               ISPRINTJE      = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISPRINTJE
                                END,
               ISMICODE       = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISMICODE
                                END,
               ISJE1          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE1
                                END,
               ISJE2          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE2
                                END,
               ISJE3          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE3
                                END,
               ISJE4          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE4
                                END,
               ISJE5          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE5
                                END,
               ISJE6          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE6
                                END,
               ISJE7          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE7
                                END,
               ISJE8          = CASE
                                  WHEN P_STATUS = 0 THEN
                                   NULL
                                  ELSE
                                   ISJE8
                                END,
               ISMEMO         = CASE
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
               ISSTATUSPER    = P_ISSTATUSPER
         WHERE ISNO = TRIM(TO_CHAR(I, '00000000'))
           AND ISBCNO = P_ISBCNO
           AND ISTYPE = P_INVTYPE;

        IF P_STATUS = '5' THEN
          NULL;
        ELSE
          SP_UPDATERECOUTFLAG(P_ISBCNO, TRIM(TO_CHAR(I, '00000000')));
          SP_DELETEISPCISNO(P_ISBCNO,
                            TRIM(TO_CHAR(I, '00000000')),
                            P_STATUS);
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
      ROLLBACK;
      MSG := 'N';
  END;

  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --��Ʊ���κ�
                                P_ISNO  IN VARCHAR2 --��Ʊ��
                                ) AS
    INV       INV_INFO_SP%ROWTYPE;
    INV_COUNT NUMBER;
    REC_COUNT NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO_SP
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      SELECT *
        INTO INV
        FROM INV_INFO_SP
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
    INV       INV_INFO_SP%ROWTYPE;
    INV_COUNT NUMBER;
    V_STATUS  INV_INFO_SP.STATUS%TYPE;
  BEGIN
    /*��Ʊ������Ʊ����2����Ʊ��ʼ��0����ʹ��1������3��ɾ��4*/
    IF P_STATUS = 0 THEN
      --���ó�δʹ��
      V_STATUS := '0';
    ELSIF P_STATUS = 1 THEN
      --��ʹ��
      V_STATUS := '1';
    ELSIF P_STATUS = 2 THEN
      --��Ʊ����
      V_STATUS := '2';
    ELSIF P_STATUS = 3THEN
    --��Ʊ����
     V_STATUS := '3' ; ELSIF P_STATUS = 4 THEN
      --��Ʊ��ɾ��
      V_STATUS := '4';
    END IF;

    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO_SP
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      -- DELETE INV_INFO WHERE ISPCISNO=P_BATCH||'.'||P_ISNO;
      --�ָ���Ϊ�ѷ�Ʊ���ϸ���Ϊ����
      IF P_STATUS = 0 THEN
        --���ó�δʹ��ʱ, ֱ��ɾ����ƱINV_INFO
        DELETE INV_INFO_SP WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      ELSE
        UPDATE INV_INFO_SP
           SET STATUS = V_STATUS, STATUSMEMO = '��Ʊ����'
         WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_DELETEISPCISNO;

  --Ԥ��Ʊ��Դ
  PROCEDURE SP_SWAPINVYC(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --��Ʊ��ˮ��
             '' ISID, --��Ʊ��ˮ��
             '' ISPCISNO, --Ʊ������||����
             CASE
               WHEN P_SLTJ = 'YYSF' AND
                    (P.PPER <> FGETPBOPER OR P.PDATE <> TRUNC(SYSDATE)) THEN
                '1'
               WHEN P_SLTJ = 'WX' THEN
                '2'
               WHEN P_SLTJ = 'QYMH' THEN
                '3'
               ELSE
                '0'
             END DYFS, --��ӡ��ʽ(0.��̨������1. ��̨����2.΢�����죬3.�Ż���վ����)
             0 PRINTNUM, --��ӡ����
             '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
             P.PPAYWAY FKFS, --��������(XJ �ֽ�,ZP,֧Ʊ
             'P' CPLX, --��Ʊ���ͣ�P,ʵ�ճ���,L��Ӧ�ճ��ˣ�
             'YC' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
             P.PBATCH PPBATCH, --��ӡ����
             P.PBATCH BATCH, --ʵ������
             'Y' FLAG, --���˱�־
             ABS(P.PPAYMENT) FKJE, --������
             P.PSPJE XZJE, --���˽��
             P.PZNJ ZNJ, --���ɽ�
             P.PSXF SXF, --������
             0 JMJE, --������
             --P.PSAVINGQC QCSAVING, --�ϴν��
             --P.PSAVINGQM QMSAVING, --���ν��
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QC'))  QCSAVING, --�ϴν��
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QM'))  QMSAVING, --���ν��
             P.PSAVINGBQ BQSAVING, --����Ԥ�淢��
             '' CZPER, --������Ա
             '' CZDATE, --��������
             P.PCHKNO JZDID, --���˵���ˮ
             P.PREVERSEFLAG REVERSEFLAG, --������־��NΪ������YΪ������
             (CASE
               WHEN P.PPAYMENT > 0 THEN
                '��̨Ԥ�淢Ʊ'
               WHEN MI.MIYL8 = 1 THEN
                'Ԥ���˷�'
               WHEN MI.MIYL8 = 2 THEN
                '�����˷�'
             END) STATUSMEMO, --״̬ԭ��
             FGETZHDJ(MIPFID) DJ, --�ܵ���
             FGETSF(MIPFID) DJ1, --ˮ��
             FGETSJWSF((MI.MIPFID), (MI.MIID)) DJ2, --������ˮ��   2016.10.18  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
             0 DJ3, --����3  ���ӷ�
             0 DJ4, --����4
             0 DJ5, --����5
             0 DJ6, --����6
             0 DJ7, --����7
             0 DJ8, --����8
             0 DJ9, --����9
             (CASE
               WHEN FGETMETERSTATUS(P.PMID) = 'Y' OR
                    FGETIFDZSB(P.PMID) = 'Y' THEN
                '-'
               WHEN FGET_CBJ_REC(P.PMID, 'QF') >= 0 THEN
                TO_CHAR(MI.MIRCODE +
                        TRUNC(FGET_CBJ_REC(P.PMID, 'QF') /
                              (FUN_GETJTDQDJ(MI.MIPFID, MI.MIPRIID, MI.MIID, '1') +
                               FGETWSF(MI.MIPFID))))
               ELSE
                '-'
             END) MEMO03, --����ˮ��Ԥ�Ʊ�ʾ��
             (CASE
               WHEN FGET_CBJ_REC(P.PMID, 'QF') >= 0 THEN
                TO_CHAR(FLOOR(FGET_CBJ_REC(P.PMID, 'QF') /
                              (FUN_GETJTDQDJ(MI.MIPFID, MI.MIPRIID, MI.MIID, '1') +
                               FGETWSF(MI.MIPFID))))
               ELSE
                '-'
             END) MEMO04, --����ˮ�۶��Ԥ�Ʊ�ʾ��
             TOOLS.FFORMATNUM(TO_NUMBER(FGETHSQMSAVING(P.PMID)), 2) MEMO05, --�������������ν��Ѻ����
             FUN_GETJTDQDJ(MI.MIPFID, MI.MIPRIID, MI.MIID, '2') MEMO06, --����ˮ�۵���
             TO_CHAR(DECODE(FGETIFDZSB(P.PMID),
                            'Y',
                            '-',
                            DECODE(FGETMETERSTATUS(P.PMID),
                                   'Y',
                                   '-',
                                   nvl(pp.pprcode ,MI.MIRCODE)))) MEMO07, --��ǰ��ʾ��
             TO_CHAR(FGETHSINVDEATIL(P.PMID)) MEMO08, --����ˮ��ָ����ϸ
             --nvl(pp.pprcode ,MI.MIRCODE)  MEMO08, --����ˮ��ָ����ϸ
             nvl(pp.pprcode ,MI.MIRCODE) MEMO09, --��ע9
             NULL MEMO10, --��ע10
             NULL MEMO11, --��ע11
             NULL MEMO12, --��ע12
             NULL MEMO13, --��ע13
             NULL MEMO14, --��ע14
             'Y' MEMO15, --��ע15
             decode(NVL(MI.MIIFTAX,'N'),'N',FGETINVEWM(P.PID, 'P'),'N') MEMO16, --��ά��
             --FGETINVEWM(P.PID, 'P') MEMO16, --��ά��
             NULL MEMO17, --Ԥ��
             /*(SELECT MAX(FGETOPERNAME(BFRPER))
                FROM BOOKFRAME
               WHERE BFID = MI.MIBFID) MEMO18,*/ --������[�տ������ڵ���]
             --FGETSMFNAME(fsysmanalbbm(fgetoperdept(p.pper),'1'))  MEMO18,  --������[�տ������ڵ���]
             (CASE WHEN P.PTRANS='B' THEN fgetsysmanapara(MI.MISMFID,'FPFHR') ELSE fgetsysmanapara(SUBSTR(fgetoperdept(p.pper),1,4),'FPFHR') END)  MEMO18,  --������[�տ������ڵ���]
             --nvl(FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)),'SYSTEM') MEMO19, --����Ա(���Ʊ��ť����Ա),��վ��Ʊsystem
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END)  MEMO19, --����Ա(���Ʊ��ť����Ա),��վ��Ʊsystem
             fgetopername(P.PPER) MEMO19, --����Ա(�տ���)
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(p.pper),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --����Ա(���Ʊ��ť����Ա),��վ��Ʊsystem,
             NULL MEMO20, --Ԥ��
             0 N1, --��ֵ1
             FGETHSCODE(P.PMID) N2, --���ջ���
             NULL N3, --��ֵ3
             NULL N4, --��ֵ4
             NULL N5, --��ֵ5
             NULL N6, --��ֵ6
             NULL N7, --��ֵ7
             NULL N8, --��ֵ8
             NULL N9, --��ֵ9
             P.PMCODE MICODE, --�ͻ�����
             MSP.TINAME KPNAME, --Ʊ������
             NULL MIUIID, --���պ�
             MSP.TIADDR KPDZ, --��Ʊ��ַ
             NULL KPZH, --�˺�
             NULL KPKHM, --������
             NULL KPKHYH, --��������
             NULL KPSKZH, --��˾�տ��˺�
             NULL KPSKHM, --��˾�տ���
             NULL KPSKYH, --��˾�տ�����
             NULL KPCBJQ, --��������
             SYSDATE KPRQ, --��Ʊ����
             P.PMONTH KPZWMONTH, --�����·�
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --��Ʊ�·�
             fgetopername(P.PPER) KPSFY, --�շ�Ա
             FGETBFRPER(MIBFID) KPCBY, --����Ա
             FGETPBOPER KPDYY, --��ӡԱ
             0 KPQM, --����
             0 KPZM, --ֹ��
             0 KPCBSL, --����ˮ��
             0 KPTZSL, --����ˮ��
             0 KPSSSL, --ʵ��ˮ��
             P.PPAYMENT KPJE, --Ӧ���ܽ��
             NULL KPJTDJ1, --һ�׵���
             NULL KPJTDJ2, --���׵���
             NULL KPJTDJ3, --���׵���
             NULL KPJTSL1, --һ��ˮ��
             NULL KPJTSL2, --����ˮ��
             NULL KPJTSL3, --����ˮ��
             NULL KPJTJE1, --һ�׽��
             NULL KPJTJE2, --���׽��
             NULL KPJTJE3, --���׽��
             NULL KPJE1, --���1
             NULL KPJE2, --���2
             NULL KPJE3, --���3
             NULL KPJE4, --���4
             NULL KPJE5, --���5
             NULL KPJE6, --���6
             NULL KPJE7, --���7
             NULL KPJE8, --���8
             NULL KPJE9, --���9
             NULL RLID,
             P.PID PID,
             P.PDATE KPSQCBRQ --���ڳ�������
        FROM PAYMENT P
             left join payment_paid pp on pid = ppid
             LEFT JOIN METERINFOSP MSP ON P.PMID = MSP.MIID
              , METERINFO MI, INVPARMTERMP T
       WHERE P.PMID = MI.MIID
         AND (P.PTRANS = 'S' OR P.PSCRTRANS = 'S' OR P.PTRANS = 'V' OR
             P.PSCRTRANS = 'V' OR P.PTRANS = 'Y' OR P.PSCRTRANS = 'Y' OR
             P.PTRANS = 'Q' OR P.PSCRTRANS = 'Q' or p.ptrans = 'B' or p.pscrtrans = 'B'
              or p.ptrans = 'H' or p.pscrtrans = 'H'  or p.ptrans = 'P' or p.pscrtrans = 'P')
         AND P.PBATCH = T.PBATCH
       ORDER BY p.PID;

  BEGIN
    OPEN C_INV;
    LOOP
      FETCH C_INV
        INTO V_INV;
      EXIT WHEN C_INV%NOTFOUND OR C_INV%NOTFOUND IS NULL;
      --��֯��Ʊ��ϸ������
      SP_GET_INV_DETAIL(V_INV.BATCH, P_PRINTTYPE, V_INV);
      --���뷢Ʊ��Ϣ
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --���뷢Ʊ��ϸ
      INSERT INTO INV_DETAILTEMP_SP
        SELECT V_INV.ID,
               NULL,
               NULL,
               PID,
               PMID,
               MI.MINAME,
               P.PBATCH,
               NULL,
               'Ԥ��'
          FROM PAYMENT P, METERINFO MI
         WHERE PMID = MIID
           AND P.PID = V_INV.PID;
    END LOOP;
    NULL;
  END;

  --��Ʊ����Դ
  PROCEDURE SP_SWAPINVHP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --��Ʊ��ˮ��
             '' ISID, --��Ʊ��ˮ��
             '' ISPCISNO, --Ʊ������||����
             CASE
               WHEN P_SLTJ = 'YYSF' AND (MAX(P.PPER) <> FGETPBOPER OR
                    MAX(P.PDATE) <> TRUNC(SYSDATE)) THEN
                '1'
               WHEN P_SLTJ = 'WX' THEN
                '2'
               WHEN P_SLTJ = 'QYMH' THEN
                '3'
               ELSE
                '0'
             END DYFS, --��ӡ��ʽ(0.��̨������1. ��̨����2.΢�����죬3.�Ż���վ����)
             0 PRINTNUM, --��ӡ����
             '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
             MAX(P.PPAYWAY) FKFS, --��������(XJ �ֽ�,ZP,֧Ʊ
             'P' CPLX, --��Ʊ���ͣ�P,ʵ�ճ���,L��Ӧ�ճ��ˣ�
             'HP' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
             P.PBATCH PPBATCH, --��ӡ����
             P.PBATCH BATCH, --ʵ������
             'Y' FLAG, --���˱�־
             MAX(DECODE(P.PMID, P.PPRIID, P.PPAYMENT, 0)) FKJE, --������
             SUM(NVL(RLZNJ, 0) + NVL(RLJE, 0)) XZJE, --���˽��
             SUM(NVL(RLZNJ, 0)) ZNJ, --���ɽ�
             SUM(NVL(RLSXF, 0)) SXF, --������
             0 JMJE, --������
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QC')) QCSAVING, --�ϴν��
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QM')) QMSAVING, --���ν��
             SUM(PSAVINGBQ) BQSAVING, --����Ԥ�淢��
             '' CZPER, --������Ա
             '' CZDATE, --��������
             MAX(P.PCHKNO) JZDID, --���˵���ˮ
             MAX(PREVERSEFLAG) REVERSEFLAG, --������־��NΪ������YΪ������
             '��̨�ϴ�Ʊ' STATUSMEMO, --״̬ԭ��
             --MAX(RD.DJ) DJ, --�ܵ���
             FGETZHDJ(MAX(M.MIPFID)) DJ, --�ܵ���
             --MAX(RD.DJ1) DJ1, --ˮ��
             FGETSF(MAX(M.MIPFID)) DJ1, --ˮ��
             FGETSJWSF(MAX(MIPFID), MAX(P.PPRIID)) DJ2, --������ˮ��   2016.10.18  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
             MAX(RD.DJ3) DJ3, --����3  ���ӷ�
             MAX(RD.DJ4) DJ4, --����4
             MAX(RD.DJ5) DJ5, --����5
             MAX(RD.DJ6) DJ6, --����6
             MAX(RD.DJ7) DJ7, --����7
             MAX(RD.DJ1) DJ8, --���ô��û���ǰ��ˮ��
             FGETWSF(MAX(M.MIPFID)) DJ9, --���ô��û���ǰ��ˮ��
             (CASE
               WHEN FGETMETERSTATUS(MAX(RL.RLMID)) = 'Y' OR
                    FGETIFDZSB(MAX(RL.RLMID)) = 'Y' THEN
                '-'
               WHEN FGET_CBJ_REC(MAX(RL.RLMID), 'QF') >= 0 THEN
                TO_CHAR(TO_NUMBER(MAX(M.MIRCODE)) +
                        FLOOR((TO_NUMBER(MAX(M.MISAVING)) /
                              (FUN_GETJTDQDJ(MAX(WATERTYPE),
                                              MAX(M.MIPRIID),
                                              MAX(M.MIID),
                                              '1') + FGETWSF(MAX(M.MIPFID))))))

               ELSE
                '-'
             END) MEMO03, --Ԥ�Ʊ�ʾ��
             (CASE
               WHEN FGET_CBJ_REC(MAX(P.PMCODE), 'QF') >= 0 THEN
                TO_CHAR(FLOOR(TO_NUMBER(FGETHSQMSAVING(MAX(P.PMCODE))) /
                              (FUN_GETJTDQDJ(MAX(WATERTYPE),
                                             MAX(M.MIPRIID),
                                             MAX(M.MIID),
                                             '1') + FGETWSF(MAX(M.MIPFID)))))
               ELSE
                '-'
             END) MEMO04, --���ձ�Ԥ�ƿ���ˮ��
             TOOLS.FFORMATNUM(TO_NUMBER(FGETHSQMSAVING(MAX(P.PMCODE))), 2) MEMO05, --��������Ԥ�����
             FUN_GETJTDQDJ(MAX(WATERTYPE), MAX(M.MIPRIID), MAX(M.MIID), '2') MEMO06, --ˮ�ѵ���
             NULL MEMO07, --��ע7
             TO_CHAR(FGETHSINVDEATIL(MAX(P.PMCODE))) MEMO08, --����ˮ��ָ����ϸ
             NULL MEMO09, --��ע9
             NULL MEMO10, --��ע10
             NULL MEMO11, --��ע11
             NULL MEMO12, --��ע12
             NULL MEMO13, --��ע13
             NULL MEMO14, --��ע14
             'Y' MEMO15, --��ע15
             decode(NVL(M.MIIFTAX,'N'),'N',FGETINVEWM(MAX(CASE
                              WHEN P.PMID = P.PPRIID THEN
                               P.PID
                              ELSE
                               '0'
                            END),
                        'P'),'N')  MEMO16, --��ά��
             /*FGETINVEWM(MAX(CASE
                              WHEN P.PMID = P.PPRIID THEN
                               P.PID
                              ELSE
                               '0'
                            END),
                        'P')  MEMO16, --��ά��  */
             NULL MEMO17, --Ԥ��
             /*FGETOPERNAME(MAX(CBY)) MEMO18, --������
             FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)) MEMO19, --��Ʊ��λ*/
             --FGETSMFNAME(fsysmanalbbm(fgetoperdept(max(p.pper)),'1')) MEMO18, --������[�տ������ڵ���]
             (CASE WHEN MAX(P.PTRANS)='B' THEN fgetsysmanapara(max(M.MISMFID),'FPFHR') ELSE fgetsysmanapara(SUBSTR(fgetoperdept(max(p.pper)),1,4),'FPFHR') END) MEMO18, --������[�տ������ڵ���]
             --nvl(FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)),'SYSTEM') MEMO19, --��Ʊ��(���Ʊ��ť����Ա)���ڵ�λ,��վ��Ʊsystem
             --NVL(fgetopername(fgetoperid),'SYSTEM') MEMO19, --��Ʊ��(���Ʊ��ť����Ա),��վ��Ʊsystem
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --��Ʊ��(���Ʊ��ť����Ա),��վ��Ʊsystem
             MAX(fgetopername(P.PPER)) MEMO19, --��Ʊ��(�տ���)
              --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(max(p.pper)),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --��Ʊ��(���Ʊ��ť����Ա),��վ��Ʊsystem
             NULL MEMO20, --Ԥ��
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(NVL(RLSL, 0)),
                    nvl(max(pp.ppsl),
                    (MAX(DECODE(P.PMID, P.PPRIID, P.PPAYMENT, 0)) /
                    (MAX(RD.DJ1) + FGETSJWSF(MAX(MIPFID), MAX(P.PPRIID)))))) N1, --Ӧ��ˮ�� 2016.10.18  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
             FGETHSCODE(MAX(P.PMID)) N2, --���ջ���
             NULL N3, --��ֵ3
             NULL N4, --��ֵ4
             NULL N5, --��ֵ5
             NULL N6, --��ֵ6
             NULL N7, --��ֵ7
             NULL N8, --��ֵ8
             NULL N9, --��ֵ9
             MAX(P.PPRIID) MICODE, --�ͻ�����
             --DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y', MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --Ʊ������
             (CASE WHEN FGETIFBJZY(MAX(P.PPRIID))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21') THEN MAX(RLCNAME) ELSE MAX(MSP.TINAME) END ) KPNAME, --Ʊ������
             NULL MIUIID, --���պ�
             DECODE(FGETIFBJZY(MAX(P.PPRIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --��Ʊ��ַ
             NULL KPZH, --�˺�
             NULL KPKHM, --������
             NULL KPKHYH, --��������
             NULL KPSKZH, --��˾�տ��˺�
             NULL KPSKHM, --��˾�տ���
             NULL KPSKYH, --��˾�տ�����
             NULL KPCBJQ, --��������
             SYSDATE KPRQ, --��Ʊ����
             CASE
               WHEN MIN(RL.RLSCRRLMONTH) <> MAX(RL.RLSCRRLMONTH) THEN
                MIN(RL.RLSCRRLMONTH) || '-' || MAX(RL.RLSCRRLMONTH)
               ELSE
                MAX(RL.RLSCRRLMONTH)
             END KPZWMONTH, --�����·�
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --��Ʊ�·�
             MAX(fgetopername(P.PPER)) KPSFY, --�շ�Ա
             FGETBFRPER(MAX(MIBFID)) KPCBY, --����Ա
             FGETPBOPER KPDYY, --��ӡԱ
             MIN(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                       -- '-',
                       null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                              -- '-',
                              null,
                               RL.RLSCODE))) KPQM, --����
             MAX(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                        --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                              -- '-',
                              null,
                               RL.RLECODE))) KPZM, --ֹ��
             SUM(RL.RLREADSL) KPCBSL, --����ˮ��
             SUM(RL.RLADDSL) KPTZSL, --����ˮ��
             SUM(RL.RLSL) KPSSSL, --ʵ��ˮ��
             SUM(DECODE(M.MIIFTAX, 'N', PSPJE, CHARGE2)) KPJE, --Ӧ���ܽ��
             NULL KPJTDJ1, --һ�׵���
             NULL KPJTDJ2, --���׵���
             NULL KPJTDJ3, --���׵���
             SUM(RD.USE_R1) KPJTSL1, --һ��ˮ��
             SUM(RD.USE_R2) KPJTSL2, --����ˮ��
             SUM(RD.USE_R3) KPJTSL3, --����ˮ��
             SUM(RD.CHARGE_R1) KPJTJE1, --һ�׽��
             SUM(RD.CHARGE_R2) KPJTJE2, --���׽��
             SUM(RD.CHARGE_R3) KPJTJE3, --���׽��
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(RD.CHARGE1),
                    nvl(max(pp.ppsl*pp.ppsfdj),
                    SUM(RD.CHARGE1)))
                     KPJE1, --���1
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(RD.CHARGE2),
                    nvl(max(pp.ppsl*pp.ppwsfdj),
                    SUM(RD.CHARGE2))) KPJE2, --���2
             SUM(RD.CHARGE3) KPJE3, --���3
             SUM(RD.CHARGE4) KPJE4, --���4
             SUM(RD.CHARGE5) KPJE5, --���5
             SUM(RD.CHARGE6) KPJE6, --���6
             SUM(RD.CHARGE7) KPJE7, --���7
             NULL KPJE8, --���8
             NULL KPJE9, --���9
             NULL RLID,
             MAX(CASE
                   WHEN P.PMID = P.PPRIID THEN
                    P.PID
                   ELSE
                    '0'
                 END) PID,
             MAX(P.PDATE) KPSQCBRQ --���ڳ�������
        FROM PAYMENT P left join payment_paid pp on pid = ppid
        LEFT JOIN RECLIST RL
          ON P.PID = RL.RLPID
        LEFT JOIN VIEW_RECLIST_CHARGE RD
          ON RD.RDID = RL.RLID
        LEFT JOIN METERINFOSP MSP
          ON P.PMID = MSP.MIID
          , VIEW_METER_PROP M, INVPARMTERMP T
       WHERE P.PPRIID = M.MIID
         AND F_GETIFPRINT(P.PMID) <> 'N'
         AND P.PREVERSEFLAG = 'N'
         AND P.PTRANS <> 'K' --Ԥ��ֿ۲���Ҫ��ӡ��Ʊ 20150410 HB ����ձ�3088575144��ӡ�������ѽ��ΪԤ��ֿ۵Ľ��
         AND P.PBATCH = T.PBATCH
       GROUP BY P.PBATCH,M.miiftax;

  BEGIN
    OPEN C_INV;
    LOOP
      FETCH C_INV
        INTO V_INV;
      EXIT WHEN C_INV%NOTFOUND OR C_INV%NOTFOUND IS NULL;
      --��֯��Ʊ��ϸ������
      SP_GET_INV_DETAIL(V_INV.BATCH, P_PRINTTYPE, V_INV);
      --���뷢Ʊ��Ϣ
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --���뷢Ʊ��ϸ
      INSERT INTO INV_DETAILTEMP_SP
        SELECT V_INV.ID,
               NULL,
               RLID,
               RLPID,
               RLMID,
               RL.RLCNAME,
               RL.RLPBATCH,
               NULL,
               NULL
          FROM RECLIST RL
         WHERE RL.RLPID = V_INV.PID;
    END LOOP;
    NULL;
  END;

  --��Ʊ����Դ
  PROCEDURE SP_SWAPINVFP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         ) IS
  BEGIN
    NULL;
  END;

  --Ԥ����Ʊ����Դ
  PROCEDURE SP_SWAPINVYKHP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           ) IS
  BEGIN
    NULL;
  END;

  --Ԥ����Ʊ����Դ
  PROCEDURE SP_SWAPINVYKFP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --��Ʊ��ˮ��
             '' ISID, --��Ʊ��ˮ��
             '' ISPCISNO, --Ʊ������||����
             CASE
               WHEN P_SLTJ = 'YYSF' THEN
                '1'
               WHEN P_SLTJ = 'WX' THEN
                '2'
               WHEN P_SLTJ = 'QYMH' THEN
                '3'
               ELSE
                '0'
             END DYFS, --��ӡ��ʽ(0.��̨������1. ��̨����2.΢�����죬3.�Ż���վ����)
             0 PRINTNUM, --��ӡ����
             '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
             NULL FKFS, --��������(XJ �ֽ�,ZP,֧Ʊ
             'L' CPLX, --��Ʊ���ͣ�P,ʵ�ճ���,L��Ӧ�ճ��ˣ�
             'YF' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
             MAX(RLMICOLUMN2) PPBATCH, --��ӡ����
             NULL BATCH, --ʵ������
             'N' FLAG, --���˱�־
             SUM(RLJE) FKJE, --������
             SUM(RLJE) XZJE, --���˽��
             0 ZNJ, --���ɽ�
             0 SXF, --������
             0 JMJE, --������
             0 QCSAVING, --�ϴν��
             0 QMSAVING, --���ν��
             0 BQSAVING, --����Ԥ�淢��
             '' CZPER, --������Ա
             '' CZDATE, --��������
             NULL JZDID, --���˵���ˮ
             MAX(RLREVERSEFLAG) REVERSEFLAG, --������־��NΪ������YΪ������
             'Ԥ����Ʊ' STATUSMEMO, --״̬ԭ��
             MAX(RD.DJ) DJ, --�ܵ���
             --FUN_GETJTDQDJ(MAX(MIPFID), MAX(MIPRIID), MAX(MIID), '1') DJ1, --ˮ��
             --FGETWSFSS(MAX(MI.MIID)) DJ2, --������ˮ��   20160715 WLJ ȡ��ˮ��ʵ�յ���
             max(rd.dj1) dj1,
             max(rd.dj2) dj2,
             MAX(RD.DJ3) DJ3, --����3  ���ӷ�
             MAX(RD.DJ4) DJ4, --����4
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ1)
               ELSE
                NULL
             END) DJ5, --����5
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ2)
               ELSE
                NULL
             END) DJ6, --����6
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ3)
               ELSE
                NULL
             END) DJ7, --����7
             FGETSF(MAX(MIPFID)) DJ8, --���ô��û���ǰ��ˮ��
             FGETWSF(MAX(MIPFID)) DJ9, --���ô��û���ǰ��ˮ��
             NULL MEMO03, --��ע3
             NULL MEMO04, --��ע4
             NULL MEMO05, --��ע5
             NULL MEMO06, --��ע6
             NULL MEMO07, --��ע7
             NULL MEMO08, --��ע8
             NULL MEMO09, --��ע9
             FGETMETERINFO(RLPRIMCODE, 'CINAME2') MEMO10, --��Ŀ����
             /*(CASE WHEN MAX(MICHARGETYPE)='M' THEN 
                        '�˿��ţ�'|| FGETNEWCARDNO(MAX(RL.RLMID)) 
                        ELSE '' END) MEMO11, --���˿���*/
             FGETNEWCARDNO(MAX(RL.RLMID)) MEMO11, --���˿���
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') THEN
                FGETSYSCHARLIST('�������',
                                FGETINVMEMO(MAX(RL.RLID), 'RLINVMEMO'))
               ELSE
                NULL
             END) MEMO12, --��Ʊ��ע ׷�����
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') THEN
                FGETINVMEMO(MAX(RL.RLID), 'RLMEMO')
               ELSE
                NULL
             END) MEMO13, --��Ʊ��ע
             NULL MEMO14, --��ע14
             --max(decode(rltrans,'u','v',rltrans)) MEMO15, --��ע15(����\����\Ӫ��\�ͷ�\����,����ӡ��ά�����ַ)
             max(CASE WHEN rltrans IN ('13','u','21','14','v','23') THEN
                           'v'
                      ELSE
                        rltrans
                      END) MEMO15, --��ע15(����\����\Ӫ��\�ͷ�\����,����ӡ��ά�����ַ),��ֵ'v'����ӡ
             (CASE
               WHEN NVL(mi.miiftax,'N') = 'Y' or MAX(RLTRANS) IN ('13', '14', '21','u','v') THEN
                'N'
               ELSE
                FGETINVEWM(RL.RLID, 'L')
             END)  MEMO16, --��ά��
             --decode(mi.miiftax,'N', FGETINVEWM(RL.RLID, 'L'),'N') MEMO16, --��ά��
             --FGETINVEWM(RL.RLID, 'L') MEMO16, --��ά��
             NULL MEMO17, --Ԥ��
             /*(SELECT MAX(FGETOPERNAME(BFRPER))
                FROM BOOKFRAME
               WHERE BFID = (SELECT MAX(MIBFID)
                               FROM METERINFO
                              WHERE MIID = RLPRIMCODE)) MEMO18, --������
             CASE
               WHEN MAX(RLTRANS) = '21' THEN
                FGETSMFNAME(FGETOPERDEPT(FGETPBOPER))
               ELSE
                FGETSMFNAME(MAX(RLSMFID))
             END MEMO19, --��Ʊ��λ*/

             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'U','v') and RLYSCHARGETYPE='M' THEN  --����
                     --�û����ڵ���
                     --FGETSMFNAME(MAX(RL.RLSMFID))
                     fgetsysmanapara(SUBSTR(MAX(RL.RLSMFID),1,4),'FPFHR')
                   WHEN
                     RL.RLTRANS = '13' THEN  --����
                     --�û����ڵ���
                     --FGETSMFNAME(MAX(RL.RLSMFID))
                     fgetsysmanapara(SUBSTR(MAX(RL.RLSMFID),1,4),'FPFHR')
                   WHEN
                     RL.RLTRANS = 'u' THEN  --����ˮ��
                     (select MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --����
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'v' THEN  --������ˮ
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = '23' THEN  --Ӫ����
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
              END) MEMO18, --������
             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'u','v') and RLYSCHARGETYPE='M' THEN  --����
                     --��¼��ӡ��Ա����վ��Ʊsystem
                    MAX(CASE WHEN P_SLTJ = 'YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END)
                   WHEN
                     RL.RLTRANS = '13' THEN  --����
                     --��¼��ӡ��Ա
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --����
                     --��¼��ӡ��Ա
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = 'v' THEN  --������ˮ
                     --��¼��ӡ��Ա
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = 'u' THEN  --����ˮ��
                     --��¼��ӡ��Ա
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = '23' THEN  --Ӫ����
                     --��¼��ӡ��Ա
                     MAX(fgetopername(fgetoperid))
              END) MEMO19, --��Ʊ��
             NULL MEMO20, --Ԥ��
             NULL N1, --��ֵ1
             NULL N2, --���ջ���
             NULL N3, --��ֵ3
             NULL N4, --��ֵ4
             NULL N5, --��ֵ5
             NULL N6, --��ֵ6
             NULL N7, --��ֵ7
             NULL N8, --��ֵ8
             NULL N9, --��ֵ9
             MAX(RLPRIMCODE) MICODE, --�ͻ�����
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y',MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --Ʊ������
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --��Ʊ��ַ
             (CASE WHEN FGETIFBJZY(MAX(RL.RLPRIMCODE))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21','23') THEN MAX(RLCNAME) ELSE MAX(MSP.TINAME) END ) KPNAME, --Ʊ������
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y',MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --Ʊ������
             NULL MIUIID, --���պ�
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --��Ʊ��ַ
             (CASE WHEN FGETIFBJZY(MAX(RL.RLPRIMCODE))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21','23') THEN MAX(RLCADR) ELSE MAX(MSP.TIADDR) END ) KPDZ, --��Ʊ��ַ
             NULL KPZH, --�˺�
             NULL KPKHM, --������
             NULL KPKHYH, --��������
             NULL KPSKZH, --��˾�տ��˺�
             NULL KPSKHM, --��˾�տ���
             NULL KPSKYH, --��˾�տ�����
             NULL KPCBJQ, --��������
             SYSDATE KPRQ, --��Ʊ����
             CASE
               WHEN MIN(RL.RLSCRRLMONTH) <> MAX(RL.RLSCRRLMONTH) THEN
                MIN(RL.RLSCRRLMONTH) || '-' || MAX(RL.RLSCRRLMONTH)
               ELSE
                MAX(RL.RLSCRRLMONTH)
             END KPZWMONTH, --�����·�
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --��Ʊ�·�
             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'U','v') and RLYSCHARGETYPE='M' THEN  --����
                     MAX(fgetopername(RLRPER))  --�շ�ԱΪ����Ա
                   WHEN
                     RL.RLTRANS = '13' THEN  --����
                     --���ݴ�����Ա
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --����
                     --���ݴ�����Ա
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'v' THEN  --������ˮ
                     --���ݴ�����Ա
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'u' THEN  --����ˮ��
                     --���ݴ�����Ա
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = '23' THEN  --Ӫ����
                     --���ݴ�����Ա
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
              END) KPSFY, --�շ�Ա
             --FGETINVMEMO(MAX(RL.RLID), 'BFPPER') KPSFY, --�շ�Ա
             FGETBFRPER(MAX(MIBFID)) KPCBY, --����Ա
             FGETPBOPER KPDYY, --��ӡԱ
             MIN(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                        --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                               --'-',
                        null,
                               RL.RLSCODE))) KPQM, --����
             MAX(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                       --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                               --'-',
                        null,
                               RL.RLECODE))) KPZM, --ֹ��
             SUM(RL.RLREADSL) KPCBSL, --����ˮ��
             SUM(RL.RLADDSL) KPTZSL, --����ˮ��
             SUM(RL.RLSL) KPSSSL, --ʵ��ˮ��
             SUM(DECODE(MI.MIIFTAX, 'N', RLJE, CHARGE2)) KPJE, --Ӧ���ܽ��
             NULL KPJTDJ1, --һ�׵���
             NULL KPJTDJ2, --���׵���
             NULL KPJTDJ3, --���׵���
             SUM(RD.USE_R1) KPJTSL1, --һ��ˮ��
             SUM(RD.USE_R2) KPJTSL2, --����ˮ��
             SUM(RD.USE_R3) KPJTSL3, --����ˮ��
             SUM(RD.CHARGE_R1) KPJTJE1, --һ�׽��
             SUM(RD.CHARGE_R2) KPJTJE2, --���׽��
             SUM(RD.CHARGE_R3) KPJTJE3, --���׽��
             SUM(RD.CHARGE1) KPJE1, --���1
             SUM(RD.CHARGE2) KPJE2, --���2
             SUM(RD.CHARGE3) KPJE3, --���3
             SUM(RD.CHARGE4) KPJE4, --���4
             SUM(RD.CHARGE5) KPJE5, --���5
             SUM(RD.CHARGE6) KPJE6, --���6
             SUM(RD.CHARGE7) KPJE7, --���7
             NULL KPJE8, --���8
             NULL KPJE9, --���9
             RL.RLID RLID,
             NULL PID,
             NULL KPSQCBRQ --���ڳ�������
        FROM RECLIST             RL,
             VIEW_RECLIST_CHARGE RD,
             METERINFO           MI
             LEFT JOIN METERINFOSP MSP
            ON MI.MIID = MSP.MIID
            ,INVPARMTERMP        T

       WHERE RD.RDID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND RL.RLID = T.RLID
            --AND F_GETIFPRINT(RLMID) <> 'N'
       --  AND RLPAIDFLAG = 'N'
      --AND (RLOUTFLAG = 'Y' OR NVL(RLIFINV, 'N') = 'Y')
       GROUP BY RL.RLID, RL.RLPRIMCODE, T.ROWID,MI.miiftax,RL.RLTRANS,rl.RLYSCHARGETYPE,RL.Rlscrrlid
       ORDER BY T.ROWID;

  BEGIN
    OPEN C_INV;
    LOOP
      FETCH C_INV
        INTO V_INV;
      EXIT WHEN C_INV%NOTFOUND OR C_INV%NOTFOUND IS NULL;
      --��֯��Ʊ��ϸ������
      SP_GET_INV_DETAIL(V_INV.RLID, P_PRINTTYPE, V_INV);
      --���뷢Ʊ��Ϣ
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --���뷢Ʊ��ϸ
      INSERT INTO INV_DETAILTEMP_SP
        SELECT V_INV.ID,
               NULL,
               RLID,
               RLPID,
               RLMID,
               RL.RLCNAME,
               RL.RLPBATCH,
               NULL,
               NULL
          FROM RECLIST RL
         WHERE RL.RLID = V_INV.RLID;
    END LOOP;
    NULL;
  END;

  --��ӡ˰Ʊƾ֤������Ʊ�ţ�
  PROCEDURE SP_PREPRINT_SPPZ(P_PRINTTYPE IN VARCHAR2,
                             P_INVTYPE   IN VARCHAR2,
                             P_INVNO     IN VARCHAR2,
                             O_CODE      OUT VARCHAR2,
                             O_ERRMSG    OUT VARCHAR2) IS
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    ERR_OTHERS EXCEPTION;
    V_RCOUNT NUMBER := 0;
    INVPT INVPARMTERMP%ROWTYPE;
    --������ӡ�����¼
    CURSOR C_INVLIST IS
      SELECT *
        FROM INVPARMTERMP;
  BEGIN
    O_CODE   := '00';
    O_ERRMSG := NULL;

    --��ʼ����ʱ��������
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;
    --����Ƿ�����Ѵ�ӡƾ֤
    --SELECT * FROM INVPARMTERMP
    V_PRC_MSG := '��֯��ӡ�����쳣��';
    OPEN C_INVLIST;
    LOOP
      FETCH C_INVLIST
        INTO INVPT;
      EXIT WHEN C_INVLIST%NOTFOUND OR C_INVLIST%NOTFOUND IS NULL;
           NULL;
           IF INVPT.RLID IS NOT NULL THEN
             --Ӧ�տ�Ʊ
             SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE RLID=INVPT.RLID;
             IF V_RCOUNT=1 THEN
                --�ѿ�Ʊ��ֱ��װ������
                INSERT INTO INV_INFOTEMP_SP
                SELECT * FROM INV_INFO_PZ WHERE RLID=INVPT.RLID;
                INSERT INTO INV_DETAILTEMP_SP
                SELECT * FROM INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE RLID=INVPT.RLID);
             ELSE
               --���ܴ��ڶ���ƾ֤��¼���ᵼ�¿�Ʊ�쳣��ɾ���ظ���¼������װ��
               DELETE INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE RLID=INVPT.RLID);
               DELETE INV_INFO_PZ WHERE RLID=INVPT.RLID;
               IF P_PRINTTYPE = C_Ԥ�� THEN
                  SP_SWAPINVYC(P_PRINTTYPE);
                ELSIF P_PRINTTYPE = C_��Ʊ THEN
                  SP_SWAPINVHP(P_PRINTTYPE);
                ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
                  SP_SWAPINVYKFP(P_PRINTTYPE);
                ELSE
                  V_PRC_MSG := '�ݲ�֧�ֵĿ�Ʊ���ͣ�';
                  RAISE ERR_OTHERS;
                END IF;
               NULL;
             END IF;

           ELSIF INVPT.PBATCH IS NOT NULL THEN
                 --ʵ�տ�Ʊ
                 SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                 IF V_RCOUNT=1 THEN
                    --�ѿ�Ʊ��ֱ��װ������
                    INSERT INTO INV_INFOTEMP_SP
                    SELECT * FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                    INSERT INTO INV_DETAILTEMP_SP
                    SELECT * FROM INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH);
                 ELSE
                   --���ܴ��ڶ���ƾ֤��¼���ᵼ�¿�Ʊ�쳣��ɾ���ظ���¼������װ��
                   DELETE INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH);
                   DELETE INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                   IF P_PRINTTYPE = C_Ԥ�� THEN
                      SP_SWAPINVYC(P_PRINTTYPE);
                    ELSIF P_PRINTTYPE = C_��Ʊ THEN
                      SP_SWAPINVHP(P_PRINTTYPE);
                    ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
                      SP_SWAPINVYKFP(P_PRINTTYPE);
                    ELSE
                      V_PRC_MSG := '�ݲ�֧�ֵĿ�Ʊ���ͣ�';
                      RAISE ERR_OTHERS;
                    END IF;
                   NULL;
                 END IF;
           END IF;
           SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE ID IN (SELECT ID FROM INV_INFOTEMP_SP);
           IF V_RCOUNT = 0 THEN
           --�洢ƾ֤��ӡ��¼
              INSERT INTO INV_INFO_PZ
              SELECT * FROM INV_INFOTEMP_SP;
              INSERT INTO INV_DETAIL_PZ
              SELECT * FROM INV_DETAILTEMP_SP;
            END IF;
    END LOOP;
    CLOSE C_INVLIST;



    SELECT COUNT(1) INTO V_RCOUNT FROM INV_INFOTEMP_SP;
    IF V_RCOUNT = 0 THEN
      V_PRC_MSG := '�޿ɴ�ӡ���ݣ����飡';
      RAISE ERR_OTHERS;
    END IF;


  EXCEPTION
    WHEN ERR_OTHERS THEN
      O_CODE   := '99';
      O_ERRMSG := V_PRC_MSG;
      ROLLBACK;
  END;

  --��ά��ƽ̨���ӷ�Ʊ
  PROCEDURE SP_PREPRINT_EINVOICE(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                                 ) IS
    V_STEP     NUMBER; --��������ȱ������������
    V_PRC_CODE VARCHAR2(10);
    V_PRC_MSG  VARCHAR2(400); --��������Ϣ�������������
    ERR_OTHERS EXCEPTION;
    V_IFPRINT VARCHAR2(1);
    VCOUNT     NUMBER;
    V_PTYPE    VARCHAR2(300);
    V_AUTOFLAG     VARCHAR2(10); --�Զ���Ʊ��־
    V_BFNUM  NUMBER; --�ֶ���Ʊ������
    V_TIME   VARCHAR2(50);
    V_SS     NUMBER;
    V_PID    VARCHAR(100);
  BEGIN
    --����(���ſ�Ʊ��һ�δ���һ�ŷ�Ʊ)
    --NSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms,memo1) Values('','0170509792','','N','R');
    --INSERT Into INVPARMTERMP(rlid,ifsms) Values('0313077670','N');

    O_CODE   := '00';
    O_ERRMSG := NULL;
    V_STEP   := 10;

    --���ӷ�Ʊȫ�ֿ���
    V_PRC_MSG := '���ӷ�Ʊ��ͣ����!';
    IF NVL(fsyspara('1116'),'N') <> 'Y' THEN
       RAISE ERR_OTHERS;
    END IF;

    --�����ֹ�����
    --�ж��ֶ����������Զ�����Ϊ�ֹ�������
    --�����Ʊ��������ȴ������Ƶȴ�ʱ������
    --�Ŷӳɹ������������ж�
    --��Ʊ�ɹ���ʧ�ܣ��ͷ��ж�
    IF NVL(fsyspara('1120'),'N') = 'Y' THEN
       NULL;
       SELECT NVL(MAX(MEMO2),'N') INTO V_AUTOFLAG FROM INVPARMTERMP;
       IF V_AUTOFLAG <> 'Y' THEN --�Զ���Ʊ��־
          --�ֹ���Ʊ
          --��鲢����
          V_TIME := TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS');
          LOOP
            SELECT COUNT(*) INTO V_BFNUM FROM PAY_EINV_JOB_LOG WHERE PERRID='9';
            IF fsyspara('1119') <= V_BFNUM THEN
               --����������ȴ�
               --���ȴ�ʱ��
               select ceil((sysdate - TO_DATE(V_TIME,'YYYYMMDD HH24:MI:SS')) * 24 * 60 * 60) INTO V_SS FROM DUAL;
               IF fsyspara('1121') <= V_SS THEN --��ʱ
                 UPDATE PAY_EINV_JOB_LOG SET PERRID='1' WHERE PERRID='9';
                 COMMIT;
                 V_PRC_MSG := '���ӷ�Ʊ����æ����Ʊ����ʱ!';
                 RAISE ERR_OTHERS;
               END IF;
               DBMS_LOCK.SLEEP(1);
            ELSE
              --�����ж����ȼ�
              IF P_PRINTTYPE = C_Ԥ�� OR P_PRINTTYPE = C_��Ʊ THEN
                 SELECT NVL(MAX(pbatch),'N') INTO V_PID FROM INVPARMTERMP;
              ELSE
                 SELECT NVL(MAX(RLID),'N') INTO V_PID FROM INVPARMTERMP;
              END IF;
              P_QUEUE(V_PID,'INSERT');
              EXIT; --����δ����ͨ��
            END IF;
          END LOOP;

       END IF;
    END IF;
    --�ؿ���������Ʊ��ɾ��ԭƱ������
    --�ؿ�R��������Ʒ��ˮ��Ψһ��1���糧��Ʊ��ʾʧ�ܣ�2����Ʊ�����쳣��
    --����A��ˮ˾�ѿ�Ʊ���糧δ�յ�
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:��ӡ���Ͳ���Ϊ��!';
    IF P_PRINTTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:��Ʊ�����Ϊ��!';
    IF P_INVTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:' || FGETSCLNAME('��Ʊ���', P_INVTYPE) ||
                 '��Ʊ�Ų���Ϊ��!';
    IF P_INVNO IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;

    V_PRC_MSG := '�������ظ����ߵ��ӷ�Ʊ!';
    IF NOT (V_PTYPE='R' OR V_PTYPE='A') THEN
      IF P_PRINTTYPE = C_Ԥ�� OR P_PRINTTYPE = C_��Ʊ THEN
        SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.PPBATCH=IP.PBATCH;
      ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
            SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.RLID=IP.RLID;
      END IF;
      IF VCOUNT > 0 THEN
         RAISE ERR_OTHERS;
      END IF;
    END IF;
    --�����ж��������߻����ӳٿ���
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')) INTO V_IFPRINT FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
    END;
    IF V_IFPRINT = 'L' THEN
      --�ӳٿ��ߣ���ʱֻ֧�ְ�Ӧ����ˮ�ӳٿ�Ʊ
      FOR INV IN (SELECT RLID FROM INVPARMTERMP) LOOP
        SP_EINVOICE_DELAY(INV.RLID);
      END LOOP;
      RETURN;
    END IF;

    V_STEP    := 20;
    V_PRC_MSG := '��֯��Ʊ����!';

    --��ʼ����Ʊ��ʱ��������
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;

    IF /*V_PTYPE ='R' OR*/ V_PTYPE = 'A' THEN
       NULL;
       --ɾ��ԭƱ��֯����
       SP_DELINV(P_PRINTTYPE);
    END IF;
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('','0170508084','','N');
    V_PRC_MSG := '��֯��ӡ�����쳣��';
    IF P_PRINTTYPE = C_Ԥ�� THEN
      SP_SWAPINVYC(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_��Ʊ THEN
      SP_SWAPINVHP(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
      SELECT COUNT(*) INTO VCOUNT
      FROM RECLIST RL,METERINFO MI,INVPARMTERMP IPT
      WHERE RLMID = MIID
      AND RL.RLID = IPT.RLID
      AND RL.RLTRANS='u'
      AND MI.MIIFTAX='Y';
      IF VCOUNT>0 THEN
         V_PRC_MSG := '�û�����ֵ˰�û�,�������߻���ˮ�ѵ�Ʊ,���飡';
         RAISE ERR_OTHERS;
      END IF;
      SP_SWAPINVYKFP(P_PRINTTYPE, P_SLTJ);
    ELSE
      V_PRC_MSG := '�ݲ�֧�ֵĿ�Ʊ���ͣ�';
      RAISE ERR_OTHERS;
    END IF;

    --���ɿ�Ʊ��¼
    V_STEP    := 30;
    V_PRC_MSG := '��֯��Ʊ����!';
    PG_EWIDE_EINVOICE.P_EINVOICE(V_PRC_CODE, V_PRC_MSG, P_SLTJ);
    IF V_PRC_CODE <> '0000' THEN
      RAISE ERR_OTHERS;
    END IF;
    P_QUEUE(V_PID,'UPDATE');
  EXCEPTION
    WHEN ERR_OTHERS THEN
      O_CODE := NVL(V_PRC_CODE, '99');
      IF SQLERRM <> 'User-Defined Exception' THEN
        O_ERRMSG := V_PRC_MSG || '|' || SQLERRM;
      ELSE
        O_ERRMSG := V_PRC_MSG;
      END IF;
      ROLLBACK;
      P_QUEUE(V_PID,'UPDATE');
      COMMIT;
  END;
  
  PROCEDURE SP_PREPRINT_EINVOICEtest(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2,
                                 P_RLID    IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                                 ) IS
    V_STEP     NUMBER; --��������ȱ������������
    V_PRC_CODE VARCHAR2(10);
    V_PRC_MSG  VARCHAR2(400); --��������Ϣ�������������
    ERR_OTHERS EXCEPTION;
    V_IFPRINT VARCHAR2(1);
    VCOUNT     NUMBER;
    V_PTYPE    VARCHAR2(300);
    V_AUTOFLAG     VARCHAR2(10); --�Զ���Ʊ��־
    V_BFNUM  NUMBER; --�ֶ���Ʊ������
    V_TIME   VARCHAR2(50);
    V_SS     NUMBER;
    V_PID    VARCHAR(100);
  BEGIN
    --����(���ſ�Ʊ��һ�δ���һ�ŷ�Ʊ)
    IF P_PBATCH IS NOT NULL THEN
       INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms,memo1) Values('',P_PBATCH,'','N','R');
    ELSIF P_RLID IS NOT NULL THEN
       INSERT Into INVPARMTERMP(rlid,ifsms,memo1) Values(P_RLID,'N','R');      
    END IF;
    
    --

    O_CODE   := '00';
    O_ERRMSG := NULL;
    V_STEP   := 10;

    --���ӷ�Ʊȫ�ֿ���
    V_PRC_MSG := '���ӷ�Ʊ��ͣ����!';
    IF NVL(fsyspara('1116'),'N') <> 'Y' THEN
       RAISE ERR_OTHERS;
    END IF;

    --�����ֹ�����
    --�ж��ֶ����������Զ�����Ϊ�ֹ�������
    --�����Ʊ��������ȴ������Ƶȴ�ʱ������
    --�Ŷӳɹ������������ж�
    --��Ʊ�ɹ���ʧ�ܣ��ͷ��ж�
    IF NVL(fsyspara('1120'),'N') = 'Y' THEN
       NULL;
       SELECT NVL(MAX(MEMO2),'N') INTO V_AUTOFLAG FROM INVPARMTERMP;
       IF V_AUTOFLAG <> 'Y' THEN --�Զ���Ʊ��־
          --�ֹ���Ʊ
          --��鲢����
          V_TIME := TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS');
          LOOP
            SELECT COUNT(*) INTO V_BFNUM FROM PAY_EINV_JOB_LOG WHERE PERRID='9';
            IF fsyspara('1119') <= V_BFNUM THEN
               --����������ȴ�
               --���ȴ�ʱ��
               select ceil((sysdate - TO_DATE(V_TIME,'YYYYMMDD HH24:MI:SS')) * 24 * 60 * 60) INTO V_SS FROM DUAL;
               IF fsyspara('1121') <= V_SS THEN --��ʱ
                 UPDATE PAY_EINV_JOB_LOG SET PERRID='1' WHERE PERRID='9';
                 COMMIT;
                 V_PRC_MSG := '���ӷ�Ʊ����æ����Ʊ����ʱ!';
                 RAISE ERR_OTHERS;
               END IF;
               DBMS_LOCK.SLEEP(1);
            ELSE
              --�����ж����ȼ�
              IF P_PRINTTYPE = C_Ԥ�� OR P_PRINTTYPE = C_��Ʊ THEN
                 SELECT NVL(MAX(pbatch),'N') INTO V_PID FROM INVPARMTERMP;
              ELSE
                 SELECT NVL(MAX(RLID),'N') INTO V_PID FROM INVPARMTERMP;
              END IF;
              P_QUEUE(V_PID,'INSERT');
              EXIT; --����δ����ͨ��
            END IF;
          END LOOP;

       END IF;
    END IF;
    --�ؿ���������Ʊ��ɾ��ԭƱ������
    --�ؿ�R��������Ʒ��ˮ��Ψһ��1���糧��Ʊ��ʾʧ�ܣ�2����Ʊ�����쳣��
    --����A��ˮ˾�ѿ�Ʊ���糧δ�յ�
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:��ӡ���Ͳ���Ϊ��!';
    IF P_PRINTTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:��Ʊ�����Ϊ��!';
    IF P_INVTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '��֯��Ʊ���ݲ����쳣:' || FGETSCLNAME('��Ʊ���', P_INVTYPE) ||
                 '��Ʊ�Ų���Ϊ��!';
    IF P_INVNO IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;

    V_PRC_MSG := '�������ظ����ߵ��ӷ�Ʊ!';
    IF NOT (V_PTYPE='R' OR V_PTYPE='A') THEN
      IF P_PRINTTYPE = C_Ԥ�� OR P_PRINTTYPE = C_��Ʊ THEN
        SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.PPBATCH=IP.PBATCH;
      ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
            SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.RLID=IP.RLID;
      END IF;
      IF VCOUNT > 0 THEN
         RAISE ERR_OTHERS;
      END IF;
    END IF;
    --�����ж��������߻����ӳٿ���
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')) INTO V_IFPRINT FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
    END;
    IF V_IFPRINT = 'L' THEN
      --�ӳٿ��ߣ���ʱֻ֧�ְ�Ӧ����ˮ�ӳٿ�Ʊ
      FOR INV IN (SELECT RLID FROM INVPARMTERMP) LOOP
        SP_EINVOICE_DELAY(INV.RLID);
      END LOOP;
      RETURN;
    END IF;

    V_STEP    := 20;
    V_PRC_MSG := '��֯��Ʊ����!';

    --��ʼ����Ʊ��ʱ��������
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;

    IF /*V_PTYPE ='R' OR*/ V_PTYPE = 'A' THEN
       NULL;
       --ɾ��ԭƱ��֯����
       SP_DELINV(P_PRINTTYPE);
    END IF;
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('','0170508084','','N');
    V_PRC_MSG := '��֯��ӡ�����쳣��';
    IF P_PRINTTYPE = C_Ԥ�� THEN
      SP_SWAPINVYC(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_��Ʊ THEN
      SP_SWAPINVHP(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_Ԥ����Ʊ THEN
      SELECT COUNT(*) INTO VCOUNT
      FROM RECLIST RL,METERINFO MI,INVPARMTERMP IPT
      WHERE RLMID = MIID
      AND RL.RLID = IPT.RLID
      AND RL.RLTRANS='u'
      AND MI.MIIFTAX='Y';
      IF VCOUNT>0 THEN
         V_PRC_MSG := '�û�����ֵ˰�û�,�������߻���ˮ�ѵ�Ʊ,���飡';
         RAISE ERR_OTHERS;
      END IF;
      SP_SWAPINVYKFP(P_PRINTTYPE, P_SLTJ);
    ELSE
      V_PRC_MSG := '�ݲ�֧�ֵĿ�Ʊ���ͣ�';
      RAISE ERR_OTHERS;
    END IF;

    --���ɿ�Ʊ��¼
    V_STEP    := 30;
    V_PRC_MSG := '��֯��Ʊ����!';
    PG_EWIDE_EINVOICE.P_EINVOICE(V_PRC_CODE, V_PRC_MSG, P_SLTJ);
    IF V_PRC_CODE <> '0000' THEN
      RAISE ERR_OTHERS;
    END IF;
    P_QUEUE(V_PID,'UPDATE');
  EXCEPTION
    WHEN ERR_OTHERS THEN
      O_CODE := NVL(V_PRC_CODE, '99');
      IF SQLERRM <> 'User-Defined Exception' THEN
        O_ERRMSG := V_PRC_MSG || '|' || SQLERRM;
      ELSE
        O_ERRMSG := V_PRC_MSG;
      END IF;
      ROLLBACK;
      P_QUEUE(V_PID,'UPDATE');
      COMMIT;
  END;

  --�����ж�
  PROCEDURE P_QUEUE(P_ID      IN VARCHAR2,P_TYPE IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      IF P_ID IS NULL THEN
        RETURN;
      END IF;
      IF P_TYPE ='INSERT' THEN
         INSERT INTO pay_einv_job_log(JOBID,PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT,Ptop)
         values ('',P_ID,'Y',SYSDATE,SYSDATE,'9','','1');
         
      ELSIF P_TYPE ='UPDATE' THEN
        UPDATE pay_einv_job_log
        SET PERRID='1'
        WHERE PBATCH=P_ID AND
              PERRID='9';
      END IF;
      --2����δ����ɾ��
      delete pay_einv_job_log 
      where perrid in ('9') AND
            (sysdate-pstime)*1440>2;
             COMMIT;
    END;
  --ɾ����Ʊ��¼
  PROCEDURE SP_DELINV(P_TYPE IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID VARCHAR2(100);
    V_PBATCH VARCHAR2(100);
    V_ISID VARCHAR2(100);
  BEGIN
    IF P_TYPE='1' OR P_TYPE='2' THEN
      --ʵ�տ�Ʊ
      NULL;
      SELECT MAX(PPBATCH) INTO V_PBATCH FROM INVPARMTERMP;
      --select * from INV_INFO_SP WHERE PPBATCH
      SELECT MAX(IIS.ID),MAX(ISID) INTO V_ID,V_ISID FROM INV_INFO_SP IIS,INVPARMTERMP IP,INV_EINVOICE_ST IES
      WHERE IIS.PPBATCH = IP.PPBATCH AND
            IIS.ID=IES.ID;
      DELETE INV_DETAIL_SP WHERE INVID = V_ID;
      DELETE INV_INFO_SP WHERE PPBATCH = V_PBATCH;
    ELSE
      --Ӧ�տ�Ʊ
      SELECT MAX(RLID) INTO V_PBATCH FROM INVPARMTERMP;
      SELECT MAX(IIS.ID),MAX(ISID) INTO V_ID,V_ISID FROM INV_INFO_SP IIS,INVPARMTERMP IP,INV_EINVOICE_ST IES
      WHERE IIS.Rlid = IP.Rlid AND
            IIS.ID=IES.ID;
      DELETE INV_DETAIL_SP WHERE INVID = V_ID;
      DELETE INV_INFO_SP WHERE RLID = V_PBATCH;
    END IF;
    DELETE INV_EINVOICE_DETAIL_ST WHERE IDID = V_ISID;
    DELETE INV_EINVOICE_ST WHERE ID = V_ID;
    COMMIT;

  END;

  --���ӷ�Ʊ�ӳٿ�Ʊ����
  PROCEDURE SP_EINVOICE_DELAY(V_ID IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    IDE INV_DELAY%ROWTYPE;
  BEGIN
    DELETE FROM INV_DELAY
     WHERE RLID = V_ID
       AND IDSTATUS = '0';
    IDE          := NULL;
    IDE.RLID     := V_ID; --Ӧ����ˮ
    IDE.IDSTATUS := '0'; --��Ʊ״̬��0=�ȴ��У�1=��Ʊ�У���Ʊ����ɾ����¼��
    SELECT NVL(MAX(ID), 0) + 1 INTO IDE.ID FROM INV_DELAY;
    INSERT INTO INV_DELAY VALUES IDE;
    COMMIT;
  END;

  --��������ʱִ�У�����ӡ���У�������Ʊ
  --Ŀǰ�� 5 �߳���ƣ��������Ϊ 0~4
  PROCEDURE SP_EINVOICE_DELAY_JOB(P_ID IN NUMBER) IS
    CURSOR C_LIST IS
      SELECT *
        FROM INV_DELAY
       WHERE IDSTATUS = '0'
         AND MOD(ID, 5) = P_ID
       ORDER BY ID;
    V_LIST   INV_DELAY%ROWTYPE;
    O_CODE   VARCHAR2(100);
    O_ERRMSG VARCHAR2(100);
  BEGIN
    OPEN C_LIST;
    LOOP
      FETCH C_LIST
        INTO V_LIST;
      EXIT WHEN C_LIST%NOTFOUND OR C_LIST%NOTFOUND IS NULL;
      --�ж��Ƿ��ѿ�Ʊ
      IF FGETPRINTNUMFP('RLID', V_LIST.RLID) = 0 THEN
        --��Ʊ
        DELETE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP
          (RLID, IFPRINT, IFSMS)
        VALUES
          (V_LIST.RLID, 'Y', 'N');
        SP_PREPRINT_EINVOICE(P_PRINTTYPE => '4',
                             P_INVTYPE   => 'P',
                             P_INVNO     => 'TZZLS.00000001',
                             O_CODE      => O_CODE,
                             O_ERRMSG    => O_ERRMSG);
        --�ύ�����ӡ��¼
        COMMIT;
      END IF;
      --��Ʊ�ɹ�ɾ����ӡ���м�¼
      DELETE FROM INV_DELAY WHERE ID = V_LIST.ID;
      COMMIT;
    END LOOP;
    CLOSE C_LIST;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_LIST%ISOPEN THEN
        CLOSE C_LIST;
      END IF;
      RAISE;
  END;

  PROCEDURE SP_EINVOICE_DELAY_ATONCE(P_ID IN NUMBER) IS
    CURSOR C_LIST IS
      SELECT *
        FROM INV_DELAY
       WHERE IDSTATUS = '0'
         AND ID = P_ID
       ORDER BY ID;
    V_LIST   INV_DELAY%ROWTYPE;
    O_CODE   VARCHAR2(100);
    O_ERRMSG VARCHAR2(100);
  BEGIN
    OPEN C_LIST;
    LOOP
      FETCH C_LIST
        INTO V_LIST;
      EXIT WHEN C_LIST%NOTFOUND OR C_LIST%NOTFOUND IS NULL;
      --�ж��Ƿ��ѿ�Ʊ
      IF FGETPRINTNUMFP('RLID', V_LIST.RLID) = 0 THEN
        --��Ʊ
        DELETE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP
          (RLID, IFPRINT, IFSMS)
        VALUES
          (V_LIST.RLID, 'Y', 'N');
        SP_PREPRINT_EINVOICE(P_PRINTTYPE => '4',
                             P_INVTYPE   => 'P',
                             P_INVNO     => 'TZZLS.00000001',
                             O_CODE      => O_CODE,
                             O_ERRMSG    => O_ERRMSG);
        --�ύ�����ӡ��¼
        COMMIT;
      END IF;
      --��Ʊ�ɹ�ɾ����ӡ���м�¼
      DELETE FROM INV_DELAY WHERE ID = V_LIST.ID;
      COMMIT;
    END LOOP;
    CLOSE C_LIST;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_LIST%ISOPEN THEN
        CLOSE C_LIST;
      END IF;
      RAISE;
  END;

  --ƾ֤��ϸ��
  PROCEDURE SP_GET_INV_DETAIL(P_ID   IN VARCHAR2,
                              P_TYPE IN VARCHAR2,
                              P_INV  IN OUT INV_INFOTEMP_SP%ROWTYPE) IS
    --��Ʊ
    CURSOR C_CUR1(P_PBATCH IN VARCHAR2) IS
      SELECT RANK() OVER(PARTITION BY RLPRIMCODE, RLMONTH, RLMONTH ORDER BY RLMONTH DESC) VNUM,
             RLPRIMCODE,
             RLMONTH,
             RLMONTH RLSCRRLMONTH,
             MAX(RLMRID) RLMRID,
             MAX(RLCID) RLCID,
             MAX(RLECODE) RLECODE,
             MAX(RLIFTAX) RLIFTAX,
             MAX(RLZNJ) RLZNJ
        FROM PAYMENT, RECLIST
       WHERE PID = RLPID
         AND PBATCH = P_PBATCH
       GROUP BY RLPRIMCODE, RLMONTH
       ORDER BY RLMONTH DESC;
    V_CUR1 C_CUR1%ROWTYPE;

    --��Ʊ
    CURSOR C_CUR2(P_PBATCH     IN VARCHAR2,
                  P_RLPRIMCODE IN VARCHAR2,
                  P_RLMONTH    IN VARCHAR2) IS
      SELECT CONNSTR(RDPFID) RDPFID,
             CONNSTR(RDDJ) RDDJ,
             CONNSTR(RDSL) RDSL,
             CONNSTR(RDZNJ) RDZNJ,
             CONNSTR(WSDJ) WSDJ,
             CONNSTR(WSJE) WSJE,
             TOOLS.FFORMATNUM(SUM(ZZSJE), 2) ZZSJE,
             CONNSTR(RDJE01) RDJE01,
             CONNSTR(RDJE03) RDJE03,
             CONNSTR(RDJE04) RDJE04,
             CONNSTR(RDJE05) RDJE05,
             CONNSTR(RDJE06) RDJE06,
             CONNSTR(RDJE07) RDJE07,
             CONNSTR(RDJE08) RDJE08,
             COUNT(*) CN,
             CONNSTR(JT) JT,
             CONNSTR(TOOLS.FFORMATNUM(RDJE01 + WSJE, 2)) XJ,
             MAX(RDCLASS) RDCLASS,
             MAX(RDDJ) DQRDDJ,
             MAX(WSDJ) DQWSDJ
        FROM (SELECT *
                FROM (SELECT RDPMDID,
                             RDPFID,
                             RDPIID,
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
                             END JT,
                             TOOLS.FFORMATNUM(MAX(NVL(RDDJ, 0)), 2) RDDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDSL,
                                                         0)),
                                              0) RDSL,
                             TOOLS.FFORMATNUM(SUM(NVL(RDZNJ, 0)), 2) RDZNJ,
                             SUM(DECODE(RDPIID, '01', 0, RDJE)) ZZSJE,
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
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         01,
                                                         0,
                                                         MAX(RDDJ)))
                                              OVER(PARTITION BY RDPFID),
                                              2) WSDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDSL,
                                                         0)) *
                                              SUM(DECODE(RDPIID,
                                                         01,
                                                         0,
                                                         MAX(RDDJ)))
                                              OVER(PARTITION BY RDPFID),
                                              2) WSJE
                        FROM RECDETAIL
                       WHERE RDID IN (SELECT RLID
                                        FROM PAYMENT, RECLIST
                                       WHERE PID = RLPID
                                         AND PBATCH = P_PBATCH
                                         AND RLPRIMCODE = P_RLPRIMCODE
                                         AND RLMONTH = P_RLMONTH)
                       GROUP BY RDPMDID, RDPIID, RDPFID, RDCLASS)
               WHERE RDPIID = '01' ) group by RDPMDID, RDPIID, RDPFID, RDCLASS
       ORDER BY RDPMDID, RDPIID, RDPFID, RDCLASS DESC;
    V_CUR2 C_CUR2%ROWTYPE;

    --��Ʊ
    CURSOR C_CUR3(P_RLID IN VARCHAR2) IS
      SELECT CONNSTR(RDPFID) RDPFID,
             CONNSTR(RDDJ) RDDJ,
             CONNSTR(RDSL) RDSL,
             CONNSTR(RDZNJ) RDZNJ,
             CONNSTR(WSDJ) WSDJ,
             CONNSTR(WSJE) WSJE,
             TOOLS.FFORMATNUM(SUM(ZZSJE), 2) ZZSJE,
             CONNSTR(RDJE01) RDJE01,
             CONNSTR(RDJE03) RDJE03,
             CONNSTR(RDJE04) RDJE04,
             CONNSTR(RDJE05) RDJE05,
             CONNSTR(RDJE06) RDJE06,
             CONNSTR(RDJE07) RDJE07,
             CONNSTR(RDJE08) RDJE08,
             COUNT(*) CN,
             CONNSTR(JT) JT,
             CONNSTR(TOOLS.FFORMATNUM(RDJE01 + WSJE, 2)) XJ,
             MAX(RDCLASS) RDCLASS,
             MAX(RDDJ) DQRDDJ,
             MAX(WSDJ) DQWSDJ
        FROM (SELECT *
                FROM (SELECT RDPMDID,
                             RDPFID,
                             RDPIID,
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
                             END JT,
                             TOOLS.FFORMATNUM(MAX(NVL(RDDJ, 0)), 2) RDDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDSL,
                                                         0)),
                                              0) RDSL,
                             TOOLS.FFORMATNUM(SUM(NVL(RDZNJ, 0)), 2) RDZNJ,
                             SUM(DECODE(RDPIID, '01', 0, RDJE)) ZZSJE,
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
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         01,
                                                         0,
                                                         MAX(RDDJ)))
                                              OVER(PARTITION BY RDPFID),
                                              2) WSDJ,
                             TOOLS.FFORMATNUM(SUM(DECODE(RDPIID,
                                                         '01',
                                                         RDSL,
                                                         0)) *
                                              SUM(DECODE(RDPIID,
                                                         01,
                                                         0,
                                                         MAX(RDDJ)))
                                              OVER(PARTITION BY RDPFID),
                                              2) WSJE
                        FROM RECDETAIL
                       WHERE RDID = P_RLID
                       GROUP BY RDPMDID, RDPIID, RDPFID, RDCLASS)
               WHERE RDPIID = '01') group by RDPMDID, RDPIID, RDPFID, RDCLASS
       ORDER BY RDPMDID, RDPIID, RDPFID, RDCLASS DESC;
    V_CUR3 C_CUR3%ROWTYPE;

    VM         VIEW_METER_PROP%ROWTYPE;
    PM         PAYMENT%ROWTYPE;
    RL         RECLIST%ROWTYPE;
    V_COUNT    NUMBER := 0;
    V_COUNT2   NUMBER := 0;
    V_ROW      NUMBER := 0;
    һ�����   BOOLEAN := FALSE;
    ��ֵ˰�û� BOOLEAN := FALSE;
    MAXROW     NUMBER := 5; --��ϸ�������
    V_RET      LONG;
    V_RET_SWAP LONG;
    V_BZ       LONG;
    v_list     number := 0;
  BEGIN

    V_RET := NULL;

    IF P_TYPE = C_Ԥ�� THEN
      --step 1 �ж���һ��һ����һ�����
      V_COUNT := 0;
      SELECT COUNT(DISTINCT MIID)
        INTO V_COUNT
        FROM METERINFO, PAYMENT
       WHERE MIPRIID = PPRIID
         AND MIPRIFLAG = 'Y'
         AND PBATCH = P_ID;
      IF V_COUNT > 1 THEN
        һ����� := TRUE;
      ELSE
        һ����� := FALSE;
      END IF;

      IF һ����� THEN
        V_RET := V_RET || 'ˮ�ѵ��ۣ�' || P_INV.MEMO06;
        V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || 'Ԫ ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'ǰ�ν�����' || CASE
                   WHEN P_INV.QCSAVING = 0 THEN
                    '0.00'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                 END || 'Ԫ';
        V_RET := V_RET || '  ���ν��Ѻ���' || CASE
                   WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                   --WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                    '0.00'
                   ELSE
                    TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2)
                 END || 'Ԫ';
        V_RET := V_RET || '  Ԥ�ƿ���ˮ��(��ǰ����)��' || P_INV.MEMO04||' ������';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ڱ�ʾ����';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || P_INV.MEMO08;

        --����˰Ʊ��ע��һ�����Ԥ�棩
        /*V_BZ := '�û��ţ�' || P_INV.MICODE || '(' || P_INV.N2 || '���û�)' ||
                '��Ԥ�ƿ���ˮ��(��ǰ����)��' || P_INV.MEMO04 || '�����ν��Ѻ���' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || 'Ԫ���������ڣ�' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');*/
        V_BZ := '�û��ţ�' || P_INV.MICODE || '(' || P_INV.N2 || '���û�)' ||
                '��Ԥ�ƿ���ˮ��' || P_INV.MEMO04 || '�����ۣ�'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'Ԫ/�����ף����ν��Ѻ���' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || 'Ԫ���������ڣ�' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');
      ELSE
        V_RET := V_RET || 'ˮ�ѵ��ۣ�' || P_INV.MEMO06;
        V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || 'Ԫ ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'ǰ�ν�����' || CASE
                   WHEN P_INV.QCSAVING = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                 END || 'Ԫ';
        V_RET := V_RET || '  ���ν��Ѻ���' || CASE
                   WHEN P_INV.QMSAVING = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QMSAVING, 2)
                 END || 'Ԫ';
        V_RET := V_RET || '  ���ڱ�ʾ����' || P_INV.MEMO07;
        V_RET := V_RET || '  Ԥ�Ʊ�ʾ��(��ǰ����)��' || P_INV.MEMO03;
        V_RET := V_RET || CHR(13);

        --����˰Ʊ��ע��һ��һ��Ԥ�棩
        V_BZ := '�û��ţ�' || P_INV.MICODE || '�����ڱ�ʾ����' || P_INV.MEMO07 ||
                '��Ԥ�Ʊ�ʾ����' || P_INV.MEMO03 || '�����ۣ�'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'Ԫ/�����ף����ν��Ѻ���' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || 'Ԫ���������ڣ�' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');

      END IF;

    ELSIF P_TYPE = C_��Ʊ THEN
      --step 1 �ж���һ��һ����һ������ж��Ƿ���ֵ˰�û�
      V_COUNT  := 0;
      V_COUNT2 := 0;
      SELECT COUNT(DISTINCT MIID),
             SUM(DECODE(NVL(MIIFTAX, 'N'), 'Y', 1, 0))
        INTO V_COUNT, V_COUNT2
        FROM METERINFO, PAYMENT
       WHERE MIPRIID = PPRIID
         AND MIPRIFLAG = 'Y'
         AND PBATCH = P_ID;
      IF V_COUNT > 1 THEN
        һ����� := TRUE;
      ELSE
        һ����� := FALSE;
      END IF;
      IF V_COUNT2 > 0 THEN
        ��ֵ˰�û� := TRUE;
      ELSE
        ��ֵ˰�û� := FALSE;
      END IF;

      IF ��ֵ˰�û� THEN
        V_RET := V_RET || 'ˮ�ѵ��ۣ�' || P_INV.MEMO06;
        V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ9 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                 END || 'Ԫ ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.N1 || '������';
        V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || 'Ԫ';
        V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || 'Ԫ ';
        V_BZ := '�û��ţ�' || P_INV.MICODE || '(' || P_INV.N2 || '���û�)' ||
                  '��Ԥ�ƿ���ˮ����' || P_INV.MEMO04 || '�����ۣ�'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'Ԫ/�����ף����ν��Ѻ���' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || 'Ԫ���������ڣ�' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');
      ELSE
        IF һ����� THEN
          V_RET := V_RET || 'ˮ�ѵ��ۣ�' || P_INV.MEMO06;
          V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ9 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                   END || 'Ԫ ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.N1 || '������';
          V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || 'Ԫ';
          V_RET := V_RET || '  Ԥ�ƿ���ˮ��(��ǰ����)��' || P_INV.MEMO04 || '������';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ�պϼƣ�' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ǰ�ν�����' || CASE
                     WHEN P_INV.QCSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ���ν��Ѻ���' || CASE
                     WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ΥԼ��' || TOOLS.FFORMATNUM(P_INV.ZNJ, 2) || 'Ԫ';

          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '�����¼��';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('����', 8, 'C') ||
                   FSETSTRALIGN('����', 6, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('ˮ�ѵ���', 10, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('��ˮ����ѵ���', 16, 'C') ||
                   FSETSTRALIGN('��ˮ�����', 12, 'C') ||
                   FSETSTRALIGN('С��', 10, 'C');
          V_RET := V_RET || CHR(13);
          V_ROW := 0;
          OPEN C_CUR1(P_ID);
          LOOP
            FETCH C_CUR1
              INTO V_CUR1;
            EXIT WHEN V_CUR1.VNUM > MAXROW OR C_CUR1%NOTFOUND OR C_CUR1%NOTFOUND IS NULL;


            /*OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
            FETCH C_CUR2
              INTO V_CUR2;
            IF C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '�����¼������');
            END IF;*/
            OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
          LOOP
            FETCH C_CUR2
              INTO V_CUR2;
            EXIT WHEN  C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL;


            V_ROW := V_ROW + 1;
            if V_ROW <= MAXROW then
            --����
            V_RET := V_RET ||
                     FSETSTRALIGN(TRIM(SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              1,
                                              4) ||
                                       SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              6,
                                              2)),
                                  8,
                                  'C');
            --����
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.JT, 6, 'C');
              --ˮ��
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDSL, 10, 'C');
              --ˮ�ѵ���
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDDJ, 10, 'C');
              --ˮ��
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDJE01, 10, 'C');
              --��ˮ����ѵ���
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSDJ, 16, 'C');
              --��ˮ�����
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSJE, 12, 'C');
              --С��
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.XJ, 10, 'C');

              --IF V_ROW < V_CUR2.CN AND V_ROW < MAXROW THEN
              V_RET := V_RET || CHR(13);
              --END IF;
            END IF;
            END LOOP;
            CLOSE C_CUR2;
          END LOOP;
          CLOSE C_CUR1;
          V_RET := V_RET || '���ڱ�ʾ����';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || P_INV.MEMO08;

          --����˰Ʊ��ע��һ������ѣ�
          V_BZ := '�û��ţ�' || P_INV.MICODE || '(' || P_INV.N2 || '���û�)' ||
                  '��Ԥ�ƿ���ˮ����' || P_INV.MEMO04 ||  '�����ۣ�'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'Ԫ/�����ף����ν��Ѻ���' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || 'Ԫ���������ڣ�' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');

        ELSE
          V_RET := V_RET || 'ˮ�ѵ��ۣ�' || P_INV.MEMO06;
          V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ9 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                   END || 'Ԫ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.N1 || '������';
          V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || 'Ԫ';
          V_RET := V_RET || '  Ԥ�Ʊ�ʾ��(��ǰ����)��' || P_INV.MEMO03;
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ�պϼƣ�' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ǰ�ν�����' || CASE
                     WHEN P_INV.QCSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ���ν��Ѻ���' || CASE
                     WHEN P_INV.QMSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QMSAVING, 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ΥԼ��' || TOOLS.FFORMATNUM(P_INV.ZNJ, 2) || 'Ԫ';

          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '�����¼��';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('����', 8, 'C') ||
                   FSETSTRALIGN('��ʾ��', 8, 'C') ||
                   FSETSTRALIGN('����', 6, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('ˮ�ѵ���', 10, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('��ˮ����ѵ���', 16, 'C') ||
                   FSETSTRALIGN('��ˮ�����', 12, 'C') ||
                   FSETSTRALIGN('С��', 10, 'C');
          V_RET := V_RET || CHR(13);
          V_ROW := 0;
          OPEN C_CUR1(P_ID);
          LOOP
            FETCH C_CUR1
              INTO V_CUR1;
            EXIT WHEN V_CUR1.VNUM > MAXROW OR C_CUR1%NOTFOUND OR C_CUR1%NOTFOUND IS NULL;


            /*OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
            FETCH C_CUR2
              INTO V_CUR2;
            IF C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '�����¼������');
            END IF;
            CLOSE C_CUR2;*/
            OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
          LOOP
            FETCH C_CUR2
              INTO V_CUR2;
            EXIT WHEN  C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL;
            V_ROW := V_ROW + 1;
            if V_ROW <= MAXROW then
            --����
            V_RET := V_RET ||
                     FSETSTRALIGN(TRIM(SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              1,
                                              4) ||
                                       SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              6,
                                              2)),
                                  8,
                                  'C');
            --��ʾ��
            IF FGETIFDZSB(V_CUR1.RLCID) = 'Y' THEN
              V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
            ELSIF FGETMETERSTATUS(V_CUR1.RLCID) = 'Y' THEN
              V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
            ELSE
               V_RET := V_RET || FSETSTRALIGN(V_CUR1.RLECODE, 8, 'C');
               V_CUR1.RLECODE := null;
            END IF;
            --����
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.JT, 6, 'C');
            --ˮ��
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDSL, 10, 'C');
            --ˮ�ѵ���
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDDJ, 10, 'C');
            --ˮ��
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDJE01, 10, 'C');
            --��ˮ����ѵ���
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSDJ, 16, 'C');
            --��ˮ�����
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSJE, 12, 'C');
            --С��
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.XJ, 10, 'C');

            --IF V_ROW < V_CUR2.CN AND V_ROW < MAXROW THEN
            V_RET := V_RET || CHR(13);
            --END IF;
            end if;
            END LOOP;
          CLOSE C_CUR2;
          END LOOP;
          CLOSE C_CUR1;

          --����˰Ʊ��ע��һ��һ���ѣ�
          V_BZ := '�û��ţ�' || P_INV.MICODE || '�����ڱ�ʾ����' ||
                  FGETMETERINFO(P_INV.MICODE, 'MIRCODE') || '��Ԥ�Ʊ�ʾ����' ||
                  P_INV.MEMO03 || '�����ۣ�'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'Ԫ/�����ף����ν��Ѻ���' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) ||
                  'Ԫ���������ڣ�' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"��"MM"��"DD"��"');
        END IF;

      END IF;

    ELSIF P_TYPE = C_��Ʊ THEN
      NULL;

    ELSIF P_TYPE = C_Ԥ����Ʊ THEN
      NULL;

    ELSIF P_TYPE = C_Ԥ����Ʊ THEN
      --step1 �ж�Ӧ������
      SELECT * INTO RL FROM RECLIST WHERE RLID = P_ID;

      IF RL.RLTRANS IN ('13', '14', '21', '23') THEN
        --����
        V_RET := V_RET || 'ˮ�ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ5 IS NULL THEN
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2) || 'Ԫ'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ1 + P_INV.DJ5, 2) || '-' ||
                    TOOLS.FFORMATNUM(P_INV.DJ5, 2) || '=' ||
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2) || 'Ԫ'
                 END;
        V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ6 IS NULL THEN
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2) || 'Ԫ'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2 + P_INV.DJ6, 2) || '-' ||
                    TOOLS.FFORMATNUM(P_INV.DJ6, 2) || '=' ||
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2) || 'Ԫ'
                 END;
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.KPSSSL || '������';
        V_RET := V_RET || '  ˮ�ѣ�' ||
                 TOOLS.FFORMATNUM(P_INV.KPSSSL * P_INV.DJ1, 2) || 'Ԫ';
        V_RET := V_RET || '  ��ˮ����ѣ�' ||
                 TOOLS.FFORMATNUM(P_INV.KPSSSL * P_INV.DJ2, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '�ϼƽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '�������' || P_INV.MEMO12;
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '��ע��' || P_INV.MEMO13;
        V_RET := V_RET || CHR(13);
      ELSIF RL.RLTRANS = LOWER('u') THEN
        --����ˮ��
        V_RET := V_RET || 'ˮ�ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ1 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                 END || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.KPSSSL || '������';
        V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '������Ŀ������ˮ��';
        V_RET := V_RET || CHR(13);
      ELSIF RL.RLTRANS = LOWER('v') THEN
        --������ˮ
        V_RET := V_RET || '��ˮ����ѵ��ۣ�' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.KPSSSL || '������';
        V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '������Ŀ��������ˮ�����';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '��Ŀ���ƣ�' || P_INV.MEMO10;
        V_RET := V_RET || CHR(13);
      ELSE
        --����
        SELECT SUM(DECODE(NVL(MIIFTAX, 'N'), 'Y', 1, 0))
          INTO V_COUNT2
          FROM METERINFO
         WHERE MIID = RL.RLMID;
        IF V_COUNT2 > 0 THEN
          ��ֵ˰�û� := TRUE;
        ELSE
          ��ֵ˰�û� := FALSE;
        END IF;

        IF ��ֵ˰�û� THEN
          V_RET := V_RET || 'ˮ�ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ1 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ2 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                   END || 'Ԫ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '�������£�' || P_INV.KPZWMONTH;
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.KPSSSL || '������';
          V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || 'Ԫ';
          V_RET := V_RET || CHR(13);
        ELSE
          V_RET := V_RET || 'ˮ�ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ1 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                   END || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѵ��ۣ�' || CASE
                     WHEN P_INV.DJ2 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                   END || 'Ԫ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '���ѽ�' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || 'Ԫ';
          V_RET := V_RET || '  ���(��д)��' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || 'Ӧ��ˮ����' || P_INV.KPSSSL || '������';
          V_RET := V_RET || '  ˮ�ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || 'Ԫ';
          V_RET := V_RET || '  ��ˮ����ѣ�' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || 'Ԫ';
          V_RET := V_RET || 'Ӧ�պϼƣ�' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || 'Ԫ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '�����¼��';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('����', 8, 'C') ||
                   FSETSTRALIGN('��ʾ��', 8, 'C') ||
                   FSETSTRALIGN('����', 6, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('ˮ�ѵ���', 10, 'C') ||
                   FSETSTRALIGN('ˮ��', 10, 'C') ||
                   FSETSTRALIGN('��ˮ����ѵ���', 16, 'C') ||
                   FSETSTRALIGN('��ˮ�����', 12, 'C') ||
                   FSETSTRALIGN('С��', 10, 'C');
          V_RET := V_RET || CHR(13);

          V_ROW := 0;
          OPEN C_CUR3(RL.RLID);
          FETCH C_CUR3
            INTO V_CUR3;
          IF C_CUR3%NOTFOUND OR C_CUR3%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '�����¼������');
          END IF;
          CLOSE C_CUR3;
          V_ROW := V_ROW + 1;
          --����
          V_RET := V_RET ||
                   FSETSTRALIGN(TRIM(SUBSTR(NVL(RL.RLMONTH, '1990.01'),
                                            1,
                                            4) ||
                                     SUBSTR(NVL(RL.RLMONTH, '1990.01'),
                                            6,
                                            2)),
                                8,
                                'C');
          --��ʾ��
          IF FGETIFDZSB(RL.RLCID) = 'Y' THEN
            V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
          ELSIF FGETMETERSTATUS(RL.RLCID) = 'Y' THEN
            V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
          ELSE
            V_RET := V_RET || FSETSTRALIGN(RL.RLECODE, 8, 'C');
          END IF;
          --����
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.JT, 6, 'C');
          --ˮ��
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDSL, 10, 'C');
          --ˮ�ѵ���
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDDJ, 10, 'C');
          --ˮ��
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDJE01, 10, 'C');
          --��ˮ����ѵ���
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.WSDJ, 16, 'C');
          --��ˮ�����
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.WSJE, 12, 'C');
          --С��
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.XJ, 10, 'C');

          --IF V_ROW < V_CUR3.CN AND V_ROW < MAXROW THEN
          V_RET := V_RET || CHR(13);
          --END IF;

        END IF;

      END IF;

      --����˰Ʊ��ע
      V_BZ := '�û��ţ�' || P_INV.MICODE ||

                    CASE WHEN RL.RLTRANS in ('13', '14', '21') THEN
                      null
                     ELSE
                       '���ʿ��ţ�' || P_INV.MEMO11 || '��ָ�룺' ||
              TO_CHAR(P_INV.KPZM)
                   END/*FGETMETERINFO(P_INV.MICODE, 'MIRCODE')*/ || '��ϵͳ�������£�' ||
              P_INV.KPZWMONTH;
      if  RL.RLTRANS in (LOWER('v'),LOWER('u')) then
         V_BZ := '��ʱ��ˮ�����ţ�'|| P_INV.MICODE  ;
      end if;
    END IF;

    IF LENGTH(V_RET) > 1 THEN
      V_RET := SUBSTR(V_RET, 1, LENGTH(V_RET) - 1);
      V_RET := REPLACE(V_RET, '/', CHR(13));
    END IF;

    P_INV.MEMO17 := V_BZ; --˰Ʊ��ע
    P_INV.MEMO20 := substr(V_RET,1,2000); --ƾ֤��ϸ��ע

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_CUR1%ISOPEN THEN
        CLOSE C_CUR1;
      END IF;
      IF C_CUR2%ISOPEN THEN
        CLOSE C_CUR2;
      END IF;
  END;

  --ȥ���ַ��������ַ�
  FUNCTION FGETFORMAT(P_STR IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET VARCHAR2(400);
  BEGIN
    --ȥ�ո�
    V_RET := TRIM(P_STR);
    IF V_RET IS NULL THEN
      RETURN NULL;
    ELSE
      --ȥTAB�Ʊ��
      V_RET := REPLACE(V_RET, CHR(9), '');
      --ȥ�س���
      V_RET := REPLACE(V_RET, CHR(10), '');
      --ȥ���з�
      V_RET := REPLACE(V_RET, CHR(13), '');
      --ȥ�ո�
      --V_RET := REPLACE(V_RET, ' ', '');
      V_RET := TRIM(V_RET);
      RETURN V_RET;
    END IF;
  END;

  --�����ַ������루C=���У�L=����룬R=�Ҷ��룩
  FUNCTION FSETSTRALIGN(P_STR   IN VARCHAR2,
                        P_LEN   IN INTEGER,
                        P_ALIGN IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET   VARCHAR2(1024);
    STRLEN  NUMBER;
    STRLENB NUMBER;
    SLEN    NUMBER;
    LBORDER NUMBER;
    RBORDER NUMBER;
  BEGIN
    V_RET := FGETFORMAT(P_STR);
    --ȡ�ֽ��������жϺ���
    STRLEN := LENGTHB(V_RET);
    IF STRLEN = 0 OR V_RET IS NULL THEN
      RETURN LPAD(' ', P_LEN, ' ');
    ELSIF STRLEN >= P_LEN THEN
      RETURN V_RET;
    END IF;
    IF UPPER(P_ALIGN) = 'C' THEN
      SLEN    := P_LEN - STRLEN;
      LBORDER := CEIL(SLEN / 2);
      RBORDER := SLEN - LBORDER;
      V_RET   := LPAD(' ', LBORDER, ' ') || V_RET ||
                 RPAD(' ', RBORDER, ' ');
    ELSIF UPPER(P_ALIGN) = 'L' THEN
      RBORDER := P_LEN - STRLEN;
      V_RET   := V_RET || RPAD(' ', RBORDER, ' ');
    ELSIF UPPER(P_ALIGN) = 'R' THEN
      LBORDER := P_LEN - STRLEN;
      V_RET   := LPAD(' ', LBORDER, ' ') || V_RET;
    END IF;
    RETURN V_RET;
  END;

  --�ж��û��Ƿ�Ϊ�Ⳮ��
  FUNCTION FGETMETERSTATUS(P_CODE IN VARCHAR2 --�û���
                           ) RETURN VARCHAR2 AS
    V_COUNT NUMBER(10);
    V_RET   VARCHAR2(2);
  BEGIN
    V_COUNT := 0;
    V_RET   := 'N';
    SELECT COUNT(*)
      INTO V_COUNT
      FROM METERINFO
     WHERE MIID = P_CODE
       AND MISTATUS IN ('29', '30', '2');
    IF V_COUNT > 0 THEN
      V_RET := 'Y';
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END FGETMETERSTATUS;

  --��ȡһ�������ĩԤ�����
  FUNCTION FGETHSQMSAVING(P_MIID IN VARCHAR2 --�ͻ�����
                          ) RETURN VARCHAR2 AS
    V_PRIID VARCHAR2(10);
    V_RET   VARCHAR2(20);
  BEGIN
    --����������
    SELECT MIPRIID INTO V_PRIID FROM METERINFO WHERE MIID = P_MIID;
    --������Ԥ�����
    SELECT MISAVING INTO V_RET FROM METERINFO WHERE MIID = V_PRIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '0';
  END FGETHSQMSAVING;

  --��ȡ���ջ���
  FUNCTION FGETHSCODE(P_MIID IN VARCHAR2 --�ͻ�����
                      ) RETURN VARCHAR2 AS

    MI    METERINFO%ROWTYPE;
    V_RET VARCHAR2(10);
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
  END FGETHSCODE;

  --��Ʊ��ӡ��ϸ(һ�����)
  FUNCTION FGETHSINVDEATIL(P_MIID IN VARCHAR2 --�ͻ�����
                           ) RETURN VARCHAR2 AS
    CURSOR C_DETAIL(V_CODE IN VARCHAR2) IS
      SELECT MIID, MIRCODECHAR FROM METERINFO WHERE MIPRIID = V_CODE;

    V_DETAIL METERINFO%ROWTYPE;
    P_CODE   VARCHAR2(10);
    V_TYPE   VARCHAR2(20);
    V_STR    VARCHAR2(4000);
    V_ROW    NUMBER;
    V_COLUMN NUMBER;
    V_NUMBER NUMBER;

  BEGIN
    NULL;
    V_NUMBER := 0;
    V_ROW    := 6; --������
    V_COLUMN := 3; --������

    SELECT MIPRIID INTO P_CODE FROM METERINFO WHERE MIID = P_MIID;
    OPEN C_DETAIL(P_CODE);
    LOOP
      FETCH C_DETAIL
        INTO V_DETAIL.MIID, V_DETAIL.MIRCODECHAR;
      EXIT WHEN C_DETAIL%NOTFOUND OR C_DETAIL%NOTFOUND IS NULL;
      /*    IF V_DETAIL.MIID = P_MIID THEN
        --V_TYPE := '(��������)';
        V_TYPE := NULL;
      ELSE
        V_TYPE := NULL;
      END IF;*/

      IF FGETMETERSTATUS(V_DETAIL.MIID) = 'Y' OR
         FGETIFDZSB(V_DETAIL.MIID) = 'Y' THEN
        V_DETAIL.MIRCODECHAR := '-';
      END IF;

      V_NUMBER := V_NUMBER + 1;

      IF V_NUMBER > (V_COLUMN * V_ROW) THEN
        EXIT;
      END IF;

      IF FLOOR(V_NUMBER / V_COLUMN) = CEIL(V_NUMBER / V_COLUMN) THEN
        V_STR := V_STR || V_DETAIL.MIID || '  :  ' ||
                 RPAD(V_DETAIL.MIRCODECHAR, 10, ' ') || CHR(13);
      ELSE
        V_STR := V_STR || V_DETAIL.MIID || '  :  ' ||
                 RPAD(V_DETAIL.MIRCODECHAR, 10, ' ');
      END IF;

    END LOOP;
    CLOSE C_DETAIL;

    IF LENGTH(V_STR) > 1 THEN
      V_STR := SUBSTR(V_STR, 1, LENGTH(V_STR) - 1);
    END IF;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END FGETHSINVDEATIL;

  --��ȡ�û����˿��ţ�����+������ţ�
  FUNCTION FGETNEWCARDNO(P_MIID IN VARCHAR2 --�ͻ�����
                         ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(20);
  BEGIN
    SELECT MIBFID || MIRORDER
      INTO V_RET
      FROM METERINFO
     WHERE MIID = P_MIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '-';
  END FGETNEWCARDNO;

  --��ȡ��ע��Ϣ
  FUNCTION FGETINVMEMO(P_RLID IN VARCHAR2, --Ӧ����ˮ
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
      SELECT FGETOPERNAME(BFRPER) --20160530 ���շ�Ա�ĳɳ���Ա
        INTO V_RET
        FROM RECLIST, BOOKFRAME
       WHERE RLBFID = BFID
         AND RLID = P_RLID;
    END IF;

    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END FGETINVMEMO;

  --��ȡ��Ʊ��ά��
 FUNCTION FGETINVEWM(P_ID   IN VARCHAR2, --��Ʊ��ȡ��
                      P_TYPE IN VARCHAR2 --��ȡ������
                      ) RETURN VARCHAR2 IS
    V_RET      VARCHAR2(400);
    V_IP       VARCHAR2(40) := 'www.hrbwatercsc.com';
    V_PORT     VARCHAR2(40) := '';
    V_TENANTID VARCHAR2(40);
    V_MIID     METERINFO.MIID%TYPE;
  BEGIN
    --V_TENANTID := PG_EWIDE_EINVOICE.F_GET_PARM('�⻧ID');
    IF P_TYPE = 'P' THEN
      SELECT PMID INTO V_MIID FROM PAYMENT WHERE PID = P_ID;
      V_RET := 'http://' || V_IP || ':' || V_PORT ||
               '/saasinv-hrb/html/result.html?tqcode=' || P_ID || '&khdm=P' || V_MIID;
    ELSIF P_TYPE = 'L' THEN
      SELECT RLMID INTO V_MIID FROM RECLIST WHERE RLID = P_ID;
      V_RET := 'http://' || V_IP || ':' || V_PORT ||
               '/saasinv-hrb/html/result.html?tqcode=' || P_ID || '&khdm=L' || V_MIID;
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

   --�������ȼ�
 FUNCTION FGETINVUP(P_ID   IN VARCHAR2
                      ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_RET      NUMBER;

  BEGIN
    UPDATE PAY_EINV_JOB_LOG
      SET PTOP = 1
      WHERE PBATCH =P_ID and PTOP <> 1;
      COMMIT;

    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  PROCEDURE SP_PREPRINT_EINVOICE_JOBRUN(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_SLTJ      IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2
                                 ) IS
V_CODE VARCHAR2(400);
V_ERRMSG VARCHAR2(400);
BEGIN
  DELETE INVPARMTERMP;
  --��Ʊ��¼��ʱ��MEMO2 �����ж��Զ���Ʊ
  INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms,MEMO2) Values('',P_PBATCH,'','N','Y');

    SP_PREPRINT_EINVOICE(P_PRINTTYPE,P_INVTYPE,P_INVNO,V_CODE,V_ERRMSG,P_SLTJ);
    UPDATE pay_einv_job_log
    SET PERRID='1',
        MEMO1 = V_ERRMSG
    WHERE PBATCH = P_PBATCH;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      rollback;
    UPDATE pay_einv_job_log
  SET PERRID='6',
      perrtext = '��Ʊʧ��'
  WHERE PBATCH = P_PBATCH;
  commit;
END SP_PREPRINT_EINVOICE_JOBRUN;

/*
P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
*/
  --�ɷ�ʱ����
  PROCEDURE SP_PAY_EINV_RUNbak(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2) IS
  vjobid  binary_integer;
  V_ROW  NUMBER;
  V_STR  VARCHAR2(4000);
  BEGIN
    /*
    errid:
    =0,���ڿ�Ʊ
    =1,������Ʊ
    =2���������Ͱ���Ӧ�տ�Ʊҵ��
    =3���ýɷ������ѿ�����Ʊ
    =4����̨��Ʊҵ��ִ���쳣����
    =5��Ӧ�����д����ѿ���Ʊ��Ϣ
    =6,��Ʊ�쳣
    =7,JOB�޷��أ��Զ��ָ�
    ------------------------------
    Ӧ�տ�Ʊ����
    ('13', '14', '21', '23', 'V', 'U','v')
    */
    NULL;
    --INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
    --P_TYPE=2 ��Ʊ����Ϊʵ�տ�Ʊ��P_TYPE=1ΪӦ�տ�Ʊ����δ������
    --1��Ӧ�տ�Ʊ��������
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND
          PBATCH=P_PBATCH AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M');
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'2','����Ӧ�տ�Ʊ��������');
       --�˴���commit����������������
       RETURN;
    END IF;

    --2�����ʵ�ռ�¼�Ƿ��ѿ�����Ʊ
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,INV_INFO_SP IIS
    WHERE P.PID=IIS.PID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'3','�ýɷ������ѿ�����Ʊ');
       RETURN;
    END IF;
    --3�����Ӧ�����Ƿ���ڿ�Ʊ��¼
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,RECLIST RL,INV_INFO_SP IIS
    WHERE P.PID=RL.RLPID AND  RL.RLID=IIS.RLID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'4','Ӧ�����д����ѿ���Ʊ��Ϣ');
       RETURN;
    END IF;
    --DELETE INVPARMTERMP;
    --��Ʊ��¼��ʱ��
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',P_PBATCH,'','N');
    --4��ִ�й��̵���
    --�жϽɷ����ͣ�Ԥ�桢��Ʊ��
    --����ģʽ���޳�Ԥ�������Ԥ��ֿۣ���Ʊ��
    /*
    �ж�10���ӣ��Զ�����״̬���������
    �ж�
    5������ʱ5��
    10����30��
    20����1����
    --dbms_lock.sleep(1);
    */
    SELECT count(*) INTO V_ROW
    FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND PBATCH=P_PBATCH and PTRANS not in('K','U') AND PPAYMENT>0;
    --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
    IF V_ROW > 0 THEN
       --��Ʊ
       dbms_job.submit
       (
        job       => vjobid,
        what      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        next_date => sysdate+100,
        interval  => NULL,
        no_parse  => NULL
       );
       /*V_STR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
       JOB_SUBMIT(V_STR,to_char(sysdate,'yyyymmdd hh24:mi:ss'));*/
    END IF;
    SELECT count(*) INTO V_ROW
    FROM PAYMENT  WHERE  PBATCH=P_PBATCH and PTRANS ='S' AND PPAYMENT > 0;


    IF V_ROW > 0 THEN
      --Ԥ��
       dbms_job.submit
       (
        job       => vjobid,
        what      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        next_date => sysdate+100,
        interval  => NULL,
        no_parse  => NULL
       );
       /*V_STR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
       JOB_SUBMIT(V_STR,to_char(sysdate,'yyyymmdd hh24:mi:ss'));*/
    END IF;
    INSERT INTO pay_einv_job_log(JOBID,PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (vjobid,P_PBATCH,'Y',SYSDATE,SYSDATE,'0','���ڿ�Ʊ');
    --dbms_job.run(vjobid);
  EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'5','��̨��Ʊҵ��ִ���쳣����');
  END ;

  PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2) IS
  vjobid  binary_integer;
  V_ROW  NUMBER;
  V_STR  VARCHAR2(4000);
  V_JOBSTR VARCHAR2(200);
  V_TOP    NUMBER := 1;
  BEGIN
    /*
    errid:
    =0,���ڿ�Ʊ
    =1,������Ʊ
    =2���������Ͱ���Ӧ�տ�Ʊҵ��
    =3���ýɷ������ѿ�����Ʊ
    =4����̨��Ʊҵ��ִ���쳣����
    =5��Ӧ�����д����ѿ���Ʊ��Ϣ
    =6,��Ʊ�쳣
    =7,JOB�޷��أ��Զ��ָ�
    =8��JOB�ύ��
    ------------------------------
    Ӧ�տ�Ʊ����
    ('13', '14', '21', '23', 'V', 'U','v','M')
    */
    NULL;
    --INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
    --P_TYPE=2 ��Ʊ����Ϊʵ�տ�Ʊ��P_TYPE=1ΪӦ�տ�Ʊ����δ������
    --1��Ӧ�տ�Ʊ��������
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND
          PBATCH=P_PBATCH AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M');
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'2','����Ӧ�տ�Ʊ��������');
       --�˴���commit����������������
       RETURN;
    END IF;

    --2�����ʵ�ռ�¼�Ƿ��ѿ�����Ʊ
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,INV_INFO_SP IIS
    WHERE P.PID=IIS.PID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'3','�ýɷ������ѿ�����Ʊ');
       RETURN;
    END IF;
    --3�����Ӧ�����Ƿ���ڿ�Ʊ��¼
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,RECLIST RL,INV_INFO_SP IIS
    WHERE P.PID=RL.RLPID AND  RL.RLID=IIS.RLID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'4','Ӧ�����д����ѿ���Ʊ��Ϣ');
       RETURN;
    END IF;
    SELECT SUM(PPAYMENT) INTO V_ROW FROM PAYMENT P WHERE P.PBATCH=P_PBATCH;
    IF V_ROW = 0 THEN
      /*INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'10','������Ϊ0������Ʊ');*/
       RETURN;
    END IF;
    --DELETE INVPARMTERMP;
    --��Ʊ��¼��ʱ��
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',P_PBATCH,'','N');
    --4��ִ�й��̵���
    --�жϽɷ����ͣ�Ԥ�桢��Ʊ��
    --����ģʽ���޳�Ԥ�������Ԥ��ֿۣ���Ʊ��

    SELECT count(*) INTO V_ROW
    FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND PBATCH=P_PBATCH and PTRANS not in('K','U') AND PPAYMENT>0;
    --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
    IF V_ROW > 0 THEN
       --��Ʊ
       /*dbms_job.submit
       (
        job       => vjobid,
        what      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        next_date => sysdate+100,
        interval  => NULL,
        no_parse  => NULL
       );*/
       V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
    END IF;
    SELECT count(*) INTO V_ROW
    FROM PAYMENT p  WHERE  PBATCH=P_PBATCH and ((P.PTRANS = 'S' or (P.PTRANS = 'B' and P.PSAVINGBQ=P.PPAYMENT) OR (P.PTRANS = 'P' AND PSPJE=0)) ) AND PPAYMENT > 0;


    IF V_ROW > 0 THEN
      --Ԥ��
/*       dbms_job.submit
       (
        job       => vjobid,
        what      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        next_date => sysdate+100,
        interval  => NULL,
        no_parse  => NULL
       );*/
       V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
    /*ELSE
      --����Ԥ��V_ROW=0
      SELECT COUNT(*) INTO V_ROW
      FROM PAYMENT,RECLIST WHERE PID=RLPID AND PTRANS='B' AND PPAYMENT>0 AND PBATCH=P_PBATCH;
      IF V_ROW = 0 THEN
         V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
      END IF;*/
    END IF;
    /*
    �ж����ȼ�
    1=��̨�ɷ�
    2=�����ɷ�
    */
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT WHERE PBATCH=P_PBATCH AND PTRANS IN ('P','S');
    IF V_ROW > 0 THEN
       --��̨
       V_TOP := 2;
    ELSE
       V_TOP := 3;
    END IF;
    INSERT INTO pay_einv_job_log(JOBID,PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT,Ptop)
       values (vjobid,P_PBATCH,'Y',SYSDATE,SYSDATE,'0',V_JOBSTR,V_TOP);
    --COMMIT;
    --dbms_job.run(vjobid);
  EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'5','��̨��Ʊҵ��ִ���쳣����');
  END ;
--JOB�ж�����2��ִ��һ��
 PROCEDURE SP_EINV_JOB IS
  V_JOBID VARCHAR2(10);
  ejl pay_einv_job_log%rowtype;
  V_ROW NUMBER;
  I NUMBER;
  VNUM NUMBER := 1;
  VTIME VARCHAR2(20);
  VTIME1 VARCHAR2(20) := '07:50:01';
  VTIME2 VARCHAR2(20) := '18:00:01';
  V_FLAG VARCHAR2(10);
  V_MAXNUM NUMBER;
  V_MAXNUM1 NUMBER;
 BEGIN
   --ȫ�ֿ��ؿ����Ƿ��ύ����
   SELECT NVL(fsyspara('1116'),'N') INTO V_FLAG FROM DUAL;
   IF V_FLAG<>'Y' THEN
     RETURN;
   END IF;
   --�����������
   SELECT to_number(fsyspara('1118')) INTO V_MAXNUM FROM DUAL;
   SELECT COUNT(*) INTO V_MAXNUM1 FROM PAY_EINV_JOB_LOG WHERE (PERRID='8' or PERRID='9');
   IF V_MAXNUM1 >= V_MAXNUM THEN
     RETURN;
   END IF;

   /*select to_char(sysdate,'hh24:mi:ss') INTO VTIME from dual;
   IF VTIME > VTIME2 OR VTIME < VTIME1 THEN
     VNUM := 2;
   END IF; */
   --����˰�������ύ
   select count(*) into VNUM from invlist where ��Ч��־='Y';
   FOR I IN 1 .. VNUM LOOP
     SELECT count(*) into V_ROW from pay_einv_job_log WHERE PERRID='0';
     IF V_ROW > 0 THEN
       --
       SELECT COUNT(*) INTO V_MAXNUM1 FROM PAY_EINV_JOB_LOG WHERE (PERRID='8' or PERRID='9');
       IF V_MAXNUM1 >= V_MAXNUM THEN
         RETURN;
       END IF;
     --SELECT * into ejl from pay_einv_job_log WHERE PERRID='0' AND rownum=1;
     SELECT * INTO EJL FROM (SELECT * FROM PAY_EINV_JOB_LOG WHERE PERRID='0' ORDER BY PTOP,PSTIME) WHERE ROWNUM=1;
     --����ȸ���
     UPDATE pay_einv_job_log SET PERRID='8' WHERE PBATCH=ejl.Pbatch;
     commit;
     dbms_job.submit
         (
          job       => V_JOBID,
          what      => ejl.perrtext,
          next_date => sysdate+0.00002,
          interval  => NULL,
          no_parse  => NULL
         );
     update  pay_einv_job_log set jobid=V_JOBID where PBATCH=ejl.Pbatch AND jobid IS NULL;
     COMMIT;
     dbms_lock.sleep(0.5);
     END IF;
   END LOOP;

   NULL;
   EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
 END;

BEGIN
  NULL;
END;
/


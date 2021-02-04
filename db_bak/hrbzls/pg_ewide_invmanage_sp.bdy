CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_INVMANAGE_SP" IS

  --新增发票非凡方法污水处理费
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --批次号
                           P_ISPER     VARCHAR2, --领票人
                           P_ISTYPE    VARCHAR2, --发票类别
                           P_ISNOSTART VARCHAR2, --发票起号
                           P_ISNOEND   VARCHAR2, --发票止号
                           P_OUTPER    VARCHAR2, --发放票据人
                           MSG         OUT VARCHAR2) IS
    /*发票管理，领票*/
    V_ISTRUE1 NUMBER;
    V_ISTRUE2 NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '发票批次号不允许为空值!';
      RETURN;
    END IF;
    IF P_ISPER IS NULL THEN
      MSG := '领票人不允许为空值!';
      RETURN;
    END IF;
    IF P_ISTYPE IS NULL THEN
      MSG := '发票类别不允许为空值!';
      RETURN;
    END IF;

    IF P_ISNOSTART IS NULL OR P_ISNOEND IS NULL THEN
      MSG := '请录入起始发票号和终止发票号!';
      RETURN;
    ELSE
      --发票止号为空，但发票起号不为空
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
        --判断每条是否添加成功
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      ELSE
        MSG := 'Y';--'该批次发票号码段存在' || V_ISTRUE1 || '张已被领取的发票！';
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '领取失败!' || SQLERRM;
  END;

  --发票转领
  PROCEDURE SP_INVMANG_ZLY(P_INVTYPE     VARCHAR2,
                           P_ISNOSTART   VARCHAR2, --发票起号
                           P_ISNOEND     VARCHAR2, --发票止号
                           P_ISBCNO      VARCHAR2, --批次号
                           P_ISSTATUSPER VARCHAR2, --领用人员
                           P_STATUS      NUMBER, --状态0
                           P_MEMO        VARCHAR2, --备注
                           MSG           OUT VARCHAR2) IS
    /*发票管理，发票作废2、发票初始化0、已使用1、锁定3、删除4*/
    V_ISSTATUS     VARCHAR2(12);
    V_ISSTATUSDATE DATE;
    V_ISSTATUSPER  VARCHAR2(12);
    V_COUNT        NUMBER;
    V_ISTRUE1      NUMBER;
    V_ISTRUE2      NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '发票批次号不允许为空值!';
      RETURN;
    END IF;
    IF P_ISSTATUSPER IS NULL THEN
      MSG := '领用人员不能为空值!';
      RETURN;
    END IF;
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '请录入发票号!';
      RETURN;
    END IF;

    --判断该段票据号码段有没有已经打印的数据
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
      --金税接口调用时P_MEMO为'NOCOMMIT'，不提交。
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

  --修改发票状态
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_INVTYPE     VARCHAR2,
                                    P_ISNOSTART   VARCHAR2, --发票起号
                                    P_ISNOEND     VARCHAR2, --发票止号
                                    P_ISBCNO      VARCHAR2, --批次号
                                    P_ISSTATUSPER VARCHAR2, --状态变更人员
                                    P_STATUS      NUMBER, --状态2
                                    P_MEMO        VARCHAR2, --备注
                                    MSG           OUT VARCHAR2) IS
    /*发票管理，发票作废2、发票初始化0、已使用1、锁定3、删除4*/
    V_ISSTATUS     VARCHAR2(12);
    V_ISSTATUSDATE DATE;
    V_ISSTATUSPER  VARCHAR2(12);
    V_COUNT        NUMBER;
    V_ISTRUE1      NUMBER;
    V_ISTRUE2      NUMBER;
  BEGIN
    IF P_ISBCNO IS NULL THEN
      MSG := '发票批次号不允许为空值!';
      RETURN;
    END IF;
    IF P_ISSTATUSPER IS NULL THEN
      MSG := '状态变更人员不能为空值!';
      RETURN;
    END IF;
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '请录入发票号!';
      RETURN;
    ELSIF P_ISNOEND IS NULL THEN
      --发票止号为空，但发票起号不为空
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
      --发票起号为空，但发票止号不为空
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
      --发票起号止号都不为空
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

  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --发票批次号
                                P_ISNO  IN VARCHAR2 --发票号
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
             SET RLOUTFLAG = 'N', RLIFINV = 'N' --还原收据打印标志
           WHERE RLMICOLUMN2 = INV.PPBATCH;
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_UPDATERECOUTFLAG;

  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --发票批次号
                              P_ISNO   IN VARCHAR2, --发票号
                              P_STATUS NUMBER) AS
    INV       INV_INFO_SP%ROWTYPE;
    INV_COUNT NUMBER;
    V_STATUS  INV_INFO_SP.STATUS%TYPE;
  BEGIN
    /*发票管理，发票作废2、发票初始化0、已使用1、锁定3、删除4*/
    IF P_STATUS = 0 THEN
      --设置成未使用
      V_STATUS := '0';
    ELSIF P_STATUS = 1 THEN
      --已使用
      V_STATUS := '1';
    ELSIF P_STATUS = 2 THEN
      --发票作废
      V_STATUS := '2';
    ELSIF P_STATUS = 3THEN
    --发票锁定
     V_STATUS := '3' ; ELSIF P_STATUS = 4 THEN
      --发票已删除
      V_STATUS := '4';
    END IF;

    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO_SP
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      -- DELETE INV_INFO WHERE ISPCISNO=P_BATCH||'.'||P_ISNO;
      --现更改为把发票资料更改为作废
      IF P_STATUS = 0 THEN
        --设置成未使用时, 直接删除发票INV_INFO
        DELETE INV_INFO_SP WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      ELSE
        UPDATE INV_INFO_SP
           SET STATUS = V_STATUS, STATUSMEMO = '发票作废'
         WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_DELETEISPCISNO;

  --预存票据源
  PROCEDURE SP_SWAPINVYC(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --出票流水号
             '' ISID, --发票流水号
             '' ISPCISNO, --票据批次||号码
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
             END DYFS, --打印方式(0.柜台正常，1. 柜台补打，2.微信申领，3.门户网站申领)
             0 PRINTNUM, --打印次数
             '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
             P.PPAYWAY FKFS, --付款类型(XJ 现金,ZP,支票
             'P' CPLX, --出票类型（P,实收出账,L，应收出账）
             'YC' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
             P.PBATCH PPBATCH, --打印批次
             P.PBATCH BATCH, --实收批次
             'Y' FLAG, --销账标志
             ABS(P.PPAYMENT) FKJE, --付款金额
             P.PSPJE XZJE, --销账金额
             P.PZNJ ZNJ, --滞纳金
             P.PSXF SXF, --手续费
             0 JMJE, --减免金额
             --P.PSAVINGQC QCSAVING, --上次结存
             --P.PSAVINGQM QMSAVING, --本次结存
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QC'))  QCSAVING, --上次结存
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QM'))  QMSAVING, --本次结存
             P.PSAVINGBQ BQSAVING, --本期预存发生
             '' CZPER, --冲正人员
             '' CZDATE, --冲正日期
             P.PCHKNO JZDID, --进账单流水
             P.PREVERSEFLAG REVERSEFLAG, --冲正标志（N为正常，Y为冲正）
             (CASE
               WHEN P.PPAYMENT > 0 THEN
                '柜台预存发票'
               WHEN MI.MIYL8 = 1 THEN
                '预存退费'
               WHEN MI.MIYL8 = 2 THEN
                '撤表退费'
             END) STATUSMEMO, --状态原因
             FGETZHDJ(MIPFID) DJ, --总单价
             FGETSF(MIPFID) DJ1, --水费
             FGETSJWSF((MI.MIPFID), (MI.MIID)) DJ2, --单价污水费   2016.10.18  WLJ   处理污水加价费加入到单价计算中
             0 DJ3, --单价3  附加费
             0 DJ4, --单价4
             0 DJ5, --单价5
             0 DJ6, --单价6
             0 DJ7, --单价7
             0 DJ8, --单价8
             0 DJ9, --单价9
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
             END) MEMO03, --阶梯水价预计表示数
             (CASE
               WHEN FGET_CBJ_REC(P.PMID, 'QF') >= 0 THEN
                TO_CHAR(FLOOR(FGET_CBJ_REC(P.PMID, 'QF') /
                              (FUN_GETJTDQDJ(MI.MIPFID, MI.MIPRIID, MI.MIID, '1') +
                               FGETWSF(MI.MIPFID))))
               ELSE
                '-'
             END) MEMO04, --阶梯水价多表预计表示数
             TOOLS.FFORMATNUM(TO_NUMBER(FGETHSQMSAVING(P.PMID)), 2) MEMO05, --（合收主表）本次交费后余额
             FUN_GETJTDQDJ(MI.MIPFID, MI.MIPRIID, MI.MIID, '2') MEMO06, --阶梯水价单价
             TO_CHAR(DECODE(FGETIFDZSB(P.PMID),
                            'Y',
                            '-',
                            DECODE(FGETMETERSTATUS(P.PMID),
                                   'Y',
                                   '-',
                                   nvl(pp.pprcode ,MI.MIRCODE)))) MEMO07, --当前表示数
             TO_CHAR(FGETHSINVDEATIL(P.PMID)) MEMO08, --合收水表指针明细
             --nvl(pp.pprcode ,MI.MIRCODE)  MEMO08, --合收水表指针明细
             nvl(pp.pprcode ,MI.MIRCODE) MEMO09, --备注9
             NULL MEMO10, --备注10
             NULL MEMO11, --备注11
             NULL MEMO12, --备注12
             NULL MEMO13, --备注13
             NULL MEMO14, --备注14
             'Y' MEMO15, --备注15
             decode(NVL(MI.MIIFTAX,'N'),'N',FGETINVEWM(P.PID, 'P'),'N') MEMO16, --二维码
             --FGETINVEWM(P.PID, 'P') MEMO16, --二维码
             NULL MEMO17, --预留
             /*(SELECT MAX(FGETOPERNAME(BFRPER))
                FROM BOOKFRAME
               WHERE BFID = MI.MIBFID) MEMO18,*/ --复核人[收款人所在地区]
             --FGETSMFNAME(fsysmanalbbm(fgetoperdept(p.pper),'1'))  MEMO18,  --复核人[收款人所在地区]
             (CASE WHEN P.PTRANS='B' THEN fgetsysmanapara(MI.MISMFID,'FPFHR') ELSE fgetsysmanapara(SUBSTR(fgetoperdept(p.pper),1,4),'FPFHR') END)  MEMO18,  --复核人[收款人所在地区]
             --nvl(FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)),'SYSTEM') MEMO19, --操作员(点电票按钮操作员),网站开票system
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END)  MEMO19, --操作员(点电票按钮操作员),网站开票system
             fgetopername(P.PPER) MEMO19, --操作员(收款人)
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(p.pper),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --操作员(点电票按钮操作员),网站开票system,
             NULL MEMO20, --预留
             0 N1, --数值1
             FGETHSCODE(P.PMID) N2, --合收户数
             NULL N3, --数值3
             NULL N4, --数值4
             NULL N5, --数值5
             NULL N6, --数值6
             NULL N7, --数值7
             NULL N8, --数值8
             NULL N9, --数值9
             P.PMCODE MICODE, --客户代码
             MSP.TINAME KPNAME, --票据名称
             NULL MIUIID, --托收号
             MSP.TIADDR KPDZ, --开票地址
             NULL KPZH, --账号
             NULL KPKHM, --开户名
             NULL KPKHYH, --开户银行
             NULL KPSKZH, --公司收款账号
             NULL KPSKHM, --公司收款名
             NULL KPSKYH, --公司收款银行
             NULL KPCBJQ, --抄表日期
             SYSDATE KPRQ, --开票日期
             P.PMONTH KPZWMONTH, --账务月份
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --开票月份
             fgetopername(P.PPER) KPSFY, --收费员
             FGETBFRPER(MIBFID) KPCBY, --抄表员
             FGETPBOPER KPDYY, --打印员
             0 KPQM, --起码
             0 KPZM, --止码
             0 KPCBSL, --抄表水量
             0 KPTZSL, --调整水量
             0 KPSSSL, --实收水量
             P.PPAYMENT KPJE, --应收总金额
             NULL KPJTDJ1, --一阶单价
             NULL KPJTDJ2, --二阶单价
             NULL KPJTDJ3, --三阶单价
             NULL KPJTSL1, --一阶水量
             NULL KPJTSL2, --二阶水量
             NULL KPJTSL3, --三阶水量
             NULL KPJTJE1, --一阶金额
             NULL KPJTJE2, --二阶金额
             NULL KPJTJE3, --三阶金额
             NULL KPJE1, --金额1
             NULL KPJE2, --金额2
             NULL KPJE3, --金额3
             NULL KPJE4, --金额4
             NULL KPJE5, --金额5
             NULL KPJE6, --金额6
             NULL KPJE7, --金额7
             NULL KPJE8, --金额8
             NULL KPJE9, --金额9
             NULL RLID,
             P.PID PID,
             P.PDATE KPSQCBRQ --上期抄表日期
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
      --组织发票明细区数据
      SP_GET_INV_DETAIL(V_INV.BATCH, P_PRINTTYPE, V_INV);
      --插入发票信息
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --插入发票明细
      INSERT INTO INV_DETAILTEMP_SP
        SELECT V_INV.ID,
               NULL,
               NULL,
               PID,
               PMID,
               MI.MINAME,
               P.PBATCH,
               NULL,
               '预存'
          FROM PAYMENT P, METERINFO MI
         WHERE PMID = MIID
           AND P.PID = V_INV.PID;
    END LOOP;
    NULL;
  END;

  --合票数据源
  PROCEDURE SP_SWAPINVHP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --出票流水号
             '' ISID, --发票流水号
             '' ISPCISNO, --票据批次||号码
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
             END DYFS, --打印方式(0.柜台正常，1. 柜台补打，2.微信申领，3.门户网站申领)
             0 PRINTNUM, --打印次数
             '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
             MAX(P.PPAYWAY) FKFS, --付款类型(XJ 现金,ZP,支票
             'P' CPLX, --出票类型（P,实收出账,L，应收出账）
             'HP' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
             P.PBATCH PPBATCH, --打印批次
             P.PBATCH BATCH, --实收批次
             'Y' FLAG, --销账标志
             MAX(DECODE(P.PMID, P.PPRIID, P.PPAYMENT, 0)) FKJE, --付款金额
             SUM(NVL(RLZNJ, 0) + NVL(RLJE, 0)) XZJE, --销账金额
             SUM(NVL(RLZNJ, 0)) ZNJ, --滞纳金
             SUM(NVL(RLSXF, 0)) SXF, --手续费
             0 JMJE, --减免金额
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QC')) QCSAVING, --上次结存
             TO_NUMBER(FGETPSAVING(P.PBATCH, 'QM')) QMSAVING, --本次结存
             SUM(PSAVINGBQ) BQSAVING, --本期预存发生
             '' CZPER, --冲正人员
             '' CZDATE, --冲正日期
             MAX(P.PCHKNO) JZDID, --进账单流水
             MAX(PREVERSEFLAG) REVERSEFLAG, --冲正标志（N为正常，Y为冲正）
             '柜台合打发票' STATUSMEMO, --状态原因
             --MAX(RD.DJ) DJ, --总单价
             FGETZHDJ(MAX(M.MIPFID)) DJ, --总单价
             --MAX(RD.DJ1) DJ1, --水费
             FGETSF(MAX(M.MIPFID)) DJ1, --水费
             FGETSJWSF(MAX(MIPFID), MAX(P.PPRIID)) DJ2, --单价污水费   2016.10.18  WLJ   处理污水加价费加入到单价计算中
             MAX(RD.DJ3) DJ3, --单价3  附加费
             MAX(RD.DJ4) DJ4, --单价4
             MAX(RD.DJ5) DJ5, --单价5
             MAX(RD.DJ6) DJ6, --单价6
             MAX(RD.DJ7) DJ7, --单价7
             MAX(RD.DJ1) DJ8, --借用存用户当前净水价
             FGETWSF(MAX(M.MIPFID)) DJ9, --借用存用户当前污水价
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
             END) MEMO03, --预计表示数
             (CASE
               WHEN FGET_CBJ_REC(MAX(P.PMCODE), 'QF') >= 0 THEN
                TO_CHAR(FLOOR(TO_NUMBER(FGETHSQMSAVING(MAX(P.PMCODE))) /
                              (FUN_GETJTDQDJ(MAX(WATERTYPE),
                                             MAX(M.MIPRIID),
                                             MAX(M.MIID),
                                             '1') + FGETWSF(MAX(M.MIPFID)))))
               ELSE
                '-'
             END) MEMO04, --合收表预计可用水量
             TOOLS.FFORMATNUM(TO_NUMBER(FGETHSQMSAVING(MAX(P.PMCODE))), 2) MEMO05, --合收主表预存余额
             FUN_GETJTDQDJ(MAX(WATERTYPE), MAX(M.MIPRIID), MAX(M.MIID), '2') MEMO06, --水费单价
             NULL MEMO07, --备注7
             TO_CHAR(FGETHSINVDEATIL(MAX(P.PMCODE))) MEMO08, --合收水表指针明细
             NULL MEMO09, --备注9
             NULL MEMO10, --备注10
             NULL MEMO11, --备注11
             NULL MEMO12, --备注12
             NULL MEMO13, --备注13
             NULL MEMO14, --备注14
             'Y' MEMO15, --备注15
             decode(NVL(M.MIIFTAX,'N'),'N',FGETINVEWM(MAX(CASE
                              WHEN P.PMID = P.PPRIID THEN
                               P.PID
                              ELSE
                               '0'
                            END),
                        'P'),'N')  MEMO16, --二维码
             /*FGETINVEWM(MAX(CASE
                              WHEN P.PMID = P.PPRIID THEN
                               P.PID
                              ELSE
                               '0'
                            END),
                        'P')  MEMO16, --二维码  */
             NULL MEMO17, --预留
             /*FGETOPERNAME(MAX(CBY)) MEMO18, --复核人
             FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)) MEMO19, --开票单位*/
             --FGETSMFNAME(fsysmanalbbm(fgetoperdept(max(p.pper)),'1')) MEMO18, --复核人[收款人所在地区]
             (CASE WHEN MAX(P.PTRANS)='B' THEN fgetsysmanapara(max(M.MISMFID),'FPFHR') ELSE fgetsysmanapara(SUBSTR(fgetoperdept(max(p.pper)),1,4),'FPFHR') END) MEMO18, --复核人[收款人所在地区]
             --nvl(FGETSMFNAME(NVL(FGETPBSYSMANA, FGETPBDEPT)),'SYSTEM') MEMO19, --开票人(点电票按钮操作员)所在单位,网站开票system
             --NVL(fgetopername(fgetoperid),'SYSTEM') MEMO19, --开票人(点电票按钮操作员),网站开票system
             --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --开票人(点电票按钮操作员),网站开票system
             MAX(fgetopername(P.PPER)) MEMO19, --开票人(收款人)
              --(CASE WHEN P_SLTJ='YYSF' THEN NVL(fgetopername(max(p.pper)),'SYSTEM') ELSE 'SYSTEM' END) MEMO19, --开票人(点电票按钮操作员),网站开票system
             NULL MEMO20, --预留
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(NVL(RLSL, 0)),
                    nvl(max(pp.ppsl),
                    (MAX(DECODE(P.PMID, P.PPRIID, P.PPAYMENT, 0)) /
                    (MAX(RD.DJ1) + FGETSJWSF(MAX(MIPFID), MAX(P.PPRIID)))))) N1, --应收水量 2016.10.18  WLJ   处理污水加价费加入到单价计算中
             FGETHSCODE(MAX(P.PMID)) N2, --合收户数
             NULL N3, --数值3
             NULL N4, --数值4
             NULL N5, --数值5
             NULL N6, --数值6
             NULL N7, --数值7
             NULL N8, --数值8
             NULL N9, --数值9
             MAX(P.PPRIID) MICODE, --客户代码
             --DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y', MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --票据名称
             (CASE WHEN FGETIFBJZY(MAX(P.PPRIID))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21') THEN MAX(RLCNAME) ELSE MAX(MSP.TINAME) END ) KPNAME, --票据名称
             NULL MIUIID, --托收号
             DECODE(FGETIFBJZY(MAX(P.PPRIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --开票地址
             NULL KPZH, --账号
             NULL KPKHM, --开户名
             NULL KPKHYH, --开户银行
             NULL KPSKZH, --公司收款账号
             NULL KPSKHM, --公司收款名
             NULL KPSKYH, --公司收款银行
             NULL KPCBJQ, --抄表日期
             SYSDATE KPRQ, --开票日期
             CASE
               WHEN MIN(RL.RLSCRRLMONTH) <> MAX(RL.RLSCRRLMONTH) THEN
                MIN(RL.RLSCRRLMONTH) || '-' || MAX(RL.RLSCRRLMONTH)
               ELSE
                MAX(RL.RLSCRRLMONTH)
             END KPZWMONTH, --账务月份
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --开票月份
             MAX(fgetopername(P.PPER)) KPSFY, --收费员
             FGETBFRPER(MAX(MIBFID)) KPCBY, --抄表员
             FGETPBOPER KPDYY, --打印员
             MIN(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                       -- '-',
                       null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                              -- '-',
                              null,
                               RL.RLSCODE))) KPQM, --起码
             MAX(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                        --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                              -- '-',
                              null,
                               RL.RLECODE))) KPZM, --止码
             SUM(RL.RLREADSL) KPCBSL, --抄表水量
             SUM(RL.RLADDSL) KPTZSL, --调整水量
             SUM(RL.RLSL) KPSSSL, --实收水量
             SUM(DECODE(M.MIIFTAX, 'N', PSPJE, CHARGE2)) KPJE, --应收总金额
             NULL KPJTDJ1, --一阶单价
             NULL KPJTDJ2, --二阶单价
             NULL KPJTDJ3, --三阶单价
             SUM(RD.USE_R1) KPJTSL1, --一阶水量
             SUM(RD.USE_R2) KPJTSL2, --二阶水量
             SUM(RD.USE_R3) KPJTSL3, --三阶水量
             SUM(RD.CHARGE_R1) KPJTJE1, --一阶金额
             SUM(RD.CHARGE_R2) KPJTJE2, --二阶金额
             SUM(RD.CHARGE_R3) KPJTJE3, --三阶金额
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(RD.CHARGE1),
                    nvl(max(pp.ppsl*pp.ppsfdj),
                    SUM(RD.CHARGE1)))
                     KPJE1, --金额1
             DECODE(MAX(M.MIIFTAX),
                    'N',
                    SUM(RD.CHARGE2),
                    nvl(max(pp.ppsl*pp.ppwsfdj),
                    SUM(RD.CHARGE2))) KPJE2, --金额2
             SUM(RD.CHARGE3) KPJE3, --金额3
             SUM(RD.CHARGE4) KPJE4, --金额4
             SUM(RD.CHARGE5) KPJE5, --金额5
             SUM(RD.CHARGE6) KPJE6, --金额6
             SUM(RD.CHARGE7) KPJE7, --金额7
             NULL KPJE8, --金额8
             NULL KPJE9, --金额9
             NULL RLID,
             MAX(CASE
                   WHEN P.PMID = P.PPRIID THEN
                    P.PID
                   ELSE
                    '0'
                 END) PID,
             MAX(P.PDATE) KPSQCBRQ --上期抄表日期
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
         AND P.PTRANS <> 'K' --预存抵扣不需要打印发票 20150410 HB 因合收表3088575144打印出来交费金额为预存抵扣的金额
         AND P.PBATCH = T.PBATCH
       GROUP BY P.PBATCH,M.miiftax;

  BEGIN
    OPEN C_INV;
    LOOP
      FETCH C_INV
        INTO V_INV;
      EXIT WHEN C_INV%NOTFOUND OR C_INV%NOTFOUND IS NULL;
      --组织发票明细区数据
      SP_GET_INV_DETAIL(V_INV.BATCH, P_PRINTTYPE, V_INV);
      --插入发票信息
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --插入发票明细
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

  --分票数据源
  PROCEDURE SP_SWAPINVFP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         ) IS
  BEGIN
    NULL;
  END;

  --预开合票数据源
  PROCEDURE SP_SWAPINVYKHP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           ) IS
  BEGIN
    NULL;
  END;

  --预开分票数据源
  PROCEDURE SP_SWAPINVYKFP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           ) IS
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    CURSOR C_INV IS
      SELECT FGETSEQUENCE('INV_INFO') ID, --出票流水号
             '' ISID, --发票流水号
             '' ISPCISNO, --票据批次||号码
             CASE
               WHEN P_SLTJ = 'YYSF' THEN
                '1'
               WHEN P_SLTJ = 'WX' THEN
                '2'
               WHEN P_SLTJ = 'QYMH' THEN
                '3'
               ELSE
                '0'
             END DYFS, --打印方式(0.柜台正常，1. 柜台补打，2.微信申领，3.门户网站申领)
             0 PRINTNUM, --打印次数
             '0' STATUS, --状态(0，正常、1, 作废、2,红票、3,蓝票
             NULL FKFS, --付款类型(XJ 现金,ZP,支票
             'L' CPLX, --出票类型（P,实收出账,L，应收出账）
             'YF' CPFS, --出票方式（合票、分票、预存票、存折，稽查,.......）
             MAX(RLMICOLUMN2) PPBATCH, --打印批次
             NULL BATCH, --实收批次
             'N' FLAG, --销账标志
             SUM(RLJE) FKJE, --付款金额
             SUM(RLJE) XZJE, --销账金额
             0 ZNJ, --滞纳金
             0 SXF, --手续费
             0 JMJE, --减免金额
             0 QCSAVING, --上次结存
             0 QMSAVING, --本次结存
             0 BQSAVING, --本期预存发生
             '' CZPER, --冲正人员
             '' CZDATE, --冲正日期
             NULL JZDID, --进账单流水
             MAX(RLREVERSEFLAG) REVERSEFLAG, --冲正标志（N为正常，Y为冲正）
             '预开分票' STATUSMEMO, --状态原因
             MAX(RD.DJ) DJ, --总单价
             --FUN_GETJTDQDJ(MAX(MIPFID), MAX(MIPRIID), MAX(MIID), '1') DJ1, --水费
             --FGETWSFSS(MAX(MI.MIID)) DJ2, --单价污水费   20160715 WLJ 取污水费实收单价
             max(rd.dj1) dj1,
             max(rd.dj2) dj2,
             MAX(RD.DJ3) DJ3, --单价3  附加费
             MAX(RD.DJ4) DJ4, --单价4
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ1)
               ELSE
                NULL
             END) DJ5, --单价5
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ2)
               ELSE
                NULL
             END) DJ6, --单价6
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') AND
                    MAX(RLINVMEMO) = 'A' THEN
                MAX(RD.YSDJ3)
               ELSE
                NULL
             END) DJ7, --单价7
             FGETSF(MAX(MIPFID)) DJ8, --借用存用户当前净水价
             FGETWSF(MAX(MIPFID)) DJ9, --借用存用户当前污水价
             NULL MEMO03, --备注3
             NULL MEMO04, --备注4
             NULL MEMO05, --备注5
             NULL MEMO06, --备注6
             NULL MEMO07, --备注7
             NULL MEMO08, --备注8
             NULL MEMO09, --备注9
             FGETMETERINFO(RLPRIMCODE, 'CINAME2') MEMO10, --项目名称
             /*(CASE WHEN MAX(MICHARGETYPE)='M' THEN 
                        '账卡号：'|| FGETNEWCARDNO(MAX(RL.RLMID)) 
                        ELSE '' END) MEMO11, --新账卡号*/
             FGETNEWCARDNO(MAX(RL.RLMID)) MEMO11, --新账卡号
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') THEN
                FGETSYSCHARLIST('补缴类别',
                                FGETINVMEMO(MAX(RL.RLID), 'RLINVMEMO'))
               ELSE
                NULL
             END) MEMO12, --发票备注 追补类别
             (CASE
               WHEN MAX(RLTRANS) IN ('13', '14', '21') THEN
                FGETINVMEMO(MAX(RL.RLID), 'RLMEMO')
               ELSE
                NULL
             END) MEMO13, --发票备注
             NULL MEMO14, --备注14
             --max(decode(rltrans,'u','v',rltrans)) MEMO15, --备注15(补缴\基建\营销\客服\稽查,不打印二维码和网址)
             max(CASE WHEN rltrans IN ('13','u','21','14','v','23') THEN
                           'v'
                      ELSE
                        rltrans
                      END) MEMO15, --备注15(补缴\基建\营销\客服\稽查,不打印二维码和网址),传值'v'不打印
             (CASE
               WHEN NVL(mi.miiftax,'N') = 'Y' or MAX(RLTRANS) IN ('13', '14', '21','u','v') THEN
                'N'
               ELSE
                FGETINVEWM(RL.RLID, 'L')
             END)  MEMO16, --二维码
             --decode(mi.miiftax,'N', FGETINVEWM(RL.RLID, 'L'),'N') MEMO16, --二维码
             --FGETINVEWM(RL.RLID, 'L') MEMO16, --二维码
             NULL MEMO17, --预留
             /*(SELECT MAX(FGETOPERNAME(BFRPER))
                FROM BOOKFRAME
               WHERE BFID = (SELECT MAX(MIBFID)
                               FROM METERINFO
                              WHERE MIID = RLPRIMCODE)) MEMO18, --复核人
             CASE
               WHEN MAX(RLTRANS) = '21' THEN
                FGETSMFNAME(FGETOPERDEPT(FGETPBOPER))
               ELSE
                FGETSMFNAME(MAX(RLSMFID))
             END MEMO19, --开票单位*/

             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'U','v') and RLYSCHARGETYPE='M' THEN  --走收
                     --用户所在地区
                     --FGETSMFNAME(MAX(RL.RLSMFID))
                     fgetsysmanapara(SUBSTR(MAX(RL.RLSMFID),1,4),'FPFHR')
                   WHEN
                     RL.RLTRANS = '13' THEN  --补缴
                     --用户所在地区
                     --FGETSMFNAME(MAX(RL.RLSMFID))
                     fgetsysmanapara(SUBSTR(MAX(RL.RLSMFID),1,4),'FPFHR')
                   WHEN
                     RL.RLTRANS = 'u' THEN  --基建水费
                     (select MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --稽查
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'v' THEN  --基建污水
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = '23' THEN  --营销部
                     (select  MAX(fgetsysmanapara(SUBSTR(fgetoperdept(RTHCREPER),1,4),'FPFHR')) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
              END) MEMO18, --复核人
             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'u','v') and RLYSCHARGETYPE='M' THEN  --走收
                     --登录打印人员，网站开票system
                    MAX(CASE WHEN P_SLTJ = 'YYSF' THEN NVL(fgetopername(fgetoperid),'SYSTEM') ELSE 'SYSTEM' END)
                   WHEN
                     RL.RLTRANS = '13' THEN  --补缴
                     --登录打印人员
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --稽查
                     --登录打印人员
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = 'v' THEN  --基建污水
                     --登录打印人员
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = 'u' THEN  --基建水费
                     --登录打印人员
                     MAX(fgetopername(fgetoperid))
                   WHEN
                     RL.RLTRANS = '23' THEN  --营销部
                     --登录打印人员
                     MAX(fgetopername(fgetoperid))
              END) MEMO19, --开票人
             NULL MEMO20, --预留
             NULL N1, --数值1
             NULL N2, --合收户数
             NULL N3, --数值3
             NULL N4, --数值4
             NULL N5, --数值5
             NULL N6, --数值6
             NULL N7, --数值7
             NULL N8, --数值8
             NULL N9, --数值9
             MAX(RLPRIMCODE) MICODE, --客户代码
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y',MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --票据名称
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --开票地址
             (CASE WHEN FGETIFBJZY(MAX(RL.RLPRIMCODE))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21','23') THEN MAX(RLCNAME) ELSE MAX(MSP.TINAME) END ) KPNAME, --票据名称
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y',MAX(RLCNAME),MAX(MSP.TINAME)) KPNAME, --票据名称
             NULL MIUIID, --托收号
             --DECODE(FGETIFBJZY(MAX(MI.MIID)), 'Y', MAX(RLCADR), MAX(MSP.TIADDR)) KPDZ, --开票地址
             (CASE WHEN FGETIFBJZY(MAX(RL.RLPRIMCODE))='Y' OR MAX(RLTRANS) in ('u','v','13','14','21','23') THEN MAX(RLCADR) ELSE MAX(MSP.TIADDR) END ) KPDZ, --开票地址
             NULL KPZH, --账号
             NULL KPKHM, --开户名
             NULL KPKHYH, --开户银行
             NULL KPSKZH, --公司收款账号
             NULL KPSKHM, --公司收款名
             NULL KPSKYH, --公司收款银行
             NULL KPCBJQ, --抄表日期
             SYSDATE KPRQ, --开票日期
             CASE
               WHEN MIN(RL.RLSCRRLMONTH) <> MAX(RL.RLSCRRLMONTH) THEN
                MIN(RL.RLSCRRLMONTH) || '-' || MAX(RL.RLSCRRLMONTH)
               ELSE
                MAX(RL.RLSCRRLMONTH)
             END KPZWMONTH, --账务月份
             TO_CHAR(SYSDATE, 'YYYY.MM') KPMONTH, --开票月份
             (CASE WHEN
                     RL.RLTRANS not in ('13', '14', '21', '23', 'V', 'U','v') and RLYSCHARGETYPE='M' THEN  --走收
                     MAX(fgetopername(RLRPER))  --收费员为抄表员
                   WHEN
                     RL.RLTRANS = '13' THEN  --补缴
                     --单据创建人员
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS in ('21','14') THEN  --稽查
                     --单据创建人员
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'v' THEN  --基建污水
                     --单据创建人员
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = 'u' THEN  --基建水费
                     --单据创建人员
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
                   WHEN
                     RL.RLTRANS = '23' THEN  --营销部
                     --单据创建人员
                     (select MAX(fgetopername(RTHCREPER)) from RECTRANSHD where rthrlid=RL.Rlscrrlid and rthshflag='Y')
              END) KPSFY, --收费员
             --FGETINVMEMO(MAX(RL.RLID), 'BFPPER') KPSFY, --收费员
             FGETBFRPER(MAX(MIBFID)) KPCBY, --抄表员
             FGETPBOPER KPDYY, --打印员
             MIN(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                        --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                               --'-',
                        null,
                               RL.RLSCODE))) KPQM, --起码
             MAX(DECODE(FGETIFDZSB(RL.RLMID),
                        'Y',
                       --'-',
                        null,
                        DECODE(FGETMETERSTATUS(RL.RLMID),
                               'Y',
                               --'-',
                        null,
                               RL.RLECODE))) KPZM, --止码
             SUM(RL.RLREADSL) KPCBSL, --抄表水量
             SUM(RL.RLADDSL) KPTZSL, --调整水量
             SUM(RL.RLSL) KPSSSL, --实收水量
             SUM(DECODE(MI.MIIFTAX, 'N', RLJE, CHARGE2)) KPJE, --应收总金额
             NULL KPJTDJ1, --一阶单价
             NULL KPJTDJ2, --二阶单价
             NULL KPJTDJ3, --三阶单价
             SUM(RD.USE_R1) KPJTSL1, --一阶水量
             SUM(RD.USE_R2) KPJTSL2, --二阶水量
             SUM(RD.USE_R3) KPJTSL3, --三阶水量
             SUM(RD.CHARGE_R1) KPJTJE1, --一阶金额
             SUM(RD.CHARGE_R2) KPJTJE2, --二阶金额
             SUM(RD.CHARGE_R3) KPJTJE3, --三阶金额
             SUM(RD.CHARGE1) KPJE1, --金额1
             SUM(RD.CHARGE2) KPJE2, --金额2
             SUM(RD.CHARGE3) KPJE3, --金额3
             SUM(RD.CHARGE4) KPJE4, --金额4
             SUM(RD.CHARGE5) KPJE5, --金额5
             SUM(RD.CHARGE6) KPJE6, --金额6
             SUM(RD.CHARGE7) KPJE7, --金额7
             NULL KPJE8, --金额8
             NULL KPJE9, --金额9
             RL.RLID RLID,
             NULL PID,
             NULL KPSQCBRQ --上期抄表日期
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
      --组织发票明细区数据
      SP_GET_INV_DETAIL(V_INV.RLID, P_PRINTTYPE, V_INV);
      --插入发票信息
      INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
      --插入发票明细
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

  --打印税票凭证（不计票号）
  PROCEDURE SP_PREPRINT_SPPZ(P_PRINTTYPE IN VARCHAR2,
                             P_INVTYPE   IN VARCHAR2,
                             P_INVNO     IN VARCHAR2,
                             O_CODE      OUT VARCHAR2,
                             O_ERRMSG    OUT VARCHAR2) IS
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    ERR_OTHERS EXCEPTION;
    V_RCOUNT NUMBER := 0;
    INVPT INVPARMTERMP%ROWTYPE;
    --遍历打印账务记录
    CURSOR C_INVLIST IS
      SELECT *
        FROM INVPARMTERMP;
  BEGIN
    O_CODE   := '00';
    O_ERRMSG := NULL;

    --初始化临时表传输数据
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;
    --检查是否存在已打印凭证
    --SELECT * FROM INVPARMTERMP
    V_PRC_MSG := '组织打印数据异常！';
    OPEN C_INVLIST;
    LOOP
      FETCH C_INVLIST
        INTO INVPT;
      EXIT WHEN C_INVLIST%NOTFOUND OR C_INVLIST%NOTFOUND IS NULL;
           NULL;
           IF INVPT.RLID IS NOT NULL THEN
             --应收开票
             SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE RLID=INVPT.RLID;
             IF V_RCOUNT=1 THEN
                --已开票，直接装载数据
                INSERT INTO INV_INFOTEMP_SP
                SELECT * FROM INV_INFO_PZ WHERE RLID=INVPT.RLID;
                INSERT INTO INV_DETAILTEMP_SP
                SELECT * FROM INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE RLID=INVPT.RLID);
             ELSE
               --可能存在多条凭证记录，会导致开票异常，删除重复记录，重新装载
               DELETE INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE RLID=INVPT.RLID);
               DELETE INV_INFO_PZ WHERE RLID=INVPT.RLID;
               IF P_PRINTTYPE = C_预存 THEN
                  SP_SWAPINVYC(P_PRINTTYPE);
                ELSIF P_PRINTTYPE = C_合票 THEN
                  SP_SWAPINVHP(P_PRINTTYPE);
                ELSIF P_PRINTTYPE = C_预开分票 THEN
                  SP_SWAPINVYKFP(P_PRINTTYPE);
                ELSE
                  V_PRC_MSG := '暂不支持的开票类型！';
                  RAISE ERR_OTHERS;
                END IF;
               NULL;
             END IF;

           ELSIF INVPT.PBATCH IS NOT NULL THEN
                 --实收开票
                 SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                 IF V_RCOUNT=1 THEN
                    --已开票，直接装载数据
                    INSERT INTO INV_INFOTEMP_SP
                    SELECT * FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                    INSERT INTO INV_DETAILTEMP_SP
                    SELECT * FROM INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH);
                 ELSE
                   --可能存在多条凭证记录，会导致开票异常，删除重复记录，重新装载
                   DELETE INV_DETAIL_PZ WHERE INVID IN (SELECT ID FROM INV_INFO_PZ WHERE BATCH=INVPT.PBATCH);
                   DELETE INV_INFO_PZ WHERE BATCH=INVPT.PBATCH;
                   IF P_PRINTTYPE = C_预存 THEN
                      SP_SWAPINVYC(P_PRINTTYPE);
                    ELSIF P_PRINTTYPE = C_合票 THEN
                      SP_SWAPINVHP(P_PRINTTYPE);
                    ELSIF P_PRINTTYPE = C_预开分票 THEN
                      SP_SWAPINVYKFP(P_PRINTTYPE);
                    ELSE
                      V_PRC_MSG := '暂不支持的开票类型！';
                      RAISE ERR_OTHERS;
                    END IF;
                   NULL;
                 END IF;
           END IF;
           SELECT COUNT(*) INTO V_RCOUNT FROM INV_INFO_PZ WHERE ID IN (SELECT ID FROM INV_INFOTEMP_SP);
           IF V_RCOUNT = 0 THEN
           --存储凭证打印记录
              INSERT INTO INV_INFO_PZ
              SELECT * FROM INV_INFOTEMP_SP;
              INSERT INTO INV_DETAIL_PZ
              SELECT * FROM INV_DETAILTEMP_SP;
            END IF;
    END LOOP;
    CLOSE C_INVLIST;



    SELECT COUNT(1) INTO V_RCOUNT FROM INV_INFOTEMP_SP;
    IF V_RCOUNT = 0 THEN
      V_PRC_MSG := '无可打印数据，请检查！';
      RAISE ERR_OTHERS;
    END IF;


  EXCEPTION
    WHEN ERR_OTHERS THEN
      O_CODE   := '99';
      O_ERRMSG := V_PRC_MSG;
      ROLLBACK;
  END;

  --易维云平台电子发票
  PROCEDURE SP_PREPRINT_EINVOICE(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                                 ) IS
    V_STEP     NUMBER; --事务处理进度变量，方便调试
    V_PRC_CODE VARCHAR2(10);
    V_PRC_MSG  VARCHAR2(400); --事务处理信息变量，方便调试
    ERR_OTHERS EXCEPTION;
    V_IFPRINT VARCHAR2(1);
    VCOUNT     NUMBER;
    V_PTYPE    VARCHAR2(300);
    V_AUTOFLAG     VARCHAR2(10); --自动开票标志
    V_BFNUM  NUMBER; --手动开票并发数
    V_TIME   VARCHAR2(50);
    V_SS     NUMBER;
    V_PID    VARCHAR(100);
  BEGIN
    --测试(单张开票，一次传入一张发票)
    --NSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms,memo1) Values('','0170509792','','N','R');
    --INSERT Into INVPARMTERMP(rlid,ifsms) Values('0313077670','N');

    O_CODE   := '00';
    O_ERRMSG := NULL;
    V_STEP   := 10;

    --电子发票全局开关
    V_PRC_MSG := '电子发票暂停服务!';
    IF NVL(fsyspara('1116'),'N') <> 'Y' THEN
       RAISE ERR_OTHERS;
    END IF;

    --增加手工并发
    --判断手动触发（非自动触发为手工触发）
    --如果开票并发满则等待，控制等待时长参数
    --排队成功，插入优先列队
    --开票成功或失败，释放列队
    IF NVL(fsyspara('1120'),'N') = 'Y' THEN
       NULL;
       SELECT NVL(MAX(MEMO2),'N') INTO V_AUTOFLAG FROM INVPARMTERMP;
       IF V_AUTOFLAG <> 'Y' THEN --自动开票标志
          --手工开票
          --检查并发数
          V_TIME := TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS');
          LOOP
            SELECT COUNT(*) INTO V_BFNUM FROM PAY_EINV_JOB_LOG WHERE PERRID='9';
            IF fsyspara('1119') <= V_BFNUM THEN
               --并发已满则等待
               --检查等待时长
               select ceil((sysdate - TO_DATE(V_TIME,'YYYYMMDD HH24:MI:SS')) * 24 * 60 * 60) INTO V_SS FROM DUAL;
               IF fsyspara('1121') <= V_SS THEN --超时
                 UPDATE PAY_EINV_JOB_LOG SET PERRID='1' WHERE PERRID='9';
                 COMMIT;
                 V_PRC_MSG := '电子发票服务繁忙，开票请求超时!';
                 RAISE ERR_OTHERS;
               END IF;
               DBMS_LOCK.SLEEP(1);
            ELSE
              --插入列队优先级
              IF P_PRINTTYPE = C_预存 OR P_PRINTTYPE = C_合票 THEN
                 SELECT NVL(MAX(pbatch),'N') INTO V_PID FROM INVPARMTERMP;
              ELSE
                 SELECT NVL(MAX(RLID),'N') INTO V_PID FROM INVPARMTERMP;
              END IF;
              P_QUEUE(V_PID,'INSERT');
              EXIT; --并发未满则通过
            END IF;
          END LOOP;

       END IF;
    END IF;
    --重开、补开发票，删除原票据数据
    --重开R：由于商品流水号唯一，1、电厂开票提示失败；2、开票数据异常；
    --补开A：水司已开票，电厂未收到
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    V_PRC_MSG := '组织发票数据参数异常:打印类型不能为空!';
    IF P_PRINTTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '组织发票数据参数异常:发票类别不能为空!';
    IF P_INVTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '组织发票数据参数异常:' || FGETSCLNAME('发票类别', P_INVTYPE) ||
                 '发票号不能为空!';
    IF P_INVNO IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;

    V_PRC_MSG := '不允许重复开具电子发票!';
    IF NOT (V_PTYPE='R' OR V_PTYPE='A') THEN
      IF P_PRINTTYPE = C_预存 OR P_PRINTTYPE = C_合票 THEN
        SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.PPBATCH=IP.PBATCH;
      ELSIF P_PRINTTYPE = C_预开分票 THEN
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
    --增加判断立即开具还是延迟开具
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')) INTO V_IFPRINT FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
    END;
    IF V_IFPRINT = 'L' THEN
      --延迟开具，暂时只支持按应收流水延迟开票
      FOR INV IN (SELECT RLID FROM INVPARMTERMP) LOOP
        SP_EINVOICE_DELAY(INV.RLID);
      END LOOP;
      RETURN;
    END IF;

    V_STEP    := 20;
    V_PRC_MSG := '组织发票数据!';

    --初始化发票临时表传输数据
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;

    IF /*V_PTYPE ='R' OR*/ V_PTYPE = 'A' THEN
       NULL;
       --删除原票组织数据
       SP_DELINV(P_PRINTTYPE);
    END IF;
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('','0170508084','','N');
    V_PRC_MSG := '组织打印数据异常！';
    IF P_PRINTTYPE = C_预存 THEN
      SP_SWAPINVYC(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_合票 THEN
      SP_SWAPINVHP(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_预开分票 THEN
      SELECT COUNT(*) INTO VCOUNT
      FROM RECLIST RL,METERINFO MI,INVPARMTERMP IPT
      WHERE RLMID = MIID
      AND RL.RLID = IPT.RLID
      AND RL.RLTRANS='u'
      AND MI.MIIFTAX='Y';
      IF VCOUNT>0 THEN
         V_PRC_MSG := '用户是增值税用户,不允许开具基建水费电票,请检查！';
         RAISE ERR_OTHERS;
      END IF;
      SP_SWAPINVYKFP(P_PRINTTYPE, P_SLTJ);
    ELSE
      V_PRC_MSG := '暂不支持的开票类型！';
      RAISE ERR_OTHERS;
    END IF;

    --生成开票记录
    V_STEP    := 30;
    V_PRC_MSG := '组织发票数据!';
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
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                                 ) IS
    V_STEP     NUMBER; --事务处理进度变量，方便调试
    V_PRC_CODE VARCHAR2(10);
    V_PRC_MSG  VARCHAR2(400); --事务处理信息变量，方便调试
    ERR_OTHERS EXCEPTION;
    V_IFPRINT VARCHAR2(1);
    VCOUNT     NUMBER;
    V_PTYPE    VARCHAR2(300);
    V_AUTOFLAG     VARCHAR2(10); --自动开票标志
    V_BFNUM  NUMBER; --手动开票并发数
    V_TIME   VARCHAR2(50);
    V_SS     NUMBER;
    V_PID    VARCHAR(100);
  BEGIN
    --测试(单张开票，一次传入一张发票)
    IF P_PBATCH IS NOT NULL THEN
       INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms,memo1) Values('',P_PBATCH,'','N','R');
    ELSIF P_RLID IS NOT NULL THEN
       INSERT Into INVPARMTERMP(rlid,ifsms,memo1) Values(P_RLID,'N','R');      
    END IF;
    
    --

    O_CODE   := '00';
    O_ERRMSG := NULL;
    V_STEP   := 10;

    --电子发票全局开关
    V_PRC_MSG := '电子发票暂停服务!';
    IF NVL(fsyspara('1116'),'N') <> 'Y' THEN
       RAISE ERR_OTHERS;
    END IF;

    --增加手工并发
    --判断手动触发（非自动触发为手工触发）
    --如果开票并发满则等待，控制等待时长参数
    --排队成功，插入优先列队
    --开票成功或失败，释放列队
    IF NVL(fsyspara('1120'),'N') = 'Y' THEN
       NULL;
       SELECT NVL(MAX(MEMO2),'N') INTO V_AUTOFLAG FROM INVPARMTERMP;
       IF V_AUTOFLAG <> 'Y' THEN --自动开票标志
          --手工开票
          --检查并发数
          V_TIME := TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS');
          LOOP
            SELECT COUNT(*) INTO V_BFNUM FROM PAY_EINV_JOB_LOG WHERE PERRID='9';
            IF fsyspara('1119') <= V_BFNUM THEN
               --并发已满则等待
               --检查等待时长
               select ceil((sysdate - TO_DATE(V_TIME,'YYYYMMDD HH24:MI:SS')) * 24 * 60 * 60) INTO V_SS FROM DUAL;
               IF fsyspara('1121') <= V_SS THEN --超时
                 UPDATE PAY_EINV_JOB_LOG SET PERRID='1' WHERE PERRID='9';
                 COMMIT;
                 V_PRC_MSG := '电子发票服务繁忙，开票请求超时!';
                 RAISE ERR_OTHERS;
               END IF;
               DBMS_LOCK.SLEEP(1);
            ELSE
              --插入列队优先级
              IF P_PRINTTYPE = C_预存 OR P_PRINTTYPE = C_合票 THEN
                 SELECT NVL(MAX(pbatch),'N') INTO V_PID FROM INVPARMTERMP;
              ELSE
                 SELECT NVL(MAX(RLID),'N') INTO V_PID FROM INVPARMTERMP;
              END IF;
              P_QUEUE(V_PID,'INSERT');
              EXIT; --并发未满则通过
            END IF;
          END LOOP;

       END IF;
    END IF;
    --重开、补开发票，删除原票据数据
    --重开R：由于商品流水号唯一，1、电厂开票提示失败；2、开票数据异常；
    --补开A：水司已开票，电厂未收到
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    V_PRC_MSG := '组织发票数据参数异常:打印类型不能为空!';
    IF P_PRINTTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '组织发票数据参数异常:发票类别不能为空!';
    IF P_INVTYPE IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;
    V_PRC_MSG := '组织发票数据参数异常:' || FGETSCLNAME('发票类别', P_INVTYPE) ||
                 '发票号不能为空!';
    IF P_INVNO IS NULL THEN
      RAISE ERR_OTHERS;
    END IF;

    V_PRC_MSG := '不允许重复开具电子发票!';
    IF NOT (V_PTYPE='R' OR V_PTYPE='A') THEN
      IF P_PRINTTYPE = C_预存 OR P_PRINTTYPE = C_合票 THEN
        SELECT COUNT(*) INTO VCOUNT
        FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES,INV_EINVOICE_RETURN IER,INVPARMTERMP IP
        WHERE IIS.ID=IES.ID AND
              IES.FPQQLSH=IER.FPQQLSH AND
              IIS.PPBATCH=IP.PBATCH;
      ELSIF P_PRINTTYPE = C_预开分票 THEN
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
    --增加判断立即开具还是延迟开具
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')) INTO V_IFPRINT FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
    END;
    IF V_IFPRINT = 'L' THEN
      --延迟开具，暂时只支持按应收流水延迟开票
      FOR INV IN (SELECT RLID FROM INVPARMTERMP) LOOP
        SP_EINVOICE_DELAY(INV.RLID);
      END LOOP;
      RETURN;
    END IF;

    V_STEP    := 20;
    V_PRC_MSG := '组织发票数据!';

    --初始化发票临时表传输数据
    DELETE INV_INFOTEMP_SP;
    DELETE INV_DETAILTEMP_SP;

    IF /*V_PTYPE ='R' OR*/ V_PTYPE = 'A' THEN
       NULL;
       --删除原票组织数据
       SP_DELINV(P_PRINTTYPE);
    END IF;
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('','0170508084','','N');
    V_PRC_MSG := '组织打印数据异常！';
    IF P_PRINTTYPE = C_预存 THEN
      SP_SWAPINVYC(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_合票 THEN
      SP_SWAPINVHP(P_PRINTTYPE, P_SLTJ);
    ELSIF P_PRINTTYPE = C_预开分票 THEN
      SELECT COUNT(*) INTO VCOUNT
      FROM RECLIST RL,METERINFO MI,INVPARMTERMP IPT
      WHERE RLMID = MIID
      AND RL.RLID = IPT.RLID
      AND RL.RLTRANS='u'
      AND MI.MIIFTAX='Y';
      IF VCOUNT>0 THEN
         V_PRC_MSG := '用户是增值税用户,不允许开具基建水费电票,请检查！';
         RAISE ERR_OTHERS;
      END IF;
      SP_SWAPINVYKFP(P_PRINTTYPE, P_SLTJ);
    ELSE
      V_PRC_MSG := '暂不支持的开票类型！';
      RAISE ERR_OTHERS;
    END IF;

    --生成开票记录
    V_STEP    := 30;
    V_PRC_MSG := '组织发票数据!';
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

  --插入列队
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
      --2分钟未解锁删除
      delete pay_einv_job_log 
      where perrid in ('9') AND
            (sysdate-pstime)*1440>2;
             COMMIT;
    END;
  --删除开票记录
  PROCEDURE SP_DELINV(P_TYPE IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID VARCHAR2(100);
    V_PBATCH VARCHAR2(100);
    V_ISID VARCHAR2(100);
  BEGIN
    IF P_TYPE='1' OR P_TYPE='2' THEN
      --实收开票
      NULL;
      SELECT MAX(PPBATCH) INTO V_PBATCH FROM INVPARMTERMP;
      --select * from INV_INFO_SP WHERE PPBATCH
      SELECT MAX(IIS.ID),MAX(ISID) INTO V_ID,V_ISID FROM INV_INFO_SP IIS,INVPARMTERMP IP,INV_EINVOICE_ST IES
      WHERE IIS.PPBATCH = IP.PPBATCH AND
            IIS.ID=IES.ID;
      DELETE INV_DETAIL_SP WHERE INVID = V_ID;
      DELETE INV_INFO_SP WHERE PPBATCH = V_PBATCH;
    ELSE
      --应收开票
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

  --电子发票延迟开票处理
  PROCEDURE SP_EINVOICE_DELAY(V_ID IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    IDE INV_DELAY%ROWTYPE;
  BEGIN
    DELETE FROM INV_DELAY
     WHERE RLID = V_ID
       AND IDSTATUS = '0';
    IDE          := NULL;
    IDE.RLID     := V_ID; --应收流水
    IDE.IDSTATUS := '0'; --开票状态（0=等待中，1=开票中，开票结束删除记录）
    SELECT NVL(MAX(ID), 0) + 1 INTO IDE.ID FROM INV_DELAY;
    INSERT INTO INV_DELAY VALUES IDE;
    COMMIT;
  END;

  --创建任务定时执行，检查打印队列，批量开票
  --目前按 5 线程设计，传入参数为 0~4
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
      --判断是否已开票
      IF FGETPRINTNUMFP('RLID', V_LIST.RLID) = 0 THEN
        --开票
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
        --提交保存打印记录
        COMMIT;
      END IF;
      --开票成功删除打印队列记录
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
      --判断是否已开票
      IF FGETPRINTNUMFP('RLID', V_LIST.RLID) = 0 THEN
        --开票
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
        --提交保存打印记录
        COMMIT;
      END IF;
      --开票成功删除打印队列记录
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

  --凭证明细行
  PROCEDURE SP_GET_INV_DETAIL(P_ID   IN VARCHAR2,
                              P_TYPE IN VARCHAR2,
                              P_INV  IN OUT INV_INFOTEMP_SP%ROWTYPE) IS
    --合票
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

    --合票
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
                                '1阶'
                               WHEN RDCLASS = 2 THEN
                                '2阶'
                               WHEN RDCLASS = 3 THEN
                                '3阶'
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

    --分票
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
                                '1阶'
                               WHEN RDCLASS = 2 THEN
                                '2阶'
                               WHEN RDCLASS = 3 THEN
                                '3阶'
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
    一户多表   BOOLEAN := FALSE;
    增值税用户 BOOLEAN := FALSE;
    MAXROW     NUMBER := 5; --明细最大行数
    V_RET      LONG;
    V_RET_SWAP LONG;
    V_BZ       LONG;
    v_list     number := 0;
  BEGIN

    V_RET := NULL;

    IF P_TYPE = C_预存 THEN
      --step 1 判断是一户一表还是一户多表
      V_COUNT := 0;
      SELECT COUNT(DISTINCT MIID)
        INTO V_COUNT
        FROM METERINFO, PAYMENT
       WHERE MIPRIID = PPRIID
         AND MIPRIFLAG = 'Y'
         AND PBATCH = P_ID;
      IF V_COUNT > 1 THEN
        一户多表 := TRUE;
      ELSE
        一户多表 := FALSE;
      END IF;

      IF 一户多表 THEN
        V_RET := V_RET || '水费单价：' || P_INV.MEMO06;
        V_RET := V_RET || '  污水处理费单价：' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || '元 ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '前次交费余额：' || CASE
                   WHEN P_INV.QCSAVING = 0 THEN
                    '0.00'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                 END || '元';
        V_RET := V_RET || '  本次交费后余额：' || CASE
                   WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                   --WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                    '0.00'
                   ELSE
                    TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2)
                 END || '元';
        V_RET := V_RET || '  预计可用水量(当前单价)：' || P_INV.MEMO04||' 立方米';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '当期表示数：';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || P_INV.MEMO08;

        --增加税票备注（一户多表预存）
        /*V_BZ := '用户号：' || P_INV.MICODE || '(' || P_INV.N2 || '表用户)' ||
                '，预计可用水量(当前单价)：' || P_INV.MEMO04 || '，本次交费后余额：' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || '元，交费日期：' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');*/
        V_BZ := '用户号：' || P_INV.MICODE || '(' || P_INV.N2 || '表用户)' ||
                '，预计可用水量' || P_INV.MEMO04 || '，单价：'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'元/立方米，本次交费后余额：' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || '元，交费日期：' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');
      ELSE
        V_RET := V_RET || '水费单价：' || P_INV.MEMO06;
        V_RET := V_RET || '  污水处理费单价：' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || '元 ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '前次交费余额：' || CASE
                   WHEN P_INV.QCSAVING = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                 END || '元';
        V_RET := V_RET || '  本次交费后余额：' || CASE
                   WHEN P_INV.QMSAVING = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.QMSAVING, 2)
                 END || '元';
        V_RET := V_RET || '  当期表示数：' || P_INV.MEMO07;
        V_RET := V_RET || '  预计表示数(当前单价)：' || P_INV.MEMO03;
        V_RET := V_RET || CHR(13);

        --增加税票备注（一户一表预存）
        V_BZ := '用户号：' || P_INV.MICODE || '，当期表示数：' || P_INV.MEMO07 ||
                '，预计表示数：' || P_INV.MEMO03 || '，单价：'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'元/立方米，本次交费后余额：' ||
                TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || '元，交费日期：' ||
                TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');

      END IF;

    ELSIF P_TYPE = C_合票 THEN
      --step 1 判断是一户一表还是一户多表，判断是否增值税用户
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
        一户多表 := TRUE;
      ELSE
        一户多表 := FALSE;
      END IF;
      IF V_COUNT2 > 0 THEN
        增值税用户 := TRUE;
      ELSE
        增值税用户 := FALSE;
      END IF;

      IF 增值税用户 THEN
        V_RET := V_RET || '水费单价：' || P_INV.MEMO06;
        V_RET := V_RET || '  污水处理费单价：' || CASE
                   WHEN P_INV.DJ9 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                 END || '元 ';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '应收水量：' || P_INV.N1 || '立方米';
        V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || '元';
        V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || '元 ';
        V_BZ := '用户号：' || P_INV.MICODE || '(' || P_INV.N2 || '表用户)' ||
                  '，预计可用水量：' || P_INV.MEMO04 || '，单价：'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'元/立方米，本次交费后余额：' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || '元，交费日期：' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');
      ELSE
        IF 一户多表 THEN
          V_RET := V_RET || '水费单价：' || P_INV.MEMO06;
          V_RET := V_RET || '  污水处理费单价：' || CASE
                     WHEN P_INV.DJ9 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                   END || '元 ';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
          V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收水量：' || P_INV.N1 || '立方米';
          V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || '元';
          V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || '元';
          V_RET := V_RET || '  预计可用水量(当前单价)：' || P_INV.MEMO04 || '立方米';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收合计：' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || '元';
          V_RET := V_RET || '  前次交费余额：' || CASE
                     WHEN P_INV.QCSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                   END || '元';
          V_RET := V_RET || '  本次交费后余额：' || CASE
                     WHEN TO_NUMBER(P_INV.QMSAVING) = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2)
                   END || '元';
          V_RET := V_RET || '  违约金：' || TOOLS.FFORMATNUM(P_INV.ZNJ, 2) || '元';

          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '结算记录：';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('年月', 8, 'C') ||
                   FSETSTRALIGN('阶梯', 6, 'C') ||
                   FSETSTRALIGN('水量', 10, 'C') ||
                   FSETSTRALIGN('水费单价', 10, 'C') ||
                   FSETSTRALIGN('水费', 10, 'C') ||
                   FSETSTRALIGN('污水处理费单价', 16, 'C') ||
                   FSETSTRALIGN('污水处理费', 12, 'C') ||
                   FSETSTRALIGN('小计', 10, 'C');
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
              RAISE_APPLICATION_ERROR(ERRCODE, '账务记录不存在');
            END IF;*/
            OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
          LOOP
            FETCH C_CUR2
              INTO V_CUR2;
            EXIT WHEN  C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL;


            V_ROW := V_ROW + 1;
            if V_ROW <= MAXROW then
            --年月
            V_RET := V_RET ||
                     FSETSTRALIGN(TRIM(SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              1,
                                              4) ||
                                       SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              6,
                                              2)),
                                  8,
                                  'C');
            --阶梯
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.JT, 6, 'C');
              --水量
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDSL, 10, 'C');
              --水费单价
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDDJ, 10, 'C');
              --水费
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDJE01, 10, 'C');
              --污水处理费单价
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSDJ, 16, 'C');
              --污水处理费
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSJE, 12, 'C');
              --小计
              V_RET := V_RET || FSETSTRALIGN(V_CUR2.XJ, 10, 'C');

              --IF V_ROW < V_CUR2.CN AND V_ROW < MAXROW THEN
              V_RET := V_RET || CHR(13);
              --END IF;
            END IF;
            END LOOP;
            CLOSE C_CUR2;
          END LOOP;
          CLOSE C_CUR1;
          V_RET := V_RET || '当期表示数：';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || P_INV.MEMO08;

          --增加税票备注（一户多表交费）
          V_BZ := '用户号：' || P_INV.MICODE || '(' || P_INV.N2 || '表用户)' ||
                  '，预计可用水量：' || P_INV.MEMO04 ||  '，单价：'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'元/立方米，本次交费后余额：' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) || '元，交费日期：' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');

        ELSE
          V_RET := V_RET || '水费单价：' || P_INV.MEMO06;
          V_RET := V_RET || '  污水处理费单价：' || CASE
                     WHEN P_INV.DJ9 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ9, 2)
                   END || '元';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
          V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收水量：' || P_INV.N1 || '立方米';
          V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || '元';
          V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || '元';
          V_RET := V_RET || '  预计表示数(当前单价)：' || P_INV.MEMO03;
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收合计：' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || '元';
          V_RET := V_RET || '  前次交费余额：' || CASE
                     WHEN P_INV.QCSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QCSAVING, 2)
                   END || '元';
          V_RET := V_RET || '  本次交费后余额：' || CASE
                     WHEN P_INV.QMSAVING = 0 THEN
                      '0.00'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.QMSAVING, 2)
                   END || '元';
          V_RET := V_RET || '  违约金：' || TOOLS.FFORMATNUM(P_INV.ZNJ, 2) || '元';

          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '结算记录：';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('年月', 8, 'C') ||
                   FSETSTRALIGN('表示数', 8, 'C') ||
                   FSETSTRALIGN('阶梯', 6, 'C') ||
                   FSETSTRALIGN('水量', 10, 'C') ||
                   FSETSTRALIGN('水费单价', 10, 'C') ||
                   FSETSTRALIGN('水费', 10, 'C') ||
                   FSETSTRALIGN('污水处理费单价', 16, 'C') ||
                   FSETSTRALIGN('污水处理费', 12, 'C') ||
                   FSETSTRALIGN('小计', 10, 'C');
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
              RAISE_APPLICATION_ERROR(ERRCODE, '账务记录不存在');
            END IF;
            CLOSE C_CUR2;*/
            OPEN C_CUR2(P_ID, V_CUR1.RLPRIMCODE, V_CUR1.RLMONTH);
          LOOP
            FETCH C_CUR2
              INTO V_CUR2;
            EXIT WHEN  C_CUR2%NOTFOUND OR C_CUR2%NOTFOUND IS NULL;
            V_ROW := V_ROW + 1;
            if V_ROW <= MAXROW then
            --年月
            V_RET := V_RET ||
                     FSETSTRALIGN(TRIM(SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              1,
                                              4) ||
                                       SUBSTR(NVL(V_CUR1.RLMONTH, '1990.01'),
                                              6,
                                              2)),
                                  8,
                                  'C');
            --表示数
            IF FGETIFDZSB(V_CUR1.RLCID) = 'Y' THEN
              V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
            ELSIF FGETMETERSTATUS(V_CUR1.RLCID) = 'Y' THEN
              V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
            ELSE
               V_RET := V_RET || FSETSTRALIGN(V_CUR1.RLECODE, 8, 'C');
               V_CUR1.RLECODE := null;
            END IF;
            --阶梯
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.JT, 6, 'C');
            --水量
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDSL, 10, 'C');
            --水费单价
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDDJ, 10, 'C');
            --水费
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.RDJE01, 10, 'C');
            --污水处理费单价
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSDJ, 16, 'C');
            --污水处理费
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.WSJE, 12, 'C');
            --小计
            V_RET := V_RET || FSETSTRALIGN(V_CUR2.XJ, 10, 'C');

            --IF V_ROW < V_CUR2.CN AND V_ROW < MAXROW THEN
            V_RET := V_RET || CHR(13);
            --END IF;
            end if;
            END LOOP;
          CLOSE C_CUR2;
          END LOOP;
          CLOSE C_CUR1;

          --增加税票备注（一户一表交费）
          V_BZ := '用户号：' || P_INV.MICODE || '，当期表示数：' ||
                  FGETMETERINFO(P_INV.MICODE, 'MIRCODE') || '，预计表示数：' ||
                  P_INV.MEMO03 || '，单价：'||TOOLS.FFORMATNUM(P_INV.Dj,2) ||'元/立方米，本次交费后余额：' ||
                  TOOLS.FFORMATNUM(TO_NUMBER(P_INV.QMSAVING), 2) ||
                  '元，交费日期：' ||
                  TO_CHAR(P_INV.KPSQCBRQ, 'YYYY"年"MM"月"DD"日"');
        END IF;

      END IF;

    ELSIF P_TYPE = C_分票 THEN
      NULL;

    ELSIF P_TYPE = C_预开合票 THEN
      NULL;

    ELSIF P_TYPE = C_预开分票 THEN
      --step1 判断应收事务
      SELECT * INTO RL FROM RECLIST WHERE RLID = P_ID;

      IF RL.RLTRANS IN ('13', '14', '21', '23') THEN
        --补缴
        V_RET := V_RET || '水费单价：' || CASE
                   WHEN P_INV.DJ5 IS NULL THEN
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2) || '元'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ1 + P_INV.DJ5, 2) || '-' ||
                    TOOLS.FFORMATNUM(P_INV.DJ5, 2) || '=' ||
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2) || '元'
                 END;
        V_RET := V_RET || '  污水处理费单价：' || CASE
                   WHEN P_INV.DJ6 IS NULL THEN
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2) || '元'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2 + P_INV.DJ6, 2) || '-' ||
                    TOOLS.FFORMATNUM(P_INV.DJ6, 2) || '=' ||
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2) || '元'
                 END;
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '应收水量：' || P_INV.KPSSSL || '立方米';
        V_RET := V_RET || '  水费：' ||
                 TOOLS.FFORMATNUM(P_INV.KPSSSL * P_INV.DJ1, 2) || '元';
        V_RET := V_RET || '  污水处理费：' ||
                 TOOLS.FFORMATNUM(P_INV.KPSSSL * P_INV.DJ2, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '合计金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '补缴类别：' || P_INV.MEMO12;
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '备注：' || P_INV.MEMO13;
        V_RET := V_RET || CHR(13);
      ELSIF RL.RLTRANS = LOWER('u') THEN
        --基建水费
        V_RET := V_RET || '水费单价：' || CASE
                   WHEN P_INV.DJ1 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                 END || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '应收水量：' || P_INV.KPSSSL || '立方米';
        V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费项目：基建水费';
        V_RET := V_RET || CHR(13);
      ELSIF RL.RLTRANS = LOWER('v') THEN
        --基建污水
        V_RET := V_RET || '污水处理费单价：' || CASE
                   WHEN P_INV.DJ2 = 0 THEN
                    '-'
                   ELSE
                    TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                 END || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '应收水量：' || P_INV.KPSSSL || '立方米';
        V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '交费项目：基建污水处理费';
        V_RET := V_RET || CHR(13);
        V_RET := V_RET || '项目名称：' || P_INV.MEMO10;
        V_RET := V_RET || CHR(13);
      ELSE
        --走收
        SELECT SUM(DECODE(NVL(MIIFTAX, 'N'), 'Y', 1, 0))
          INTO V_COUNT2
          FROM METERINFO
         WHERE MIID = RL.RLMID;
        IF V_COUNT2 > 0 THEN
          增值税用户 := TRUE;
        ELSE
          增值税用户 := FALSE;
        END IF;

        IF 增值税用户 THEN
          V_RET := V_RET || '水费单价：' || CASE
                     WHEN P_INV.DJ1 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                   END || '元';
          V_RET := V_RET || '  污水处理费单价：' || CASE
                     WHEN P_INV.DJ2 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                   END || '元';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
          V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '账务年月：' || P_INV.KPZWMONTH;
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收水量：' || P_INV.KPSSSL || '立方米';
          V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || '元';
          V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || '元';
          V_RET := V_RET || CHR(13);
        ELSE
          V_RET := V_RET || '水费单价：' || CASE
                     WHEN P_INV.DJ1 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ1, 2)
                   END || '元';
          V_RET := V_RET || '  污水处理费单价：' || CASE
                     WHEN P_INV.DJ2 = 0 THEN
                      '-'
                     ELSE
                      TOOLS.FFORMATNUM(P_INV.DJ2, 2)
                   END || '元';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '交费金额：' || TOOLS.FFORMATNUM(P_INV.FKJE, 2) || '元';
          V_RET := V_RET || '  金额(大写)：' || TOOLS.FUPPERNUMBER(P_INV.FKJE);
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '应收水量：' || P_INV.KPSSSL || '立方米';
          V_RET := V_RET || '  水费：' || TOOLS.FFORMATNUM(P_INV.KPJE1, 2) || '元';
          V_RET := V_RET || '  污水处理费：' || TOOLS.FFORMATNUM(P_INV.KPJE2, 2) || '元';
          V_RET := V_RET || '应收合计：' || TOOLS.FFORMATNUM(P_INV.XZJE, 2) || '元';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || '结算记录：';
          V_RET := V_RET || CHR(13);
          V_RET := V_RET || FSETSTRALIGN('年月', 8, 'C') ||
                   FSETSTRALIGN('表示数', 8, 'C') ||
                   FSETSTRALIGN('阶梯', 6, 'C') ||
                   FSETSTRALIGN('水量', 10, 'C') ||
                   FSETSTRALIGN('水费单价', 10, 'C') ||
                   FSETSTRALIGN('水费', 10, 'C') ||
                   FSETSTRALIGN('污水处理费单价', 16, 'C') ||
                   FSETSTRALIGN('污水处理费', 12, 'C') ||
                   FSETSTRALIGN('小计', 10, 'C');
          V_RET := V_RET || CHR(13);

          V_ROW := 0;
          OPEN C_CUR3(RL.RLID);
          FETCH C_CUR3
            INTO V_CUR3;
          IF C_CUR3%NOTFOUND OR C_CUR3%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '账务记录不存在');
          END IF;
          CLOSE C_CUR3;
          V_ROW := V_ROW + 1;
          --年月
          V_RET := V_RET ||
                   FSETSTRALIGN(TRIM(SUBSTR(NVL(RL.RLMONTH, '1990.01'),
                                            1,
                                            4) ||
                                     SUBSTR(NVL(RL.RLMONTH, '1990.01'),
                                            6,
                                            2)),
                                8,
                                'C');
          --表示数
          IF FGETIFDZSB(RL.RLCID) = 'Y' THEN
            V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
          ELSIF FGETMETERSTATUS(RL.RLCID) = 'Y' THEN
            V_RET := V_RET || FSETSTRALIGN('-', 8, 'C');
          ELSE
            V_RET := V_RET || FSETSTRALIGN(RL.RLECODE, 8, 'C');
          END IF;
          --阶梯
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.JT, 6, 'C');
          --水量
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDSL, 10, 'C');
          --水费单价
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDDJ, 10, 'C');
          --水费
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.RDJE01, 10, 'C');
          --污水处理费单价
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.WSDJ, 16, 'C');
          --污水处理费
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.WSJE, 12, 'C');
          --小计
          V_RET := V_RET || FSETSTRALIGN(V_CUR3.XJ, 10, 'C');

          --IF V_ROW < V_CUR3.CN AND V_ROW < MAXROW THEN
          V_RET := V_RET || CHR(13);
          --END IF;

        END IF;

      END IF;

      --增加税票备注
      V_BZ := '用户号：' || P_INV.MICODE ||

                    CASE WHEN RL.RLTRANS in ('13', '14', '21') THEN
                      null
                     ELSE
                       '，帐卡号：' || P_INV.MEMO11 || '，指针：' ||
              TO_CHAR(P_INV.KPZM)
                   END/*FGETMETERINFO(P_INV.MICODE, 'MIRCODE')*/ || '，系统账务年月：' ||
              P_INV.KPZWMONTH;
      if  RL.RLTRANS in (LOWER('v'),LOWER('u')) then
         V_BZ := '临时用水审批号：'|| P_INV.MICODE  ;
      end if;
    END IF;

    IF LENGTH(V_RET) > 1 THEN
      V_RET := SUBSTR(V_RET, 1, LENGTH(V_RET) - 1);
      V_RET := REPLACE(V_RET, '/', CHR(13));
    END IF;

    P_INV.MEMO17 := V_BZ; --税票备注
    P_INV.MEMO20 := substr(V_RET,1,2000); --凭证明细备注

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

  --去除字符串特殊字符
  FUNCTION FGETFORMAT(P_STR IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET VARCHAR2(400);
  BEGIN
    --去空格
    V_RET := TRIM(P_STR);
    IF V_RET IS NULL THEN
      RETURN NULL;
    ELSE
      --去TAB制表符
      V_RET := REPLACE(V_RET, CHR(9), '');
      --去回车符
      V_RET := REPLACE(V_RET, CHR(10), '');
      --去换行符
      V_RET := REPLACE(V_RET, CHR(13), '');
      --去空格
      --V_RET := REPLACE(V_RET, ' ', '');
      V_RET := TRIM(V_RET);
      RETURN V_RET;
    END IF;
  END;

  --设置字符串对齐（C=居中，L=左对齐，R=右对齐）
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
    --取字节数，简单判断汉字
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

  --判断用户是否为免抄户
  FUNCTION FGETMETERSTATUS(P_CODE IN VARCHAR2 --用户号
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

  --获取一户多表期末预存余额
  FUNCTION FGETHSQMSAVING(P_MIID IN VARCHAR2 --客户代码
                          ) RETURN VARCHAR2 AS
    V_PRIID VARCHAR2(10);
    V_RET   VARCHAR2(20);
  BEGIN
    --求合收主表号
    SELECT MIPRIID INTO V_PRIID FROM METERINFO WHERE MIID = P_MIID;
    --求主表预存余额
    SELECT MISAVING INTO V_RET FROM METERINFO WHERE MIID = V_PRIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '0';
  END FGETHSQMSAVING;

  --获取合收户数
  FUNCTION FGETHSCODE(P_MIID IN VARCHAR2 --客户代码
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

  --发票打印明细(一户多表)
  FUNCTION FGETHSINVDEATIL(P_MIID IN VARCHAR2 --客户代码
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
    V_ROW    := 6; --行限制
    V_COLUMN := 3; --列限制

    SELECT MIPRIID INTO P_CODE FROM METERINFO WHERE MIID = P_MIID;
    OPEN C_DETAIL(P_CODE);
    LOOP
      FETCH C_DETAIL
        INTO V_DETAIL.MIID, V_DETAIL.MIRCODECHAR;
      EXIT WHEN C_DETAIL%NOTFOUND OR C_DETAIL%NOTFOUND IS NULL;
      /*    IF V_DETAIL.MIID = P_MIID THEN
        --V_TYPE := '(合收主表)';
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

  --获取用户新账卡号（表册号+册内序号）
  FUNCTION FGETNEWCARDNO(P_MIID IN VARCHAR2 --客户代码
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

  --获取备注信息
  FUNCTION FGETINVMEMO(P_RLID IN VARCHAR2, --应收流水
                       P_TYPE IN VARCHAR2 --备注类型
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
      SELECT FGETOPERNAME(BFRPER) --20160530 将收费员改成抄表员
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

  --获取发票二维码
 FUNCTION FGETINVEWM(P_ID   IN VARCHAR2, --发票提取码
                      P_TYPE IN VARCHAR2 --提取码类型
                      ) RETURN VARCHAR2 IS
    V_RET      VARCHAR2(400);
    V_IP       VARCHAR2(40) := 'www.hrbwatercsc.com';
    V_PORT     VARCHAR2(40) := '';
    V_TENANTID VARCHAR2(40);
    V_MIID     METERINFO.MIID%TYPE;
  BEGIN
    --V_TENANTID := PG_EWIDE_EINVOICE.F_GET_PARM('租户ID');
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

   --提升优先级
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
  --开票记录临时表MEMO2 用于判断自动开票
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
      perrtext = '开票失败'
  WHERE PBATCH = P_PBATCH;
  commit;
END SP_PREPRINT_EINVOICE_JOBRUN;

/*
P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
*/
  --缴费时调用
  PROCEDURE SP_PAY_EINV_RUNbak(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2) IS
  vjobid  binary_integer;
  V_ROW  NUMBER;
  V_STR  VARCHAR2(4000);
  BEGIN
    /*
    errid:
    =0,正在开票
    =1,正常开票
    =2，账务类型包含应收开票业务
    =3，该缴费批次已开过发票
    =4，后台开票业务执行异常报错
    =5，应收账中存在已开电票信息
    =6,开票异常
    =7,JOB无返回，自动恢复
    ------------------------------
    应收开票类型
    ('13', '14', '21', '23', 'V', 'U','v')
    */
    NULL;
    --INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
    --P_TYPE=2 开票类型为实收开票，P_TYPE=1为应收开票（暂未开启）
    --1、应收开票类型屏蔽
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND
          PBATCH=P_PBATCH AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M');
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'2','包含应收开票账务类型');
       --此处不commit，保持事物完整性
       RETURN;
    END IF;

    --2、检查实收记录是否已开过发票
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,INV_INFO_SP IIS
    WHERE P.PID=IIS.PID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'3','该缴费批次已开过发票');
       RETURN;
    END IF;
    --3、检查应收中是否存在开票记录
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,RECLIST RL,INV_INFO_SP IIS
    WHERE P.PID=RL.RLPID AND  RL.RLID=IIS.RLID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'4','应收账中存在已开电票信息');
       RETURN;
    END IF;
    --DELETE INVPARMTERMP;
    --开票记录临时表
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',P_PBATCH,'','N');
    --4、执行过程调用
    --判断缴费类型（预存、合票）
    --销账模式，剔除预存调拨、预存抵扣（合票）
    /*
    列队10分钟，自动清理状态，避免堵塞
    列队
    5条，延时5秒
    10条，30秒
    20条，1分钟
    --dbms_lock.sleep(1);
    */
    SELECT count(*) INTO V_ROW
    FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND PBATCH=P_PBATCH and PTRANS not in('K','U') AND PPAYMENT>0;
    --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
    IF V_ROW > 0 THEN
       --合票
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
      --预存
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
       values (vjobid,P_PBATCH,'Y',SYSDATE,SYSDATE,'0','正在开票');
    --dbms_job.run(vjobid);
  EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'5','后台开票业务执行异常报错');
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
    =0,正在开票
    =1,正常开票
    =2，账务类型包含应收开票业务
    =3，该缴费批次已开过发票
    =4，后台开票业务执行异常报错
    =5，应收账中存在已开电票信息
    =6,开票异常
    =7,JOB无返回，自动恢复
    =8，JOB提交中
    ------------------------------
    应收开票类型
    ('13', '14', '21', '23', 'V', 'U','v','M')
    */
    NULL;
    --INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
    --P_TYPE=2 开票类型为实收开票，P_TYPE=1为应收开票（暂未开启）
    --1、应收开票类型屏蔽
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND
          PBATCH=P_PBATCH AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M');
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'2','包含应收开票账务类型');
       --此处不commit，保持事物完整性
       RETURN;
    END IF;

    --2、检查实收记录是否已开过发票
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,INV_INFO_SP IIS
    WHERE P.PID=IIS.PID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'3','该缴费批次已开过发票');
       RETURN;
    END IF;
    --3、检查应收中是否存在开票记录
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,RECLIST RL,INV_INFO_SP IIS
    WHERE P.PID=RL.RLPID AND  RL.RLID=IIS.RLID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'4','应收账中存在已开电票信息');
       RETURN;
    END IF;
    SELECT SUM(PPAYMENT) INTO V_ROW FROM PAYMENT P WHERE P.PBATCH=P_PBATCH;
    IF V_ROW = 0 THEN
      /*INSERT INTO pay_einv_job_log(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'10','付款金额为0不开电票');*/
       RETURN;
    END IF;
    --DELETE INVPARMTERMP;
    --开票记录临时表
    --INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',P_PBATCH,'','N');
    --4、执行过程调用
    --判断缴费类型（预存、合票）
    --销账模式，剔除预存调拨、预存抵扣（合票）

    SELECT count(*) INTO V_ROW
    FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND PBATCH=P_PBATCH and PTRANS not in('K','U') AND PPAYMENT>0;
    --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
    IF V_ROW > 0 THEN
       --合票
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
      --预存
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
      --银行预存V_ROW=0
      SELECT COUNT(*) INTO V_ROW
      FROM PAYMENT,RECLIST WHERE PID=RLPID AND PTRANS='B' AND PPAYMENT>0 AND PBATCH=P_PBATCH;
      IF V_ROW = 0 THEN
         V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
      END IF;*/
    END IF;
    /*
    判断优先级
    1=柜台缴费
    2=其他缴费
    */
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT WHERE PBATCH=P_PBATCH AND PTRANS IN ('P','S');
    IF V_ROW > 0 THEN
       --柜台
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
       values (P_PBATCH,'Y',SYSDATE,SYSDATE,'5','后台开票业务执行异常报错');
  END ;
--JOB列队任务，2秒执行一次
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
   --全局开关控制是否提交任务
   SELECT NVL(fsyspara('1116'),'N') INTO V_FLAG FROM DUAL;
   IF V_FLAG<>'Y' THEN
     RETURN;
   END IF;
   --最大限制数量
   SELECT to_number(fsyspara('1118')) INTO V_MAXNUM FROM DUAL;
   SELECT COUNT(*) INTO V_MAXNUM1 FROM PAY_EINV_JOB_LOG WHERE (PERRID='8' or PERRID='9');
   IF V_MAXNUM1 >= V_MAXNUM THEN
     RETURN;
   END IF;

   /*select to_char(sysdate,'hh24:mi:ss') INTO VTIME from dual;
   IF VTIME > VTIME2 OR VTIME < VTIME1 THEN
     VNUM := 2;
   END IF; */
   --根据税盘数量提交
   select count(*) into VNUM from invlist where 有效标志='Y';
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
     --入口先更新
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


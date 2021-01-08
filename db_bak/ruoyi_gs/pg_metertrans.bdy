CREATE OR REPLACE PACKAGE BODY PG_METERTRANS IS

  --工单主程序-用户变更审核
  PROCEDURE SP_METERTRANS(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          ) AS
    MH REQUEST_YHZT%ROWTYPE;
    MD REQUEST_YHZT%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM REQUEST_YHZT WHERE RENO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
  
    IF MH.REFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;
  
    FOR MD IN (SELECT * FROM REQUEST_YHZT WHERE RENO = P_MTHNO) LOOP
      --SP_METERTRANSONE(P_TYPE, P_PER, MD);
      IF P_TYPE IN ('F') THEN
        --旧表状态
        UPDATE BS_METERDOC
           SET MDSTATUS = '4',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MD.MDNO
           AND MDSTATUS = '1';
        --销户拆表旧表所有封号作废
      END IF; -------------
      IF P_TYPE IN ('L', 'K') THEN
        --旧表状态
        INSERT INTO BS_METERDOC
          SELECT ID,
                 MDID,
                 MDNO,
                 MDCALIBER,
                 MDBRAND,
                 MDMODEL,
                 '4' MDSTATUS,
                 MDSTATUSDATE,
                 MDCYCCHKDATE,
                 MDSTOCKDATE,
                 MDSTORE,
                 SFH,
                 DQSFH,
                 DQGFH,
                 JCGFH,
                 QFH,
                 MDFQ1,
                 MDFQ2,
                 MDFQ3,
                 MDFQ4,
                 MDFQ5,
                 BARCODE,
                 RFID,
                 IFDZSB,
                 CONCENTRATORID,
                 READMETERCODE,
                 TRANSFERSTYPE,
                 COLLENTTYPE,
                 ISCONTROL,
                 READTYPE,
                 RKBATCH,
                 RKDNO,
                 STOREROOMID,
                 RKMAN,
                 P_PER MAINMAN,
                 SYSDATE MAINDATE,
                 SJDATE,
                 MDMODE,
                 PORTNO
            FROM BS_METERDOC
           WHERE MDNO = MD.MDNO
             AND MDSTATUS = '1';
        UPDATE BS_METERDOC
           SET MDSTATUS = '3', MDID = '', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE MDNO = MD.MDNO
           AND MDSTATUS = '1';
/*        --故障换表、周期换表旧表所有封号作废
        UPDATE BS_METERDOC
           SET MDSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE MDNO = MD.MDNO
           AND MDSTATUS = '1';*/
        --新表状态
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = MD.MIID
         WHERE MDNO = MD.MDNO AND MDSTATUS = '4';
      
        --重置正常表态
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MD.MIID;
        --去掉倒表标志
        UPDATE BS_METERDOC T SET T.IFDZSB = 'N' WHERE T.MDID = MD.MIID;
      END IF;
      IF P_TYPE = 'A' THEN
        UPDATE BS_METERINFO T
           SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
         WHERE T.MIID = MD.MIID;
      END IF;
    END LOOP;
  
    UPDATE REQUEST_GZHB
       SET REHSDATE = SYSDATE, REPER = P_PER, REFLAG = 'Y', MTDFLAG = 'Y'
     WHERE RENO = P_MTHNO;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --工单主程序-周期换表
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --操作类型
                               P_MTHNO  IN VARCHAR2, --批次流水
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2 --提交标志
                               ) AS
    MH REQUEST_GZHB%ROWTYPE;
    MD REQUEST_GZHB%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
    END;
    IF MH.REFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;
  
    FOR V_CURSOR IN (SELECT * FROM REQUEST_GZHB WHERE RENO = P_MTHNO) LOOP
      BEGIN
        SELECT * INTO MD FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
      END;
      ----------------表身码状态改变
      IF P_TYPE IN ('F') THEN
        --旧表状态
        INSERT INTO BS_METERDOC
          SELECT SEQMESTERDOCID.NEXTVAL ID,
                 MDID,
                 MDNO,
                 MDCALIBER,
                 MDBRAND,
                 MDMODEL,
                 '2' MDSTATUS,
                 MDSTATUSDATE,
                 MDCYCCHKDATE,
                 MDSTOCKDATE,
                 MDSTORE,
                 SFH,
                 DQSFH,
                 DQGFH,
                 JCGFH,
                 QFH,
                 MDFQ1,
                 MDFQ2,
                 MDFQ3,
                 MDFQ4,
                 MDFQ5,
                 BARCODE,
                 RFID,
                 IFDZSB,
                 CONCENTRATORID,
                 READMETERCODE,
                 TRANSFERSTYPE,
                 COLLENTTYPE,
                 ISCONTROL,
                 READTYPE,
                 RKBATCH,
                 RKDNO,
                 STOREROOMID,
                 RKMAN,
                 P_PER MAINMAN,
                 SYSDATE MAINDATE,
                 SJDATE,
                 MDMODE,
                 PORTNO
            FROM BS_METERDOC
           WHERE MDNO = MD.MDNO
             AND MDSTATUS = '1';
        UPDATE BS_METERDOC
           SET MDSTATUS = '',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MD.MDNO
           AND MDSTATUS = '1';
      
      END IF;
      IF P_TYPE IN ('L', 'K') THEN
        --旧表状态
        INSERT INTO BS_METERDOC
          SELECT ID,
                 MDID,
                 MDNO,
                 MDCALIBER,
                 MDBRAND,
                 MDMODEL,
                 '4' MDSTATUS,
                 MDSTATUSDATE,
                 MDCYCCHKDATE,
                 MDSTOCKDATE,
                 MDSTORE,
                 SFH,
                 DQSFH,
                 DQGFH,
                 JCGFH,
                 QFH,
                 MDFQ1,
                 MDFQ2,
                 MDFQ3,
                 MDFQ4,
                 MDFQ5,
                 BARCODE,
                 RFID,
                 IFDZSB,
                 CONCENTRATORID,
                 READMETERCODE,
                 TRANSFERSTYPE,
                 COLLENTTYPE,
                 ISCONTROL,
                 READTYPE,
                 RKBATCH,
                 RKDNO,
                 STOREROOMID,
                 RKMAN,
                 P_PER MAINMAN,
                 SYSDATE MAINDATE,
                 SJDATE,
                 MDMODE,
                 PORTNO
            FROM BS_METERDOC
           WHERE MDNO = MD.MDNO
             AND MDSTATUS = '1';
        UPDATE BS_METERDOC
           SET MDSTATUS = '',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MD.MDNO
           AND MDSTATUS = '1';
      
        --新表状态
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = MD.MIID
         WHERE MDNO = MD.NEWMDNO
           AND MDSTATUS = '0';
      END IF;
      IF P_TYPE = 'A' THEN
        UPDATE BS_METERINFO T
           SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
         WHERE T.MIID = MD.MIID;
      END IF;
    
      --免抄户、倒装水表 故障换表、周期换表后为正常户
      IF P_TYPE IN ('L', 'K') THEN
        --重置正常表态
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MD.MIID;
        --去掉倒表标志
        UPDATE BS_METERDOC T
           SET T.IFDZSB = 'N'
         WHERE T.MDID = MD.MIID
           AND MDSTATUS = '1';
      END IF;
    END LOOP;
  
    UPDATE REQUEST_GZHB
       SET REHSDATE = SYSDATE, REPER = P_PER, REFLAG = 'Y', MTDFLAG = 'Y'
     WHERE RENO = P_MTHNO;
  
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
END;
/


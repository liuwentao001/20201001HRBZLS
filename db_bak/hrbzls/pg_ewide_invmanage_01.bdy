CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_INVMANAGE_01" IS

  --总仓入库 zhangrong
  PROCEDURE HQINSTORE(P_IITYPE     IN CHAR, --票据类型
                      P_IIRECEIVER IN VARCHAR2, --入库人员
                      P_IISMFID    IN VARCHAR2, --入库单位
                      P_IIBCNO     IN VARCHAR2, --批次
                      P_IISNO      IN VARCHAR2, --起号
                      P_IIENO      IN VARCHAR2 --止号
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
  
    --检查票号段内是否有已入库的
    OPEN C1(P_IISNO, P_IIENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '库存中已存在该号码段中的票据');
    END IF;
    CLOSE C1;
  
    --插入invin表
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
  
    --循环插入invstock表
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

  --总仓出库 zhangrong
  PROCEDURE HQOUTSTORE(P_IOTYPE   IN CHAR, --票据类型
                       P_IOSENDER IN VARCHAR2, --出库人员
                       P_IOSMFID  IN VARCHAR2, --出库单位
                       P_IOBCNO   IN VARCHAR2, --批次
                       P_IOSNO    IN VARCHAR2, --起号
                       P_IOENO    IN VARCHAR2 --止号
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
  
    --检查票号段内是否有库存中不存在的
    SELECT COUNT(*)
      INTO CNT
      FROM INVSTOCK
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE
       AND ISPER = P_IOSENDER;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '该号码段有库存中不存在的票据');
    END IF;
  
    --检查票号段内是否有已使用或者作废的
    OPEN C1(P_IOSNO, P_IOENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '该号码段有已使用或者作废的票据');
    END IF;
    CLOSE C1;
  
    --插入invout表
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
  
    --删除invstock表数据
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

  --票据入库 zhangrong
  PROCEDURE INSTORE(P_IITYPE     IN CHAR, --票据类型
                    P_IISENDER   IN VARCHAR2, --派发人员
                    P_IIRECEIVER IN VARCHAR2, --领取人员
                    P_IISMFID    IN VARCHAR2, --入库单位
                    P_IIBCNO     IN VARCHAR2, --批次
                    P_IISNO      IN VARCHAR2, --起号
                    P_IIENO      IN VARCHAR2 --止号
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
      RAISE_APPLICATION_ERROR(ERRCODE, '不能派发给自己');
    END IF;
  
    SNONUM := TO_NUMBER(P_IISNO);
    ENONUM := TO_NUMBER(P_IIENO);
  
    --检查票号段内是否有已入库的
    OPEN C1(P_IISNO, P_IIENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '领票人已存在该号码段中的票据，不能派发');
    END IF;
    CLOSE C1;
  
    --检查派发人员是否有票号段内票据可发
    OPEN C2(P_IISNO, P_IIENO);
    FETCH C2
      INTO CNT;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '派发人不存在该号码段中的票据，不能派发');
    END IF;
    CLOSE C2;
  
    --检查派发人员是否票号从小到大派发
    /*open c3(p_iisno);
    fetch c3
      into rt_is;
    if c3%found then
      raise_application_error(errcode,
                              '派发人必须按从小到大的票号进行派发');
    end if;
    close c3;*/
  
    --插入invin表
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
  
    --改变库存所有人、营业所和状态
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

  --票据出库 zhangrong
  PROCEDURE OUTSTORE(P_IOTYPE     IN CHAR, --票据类型
                     P_IOSENDER   IN VARCHAR2, --派发人员
                     P_IORECEIVER IN VARCHAR2, --接收人员
                     P_IOSMFID    IN VARCHAR2, --出库单位
                     P_IOBCNO     IN VARCHAR2, --批次
                     P_IOSNO      IN VARCHAR2, --起号
                     P_IOENO      IN VARCHAR2 --止号
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
      RAISE_APPLICATION_ERROR(ERRCODE, '不能退票给自己');
    END IF;
  
    SNONUM := TO_NUMBER(P_IOSNO);
    ENONUM := TO_NUMBER(P_IOENO);
  
    --检查票号段内是否有库存中不存在的
    SELECT COUNT(*)
      INTO CNT
      FROM INVSTOCK
     WHERE ISNO >= P_IOSNO
       AND ISNO <= P_IOENO
       AND ISTYPE = P_IOTYPE
       AND ISPER = P_IOSENDER;
    IF CNT <> ENONUM - SNONUM + 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '该号码段有库存中不存在的票据');
    END IF;
  
    --检查票号段内是否有已使用或者作废的
    OPEN C1(P_IOSNO, P_IOENO);
    FETCH C1
      INTO RT_IS;
    IF C1%FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '该号码段有已使用或者作废的票据');
    END IF;
    CLOSE C1;
  
    --插入invout表
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
  
    --改变库存所有人和状态
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

  --记录打印票号 zhangrong
  PROCEDURE RECINVNO(P_ILNO     IN VARCHAR2, --票据号码(###|###|)
                     P_ILRLID   IN VARCHAR2, --应收流水(###|###|)
                     P_ILRDPIID IN VARCHAR2, --费用项目(###|###|)
                     P_ILJE     IN VARCHAR2, --票据金额(###|###|)
                     P_ILTYPE   IN CHAR, --票据类型
                     P_ILCD     IN CHAR, --借贷方向
                     P_ILPER    IN VARCHAR2, --出票人
                     P_ILSTATUS IN CHAR, --票据状态
                     P_ILSMFID  IN VARCHAR2 --分公司
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
    
      --验证票号是否可用
      OPEN C_IS(VILNO);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '无效发票号码：[' || VILNO || ']，请检查已领票据中是否存在');
      END IF;
      CLOSE C_IS;
    
      VILRLID   := TOOLS.FGETPARA2(P_ILRLID, I, 1);
      VILRDPIID := TOOLS.FGETPARA2(P_ILRDPIID, I, 1);
      VILJE     := TOOLS.FGETPARA2(P_ILJE, I, 1);
      SELECT SEQ_ILID.NEXTVAL INTO VILID FROM DUAL;
    
      --插入INVOICELIST
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
    
      --插入recinv
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
    
      --更新invstock
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

  --票据日结 zhangrong
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR) --票据类型
   AS
    CURSOR C1 IS
      SELECT OAID, FSYSMANALBBM(OADEPT, '1')
        FROM OPERACCNT, OPERACCNTROLE
       WHERE OAROAID = OAID
         AND OARRID IN ('03', '17', '19')
         FOR UPDATE NOWAIT;
    V_OAID      VARCHAR2(15); --工号
    V_OASMFID   VARCHAR2(10); --营业所
    V_LNUM      INTEGER; --领用数
    V_TNUM      INTEGER; --退票数
    V_SNUM      INTEGER; --使用数
    V_FNUM      INTEGER; --作废数
    V_CNT       INTEGER; --记录数
    V_LASTQMNUM INTEGER; --上期期末可用张数
    V_THISQMNUM INTEGER; --本期期末可用张数
  
    V_THISDATE DATE; --本期票务日期
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
    
      --取领用数
      SELECT NVL(SUM(TO_NUMBER(IIENO) - TO_NUMBER(IISNO) + 1), 0)
        INTO V_LNUM
        FROM INVIN
       WHERE IIRECEIVER = V_OAID
         AND IITYPE = P_INVTYPE
         AND TRUNC(IIDATE) = TRUNC(V_THISDATE);
    
      --取退票数
      SELECT NVL(SUM(TO_NUMBER(IOENO) - TO_NUMBER(IOSNO) + 1), 0)
        INTO V_TNUM
        FROM INVOUT
       WHERE IOSENDER = V_OAID
         AND IOTYPE = P_INVTYPE
         AND TRUNC(IODATE) = TRUNC(V_THISDATE);
    
      --取使用数
      SELECT COUNT(*)
        INTO V_SNUM
        FROM INVOICELIST
       WHERE ILPER = V_OAID
         AND ILTYPE = P_INVTYPE
         AND TRUNC(ILDATE) = TRUNC(V_THISDATE);
    
      --取作废数
      SELECT COUNT(*)
        INTO V_FNUM
        FROM INVCANCEL
       WHERE ICPER = V_OAID
         AND ICTYPE = P_INVTYPE
         AND TRUNC(ICDATE) = TRUNC(V_THISDATE);
    
      --更新/插入 invdailybalance 表
      SELECT COUNT(*)
        INTO V_CNT
        FROM INVDAILYBALANCE
       WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
         AND IDBTYPE = P_INVTYPE
         AND IDBPER = V_OAID;
    
      IF V_CNT = 0 THEN
        --未做过日结：插入记录
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
      
        --已做过日结：更新记录
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
  
    --库存日结明细
    DELETE FROM INVSTOCKDAILYBALANCE
     WHERE TRUNC(ISDBDATE) = TRUNC(V_THISDATE)
       AND ISDBTYPE = P_INVTYPE;
    INSERT INTO INVSTOCKDAILYBALANCE
      SELECT V_THISDATE,
             ISID,
             ISPER,
             ISTYPE,
             ISBCNO,
             NULL /*票据号码*/,
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

  --票据日结_手动执行 zhangrong
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR, BALDATE VARCHAR2) --票据类型
   AS
    CURSOR C1 IS
      SELECT OAID, FSYSMANALBBM(OADEPT, '1')
        FROM OPERACCNT, OPERACCNTROLE
       WHERE OAROAID = OAID
         AND OARRID IN ('03', '17', '19')
         FOR UPDATE NOWAIT;
    V_OAID      VARCHAR2(15); --工号
    V_OASMFID   VARCHAR2(10); --营业所
    V_LNUM      INTEGER; --领用数
    V_TNUM      INTEGER; --退票数
    V_SNUM      INTEGER; --使用数
    V_FNUM      INTEGER; --作废数
    V_CNT       INTEGER; --记录数
    V_LASTQMNUM INTEGER; --上期期末可用张数
    V_THISQMNUM INTEGER; --本期期末可用张数
  
    V_THISDATE DATE; --本期票务日期
  BEGIN
    SELECT TO_DATE(BALDATE, 'yyyy.mm.dd') INTO V_THISDATE FROM DUAL;
    OPEN C1;
    LOOP
      FETCH C1
        INTO V_OAID, V_OASMFID;
      EXIT WHEN C1%NOTFOUND OR C1%NOTFOUND IS NULL;
    
      --取领用数
      SELECT NVL(SUM(TO_NUMBER(IIENO) - TO_NUMBER(IISNO) + 1), 0)
        INTO V_LNUM
        FROM INVIN
       WHERE IIRECEIVER = V_OAID
         AND IITYPE = P_INVTYPE
         AND TRUNC(IIDATE) = TRUNC(V_THISDATE);
    
      --取退票数
      SELECT NVL(SUM(TO_NUMBER(IOENO) - TO_NUMBER(IOSNO) + 1), 0)
        INTO V_TNUM
        FROM INVOUT
       WHERE IOSENDER = V_OAID
         AND IOTYPE = P_INVTYPE
         AND TRUNC(IODATE) = TRUNC(V_THISDATE);
    
      --取使用数
      SELECT COUNT(*)
        INTO V_SNUM
        FROM INVOICELIST
       WHERE ILPER = V_OAID
         AND ILTYPE = P_INVTYPE
         AND TRUNC(ILDATE) = TRUNC(V_THISDATE);
    
      --取作废数
      SELECT COUNT(*)
        INTO V_FNUM
        FROM INVCANCEL
       WHERE ICPER = V_OAID
         AND ICTYPE = P_INVTYPE
         AND TRUNC(ICDATE) = TRUNC(V_THISDATE);
    
      --更新/插入 invdailybalance 表
      SELECT COUNT(*)
        INTO V_CNT
        FROM INVDAILYBALANCE
       WHERE TRUNC(IDBDATE) = TRUNC(V_THISDATE)
         AND IDBTYPE = P_INVTYPE
         AND IDBPER = V_OAID;
    
      IF V_CNT = 0 THEN
        --未做过日结：插入记录
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
      
        --已做过日结：更新记录
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
  
    --库存日结明细
    DELETE FROM INVSTOCKDAILYBALANCE
     WHERE TRUNC(ISDBDATE) = TRUNC(V_THISDATE)
       AND ISDBTYPE = P_INVTYPE;
    INSERT INTO INVSTOCKDAILYBALANCE
      SELECT V_THISDATE,
             ISID,
             ISPER,
             ISTYPE,
             ISBCNO,
             NULL /*票据号码*/,
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

  --未使用票据作废
  PROCEDURE CANCEL(P_ICPER   IN VARCHAR2, --票据所有人
                   P_ICSMFID IN VARCHAR2, --作废单位
                   P_ICTYPE  IN CHAR, --票据类型
                   P_ICNO    IN VARCHAR2 --票据编号
                   ) AS
  
    V_CNT INTEGER; --记录条数
  BEGIN
    --验证此票号是否可作废
    SELECT COUNT(*)
      INTO V_CNT
      FROM INVSTOCK
     WHERE ISPER = P_ICPER
       AND ISTYPE = P_ICTYPE
       AND ISNO = P_ICNO
       AND ISSTATUS = '0';
    IF V_CNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此票号不可作废，请检查票据所有人、票据状态及票据类型');
    END IF;
  
    --作废
    INSERT INTO INVCANCEL
    VALUES
      (SEQ_INVCANCEL.NEXTVAL,
       P_ICTYPE,
       SYSDATE,
       P_ICPER,
       P_ICNO,
       P_ICSMFID);
  
    --更新库存
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
  --鄂州自来水
  --取发将要使用发票号（系统编号）
  FUNCTION FGETINVNO(P_PER    IN VARCHAR2, --操作员
                     P_IITYPE IN VARCHAR2, --发票类型
                     P_SNO    IN NUMBER --发票流水号
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

  --鄂州自来水
  --取发将要使用发票号
  FUNCTION FGETINVNO_STR(P_PER    IN VARCHAR2, --操作员
                         P_IITYPE IN VARCHAR2 --发票类型
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

  --操作操作员票据信息
  FUNCTION FGETHADINV(P_PER IN VARCHAR2 --操作员
                      
                      ) RETURN VARCHAR2 AS
    V_STR VARCHAR2(2000);
  BEGIN
    SELECT '水费发票号：' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'S') ||
           '共计：' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'S') || '张；' ||
           '污水费发票号：' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'W') ||
           '共计：' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'W') || '张；'
      INTO V_STR
      FROM DUAL;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --操作操作员票据信息[TS]
  FUNCTION FGETHADINVTS(P_PER IN VARCHAR2 --操作员
                        
                        ) RETURN VARCHAR2 AS
    V_STR VARCHAR2(2000);
  BEGIN
    SELECT '水费发票号：' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'T') ||
           '共计：' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'T') || '张；' ||
           '污水费发票号：' || PG_EWIDE_INVMANAGE_01.FGETINVNO_STR(P_PER, 'U') ||
           '共计：' || PG_EWIDE_INVMANAGE_01.FGETINVCOUNT(P_PER, 'U') || '张；'
      INTO V_STR
      FROM DUAL;
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --鄂州自来水
  --取发将要使用发票号存放在事务会话表里

  FUNCTION FGETINVNO_TEMP(P_PER    IN VARCHAR2, --操作员
                          P_IITYPE IN VARCHAR2, --发票类型
                          P_COUNT  IN NUMBER, --要取发票张数
                          P_SNO    IN NUMBER -- 发票号码
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
  
    --未指定的票号
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
      --制定票号
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

  --鄂州自来水
  --取会话表里 发票号
  FUNCTION FGETINVNO_FROMTEMP(P_I IN NUMBER --第几张发票
                              ) RETURN NUMBER AS
  
    V_INVNO NUMBER(10);
  
  BEGIN
    SELECT C1 INTO V_INVNO FROM PBPARMTEMPFORINV WHERE C2 = P_I;
    RETURN V_INVNO;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --鄂州自来水
  --取可用发票号数量
  FUNCTION FGETINVCOUNT(P_PER    IN VARCHAR2, --操作员
                        P_IITYPE IN VARCHAR2 --发票类型
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

  --记录打印票号 鄂州
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE RECINVNO_EZ(P_ISPRINTTYPE IN VARCHAR2, --打印方式
                        P_ILNO        IN VARCHAR2, --票据号码(###|###|)
                        P_ILRLID      IN VARCHAR2, --应收流水(###|###|)
                        P_ILRDPIID    IN VARCHAR2, --费用项目(###|###|)
                        P_ILJE        IN VARCHAR2, --票据金额(###|###|)
                        P_ILTYPE      IN CHAR, --票据类型
                        P_ILCD        IN CHAR, --借贷方向
                        P_ILPER       IN VARCHAR2, --出票人
                        P_ILSTATUS    IN CHAR, --票据状态
                        P_ILSMFID     IN VARCHAR2, --分公司
                        P_TRANS       IN VARCHAR2, --事务
                        P_ISZZS       IN VARCHAR2 --增值税
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
    
      --验证票号是否可用
      OPEN C_IS(V_ISID);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '无效发票号码：[' || V_ISID || ']，请检查已领票据中是否存在');
      END IF;
      CLOSE C_IS;
    
      VILRLID   := TOOLS.FGETPARA2(P_ILRLID, I, 1);
      VILRDPIID := TOOLS.FGETPARA2(P_ILRDPIID, I, 1);
      VILJE     := TOOLS.FGETPARA2(P_ILJE, I, 1);
    
      --更新invstock
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
             ISPRINTTYPE  = P_ISPRINTTYPE, --打印方式（1:实收打印批次pbatch，2:实收pid3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid)
             ISPRINTCD    = P_ILCD, --借款方de/cr
             ISPRINTJE    = VILJE, --票面金额
             ISPRINTTRANS = P_TRANS, --事务类别
             ISZZS        = P_ISZZS --增值税标志
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
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE SP_FCHARGEINVREG(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
                             P_SNO         IN NUMBER --发票流水
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
    --按交易批次打印 payment.pbatch
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
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
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
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --发票号码
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        RECINVNO_EZ(P_ISPRINTTYPE, --打印方式
                    V_ISID || '|', --票据号码(###|###|)
                    P_ID || '|', --应收流水(###|###|)
                    '' || '|', --费用项目(###|###|)
                    V_ISPRINTJE || '|', --票据金额(###|###|)
                    P_ILTYPE, --票据类型
                    P_ISPRINTCD, --借贷方向
                    P_PRINTER, --出票人
                    P_ILSTATUS, --票据状态
                    P_ILSMFID, --分公司
                    V_TRNAS,
                    V_ISZZS);
      
      ELSIF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM PAYMENT T, PAIDLIST T1
         WHERE PBATCH = P_ID
           AND PID = PLPID(+);
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO --发票流水
                                        );
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
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
              /* v_ilno      := fgetinvno(P_PRINTER, --操作员
              p_iltype --发票类型
              );*/
              IF V_ISID IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
              END IF;
            
              V_ISPRINTJE := PM.PPAYMENT - PM.PCHANGE;
            
              IF V_ISPRINTJE01 <> 0 THEN
                V_ISZZS := 'Y';
              
              ELSE
                V_ISZZS := 'N';
              END IF;
            
              RECINVNO_EZ('2', --打印方式
                          V_ISID || '|', --票据号码(###|###|)
                          PM.PID || '|', --应收流水(###|###|)
                          '' || '|', --费用项目(###|###|)
                          V_ISPRINTJE || '|', --票据金额(###|###|)
                          P_ILTYPE, --票据类型
                          PM.PCD, --借贷方向
                          P_PRINTER, --出票人
                          P_ILSTATUS, --票据状态
                          P_ILSMFID, --分公司
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
              
                --减掉水费金额  (增值税用户)
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
                /*v_ilno      := fgetinvno(P_PRINTER, --操作员
                p_iltype --发票类型
                );*/
                IF V_ISID IS NULL THEN
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                          '发票已用完，请领取发票');
                END IF;
              
                IF V_ISPRINTJE01 <> 0 THEN
                  V_ISZZS := 'Y';
                
                ELSE
                
                  V_ISZZS := 'N';
                
                END IF;
              
                RECINVNO_EZ('3', --打印方式
                            V_ISID || '|', --票据号码(###|###|)
                            PL.PLID || '|', --应收流水(###|###|)
                            '' || '|', --费用项目(###|###|)
                            V_ISPRINTJE || '|', --票据金额(###|###|)
                            P_ILTYPE, --票据类型
                            PL.PLCD, --借贷方向
                            P_PRINTER, --出票人
                            P_ILSTATUS, --票据状态
                            P_ILSMFID, --分公司
                            PM.PTRANS,
                            V_ISZZS);
              END LOOP;
              CLOSE C_PBATCH_PLID_MX;
            END IF;
          END LOOP;
          CLOSE C_PBATCH_MX;
        ELSE
        
          ---将转预存补到发票上去
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
                  RAISE_APPLICATION_ERROR(-20010, '记票异常');
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
            
              --减掉水费金额  (增值税用户)
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
              /*v_ilno      := fgetinvno(P_PRINTER, --操作员
              p_iltype --发票类型
              );*/
              IF V_ISID IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
              END IF;
            
              IF V_ISPRINTJE01 <> 0 THEN
                V_ISZZS := 'Y';
              
              ELSE
              
                V_ISZZS := 'N';
              
              END IF;
            
              IF V_PLID IS NOT NULL AND V_PLID = PL.PLID THEN
                RECINVNO_EZ('3', --打印方式
                            V_ISID || '|', --票据号码(###|###|)
                            PL.PLID || '|', --应收流水(###|###|)
                            '' || '|', --费用项目(###|###|)
                            V_ISPRINTJE + V_YCJE || '|', --票据金额(###|###|)
                            P_ILTYPE, --票据类型
                            PL.PLCD, --借贷方向
                            P_PRINTER, --出票人
                            P_ILSTATUS, --票据状态
                            P_ILSMFID, --分公司
                            PM.PTRANS,
                            V_ISZZS);
              
              ELSE
              
                RECINVNO_EZ('3', --打印方式
                            V_ISID || '|', --票据号码(###|###|)
                            PL.PLID || '|', --应收流水(###|###|)
                            '' || '|', --费用项目(###|###|)
                            V_ISPRINTJE || '|', --票据金额(###|###|)
                            P_ILTYPE, --票据类型
                            PL.PLCD, --借贷方向
                            P_PRINTER, --出票人
                            P_ILSTATUS, --票据状态
                            P_ILSMFID, --分公司
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
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        V_ISID      := FGETINVNO_FROMTEMP(1);
      
        --生成中间数据
        SP_PRINTINV_OCX(P_ID, 'Z');
        V_ISID := FGETINVNO_FROMTEMP(1);
      
        OPEN C_PBATCH_PID_MX;
        LOOP
          FETCH C_PBATCH_PID_MX
            INTO PPT;
          EXIT WHEN C_PBATCH_PID_MX%NOTFOUND OR C_PBATCH_PID_MX%NOTFOUND IS NULL;
          I := I + 1;
          --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PPT.C1;
        
          V_ISPRINTJE := PPT.C10;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '第' || I || '发票已用完，请领取发票');
          END IF;
        
          SELECT PID, PCD, PTRANS
            INTO PM.PID, PM.PCD, PM.PTRANS
            FROM PAYMENT T
           WHERE T.PMID = PPT.C1
             AND T.PBATCH = PPT.C5
             AND T.PTRANS <> 'S';
        
          RECINVNO_EZ('2', --打印方式
                      V_ISID || '|', --票据号码(###|###|)
                      PM.PID || '|', --应收流水(###|###|)
                      '' || '|', --费用项目(###|###|)
                      V_ISPRINTJE || '|', --票据金额(###|###|)
                      P_ILTYPE, --票据类型
                      PM.PCD, --借贷方向
                      P_PRINTER, --出票人
                      P_ILSTATUS, --票据状态
                      P_ILSMFID, --分公司
                      PM.PTRANS,
                      V_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_PID_MX;
      
        --------------------------
      
      END IF;
    END IF;
    ----按交易实收流水打印 payment.pid 只对预存
    IF P_ISPRINTTYPE = '2' THEN
      V_ISPRINTJE01 := 0;
      SELECT SUM((T.PPAYMENT - T.PCHANGE))
        INTO V_ISPRINTJE
        FROM PAYMENT T
       WHERE PID = P_ID;
    
      V_ISID := FGETINVNO(P_PRINTER, --操作员
                          P_ILTYPE, --发票类型
                          P_SNO);
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      
      ELSE
      
        V_ISZZS := 'N';
      
      END IF;
    
      RECINVNO_EZ(P_ISPRINTTYPE, --打印方式
                  V_ISID || '|', --票据号码(###|###|)
                  P_ID || '|', --应收流水(###|###|)
                  '' || '|', --费用项目(###|###|)
                  V_ISPRINTJE || '|', --票据金额(###|###|)
                  P_ILTYPE, --票据类型
                  P_ISPRINTCD, --借贷方向
                  P_PRINTER, --出票人
                  P_ILSTATUS, --票据状态
                  P_ILSMFID, --分公司
                  'S',
                  V_ISZZS);
    
    END IF;
    ----按交易实收明细流水打印 paidlist.plid --按PLID打印明细票
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
      
        --减掉水费金额  (增值税用户)
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --发票号码
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO_EZ('3', --打印方式
                    V_ISID || '|', --票据号码(###|###|)
                    PL.PLID || '|', --应收流水(###|###|)
                    '' || '|', --费用项目(###|###|)
                    V_ISPRINTJE || '|', --票据金额(###|###|)
                    P_ILTYPE, --票据类型
                    PL.PLCD, --借贷方向
                    P_PRINTER, --出票人
                    P_ILSTATUS, --票据状态
                    P_ILSMFID, --分公司
                    PM.PTRANS,
                    V_ISZZS);
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    END IF;
  
    --5:应收流水rlid  结构 ###,###|###,###|###,###|
    --6:实收明细 rdid+rdpiid  结构 ###,01/02/03|###,01/02/03|###,01/02/03|
    IF P_ISPRINTTYPE = '5' THEN
      --v_invcount    number(10);
      --v_invretcount number(10);
      --检查
      --打印员发票号
    
      --分票/合票
      IF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*) INTO V_INVCOUNT FROM PBPARMTEMP;
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '###没有需要打印的发票');
        
        END IF;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
      
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVCOUNT > V_INVRETCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
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
        
          --减掉水费金额  (增值税用户)
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
          /*v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          
          ELSE
          
            V_ISZZS := 'N';
          
          END IF;
        
          RECINVNO_EZ('5', --打印方式
                      V_ISID || '|', --票据号码(###|###|)
                      TRIM(PPT.C5) || '|', --应收流水(###|###|)
                      TRIM(PPT.C8) || '|', --费用项目(###|###|)
                      V_ISPRINTJE || '|', --票据金额(###|###|)
                      P_ILTYPE, --票据类型
                      P_ISPRINTCD, --借贷方向
                      P_PRINTER, --出票人
                      P_ILSTATUS, --票据状态
                      P_ILSMFID, --分公司
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
      
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
      
        RECINVNO_EZ(P_ISPRINTTYPE, --打印方式
                    V_ISID || '|', --票据号码(###|###|)
                    V_RLIDSTR || '|', --应收流水(###|###|)
                    V_RDPIIDSTR || '|', --费用项目(###|###|)
                    V_ISPRINTJE || '|', --票据金额(###|###|)
                    P_ILTYPE, --票据类型
                    P_ISPRINTCD, --借贷方向
                    P_PRINTER, --出票人
                    P_ILSTATUS, --票据状态
                    P_ILSMFID, --分公司
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
      
        --减掉水费金额  (增值税用户)
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO_EZ('3', --打印方式
                    V_ISID || '|', --票据号码(###|###|)
                    PL.PLID || '|', --应收流水(###|###|)
                    '' || '|', --费用项目(###|###|)
                    V_ISPRINTJE || '|', --票据金额(###|###|)
                    P_ILTYPE, --票据类型
                    PL.PLCD, --借贷方向
                    P_PRINTER, --出票人
                    P_ILSTATUS, --票据状态
                    P_ILSMFID, --分公司
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

  /*--备份20110817
   procedure sp_fchargeinvreg(P_iffphp      in varchar2, --F分票H合票
                               p_id          in varchar2, --实收批次
                               p_piid        in varchar2, --费用项目 01/02/03
                               p_ISPRINTTYPE in varchar2, --打印方式
                               p_iltype      in varchar2, --票据类型
                               P_PRINTER     IN VARCHAR2, --打印员
                               p_ilstatus    in VARCHAR2, --票据状态
                               p_ilsmfid     IN VARCHAR2, --分公司
                               p_ISPRINTCD   IN VARCHAR2 --借代方
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
      --按交易批次打印 payment.pbatch
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
          --减掉水费金额  (增值税用户)
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
            raise_application_error(errcode, '没有需要打印的发票');
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
          v_isid := fgetinvno(P_PRINTER, --操作员
                              p_iltype --发票类型
                              );
          IF v_isid is null THEN
            raise_application_error(errcode, '发票已用完，请领取发票');
          END IF;
          if v_isprintje01<>0 THEN
             v_ISZZS :='Y' ;
          ELSE
             v_ISZZS :='N' ;
          END IF;
          recinvno_ez(p_ISPRINTTYPE, --打印方式
                      v_isid || '|', --票据号码(###|###|)
                      p_id || '|', --应收流水(###|###|)
                      '' || '|', --费用项目(###|###|)
                      v_isprintje || '|', --票据金额(###|###|)
                      p_iltype, --票据类型
                      p_ISPRINTCD, --借贷方向
                      P_PRINTER, --出票人
                      p_ilstatus, --票据状态
                      p_ilsmfid, --分公司
                      V_TRNAS,
                      v_ISZZS);
  
        ELSIF P_iffphp = 'F' THEN
  
          select count(*)
            into v_invcount
            from payment t, paidlist t1
           where pbatch = p_id
             and pid = plpid(+);
  
          v_invretcount := fgetinvno_temp(P_PRINTER, --操作员
                                          p_iltype, --发票类型
                                          v_invcount --要取发票张数
                                          );
          if v_invcount = 0 then
            raise_application_error(errcode, '没有需要打印的发票');
  
          end if;
          if v_invretcount < v_invcount then
            raise_application_error(errcode,
                                    '发票数据不够,需要打印' || v_invcount || '张，实际只有' ||
                                    v_invretcount || '张');
  
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
              \* v_ilno      := fgetinvno(P_PRINTER, --操作员
              p_iltype --发票类型
              );*\
              IF v_isid is null THEN
                raise_application_error(errcode, '发票已用完，请领取发票');
              END IF;
  
              v_isprintje := PM.PPAYMENT - PM.PCHANGE;
  
              if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
                 v_ISZZS :='N' ;
              END IF;
  
              recinvno_ez('2', --打印方式
                          v_isid || '|', --票据号码(###|###|)
                          PM.PID || '|', --应收流水(###|###|)
                          '' || '|', --费用项目(###|###|)
                          v_isprintje || '|', --票据金额(###|###|)
                          p_iltype, --票据类型
                          PM.Pcd, --借贷方向
                          P_PRINTER, --出票人
                          p_ilstatus, --票据状态
                          p_ilsmfid, --分公司
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
  
                --减掉水费金额  (增值税用户)
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
                \*v_ilno      := fgetinvno(P_PRINTER, --操作员
                p_iltype --发票类型
                );*\
                IF v_isid is null THEN
                  raise_application_error(errcode, '发票已用完，请领取发票');
                END IF;
  
                if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
  
                recinvno_ez('3', --打印方式
                            v_isid || '|', --票据号码(###|###|)
                            pl.plid || '|', --应收流水(###|###|)
                            '' || '|', --费用项目(###|###|)
                            v_isprintje || '|', --票据金额(###|###|)
                            p_iltype, --票据类型
                            pl.plcd, --借贷方向
                            P_PRINTER, --出票人
                            p_ilstatus, --票据状态
                            p_ilsmfid, --分公司
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
  
          v_invretcount := fgetinvno_temp(P_PRINTER, --操作员
                                          p_iltype, --发票类型
                                          v_invcount --要取发票张数
                                          );
          if v_invcount = 0 then
            raise_application_error(errcode, '没有需要打印的发票');
  
          end if;
          if v_invretcount < v_invcount then
            raise_application_error(errcode,
                                    '发票数据不够,需要打印' || v_invcount || '张，实际只有' ||
                                    v_invretcount || '张');
  
          end if;
          i := 0;
          v_isprintje :=0 ;
          v_isid := fgetinvno_fromtemp(1);
  
  --生成中间数据
  SP_PRINTINV_OCX(p_id,'Z' );
  v_isid := fgetinvno_fromtemp(1);
  
              OPEN C_PBATCH_pid_MX ;
              LOOP
                FETCH C_PBATCH_pid_MX
                  INTO PPT;
                EXIT WHen C_PBATCH_pid_MX%NOTFOUND OR C_PBATCH_pid_MX%NOTFOUND IS NULL;
                i := i + 1;
                --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
                select MIIFTAX
                  into v_ISZZS
                  from
                       meterinfo  t4
                 where miid = ppt.c1 ;
  
                v_isprintje := ppt.c10 ;
  
                v_isid := fgetinvno_fromtemp(i);
  
                IF v_isid is null THEN
                  raise_application_error(errcode,'第' ||I||'发票已用完，请领取发票');
                END IF;
  
          select pid ,pcd,PTRANS  INTO PM.PID,PM.PCD,PM.PTRANS
           from payment t
          where t.pmid=ppt.c1
          and t.pbatch=PPT.C5 and t.ptrans<>'S' ;
  
  
                recinvno_ez('2', --打印方式
                            v_isid || '|', --票据号码(###|###|)
                             PM.PID|| '|', --应收流水(###|###|)
                            '' || '|', --费用项目(###|###|)
                            v_isprintje || '|', --票据金额(###|###|)
                            p_iltype, --票据类型
                            PM.PCD, --借贷方向
                            P_PRINTER, --出票人
                            p_ilstatus, --票据状态
                            p_ilsmfid, --分公司
                            pm.ptrans,
                            v_ISZZS);
              END LOOP;
              CLOSE C_PBATCH_pid_MX;
  
            --------------------------
  
  
        END IF;
      end if;
      ----按交易实收流水打印 payment.pid 只对预存
      if p_ISPRINTTYPE = '2' then
        v_isprintje01  := 0 ;
        SELECT SUM((T.PPAYMENT - T.PCHANGE))
          INTO v_isprintje
          FROM PAYMENT T
         WHERE pid = p_id;
  
  
        v_isid := fgetinvno(P_PRINTER, --操作员
                            p_iltype --发票类型
                            );
        IF v_isid is null THEN
          raise_application_error(errcode, '发票已用完，请领取发票');
        END IF;
  
        if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
        recinvno_ez(p_ISPRINTTYPE, --打印方式
                    v_isid || '|', --票据号码(###|###|)
                    p_id || '|', --应收流水(###|###|)
                    '' || '|', --费用项目(###|###|)
                    v_isprintje || '|', --票据金额(###|###|)
                    p_iltype, --票据类型
                    p_ISPRINTCD, --借贷方向
                    P_PRINTER, --出票人
                    p_ilstatus, --票据状态
                    p_ilsmfid, --分公司
                    'S',
                    v_ISZZS);
  
      end if;
      ----按交易实收明细流水打印 paidlist.plid --按PLID打印明细票
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
  
          --减掉水费金额  (增值税用户)
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
  
  
          v_isid      := fgetinvno(P_PRINTER, --操作员
                                   p_iltype --发票类型
                                   );
          IF v_isid is null THEN
            raise_application_error(errcode, '发票已用完，请领取发票');
          END IF;
  
           if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
          recinvno_ez('3', --打印方式
                      v_isid || '|', --票据号码(###|###|)
                      pl.plid || '|', --应收流水(###|###|)
                      '' || '|', --费用项目(###|###|)
                      v_isprintje || '|', --票据金额(###|###|)
                      p_iltype, --票据类型
                      pl.plcd, --借贷方向
                      P_PRINTER, --出票人
                      p_ilstatus, --票据状态
                      p_ilsmfid, --分公司
                      pm.ptrans,
                      v_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_plid_MX_one;
      end if;
  
      --5:应收流水rlid  结构 ###,###|###,###|###,###|
      --6:实收明细 rdid+rdpiid  结构 ###,01/02/03|###,01/02/03|###,01/02/03|
      if p_ISPRINTTYPE = '5' then
      --v_invcount    number(10);
      --v_invretcount number(10);
      --检查
      --打印员发票号
  
      --分票/合票
       if P_iffphp = 'F' THEN
  
     select count(*) into v_invcount  from pbparmtemp;
     if v_invcount = 0 then
            raise_application_error(errcode, '###没有需要打印的发票');
  
          end if;
    v_invretcount := fgetinvno_temp(P_PRINTER, --操作员
                                          p_iltype, --发票类型
                                          v_invcount --要取发票张数
                                          );
  
          if v_invcount = 0 then
            raise_application_error(errcode, '没有需要打印的发票');
  
          end if;
     if v_invcount > v_invretcount  then
        raise_application_error(errcode,
                                    '发票数据不够,需要打印' || v_invcount || '张，实际只有' ||
                                    v_invretcount || '张');
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
  
                --减掉水费金额  (增值税用户)
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
                \*v_ilno      := fgetinvno(P_PRINTER, --操作员
                p_iltype --发票类型
                );*\
                IF v_isid is null THEN
                  raise_application_error(errcode, '发票已用完，请领取发票');
                END IF;
  
             if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
  
                recinvno_ez('5', --打印方式
                            v_isid || '|', --票据号码(###|###|)
                            trim(ppt.c5)  || '|', --应收流水(###|###|)
                            trim(ppt.c8) || '|', --费用项目(###|###|)
                            v_isprintje || '|', --票据金额(###|###|)
                            p_iltype, --票据类型
                            p_ISPRINTCD, --借贷方向
                            P_PRINTER, --出票人
                            p_ilstatus, --票据状态
                            p_ilsmfid, --分公司
                            'T',
                            v_ISZZS);
  
  
          END LOOP;
          CLOSE C_rlid_PBPARMTEMP;
  
  
  
        ELSIF P_iffphp = 'H' THEN
         SELECT SUM(to_number( c7) ),connstr( c5 ),connstr( c5||','|| REPLACE( c8,'/','#'))
            INTO v_isprintje ,v_rlidstr,v_rdpiidstr
            FROM PBPARMTEMP;
  
          --减掉水费金额  (增值税用户)
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
            raise_application_error(errcode, '没有需要打印的发票');
  
          END IF;
          v_isid := fgetinvno(P_PRINTER, --操作员
                              p_iltype --发票类型
                              );
          IF v_isid is null THEN
            raise_application_error(errcode, '发票已用完，请领取发票');
          END IF;
          if v_isprintje01<>0 THEN
             v_ISZZS :='Y' ;
          ELSE
             v_ISZZS :='N' ;
          END IF;
  
  
  
          recinvno_ez(p_ISPRINTTYPE, --打印方式
                      v_isid || '|', --票据号码(###|###|)
                      v_rlidstr || '|', --应收流水(###|###|)
                      v_rdpiidstr || '|', --费用项目(###|###|)
                      v_isprintje || '|', --票据金额(###|###|)
                      p_iltype, --票据类型
                      p_ISPRINTCD, --借贷方向
                      P_PRINTER, --出票人
                      p_ilstatus, --票据状态
                      p_ilsmfid, --分公司
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
  
          --减掉水费金额  (增值税用户)
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
  
  
          v_isid      := fgetinvno(P_PRINTER, --操作员
                                   p_iltype --发票类型
                                   );
          IF v_isid is null THEN
            raise_application_error(errcode, '发票已用完，请领取发票');
          END IF;
  
           if v_isprintje01<>0 THEN
                 v_ISZZS :='Y' ;
  
              ELSE
  
                 v_ISZZS :='N' ;
  
              END IF;
  
          recinvno_ez('3', --打印方式
                      v_isid || '|', --票据号码(###|###|)
                      pl.plid || '|', --应收流水(###|###|)
                      '' || '|', --费用项目(###|###|)
                      v_isprintje || '|', --票据金额(###|###|)
                      p_iltype, --票据类型
                      pl.plcd, --借贷方向
                      P_PRINTER, --出票人
                      p_ilstatus, --票据状态
                      p_ilsmfid, --分公司
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
  --鄂州自来水
  --检查发票是否够打
  FUNCTION FCHKINVFULL(P_PER    IN VARCHAR2, --操作员
                       P_IITYPE IN VARCHAR2, --发票类型
                       P_TYPE   IN VARCHAR2, --流水号类别
                       P_ID     IN VARCHAR2 --流水号
                       ) RETURN NUMBER --返回是否差发票数量
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
    V_INVHAVECOUNT := FGETINVCOUNT(P_PER, --操作员
                                   P_IITYPE --发票类型
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
  --备份20110817
    function fchkinvfull(p_per    in varchar2, --操作员
                         p_iitype in varchar2, --发票类型
                         p_type   in varchar2, --流水号类别
                         p_id     in varchar2 --流水号
                         ) return number --返回是否差发票数量
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
      v_invhavecount := fgetinvcount(p_per, --操作员
                                     p_iitype --发票类型
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
  --发票状态处理
  PROCEDURE SP_CANCEL_HADPRINTNO(P_PER    IN VARCHAR2, --操作员
                                 P_TYPE   IN VARCHAR2, --发票类别
                                 P_STATUS IN VARCHAR2, --处理状态
                                 P_ID     IN VARCHAR2, --流水号
                                 P_MODE   IN VARCHAR2, --流水号类别
                                 O_FLAG   OUT VARCHAR2 --返回值
                                 ) AS
    V_COUNT NUMBER(10);
    IT      INVSTOCK%ROWTYPE;
  BEGIN
    IF P_MODE = '1' THEN
      /*select count(*) into v_count from invstock t where t.isprinttype='1'
      and isprintid= p_id ;*/
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
         WHERE T.ISPRINTTYPE = '1'
           AND ISSTATUS = '1'
           AND T.ISPCISNO = P_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
         WHERE T.ISPRINTTYPE = '2'
           AND ISSTATUS = '1'
           AND T.ISPCISNO IN (SELECT PID FROM PAYMENT WHERE PBATCH = P_ID);
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
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
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
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
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
         WHERE T.ISPRINTTYPE = '5'
           AND ISSTATUS = '1'
           AND T.ISPCISNO = P_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '不支持此种处理方式,类别代码：' || P_MODE);
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
  --删除发票
  PROCEDURE SP_INVMANG_DELETE(P_ISNOSTART   VARCHAR2, --发票起号
                              P_ISNOEND     VARCHAR2, --发票止号
                              P_ISBCNO      VARCHAR2, --发票批次
                              P_ISSTATUSPER VARCHAR2, --状态变更人
                              P_MEMO        VARCHAR2, --备注
                              MSG           OUT VARCHAR2) IS
    /*票据管理，删除票据*/
    V_MSG   VARCHAR2(200);
    V_COUNT NUMBER;
  BEGIN
  
    V_MSG := 'N';
    IF P_ISBCNO IS NULL THEN
      MSG := '发票批次号不允许为空值!';
      RETURN;
    END IF;
  
    --修改发票操作时间，操作人，（发票变更状态）
    IF P_ISNOSTART IS NOT NULL OR P_ISNOEND IS NOT NULL THEN
      SP_INVMANG_MODIFYSTATUS(P_ISNOSTART,
                              P_ISNOEND,
                              P_ISBCNO,
                              P_ISSTATUSPER,
                              4,
                              P_MEMO,
                              V_MSG);
    END IF;
  
    --如果变更状态不等于Y，则返回删除不成功信息
    IF V_MSG <> 'Y' THEN
      MSG := V_MSG;
      RETURN;
    END IF;
  
    IF P_ISNOSTART IS NULL AND P_ISNOEND IS NULL THEN
      MSG := '发票删除失败!';
      RETURN;
    ELSIF P_ISNOEND IS NULL THEN
      /*发票止号为空，但发票起号不为空*/
      --添加到备份数据库
      INSERT INTO INVSTOCKHIS
        SELECT *
          FROM INVSTOCK
         WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
           AND ISBCNO = P_ISBCNO;
      --删除当前票据信息
      DELETE FROM INVSTOCK
       WHERE ISNO = TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISBCNO = P_ISBCNO;
      --是否成功
      IF SQL%ROWCOUNT > 0 THEN
        MSG := 'Y';
        RETURN;
      ELSE
        MSG := 'N';
        RETURN;
      END IF;
    ELSIF P_ISNOSTART IS NULL THEN
      /*发票起号为空，但发票止号不为空*/
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
  --修改发票状态
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_ISNOSTART   VARCHAR2, --发票起号
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
    nsql           number;
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
      UPDATE INVSTOCK
         SET ISPSTATUS      = ISSTATUS, --上次状态  
             ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期 
             ISPTATUSPER    = ISSTATUSPER, --上次状态人员 
             ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定, 4退回, 5销毁) 
             ISSTATUSDATE   = SYSDATE, --状态日期 
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
             ISSTATUSPER = P_ISSTATUSPER --状态人员 
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
      --发票起号为空，但发票止号不为空
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

  --修改发票状态
  PROCEDURE SP_INVMANG_MODIFYINV(P_ISNOSTART   VARCHAR2, --发票起号
                                 P_ISNOEND     VARCHAR2, --发票止号
                                 P_ISBCNO      VARCHAR2, --批次号
                                 P_ISSTATUSPER VARCHAR2, --状态变更人员
                                 P_TYPE        VARCHAR2, --状态2
                                 P_NUM         VARCHAR2, --备注
                                 MSG           OUT VARCHAR2) IS
    /*发票管理，发票作废2、发票初始化0、已使用1、锁定3、删除4*/
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
    END IF;
  
    --把原始数据插入到临时表中
    DELETE INVSTOCK_TEMP;
    INSERT INTO INVSTOCK_TEMP INTP
      SELECT *
        FROM INVSTOCK INST
       WHERE INST.ISBCNO = P_ISBCNO
         AND INST.ISNO >= P_ISNOSTART
         AND INST.ISNO <= P_ISNOEND;
  
    ---上移的数据
    IF P_TYPE = '01' THEN
    
      IF TO_NUMBER(P_ISNOSTART) - TO_NUMBER(P_NUM) < 0 THEN
        MSG := '上移的数据不满足条件！!';
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
                              '调票！',
                              V_MSG);
    
      --下移的数据
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
        MSG := '下移的数据不满足条件！!';
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
                              '调票！',
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

  PROCEDURE SP_INVMANG_ZLY(P_ISNOSTART   VARCHAR2, --发票起号
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
        FROM INVSTOCK
       WHERE ISNO >= P_ISNOSTART
         AND ISNO <= P_ISNOEND
         AND ISBCNO = P_ISBCNO
         AND ISSTATUS <> '0';
    END;
  
    --发票止号为空，但发票起号不为空
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

  --新增发票
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
        --判断每条是否添加成功
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      ELSE
        MSG := '该批次发票号码段存在已被领取的发票！';
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '领取失败!';
  END;

  PROCEDURE SP_SPTZ(P_ISBCNO      IN VARCHAR2, --批次号
                    P_MINSOURCENO IN VARCHAR2,
                    P_MAXSOURCENO IN VARCHAR2,
                    P_MINDESTNO   IN VARCHAR2, --调整目标发票起始号
                    P_MAXDESTNO   IN VARCHAR2, --调整目标原发票终止号
                    P_TYPE        IN VARCHAR2) -- FPDT 发票对调  FPTH 发票调号
   IS
  
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    V_OUTMSG  VARCHAR2(300);
    V_COUNT   NUMBER;
    V_s       VARCHAR2(300);
    V_d       VARCHAR2(300);
    E_票号占用 EXCEPTION;
    V_ISNO VARCHAR2(12);
  BEGIN
    --清空临时表
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
             WHERE T.ISBCNO = P_ISBCNO --目标
               AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
               AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))
            MINUS
            SELECT T.ISID
              FROM INVSTOCK T
             WHERE T.ISBCNO = P_ISBCNO --原
               AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
               AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000')));
    /*IF V_COUNT > 0 THEN
      RAISE E_票号占用; 
    END IF;*/
    V_STEP    := 10;
    V_PRC_MSG := '组织发票调整关系';
  
    INSERT INTO INVSTOCKSWAP
      SELECT MAX(DECODE(V_TYPE, 'S', ISNO, NULL)) SOURCENO,
             MAX(DECODE(V_TYPE, 'D', ISNO, NULL)) DESTNO,
             MAX(DECODE(V_TYPE, 'S', ISID, NULL)) SOURCEID,
             MAX(DECODE(V_TYPE, 'D', ISID, NULL)) DESTID,
             0
        FROM (SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'S' V_TYPE
                FROM INVSTOCK T
               WHERE T.ISBCNO = P_ISBCNO --原
                 AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                 AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))
              UNION
              SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'D' V_TYPE
                FROM INVSTOCK T
               WHERE T.ISBCNO = P_ISBCNO --目标
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
                       WHERE T.ISBCNO = P_ISBCNO --原
                         AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))
                      MINUS
                      SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --目标
                         AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))) T
              UNION
              SELECT T.ISNO, T.ISID, ROWNUM V_NUM, 'D' V_TYPE
                FROM (SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --目标
                         AND ISNO >= TRIM(TO_CHAR(P_MINDESTNO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXDESTNO, '00000000'))
                      MINUS
                      SELECT T.ISNO, T.ISID
                        FROM INVSTOCK T
                       WHERE T.ISBCNO = P_ISBCNO --原
                         AND ISNO >= TRIM(TO_CHAR(P_MINSOURCENO, '00000000'))
                         AND ISNO <= TRIM(TO_CHAR(P_MAXSOURCENO, '00000000'))) T)
       GROUP BY V_NUM;
  
    IF UPPER(P_TYPE) = 'FPTH' THEN
      V_STEP    := 20;
      V_PRC_MSG := '调票';
    
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
             T.ISMEMO = '手工调票'
       WHERE T.ISID IN (SELECT SOURCEID FROM INVSTOCKSWAP WHERE DTYPE = 0)
         AND T.ISBCNO = P_ISBCNO;
    
      V_STEP := 201;
      insert into invstock_datatemp_h
        select *
          from invstock
         where isid in (SELECT DESTID FROM INVSTOCKSWAP WHERE DTYPE = 1);
    
      V_PRC_MSG := '更新调整出来的票为未使用';
      UPDATE invstock_datatemp_h T
         SET T.ISNO =
             (SELECT SOURCENO
                FROM INVSTOCKSWAP
               WHERE DESTID = T.ISID
                 AND DTYPE = 1),
             --T.ISSTATUS = 0,
             T.ISMEMO = '手工调票'
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
                   T.ISMEMO = '手工调票'
             WHERE T.ISID IN (SELECT SOURCEID FROM INVSTOCKSWAP WHERE DTYPE = 0)
               AND T.ISBCNO = P_ISBCNO;
            V_STEP    := 201;
            V_PRC_MSG := '更新调整出来的票为未使用';
            UPDATE INVSTOCK T
               SET T.ISNO     = (SELECT SOURCENO
                                   FROM INVSTOCKSWAP
                                  WHERE DESTID = T.ISID
                                    AND DTYPE = 1),
                   --T.ISSTATUS = 0,
                   T.ISMEMO   = '手工调票'
             WHERE T.ISID IN (SELECT DESTID FROM INVSTOCKSWAP WHERE DTYPE = 1)
               AND T.ISBCNO = P_ISBCNO;
      */
    END IF;
  
    IF UPPER(P_TYPE) = 'FPDD' THEN
      V_STEP    := 20;
      V_PRC_MSG := '调票';
    
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
    WHEN E_票号占用 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票号[' || V_ISNO || ']' || '已经被使用，请先对该号码进行调整');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '执行步骤[' || V_STEP || '],[' || V_PRC_MSG ||
                              '],出现错误!');
  END;

  --发票入库、分发、领用、退还
  PROCEDURE SP_STOCK(P_ISBCNO    VARCHAR2, --批次号
                     P_ISSTOCKDO VARCHAR2, --仓库操作
                     P_ISSMFID   VARCHAR2, --仓库
                     P_ISPER     VARCHAR2, --领票人
                     P_ISTYPE    VARCHAR2, --发票类别
                     P_ISNOSTART VARCHAR2, --发票起号
                     P_ISNOEND   VARCHAR2, --发票止号
                     P_OUTPER    VARCHAR2, --发放票据人
                     MSG         OUT VARCHAR2) IS
  
    V_ISPCISNO VARCHAR2(100);
    V_ROOT     VARCHAR2(100);
    V_do       VARCHAR2(100);
    V_qty      NUMBER;
    V_ISTRUE1  NUMBER;
    V_ISTRUE2  NUMBER;
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
    END IF;
  
    V_qty  := to_number(P_ISNOEND) - to_number(P_ISNOSTART) + 1;
    V_ROOT := 'ROOT';
    --发票止号为空，但发票起号不为空
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '0' THEN
      -- 0入库
      V_do := '入库';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'));
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          INSERT INTO INVSTOCK
            (ISID, --票据流水号 
             ISBCNO, --批号 
             ISNO, --票据号码 
             ISPER, --库存所有人 
             ISTYPE, --票据类型 
             ISSTATUSPER, --状态人员 
             ISOUTPER, --发放票据人 
             ISSTATUSDATE, --状态日期 
             ISOUTDATE, --发放时间 
             ISSTATUS, --状态(0未使用；1使用；2作废；3锁定, 4退回, 5销毁) 
             ISPCISNO, --票据批次||号码 
             ISSMFID, --库存单位 
             ISSTOCKDO,
             ISSTOCKPER,
             ISSTOCKDATE) --仓库状态(0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废)
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
      
        --判断每条是否添加成功
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '1' THEN
      -- 1分发
      V_do := '分发';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> 'ROOT' or ISSTATUS <> '0');
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --状态日期 
                 ISPER        = P_ISPER, --库存所有人 
                 ISSMFID      = P_ISSMFID, --库存单位 
                 ISOUTPER     = P_OUTPER, --发放票据人 
                 ISOUTDATE    = SYSDATE, --发放时间 
                 ISSTOCKDO    = P_ISSTOCKDO --仓库状态(0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废)
           where ISPCISNO = V_ISPCISNO;
        
        END LOOP;
        IF SQL%ROWCOUNT > 0 THEN
          MSG := 'Y';
        ELSE
          MSG := 'N';
          RETURN;
        END IF;
      
      ELSE
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '2' THEN
      -- 22领用
      V_do := '领用';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> P_ISSMFID or ISSTATUS <> '0' or
             (ISSTOCKDO not in ('1', '3')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --状态日期 
                 ISSMFID      = P_ISSMFID, --库存单位 
                 ISPER        = P_ISPER, --库存所有人 
                 ISOUTDATE    = SYSDATE, --发放时间 
                 ISOUTPER     = P_OUTPER, --发放票据人 
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
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '5' THEN
      -- 5销毁作废
      V_do := '销毁作废';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSTATUS <> '0');
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
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
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '3' THEN
      -- 3退回营业所
      V_do := '使用的';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         AND (ISSMFID <> P_ISSMFID or ISSTOCKDO <> '2' or
             (ISSTATUS not in ('0', '2')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
        FOR I IN P_ISNOSTART .. P_ISNOEND LOOP
          V_ISPCISNO := TRIM(P_ISBCNO || '.' ||
                             TRIM(TO_CHAR(I, '00000000')));
        
          update INVSTOCK
             set ISSTATUSDATE = SYSDATE, --状态日期 
                 --ISPER = P_ISPER,--库存所有人 
                 ISSMFID = P_ISSMFID, --库存单位 
                 -- ISOUTDATE = SYSDATE,--发放时间 
                 -- ISOUTPER = P_ISPER,--发放票据人 
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
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
    /*0入库；1分发；2领用；3退回营业所, 4退回公司，5销毁作废*/
    IF P_ISSTOCKDO = '4' THEN
      -- 4退回公司
      V_do := '退回公司';
    
      --检查操作条件      
      SELECT COUNT(ISID)
        INTO V_ISTRUE1
        FROM INVSTOCK
       WHERE ISBCNO = TRIM(P_ISBCNO)
         AND ISNO >= TRIM(TO_CHAR(P_ISNOSTART, '00000000'))
         AND ISNO <= TRIM(TO_CHAR(P_ISNOEND, '00000000'))
         and (ISSMFID <> P_ISSMFID or ISSTATUS not in ('0', '2', '4') or
             (ISSTOCKDO not in ('1', '3')));
    
      IF V_ISTRUE1 = 0 THEN
      
        --插入 INV_IO 表
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
      
        --票据分拆    
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
        MSG := '该批次发票号码段存在已被' || V_do || '的发票！';
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      MSG := '领取失败!';
  END;

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV(P_IFFPHP      IN VARCHAR2, --F分票H合票
                         P_ID          IN VARCHAR2, --实收批次
                         P_PIID        IN VARCHAR2, --费用项目 01/02/03
                         P_ISPRINTTYPE IN VARCHAR2, --打印方式
                         P_ILTYPE      IN VARCHAR2, --票据类型
                         P_PRINTER     IN VARCHAR2, --打印员
                         P_ILSTATUS    IN VARCHAR2, --票据状态
                         P_ILSMFID     IN VARCHAR2, --分公司
                         P_ISPRINTCD   IN VARCHAR2, --借代方，
                         P_SNO         IN NUMBER ----发票流水
                         )
  
   IS
  
  BEGIN
  
    IF P_ISPRINTTYPE = '1' THEN
      NULL;
      IF P_IFFPHP = 'H' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_H_SF(P_IFFPHP, --F分票H合票
                              P_ID, --实收批次
                              P_PIID, --费用项目 01/02/03
                              P_ISPRINTTYPE, --打印方式
                              P_ILTYPE, --票据类型
                              P_PRINTER, --打印员
                              P_ILSTATUS, --票据状态
                              P_ILSMFID, --分公司
                              P_ISPRINTCD, --借代方
                              P_SNO --初始化票号
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_H_WSF(P_IFFPHP, --F分票H合票
                               P_ID, --实收批次
                               P_PIID, --费用项目 01/02/03
                               P_ISPRINTTYPE, --打印方式
                               P_ILTYPE, --票据类型
                               P_PRINTER, --打印员
                               P_ILSTATUS, --票据状态
                               P_ILSMFID, --分公司
                               P_ISPRINTCD, --借代方
                               P_SNO --初始化票号
                               );
        END IF;
      
      ELSIF P_IFFPHP = 'F' THEN
        --
        NULL;
        SP_CHARGEINV_1_F(P_IFFPHP, --F分票H合票
                         P_ID, --实收批次
                         P_PIID, --费用项目 01/02/03
                         P_ISPRINTTYPE, --打印方式
                         P_ILTYPE, --票据类型
                         P_PRINTER, --打印员
                         P_ILSTATUS, --票据状态
                         P_ILSMFID, --分公司
                         P_ISPRINTCD, --借代方
                         P_SNO --初始化票号
                         );
      
      ELSIF P_IFFPHP = 'M' THEN
        NULL;
        SP_CHARGEINV_1_F_HSB(P_IFFPHP, --F分票H合票
                             P_ID, --实收批次
                             P_PIID, --费用项目 01/02/03
                             P_ISPRINTTYPE, --打印方式
                             P_ILTYPE, --票据类型
                             P_PRINTER, --打印员
                             P_ILSTATUS, --票据状态
                             P_ILSMFID, --分公司
                             P_ISPRINTCD, --借代方
                             P_SNO --初始化票号
                             );
      
      ELSIF P_IFFPHP = 'G' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_G_SF(P_IFFPHP, --F分票H合票
                              P_ID, --实收批次
                              P_PIID, --费用项目 01/02/03
                              P_ISPRINTTYPE, --打印方式
                              P_ILTYPE, --票据类型
                              P_PRINTER, --打印员
                              P_ILSTATUS, --票据状态
                              P_ILSMFID, --分公司
                              P_ISPRINTCD, --借代方
                              P_SNO --初始化票号
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_G_WSF(P_IFFPHP, --F分票H合票
                               P_ID, --实收批次
                               P_PIID, --费用项目 01/02/03
                               P_ISPRINTTYPE, --打印方式
                               P_ILTYPE, --票据类型
                               P_PRINTER, --打印员
                               P_ILSTATUS, --票据状态
                               P_ILSMFID, --分公司
                               P_ISPRINTCD, --借代方
                               P_SNO --初始化票号
                               );
        
        END IF;
      
      ELSIF P_IFFPHP = 'Z' THEN
        IF P_ILTYPE = 'S' THEN
          SP_CHARGEINV_1_Z_SF(P_IFFPHP, --F分票H合票
                              P_ID, --实收批次
                              P_PIID, --费用项目 01/02/03
                              P_ISPRINTTYPE, --打印方式
                              P_ILTYPE, --票据类型
                              P_PRINTER, --打印员
                              P_ILSTATUS, --票据状态
                              P_ILSMFID, --分公司
                              P_ISPRINTCD, --借代方
                              P_SNO --初始化票号
                              );
        ELSIF P_ILTYPE = 'W' THEN
          SP_CHARGEINV_1_Z_WSF(P_IFFPHP, --F分票H合票
                               P_ID, --实收批次
                               P_PIID, --费用项目 01/02/03
                               P_ISPRINTTYPE, --打印方式
                               P_ILTYPE, --票据类型
                               P_PRINTER, --打印员
                               P_ILSTATUS, --票据状态
                               P_ILSMFID, --分公司
                               P_ISPRINTCD, --借代方
                               P_SNO --初始化票号
                               );
        END IF;
      END IF;
      -- 针对托收和走收的用户的打印
    ELSIF P_ISPRINTTYPE = 'T' THEN
      NULL;
      SP_CHARGEINV_1_F_TS(P_IFFPHP, --F分票H合票
                          P_ID, --实收批次
                          P_PIID, --费用项目 01/02/03
                          P_ISPRINTTYPE, --打印方式
                          P_ILTYPE, --票据类型
                          P_PRINTER, --打印员
                          P_ILSTATUS, --票据状态
                          P_ILSMFID, --分公司
                          P_ISPRINTCD, --借代方
                          P_SNO --初始化票号
                          );
      --针对走收的用户的打印
    ELSIF P_ISPRINTTYPE = 'I' THEN
      NULL;
      SP_CHARGEINV_1_F_ZS(P_IFFPHP, --F分票H合票
                          P_ID, --实收批次
                          P_PIID, --费用项目 01/02/03
                          P_ISPRINTTYPE, --打印方式
                          P_ILTYPE, --票据类型
                          P_PRINTER, --打印员
                          P_ILSTATUS, --票据状态
                          P_ILSMFID, --分公司
                          P_ISPRINTCD, --借代方
                          P_SNO --初始化票号
                          );
      --针对打印的数据
    
    ELSE
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_BAK(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
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
    --按交易批次打印 payment.pbatch
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
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
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
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          ID.IDID        := V_ISID; -- 票据流水号
          ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
          ID.IDPRINTID   := PM.PID; -- 对应流水号
          ID.ISPRINTPIID := NULL; -- 费用项目
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --收款金额
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          --减掉水费金额  (增值税用户)
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
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            ID.IDPRINTID := RL.RLID; -- 对应流水号
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
              INSERT INTO INVSTOCKDETAIL VALUES ID;
              UPDATE RECDETAIL T
                 SET T.RDILID = V_ISID
               WHERE RDID = RL.RLID
                 AND RDPIID = ID.ISPRINTPIID;
            END LOOP;
            UPDATE RECLIST T SET T.RLILID = V_ISID WHERE RLID = RL.RLID;
          END LOOP;
          CLOSE C_PBATCH_RLID_SF_MX;
        
          --污水费
        
          V_ISID := FGETINVNO(P_PRINTER, --操作员
                              'W', --发票类型
                              P_SNO);
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --收款金额
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          --减掉水费金额  (增值税用户)
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
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   'W', --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            ID.IDPRINTID := RL.RLID; -- 对应流水号
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
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
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
        IF V_TRNAS = 'S' THEN
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
          SELECT *
            INTO PM
            FROM PAYMENT T
           WHERE PBATCH = P_ID
             AND PTRANS = 'S'
             AND ROWNUM = 1;
        
          ID.IDID        := V_ISID; -- 票据流水号
          ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
          ID.IDPRINTID   := PM.PID; -- 对应流水号
          ID.ISPRINTPIID := NULL; -- 费用项目
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            ID.IDPRINTID := RL.RLID; -- 对应流水号
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
        --回
      
      ELSIF P_IFFPHP = 'F' THEN
        --判断是否预存
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
        --单缴预存
        V_ISPRINTJE01 := 0;
        IF V_COUNT2 = 1 AND V_COUNT1 = 1 THEN
          I      := I + 1;
          V_ISID := FGETINVNO_FROMTEMP(I);
          /* v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
          SELECT * INTO PM FROM PAYMENT T WHERE T.PBATCH = P_ID;
          V_ISPRINTJE := PM.PPAYMENT - PM.PCHANGE;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
          RECINVNO('2', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   PM.PID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   PM.PCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- 票据流水号
          ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
          ID.IDPRINTID   := PM.PID; -- 对应流水号
          ID.ISPRINTPIID := NULL; -- 费用项目
          INSERT INTO INVSTOCKDETAIL VALUES ID;
          UPDATE PAYMENT T SET T.PILID = V_ISID WHERE PID = PM.PID;
        ELSE
          --缴水费
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
        
          V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                          P_ILTYPE, --发票类型
                                          V_INVCOUNT, --要取发票张数
                                          P_SNO);
          IF V_INVCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
          
          END IF;
          IF V_INVRETCOUNT < V_INVCOUNT THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                    V_INVRETCOUNT || '张');
          
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
          
            --减掉水费金额  (增值税用户)
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
            /*v_ilno      := fgetinvno(P_PRINTER, --操作员
            p_iltype --发票类型
            );*/
            IF V_ISID IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
          
            RECINVNO('6', --打印方式
                     V_ISID || '|', --票据号码(###|###|)
                     RL.RLID || '|', --应收流水(###|###|)
                     V_RDPIIDSTR || '|', --费用项目(###|###|)
                     V_ISPRINTJE || '|', --票据金额(###|###|)
                     P_ILTYPE, --票据类型
                     RL.RLCD, --借贷方向
                     P_PRINTER, --出票人
                     P_ILSTATUS, --票据状态
                     P_ILSMFID, --分公司
                     PM.PTRANS,
                     V_ISZZS);
            ID.IDID      := V_ISID; -- 票据流水号
            ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
            ID.IDPRINTID := RL.RLID; -- 对应流水号
          
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
        --判断是否预存
      
        --单缴预存
      
        V_ISPRINTJE01 := 0;
        --缴水费
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
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
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
        
          --减掉水费金额  (增值税用户)
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
          /*v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   RL.RLMRID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   RL.RLCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
          OPEN C_PBATCH_MRID_MX_SF_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_SF_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_SF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_SF_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- 对应流水号
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
      
        --判断是否预存
        --单缴预存
        V_ISPRINTJE01 := 0;
        --缴水费
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
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        'W', --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
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
        
          --减掉水费金额  (增值税用户)
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
          /*v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   RL.RLMRID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   'W', --票据类型
                   RL.RLCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
          OPEN C_PBATCH_MRID_MX_WSF_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_WSF_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- 对应流水号
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
        --判断是否预存
        --单缴预存
        V_ISPRINTJE01 := 0;
        --缴水费
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
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
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
        
          --减掉水费金额  (增值税用户)
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
          /*v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          ELSE
            V_ISZZS := 'N';
          END IF;
        
          RECINVNO('7', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   RL.RLMRID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   RL.RLCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
          OPEN C_PBATCH_MRID_MX_ONE(RL.RLMRID);
          LOOP
            FETCH C_PBATCH_MRID_MX_ONE
              INTO RLONE;
            EXIT WHEN C_PBATCH_MRID_MX_ONE%NOTFOUND OR C_PBATCH_MRID_MX_ONE%NOTFOUND IS NULL;
            ID.IDPRINTID := RLONE.RLID; -- 对应流水号
          
            SELECT CONNSTR(RDPIID)
              INTO V_RDPIIDSTR
              FROM (SELECT DISTINCT RDPIID
                      FROM RECDETAIL T
                     WHERE RDID = RLONE.RLID
                       AND (V_ISZZS = 'N' OR
                           (V_ISZZS = 'Y' AND RDPIID <> '01')));
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        OPEN C_PBATCH_PID_SF_MX(P_ID);
        LOOP
          FETCH C_PBATCH_PID_SF_MX
            INTO PM;
          EXIT WHEN C_PBATCH_PID_SF_MX%NOTFOUND OR C_PBATCH_PID_SF_MX%NOTFOUND IS NULL;
          I := I + 1;
          --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
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
                                    '第' || I || '发票已用完，请领取发票');
          END IF;
          RECINVNO('2', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   PM.PID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   PM.PCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            ID.IDPRINTID := RL.RLID; -- 对应流水号
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
      
        --污水
        SELECT COUNT(*)
          INTO V_INVCOUNT
          FROM (SELECT PID, PBATCH
                  FROM PAYMENT T, RECLIST T1
                 WHERE T.PID = T1.RLPID
                   AND PTRANS <> 'S'
                   AND PBATCH = P_ID
                   AND RLGROUP = '2'
                 GROUP BY PID, PBATCH);
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        'W', --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        OPEN C_PBATCH_PID_WSF_MX(P_ID);
        LOOP
          FETCH C_PBATCH_PID_WSF_MX
            INTO PM;
          EXIT WHEN C_PBATCH_PID_WSF_MX%NOTFOUND OR C_PBATCH_PID_WSF_MX%NOTFOUND IS NULL;
          I := I + 1;
          --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
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
                                    '第' || I || '发票已用完，请领取发票');
          END IF;
          RECINVNO('2', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   PM.PID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   'W', --票据类型
                   PM.PCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            ID.IDPRINTID := RL.RLID; -- 对应流水号
            FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
              ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
      
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        END IF;
        IF V_INVRETCOUNT < V_INVCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
        
        END IF;
        I           := 0;
        V_ISPRINTJE := 0;
        V_ISID      := FGETINVNO_FROMTEMP(1);
      
        --生成中间数据
        SP_PRINTINV_OCX(P_ID, 'Z');
        V_ISID := FGETINVNO_FROMTEMP(1);
      
        OPEN C_PBATCH_PID_MX;
        LOOP
          FETCH C_PBATCH_PID_MX
            INTO PPT;
          EXIT WHEN C_PBATCH_PID_MX%NOTFOUND OR C_PBATCH_PID_MX%NOTFOUND IS NULL;
          I := I + 1;
          --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
          SELECT MIIFTAX
            INTO V_ISZZS
            FROM METERINFO T4
           WHERE MIID = PPT.C1;
        
          V_ISPRINTJE := PPT.C10;
        
          V_ISID := FGETINVNO_FROMTEMP(I);
        
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '第' || I || '发票已用完，请领取发票');
          END IF;
        
          SELECT PID, PCD, PTRANS
            INTO PM.PID, PM.PCD, PM.PTRANS
            FROM PAYMENT T
           WHERE T.PMID = PPT.C1
             AND T.PBATCH = PPT.C5
             AND T.PTRANS <> 'S';
        
          RECINVNO('2', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   PM.PID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   PM.PCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   PM.PTRANS,
                   V_ISZZS);
        END LOOP;
        CLOSE C_PBATCH_PID_MX;
      
        --------------------------
      
      END IF;
    END IF;
    ----按交易实收流水打印 payment.pid 只对预存
    IF P_ISPRINTTYPE = '2' THEN
      V_ISPRINTJE01 := 0;
      SELECT SUM((T.PPAYMENT - T.PCHANGE))
        INTO V_ISPRINTJE
        FROM PAYMENT T
       WHERE PID = P_ID;
    
      V_ISID := FGETINVNO(P_PRINTER, --操作员
                          P_ILTYPE, --发票类型
                          P_SNO);
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      
      ELSE
      
        V_ISZZS := 'N';
      
      END IF;
    
      RECINVNO(P_ISPRINTTYPE, --打印方式
               V_ISID || '|', --票据号码(###|###|)
               P_ID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               P_ISPRINTCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               'S',
               V_ISZZS);
    
    END IF;
    ----按交易实收明细流水打印 paidlist.plid --按PLID打印明细票
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
      
        --减掉水费金额  (增值税用户)
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO);
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
      
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        
        ELSE
        
          V_ISZZS := 'N';
        
        END IF;
      
        RECINVNO('3', --打印方式
                 V_ISID || '|', --票据号码(###|###|)
                 RL.RLID || '|', --应收流水(###|###|)
                 '' || '|', --费用项目(###|###|)
                 V_ISPRINTJE || '|', --票据金额(###|###|)
                 P_ILTYPE, --票据类型
                 RL.RLCD, --借贷方向
                 P_PRINTER, --出票人
                 P_ILSTATUS, --票据状态
                 P_ILSMFID, --分公司
                 PM.PTRANS,
                 V_ISZZS);
      END LOOP;
      CLOSE C_PBATCH_PLID_MX_ONE;
    END IF;
  
    --5:应收流水rlid  结构 ###,###|###,###|###,###|
    --6:实收明细 rdid+rdpiid  结构 ###,01/02/03|###,01/02/03|###,01/02/03|
    IF P_ISPRINTTYPE = '5' THEN
      --v_invcount    number(10);
      --v_invretcount number(10);
      --检查
      --打印员发票号
    
      --分票/合票
      IF P_IFFPHP = 'F' THEN
      
        SELECT COUNT(*) INTO V_INVCOUNT FROM PBPARMTEMP;
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '###没有需要打印的发票');
        
        END IF;
        V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                        P_ILTYPE, --发票类型
                                        V_INVCOUNT, --要取发票张数
                                        P_SNO);
      
        IF V_INVCOUNT = 0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        IF V_INVCOUNT > V_INVRETCOUNT THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                  V_INVRETCOUNT || '张');
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
        
          --减掉水费金额  (增值税用户)
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
          /*v_ilno      := fgetinvno(P_PRINTER, --操作员
          p_iltype --发票类型
          );*/
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          IF V_ISPRINTJE01 <> 0 THEN
            V_ISZZS := 'Y';
          
          ELSE
          
            V_ISZZS := 'N';
          
          END IF;
        
          RECINVNO('5', --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   TRIM(PPT.C5) || '|', --应收流水(###|###|)
                   TRIM(PPT.C8) || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
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
      
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
        
        END IF;
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --初始化票号
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
        IF V_ISPRINTJE01 <> 0 THEN
          V_ISZZS := 'Y';
        ELSE
          V_ISZZS := 'N';
        END IF;
      
        RECINVNO(P_ISPRINTTYPE, --打印方式
                 V_ISID || '|', --票据号码(###|###|)
                 V_RLIDSTR || '|', --应收流水(###|###|)
                 V_RDPIIDSTR || '|', --费用项目(###|###|)
                 V_ISPRINTJE || '|', --票据金额(###|###|)
                 P_ILTYPE, --票据类型
                 P_ISPRINTCD, --借贷方向
                 P_PRINTER, --出票人
                 P_ILSTATUS, --票据状态
                 P_ILSMFID, --分公司
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
      
        --减掉水费金额  (增值税用户)
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --初始化票号
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
      
        RECINVNO('6', --打印方式
                 V_ISID || '|', --票据号码(###|###|)
                 RL.RLID || '|', --应收流水(###|###|)
                 '' || '|', --费用项目(###|###|)
                 V_ISPRINTJE || '|', --票据金额(###|###|)
                 P_ILTYPE, --票据类型
                 RL.RLCD, --借贷方向
                 P_PRINTER, --出票人
                 P_ILSTATUS, --票据状态
                 P_ILSMFID, --分公司
                 PM.PTRANS,
                 V_ISZZS);
      
        ID.IDID      := V_ISID; -- 票据流水号
        ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        ID.IDPRINTID := RL.RLID; -- 对应流水号
      
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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
      
                    --减掉水费金额  (增值税用户)
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
                    \*v_ilno      := fgetinvno(P_PRINTER, --操作员
                    p_iltype --发票类型
                    );*\
                    IF v_isid is null THEN
                      raise_application_error(errcode, '发票已用完，请领取发票');
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
      
                    recinvno('6', --打印方式
                                v_isid || '|', --票据号码(###|###|)
                                rl.rlid || '|', --应收流水(###|###|)
                                v_rdpiidstr || '|', --费用项目(###|###|)
                                v_isprintje || '|', --票据金额(###|###|)
                                p_iltype, --票据类型
                                rl.rlcd, --借贷方向
                                P_PRINTER, --出票人
                                p_ilstatus, --票据状态
                                p_ilsmfid, --分公司
                                pm.ptrans,
                                v_ISZZS);
                    id.idid  :=v_isid ;-- 票据流水号
                    id.idtype   :='01' ;-- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
                    id.idprintid   :=rl.rlid ;-- 对应流水号
      
                  for i IN 1..tools.fmidn(v_rdpiidstr,'/')
                    loop
                      id.isprintpiid   :=tools.fmid(v_rdpiidstr,I,'N','/')   ;-- 费用项目
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
      
        --减掉水费金额  (增值税用户)
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --初始化票号
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
      
        RECINVNO('7', --打印方式
                 V_ISID || '|', --票据号码(###|###|)
                 RL.RLID || '|', --应收流水(###|###|)
                 '' || '|', --费用项目(###|###|)
                 V_ISPRINTJE || '|', --票据金额(###|###|)
                 P_ILTYPE, --票据类型
                 RL.RLCD, --借贷方向
                 P_PRINTER, --出票人
                 P_ILSTATUS, --票据状态
                 P_ILSMFID, --分公司
                 PM.PTRANS,
                 V_ISZZS);
      
        ID.IDID      := V_ISID; -- 票据流水号
        ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        ID.IDPRINTID := RL.RLID; -- 对应流水号
      
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_H_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
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
    --按交易批次打印 payment.pbatch
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
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
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
      
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --发票流水
                            );
      
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- 票据流水号
          ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
          ID.IDPRINTID   := PM.PID; -- 对应流水号
          ID.ISPRINTPIID := NULL; -- 费用项目
          INSERT INTO INVSTOCKDETAIL VALUES ID;
        
          SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
        
          UPDATE PAYMENT T
             SET T.PILID = IN_STOCK.ISPCISNO
           WHERE PID = PM.PID;
        
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --收款金额
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND (RLGROUP <> '2' OR RLGROUP IS NULL);
        
          --减掉水费金额  (增值税用户)
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
        
          --取账务标志的相关信息
          SELECT PM.PTRANS
            INTO V_TRNAS
            FROM PAYMENT T
           WHERE T.PBATCH = P_ID
             AND ROWNUM = 1;
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_H_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --票据流水
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
    --按交易批次打印 payment.pbatch
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
        --减掉水费金额  (增值税用户)
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
          RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
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
        V_ISID := FGETINVNO(P_PRINTER, --操作员
                            P_ILTYPE, --发票类型
                            P_SNO --发票号码
                            );
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   P_ILTYPE, --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID        := V_ISID; -- 票据流水号
          ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
          ID.IDPRINTID   := PM.PID; -- 对应流水号
          ID.ISPRINTPIID := NULL; -- 费用项目
          INSERT INTO INVSTOCKDETAIL VALUES ID;
        
          SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
        
          UPDATE PAYMENT T
             SET T.PILID = IN_STOCK.ISPCISNO
           WHERE PID = PM.PID;
        
        ELSE
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --污水费
        
          V_ISID := FGETINVNO(P_PRINTER, --操作员
                              'W', --发票类型
                              P_SNO --初始化票号
                              );
          IF V_ISID IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
          END IF;
        
          V_ISPRINTJE   := 0;
          V_ISPRINTJE01 := 0;
          --收款金额
          SELECT SUM((RLPAIDJE))
            INTO V_ISPRINTJE
            FROM RECLIST T1, PAYMENT T3, METERINFO T4
           WHERE PBATCH = P_ID
             AND PID = RLPID
             AND PMID = MIID
             AND RLGROUP = '2';
        
          --减掉水费金额  (增值税用户)
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
        
          --取账务标志的相关信息
          SELECT PM.PTRANS
            INTO V_TRNAS
            FROM PAYMENT T
           WHERE T.PBATCH = P_ID
             AND ROWNUM = 1;
        
          RECINVNO(P_ISPRINTTYPE, --打印方式
                   V_ISID || '|', --票据号码(###|###|)
                   P_ID || '|', --应收流水(###|###|)
                   '' || '|', --费用项目(###|###|)
                   V_ISPRINTJE || '|', --票据金额(###|###|)
                   'W', --票据类型
                   P_ISPRINTCD, --借贷方向
                   P_PRINTER, --出票人
                   P_ILSTATUS, --票据状态
                   P_ILSMFID, --分公司
                   V_TRNAS,
                   V_ISZZS);
        
          ID.IDID   := V_ISID; -- 票据流水号
          ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        
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
          
            id.idprintid := rl.rlid; -- 对应流水号
            for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
              id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
                             P_SNO         IN NUMBER --票据流水
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
  
    --一套赋值的数据
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
  
    --判断是否预存
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
    --单缴预存
    V_ISPRINTJE01 := 0;
    J             := 0;
    IF V_COUNT2 = 1 AND V_COUNT1 = 1 THEN
    
      J      := J + 1;
      V_ISID := FGETINVNO_FROMTEMP(J);
      /* v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
    
      RECINVNO('7', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               PM.PID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               PM.PCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID        := V_ISID; -- 票据流水号
      ID.IDTYPE      := '05'; -- 打印类别（01现金，02代扣，03托收，04入户直收，05打预存）
      ID.IDPRINTID   := PM.PID; -- 对应流水号
      ID.ISPRINTPIID := NULL; -- 费用项目
    
      INSERT INTO INVSTOCKDETAIL VALUES ID;
    
      --
      SELECT * INTO IN_STOCK FROM INVSTOCK INS WHERE INS.ISID = V_ISID;
    
      UPDATE PAYMENT T
         SET T.PILID = IN_STOCK.ISPCISNO
      
       WHERE PID = PM.PID;
    ELSE
    
      --缴水费
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
    
      V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                      P_ILTYPE, --发票类型
                                      V_INVCOUNT, --要取发票张数
                                      P_SNO --发票号码
                                      );
      IF V_INVCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
      
      END IF;
      IF V_INVRETCOUNT < V_INVCOUNT THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                                V_INVRETCOUNT || '张');
      
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
      
        --减掉水费金额  (增值税用户)
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
        /*v_ilno      := fgetinvno(P_PRINTER, --操作员
        p_iltype --发票类型
        );*/
        IF V_ISID IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
        END IF;
      
        --取账务标志的相关信息
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
      
        RECINVNO('7', --打印方式
                 V_ISID || '|', --票据号码(###|###|)
                 V_MRID || '|', --抄表流水(###|###|)
                 '' || '|', --费用项目(###|###|)
                 V_ISPRINTJE || '|', --票据金额(###|###|)
                 P_ILTYPE, --票据类型
                 'DE', --借贷方向
                 P_PRINTER, --出票人
                 P_ILSTATUS, --票据状态
                 P_ILSMFID, --分公司
                 PM.PTRANS,
                 V_ISZZS);
        ID.IDID      := V_ISID; -- 票据流水号
        ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
        ID.IDPRINTID := V_MRID; -- 对应流水号
      
        /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
          id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- 费用项目
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

  --托收
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F_TS(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
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
  
    --一套赋值的数据
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
  
    --单缴预存
    V_ISPRINTJE01 := 0;
    J             := 0;
  
    --水费记录
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
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    P_ILTYPE, --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
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
    
      --减掉水费金额  (增值税用户)
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
    
      ---增值税数据的处理
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
    
      RECINVNO('6', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               V_MRID || '|', --抄表流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               'DE', --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               P_ILTYPE,
               V_ISZZS);
      ID.IDID      := V_ISID; -- 票据流水号
      ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
      ID.IDPRINTID := V_MRID; -- 对应流水号
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- 费用项目
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

  --走收
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F_ZS(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
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
  
    --一套赋值的数据
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
  
    --单缴预存
    V_ISPRINTJE01 := 0;
    J             := 0;
  
    --水费记录
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
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    P_ILTYPE, --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
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
    
      --减掉水费金额  (增值税用户)
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
    
      ---增值税数据的处理
      V_ISPRINTJE := V_ISPRINTJE - V_ISPRINTJE01;
      V_ISID      := FGETINVNO_FROMTEMP(I);
      /*v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
    
      RECINVNO('5', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               V_MRID || '|', --抄表流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               'DE', --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               P_ILTYPE,
               V_ISZZS);
      ID.IDID      := V_ISID; -- 票据流水号
      ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
      ID.IDPRINTID := V_MRID; -- 对应流水号
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F_HSB(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --票据流水
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
  
    --一套赋值的数据
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
      --缴水费
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
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    P_ILTYPE, --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    
    END IF;
  
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
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
    
      --减掉水费金额  (增值税用户)
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
      /*v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
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
    
      RECINVNO('7', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               V_MRID || '|', --抄表流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               'DE', --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
      ID.IDID      := V_ISID; -- 票据流水号
      ID.IDTYPE    := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
      ID.IDPRINTID := V_MRID; -- 对应流水号
    
      /*  for i IN 1 .. tools.fmidn(v_rdpiidstr, '/') loop
        id.isprintpiid := tools.fmid(v_rdpiidstr, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_G_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
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
  
    --判断是否预存
  
    --单缴预存
  
    V_ISPRINTJE01 := 0;
    --缴水费
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
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    P_ILTYPE, --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
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
    
      --减掉水费金额  (增值税用户)
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
      /*v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      RECINVNO('7', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               RL.RLMRID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               RL.RLCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
      ID.IDID   := V_ISID; -- 票据流水号
      ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
    
      OPEN C_PBATCH_MRID_MX_SF_ONE(RL.RLMRID);
      LOOP
        FETCH C_PBATCH_MRID_MX_SF_ONE
          INTO RLONE;
        EXIT WHEN C_PBATCH_MRID_MX_SF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_SF_ONE%NOTFOUND IS NULL;
        ID.IDPRINTID := RLONE.RLID; -- 对应流水号
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RLONE.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_G_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --票据流水
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
  
    --判断是否预存
  
    --单缴预存
    ----STRAT@@@@@@@@@@@@@@@@@@@@@@@@@22222
  
    --判断是否预存
    --单缴预存
    V_ISPRINTJE01 := 0;
    --缴水费
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
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    'W', --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
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
    
      --减掉水费金额  (增值税用户)
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
      /*v_ilno      := fgetinvno(P_PRINTER, --操作员
      p_iltype --发票类型
      );*/
      IF V_ISID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '发票已用完，请领取发票');
      END IF;
    
      IF V_ISPRINTJE01 <> 0 THEN
        V_ISZZS := 'Y';
      ELSE
        V_ISZZS := 'N';
      END IF;
    
      RECINVNO('7', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               RL.RLMRID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               'W', --票据类型
               RL.RLCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
      ID.IDID   := V_ISID; -- 票据流水号
      ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
    
      OPEN C_PBATCH_MRID_MX_WSF_ONE(RL.RLMRID);
      LOOP
        FETCH C_PBATCH_MRID_MX_WSF_ONE
          INTO RLONE;
        EXIT WHEN C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND OR C_PBATCH_MRID_MX_WSF_ONE%NOTFOUND IS NULL;
        ID.IDPRINTID := RLONE.RLID; -- 对应流水号
      
        SELECT CONNSTR(RDPIID)
          INTO V_RDPIIDSTR
          FROM (SELECT DISTINCT RDPIID
                  FROM RECDETAIL T
                 WHERE RDID = RLONE.RLID
                   AND (V_ISZZS = 'N' OR (V_ISZZS = 'Y' AND RDPIID <> '01')));
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_Z_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --发票流水
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
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    P_ILTYPE, --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票号码
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
    END IF;
    I           := 0;
    V_ISPRINTJE := 0;
    OPEN C_PBATCH_PID_SF_MX(P_ID);
    LOOP
      FETCH C_PBATCH_PID_SF_MX
        INTO PM;
      EXIT WHEN C_PBATCH_PID_SF_MX%NOTFOUND OR C_PBATCH_PID_SF_MX%NOTFOUND IS NULL;
      I := I + 1;
      --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
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
                                '第' || I || '发票已用完，请领取发票');
      END IF;
      RECINVNO('2', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               PM.PID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               P_ILTYPE, --票据类型
               PM.PCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID   := V_ISID; -- 票据流水号
      ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
    
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
      
        ID.IDPRINTID := RL.RLID; -- 对应流水号
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_Z_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方,
                                 P_SNO         IN NUMBER ----发票流水
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
  
    --污水
    SELECT COUNT(*)
      INTO V_INVCOUNT
      FROM (SELECT PID, PBATCH
              FROM PAYMENT T, RECLIST T1
             WHERE T.PID = T1.RLPID
               AND PTRANS <> 'S'
               AND PBATCH = P_ID
               AND RLGROUP = '2'
             GROUP BY PID, PBATCH);
  
    V_INVRETCOUNT := FGETINVNO_TEMP(P_PRINTER, --操作员
                                    'W', --发票类型
                                    V_INVCOUNT, --要取发票张数
                                    P_SNO --发票
                                    );
    IF V_INVCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '没有需要打印的发票');
    END IF;
    IF V_INVRETCOUNT < V_INVCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发票数据不够,需要打印' || V_INVCOUNT || '张，实际只有' ||
                              V_INVRETCOUNT || '张');
    
    END IF;
    I           := 0;
    V_ISPRINTJE := 0;
    OPEN C_PBATCH_PID_WSF_MX(P_ID);
    LOOP
      FETCH C_PBATCH_PID_WSF_MX
        INTO PM;
      EXIT WHEN C_PBATCH_PID_WSF_MX%NOTFOUND OR C_PBATCH_PID_WSF_MX%NOTFOUND IS NULL;
      I := I + 1;
      --减掉水费金额  (增值税用户) 在SP_PRINTINV_OCX 过程中已处理
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
                                '第' || I || '发票已用完，请领取发票');
      END IF;
      RECINVNO('2', --打印方式
               V_ISID || '|', --票据号码(###|###|)
               PM.PID || '|', --应收流水(###|###|)
               '' || '|', --费用项目(###|###|)
               V_ISPRINTJE || '|', --票据金额(###|###|)
               'W', --票据类型
               PM.PCD, --借贷方向
               P_PRINTER, --出票人
               P_ILSTATUS, --票据状态
               P_ILSMFID, --分公司
               PM.PTRANS,
               V_ISZZS);
    
      ID.IDID   := V_ISID; -- 票据流水号
      ID.IDTYPE := '01'; -- 打印类别（01现金，02代扣，03托收，04入户直收，01打预存）
    
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
      
        ID.IDPRINTID := RL.RLID; -- 对应流水号
        FOR I IN 1 .. TOOLS.FMIDN(V_RDPIIDSTR, '/') LOOP
          ID.ISPRINTPIID := TOOLS.FMID(V_RDPIIDSTR, I, 'N', '/'); -- 费用项目
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

  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE RECINVNO(P_ISPRINTTYPE IN VARCHAR2, --打印方式
                     P_ILNO        IN VARCHAR2, --票据号码(###|###|)
                     P_ILRLID      IN VARCHAR2, --应收流水(###|###|)
                     P_ILRDPIID    IN VARCHAR2, --费用项目(###|###|)
                     P_ILJE        IN VARCHAR2, --票据金额(###|###|)
                     P_ILTYPE      IN CHAR, --票据类型
                     P_ILCD        IN CHAR, --借贷方向
                     P_ILPER       IN VARCHAR2, --出票人
                     P_ILSTATUS    IN CHAR, --票据状态
                     P_ILSMFID     IN VARCHAR2, --分公司
                     P_TRANS       IN VARCHAR2, --事务
                     P_ISZZS       IN VARCHAR2 --增值税
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
    
      --验证票号是否可用
      OPEN C_IS(V_ISID);
      FETCH C_IS
        INTO RT_IS;
      IF C_IS%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '无效发票号码：[' || V_ISID || ']，请检查已领票据中是否存在');
      END IF;
      CLOSE C_IS;
    
      /* vilrlid   := tools.FGetPara2(p_ilrlid, i, 1);
       vilrdpiid := tools.FGetPara2(p_ilrdpiid, i, 1);
      */
    
      VILJE := TOOLS.FGETPARA2(P_ILJE, I, 1);
    
      --取临时表中的信息
      SELECT　 *
        INTO PB_TEMP FROM PBPARMTEMP PBT WHERE PBT.C1 = V_ISID;
    
      UPDATE INVSTOCK
         SET ISPSTATUS      = RT_IS.ISPSTATUS,
             ISPSTATUSDATEP = RT_IS.ISPSTATUSDATEP,
             ISPTATUSPER    = RT_IS.ISPTATUSPER,
             ISSTATUS       = '1',
             ISSTATUSDATE   = SYSDATE,
             ISSTATUSPER    = P_ILPER,
             ISPRINTTYPE    = P_ISPRINTTYPE, --打印方式（1:实收打印批次pbatch，2:实收pid3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid)
             ISPRINTCD      = P_ILCD, --借款方de/cr
             ISPRINTJE      = VILJE, --票面金额
             ISPRINTTRANS   = P_TRANS, --事务类别
             ISZZS          = P_ISZZS, --增值税标
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

  --单个号码的修改 【yujia ,2012-02-12 】
  PROCEDURE SP_CANCEL(P_PER    IN VARCHAR2, --操作员
                      P_TYPE   IN VARCHAR2, --发票类别
                      P_STATUS IN VARCHAR2, --处理状态
                      P_ID     IN VARCHAR2, --流水号
                      P_MODE   IN VARCHAR2, --流水号类别
                      O_FLAG   OUT VARCHAR2 --返回值
                      ) AS
    V_COUNT NUMBER(10);
    IT      INVSTOCK%ROWTYPE;
    PMINFO  PAYMENT%ROWTYPE;
  BEGIN
  
    --从缴费途径中获得信息
    IF P_MODE = '1' THEN
    
      SELECT COUNT(PM.PILID)
        INTO V_COUNT
        FROM PAYMENT PM
       WHERE PM.PBATCH = P_ID;
    
      IF V_COUNT >= 1 THEN
      
        BEGIN
        
          --yc
          UPDATE INVSTOCK T
             SET ISPSTATUS      = ISSTATUS, --上次状态
                 ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
                 ISPTATUSPER    = ISSTATUSPER, --状态人员
                 ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
                 ISSTATUSDATE   = SYSDATE, --状态日期
                 ISSTATUSPER    = P_PER --状态人员
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
             SET ISPSTATUS      = ISSTATUS, --上次状态
                 ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
                 ISPTATUSPER    = ISSTATUSPER, --状态人员
                 ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
                 ISSTATUSDATE   = SYSDATE, --状态日期
                 ISSTATUSPER    = P_PER --状态人员
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
    
      --从托收缴费途径中获得信息
    ELSIF P_MODE = '6' THEN
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
         WHERE T.ISID IN (SELECT ISK.ISID
                            FROM RECLIST RL, INVSTOCK ISK
                           WHERE RL.RLILID = ISK.ISPCISNO
                             AND ISK.ISPCISNO = P_ID);
      
        --更新 entrustlist 的计票次数
        UPDATE ENTRUSTLIST EL
           SET EL.ETLIFINV = 0
         WHERE EL.ETLRLID IN
               (SELECT RLID FROM RECLIST RL WHERE RL.RLILID = P_ID);
      
        --更新reclist 的票号
        UPDATE RECLIST RL SET RL.RLILID = '' WHERE RL.RLILID = P_ID;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      --从走收缴费途径中获得信息
    ELSIF P_MODE = '5' THEN
    
      BEGIN
        UPDATE INVSTOCK T
           SET ISPSTATUS      = ISSTATUS, --上次状态
               ISPSTATUSDATEP = ISSTATUSDATE, --上次状态日期
               ISPTATUSPER    = ISSTATUSPER, --状态人员
               ISSTATUS       = P_STATUS, --状态(0未使用；1使用；2作废；3锁定)
               ISSTATUSDATE   = SYSDATE, --状态日期
               ISSTATUSPER    = P_PER --状态人员
         WHERE T.ISID IN (SELECT ISK.ISID
                            FROM RECLIST RL, INVSTOCK ISK
                           WHERE RL.RLILID = ISK.ISPCISNO
                             AND ISK.ISPCISNO = P_ID
                          
                          );
      
        --更新outflag
      
        UPDATE RECLIST RL
           SET RL.RLOUTFLAG = 'N', RL.RLYSCHARGETYPE = 'X'
         WHERE RL.RLILID = P_ID;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '不支持此种处理方式,类别代码：' || P_MODE);
      O_FLAG := 'N';
    END IF;
    O_FLAG := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_FLAG := 'N';
      --raise_application_error(errcode, sqlerrm);
  END;

  PROCEDURE SP_SNO_MODEFY_FP(P_OLDISBCO IN VARCHAR2, --原批次
                             P_OLDISNO  IN VARCHAR2, --原号码
                             P_NEWISBCO IN VARCHAR2, --处理状态
                             P_NEWISNO  IN VARCHAR2, --流水号
                             P_TYPE     IN VARCHAR2, --流水号
                             P_OPER     IN VARCHAR2, --流水号类别
                             O_FLAG     OUT VARCHAR2 --返回值
                             ) AS
    V_COUNT  NUMBER(10);
    IT       INVSTOCK%ROWTYPE;
    MSG      VARCHAR2(100);
    INV_TEMP INVSTOCK_TEMP%ROWTYPE;
  BEGIN
    BEGIN
      --从缴费途径中获得信息
      IF P_NEWISBCO IS NULL THEN
        MSG := '修改的发票批次号不存在!';
        RETURN;
      END IF;
      IF P_NEWISNO IS NULL THEN
        MSG := '修改的发票号码不存在!';
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
    
      --通过临时表做数据的转移
      DELETE INVSTOCK_TEMP;
      INSERT INTO INVSTOCK_TEMP INTP
        SELECT *
          FROM INVSTOCK INST
         WHERE INST.ISBCNO = P_OLDISBCO
           AND INST.ISNO = P_OLDISNO;
      --取值信息
      SELECT *
        INTO INV_TEMP
        FROM INVSTOCK_TEMP ISK_TEMP
       WHERE ISK_TEMP.ISBCNO = P_OLDISBCO
         AND ISK_TEMP.ISNO = P_OLDISNO
         AND ISK_TEMP.ISTYPE = P_TYPE;
    
      --更新新号码的信息
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
    
      --更新原有的发票的号码
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
                              '发票批次号码：' || P_NEWISBCO || P_NEWISNO);
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

  --判断用户是否为免抄户                      
  FUNCTION fgetmeterstatus(P_CODE IN VARCHAR2 --用户号
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

  --柜台打印明细函数
  FUNCTION fgetinvdeatil_gt(P_BATCH IN VARCHAR2, --批次号
                            P_TYPE  IN VARCHAR2, --类型
                            P_ROW   IN NUMBER --行数  
                            ) RETURN VARCHAR2 AS
    --参数说明
    --参数1：收费批次payment表pbatch字段
    --参数2：
    /*NY  年月
    BSS  表示数  
    SL  水量
    DJ  单价
    SF  水费
    WSF  污水处理费
    WYJ  违约金
    XJ  小计*/
    --参数3：控制行数
  
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
                                '1阶'
                               WHEN RDCLASS = 2 THEN
                                '2阶'
                               WHEN RDCLASS = 3 THEN
                                '3阶'
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
        --年月
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
        --表示数
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
                V_STR :=   v_dqRDDJ||'元' ||CHR(13);
             else
                 V_STR := '('||v_RDCLASS||'阶)' || v_dqRDDJ||'元' ||CHR(13);
              end if;
          END IF;
      ELSIF P_TYPE='DJX' THEN
          IF V_ROW = 1 THEN
             V_STR :=  v_dqRDDJ + v_WSDJ   ||CHR(13);
          END IF;
      ELSIF P_TYPE = 'XJ' THEN
        IF RL.RLIFTAX = 'Y' /*and  rl.rlmid <> '3123016839' */
         THEN
          --增值税发票
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

  --走收打印明细函数
  FUNCTION fgetinvdeatil_zs(P_RLIDLIST IN VARCHAR2, --应收流水号
                            P_TYPE     IN VARCHAR2, --类型
                            P_ROW      IN NUMBER --行数  
                            ) RETURN VARCHAR2 AS
    --参数说明
    --参数1：收费批次payment表pbatch字段
    --参数2：
    /*NY  年月
    BSS  表示数  
    SL  水量
    DJ  单价
    SF  水费
    WSF  污水处理费
    WYJ  违约金
    XJ  小计*/
    --参数3：控制行数
  
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
                                '1阶'
                               WHEN RDCLASS = 2 THEN
                                '2阶'
                               WHEN RDCLASS = 3 THEN
                                '3阶'
                               ELSE
                                '-'
                             END jt,
                             --TOOLS.FFORMATNUM(SUM(NVL(RDDJ, 0)), 2) RDDJ,
                             TOOLS.FFORMATNUM(max(NVL(RDDJ, 0)), 2) RDDJ,  --20170421由于涉及到阶梯计算同笔应收2条水费明细不能取和
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
        --年月
        if rl.rltrans <> '23' then
          --营销部收入时直接抓取应收账月份
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
        --表示数
        if FGETIFDZSB(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        elsif fgetmeterstatus(RL.RLCID) = 'Y' then
          V_STR := V_STR || '-' || CHR(13);
        else
          if nvl(TRIM(RL.RLMICOLUMN4), 'N') <> 'Y' AND rl.rltrans = '23' THEN
            --营销部收入时，如果单据未置起始指针，则发票不打印指示数
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
          --增值税发票
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

  --获取合收户数
  FUNCTION fgethscode(P_MIID IN VARCHAR2 --客户代码  
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

  --获取备注信息                  
  FUNCTION fgetinvmemo(P_RLID IN VARCHAR2, --应收流水
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
      SELECT FGETOPERNAME(bfrper) --20160530 将收费员改成抄表员
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

  --获取用户原水账标识号                   
  FUNCTION fgetcltno(P_MIID IN VARCHAR2 --客户代码  
                     ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(20);
  BEGIN
    SELECT miemail INTO V_RET FROM METERINFO WHERE MIID = P_MIID;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '-';
  END fgetcltno;

  --获取用户新账卡号（表册号+册内序号）                   
  FUNCTION fgetnewcardno(P_MIID IN VARCHAR2 --客户代码  
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

  --获取一户多表期末预存余额        
  FUNCTION fgethsqmsaving(P_MIID IN VARCHAR2 --客户代码  
                          ) RETURN VARCHAR2 as
    v_priid VARCHAR2(10);
    V_RET   VARCHAR2(20);
  begin
    --求合收主表号
    SELECT mipriid INTO v_priid FROM METERINFO WHERE MIID = P_MIID;
    --求主表预存余额
    SELECT misaving INTO V_RET FROM METERINFO WHERE MIID = v_priid;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '0';
  END fgethsqmsaving;

  --发票打印明细(一户多表)
  function fgethsinvdeatil(p_miid in varchar2 --客户代码  
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
    v_row    := 6; --行限制
    v_column := 3; --列限制
  
    select mipriid into p_code from meterinfo where miid = p_miid;
    open c_detail(p_code);
    loop
      fetch c_detail
        into v_detail.miid, v_detail.mircodechar;
      exit when c_detail%notfound or c_detail%notfound is null;
      /*    if v_detail.miid = p_miid then
        --v_type := '(合收主表)';
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

  --翻译发票备注rlinvmemo                 
  FUNCTION FGETTRANSLATE(P_RLTRANS   IN VARCHAR2, --应收事务
                         P_RLINVMEMO IN VARCHAR2 -- 发票备注
                         ) RETURN VARCHAR2 AS
    V_RET VARCHAR2(200);
  BEGIN
    --补缴收入
    IF P_RLTRANS = '13' THEN
      SELECT SCLVALUE
        INTO V_RET
        FROM SYSCHARLIST
       WHERE SCLTYPE = '补缴类别'
         AND SCLID = P_RLINVMEMO;
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '其他';
  END FGETTRANSLATE;

  --缴费生成支票数据
  PROCEDURE SP_CHEQUE(P_BATCH    IN VARCHAR2, --收费批次号 
                      P_CODE     IN VARCHAR2, --客户代码
                      P_SMFID    IN VARCHAR2, --营业所
                      P_OPER     IN VARCHAR2, --收款员
                      P_STATUS   IN VARCHAR2, --支票状态
                      P_NO       IN VARCHAR2, --支票号
                      P_BANKNAME IN VARCHAR2, --开户行名
                      P_BANKID   IN VARCHAR2, --行号
                      P_BANKNO   IN VARCHAR2, --开户账号
                      P_CWDH     IN VARCHAR2, --财务单号
                      P_TYPE     IN VARCHAR2 --进账类型
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
    --开户账号
    SELECT SMPPVALUE
      INTO V_BANKNO
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHZH';
    --开户银行
    SELECT SMPPVALUE
      INTO V_BANKNAME
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHYH';
    --开户行号
    SELECT SMPPVALUE
      INTO V_BANKID
      FROM SYSMANAPARA
     WHERE SMPID = P_SMFID
       AND SMPPID = 'KHHH';
  
    IF P_TYPE = 'ZP' THEN
      --1.检查参数
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL OR P_STATUS IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '生成参数数据：支票参数异常！');
      END IF;
    
      IF P_NO IS NULL OR P_BANKNAME IS NULL OR P_BANKID IS NULL OR
         P_BANKNO IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '支票银行信息未填写,请检查！');
      END IF;
      --2.生成数据
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
    
      --3.更新数据
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'ZP'
       WHERE PBATCH = P_BATCH;
    
      --抹帐进账单
    ELSIF P_TYPE = 'MZ' THEN
      --1.检查参数
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '参数异常！');
      END IF;
    
      --2.生成数据
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
    
      --3.更新数据
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'MZ'
       WHERE PBATCH = P_BATCH;
    
      --倒存进账单
    ELSIF P_TYPE = 'DC' THEN
      --1.检查参数
      IF P_BATCH IS NULL OR P_CODE IS NULL OR P_SMFID IS NULL OR
         P_OPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '参数异常！');
      END IF;
    
      --2.生成数据
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
    
      --3.更新数据
      UPDATE PAYMENT
         SET PCHBATCH = P_NO, ppayway = 'DC'
       WHERE PBATCH = P_BATCH;
    
    ELSIF P_TYPE = 'XJ' THEN
      --财务扎帐添加进账单
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
      CQ.chequememo      := '财务进账';
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
       CQ.chequememo = '财务进账' THEN
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

  PROCEDURE sp_财务到账(P_ID   IN VARCHAR2, --进账单流水
                    P_OPER IN VARCHAR2 --到账人
                    ) IS
    CQ CHEQUE%ROWTYPE;
  begin
    begin
      select * into CQ from CHEQUE WHERE CHEQUEID = P_ID;
    exception
      when others then
        RAISE_APPLICATION_ERROR(ERRCODE, '进账单：' || P_ID || '不存在!');
    end;
    /*--检查是否是作废支票
    IF CQ.CHEQUECRFLAG='Y' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '进账单：'||P_ID||'已作废!');
    END IF;*/
    --更新到账标志
    UPDATE CHEQUE
       SET CHEQUESTATUS = 'Y', --支票状态 
           CHEQUEOPER   = P_OPER, --状态人 
           CHEQUESDATE  = SYSDATE, --状态日期 
           CHEQUEFLAG   = 'Y' --支票勾票 
     WHERE CHEQUEID = P_ID;
    --勾账后，回写payment到账日期
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
  end sp_财务到账;

  PROCEDURE sp_财务退票(P_ID    IN VARCHAR2, --进账单流水
                    P_SMFID IN VARCHAR, --营业所
                    P_OPER  IN VARCHAR2 --退票人
                    ) IS
    v_ret varchar2(1000);
    CQ    CHEQUE%ROWTYPE;
  begin
    begin
      select * into CQ from CHEQUE WHERE CHEQUEID = P_ID;
    exception
      when others then
        RAISE_APPLICATION_ERROR(ERRCODE, '进账单：' || P_ID || '不存在!');
    end;
    IF CQ.CHEQUECRFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '进账单：' || P_ID || '已作废!');
    END IF;
  
    IF CQ.CHEQUESTATUS = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '进账单：' || P_ID || '已确认到账!');
    END IF;
  
    v_ret := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(P_ID,
                                                P_SMFID,
                                                P_OPER,
                                                P_SMFID,
                                                'C');
  
    --更新到账标志
    UPDATE CHEQUE
       SET CHEQUECRFLAG = 'Y', --作废标志 
           CHEQUECROPER = P_OPER, --作废人 
           CHEQUECRDATE = SYSDATE, --作废时间 
           CHEQUEFLAG   = 'Y' --支票勾票 
     WHERE CHEQUEID = P_ID;
  
  exception
    when others then
      rollback;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  end sp_财务退票;

  --根据发票号更新应收账务标志
  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --发票批次号
                                P_ISNO  IN VARCHAR2 --发票号
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
    INV       INV_INFO%ROWTYPE;
    INV_COUNT NUMBER;
    v_STATUS  INV_INFO.Status%type;
  BEGIN
    if P_STATUS = 0 then
      --设置成未使用
      v_STATUS := '0';
    elsif P_STATUS = 1 then
      --已使用
      v_STATUS := '1';
    elsif P_STATUS = 2 then
      --发票作废
      v_STATUS := '2';
    elsif P_STATUS = 3then --发票锁定
     v_STATUS := '3' ; elsif P_STATUS = 4 then
      --发票已删除
      v_STATUS := '4';
    elsif P_STATUS = 5 then
      --发票销毁
      v_STATUS := '5';
    end if;
    /*  0 未使用
    1 已使用
    2 作废
    3 锁定
    4 已删除
    5 销毁*/
  
    SELECT COUNT(*)
      INTO INV_COUNT
      FROM INV_INFO
     WHERE ISPCISNO = P_BATCH || '.' || P_ISNO;
    IF INV_COUNT > 0 THEN
      -- DELETE INV_INFO WHERE ISPCISNO=P_BATCH||'.'||P_ISNO;
      --modify 20140630  以上为之前发票管理时点击作废直接删除发票INV_INFO资料.
      --现更改为把发票资料更改为作废
      if P_STATUS = 0 then
        --设置成未使用时, 直接删除发票INV_INFO
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
           set STATUS = v_STATUS, statusmemo = '发票管理作废'
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


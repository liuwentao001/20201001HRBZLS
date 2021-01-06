CREATE OR REPLACE PROCEDURE PROC_INSERTMETER(U_MDNO1        IN VARCHAR,   --开始水表号
                                             U_MDNO2        IN VARCHAR,   --结束水表号
                                             U_STOREROOMID  IN VARCHAR,   --库房编号
                                             U_MDSTORE      IN VARCHAR,   --库存位置
                                             U_QFH          IN VARCHAR,   --铅封号
                                             U_MDCALIBER    IN NUMBER,    --表口径
                                             U_MDBRAND      IN VARCHAR2,  --表厂家
                                             U_MDMODEL      IN VARCHAR2,  --计量方式
                                             U_MDSTATUS     IN VARCHAR2,  --表状态
                                             U_MDSTATUSDATE IN DATE,      --表状态发生时间
                                             U_MDCYCCHKDATE IN DATE,      --周检起算日
                                             U_RKBATCH      IN VARCHAR2,  --入库批次
                                             U_RKDNO        IN VARCHAR2,  --入库单号
                                             U_MDSTOCKDATE  IN DATE,      --表状态发生时间
                                             U_RKMAN        IN VARCHAR2,  --入库人员
                                             U_RESULT       OUT NUMBER) IS
  V_SL    VARCHAR2(100);
  V_COUNT VARCHAR2(100);
BEGIN
  V_SL := U_MDNO1;
  WHILE U_MDNO2 >= V_SL LOOP
    SELECT COUNT(*) INTO V_COUNT FROM BS_METERDOC WHERE MDNO = V_SL;
    IF V_COUNT = '0' THEN
      INSERT INTO BS_METERDOC
        (ID,
         MDNO,
         STOREROOMID,
         QFH,
         MDCALIBER,
         MDBRAND,
         MDMODEL,
         MDSTATUS,
         MDSTATUSDATE,
         MDCYCCHKDATE,
         RKBATCH,
         RKDNO,
         MDSTOCKDATE,
         RKMAN,
         MDSTORE)
      VALUES
        (SEQMESTERDOCID.NEXTVAL,
         V_SL,
         U_STOREROOMID,
         U_QFH,
         U_MDCALIBER,
         U_MDBRAND,
         U_MDMODEL,
         U_MDSTATUS,
         U_MDSTATUSDATE,
         U_MDCYCCHKDATE,
         U_RKBATCH,
         U_RKDNO,
         U_MDSTOCKDATE,
         U_RKMAN,
         U_MDSTORE);
      V_SL     := V_SL + 1;
      U_RESULT := TO_NUMBER(U_MDNO2 - U_MDNO1 + 1);
    ELSE
      U_RESULT := '-1';
      RETURN;
    END IF;
  END LOOP;
  IF U_RESULT<>'-1' THEN
  COMMIT;
  ELSE
  ROLLBACK;
  END IF;
  --U_RESULT := SQL%ROWCOUNT;
END;
/


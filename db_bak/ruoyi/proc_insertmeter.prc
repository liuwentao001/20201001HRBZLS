CREATE OR REPLACE PROCEDURE PROC_INSERTMETER(U_MDNO1        IN VARCHAR, --开始水表号
                                             U_MDNO2        IN VARCHAR, --结束水表号
                                             U_STOREROOMID  IN VARCHAR, --库房编号
                                             U_MDSTORE      IN VARCHAR, --库存位置
                                             U_QFH          IN VARCHAR, --铅封号
                                             U_MDCALIBER    IN NUMBER, --表口径
                                             U_MDBRAND      IN VARCHAR2, --表厂家
                                             U_MDMODEL      IN VARCHAR2, --计量方式
                                             U_MDSTATUS     IN VARCHAR2, --表状态
                                             U_MDSTATUSDATE IN DATE, --表状态发生时间
                                             U_MDCYCCHKDATE IN DATE, --周检起算日
                                             U_RKBATCH      IN VARCHAR2, --入库批次
                                             U_RKDNO        IN VARCHAR2, --入库单号
                                             U_MDSTOCKDATE  IN DATE, --表状态发生时间
                                             U_RKMAN        IN VARCHAR2, --入库人员
                                             I_MDMODE       IN VARCHAR2, --基电转换方式
                                             I_MIRTID       IN VARCHAR2, --采集类型
                                             I_CONCENTRATORID IN VARCHAR2, --集中器ID
                                             I_READMETERCODE  IN VARCHAR2, --抄表序号
                                             I_PORTNO       IN VARCHAR2, --上传端口号
                                             I_TRANSFERSTYPE  IN VARCHAR2, --传输类型
                                             I_READTYPE     IN VARCHAR2, --读数方式
                                             I_ISCONTROL    IN VARCHAR2, --阀控否
                                             U_RETURN       OUT VARCHAR2, --返回重复编号
                                             U_RESULT       OUT NUMBER) IS  --返回执行状态或数量
  V_SL     VARCHAR2(100);
  V_COUNT  VARCHAR2(100);
BEGIN
  V_SL     := U_MDNO1;
  U_RETURN := '';
  WHILE U_MDNO2 >= V_SL LOOP
    SELECT COUNT(*) INTO V_COUNT FROM BS_METERDOC WHERE MDNO = V_SL;
    IF V_COUNT <> 0 THEN
      U_RETURN := U_RETURN || V_SL || ',';
    END IF;
    V_SL     := V_SL + 1;
  END LOOP;
  V_SL     := U_MDNO1;
  IF U_RETURN IS NULL THEN
    WHILE U_MDNO2 >= V_SL LOOP
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
         MDSTORE,
         MDMODE,
         MIRTID,
         CONCENTRATORID,
         READMETERCODE,
         PORTNO,
         TRANSFERSTYPE,
         READTYPE,
         ISCONTROL)
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
         U_MDSTORE,
         I_MDMODE,
         I_MIRTID,
         I_CONCENTRATORID,
         I_READMETERCODE,
         I_PORTNO,
         I_TRANSFERSTYPE,
         I_READTYPE,
         I_ISCONTROL);
      V_SL     := V_SL + 1;
      U_RESULT := TO_NUMBER(U_MDNO2 - U_MDNO1 + 1);
    END LOOP;
    COMMIT;
  ELSE
    U_RESULT := '-1';
  END IF;
  IF LENGTH(U_RETURN)<>0 THEN
    U_RETURN := SUBSTR(U_RETURN,1,LENGTH(U_RETURN)-1);
    END IF;
END;
/


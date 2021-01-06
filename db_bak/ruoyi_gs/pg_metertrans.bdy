CREATE OR REPLACE PACKAGE BODY PG_METERTRANS IS

  --工单主程序
  --工单主程序
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --操作类型
                               P_MTHNO  IN VARCHAR2, --批次流水
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2 --提交标志
                               ) AS
    MH REQUEST_GZHB%ROWTYPE;
    MD REQUEST_GZHB%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM REQUEST_GZHB WHERE reno = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    --    20140815 工单信息已经审核不能再审 改用表头判断
    IF MH.MTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;

    FOR V_CURSOR IN (SELECT * FROM REQUEST_GZHB WHERE MTDNO = P_MTHNO) LOOP
      BEGIN
        SELECT *
          INTO MD
          FROM REQUEST_GZHB
         WHERE MTDNO = P_MTHNO
           AND MTDROWNO = V_CURSOR.MTDROWNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
      END;
      SP_METERTRANSONE(P_TYPE, P_PER, MD);
      ----------------表身码状态改变
      IF P_TYPE IN ('F') THEN
        --旧表状态
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = ''
         WHERE BSM = MD.MTDMNOO;
        --销户拆表旧表所有封号作废
        UPDATE ST_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = FGETPBOPER, MAINDATE = SYSDATE
         WHERE BSM = MD.MTDMNOO
           AND FHSTATUS = '1';
      END IF;
      IF P_TYPE IN ('L', 'K') THEN
        --旧表状态
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = ''
         WHERE BSM = MD.MTDMNOO;
        --故障换表、周期换表旧表所有封号作废
        UPDATE ST_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = FGETPBOPER, MAINDATE = SYSDATE
         WHERE BSM = MD.MTDMNOO
           AND FHSTATUS = '1';
        --新表状态
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MD.MTDMCODE
         WHERE BSM = MD.MTDMNON;
      END IF;
      -----------------
      IF P_TYPE = 'A' THEN
        UPDATE BS_METERINFO T
           SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
         WHERE T.MIID = MD.MTDMID;
      END IF;

      --免抄户、倒装水表 故障换表、周期换表后为正常户
      IF P_TYPE IN ('L', 'K') THEN
        --重置正常表态
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MD.MTDMID;
        --去掉倒表标志
        UPDATE METERDOC T SET T.IFDZSB = 'N' WHERE T.MDMID = MD.MTDMID;
      END IF;
    END LOOP;

    UPDATE REQUEST_GZHB
       SET MTDFLAG = 'Y' /*,MTBK8='Y'*/
     WHERE MTDNO = P_MTHNO;

    UPDATE REQUEST_GZHB
       SET MTHSHDATE = SYSDATE, MTHSHPER = P_PER, MTHSHFLAG = 'Y'
     WHERE reno = P_MTHNO;

    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT reno, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM REQUEST_GZHB
       WHERE reno = P_MTHNO;

    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_MTHNO);

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --工单单个审核过程
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN REQUEST_GZHB%ROWTYPE --单体行变更
                             ) AS
    MH            REQUEST_GZHB%ROWTYPE;
    MD            REQUEST_GZHB%ROWTYPE;
    MI            BS_METERINFO%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MC            METERDOC%ROWTYPE;
    MA            METERADDSL%ROWTYPE;
    MK            METERTRANSROLLBACK%ROWTYPE;
    V_MRMEMO      METERREAD.MRMEMO%TYPE;
    V_COUNT       NUMBER(4);
    V_COUNTMRID   NUMBER(4);
    V_COUNTFLAG   NUMBER(4);
    V_NUMBER      NUMBER(10);
    V_RCODE       NUMBER(10);
    V_CRHNO       VARCHAR2(10);
    V_OMRID       VARCHAR2(20);
    O_STR         VARCHAR2(20);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    V_METERSTORE  ST_METERINFO_STORE%ROWTYPE;

    --未算费抄表记录
    CURSOR CUR_METERREAD_NOCALC(P_MRMID VARCHAR2, P_MRMONTH VARCHAR2) IS
      SELECT *
        FROM METERREAD MR
       WHERE MR.MRMID = P_MRMID
         AND MR.MRMONTH = P_MRMONTH;

  BEGIN
    BEGIN
      SELECT * INTO MI FROM BS_METERINFO WHERE MIID = P_MD.MTDMID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CUSTINFO.CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT * INTO MC FROM METERDOC WHERE MDMID = P_MD.MTDMID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;

    IF MI.MIRCODE != MD.MTDSCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '上期抄见发生变化，请重置上期抄见');
    END IF;

    IF FSYSPARA('sys4') = 'Y' THEN
      BEGIN
        SELECT STATUS
          INTO V_METERSTATUS.SID
          FROM ST_METERINFO_STORE
         WHERE BSM = P_MD.MTDMNON;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTATUS.SID) <> '2' THEN
        SELECT SNAME
          INTO V_METERSTATUS.SNAME
          FROM METERSTATUS
         WHERE SID = V_METERSTATUS.SID;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MICID || '该水表状态为【' ||
                                V_METERSTATUS.SNAME || '】不能使用！');
      END IF;
    END IF;

    --F销户拆表
    IF P_TYPE = BT销户拆表 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M销户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIUNINSDATE   = SYSDATE,
             MIBFID        = NULL -- BY 20170904 WLJ 销户拆表将表册置空
       WHERE MIID = P_MD.MTDMID;

      --销户后同步用户状态
      UPDATE CUSTINFO
         SET CISTATUS      = M销户,
             CISTATUSDATE  = SYSDATE,
             CISTATUSTRANS = P_TYPE
       WHERE CICODE = P_MD.MTDMID;

      ---销户拆表收取余量水费（在去掉低度之前）
      --STEP1 插入抄表记录

      --STEP2  插入应收记录

      --去掉低度[20110702]
      UPDATE PRICEADJUSTLIST PL
         SET PL.PALSTATUS = 'N'
       WHERE PL.PALMID = P_MD.MTDMID;

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      ----增加拆表数据的实时型
      BEGIN
        PG_EWIDE_CUSTBASE_01.SUM$DAY$METER(MI.MIID, '7', 'N');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;
      -----METERDOC  表状态 表状态发生时间  【YUJIA 20110323】
      UPDATE METERDOC
         SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;

    ELSIF P_TYPE = BT口径变更 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER    = P_MD.MTDREINSPER, --换表人
             MITYPE        = P_MD.MTDMTYPEN, --表型
             MIBFID        = NULL
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS     = M立户,
             MDCALIBER    = P_MD.MTDCALIBERN,
             MDNO         = P_MD.MTDMNON, ---表型号
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      ------表身码状态改变    旧表状态
      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费？？？
    ELSIF P_TYPE = BT换阀门 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT欠费停水 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M欠费停水,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT恢复供水 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT报停 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      UPDATE BS_METERINFO
         SET MISTATUS      = M报停,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT校表 THEN
      -- BS_METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE BS_METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIREINSDATE   = P_MD.MTDREINSDATE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS     = M立户,
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT复装 THEN
      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE BS_METERINFO
         SET MISTATUS      = M立户, --状态
             MISTATUSDATE  = SYSDATE, --状态日期
             MISTATUSTRANS = P_TYPE, --状态表务
             MIADR         = P_MD.MTDMADRN, --水表地址
             MISIDE        = P_MD.MTDSIDEN, --表位
             MIPOSITION    = P_MD.MTDPOSITIONN, --水表接水地址
             MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER    = P_MD.MTDREINSPER --换表人
       WHERE MIID = P_MD.MTDMID;
      UPDATE METERDOC
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.MTDMNON, --表身号
             MDCALIBER    = P_MD.MTDCALIBERN, --表口径
             MDBRAND      = P_MD.MTDBRANDN, --表厂家
             MDMODEL      = P_MD.MTDMODELN, --表型号
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;
      --REQUEST_GZHB 回滚换表日期 回滚水表状态
      UPDATE REQUEST_GZHB
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK
       WHERE MTRBID = P_MD.MTDNO
         AND MTRBROWNO = P_MD.MTDROWNO;
      MK.MTRBID           := P_MD.MTDNO; --单据流水
      MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
      MK.MTRBDATE         := SYSDATE; --回滚备份日期
      MK.MTRBSTATUS       := MI.MISTATUS; --状态
      MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
      MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
      MK.MTRBRCODE        := MI.MIRCODE; --本期读数
      MK.MTRBADR          := MI.MIADR; --表地址
      MK.MTRBSIDE         := MI.MISIDE; --表位
      MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
      MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
      MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
      MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
      MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
      MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
      MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
      MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
      MK.MTRBNO           := MC.MDNO; --表身码
      MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
      MK.MTRBBRAND        := MC.MDBRAND; --表厂家
      MK.MTRBMODEL        := MC.MDMODEL; --表型号
      MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
      MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
      -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
      MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
      MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
      MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
      MA.MASCREDATE   := SYSDATE; --创建日期
      MA.MASCID       := MI.MICID; --用户编号
      MA.MASMID       := MI.MIID; --水表编号
      MA.MASSL        := P_MD.MTDADDSL; --余量
      MA.MASCREPER    := P_PERSON; --创建人员
      MA.MASTRANS     := P_TYPE; --加调事务
      MA.MASBILLNO    := P_MD.MTDNO; --单据流水
      MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
      MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
      MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
      INSERT INTO METERADDSL VALUES MA;
      --算费
    ELSIF P_TYPE = BT故障换表 THEN
      SELECT COUNT(*)
        INTO V_COUNTFLAG
        FROM METERREAD MR
       WHERE MR.MRMID = P_MD.MTDMID
         AND MR.MRREADOK = 'Y' --已抄表
         AND MR.MRIFREC <> 'Y'; --未算费
      IF V_COUNTFLAG > 0 THEN
        --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '【' || P_MD.MTDMID ||
                                '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
      END IF;
      UPDATE METERREAD T
         SET MRSCODE = P_MD.MTDREINSCODE --BY RALPH 20151021  增加的将未抄见指针更换掉
       WHERE MRMID = P_MD.MTDMID
         AND MRREADOK = 'N';
      ------水表量程校验与更新 ZF  20160828
       IF P_MD.MIYL9 IS NOT NULL THEN
         UPDATE BS_METERINFO
         SET MIYL9 = P_MD.MIYL9 --水表最大量程
       WHERE MIID = P_MD.MTDMID;
       END IF;
    END IF;
    UPDATE BS_METERINFO
       SET MISTATUS      = M立户, --状态
           MISTATUSDATE  = SYSDATE, --状态日期
           MISTATUSTRANS = P_TYPE, --状态表务
           MIRCODE       = P_MD.MTDREINSCODE, --换表起度
           MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
           MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
           MIREINSPER    = P_MD.MTDREINSPER, --换表人
           MIYL1         = 'N', --换表后将 等针标志清除(如果有) BYJ 2016.08
           MIRTID        = P_MD.MTDMIRTID --换表后 根据工单更新 抄表方式! BYJ 2016.12
     WHERE MIID = P_MD.MTDMID;
    --换表后清除等针中间表标志 BYJ 2016.08-------------
    UPDATE METERTGL MTG
       SET MTG.MTSTATUS = 'N'
     WHERE MTMID = P_MD.MTDMID
       AND MTSTATUS = 'Y';
    ---------------------------------------------------

    --METERDOC 更新新表信息
    BEGIN
      SELECT *
        INTO V_METERSTORE
        FROM ST_METERINFO_STORE ST
       WHERE ST.BSM = P_MD.MTDMNON
         AND ROWNUM < 2;
      UPDATE METERDOC
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --表状态发生时间
             MDNO         = P_MD.MTDMNON, --表身号
             DQSFH        = P_MD.MTDDQSFHN, --塑封号
             DQGFH        = P_MD.MTDLFHN, --钢封号
             QFH          = P_MD.MTDQFHN, --铅封号
             MDCALIBER    = V_METERSTORE.CALIBER, --表口径
             MDBRAND      = P_MD.MTDBRANDN, --表厂家
             MDCYCCHKDATE = P_MD.MTDREINSDATE, --
             MDMODEL      = V_METERSTORE.MODEL --表型号
       WHERE MDMID = P_MD.MTDMID;
    EXCEPTION
      WHEN OTHERS THEN
        UPDATE METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --表状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               DQSFH        = P_MD.MTDDQSFHN, --塑封号
               DQGFH        = P_MD.MTDLFHN, --钢封号
               QFH          = P_MD.MTDQFHN, --铅封号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;
    END;

    --设置塑封号为已使用
    IF P_MD.MTDDQSFHN IS NOT NULL THEN
      UPDATE ST_METERFH_STORE
         SET BSM      = P_MD.MTDMNON,
             FHSTATUS = '1',
             MAINMAN  = FGETPBOPER,
             MAINDATE = SYSDATE
       WHERE METERFH = P_MD.MTDDQSFHN
         AND STOREID = MI.MISMFID --地区
         AND CALIBER = P_MD.MTDCALIBERO --口径
         AND FHTYPE = '1';
    END IF;
    --设置钢封号为已使用
    IF P_MD.MTDLFHN IS NOT NULL THEN
      UPDATE ST_METERFH_STORE
         SET BSM      = P_MD.MTDMNON,
             FHSTATUS = '1',
             MAINMAN  = FGETPBOPER,
             MAINDATE = SYSDATE
       WHERE METERFH = P_MD.MTDLFHN
         AND STOREID = MI.MISMFID --地区
         AND FHTYPE = '2';
    END IF;
    --设置铅封号为已使用
    IF P_MD.MTDQFHN IS NOT NULL THEN
      UPDATE ST_METERFH_STORE
         SET BSM      = P_MD.MTDMNON,
             FHSTATUS = '1',
             MAINMAN  = FGETPBOPER,
             MAINDATE = SYSDATE
       WHERE METERFH = P_MD.MTDQFHN
         AND STOREID = MI.MISMFID --地区
         AND FHTYPE = '4';
    END IF;

    --【抄表审核转单】故障换表后回写复核标志
    SELECT COUNT(*)
      INTO V_COUNTFLAG
      FROM METERREAD MR
     WHERE MR.MRMID = P_MD.MTDMID
       AND MR.MRIFSUBMIT = 'N';
    IF V_COUNTFLAG > 0 THEN
      UPDATE METERREAD MR
         SET MR.MRCHKFLAG = 'Y', --复核标志
             MR.MRCHKDATE = SYSDATE, --复核日期
             MR.MRCHKPER  = P_PERSON --复核人员

       WHERE MR.MRMID = P_MD.MTDMID
         AND MR.MRIFSUBMIT = 'N';
    END IF;

    --备份记录回滚信息
    DELETE METERTRANSROLLBACK
     WHERE MTRBID = P_MD.MTDNO
       AND MTRBROWNO = P_MD.MTDROWNO;
    MK.MTRBID           := P_MD.MTDNO; --单据流水
    MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
    MK.MTRBDATE         := SYSDATE; --回滚备份日期
    MK.MTRBSTATUS       := MI.MISTATUS; --状态
    MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
    MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
    MK.MTRBRCODE        := MI.MIRCODE; --本期读数
    MK.MTRBADR          := MI.MIADR; --表地址
    MK.MTRBSIDE         := MI.MISIDE; --表位
    MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
    MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
    MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
    MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
    MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
    MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
    MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
    MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
    MK.MTRBNO           := MC.MDNO; --表身码
    MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
    MK.MTRBBRAND        := MC.MDBRAND; --表厂家
    MK.MTRBMODEL        := MC.MDMODEL; --表型号
    MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
    MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
    INSERT INTO METERTRANSROLLBACK VALUES MK;

    --记余量表 METERADDSL
    SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
    -- MD.MASID           :=     ;--记录流水号
    MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
    MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
    MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
    MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
    MA.MASCREDATE   := SYSDATE; --创建日期
    MA.MASCID       := MI.MICID; --用户编号
    MA.MASMID       := MI.MIID; --水表编号
    MA.MASSL        := P_MD.MTDADDSL; --余量
    MA.MASCREPER    := P_PERSON; --创建人员
    MA.MASTRANS     := P_TYPE; --加调事务
    MA.MASBILLNO    := P_MD.MTDNO; --单据流水
    MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
    MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
    MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
    INSERT INTO METERADDSL VALUES MA;
    BEGIN
      SELECT STATUS
        INTO V_METERSTATUS.SID
        FROM ST_METERINFO_STORE
       WHERE BSM = P_MD.MTDMNON;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF TRIM(V_METERSTATUS.SID) <> '2' THEN
      SELECT SNAME
        INTO V_METERSTATUS.SNAME
        FROM METERSTATUS
       WHERE SID = V_METERSTATUS.SID;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '该水表状态为【' || V_METERSTATUS.SNAME || '】不能使用！');
    END IF;
    IF TRIM(V_METERSTATUS.SID) = '2' THEN
      UPDATE ST_METERINFO_STORE
         SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNON;
      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;
    END IF;
    --算费
   --ELSIF P_TYPE = BT水表整改 THEN
   IF P_TYPE = BT水表整改 THEN
  -- BS_METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
  UPDATE BS_METERINFO SET MISTATUS = M立户, --状态
  MISTATUSDATE = SYSDATE, --状态日期
  MISTATUSTRANS = P_TYPE, --状态表务
  MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
  MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
  MIREINSPER = P_MD.MTDREINSPER --换表人
  WHERE MIID = P_MD.MTDMID;
  UPDATE METERDOC SET MDSTATUS = M立户, --状态
  MDSTATUSDATE = SYSDATE, --表状态发生时间
  MDNO = P_MD.MTDMNON, --表身号
  MDCALIBER = P_MD.MTDCALIBERN, --表口径
  MDBRAND = P_MD.MTDBRANDN, --表厂家
  MDMODEL = P_MD.MTDMODELN, --表型号
  MDCYCCHKDATE = P_MD.MTDREINSDATE --
  WHERE MDMID = P_MD.MTDMID;
  --备份记录回滚信息
  DELETE              METERTRANSROLLBACK WHERE MTRBID = P_MD.MTDNO AND MTRBROWNO = P_MD.MTDROWNO;
  MK.MTRBID           := P_MD.MTDNO; --单据流水
  MK.MTRBROWNO        := P_MD.MTDROWNO; --行号
  MK.MTRBDATE         := SYSDATE; --回滚备份日期
  MK.MTRBSTATUS       := MI.MISTATUS; --状态
  MK.MTRBSTATUSDATE   := MI.MISTATUSDATE; --状态日期
  MK.MTRBSTATUSTRANS  := MI.MISTATUSTRANS; --状态表务
  MK.MTRBRCODE        := MI.MIRCODE; --本期读数
  MK.MTRBADR          := MI.MIADR; --表地址
  MK.MTRBSIDE         := MI.MISIDE; --表位
  MK.MTRBPOSITION     := MI.MIPOSITION; --水表接水地址
  MK.MTRBINSCODE      := MI.MIINSCODE; --新装起度
  MK.MTRBREINSCODE    := MI.MIREINSCODE; --换表起度
  MK.MTRBREINSDATE    := MI.MIREINSDATE; --换表日期
  MK.MTRBREINSPER     := MI.MIREINSPER; --换表人
  MK.MTRBCSTATUS      := CI.CISTATUS; --用户状态
  MK.MTRBCSTATUSDATE  := CI.CISTATUSDATE; --状态日期
  MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
  MK.MTRBNO           := MC.MDNO; --表身码
  MK.MTRBCALIBER      := MC.MDCALIBER; --表口径
  MK.MTRBBRAND        := MC.MDBRAND; --表厂家
  MK.MTRBMODEL        := MC.MDMODEL; --表型号
  MK.MTRBMSTATUS      := MC.MDSTATUS; --表状态
  MK.MTRBMSTATUSDATE  := MC.MDSTATUSDATE; --表状态发生时间
  INSERT              INTO METERTRANSROLLBACK VALUES MK;
  --记余量表 METERADDSL
  SELECT          SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
  MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
  MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
  MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
  MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
  MA.MASCREDATE   := SYSDATE; --创建日期
  MA.MASCID       := MI.MICID; --用户编号
  MA.MASMID       := MI.MIID; --水表编号
  MA.MASSL        := P_MD.MTDADDSL; --余量
  MA.MASCREPER    := P_PERSON; --创建人员
  MA.MASTRANS     := P_TYPE; --加调事务
  MA.MASBILLNO    := P_MD.MTDNO; --单据流水
  MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
  MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
  MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
  INSERT          INTO METERADDSL VALUES MA;
  ELSIF           P_TYPE = BT周期换表 THEN
    SELECT COUNT(*)
      INTO V_COUNTFLAG
      FROM METERREAD MR
     WHERE MR.MRMID = P_MD.MTDMID
       AND MR.MRREADOK = 'Y' --已抄表
       AND MR.MRIFREC <> 'Y'; --未算费
  IF              V_COUNTFLAG > 0 THEN --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
  RAISE_APPLICATION_ERROR(ERRCODE,
                          '此水表[' || P_MD.MTDMID ||
                          ']已经抄表录入,抄见标志有打上,不能进行周期换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
END IF;

------水表量程校验与更新 ZF  20160828
IF P_MD.MIYL9 IS
NOT NULL THEN UPDATE BS_METERINFO SET MIYL9 = P_MD.MIYL9 --水表最大量程
WHERE MIID = P_MD.MTDMID;
---  END IF ;
END IF;
----------------------------20160828,
UPDATE BS_METERINFO SET MISTATUS = M立户, --状态
MISTATUSDATE = SYSDATE, --状态日期
MISTATUSTRANS = P_TYPE, --状态表务
MIRCODE = P_MD.MTDREINSCODE, --换表起度
MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
MIREINSPER = P_MD.MTDREINSPER, --换表人
MIYL1 = 'N', --换表后将 等针标志清除(如果有) BYJ 2016.08
MIRTID = P_MD.MTDMIRTID --换表后 根据工单更新 抄表方式! BYJ 2016.12
WHERE MIID = P_MD.MTDMID;

--换表后清除等针中间表标志 BYJ 2016.08-------------
UPDATE METERTGL MTG SET MTG.MTSTATUS = 'N' WHERE MTMID = P_MD.MTDMID AND MTSTATUS = 'Y';
---------------------------------------------------
--METERDOC 更新新表信息
BEGIN
SELECT * INTO V_METERSTORE FROM ST_METERINFO_STORE ST WHERE ST.BSM = P_MD.MTDMNON AND ROWNUM < 2; UPDATE METERDOC SET MDSTATUS = M立户, --状态
MDSTATUSDATE = SYSDATE, --表状态发生时间
MDNO = P_MD.MTDMNON, --表身号
DQSFH = P_MD.MTDDQSFHN, --塑封号
DQGFH = P_MD.MTDLFHN, --钢封号
QFH = P_MD.MTDQFHN, --铅封号
MDCALIBER = V_METERSTORE.CALIBER, --表口径
MDBRAND = P_MD.MTDBRANDN, --表厂家
MDCYCCHKDATE = P_MD.MTDREINSDATE, --
MDMODEL = V_METERSTORE.MODEL --表型号
WHERE MDMID = P_MD.MTDMID;
EXCEPTION
WHEN OTHERS THEN UPDATE METERDOC SET MDSTATUS = M立户, --状态
MDSTATUSDATE = SYSDATE, --表状态发生时间
MDNO = P_MD.MTDMNON, --表身号
DQSFH = P_MD.MTDDQSFHN, --塑封号
DQGFH = P_MD.MTDLFHN, --钢封号
QFH = P_MD.MTDQFHN, --铅封号
MDCALIBER = P_MD.MTDCALIBERN, --表口径
MDBRAND = P_MD.MTDBRANDN, --表厂家
MDCYCCHKDATE = P_MD.MTDREINSDATE --
WHERE MDMID = P_MD.MTDMID;
END;
--设置塑封号为已使用
IF P_MD.MTDDQSFHN IS
NOT NULL THEN UPDATE ST_METERFH_STORE SET BSM = P_MD.MTDMNON, FHSTATUS = '1', MAINMAN = FGETPBOPER, MAINDATE = SYSDATE WHERE METERFH = P_MD.MTDDQSFHN AND STOREID = MI.MISMFID --地区
AND CALIBER = P_MD.MTDCALIBERO --口径
AND FHTYPE = '1';
END IF;
--设置钢封号为已使用
IF P_MD.MTDLFHN IS
NOT NULL THEN UPDATE ST_METERFH_STORE SET BSM = P_MD.MTDMNON, FHSTATUS = '1', MAINMAN = FGETPBOPER, MAINDATE = SYSDATE WHERE METERFH = P_MD.MTDLFHN AND STOREID = MI.MISMFID --地区
AND FHTYPE = '2';
END IF;
--设置铅封号为已使用
IF P_MD.MTDQFHN IS
NOT NULL THEN UPDATE ST_METERFH_STORE SET BSM = P_MD.MTDMNON, FHSTATUS = '1', MAINMAN = FGETPBOPER, MAINDATE = SYSDATE WHERE METERFH = P_MD.MTDQFHN AND STOREID = MI.MISMFID --地区
AND FHTYPE = '4';
END IF;

--【抄表审核转单】周期换表后回写复核标志
SELECT COUNT(*) INTO V_COUNTFLAG FROM METERREAD MR WHERE MR.MRMID = P_MD.MTDMID AND MR.MRIFSUBMIT = 'N'; IF V_COUNTFLAG > 0 THEN UPDATE METERREAD MR SET MR.MRCHKFLAG = 'Y', --复核标志
MR.MRCHKDATE = SYSDATE, --复核日期
MR.MRCHKPER = P_PERSON --复核人员

WHERE MR.MRMID = P_MD.MTDMID AND MR.MRIFSUBMIT = 'N';
END IF;

--备份记录回滚信息
DELETE METERTRANSROLLBACK WHERE MTRBID = P_MD.MTDNO AND MTRBROWNO = P_MD.MTDROWNO; MK.MTRBID := P_MD.MTDNO; --单据流水
MK.MTRBROWNO := P_MD.MTDROWNO; --行号
MK.MTRBDATE := SYSDATE; --回滚备份日期
MK.MTRBSTATUS := MI.MISTATUS; --状态
MK.MTRBSTATUSDATE := MI.MISTATUSDATE; --状态日期
MK.MTRBSTATUSTRANS := MI.MISTATUSTRANS; --状态表务
MK.MTRBRCODE := MI.MIRCODE; --本期读数
MK.MTRBADR := MI.MIADR; --表地址
MK.MTRBSIDE := MI.MISIDE; --表位
MK.MTRBPOSITION := MI.MIPOSITION; --水表接水地址
MK.MTRBINSCODE := MI.MIINSCODE; --新装起度
MK.MTRBREINSCODE := MI.MIREINSCODE; --换表起度
MK.MTRBREINSDATE := MI.MIREINSDATE; --换表日期
MK.MTRBREINSPER := MI.MIREINSPER; --换表人
MK.MTRBCSTATUS := CI.CISTATUS; --用户状态
MK.MTRBCSTATUSDATE := CI.CISTATUSDATE; --状态日期
MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
MK.MTRBNO := MC.MDNO; --表身码
MK.MTRBCALIBER := MC.MDCALIBER; --表口径
MK.MTRBBRAND := MC.MDBRAND; --表厂家
MK.MTRBMODEL := MC.MDMODEL; --表型号
MK.MTRBMSTATUS := MC.MDSTATUS; --表状态
MK.MTRBMSTATUSDATE := MC.MDSTATUSDATE; --表状态发生时间
INSERT INTO METERTRANSROLLBACK VALUES MK;
--记余量表 METERADDSL
SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
-- MD.MASID           :=     ;--记录流水号
MA.MASSCODEO := P_MD.MTDSCODE; --旧表起度
MA.MASECODEN := P_MD.MTDECODE; --旧表止度
MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
MA.MASUNINSPER := P_MD.MTDUNINSPER; --拆表人
MA.MASCREDATE := SYSDATE; --创建日期
MA.MASCID := MI.MICID; --用户编号
MA.MASMID := MI.MIID; --水表编号
MA.MASSL := P_MD.MTDADDSL; --余量
MA.MASCREPER := P_PERSON; --创建人员
MA.MASTRANS := P_TYPE; --加调事务
MA.MASBILLNO := P_MD.MTDNO; --单据流水
MA.MASSCODEN := P_MD.MTDREINSCODE; --新表起度
MA.MASINSDATE := P_MD.MTDREINSDATE; --装表日期
MA.MASINSPER := P_MD.MTDREINSPER; --装表人
INSERT INTO METERADDSL VALUES MA;
BEGIN
SELECT STATUS INTO V_METERSTATUS.SID FROM ST_METERINFO_STORE WHERE BSM = P_MD.MTDMNON;

EXCEPTION
WHEN OTHERS THEN NULL;
END; IF TRIM(V_METERSTATUS.SID) <> '2' THEN SELECT SNAME INTO V_METERSTATUS.SNAME FROM METERSTATUS WHERE SID = V_METERSTATUS.SID; RAISE_APPLICATION_ERROR(ERRCODE, MI.MICID || '该水表状态为【' || V_METERSTATUS.SNAME || '】不能使用！');
END IF; IF TRIM(V_METERSTATUS.SID) = '2' THEN UPDATE ST_METERINFO_STORE SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE WHERE BSM = P_MD.MTDMNON; UPDATE ST_METERINFO_STORE SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE WHERE BSM = P_MD.MTDMNOO;
END IF;

--算费
ELSIF P_TYPE = BT复查工单 THEN NULL; ELSIF P_TYPE = BT改装总表 THEN IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN TOOLS.SP_BILLSEQ('100', V_CRHNO); INSERT INTO CUSTREGHD(CRHNO, CRHBH, CRHLB, CRHSOURCE, CRHSMFID, CRHDEPT, CRHCREDATE, CRHCREPER, CRHSHFLAG) VALUES(V_CRHNO, P_MD.MTDNO, '0', P_TYPE, P_MD.MTDSMFID, NULL, SYSDATE, P_PERSON, 'N');

V_NUMBER := 0; LOOP INSERT INTO CUSTMETERREGDT(CMRDNO, CMRDROWNO, CISMFID, CINAME, CINAME2, CIADR, CISTATUS, CISTATUSTRANS, CIIDENTITYLB, CIIDENTITYNO, CIMTEL, CITEL1, CITEL2, CITEL3, CICONNECTPER, CICONNECTTEL, CIIFINV, CIIFSMS, CIIFZN, MIADR, MISAFID, MISMFID, MIRTID, MISTID, MIPFID, MISTATUS, MISTATUSTRANS, MIRPID, MISIDE, MIPOSITION, MITYPE, MIIFCHARGE, MIIFSL, MIIFCHK, MIIFWATCH, MICHARGETYPE, MILB, MINAME, MINAME2, CICLASS, CIFLAG, MIIFMP, MIIFSP, MIIFCKF, MIUSENUM, MISAVING, MIIFTAX, MIINSCODE, MIINSDATE, MIPRIFLAG, MDSTATUS, MAIFXEZF, MIRCODE, MDNO, MDMODEL, MDBRAND, MDCALIBER, CMDCHKPER, MIINSCODECHAR, MIPID) VALUES(V_CRHNO, V_NUMBER + 1, MI.MISMFID, '新用户', '新用户', CI.CIADR, '0', CI.CISTATUSTRANS, '1', CI.CIIDENTITYNO, P_MD.MTDTEL, CI.CITEL1, CI.CITEL2, CI.CITEL3, P_MD.MTDCONPER, P_MD.MTDCONTEL, 'Y', 'N', 'Y', MI.MIADR, MI.MISAFID, MI.MISMFID, MI.MIRTID, MI.MISTID, MI.MIPFID, '1', MI.MISTATUSTRANS, MI.MIRPID, P_MD.MTDSIDEO, P_MD.MTDPOSITIONO, '1', 'Y', 'Y', 'N', 'N', 'X', 'H', MI.MINAME, MI.MINAME2, 1, 'Y', 'N', 'N', 'N', 1, 0, 'N', 0, TRUNC(SYSDATE), 'N', '00', 'N', P_MD.MTDREINSCODE, P_MD.MTDMNOO, P_MD.MTDMODELO, P_MD.MTDBRANDO, P_MD.MTDCALIBERO, P_MD.MTDCHKPER, '00000', P_MD.MTDMCODE); V_NUMBER := V_NUMBER + 1; EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
END LOOP;
END IF; ELSIF P_TYPE = BT补装户表 THEN IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN TOOLS.SP_BILLSEQ('100', V_CRHNO); INSERT INTO CUSTREGHD(CRHNO, CRHBH, CRHLB, CRHSOURCE, CRHSMFID, CRHDEPT, CRHCREDATE, CRHCREPER, CRHSHFLAG) VALUES(V_CRHNO, P_MD.MTDNO, '0', P_TYPE, P_MD.MTDSMFID, NULL, SYSDATE, P_PERSON, 'N');

V_NUMBER := 0; LOOP INSERT INTO CUSTMETERREGDT(CMRDNO, CMRDROWNO, CISMFID, CINAME, CINAME2, CIADR, CISTATUS, CISTATUSTRANS, CIIDENTITYLB, CIIDENTITYNO, CIMTEL, CITEL1, CITEL2, CITEL3, CICONNECTPER, CICONNECTTEL, CIIFINV, CIIFSMS, CIIFZN, MIADR, MISAFID, MISMFID, MIRTID, MISTID, MIPFID, MISTATUS, MISTATUSTRANS, MIRPID, MISIDE, MIPOSITION, MITYPE, MIIFCHARGE, MIIFSL, MIIFCHK, MIIFWATCH, MICHARGETYPE, MILB, MINAME, MINAME2, CICLASS, CIFLAG, MIIFMP, MIIFSP, MIIFCKF, MIUSENUM, MISAVING, MIIFTAX, MIINSCODE, MIINSDATE, MIPRIFLAG, MDSTATUS, MAIFXEZF, MIRCODE, MDNO, MDMODEL, MDBRAND, MDCALIBER, CMDCHKPER, MIINSCODECHAR, MIPID) VALUES(V_CRHNO, V_NUMBER + 1, MI.MISMFID, '新用户', '新用户', CI.CIADR, '0', CI.CISTATUSTRANS, '1', CI.CIIDENTITYNO, P_MD.MTDTEL, CI.CITEL1, CI.CITEL2, CI.CITEL3, P_MD.MTDCONPER, P_MD.MTDCONTEL, 'Y', 'N', 'Y', MI.MIADR, MI.MISAFID, MI.MISMFID, MI.MIRTID, MI.MISTID, MI.MIPFID, '1', MI.MISTATUSTRANS, MI.MIRPID, P_MD.MTDSIDEO, P_MD.MTDPOSITIONO, '1', 'Y', 'Y', 'N', 'N', 'X', 'H', MI.MINAME, MI.MINAME2, 1, 'Y', 'N', 'N', 'N', 1, 0, 'N', 0, TRUNC(SYSDATE), 'N', '00', 'N', P_MD.MTDREINSCODE, P_MD.MTDMNOO, P_MD.MTDMODELO, P_MD.MTDBRANDO, P_MD.MTDCALIBERO, P_MD.MTDCHKPER, '00000', P_MD.MTDMPID); V_NUMBER := V_NUMBER + 1; EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
END LOOP;
END IF; ELSIF P_TYPE = BT安装分类计量表 THEN TOOLS.SP_BILLSEQ('100', V_CRHNO);

INSERT INTO CUSTREGHD(CRHNO, CRHBH, CRHLB, CRHSOURCE, CRHSMFID, CRHDEPT, CRHCREDATE, CRHCREPER, CRHSHFLAG) VALUES(V_CRHNO, P_MD.MTDNO, '0', P_TYPE, P_MD.MTDSMFID, NULL, SYSDATE, P_PERSON, 'N');

INSERT INTO CUSTMETERREGDT(CMRDNO, CMRDROWNO, CISMFID, CINAME, CINAME2, CIADR, CISTATUS, CISTATUSTRANS, CIIDENTITYLB, CIIDENTITYNO, CIMTEL, CITEL1, CITEL2, CITEL3, CICONNECTPER, CICONNECTTEL, CIIFINV, CIIFSMS, CIIFZN, MIADR, MISAFID, MISMFID, MIRTID, MISTID, MIPFID, MISTATUS, MISTATUSTRANS, MIRPID, MISIDE, MIPOSITION, MITYPE, MIIFCHARGE, MIIFSL, MIIFCHK, MIIFWATCH, MICHARGETYPE, MILB, MINAME, MINAME2, CICLASS, CIFLAG, MIIFMP, MIIFSP, MIIFCKF, MIUSENUM, MISAVING, MIIFTAX, MIINSCODE, MIINSDATE, MIPRIFLAG, MDSTATUS, MAIFXEZF, MIRCODE, MDNO, MDMODEL, MDBRAND, MDCALIBER, CMDCHKPER, MIINSCODECHAR) VALUES(V_CRHNO, 1, MI.MISMFID, '新用户', '新用户', CI.CIADR, '0', CI.CISTATUSTRANS, '1', CI.CIIDENTITYNO, P_MD.MTDTEL, CI.CITEL1, CI.CITEL2, CI.CITEL3, P_MD.MTDCONPER, P_MD.MTDCONTEL, 'Y', 'N', 'Y', MI.MIADR, MI.MISAFID, MI.MISMFID, MI.MIRTID, MI.MISTID, MI.MIPFID, '1', MI.MISTATUSTRANS, MI.MIRPID, P_MD.MTDSIDEO, P_MD.MTDPOSITIONO, '1', 'Y', 'Y', 'N', 'N', 'X', 'D', MI.MINAME, MI.MINAME2, 1, 'Y', 'N', 'N', 'N', 1, 0, 'N', 0, TRUNC(SYSDATE), 'N', '00', 'N', P_MD.MTDREINSCODE, P_MD.MTDMNOO, P_MD.MTDMODELO, P_MD.MTDBRANDO, P_MD.MTDCALIBERO, P_MD.MTDCHKPER, '00000'); ELSIF P_TYPE = BT水表升移 THEN
-- BS_METERINFO 有效状态 --状态日期 --状态表务
UPDATE BS_METERINFO SET MISTATUS = M立户, MISTATUSDATE = SYSDATE, MISTATUSTRANS = P_TYPE, MIPOSITION = P_MD.MTDPOSITIONN WHERE MIID = P_MD.MTDMID;
-- METERDOC
UPDATE METERDOC SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE WHERE MDMID = P_MD.MTDMID;
--REQUEST_GZHB 回滚换表日期 回滚水表状态
UPDATE REQUEST_GZHB SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE

WHERE MTDMID = MI.MIID;
--备份记录回滚信息
DELETE METERTRANSROLLBACK WHERE MTRBID = P_MD.MTDNO AND MTRBROWNO = P_MD.MTDROWNO;

MK.MTRBID := P_MD.MTDNO; --单据流水
MK.MTRBROWNO := P_MD.MTDROWNO; --行号
MK.MTRBDATE := SYSDATE; --回滚备份日期
MK.MTRBSTATUS := MI.MISTATUS; --状态
MK.MTRBSTATUSDATE := MI.MISTATUSDATE; --状态日期
MK.MTRBSTATUSTRANS := MI.MISTATUSTRANS; --状态表务
MK.MTRBRCODE := MI.MIRCODE; --本期读数
MK.MTRBADR := MI.MIADR; --表地址
MK.MTRBSIDE := MI.MISIDE; --表位
MK.MTRBPOSITION := MI.MIPOSITION; --水表接水地址
MK.MTRBINSCODE := MI.MIINSCODE; --新装起度
MK.MTRBREINSCODE := MI.MIREINSCODE; --换表起度
MK.MTRBREINSDATE := MI.MIREINSDATE; --换表日期
MK.MTRBREINSPER := MI.MIREINSPER; --换表人
MK.MTRBCSTATUS := CI.CISTATUS; --用户状态
MK.MTRBCSTATUSDATE := CI.CISTATUSDATE; --状态日期
MK.MTRBCSTATUSTRANS := CI.CISTATUSTRANS; --状态表务
MK.MTRBNO := MC.MDNO; --表身码
MK.MTRBCALIBER := MC.MDCALIBER; --表口径
MK.MTRBBRAND := MC.MDBRAND; --表厂家
MK.MTRBMODEL := MC.MDMODEL; --表型号
MK.MTRBMSTATUS := MC.MDSTATUS; --表状态
MK.MTRBMSTATUSDATE := MC.MDSTATUSDATE; --表状态发生时间
INSERT INTO METERTRANSROLLBACK VALUES MK;

--记余量表 METERADDSL
--算费
END IF;
--库存管理开关
IF FSYSPARA('sys4') = 'Y' THEN
--更新新表状态
UPDATE ST_METERINFO_STORE SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE WHERE BSM = P_MD.MTDMNON; IF P_TYPE = BT销户拆表 OR P_TYPE = BT报停 OR P_TYPE = BT欠费停水 OR P_TYPE = BT复装 OR P_TYPE = BT换阀门 OR P_TYPE = BT水表整改 THEN
--更新旧表状态
UPDATE ST_METERINFO_STORE SET --STATUS=P_MD.MTBK4 ,
STATUS = '4', STATUSDATE = SYSDATE WHERE BSM = P_MD.MTDMNOO; ELSE
--更新旧表状态
UPDATE ST_METERINFO_STORE SET --STATUS=P_MD.MTBK4 ,
STATUS = '4', STATUSDATE = SYSDATE, MIID = NULL WHERE BSM = P_MD.MTDMNOO;
END IF;
END IF;

--算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
IF FSYSPARA('1102') = 'Y' THEN

IF P_TYPE = BT周期换表 THEN
--余量大于0 进行算费
--20140520 余量算费增加调整水量
--将余量添加抄表库METERREAD
V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm'); SP_INSERTMR(P_PERSON, TO_CHAR(SYSDATE, 'yyyy.mm'), 'L', P_MD.MTDADDSL, P_MD.MTDSCODE, P_MD.MTDECODE, P_MD.MTCARRYSL, MI, V_OMRID); ELSE
--余量大于0 进行算费
--20140520 余量算费增加调整水量
--将余量添加抄表库METERREAD
V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm'); SP_INSERTMR(P_PERSON, TO_CHAR(SYSDATE, 'yyyy.mm'), 'M', P_MD.MTDADDSL, P_MD.MTDSCODE, P_MD.MTDECODE, P_MD.MTCARRYSL, MI, V_OMRID);
END IF;

IF P_MD.MTDADDSL > 0 AND P_MD.MTDADDSL IS
NOT NULL THEN IF V_OMRID IS
NOT NULL THEN
--返回流水不等于空，添加成功

--算费
PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

--将之前余用掉
PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --抄表流水
MA.MASID, --余量流水
O_STR --返回值
);

--更新换表止码
IF P_TYPE IN (BT故障换表, BT周期换表) THEN UPDATE BS_METERINFO SET MIRCODE = P_MD.MTDREINSCODE, --换表起度
MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
WHERE MIID = P_MD.MTDMID;
END IF;

-- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID, TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN DELETE FROM METERREAD WHERE MRID = REC_MR.MRID;
END IF;
END LOOP; INSERT INTO METERREADHIS SELECT * FROM METERREAD WHERE MRID = V_OMRID; DELETE METERREAD WHERE MRID = V_OMRID;
END IF; ELSIF P_MD.MTDADDSL = 0 OR P_MD.MTDADDSL IS
NULL THEN
--20140512 换表后如果当月有未算费的正常抄表记录，则更新起码
IF P_TYPE = BT故障换表 THEN V_MRMEMO := '故障换表重置指针'; ELSIF P_TYPE = BT周期换表 THEN V_MRMEMO := '周期换表重置指针';
END IF;
--更新换表止码
IF P_TYPE IN (BT故障换表, BT周期换表) THEN UPDATE BS_METERINFO SET MIRCODE = P_MD.MTDREINSCODE, --换表起度
MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
WHERE MIID = P_MD.MTDMID;
END IF;

-- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID, TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN DELETE FROM METERREAD WHERE MRID = REC_MR.MRID;
END IF;
END LOOP;

INSERT INTO METERREADHIS SELECT * FROM METERREAD WHERE MRID = V_OMRID; DELETE METERREAD WHERE MRID = V_OMRID;

END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN ROLLBACK; RAISE;
END;
END;
/


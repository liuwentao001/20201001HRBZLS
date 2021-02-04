CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_METERTRANS" IS

  CURRENTDATE  DATE := TOOLS.FGETSYSDATE;
  最低算费水量 NUMBER(10);
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
    IF upper(P_DJLB) ='L' or upper(P_DJLB) ='F' THEN --周期换表、销户拆表 调用批量
        SP_METERTRANS_ZQHB(P_DJLB, P_BILLNO, P_PERSON, 'N');
      --  SP_BILLSUBMIT(P_BILLNO, O_MRID);
       ELSIF P_DJLB = '25' THEN
      SP_METERDZ(P_BILLNO, P_PERSON,'Y'); --等针处理
    ELSE
        SP_METERTRANS(P_DJLB, P_BILLNO, P_PERSON, 'N');
        SP_BILLSUBMIT(P_BILLNO, O_MRID);
     END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END APPROVE;

  --工单主程序
  PROCEDURE SP_METERTRANS(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    
    --byj update 2016.10.21
    IF mh.mthshflag = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;

    /*BEGIN
      SELECT * INTO MD FROM METERTRANSDT WHERE MTDNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '工单信息明细只能有一笔资料,不能无资料或多于一笔资料!');
    END;*/

    --工单信息已经审核不能再审
    /*IF MD.MTDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;*/
    ----
    
    for md in (SELECT * FROM METERTRANSDT WHERE MTDNO = P_MTHNO) loop
        SP_METERTRANSONE(P_TYPE, P_PER, MD);
        IF P_TYPE in('F') THEN
          --旧表状态
          update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
          --销户拆表旧表所有封号作废
          UPDATE ST_METERFH_STORE
               SET FHSTATUS = '2',
                   MAINMAN  = FGETPBOPER,
                   MAINDATE = SYSDATE
             WHERE BSM=MD.MTDMNOO
             AND FHSTATUS = '1';
        END IF;    
        IF P_TYPE in('L','K') THEN
          --旧表状态
          update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
          --故障换表、周期换表旧表所有封号作废
          UPDATE ST_METERFH_STORE
               SET FHSTATUS = '2',
                   MAINMAN  = FGETPBOPER,
                   MAINDATE = SYSDATE
             WHERE BSM=MD.MTDMNOO
             AND FHSTATUS = '1';
          --新表状态
          update st_meterinfo_store set status='3',miid=MD.MTDMCODE WHERE bsm=MD.MTDMNON;
          
          --重置正常表态
          UPDATE METERINFO T
             SET T.MISTATUS  = '1', T.MICOLUMN5  = NULL
           WHERE T.MIID = MD.MTDMID;
          --去掉倒表标志
          UPDATE METERDOC T SET T.IFDZSB = 'N' WHERE T.MDMID = MD.MTDMID;
        END IF;    
        IF P_TYPE = 'A' THEN
           UPDATE METERINFO T
             SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
           WHERE T.MIID = MD.MTDMID;
        END IF;    
    end loop;
             
    UPDATE METERTRANSDT
       SET MTDFLAG = 'Y' /*,MTBK8='Y'*/
     WHERE MTDNO = P_MTHNO;
    UPDATE METERTRANSHD
       SET MTHSHDATE = SYSDATE, MTHSHPER = P_PER, MTHSHFLAG = 'Y'
     WHERE MTHNO = P_MTHNO;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_MTHNO;
    
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

 --工单主程序
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END; 
   --    20140815 工单信息已经审核不能再审 改用表头判断
    IF MH.MTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;
     
  --20140815因周期换表多笔执行时报错，下述针对单笔执行，需取消重新写
/*    BEGIN
      SELECT * INTO MD FROM METERTRANSDT WHERE MTDNO = P_MTHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
    END;  
   --工单信息已经审核不能再审
    IF MD.MTDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;*/
    ----
    for v_cursor in ( SELECT *  FROM METERTRANSDT WHERE MTDNO = P_MTHNO ) loop  
        BEGIN   
          SELECT * 
          into MD 
          FROM METERTRANSDT 
          WHERE MTDNO = P_MTHNO and mtdrowno =v_cursor.Mtdrowno;
        EXCEPTION 
          WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
          END ; 
      SP_METERTRANSONE(P_TYPE, P_PER, MD); 
      ----------------表身码状态改变   
      IF P_TYPE in('F') THEN
        --旧表状态
        update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
        --销户拆表旧表所有封号作废
        UPDATE ST_METERFH_STORE
             SET FHSTATUS = '2',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE BSM=MD.MTDMNOO
           AND FHSTATUS = '1';
      END IF;
      IF P_TYPE in('L','K') THEN
        --旧表状态
        update st_meterinfo_store set status='4',MIID='' where bsm=MD.MTDMNOO;
        --故障换表、周期换表旧表所有封号作废
        UPDATE ST_METERFH_STORE
             SET FHSTATUS = '2',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE BSM=MD.MTDMNOO
           AND FHSTATUS = '1';
        --新表状态
        update st_meterinfo_store set status='3',miid=MD.MTDMCODE WHERE bsm=MD.MTDMNON;
      END IF;
      -----------------
      IF P_TYPE = 'A' THEN
        UPDATE METERINFO T
           SET T.MIIFCHK = 'Y', T.MIIFCHARGE = 'N'
         WHERE T.MIID = MD.MTDMID;
      END IF;
      
      --免抄户、倒装水表 故障换表、周期换表后为正常户
      IF P_TYPE  in('L','K')  THEN
        --重置正常表态
        UPDATE METERINFO T
           SET T.MISTATUS  = '1', T.MICOLUMN5  = NULL
         WHERE T.MIID = MD.MTDMID;
         --去掉倒表标志
         UPDATE METERDOC T SET T.IFDZSB = 'N' WHERE T.MDMID = MD.MTDMID;
      END IF; 
    end loop ;
    
   UPDATE METERTRANSDT
       SET MTDFLAG = 'Y' /*,MTBK8='Y'*/
     WHERE MTDNO = P_MTHNO;
     
    UPDATE METERTRANSHD
       SET MTHSHDATE = SYSDATE, MTHSHPER = P_PER, MTHSHFLAG = 'Y'
     WHERE MTHNO = P_MTHNO;
     
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_MTHNO;
       
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
                             P_MD     IN METERTRANSDT%ROWTYPE --单体行变更
                             ) AS
    MH            METERTRANSHD%ROWTYPE;
    MD            METERTRANSDT%ROWTYPE;
    MI            METERINFO%ROWTYPE;
    CI            CUSTINFO%ROWTYPE;
    MC            METERDOC%ROWTYPE;
    MA            METERADDSL%ROWTYPE;
    MK            METERTRANSROLLBACK%ROWTYPE;
    v_mrmemo       meterread.mrmemo%type;
    V_COUNT       NUMBER(4);
    V_COUNTMRID   NUMBER(4);
    V_COUNTFLAG    NUMBER(4);
    V_NUMBER      NUMBER(10);
    v_rcode       NUMBER(10);
    V_CRHNO       VARCHAR2(10);
    V_OMRID       VARCHAR2(20);
    O_STR         VARCHAR2(20);
    V_METERSTATUS METERSTATUS%ROWTYPE;
    v_meterstore  st_meterinfo_store%rowType;
    
    --未算费抄表记录
    cursor cur_meterread_nocalc(p_mrmid varchar2,p_mrmonth varchar2) is 
      select * from meterread mr where mr.mrmid = p_mrmid and mr.mrmonth = p_mrmonth;
    
  BEGIN
    BEGIN
      SELECT * INTO MI FROM METERINFO WHERE MIID = P_MD.MTDMID;
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
                                MI.MICID||'该水表状态为【' || V_METERSTATUS.SNAME ||
                                '】不能使用！');
      END IF;
    END IF;

    --F销户拆表
    IF P_TYPE = BT销户拆表 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      update METERINFO
         set MISTATUS      = m销户,
             MISTATUSDATE  = sysdate,
             MISTATUSTRANS = P_TYPE,
             MIUNINSDATE   = sysdate,
             MIBFID = NULL   -- by 20170904 wlj 销户拆表将表册置空
       where MIID = P_MD.Mtdmid;

       --销户后同步用户状态
        UPDATE CUSTINFO
           SET CISTATUS = m销户,
           cistatusdate = sysdate,
           cistatustrans = P_TYPE
         WHERE CICODE = P_MD.Mtdmid;

      ---销户拆表收取余量水费（在去掉低度之前）
      --step1 插入抄表记录

      --step2  插入应收记录

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
      update METERDOC
         set MDSTATUS = m销户, MDSTATUSDATE = sysdate
       where MDMID = P_MD.Mtdmid;
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

      ---- METERINFO 有效状态 --状态日期 --状态表务 【yujia 20110323】
      /*UPDATE METERINFO
        SET MISTATUS      = M销户,
            MISTATUSDATE  = SYSDATE,
            MISTATUSTRANS = P_TYPE,
            MIUNINSDATE   = SYSDATE,
            MISEQNO       = '',
            MIBFID        = NULL
      WHERE MIID = P_MD.MTDMID;*/
      UPDATE ST_METERINFO_STORE
         SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNOO;
      -----METERDOC  表状态 表状态发生时间  【yujia 20110323】

      UPDATE METERDOC
         SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;



    ELSIF P_TYPE = BT口径变更 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
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
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
      --
    ELSIF P_TYPE = BT欠费停水 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
         SET MISTATUS      = M欠费停水,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
    ELSIF P_TYPE = BT恢复供水 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
    ELSIF P_TYPE = BT报停 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
         SET MISTATUS      = M报停,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE
       WHERE MIID = P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
         SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
      --
    ELSIF P_TYPE = BT校表 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE METERINFO
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
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
      UPDATE METERINFO
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
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.MTDMNON, --表身号
             MDCALIBER    = P_MD.MTDCALIBERN, --表口径
             MDBRAND      = P_MD.MTDBRANDN, --表厂家
             MDMODEL      = P_MD.MTDMODELN, --表型号
             MDCYCCHKDATE = P_MD.MTDREINSDATE
       WHERE MDMID = P_MD.MTDMID;

      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
        and MR.mrreadok ='Y' --已抄表
        AND MR.MRIFREC <> 'Y'; --未算费
     IF V_COUNTFLAG > 0 THEN  --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
           RAISE_APPLICATION_ERROR(ERRCODE,'【' || p_md.mtdmid || '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
     end if ;

     update meterread t set MRSCODE=P_MD.MTDREINSCODE   --by ralph 20151021  增加的将未抄见指针更换掉
     where mrmid=P_MD.MTDMID AND mrreadok='N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
     t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/;

     --add 20141117 hb
     --如果故障换表为9月份开立故障换表单据一直未审核，10月份如果又有抄表算费，则不允许进行审核9月份的故障换表
     --因这样会造成初始指针错误
     /*  select  count(a.MTHNO)
       INTO V_COUNTFLAG
      FROM "METERTRANSHD" a, "METERTRANSDT" b, "METERINFO" C
     WHERE a.MTHNO = b.MTdNO
      AND B.MTDMID = C.MIID
      and a.MTHSHFLAG <> 'Y'
      and a.mthlb = 'K'
      and b.MTdNO=P_MD.MTdNO --单据号
      and (c.MICID =P_MD.MTDMID )   --客户代码
    --  and  c.mircode > b.mtdreinscode  --起始指针 大于
      AND ( a.mthcredate  < (   select max(mrday)
     from view_meterreadall
    where mrmid = c.MICID
      and mrreadok = 'Y' )   ) ;
   IF V_COUNTFLAG > 0 THEN  --
           RAISE_APPLICATION_ERROR(ERRCODE, '【' || p_md.mtdmid || '】此水表已经抄表录入时间在此工单故障换表之后,不能进行故障换表审核,需删除此工单再重新建立此工单,以免造成起始指针错误!');
     end if ;*/

  ------水表量程校验与更新 zf  20160828
          if p_md.mtdmiyl9 is not null then
         /*SELECT nvl(mrecode,mircode)
           INTO v_rcode
           FROM meterinfo
           left join ( select mrecode,mrmcode from  METERREAD MR
                       WHERE MR.MRMID = P_MD.MTDMID
                             and MR.mrreadok ='Y' --已抄表
                             AND MR.MRIFREC <> 'Y'--未算费
                      ) on micode=mrmcode
           where micode=P_MD.MTDMID;

         IF v_rcode > p_md.mtdmiyl9 THEN  --检查水表量程是否合理，不能小于当前水表读数
               RAISE_APPLICATION_ERROR(ERRCODE, '此水表当前读数已超过该工单中设置的最大量程，请检查!');
         else*/   ---新表量程 不用跟旧表比较了

         UPDATE METERINFO
         SET miyl9      = p_md.mtdmiyl9  --水表最大量程
          WHERE MIID = P_MD.MTDMID;
        --- end if ;
       end if;
 ----------------------------20160828

     --end add 20141117 hb

     --20140809 总分表故障换表 modiby hb
     --总表先换表、分表出账导致水量不够减，换表后不出账

     -- end 20140809 总分表故障换表 modiby hb
      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M立户, --状态
             MISTATUSDATE  = SYSDATE, --状态日期
             MISTATUSTRANS = P_TYPE, --状态表务
             MIRCODE       = P_MD.MTDREINSCODE, --换表起度
             --MIQFH         = P_MD.MTDQFHN,
             --MIADR         = P_MD.MTDMADRN,--水表地址
             --MISIDE        = P_MD.MTDSIDEN,--表位
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
             MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER  = P_MD.MTDREINSPER,  --换表人
             MIYL1 = 'N',                      --换表后将 等针标志清除(如果有) byj 2016.08
             MIRTID = p_md.mtdmirtid          --换表后 根据工单更新 抄表方式! byj 2016.12 
       WHERE MIID = P_MD.MTDMID;

      --换表后清除等针中间表标志 byj 2016.08-------------
       update metertgl mtg
          set mtg.mtstatus = 'N'
        where mtmid = p_md.MTDMID and
              mtstatus = 'Y';
      ---------------------------------------------------

      --METERDOC 更新新表信息 
      begin
        select * into v_meterstore from st_meterinfo_store st where st.bsm = p_md.MTDMNON and rownum < 2 ;
        UPDATE METERDOC
           SET MDSTATUS     = M立户,          --状态
               MDSTATUSDATE = SYSDATE,        --表状态发生时间
               MDNO         = P_MD.MTDMNON,   --表身号
               DQSFH        = P_MD.MTDDQSFHN, --塑封号
               DQGFH        = P_MD.MTDLFHN,   --钢封号
               QFH          = P_MD.MTDQFHN ,  --铅封号
               MDCALIBER    = v_meterstore.caliber, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家    
               MDCYCCHKDATE = P_MD.MTDREINSDATE, --
               MDMODEL      = v_meterstore.model --表型号
         WHERE MDMID = P_MD.MTDMID;    
      exception
        when others then
          UPDATE METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --表状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               DQSFH        = P_MD.MTDDQSFHN, --塑封号
               DQGFH  =  P_MD.MTDLFHN,--钢封号
               QFH          = P_MD.MTDQFHN ,--铅封号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;   
      end;
       
       
       
       

      --设置塑封号为已使用
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
         and STOREID =mi.mismfid   --地区
         and CALIBER=  P_MD.mtdcalibero  --口径
         AND FHTYPE ='1';
      END IF;
      --设置钢封号为已使用
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
           and STOREID =mi.mismfid  --地区
          AND FHTYPE ='2';
      END IF;
        --设置铅封号为已使用
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
           and STOREID =mi.mismfid  --地区
          AND FHTYPE ='4';
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
                                '该水表状态为【' || V_METERSTATUS.SNAME ||
                                '】不能使用！');
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
    ELSIF P_TYPE = BT水表整改 THEN
      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M立户, --状态
             MISTATUSDATE  = SYSDATE, --状态日期
             MISTATUSTRANS = P_TYPE, --状态表务
             --MIADR         = P_MD.MTDMADRN,--水表地址
             --MISIDE        = P_MD.MTDSIDEN,--表位
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
             MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER  = P_MD.MTDREINSPER --换表人
       WHERE MIID = P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --表状态发生时间
             MDNO         = P_MD.MTDMNON, --表身号
             MDCALIBER    = P_MD.MTDCALIBERN, --表口径
             MDBRAND      = P_MD.MTDBRANDN, --表厂家
             MDMODEL      = P_MD.MTDMODELN, --表型号
             MDCYCCHKDATE = P_MD.MTDREINSDATE --
       WHERE MDMID = P_MD.MTDMID;
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
    ELSIF P_TYPE = BT周期换表 THEN
/*      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M立户, --状态
             MISTATUSDATE  = SYSDATE, --状态日期
             MISTATUSTRANS = P_TYPE, --状态表务
             MIRCODE       = P_MD.MTDREINSCODE, --新表起数
             --MIADR         = P_MD.MTDMADRN,--水表地址
             --MISIDE        = P_MD.MTDSIDEN,--表位
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
             MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER  = P_MD.MTDREINSPER --换表人
       WHERE MIID = P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --表状态发生时间
             MDNO         = P_MD.MTDMNON, --表身号
             DQSFH        = P_MD.MTDDQSFHN, --塑封号
             --LFH          = P_MD.MTDLFHN, --锁封号（就是钢封号）
             DQGFH  =  P_MD.MTDLFHN,--钢封号
             QFH          = P_MD.MTDQFHN ,--铅封号
             MDCALIBER    = P_MD.MTDCALIBERN, --表口径
             MDBRAND      = P_MD.MTDBRANDN, --表厂家
             MDMODEL      = P_MD.MTDMODELN, --表型号
             MDCYCCHKDATE = P_MD.MTDREINSDATE --
       WHERE MDMID = P_MD.MTDMID;

            --设置塑封号为已使用
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
          AND FHTYPE ='1';
      END IF;
      --设置钢封号为已使用
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
          AND FHTYPE ='2';
      END IF;
        --设置铅封号为已使用
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
          AND FHTYPE ='4';
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
                                '该水表状态为【' || V_METERSTATUS.SNAME ||
                                '】不能使用！');
      END IF;
      IF TRIM(V_METERSTATUS.SID) = '2' THEN
        UPDATE ST_METERINFO_STORE
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        UPDATE ST_METERINFO_STORE
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      END IF;
    */
    --以上为之前周期换表代码 modiby hb 20140815
    --下述为故障换表的代码放过来，原理与故障换表原理一致

           SELECT COUNT(*)
       INTO V_COUNTFLAG
       FROM METERREAD MR
      WHERE MR.MRMID = P_MD.MTDMID
        and MR.mrreadok ='Y' --已抄表
        AND MR.MRIFREC <> 'Y'; --未算费
     IF V_COUNTFLAG > 0 THEN  --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
           RAISE_APPLICATION_ERROR(ERRCODE, '此水表['|| P_MD.MTDMID||']已经抄表录入,抄见标志有打上,不能进行周期换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
     end if ;

    ------水表量程校验与更新 zf  20160828
          if p_md.mtdmiyl9 is not null then
        /* SELECT nvl(mrecode,mircode)
           INTO v_rcode
           FROM meterinfo
           left join ( select mrecode,mrmcode from  METERREAD MR
                       WHERE MR.MRMID = P_MD.MTDMID
                             and MR.mrreadok ='Y' --已抄表
                             AND MR.MRIFREC <> 'Y'--未算费
                      ) on micode=mrmcode
           where micode=P_MD.MTDMID;

         IF v_rcode > p_md.mtdmiyl9 THEN  --检查水表量程是否合理，不能小于当前水表读数
               RAISE_APPLICATION_ERROR(ERRCODE, '此水表当前读数已超过该工单中设置的最大量程，请检查!');
         else*/
         UPDATE METERINFO
         SET miyl9      = p_md.mtdmiyl9  --水表最大量程
          WHERE MIID = P_MD.MTDMID;
       ---  end if ;
       end if;
       ----------------------------20160828

     --20140809 总分表故障换表 modiby hb
     --总表先换表、分表出账导致水量不够减，换表后不出账

     -- end 20140809 总分表故障换表 modiby hb
      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
         SET MISTATUS      = M立户, --状态
             MISTATUSDATE  = SYSDATE, --状态日期
             MISTATUSTRANS = P_TYPE, --状态表务
             MIRCODE       = P_MD.MTDREINSCODE, --换表起度
             --MIQFH         = P_MD.MTDQFHN,
             --MIADR         = P_MD.MTDMADRN,--水表地址
             --MISIDE        = P_MD.MTDSIDEN,--表位
             --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
             MIREINSCODE = P_MD.MTDREINSCODE, --换表起度
             MIREINSDATE = P_MD.MTDREINSDATE, --换表日期
             MIREINSPER  = P_MD.MTDREINSPER,  --换表人
             MIYL1 = 'N',                     --换表后将 等针标志清除(如果有) byj 2016.08
             MIRTID = p_md.mtdmirtid          --换表后 根据工单更新 抄表方式! byj 2016.12 
       WHERE MIID = P_MD.MTDMID;

      --换表后清除等针中间表标志 byj 2016.08-------------
       update metertgl mtg
          set mtg.mtstatus = 'N'
        where mtmid = p_md.MTDMID and
              mtstatus = 'Y';
      ---------------------------------------------------

      --METERDOC 更新新表信息 
      begin
        select * into v_meterstore from st_meterinfo_store st where st.bsm = p_md.MTDMNON and rownum < 2 ;
        UPDATE METERDOC
           SET MDSTATUS     = M立户,          --状态
               MDSTATUSDATE = SYSDATE,        --表状态发生时间
               MDNO         = P_MD.MTDMNON,   --表身号
               DQSFH        = P_MD.MTDDQSFHN, --塑封号
               DQGFH        = P_MD.MTDLFHN,   --钢封号
               QFH          = P_MD.MTDQFHN ,  --铅封号
               MDCALIBER    = v_meterstore.caliber, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家    
               MDCYCCHKDATE = P_MD.MTDREINSDATE, --
               MDMODEL      = v_meterstore.model --表型号
         WHERE MDMID = P_MD.MTDMID;    
      exception
        when others then
          UPDATE METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --表状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               DQSFH        = P_MD.MTDDQSFHN, --塑封号
               DQGFH  =  P_MD.MTDLFHN,--钢封号
               QFH          = P_MD.MTDQFHN ,--铅封号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;   
      end;
 

      --设置塑封号为已使用
      IF P_MD.MTDDQSFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDDQSFHN
         and STOREID =mi.mismfid   --地区
         and CALIBER=  P_MD.mtdcalibero  --口径
         AND FHTYPE ='1';
      END IF;
      --设置钢封号为已使用
      IF P_MD.MTDLFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDLFHN
           and STOREID =mi.mismfid  --地区
          AND FHTYPE ='2';
      END IF;
        --设置铅封号为已使用
      IF P_MD.MTDQFHN IS NOT NULL THEN
        UPDATE ST_METERFH_STORE
           SET BSM      = P_MD.MTDMNON,
               FHSTATUS = '1',
               MAINMAN  = FGETPBOPER,
               MAINDATE = SYSDATE
         WHERE METERFH = P_MD.MTDQFHN
           and STOREID =mi.mismfid  --地区
          AND FHTYPE ='4';
      END IF;

     --【抄表审核转单】周期换表后回写复核标志
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
                                MI.MICID||'该水表状态为【' || V_METERSTATUS.SNAME ||
                                '】不能使用！');
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
    ELSIF P_TYPE = BT复查工单 THEN
      NULL;
    ELSIF P_TYPE = BT改装总表 THEN
      IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);
        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        V_NUMBER := 0;
        LOOP
          INSERT INTO CUSTMETERREGDT
            (CMRDNO,
             CMRDROWNO,
             CISMFID,
             CINAME,
             CINAME2,
             CIADR,
             CISTATUS,
             CISTATUSTRANS,
             CIIDENTITYLB,
             CIIDENTITYNO,
             CIMTEL,
             CITEL1,
             CITEL2,
             CITEL3,
             CICONNECTPER,
             CICONNECTTEL,
             CIIFINV,
             CIIFSMS,
             CIIFZN,
             MIADR,
             MISAFID,
             MISMFID,
             MIRTID,
             MISTID,
             MIPFID,
             MISTATUS,
             MISTATUSTRANS,
             MIRPID,
             MISIDE,
             MIPOSITION,
             MITYPE,
             MIIFCHARGE,
             MIIFSL,
             MIIFCHK,
             MIIFWATCH,
             MICHARGETYPE,
             MILB,
             MINAME,
             MINAME2,
             CICLASS,
             CIFLAG,
             MIIFMP,
             MIIFSP,
             MIIFCKF,
             MIUSENUM,
             MISAVING,
             MIIFTAX,
             MIINSCODE,
             MIINSDATE,
             MIPRIFLAG,
             MDSTATUS,
             MAIFXEZF,
             MIRCODE,
             MDNO,
             MDMODEL,
             MDBRAND,
             MDCALIBER,
             CMDCHKPER,
             MIINSCODECHAR,
             MIPID)
          VALUES
            (V_CRHNO,
             V_NUMBER + 1,
             MI.MISMFID,
             '新用户',
             '新用户',
             CI.CIADR,
             '0',
             CI.CISTATUSTRANS,
             '1',
             CI.CIIDENTITYNO,
             P_MD.MTDTEL,
             CI.CITEL1,
             CI.CITEL2,
             CI.CITEL3,
             P_MD.MTDCONPER,
             P_MD.MTDCONTEL,
             'Y',
             'N',
             'Y',
             MI.MIADR,
             MI.MISAFID,
             MI.MISMFID,
             MI.MIRTID,
             MI.MISTID,
             MI.MIPFID,
             '1',
             MI.MISTATUSTRANS,
             MI.MIRPID,
             P_MD.MTDSIDEO,
             P_MD.MTDPOSITIONO,
             '1',
             'Y',
             'Y',
             'N',
             'N',
             'X',
             'H',
             MI.MINAME,
             MI.MINAME2,
             1,
             'Y',
             'N',
             'N',
             'N',
             1,
             0,
             'N',
             0,
             TRUNC(SYSDATE),
             'N',
             '00',
             'N',
             P_MD.MTDREINSCODE,
             P_MD.MTDMNOO,
             P_MD.MTDMODELO,
             P_MD.MTDBRANDO,
             P_MD.MTDCALIBERO,
             P_MD.MTDCHKPER,
             '00000',
             P_MD.MTDMCODE);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;
    ELSIF P_TYPE = BT补装户表 THEN
      IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);
        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        V_NUMBER := 0;
        LOOP
          INSERT INTO CUSTMETERREGDT
            (CMRDNO,
             CMRDROWNO,
             CISMFID,
             CINAME,
             CINAME2,
             CIADR,
             CISTATUS,
             CISTATUSTRANS,
             CIIDENTITYLB,
             CIIDENTITYNO,
             CIMTEL,
             CITEL1,
             CITEL2,
             CITEL3,
             CICONNECTPER,
             CICONNECTTEL,
             CIIFINV,
             CIIFSMS,
             CIIFZN,
             MIADR,
             MISAFID,
             MISMFID,
             MIRTID,
             MISTID,
             MIPFID,
             MISTATUS,
             MISTATUSTRANS,
             MIRPID,
             MISIDE,
             MIPOSITION,
             MITYPE,
             MIIFCHARGE,
             MIIFSL,
             MIIFCHK,
             MIIFWATCH,
             MICHARGETYPE,
             MILB,
             MINAME,
             MINAME2,
             CICLASS,
             CIFLAG,
             MIIFMP,
             MIIFSP,
             MIIFCKF,
             MIUSENUM,
             MISAVING,
             MIIFTAX,
             MIINSCODE,
             MIINSDATE,
             MIPRIFLAG,
             MDSTATUS,
             MAIFXEZF,
             MIRCODE,
             MDNO,
             MDMODEL,
             MDBRAND,
             MDCALIBER,
             CMDCHKPER,
             MIINSCODECHAR,
             MIPID)
          VALUES
            (V_CRHNO,
             V_NUMBER + 1,
             MI.MISMFID,
             '新用户',
             '新用户',
             CI.CIADR,
             '0',
             CI.CISTATUSTRANS,
             '1',
             CI.CIIDENTITYNO,
             P_MD.MTDTEL,
             CI.CITEL1,
             CI.CITEL2,
             CI.CITEL3,
             P_MD.MTDCONPER,
             P_MD.MTDCONTEL,
             'Y',
             'N',
             'Y',
             MI.MIADR,
             MI.MISAFID,
             MI.MISMFID,
             MI.MIRTID,
             MI.MISTID,
             MI.MIPFID,
             '1',
             MI.MISTATUSTRANS,
             MI.MIRPID,
             P_MD.MTDSIDEO,
             P_MD.MTDPOSITIONO,
             '1',
             'Y',
             'Y',
             'N',
             'N',
             'X',
             'H',
             MI.MINAME,
             MI.MINAME2,
             1,
             'Y',
             'N',
             'N',
             'N',
             1,
             0,
             'N',
             0,
             TRUNC(SYSDATE),
             'N',
             '00',
             'N',
             P_MD.MTDREINSCODE,
             P_MD.MTDMNOO,
             P_MD.MTDMODELO,
             P_MD.MTDBRANDO,
             P_MD.MTDCALIBERO,
             P_MD.MTDCHKPER,
             '00000',
             P_MD.MTDMPID);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;
    ELSIF P_TYPE = BT安装分类计量表 THEN
      TOOLS.SP_BILLSEQ('100', V_CRHNO);

      INSERT INTO CUSTREGHD
        (CRHNO,
         CRHBH,
         CRHLB,
         CRHSOURCE,
         CRHSMFID,
         CRHDEPT,
         CRHCREDATE,
         CRHCREPER,
         CRHSHFLAG)
      VALUES
        (V_CRHNO,
         P_MD.MTDNO,
         '0',
         P_TYPE,
         P_MD.MTDSMFID,
         NULL,
         SYSDATE,
         P_PERSON,
         'N');

      INSERT INTO CUSTMETERREGDT
        (CMRDNO,
         CMRDROWNO,
         CISMFID,
         CINAME,
         CINAME2,
         CIADR,
         CISTATUS,
         CISTATUSTRANS,
         CIIDENTITYLB,
         CIIDENTITYNO,
         CIMTEL,
         CITEL1,
         CITEL2,
         CITEL3,
         CICONNECTPER,
         CICONNECTTEL,
         CIIFINV,
         CIIFSMS,
         CIIFZN,
         MIADR,
         MISAFID,
         MISMFID,
         MIRTID,
         MISTID,
         MIPFID,
         MISTATUS,
         MISTATUSTRANS,
         MIRPID,
         MISIDE,
         MIPOSITION,
         MITYPE,
         MIIFCHARGE,
         MIIFSL,
         MIIFCHK,
         MIIFWATCH,
         MICHARGETYPE,
         MILB,
         MINAME,
         MINAME2,
         CICLASS,
         CIFLAG,
         MIIFMP,
         MIIFSP,
         MIIFCKF,
         MIUSENUM,
         MISAVING,
         MIIFTAX,
         MIINSCODE,
         MIINSDATE,
         MIPRIFLAG,
         MDSTATUS,
         MAIFXEZF,
         MIRCODE,
         MDNO,
         MDMODEL,
         MDBRAND,
         MDCALIBER,
         CMDCHKPER,
         MIINSCODECHAR)
      VALUES
        (V_CRHNO,
         1,
         MI.MISMFID,
         '新用户',
         '新用户',
         CI.CIADR,
         '0',
         CI.CISTATUSTRANS,
         '1',
         CI.CIIDENTITYNO,
         P_MD.MTDTEL,
         CI.CITEL1,
         CI.CITEL2,
         CI.CITEL3,
         P_MD.MTDCONPER,
         P_MD.MTDCONTEL,
         'Y',
         'N',
         'Y',
         MI.MIADR,
         MI.MISAFID,
         MI.MISMFID,
         MI.MIRTID,
         MI.MISTID,
         MI.MIPFID,
         '1',
         MI.MISTATUSTRANS,
         MI.MIRPID,
         P_MD.MTDSIDEO,
         P_MD.MTDPOSITIONO,
         '1',
         'Y',
         'Y',
         'N',
         'N',
         'X',
         'D',
         MI.MINAME,
         MI.MINAME2,
         1,
         'Y',
         'N',
         'N',
         'N',
         1,
         0,
         'N',
         0,
         TRUNC(SYSDATE),
         'N',
         '00',
         'N',
         P_MD.MTDREINSCODE,
         P_MD.MTDMNOO,
         P_MD.MTDMODELO,
         P_MD.MTDBRANDO,
         P_MD.MTDCALIBERO,
         P_MD.MTDCHKPER,
         '00000');
    ELSIF P_TYPE = BT水表升移 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO
         SET MISTATUS      = M立户,
             MISTATUSDATE  = SYSDATE,
             MISTATUSTRANS = P_TYPE,
             MIPOSITION    = P_MD.MTDPOSITIONN
       WHERE MIID = P_MD.MTDMID;
      -- meterdoc
      UPDATE METERDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       WHERE MDMID = P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
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
      --算费
    END IF;
    --库存管理开关
    IF FSYSPARA('sys4') = 'Y' THEN
      --更新新表状态
      UPDATE ST_METERINFO_STORE
         SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
       WHERE BSM = P_MD.MTDMNON;
      IF P_TYPE = BT销户拆表 OR P_TYPE = BT报停 OR P_TYPE = BT欠费停水 OR
         P_TYPE = BT复装 OR P_TYPE = BT换阀门 OR P_TYPE = BT水表整改 THEN
        --更新旧表状态
        UPDATE ST_METERINFO_STORE
           SET --STATUS=P_MD.MTBK4 ,
                  STATUS = '4',
               STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;
      ELSE
        --更新旧表状态
        UPDATE ST_METERINFO_STORE
           SET --STATUS=P_MD.MTBK4 ,
                  STATUS = '4',
               STATUSDATE = SYSDATE,
               MIID       = NULL
         WHERE BSM = P_MD.MTDMNOO;
      END IF;
    END IF;


    --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
    IF FSYSPARA('1102') = 'Y' THEN
      --    IF P_MD.MTDADDSL >= 最低算费水量 AND P_MD.MTDADDSL IS NOT NULL THEN
/*      IF P_MD.MTDADDSL >= 0 AND P_MD.MTDADDSL IS NOT NULL THEN*/   --20140506

        if P_TYPE = BT周期换表 then
            --余量大于0 进行算费
        --20140520 余量算费增加调整水量
        --将余量添加抄表库meterread
        V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
        SP_INSERTMR(P_PERSON,
                    TO_CHAR(SYSDATE, 'yyyy.mm'),
                    'L',
                    P_MD.MTDADDSL,
                    P_MD.MTDSCODE,
                    P_MD.MTDECODE,
                    P_MD.MTCARRYSL,
                    MI,
                    V_OMRID);
        else
        --余量大于0 进行算费
        --20140520 余量算费增加调整水量
        --将余量添加抄表库meterread
        V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
        SP_INSERTMR(P_PERSON,
                    TO_CHAR(SYSDATE, 'yyyy.mm'),
                    'M',
                    P_MD.MTDADDSL,
                    P_MD.MTDSCODE,
                    P_MD.MTDECODE,
                    P_MD.MTCARRYSL,
                    MI,
                    V_OMRID);
       end if ;
          
       IF P_MD.MTDADDSL > 0 AND P_MD.MTDADDSL IS NOT NULL THEN
          IF V_OMRID IS NOT NULL THEN
              --返回流水不等于空，添加成功

              --算费
              PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

              --将之前余用掉
              PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --抄表流水
                                                  MA.MASID, --余量流水
                                                  O_STR --返回值
                                                  );

              --更新换表止码
              if p_type in (BT故障换表, BT周期换表) then
                update meterinfo
                   set mircode     = p_md.mtdreinscode, --换表起度
                       mircodechar = to_char(p_md.mtdreinscode) --换表起度char
                 where miid = p_md.mtdmid;
              end if;

             -- modify 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
             for rec_mr in cur_meterread_nocalc(P_MD.Mtdmid,TOOLS.FGETREADMONTH(MI.MISMFID)) loop
                if rec_mr.mrifrec = 'N' and rec_mr.mrdatasource in ('1','5') then
                   delete from meterread where mrid = rec_mr.mrid;
                end if;
             end loop;
                
             

             INSERT INTO METERREADHIS
                  SELECT * FROM METERREAD WHERE MRID = V_OMRID;
             DELETE METERREAD WHERE MRID = V_OMRID;
         END IF;
      elsif P_MD.MTDADDSL = 0  or  P_MD.MTDADDSL IS   NULL then
           --20140512 换表后如果当月有未算费的正常抄表记录，则更新起码
        IF P_TYPE = BT故障换表 THEN
           v_mrmemo :='故障换表重置指针';
        elsif  P_TYPE = BT周期换表 THEN
            v_mrmemo :='周期换表重置指针';
        end if ;
                --更新换表止码
        if p_type in (BT故障换表, BT周期换表) then
          update meterinfo
             set mircode     = p_md.mtdreinscode, --换表起度
                 mircodechar = to_char(p_md.mtdreinscode) --换表起度char
           where miid = p_md.mtdmid;
        end if;
        
        -- modify 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
         for rec_mr in cur_meterread_nocalc(P_MD.Mtdmid,TOOLS.FGETREADMONTH(MI.MISMFID)) loop
            if rec_mr.mrifrec = 'N' and rec_mr.mrdatasource in ('1','5') then
               delete from meterread where mrid = rec_mr.mrid;
            end if;
         end loop;
        
 
        INSERT INTO METERREADHIS
        SELECT * FROM METERREAD WHERE MRID = V_OMRID;
         DELETE METERREAD WHERE MRID = V_OMRID;

      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
 

  --工单派工
  PROCEDURE SP_METEROUT(P_BILLID IN VARCHAR2, --单据流水
                        P_DEPT   IN VARCHAR2, --派工部门
                        P_OPER   IN VARCHAR2, --操作员
                        P_MAN    IN VARCHAR2 --施工员
                        ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
      SELECT * INTO MT FROM METERTRANSDT WHERE MTDNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 工单不存在！');
    END;
    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'W', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT
       SET MTDFLAG     = 'W',
           MTDSENTDEPT = P_DEPT,
           MTDSENTDATE = SYSDATE,
           MTDSENTPER  = P_OPER,
           MTDUNINSPER = P_MAN,
           MTDREINSPER = P_MAN
     WHERE MTDNO = P_BILLID;
    IF MH.MTHLB = BT水表升移 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M升移中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT水表升移
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT销户拆表 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M销户中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT销户拆表,
             MIBFID          = NULL
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT口径变更 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M口径变更中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT口径变更
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT欠费停水 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M欠费停水中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT欠费停水
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT报停 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M报停中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT报停
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT复装 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M复装中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT复装
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT校表 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M校表中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT校表
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT故障换表 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M故障换表中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT故障换表
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT周期换表 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M周检换表中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT周期换表
       WHERE T.MIID = MT.MTDMID;
    ELSIF MH.MTHLB = BT复查工单 THEN
      UPDATE METERINFO T
         SET T.MISTATUS      = M复查中,
             T.MISTATUSDATE  = SYSDATE,
             T.MISTATUSTRANS = BT复查工单
       WHERE T.MIID = MT.MTDMID;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --工单作废
  PROCEDURE SP_METERZF(P_BILLID IN VARCHAR2, --单据流水
                       P_OPER   IN VARCHAR2 --操作员
                       ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
      SELECT * INTO MT FROM METERTRANSDT WHERE MTDNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 工单不存在！');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'Q', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'Q' WHERE MTDNO = P_BILLID;
    UPDATE METERINFO
       SET MISTATUS = NVL(MT.MTDMSTATUSO, M立户)
     WHERE MIID = MT.MTDMID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --工单待解决
  PROCEDURE SP_METERWAITER(P_BILLID IN VARCHAR2, --单据流水
                           P_OPER   IN VARCHAR2 --操作员
                           ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 工单不存在！');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'D', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'D' WHERE MTDNO = P_BILLID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --工单已解决
  PROCEDURE SP_METEROK(P_BILLID IN VARCHAR2, --单据流水
                       P_OPER   IN VARCHAR2 --操作员
                       ) AS
    MT METERTRANSDT%ROWTYPE;
    MH METERTRANSHD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_BILLID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, P_BILLID || '->1 工单不存在！');
    END;

    UPDATE METERTRANSHD
       SET MTHSHFLAG = 'Z', MTHSHDATE = SYSDATE, MTHSHPER = P_OPER
     WHERE MTHNO = P_BILLID;
    INSERT INTO METERTRANSSTATES
      (MTSNO, MTSSHDATE, MTSSHFLAG, MTSSHPER, MTSCREDATE)
      SELECT MTHNO, MTHSHDATE, MTHSHFLAG, MTHSHPER, MTHCREDATE
        FROM METERTRANSHD
       WHERE MTHNO = P_BILLID;
    UPDATE METERTRANSDT SET MTDFLAG = 'Z' WHERE MTDNO = P_BILLID;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  
   --等针处理
PROCEDURE SP_METERDZ(P_BILLID IN VARCHAR2, --单据流水
                     P_OPER   IN VARCHAR2, --操作员
                     P_COMMIT IN VARCHAR2 --提交标志
                     ) AS
  CURSOR C_MD(VNO IN METERTGLDT.MTDNO%TYPE) IS
    SELECT * FROM METERTGLDT WHERE MTDNO = VNO ORDER BY MTDROWNO;
  MH METERTGLHD%ROWTYPE;
  MD METERTGLDT%ROWTYPE;
  MT METERTGL%ROWTYPE;
BEGIN
  BEGIN
    SELECT * INTO MH FROM METERTGLHD WHERE MTHNO = P_BILLID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
  END;

  --工单信息已经审核不能再审
  IF MH.MTHSHFLAG = 'Y' THEN
    RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
  END IF;

  --取出单体明细行
  MD := NULL;
  OPEN C_MD(MH.MTHNO);
  LOOP
    FETCH C_MD
      INTO MD;
    EXIT WHEN C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL;
      --处理历史记录，每个用户只能有一笔有效的等针记录
      BEGIN
        UPDATE METERTGL SET MTSTATUS = 'N' WHERE MTMID = MD.MTDMID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    MT := NULL;
    SELECT SYS_GUID() INTO MT.MTSID FROM DUAL; --序号
    MT.MTMID      := MD.MTDMID; --用户号
    MT.MTSYSCODE  := MD.MTDSYSCODE; --系统读数（等针，维护时的系统指针）
    MT.MTREALCODE := MD.MTDREALCODE; --实际读数
    MT.MTCURCODE  := MT.MTREALCODE; --当前读数（初始化为实际读数，每次抄表时更新）
    MT.MTTGL      := MD.MTDTGL; --推估量（=系统读数-实际读数）
    MT.MTSTATUS   := 'Y'; --有效标志（当等针结束即当前读数大于等于系统读数时置为N）
    MT.MTBILLNO   := MD.MTDNO; --单据流水
    MT.MTSCRPER   := P_OPER; --创建人员
    MT.MTSCRDATE  := SYSDATE; --创建时间
    INSERT INTO METERTGL VALUES MT;
      --更新meterinfo 的等针标志
      UPDATE METERINFO SET MIYL1 ='Y' WHERE MIID=MD.MTDMID;
  END LOOP;
  
    UPDATE METERTGLHD
       SET MTHSHFLAG = 'Y', mthshper = P_OPER, mthshdate = SYSDATE
     WHERE MTHNO = P_BILLID;
  CLOSE C_MD;

  IF P_COMMIT = 'Y' THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF C_MD%ISOPEN THEN
      CLOSE C_MD;
    END IF;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;


  --抄表计划批量生成故障换表工单
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID   IN VARCHAR2,
                            P_TYPE   IN VARCHAR2,
                            P_SOURCE IN VARCHAR2,
                            P_SMFID  IN VARCHAR2,
                            P_DEPT   IN VARCHAR2,
                            P_OPER   IN VARCHAR2,
                            P_FLAG   IN VARCHAR2) IS
    CURSOR C_EXIST IS
      SELECT *
        FROM METERTRANSHD
       WHERE MTHNO IN
             (SELECT MTDNO
                FROM METERTRANSDT
               WHERE MTDMID =
                     (SELECT MRMID FROM METERREAD WHERE MRID = P_MRID))
         AND MTHSHFLAG NOT IN ('Q', 'Y')
         AND MTHLB = P_TYPE
         FOR UPDATE;

    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MR       METERREAD%ROWTYPE;
    CI       CUSTINFO%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    MD       METERDOC%ROWTYPE;
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    IF P_FLAG = '0' THEN
      --取消
      UPDATE METERREAD SET MRFACE = NULL WHERE MRID = P_MRID;
    ELSE
      --生成工单(重复工单设置加急值，否则生成工单)
      BEGIN
        SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '抄表计划不存在!');
      END;
      BEGIN
        SELECT * INTO CI FROM CUSTINFO WHERE CIID = MR.MRCID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '客户信息不存在!');
      END;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = MR.MRMID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表信息信息不存在!');
      END;
      BEGIN
        SELECT * INTO MD FROM METERDOC WHERE METERDOC.MDMID = MR.MRMID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表档案信息信息不存在!');
      END;
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;

      --标记抄表计划转单标志
      UPDATE METERREAD SET MRIFTRANS = 'Y' WHERE MRID = P_MRID;

      OPEN C_EXIST;
      FETCH C_EXIST
        INTO MH;
      IF C_EXIST%NOTFOUND OR C_EXIST%NOTFOUND IS NULL THEN
        --生成工单
        TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

        MH.MTHNO      := V_ID; --单据流水号
        MH.MTHBH      := MH.MTHNO; --单据编号
        MH.MTHLB      := P_TYPE; --单据类别
        MH.MTHSOURCE  := P_SOURCE; --单据来源
        MH.MTHSMFID   := P_SMFID; --营销公司
        MH.MTHDEPT    := P_DEPT; --受理部门
        MH.MTHCREDATE := SYSDATE; --受理日期
        MH.MTHCREPER  := P_OPER; --受理人员
        MH.MTHSHFLAG  := 'N'; --审核标志
        MH.MTHSHDATE  := NULL; --审核日期
        MH.MTHSHPER   := NULL; --审核人员
        MH.MTHHOT     := 1;
        MH.MTHMRID    := P_MRID;
        INSERT INTO METERTRANSHD VALUES MH;

        MT.MTDNO         := MH.MTHNO; --单据流水
        MT.MTDROWNO      := 1; --行号
        MT.MTDSMFID      := MI.MISMFID; --营业所
        MT.MTDREQUDATE   := SYSDATE + 7; --要求完成时间
        MT.MTDTEL        := CI.CIMTEL; --电话
        MT.MTDCONPER     := CI.CINAME; --联系人
        MT.MTDCONTEL     := SUBSTR(CI.CIMTEL || ' ' || CI.CITEL1 || ' ' ||
                                   CI.CITEL2 || ' ' || CI.CICONNECTTEL,
                                   90); --联系电话
        MT.MTDSHDATE     := NULL; --完工录入日期
        MT.MTDSHPER      := NULL; --完工录入人员
        MT.MTDSENTDEPT   := NULL; --派工部门
        MT.MTDSENTDATE   := NULL; --派工时间
        MT.MTDSENTPER    := NULL; --派工人员
        MT.MTDFLAG       := 'N'; --完工标志（N创建S派工Y完工X作废）
        MT.MTDCHKPER     := NULL; --验收收人
        MT.MTDCHKDATE    := NULL; --验收日期
        MT.MTDCHKMEMO    := NULL; --验收结果
        MT.MTDMID        := MI.MIID; --原水表编号
        MT.MTDMCODE      := MI.MICODE; --原资料号
        MT.MTDMDIDO      := MD.MDID; --原表档案号
        MT.MTDMDIDN      := MD.MDID; --新表档案号
        MT.MTDCNAME      := CI.CINAME; --原用户名
        MT.MTDMADRO      := MI.MIADR; --原水表地址
        MT.MTDCALIBERO   := MD.MDCALIBER; --原表口径
        MT.MTDBRANDO     := MD.MDBRAND; --原表厂家
        MT.MTDMODELO     := MD.MDMODEL; --原表型号
        MT.MTDMNON       := MD.MDNO; --新表身号
        MT.MTDCALIBERN   := NULL; --新表口径
        MT.MTDBRANDN     := NULL; --新表厂家
        MT.MTDMODELN     := NULL; --新表型号
        MT.MTDPOSITIONO  := MI.MIPOSITION; --原表位描述
        MT.MTDSIDEO      := MI.MISIDE; --原表位
        MT.MTDMNOO       := MD.MDNO; --原表身号
        MT.MTDMADRN      := NULL; --新表
        MT.MTDPOSITIONN  := NULL; --新表
        MT.MTDSIDEN      := NULL; --新表
        MT.MTDUNINSPER   := NULL; --拆表员
        MT.MTDUNINSDATE  := NULL; --拆表日期
        MT.MTDSCODE      := MR.MRECODE; --上期读数
        MT.MTDSCODECHAR  := MR.MRECODECHAR;
        MT.MTDECODE      := NULL; --拆表底数
        MT.MTDADDSL      := NULL; --余量
        MT.MTDREINSPER   := NULL; --换表员
        MT.MTDREINSDATE  := NULL; --换表日期
        MT.MTDREINSCODE  := NULL; --新表起数
        MT.MTDREINSDATEO := NULL; --回滚换表日期
        MT.MTDMSTATUSO   := MI.MISTATUS; --回滚水表状态
        MT.MTDAPPNOTE    := NULL; --申请说明
        MT.MTDFILASHNOTE := NULL; --领导意见
        MT.MTDMEMO       := '抄见故障表转单'; --备注
        MT.MTDYCCHKDATE  := MD.MDCYCCHKDATE;
        MT.MTFACE1       := MR.MRFACE; --水表故障
        MT.MTFACE2       := MR.MRFACE2; --抄见故障
        MT.MIFACE4       := MR.MRFACE4; --表井故障
        INSERT INTO METERTRANSDT VALUES MT;
      END IF;
      WHILE C_EXIST%FOUND LOOP
        UPDATE METERTRANSHD
           SET MTHHOT = NVL(MTHHOT, 0) + 1
         WHERE CURRENT OF C_EXIST;
        FETCH C_EXIST
          INTO MH;
      END LOOP;
      CLOSE C_EXIST;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_EXIST%ISOPEN THEN
        CLOSE C_EXIST;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_MRMRIFSUBMIT;

  --催收管理批量生成欠费工单
  PROCEDURE SP_CRERECBILL(P_MID    IN VARCHAR2,
                          P_TYPE   IN VARCHAR2,
                          P_SOURCE IN VARCHAR2,
                          P_SMFID  IN VARCHAR2,
                          P_DEPT   IN VARCHAR2,
                          P_OPER   IN VARCHAR2,
                          P_FLAG   IN VARCHAR2) IS
    CURSOR C_EXIST IS
      SELECT *
        FROM METERTRANSHD
       WHERE MTHNO IN (SELECT MTDNO FROM METERTRANSDT WHERE MTDMID = P_MID)
         AND MTHSHFLAG NOT IN ('Q', 'Y')
         AND MTHLB = P_TYPE
         FOR UPDATE;

    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MR       METERREAD%ROWTYPE;
    CI       CUSTINFO%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    MD       METERDOC%ROWTYPE;
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    IF P_FLAG = '0' THEN
      --取消
      NULL;
    ELSE
      --生成工单(重复工单设置加急值，否则生成工单)
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = P_MID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表信息信息不存在!');
      END;
      BEGIN
        SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '客户信息不存在!');
      END;
      BEGIN
        SELECT * INTO MD FROM METERDOC WHERE METERDOC.MDMID = P_MID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表档案信息信息不存在!');
      END;
      BEGIN
        SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
      END;

      OPEN C_EXIST;
      FETCH C_EXIST
        INTO MH;
      IF C_EXIST%NOTFOUND OR C_EXIST%NOTFOUND IS NULL THEN
        --生成工单
        TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

        MH.MTHNO      := V_ID; --单据流水号
        MH.MTHBH      := MH.MTHNO; --单据编号
        MH.MTHLB      := P_TYPE; --单据类别
        MH.MTHSOURCE  := P_SOURCE; --单据来源
        MH.MTHSMFID   := P_SMFID; --营销公司
        MH.MTHDEPT    := P_DEPT; --受理部门
        MH.MTHCREDATE := SYSDATE; --受理日期
        MH.MTHCREPER  := P_OPER; --受理人员
        MH.MTHSHFLAG  := 'N'; --审核标志
        MH.MTHSHDATE  := NULL; --审核日期
        MH.MTHSHPER   := NULL; --审核人员
        MH.MTHHOT     := 1;
        MH.MTHMRID    := NULL;
        INSERT INTO METERTRANSHD VALUES MH;

        MT.MTDNO         := MH.MTHNO; --单据流水
        MT.MTDROWNO      := 1; --行号
        MT.MTDSMFID      := MI.MISMFID; --营业所
        MT.MTDREQUDATE   := SYSDATE + 7; --要求完成时间
        MT.MTDTEL        := CI.CIMTEL; --电话
        MT.MTDCONPER     := CI.CINAME; --联系人
        MT.MTDCONTEL     := CI.CICONNECTTEL; --联系电话
        MT.MTDSHDATE     := NULL; --完工录入日期
        MT.MTDSHPER      := NULL; --完工录入人员
        MT.MTDSENTDEPT   := NULL; --派工部门
        MT.MTDSENTDATE   := NULL; --派工时间
        MT.MTDSENTPER    := NULL; --派工人员
        MT.MTDFLAG       := 'N'; --完工标志（N创建S派工Y完工X作废）
        MT.MTDCHKPER     := NULL; --验收收人
        MT.MTDCHKDATE    := NULL; --验收日期
        MT.MTDCHKMEMO    := NULL; --验收结果
        MT.MTDMID        := MI.MIID; --原水表编号
        MT.MTDMCODE      := MI.MICODE; --原资料号
        MT.MTDMDIDO      := MD.MDID; --原表档案号
        MT.MTDMDIDN      := MD.MDID; --新表档案号
        MT.MTDCNAME      := CI.CINAME; --原用户名
        MT.MTDMADRO      := MI.MIADR; --原水表地址
        MT.MTDCALIBERO   := MD.MDCALIBER; --原表口径
        MT.MTDBRANDO     := MD.MDBRAND; --原表厂家
        MT.MTDMODELO     := MD.MDMODEL; --原表型号
        MT.MTDMNON       := MD.MDNO; --新表身号
        MT.MTDCALIBERN   := NULL; --新表口径
        MT.MTDBRANDN     := NULL; --新表厂家
        MT.MTDMODELN     := NULL; --新表型号
        MT.MTDPOSITIONO  := NULL; --原表位描述
        MT.MTDSIDEO      := NULL; --原表位
        MT.MTDMNOO       := MD.MDNO; --原表身号
        MT.MTDMADRN      := NULL; --新表
        MT.MTDPOSITIONN  := NULL; --新表
        MT.MTDSIDEN      := NULL; --新表
        MT.MTDUNINSPER   := NULL; --拆表员
        MT.MTDUNINSDATE  := NULL; --拆表日期
        MT.MTDSCODE      := MR.MRECODE; --上期读数
        MT.MTDSCODECHAR  := MR.MRECODECHAR;
        MT.MTDECODE      := NULL; --拆表底数
        MT.MTDADDSL      := NULL; --余量
        MT.MTDREINSPER   := NULL; --换表员
        MT.MTDREINSDATE  := NULL; --换表日期
        MT.MTDREINSCODE  := NULL; --新表起数
        MT.MTDREINSDATEO := NULL; --回滚换表日期
        MT.MTDMSTATUSO   := NULL; --回滚水表状态
        MT.MTDAPPNOTE    := NULL; --申请说明
        MT.MTDFILASHNOTE := NULL; --领导意见
        MT.MTDMEMO       := '催收转单'; --备注
        INSERT INTO METERTRANSDT VALUES MT;
      END IF;
      WHILE C_EXIST%FOUND LOOP
        UPDATE METERTRANSHD
           SET MTHHOT = NVL(MTHHOT, 0) + 1
         WHERE CURRENT OF C_EXIST;
        FETCH C_EXIST
          INTO MH;
      END LOOP;
      CLOSE C_EXIST;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_EXIST%ISOPEN THEN
        CLOSE C_EXIST;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_CRERECBILL;

  --抄表计划批量生成故障换表工单
  PROCEDURE SP_BUILDZJBILL(P_NUM    IN VARCHAR2, --水表数
                           P_TYPE   IN VARCHAR2, --单据类型
                           P_SOURCE IN VARCHAR2, --单据来源
                           P_SMFID  IN VARCHAR2, --营业所
                           P_DEPT   IN VARCHAR2, --部门
                           P_OPER   IN VARCHAR2) IS
    --操作人
    /*  cursor c_exist is
    select * from metertranshd
    where mthno in (select mtdno from metertransdt
                   where mtdmid=(select mrmid from meterread where mrid=p_mrid)
                   ) and
          mthshflag not in ('Q','Y') and mthlb=p_type
    for update;*/
    ROWCNT   INT;
    N        NUMBER;
    V_BILLID VARCHAR2(10);
    V_ID     VARCHAR2(10);
    MH       METERTRANSHD%ROWTYPE;
    MT       METERTRANSDT%ROWTYPE;
  BEGIN
    /*begin
      select * into ci from custinfo where ciid=mr.mrcid;
    exception when others then
      raise_application_error(errcode, '客户信息不存在!');
    end;
    begin
      select * into mi from meterinfo where miid=mr.mrmid;
    exception when others then
      raise_application_error(errcode, '水表信息信息不存在!');
    end;
    begin
      select * into md from meterdoc where meterdoc.mdmid =mr.mrmid;
    exception when others then
      raise_application_error(errcode, '水表档案信息信息不存在!');
    end;*/
    BEGIN
      SELECT BMID INTO V_BILLID FROM BILLMAIN WHERE BMTYPE = P_TYPE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '此种类型单据未定义!');
    END;

    --标记抄表计划转单标志

    SELECT COUNT(*)
      INTO N
      FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
     WHERE MIID = MDMID
       AND BFID = MIBFID
       AND MISMFID = BFSMFID
       AND CIID = MICID
       AND MIID IN (SELECT C1 FROM PBPARMTEMP);
    IF P_NUM <> N THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单生成失败!' || SQLERRM);
    END IF;
    FOR CMMB IN (SELECT *
                   FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
                  WHERE MIID = MDMID
                    AND BFID = MIBFID
                    AND MISMFID = BFSMFID
                    AND CIID = MICID
                    AND MIID IN (SELECT C1 FROM PBPARMTEMP)) LOOP
      --生成工单
      TOOLS.SP_BILLSEQ(V_BILLID, V_ID, 'N');

      MH.MTHNO      := V_ID; --单据流水号
      MH.MTHBH      := MH.MTHNO; --单据编号
      MH.MTHLB      := P_TYPE; --单据类别
      MH.MTHSOURCE  := P_SOURCE; --单据来源
      MH.MTHSMFID   := P_SMFID; --营销公司
      MH.MTHDEPT    := P_DEPT; --受理部门
      MH.MTHCREDATE := SYSDATE; --受理日期
      MH.MTHCREPER  := P_OPER; --受理人员
      MH.MTHSHFLAG  := 'N'; --审核标志
      MH.MTHSHDATE  := NULL; --审核日期
      MH.MTHSHPER   := NULL; --审核人员
      MH.MTHHOT     := 1;
      MH.MTHMRID    := NULL;
      INSERT INTO METERTRANSHD VALUES MH;

      MT.MTDNO         := MH.MTHNO; --单据流水
      MT.MTDROWNO      := 1; --行号
      MT.MTDSMFID      := CMMB.MISMFID; --营业所
      MT.MTDREQUDATE   := SYSDATE + 7; --要求完成时间
      MT.MTDTEL        := CMMB.CITEL1; --电话
      MT.MTDCONPER     := CMMB.CINAME; --联系人
      MT.MTDCONTEL     := CMMB.CICONNECTTEL; --联系电话
      MT.MTDSHDATE     := NULL; --完工录入日期
      MT.MTDSHPER      := NULL; --完工录入人员
      MT.MTDSENTDEPT   := NULL; --派工部门
      MT.MTDSENTDATE   := NULL; --派工时间
      MT.MTDSENTPER    := NULL; --派工人员
      MT.MTDFLAG       := 'N'; --完工标志（N创建S派工Y完工X作废）
      MT.MTDCHKPER     := NULL; --验收收人
      MT.MTDCHKDATE    := NULL; --验收日期
      MT.MTDCHKMEMO    := NULL; --验收结果
      MT.MTDMID        := CMMB.MIID; --原水表编号
      MT.MTDMCODE      := CMMB.MICODE; --原资料号
      MT.MTDMDIDO      := CMMB.MDID; --原表档案号
      MT.MTDMDIDN      := CMMB.MDID; --新表档案号
      MT.MTDCNAME      := CMMB.CINAME; --原用户名
      MT.MTDMADRO      := CMMB.MIADR; --原水表地址
      MT.MTDCALIBERO   := CMMB.MDCALIBER; --原表口径
      MT.MTDBRANDO     := CMMB.MDBRAND; --原表厂家
      MT.MTDMTYPEO     := CMMB.MITYPE;
      MT.MTDMODELO     := CMMB.MDMODEL;
      MT.MTDMNON       := CMMB.MDNO; --新表身号
      MT.MTDCALIBERN   := NULL; --新表口径
      MT.MTDBRANDN     := NULL; --新表厂家
      MT.MTDMODELN     := NULL; --新表型号
      MT.MTDPOSITIONO  := CMMB.MIPOSITION; --原接水地址
      MT.MTDSIDEO      := CMMB.MISIDE; --原表位
      MT.MTDMNOO       := CMMB.MDNO; --原表身号
      MT.MTDMADRN      := NULL; --新表
      MT.MTDPOSITIONN  := NULL; --新表
      MT.MTDSIDEN      := NULL; --新表
      MT.MTDUNINSPER   := NULL; --拆表员
      MT.MTDUNINSDATE  := NULL; --拆表日期
      MT.MTDSCODE      := CMMB.MIRCODE; --上期读数
      MT.MTDSCODECHAR  := CMMB.MIRCODECHAR;
      MT.MTDECODE      := NULL; --拆表底数
      MT.MTDADDSL      := NULL; --余量
      MT.MTDREINSPER   := NULL; --换表员
      MT.MTDREINSDATE  := NULL; --换表日期
      MT.MTDREINSCODE  := NULL; --新表起数
      MT.MTDREINSDATEO := NULL; --回滚换表日期
      MT.MTDMSTATUSO   := NULL; --回滚水表状态
      MT.MTDAPPNOTE    := NULL; --申请说明
      MT.MTDFILASHNOTE := NULL; --领导意见
      MT.MTDMEMO       := '周检换表批量生成'; --备注
      MT.MTFACE1       := CMMB.MIFACE; --水表故障
      MT.MTFACE2       := CMMB.MIFACE2; --抄见故障
      MT.MIFACE4       := CMMB.MIFACE4; --表井故障
      INSERT INTO METERTRANSDT VALUES MT;
      ROWCNT := SQL%ROWCOUNT;
      IF ROWCNT < 1 THEN
        RAISE_APPLICATION_ERROR(-20010, '单据生成失败!' || SQLERRM);
      END IF;
    END LOOP;

    COMMIT;
    /*      while c_exist%found loop
      update metertranshd set mthhot=nvl(mthhot,0)+1 where current of c_exist;
      fetch c_exist into mh;
    end loop;
    close c_exist;*/
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_BUILDZJBILL;

  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        P_CARRYSL    IN NUMBER, --调整水量
                        MI        IN METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT METERREAD.MRID%TYPE --抄表流水
                        ) AS
    MR METERREAD%ROWTYPE; --抄表库
    CI    CUSTINFO%ROWTYPE; --用户信息
  BEGIN
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, '用户不存在!');
    END;

    MR.MRID    := FGETSEQUENCE('METERREAD'); --流水号
    OMRID         := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
    MR.MRBFID  := MI.MIBFID /*rth.RTHBFID*/
     ; --表册
    BEGIN
      SELECT BFBATCH
        INTO MR.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRBATCH := 1; --抄表批次
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MR.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MR.MRMONTH
         AND MRBBATCH = MR.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRDAY := SYSDATE; --计划抄表日
      /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
            raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
      end if;*/
    END;
    MR.MRDAY       := SYSDATE; --计划抄表日
    MR.MRRORDER    := MI.MIRORDER; --抄表次序
    MR.MRCID       := CI.CIID; --用户编号
    MR.MRCCODE     := CI.CICODE; --用户号
    MR.MRMID       := MI.MIID; --水表编号
    MR.MRMCODE     := MI.MICODE; --水表手工编号
    MR.MRSTID      := MI.MISTID; --行业分类
    MR.MRMPID      := MI.MIPID; --上级水表
    MR.MRMCLASS    := MI.MICLASS; --水表级次
    MR.MRMFLAG     := MI.MIFLAG; --末级标志
    MR.MRCREADATE  := SYSDATE; --创建日期
    MR.MRINPUTDATE := SYSDATE; --编辑日期
    MR.MRREADOK    := 'Y'; --抄见标志
    MR.MRRDATE     := SYSDATE /*TO_DATE(p_month||'.15','YYYY.MM.DD') */
     ; --抄表日期
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := P_PPER; --预留 空抄表员
    END;
    MR.MRPRDATE        := NULL; --上次抄见日期
    MR.MRSCODE         := P_SCODE; --上期抄见
    MR.MRECODE         := P_ECODE; --本期抄见
    MR.MRSL            := P_RLSL-NVL(P_CARRYSL,0); --本期水量
    MR.MRFACE          := NULL; --水表故障
    MR.MRIFSUBMIT      := 'Y'; --是否提交计费
    MR.MRIFHALT        := 'N'; --系统停算
    MR.MRDATASOURCE    := P_MRTRANS; --抄表结果来源：表务抄表 L-周期换表
    MR.MRIFIGNOREMINSL := 'N'; --停算最低抄量
    MR.MRPDARDATE      := NULL; --抄表机抄表时间
    MR.MROUTFLAG       := 'N'; --发出到抄表机标志
    MR.MROUTID         := NULL; --发出到抄表机流水号
    MR.MROUTDATE       := NULL; --发出到抄表机日期
    MR.MRINORDER       := NULL; --抄表机接收次序
    MR.MRINDATE        := NULL; --抄表机接受日期
    MR.MRRPID          := NULL; --计件类型
    if P_MRTRANS='L' THEN
          MR.MRMEMO          := '周期换表余量欠费'; --抄表备注
    ELSE 
         MR.MRMEMO          := '换表余量欠费'; --抄表备注
    END IF ;
    MR.MRIFGU          := 'N'; --估表标志
    MR.MRIFREC         := 'N'; --已计费
    MR.MRRECDATE       := SYSDATE; --计费日期
    MR.MRRECSL         := P_RLSL-NVL(P_CARRYSL,0); --应收水量
   --  MR.MRADDSL         := 0; --余量 
   --add 20140809 故障换表时，总表余量写入余量列，如果本月有出账时，则抓取此余量判断
    if P_MRTRANS='M' and MI.Miclass ='2' THEN  
        MR.MRADDSL  :=  P_RLSL; --余量
    ELSE
       MR.MRADDSL         := 0; --余量
    END IF ;
    MR.MRCARRYSL       := NVL(P_CARRYSL,0); --进位水量
    MR.MRCTRL1         := NULL; --抄表机控制位1
    MR.MRCTRL2         := NULL; --抄表机控制位2
    MR.MRCTRL3         := NULL; --抄表机控制位3
    MR.MRCTRL4         := NULL; --抄表机控制位4
    MR.MRCTRL5         := NULL; --抄表机控制位5
    MR.MRCHKFLAG       := 'N'; --复核标志
    MR.MRCHKDATE       := NULL; --复核日期
    MR.MRCHKPER        := NULL; --复核人员
    MR.MRCHKSCODE      := NULL; --原起数
    MR.MRCHKECODE      := NULL; --原止数
    MR.MRCHKSL         := NULL; --原水量
    MR.MRCHKADDSL      := NULL; --原余量
    MR.MRCHKCARRYSL    := NULL; --原进位水量
    MR.MRCHKRDATE      := NULL; --原抄见日期
    MR.MRCHKFACE       := NULL; --原表况
    MR.MRCHKRESULT     := NULL; --检查结果类型
    MR.MRCHKRESULTMEMO := NULL; --检查结果说明
    MR.MRPRIMID        := MI.MIPRIID; --合收表主表
    MR.MRPRIMFLAG      := MI.MIPRIFLAG; --合收表标志
    MR.MRLB            := MI.MILB; --水表类别
    MR.MRNEWFLAG       := NULL; --新表标志
    MR.MRFACE2         := NULL; --抄见故障
    MR.MRFACE3         := NULL; --非常计量
    MR.MRFACE4         := NULL; --表井设施说明
    MR.MRSCODECHAR     := TO_CHAR(P_SCODE); --上期抄见
    MR.MRECODECHAR     := TO_CHAR(P_ECODE); --本期抄见
    MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --特权操作人
    MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
    MR.MRPRIVILEGEDATE := NULL; --特权操作时间
    MR.MRSAFID         := MI.MISAFID; --管理区域
    MR.MRIFTRANS       := 'N'; --抄表事务
    MR.MRREQUISITION   := 0; --通知单打印次数
    MR.MRIFCHK         := MI.MIIFCHK; --考核表
    INSERT INTO METERREAD VALUES MR;
  END;
  
  PROCEDURE SP_INSERTMRHIS(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        P_CARRYSL    IN NUMBER, --调整水量
                        MI        IN METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT METERREADHIS.MRID%TYPE --抄表流水
                        ) AS
    MRHIS METERREADHIS%ROWTYPE; --抄表历史库
    CI    CUSTINFO%ROWTYPE; --用户信息
  BEGIN
    BEGIN
      SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, '用户不存在!');
    END;

    MRHIS.MRID    := FGETSEQUENCE('METERREAD'); --流水号
    OMRID         := MRHIS.MRID;
    MRHIS.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
    MRHIS.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
    MRHIS.MRBFID  := MI.MIBFID /*rth.RTHBFID*/
     ; --表册
    BEGIN
      SELECT BFBATCH
        INTO MRHIS.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRBATCH := 1; --抄表批次
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MRHIS.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MRHIS.MRMONTH
         AND MRBBATCH = MRHIS.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRDAY := SYSDATE; --计划抄表日
      /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
            raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
      end if;*/
    END;
    MRHIS.MRDAY       := SYSDATE; --计划抄表日
    MRHIS.MRRORDER    := MI.MIRORDER; --抄表次序
    MRHIS.MRCID       := CI.CIID; --用户编号
    MRHIS.MRCCODE     := CI.CICODE; --用户号
    MRHIS.MRMID       := MI.MIID; --水表编号
    MRHIS.MRMCODE     := MI.MICODE; --水表手工编号
    MRHIS.MRSTID      := MI.MISTID; --行业分类
    MRHIS.MRMPID      := MI.MIPID; --上级水表
    MRHIS.MRMCLASS    := MI.MICLASS; --水表级次
    MRHIS.MRMFLAG     := MI.MIFLAG; --末级标志
    MRHIS.MRCREADATE  := SYSDATE; --创建日期
    MRHIS.MRINPUTDATE := SYSDATE; --编辑日期
    MRHIS.MRREADOK    := 'Y'; --抄见标志
    MRHIS.MRRDATE     := SYSDATE /*TO_DATE(p_month||'.15','YYYY.MM.DD') */
     ; --抄表日期
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MRHIS.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRRPER := P_PPER; --预留 空抄表员
    END;
    MRHIS.MRPRDATE        := NULL; --上次抄见日期
    MRHIS.MRSCODE         := P_SCODE; --上期抄见
    MRHIS.MRECODE         := P_ECODE; --本期抄见
    MRHIS.MRSL            := P_RLSL-NVL(P_CARRYSL,0); --本期水量
    MRHIS.MRFACE          := NULL; --水表故障
    MRHIS.MRIFSUBMIT      := 'Y'; --是否提交计费
    MRHIS.MRIFHALT        := 'N'; --系统停算
    MRHIS.MRDATASOURCE    := P_MRTRANS; --抄表结果来源：表务抄表
    MRHIS.MRIFIGNOREMINSL := 'N'; --停算最低抄量
    MRHIS.MRPDARDATE      := NULL; --抄表机抄表时间
    MRHIS.MROUTFLAG       := 'N'; --发出到抄表机标志
    MRHIS.MROUTID         := NULL; --发出到抄表机流水号
    MRHIS.MROUTDATE       := NULL; --发出到抄表机日期
    MRHIS.MRINORDER       := NULL; --抄表机接收次序
    MRHIS.MRINDATE        := NULL; --抄表机接受日期
    MRHIS.MRRPID          := NULL; --计件类型
    MRHIS.MRMEMO          := '换表余量欠费'; --抄表备注
    MRHIS.MRIFGU          := 'N'; --估表标志
    MRHIS.MRIFREC         := 'N'; --已计费
    MRHIS.MRRECDATE       := SYSDATE; --计费日期
    MRHIS.MRRECSL         := P_RLSL-NVL(P_CARRYSL,0); --应收水量
    MRHIS.MRADDSL         := 0; --余量
    MRHIS.MRCARRYSL       := NVL(P_CARRYSL,0); --进位水量
    MRHIS.MRCTRL1         := NULL; --抄表机控制位1
    MRHIS.MRCTRL2         := NULL; --抄表机控制位2
    MRHIS.MRCTRL3         := NULL; --抄表机控制位3
    MRHIS.MRCTRL4         := NULL; --抄表机控制位4
    MRHIS.MRCTRL5         := NULL; --抄表机控制位5
    MRHIS.MRCHKFLAG       := 'N'; --复核标志
    MRHIS.MRCHKDATE       := NULL; --复核日期
    MRHIS.MRCHKPER        := NULL; --复核人员
    MRHIS.MRCHKSCODE      := NULL; --原起数
    MRHIS.MRCHKECODE      := NULL; --原止数
    MRHIS.MRCHKSL         := NULL; --原水量
    MRHIS.MRCHKADDSL      := NULL; --原余量
    MRHIS.MRCHKCARRYSL    := NULL; --原进位水量
    MRHIS.MRCHKRDATE      := NULL; --原抄见日期
    MRHIS.MRCHKFACE       := NULL; --原表况
    MRHIS.MRCHKRESULT     := NULL; --检查结果类型
    MRHIS.MRCHKRESULTMEMO := NULL; --检查结果说明
    MRHIS.MRPRIMID        := MI.MIPRIID; --合收表主表
    MRHIS.MRPRIMFLAG      := MI.MIPRIFLAG; --合收表标志
    MRHIS.MRLB            := MI.MILB; --水表类别
    MRHIS.MRNEWFLAG       := NULL; --新表标志
    MRHIS.MRFACE2         := NULL; --抄见故障
    MRHIS.MRFACE3         := NULL; --非常计量
    MRHIS.MRFACE4         := NULL; --表井设施说明
    MRHIS.MRSCODECHAR     := TO_CHAR(P_SCODE); --上期抄见
    MRHIS.MRECODECHAR     := TO_CHAR(P_ECODE); --本期抄见
    MRHIS.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
    MRHIS.MRPRIVILEGEPER  := NULL; --特权操作人
    MRHIS.MRPRIVILEGEMEMO := NULL; --特权操作备注
    MRHIS.MRPRIVILEGEDATE := NULL; --特权操作时间
    MRHIS.MRSAFID         := MI.MISAFID; --管理区域
    MRHIS.MRIFTRANS       := 'N'; --抄表事务
    MRHIS.MRREQUISITION   := 0; --通知单打印次数
    MRHIS.MRIFCHK         := MI.MIIFCHK; --考核表
    INSERT INTO METERREADHIS VALUES MRHIS;
  END;
 
  
BEGIN
  最低算费水量 := TO_NUMBER(FSYSPARA('1092'));
END;
/


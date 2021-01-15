CREATE OR REPLACE PACKAGE BODY PG_METERTRANS IS

  --周期换表、拆表、故障换表
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --操作类型
                            P_MTHNO  IN VARCHAR2, --批次流水
                            P_PER    IN VARCHAR2, --操作员
                            P_COMMIT IN VARCHAR2 --提交标志
                            ) AS
    MF REQUEST_CB%ROWTYPE;
    MK REQUEST_GZHB%ROWTYPE;
    ML REQUEST_ZQGZ%ROWTYPE;
  BEGIN
    IF P_TYPE IN ('L') THEN
      --周期换表
      BEGIN
        SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '周期换表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = ML.MDNO;
        /*        --现用表状态更新,去掉倒表标志
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE,
               IFDZSB   = 'N'
         WHERE MDNO = ML.MDNO;*/
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = ML.MDNO;
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = ML.MDNO
           AND FHSTATUS = '1';
        --新表状态、水表档案号更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = ML.MIID
         WHERE MDNO = ML.NEWMDNO;
        --故障换表后为正常户
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = ML.MIID;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_ZQGZ
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             REFLAG       = 'Y',
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('F') THEN
      --拆表
      BEGIN
        SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_CB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '拆表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MF.MDNO;
        /*        UPDATE BS_METERDOC
          SET MDSTATUS = '0',
              MDID     = '',
              MAINMAN  = P_PER,
              MAINDATE = SYSDATE
        WHERE MDNO = MF.MDNO;*/
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = MF.MDNO;
        --更新户表信息为作废
        --暂未确定 等待确定
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '拆表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE A.MIID = MF.MIID;
        /*        UPDATE BS_METERINFO T
          SET T.MISTATUS = '40' --, T.MICOLUMN5 = NULL
        WHERE T.MIID = MF.MIID;*/
        --正事表中删除旧户表
        DELETE FROM BS_METERINFO A WHERE A.MIID = MF.MIID;
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MF.MDNO
           AND FHSTATUS = '1';
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_CB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             REFLAG       = 'Y',
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      --故障换表
      BEGIN
        SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;
    
      FOR V_CURSOR IN (SELECT * FROM REQUEST_GZHB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '故障换表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MK.MDNO;
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = MK.MDNO;
        /*        --现用表状态更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MK.MDNO;*/
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MK.MDNO
           AND FHSTATUS = '1';
        --新表状态、水表档案号更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = MK.MIID
         WHERE MDNO = MK.NEWMDNO;
        --重置正常表态
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MK.MIID;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_GZHB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             REFLAG       = 'Y',
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --撤表销户简单的销户操作 不考虑财务
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --批次流水
                                 I_PER   IN VARCHAR2, --操作员
                                 O_STATE OUT NUMBER) IS
    --执行状态
    MX     REQUEST_XH%ROWTYPE;
    V_LINA VARCHAR2(30);
    V_LINB VARCHAR2(100);
  BEGIN
    O_STATE := 0;
    SELECT * INTO MX FROM REQUEST_XH WHERE RENO = I_RENO;
    FOR I IN (SELECT * FROM BS_METERINFO A WHERE A.MICODE = MX.CIID) LOOP
      V_LINA := SYS_GUID();
      SELECT MDNO INTO V_LINB FROM BS_METERDOC WHERE MDID = I.MIID;
      INSERT INTO REQUEST_CB
        (RENO, MDNO, MIID)
        SELECT V_LINA, V_LINB, I.MIID FROM DUAL;
      PG_METERTRANS.SP_CHEBIAOTRANS('F', V_LINA, I_PER, 'Y');
      DELETE FROM REQUEST_CB WHERE RENO = V_LINA;
    END LOOP;
    --0.插入历史记录
    INSERT INTO BS_METERINFO_HIS
      SELECT A.*, '销户' GDLX, I_RENO GDID, SYSDATE GDSJ
        FROM BS_METERINFO A
       WHERE MICODE = MX.CIID;
    --1.更新METERINFO主表状态
    UPDATE BS_METERINFO
       SET MISTATUS      = '7', --销户状态
           MISTATUSDATE  = SYSDATE,
           MISTATUSTRANS = '0',
           MIUNINSDATE   = SYSDATE
     WHERE MICODE = MX.CIID;
    --2.销户后同步用户状态
    UPDATE BS_CUSTINFO
       SET CISTATUS = '7', CISTATUSDATE = SYSDATE, CISTATUSTRANS = '0'
     WHERE CIID = MX.CIID;
    --3.更新工单完成状态
    UPDATE REQUEST_XH
       SET MODIFYDATE   = SYSDATE,
           MODIFYUSERID = I_PER,
           REFLAG       = 'Y',
           MTDFLAG      = 'Y'
     WHERE RENO = I_RENO;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  /*  --工单单个审核过程
    PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                               P_PERSON IN VARCHAR2, -- 操作员
                               P_MD     IN REQUEST_GZHB%ROWTYPE --单体行变更
                               ) AS
      MH REQUEST_GZHB%ROWTYPE;
      MD REQUEST_GZHB%ROWTYPE;
      MI BS_METERINFO%ROWTYPE;
      CI BS_CUSTINFO%ROWTYPE;
      MC BS_METERDOC%ROWTYPE;
      MA BS_METERREAD%ROWTYPE;
    
      V_MRMEMO     BS_METERREAD.MRMEMO%TYPE;
      V_COUNT      NUMBER(4);
      V_COUNTMRID  NUMBER(4);
      V_COUNTFLAG  NUMBER(4);
      V_NUMBER     NUMBER(10);
      V_RCODE      NUMBER(10);
      V_CRHNO      VARCHAR2(10);
      V_OMRID      VARCHAR2(20);
      O_STR        VARCHAR2(20);
      O_STATE      VARCHAR2(20);
      V_METERSTORE SYS_DICT_DATA%ROWTYPE;
      O_OUT        BS_METERREAD%ROWTYPE;
    
      --未算费抄表记录
      CURSOR CUR_METERREAD_NOCALC(P_MRMID VARCHAR2, P_MRMONTH VARCHAR2) IS
        SELECT *
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MRMID
           AND MR.MRMONTH = P_MRMONTH;
    
    BEGIN
      BEGIN
        SELECT * INTO MI FROM BS_METERINFO WHERE MIID = P_MD.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
      END;
      BEGIN
        SELECT * INTO CI FROM BS_CUSTINFO WHERE BS_CUSTINFO.CIID = MI.MICODE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
      END;
      BEGIN
        SELECT *
          INTO MC
          FROM BS_METERDOC
         WHERE MDID = P_MD.MIID
           AND IFOLD = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
      END;
    
      BEGIN
        SELECT MDSTATUS
          INTO V_METERSTORE.DICT_VALUE
          FROM BS_METERDOC A
         WHERE MDNO = P_MD.NEWMDNO
           AND A.IFOLD = 'N';
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTORE.DICT_VALUE) <> '0' THEN
        SELECT A.DICT_LABEL
          INTO V_METERSTORE.DICT_LABEL
          FROM SYS_DICT_DATA A
         WHERE A.DICT_TYPE = 'sys_meterusestatus'
           AND A.DICT_VALUE = V_METERSTORE.DICT_VALUE;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MIID || '该水表状态为【' ||
                                V_METERSTORE.DICT_LABEL || '】不能使用！');
      END IF;
    
      --F销户拆表
      IF P_TYPE = BT拆表 THEN
        -- BS_METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = BT拆表,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIUNINSDATE   = SYSDATE,
               MIBFID        = NULL -- BY 20170904 WLJ 销户拆表将表册置空
         WHERE MIID = P_MD.MIID;
      
        ---销户拆表收取余量水费（在去掉低度之前）
        --STEP1 插入抄表记录
  
        \*      --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;*\
        ----增加拆表数据的实时型
        BEGIN
          PG_RAEDPLAN.CREATECBGD(MI.MIID, O_STATE);
          IF O_STATE = '0' THEN
            SELECT MAX(MRID)
              INTO O_STATE
              FROM BS_METERREAD A
             WHERE A.MRMID = MI.MIID;
            PG_CB_COST.CALCULATEBF(O_STATE,
                                   '02',
                                   O_OUT.MRRECJE01,
                                   O_OUT.MRRECJE02,
                                   O_OUT.MRRECJE03,
                                   O_OUT.MRRECJE04,
                                   O_OUT.MRMEMO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        ---- METERINFO 有效状态 --状态日期 --状态表务 【YUJIA 20110323】
        UPDATE BS_METERDOC
           SET MDSTATUS = '4', MDID = MI.MIID, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';
  \*      -----METERDOC  表状态 表状态发生时间  【YUJIA 20110323】
      
        UPDATE BS_METERDOC
           SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';*\
  
      ELSIF P_TYPE = BT口径变更 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER, --换表人
               MIBFID        = NULL
         WHERE MIID = P_MD.MIID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
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
        ------表身码状态改变    旧表状态
        UPDATE BS_METERDOC
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
      
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M欠费停水,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
      
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
      
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M报停,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
      
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSDATE   = P_MD.MTDREINSDATE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户,
               MDSTATUSDATE = SYSDATE,
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
      
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
        --METERDOC
        UPDATE BS_METERDOC
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
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --已抄表
           AND MR.MRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '【' || P_MD.MTDMID ||
                                  '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        END IF;
      
        UPDATE BS_METERREAD T
           SET MRSCODE = P_MD.MTDREINSCODE --BY RALPH 20151021  增加的将未抄见指针更换掉
         WHERE MRMID = P_MD.MTDMID
           AND MRREADOK = 'N';
      
        --ADD 20141117 HB
        --如果故障换表为9月份开立故障换表单据一直未审核，10月份如果又有抄表算费，则不允许进行审核9月份的故障换表
        --因这样会造成初始指针错误
      
        ------水表量程校验与更新 ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN
        
          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --水表最大量程
           WHERE MIID = P_MD.MTDMID;
          --- END IF ;
        END IF;
        ----------------------------20160828
      
        --END ADD 20141117 HB
      
        --20140809 总分表故障换表 MODIBY HB
        --总表先换表、分表出账导致水量不够减，换表后不出账
      
        -- END 20140809 总分表故障换表 MODIBY HB
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
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
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
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
            UPDATE BS_METERDOC
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
          UPDATE BS_METERFH_STORE
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
          UPDATE BS_METERFH_STORE
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
          UPDATE BS_METERFH_STORE
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
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --复核标志
                 MR.MRCHKDATE = SYSDATE, --复核日期
                 MR.MRCHKPER  = P_PERSON --复核人员
          
           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;
      
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
            FROM BS_METERDOC
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
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
             SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
        --算费
      ELSIF P_TYPE = BT水表整改 THEN
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户, --状态
               MISTATUSDATE  = SYSDATE, --状态日期
               MISTATUSTRANS = P_TYPE, --状态表务
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER --换表人
         WHERE MIID = P_MD.MTDMID;
        --METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --表状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDMODEL      = P_MD.MTDMODELN, --表型号
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
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
      ELSIF P_TYPE = BT周期换表 THEN
        --以上为之前周期换表代码 MODIBY HB 20140815
        --下述为故障换表的代码放过来，原理与故障换表原理一致
      
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --已抄表
           AND MR.MRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '此水表[' || P_MD.MTDMID ||
                                  ']已经抄表录入,抄见标志有打上,不能进行周期换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        END IF;
      
        ------水表量程校验与更新 ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN
          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --水表最大量程
           WHERE MIID = P_MD.MTDMID;
          ---  END IF ;
        END IF;
        ----------------------------20160828
      
        --20140809 总分表故障换表 MODIBY HB
        --总表先换表、分表出账导致水量不够减，换表后不出账
      
        -- END 20140809 总分表故障换表 MODIBY HB
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
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
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
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
            UPDATE BS_METERDOC
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
          UPDATE BS_METERFH_STORE
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
          UPDATE BS_METERFH_STORE
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
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDQFHN
             AND STOREID = MI.MISMFID --地区
             AND FHTYPE = '4';
        END IF;
      
        --【抄表审核转单】周期换表后回写复核标志
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --复核标志
                 MR.MRCHKDATE = SYSDATE, --复核日期
                 MR.MRCHKPER  = P_PERSON --复核人员
          
           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;
      
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
            FROM BS_METERDOC
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
        IF TRIM(V_METERSTATUS.SID) = '2' THEN
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
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
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIPOSITION    = P_MD.MTDPOSITIONN
         WHERE MIID = P_MD.MTDMID;
        -- METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
        
         WHERE MTDMID = MI.MIID;
      
        --记余量表 METERADDSL
        --算费
      END IF;
      --库存管理开关
      IF FSYSPARA('sys4') = 'Y' THEN
        --更新新表状态
        UPDATE BS_METERDOC
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        IF P_TYPE = BT拆表 OR P_TYPE = BT报停 OR P_TYPE = BT欠费停水 OR P_TYPE = BT复装 OR
           P_TYPE = BT换阀门 OR P_TYPE = BT水表整改 THEN
          --更新旧表状态
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        ELSE
          --更新旧表状态
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE,
                 MIID       = NULL
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
      END IF;
    
      --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
      IF FSYSPARA('1102') = 'Y' THEN
        IF P_TYPE = BT周期换表 THEN
          --余量大于0 进行算费
          --20140520 余量算费增加调整水量
          --将余量添加抄表库METERREAD
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
        ELSE
          --余量大于0 进行算费
          --20140520 余量算费增加调整水量
          --将余量添加抄表库METERREAD
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
        END IF;
      
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
            IF P_TYPE IN (BT故障换表, BT周期换表) THEN
              UPDATE BS_METERINFO
                 SET MIRCODE     = P_MD.MTDREINSCODE, --换表起度
                     MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
               WHERE MIID = P_MD.MTDMID;
            END IF;
          
            -- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
            FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                               TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
              IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
                DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
              END IF;
            END LOOP;
          
            INSERT INTO BS_METERREADHIS
              SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
            DELETE BS_METERREAD WHERE MRID = V_OMRID;
          END IF;
        ELSIF P_MD.MTDADDSL = 0 OR P_MD.MTDADDSL IS NULL THEN
          --20140512 换表后如果当月有未算费的正常抄表记录，则更新起码
          IF P_TYPE = BT故障换表 THEN
            V_MRMEMO := '故障换表重置指针';
          ELSIF P_TYPE = BT周期换表 THEN
            V_MRMEMO := '周期换表重置指针';
          END IF;
          --更新换表止码
          IF P_TYPE IN (BT故障换表, BT周期换表) THEN
            UPDATE BS_METERINFO
               SET MIRCODE     = P_MD.MTDREINSCODE, --换表起度
                   MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
             WHERE MIID = P_MD.MTDMID;
          END IF;
        
          -- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
          FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                             TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
            IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
              DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
            END IF;
          END LOOP;
        
          INSERT INTO BS_METERREADHIS
            SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
          DELETE BS_METERREAD WHERE MRID = V_OMRID;
        
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  */
  --工单流程未通过
  PROCEDURE SP_METERUSER(I_RENO  IN VARCHAR2, --批次流水
                         I_PER   IN VARCHAR2, --操作员
                         I_TYPE  IN VARCHAR2, --类型
                         O_STATE OUT NUMBER) AS -- 执行状态
    -- 执行状态
    MH      REQUEST_YHDBYH%ROWTYPE;
    MB      REQUEST_YHDBSB%ROWTYPE;
    V_COUNT VARCHAR2(100);
  BEGIN
    --分户
    IF I_TYPE = '1' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --插入历史记录
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '分户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        --更新户表信息水表档案号
        UPDATE BS_METERINFO SET MICODE = I.CIID WHERE MIID = I.MIID;
        SELECT COUNT(*)
          INTO V_COUNT
          FROM BS_CUSTINFO
         WHERE CIID = I.CIID;
        --分户后插入信息到用户信息表 如果有则不插入
        IF V_COUNT = 0 THEN
          INSERT INTO BS_CUSTINFO
            SELECT I.CIID MIID, --用户号
                   CISMFID, --营销公司
                   CIPID, --上级用户编号
                   CICLASS, --用户级次
                   CIFLAG, --末级标志
                   MH.CINAMEB CINAME, --用户名
                   MH.CIADRB CIADR, --用户地址
                   CISTATUS, --用户状态【SYSCUSTSTATUS】
                   SYSDATE CISTATUSDATE, --状态日期
                   CISTATUSTRANS, --状态表务
                   SYSDATE CINEWDATE, --立户日期
                   CIIDENTITYLB, --证件类型
                   CIIDENTITYNO, --证件号码
                   CIMTEL, --移动电话
                   CITEL1, --电话1
                   CITEL2, --电话2
                   CITEL3, --电话3
                   CICONNECTPER, --联系人
                   CICONNECTTEL, --联系电话
                   CIIFINV, --是否普票（迁移数据时同步BS_METERINFO.MIIFTAX(是否税票)）
                   CIIFSMS, --是否提供短信服务
                   CIPROJNO, --工程编号(老系统水账标识号)
                   CIFILENO, --档案号(老系统供水合同号)
                   CIMEMO, --备注信息
                   MICHARGETYPE, --类型（1=坐收，2=走收,收费方式）
                   '0' MISAVING, --预存款余额
                   MIEMAIL, --电子邮件
                   MIEMAILFLAG, --发账是否发邮件
                   MIYHPJ, --用户信用评级
                   MISTARLEVEL, --星级等级
                   ISCONTRACTFLAG, --是否签订供用水合同
                   WATERPW, --用户水表密码(限定6位,默为用户号后6位）
                   LADDERWATERDATE, --阶梯开始日期
                   CIHTBH, --合同编号
                   CIHTZQ, --周期（合同用）
                   CIRQXZ, --日期限制（合同用）
                   HTDATE, --合同签订日期
                   ZFDATE, --合同作废日期
                   JZDATE, --合同签订截止日期
                   SIGNPER, --签订人
                   SIGNID, --签订人身份证号
                   POCID, --房产证号
                   CIBANKNAME, --开户行名称(电票)
                   CIBANKNO, --开户行账号(电票)
                   CINAME2, --招牌名称
                   CINAME1, --票据名称
                   CITAXNO, --税号
                   CIADR1, --票据地址
                   CITEL4, --票据电话
                   CICOLUMN11, --特困标志
                   CITKZJH, --特困证件号
                   CICOLUMN2, --低保用户标志
                   CIDBZJH, --低保证件号
                   CICOLUMN1, --低保减免水量
                   CICOLUMN3, --低保截止月份
                   CIPASSWORD, --用户密码
                   CIUSENUM, --户籍人数
                   CIAMOUNT, --户数
                   CIDBBS, --是否一户多表
                   CILTID, --老户号
                   CIWXNO, --微信号码
                   CICQNO, --产权证号
                   'N' REFLAG --工单状态(Y:存在审批过程中的工单；N:不存在)
              FROM BS_CUSTINFO
             WHERE CIID = MH.CIIDA;
        END IF;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, REFLAG = 'Y', MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
      --合户
    ELSIF I_TYPE = '0' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --插入历史记录
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '合户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        UPDATE BS_METERINFO SET MICODE = MH.CIIDA WHERE MICODE = MH.CIIDB AND MIID = I.MIID;
        --插入历史记录
        INSERT INTO BS_CUSTINFO_HIS
          SELECT A.*, '合户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_CUSTINFO A
           WHERE CIID = MH.CIIDB;
        --删除合并后取消的用户信息
        DELETE FROM BS_CUSTINFO A WHERE CIID = MH.CIIDB;
        --合户后余额相加
        UPDATE BS_CUSTINFO A
           SET MISAVING = MH.MISAVINGA + MH.MISAVINGB
         WHERE CIID = MH.CIIDA;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, REFLAG = 'Y', MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --工单流程未通过
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --操作类型
                           P_MTHNO  IN VARCHAR2, --批次流水
                           P_PER    IN VARCHAR2, --操作员
                           P_REMARK IN VARCHAR2, --备注、拒绝原因
                           P_COMMIT IN VARCHAR2) AS --提交标志
  BEGIN
    IF P_TYPE IN ('F') THEN
      UPDATE REQUEST_CB A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.REFLAG         = 'N', --当前审批状
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      UPDATE REQUEST_GZHB A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.REFLAG         = 'N', --当前审批状
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('L') THEN
      UPDATE REQUEST_ZQGZ A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.REFLAG         = 'N', --当前审批状
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  END;

END;
/


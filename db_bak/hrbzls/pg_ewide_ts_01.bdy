CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_TS_01" IS
  --CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                         P_BANKID  IN VARCHAR2,
                         P_MFSMFID IN VARCHAR2,
                         P_OPER    IN VARCHAR2,
                         P_SRLDATE IN VARCHAR2,
                         P_ERLDATE IN VARCHAR2,
                         P_SMON    IN VARCHAR2,
                         P_EMON    IN VARCHAR2,
                         P_SFTYPE  IN VARCHAR2,
                         P_COMMIT  IN VARCHAR2,
                         O_BATCH   OUT VARCHAR2) IS

  BEGIN
    SP_CREATE_TS_MAACCOUNT_03(P_MODEL,
                              P_BANKID,
                              P_MFSMFID,
                              P_OPER,
                              P_SRLDATE,
                              P_ERLDATE,
                              P_SMON,
                              P_EMON,
                              P_SFTYPE,
                              'N', --p_commit   ,
                              O_BATCH);
    /*    sp_create_ts_maaccount_01(P_MODEL,
                              p_bankid,
                              p_mfsmfid,
                              p_oper,
                              p_srldate,
                              p_erldate,
                              p_smon,
                              p_emon,
                              p_sftype,
                              'N', -- p_commit   ,
                              o_batch);
    sp_create_ts_maaccount_02(P_MODEL,
                              p_bankid,
                              p_mfsmfid,
                              p_oper,
                              p_srldate,
                              p_erldate,
                              p_smon,
                              p_emon,
                              p_sftype,
                              'N', --p_commit   ,
                              o_batch);*/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:托收
  --author:wy
  --date：2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_01(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL ENTRUSTLIST%ROWTYPE;
    EG ENTRUSTLOG%ROWTYPE;
    MI METERINFO%ROWTYPE;

    RL            RECLIST%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    V_MAACCOUNTNO METERACCOUNT.MAACCOUNTNO%TYPE;
    V_RLID        RECLIST.RLID%TYPE;
    V_SFJE        RECLIST.RLJE%TYPE;
    V_LJFJE       RECLIST.RLJE%TYPE;
    V_LJFSL       RECLIST.RLSL%TYPE;
    CURSOR C_YSZS IS
      SELECT MAX((CASE
                   WHEN RLGROUP = 1 THEN
                    RLID
                   ELSE
                    ''
                 END)) RLID, --应收流水
             MAX((CASE
                   WHEN RLGROUP = 3 THEN
                    RLID
                   ELSE
                    ''
                 END)) RLIDLJ,
             MIID, --水表号
             MICODE, --客户代码
             MAX(MABANKID), --银行ID
             MAACCOUNTNO, --用户开户帐号
             MAX(MAACCOUNTNAME), --用户开户名
             MAX(MATSBANKID), --用户开户行
             SUM(RLJE), --应收金额
             SUM(CASE
                   WHEN RLGROUP = 1 THEN
                    RLJE
                   ELSE
                    0
                 END) SFJE, --水费金额
             SUM(CASE
                   WHEN RLGROUP = 3 THEN
                    RLJE
                   ELSE
                    0
                 END) LJFJE, --垃圾费金额
             SUM(CASE
                   WHEN RLGROUP = 1 THEN
                    RLSL
                   ELSE
                    0
                 END) SFSL, --水费水量
             SUM(CASE
                   WHEN RLGROUP = 3 THEN
                    RLSL
                   ELSE
                    0
                 END) LJFSL, --垃圾费水量
             MAX(RLZNDATE), --滞纳金起算日
             /*             PG_EWIDE_PAY_01.getznjadj(mismfid,
             rlje,
             rlgroup,
             rlzndate,
             mismfid,
             sysdate), --滞纳金*/
             0, --滞纳金
             RLMONTH, --应收帐月份
             MAX(RLCADR), --用户地址
             MAX(RLMADR), --水表地址
             MAX(RLCNAME), --产权名
             T1.MIUIID
        FROM METERACCOUNT T, METERINFO T1, /*水表欠费 T3,*/ RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
            -- AND T3.QFMIID = MIID
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            --and t3.合计欠费>0
         AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
             P_MFSMFID IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
         AND RLGROUP <> 2 --    AND RLMONTH='2012.02'
       GROUP BY RLMRID, MAACCOUNTNO, MATSBANKID, MIID, MICODE, RLMONTH
       ORDER BY MAACCOUNTNO;
  BEGIN
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入错误');
    END IF;
    EG.ELOUTROWS  := 0; --发出数
    EG.ELOUTMONEY := 0; --发出金额
    SELECT 'S' || TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL;
    --清空中间帐号帐
    --    v_maaccountno := null;
    V_RLID := NULL;
    OPEN C_YSZS;
    LOOP
      FETCH C_YSZS
        INTO RL.RLID, --应收流水
             V_RLID, --垃圾费流水
             MI.MIID, --水表号
             MI.MICODE, --客户代码
             MA.MABANKID, --银行ID
             MA.MAACCOUNTNO, --用户开户帐号
             MA.MAACCOUNTNAME, --用户开户名
             MA.MATSBANKID,
             RL.RLJE, --应收金额
             V_SFJE, --水费金额
             V_LJFJE, --垃圾费金额
             RL.RLSL, --水费水量
             V_LJFSL, --垃圾费水量
             RL.RLZNDATE, --滞纳金起算日
             RL.RLZNJ, --滞纳金
             RL.RLMONTH, --应收帐月份
             RL.RLCADR, --用户地址
             RL.RLMADR, --水表地址
             RL.RLCNAME, --产权名
             MI.MIUIID;
      EXIT WHEN C_YSZS%NOTFOUND OR C_YSZS%NOTFOUND IS NULL;
      EL.ETLBATCH := EG.ELBATCH; --代扣批次
      --EL.TLSEQNO            :=  ;--代扣流水
      EL.ETLRLID        := RL.RLID; --应收流水
      EL.ETLMID         := MI.MIID; --水表编号
      EL.ETLMCODE       := MI.MICODE; --资料号
      EL.ETLBANKID      := MA.MABANKID; --代扣银行
      EL.ETLACCOUNTNO   := MA.MAACCOUNTNO; --开户帐号
      EL.ETLACCOUNTNAME := MA.MAACCOUNTNAME; --开户名
      EL.ETLZNDATE      := RL.RLZNDATE; --滞纳金起算日
      --EL.ETLPIID             :=  ;--费用项目
      --EL.ETLPAIDDATE         :=  ;--销帐日期
      --EL.ETLPAIDCDATE        :=  ;--清算日期
      EL.ETLPAIDFLAG := 'N'; --销帐标志
      --EL.ETLRETURNCODE       :=  ;--返回信息码
      --EL.ETLRETURNMSG        :=  ;--返回信息
      --EL.ETLCHKDATE          :=  ;--对帐日期
      EL.ETLSFLAG    := 'N'; --银行成功扣款标志
      EL.ETLRLDATE   := RL.RLDATE; --应收账务日期
      EL.ETLNO       := MA.MANO; --委托授权号
      EL.ETLTSBANKID := MA.MATSBANKID; --接收行号（托）
      EL.ETLPZNO     := V_RLID; --凭证号  现用作垃圾费应收流水
      EL.ETLCIADR    := RL.RLCADR; --用户地址
      EL.ETLMIADR    := RL.RLMADR; --水表地址
      --EL.ETLBANKIDNAME       :=  ;--开户银行名称
      --EL.ETLBANKIDNO         :=  ;--开户银行实际编号
      --EL.ETLTSBANKIDNAME     :=  ;--收款行名
      -- EL.ETLTSBANKIDNO       :=  ;--收款行号
      EL.ETLSFJE := V_SFJE; --水费
      --EL.ETLWSFJE            :=  ;--污水费
      --EL.ETLSFZNJ            :=  ;--水费滞纳金
      --EL.ETLWSFZNJ           :=  ;--污水费滞纳金
      --EL.ETLRLIDPIID         :=  ;--应收流水加费用项目
      EL.ETLSL := RL.RLSL; --水量
      --EL.ETLWSL              :=  ;--污水量
      --EL.ETLSFDJ             :=  ;--水费单价
      --EL.ETLWSFDJ            :=  ;--污水费单价
      EL.ETLCINAME  := RL.RLCNAME; --产权名
      EL.ETLRLMONTH := RL.RLMONTH; --应收帐月份
      --EL.ETLCHRMODE          :=  ;--销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
      --EL.ETLPAIDPER          :=  ;--销帐员
      --EL.ETLTSACCOUNTNO      :=  ;--收款行号
      --EL.ETLTSACCOUNTNAME    :=  ;--收款户名
      --EL.ETLSZYFZNJ          :=  ;--水资源费滞纳金
      --EL.ETLLJFZNJ           :=  ;--垃圾处理费滞纳金
      --EL.ETLSZYFSL           :=  ;--水资源水量
      EL.ETLLJFSL := V_LJFSL; --垃圾费水量
      --EL.ETLSZYFDJ           :=  ;--水资源费单价
      --EL.ETLLJFDJ            :=  ;--垃圾费单价
      --EL.ETLINVSFCOUNT       :=  ;--垃圾费单价
      --EL.ETLINVWSFCOUNT      :=  ;--垃圾费单价
      --EL.ETLINVSZYFCOUNT     :=  ;--垃圾费单价
      --EL.ETLINVLJFCOUNT      :=  ;--垃圾费单价
      --EL.ETLMIUIID           :=  ;--合收单位编号
      --EL.ETLSZYFJE           :=  ;--水资源费
      EL.ETLLJFJE := V_LJFJE; --垃圾费
      EL.ETLIFINV := 0; --发票是否已打印（发票托收凭证）
      --每一个应收生成一条记录
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL;
      EL.ETLSXF      := 0; --手续费
      EL.ETLZNJ      := RL.RLZNJ; --应收滞纳金
      EL.ETLJE       := RL.RLJE + RL.RLZNJ + 0; --应收金额
      EL.ETLINVCOUNT := 1; --发票张数
      EG.ELOUTROWS   := EG.ELOUTROWS + 1; --发出数
      ---每一个帐号生成一条记录
      /*if v_maaccountno is null or ( v_maaccountno is not null and v_maaccountno<>ma.maaccountname )  then
            select trim(to_char(seq_entrustlist.nextval, '0000000000'))
              into EL.ETLSEQNO
              from dual;

            EL.ETLSXF := 0; --手续费
            EL.ETLZNJ := rl.rlznj; --应收滞纳金
            EL.ETLJE     := rl.rlje + rl.rlznj + 0 ; --应收金额
            EL.ETLINVCOUNT := 1; --发票张数
            eg.eloutrows  := eg.eloutrows + 1; --发出数
      else
            EL.ETLSXF :=EL.ETLSXF + 0; --手续费
            EL.ETLZNJ :=EL.ETLZNJ +  rl.rlznj; --应收滞纳金
            EL.ETLJE  :=EL.ETLJE + rl.rlje + rl.rlznj + 0  ; --应收金额
            EL.ETLINVCOUNT :=EL.ETLINVCOUNT + 1; --发票张数

      end if; */

      BEGIN
        INSERT INTO ENTRUSTLIST VALUES EL;
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE ENTRUSTLIST T
             SET ETLSXF      = EL.ETLSXF, --手续费
                 ETLZNJ      = EL.ETLZNJ, --应收滞纳金
                 ETLJE       = EL.ETLJE, --应收金额
                 ETLWSFJE    = EL.ETLWSFJE, --污水费
                 ETLINVCOUNT = EL.ETLINVCOUNT --发票张数
           WHERE T.ETLBATCH = EL.ETLBATCH
             AND T.ETLSEQNO = EL.ETLSEQNO;
      END;

      --锁帐，更新批次号，流水，滞纳金便于回来销帐
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;

      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = V_RLID;

      /*--更新明细滞金
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      EG.ELOUTMONEY := EG.ELOUTMONEY + RL.RLJE; --发出金额

      --     v_maaccountno := ma.maaccountno  ;

    END LOOP;
    CLOSE C_YSZS;
    IF EG.ELOUTMONEY > 0 THEN
      --eg.ELBATCH          :=    ;--托收代扣批号
      EG.ELBANKID     := NULL; --代扣文档银行
      EG.ELCHARGETYPE := P_SFTYPE; --收费方式
      EG.ELOUTOER     := P_OPER; --发出操作员
      EG.ELOUTDATE    := SYSDATE; --发出日期
      --eg.ELOUTROWS        :=    ;--发出条数
      --eg.ELOUTMONEY       :=    ;--发出金额
      --eg.ELCHKDATE        :=    ;--对账日期
      EG.ELCHKROWS := 0; --对账总条数
      EG.ELCHKJE   := 0; --对账总金额
      --eg.ELSCHKDATE       :=    ;--成功文件导入日期
      EG.ELSROWS := 0; --银行成功条数
      EG.ELSJE   := 0; --银行成功金额
      --eg.ELFCHKDATE       :=    ;--失败文件导入日期
      EG.ELFROWS := 0; --银行失败条数
      EG.ELFJE   := 0; --银行失败金额
      --eg.ELPAIDDATE       :=    ;--本地销帐日期
      EG.ELPAIDROWS := 0; --本地已销帐条数
      EG.ELPAIDJE   := 0; --本地已销帐金额
      EG.ELCHKNUM   := 0; --本地对账次数
      EG.ELCHKEND   := 'N'; --本地对账截止标志
      EG.ELSTATUS   := 'Y'; --有效状态
      EG.ELSMFID    := P_MFSMFID; --营业所
      --eg.ELTSTYPE         :=    ;--托收类型（1批量托收,2零托）
      --eg.ELPLANIMPDATE    :=    ;--计划导入日期
      --eg.ELIMPTYPE        :=    ;--文件导入类型1：未处理，2：手工，3：自动
      --eg.ELRECMONTH       :=    ;--应收帐月份
      INSERT INTO ENTRUSTLOG VALUES EG;
      O_BATCH := EG.ELBATCH;
      IF P_COMMIT = 'Y' THEN
        COMMIT;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_YSZS%ISOPEN THEN
        CLOSE C_YSZS;
      END IF;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_02
  --note:T:托收
  --author:yf
  --date：2012/02/08
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_02(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL ENTRUSTLIST%ROWTYPE;
    EG ENTRUSTLOG%ROWTYPE;
    MI METERINFO%ROWTYPE;

    RL            RECLIST%ROWTYPE;
    MA            METERACCOUNT%ROWTYPE;
    V_MAACCOUNTNO METERACCOUNT.MAACCOUNTNO%TYPE;
    V_RLID        RECLIST.RLID%TYPE;

    CURSOR C_YSZW IS
      SELECT RLID, --应收耍？            
             MIID, --水表号
             MICODE, --客户代码
             MABANKID, --银行ID
             MAACCOUNTNO, --用户开户帐号
             MAACCOUNTNAME, --用户开户名
             MATSBANKID,
             RLJE, --应收金额
             RLZNDATE, --滞纳金起算日
             /*             PG_EWIDE_PAY_01.getznjadj(mismfid,
             rlje,
             rlgroup,
             rlzndate,
             mismfid,
             sysdate), --滞纳金*/
             0, --滞纳金
             RLMONTH, --应收帐月份
             RLCADR, --用户地址
             RLMADR, --水表地址
             RLCNAME --产权名
        FROM METERACCOUNT T, METERINFO T1, /*水表欠费 T3,*/ RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
            -- AND T3.QFMIID = MIID
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            --and t3.合计欠费>0
         AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
             P_MFSMFID IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
         AND RLGROUP = 2
       ORDER BY MAACCOUNTNO;
  BEGIN
    --  INSERT INTO PBPARMTEMP (C1) VALUEs ('89610631');
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入错误');
    END IF;
    EG.ELOUTROWS  := 0; --发出数
    EG.ELOUTMONEY := 0; --发出金额
    SELECT 'W' || TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL;
    --清空中间帐号帐
    --    v_maaccountno := null;
    OPEN C_YSZW;
    LOOP
      FETCH C_YSZW
        INTO RL.RLID, --应收流水
             MI.MIID, --水表号
             MI.MICODE, --客户代码
             MA.MABANKID, --银行ID
             MA.MAACCOUNTNO, --用户开户帐号
             MA.MAACCOUNTNAME, --用户开户名
             MA.MATSBANKID,
             RL.RLJE, --应收金额
             RL.RLZNDATE, --滞纳金起算日
             RL.RLZNJ, --滞纳金
             RL.RLMONTH, --应收帐月份
             RL.RLCADR, --用户地址
             RL.RLMADR, --水表地址
             RL.RLCNAME --产权名
      ;
      EXIT WHEN C_YSZW%NOTFOUND OR C_YSZW%NOTFOUND IS NULL;
      EL.ETLBATCH := EG.ELBATCH; --代扣批次
      --EL.TLSEQNO            :=  ;--代扣流水
      EL.ETLRLID        := RL.RLID; --应收流水
      EL.ETLMID         := MI.MIID; --水表编号
      EL.ETLMCODE       := MI.MICODE; --资料号
      EL.ETLBANKID      := MA.MABANKID; --代扣银行
      EL.ETLACCOUNTNO   := MA.MAACCOUNTNO; --开户帐号
      EL.ETLACCOUNTNAME := MA.MAACCOUNTNAME; --开户名
      EL.ETLZNDATE      := RL.RLZNDATE; --滞纳金起算日
      --EL.ETLPIID             :=  ;--费用项目
      ----EL.ETLPAIDDATE         :=  ;--销帐日期
      --EL.ETLPAIDCDATE        :=  ;--清算日期
      EL.ETLPAIDFLAG := 'N'; --销帐标志
      --EL.ETLRETURNCODE       :=  ;--返回信息码
      --EL.ETLRETURNMSG        :=  ;--返回信息
      --EL.ETLCHKDATE          :=  ;--对帐日期
      EL.ETLSFLAG    := 'N'; --银行成功扣款标志
      EL.ETLRLDATE   := RL.RLDATE; --应收账务日期
      EL.ETLNO       := MA.MANO; --委托授权号
      EL.ETLTSBANKID := MA.MATSBANKID; --接收行号（托）
      --EL.TLPZNO             :=  ;--凭证号
      EL.ETLCIADR := RL.RLCADR; --用户地址
      EL.ETLMIADR := RL.RLMADR; --水表地址
      --EL.ETLBANKIDNAME       :=  ;--开户银行名称
      --EL.ETLBANKIDNO         :=  ;--开户银行实际编号
      --EL.ETLTSBANKIDNAME     :=  ;--收款行名
      --   EL.ETLTSBANKIDNO       := ma.matsbankid ;--收款行号
      --EL.ETLSFJE             :=  ;--水费
      --EL.ETLWSFJE            :=  ;--污水费
      --EL.ETLSFZNJ            :=  ;--水费滞纳金
      --EL.ETLWSFZNJ           :=  ;--污水费滞纳金
      --EL.ETLRLIDPIID         :=  ;--应收流水加费用项目
      --EL.ETLSL               :=  ;--水量
      --EL.ETLWSL              :=  ;--污水量
      --EL.ETLSFDJ             :=  ;--水费单价
      --EL.ETLWSFDJ            :=  ;--污水费单价
      EL.ETLCINAME  := RL.RLCNAME; --产权名
      EL.ETLRLMONTH := RL.RLMONTH; --应收帐月份
      --EL.ETLCHRMODE          :=  ;--销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
      --EL.ETLPAIDPER          :=  ;--销帐员
      --EL.ETLTSACCOUNTNO      :=  ;--收款行号
      --EL.ETLTSACCOUNTNAME    :=  ;--收款户名
      --EL.ETLSZYFZNJ          :=  ;--水资源费滞纳金
      --EL.ETLLJFZNJ           :=  ;--垃圾处理费滞纳金
      --EL.ETLSZYFSL           :=  ;--水资源水量
      --EL.ETLLJFSL            :=  ;--垃圾费水量
      --EL.ETLSZYFDJ           :=  ;--水资源费单价
      --EL.ETLLJFDJ            :=  ;--垃圾费单价
      --EL.ETLINVSFCOUNT       :=  ;--垃圾费单价
      --EL.ETLINVWSFCOUNT      :=  ;--垃圾费单价
      --EL.ETLINVSZYFCOUNT     :=  ;--垃圾费单价
      --EL.ETLINVLJFCOUNT      :=  ;--垃圾费单价
      --EL.ETLMIUIID           :=  ;--合收单位编号
      --EL.ETLSZYFJE           :=  ;--水资源费
      --EL.ETLLJFJE            :=  ;--垃圾费
      EL.ETLIFINV := 0; --发票是否已打印（发票托收凭证）
      --每一个污水应收生成一条记录
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL;
      EL.ETLSXF         := 0; --手续费
      EL.ETLZNJ         := RL.RLZNJ; --应收滞纳金
      EL.ETLJE          := RL.RLJE + RL.RLZNJ + 0; --应收金额
      EL.ETLWSFJE       := RL.RLJE; --污水费
      EL.ETLINVCOUNT    := 1; --发票张数
      EL.ETLINVWSFCOUNT := 1; --垃圾费单价
      EG.ELOUTROWS      := EG.ELOUTROWS + 1; --发出数
      ---每一个帐号生成一条记录
      /*if v_maaccountno is null or ( v_maaccountno is not null and v_maaccountno<>ma.maaccountname )  then
            select trim(to_char(seq_entrustlist.nextval, '0000000000'))
              into EL.ETLSEQNO
              from dual;

            EL.ETLSXF := 0; --手续费
            EL.ETLZNJ := rl.rlznj; --应收滞纳金
            EL.ETLJE     := rl.rlje + rl.rlznj + 0 ; --应收金额
            EL.ETLINVCOUNT := 1; --发票张数
            eg.eloutrows  := eg.eloutrows + 1; --发出数
      else
            EL.ETLSXF :=EL.ETLSXF + 0; --手续费
            EL.ETLZNJ :=EL.ETLZNJ +  rl.rlznj; --应收滞纳金
            EL.ETLJE  :=EL.ETLJE + rl.rlje + rl.rlznj + 0  ; --应收金额
            EL.ETLINVCOUNT :=EL.ETLINVCOUNT + 1; --发票张数

      end if;    */

      BEGIN
        INSERT INTO ENTRUSTLIST VALUES EL;
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE ENTRUSTLIST T
             SET ETLSXF      = EL.ETLSXF, --手续费
                 ETLZNJ      = EL.ETLZNJ, --应收滞纳金
                 ETLJE       = EL.ETLJE, --应收金额
                 ETLWSFJE    = EL.ETLWSFJE, --污水费
                 ETLINVCOUNT = EL.ETLINVCOUNT --发票张数
           WHERE T.ETLBATCH = EL.ETLBATCH
             AND T.ETLSEQNO = EL.ETLSEQNO;
      END;

      --锁帐，更新批次号，流水，滞纳金便于回来销帐
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;

      /*--更新明细滞金
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      EG.ELOUTMONEY := EG.ELOUTMONEY + RL.RLJE; --发出金额

      --     v_maaccountno := ma.maaccountno  ;

    END LOOP;
    CLOSE C_YSZW;
    IF EG.ELOUTMONEY > 0 THEN
      --eg.ELBATCH          :=    ;--托收代扣批号
      EG.ELBANKID     := P_BANKID; --代扣文档银行
      EG.ELCHARGETYPE := P_SFTYPE; --收费方式
      EG.ELOUTOER     := P_OPER; --发出操作员
      EG.ELOUTDATE    := SYSDATE; --发出日期
      --eg.ELOUTROWS        :=    ;--发出条数
      --eg.ELOUTMONEY       :=    ;--发出金额
      --eg.ELCHKDATE        :=    ;--对账日期
      EG.ELCHKROWS := 0; --对账总条数
      EG.ELCHKJE   := 0; --对账总金额
      --eg.ELSCHKDATE       :=    ;--成功文件导入日期
      EG.ELSROWS := 0; --银行成功条数
      EG.ELSJE   := 0; --银行成功金额
      --eg.ELFCHKDATE       :=    ;--失败文件导入日期
      EG.ELFROWS := 0; --银行失败条数
      EG.ELFJE   := 0; --银行失败金额
      --eg.ELPAIDDATE       :=    ;--本地销帐日期
      EG.ELPAIDROWS := 0; --本地已销帐条数
      EG.ELPAIDJE   := 0; --本地已销帐金额
      EG.ELCHKNUM   := 0; --本地对账次数
      EG.ELCHKEND   := 'N'; --本地对账截止标志
      EG.ELSTATUS   := 'Y'; --有效状态
      EG.ELSMFID    := P_MFSMFID; --
      --eg.ELTSTYPE         :=    ;--托收类型（1批量托收,2零托）
      --eg.ELPLANIMPDATE    :=    ;--计划导入日期
      --eg.ELIMPTYPE        :=    ;--文件导入类型1：未处理，2：手工，3：自动
      --eg.ELRECMONTH       :=    ;--应收帐月份
      INSERT INTO ENTRUSTLOG VALUES EG;
      O_BATCH := O_BATCH || '/' || EG.ELBATCH;
      IF P_COMMIT = 'Y' THEN
        COMMIT;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_YSZW%ISOPEN THEN
        CLOSE C_YSZW;
      END IF;
      RAISE;
  END;

  --name:sp_create_dk_batch_rlid_01
  --note:T:托收
  --author:lgb
  --date：2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录
  PROCEDURE SP_CREATE_TS_MAACCOUNT_03(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL     ENTRUSTLIST%ROWTYPE;
    EG     ENTRUSTLOG%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    V_RLID RECLIST.RLID%TYPE;
    V_MIID METERINFO.MIID%TYPE;

    /*托收信息*/
    CURSOR C_TSINFO IS
      SELECT RLID, MIID
        FROM METERACCOUNT T, METERINFO T1, RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            /*     AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
            P_MFSMFID IS NULL)*/
            --按托收号所在营业所进行生成
         AND MIUIID IN
             (SELECT CDMID
                FROM CUSTDWDM
               WHERE (CDMFPCODE = P_MFSMFID OR P_MFSMFID IS NULL))
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
       GROUP BY RLID, MIID, MAACCOUNTNO
       ORDER BY MAACCOUNTNO;

  BEGIN
    /*参数检查**/
    IF P_SFTYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入不能为空');
    END IF;
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入错误');
    END IF;
    IF P_MODEL NOT IN ('TS', 'LT') OR P_MODEL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收方式传错误,托收方式只能为 TS 或者 LT');
    END IF;
    /**托收日志初始化*/
    SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL; --批次
    EG.ELCHARGETYPE := P_SFTYPE;
    EG.ELBANKID     := P_BANKID;
    EG.ELOUTOER     := P_OPER; --发出操作员
    EG.ELOUTDATE    := SYSDATE; --发出日期
    EG.ELOUTROWS    := 0; --发出条数
    EG.ELOUTMONEY   := 0; --发出金额
    EG.ELCHKDATE    := NULL; --对账日期
    EG.ELCHKROWS    := 0; --对账总条数
    EG.ELCHKJE      := 0; --对账总金额
    EG.ELSCHKDATE   := NULL; --成功文件导入日期
    EG.ELSROWS      := 0; --银行成功条数
    EG.ELSJE        := 0; --银行成功金额
    EG.ELFCHKDATE   := NULL; --失败文件导入日期
    EG.ELFROWS      := 0; --银行失败条数
    EG.ELFJE        := 0; --银行失败金额
    EG.ELPAIDDATE   := NULL; --本地销帐日期
    EG.ELPAIDROWS   := 0; --本地已销帐条数
    EG.ELPAIDJE     := 0; --本地已销帐金额
    EG.ELCHKNUM     := 0; --本地对账次数
    EG.ELCHKEND     := 'N'; --本地对账截止标志
    EG.ELSTATUS     := 'Y'; --有效状态
    EG.ELSMFID      := P_MFSMFID; --
    IF P_MODEL = 'TS' THEN
      EG.ELTSTYPE := '1'; --批量托收
    ELSE
      EG.ELTSTYPE := '2'; --零托
    END IF;
    EG.ELPLANIMPDATE := NULL; --计划导入日期
    EG.ELIMPTYPE     := NULL; --文件导入类型1：未处理，2：手工，3：自动
    EG.ELRECMONTH    := P_SMON; --应收帐月份
    /***托收信息**/
    OPEN C_TSINFO;

    LOOP
      FETCH C_TSINFO
        INTO V_RLID, V_MIID;
      EXIT WHEN C_TSINFO%NOTFOUND OR C_TSINFO%NOTFOUND IS NULL;

      --应收信息
      SELECT * INTO RL FROM RECLIST WHERE RLID = V_RLID;
      --用户信息
      SELECT * INTO MI FROM METERINFO WHERE MIID = V_MIID;
      --用户银行信息
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = V_MIID;

      --违约金
      RL.RLZNJ    := PG_EWIDE_PAY_01.GETZNJADJ(RL.RLID,
                                               RL.RLJE,
                                               RL.RLGROUP,
                                               RL.RLZNDATE,
                                               RL.RLSMFID,
                                               TRUNC(SYSDATE));
      EL.ETLBATCH := EG.ELBATCH; --代扣批次
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL; --代扣流水
      EL.ETLRLID          := RL.RLID; --应收流水
      EL.ETLMID           := MI.MIID; --水表编号
      EL.ETLMCODE         := MI.MICODE; --资料号
      EL.ETLBANKID        := MA.MABANKID; --代扣银行
      EL.ETLACCOUNTNO     := MA.MAACCOUNTNO; --开户帐号
      EL.ETLACCOUNTNAME   := MA.MAACCOUNTNAME; --开户名
      EL.ETLZNDATE        := RL.RLZNDATE; --滞纳金起算日
      EL.ETLPIID          := NULL; --费用项目
      EL.ETLPAIDDATE      := NULL; --销帐日期
      EL.ETLPAIDCDATE     := NULL; --清算日期
      EL.ETLPAIDFLAG      := 'N'; --销帐标志
      EL.ETLRETURNCODE    := NULL; --返回信息码
      EL.ETLRETURNMSG     := NULL; --返回信息
      EL.ETLCHKDATE       := NULL; --对帐日期
      EL.ETLSFLAG         := 'N'; --银行成功扣款标志
      EL.ETLRLDATE        := RL.RLDATE; --应收账务日期
      EL.ETLNO            := MA.MANO; --委托授权号
      EL.ETLTSBANKID      := MA.MATSBANKID; --接收行号（托）
      EL.ETLPZNO          := NULL; --凭证号
      EL.ETLCIADR         := RL.RLCADR; --用户地址
      EL.ETLMIADR         := RL.RLMADR; --水表地址
      EL.ETLBANKIDNAME    := FGETSYSMANAFRAME(MA.MABANKID); --开户银行名称
      EL.ETLBANKIDNO      := MA.MABANKID; --开户银行实际编号
      EL.ETLTSBANKIDNAME  := FGETSYSMANAFRAME(MA.MATSBANKID); --收款行名
      EL.ETLTSBANKIDNO    := MA.MATSBANKID; --收款行号
      EL.ETLSFJE          := NULL; --水费
      EL.ETLWSFJE         := NULL; --污水费
      EL.ETLSFZNJ         := NULL; --水费滞纳金
      EL.ETLWSFZNJ        := NULL; --污水费滞纳金
      EL.ETLRLIDPIID      := NULL; --应收流水加费用项目
      EL.ETLSL            := NULL; --水量
      EL.ETLWSL           := NULL; --污水量
      EL.ETLSFDJ          := NULL; --水费单价
      EL.ETLWSFDJ         := NULL; --污水费单价
      EL.ETLCINAME        := RL.RLCNAME; --产权名
      EL.ETLRLMONTH       := RL.RLMONTH; --应收帐月份
      EL.ETLCHRMODE       := NULL; --销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
      EL.ETLPAIDPER       := NULL; --销帐员
      EL.ETLTSACCOUNTNO   := FGETSYSMANAPARA(MA.MATSBANKID, 'ZH'); --收款行号
      EL.ETLTSACCOUNTNAME := FGETSYSMANAPARA(MA.MATSBANKID, 'HM'); --收款户名
      EL.ETLSZYFZNJ       := NULL; --水资源费滞纳金
      EL.ETLLJFZNJ        := NULL; --垃圾处理费滞纳金
      EL.ETLSZYFSL        := NULL; --水资源水量
      EL.ETLLJFSL         := NULL; --垃圾费水量
      EL.ETLSZYFDJ        := NULL; --水资源费单价
      EL.ETLLJFDJ         := NULL; --训ゼ？      EL.ETLINVSFCOUNT    := NULL; --垃圾费单价
      EL.ETLINVWSFCOUNT   := NULL; --垃圾费单价
      EL.ETLINVSZYFCOUNT  := NULL; --垃圾费单价
      EL.ETLINVLJFCOUNT   := NULL; --垃圾费单价
      EL.ETLMIUIID        := MI.MIUIID; --合收单位编号
      EL.ETLSZYFJE        := NULL; --水资源费
      EL.ETLLJFJE         := NULL; --垃圾费
      EL.ETLIFINV         := 0; --发票是否已打印（发票托收凭证）
      EL.ETLIFINVPZ       := 0; --凭证是否已经打印
      EL.ETLSXF           := NULL; --手续费
      EL.ETLZNJ           := RL.RLZNJ; --应收滞纳金
      EL.ETLJE            := RL.RLJE + RL.RLZNJ + 0; --应收金额
      EL.ETLWSFJE         := NULL; --污水费
      EL.ETLINVCOUNT      := 1; --发票张数
      EL.ETLINVWSFCOUNT   := NULL; --垃圾费单价
      EG.ELOUTROWS        := EG.ELOUTROWS + 1; --发出数
      EG.ELOUTMONEY       := EG.ELOUTMONEY + EL.ETLJE;
      INSERT INTO ENTRUSTLIST VALUES EL;
      /**更新应收信息**/
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;
    END LOOP;
    IF C_TSINFO%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '本次没有需要发出托收用户信息');
    END IF;
    IF EG.ELOUTMONEY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '发出金额为0');
    END IF;
    /*插入日志*/
    INSERT INTO ENTRUSTLOG VALUES EG;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_TSINFO%ISOPEN THEN
        CLOSE C_TSINFO;
      END IF;
      RAISE;
  END;
  PROCEDURE SP_CREATE_TS_MAACCOUNT_04(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      P_STSH    IN VARCHAR2,
                                      P_ETSH    IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2) IS
    EL     ENTRUSTLIST%ROWTYPE;
    EG     ENTRUSTLOG%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    V_RLID RECLIST.RLID%TYPE;
    V_MIID METERINFO.MIID%TYPE;

    /*托收信息*/
    CURSOR C_TSINFO IS
      SELECT RLID, MIID
        FROM METERACCOUNT T, METERINFO T1, RECLIST T
       WHERE MIID = MAMID
         AND (P_MODEL = 'TS' OR
             (P_MODEL = 'LT' AND RLID IN (SELECT C1 FROM PBPARMTEMP)))
         AND MIID = RLMID
         AND RLOUTFLAG = 'N'
         AND RLJE > 0
         AND RLCD = 'DE'
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND T1.MIUIID IS NOT NULL
            /*     AND ((MISMFID = P_MFSMFID AND P_MFSMFID IS NOT NULL) OR
            P_MFSMFID IS NULL)*/
            --按托收号所在营业所进行生成

         AND MIUIID IN
             (SELECT CDMID
                FROM CUSTDWDM
               WHERE (CDMFPCODE = P_MFSMFID OR P_MFSMFID IS NULL))
         AND (TO_NUMBER(MIUIID) >= TO_NUMBER(P_STSH) OR P_STSH IS NULL)
         AND (TO_NUMBER(MIUIID) <= TO_NUMBER(P_ETSH) OR P_ETSH IS NULL)
         AND T1.MICHARGETYPE = P_SFTYPE
         AND T.MATSBANKID LIKE P_BANKID || '%'
         AND ((RLMONTH >= P_SMON AND P_SMON IS NOT NULL) OR P_SMON IS NULL)
         AND ((RLMONTH <= P_EMON AND P_EMON IS NOT NULL) OR P_EMON IS NULL)
         AND ((RLDATE >= TO_DATE(P_SRLDATE, 'yyyymmdd') AND
             P_SRLDATE IS NOT NULL) OR P_SRLDATE IS NULL)
         AND ((RLDATE <= TO_DATE(P_ERLDATE, 'yyyymmdd') AND
             P_ERLDATE IS NOT NULL) OR P_ERLDATE IS NULL)
       GROUP BY RLID, MIID, MAACCOUNTNO
       ORDER BY MAACCOUNTNO;

  BEGIN
    /*参数检查**/
    IF P_SFTYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入不能为空');
    END IF;
    IF P_SFTYPE <> 'T' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '收费方式传入错误');
    END IF;
    IF P_MODEL NOT IN ('TS', 'LT') OR P_MODEL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收方式传错误,托收方式只能为 TS 或者 LT');
    END IF;
    /**托收日志初始化*/
    SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLOG.NEXTVAL, '000000000'))
      INTO EG.ELBATCH
      FROM DUAL; --批次
    EG.ELCHARGETYPE := P_SFTYPE;
    EG.ELBANKID     := P_BANKID;
    EG.ELOUTOER     := P_OPER; --发出操作员
    EG.ELOUTDATE    := SYSDATE; --发出日期
    EG.ELOUTROWS    := 0; --发出条数
    EG.ELOUTMONEY   := 0; --发出金额
    EG.ELCHKDATE    := NULL; --对账日期
    EG.ELCHKROWS    := 0; --对账总条数
    EG.ELCHKJE      := 0; --对账总金额
    EG.ELSCHKDATE   := NULL; --成功文件导入日期
    EG.ELSROWS      := 0; --银行成功条数
    EG.ELSJE        := 0; --银行成功金额
    EG.ELFCHKDATE   := NULL; --失败文件导入日期
    EG.ELFROWS      := 0; --银行失败条数
    EG.ELFJE        := 0; --银行失败金额
    EG.ELPAIDDATE   := NULL; --本地销帐日期
    EG.ELPAIDROWS   := 0; --本地已销帐条数
    EG.ELPAIDJE     := 0; --本地已销帐金额
    EG.ELCHKNUM     := 0; --本地对账次数
    EG.ELCHKEND     := 'N'; --本地对账截止标志
    EG.ELSTATUS     := 'Y'; --有效状态
    EG.ELSMFID      := P_MFSMFID; --
    IF P_MODEL = 'TS' THEN
      EG.ELTSTYPE := '1'; --批量托收
    ELSE
      EG.ELTSTYPE := '2'; --零托
    END IF;
    EG.ELPLANIMPDATE := NULL; --计划导入日期
    EG.ELIMPTYPE     := NULL; --文件导入类型1：未处理，2：手工，3：自动
    EG.ELRECMONTH    := P_SMON; --应收帐月份
    /***托收信息**/
    OPEN C_TSINFO;

    LOOP
      FETCH C_TSINFO
        INTO V_RLID, V_MIID;
      EXIT WHEN C_TSINFO%NOTFOUND OR C_TSINFO%NOTFOUND IS NULL;

      --应收信息
      SELECT * INTO RL FROM RECLIST WHERE RLID = V_RLID;
      --用户信息
      SELECT * INTO MI FROM METERINFO WHERE MIID = V_MIID;
      --用户银行信息
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = V_MIID;

      --违约金
      RL.RLZNJ    := PG_EWIDE_PAY_01.GETZNJADJ(RL.RLID,
                                               RL.RLJE,
                                               RL.RLGROUP,
                                               RL.RLZNDATE,
                                               RL.RLSMFID,
                                               TRUNC(SYSDATE));
      EL.ETLBATCH := EG.ELBATCH; --代扣批次
      SELECT TRIM(TO_CHAR(SEQ_ENTRUSTLIST.NEXTVAL, '0000000000'))
        INTO EL.ETLSEQNO
        FROM DUAL; --代扣流水
      EL.ETLRLID          := RL.RLID; --应收流水
      EL.ETLMID           := MI.MIID; --水表编号
      EL.ETLMCODE         := MI.MICODE; --资料号
      EL.ETLBANKID        := MA.MABANKID; --代扣银行
      EL.ETLACCOUNTNO     := MA.MAACCOUNTNO; --开户帐号
      EL.ETLACCOUNTNAME   := MA.MAACCOUNTNAME; --开户名
      EL.ETLZNDATE        := RL.RLZNDATE; --滞纳金起算日
      EL.ETLPIID          := NULL; --费用项目
      EL.ETLPAIDDATE      := NULL; --销帐日期
      EL.ETLPAIDCDATE     := NULL; --清算日期
      EL.ETLPAIDFLAG      := 'N'; --销帐标志
      EL.ETLRETURNCODE    := NULL; --返回信息码
      EL.ETLRETURNMSG     := NULL; --返回信息
      EL.ETLCHKDATE       := NULL; --对帐日期
      EL.ETLSFLAG         := 'N'; --银行成功扣款标志
      EL.ETLRLDATE        := RL.RLDATE; --应收账务日期
      EL.ETLNO            := MA.MANO; --委托授权号
      EL.ETLTSBANKID      := MA.MATSBANKID; --接收行号（托）
      EL.ETLPZNO          := NULL; --凭证号
      EL.ETLCIADR         := RL.RLCADR; --用户地址
      EL.ETLMIADR         := RL.RLMADR; --水表地址
      EL.ETLBANKIDNAME    := FGETSYSMANAFRAME(MA.MABANKID); --开户银行名称
      EL.ETLBANKIDNO      := MA.MABANKID; --开户银行实际编号
      EL.ETLTSBANKIDNAME  := FGETSYSMANAFRAME(MA.MATSBANKID); --收款行名
      EL.ETLTSBANKIDNO    := MA.MATSBANKID; --收款行号
      EL.ETLSFJE          := NULL; --水费
      EL.ETLWSFJE         := NULL; --污水费
      EL.ETLSFZNJ         := NULL; --水费滞纳金
      EL.ETLWSFZNJ        := NULL; --污水费滞纳金
      EL.ETLRLIDPIID      := NULL; --应收流水加费用项目
      EL.ETLSL            := NULL; --水量
      EL.ETLWSL           := NULL; --污水量
      EL.ETLSFDJ          := NULL; --水费单价
      EL.ETLWSFDJ         := NULL; --污水费单价
      EL.ETLCINAME        := RL.RLCNAME; --产权名
      EL.ETLRLMONTH       := RL.RLMONTH; --应收帐月份
      EL.ETLCHRMODE       := NULL; --销帐方式（1：未处理 ，2：文档销帐，3：手工销帐,4:解锁,5:银行未处理的全部销帐,6:银行未处理的部分销帐,7银行反盘未处理）
      EL.ETLPAIDPER       := NULL; --销帐员
      EL.ETLTSACCOUNTNO   := FGETSYSMANAPARA(MA.MATSBANKID, 'ZH'); --收款行号
      EL.ETLTSACCOUNTNAME := FGETSYSMANAPARA(MA.MATSBANKID, 'HM'); --收款户名
      EL.ETLSZYFZNJ       := NULL; --水资源费滞纳金
      EL.ETLLJFZNJ        := NULL; --垃圾处理费滞纳金
      EL.ETLSZYFSL        := NULL; --水资源水量
      EL.ETLLJFSL         := NULL; --垃圾费水量
      EL.ETLSZYFDJ        := NULL; --水资源费单价
      EL.ETLLJFDJ         := NULL; --垃圾费单价
      EL.ETLINVSFCOUNT    := NULL; --垃圾费单价
      EL.ETLINVWSFCOUNT   := NULL; --垃圾费单价
      EL.ETLINVSZYFCOUNT  := NULL; --垃圾费单价
      EL.ETLINVLJFCOUNT   := NULL; --垃圾费单价
      EL.ETLMIUIID        := MI.MIUIID; --合收单位编号
      EL.ETLSZYFJE        := NULL; --水资源费
      EL.ETLLJFJE         := NULL; --垃圾费
      EL.ETLIFINV         := 0; --发票是否已打印（发票托收凭证）
      EL.ETLIFINVPZ       := 0; --凭证是否已经打印
      EL.ETLSXF           := NULL; --手续费
      EL.ETLZNJ           := RL.RLZNJ; --应收滞纳金
      EL.ETLJE            := RL.RLJE + RL.RLZNJ + 0; --应收金额
      EL.ETLWSFJE         := NULL; --污水费
      EL.ETLINVCOUNT      := 1; --发票张数
      EL.ETLINVWSFCOUNT   := NULL; --垃圾费单价
      EG.ELOUTROWS        := EG.ELOUTROWS + 1; --发出数
      EG.ELOUTMONEY       := EG.ELOUTMONEY + EL.ETLJE;
      INSERT INTO ENTRUSTLIST VALUES EL;
      /**更新应收信息**/
      UPDATE RECLIST T
         SET T.RLZNJ          = RL.RLZNJ,
             T.RLOUTFLAG      = 'Y',
             T.RLENTRUSTBATCH = EL.ETLBATCH,
             T.RLENTRUSTSEQNO = EL.ETLSEQNO
       WHERE RLID = RL.RLID;
    END LOOP;
    IF C_TSINFO%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '本次没有需要发出托收用户信息');
    END IF;
    IF EG.ELOUTMONEY = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '发出金额为0');
    END IF;
    /*插入日志*/
    INSERT INTO ENTRUSTLOG VALUES EG;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_TSINFO%ISOPEN THEN
        CLOSE C_TSINFO;
      END IF;
      RAISE;
  END;
  ---------------------------------------------------------------------------
  --                        撤销托收批次数据
  --name:sp_cancle_ts_batch
  --note:撤销托收批次数据
  --author:wy
  --date：2009/04/26
  --input: p_entrust_batch 托收批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_BATCH_01(P_ENTRUST_BATCH IN VARCHAR2,
                                  P_OPER          IN VARCHAR2, --操作员
                                  P_COMMIT        IN VARCHAR2) IS

    V_TS_LOG ENTRUSTLOG%ROWTYPE; --托收日志
    V_TEST   VARCHAR2(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '批次号[' || P_ENTRUST_BATCH || ']不存在,请检查!');
    END;
    --撤销检查
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '批次号[' || P_ENTRUST_BATCH || ']已作废,无需再次作废!');
    END IF;
    IF V_TS_LOG.ELCHKNUM > 0 OR V_TS_LOG.ELCHKEND = 'Y' THEN
      SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH, 'N');
      --RAISE_application_error(errcode, '该托收批次[' || p_entrust_batch || ']已经导入，不能撤销！');
    END IF;
    /* --清空应收账发出流水,批次号,发出标志
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch
    )
    and rdpaidflag='N' ;*/

    UPDATE RECLIST
       SET RLENTRUSTBATCH = NULL,
           RLENTRUSTSEQNO = NULL,
           RLOUTFLAG      = 'N',
           RLZNJ          = 0
     WHERE RLENTRUSTBATCH = P_ENTRUST_BATCH;
    --更新托收发出日志有效标志
    UPDATE ENTRUSTLOG SET ELSTATUS = 'N' WHERE ELBATCH = P_ENTRUST_BATCH;

    ---插入日志表
    INSERT INTO ELDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLOG T
       WHERE ELBATCH = P_ENTRUST_BATCH;

    ---插入日志表
    INSERT INTO ETLDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLIST T
       WHERE ETLBATCH = P_ENTRUST_BATCH;

    --删除
    DELETE ENTRUSTLOG WHERE ELBATCH = P_ENTRUST_BATCH;
    --删除托收的中间表
    DELETE ENTRUSTLIST WHERE ETLBATCH = P_ENTRUST_BATCH;

    --提交
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --                        撤销托收批次数据
  --name:sp_cancle_ts_entpzseqno_01
  --note:撤销托收批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_ts_entpzseqno_01 托收批次号
  -- p_enterst_pzseqno  in varchar2, 流水号
  -- p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_ENTPZSEQNO_01(P_ENTRUST_BATCH   IN VARCHAR2,
                                       P_ENTERST_PZSEQNO IN VARCHAR2,
                                       P_OPER            IN VARCHAR2, --操作员
                                       P_COMMIT          IN VARCHAR2) IS

    V_TS_LOG  ENTRUSTLOG%ROWTYPE; --托收日志
    V_TS_LIST ENTRUSTLIST%ROWTYPE; --托收凭证
    --v_rl      reclist%rowtype; --应收
    --v_rd      recdetail%rowtype;--应收明细
    V_JE   NUMBER(12, 2);
    V_TEST VARCHAR2(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '批次号[' || P_ENTRUST_BATCH || ']不存在,请检查!');
    END;
    BEGIN
      SELECT *
        INTO V_TS_LIST
        FROM ENTRUSTLIST
       WHERE ETLBATCH = P_ENTRUST_BATCH
         AND ETLSEQNO = P_ENTERST_PZSEQNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '批次号[' || P_ENTRUST_BATCH || '中托收流水' ||
                                P_ENTERST_PZSEQNO || ']不存在,请检查!');
    END;
    IF V_TS_LIST.ETLPAIDFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '用户[' || V_TS_LIST.ETLMCODE || ']已销账，无需作废!');
    END IF;

    --撤销检查
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '批次号[' || P_ENTRUST_BATCH || ']已作废,无需再次作废!');
    END IF;
    IF V_TS_LOG.ELCHKNUM > 0 OR V_TS_LOG.ELCHKEND = 'Y' THEN
      NULL;
      --sp_cancle_ts_imp_01(p_entrust_batch, 'N');
      --RAISE_application_error(errcode, '该托收批次[' || p_entrust_batch || ']已经导入，不能撤销！');
    END IF;
    /*--清空应收账发出流水,批次号,发出标志
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch and  RLENTRUSTSEQNO = p_enterst_pzseqno
    )
    and rdpaidflag='N' ;*/

    UPDATE RECLIST
       SET RLENTRUSTBATCH = NULL,
           RLENTRUSTSEQNO = NULL,
           RLOUTFLAG      = 'N',
           RLZNJ          = 0
     WHERE RLENTRUSTBATCH = P_ENTRUST_BATCH
       AND RLENTRUSTSEQNO = P_ENTERST_PZSEQNO;
    --更新托收发出日志
    SELECT ETLJE
      INTO V_JE
      FROM ENTRUSTLIST
     WHERE ETLBATCH = P_ENTRUST_BATCH
       AND ETLSEQNO = P_ENTERST_PZSEQNO;

    ---插入日志表
    INSERT INTO ETLDELBAK
      SELECT P_OPER, SYSDATE, T.*
        FROM ENTRUSTLIST T
       WHERE ETLBATCH = P_ENTRUST_BATCH
         AND ETLSEQNO = P_ENTERST_PZSEQNO;
    --删除托收单
    DELETE ENTRUSTLIST
     WHERE ETLBATCH = P_ENTRUST_BATCH
       AND ETLSEQNO = P_ENTERST_PZSEQNO;

    UPDATE ENTRUSTLOG
       SET (ELOUTROWS, --发出条数
            ELOUTMONEY, --发出金额
            ELCHKROWS, --对账总条数
            ELCHKJE, --对账总金额
            ELSROWS, --银行成功条数
            ELSJE, --银行成功金额
            ELFROWS, --银行失败条数
            ELFJE, --银行失败金额
            ELPAIDROWS, --本地已销账条数
            ELPAIDJE) --本地已销账金额
            =
           (SELECT COUNT(*),
                   SUM(ETLJE),
                   SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                   SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                   SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                   SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                   SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
              FROM ENTRUSTLIST EL
             WHERE EL.ETLBATCH = P_ENTRUST_BATCH)
     WHERE ELBATCH = P_ENTRUST_BATCH;

    --提交
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  --撤销未销账
  PROCEDURE SP_CANCLE_TS_WXZ_01(P_BATCH IN VARCHAR2, P_OPER IN VARCHAR2) IS
    CURSOR C_ENTRUSTLIST(VID VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = VID
         AND ETLPAIDFLAG = 'N';
    V_ENTRUSTLIST ENTRUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_ENTRUSTLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSTLIST
        INTO V_ENTRUSTLIST;
      EXIT WHEN C_ENTRUSTLIST%NOTFOUND OR C_ENTRUSTLIST%NOTFOUND IS NULL;
      PG_EWIDE_TS_01.SP_CANCLE_TS_ENTPZSEQNO_01(V_ENTRUSTLIST.ETLBATCH,
                                                V_ENTRUSTLIST.ETLSEQNO,
                                                P_OPER,
                                                'N');
    END LOOP;
    IF C_ENTRUSTLIST%ISOPEN THEN
      CLOSE C_ENTRUSTLIST;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSTLIST%ISOPEN THEN
        CLOSE C_ENTRUSTLIST;
      END IF;
      ROLLBACK;
      RAISE;
  END;

  ---------------------------------------------------------------------------
  --                        撤销托收导入
  --name:sp_cancle_ts_imp_01
  --note:撤销托收导入
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_ts_imp_01 撤销托收导入
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH IN VARCHAR2,
                                P_COMMIT        IN VARCHAR2) IS

    V_TS_LOG ENTRUSTLOG%ROWTYPE; --托收日志
    V_TEST   VARCHAR2(10);
    V_EXIT   NUMBER(10);
  BEGIN
    IF P_ENTRUST_BATCH IS NULL THEN
      V_TEST := '000';
    END IF;
    BEGIN
      SELECT *
        INTO V_TS_LOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_ENTRUST_BATCH
         AND ELCHARGETYPE = 'T';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '托收批次号[' || P_ENTRUST_BATCH || ']不存在,请检查!');
    END;
    --撤销检查
    IF V_TS_LOG.ELSTATUS = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次号[' || P_ENTRUST_BATCH ||
                              ']已作废,无需要取消导入!');
    END IF;
    IF V_TS_LOG.ELPAIDDATE IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次号[' || P_ENTRUST_BATCH ||
                              ']已经销帐处理[销帐日期不为空]，不能取消导入!');
    END IF;
    IF V_TS_LOG.ELPAIDROWS > 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次号[' || P_ENTRUST_BATCH ||
                              ']已经销帐处理[销帐记录条件大于0]，不能取消导入!');
    END IF;
    IF V_TS_LOG.ELCHKNUM < 1 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '该托收代扣批次[' || P_ENTRUST_BATCH ||
                              ']没有导入，无需要取消导入！');
    END IF;
    SELECT COUNT(*)
      INTO V_EXIT
      FROM ENTRUSTLIST
     WHERE ETLPAIDFLAG = 'Y'
       AND ETLBATCH = P_ENTRUST_BATCH;
    IF V_EXIT > 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次号[' || P_ENTRUST_BATCH ||
                              ']已经销帐处理，不能取消导入!');
    END IF;
    --更新代扣发出日志有效标志
    UPDATE ENTRUSTLOG
       SET ELCHKEND   = 'N',
           ELCHKNUM   = 0,
           ELPAIDJE   = 0,
           ELPAIDROWS = 0,
           ELPAIDDATE = NULL,
           ELFJE      = 0,
           ELFROWS    = 0,
           ELFCHKDATE = NULL,
           ELSJE      = 0,
           ELSROWS    = 0,
           ELSCHKDATE = NULL,
           ELCHKJE    = 0,
           ELCHKROWS  = 0,
           ELCHKDATE  = NULL
     WHERE ELBATCH = P_ENTRUST_BATCH
       AND ELCHARGETYPE = 'T';
    UPDATE ENTRUSTLIST
       SET ETLRETURNCODE = NULL,
           ETLRETURNMSG  = NULL,
           ETLCHKDATE    = NULL,
           ETLSFLAG      = 'N'
     WHERE ETLBATCH = P_ENTRUST_BATCH;
    --提交
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  --生成托收文件名函数
  ---------------------------------------------------------------------------
  --                        生成托收文件名函数
  --name:fgettsexpname
  --note:生成托收文件名函数
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --       p_batch 托收批次号
  --return TSDS(4位)+银行编号(6位)+日期(8位)+批次号+(10位)
  -- 如:DK03001200904280000000001
  ---------------------------------------------------------------------------
  FUNCTION FGETTSEXPNAME(P_TYPE   IN VARCHAR2,
                         P_BANKID IN VARCHAR2,
                         P_BATCH  IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET VARCHAR2(100);
    ETLOG ENTRUSTLOG%ROWTYPE;
  BEGIN
    --生成托收文件名 格式：TSDS(4位)+银行编号(6位)+日期(8位)+批次号+(10位)
    -- 如:TS031200904280000000001
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;
    IF P_BATCH IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入批次为空,请系统管理员检查!');
    END IF;
    BEGIN
      SELECT * INTO ETLOG FROM ENTRUSTLOG WHERE ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '托收批次不存在!');
    END;
    IF P_TYPE = '01' THEN

      V_RET := FPARA(P_BANKID, 'TSEXPNAME') ||
               TO_CHAR(ETLOG.ELOUTDATE, 'yymmdd');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --取托收导出格文件类型
  ---------------------------------------------------------------------------
  --                        取托收导出格文件类型
  --name:fgettsexpfiletype
  --note:取托收导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSEXPTYPE');

    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  FUNCTION FGETTSEXPFILEPATH(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN
      V_RETSQL := FPARA(P_BANKID, 'TSLPATH');
    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  FUNCTION FGETTSEXPFILEGS(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSEXP');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  FUNCTION FGETTSEXPFILEHZ(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSFILETAIL');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;
  --取托收导入格文件类型
  ---------------------------------------------------------------------------
  --                        取托收导入格文件类型
  --name:fgettsimpfiletype
  --note:取托收导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSIMPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSIMPTYPE');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --取托收导入格式字符串
  ---------------------------------------------------------------------------
  --                        取托收导入格式字符串
  --name:fgettsimpsqlstr
  --note:取托收导入格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------
  FUNCTION FGETTSIMPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;
    IF P_TYPE = '01' THEN

      V_RETSQL := FPARA(P_BANKID, 'TSIMP');

    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --取托收导出格式字符串
  ---------------------------------------------------------------------------
  --                        取托收导出格式字符串
  --name:fgetdkexpsqlstr
  --note:取托收导出格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2 IS
    V_RETSQL VARCHAR2(2000);
  BEGIN
    IF P_TYPE IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入类型为空,请系统管理员检查!');
    END IF;
    IF P_BANKID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '传入银行为空,请系统管理员检查!');
    END IF;

    IF P_TYPE = '01' THEN
      V_RETSQL := FPARA(P_BANKID, 'TSEXP');
    ELSE
      RETURN NULL;
    END IF;
    RETURN V_RETSQL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN NULL;
  END;

  --托收数据导入过程
  ---------------------------------------------------------------------------
  --                        托收数据导入过程
  --name:sq_dkfileimp
  --note:托收数据导入过程
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP_BAK(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2) IS
    ETSL     ENTRUSTLIST%ROWTYPE;
    ETSLTEMP ENTRUSTLIST%ROWTYPE;
    ETRG     ENTRUSTLOG%ROWTYPE;
    TYPE CUR IS REF CURSOR;
    C_IMP CUR;
    CURSOR C_ENTRUSLIST(BATCH VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = BATCH
         AND ETLSFLAG = 'N'
         AND ETLPAIDFLAG = 'N';
    V_SQL            VARCHAR2(10000);
    V_SQLIMPCUR      VARCHAR2(10000);
    V_MULTIFILE      VARCHAR2(1);
    V_MULTIIMP       VARCHAR2(1);
    V_MULTISUCCCOUNT NUMBER(10);
    V_ALLCOUNT       NUMBER(10);
  BEGIN
    /*    v_multifile := fsyspara('0045');
    v_multiimp  := fsyspara('0046');*/
    /*    if v_multifile is null or v_multifile not in ('Y', 'N') THEN
      raise_application_error(errcode, '托收是否分文件对账标志设置错误!');
    END IF;*/
    /*    if v_multiimp is null or v_multiimp not in ('Y', 'N') THEN
      raise_application_error(errcode, '托收是否多次对账标志设置错误!');
    END IF;*/
    BEGIN
      SELECT * INTO ETRG FROM ENTRUSTLOG T WHERE T.ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '托收批次不存在!');
    END;
    IF ETRG.ELCHKEND = 'Y' THEN
      SP_CANCLE_TS_IMP_01(P_BATCH, 'N');
    END IF;
    V_SQL := TRIM(FGETTSIMPSQLSTR('01', ETRG.ELBANKID));
    IF V_SQL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '托收导入格式未定义!');
    END IF;
    OPEN C_ENTRUSLIST(P_BATCH);
    FETCH C_ENTRUSLIST
      INTO ETSL;
    IF C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL THEN
      CLOSE C_ENTRUSLIST;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次[' || P_BATCH || ']已经全部对帐!');
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;

    OPEN C_ENTRUSLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSLIST
        INTO ETSL;
      EXIT WHEN C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL;

      V_SQLIMPCUR := REPLACE(V_SQL, '@PARM1', '''' || ETSL.ETLSEQNO || '''');
      OPEN C_IMP FOR V_SQLIMPCUR;
      FETCH C_IMP
        INTO ETSLTEMP;
      IF C_IMP%ROWCOUNT > 1 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '托收流水[' || ETSLTEMP.ETLSEQNO || ']重复!');
      END IF;
      IF C_IMP%FOUND THEN
        --导入检查
        IF TRIM(ETSL.ETLSEQNO) <> TRIM(ETSLTEMP.ETLSEQNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '系统流水号[' || ETSL.ETLSEQNO || ']' ||
                                  '实际系统流水号[' || ETSL.ETLSEQNO || ']' || '与[' ||
                                  ETSLTEMP.ETLSEQNO || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF TRIM(ETSL.ETLBANKIDNO) <> TRIM(ETSLTEMP.ETLBANKIDNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' ||
                                  '开户银行实际编号[' || ETSL.ETLBANKIDNO || ']' || '与[' ||
                                  ETSLTEMP.ETLBANKIDNO || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF TRIM(ETSL.ETLACCOUNTNAME) <> TRIM(ETSLTEMP.ETLACCOUNTNAME) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' || '开户名[' ||
                                  ETSL.ETLACCOUNTNAME || ']' || '与[' ||
                                  ETSLTEMP.ETLACCOUNTNAME || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF ETSL.ETLJE <> ETSLTEMP.ETLJE THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' || '扣款金额[' ||
                                  ETSL.ETLJE || ']' || '与[' ||
                                  ETSLTEMP.ETLJE || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF ETSLTEMP.ETLSFLAG NOT IN ('Y', 'N') THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '银行返回扣款成功标志错误!');
        END IF;

        --扣款信息
        UPDATE ENTRUSTLIST
           SET ETLSFLAG      = ETSLTEMP.ETLSFLAG,
               ETLCHKDATE    = SYSDATE,
               ETLRETURNCODE = ETSLTEMP.ETLRETURNCODE,
               ETLRETURNMSG  = ETSLTEMP.ETLRETURNMSG,
               ETLCHRMODE    = ETSLTEMP.ETLCHRMODE
         WHERE ETLBATCH = ETSL.ETLBATCH
           AND ETLSEQNO = ETSL.ETLSEQNO;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
    END LOOP;
    V_ALLCOUNT := C_ENTRUSLIST%ROWCOUNT;
    IF C_IMP%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF V_MULTISUCCCOUNT >= V_ALLCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '对帐文件异常!');
    END IF;
    --更新托收头
    BEGIN
      /*
      update entrustlog
         set elchkdate  = sysdate,
             elchkrows  = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutrows else (select count(*)
                                                                                                     from entrustlist
                                                                                                    where etlbatch =
                                                                                                          p_batch
                                                                                                      and etlsflag = 'Y') end), --对帐条数
             eloutmoney = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutmoney else (select sum(etlje)
                                                                                                      from entrustlist
                                                                                                     where etlbatch =
                                                                                                           p_batch
                                                                                                       and etlsflag = 'Y') end), --对帐金额
             elschkdate = (case when v_multifile = 'N' then sysdate else null end),
             elsrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elsje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elfchkdate = sysdate,
             elfrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elfje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = (case when v_multiimp = 'N' then 'Y' when v_multiimp = 'Y' then p_lasttime end),
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
       where ELBATCH = p_batch;*/

      UPDATE ENTRUSTLOG
         SET (ELCHKDATE,
              ELSCHKDATE,
              ELFCHKDATE,
              ELOUTROWS, --发出条数
              ELOUTMONEY, --发出金额
              ELCHKROWS, --对账总条数
              ELCHKJE, --对账总金额
              ELSROWS, --银行成功条数
              ELSJE, --银行成功金额
              ELFROWS, --银行失败条数
              ELFJE, --银行失败金额
              ELPAIDROWS, --本地已销账条数
              ELPAIDJE) --本地已销账金额
              =
             (SELECT SYSDATE,
                     SYSDATE,
                     SYSDATE,
                     COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = P_BATCH),
             ELCHKNUM = NVL(ELCHKNUM, 0) + 1,
             ELCHKEND = 'N',
             ELIMPTYPE = 2,
             ELIMFLAG = 'Y'
       WHERE ELBATCH = P_BATCH;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '更新托收汇总信息失败!');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSLIST%ISOPEN THEN
        CLOSE C_ENTRUSLIST;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
      ROLLBACK;
      RAISE;
  END;
  PROCEDURE SQ_TSFILEIMPFAST(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2) IS
    ETSL     ENTRUSTLIST%ROWTYPE;
    ETSLTEMP ENTRUSTLIST%ROWTYPE;
    ETRG     ENTRUSTLOG%ROWTYPE;
    CURSOR C_IMP(P_ETLSEQNO VARCHAR2) IS
      SELECT * FROM ENTRUSTLISTTEMP WHERE ETLSEQNO = P_ETLSEQNO;
    CURSOR C_ENTRUSLIST(BATCH VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLIST
       WHERE ETLBATCH = BATCH
         AND (ETLSFLAG = 'N' AND ETLPAIDFLAG = 'N');
    V_SQL            VARCHAR2(10000);
    V_SQLIMPCUR      VARCHAR2(10000);
    V_MULTIFILE      VARCHAR2(1);
    V_MULTIIMP       VARCHAR2(1);
    V_MULTISUCCCOUNT NUMBER(10);
    V_ALLCOUNT       NUMBER(10);
  BEGIN
    BEGIN
      SELECT * INTO ETRG FROM ENTRUSTLOG T WHERE T.ELBATCH = P_BATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '托收批次不存在!');
    END;
    IF ETRG.ELCHKEND = 'Y' THEN
      PG_EWIDE_TS_01.SP_CANCLE_TS_IMP_01(P_BATCH, 'N');
    END IF;
    V_SQL := TRIM(PG_EWIDE_TS_01.FGETTSIMPSQLSTR('01', ETRG.ELBANKID));

    IF V_SQL IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '托收导入格式未定义!');
    END IF;
    OPEN C_ENTRUSLIST(P_BATCH);
    FETCH C_ENTRUSLIST
      INTO ETSL;
    IF C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL THEN
      CLOSE C_ENTRUSLIST;
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '托收批次[' || P_BATCH || ']已经全部对帐!');
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    --清空临时表
    DELETE ENTRUSTLISTTEMP;
    --导入返盘文件到临时表
    V_SQLIMPCUR := REPLACE(V_SQL, '@PARM1', '''' || ETSL.ETLSEQNO || '''');
    EXECUTE IMMEDIATE V_SQLIMPCUR;

    OPEN C_ENTRUSLIST(P_BATCH);
    LOOP
      FETCH C_ENTRUSLIST
        INTO ETSL;
      EXIT WHEN C_ENTRUSLIST%NOTFOUND OR C_ENTRUSLIST%NOTFOUND IS NULL;
      OPEN C_IMP(ETSL.ETLSEQNO);
      FETCH C_IMP
        INTO ETSLTEMP;
      IF C_IMP%ROWCOUNT > 1 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '托收流水[' || ETSLTEMP.ETLSEQNO || ']重复!');
      END IF;
      IF C_IMP%FOUND THEN
        --导入检查
        IF TRIM(ETSL.ETLSEQNO) <> TRIM(ETSLTEMP.ETLSEQNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '系统流水号[' || ETSL.ETLSEQNO || ']' ||
                                  '实际系统流水号[' || ETSL.ETLSEQNO || ']' || '与[' ||
                                  ETSLTEMP.ETLSEQNO || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF TRIM(ETSL.ETLBANKIDNO) <> TRIM(ETSLTEMP.ETLBANKIDNO) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' ||
                                  '开户银行实际编号[' || ETSL.ETLBANKIDNO || ']' || '与[' ||
                                  ETSLTEMP.ETLBANKIDNO || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF TRIM(ETSL.ETLACCOUNTNAME) <> TRIM(ETSLTEMP.ETLACCOUNTNAME) THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' || '开户名[' ||
                                  ETSL.ETLACCOUNTNAME || ']' || '与[' ||
                                  ETSLTEMP.ETLACCOUNTNAME || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF ETSL.ETLJE <> ETSLTEMP.ETLJE THEN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '资料号[' || ETSL.ETLMCODE || ']' || '扣款金额[' ||
                                  ETSL.ETLJE || ']' || '与[' ||
                                  ETSLTEMP.ETLJE || ']' ||
                                  '导出文件与导入电子文档的不一致!');
        END IF;
        IF ETSLTEMP.ETLSFLAG NOT IN ('Y', 'N') THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '银行返回扣款成功标志错误!');
        END IF;

        --扣款信息
        UPDATE ENTRUSTLIST
           SET ETLSFLAG      = ETSLTEMP.ETLSFLAG,
               ETLCHKDATE    = SYSDATE,
               ETLRETURNCODE = ETSLTEMP.ETLRETURNCODE,
               ETLRETURNMSG  = ETSLTEMP.ETLRETURNMSG,
               ETLCHRMODE    = ETSLTEMP.ETLCHRMODE
         WHERE ETLBATCH = ETSL.ETLBATCH
           AND ETLSEQNO = ETSL.ETLSEQNO;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
    END LOOP;
    V_ALLCOUNT := C_ENTRUSLIST%ROWCOUNT;
    IF C_IMP%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF C_ENTRUSLIST%ISOPEN THEN
      CLOSE C_ENTRUSLIST;
    END IF;
    IF V_MULTISUCCCOUNT >= V_ALLCOUNT THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '对帐文件异常!');
    END IF;
    --更新托收头
    BEGIN
      UPDATE ENTRUSTLOG
         SET (ELCHKDATE,
              ELSCHKDATE,
              ELFCHKDATE,
              ELOUTROWS, --发出条数
              ELOUTMONEY, --发出金额
              ELCHKROWS, --对账总条数
              ELCHKJE, --对账总金额
              ELSROWS, --银行成功条数
              ELSJE, --银行成功金额
              ELFROWS, --银行失败条数
              ELFJE, --银行失败金额
              ELPAIDROWS, --本地已销账条数
              ELPAIDJE) --本地已销账金额
              =
             (SELECT SYSDATE,
                     SYSDATE,
                     SYSDATE,
                     COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = P_BATCH),
             ELCHKNUM = NVL(ELCHKNUM, 0) + 1,
             ELCHKEND = 'N',
             ELIMPTYPE = 2,
             ELIMFLAG = 'Y'
       WHERE ELBATCH = P_BATCH;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '更新托收汇总信息失败!');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSLIST%ISOPEN THEN
        CLOSE C_ENTRUSLIST;
      END IF;
      IF C_IMP%ISOPEN THEN
        CLOSE C_IMP;
      END IF;
      ROLLBACK;
      RAISE;
  END;
  PROCEDURE SQ_TSFILEIMP(P_BATCH    IN VARCHAR2,
                         P_COUNT    IN NUMBER,
                         P_LASTTIME IN VARCHAR2) IS
  BEGIN
    SQ_TSFILEIMPFAST(P_BATCH, P_COUNT, P_LASTTIME);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  --托收批次销帐和解锁 by lgb 2012-09-22
  PROCEDURE SP_TSPOS(P_BATCH  IN VARCHAR2, --代扣批次流水 序列
                     P_OPER   IN VARCHAR2, ----销帐员
                     P_COMMIT IN VARCHAR2 --提交标志
                     ) IS
    V_COUNT NUMBER(10);
    CURSOR C_ENTRUSTLOG(VID VARCHAR2) IS
      SELECT *
        FROM ENTRUSTLOG
       WHERE ELBATCH = VID
         AND ELCHARGETYPE = PG_EWIDE_PAY_01.PAYTRANS_TS; --被锁直接抛出
    ELOG ENTRUSTLOG%ROWTYPE;

    CURSOR C_ENTRUSTLIST(VID VARCHAR2) IS
      SELECT * FROM ENTRUSTLIST WHERE ETLBATCH = VID;
    --AND ETLSFLAG = 'Y'; --被锁直接抛出
    ELIST ENTRUSTLIST%ROWTYPE;

    --注：回盘重复销帐规则：代扣成功金额预存
    CURSOR C_RL(VBATCH VARCHAR2, VSEQNO VARCHAR2) IS
      SELECT *
        FROM RECLIST
       WHERE RLENTRUSTBATCH = VBATCH
         AND RLENTRUSTSEQNO = VSEQNO
         AND RLOUTFLAG = 'Y'
         AND RLCD = PG_EWIDE_PAY_01.DEBIT
       ORDER BY RLID; --被锁直接抛出

    CURSOR C_MI(VMID VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID; --被锁直接抛出

    CURSOR C_CI(VCID VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID; --被锁直接抛出

    I          NUMBER;
    MI         METERINFO%ROWTYPE;
    VP         PAYMENT%ROWTYPE;
    RL         RECLIST%ROWTYPE;
    PL         PAIDLIST%ROWTYPE;
    CI         CUSTINFO%ROWTYPE;
    VPIID      VARCHAR2(100);
    VZNJ       VARCHAR2(100);
    VPLJE      NUMBER;
    VPID       VARCHAR2(10); --预存返回pid
    V_SXFCOUNT NUMBER(10); --手续费回到第一条应收对应的实收上
    V_SXF      NUMBER(12, 2); --手续费
    V_RET      VARCHAR2(5);
  BEGIN
    FOR I IN 1 .. TOOLS.FBOUNDPARA(P_BATCH) LOOP
      --取发出批次信息
      OPEN C_ENTRUSTLOG(TOOLS.FGETPARA(P_BATCH, I, 1));
      FETCH C_ENTRUSTLOG
        INTO ELOG;
      IF C_ENTRUSTLOG%NOTFOUND OR C_ENTRUSTLOG%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的代扣批次' || P_BATCH);
      END IF;
      --游标批次下明细流水
      OPEN C_ENTRUSTLIST(ELOG.ELBATCH);
      FETCH C_ENTRUSTLIST
        INTO ELIST;
      IF C_ENTRUSTLIST%NOTFOUND OR C_ENTRUSTLIST%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '无效销账记录，请检查是否导入扣款成功文件！' || P_BATCH);
      END IF;
      WHILE C_ENTRUSTLIST%FOUND LOOP
        IF ELIST.ETLPAIDFLAG = 'N' AND ELIST.ETLSFLAG = 'Y' THEN

          ------------------------------
          --游标批次、明细流水下应收流水（考虑合帐代扣）
          VPLJE      := 0; --累计销帐金额
          V_SXFCOUNT := 0;
          OPEN C_RL(ELIST.ETLBATCH, ELIST.ETLSEQNO);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            NULL;
            --raise_application_error(errcode,'无效的代扣应收帐记录'||elist.etlbatch||','||elist.etlseqno);
          END IF;
          WHILE C_RL%FOUND AND RL.RLPAIDFLAG = 'N' LOOP

            --手续费控制
            IF V_SXFCOUNT = 0 THEN
              V_SXFCOUNT := V_SXFCOUNT + 1;
              V_SXF      := 0;
            ELSE
              V_SXF := ELIST.ETLSXF;
            END IF;
            V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                         ELOG.ELBANKID, --缴费机构
                                         P_OPER, --收款员
                                         RL.RLID || '|', --应收流水
                                         RL.RLJE, --应收金额
                                         RL.RLZNJ, --销帐违约金
                                         V_SXF, --手续费
                                         RL.RLJE + RL.RLZNJ + V_SXF, --实际收款
                                         PG_EWIDE_PAY_01.PAYTRANS_TS, --缴费事务
                                         RL.RLMID, --户号
                                         'TS', --付款方式
                                         RL.RLSMFID, --缴费地点
                                         FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                                         'N', --是否打票  Y 打票，N不打票， R 应收票
                                         '', --发票号
                                         'N' --控制是否提交（Y/N）
                                         );
            IF V_RET <> '000' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '销账失败' || RL.RLMID);
            END IF;
            --累计销帐金额
            VPLJE := VPLJE + RL.RLJE + RL.RLZNJ + V_SXF;
            FETCH C_RL
              INTO RL;
          END LOOP;
          CLOSE C_RL;
          IF ELIST.ETLJE > VPLJE THEN
            --多出补预存

            V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                         ELOG.ELBANKID, --缴费机构
                                         P_OPER, --收款员
                                         NULL, --应收流水
                                         0, --应收金额
                                         0, --销帐违约金
                                         0, --手续费
                                         ELIST.ETLJE - VPLJE, --实际收款
                                         'S', --缴费事务
                                         RL.RLMID, --户号
                                         'TS', --付款方式
                                         ELOG.ELBANKID, --缴费地点
                                         ELIST.ETLBATCH, --缴费事务流水
                                         'N', --是否打票  Y 打票，N不打票， R 应收票
                                         '', --发票号
                                         'N' --控制是否提交（Y/N）
                                         );
            IF V_RET <> '000' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '销账失败' || P_BATCH);
            END IF;
          END IF;

          --回写elist,elog
          UPDATE ENTRUSTLIST
             SET ETLPAIDDATE = VP.PDATETIME, ETLPAIDFLAG = 'Y'
           WHERE ETLBATCH = ELIST.ETLBATCH
             AND ETLSEQNO = ELIST.ETLSEQNO;
          /*          update entrustlog
            set elpaiddate = vp.pdatetime,
                elpaidrows = nvl(elpaidrows, 0) + 1,
                elpaidje   = nvl(elpaidje, 0) + elist.etlje
          where elbatch = elist.etlbatch;*/
          UPDATE RECLIST
             SET RLOUTFLAG = 'N'
           WHERE RLENTRUSTBATCH = ELIST.ETLBATCH
             AND RLENTRUSTSEQNO = ELIST.ETLSEQNO;

        ELSE
          --elist游标内若最后返盘则解锁应收，否则只解锁代扣成功的应收
          UPDATE RECLIST
             SET RLOUTFLAG = 'N'
           WHERE RLENTRUSTBATCH = ELIST.ETLBATCH
             AND RLENTRUSTSEQNO = ELIST.ETLSEQNO;
          NULL;
        END IF;
        COMMIT;
        FETCH C_ENTRUSTLIST
          INTO ELIST;
      END LOOP;
      CLOSE C_ENTRUSTLIST;
      CLOSE C_ENTRUSTLOG;

      --如果银行销帐条数等于本地销帐时,结束终止导入标志

      SELECT COUNT(*)
        INTO V_COUNT
        FROM ENTRUSTLOG
       WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1)
         AND ELSROWS = ELPAIDROWS;

      IF V_COUNT > 0 THEN
        UPDATE ENTRUSTLOG
           SET ELCHKEND = 'Y'
         WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1)
           AND ELSROWS = ELPAIDROWS;
      END IF;
      UPDATE ENTRUSTLOG
         SET (ELOUTROWS, --发出条数
              ELOUTMONEY, --发出金额
              ELCHKROWS, --对账总条数
              ELCHKJE, --对账总金额
              ELSROWS, --银行成功条数
              ELSJE, --银行成功金额
              ELFROWS, --银行失败条数
              ELFJE, --银行失败金额
              ELPAIDROWS, --本地已销账条数
              ELPAIDJE) --本地已销账金额
              =
             (SELECT COUNT(*),
                     SUM(ETLJE),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'Y', ETLJE, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', 1, 0)),
                     SUM(DECODE(ETLSFLAG, 'N', ETLJE, 0)),
                     SUM(DECODE(EL.ETLPAIDFLAG, 'Y', 1, 0)),
                     SUM(DECODE(ETLPAIDFLAG, 'Y', ETLJE, 0))
                FROM ENTRUSTLIST EL
               WHERE EL.ETLBATCH = TOOLS.FGETPARA(P_BATCH, I, 1))
       WHERE ELBATCH = TOOLS.FGETPARA(P_BATCH, I, 1);
    END LOOP;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_ENTRUSTLOG%ISOPEN THEN
        CLOSE C_ENTRUSTLOG;
      END IF;
      IF C_ENTRUSTLIST%ISOPEN THEN
        CLOSE C_ENTRUSTLIST;
      END IF;
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE SP_TS_EXP(P_TYPE  IN VARCHAR2, --导出类
                      P_BATCH IN VARCHAR2, --导出批次
                      O_BASE  OUT TOOLS.OUT_BASE) IS
    V_SQLSTR  VARCHAR2(2000);
    V_BANKID  VARCHAR2(10);
    V_TEMPSTR VARCHAR2(30000);
    V_CLOB    CLOB;
    EF        ENTRUSTFILE%ROWTYPE;
    ETLOG     ENTRUSTLOG%ROWTYPE;
    TYPE CUR IS REF CURSOR;
    C_CDK        CUR;
    V_SMFID      VARCHAR2(2000);
    V_SMFNAME    VARCHAR2(2000);
    V_SMPPVALUE1 VARCHAR2(2000);
    V_SMPPVALUE2 VARCHAR2(2000);
    CURSOR C_FTPPATH(VSMFID IN VARCHAR2) IS
      SELECT SMFID, SMFNAME, B.SMPPVALUE, A.SMPPVALUE
        FROM SYSMANAFRAME, SYSMANAPARA A, SYSMANAPARA B
       WHERE SMFID = A.SMPID
         AND SMFID = B.SMPID
         AND A.SMPPID = 'FTPDKDIR'
         AND B.SMPPID = 'FTPDKSRV'
         AND SMFID = VSMFID;

  BEGIN
    BEGIN
      SELECT *
        INTO ETLOG
        FROM ENTRUSTLOG
       WHERE ELBATCH = P_BATCH
         AND ELOUTMONEY > 0;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN;
        RAISE_APPLICATION_ERROR(-20012, '托收批次不存在,请检查!');
    END;
    IF FSYSPARA('TS01') = 'Y' THEN
      V_BANKID := ETLOG.ELBANKID;
      V_SQLSTR := PG_EWIDE_TS_01.FGETTSEXPSQLSTR(P_TYPE, V_BANKID);
    ELSE
      V_SQLSTR := FSYSPARA('0044');
    END IF;

    IF V_SQLSTR IS NULL THEN
      RETURN;
      RAISE_APPLICATION_ERROR(-20012, '该银行代扣格式未定义请检查!');
    END IF;
    V_SQLSTR := REPLACE(V_SQLSTR, '@PARM1', '''' || P_BATCH || '''');
    IF P_TYPE = '01' THEN
      OPEN O_BASE FOR V_SQLSTR;
    ELSIF P_TYPE = '02' THEN
      DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);
      OPEN C_CDK FOR 'select c1 from ( ' || V_SQLSTR || ' )';
      LOOP
        FETCH C_CDK
          INTO V_TEMPSTR;
        EXIT WHEN C_CDK%NOTFOUND OR C_CDK%NOTFOUND IS NULL;
        V_TEMPSTR := V_TEMPSTR || CHR(13) || CHR(10);
        DBMS_LOB.WRITEAPPEND(V_CLOB, LENGTH(V_TEMPSTR), V_TEMPSTR);
      END LOOP;
      CLOSE C_CDK;
      OPEN C_FTPPATH(ETLOG.ELBANKID);
      FETCH C_FTPPATH
        INTO V_SMFID, V_SMFNAME, V_SMPPVALUE1, V_SMPPVALUE2;
      IF C_FTPPATH%FOUND THEN
        SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
        --EF.EFID                     :=   ;--代扣文档流水
        EF.EFSRVID       := V_SMPPVALUE1; --存放机器标识（文件服务本地pfile.ini中标识）
        EF.EFPATH        := V_SMPPVALUE2; --存放路径
        EF.EFFILENAME    := FGETTSEXPNAME('01', ETLOG.ELBANKID, P_BATCH) ||
                            '.TXT'; --代扣文档名
        EF.EFELBATCH     := P_BATCH; --代扣批次
        EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--代扣文档
        EF.EFSOURCE      := '自来水公司系统自动生成'; --文档来源
        EF.EFNEWDATETIME := SYSDATE; --文档创建时间
        --EF.EFSYNDATETIME            :=  ;--文档同步时间
        EF.EFFLAG := '0'; --文档标志位
        --EF.EFREADDATETIME           :=  ;--文档访问时间
        EF.EFMEMO := '自来水公司系统自动生成'; --文档说明

        INSERT INTO ENTRUSTFILE VALUES EF;
        --插入空文件
        SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
        EF.EFFILENAME := EF.EFFILENAME || '.CHK';
        EF.EFFILEDATA := C2B('0'); --v_cdk.c1 ;--代扣文档
        INSERT INTO ENTRUSTFILE VALUES EF;
        COMMIT;
      END IF;
      CLOSE C_FTPPATH;

    ELSE
      RETURN;
      --raise_application_error(-20012, '暂不支持此类型银行代扣数据导出!');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CDK%ISOPEN THEN
        CLOSE C_CDK;
      END IF;
      IF C_FTPPATH%ISOPEN THEN
        CLOSE C_FTPPATH;
      END IF;
      ROLLBACK;
  END;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:取污水的水量
  --author:刘光波
  --date：2011/11/10
  --input: pc 批次号
  --       tsh  托收号
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSSL_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER AS
    DJ NUMBER;
  BEGIN
    SELECT SUM(RDSL)
      INTO DJ
      FROM RECLIST R2, RECDETAIL
     WHERE RLID = RDID
       AND RLENTRUSTBATCH = PC
       AND RLCCODE IN (SELECT MICODE FROM METERINFO WHERE MIUIID = TSH)
       AND RDPIID = '04'
       AND RDJE > 0
       AND RLIFTAX = 'Y';
    RETURN DJ;
  END;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:取污水的金额
  --author:刘光波
  --date：2011/11/10
  --input: pc 批次号
  --       tsh  托收号
  ---------------------------------------------------------------------------

  FUNCTION F_GETWZTSJE_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER AS
    JE NUMBER;
  BEGIN
    SELECT SUM(RDJE)
      INTO JE
      FROM RECLIST R2, RECDETAIL
     WHERE RLID = RDID
       AND RLENTRUSTBATCH = PC
       AND RLCCODE IN (SELECT MICODE FROM METERINFO WHERE MIUIID = TSH)
       AND RDPIID = '04'
       AND RLIFTAX = 'Y';
    RETURN JE;
  END;
END;
/


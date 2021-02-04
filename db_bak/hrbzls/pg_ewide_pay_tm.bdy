CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_PAY_TM" IS
  CURDATE DATE;

  --实时欠费金额（含违约金）
  --返回总金额包括违约金
  FUNCTION GETREC(P_MID IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
    MI     METERINFO%ROWTYPE;
  BEGIN
    SELECT * INTO MI FROM METERINFO T WHERE MIID = P_MID;
    SELECT SUM(RLJE + GETZNJADJ(RLID,
                                RLJE,
                                RLGROUP,
                                RLZNDATE,
                                MI.MISMFID,
                                TRUNC(SYSDATE)))
      INTO RESULT
      FROM RECLIST T
     WHERE T.RLPAIDFLAG = 'N'
       AND RLCD = 'DE'
       AND RLOUTFLAG = 'N';

    RETURN NVL(RESULT, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --实时欠费金额
  --返回总金额包括违约金，同时有2个输出参数（应收金额 和 违约金）
  FUNCTION GETREC(P_MID   IN VARCHAR2,
                  P_RECJE OUT RECLIST.RLJE%TYPE,
                  P_ZNJ   OUT RECLIST.RLZNJ%TYPE) RETURN NUMBER IS

    RESULT NUMBER;
    MI     METERINFO%ROWTYPE;
  BEGIN

    SELECT * INTO MI FROM METERINFO T WHERE MIID = P_MID;

    SELECT NVL(SUM(T.RLJE), 0),
           NVL(SUM(GETZNJADJ(T.RLID,
                             T.RLJE,
                             T.RLGROUP,
                             T.RLZNDATE,
                             MI.MISMFID, --使用当前营业所号计算违约金
                             TRUNC(SYSDATE))),
               0)
      INTO P_RECJE, P_ZNJ
      FROM RECLIST T
     WHERE T.RLMID = P_MID
       AND T.RLPAIDFLAG = 'N'
       AND RLOUTFLAG = 'N';

    RESULT := P_RECJE + P_ZNJ;
    --返回欠费总和
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --取滞纳金宽限比例
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --滞纳金类别
                       P_SMFID   IN VARCHAR2, --营业所
                       P_RLGROUP IN VARCHAR2 --应收分帐号
                       ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPVALUE, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --取滞纳金宽限天数
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --滞纳金类别
                     P_SMFID   IN VARCHAR2, --营业所
                     P_RLGROUP IN VARCHAR2 --应收分帐号
                     ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPDAY, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --违约金计算子函数（含节假日规则，不含减免规则）
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --营业所
                  P_RLGROUP IN VARCHAR2, --应收分帐号
                  P_SDATE   IN DATE, --起算日'计入'违约日
                  P_EDATE   IN DATE, --终算日'不计入'违约日
                  P_JE      IN NUMBER) --违约金本金
   RETURN NUMBER IS
    VRESULT NUMBER := 0;
    V_DAY   NUMBER;
    V_SCALE NUMBER;
  BEGIN
    IF P_SDATE IS NULL OR P_EDATE IS NULL THEN
      RETURN 0;
    END IF;

    BEGIN
      IF 全公司统一标准收滞纳金 = '1' THEN
        --取宽限天数、比例参数
        SELECT NVL(ZPVALUE, 0), NVL(ZPDAY, 0)
          INTO V_SCALE, V_DAY
          FROM ZNJPARME T
         WHERE ZPTYPE = 全公司统一标准收滞纳金
           AND (ZPTYPE = 全公司统一标准收滞纳金)
           AND ZPGROUP = P_RLGROUP
           AND ZPFLAG = 'Y';
      END IF;
      IF 全公司统一标准收滞纳金 = '2' THEN
        --取宽限天数、比例参数
        SELECT NVL(ZPVALUE, 0), NVL(ZPDAY, 0)
          INTO V_SCALE, V_DAY
          FROM ZNJPARME T
         WHERE ZPTYPE = 全公司统一标准收滞纳金
           AND (ZPTYPE = 全公司统一标准收滞纳金 AND ZPSMFID = P_SMFID)
           AND ZPGROUP = P_RLGROUP
           AND ZPFLAG = 'Y';
      END IF;
      --滞缴期--计起算日当天、不计算缴费当日
      SELECT NVL(COUNT(*) - SUM(CALIFHOL) - V_DAY, 0)
        INTO VRESULT
        FROM CALENDAR
       WHERE CALDATE >= TRUNC(P_SDATE)
         AND CALDATE <= TRUNC(P_EDATE);

      --全局宽限天数、比例参数
      IF VRESULT <= 0 THEN
        RETURN 0;
      ELSE
        --结果滞纳金
        VRESULT := ROUND(VRESULT * NVL(P_JE, 0) * V_SCALE, 8);
        RETURN TRUNC(VRESULT, 2);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;

  END;

  --违约金计算（含节假日规则，含减免规则）
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --应收流水
                     P_RLJE     IN NUMBER, --应收金额
                     P_RLGROUP  IN NUMBER, --应收组号
                     P_RLZNDATE IN DATE, --滞纳金起算日
                     P_SMFID    VARCHAR2, --水表营业所
                     --P_RL
                     P_EDATE IN DATE --终算日'不计入'违约日
                     ) RETURN NUMBER IS
    CURSOR C_ZAL IS
      SELECT *
        FROM ZNJADJUSTLIST
       WHERE ZALRLID = P_RLID
         AND ZALSTATUS = 'Y'
         AND (TRUNC(SYSDATE) <= ZALZNDATE OR ZALZNDATE IS NULL);
    ZAL         ZNJADJUSTLIST%ROWTYPE;
    JE          NUMBER;
    V_MID       VARCHAR(10);
    V_RLMIEMAIL VARCHAR2(64);
  BEGIN
    BEGIN
      SELECT RLMID, RLMIEMAIL
        INTO V_MID, V_RLMIEMAIL
        FROM RECLIST RL
       WHERE RL.RLID = P_RLID;
      IF V_RLMIEMAIL IS NOT NULL THEN
        RETURN 0;
      END IF;
      IF F_GETIFZNJ(V_MID) = 'N' THEN
        RETURN 0;
      END IF;
    END;
    --异常反回0
    JE := GETZNJ(P_SMFID, P_RLGROUP, P_RLZNDATE, P_EDATE, P_RLJE);
    OPEN C_ZAL;
    FETCH C_ZAL
      INTO ZAL;
    IF C_ZAL%FOUND THEN
      IF ZAL.ZALMETHOD = '1' THEN
        --目标金额减免;
        JE := TOOLS.GETMAX(NVL(ZAL.ZALVALUE, JE), 0);
      ELSIF ZAL.ZALMETHOD = '2' THEN
        --比例金额减免;
        JE := TOOLS.GETMAX(JE * (1 + NVL(ZAL.ZALVALUE, 0)), 0);
      ELSIF ZAL.ZALMETHOD = '3' THEN
        --差额减免;
        JE := TOOLS.GETMAX(JE + NVL(ZAL.ZALVALUE, 0), 0);
      ELSIF ZAL.ZALMETHOD = '4' THEN
        --调整起算日期
        JE := GETZNJ(P_SMFID, P_RLGROUP, ZAL.ZALDATE, P_EDATE, P_RLJE);
      END IF;
    END IF;
    CLOSE C_ZAL;

    RETURN JE;
  EXCEPTION
    WHEN OTHERS THEN

      RETURN 0;
  END;

  /*******************************************************************************************
  新的销帐处理过程由此以下
  *******************************************************************************************/
  /*******************************************************************************************
  函数名：F_PAY_CORE
  用途：核心销帐过程，所有针销帐业务都最终调用本函数实现
  参数：
  返回值：
          000---成功
          其他--失败
  前置条件：
          在临时表RECLIST_1METER_TMP中，准备好所有【待销帐数据】
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                      P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                      P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                      P_RLJE     IN NUMBER, --应收金额
                      P_ZNJ      IN NUMBER, --销帐违约金
                      P_SXF      IN NUMBER, --手续费
                      P_PAYJE    IN NUMBER, --实际收款
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                      P_PAYBATCH IN VARCHAR2, --缴费事务流水
                      P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                      P_INVNO    IN PAYMENT.PILID%TYPE, --发票号
                      P_PAYID    OUT PAYMENT.PID%TYPE --实收流水，返回此次记账的实收流水号
                      ) RETURN VARCHAR2 IS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果

    /*   V_REC_TOTAL NUMBER(10,2);     --总应缴水费
    V_ZNJ_TOTAL NUMBER(10,2);     --总违约金
    V_SXF_TOTAL NUMBER(10,2);     --总手续费*/

    ERR_JE EXCEPTION; --金额错误
    NO_METER EXCEPTION; --无指定水表
    ERR_REC EXCEPTION; --销帐处理错误
    V_CALL NUMBER;

    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    --RL      RECLIST%ROWTYPE;
    --RD      RECDETAIL%ROWTYPE;
    VP       PAYMENT%ROWTYPE;
    V_TEMPRL RECLIST_1METER_TMP%ROWTYPE;
    --V_RDROW NUMBER(10);
    --游标在此说明
    --水表信息
    CURSOR C_MI(VMID VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT; --被锁直接抛出

    --待销帐应收总账记录
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST RT
       WHERE RT.RLID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
       ORDER BY RT.RLGROUP
         FOR UPDATE NOWAIT; --被锁直接抛出

    --待销帐应收明细账记录
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL T
       WHERE T.RDID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
         FOR UPDATE NOWAIT; --被锁直接抛出

    -- 回写明细滞纳金所用临时表记录
    CURSOR C_TEMPRL IS
      SELECT * FROM RECLIST_1METER_TMP;

  BEGIN
    V_RESULT := '000';
    --STEP 1: 检查水表号
    V_STEP    := 1;
    V_PRC_MSG := '检查水表号';

    --取水表信息（不关闭游标，待更新）
    OPEN C_MI(P_MIID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE NO_METER;
    END IF;

    SELECT T.* INTO CI FROM CUSTINFO T WHERE T.CIID = MI.MICID;

    ------STEP 10: 检查各种金额
    --外围检查 ，核心销帐不再进行

    ------STEP 20: 记录实收帐
    V_STEP       := 20;
    V_PRC_MSG    := '记录实收帐';
    P_PAYID      := FGETSEQUENCE('PAYMENT'); --PAYMENT销帐流水，每次销帐交易一条记录
    VP.PID       := P_PAYID;
    VP.PCID      := MI.MICID;
    VP.PCCODE    := CI.CICODE;
    VP.PMID      := MI.MIID;
    VP.PMCODE    := MI.MICODE;
    VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
    VP.PDATETIME := SYSDATE;
    VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
                        TO_CHAR(SYSDATE, 'yyyy.mm'));
    VP.PPOSITION := P_POSITION;

    VP.PTRANS := P_TRANS;
    VP.PCD    := '  ';
    VP.PPER   := P_OPER;
    -----金额字段赋值次序要注意------------------------------
    VP.PCHANGE     := 0;
    VP.PPAYMENT    := P_PAYJE;
    VP.PSAVINGQC   := MI.MISAVING;
    VP.PSPJE       := P_RLJE;
    VP.PSXF        := P_SXF;
    VP.PZNJ        := P_ZNJ;
    VP.PCHANGE     := 0;
    VP.PRCRECEIVED := VP.PPAYMENT - VP.PCHANGE;
    ---每条PAYMENT记录中的金额关系为以下2条
    --预存期末=实收+预存起初-应销水费-手续费-违约金
    VP.PSAVINGQM := VP.PPAYMENT + VP.PSAVINGQC - VP.PSPJE - VP.PZNJ -
                    VP.PSXF;
    --预存本期发生=期末-期初
    VP.PSAVINGBQ := VP.PSAVINGQM - VP.PSAVINGQC;
    ------以上次序不可随意变动------------------------------------------------
    VP.PIFSAVING := (CASE
                      WHEN VP.PSAVINGBQ <> 0 THEN
                       'Y'
                      ELSE
                       'N'
                    END);
    VP.PPAYWAY   := P_FKFS;
    VP.PBATCH    := P_PAYBATCH;
    VP.PPAYEE    := P_OPER;
    VP.PPAYPOINT := P_PAYPOINT;
    VP.PSXF      := P_SXF;
    IF P_IFP = 'Y' THEN
      VP.PILID := P_INVNO; --发票流水号
    END IF;
    VP.PFLAG := 'Y';
    VP.PZNJ  := P_ZNJ;

    VP.PREVERSEFLAG := 'N'; --冲正标志='N'
    INSERT INTO PAYMENT VALUES VP;
    ------- END OF  记录实收帐

    ----是否单缴预存？欠费金额为0 ，则为单缴预存，无需处理应收细节，直接跳转
    IF P_RLJE = 0 THEN
      GOTO PAY_SAVING;
    END IF;

    -------STEP 30: 应收总账销帐处理
    V_STEP    := 30;
    V_PRC_MSG := '应收总账销帐处理';
    -------------------------------------
    --作为前置条件，待销帐记录存放在RECLIST_1METER_TMP，先在临时表中做好计算处理
    V_CALL := 0;
    V_CALL := F_PSET_RECLIST(P_PAYJE,
                             VP.PID,
                             MI.MISAVING,
                             VP.PDATE,
                             VP.PPER);
    IF V_CALL = 0 THEN
      RAISE ERR_REC;
    END IF;

    --再从临时表更新到正式表
    OPEN C_RL; --应收总账加锁
    UPDATE RECLIST T
       SET (T.RLPID, --对应的PAYMENT 流水
            T.RLPBATCH, --实收批次号
            T.RLPAIDFLAG, --销帐标志
            --T.RLPAIDJE,            --销帐金额
            T.RLPAIDDATE, --销帐日期
            T.RLPAIDPER, --收费员
            T.RLZNJ, --违约金
            T.RLPAIDJE, --缴费金额
            T.RLSAVINGQC, --期初预存
            T.RLSAVINGQM, --期末预存
            T.RLSAVINGBQ, --本期发生
            T.RLPAIDMONTH) =
           (SELECT S.RLPID,
                   P_PAYBATCH,
                   'Y',
                   --T.RLJE,
                   VP.PDATE,
                   VP.PPER,
                   S.RLZNJ,
                   S.RLPAIDJE,
                   S.RLSAVINGQC,
                   S.RLSAVINGQM,
                   S.RLSAVINGBQ,
                   VP.PMONTH
              FROM RECLIST_1METER_TMP S
             WHERE T.RLID = S.RLID)
     WHERE T.RLID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RL;
    ----END OF  STEP 30: 应收总账销帐处理----------------------------------------------------------

    ---STEP 40: 应收明细帐销帐处理----------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := '应收明细帐销帐处理';
    -----------------------------------------
    OPEN C_RD; --应收明细帐加锁
    UPDATE RECDETAIL T
       SET T.RDPAIDFLAG  = 'Y', --销帐标志
           T.RDPAIDDATE  = VP.PDATE, --销帐日期
           T.RDPAIDMONTH = VP.PMONTH, --销帐月份
           T.RDPAIDPER   = VP.PPER --收费员
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --应收明细帐解锁


    /******************* 回写滞纳金  by lgb 2012-06-01**********************************/
    OPEN C_RD; --滞纳金清零
    UPDATE RECDETAIL T
       SET T.RDZNJ = 0
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --应收明细帐解锁

    OPEN C_RD; --回写滞纳金
    OPEN C_TEMPRL;
    LOOP
      FETCH C_TEMPRL
        INTO V_TEMPRL;
      EXIT WHEN C_TEMPRL%NOTFOUND OR C_TEMPRL%NOTFOUND IS NULL;
      UPDATE RECDETAIL T
         SET T.RDZNJ =
             (SELECT S.RLZNJ FROM RECLIST_1METER_TMP S WHERE T.RDID = S.RLID)
       WHERE T.RDID = V_TEMPRL.RLID
         AND ROWNUM < 2;
    END LOOP;
    CLOSE C_TEMPRL;
    CLOSE C_RD; --应收明细帐解锁

    ----END OF STEP 40: 应收明细帐销帐处理 ------------------------------------------------

    <<PAY_SAVING>> --单缴预存标签

    ----STEP 50: 预存余额处理-----------------------------------------------------------
    V_STEP    := 50;
    V_PRC_MSG := '预存余额处理';
    --判断本期预存是否变化，有变化再更新水表信息，可以提高一些效率
    IF VP.PSAVINGBQ <> 0 THEN
      UPDATE METERINFO T
         SET T.MISAVING = VP.PSAVINGQM, T.MIPAYMENTID = P_PAYID
       WHERE CURRENT OF C_MI;
      CLOSE C_MI;
    END IF;
    ----END OF  STEP 5: 预存余额处理------------------------------------------------

    --STEP 60: 提交事务---------------------------------------------------------
    V_STEP    := 60;
    V_PRC_MSG := '水表缴费提交';
    /*           IF P_COMMIT = 'Y' THEN
        COMMIT;
    END IF;   */

    RETURN V_RESULT;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_PAY_CORE', V_STEP, V_PRC_MSG, '');
      V_RESULT := '999';
      RETURN V_RESULT;
  END F_PAY_CORE;

  /*******************************************************************************************
  函数名：F_PSET_RECLIST
  用途： 本函数由核心销帐过程调用，调用前【待销帐记录】已经在从RECLIST 中拷贝到临时表中，本函数对临时表进行逐条销帐处理，
  返回主程序后，核心销帐过程根据临时表更新RECLIST ，达到快捷销帐目的。
             逐条处理的目的：将收费金额和预存逐条分配到应收帐记录上，方便打票处理
  例子： A水表，3个月欠费110元，期初预存30元，本次收费100元，违约金5元，应收销帐记录如下：
  ----------------------------------------------------------------------------------------------------
   月     份       预初     本次收费    应缴水费     违约金    预存期末   预存发生
  ----------------------------------------------------------------------------------------------------
  2011.06        30        100           30             1               99             69
  -----------------------------------------------------------------------------------------------------
  2011.08        99         0              40             2                57           -42
  -----------------------------------------------------------------------------------------------------
  2011.10        57         0              40             2                15           -42
  -----------------------------------------------------------------------------------------------------
  参数：P_PAYJE NUMBER，实收金额
           P_REMAIND NUMBER 当前预存
  前置条件：RECLIST_1METER_TMP 里RLID, RLJE,RLZNJ ，RLSXF 都已算好了。
  *******************************************************************************************/
  FUNCTION F_PSET_RECLIST(P_PAYJE   IN NUMBER, --实收金额
                          P_PID     IN PAYMENT.PID%TYPE, --实收流水
                          P_REMAIND IN NUMBER, --当前预存
                          P_DATE    DATE, --销帐日期
                          P_PPER    IN PAYMENT.PPER%TYPE --收款员
                          ) RETURN NUMBER AS
    --应收帐销帐临时表游标,按原应收帐月份排序
    CURSOR C_RL IS
      SELECT T.*
        FROM RECLIST_1METER_TMP T
       ORDER BY T.RLSCRRLMONTH, T.RLGROUP;

    V_RCOUNT NUMBER;
    V_RL     RECLIST%ROWTYPE;
    V_JE_TMP NUMBER; --记录剩余金额
    V_QC     NUMBER;

  BEGIN
    V_RCOUNT := 0;

    OPEN C_RL;
    V_JE_TMP := P_PAYJE;
    V_QC     := P_REMAIND;
    LOOP
      FETCH C_RL
        INTO V_RL;

      EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;

      ----各类金额处理，以下赋值语句次序不可随意变动--------------------------------------------------------------------
      V_RL.RLZNJ := NVL(V_RL.RLZNJ, 0);
      V_RL.RLSXF := NVL(V_RL.RLSXF, 0);

      V_RL.RLPAIDJE   := V_JE_TMP; --销本应收记录时的收费金额
      V_RL.RLSAVINGQC := V_QC; --销本应收记录时的预存期初
      --销本应收记录后的预存期末
      V_RL.RLSAVINGQM := V_RL.RLPAIDJE + V_RL.RLSAVINGQC - V_RL.RLJE -
                         V_RL.RLZNJ - V_RL.RLSXF;
      ----销本应收记录时的预存发生
      V_RL.RLSAVINGBQ := V_RL.RLSAVINGQM - V_RL.RLSAVINGQC;

      V_JE_TMP := 0; --除第一条外，后续每条的实收金额都是0
      V_QC     := V_RL.RLSAVINGQM; --上一条期末，成为下一条期初
      ----金额处理完毕------------------------------------------------------------------------------------------------

      ---更新临时应收表
      UPDATE RECLIST_1METER_TMP T
         SET T.RLPAIDJE   = V_RL.RLPAIDJE,
             T.RLSAVINGQC = V_RL.RLSAVINGQC,
             T.RLSAVINGQM = V_RL.RLSAVINGQM,
             T.RLSAVINGBQ = V_RL.RLSAVINGBQ,
             T.RLPAIDFLAG = 'Y',
             T.RLPID      = P_PID,
             T.RLPAIDDATE = P_DATE,
             T.RLPAIDPER  = P_PPER
       WHERE T.RLID = V_RL.RLID;

      V_RCOUNT := V_RCOUNT + 1;
    END LOOP;

    RETURN V_RCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END F_PSET_RECLIST;

  /*******************************************************************************************
  函数名：F_POS_1METER
  用途：单只水表缴费
      1、单表缴费业务，调用本函数，在PAYMENT 中记一条记录，一个id流水，一个批次
      2、多表缴费业务，通过循环调用本函数实现业务，一只水表一条记录，多个水表一个批次。
  业务规则：
     1、单只水表，非欠费全销，将待销应收id，按xxxxx,xxxxx,xxxxx| 格式存放P_RLIDS, 调用本过程
     2、银行行等代收机构或柜台进行单只水表的欠费全销，P_RLIDS='ALL'
     3、单缴预存，P_RLJE=0
  参数：参见用途说明
     P_PAYBATCH='999999999',则在模块内生成批次号，否则，直接使用P_PAYBATCH作为批次号
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_RLIDS    IN VARCHAR2, --应收流水串
                        P_RLJE     IN NUMBER, --应收总金额
                        P_ZNJ      IN NUMBER, --销帐违约金
                        P_SXF      IN NUMBER, --手续费
                        P_PAYJE    IN NUMBER, --实际收款
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --销帐批次
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
                        ) RETURN VARCHAR2 AS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_SRESULT VARCHAR2(3); --处理结果
    V_NRESULT NUMBER; --处理结果

    V_PAYID VARCHAR2(10); --返回的实收帐流水

    V_MINFO METERINFO%ROWTYPE;

    V_PAYBATCH PAYMENT.PBATCH%TYPE; -- 实收帐批次流水

    V_LAST_PID PAYMENT.PID%TYPE;

    V_LAST_SAVING METERINFO.MISAVING%TYPE;

    ERR_CHK EXCEPTION; --检查未通过
    ERR_RECID EXCEPTION; --应收流水串格式错
    ERR_PAY EXCEPTION; --销账错误
  BEGIN

    ----STEP 1: 应收流水ID分解，准备临时表数据-------------------------------------
    V_STEP    := 1;
    V_PRC_MSG := '应收流水ID分解';
    V_NRESULT := F_SET_REC_TMP(P_RLIDS, P_MIID);
    IF V_NRESULT <= 0 THEN
      RAISE ERR_RECID;
    END IF;
    ----END OF STEP 1:，结果：所有待销帐数据全部在临时表准备好-------------------

    ----STEP 10:  销帐前各项检查-------------------------------------
    V_STEP    := 10;
    V_PRC_MSG := '销帐前各项检查';

    --如水表不存在，则NO_DATA_FOUND 错误
    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    V_NRESULT := F_CHK_LIST(P_RLJE, --应收金额
                            P_ZNJ, --销帐违约金
                            P_SXF, --手续费
                            P_PAYJE, --实际收款
                            V_MINFO.MISAVING --当前预存
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;

    --检查水表预存余额和上次实收记录的预存期末值的相关性
    --取最近一次实收记录
    SELECT MAX(T.PID), COUNT(T.PID)
      INTO V_LAST_PID, V_NRESULT
      FROM PAYMENT T
     WHERE T.PMID = P_MIID;
    --取实收帐的预存期末值
    V_LAST_SAVING := 0;
    IF V_NRESULT > 0 THEN
      SELECT T.PSAVINGQM
        INTO V_LAST_SAVING
        FROM PAYMENT T
       WHERE T.PID = V_LAST_PID;
    END IF;
    --如果预存期末值和水表信息的预存余额不符，则记录异常
    IF V_LAST_SAVING <> V_MINFO.MISAVING THEN
      INSERT INTO CHK_RESULT
      VALUES
        (SEQ_CHK_LIST.NEXTVAL,
         SYSDATE,
         '预存检查',
         '水表信息预存金额和实收帐表预存期末不符！',
         '',
         P_MIID,
         V_LAST_PID,
         '',
         '水表预存余额:' || TO_CHAR(V_MINFO.MISAVING) || '  实收帐预存期末:' ||
         TO_CHAR(V_LAST_SAVING),
         '');
    END IF;
    ----END OF STEP 10:  检查通过,并且返回水表基本信息--------------

    ----STEP 20: 参数准备，为调用核心销帐过程准备参数------------------------------------------------
    V_STEP     := 20;
    V_PRC_MSG  := '参数准备';
    V_PAYBATCH := (CASE
                    WHEN P_PAYBATCH <> '9999999999' THEN
                     P_PAYBATCH
                    ELSE
                     FGETSEQUENCE('ENTRUSTLOG')
                  END);
    --如果还有其他参数需要准备，在此进行

    ----END OF STEP 20: 过程调用参数准备完成------------------------------------------------------------

    ----STEP 30: 调用核心销帐过程销帐-----------------------------------------------------
    V_STEP    := 30;
    V_PRC_MSG := '调用核心销帐过程销帐';
    V_SRESULT := F_PAY_CORE(P_POSITION, --缴费机构
                            P_OPER, --收款员
                            P_MIID, --水表编号
                            P_RLJE, --应收金额
                            P_ZNJ, --销帐违约金
                            P_SXF, --手续费
                            P_PAYJE, --实际收款
                            P_TRANS, --缴费事务
                            P_FKFS, --付款方式
                            P_PAYPOINT, --缴费地点
                            V_PAYBATCH, --缴费事务流水
                            P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                            P_INVNO, --发票号
                            V_PAYID --实收流水，返回此次记账的实收流水号
                            );
    IF V_SRESULT <> '000' THEN
      RAISE ERR_PAY;
    END IF;
    --END OF STEP 30: 单表销帐过程完毕，后台数据变化如下：-----------------
    --PAYMENT 中增加了一条记录，记录实收流水在从V_PAYID返回
    --RECLIST 中，在串P_RLIDS中指定的应收ID，都按照销帐规则进行处理。
    --RECDETAIL中，和指定的应收ID相关的记录，都按照销帐规则进行处理。
    --METERINFO 中，和指定水表号P_MIID相关的记录，预存金额被更新
    ----------------------------------------------------------------------------------------
    ----STEP 40: 事务提交：根据参数判断是否提交---------------------------------------------------------
    IF TRIM(UPPER(P_COMMIT)) = 'Y' THEN
      COMMIT;
    END IF;
    ----END OF STEP 40: 事务提交完成------------------------------------------------
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_1METER', V_STEP, V_PRC_MSG, '');
      RETURN '999';
  END F_POS_1METER;

  /*******************************************************************************************
  函数名：F_POS_MULT_M
  用途：
      多表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，支持水表挑选销帐月份
     2、每只水表都不发生预存变化，收费金额=欠费金额
     3、所有水表的销帐，在PAYMENT中，同一个批次流水。
  参数：
  前置条件：
      1、最重要的销帐参数（水表id，应收帐流水id串，应收金额，违约金，手续费） 在调用本过程前，
       存放在临时接口表 PAY_PARA_TMP
      2、应收帐流水串的格式见核心单表销帐过程的说明。
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_PAYJE    IN NUMBER, --总实际收款金额
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    MID_COUNT NUMBER; --水表只数
    V_INP     NUMBER; --循环变量

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --销账错误
    ERR_JE EXCEPTION; --金额错误

    CURSOR C_M_PAY IS
      SELECT * FROM PAY_PARA_TMP RT;

  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    --生成统一批次号
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');
    V_BATCH := P_BATCH;
    V_TOTAL := 0;
    --调用单表销帐过程，进行逐水表销帐 处理
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --计算单只水表的实际收款金额
      V_PAID_METER := V_PP.RLJE + V_PP.RLZNJ + V_PP.RLSXF;

      V_TOTAL := V_TOTAL + V_PAID_METER;

      ---单表销帐---------------------------------------------------------------------------------
      V_RESULT := F_POS_1METER(P_POSITION, --缴费机构
                               P_OPER, --收款员
                               V_PP.PLIDS, --应收流水串
                               V_PP.RLJE, --应收总金额
                               V_PP.RLZNJ, --销帐违约金
                               V_PP.RLSXF, --手续费
                               V_PAID_METER, -- 水表实际收款
                               P_TRANS, --缴费事务
                               V_PP.MID, --水表资料号
                               P_FKFS, --付款方式
                               P_PAYPOINT, --缴费地点
                               V_BATCH, --自动生成销帐批次
                               P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                               P_INVNO, --发票号
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;
    END LOOP;

    /*--全部水表处理完毕，后台数据影响如下：------------------------------------------------------
    1、【PAYMENT】中，增加了和水表数量相同的记录，实际收费金额=应缴金额（水费、违约金、手续费等）
          没有预存变化，这些记录有相同的批次号。
    2、在应收总账【RECLIST】中，指定水表指定的应收记录，都按照销帐规则进行处理。没有预存的变化
    3、在应收明细【RECDETAIL 】中，和RECLIST中相匹配的记录，都按照销帐规则进行处理。
    ----------------------------------------------------------------------------------------------------*/
    --检查总金额是否相符，否则报错
    IF V_TOTAL <> P_PAYJE THEN
      RAISE ERR_JE;
    END IF;
    --一次性提交-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_M', V_INP, '表号:' || V_PP.MID, '');
      RETURN '999';
  END F_POS_MULT_M;
  /*******************************************************************************************
  函数名：F_POS_MULT_HS
  用途：合收表缴费
  业务规则：
     1、多只水表销帐，每只水表都根据客户端选择的结果返回待销流水id
     2、主表先销帐，所有销帐金额计算到主表期末余额上
     3、逐笔处理子表，主表预存转子表预存，子表预存销帐，
     4、整体事务提交
  参数：
  前置条件：
      水表和水表对应的应收帐流水串，存放在临时接口表 PAY_PARA_TMP 中
  *******************************************************************************************/

  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                         P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --合收主表号
                         P_PAYJE    IN NUMBER, --总实际收款金额
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                         P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                         P_INVNO    IN VARCHAR2, --发票号
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS

    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    MID_COUNT NUMBER; --水表只数
    V_INP     NUMBER; --循环变量

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --销帐批次号
    ERR_PAY EXCEPTION; --销账错误

    V_NRESULT NUMBER; --处理结果

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM PAY_PARA_TMP RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING > 0;
    V_PAYID PAYMENT.PID%TYPE;
  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    V_BATCH := P_BATCH;

    ---STEP 0: 将非合收主表的预存转到主表上去---------------------------------------------------
    OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      V_NRESULT := F_REMAIND_TRANS1(MI.MIID, --转出水表号

                                    P_MMID, --转入水表资料号
                                    MI.MISAVING, --转移金额=该水表销帐金额
                                    V_BATCH, --实收批次号
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: 合收主表销帐---------------------------------------------------
    --生成销帐批次号
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '合收主表销帐';
    BEGIN
      SELECT RT.* INTO V_PP FROM PAY_PARA_TMP RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER(P_POSITION, --缴费机构
                               P_OPER, --收款员
                               V_PP.PLIDS, --应收流水串
                               V_PP.RLJE, --应收总金额
                               V_PP.RLZNJ, --销帐违约金
                               V_PP.RLSXF, --手续费
                               P_PAYJE, -- 水表实际收款
                               P_TRANS, --缴费事务
                               V_PP.MID, --水表资料号
                               P_FKFS, --付款方式
                               P_PAYPOINT, --缴费地点
                               V_BATCH,
                               P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                               P_INVNO, --发票号
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;

    ELSE
      --预存到主表
      ----记转入预存的实收帐-----------------------------------------------------------------
      V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                             P_OPER, --收款员
                             P_MMID, --水表资料号
                             0, --应收金额
                             0, --销帐违约金
                             0, --手续费
                             P_PAYJE, --实际收款
                             PAYTRANS_YCDB, --缴费事务
                             P_FKFS, --付款方式
                             P_PAYPOINT, --缴费地点
                             P_BATCH, --缴费事务批号
                             'N', --是否打票  Y 打票，N不打票， R 应收票
                             '', --发票号
                             V_PAYID --实收流水，返回此次记账的实收流水号
                             );

    END IF;
    ---end of  STEP 1: ---------------------------------------------------

    ---STEP 20: 合收子表销帐---------------------------------------------------
    V_STEP    := 20;
    V_PRC_MSG := '合收子表销帐';
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --计算单只水表的实际收款金额
      V_PAID_METER := 0;
      V_TOTAL      := V_PP.RLJE + V_PP.RLSXF + V_PP.RLZNJ;

      ---STEP 21: 预存调拨---------------------------------------------------
      V_STEP    := 21;
      V_PRC_MSG := '合收子表销帐--预存调拨';
      --
      V_NRESULT := F_REMAIND_TRANS1(P_MMID, --转出水表号
                                    V_PP.MID, --转入水表资料号
                                    V_TOTAL, --转移金额=该水表销帐金额
                                    V_BATCH, --实收批次号
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');
      ---END OF STEP 21 预存调拨完成，后台数据结果------------------------------------------
      -- 在PAYMENT中，增加2条记录，一个为正预存，一个为负预存
      --2条记录同一个批次号，和水表销帐的批次号一样。
      --子表的水表信息中，预存余额增加，增加金额等于主表调拨出的金额
      ------------------------------------------------------------------------------------------------
      ---STEP 22: 子表销帐---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '合收子表销帐--子表销帐';
      V_RESULT  := F_POS_1METER(P_POSITION, --缴费机构
                                P_OPER, --收款员
                                V_PP.PLIDS, --应收流水串
                                V_PP.RLJE, --应收总金额
                                V_PP.RLZNJ, --销帐违约金
                                V_PP.RLSXF, --手续费
                                V_PAID_METER, -- 水表实际收款
                                P_TRANS, --缴费事务
                                V_PP.MID, --水表资料号
                                P_FKFS, --付款方式
                                P_PAYPOINT, --缴费地点
                                V_BATCH,
                                P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                P_INVNO, --发票号
                                'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --一次性提交-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_HS',
                           V_STEP,
                           V_PRC_MSG,
                           '水表资料号:' || V_PP.MID);
      RETURN '999';
  END F_POS_MULT_HS;

  /*******************************************************************************************
  函数名：F_SET_REC_TMP
  用途：为销帐核心过程准备待处理应收数据
  处理过程：
       1、如果是全部销帐，则直接将相应记录从RECLIST拷贝到临时表
       2、如果是部分记录销帐，则根据应收帐流水串，逐条从RECLIST拷贝到临时表
       3、计算违约金、手续费等销帐前计算的金额信息
  参数：
       1、部分销帐，P_RLIDS 应收流水串，格式：XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| 逗号分隔
       2、全部销帐：_RLIDS='ALL'
       3、P_MIID  水表资料号
  返回值：成功--应收流水ID个数，失败--0
  *******************************************************************************************/
  FUNCTION F_SET_REC_TMP(P_RLIDS IN VARCHAR2, P_MIID IN VARCHAR2)
    RETURN NUMBER IS
    V_INP    NUMBER;
    V_RLIDS  VARCHAR2(1280);
    ID_COUNT NUMBER;
    STR_TMP  VARCHAR2(10);
    V_MINFO  METERINFO%ROWTYPE;
  BEGIN
    --首先清空临时表RECLIST_1METER_TMP----------------------------------------------------
    DELETE RECLIST_1METER_TMP;

    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    IF P_RLIDS = 'ALL' THEN
      --全部欠费销帐
      INSERT INTO RECLIST_1METER_TMP
        (SELECT S.*
           FROM RECLIST S
          WHERE S.RLMID = P_MIID --该水表的全部欠费
            AND S.RLPAIDFLAG = 'N'
            AND S.RLJE > 0
            AND S.RLREVERSEFLAG = 'N');
    ELSE
      --部分应收销帐
      V_RLIDS := P_RLIDS || '|';
      --取ID个数
      ID_COUNT := TOOLS.FBOUNDPARA2(V_RLIDS);
      --逐个存入到临时表
      FOR V_INP IN 1 .. ID_COUNT LOOP
        STR_TMP := TOOLS.FGETPARA(V_RLIDS, 1, V_INP);
        --------------------------------------------------------------------------------------
        --是否此处应该直接通过截取的ID值，将应收信息从RECLIST 导出到临时表？
        INSERT INTO RECLIST_1METER_TMP
          (SELECT S.*
             FROM RECLIST S
            WHERE S.RLID = STR_TMP
              AND S.RLMID = P_MIID --此处带入水表资料号的条件，基本可省去后面对水表资料的检查
              AND S.RLPAIDFLAG = 'N'
              AND S.RLJE > 0
              AND S.RLREVERSEFLAG = 'N');
        --还是只插入应收ID？
      --  INSERT INTO RECLIST_1METER_TMP (RLID) VALUES (STR_TMP);
      ---------------------------------------------------------------------------------------
      END LOOP;
    END IF;

    --违约金金额计算到临时表中
    UPDATE RECLIST_1METER_TMP T
       SET T.RLZNJ = GETZNJADJ(T.RLID,
                               T.RLJE,
                               T.RLGROUP,
                               T.RLZNDATE,
                               T.RLMSMFID,
                               TRUNC(SYSDATE));

    -- 如果在销帐时产生手续费，手续费的计算在此进行
    /*         UPDATE  RECLIST_1METER_TMP T
    SET T.RLSXF=*/
    /*      COMMIT;  */
    RETURN ID_COUNT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN 0;
  END F_SET_REC_TMP;

  /*******************************************************************************************
  函数名：F_CHK_LIST
  用途：销帐前各项检查
  参数： 应缴，手续费，违约金，实收金额，预存期初
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --应收金额
                      P_ZNJ    IN NUMBER, --销帐违约金
                      P_SXF    IN NUMBER, --手续费
                      P_PAYJE  IN NUMBER, --实际收款
                      P_SAVING IN METERINFO.MISAVING%TYPE --水表资料号
                      ) RETURN NUMBER IS

    V_REC_TOTAL NUMBER(10, 2); --总应缴水费
    V_ZNJ_TOTAL NUMBER(10, 2); --总违约金
    V_SXF_TOTAL NUMBER(10, 2); --总手续费

    ERR_NOMATCH EXCEPTION;
    ERR_JE EXCEPTION;
    ERR_METER EXCEPTION;

    V_RESULT NUMBER;
    V_MSG    VARCHAR2(200);
  BEGIN
    --从临时表中求总应收水费，总违约金
    SELECT NVL(SUM(T.RLJE), 0), NVL(SUM(T.RLZNJ), 0), NVL(SUM(T.RLSXF), 0)
      INTO V_REC_TOTAL, V_ZNJ_TOTAL, V_SXF_TOTAL
      FROM RECLIST_1METER_TMP T;

    --检查金额关系
    IF P_RLJE <> V_REC_TOTAL OR P_ZNJ <> V_ZNJ_TOTAL OR
       P_SXF <> V_SXF_TOTAL THEN
      RAISE ERR_NOMATCH;
    END IF;
    --要求在调用本过程前，需要做好检查，但此处还是再做一次金额关系比较
    /*         IF P_PAYJE+P_SAVING<P_RLJE+P_ZNJ+P_SXF THEN
      RAISE ERR_JE;
    END IF;   */ ---由于负预存取消

    RETURN 0;
  EXCEPTION
    WHEN ERR_NOMATCH THEN
      RETURN - 1;
    WHEN ERR_JE THEN
      RETURN - 2;
  END F_CHK_LIST;

  /*******************************************************************************************
  函数名：F_REMAIND_TRANS1
  用途：在2块水表之间进行预存转移
  参数： 转出水表号，准入水表号，金额
  业务规则：
     1、调用核心销帐过程，水费金额=0时为单缴预存，
     2、在PAYMENT中，增加2条记录，一个为正预存，一个为负预存
     3、2条记录同一个批次号
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --转出水表号
                            P_MID_T    IN METERINFO.MIID%TYPE, --水表资料号
                            P_JE       IN METERINFO.MISAVING%TYPE, --转移金额
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --实收帐批次号
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --是否提交
                            ) RETURN VARCHAR2 IS
    V_RESULT VARCHAR2(3);
    PM       PAYMENT%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    V_PAYID  PAYMENT.PID%TYPE;
    /*V_BATCH PAYMENT.PBATCH%TYPE;*/

    ERR_JE EXCEPTION;

  BEGIN
    --取转出水表的预存金额
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = P_MID_S;
    --如果源水表预存小于转出金额，抛出错误
    IF MI.MISAVING < P_JE THEN
      RAISE ERR_JE;
    END IF;

    V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                           P_OPER, --收款员
                           P_MID_S, --水表资料号
                           0, --应收金额
                           0, --销帐违约金
                           0, --手续费
                           -1 * P_JE, --实际收款
                           PAYTRANS_YCDB, --缴费事务
                           'XJ', --付款方式
                           P_PAYPOINT, --缴费地点
                           P_BATCH, --缴费事务批号
                           'N', --是否打票  Y 打票，N不打票， R 应收票
                           '', --发票号
                           V_PAYID --实收流水，返回此次记账的实收流水号
                           );
    ----记转入预存的实收帐-----------------------------------------------------------------
    V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                           P_OPER, --收款员
                           P_MID_T, --水表资料号
                           0, --应收金额
                           0, --销帐违约金
                           0, --手续费
                           P_JE, --实际收款
                           PAYTRANS_YCDB, --缴费事务
                           'XJ', --付款方式
                           P_PAYPOINT, --缴费地点
                           P_BATCH, --缴费事务批号
                           'N', --是否打票  Y 打票，N不打票， R 应收票
                           '', --发票号
                           V_PAYID --实收流水，返回此次记账的实收流水号
                           );
    ------- END OF  预存调拨 记账----------------------------------------------------------
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END F_REMAIND_TRANS1;

  /*******************************************************************************************
  函数名：SP_AUTO_PAY
  用途：
      普通水表自动预存抵扣缴费
  业务规则：

  参数：  --水表号
  前置条件：
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY(P_MIID IN METERINFO.MIID%TYPE) IS

    RL_INFO RECLIST%ROWTYPE; --应收信息
    MINFO   METERINFO%ROWTYPE; --水表信息
    PM      PAYMENT%ROWTYPE; --实收信息
    RECJE   RECLIST.RLJE%TYPE; --应收水费
    V_ZNJ   RECLIST.RLZNJ%TYPE; --应收违约金
    V_TOTAL NUMBER; --总欠费

    V_SRESULT VARCHAR2(3);

    ERR_JE EXCEPTION;
  BEGIN
    --水表信息
    SELECT T.* INTO MINFO FROM METERINFO T WHERE T.MIID = P_MIID;
    --当前水表总欠费
    V_TOTAL := GETREC(P_MIID, RECJE, V_ZNJ);

    IF MINFO.MISAVING < V_TOTAL THEN
      RAISE ERR_JE;
    END IF;
    --参数准备
    PM.PPOSITION := MINFO.MISMFID;
    PM.PPER      := 'SYS';
    PM.PSPJE     := RECJE;
    PM.PZNJ      := V_ZNJ;
    PM.PSXF      := 0;
    PM.PPAYMENT  := 0;
    PM.PTRANS    := PAYTRANS_预存抵扣;
    PM.PMID      := P_MIID;
    PM.PPAYWAY   := 'XJ';
    PM.PPAYPOINT := MINFO.MISMFID;
    PM.PBATCH    := FGETSEQUENCE('ENTRUSTLOG');

    --调用水表销帐
    V_SRESULT := F_POS_1METER(PM.PPOSITION, --缴费机构
                              PM.PPER, --收款员
                              'ALL', --应收流水串，全部销帐
                              PM.PSPJE, --应收总金额
                              PM.PZNJ, --销帐违约金
                              PM.PSXF, --手续费
                              PM.PPAYMENT, --实际收款
                              PM.PTRANS, --缴费事？                             
                              PM.PMID, --水表资料号
                              PM.PPAYWAY, --付款方式
                              PM.PPAYPOINT, --缴费地点
                              PM.PBATCH, --销帐批次
                              'N', --是否打票  Y 打票，N不打票， R 应收票
                              '',
                              'Y');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('SP_AUTO_PAY', 1, '', '水表号:' || P_MIID);
  END SP_AUTO_PAY;

  /*******************************************************************************************
  函数名：SP_AUTO_PAY_1REC
  用途：
      普通水表1条应收记录自动预存抵扣缴费
  业务规则：

  参数：  --应收流水id
  前置条件：
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY_1REC(P_REC IN RECLIST%ROWTYPE) IS

    RL_INFO RECLIST%ROWTYPE; --应收信息
    MINFO   METERINFO%ROWTYPE; --水表信息
    PM      PAYMENT%ROWTYPE; --实收信息
    RECJE   RECLIST.RLJE%TYPE; --应收水费
    V_ZNJ   RECLIST.RLZNJ%TYPE; --应收违约金
    V_TOTAL NUMBER; --总欠费

    V_SRESULT VARCHAR2(3);

    ERR_JE EXCEPTION;
  BEGIN
    --水表信息
    SELECT T.* INTO MINFO FROM METERINFO T WHERE T.MIID = P_REC.RLMID;

    IF MINFO.MISAVING < P_REC.RLJE THEN
      RAISE ERR_JE;
    END IF;

    --参数准备
    PM.PPOSITION := MINFO.MISMFID;
    PM.PPER      := 'SYS';
    PM.PSPJE     := RECJE;
    PM.PZNJ      := GETZNJADJ(P_REC.RLID, --应收流水
                              P_REC.RLJE, --应收金额
                              P_REC.RLGROUP, --应收组号
                              P_REC.RLZNDATE, --滞纳金起算日
                              MINFO.MISMFID, --水表营业所
                              SYSDATE --终算日'不计入'违约日
                              );
    PM.PSXF      := 0;
    PM.PPAYMENT  := 0;
    PM.PTRANS    := PAYTRANS_预存抵扣;
    PM.PMID      := P_REC.RLMID;
    PM.PPAYWAY   := 'XJ';
    PM.PPAYPOINT := MINFO.MISMFID;
    PM.PBATCH    := FGETSEQUENCE('ENTRUSTLOG');

    --调用水表销帐
    V_SRESULT := F_POS_1METER(PM.PPOSITION, --缴费机构
                              PM.PPER, --收款员
                              P_REC.RLID, --应收流水串，
                              PM.PSPJE, --应收总金额
                              PM.PZNJ, --销帐违约金
                              PM.PSXF, --手续费
                              PM.PPAYMENT, --实际收款
                              PM.PTRANS, --缴费事务
                              PM.PMID, --水表资料号
                              PM.PPAYWAY, --付款方式
                              PM.PPAYPOINT, --缴费地点
                              PM.PBATCH, --销帐批次
                              'N', --是否打票  Y 打票，N不打票， R 应收票
                              '',
                              'Y');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('SP_AUTO_PAY_1REC',
                           1,
                           '',
                           '应收流水:' || P_REC.RLID);
  END SP_AUTO_PAY_1REC;

  /*******************************************************************************************
  函数名：F_PAYBACK_BY_PMID
  用途：实收冲正,按实收流水id冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN PAYMENT.PID%TYPE,
                             P_POSITION IN PAYMENT.PPOSITION%TYPE,
                             P_OPER     IN PAYMENT.PPER%TYPE,
                             P_BATCH    IN PAYMENT.PBATCH%TYPE,
                             P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                             P_TRANS    IN PAYMENT.PTRANS%TYPE,
                             P_COMMIT   IN VARCHAR2) RETURN VARCHAR2 IS

    PM PAYMENT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果
    V_RECID  RECLIST.RLID%TYPE;

    ERR_SAVING EXCEPTION;
  BEGIN
    --STEP 1:实收帐处理----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := '实收帐处理';
    --检查是否有符合条件的待冲正记录
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PID = P_PAYID
       AND T.PREVERSEFLAG <> 'Y';

    --取水表信息
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = PM.PMID;

    /*--检查当前预存是否够冲正回退,不够则退出 [yujia 2012-02-08]
    IF PM.PSAVINGBQ>MI.MISAVING THEN
       RAISE ERR_SAVING;
    END IF;*/

    --准备实收冲正负记录的数据
    PM.PPOSITION    := P_POSITION; --参数
    PM.PPER         := P_OPER; --参数
    PM.PSAVINGQC    := MI.MISAVING; --取当前
    PM.PSAVINGBQ    := 0 - PM.PSAVINGBQ; --取负
    PM.PSAVINGQM    := MI.MISAVING + PM.PSAVINGBQ; --计算
    PM.PPAYMENT     := 0 - PM.PPAYMENT; --取负
    PM.PBATCH       := P_BATCH; --参数
    PM.PPAYEE       := P_OPER; --参数
    PM.PPAYPOINT    := P_PAYPOINT; --参数
    PM.PSXF         := 0 - PM.PSXF; --取负
    PM.PILID        := ''; --无
    PM.PZNJ         := 0 - PM.PZNJ; --取负
    PM.PRCRECEIVED  := 0 - PM.PRCRECEIVED; --取负
    PM.PSPJE        := 0 - PM.PSPJE; --取负
    PM.PREVERSEFLAG := 'Y'; --Y
    PM.PSCRID       := PM.PID; --原记录.PID
    PM.PSCRTRANS    := PM.PTRANS; --原记录.PTRANS
    PM.PSCRMONTH    := PM.PMONTH; --原记录.PMONTH
    PM.PSCRDATE     := PM.PDATE; --原记录.PDATE
    ----以下几个变量赋值一定要放在最后，和次序有关
    PM.PID       := FGETSEQUENCE('PAYMENT'); --新生成
    PM.PDATE     := TOOLS.FGETPAYDATE(PM.PPOSITION); --SYSDATE
    PM.PDATETIME := SYSDATE; --SYSDATE
    PM.PMONTH    := TOOLS.FGETPAYMONTH(PM.PPOSITION); --当前月份
    PM.PTRANS    := P_TRANS; --参数
    -----------------------------------------------------------------
    --插入冲正实收负记录
    INSERT INTO PAYMENT T VALUES PM;
    --原被冲正记录打上冲正标志
    UPDATE PAYMENT T SET T.PREVERSEFLAG = 'Y' WHERE T.PID = P_PAYID;
    --END OF STEP 1: 处理结果：---------------------------------------------------
    --PAYMENT 增加了了一条负记录
    -- 被冲正记录的冲正标志为Y
    ----------------------------------------------------------------------------------------

    --应收账处理--------------------------------------------------------------
    -----STEP 10: 增加负应收记录
    ------在临时表中存放需要冲正处理的应收总账和明细帐记录
    ---先清空临时表
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---保存需要冲正处理的应收总账记录
    V_STEP    := 10;
    V_PRC_MSG := '保存需要冲正处理的应收总账记录';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---保存需要冲正处理的应收明细帐记录
    V_STEP    := 11;
    V_PRC_MSG := '保存需要冲正处理的应收明细帐记录';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---在应收总账临时表中做负记录的调整
    V_STEP    := 12;
    V_PRC_MSG := '在应收总账临时表中做负记录的调整';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID          = FGETSEQUENCE('RECLIST'),
           T.RLMONTH       = PM.PMONTH, --当前              帐务月份
           T.RLDATE        = PM.PDATE, --当前              帐务日期
           T.RLCHARGEPER   = PM.PPER, --同实收           收费员
           T.RLSL          = 0 - T.RLSL, --取负              应收水量
           T.RLJE          = 0 - T.RLJE, --取负             应收金额
           T.RLADDSL       = 0 - T.RLADDSL, --取负             加调水量
           T.RLSCRRLID     = T.RLID, --原记录.RLID       原应收帐流水
           T.RLSCRRLTRANS  = T.RLTRANS, --原记录.RLTRANS    原应收帐事务
           T.RLSCRRLMONTH  = T.RLMONTH, --原记录.RLMONTH    原应收帐月份
           T.RLPAIDJE      = 0 - T.RLPAIDJE, --取负              销帐金额
           T.RLPAIDFLAG    = 'Y', --Y                 销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
           T.RLPAIDPER     = PM.PPER, --同实收           销帐人员
           T.RLPAIDDATE    = PM.PDATE, --同实收            销帐日期
           T.RLZNJ         = 0 - T.RLZNJ, --取负             违约金
           T.RLDATETIME    = SYSDATE, --SYSDATE          发生日期
           T.RLSCRRLDATE   = T.RLDATE, --原记录.RLDATE    原帐务日期
           T.RLPID         = PM.PID, --对应的负实收流水  实收流水（与payment.pid对应）
           T.RLPBATCH      = PM.PBATCH, --对应的负实收流水  缴费交易批次（与payment.PBATCH对应）
           T.RLSAVINGQC    = T.RLSAVINGQM, --计算             期初预存（销帐时产生）
           T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --计算             本期预存发生（销帐时产生）
           T.RLSAVINGQM    = T.RLSAVINGQC + T.RLSAVINGBQ, --计算             期末预存（销帐时产生）
           T.RLREVERSEFLAG = 'Y', --Y                   冲正标志（N为正常，Y为冲正）
           T.RLSXF         = 0 - T.RLSXF;

    --将应收冲正负记录插入到应收总账中
    V_STEP    := 13;
    V_PRC_MSG := '将应收冲正负记录插入到应收总账中';

    ------
    INSERT INTO PBPARMTEMP_TEST T
      (SELECT S.RLID,
              S.RLSMFID,
              S.RLMONTH,
              S.RLDATE,
              S.RLCID,
              S.RLMID,
              S.RLMSMFID,
              S.RLCSMFID,
              S.RLCCODE,
              S.RLCHARGEPER,
              S.RLCPID,
              S.RLCCLASS,
              S.RLCFLAG,
              S.RLUSENUM,
              S.RLCNAME,
              S.RLCADR,
              S.RLMADR,
              S.RLCSTATUS,
              S.RLMTEL,
              S.RLTEL,
              S.RLBANKID,
              S.RLTSBANKID,
              S.RLACCOUNTNO,
              S.RLACCOUNTNAME,
              S.RLIFTAX,
              S.RLTAXNO,
              S.RLIFINV,
              S.RLMCODE,
              S.RLMPID,
              S.RLMCLASS,
              S.RLMFLAG,
              S.RLMSFID,
              S.RLDAY,
              S.RLBFID,
              S.RLPRDATE,
              S.RLRDATE,
              S.RLZNDATE,
              S.RLCALIBER,
              S.RLRTID,
              S.RLMSTATUS,
              S.RLMTYPE,
              S.RLMNO,
              S.RLSCODE,
              S.RLECODE,
              S.RLREADSL,
              S.RLINVMEMO,
              S.RLENTRUSTBATCH,
              S.RLENTRUSTSEQNO,
              S.RLOUTFLAG,
              S.RLTRANS,
              S.RLCD,
              S.RLYSCHARGETYPE,
              S.RLSL,
              S.RLJE,
              S.RLADDSL,
              S.RLSCRRLID,
              S.RLSCRRLTRANS,
              S.RLSCRRLMONTH,
              S.RLPAIDJE,
              S.RLPAIDFLAG,
              S.RLPAIDPER,
              S.RLPAIDDATE,
              S.RLMRID,
              S.RLMEMO,
              S.RLZNJ,
              S.RLLB,
              S.RLCNAME2,
              S.RLPFID,
              S.RLDATETIME,
              S.RLSCRRLDATE,
              S.RLPRIMCODE,
              S.RLPRIFLAG,
              S.RLRPER,
              S.RLSAFID,
              S.RLSCODECHAR,
              S.RLECODECHAR,
              S.RLILID,
              S.RLMIUIID,
              S.RLGROUP,
              S.RLPID,
              S.RLPBATCH,
              S.RLSAVINGQC,
              S.RLSAVINGBQ,
              S.RLSAVINGQM,
              S.RLREVERSEFLAG,
              S.RLBADFLAG,
              S.RLZNJREDUCFLAG,
              S.RLMISTID,
              S.RLMINAME,
              S.RLSXF,
              S.RLMIFACE2,
              S.RLMIFACE3,
              S.RLMIFACE4,
              S.RLMIIFCKF,
              S.RLMIGPS,
              S.RLMIQFH,
              S.RLMIBOX,
              S.RLMINAME2,
              S.RLMISEQNO,
              S.RLMISAVING
         FROM RECLIST_1METER_TMP S);
    COMMIT;
    ------

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---在应收明细临时表中做负记录的调整
    V_STEP    := 14;
    V_PRC_MSG := '在应收明细临时表中做负记录的调整';

    --一般字段调整
    UPDATE RECDETAIL_TMP T
       SET T.RDYSSL  = 0 - T.RDYSSL,
           T.RDYSJE  = 0 - T.RDYSJE,
           T.RDSL    = 0 - T.RDSL,
           T.RDJE    = 0 - T.RDJE,
           T.RDADJSL = 0 - T.RDADJSL,
           T.RDADJJE = 0 - T.RDADJJE,
           T.RDZNJ   = 0 - T.RDZNJ;
    --流水id调整
    UPDATE RECDETAIL_TMP T
       SET T.RDID =
           (SELECT S.RLID
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLSCRRLID)
     WHERE T.RDID IN (SELECT RLSCRRLID FROM RECLIST_1METER_TMP);
    --插入到应收明细表
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);

    -----END OF  STEP 10: 增加负应收记录处理完成---------------------------------------

    -----STEP 20: 增加正应收记录--------------------------------------------------------------
    ------在临时表中存放需要冲正处理的应收总账和明细帐记录
    ---先清空临时表
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---保存需要冲正处理的应收总账记录
    V_STEP    := 20;
    V_PRC_MSG := '保存需要冲正处理的应收总账记录';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---保存需要冲正处理的应收明细帐记录
    V_STEP    := 21;
    V_PRC_MSG := '保存需要冲正处理的应收明细帐记录';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---在应收总账临时表中做正记录的调整
    V_STEP    := 22;
    V_PRC_MSG := '在应收总账临时表中做正记录的调整';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID          = FGETSEQUENCE('RECLIST'), --新生成
           T.RLMONTH       = PM.PMONTH, --当前
           T.RLDATE        = PM.PDATE, --当前
           T.RLCHARGEPER   = '', --无
           T.RLSCRRLID     = T.RLID, --原记录.RLID
           T.RLSCRRLTRANS  = T.RLTRANS, --原记录.RLTRANS
           T.RLSCRRLMONTH  = T.RLMONTH, --原记录.RLMONTH
           T.RLPAIDFLAG    = 'N', --N
           T.RLPAIDPER     = '', --无
           T.RLPAIDDATE    = '', --无
           T.RLDATETIME    = SYSDATE, --SYSDATE
           T.RLSCRRLDATE   = T.RLDATE, --原记录.RLDATE
           T.RLPID         = NULL, --无
           T.RLPBATCH      = NULL, --无
           T.RLSAVINGQC    = NULL, --无
           T.RLSAVINGBQ    = NULL, --无
           T.RLSAVINGQM    = NULL, --无
           T.RLREVERSEFLAG = 'N',
           T.RLPAIDJE      = 0,
           T.RLOUTFLAG     = 'N'; --N
    --        T.RLSXF         =NULL

    --将应收冲正正记录插入到应收总账中
    V_STEP    := 23;
    V_PRC_MSG := '将应收冲正正记录插入到应收总账中';
    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---在应收明细临时表中做正记录的调整
    V_STEP    := 14;
    V_PRC_MSG := '在应收明细临时表中做正记录的调整';

    UPDATE RECDETAIL_TMP T
       SET (T.RDID,
            T.RDPAIDFLAG,
            T.RDPAIDDATE,
            T.RDPAIDMONTH,
            T.RDPAIDPER,
            T.RDMONTH) =
           (SELECT S.RLID, 'N', NULL, NULL, NULL, S.RLMONTH
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLSCRRLID)
     WHERE T.RDID IN (SELECT RLSCRRLID FROM RECLIST_1METER_TMP);
    --插入到应收明细表
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);

    ----END OF STEP 20: 增加正应收记录  处理完成 ------------------------------------------
    ----STEP 30 原应收记录打冲正标记
    V_STEP    := 30;
    V_PRC_MSG := '原应收记录打冲正标记';
    UPDATE RECLIST T
       SET T.RLREVERSEFLAG = 'Y'

     WHERE T.RLPID = P_PAYID
       AND T.RLPAIDFLAG = 'Y';
    --END OF  应收账处理完成--------------------------------------------------------------

    --STEP 40 水表资料预存余额调整--------------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := '水表资料预存余额调整';
    UPDATE METERINFO T
       SET T.MISAVING = PM.PSAVINGQM, T.MIPAYMENTID = P_PAYID
     WHERE T.MIID = PM.PMID;
    -- END OF STEP 40 水表资料预存余额调整------------------------------------------------------------

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END F_PAYBACK_BY_PMID;

  /*******************************************************************************************
  函数名：F_PAYBACK_BY_BANKNO
  用途：实收冲正,按银行流水id冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BANKNO(P_BSEQNO   IN PAYMENT.PBSEQNO%TYPE,
                               P_POSITION IN PAYMENT.PPOSITION%TYPE,
                               P_OPER     IN PAYMENT.PPER%TYPE,
                               P_BATCH    IN PAYMENT.PBATCH%TYPE,
                               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                               P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2 IS
    PM PAYMENT%ROWTYPE;
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果
    V_RECID  RECLIST.RLID%TYPE;

    ERR_SAVING EXCEPTION;
  BEGIN
    --STEP 1:实收帐处理----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := '实收帐处理';
    --检查是否有符合条件的待冲正记录
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PBSEQNO = P_BSEQNO
       AND T.PREVERSEFLAG <> 'Y';
    --调用实收流水 冲正
    V_RESULT := F_PAYBACK_BY_PMID(PM.PID,
                                  P_POSITION,
                                  P_OPER,
                                  P_BATCH,
                                  P_PAYPOINT,
                                  P_TRANS,
                                  'Y');
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '001';
    WHEN OTHERS THEN
      RETURN '009';
  END F_PAYBACK_BY_BANKNO;

  /*******************************************************************************************
  函数名：F_PAYBACK_BATCH
  用途：实收冲正,按批次冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                              P_POSITION IN PAYMENT.PPOSITION%TYPE,
                              P_OPER     IN PAYMENT.PPER%TYPE,
                              P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                              P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2 IS

    --函数变量在此说明

    CURSOR C_PM IS
      SELECT T.*
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH
         AND T.PREVERSEFLAG <> 'Y'
       ORDER BY T.PID DESC;

    PM        PAYMENT%ROWTYPE;
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果
    V_RECID  RECLIST.RLID%TYPE;

    V_BATCH PAYMENT.PID%TYPE;

    ERR_PAYBACK EXCEPTION;
  BEGIN
    --STEP 1:实收帐处理----------------------------------
    V_STEP    := 1;
    V_PRC_MSG := '实收帐处理';
    --检查是否有符合条件的待冲正记录
    OPEN C_PM;
    LOOP
      FETCH C_PM
        INTO PM;
      EXIT WHEN C_PM%NOTFOUND OR C_PM%NOTFOUND IS NULL;

      --生成批次号
      V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
      --调用实收流水 冲正
      V_RESULT := F_PAYBACK_BY_PMID(PM.PID,
                                    P_POSITION,
                                    P_OPER,
                                    P_BATCH,
                                    P_PAYPOINT,
                                    P_TRANS,
                                    'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAYBACK;
      END IF;
    END LOOP;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BATCH);
    COMMIT;
    RETURN V_RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '001';
    WHEN OTHERS THEN
      RETURN '009';
  END F_PAYBACK_BY_BATCH;
  /*******************************************************************************************
  和账务过程相关的数据库对象

  /*-- Create table
  DROP  TABLE reclist_1meter_tmp;
  create global temporary table reclist_1meter_tmp  on commit delete rows
  as (select * from reclist s where s.rlid='1');

  -- Create table
  DROP  TABLE PAY_PARA_TMP;
  create global temporary table PAY_PARA_TMP  on commit delete rows
  as (select * from reclist s where s.rlid='1');

  -- Create table
  create table CHK_RESULT
  (
    ID         NUMBER not null,
    CHK_TIME   DATE,
    CHK_ITEM   VARCHAR2(100),
    CHK_RESULT VARCHAR2(100),
    PID        VARCHAR2(10),
    PARA       VARCHAR2(400),
    REMARK     VARCHAR2(1000)
  )
  tablespace USERS
    pctfree 10
    initrans 1
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );
  -- Add comments to the table
  comment on table CHK_RESULT
    is '业务检查异常清单';
  -- Add comments to the columns
  comment on column CHK_RESULT.ID
    is '流水号';
  comment on column CHK_RESULT.CHK_TIME
    is '检查时间';
  comment on column CHK_RESULT.CHK_ITEM
    is '检查项目';
  comment on column CHK_RESULT.PID
    is '相关的id';
  comment on column CHK_RESULT.PARA
    is '相关参数说明';
  comment on column CHK_RESULT.REMARK
    is '备注';
  -- Create/Recreate primary, unique and foreign key constraints
  alter table CHK_RESULT
    add constraint PK_CHK_RESULT primary key (ID)
    using index
    tablespace USERS
    pctfree 10
    initrans 2
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );
  -- Create/Recreate indexes
  create index IDX_CHK_RESULT1 on CHK_RESULT (CHK_ITEM, CHK_TIME)
    tablespace USERS
    pctfree 10
    initrans 2
    maxtrans 255
    storage
    (
      initial 64K
      minextents 1
      maxextents unlimited
    );

  -- Create sequence
  create sequence SEQ_CHK_LIST
  minvalue 1
  maxvalue 9999999999
  start with 21
  increment by 1
  cache 20
  order;
  *******************************************************************************************/

----------------------------------------------------------------------------------------------------------

BEGIN
  CURDATE                := SYSDATE;
  全公司统一标准收滞纳金 := FSYSPARA('1090'); --全公司统一标准收滞纳金(1),各营业所标准收滞纳金(2)
END;
/


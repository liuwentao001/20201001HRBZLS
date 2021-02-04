CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PAY_TM" IS
  /*************************************************************************************
    -- Author  : 郑仕华
    -- Created : 2012-02-03
    -- Purpose : 缴费事务包
  *************************************************************************************/
  -- 全局类型说明
  TYPE VARCHAR_IDXTAB IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
  -- type pay_para
  -- 全局常量说明
  全公司统一标准收滞纳金 VARCHAR2(100); --全公司统一标准收滞纳金(Y),各营业所标准收滞纳金(N)
  --错误代码
  ERRCODE  CONSTANT INTEGER := -20012;
  NOCUST   CONSTANT INTEGER := -20013;
  NOARREAR CONSTANT INTEGER := -20014;
  NOENOUGH CONSTANT INTEGER := -20015;
  --常量参数
  PAYTRANS_POS      CONSTANT CHAR(1) := 'P'; --自来水柜台缴费
  PAYTRANS_DS       CONSTANT CHAR(1) := 'B'; --银行实时代收
  PAYTRANS_BSAV     CONSTANT CHAR(1) := 'W'; --银行实时单缴预存
  PAYTRANS_DSDE     CONSTANT CHAR(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销隔日发起）
  PAYTRANS_DK       CONSTANT CHAR(1) := 'D'; --代扣销帐
  PAYTRANS_TS       CONSTANT CHAR(1) := 'T'; --托收票据销帐
  PAYTRANS_SAV      CONSTANT CHAR(1) := 'S'; --自来水柜台独立预存
  PAYTRANS_INV      CONSTANT CHAR(1) := 'I'; --走收票据销帐
  PAYTRANS_预存抵扣 CONSTANT CHAR(1) := 'U'; --算费过程即时预存抵扣
  PAYTRANS_YCDB     CONSTANT CHAR(1) := 'K'; --预存调拨

  PAYTRANS_CR     CONSTANT CHAR(1) := 'C'; --其它所有未独立业务冲销（销帐冲正单据发起）
  PAYTRANS_BANKCR CONSTANT CHAR(1) := 'X'; --实时代收冲销（银行当日冲销发起）
  PAYTRANS_DSCR   CONSTANT CHAR(1) := 'R'; --实时代收单边帐冲销
  PAYTRANS_ADJ    CONSTANT CHAR(1) := 'V'; --减量退费：退费贷帐事务(CR)、借帐补销事务(DE)

  PAYTRANS_稽查   CONSTANT CHAR(1) := 'F'; --稽查罚款
  PAYTRANS_追量   CONSTANT CHAR(1) := 'Z'; --追量
  PAYTRANS_预留   CONSTANT CHAR(1) := 'Y'; --预留
  PAYTRANS_余度   CONSTANT CHAR(1) := 'A'; --余度
  PAYTRANS_工程款 CONSTANT CHAR(1) := 'G'; --工程款
  PAYTRANS_价差   CONSTANT CHAR(1) := 'J'; --价差
  PAYTRANS_水损   CONSTANT CHAR(1) := 'K'; --水损

  DEBIT  CONSTANT CHAR(2) := 'DE'; --借方
  CREDIT CONSTANT CHAR(2) := 'CR'; --贷方

  CTL_PAYPART CONSTANT VARCHAR2(10) := 'FULL'; --满付
  CAL_DAYS    CONSTANT INTEGER := 3; --计费缓冲日（计算滞纳金）
  --待销帐应收包
  SUBTYPE RL_TYPE IS RECLIST%ROWTYPE;
  TYPE RL_TABLE IS TABLE OF RL_TYPE;

  --供调用查询欠费过程（同与INQ101）
  FUNCTION GETREC(P_MID IN VARCHAR2) RETURN NUMBER;
  --实时欠费金额
  FUNCTION GETREC(P_MID   IN VARCHAR2,
                  P_RECJE OUT RECLIST.RLJE%TYPE,
                  P_ZNJ   OUT RECLIST.RLZNJ%TYPE) RETURN NUMBER;
  --违约金计算子函数（含节假日规则，不含减免规则）

  --取滞纳金宽限比例
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --滞纳金类别
                       P_SMFID   IN VARCHAR2, --营业所
                       P_RLGROUP IN VARCHAR2 --应收分帐号
                       ) RETURN NUMBER;
  --取滞纳金宽限天数
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --滞纳金类别
                     P_SMFID   IN VARCHAR2, --营业所
                     P_RLGROUP IN VARCHAR2 --应收分帐号
                     ) RETURN NUMBER;
  --违约金计算子函数（含节假日规则，不含减免规则）
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --营业所
                  P_RLGROUP IN VARCHAR2, --应收分帐号
                  P_SDATE   IN DATE, --起算日'计入'违约日
                  P_EDATE   IN DATE, --终算日'不计入'违约日
                  P_JE      IN NUMBER) --违约金本金
   RETURN NUMBER;
  --违约金计算（含节假日规则，含减免规则）
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --应收流水
                     P_RLJE     IN NUMBER, --应收金额
                     P_RLGROUP  IN NUMBER, --应收组号
                     P_RLZNDATE IN DATE, --滞纳金起算日
                     P_SMFID    VARCHAR2, --水表营业所
                     P_EDATE    IN DATE --终算日'不计入'违约日
                     ) RETURN NUMBER;

  /*******************************************************************************************
  新的销帐处理过程由此以下:
  销帐业务总体规则说明如下：
  1、最小缴费单元：一块水表一个月的全部费用
  2、实收帐PAYMENT中一条记录，对应一只水表的一个月或多个月的应收销帐
  3、如有多表缴费（托收、合收户等），则在PAYMENT中记录多条收费流水，每条记录参见第2点说明
  多条收费流水通过批次流水关联成一次销帐业务。
  4、欠费判断依据：t.rlpaidflag=’N’ AND t.RLJE>0 AND t.RLREVERSEFLAG=’N’
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
                      ) RETURN VARCHAR2;

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
                          ) RETURN NUMBER;
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
                        ) RETURN VARCHAR2;
  /*******************************************************************************************
  函数名：F_POS_MULT_M
  用途：
      多表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，支持水表挑选销帐月份
     2、每只水表都不发生预存变化，收费金额=欠费金额
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
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2;
  /*******************************************************************************************
  函数名：F_POS_MULT_HS
  用途：
      合收表缴费，通过循环调用单表缴费过程实现。
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
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2;
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
    RETURN NUMBER;

  /*******************************************************************************************
  函数名：F_CHK_AMOUNT
  用途：检查销帐金额是否相符
  参数： 应缴，手续费，违约金，实收金额，预存期初
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --应收金额
                      P_ZNJ    IN NUMBER, --销帐违约金
                      P_SXF    IN NUMBER, --手续费
                      P_PAYJE  IN NUMBER, --实际收款
                      P_SAVING IN METERINFO.MISAVING%TYPE --水表资料号
                      ) RETURN NUMBER;
  /*******************************************************************************************
  函数名：F_REMAIND_TRANS
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
                            ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：SP_AUTO_PAY
  用途：
      普通水表自动预存抵扣缴费
  业务规则：

  参数：  --水表号
  前置条件：
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY(P_MIID IN METERINFO.MIID%TYPE);
  /*******************************************************************************************
  函数名：SP_AUTO_PAY_1REC
  用途：
      普通水表1条应收记录自动预存抵扣缴费
  业务规则：

  参数：  --应收流水id
  前置条件：
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY_1REC(P_REC IN RECLIST%ROWTYPE);
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
                             P_COMMIT   IN VARCHAR2) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_PAYBACK_BANKSEQNO
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
    RETURN VARCHAR2;
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
    RETURN VARCHAR2;
END;
/


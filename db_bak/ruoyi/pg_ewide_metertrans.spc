CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS IS

  --优惠明细包
  SUBTYPE PAL_TYPE IS REQUEST_PID%ROWTYPE;
  TYPE PAL_TABLE IS TABLE OF PAL_TYPE;
  
  --应收明细包
  SUBTYPE RD_TYPE IS BS_RECDETAIL%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  
  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(P_MTHNO  IN VARCHAR2, --批次流水
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2); --提交标志

  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER    IN VARCHAR2, -- 操作员
                              I_RENO   IN VARCHAR2, --流水号
                              P_COMMIT IN VARCHAR2); --提交标志

  --插入抄表计划
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        MI        IN BS_METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT BS_METERREAD.MRID%TYPE); --抄表流水

  --计划内算费
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE);

  -- 自来水单笔算费，提供外部调用
  PROCEDURE CALCULATE(MR      IN OUT BS_METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           );

  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT BS_METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);

  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);

  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN BS_RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2);

  -- 费率明细计算步骤
  PROCEDURE CALPIID(P_RL             IN OUT BS_RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN BS_PRICEDETAIL%ROWTYPE,
                    PMD              BS_PRICEDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    P_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2);

  PROCEDURE INSRD(RD IN RD_TABLE);

  PROCEDURE SP_RECLIST_CHARGE_01(V_RDID IN VARCHAR2, V_TYPE IN VARCHAR2);

    --阶梯计费步骤
  PROCEDURE CALSTEP(P_RL       IN OUT BS_RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN BS_PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        BS_PRICEDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);

  --缴费自动执行电子发票开具任务
  PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2);

  --违约金计算（含节假日规则，含减免规则）
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --应收流水
                     P_RLJE     IN NUMBER, --应收金额
                     P_RLGROUP  IN NUMBER, --应收组号
                     P_RLZNDATE IN DATE, --滞纳金起算日
                     P_SMFID    VARCHAR2, --水表营业所
                     P_EDATE    IN DATE --终算日'不计入'违约日
                     ) RETURN NUMBER;

  --水价调整函数   BY WY 20130531
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE;

  --调整水价+费用项目函数   BY WY 20130531
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;

  --自来水柜台缴费
  FUNCTION POS(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
               P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
               P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
               P_RLIDS    IN VARCHAR2, --应收流水串
               P_RLJE     IN NUMBER, --应收总金额
               P_ZNJ      IN NUMBER, --销帐违约金
               P_SXF      IN NUMBER, --手续费
               P_PAYJE    IN NUMBER, --实际收款
               P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务
               P_MIID     IN BS_PAYMENT.PMID%TYPE, --水表资料号
               P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
               P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE, --缴费地点
               P_PAYBATCH IN BS_PAYMENT.PBATCH%TYPE, --销帐批次
               P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
               P_INVNO    IN VARCHAR2, --发票号
               P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
               ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_POS_1METER
  用途：单只水表缴费
      1、单表缴费业务，调用本函数，在PAYMENT 中记一条记录，一个ID流水，一个批次
      2、多表缴费业务，通过循环调用本函数实现业务，一只水表一条记录，多个水表一个批次。
  业务规则：
     1、单只水表，非欠费全销，将待销应收ID，按XXXXX,XXXXX,XXXXX| 格式存放P_RLIDS, 调用本过程
     2、银行行等代收机构或柜台进行单只水表的欠费全销，P_RLIDS='ALL'
     3、单缴预存，P_RLJE=0
  参数：参见用途说明
     P_PAYBATCH='999999999',则在模块内生成批次号，否则，直接使用P_PAYBATCH作为批次号
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
                        P_RLIDS    IN VARCHAR2, --应收流水串
                        P_RLJE     IN NUMBER, --应收总金额
                        P_ZNJ      IN NUMBER, --销帐违约金
                        P_SXF      IN NUMBER, --手续费
                        P_PAYJE    IN NUMBER, --实际收款
                        P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务
                        P_MIID     IN BS_PAYMENT.PMID%TYPE, --水表资料号
                        P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE, --缴费地点
                        P_PAYBATCH IN BS_PAYMENT.PBATCH%TYPE, --销帐批次
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
                        ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_POS_MULT_HS
  用途：
      合收表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，每只水表都根据客户端选择的结果返回待销流水ID
     2、主表先销帐，所有销帐金额计算到主表期末余额上
     3、逐笔处理子表，主表预存转子表预存，子表预存销帐，
     4、整体事务提交
  参数：
  前置条件：
      水表和水表对应的应收帐流水串，存放在临时接口表 PAY_PARA_TMP 中
  *******************************************************************************************/
  FUNCTION F_POS_MULT_HS(P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
                         P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
                         P_MMID     IN BS_METERINFO.MICODE%TYPE, --合收主表号
                         P_PAYJE    IN NUMBER, --总实际收款金额
                         P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务
                         P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
                         P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE, --缴费地点
                         P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                         P_INVNO    IN VARCHAR2, --发票号
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2;

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
      1、最重要的销帐参数（水表ID，应收帐流水ID串，应收金额，违约金，手续费） 在调用本过程前，
       存放在临时接口表 PAY_PARA_TMP
      2、应收帐流水串的格式见核心单表销帐过程的说明。
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
                        P_PAYJE    IN NUMBER, --总实际收款金额
                        P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务
                        P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE, --缴费地点
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
                      P_SAVING IN BS_CUSTINFO.MISAVING%TYPE --水表资料号
                      ) RETURN NUMBER;

  /*******************************************************************************************
  新的销帐处理过程由此以下:
  销帐业务总体规则说明如下：
  1、最小缴费单元：一块水表一个月的全部费用
  2、实收帐PAYMENT中一条记录，对应一只水表的一个月或多个月的应收销帐
  3、如有多表缴费（托收、合收户等），则在PAYMENT中记录多条收费流水，每条记录参见第2点说明
  多条收费流水通过批次流水关联成一次销帐业务。
  4、欠费判断依据：T.RLPAIDFLAG=’N’ AND T.RLJE>0 AND T.RLREVERSEFLAG=’N’
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
  FUNCTION F_PAY_CORE(P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
                      P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
                      P_MIID     IN BS_PAYMENT.PMID%TYPE, --水表资料号
                      P_RLJE     IN NUMBER, --应收金额
                      P_ZNJ      IN NUMBER, --销帐违约金
                      P_SXF      IN NUMBER, --手续费
                      P_PAYJE    IN NUMBER, --实际收款
                      P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务
                      P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
                      P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE, --缴费地点
                      P_PAYBATCH IN VARCHAR2, --缴费事务流水
                      P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                      --P_INVNO    IN BS_PAYMENT.PILID%TYPE, --发票号
                      P_PAYID    OUT BS_PAYMENT.PID%TYPE --实收流水，返回此次记账的实收流水号
                      ) RETURN VARCHAR2;

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
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN BS_METERINFO.MIID%TYPE, --转出水表号
                            P_MID_T    IN BS_METERINFO.MIID%TYPE, --水表资料号
                            P_JE       IN BS_CUSTINFO.MISAVING%TYPE, --转移金额
                            P_BATCH    IN BS_PAYMENT.PBATCH%TYPE, --实收帐批次号
                            P_POSITION IN BS_PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN BS_PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN BS_PAYMENT.PPOSITION%TYPE,
                            P_COMMIT   IN VARCHAR2 --是否提交
                            ) RETURN VARCHAR2;

END PG_EWIDE_METERTRANS;
/


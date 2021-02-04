CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PAY_01" IS

  -- Author  : WANGYNG
  -- Created : 2011-10-18
  -- Purpose : 缴费事务包

  -- Public type declarations
  TYPE VARCHAR_IDXTAB IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
  -- Public constant declarations

  全公司统一标准收滞纳金 VARCHAR2(100); --全公司统一标准收滞纳金(Y),各营业所标准收滞纳金(N)

  V_PROJECT VARCHAR2(10); --项目编号
  --错误代码
  ERRCODE  CONSTANT INTEGER := -20012;
  NOCUST   CONSTANT INTEGER := -20013;
  NOARREAR CONSTANT INTEGER := -20014;
  NOENOUGH CONSTANT INTEGER := -20015;
  --常量参数
  PAYTRANS_POS      CONSTANT CHAR(1) := 'P'; --自来水柜台缴费
  PAYTRANS_DS       CONSTANT CHAR(1) := 'B'; --银行实时代收
  PAYTRANS_DSDE     CONSTANT CHAR(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销隔日发起）
  PAYTRANS_DK       CONSTANT CHAR(1) := 'D'; --代扣销帐
  PAYTRANS_TS       CONSTANT CHAR(1) := 'T'; --托收票据销帐
  PAYTRANS_SAV      CONSTANT CHAR(1) := 'S'; --自来水柜台独立预存
  PAYTRANS_BANKSAV  CONSTANT CHAR(1) := 'Q'; --自来水柜台独立预存
  PAYTRANS_INV      CONSTANT CHAR(1) := 'I'; --走收票据销帐
  PAYTRANS_预存抵扣 CONSTANT CHAR(1) := 'U'; --算费过程即时预存抵扣

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

  --自来水柜台缴费
  FUNCTION POS(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
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
               
  --支付宝缴费
  FUNCTION POS_ZFB (
               P_PAYJE    IN NUMBER, --实际收款
               p_pbseqno  IN VARCHAR2,  --支付宝流水
               P_MIID     IN VARCHAR2 --水表资料号
               ) RETURN VARCHAR2;

  --微信缴费
  FUNCTION POS_WX (
               P_PAYJE    IN NUMBER, --实际收款
               p_pbseqno  IN VARCHAR2,  --交易流水
               P_MIID     IN VARCHAR2, --水表资料号
               P_BZ       IN VARCHAR2, --缴费来源
               p_pwseqno  IN VARCHAR2,  --微信流水
               p_date     IN VARCHAR2       --交易申请时间
               ) RETURN VARCHAR2;



  --自来水柜台缴费
  FUNCTION POS_test(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
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
  --实收冲正按 缴费流水 PAYMENT.pid
  PROCEDURE SP_PAIDBAK(P_PID      IN PAYMENT.PID%TYPE, --实收流水
                       P_POSITION IN VARCHAR2, --冲正单位地点
                       P_OPER     IN VARCHAR2, --冲正操作员
                       P_PAYEE    IN VARCHAR2, --冲正付款员
                       P_TRANS    IN VARCHAR2, --冲正事务
                       P_MEMO     IN VARCHAR2, --冲正备注
                       P_IFFP     IN VARCHAR2, --是否打负票
                       P_INVNO    IN VARCHAR2, --票号
                       P_CRPBATCH IN VARCHAR2, --冲正批次流水
                       P_COMMIT   IN VARCHAR2 --提交标志
                       );
  --实收冲正按 缴费批次 PAYMENT.PBATCH
  PROCEDURE SP_PAIDBAK_BYPBATCH(P_PBATCH   IN PAYMENT.PBATCH%TYPE, --实收流水
                                P_POSITION IN VARCHAR2, --冲正单位地点
                                P_OPER     IN VARCHAR2, --冲正操作员
                                P_PAYEE    IN VARCHAR2, --冲正付款员
                                P_TRANS    IN VARCHAR2, --冲正事务
                                P_MEMO     IN VARCHAR2, --冲正备注
                                P_IFFP     IN VARCHAR2, --是否打负票
                                P_INVNO    IN VARCHAR2, --票号
                                P_CRPBATCH IN VARCHAR2, --冲正批次流水
                                P_COMMIT   IN VARCHAR2 --提交标志
                                );
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
    
    -------------支付宝退费-------------------------------------------
    FUNCTION REVERSE_ZFB(P_BATCH    IN PAYMENT.PBATCH%TYPE)
    RETURN VARCHAR2;
            -------------微信退费-------------------------------------------
    FUNCTION REVERSE_WX(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                        P_BZ       IN VARCHAR2)
    RETURN VARCHAR2;
  --预存扣款
--预存扣款(预存抵扣，不含手续费)

--柜台合收表借预存销帐

END;
/


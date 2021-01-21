CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS IS

  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2);  --提交标志

  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER IN VARCHAR2,-- 操作员
                              --P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                              P_COMMIT IN VARCHAR2) ; --提交标志

  --插入抄表计划
  PROCEDURE SP_INSERTMR(P_PPER IN VARCHAR2,--操作员
                        P_MONTH  IN VARCHAR2,--应收月份
                        P_MRTRANS IN VARCHAR2,--抄表事务
                        P_RLSL   IN NUMBER,--应收水量
                        P_SCODE  IN NUMBER,--起码
                        P_ECODE  IN NUMBER,--止码
                        MI IN BS_METERINFO%ROWTYPE,  --水表信息
                        OMRID OUT BS_METERREAD.MRID%TYPE); --抄表流水
                        
  --计划内算费
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE); 
    
  -- 自来水单笔算费，提供外部调用
  --PROCEDURE CALCULATE(MR IN OUT BS_METERREAD%ROWTYPE, P_TRANS IN CHAR);
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
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);
                      
  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2);
                       
  -- 费率明细计算步骤
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    p_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2);
                    
  PROCEDURE INSRD(RD IN RD_TABLE);
  
  PROCEDURE SP_RECLIST_CHARGE_01(V_RDID IN VARCHAR2,
                                 V_TYPE IN VARCHAR2);
                       
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
                     
END PG_EWIDE_METERTRANS;
/


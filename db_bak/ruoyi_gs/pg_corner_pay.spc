CREATE OR REPLACE PACKAGE "PG_CORNER_PAY" IS

  /*******************************************************************************************
  函数名：F_POS_CUST
  用途：单用户缴费
      1、单表缴费业务，调用本函数，在BS_PAYMENT 中记一条记录，一个id流水，一个批次
  业务规则：
     1、单只水表，缴费金额大于欠费金额，调用销账过程
     2、银行行，微信支付宝等代收机构或柜台进行单只水表的欠费全销
     3、单缴预存，P_RLJE=0，不调用销账过程
  参数：参见用途说明
     P_PAYBATCH='999999999',则在模块内生成批次号，否则，直接使用P_PAYBATCH作为批次号
  *******************************************************************************************/
  FUNCTION F_POS_CUST(P_POSITION IN BS_PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN BS_PAYMENT.PPAYEE%TYPE, --收款员
                        P_RLJE     IN NUMBER, --应收金额
                        P_PAYJE    IN NUMBER, --实际收款
                        P_TRANS    IN BS_PAYMENT.PTRANS%TYPE, --缴费事务（XJ,ZP,DC1,DC1,MZ,POS）
                        P_CID     IN BS_PAYMENT.PCID%TYPE, --用户号
                        P_FKFS     IN BS_PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYBATCH IN BS_PAYMENT.PBATCH%TYPE, --销帐批次
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票
                        P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
                        ) RETURN VARCHAR2;


END;
/


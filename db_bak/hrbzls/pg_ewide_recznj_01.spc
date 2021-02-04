CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RECZNJ_01" IS

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;

  --单据提交入口过程
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --减免单体
  PROCEDURE SP_RECZNJJM(P_ZAHNO  IN VARCHAR2, --批次流水
                        P_PER    IN VARCHAR2, --操作员
                        P_COMMIT IN VARCHAR2 --提交标志
                        );

  --滞纳金减免取消
  PROCEDURE SP_RECZNJJMCANCEL(P_ZAHNO  IN VARCHAR2, --批次流水
                              P_PER    IN VARCHAR2, --操作员
                              P_COMMIT IN VARCHAR2 --提交标志
                              );

  --检查操作员是否有审批额度
  FUNCTION F_CHKZNJED(P_OPER IN VARCHAR2, P_WYDNO IN VARCHAR2)
    RETURN VARCHAR2;
  --滞纳金减免功能使用
  PROCEDURE SP_ZNJJM_GETZNJLIST(P_CODE    IN VARCHAR2,
                                P_BFID    IN VARCHAR2,
                                P_MINDATE IN DATE,
                                P_MAXDATE IN DATE,
                                O_FLAG    OUT VARCHAR2);
  PROCEDURE 构造违约金减免单据(P_ZASMFID    IN VARCHAR2, --营业所
                      P_ZAHDEPT    IN VARCHAR2, -- 创建部门
                      P_ZAHCREPER  IN VARCHAR2, --创建人员
                      P_ZAHCREDATE IN VARCHAR2, --创建日期
                      P_RL         RECLIST%ROWTYPE, --应收信息
                      P_ZAHNO      IN OUT VARCHAR2, --输出单据号
                      P_ZNJ        IN NUMBER, --目标金额
                      P_COMMIT     IN VARCHAR2 --提交标志
                      );

END;
/


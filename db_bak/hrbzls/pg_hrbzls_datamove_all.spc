CREATE OR REPLACE PACKAGE HRBZLS."PG_HRBZLS_DATAMOVE_ALL" IS
  ERRCODE   CONSTANT INTEGER := -20012;
  YINYESHOU CONSTANT VARCHAR2(10) := '020101';
  QUBIEMA   CONSTANT VARCHAR2(10) := '1';
  PROCEDURE 所有数据初始化SQL;
  PROCEDURE 清理数据;
  PROCEDURE 维护老数据库表册;
  PROCEDURE 基础数据;
  PROCEDURE 添加操作员信息;
  PROCEDURE 管理架构;

  PROCEDURE 口径;
  PROCEDURE 表厂家;
  PROCEDURE 区域;
  PROCEDURE 水费管理;
  PROCEDURE 添加表册;
  PROCEDURE 添加计划(V_YEAR IN VARCHAR2);

  PROCEDURE 添加正常用户信息;
  PROCEDURE 添加销户用户信息;

  PROCEDURE 添加基建用户信息;
  PROCEDURE 添加基建应收帐;
  PROCEDURE 添加基建实收帐;
  PROCEDURE 添加补缴应收欠费;
  PROCEDURE 添加补缴已销应实收;

  PROCEDURE 添加不建帐用户信息;

  FUNCTION 取备份表用户号(V_ID IN VARCHAR2, V_NO IN VARCHAR2) RETURN VARCHAR2;
  --不建账用户使用重载函数
  FUNCTION 取备份表用户号(V_NO IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE 更新用户性质(P_SMFID IN VARCHAR2);
  /*procedure 更新条码号;*/
  PROCEDURE 维护总分表关系;
  ---
  FUNCTION 求户表应收起码(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;
  FUNCTION 求总表应收起码(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;
  FUNCTION 求总表应收止码(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;

  FUNCTION 求自动预存抵扣的期末预存(P_NO VARCHAR2, P_DATE VARCHAR2) RETURN NUMBER;

  PROCEDURE 添加应收帐_欠费_户表_0201(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0201(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0201(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0201(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0201(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0201(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0201(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0202(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0202(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0202(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0202(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0202(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0202(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0202(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0203(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0203(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0203(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0203(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0203(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0203(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0203(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0204(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0204(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0204(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0204(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0204(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0204(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0204(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0205(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0205(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0205(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0205(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0205(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0205(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0205(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0206(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0206(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0206(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0206(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0206(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0206(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0206(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0207(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0207(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0207(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0207(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0207(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0207(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0207(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0208(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0208(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0208(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0208(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0208(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0208(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0208(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0209(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0209(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0209(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0209(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0209(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0209(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0209(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 添加应收帐_欠费_户表_0210(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_欠费_总表_0210(P_SMFID IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_户表_0210(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加应收帐_已销_总表_0210(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_户表_0210(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加实收帐_总表_0210(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE 添加自动预存抵扣记录_0210(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE 更新缴费交易批次;

  FUNCTION F_GETCBYNAME(P_CBYID IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION 求水价(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETMICPER_XC(P_BFID IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE 批量插入营业所参数(P_SMFID IN VARCHAR2);
  FUNCTION F_GETSYSFRAME(P_SMFIDNAME IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETSYSFRAME_PC(P_PC IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETOPERID(P_OPERNAME IN VARCHAR2) RETURN VARCHAR2;

  /*procedure 更新reclist抄表员;*/
  /*procedure 更新meterreadhis抄表员;*/
  PROCEDURE 更新水表止码;
  PROCEDURE 更新水表预存;
  FUNCTION 求水价_CMID(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FCHKFLAG(P_ID IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION 求表册号(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FGETPIIDJ(P_PFID IN VARCHAR2, P_PIID IN VARCHAR2) RETURN NUMBER;

  FUNCTION 取补缴用户信息(P_STR IN VARCHAR2, P_TYPE IN VARCHAR2) RETURN VARCHAR2;

END;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_INVMANAGE_SP" IS

  ERRCODE CONSTANT INTEGER := -20012;
  --哈尔滨电子发票凭证类别
  C_预存     CONSTANT VARCHAR2(10) := '1';
  C_合票     CONSTANT VARCHAR2(10) := '2';
  C_分票     CONSTANT VARCHAR2(10) := '3';
  C_预开合票 CONSTANT VARCHAR2(10) := '4';
  C_预开分票 CONSTANT VARCHAR2(10) := '5';

  --新增发票
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --批次号
                           P_ISPER     VARCHAR2, --领票人
                           P_ISTYPE    VARCHAR2, --发票类别
                           P_ISNOSTART VARCHAR2, --发票起号
                           P_ISNOEND   VARCHAR2, --发票止号
                           P_OUTPER    VARCHAR2, --发放票据人
                           MSG         OUT VARCHAR2);

  --发票转领
  PROCEDURE SP_INVMANG_ZLY(P_INVTYPE     VARCHAR2,
                           P_ISNOSTART   VARCHAR2, --发票起号
                           P_ISNOEND     VARCHAR2, --发票止号
                           P_ISBCNO      VARCHAR2, --批次号
                           P_ISSTATUSPER VARCHAR2, --领用人员
                           P_STATUS      NUMBER, --状态0
                           P_MEMO        VARCHAR2, --备注
                           MSG           OUT VARCHAR2);

  --修改发票状态
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_INVTYPE     VARCHAR2,
                                    P_ISNOSTART   VARCHAR2, --发票起号
                                    P_ISNOEND     VARCHAR2, --发票止号
                                    P_ISBCNO      VARCHAR2, --批次号
                                    P_ISSTATUSPER VARCHAR2, --状态变更人员
                                    P_STATUS      NUMBER, --状态2
                                    P_MEMO        VARCHAR2, --备注
                                    MSG           OUT VARCHAR2);
  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --发票批次号
                                P_ISNO  IN VARCHAR2 --发票号
                                );
  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --发票批次号
                              P_ISNO   IN VARCHAR2, --发票号
                              P_STATUS NUMBER);

  --预存票据源
  PROCEDURE SP_SWAPINVYC(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         );
  --合票数据源
  PROCEDURE SP_SWAPINVHP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         );
  --分票数据源
  PROCEDURE SP_SWAPINVFP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                         );
  --预开合票数据源
  PROCEDURE SP_SWAPINVYKHP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           );
  --预开分票数据源
  PROCEDURE SP_SWAPINVYKFP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           );

  --打印税票凭证（不计票号）
  PROCEDURE SP_PREPRINT_SPPZ(P_PRINTTYPE IN VARCHAR2,
                             P_INVTYPE   IN VARCHAR2,
                             P_INVNO     IN VARCHAR2,
                             O_CODE      OUT VARCHAR2,
                             O_ERRMSG    OUT VARCHAR2);

  --易维云平台电子发票
  PROCEDURE SP_PREPRINT_EINVOICE(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                                 );
    PROCEDURE SP_PREPRINT_EINVOICEtest(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2,
                                 P_RLID    IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                                 );

  PROCEDURE P_QUEUE(P_ID      IN VARCHAR2,P_TYPE IN VARCHAR2);
  --删除开票记录
  PROCEDURE SP_DELINV(P_TYPE IN VARCHAR2);
  --电子发票延迟开票处理
  PROCEDURE SP_EINVOICE_DELAY(V_ID IN VARCHAR2);
  PROCEDURE SP_EINVOICE_DELAY_JOB(P_ID IN NUMBER);
  PROCEDURE SP_EINVOICE_DELAY_ATONCE(P_ID IN NUMBER);

  --凭证明细行
  PROCEDURE SP_GET_INV_DETAIL(P_ID   IN VARCHAR2,
                              P_TYPE IN VARCHAR2,
                              P_INV  IN OUT INV_INFOTEMP_SP%ROWTYPE);

  --去除字符串特殊字符
  FUNCTION FGETFORMAT(P_STR IN VARCHAR2) RETURN VARCHAR2;
  --设置字符串对齐（C=居中，L=左对齐，R=右对齐）
  FUNCTION FSETSTRALIGN(P_STR   IN VARCHAR2,
                        P_LEN   IN INTEGER,
                        P_ALIGN IN VARCHAR2) RETURN VARCHAR2;

  --判断用户是否为免抄户
  FUNCTION FGETMETERSTATUS(P_CODE IN VARCHAR2 --用户号
                           ) RETURN VARCHAR2;
  --获取一户多表期末预存余额
  FUNCTION FGETHSQMSAVING(P_MIID IN VARCHAR2 --客户代码
                          ) RETURN VARCHAR2;
  --获取合收户数
  FUNCTION FGETHSCODE(P_MIID IN VARCHAR2 --客户代码
                      ) RETURN VARCHAR2;
  --发票打印明细(一户多表)
  FUNCTION FGETHSINVDEATIL(P_MIID IN VARCHAR2 --客户代码
                           ) RETURN VARCHAR2;
  --获取用户新账卡号（表册号+册内序号）
  FUNCTION FGETNEWCARDNO(P_MIID IN VARCHAR2 --客户代码
                         ) RETURN VARCHAR2;
  --获取备注信息
  FUNCTION FGETINVMEMO(P_RLID IN VARCHAR2, --应收流水
                       P_TYPE IN VARCHAR2 --备注类型
                       ) RETURN VARCHAR2;
  --获取发票二维码
  FUNCTION FGETINVEWM(P_ID   IN VARCHAR2, --发票提取码
                      P_TYPE IN VARCHAR2 --提取码类型
                      ) RETURN VARCHAR2;
FUNCTION FGETINVUP(P_ID   IN VARCHAR2
                      ) RETURN NUMBER;
PROCEDURE SP_PREPRINT_EINVOICE_JOBRUN(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_SLTJ      IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2
                                 );
--缴费自动执行电子发票开具任务
PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2);
--JOB列队任务，2秒执行一次
 PROCEDURE SP_EINV_JOB;

END;
/


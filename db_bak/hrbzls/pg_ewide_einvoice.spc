CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_EINVOICE IS
  /*
  --授权 dba用户下执行
  begin
    dbms_java.grant_permission('TZZLS','SYS:java.net.SocketPermission','1.1.1.83:8999','connect,resolve');
  end;
  */
  /*
    CREATE SEQUENCE SEQ_EINVOICE
    MINVALUE 1
    MAXVALUE 9999999999
    START WITH 1
    INCREMENT BY 1
    CACHE 20
    ORDER;
    DELETE SYSSEQLIST WHERE SSLTBLNAME='INV_EINVOICE';
    INSERT INTO SYSSEQLIST (SSLTBLNAME, SSLSEQNAME, SSLPREFIX, SSLWIDTH, SSLCNAME, SSLSTARTNO)
           VALUES ('INV_EINVOICE', 'SEQ_EINVOICE', '', 10, '易维云平台电子发票流水号', NULL);

  */
  DEBUG      CONSTANT BOOLEAN := FALSE;
  ERRCODE    CONSTANT INTEGER := -20012;
  G_含税     CONSTANT BOOLEAN := FALSE;
  G_发票限额 CONSTANT NUMBER(10) := 9999999;
  G_用友税票 CONSTANT BOOLEAN := TRUE;

  --发票开具入口
  PROCEDURE P_EINVOICE(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                       );
  PROCEDURE p_distribute(O_INVLIST   OUT INVLIST%ROWTYPE);
  --按付款金额合并为一条明细
  PROCEDURE P_UNION(P_ID VARCHAR2);
  --按费用项目拆分
  PROCEDURE P_SHARE(P_ID VARCHAR2);
  --增补违约金明细行
  PROCEDURE P_ZNJ(P_ID VARCHAR2, P_JE IN NUMBER, P_PIID IN VARCHAR2);
  --生成发票请求流水号，并记录日志表
  FUNCTION F_GET_FPQQLSH(P_ICID VARCHAR2) RETURN VARCHAR2;
  --限额拆票过程
  PROCEDURE P_SPLIT_含税;
  PROCEDURE P_SPLIT_不含税;
  --获取发票备注
  FUNCTION F_NOTES(P_ID VARCHAR2) RETURN VARCHAR2;
  --获取税控参数
  FUNCTION F_GET_PARM(P_PARM VARCHAR2) RETURN VARCHAR2;
  --去除回车符
  FUNCTION F_DISCARDCR(P_CHAR VARCHAR2) RETURN VARCHAR2;
  --生成发票库存记录
  PROCEDURE P_INVSTOCK_ADD;
  --保存开票记录
  PROCEDURE P_SAVEINV;
  --交易日志
  PROCEDURE P_LOG(P_ID      IN OUT NUMBER,
                  P_CODE    IN VARCHAR2,
                  P_FPQQLSH IN VARCHAR2,
                  P_XH      IN NUMBER,
                  P_I_JSON  IN VARCHAR2,
                  P_O_JSON  IN VARCHAR2);
  --发票开具
  PROCEDURE P_BUILDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2);
  --开具红票
  PROCEDURE P_REDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2);
  --发票下载
  PROCEDURE P_BUILDINVFILE(P_ICID     IN VARCHAR2,
                           P_SLTJ     IN VARCHAR2 DEFAULT 'YYSF', --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           P_FILETYPE IN VARCHAR2 DEFAULT 'PNG', --文件类型（PNG,PDF,JPG 三种格式）
                           O_CODE     OUT VARCHAR2,
                           O_ERRMSG   OUT VARCHAR2,
                           O_URL1     OUT VARCHAR2,
                           O_URL2     OUT VARCHAR2);
  --发票库存
  PROCEDURE P_GETINVKC(O_CODE OUT VARCHAR2, O_ERRMSG OUT VARCHAR2);

  --获取取票二维码
  FUNCTION F_BUILDMATRIX(P_FPQQLSH VARCHAR2) RETURN VARCHAR2;

  --发票作废
  PROCEDURE P_CANCEL(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
  --发票作废
  PROCEDURE P_CANCELINV(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2);
  --发票作废
  PROCEDURE P_CANCEL_HRB(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     P_CDRLID VARCHAR2,
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
PROCEDURE P_CANCEL_HRBtest(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     P_CDRLID VARCHAR2, --应收流水号

                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
  --发票作废
  PROCEDURE P_CANCELINV_HRB(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        P_CDRLID VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2);

  --微信发票开具
  PROCEDURE P_PRINT_WX(I_ID   IN VARCHAR2, --传入流水
                       O_JSON OUT CLOB --开具结果
                       );

  --邮箱推送
  PROCEDURE P_SENDMAIL(P_URL    IN VARCHAR2,
                       P_MIID   IN VARCHAR2,
                       P_EMAIL  IN VARCHAR2,
                       P_MINAME IN VARCHAR2);

  --查询请求流水号是否已开
  PROCEDURE P_QUERYINV(P_FPQQLSH IN VARCHAR2, P_RETURN OUT VARCHAR2);

  --发票查询开具状态
  PROCEDURE P_ASYNCINV(P_FPQQLSH IN VARCHAR2,

                       P_QYSH    IN VARCHAR2,
                       /*P_RETURN  OUT LONG*/
                       O_TYPE    OUT VARCHAR2,
                       O_MSG     OUT VARCHAR2);

  --消息推送
PROCEDURE P_PUSHURL(P_TYPE    IN VARCHAR2,
                      P_FPQQLSH IN VARCHAR2,
                      P_CONTENT IN CLOB,
                      P_RETURN  OUT VARCHAR2);

PROCEDURE P_QUICKCANCEL(P_FPQQLSH IN VARCHAR2,
                          P_FPDM    IN VARCHAR2,
                          P_FPHM    IN VARCHAR2,
                          O_CODE    OUT VARCHAR2,
                          O_ERRMSG  OUT VARCHAR2);
--实收补票
PROCEDURE P_INV_ADDFP(P_DATE IN VARCHAR2);
--对票
PROCEDURE P_CHK_INV(P_DATE IN VARCHAR2);

--平票
PROCEDURE P_INV_PP(P_DATE IN VARCHAR2);
PROCEDURE P_INV_PP_HRB(P_DATE IN VARCHAR2);
--每日自动对票，对前一天票据
PROCEDURE P_INV_DP;

--对票功能-补票功能方法
PROCEDURE P_INV_ADDFP_RUN(V_DATE IN VARCHAR2);

END PG_EWIDE_EINVOICE;
/


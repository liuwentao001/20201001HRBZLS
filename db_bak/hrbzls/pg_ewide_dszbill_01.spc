CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_DSZBILL_01" IS

  ERRCODE CONSTANT INTEGER := -20012;

  PROCEDURE CREATEHD(P_DSHNO     IN VARCHAR2, --单据流水号
                     P_DSHLB     IN VARCHAR2, --单据类别
                     P_DSHSMFID  IN VARCHAR2, --营销公司
                     P_DSHDEPT   IN VARCHAR2, --受理部门
                     P_DSHCREPER IN VARCHAR2 --受理人员
                     );
  PROCEDURE CREATEDT(P_DSDNO    IN VARCHAR2, --单据流水号
                     P_DSDROWNO IN VARCHAR2, --行号
                     P_RLID     IN VARCHAR2 --应收流水
                     );

  -----------------------------------------------------
  --构造呆死帐单据
  --外部调用，将应收流水号reclist.rlid在前台插入到临时表PBPARMTEMP.c1中
  PROCEDURE CREATEDSZBILL(P_DSHNO     IN VARCHAR2, --单据流水号
                          P_DSHLB     IN VARCHAR2, --单据类别
                          P_DSHSMFID  IN VARCHAR2, --营销公司
                          P_DSHDEPT   IN VARCHAR2, --受理部门
                          P_DSHCREPER IN VARCHAR2, --受理人员
                          P_RLID      IN VARCHAR2 --应收流水号
                          );

  --删除单据
  PROCEDURE CANCELBILL(P_BILLNO IN VARCHAR2, --单据编号
                       P_PERSON IN VARCHAR2, --操作员
                       P_DJLB   IN VARCHAR2); --单据类别


  PROCEDURE CUSTBILLMAIN      (P_CCHNO  IN VARCHAR2, --批次流水
                     P_PER    IN VARCHAR2, --操作员
                     P_billid IN VARCHAR2, --单据id
                     P_BILLTYPE IN VARCHAR2 --单据类别
                     );
  --审核主程序
  PROCEDURE CUSTBILL(P_CCHNO  IN VARCHAR2, --批次流水
                     P_PER    IN VARCHAR2, --操作员
                     P_BILLTYPE IN VARCHAR2, --单据类别
                     P_COMMIT IN VARCHAR2 --提交标志
                     );
END;
/


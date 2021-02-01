CREATE OR REPLACE PACKAGE PG_UPDATE IS

  --变更管理
  PROCEDURE PROC_USER(I_WORK  IN VARCHAR2, --批次号
                      I_TPYE  IN VARCHAR2, --跟新类型
                      I_PER   IN VARCHAR2, --操作员
                      O_STATE OUT NUMBER); --执行状态

END;
/


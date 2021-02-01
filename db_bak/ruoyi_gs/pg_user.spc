CREATE OR REPLACE PACKAGE PG_USER IS

  --应收冲正_按应收账流水
  PROCEDURE AUTOSUBMIT(I_RENO  IN VARCHAR2, --批次流水
                       I_PER   IN VARCHAR2, --操作员
                       O_STATE OUT NUMBER); --执行状态

END;
/


CREATE OR REPLACE PACKAGE "PG_EWIDE_RAEDPLAN_01" IS

  --复核检查(哈尔滨)
  --返回 0  正常
  --返回 -1 异常
  PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2, /*流水号*/
                             P_MRSL      IN NUMBER, /*用水量*/
                             O_SUBCOMMIT OUT VARCHAR2); /*返回结果*/

END;
/


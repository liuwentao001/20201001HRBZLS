CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_STMETERREG" IS

  -- Author  : ADMINISTRATOR
  -- Created : 2012-9-3 上午 10:39:53
  -- Purpose : 水表入库管理
  ERRCODE CONSTANT INTEGER := -20012;
  --主单据入口
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --水表入库审核
  PROCEDURE SP_STMETERREG(P_DNO    IN VARCHAR2,
                          P_PER    IN VARCHAR2,
                          P_COMMIT IN VARCHAR2);
  --水表变更
  PROCEDURE SP_STMETERCHANGE(P_DNO    IN VARCHAR2,
                             P_PER    IN VARCHAR2,
                             P_COMMIT IN VARCHAR2);
END PG_EWIDE_STMETERREG;
/


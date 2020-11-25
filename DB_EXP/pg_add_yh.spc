CREATE OR REPLACE PACKAGE PG_add_yh is

  -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : 用户审核
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  errcode constant integer := -20012;
  v_HIRE_CODE varchar2(10) := f_get_HIRE_CODE();
  no_data_found exception;
  --审核审核入口
  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2);
  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2,
                     P_billno IN VARCHAR2,
                     P_PERSON IN VARCHAR2,
                     P_COMMIT IN VARCHAR2);

end;
/


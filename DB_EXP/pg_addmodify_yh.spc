CREATE OR REPLACE PACKAGE PG_addModify_yh is

  -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : �û����
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  errcode constant integer := -20012;
  v_HIRE_CODE varchar2(10) := f_get_HIRE_CODE();
  no_data_found exception;
  --���������
  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2);
  --������ˣ�һ��һ��
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2,
                     P_billno IN VARCHAR2,
                     P_PERSON IN VARCHAR2,
                     P_COMMIT IN VARCHAR2);

  --�û��޸���ˣ�һ��һ��
  PROCEDURE SP_yhModify(P_DJLB   IN VARCHAR2,
                        P_billno IN VARCHAR2,
                        P_PERSON IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);

end;
/


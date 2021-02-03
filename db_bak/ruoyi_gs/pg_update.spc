CREATE OR REPLACE PACKAGE PG_UPDATE IS

  --变更管理
  -- A 用户信息维护
  -- B 票据信息维护
  -- C 收费方式变更
  -- D 用水性质变更
  -- E 水表档案变更
  -- F 过户
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --批次号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER); --执行状态
END;
/


CREATE OR REPLACE PACKAGE PG_UPDATE IS

  --变更管理
  -- A 用户信息维护
  -- B 票据信息维护
  -- C 收费方式变更
  -- D 用水性质变更
  -- E 水表档案变更
  -- F 过户
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER); --执行状态

  --表册调整
  -- A 跨区域调整
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER); --执行状态

  --抄表员间表册转移
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --表册号
                       I_BFRPER  IN VARCHAR2, --新抄表员
                       I_BFRCYC  IN VARCHAR2, --新抄表周期
                       I_BFSDATE IN VARCHAR2, --新计划起始日期
                       I_BFEDATE IN VARCHAR2, --新计划结束日期
                       I_BFNRMONTH IN VARCHAR2, --新下次抄表月份
                       O_STATE   OUT NUMBER); --执行状态

  --账卡号调整
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --水表档案编号
                      I_MIBFID  IN VARCHAR2, --表册号
                      O_STATE   OUT NUMBER); --执行状态

  --等针
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --流水号
                    O_STATE   OUT NUMBER); --执行状态

  --固定量
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --流水号
                     O_STATE   OUT NUMBER); --执行状态

  --总表收免
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --流水号
                      O_STATE   OUT NUMBER); --执行状态

END;
/


CREATE OR REPLACE PACKAGE "PG_METERTRANS" IS

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;
  
  
  --2、在装水表状态
  M立户       CONSTANT VARCHAR2(2) := '1'; --【分公司】用户正在使用
  M销户       CONSTANT VARCHAR2(2) := '7'; --【分公司】销户拆表后如果没有送检，则处于销户
  --单据类别,表务类别
  BT拆表           CONSTANT CHAR(1) := 'F';
  BT故障换表       CONSTANT CHAR(1) := 'K';
  BT周期换表       CONSTANT CHAR(1) := 'L';
                          
   --周期换表、拆表、故障换表
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          );



  --撤表销户简单的销户操作 不考虑财务
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --批次流水
                                 I_PER   IN VARCHAR2, --操作员
                                 O_STATE OUT NUMBER);  --执行状态



/*  --工单单个审核过程
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN GD_METERTGLDT%ROWTYPE --单体行变更
                             );*/



  --分户、合户
  PROCEDURE SP_METERUSER(I_RENO   IN  VARCHAR2, --批次流水
                         I_PER    IN  VARCHAR2, --操作员
                         I_TYPE   IN  VARCHAR2, --类型
                         O_STATE  OUT NUMBER); -- 执行状态



  --工单流程未通过
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --操作类型
                           P_MTHNO  IN VARCHAR2, --批次流水
                           P_PER    IN VARCHAR2, --操作员
                           P_REMARK IN VARCHAR2,--备注、拒绝原因
                           P_COMMIT IN VARCHAR2);--提交标志
END;
/


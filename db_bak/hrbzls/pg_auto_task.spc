CREATE OR REPLACE PACKAGE HRBZLS.PG_AUTO_TASK as
 ERRCODE   CONSTANT INTEGER := -20012;

  procedure 月结任务(p_id varchar2);
  procedure 月末任务(p_id varchar2);
  procedure 账务检查(p_id varchar2);
  
  procedure 日结任务(p_id varchar2);
  procedure 当天日结任务(p_id varchar2);
  PROCEDURE 单任务设置(P_ID in NUMBER ,p_msg out varchar2);
  
  PROCEDURE 状态注销(p_id varchar2);
  PROCEDURE 状态注册(p_id varchar2);
  FUNCTION ISRUNNING(p_id varchar2) return varchar2;
  
  PROCEDURE 清抄表月结标志 ;
  
  PROCEDURE 自动账务处理(p_id varchar2);
  
  --p_type 抄表方式 0-无线远传 1-集抄
  procedure 智能表平台抄表(p_type  varchar2);
  
  procedure 智能表平台抄表_test(p_type  varchar2);
  
  PROCEDURE updatey001;  --更新合收表月底结算日期参数
  
  PROCEDURE 合同用户变更记录;

end PG_AUTO_TASK;
/


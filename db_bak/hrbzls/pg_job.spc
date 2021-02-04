CREATE OR REPLACE PACKAGE HRBZLS."PG_JOB" is

  -- Author  : 江浩
  -- Created : 2008-06-15 17:08:35
  -- Purpose : jh

  --错误代码
  errcode constant integer:= -20012;

  function  fwhatname(job_what in varchar2) return varchar2;

  --创建置顶JOB，此过程在系统运行初始手工执行一次
  procedure Topjobsubmit(p_time in varchar2);
  --置顶JOB调用的重建其他JOB过程
  procedure Rebuildalljobs;

  --按计划时刻重置JOB【日初】
  procedure SetCarryover(p_time in varchar2);
  --按计划时刻重置JOB【代扣导出】
  procedure Setdkexp(p_time in varchar2);
  --按计划时刻重置JOB【代扣导入】
  procedure Setdkimp(p_time in varchar2);
    --按计划时刻重置JOB【对账导入】
  procedure SetbankXCZLStaskd(P_bankid in varchar2);
  --按计划时刻重置JOB【手工代扣导入】
  procedure Sethanddkimp(p_time in date , p_bankid in varchar2 ) ;
  --按计划时刻重置JOB【代扣导出】
  procedure Sethanddkexp( p_bankid in varchar2 );
  --按计划时刻重置JOB【后台算费】
  procedure SetCal(p_time in varchar2);
  --按计划时刻重置JOB【预存抵扣销帐】
  procedure SetSavingPay(p_time in varchar2);
  --按计划时刻重置JOB【银行代收对帐】
  procedure SetDz(p_time in varchar2);
  --按计划时刻重置JOB【代收日志转存】
  procedure SetClearTransLog(p_time in varchar2);
  --按计划时刻重置JOB【报装数据导入】
  procedure SetRefmv(p_time in varchar2);
  procedure SetCarryFee(p_time in varchar2);
  procedure CarryFee;
  --日初事务
  procedure Carryover;
end pg_job;
/


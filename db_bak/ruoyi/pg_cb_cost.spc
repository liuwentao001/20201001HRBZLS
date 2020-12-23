create or replace package pg_cb_cost is
  --错误返回码
  errcode constant integer := -20012;
  
	procedure wlog(p_txt in varchar2);
  
  procedure autosubmit;
  --计划内抄表提交算费
  procedure submit(p_mrbfid in varchar2, log out clob);
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type);
end;
/


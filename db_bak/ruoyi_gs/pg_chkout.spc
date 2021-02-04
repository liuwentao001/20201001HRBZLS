create or replace package pg_chkout is
  --对账处理程序包
  
  --生成建账工单        收费员结账
  procedure ins_jzgd(p_userid varchar2) ;
  
end pg_chkout;
/


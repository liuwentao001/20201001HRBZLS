create or replace package pg_chkout is
  --对账处理程序包
  
  --收费员结账
  procedure chkout_by_user(p_userid varchar2);
  
end pg_chkout;
/


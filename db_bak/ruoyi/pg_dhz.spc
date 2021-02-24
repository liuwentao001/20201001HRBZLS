create or replace package pg_dhz is
  --呆账坏账过程包
  
  --呆账坏账工单处理
  procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2) ;
  --呆账坏账销账
  procedure dhgl_pay(p_rlid varchar2, p_oper varchar, o_log out varchar2) ;
  
end pg_dhz;
/


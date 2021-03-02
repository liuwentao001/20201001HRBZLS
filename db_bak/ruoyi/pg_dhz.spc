create or replace package pg_dhz is

  --呆账坏账 批量工单处理
  procedure dhgl_gd_pl(p_reno varchar2, p_oper in varchar2, o_log out varchar2);
  
  --呆账坏账 工单处理
  procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2);

  --呆账坏账 销账
  procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, p_payway varchar2, o_log out varchar2, o_status out varchar2);

end pg_dhz;
/


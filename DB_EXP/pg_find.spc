create or replace package pg_find is
  /*
  功能：前台页面综合查询
  参数说明
  p_yhid          用户id
  p_bookno        表册编码
  p_sbid          水表编码
  p_manageno      营销公司编码
  out             输出结果集
  */
  procedure findcustmetercomplexdoc(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor);
  
  /*
  功能：柜台缴费页面基本信息查询
  参数说明
  p_yhid          用户id
  p_yhname        用户名
  p_sbposition    用水地址
  p_yhmtel        移动电话
  out             输出结果集
  */
  procedure find_gtjf_jbxx(p_yhid in varchar2,p_yhname in varchar2,p_sbposition in varchar2,p_yhmtel in varchar2 ,out_tab out sys_refcursor);
  
  /*
  功能：柜台缴费页面欠费信息查询
  参数说明
  p_yhid          用户id
  out             输出结果集
  */
  procedure find_gtjf_qf(p_yhid in varchar2,out_tab out sys_refcursor);
  
  /*
  功能：柜台缴费页面欠费信息明细查询
  参数说明
  p_arid          流水号
  out             输出结果集
  */
  procedure find_gtjf_qfmx(p_arid in varchar2,out_tab out sys_refcursor);
  
end;
/


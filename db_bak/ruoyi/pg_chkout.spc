create or replace package pg_chkout is
  --对账处理程序包

  /*
  生成结账工单
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数：  p_userid        收费员编码
  */
  procedure ins_jzgd(p_userid varchar2) ;

  /*
  删除结账工单
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数     p_reno      建账工单编码
  */
  procedure del_jzgd(p_reno varchar2) ;

  /*
  生成对账工单
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_deptid    机构编码
  */
  procedure ins_dzgd(p_deptid varchar2) ;

  /*
  删除对账工单
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_reno    对账工单  编码
  */
  procedure del_dzgd(p_reno varchar2);

  /*
  结账工单审批
  结账工单审批通过后回写  扎帐日期（收费员结账后回写审核日期） payment.pchkdate 
  参数    p_reno 结账工单单号request_jzgd.reno
          p_oper       操作员编码
          o_log         输出日志
  */
  procedure jzgd_sp(p_reno varchar2, o_log out varchar2, o_status out varchar2);
  
   /*
  对账工单审批
  对账工单审批通过后回写  pdzdate	财务对账日期（财务对账审核后回写）
  参数    p_reno 结账工单单号request_jzgd.reno
          p_oper       操作员编码
          o_log         输出日志
  */
  procedure dzgd_sp(p_reno varchar2, o_log out varchar2, o_status out varchar2);
   
end pg_chkout;
/


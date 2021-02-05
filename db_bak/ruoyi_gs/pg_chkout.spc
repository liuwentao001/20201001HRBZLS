create or replace package pg_chkout is
  --对账处理程序包
  
  /*
  生成建账工单        
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数：  p_userid        收费员编码
  */
  procedure ins_jzgd(p_userid varchar2) ;

  /*
  删除建账工单
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
    
end pg_chkout;
/


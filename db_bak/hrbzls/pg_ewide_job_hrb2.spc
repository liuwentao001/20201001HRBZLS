CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_JOB_HRB2 AS
  /*  CREATE DATE : 2015/12/8 
   *  AUTHOR : BiYanJun
   *  PURPOSE : 哈尔滨维护后台工作包
   *  LAST MODI DATE : 2015/12/8
   */
   
  --自定义错误代码
  ERROR_CUSTOMERPWD_LENGTH constant integer := -2; 
  
  TYPE myref IS REF CURSOR;
  
  --函数名称 : f_getCustomerPwd
  --用途: 根据用户编号返回用户的水表加密密码(已转换小写)
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 加密的用户口令(32位,小写),如果有任何异常,返回null
  --创建日期: 2015/12/8
  function f_getCustomerPwd(ic_micid   IN    varchar2) return varchar2; 
  
  --过程名称 : prc_chgCustomerPwd
  --创建日期: 2015/12/8
  --用途: 修改客户的水表密码
  --参数：ic_micid    in  varchar2  用户编号
  --      ic_plainpwd in  varchar2  用户明文密码
  --      on_appcode  out number    返回码（成功执行返回 1,密码位数错误返回 -2 ,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）     
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_chgCustomerPwd( ic_micid      IN   varchar2,
                                ic_plainpwd   IN   varchar2,
                                on_appcode    OUT  number,
                                oc_error      OUT  varchar2
  ); 
  
  --函数名称 : f_getAccountPrecash
  --用途: 根据编号返回账户的预存余额(如果是合收表,返回合收账户金额)
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 预存余额
  --创建日期: 2016/3/11
  function f_getAccountPrecash(ic_micid   IN    varchar2) return number; 
  
  --过程名称 : prc_meterCancellation
  --创建日期: 2016/3/14
  --用途: 撤表销户(单块水表) 简单的销户操作 不考虑财务
  --参数：ic_micid    in  varchar2  用户编号
  --      ic_trans    in  varchar2  销户事务类型
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,密码位数错误返回 -2 ,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）     
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_meterCancellation( ic_micid      IN   varchar2,
                                   ic_trans      IN   varchar2,
                                   ic_oper       IN   varchar2,
                                   on_appcode    OUT  number,
                                   oc_error      OUT  varchar2
  );
  
  
  --函数名称 : f_checkUnfinishedBill
  --用途: 根据编号返回用户未完结的工单号
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 以'|'返回的工单号
  --创建日期: 2016/3/17
  function f_checkUnfinishedBill(ic_micid   IN    varchar2) return varchar2; 
  
  
  --函数名称 : f_getCBTFtotal
  --用途: 返回指定营业所指定账务月份撤表退费金额(审核后的)
  --参数：ic_smfid  in varchar2  营业所编号
  --      ic_month  in varchar2  账务月份 (yyyy.mm)
  --返回值: 撤表退费金额
  --创建日期: 2016/3/30
  function f_getCBTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number; 
  
  
  --函数名称 : f_getYCTFtotal
  --用途: 返回指定营业所指定账务月份预存退费金额(审核后的)
  --参数：ic_smfid  in varchar2  营业所编号
  --      ic_month  in varchar2  账务月份 (yyyy.mm)
  --返回值: 撤表退费金额
  --创建日期: 2016/3/30
  function f_getYCTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number; 
	
	--函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额
  --参数 ic_rlid   In   varchar2  应收流水号
  --返回值:对应指定应收流水号，已经调拨的预存金额
  function f_getAllotMoney(ic_rlid   IN    varchar2) return number;
  
  --函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份
  --返回值:统计指定分公司指定账务业务 已经调拨的预存金额
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month   IN    varchar2
  ) return number;
  
  
  --函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务业务 已经调拨的预存金额
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month1  IN    varchar2,
                           ic_month2  IN    varchar2
  ) return number;
  

  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量
  --参数 ic_rlid   In   varchar2  应收流水号
  --返回值:对应指定应收流水号，已经调拨的水量
  function f_getAllotSl(ic_rlid   IN    varchar2) return number;
  
  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份
  --返回值:统计指定分公司指定账务业务 已经调拨的预存金额
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month   IN    varchar2
  ) return number;
  
  
  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务业务 已经调拨的水量
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month1  IN    varchar2,
                        ic_month2  IN    varchar2
  ) return number;
  
	--函数名称:f_getAllotSl_current
  --用途:获取基建临时用水已调拨水量(回收当月)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
	--     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务月份 已经调拨当月的水量
  function f_getAllotSl_current(ic_smfid   IN    varchar2,       
                                ic_month1  IN    varchar2,
																ic_month2  IN    varchar2
  ) return number;
	
	--函数名称:f_getAllotMoney_current
  --用途:获取基建临时用水已调拨金额(回收当月)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
	--     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务月份 已经调拨当月的金额
  function f_getAllotMoney_current(ic_smfid   IN    varchar2,       
                                   ic_month1  IN    varchar2,
																	 ic_month2  IN    varchar2 
  ) return number; 
	
	--函数名称:f_getAllotNumber
  --用途:获取基建临时用水已调拨件数
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份-起始
  --返回值:统计指定分公司指定账务月份 已经调拨的件数
  function f_getAllotNumber(ic_smfid   IN    varchar2,       
                            ic_month   IN    varchar2 
  ) return number;

  --过程名称 : prc_baseAllot
  --创建日期: 2016/5/17
  --用途: 基建预存水费调拨收入
  --参数：ic_rlid     in  varchar2  应收流水号
  --      in_allotSl  in  number    调拨水量
  --      in_allotJe  in  number    调拨金额
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_baseAllot        ( ic_rlid      IN   varchar2,
                                   in_allotSl   IN   varchar2,
                                   in_allotJe   IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  );

  --过程名称 : prc_unbaseAllot
  --创建日期: 2016/5/17
  --用途: 取消预存水费调拨
  --参数：in_baid     in  number    调拨流水号
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_unbaseAllot      ( in_baid      IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  );
  
  
  --过程名称 : prc_rpt_allot_sum
  --创建日期: 2016/5/29
  --用途: 基建预存调拨统计汇总
  --参数：ic_month    in  varchar   账务月份
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_rpt_allot_sum( ic_month     in   varchar2,
                               on_appcode   out  number,
                               oc_error     out  varchar2
  ); 
  
  
  --基建预存调拨统计表 初始化
  PROCEDURE PRC_RPT_ALLOT_INIT;
  
  --过程名称: prc_rpt_allot_carryOver
  --创建日期: 2016.6
  --用途: 基建预存调拨统计表月末结转
  --参数: ic_month   in   varchar2  账务月份
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_rpt_allot_carryOver( ic_month   in   varchar2,
                                     on_appcode out  number,
                                     oc_error   out  varchar2
  );
  
  --水费水量完成情况同期对比
  procedure prc_compareReport( ic_smfid       IN   varchar2,  --营业所Id
                               ic_umonth_beg  IN   varchar2,  --比较起始账务月份
                               ic_umonth_end  IN   varchar2,  --比较终止账务月份                            
                               oc_data        out  myref      --返回数据
  );
  
  --水费水量完成情况同期对比-动态
  procedure prc_compareReport2(ic_smfid       IN   varchar2,  --营业所Id
                               ic_umonth_beg  IN   varchar2,  --比较起始账务月份
                               ic_umonth_end  IN   varchar2,  --比较终止账务月份                            
                               oc_data        out  myref      --返回数据
  );
  
   
END PG_EWIDE_JOB_HRB2;
/


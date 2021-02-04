CREATE OR REPLACE PACKAGE HRBZLS."PG_RAEDPLAN" is

  -- Author  : ADMIN
  -- Created : 2004-4-12 20:49:17
  -- Purpose : 月初处理

  --错误代码

  errcode constant integer := -20012;

  no_data_found exception;
  PROCEDURE createmr(p_mfpcode in VARCHAR2,
                     p_month   in varchar2,
                     p_bfid    in varchar2);
  /*
  表册管理页面提交处理
  参数：p_mtab： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_smfid: 目标营业所
        p_bfid:  目标表册
        p_oper： 操作员ID
  处理：1、更新抄表次序
        2、更新表册
        3、户号（表本页号）初始化
        4、生成系统变更单，形成历史变更数据
  输出：无
  */
  procedure meterbook(p_smfid in varchar2,
                      p_bfid  in varchar2,
                      p_oper  in varchar2);
  --删除抄表计划
  PROCEDURE deleteplan(p_type    in varchar2,
                       p_mfpcode in varchar2,
                       p_month   in varchar2,
                       p_bfid    in varchar2);

  -- 月终处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2009-04-04  by wy
  procedure CarryForward_mr(p_smfid  in varchar2,
                            p_month  in varchar2,
                            p_per    in varchar2,
                            p_commit in varchar2);
  -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  procedure CarryFpay_mr(p_smfid  in varchar2,
                         p_month  in varchar2,
                         p_per    in varchar2,
                         p_commit in varchar2);
  --更新单个抄表计划
  procedure sp_updatemrone(p_type   in varchar2, --更新类型 :01 更新余量
                           p_mrid   in varchar2, --抄表流水号
                           p_commit in varchar2 --是否提交
                           );

  --查未用余量
  procedure sp_getaddingsl(p_miid      in varchar2, --水表号
                           o_masecoden out number, --旧表止度
                           o_masscoden out number, --新表起度
                           o_massl     out number, --余量
                           o_adddate   out date, --创建日期
                           o_mastrans  out varchar2, --加调事务
                           o_str       out varchar2 --返回值
                           );

  --查已用余量
  procedure sp_getaddedsl(p_mrid      in varchar2, --抄表流水
                          o_masecoden out number, --旧表止度
                          o_masscoden out number, --新表起度
                          o_massl     out number, --余量
                          o_adddate   out date, --创建日期
                          o_mastrans  out varchar2, --加调事务
                          o_str       out varchar2 --返回值
                          );
  --取余量
  procedure sp_fetchaddingsl(p_mrid      in varchar2, --抄表流水
                             p_miid      in varchar2, --水表号
                             o_masecoden out number, --旧表止度
                             o_masscoden out number, --新表起度
                             o_massl     out number, --余量
                             o_adddate   out date, --创建日期
                             o_mastrans  out varchar2, --加调事务
                             o_str       out varchar2 --返回值
                             );

  --退余量
  procedure sp_rollbackaddedsl(p_mrid in varchar2, --抄表流水
                               o_str  out varchar2 --返回值
                               );

  --挫峰填谷均量计算12月历史水量表中增量抄表水量
  procedure updatemrslhis(p_smfid in varchar2, p_month in varchar2);
  --复核检查
  --复核检查
  procedure sp_mrslcheck(p_smfid     in varchar2,
                         p_mrmid     in varchar2,
                         p_MRSCODE   in varchar2,
                         p_MRECODE   in number,
                         p_MRSL      in number,
                         p_MRADDSL   in number,
                         p_MRRDATE   in date,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2);
  --求录入月均量
  function fgetmrslmonavg(p_miid    in varchar2,
                          p_mrsl    in number,
                          p_mrrdate in date) return number;
  --取三月平均
  function fgetthreemonavg(p_miid in varchar2) return number;

  --用余量
  procedure sp_useaddingsl(p_mrid  in varchar2, --抄表流水
                           p_masid in number, --余量流水
                           o_str   out varchar2 --返回值
                           );
  --还余量
  procedure sp_retaddingsl(p_MASMRID in varchar2, --抄表流水
                           o_str     out varchar2 --返回值
                           );
  --抄表批次检查
  function fcheckmrbatch(p_mrid in varchar2, p_smfid in varchar2)
    return varchar2;
  --抄表特权
  procedure sp_mrprivilege(p_mrid in varchar2,
                           p_oper in varchar2,
                           p_memo in varchar2,
                           o_str  out varchar2);
  --查询整表册是否已全部录入水量
  function fckkbfidallimputsl(p_smfid in varchar2,
                              p_bfid  in varchar2,
                              p_mon   in varchar2) return varchar2;
  --查询整表册是否已审核
  function fckkbfidallsubmit(p_smfid in varchar2,
                             p_bfid  in varchar2,
                             p_mon   in varchar2) return varchar2;
  --批量审核
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_oper in varchar2,
                            p_memo in varchar2,
                            p_flag in varchar2);

  procedure sp_mrslerrchk(p_mrid            in varchar2, --抄表流水呈
                          p_MRCHKPER        in varchar2, --复核人员
                          p_MRCHKSCODE      in number, --原起数
                          p_MRCHKECODE      in number, --原止数
                          p_MRCHKSL         in number, --原水量
                          p_MRCHKADDSL      in number, --原余量
                          p_MRCHKCARRYSL    in number, --原进位水量
                          p_MRCHKRDATE      in date, --原抄见日期
                          p_MRCHKFACE       in varchar2, --原表况
                          p_MRCHKRESULT     in varchar2, --检查结果类型
                          p_MRCHKRESULTMEMO in varchar2, --检查结果说明
                          o_str             out varchar2 --返回值
                          );

  -- 抄表机数据生成
  --p_cont 生成抄表机发出条件
  --p_commit 提交标志
  --time 2010-03-14  by wy
  procedure sp_poshandcreate(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2);

  -- 抄表机年批次取消

  --p_commit 提交标志
  --time 2010-06-21  by wy
  procedure sp_poshandcancel(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2);

  -- 抄表机数据取消
  --p_batch 抄表机发出批次
  --p_commit 提交标志
  --time 2010-03-15  by wy
  procedure sp_poshanddel(p_batch in varchar2, p_commit in varchar2);
  -- 抄表机检查
  --p_type 抄表机检查类别
  --p_batch 抄表机发出批次
  --time 2010-03-15  by wy
  procedure sp_poshandchk(p_type in varchar2, p_batch in varchar2);

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  procedure sp_poshandimp(p_oper in varchar2, --操作员
                          p_type in varchar2 --导入方式
                          );
  procedure sp_poshandimp1(p_oper in varchar2, --操作员
                           p_type in varchar2 --导入方式
                           );
  procedure sp_poshandimp_ycb(p_oper  in varchar2, --操作员
                              p_type  in varchar2, --导入方式
                              p_bfid  out varchar2,
                              p_bfid1 out varchar2);
  procedure getmrhis(p_miid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number);
  procedure sp_getnoread(vmid   in varchar2,
                         vcont  out number,
                         vtotal out number);

  procedure sp_poshandimp_tp800(p_oper in varchar2, --操作员
                                p_type in varchar2 --导入方式
                                );
  procedure sp_poshandcreate_tp900(p_smfid   in varchar2,
                                   p_month   in varchar2,
                                   p_bfidstr in varchar2,
                                   p_oper    in varchar2,
                                   p_commit  in varchar2);
  function  fbdsl(p_mrid   in varchar2)  RETURN VARCHAR2 ;
end ;
/


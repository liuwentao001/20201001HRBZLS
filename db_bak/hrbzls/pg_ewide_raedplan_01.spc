CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RAEDPLAN_01" IS

  -- Author  : ADMIN
  -- Created : 2004-4-12 20:49:17
  -- Purpose : 月初处理

  --错误代码

  ERRCODE CONSTANT INTEGER := -20012;

  NO_DATA_FOUND EXCEPTION;
  PROCEDURE CREATEMR(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
  
	--生成抄表计划-byj 修改版 
	--月初时按营业所循环 传递表册为 空值                  
   PROCEDURE CREATEMR2(P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2);		
	
   PROCEDURE CREATEMRBYMIID(P_CICODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
   PROCEDURE CREATEMR免抄户(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
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
  PROCEDURE METERBOOK(P_SMFID IN VARCHAR2,
                      P_BFID  IN VARCHAR2,
                      P_OPER  IN VARCHAR2);
  --删除抄表计划
  PROCEDURE DELETEPLAN(P_TYPE    IN VARCHAR2,
                       P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2);
                       
  --单件取消抄表计划
  PROCEDURE DELETEPLANONE(p_mrmid    IN VARCHAR2,  --水表编号
                          P_BFID     IN VARCHAR2,  --表册号
                          P_MRID     IN VARCHAR2,   --抄表流水号
                          on_appcode out number,
                          oc_error   out varchar2
  );
  
  --账务月结
  PROCEDURE CARRYFORPAY_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);
  -- 抄表月结
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2009-04-04  by wy
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);
  -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  PROCEDURE CARRYFPAY_MR(P_SMFID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2);
  --更新单个抄表计划
  PROCEDURE SP_UPDATEMRONE(P_TYPE   IN VARCHAR2, --更新类型 :01 更新余量
                           P_MRID   IN VARCHAR2, --抄表流水号
                           P_COMMIT IN VARCHAR2 --是否提交
                           );

  --查未用余量
  PROCEDURE SP_GETADDINGSL(P_MIID      IN VARCHAR2, --水表号
                           O_MASECODEN OUT NUMBER, --旧表止度
                           O_MASSCODEN OUT NUMBER, --新表起度
                           O_MASSL     OUT NUMBER, --余量
                           O_ADDDATE   OUT DATE, --创建日期
                           O_MASTRANS  OUT VARCHAR2, --加调事务
                           O_STR       OUT VARCHAR2 --返回值
                           );

  --查已用余量
  PROCEDURE SP_GETADDEDSL(P_MRID      IN VARCHAR2, --抄表流水
                          O_MASECODEN OUT NUMBER, --旧表止度
                          O_MASSCODEN OUT NUMBER, --新表起度
                          O_MASSL     OUT NUMBER, --余量
                          O_ADDDATE   OUT DATE, --创建日期
                          O_MASTRANS  OUT VARCHAR2, --加调事务
                          O_STR       OUT VARCHAR2 --返回值
                          );
  --取余量
  PROCEDURE SP_FETCHADDINGSL(P_MRID      IN VARCHAR2, --抄表流水
                             P_MIID      IN VARCHAR2, --水表号
                             O_MASECODEN OUT NUMBER, --旧表止度
                             O_MASSCODEN OUT NUMBER, --新表起度
                             O_MASSL     OUT NUMBER, --余量
                             O_ADDDATE   OUT DATE, --创建日期
                             O_MASTRANS  OUT VARCHAR2, --加调事务
                             O_STR       OUT VARCHAR2 --返回值
                             );

  --退余量
  PROCEDURE SP_ROLLBACKADDEDSL(P_MRID IN VARCHAR2, --抄表流水
                               O_STR  OUT VARCHAR2 --返回值
                               );

  --挫峰填谷均量计算12月历史水量表中增量抄表水量
  PROCEDURE UPDATEMRSLHIS(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2);

  PROCEDURE UPDATEMRSLHIS_CK(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2);
  --复核检查
  --复核检查
  PROCEDURE SP_MRSLCHECK(P_SMFID     IN VARCHAR2,
                         P_MRMID     IN VARCHAR2,
                         P_MRSCODE   IN VARCHAR2,
                         P_MRECODE   IN NUMBER,
                         P_MRSL      IN NUMBER,
                         P_MRADDSL   IN NUMBER,
                         P_MRRDATE   IN DATE,
                         O_ERRFLAG   OUT VARCHAR2,
                         O_IFMSG     OUT VARCHAR2,
                         O_MSG       OUT VARCHAR2,
                         O_EXAMINE   OUT VARCHAR2,
                         O_SUBCOMMIT OUT VARCHAR2);
  --求录入月均量
  FUNCTION FGETMRSLMONAVG(P_MIID    IN VARCHAR2,
                          P_MRSL    IN NUMBER,
                          P_MRRDATE IN DATE) RETURN NUMBER;
  --取三月平均
  FUNCTION FGETTHREEMONAVG(P_MIID IN VARCHAR2) RETURN NUMBER;

  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           );
  --还余量
  PROCEDURE SP_RETADDINGSL(P_MASMRID IN VARCHAR2, --抄表流水
                           O_STR     OUT VARCHAR2 --返回值
                           );
  --抄表批次检查
  FUNCTION FCHECKMRBATCH(P_MRID IN VARCHAR2, P_SMFID IN VARCHAR2)
    RETURN VARCHAR2;
  --抄表特权
  PROCEDURE SP_MRPRIVILEGE(P_MRID IN VARCHAR2,
                           P_OPER IN VARCHAR2,
                           P_MEMO IN VARCHAR2,
                           O_STR  OUT VARCHAR2);
  --查询整表册是否已全部录入水量
  FUNCTION FCKKBFIDALLIMPUTSL(P_SMFID IN VARCHAR2,
                              P_BFID  IN VARCHAR2,
                              P_MON   IN VARCHAR2) RETURN VARCHAR2;
  --查询整表册是否已审核
  FUNCTION FCKKBFIDALLSUBMIT(P_SMFID IN VARCHAR2,
                             P_BFID  IN VARCHAR2,
                             P_MON   IN VARCHAR2) RETURN VARCHAR2;
  --批量审核
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID IN VARCHAR2,
                            P_OPER IN VARCHAR2,
                            P_MEMO IN VARCHAR2,
                            P_FLAG IN VARCHAR2);

  PROCEDURE SP_MRSLERRCHK(P_MRID            IN VARCHAR2, --抄表流水呈
                          P_MRCHKPER        IN VARCHAR2, --复核人员
                          P_MRCHKSCODE      IN NUMBER, --原起数
                          P_MRCHKECODE      IN NUMBER, --原止数
                          P_MRCHKSL         IN NUMBER, --原水量
                          P_MRCHKADDSL      IN NUMBER, --原余量
                          P_MRCHKCARRYSL    IN NUMBER, --原进位水量
                          P_MRCHKRDATE      IN DATE, --原抄见日期
                          P_MRCHKFACE       IN VARCHAR2, --原表况
                          P_MRCHKRESULT     IN VARCHAR2, --检查结果类型
                          P_MRCHKRESULTMEMO IN VARCHAR2, --检查结果说明
                          O_STR             OUT VARCHAR2 --返回值
                          );

  -- 抄表机数据生成
  --p_cont 生成抄表机发出条件
  --p_commit 提交标志
  --time 2010-03-14  by wy
  PROCEDURE SP_POSHANDCREATE(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2);

  -- 抄表机年批次取消

  --p_commit 提交标志
  --time 2010-06-21  by wy
  PROCEDURE SP_POSHANDCANCEL(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2);

  -- 抄表机数据取消
  --p_batch 抄表机发出批次
  --p_commit 提交标志
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDDEL(P_BATCH IN VARCHAR2, P_COMMIT IN VARCHAR2);
  -- 抄表机检查
  --p_type 抄表机检查类别
  --p_batch 抄表机发出批次
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDCHK(P_TYPE IN VARCHAR2, P_BATCH IN VARCHAR2);

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
PROCEDURE SP_POSHANDIMP_HRB(P_OPER IN VARCHAR2, --操作员
                            P_SMFID IN VARCHAR2, --营业所
                          P_TYPE IN VARCHAR2, --导入方式
                          O_MSG OUT VARCHAR2  --返回更新信息
                          );
  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP(P_OPER IN VARCHAR2, --操作员
                          P_TYPE IN VARCHAR2 --导入方式
                          );
  PROCEDURE SP_POSHANDIMP1(P_OPER IN VARCHAR2, --操作员
                           P_TYPE IN VARCHAR2 --导入方式
                           );
  PROCEDURE SP_POSHANDIMP_YCB(P_OPER  IN VARCHAR2, --操作员
                              P_TYPE  IN VARCHAR2, --导入方式
                              P_BFID  OUT VARCHAR2,
                              P_BFID1 OUT VARCHAR2);
  PROCEDURE GETMRHIS(P_MIID   IN VARCHAR2,
                     P_MONTH  IN VARCHAR2,
                     O_SL_1   OUT NUMBER,
                     O_JE01_1 OUT NUMBER,
                     O_JE02_1 OUT NUMBER,
                     O_JE03_1 OUT NUMBER,
                     O_SL_2   OUT NUMBER,
                     O_JE01_2 OUT NUMBER,
                     O_JE02_2 OUT NUMBER,
                     O_JE03_2 OUT NUMBER,
                     O_SL_3   OUT NUMBER,
                     O_JE01_3 OUT NUMBER,
                     O_JE02_3 OUT NUMBER,
                     O_JE03_3 OUT NUMBER,
                     O_SL_4   OUT NUMBER,
                     O_JE01_4 OUT NUMBER,
                     O_JE02_4 OUT NUMBER,
                     O_JE03_4 OUT NUMBER);
  PROCEDURE SP_GETNOREAD(VMID   IN VARCHAR2,
                         VCONT  OUT NUMBER,
                         VTOTAL OUT NUMBER);

  PROCEDURE SP_POSHANDIMP_TP800(P_OPER IN VARCHAR2, --操作员
                                P_TYPE IN VARCHAR2 --导入方式
                                );
  PROCEDURE SP_POSHANDCREATE_TP900(P_SMFID   IN VARCHAR2,
                                   P_MONTH   IN VARCHAR2,
                                   P_BFIDSTR IN VARCHAR2,
                                   P_OPER    IN VARCHAR2,
                                   P_COMMIT  IN VARCHAR2);
  FUNCTION FBDSL(P_MRID IN VARCHAR2) RETURN VARCHAR2;
  function fgetavgmonthsl(P_MIID   IN VARCHAR2,
                                   P_READDATE1   IN DATE,
                                   P_READDATE2 IN DATE) RETURN NUMBER;
  
  --抄表水量计算(三次均量，去年同期，上次)                               
  FUNCTION FGETBDMONTHSL(P_MIID   IN VARCHAR2,
                                   P_READDATE   IN DATE,
                                   P_TYPE IN VARCHAR2) RETURN NUMBER;
                                                                    
  --复核检查(哈尔滨)
   PROCEDURE SP_MRSLCHECK_HRB(
                         P_MRMID     IN VARCHAR2,
                         P_MRSL      IN NUMBER,
                         O_SUBCOMMIT OUT VARCHAR2);
												 
   TYPE HISAVGDATA IS RECORD( mrmid   varchar2(20),
                             mrsl    number,
                             je01    number,
                             je02    number,
                             je03    number
  );
  TYPE TAB_HISAVGDATA IS TABLE OF HISAVGDATA;												 
  
END;
/


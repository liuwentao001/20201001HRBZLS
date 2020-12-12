prompt PL/SQL Developer Export User Objects for user YYSF@49.233.62.251/ORCL
prompt Created by my on 2020骞?2鏈?2鏃?
set define off
spool db_exp_sync.log

prompt
prompt Creating sequence SEQ_ARID
prompt ==========================
prompt
create sequence SEQ_ARID
minvalue 1
maxvalue 9999999999
start with 12941
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_PAIDBATCH
prompt ===============================
prompt
create sequence SEQ_PAIDBATCH
minvalue 1
maxvalue 9999999999
start with 1161047
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_PAIDMENT
prompt ==============================
prompt
create sequence SEQ_PAIDMENT
minvalue 1
maxvalue 9999999999
start with 247323
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_SBETERADDSL
prompt =================================
prompt
create sequence SEQ_SBETERADDSL
minvalue 1
maxvalue 9999999999
start with 524639
increment by 1
cache 50
order;

prompt
prompt Creating sequence SEQ_SBID
prompt ==========================
prompt
create sequence SEQ_SBID
minvalue 1
maxvalue 999999999
start with 130758270
increment by 1
cache 50
order;

prompt
prompt Creating synonym BS_MENU
prompt ========================
prompt
create or replace synonym BS_MENU
  for YYSF.T01001;

prompt
prompt Creating function F_GET_HIRE_CODE
prompt =================================
prompt
CREATE OR REPLACE FUNCTION f_get_HIRE_CODE  RETURN char AS
  v_HIRE_CODE varchar2(32);
BEGIN

   v_HIRE_CODE := 'kings';
   return v_HIRE_CODE ;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'kings';
END;
/

prompt
prompt Creating package PG_ADDMODIFY_YH
prompt ================================
prompt
CREATE OR REPLACE PACKAGE PG_addModify_yh is

  -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : 用户审核
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  errcode constant integer := -20012;
  v_HIRE_CODE varchar2(10) := f_get_HIRE_CODE();
  no_data_found exception;
  --审核审核入口
  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2);
  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2,
                     P_billno IN VARCHAR2,
                     P_PERSON IN VARCHAR2,
                     P_COMMIT IN VARCHAR2);

  --用户修改审核（一户一表）
  PROCEDURE SP_yhModify(P_DJLB   IN VARCHAR2,
                        P_billno IN VARCHAR2,
                        P_PERSON IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);

end;
/

prompt
prompt Creating package PG_ADD_YH
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_add_yh is

  -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : 用户审核
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  errcode constant integer := -20012;
  v_HIRE_CODE varchar2(10) := f_get_HIRE_CODE();
  no_data_found exception;
  --审核审核入口
  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2);
  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2,
                     P_billno IN VARCHAR2,
                     P_PERSON IN VARCHAR2,
                     P_COMMIT IN VARCHAR2);

end;
/

prompt
prompt Creating package PG_ARSPLIT_01
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE Pg_Arsplit_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_ARSPLIT_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月14日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --拆分账单单体
  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       );
   --拆分账单单体
  PROCEDURE Sp_Arsplit_change_one(p_Arsplitdt   IN Ys_Gd_Arsplitdt%rowTYPE,  
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       ); 
                                           
  --插入单负应收与应收冲正  --单条                     
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, -- 行变量
                            p_Commit IN VARCHAR --是否提交标志
                            );
  
  --应收分账处理  
  --输入应收流水，分帐金额，
  --返回分帐水量
  --1按水量乘单价分
  --2分到不足一吨水为止
  --3从高水量减起减到水量为1吨为止
  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --分帐流水
                      p_Arje IN NUMBER --分帐金额
                      ) RETURN NUMBER;

END;
/

prompt
prompt Creating package PG_ARTRANS_01
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE Pg_Artrans_01 IS

  Currentdate DATE;

  Errcode CONSTANT INTEGER := -20012;
  -----------------------------------------------------------------------------  
  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  -----------------------------------------------------------------------------                      
  --追量收费 
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2);
  -----------------------------------------------------------------------------  
  --追收插入抄表计划   
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE);
  -----------------------------------------------------------------------------  
  --追收插入抄表计划到历史库
  PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                           p_Mriftrans IN VARCHAR2, --抄表数据事务
                           Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                           Omrid       OUT Ys_Cb_Mtread.Id%TYPE);

  -----------------------------------------------------------------------------  
  --调整减免
  PROCEDURE Recadjust(p_Billno IN VARCHAR2, --单据编号
                      p_Per    IN VARCHAR2, --完结人
                      p_Memo   IN VARCHAR2, --备注
                      p_Commit IN VARCHAR --是否提交标志
                      );
  -----------------------------------------------------------------------------  
  ---实收冲正
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2);
  -----------------------------------------------------------------------------  
  --应收冲正（相当于应收调整到0 ）
  PROCEDURE Sp_Recreverse(p_Billno IN VARCHAR2, --单据编号
                          p_Per    IN VARCHAR2, --完结人
                          p_Memo   IN VARCHAR2, --备注
                          p_Commit IN VARCHAR --是否提交标志
                          );
 

END;
/

prompt
prompt Creating package PG_ARZNJ_01
prompt ============================
prompt
CREATE OR REPLACE PACKAGE Pg_Arznj_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_Arznj_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --减免单体
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       );
END;
/

prompt
prompt Creating package PG_BALANCEADJ_01
prompt =================================
prompt
CREATE OR REPLACE PACKAGE Pg_Balanceadj_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_BALANCEADJ_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月14日
  ----------------------------------------------------------------------
  -- Description: 余额调整过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --减免单体
  PROCEDURE Sp_Balanceadj(p_Bill_Id IN VARCHAR2, --批次流水
                          p_Per     IN VARCHAR2, --操作员
                          p_Commit  IN VARCHAR2 --提交标志;
                          );
END;
/

prompt
prompt Creating package PG_CBPLAN
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_CBPLAN is

  -- --------------------------------------------------------------------------
  -- Name         : PG_CBPLAN
  -- Author       : Tim
  -- Description  : 抄表计划管理  
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  errcode constant integer := -20012;

  no_data_found exception;
  PROCEDURE createCB(p_HIRE_CODE in VARCHAR2,
                     p_manage_no in VARCHAR2,
                     p_month     in varchar2,
                     p_book_no   in varchar2);
  PROCEDURE createCBsb(p_HIRE_CODE in VARCHAR2,
                       p_month     in varchar2,
                       p_sbid      in VARCHAR2);

  procedure getmrhis(p_sbid   in varchar2,
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

  PROCEDURE month_over(p_HIRE_CODE in varchar2,
                       P_ID        IN VARCHAR2,
                       P_MONTH     IN VARCHAR2,
                       P_PER       IN VARCHAR2,
                       P_COMMIT    IN VARCHAR2);
  PROCEDURE month_over_all(p_HIRE_CODE in varchar2,
                           P_ID        IN VARCHAR2,
                           P_MONTH     IN VARCHAR2,
                           P_PER       IN VARCHAR2,
                           P_COMMIT    IN VARCHAR2);
  PROCEDURE cb_delete(p_HIRE_CODE in varchar2,
                      p_MANAGE_NO in varchar2,
                      P_book_no   IN VARCHAR2,
                      P_MONTH     IN VARCHAR2,
                      p_sbid      in varchar2,
                      P_PER       IN VARCHAR2,
                      P_COMMIT    IN VARCHAR2);

end;
/

prompt
prompt Creating package PG_CB_COST
prompt ===========================
prompt
CREATE OR REPLACE PACKAGE pg_cb_cost is
  /*add 20201113*/
  ----过程提交控制
  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  --计费事务
  计划抄表   CONSTANT CHAR(1) := '1';
  余度       CONSTANT CHAR(1) := 'Q';
  营业外收入 CONSTANT CHAR(1) := 'T';
  追量       CONSTANT CHAR(1) := 'O';
  --应收总账包
  SUBTYPE RL_TYPE IS YS_ZW_ARLIST%ROWTYPE;
  TYPE RL_TABLE IS TABLE OF RL_TYPE;
  --应收明细包
  SUBTYPE RD_TYPE IS ys_zw_ardetail%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --应收临时审批明细包
  SUBTYPE RDT_TYPE IS ys_zw_ardetail_budget%ROWTYPE;
  TYPE RDT_TABLE IS TABLE OF RDT_TYPE;

  --记账方向
  DEBIT  CONSTANT CHAR(2) := 'DE'; --借方
  CREDIT CONSTANT CHAR(2) := 'CR'; --贷方

  --错误代码
  ERRCODE CONSTANT INTEGER := -20012;

  --写算费日志
  /*PROCEDURE AUTOSUBMIT;
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB);
  
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB);*/
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2);
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER); --计划内算费
  --单笔算费核心
  PROCEDURE COSTCULATECORE(MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                           P_TRANS  IN CHAR,
                           P_PSCID  IN VARCHAR2,
                           P_COMMIT IN NUMBER);
  --
  PROCEDURE COSTPIID(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                     P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                     P_SL       IN NUMBER,
                     PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                     PMD        IN YS_YH_PRICEGROUP%ROWTYPE,
                     RDTAB      IN OUT RD_TABLE,
                     P_CLASSCTL IN CHAR,
                     P_PSCID    IN NUMBER,
                     P_COMMIT   IN NUMBER);
  --
  PROCEDURE COSTSTEP_MON(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                         P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                         P_SL       IN NUMBER,
                         P_ADJSL    IN NUMBER,
                         P_ADJDJ    IN NUMBER,
                         PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                         RDTAB      IN OUT RD_TABLE,
                         P_CLASSCTL IN CHAR,
                         PMD        IN YS_YH_PRICEGROUP%ROWTYPE);
  --
  PROCEDURE COSTSTEP_YEAR(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                          P_SL       IN NUMBER,
                          P_ADJSL    IN NUMBER,
                          P_ADJDJ    IN NUMBER,
                          PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                          RDTAB      IN OUT RD_TABLE,
                          P_CLASSCTL IN CHAR,
                          PMD        YS_YH_PRICEGROUP%ROWTYPE,
                          PMONTH     IN VARCHAR2);
  --                        
  PROCEDURE INSRD(RD IN RD_TABLE, P_COMMIT IN NUMBER);
  --
  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;
  --
  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;
  --
  FUNCTION FBOUNDPARA(P_PARASTR IN CLOB) RETURN INTEGER;
  --
  FUNCTION FGETPARA(P_PARASTR IN VARCHAR2,
                    ROWN      IN INTEGER,
                    COLN      IN INTEGER) RETURN VARCHAR2;
   --预算费，提供追补、应收调整、退费单据中重算费中间数据                  
  PROCEDURE SUBMIT_VIRTUAL(p_mid    in varchar2,
                           p_PRICE_VER  IN  VARCHAR2,
                           p_prdate in date,
                           p_rdate  in date,
                           p_scode  in number,
                           p_ecode  in number,
                           p_sl     in number,
                           p_rper   in varchar2,
                           p_pfid   in varchar2,
                           p_usenum in number,
                           p_trans  in varchar2,
                           o_rlid   out varchar2)  ;                
end;
/

prompt
prompt Creating package PG_DSZBILL_01
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE Pg_Dszbill_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: PG_DSZBILL_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 呆坏账过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --单据流水号
                     p_Dshlb     IN VARCHAR2, --单据类别
                     p_Dshsmfid  IN VARCHAR2, --营销公司
                     p_Dshdept   IN VARCHAR2, --受理部门
                     p_Dshcreper IN VARCHAR2 --受理人员
                     );
  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --单据流水号
                     p_Dsdrowno IN VARCHAR2, --行号
                     p_Arid     IN VARCHAR2 --应收流水
                     );

  -----------------------------------------------------
  --构造呆死帐单据
  --外部调用，将应收流水号YS_ZW_AARIST.ARID在前台插入到临时表PBPARMTEMP.C1中
  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --单据流水号
                          p_Dshlb     IN VARCHAR2, --单据类别
                          p_Dshsmfid  IN VARCHAR2, --营销公司
                          p_Dshdept   IN VARCHAR2, --受理部门
                          p_Dshcreper IN VARCHAR2, --受理人员
                          p_Arid      IN VARCHAR2 --应收流水号
                          );

  --删除单据
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --单据编号
                       p_Person IN VARCHAR2, --操作员
                       p_Djlb   IN VARCHAR2); --单据类别

  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --批次流水
                         p_Per      IN VARCHAR2, --操作员
                         p_Billid   IN VARCHAR2, --单据ID
                         p_Billtype IN VARCHAR2 --单据类别
                         );
  --审核主程序
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --批次流水
                     p_Per      IN VARCHAR2, --操作员
                     p_Billtype IN VARCHAR2, --单据类别
                     p_Commit   IN VARCHAR2 --提交标志
                     );
END;
/

prompt
prompt Creating package PG_FIND
prompt ========================
prompt
create or replace package pg_find is
  /*
  功能：前台页面综合查询_详细信息
  参数说明
  p_yhid          用户id
  p_bookno        表册编码
  p_sbid          水表编码
  p_manageno      营销公司编码
  out             输出结果集
  */
  procedure find_zhcx_xxxx(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor);
  
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

  /*
  功能：柜台缴费页面缴费入口
  参数说明
  p_yhid          用户编码
  p_arid          流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        资金来源
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_gnm           功能码， 正常999 错误000
  p_cwxx          错误信息
  */
  procedure find_gtjf_jf(p_yhid in varchar2,
            p_arid in varchar2,
            p_oper     in varchar2,
            p_payway in varchar2,
            p_payment in number,
            p_gnm out varchar2,
            p_cwxx out varchar2);

end;
/

prompt
prompt Creating package PG_METER_COST
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE pg_meter_cost is
  /*账务的：
   ys_zw_ardetail
   ys_zw_arlist

  基本资料：
   ys_yh_sbdoc
   ys_yh_sbinfo
   ys_yh_pricegroup
   ys_yh_custinfo
   ys_yh_account

  水价：
   bas_price_name
   bas_price_detail
   bas_price_step

  抄表：
   ys_cb_mtread*/

  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  PROCEDURE PTEST(P_TXT IN VARCHAR2);
end;
/

prompt
prompt Creating type PARM_APPEND1RD
prompt ============================
prompt
CREATE OR REPLACE TYPE PARM_APPEND1RD  as object
( HIRE_CODE  VARCHAR2(20),
  ARDPSCID  number,
  ARDPMDID  number,
  ARDPFID   varchar2(10),
  ARDPIID   char(2),
  ARDCLASS  number(4),
  ARDDJ     number(13,2),
  Ardsl     number(12),
  Ardje     number(13,2),
  Ardilid   varchar2(20)
)
/

prompt
prompt Creating type PARM_APPEND1RD_TAB
prompt ================================
prompt
CREATE OR REPLACE TYPE PARM_APPEND1RD_TAB as table of parm_append1rd
/

prompt
prompt Creating type PARM_PAYAR
prompt ========================
prompt
CREATE OR REPLACE TYPE PARM_PAYAR as object
(
  arid    varchar2(1000),
  ardpiids varchar2(4000),
  arwyj   number(12, 2),
  fee1    number(12, 2),
  fee2    number(12, 2),
  fee3    number(12, 2))
/

prompt
prompt Creating type PARM_PAYAR_TAB
prompt ============================
prompt
CREATE OR REPLACE TYPE PARM_PAYAR_TAB as table of parm_payar
/

prompt
prompt Creating package PG_PAID
prompt ========================
prompt
CREATE OR REPLACE PACKAGE PG_PAID IS
  -- Public type declarations
  SUBTYPE RD_TYPE IS YS_ZW_ARDETAIL%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --存储临时变量
  /*SUBTYPE PB_TYPE IS YSPARMTEMP%ROWTYPE;
  TYPE ARR_TABLE IS TABLE OF PB_TYPE;*/
  --
  -- Public constant declarations
  --错误返回码
  ERRCODE CONSTANT INTEGER := -20012;

  --【代码规则常量】（可转化为由系统参数初始化）
  --↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  ----过程提交控制
  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  ----可忽略的应实收计帐方向，现已由+/-值含义替代
  借方 CONSTANT CHAR(2) := 'DE';
  贷方 CONSTANT CHAR(2) := 'CR';
  --【缴费业务核心规则】
  --  全局重要参数，允许各帐务流程中预存发生
  --  例如：无预存业务的项目本控制位设为false
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许预存发生 CONSTANT BOOLEAN := TRUE;

  --  全局重要参数，允许各帐务流程中期初可以是负预存、销帐后也可以是负预存，但不能发生更多的负预存
  --  true时意味着无条件销帐成功，不足额部分无底线的转负预存余额
  --  例如：某些项目中有向下取整找零的规则时此控制位为true，取整规则在调用前计算ok，本地后台不校验
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许净减后负预存 CONSTANT BOOLEAN := TRUE;

  ----净减为负预存余额时不销帐转预存
  --  作用于：PayRecCore
  净减为负预存不销帐 CONSTANT BOOLEAN := FALSE;
  代扣后是否发送短信 CONSTANT BOOLEAN := FALSE;

  --  调度作业方式下余额足额抵扣当前欠费时控制是否抵扣含违约金欠费记录
  --  作用于：pg_pay.ReMainPayCoreByCust
  允许预存抵扣违约欠费 CONSTANT INTEGER := 1;

  允许重复销帐 CONSTANT INTEGER := 1;

  ----实时代收单缴预存规则
  --  作用于：BPay
  允许实时代收单缴预存 CONSTANT BOOLEAN := FALSE; --20140812 0:30 true->flase

  --【一些可选的销帐方式】
  ----允许销帐拆帐
  不允许拆帐 CONSTANT INTEGER := 0; --0金额非0水量销帐
  允许拆帐   CONSTANT INTEGER := 1; --默认
  ----代收对帐方法
  正常对帐 CONSTANT INTEGER := 1; --自动化调用时可传此参数，若存在已对帐记录，且有平帐，则对帐失败；
  重新对帐 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已对帐记录，且有平帐，则还原平帐（对帐冲正进行对帐补销、对帐补销进行对帐冲正）后进行首次对帐；
  ----批扣本地处理方式
  正常批扣处理 CONSTANT INTEGER := 1; --自动化调用时可传此参数，对新已下账记录进行销帐，其余根据在途完结标志全部解锁；
  重新批扣处理 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已销帐记录，则还原销帐（代扣销帐进行代扣冲正）后进行正常处理；
  ----批次在途完结否
  批扣未结束 CONSTANT INTEGER := 0; --本次文档后银行还未结束扣费
  批扣结束   CONSTANT INTEGER := 1; --已结束
  ----批扣文本类型
  成功批扣文本   CONSTANT INTEGER := 0; --只有失败记录
  失败批扣文本   CONSTANT INTEGER := 1; --只有成功记录
  全部批扣文本   CONSTANT INTEGER := 2; --所有记录
  无文本全部成功 CONSTANT INTEGER := 3; --无文本返回，银行口头通知所有批扣成功
  ----抵减预存余额后代扣
  抵减预存余额后代扣 CONSTANT INTEGER := 1; --批扣发包时预存余额参与计算应缴，etlje = etlrlje +etlwyj +etlremaind
  NO抵减预存余额代扣 CONSTANT INTEGER := 0; --批扣发包时预存余额不参与计算应缴，etlje = etlrlje +etlwyj
  ----缴费通知
  全局屏蔽通知 CONSTANT BOOLEAN := FALSE;
  局部屏蔽通知 CONSTANT INTEGER := 0; --（可能用于外部传参，故使用通用int类型）
  局部允许通知 CONSTANT INTEGER := 1; --（可能用于外部传参，故使用通用int类型）
  ----销帐违约金分帐，可通过参数控制销帐核心过程中对违约金和本金分帐处理，分帐条件内置
  ----独立违约金发票需求
  允许销帐违约金分帐 CONSTANT BOOLEAN := TRUE; --
  --↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
  --常量参数
  PTRANS_柜台缴费 CONSTANT CHAR(1) := 'P'; --自来水柜台缴费
  PTRANS_代收销帐 CONSTANT CHAR(1) := 'B'; --银行实时代收
  PTRANS_代收补销 CONSTANT CHAR(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销,隔日发起）
  PTRANS_代扣销帐 CONSTANT CHAR(1) := 'D'; --代扣销帐
  PTRANS_托收销帐 CONSTANT CHAR(1) := 'T'; --托收票据销帐
  PTRANS_独立预存 CONSTANT CHAR(1) := 'S'; --自来水柜台独立预存
  PTRANS_票据销帐 CONSTANT CHAR(1) := 'I'; --走收票据销帐
  PTRANS_预存抵扣 CONSTANT CHAR(1) := 'U'; --算费过程即时预存抵扣
  PTRANS_预存调拨 CONSTANT CHAR(1) := 'K'; --合收表创建时子表预存余额转到主表预存余额中

  PTRANS_冲正       CONSTANT CHAR(1) := 'C'; --冲正
  PTRANS_退费       CONSTANT CHAR(1) := 'V'; --退费
  PTRANS_代收冲正   CONSTANT CHAR(1) := 'R'; --实时代收单边帐冲销
  PTRANS_预售       CONSTANT CHAR(1) := 'Q'; --预售水
  PTRANS_零量费销帐 CONSTANT CHAR(1) := 'W'; --零量费销帐
  --
  FUNCTION OBTWYJ(P_SDATE IN DATE, P_EDATE IN DATE, P_JE IN NUMBER)
    RETURN NUMBER;
  --
  function ObtWyjAdj(p_arid     in varchar2, --应收流水
                     p_ardpiids in varchar2, --应收明细费项串'01|02|03'
                     p_edate    in date --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) return number;
  --
  PROCEDURE POSCUSTFORYS(P_SBID     IN VARCHAR2,
                         P_ARSTR    IN VARCHAR2,
                         P_POSITION IN VARCHAR2,
                         P_OPER     IN VARCHAR2,
                         P_PAYPOINT IN VARCHAR2,
                         P_PAYWAY   IN VARCHAR2,
                         P_PAYMENT  IN NUMBER,
                         P_BATCH    IN VARCHAR2,
                         P_PID      OUT VARCHAR2);
  --
  PROCEDURE POSCUST(P_SBID     IN VARCHAR2,
                    P_PARM_ARS IN PARM_PAYAR_TAB,
                    P_POSITION IN VARCHAR2,
                    P_OPER     IN VARCHAR2,
                    P_PAYPOINT IN VARCHAR2,
                    P_PAYWAY   IN VARCHAR2,
                    P_PAYMENT  IN NUMBER,
                    P_BATCH    IN VARCHAR2,
                    P_PID      OUT VARCHAR2);
  --
  PROCEDURE PAYCUST(P_SBID        IN VARCHAR2,
                    P_PARM_ARS    IN PARM_PAYAR_TAB,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_PID_SOURCE  IN VARCHAR2,
                    P_COMMIT      IN NUMBER,
                    P_CTL_MSG     IN NUMBER,
                    P_CTL_PRE     IN NUMBER,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    P_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PAYZWARPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                       P_COMMIT   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE ZWARREVERSECORE(P_ARID_SOURCE         IN VARCHAR2,
                            P_ARTRANS_REVERSE     IN VARCHAR2,
                            P_PBATCH_REVERSE      IN VARCHAR2,
                            P_PID_REVERSE         IN VARCHAR2,
                            P_PPAYMENT_REVERSE    IN NUMBER,
                            P_MEMO                IN VARCHAR2,
                            P_CTL_MIRCODE         IN VARCHAR2,
                            P_COMMIT              IN NUMBER DEFAULT 不提交,
                            O_ARID_REVERSE        OUT VARCHAR2,
                            O_ARTRANS_REVERSE     OUT VARCHAR2,
                            O_ARJE_REVERSE        OUT NUMBER,
                            O_ARZNJ_REVERSE       OUT NUMBER,
                            O_ARSXF_REVERSE       OUT NUMBER,
                            O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                            IO_ARSAVINGQM_REVERSE IN OUT NUMBER);
  --
  PROCEDURE PAYWYJPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                      P_COMMIT   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE PAYZWARCORE(P_PID          IN VARCHAR2,
                        P_BATCH        IN VARCHAR2,
                        P_PAYMENT      IN NUMBER,
                        P_REMAINBEFORE IN NUMBER,
                        P_PAIDDATE     IN DATE,
                        P_PAIDMONTH    IN VARCHAR2,
                        P_PARM_ARS     IN PARM_PAYAR_TAB,
                        P_COMMIT       IN NUMBER DEFAULT 不提交,
                        O_SUM_ARJE     OUT NUMBER,
                        O_SUM_ARZNJ    OUT NUMBER,
                        O_SUM_ARSXF    OUT NUMBER);
  --                    
  PROCEDURE PRECUST(P_SBID        IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PRECUSTBACK(P_SBID        IN VARCHAR2,
                        P_POSITION    IN VARCHAR2,
                        P_OPER        IN VARCHAR2,
                        P_PAYWAY      IN VARCHAR2,
                        P_PAYMENT     IN NUMBER,
                        P_MEMO        IN VARCHAR2,
                        P_BATCH       IN OUT VARCHAR2,
                        O_PID         OUT VARCHAR2,
                        O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PRECORE(P_SBID        IN VARCHAR2,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_COMMIT      IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  FUNCTION FMID(P_STR IN VARCHAR2, P_SEP IN VARCHAR2) RETURN INTEGER;
  
  --1、实收冲正（当月负实收）
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER);
 -- 应收追帐核心
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2);
  --应收追正
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER);
  
  --实收冲正次核心
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2);
   --水司柜台冲正(不退款)   
   procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2); 
 --应收追调 
  procedure RecAppendAdj(p_rlmid           in varchar2,
                         p_rlcname         in varchar2,
                         p_rlpfid          in varchar2,
                         p_rlrdate         in date,
                         p_rlscode         in number,
                         p_rlecode         in number,
                         p_rlsl            in number,
                         p_rlje            in number,
                         p_rlznj           in number,
                         p_rltrans         in varchar2,
                         p_rlmemo          in varchar2,
                         p_rlid_source     in varchar2,
                         p_parm_append1rds parm_append1rd_tab,
                         p_ctl_mircode     in varchar2,
                         p_commit          in number default 不提交,
                         o_rlid            out varchar2);   
                         
 -- 应收调整 
  procedure RecAdjust(p_rlmid           in varchar2,
                      p_rlcname         in varchar2,
                      p_rlpfid          in varchar2,
                      p_rlrdate         in date,
                      p_rlscode         in number,
                      p_rlecode         in number,
                      p_rlsl            in number,
                      p_rlje            in number,
                      p_rlznj           in number,
                      p_rltrans         in varchar2,
                      p_rlmemo          in varchar2,
                      p_rlid_source     in varchar2,
                      p_parm_append1rds parm_append1rd_tab,
                      p_commit          in number default 不提交,
                      p_ctl_mircode     in varchar2,
                      o_rlid_reverse    out varchar2,
                      o_rlid            out varchar2) ;                                          
END PG_PAID;
/

prompt
prompt Creating package PG_PAID_01BAK
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE Pg_Paid_01bak IS
  -- Public type declarations
  SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
  TYPE Rd_Table IS TABLE OF Rd_Type;
  --存储临时变量
  SUBTYPE Pb_Type IS Ysparmtemp%ROWTYPE;
  TYPE Arr_Table IS TABLE OF Pb_Type;
  --
  -- Public constant declarations
  --错误返回码
  Errcode CONSTANT INTEGER := -20012;

  --【代码规则常量】（可转化为由系统参数初始化）
  --↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  ----过程提交控制
  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  ----可忽略的应实收计帐方向，现已由+/-值含义替代
  借方 CONSTANT CHAR(2) := 'DE';
  贷方 CONSTANT CHAR(2) := 'CR';
  --【缴费业务核心规则】
  --  全局重要参数，允许各帐务流程中预存发生
  --  例如：无预存业务的项目本控制位设为false
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许预存发生 CONSTANT BOOLEAN := TRUE;

  --  全局重要参数，允许各帐务流程中期初可以是负预存、销帐后也可以是负预存，但不能发生更多的负预存
  --  true时意味着无条件销帐成功，不足额部分无底线的转负预存余额
  --  例如：某些项目中有向下取整找零的规则时此控制位为true，取整规则在调用前计算ok，本地后台不校验
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许净减后负预存 CONSTANT BOOLEAN := TRUE;

  ----净减为负预存余额时不销帐转预存
  --  作用于：PayRecCore
  净减为负预存不销帐 CONSTANT BOOLEAN := FALSE;
  代扣后是否发送短信 CONSTANT BOOLEAN := FALSE;

  --  调度作业方式下余额足额抵扣当前欠费时控制是否抵扣含违约金欠费记录
  --  作用于：pg_pay.ReMainPayCoreByCust
  允许预存抵扣违约欠费 CONSTANT INTEGER := 1;

  允许重复销帐 CONSTANT INTEGER := 1;

  ----实时代收单缴预存规则
  --  作用于：BPay
  允许实时代收单缴预存 CONSTANT BOOLEAN := FALSE; --20140812 0:30 true->flase

  --【一些可选的销帐方式】
  ----允许销帐拆帐
  不允许拆帐 CONSTANT INTEGER := 0; --0金额非0水量销帐
  允许拆帐   CONSTANT INTEGER := 1; --默认
  ----代收对帐方法
  正常对帐 CONSTANT INTEGER := 1; --自动化调用时可传此参数，若存在已对帐记录，且有平帐，则对帐失败；
  重新对帐 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已对帐记录，且有平帐，则还原平帐（对帐冲正进行对帐补销、对帐补销进行对帐冲正）后进行首次对帐；
  ----批扣本地处理方式
  正常批扣处理 CONSTANT INTEGER := 1; --自动化调用时可传此参数，对新已下账记录进行销帐，其余根据在途完结标志全部解锁；
  重新批扣处理 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已销帐记录，则还原销帐（代扣销帐进行代扣冲正）后进行正常处理；
  ----批次在途完结否
  批扣未结束 CONSTANT INTEGER := 0; --本次文档后银行还未结束扣费
  批扣结束   CONSTANT INTEGER := 1; --已结束
  ----批扣文本类型
  成功批扣文本   CONSTANT INTEGER := 0; --只有失败记录
  失败批扣文本   CONSTANT INTEGER := 1; --只有成功记录
  全部批扣文本   CONSTANT INTEGER := 2; --所有记录
  无文本全部成功 CONSTANT INTEGER := 3; --无文本返回，银行口头通知所有批扣成功
  ----抵减预存余额后代扣
  抵减预存余额后代扣 CONSTANT INTEGER := 1; --批扣发包时预存余额参与计算应缴，etlje = etlrlje +etlwyj +etlremaind
  No抵减预存余额代扣 CONSTANT INTEGER := 0; --批扣发包时预存余额不参与计算应缴，etlje = etlrlje +etlwyj
  ----缴费通知
  全局屏蔽通知 CONSTANT BOOLEAN := FALSE;
  局部屏蔽通知 CONSTANT INTEGER := 0; --（可能用于外部传参，故使用通用int类型）
  局部允许通知 CONSTANT INTEGER := 1; --（可能用于外部传参，故使用通用int类型）
  ----销帐违约金分帐，可通过参数控制销帐核心过程中对违约金和本金分帐处理，分帐条件内置
  ----独立违约金发票需求
  允许销帐违约金分帐 CONSTANT BOOLEAN := TRUE; --
  --↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
  --常量参数
  Ptrans_柜台缴费 CONSTANT CHAR(1) := 'P'; --自来水柜台缴费
  Ptrans_代收销帐 CONSTANT CHAR(1) := 'B'; --银行实时代收
  Ptrans_代收补销 CONSTANT CHAR(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销,隔日发起）
  Ptrans_代扣销帐 CONSTANT CHAR(1) := 'D'; --代扣销帐
  Ptrans_托收销帐 CONSTANT CHAR(1) := 'T'; --托收票据销帐
  Ptrans_独立预存 CONSTANT CHAR(1) := 'S'; --自来水柜台独立预存
  Ptrans_票据销帐 CONSTANT CHAR(1) := 'I'; --走收票据销帐
  Ptrans_预存抵扣 CONSTANT CHAR(1) := 'U'; --算费过程即时预存抵扣
  Ptrans_预存调拨 CONSTANT CHAR(1) := 'K'; --合收表创建时子表预存余额转到主表预存余额中

  Ptrans_冲正       CONSTANT CHAR(1) := 'C'; --冲正
  Ptrans_退费       CONSTANT CHAR(1) := 'V'; --退费
  Ptrans_代收冲正   CONSTANT CHAR(1) := 'R'; --实时代收单边帐冲销
  Ptrans_预售       CONSTANT CHAR(1) := 'Q'; --预售水
  Ptrans_零量费销帐 CONSTANT CHAR(1) := 'W'; --零量费销帐
  --
  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER;
  --
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --应收流水
                     p_Ardpiids IN VARCHAR2, --应收明细费项串'01|02|03'
                     p_Edate    IN DATE --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) RETURN NUMBER;
  --
  PROCEDURE Poscustforys(p_Sbid     IN VARCHAR2,
                         p_Arstr    IN VARCHAR2,
                         p_Position IN VARCHAR2,
                         p_Oper     IN VARCHAR2,
                         p_Paypoint IN VARCHAR2,
                         p_Payway   IN VARCHAR2,
                         p_Payment  IN NUMBER,
                         p_Batch    IN VARCHAR2,
                         p_Pid      OUT VARCHAR2);
  --
  PROCEDURE Poscust(p_Sbid     IN VARCHAR2,
                    p_Parm_Ars IN Parm_Payar_Tab,
                    p_Position IN VARCHAR2,
                    p_Oper     IN VARCHAR2,
                    p_Paypoint IN VARCHAR2,
                    p_Payway   IN VARCHAR2,
                    p_Payment  IN NUMBER,
                    p_Batch    IN VARCHAR2,
                    p_Pid      OUT VARCHAR2);
  --
  PROCEDURE Paycust(p_Sbid        IN VARCHAR2,
                    p_Parm_Ars    IN Parm_Payar_Tab,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Pid_Source  IN VARCHAR2,
                    p_Commit      IN NUMBER,
                    p_Ctl_Msg     IN NUMBER,
                    p_Ctl_Pre     IN NUMBER,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    p_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  PROCEDURE Payzwarpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                       p_Commit   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT 不提交,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER);
  --
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT 不提交,
                        o_Sum_Arje     OUT NUMBER,
                        o_Sum_Arznj    OUT NUMBER,
                        o_Sum_Arsxf    OUT NUMBER);
  --                    
  PROCEDURE Precust(p_Sbid        IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  PROCEDURE Precustback(p_Sbid        IN VARCHAR2,
                        p_Position    IN VARCHAR2,
                        p_Oper        IN VARCHAR2,
                        p_Payway      IN VARCHAR2,
                        p_Payment     IN NUMBER,
                        p_Memo        IN VARCHAR2,
                        p_Batch       IN OUT VARCHAR2,
                        o_Pid         OUT VARCHAR2,
                        o_Remainafter OUT NUMBER);
  --
  PROCEDURE Precore(p_Sbid        IN VARCHAR2,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Commit      IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  FUNCTION Fmid(p_Str IN VARCHAR2, p_Sep IN VARCHAR2) RETURN INTEGER;

  --1、实收冲正（当月负实收）
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER);
 -- 应收追帐核心
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2);
  --应收追正
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER);
  
  --实收冲正次核心
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2);
   --水司柜台冲正(不退款)   
   procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2);                                                                           
  /*******************************************************************************************
  函数名：F_PAYBACK_BY_PMID
  用途：实收冲正,按实收流水id冲正
  参数：
  业务规则：
  
  返回值：
  *******************************************************************************************/
/*  FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN YS_ZW_PAIDMENT.PID%TYPE,
                             P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                             P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                             P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                             P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                             P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE,
                             P_COMMIT   IN VARCHAR2) 
                   RETURN VARCHAR2;*/

/* \*******************************************************************************************
  函数名：F_PAYBACK_BATCH
  用途：实收冲正,按批次冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************\
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                              P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                              P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                              P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                              P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE)
    RETURN VARCHAR2;
    */
END;
/

prompt
prompt Creating package PG_SBTRANS
prompt ===========================
prompt
CREATE OR REPLACE PACKAGE "PG_SBTRANS" IS
  -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : 用户审核
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  ERRCODE CONSTANT INTEGER := -20012;

  M换表     CONSTANT VARCHAR2(2) := '11'; --【分公司】换表拆表后如果没有送检，水表状态为换表
  M违章     CONSTANT VARCHAR2(2) := '12'; --【分公司】违章拆表后，水表状态为违章
  M报停     CONSTANT VARCHAR2(2) := '13'; --【分公司】报停拆表后，则处于报停
  M暂停     CONSTANT VARCHAR2(2) := '14'; --【分公司】暂停拆表后，则处于暂停
  M遗失     CONSTANT VARCHAR2(2) := '15'; --【分公司】遗失处理后，为遗失
  M总仓出库 CONSTANT VARCHAR2(2) := '17'; --【总仓】总仓配表到分公司后，总仓水表为总仓出库
  M拆迁     CONSTANT VARCHAR2(2) := '16'; --【分公司】拆迁拆表后如果没有送检，为拆迁
  M欠费停水 CONSTANT VARCHAR2(2) := '21'; --【总仓】欠费造成停水

  --2、在装水表状态
  M立户       CONSTANT VARCHAR2(2) := '1'; --【分公司】用户正在使用
  M销户       CONSTANT VARCHAR2(2) := '7'; --【分公司】销户拆表后如果没有送检，则处于销户
  M销户中     CONSTANT VARCHAR2(2) := '19'; --【分公司】销户拆表派工后后完工前
  M口径变更中 CONSTANT VARCHAR2(2) := '20'; --【分公司】口径变更派工后完工前
  M欠费停水中 CONSTANT VARCHAR2(2) := '21'; --【分公司】欠费停水派工后完工前
  M报停中     CONSTANT VARCHAR2(2) := '13';
  M复装中     CONSTANT VARCHAR2(2) := '22'; --【分公司】复装派工后完工前
  M校表中     CONSTANT VARCHAR2(2) := '23'; --【分公司】校表派工后完工前
  M故障换表中 CONSTANT VARCHAR2(2) := '24'; --【分公司】故障换表派工后完工前
  M周检换表中 CONSTANT VARCHAR2(2) := '25'; --【分公司】周检换表派工后完工前
  M复查中     CONSTANT VARCHAR2(2) := '26'; --【分公司】复查派工后完工前
  M升移中     CONSTANT VARCHAR2(2) := '27'; --【分公司】水表升移改造派工后完工前

  --单据类别,表务类别
  --
/*  BT水表升移       CONSTANT CHAR(1) := '3';
  BT水表整改       CONSTANT CHAR(1) := '4';
  BT改装总表       CONSTANT CHAR(2) := 'NA'; --报装类
  BT销户拆表       CONSTANT CHAR(1) := 'F';
  BT口径变更       CONSTANT CHAR(1) := 'G';
  BT欠费停水       CONSTANT CHAR(1) := 'H';
  BT恢复供水       CONSTANT CHAR(1) := '9';
  BT报停           CONSTANT CHAR(1) := '2';
  BT复装           CONSTANT CHAR(1) := 'I';
  BT换阀门         CONSTANT CHAR(1) := 'P';
  BT校表           CONSTANT CHAR(1) := 'A';
  BT故障换表       CONSTANT CHAR(1) := 'K';
  BT周期换表       CONSTANT CHAR(1) := 'L';
  BT复查工单       CONSTANT CHAR(2) := 'NM';
  BT安装分类计量表 CONSTANT CHAR(2) := 'NP'; --报装类
  BT补装户表       CONSTANT CHAR(2) := 'NQ'; --报装类*/

  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                  P_BILLNO    IN VARCHAR2,
                  P_PERSON    IN VARCHAR2,
                  P_BILLID    IN VARCHAR2,
                  P_DJLB      IN VARCHAR2);

  --工单主程序
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                       P_TYPE      IN VARCHAR2, --操作类型
                       P_BILL_ID   IN VARCHAR2, --批次流水
                       P_PER       IN VARCHAR2, --操作员
                       P_COMMIT    IN VARCHAR2 --提交标志
                       );

  --工单单个审核过程
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --类型
                          P_PERSON IN VARCHAR2, -- 操作员
                          P_MD     IN ys_gd_metertransdt%ROWTYPE --单体行变更
                          );

END PG_SBTRANS;
/

prompt
prompt Creating type CONNSTRIMPL
prompt =========================
prompt
CREATE OR REPLACE TYPE CONNSTRIMPL as object
(
  currentstr varchar2(4000),
  currentseprator varchar2(8),
  static function ODCIAggregateInitialize(sctx IN OUT connstrImpl)
    return number,
  member function ODCIAggregateIterate(self IN OUT connstrImpl,
    value IN VARCHAR2) return number,
  member function ODCIAggregateTerminate(self IN connstrImpl,
    returnValue OUT VARCHAR2, flags IN number) return number,
  member function ODCIAggregateMerge(self IN OUT connstrImpl,
    ctx2 IN connstrImpl) return number)
/

prompt
prompt Creating function CONNSTR
prompt =========================
prompt
CREATE OR REPLACE FUNCTION CONNSTR (input VARCHAR2) RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING connstrImpl;
/

prompt
prompt Creating function FCHKCBMK
prompt ==========================
prompt
CREATE OR REPLACE FUNCTION FCHKCBMK
   (vmiid IN VARCHAR2)
   Return CHAR
AS
   lret       char(1);
   /*vmistatus  METERINFO.Mistatus%type;
   vmitype    METERINFO.Mitype%type;
   vmiifsl    METERINFO.Miifsl%type;
   vmiifchk   METERINFO.miifchk%type;
   mi         meterinfo%rowtype;*/
BEGIN
   /*SELECT Mistatus,nvl(Mitype,'1'),Miifsl,NVL(miifchk,'N')
     INTO vmistatus,vmitype,vmiifsl,vmiifchk
     FROM METERINFO
    WHERE MIID=vmiid;
   --非抄表类型的表状态水表不抄
   --
\*   IF vmiifchk ='Y' THEN
      return 'N';  --add 20141121 HB 哈尔滨计量表不生成抄表计划
   END IF ;
   *\
   select SMSMEMO into lret from sysmeterstatus where smsid=vmistatus;
   if lret='N' then
      return 'N';
   end if;
   --非抄表类型的表类型水表不抄
   select smtifread into lret from sysmetertype where smtid=vmitype;
   if lret='N' then
      return 'N';
   end if;
   --一表多户分表水表不抄 zhb
   select * into mi from meterinfo where miid=vmiid;
   if mi.micolumn9='Y' and mi.micode <> mi.mipriid  then
      return 'N';
   end if;*/

   Return 'Y';
exception

WHEN OTHERS THEN
   Return 'N';
END;
/

prompt
prompt Creating function FIND_IN_SET
prompt =============================
prompt
CREATE OR REPLACE FUNCTION FIND_IN_SET(piv_str1 varchar2, piv_str2 varchar2, p_sep varchar2 := ',')
RETURN NUMBER IS
  l_idx    number:=0; -- 用于计算piv_str2中分隔符的位置
  str      varchar2(500);  -- 根据分隔符截取的子字符串
  piv_str  varchar2(500) := piv_str2; -- 将piv_str2赋值给piv_str
  res      number:=0; -- 返回结果
  res_place      number:=0;-- 原字符串在目标字符串中的位置
BEGIN
-- 如果字段是null 则返回0
IF piv_str2 IS NULL THEN
  RETURN res;
END IF;
-- 如果piv_str中没有分割符，直接判断piv_str1和piv_str是否相等，相等 res_place=1
IF instr(piv_str, p_sep, 1) = 0 THEN
   IF piv_str = piv_str1 THEN
      res_place:=1;
      res:= res_place;
   END IF;
ELSE
 -- 循环按分隔符截取piv_str
LOOP
    l_idx := instr(piv_str,p_sep);
    --
    res_place := res_place + 1;
    -- 当piv_str中还有分隔符时
      IF l_idx > 0 THEN
      -- 截取第一个分隔符前的字段str
         str:= substr(piv_str,1,l_idx-1);
         -- 判断 str 和piv_str1 是否相等，相等则结束循环判断
         IF str = piv_str1 THEN
           res:= res_place;
           EXIT;
         END IF;
        piv_str := substr(piv_str,l_idx+length(p_sep));
      ELSE
      -- 当截取后的piv_str 中不存在分割符时，判断piv_str和piv_str1是否相等，相等 res=res_path
        IF piv_str = piv_str1 THEN
           res:= res_place;
        END IF;
        -- 无论最后是否相等，都跳出循环
        EXIT;
      END IF;
 END LOOP;
 -- 结束循环
 END IF;
 -- 返回res
 RETURN res;
END FIND_IN_SET;
/

prompt
prompt Creating function FOBTMANAPARA
prompt ==============================
prompt
CREATE OR REPLACE FUNCTION FOBTMANAPARA(P_MAID IN VARCHAR2,P_MANO IN VARCHAR2) RETURN VARCHAR2 AS
   V_RET VARCHAR2(1000);
BEGIN
  --获取架构参数
  SELECT CONTENT
    INTO V_RET
    FROM BAS_MANA_PARA
   WHERE MANAGE_NO = P_MAID
     AND PARAMETER_NO = P_MANO;
  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END;
/

prompt
prompt Creating function F_GET_SEQ_NEXT
prompt ================================
prompt
CREATE OR REPLACE FUNCTION F_GET_SEQ_NEXT(AS_TAB_NAME IN VARCHAR2)
  RETURN VARCHAR2 IS
  -- --------------------------------------------------------------------------
  -- Name         : F_GET_SEQ_NEXT
  -- Author       : Tim
  -- Description  : 按照在SYS_SEQ_ID 表中定义的细节返回序列值
  -- Ammedments   : 
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation
  -- --------------------------------------------------------------------------
  LN_SEQ_NUM    NUMBER;
  LS_SEQ_NUM    VARCHAR2(20);
  LS_PREFIX     VARCHAR2(2);
  AS_SEQ_NAME   VARCHAR2(30);
  TEMP_ID       VARCHAR2(40);
  LS_CUR_SYNTAX VARCHAR(200);
  LI_CUR_HANDLE INTEGER;
  LI_RTN        INTEGER;
  LR_SEQLIST    SYS_SEQ_ID%ROWTYPE;
  PRELEN        NUMBER;
BEGIN
  --获得当前的序列相关的定义
  SELECT SEQSEQNAME, NVL(SEQPREFIX, ' '), SEQWIDTH, SEQSTARTNO
    INTO LR_SEQLIST.SEQSEQNAME,
         LR_SEQLIST.SEQPREFIX,
         LR_SEQLIST.SEQWIDTH,
         LR_SEQLIST.SEQSTARTNO
    FROM SYS_SEQ_ID
   WHERE UPPER(SEQTBLNAME) = UPPER(AS_TAB_NAME);

  IF TRIM(LR_SEQLIST.SEQPREFIX) IS NULL THEN
    PRELEN := 0;
  ELSE
    PRELEN := LENGTH(TRIM(LR_SEQLIST.SEQPREFIX));
  END IF;

  --动态SQL取序列的值
  AS_SEQ_NAME   := LR_SEQLIST.SEQSEQNAME;
  LS_PREFIX     := LR_SEQLIST.SEQPREFIX;
  LI_CUR_HANDLE := DBMS_SQL.OPEN_CURSOR;
  LS_CUR_SYNTAX := 'select ' || AS_SEQ_NAME || '.nextval from dual';
  DBMS_SQL.PARSE(LI_CUR_HANDLE, LS_CUR_SYNTAX, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(LI_CUR_HANDLE, 1, LN_SEQ_NUM);

  LI_RTN := DBMS_SQL.EXECUTE(LI_CUR_HANDLE);
  IF DBMS_SQL.FETCH_ROWS(LI_CUR_HANDLE) > 0 THEN
    DBMS_SQL.COLUMN_VALUE(LI_CUR_HANDLE, 1, LN_SEQ_NUM);
    DBMS_SQL.CLOSE_CURSOR(LI_CUR_HANDLE);
  END IF;

  -- 按照预定的格式返回序列值
  TEMP_ID    := '000000000000000000000000000000' || TO_CHAR(LN_SEQ_NUM);
  LS_SEQ_NUM := TRIM(LR_SEQLIST.SEQPREFIX ||
                     SUBSTR(TEMP_ID,
                            LENGTH(TEMP_ID) - LR_SEQLIST.SEQWIDTH + PRELEN + 1,
                            LR_SEQLIST.SEQWIDTH - PRELEN));

  RETURN(LS_SEQ_NUM);

EXCEPTION
  
  WHEN OTHERS THEN 
      RETURN ' seq        error!';
   
END;
/

prompt
prompt Creating function F_GET_SBID
prompt ============================
prompt
CREATE OR REPLACE FUNCTION F_GET_SBID return varchar2 is
 -- --------------------------------------------------------------------------
  -- Name         : F_GET_SBID
  -- Author       : Tim
  -- Description  : 取水表编号
  -- Ammedments   : 水表编号前面9位是从序号取，后面一位是前面9位数据相加，取4的膜
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation
  -- --------------------------------------------------------------------------

  v_num       number(10);
  v_newsbid   varchar2(10);
  v_modnum    number(10);
  v_sbid    varchar2(10);
begin

  v_sbid := f_get_seq_next('SEQ_SBID');
  v_num := 0 ;
  for i in 1 .. length(v_sbid) loop
    v_num := nvl(v_num,0) + to_number(substr(v_sbid, (i), 1));
  end loop;
  v_modnum    := mod(v_num, 4);
  v_newsbid := v_sbid || v_modnum;
  return(v_newsbid);
exception
  when others then
    return '';
end;
/

prompt
prompt Creating function F_LJF_MONTH
prompt =============================
prompt
CREATE OR REPLACE FUNCTION F_ljf_month(p_pmicode in varchar2,
                                       p_month   in varchar2) RETURN number AS
  LCODE number(13, 3) := 0 ;
BEGIN

  /*select DECODE(RL_CD, 'DE', 1, -1) * rl_je
    into LCODE
    from zkzlsds.record_list
   where rl_mcode = p_pmicode
     and rl_month = p_month;*/

  RETURN LCODE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
/

prompt
prompt Creating function MD5
prompt =====================
prompt
CREATE OR REPLACE FUNCTION MD5(

passwd IN VARCHAR2)

RETURN VARCHAR2

IS

retval varchar2(32);

BEGIN

retval := utl_raw.cast_to_raw(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => passwd)) ;

RETURN retval;

END;
/

prompt
prompt Creating function UUID
prompt ======================
prompt
CREATE OR REPLACE FUNCTION uuid  RETURN char AS
  v_method varchar2(32);
BEGIN
 
   v_method := sys_guid();
   return v_method ; 
EXCEPTION
  WHEN OTHERS THEN
    RETURN sys_guid();
END;
/

prompt
prompt Creating function 实时计算年累计已用量
prompt ============================
prompt
CREATE OR REPLACE FUNCTION 实时计算年累计已用量(P_MIID IN VARCHAR2, P_SDATE IN DATE)
  RETURN VARCHAR2 AS
  LRET NUMBER;
BEGIN
  SELECT NVL(SUM(ARDSL), 0)
    INTO LRET
    FROM YS_ZW_ARLIST, YS_ZW_ARDETAIL
   WHERE ARID = ARDID
     AND ARDPIID = '01' --只计水费水量
     AND ARDMETHOD IN( 'yjt','njt') --年阶梯月结 暂时只通过RLIFYEARCLASS标志判断
     AND ARSCRARMONTH >= TO_CHAR(P_SDATE, 'YYYY.MM') --大于阶梯起算日
     AND SBID = P_MIID;
  RETURN LRET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function 是否年阶梯水价
prompt =========================
prompt
CREATE OR REPLACE FUNCTION 是否年阶梯水价(P_PFNO IN VARCHAR2) RETURN VARCHAR2 AS
  VCOUNT NUMBER := 0;
BEGIN
  --先检查是否年阶梯账务
  SELECT COUNT(*)
    INTO VCOUNT
    FROM BAS_PRICE_DETAIL
   WHERE METHOD IN ('njt')
     AND PRICE_NO = P_PFNO;
  IF VCOUNT > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

prompt
prompt Creating function 是否含年阶梯水价
prompt ==========================
prompt
CREATE OR REPLACE FUNCTION 是否含年阶梯水价(P_SBID IN VARCHAR2) RETURN VARCHAR2 AS
  VCOUNT NUMBER := 0;
BEGIN
  SELECT COUNT(*)
    INTO VCOUNT
    FROM (SELECT 1
            FROM YS_YH_SBINFO MI
           WHERE MI.SBID = P_SBID
             AND MI.SBIFMP = 'N'
             AND 是否年阶梯水价(MI.PRICE_NO) = 'Y'
          UNION
          SELECT 1
            FROM YS_YH_SBINFO MI, YS_YH_PRICEGROUP PMD
           WHERE MI.SBID = P_SBID
             AND MI.SBID = PMD.SBID
             AND MI.SBIFMP = 'Y'
             AND 是否年阶梯水价(PMD.PRICE_NO) = 'Y');
  IF VCOUNT > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

prompt
prompt Creating package body PG_ADDMODIFY_YH
prompt =====================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_ADDModify_YH is
  --CurrentDate date := tools.fGetSysDate;

  --msl meter_static_log%rowtype;

  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2) IS
  BEGIN
    IF P_DJLB IN ('LH') THEN
      SP_yhadd(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSE
      SP_yhModify(P_DJLB, P_BILLNO, P_PERSON, 'N');
    END IF;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END AUDIT;

  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2, --单据类型
                     P_billno IN VARCHAR2, --单据流水号
                     P_PERSON IN VARCHAR2, --审核人
                     P_COMMIT IN VARCHAR2) AS
    --是否提交
    v_CRHSHFLAG varchar2(10);
    v_yh        ys_yh_custinfo%ROWTYPE;
    v_sb        ys_yh_sbinfo%ROWTYPE;
    V_YHPID     ys_yh_custinfo%ROWTYPE;
    V_SBPID     Ys_Yh_Sbinfo%ROWTYPE;
    v_sd        ys_yh_sbdoc%ROWTYPE;
    v_sa        ys_yh_account%rowtype;
    CURSOR C_YHPID(VYHID IN VARCHAR2) IS
      SELECT *
        FROM ys_yh_custinfo
       WHERE YHID = VYHID
         AND HIRE_CODE = v_HIRE_CODE;
    CURSOR C_SBPID(VSBID IN VARCHAR2) IS
      SELECT *
        FROM Ys_Yh_Sbinfo
       WHERE YHID = VSBID
         AND HIRE_CODE = v_HIRE_CODE;
  begin
    --select  * from  ys_gd_yhsbreghd
    select nvl(max(CHECK_FLAG), '999')
      into v_CRHSHFLAG
      from ys_gd_yhsbreghd
     where bill_id = P_billno
       and HIRE_CODE = v_HIRE_CODE;
    IF v_CRHSHFLAG = '999' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END IF;
    IF v_CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF v_CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    for i in (select *
                from ys_gd_yhsbregdt
               where bill_id = P_billno
                 and HIRE_CODE = v_HIRE_CODE) loop
      v_yh.id        := uuid();
      v_yh.hire_code := v_HIRE_CODE;
      --v_yh.yhid,
      v_yh.yhconid   := i.yhconid;
      v_yh.manage_no := i.manage_no;
      v_yh.yhpid     := i.yhpid;
      --校验上级用户
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_YHPID(i.yhpid);
        FETCH C_YHPID
          INTO V_YHPID;
        IF C_YHPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_yh.yhclass := V_YHPID.yhclass + 1; --
        CLOSE C_YHPID;
      ELSE
        v_yh.yhclass := 1; --
      END IF;
    
      v_yh.yhflag        := 'Y';
      v_yh.yhname        := I.YHNAME;
      v_yh.yhname2       := I.YHNAME2;
      v_yh.yhadr         := I.YHADR;
      v_yh.yhstatus      := I.YHSTATUS;
      v_yh.yhstatusdate  := null;
      v_yh.yhstatustrans := null;
      v_yh.yhnewdate     := i.yhnewdate;
      v_yh.yhidentitylb  := i.yhidentitylb;
      v_yh.yhidentityno  := i.yhidentityno;
      v_yh.yhmtel        := i.yhmtel;
      v_yh.yhtel1        := i.yhtel1;
      v_yh.yhtel2        := i.yhtel2;
      v_yh.yhtel3        := i.yhtel3;
      v_yh.yhconnectper  := i.yhconnectper;
      v_yh.yhconnecttel  := i.yhconnecttel;
      v_yh.yhifinv       := i.yhifinv;
      v_yh.yhifsms       := i.yhifsms;
      v_yh.yhifzn        := i.yhifzn;
      v_yh.yhprojno      := i.yhprojno;
      v_yh.yhfileno      := i.yhfileno;
      v_yh.yhmemo        := i.yhmemo;
      v_yh.yhdeptid      := i.yhdeptid;
      v_yh.yhwxno        := null;
      v_sb.id            := uuid();
    
      v_sb.sbid      := nvl(i.sbid, f_get_sbid);
      v_sb.id        := i.id;
      v_sb.hire_code := i.hire_code;
      v_yh.yhid      := nvl(i.yhid, v_sb.sbid);
      v_sb.yhid      := v_yh.yhid;
      -- v_sb.sbid          := i.sbid;
      v_sb.sbadr     := i.sbadr;
      v_sb.area_no   := i.area_no;
      v_sb.manage_no := i.manage_no;
      v_sb.sbprmon   := i.sbprmon;
      v_sb.sbrmon    := i.sbrmon;
      v_sb.book_no   := i.book_no;
      v_sb.sbrorder  := i.sbrorder;
      v_sb.sbpid     := i.sbpid;
      --v_sb.sbclass       := i.sbclass;
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_SBPID(i.sbpid);
        FETCH C_SBPID
          INTO V_SBPID;
        IF C_SBPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_sb.sbclass := V_SBPID.SBclass + 1; --
        CLOSE C_SBPID;
      ELSE
        V_SBPID.sbclass := 1; --
      END IF;
      v_sb.sbflag        := i.sbflag;
      v_sb.sbrtid        := i.sbrtid;
      v_sb.sbifmp        := i.sbifmp;
      v_sb.sbifsp        := i.sbifsp;
      v_sb.trade_no      := i.trade_no;
      v_sb.price_no      := i.price_no;
      v_sb.sbstatus      := i.sbstatus;
      v_sb.sbstatusdate  := i.sbstatusdate;
      v_sb.sbstatustrans := i.sbstatustrans;
      v_sb.sbface        := i.sbface;
      v_sb.sbrpid        := i.sbrpid;
      v_sb.sbside        := i.sbside;
      v_sb.sbposition    := i.sbposition;
      v_sb.sbinscode     := i.sbinscode;
      v_sb.sbinsdate     := i.sbinsdate;
      v_sb.sbinsper      := i.sbinsper;
      v_sb.sbreinscode   := i.sbreinscode;
      v_sb.sbreinsdate   := i.sbreinsdate;
      v_sb.sbreinsper    := i.sbreinsper;
      v_sb.sbtype        := i.sbtype;
      v_sb.sbrcode       := i.sbrcode;
      v_sb.sbrecdate     := i.sbrecdate;
      v_sb.sbrecsl       := i.sbrecsl;
      v_sb.sbifcharge    := 'Y';
      v_sb.sbifsl        := i.sbifsl;
      v_sb.sbifchk       := i.sbifchk;
      v_sb.sbifwatch     := i.sbifwatch;
      v_sb.sbicno        := i.sbicno;
      v_sb.sbmemo        := i.sbmemo;
      v_sb.sbpriid       := i.sbpriid;
      v_sb.sbpriflag     := i.sbpriflag;
      v_sb.sbusenum      := i.sbusenum;
      v_sb.sbchargetype  := i.sbchargetype;
      v_sb.sbsaving      := i.sbsaving;
      v_sb.sblb          := i.sblb;
      v_sb.sbnewflag     := i.sbnewflag;
      v_sb.sbcper        := i.sbcper;
      v_sb.sbiftax       := i.sbiftax;
      v_sb.sbtaxno       := i.sbtaxno;
    
      v_sb.sbrcodechar := i.sbrcodechar;
      v_sb.sbifckf     := i.sbifckf;
      v_sb.sbgps       := i.sbgps;
      v_sb.sbqfh       := i.sbqfh;
      v_sb.sbbox       := i.sbbox;
    
      v_sb.sbname  := i.sbname;
      v_sb.sbname2 := i.sbname2;
      -- v_sb.sbseqno       := i.sbseqno;
      v_sb.sbnewdate     := i.YHNEWDATE;
      v_sb.sbuiid        := i.sbuiid;
      v_sb.sbcommunity   := i.sbcommunity;
      v_sb.sbremoteno    := i.sbremoteno;
      v_sb.sbremotehubno := i.sbremotehubno;
      v_sb.sbemail       := i.sbemail;
      v_sb.sbemailflag   := i.sbemailflag;
      v_sb.sbdbjmsl1     := i.sbdbjmsl1;
      v_sb.sbdbyhbz2     := i.sbdbyhbz2;
      v_sb.sbdbjzyf3     := i.sbdbjzyf3;
      v_sb.sbyhxz4       := i.sbyhxz4;
      --v_sb.sbpaymentid   := i.sbpaymentid;
      v_sb.sbgdsl5    := i.sbgdsl5;
      v_sb.sbftsl6    := i.sbftsl6;
      v_sb.sbxjdj7    := i.sbxjdj7;
      v_sb.sbcolumn8  := i.sbcolumn8;
      v_sb.sbyhlb9    := i.sbyhlb9;
      v_sb.sbsfqdht10 := i.sbsfqdht10;
      v_sb.sblh       := i.LH;
      v_sb.sbdyh      := i.dyh;
      v_sb.sbmph      := i.mph;
      v_sb.sbjd       := i.sbjd;
      --v_sb.sbyhpj        := i.sbyhpj;
      v_sb.sbtax := i.YHIFINV;
      --v_sb.sbifzdh       := i.sbifzdh;
      --v_sb.sbdbzjh       := i.sbdbzjh;
      --v_sb.sbdzbz1       := i.sbdzbz1;
      -- v_sb.sbmsbz2       := i.sbmsbz2;
      --v_sb.sbxkzbz3      := i.sbxkzbz3;
      --v_sb.sbsbmm4       := i.sbsbmm4;
      --v_sb.sbmmsz5       := i.sbmmsz5;
      --v_sb.sbxymm6       := i.sbxymm6;
      --v_sb.sbmszdsl7     := i.sbmszdsl7;
      --v_sb.sbyctf8       := i.sbyctf8;
      -- v_sb.sbzdzzs9      := i.sbzdzzs9;
      --v_sb.sbcbshsj10    := i.sbcbshsj10;
      --v_sb.sbjtkssj11    := i.sbjtkssj11;
      --v_sb.sbyl12        := i.sbyl12;
      --v_sb.sbjdh13       := i.sbjdh13;
      v_sb.sbtkbz11 := i.sbtkbz11;
      --v_sb.sbtkzjh       := i.sbtkzjh;
      --v_sb.sbhtbh        := i.sbhtbh;
      --v_sb.sbhtzq        := i.sbhtzq;
      --v_sb.sbrqxz        := i.sbrqxz;
      -- v_sb.htdate        := i.htdate;
      --v_sb.zfdate        := i.zfdate;
      --v_sb.jzdate        := i.jzdate;
      --v_sb.signper       := i.signper;
      --v_sb.signid        := i.signid;
      -- v_sb.pocid         := i.pocid;
      v_sd.MDNO         := i.MDNO; --
      v_sd.sbid         := v_sb.sbid;
      v_sd.id           := uuid();
      v_sd.hire_code    := v_HIRE_CODE;
      v_sd.MDCALIBER    := i.MDCALIBER; --
      v_sd.MDBRAND      := i.MDBRAND; --
      v_sd.MDMODEL      := i.MDMODEL; --
      v_sd.MDSTATUS     := i.MDSTATUS; --
      v_sd.MDSTATUSDATE := NULL; --
      v_sd.MDSTOCKDATE  := sysdate;
    
      --v_sd.BARCODE      := i.BARCODE;
      v_sd.RFID   := i.RFID;
      v_sd.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。 
      v_sd.BARCODE := SUBSTR(v_sb.manage_no, 4, 1) ||
                      TO_CHAR(SYSDATE, 'YYYYMMDD') || v_sb.sbid;
      v_sd.DQSFH   := i.DQSFH; --塑封号
      v_sd.DQGFH   := i.DQGFH; --钢封号
      v_sd.JCGFH   := i.JCGFH; --稽查封号
      v_sd.QFH     := i.QHF; --铅封号
    
      v_sa.id             := uuid();
      v_sa.hire_code      := v_HIRE_CODE;
      v_sa.sbid           := v_sb.sbid;
      v_sa.yhano          := i.yhano;
      v_sa.yhanoname      := i.yhanoname;
      v_sa.yhabankid      := i.YHABANKID;
      v_sa.yhaaccountno   := i.yhaaccountno;
      v_sa.yhaaccountname := i.yhaaccountname;
      v_sa.yhatsbankid    := i.yhatsbankid;
      v_sa.yhatsbankname  := i.yhatsbankname;
      v_sa.yhaifxezf      := i.yhaifxezf;
      v_sa.yharegdate     := trunc(sysdate);
      INSERT INTO ys_yh_custinfo VALUES v_yh;
      INSERT INTO ys_yh_sbinfo VALUES v_sb;
      INSERT INTO ys_yh_sbdoc VALUES v_sd;
      INSERT INTO ys_yh_account VALUES v_sa;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_yhadd;
  --立户审核（一户一表）
  PROCEDURE SP_yhModify(P_DJLB   IN VARCHAR2, --单据类型
                        P_billno IN VARCHAR2, --单据流水号
                        P_PERSON IN VARCHAR2, --审核人
                        P_COMMIT IN VARCHAR2) AS
    --是否提交
    v_CRHSHFLAG varchar2(10);
    v_yh        ys_yh_custinfo%ROWTYPE;
    v_sb        ys_yh_sbinfo%ROWTYPE;
    V_YHPID     ys_yh_custinfo%ROWTYPE;
    V_SBPID     Ys_Yh_Sbinfo%ROWTYPE;
    v_sd        ys_yh_sbdoc%ROWTYPE;
    v_sa        ys_yh_account%rowtype;
    CURSOR C_YHPID(VYHID IN VARCHAR2) IS
      SELECT *
        FROM ys_yh_custinfo
       WHERE YHID = VYHID
         AND HIRE_CODE = v_HIRE_CODE;
    CURSOR C_SBPID(VSBID IN VARCHAR2) IS
      SELECT *
        FROM Ys_Yh_Sbinfo
       WHERE YHID = VSBID
         AND HIRE_CODE = v_HIRE_CODE;
  begin
    --select  * from  ys_gd_yhsbreghd
    select nvl(max(CHECK_FLAG), '999')
      into v_CRHSHFLAG
      from ys_gd_yhsbmodifyd
     where bill_id = P_billno
       and HIRE_CODE = v_HIRE_CODE;
    IF v_CRHSHFLAG = '999' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END IF;
    IF v_CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF v_CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    for i in (select *
                from ys_gd_yhsbmodifyt
               where bill_id = P_billno
                 and HIRE_CODE = v_HIRE_CODE) loop
      --更名           
      if P_DJLB = 'GM' then
        update ys_yh_custinfo
           set yhname       = i.yhname,
               yhadr        = i.yhadr,
               yhidentitylb = i.yhidentitylb,
               yhidentityno = i.yhidentityno,
               yhmtel       = i.yhmtel,
               yhtel1       = i.yhtel1,
               yhtel2       = i.yhtel2,
               yhtel3       = i.yhtel3,
               yhconnectper = i.yhconnectper,
               yhconnecttel = i.yhconnecttel,
               yhifsms      = i.yhifsms
         where yhid = i.yhid;
        update ys_yh_sbinfo
           set sbadr = i.sbadr, sbname = i.sbname, sbname2 = i.sbname2
         where sbid = i.sbid;
      end if;
    
      --更名           
      if P_DJLB = 'YHXXBG' then
      
        update ys_yh_custinfo
           set yhconid       = I.yhconid,
               manage_no     = I.manage_no,
               yhpid         = I.yhpid,
               yhclass       = I.yhclass,
               yhflag        = I.yhflag,
               yhname        = I.yhname,
               yhname2       = I.yhname2,
               yhadr         = I.yhadr,
               yhstatus      = I.yhstatus,
               yhstatusdate  = I.yhstatusdate,
               yhstatustrans = I.yhstatustrans,
               yhnewdate     = I.yhnewdate,
               yhidentitylb  = I.yhidentitylb,
               yhidentityno  = I.yhidentityno,
               yhmtel        = I.yhmtel,
               yhtel1        = I.yhtel1,
               yhtel2        = I.yhtel2,
               yhtel3        = I.yhtel3,
               yhconnectper  = I.yhconnectper,
               yhconnecttel  = I.yhconnecttel,
               yhifinv       = I.yhifinv,
               yhifsms       = I.yhifsms,
               yhifzn        = I.yhifzn,
               yhprojno      = I.yhprojno,
               yhfileno      = I.yhfileno,
               yhmemo        = I.yhmemo,
               yhdeptid      = I.yhdeptid
         where yhid = I.yhid;
        update ys_yh_sbinfo
           set yhid          = I.yhid,
               sbadr         = I.sbadr,
               area_no       = I.area_no,
               manage_no     = I.manage_no,
               sbprmon       = I.sbprmon,
               sbrmon        = I.sbrmon,
               book_no       = I.book_no,
               sbrorder      = I.sbrorder,
               sbpid         = I.sbpid,
               sbclass       = I.sbclass,
               sbflag        = I.sbflag,
               sbrtid        = I.sbrtid,
               sbifmp        = I.sbifmp,
               sbifsp        = I.sbifsp,
               trade_no      = I.trade_no,
               price_no      = I.price_no,
               sbstatus      = I.sbstatus,
               sbstatusdate  = I.sbstatusdate,
               sbstatustrans = I.sbstatustrans,
               sbface        = I.sbface,
               sbrpid        = I.sbrpid,
               sbside        = I.sbside,
               sbposition    = I.sbposition,
               sbinscode     = I.sbinscode,
               sbinsdate     = I.sbinsdate,
               sbinsper      = I.sbinsper,
               sbreinscode   = I.sbreinscode,
               sbreinsdate   = I.sbreinsdate,
               sbreinsper    = I.sbreinsper,
               sbtype        = I.sbtype,
               sbrcode       = I.sbrcode,
               sbrecdate     = I.sbrecdate,
               sbrecsl       = I.sbrecsl,
               sbifcharge    = I.sbifcharge,
               sbifsl        = I.sbifsl,
               sbifchk       = I.sbifchk,
               sbifwatch     = I.sbifwatch,
               sbicno        = I.sbicno,
               sbmemo        = I.sbmemo,
               sbpriid       = I.sbpriid,
               sbpriflag     = I.sbpriflag,
               sbusenum      = I.sbusenum,
               sbchargetype  = I.sbchargetype,
               sbsaving      = I.sbsaving,
               sblb          = I.sblb,
               sbnewflag     = I.sbnewflag,
               sbcper        = I.sbcper,
               sbiftax       = I.sbiftax,
               sbtaxno       = I.sbtaxno,
               sbuninscode   = I.sbuninscode,
               sbuninsdate   = I.sbuninsdate,
               sbuninsper    = I.sbuninsper,
               sbface2       = I.sbface2,
               sbface3       = I.sbface3,
               sbface4       = I.sbface4,
               sbrcodechar   = I.sbrcodechar,
               sbifckf       = I.sbifckf,
               sbgps         = I.sbgps,
               sbqfh         = I.sbqfh,
               sbbox         = I.sbbox,
               sbjfkrow      = I.sbjfkrow,
               sbname        = I.sbname,
               sbname2       = I.sbname2,
               sbseqno       = I.sbseqno,
               sbnewdate     = I.sbnewdate,
               sbuiid        = I.sbuiid,
               sbcommunity   = I.sbcommunity,
               sbremoteno    = I.sbremoteno,
               sbremotehubno = I.sbremotehubno,
               sbemail       = I.sbemail,
               sbemailflag   = I.sbemailflag,
               sbdbjmsl1     = I.sbdbjmsl1,
               sbdbyhbz2     = I.sbdbyhbz2,
               sbdbjzyf3     = I.sbdbjzyf3,
               sbyhxz4       = I.sbyhxz4,
               sbpaymentid   = I.sbpaymentid,
               sbgdsl5       = I.sbgdsl5,
               sbftsl6       = I.sbftsl6,
               sbxjdj7       = I.sbxjdj7,
               sbcolumn8     = I.sbcolumn8,
               sbyhlb9       = I.sbyhlb9,
               sbsfqdht10    = I.sbsfqdht10,
               sblh          = I.sblh,
               sbdyh         = I.sbdyh,
               sbmph         = I.sbmph,
               sbjd          = I.sbjd,
               sbyhpj        = I.sbyhpj,
               sbtax         = I.sbtax,
               sbifzdh       = I.sbifzdh,
               sbdbzjh       = I.sbdbzjh,
               sbdzbz1       = I.sbdzbz1,
               sbmsbz2       = I.sbmsbz2,
               sbxkzbz3      = I.sbxkzbz3,
               sbsbmm4       = I.sbsbmm4,
               sbmmsz5       = I.sbmmsz5,
               sbxymm6       = I.sbxymm6,
               sbmszdsl7     = I.sbmszdsl7,
               sbyctf8       = I.sbyctf8,
               sbzdzzs9      = I.sbzdzzs9,
               sbcbshsj10    = I.sbcbshsj10,
               sbjtkssj11    = I.sbjtkssj11,
               sbyl12        = I.sbyl12,
               sbjdh13       = I.sbjdh13,
               sbtkbz11      = I.sbtkbz11,
               sbtkzjh       = I.sbtkzjh,
               sbhtbh        = I.sbhtbh,
               sbhtzq        = I.sbhtzq,
               sbrqxz        = I.sbrqxz,
               htdate        = I.htdate,
               zfdate        = I.zfdate,
               jzdate        = I.jzdate,
               signper       = I.signper,
               signid        = I.signid,
               pocid         = I.pocid,
               sbcode        = I.sbcode
         where sbid = I.sbid;
      
        update ys_yh_account
           set yhano          = I.yhano,
               yhanoname      = I.yhanoname,
               yhabankid      = I.yhabankid,
               yhaaccountno   = I.yhaaccountno,
               yhaaccountname = I.yhaaccountname,
               yhatsbankid    = I.yhatsbankid,
               yhatsbankname  = I.yhatsbankname,
               yhaifxezf      = I.yhaifxezf,
               yharegdate     = I.yharegdate
         where sbid = I.sbid;
      
        update ys_yh_sbdoc
           set mdno           = I.mdno,
               mdcaliber      = I.mdcaliber,
               mdbrand        = I.mdbrand,
               mdmodel        = I.mdmodel,
               mdstatus       = I.mdstatus,
               mdstatusdate   = I.mdstatusdate,
               mdcycchkdate   = I.mdcycchkdate,
               mdstockdate    = I.mdstockdate,
               mdstore        = I.mdstore,
               sfh            = I.sfh,
               dqsfh          = I.dqsfh,
               dqgfh          = I.dqgfh,
               jcgfh          = I.jcgfh,
               qfh            = I.qfh,
               mdfq1          = I.mdfq1,
               mdfq2          = I.mdfq2,
               mdfq3          = I.mdfq3,
               mdfq4          = I.mdfq4,
               mdfq5          = I.mdfq5,
               barcode        = I.barcode,
               rfid           = I.rfid,
               ifdzsb         = I.ifdzsb,
               concentratorid = I.concentratorid,
               readmetercode  = I.readmetercode,
               transferstype  = I.transferstype,
               collenttype    = I.collenttype,
               iscontrol      = I.iscontrol,
               readtype       = I.readtype,
               rkbatch        = I.rkbatch,
               rkdno          = I.rkdno,
               storeroomid    = I.storeroomid,
               rkman          = I.rkman,
               mainman        = I.mainman,
               maindate       = I.maindate,
               sjdate         = I.sjdate,
               mdmode         = I.mdmode,
               portno         = I.portno
         where id = I.id;
      end if;
      --过户          
      if P_DJLB = 'GH' then
        update ys_yh_custinfo
           set yhname       = i.yhname,
               yhadr        = i.yhadr,
               yhidentitylb = i.yhidentitylb,
               yhidentityno = i.yhidentityno,
               yhmtel       = i.yhmtel,
               yhtel1       = i.yhtel1,
               yhtel2       = i.yhtel2,
               yhtel3       = i.yhtel3,
               yhconnectper = i.yhconnectper,
               yhconnecttel = i.yhconnecttel,
               yhifsms      = i.yhifsms,
               yhmemo       = i.yhmemo
         where yhid = i.yhid;
        update ys_yh_sbinfo
           set sbadr = i.sbadr, sbname = i.sbname, sbname2 = i.sbname2
         where sbid = i.sbid
           AND HIRE_CODE = I.HIRE_CODE;
      end if;
    
      --水价变更    
      if P_DJLB = 'SJBG' then
      
        update ys_yh_sbinfo O
        
           set O.PRICE_NO = i.price_no
         where O.sbid = i.sbid
           AND O.HIRE_CODE = I.HIRE_CODE;
        --删除混合  
        DELETE ys_yh_pricegroup P
         WHERE P.SBID = I.SBID
           AND P.HIRE_CODE = I.HIRE_CODE;
      
        IF I.SBIFMP = 'Y' THEN
          if i.price_no1 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               1,
               i.price_no1,
               i.PMDSCALE1,
               i.PMDTYPE,
               null,
               null,
               null);
          
          end if;
          if i.price_no2 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               2,
               i.price_no2,
               i.PMDSCALE2,
               i.PMDTYPE2,
               null,
               null,
               null);
          end if;
          if i.price_no3 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               3,
               i.price_no3,
               i.PMDSCALE3,
               i.PMDTYPE3,
               null,
               null,
               null);
          end if;
          if i.price_no4 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               4,
               i.price_no4,
               i.PMDSCALE4,
               i.PMDTYPE4,
               null,
               null,
               null);
          end if;
          update ys_yh_sbinfo O
          
             set SBIFMP = 'Y'
           where O.sbid = i.sbid
             AND O.HIRE_CODE = I.HIRE_CODE;
        ELSE
          DELETE ys_yh_pricegroup P
           WHERE P.SBID = I.SBID
             AND P.HIRE_CODE = I.HIRE_CODE;
        END IF;
      end if;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_yhModify;
end;
/

prompt
prompt Creating package body PG_ADD_YH
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_ADD_YH is
  --CurrentDate date := tools.fGetSysDate;

  --msl meter_static_log%rowtype;

  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2) IS
  BEGIN
    /* IF P_DJLB IN ('R', '0') THEN
      SP_REGISTER(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSE
      SP_CUSTCHANGE(P_DJLB, P_BILLNO, P_PERSON, 'N');
    END IF;*/
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END AUDIT;

  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2, --单据类型
                     P_billno IN VARCHAR2, --单据流水号
                     P_PERSON IN VARCHAR2, --审核人
                     P_COMMIT IN VARCHAR2) AS
    --是否提交
    v_CRHSHFLAG varchar2(10);
    v_yh        ys_yh_custinfo%ROWTYPE;
    v_sb        ys_yh_sbinfo%ROWTYPE;
    V_YHPID     ys_yh_custinfo%ROWTYPE;
    V_SBPID     Ys_Yh_Sbinfo%ROWTYPE;
    v_sd        ys_yh_sbdoc%ROWTYPE;
    v_sa        ys_yh_account%rowtype;
    CURSOR C_YHPID(VYHID IN VARCHAR2) IS
      SELECT *
        FROM ys_yh_custinfo
       WHERE YHID = VYHID
         AND HIRE_CODE = v_HIRE_CODE;
    CURSOR C_SBPID(VSBID IN VARCHAR2) IS
      SELECT *
        FROM Ys_Yh_Sbinfo
       WHERE YHID = VSBID
         AND HIRE_CODE = v_HIRE_CODE;
  begin
    --select  * from  ys_gd_yhsbreghd
    select nvl(max(CHECK_FLAG), '999')
      into v_CRHSHFLAG
      from ys_gd_yhsbreghd
     where bill_id = P_billno
       and HIRE_CODE = v_HIRE_CODE;
    IF v_CRHSHFLAG = '999' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END IF;
    IF v_CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF v_CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    for i in (select *
                from ys_gd_yhsbregdt
               where bill_id = P_billno
                 and HIRE_CODE = v_HIRE_CODE) loop
      v_yh.id        := uuid();
      v_yh.hire_code := v_HIRE_CODE;
      --v_yh.yhid,
      v_yh.yhconid   := i.yhconid;
      v_yh.manage_no := i.manage_no;
      v_yh.yhpid     := i.yhpid;
      --校验上级用户
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_YHPID(i.yhpid);
        FETCH C_YHPID
          INTO V_YHPID;
        IF C_YHPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_yh.yhclass := V_YHPID.yhclass + 1; --
        CLOSE C_YHPID;
      ELSE
        v_yh.yhclass := 1; --
      END IF;
    
      v_yh.yhflag        := 'Y';
      v_yh.yhname        := I.YHNAME;
      v_yh.yhname2       := I.YHNAME2;
      v_yh.yhadr         := I.YHADR;
      v_yh.yhstatus      := I.YHSTATUS;
      v_yh.yhstatusdate  := null;
      v_yh.yhstatustrans := null;
      v_yh.yhnewdate     := i.yhnewdate;
      v_yh.yhidentitylb  := i.yhidentitylb;
      v_yh.yhidentityno  := i.yhidentityno;
      v_yh.yhmtel        := i.yhmtel;
      v_yh.yhtel1        := i.yhtel1;
      v_yh.yhtel2        := i.yhtel2;
      v_yh.yhtel3        := i.yhtel3;
      v_yh.yhconnectper  := i.yhconnectper;
      v_yh.yhconnecttel  := i.yhconnecttel;
      v_yh.yhifinv       := i.yhifinv;
      v_yh.yhifsms       := i.yhifsms;
      v_yh.yhifzn        := i.yhifzn;
      v_yh.yhprojno      := i.yhprojno;
      v_yh.yhfileno      := i.yhfileno;
      v_yh.yhmemo        := i.yhmemo;
      v_yh.yhdeptid      := i.yhdeptid;
      v_yh.yhwxno        := null;
       v_sb.id        := uuid();
      
      v_sb.sbid          := nvl(i.sbid, f_get_sbid);
      v_sb.id            := i.id;
      v_sb.hire_code     := i.hire_code;
      v_sb.yhid          := i.yhid;
     -- v_sb.sbid          := i.sbid;
      v_sb.sbadr         := i.sbadr;
      v_sb.area_no       := i.area_no;
      v_sb.manage_no     := i.manage_no;
      v_sb.sbprmon       := i.sbprmon;
      v_sb.sbrmon        := i.sbrmon;
      v_sb.book_no       := i.book_no;
      v_sb.sbrorder      := i.sbrorder;
      v_sb.sbpid         := i.sbpid;
      --v_sb.sbclass       := i.sbclass;
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_SBPID(i.sbpid);
        FETCH C_SBPID
          INTO V_SBPID;
        IF C_SBPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_sb.sbclass  := V_SBPID.SBclass + 1; --
        CLOSE C_SBPID;
      ELSE
        V_SBPID.sbclass := 1; --
      END IF;
      v_sb.sbflag        := i.sbflag;
      v_sb.sbrtid        := i.sbrtid;
      v_sb.sbifmp        := i.sbifmp;
      v_sb.sbifsp        := i.sbifsp;
      v_sb.trade_no      := i.trade_no;
      v_sb.price_no      := i.price_no;
      v_sb.sbstatus      := i.sbstatus;
      v_sb.sbstatusdate  := i.sbstatusdate;
      v_sb.sbstatustrans := i.sbstatustrans;
      v_sb.sbface        := i.sbface;
      v_sb.sbrpid        := i.sbrpid;
      v_sb.sbside        := i.sbside;
      v_sb.sbposition    := i.sbposition;
      v_sb.sbinscode     := i.sbinscode;
      v_sb.sbinsdate     := i.sbinsdate;
      v_sb.sbinsper      := i.sbinsper;
      v_sb.sbreinscode   := i.sbreinscode;
      v_sb.sbreinsdate   := i.sbreinsdate;
      v_sb.sbreinsper    := i.sbreinsper;
      v_sb.sbtype        := i.sbtype;
      v_sb.sbrcode       := i.sbrcode;
      v_sb.sbrecdate     := i.sbrecdate;
      v_sb.sbrecsl       := i.sbrecsl;
      v_sb.sbifcharge    := i.sbifcharge;
      v_sb.sbifsl        := i.sbifsl;
      v_sb.sbifchk       := i.sbifchk;
      v_sb.sbifwatch     := i.sbifwatch;
      v_sb.sbicno        := i.sbicno;
      v_sb.sbmemo        := i.sbmemo;
      v_sb.sbpriid       := i.sbpriid;
      v_sb.sbpriflag     := i.sbpriflag;
      v_sb.sbusenum      := i.sbusenum;
      v_sb.sbchargetype  := i.sbchargetype;
      v_sb.sbsaving      := i.sbsaving;
      v_sb.sblb          := i.sblb;
      v_sb.sbnewflag     := i.sbnewflag;
      v_sb.sbcper        := i.sbcper;
      v_sb.sbiftax       := i.sbiftax;
      v_sb.sbtaxno       := i.sbtaxno;
     
      v_sb.sbrcodechar   := i.sbrcodechar;
      v_sb.sbifckf       := i.sbifckf;
      v_sb.sbgps         := i.sbgps;
      v_sb.sbqfh         := i.sbqfh;
      v_sb.sbbox         := i.sbbox;
     
      v_sb.sbname        := i.sbname;
      v_sb.sbname2       := i.sbname2;
     -- v_sb.sbseqno       := i.sbseqno;
      v_sb.sbnewdate     := i.YHNEWDATE;
      v_sb.sbuiid        := i.sbuiid;
      v_sb.sbcommunity   := i.sbcommunity;
      v_sb.sbremoteno    := i.sbremoteno;
      v_sb.sbremotehubno := i.sbremotehubno;
      v_sb.sbemail       := i.sbemail;
      v_sb.sbemailflag   := i.sbemailflag;
      v_sb.sbdbjmsl1     := i.sbdbjmsl1;
      v_sb.sbdbyhbz2     := i.sbdbyhbz2;
      v_sb.sbdbjzyf3     := i.sbdbjzyf3;
      v_sb.sbyhxz4       := i.sbyhxz4;
      --v_sb.sbpaymentid   := i.sbpaymentid;
      v_sb.sbgdsl5       := i.sbgdsl5;
      v_sb.sbftsl6       := i.sbftsl6;
      v_sb.sbxjdj7       := i.sbxjdj7;
      v_sb.sbcolumn8     := i.sbcolumn8;
      v_sb.sbyhlb9       := i.sbyhlb9;
      v_sb.sbsfqdht10    := i.sbsfqdht10;
      v_sb.sblh          := i.LH;
      v_sb.sbdyh         := i.dyh;
      v_sb.sbmph         := i.mph;
      v_sb.sbjd          := i.sbjd;
      --v_sb.sbyhpj        := i.sbyhpj;
      v_sb.sbtax         := i.YHIFINV;
      --v_sb.sbifzdh       := i.sbifzdh;
      --v_sb.sbdbzjh       := i.sbdbzjh;
      --v_sb.sbdzbz1       := i.sbdzbz1;
     -- v_sb.sbmsbz2       := i.sbmsbz2;
      --v_sb.sbxkzbz3      := i.sbxkzbz3;
      --v_sb.sbsbmm4       := i.sbsbmm4;
      --v_sb.sbmmsz5       := i.sbmmsz5;
      --v_sb.sbxymm6       := i.sbxymm6;
      --v_sb.sbmszdsl7     := i.sbmszdsl7;
      --v_sb.sbyctf8       := i.sbyctf8;
     -- v_sb.sbzdzzs9      := i.sbzdzzs9;
      --v_sb.sbcbshsj10    := i.sbcbshsj10;
      --v_sb.sbjtkssj11    := i.sbjtkssj11;
      --v_sb.sbyl12        := i.sbyl12;
      --v_sb.sbjdh13       := i.sbjdh13;
      v_sb.sbtkbz11      := i.sbtkbz11;
      --v_sb.sbtkzjh       := i.sbtkzjh;
      --v_sb.sbhtbh        := i.sbhtbh;
      --v_sb.sbhtzq        := i.sbhtzq;
      --v_sb.sbrqxz        := i.sbrqxz;
     -- v_sb.htdate        := i.htdate;
      --v_sb.zfdate        := i.zfdate;
      --v_sb.jzdate        := i.jzdate;
      --v_sb.signper       := i.signper;
      --v_sb.signid        := i.signid;
     -- v_sb.pocid         := i.pocid;
     v_sd.MDNO         := i.MDNO; --
     v_sd.sbid := v_sb.sbid;
      v_sd.id        := uuid();
      v_sd.hire_code := v_HIRE_CODE;
      v_sd.MDCALIBER    := i.MDCALIBER; --
      v_sd.MDBRAND      := i.MDBRAND; --
      v_sd.MDMODEL      := i.MDMODEL; --
      v_sd.MDSTATUS     := i.MDSTATUS; --
      v_sd.MDSTATUSDATE := NULL; --
      v_sd.MDSTOCKDATE  := sysdate;
  
      --v_sd.BARCODE      := i.BARCODE;
      v_sd.RFID   := i.RFID;
      v_sd.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。 
      v_sd.BARCODE := SUBSTR(v_sb.manage_no, 4, 1) ||
                    TO_CHAR(SYSDATE, 'YYYYMMDD') || v_sb.sbid;
      v_sd.DQSFH   := i.DQSFH; --塑封号
      v_sd.DQGFH   := i.DQGFH; --钢封号
      v_sd.JCGFH   := i.JCGFH; --稽查封号
      v_sd.QFH     := i.QHF; --铅封号
      
       v_sa.id        := uuid();
      v_sa.hire_code := v_HIRE_CODE;
       v_sa.sbid := v_sb.sbid;
       v_sa.yhano := i.yhano;
       v_sa.yhanoname := i.yhanoname;
       v_sa.yhabankid := i.YHABANKID;
       v_sa.yhaaccountno := i.yhaaccountno;
       v_sa.yhaaccountname := i.yhaaccountname;
       v_sa.yhatsbankid := i.yhatsbankid;
       v_sa.yhatsbankname := i.yhatsbankname;
       v_sa.yhaifxezf := i.yhaifxezf;
       v_sa.yharegdate := trunc(sysdate);
       INSERT INTO ys_yh_custinfo VALUES v_yh;
      INSERT INTO ys_yh_sbinfo VALUES v_sb;
      INSERT INTO ys_yh_sbdoc VALUES v_sd;
      INSERT INTO ys_yh_account VALUES v_sa; 
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_yhadd;
end;
/

prompt
prompt Creating package body PG_ARSPLIT_01
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Arsplit_01 IS
  /*====================================================================
  -- Name: Pg_ARSPLIT_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包,单据提交入口过程
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
  
    IF p_Djlb = '3' THEN
      Sp_Arsplit(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;
  --分账过程
  PROCEDURE Sp_Recfzrlid(p_Arid IN VARCHAR2, --分账流水
                         p_Je   IN NUMBER --分账金额
                         
                         ) AS
  
    CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arid
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         AND Arpaidflag = 'N'
         AND Aroutflag = 'N'
         AND Arje > 0
         FOR UPDATE;
  
    CURSOR c_Rd IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = p_Arid FOR UPDATE;
  
    CURSOR c_Rdf IS
      SELECT * FROM Ys_Zw_Ardetail_Fz WHERE Ardid = p_Arid FOR UPDATE;
  
    Ar      Ys_Zw_Arlist%ROWTYPE;
    Rd      Ys_Zw_Ardetail%ROWTYPE;
    Arf     Ys_Zw_Arlist_Fz%ROWTYPE;
    Rdf     Ys_Zw_Ardetail_Fz%ROWTYPE;
    v_Je    NUMBER(12, 3);
    v_Arid  VARCHAR2(20);
    v_Arid2 VARCHAR2(20);
    v_Sl2   NUMBER(10);
    v_Je2   NUMBER(10, 3);
    v_Sls2  NUMBER(10);
    v_Jes2  NUMBER(10, 3);
    v_Count NUMBER(10);
    v_Czsl  NUMBER(10);
    p_Sl    NUMBER(10);
    Pb      Ysparmtemp%ROWTYPE;
    v_Scode NUMBER(10);
    v_Ecode NUMBER(10);
  
  BEGIN
    NULL;
    --1、调用过程检查要分拆水量
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arid || '请检查！');
    END IF;
    CLOSE c_Ar;
    p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Sl <= 0 THEN
      Raise_Application_Error(Errcode,
                              '分账水量必须小于' || Ar.Arsl || ',流水号:' || Ar.Arid);
    END IF;
  
    --2、将要分账 备份 
    Arf := Ar; --备份原账务
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL插入分账第一笔
    v_Je := 0;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid FROM Dual;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid2 FROM Dual;
    v_Sl2  := 0;
    v_Je2  := 0;
    v_Sls2 := Ar.Arsl;
    v_Jes2 := 0;
    OPEN c_Rdf;
    LOOP
      FETCH c_Rdf
        INTO Rd;
      EXIT WHEN c_Rdf%NOTFOUND OR c_Rdf%NOTFOUND IS NULL;
      --获取临时表中的水量
      SELECT * INTO Pb FROM Ysparmtemp p WHERE TRIM(p.C1) = Rd.Ardpmdid;
      p_Sl  := To_Number(TRIM(Pb.C4));
      v_Sl2 := Rd.Ardsl - p_Sl; --第二笔明细水量
      v_Je2 := Rd.Ardje;
      --第一笔明细
    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Sl;
      Rd.Ardsl   := p_Sl;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --第一笔明细
      v_Je  := v_Je + Rd.Ardje; --第一笔应收合计金额
      v_Je2 := v_Je2 - Rd.Ardje; --第二笔明细金额
      --生成第二笔明细
      Rd.Ardid   := TRIM(v_Arid2);
      Rd.Ardyssl := v_Sl2;
      Rd.Ardsl   := v_Sl2;
      Rd.Ardysje := v_Je2;
      Rd.Ardje   := v_Je2;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd;
      --V_SLS2          := V_SLS2 + RD.RDSL;
      v_Jes2 := v_Jes2 + Rd.Ardje;
    END LOOP;
    CLOSE c_Rdf;
  
    -- 备份起止码
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist插入分账第一笔
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --上次应帐帐日期
    Ar.Arcolumn9  := Arf.Arid; --上次应收帐流水
    Ar.Arcolumn10 := Arf.Armonth; --上次应收帐月份
    Ar.Arcolumn11 := Arf.Artrans; --上次应收帐事务
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --原账务应收流水
    ar.arSCRarTRANS := arF.arTRANS; --原账务事物
    ar.arSCRarMONTH := arF.arMONTH; --原账务月份
    ar.arSCRarDATE  := arF.arDATE;  --原账务日期*/
    SELECT SUM(To_Number(Nvl(TRIM(C4), 0))) INTO v_Czsl FROM Ysparmtemp;
    Ar.Arsl     := v_Czsl;
    Ar.Arje     := v_Je;
    Ar.Arreadsl := v_Czsl;
  
    --第一笔账起码不变，止码为起码加上应收水量 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist插入分账第二笔 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := v_Sls2 - v_Czsl;
    Ar.Arje     := v_Jes2;
    Ar.Arreadsl := v_Sls2 - v_Czsl;
  
    --第二笔账止码不变，起码为止码减去应收水量 20140318
    Ar.Arscode     := v_Ecode - Ar.Arsl;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Ecode;
    Ar.Arecodechar := To_Char(Ar.Arecode);
  
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --5、检查一下分拆两条应收后水量与金额这与与原帐 ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz 是否相同
    --SELECT * INTO arF FROM ys_zw_arlist_FZ WHERE
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Arsl, Arje
              FROM Ys_Zw_Arlist_Fz
             WHERE Arid = p_Arid
            MINUS
            SELECT SUM(Arsl), SUM(Arje)
              FROM Ys_Zw_Arlist
             WHERE Arid IN (TRIM(v_Arid), TRIM(v_Arid2)));
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账总金额错误！');
    END IF;
  
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Ardsl, Ardje
              FROM Ys_Zw_Ardetail_Fz
             WHERE Ardid = p_Arid
            MINUS
            SELECT SUM(Ardsl), SUM(Ardje)
              FROM Ys_Zw_Ardetail
             WHERE Ardid IN (TRIM(v_Arid), TRIM(v_Arid2))
             GROUP BY Ardpmdid, Ardpiid, Ardpfid, Ardclass);
  
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账明细金额错误！');
    END IF;
  
    --5冲原应收帐
    Sp_Reccz_One_01(p_Arid, 'N');
  
    --O_RET := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rdf%ISOPEN THEN
        CLOSE c_Rdf;
      END IF;
      ROLLBACK;
      --O_RET :='N';
      Raise_Application_Error(Errcode, SQLERRM);
  END Sp_Recfzrlid;

  /*====================================================================
  -- Name: Pg_ARSPLIT_01.Sp_ARSPLIT
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包,拆分账单
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志
                       ) AS
    CURSOR c_Hd IS
      SELECT * FROM Ys_Gd_Arsplithd WHERE Bill_Id = p_Bill_Id;
  
    CURSOR c_Dt IS
      SELECT *
        FROM Ys_Gd_Arsplitdt
       WHERE Bill_Id = p_Bill_Id
         AND Chk_Flag = 'Y'
         AND Charge_Amt > 0;    
    Hd    Ys_Gd_Arsplithd%ROWTYPE;
    Dt    Ys_Gd_Arsplitdt%ROWTYPE;
    v_Ret VARCHAR2(10);
  BEGIN
    --检查单头
    OPEN c_Hd;
    FETCH c_Hd
      INTO Hd;
    IF c_Hd%NOTFOUND OR c_Hd%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在' || p_Bill_Id);
    END IF;
    CLOSE c_Hd;
    --检查单体
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
      Sp_Arsplit_change_one(Dt, p_Per, p_Commit);
      --Sp_Recfzrlid(c_Dt.REC_ID,c_Dt.CHARGE_AMT1);
      IF v_Ret = 'N' THEN
        Raise_Application_Error(Errcode,
                                '分账错误,账务流水:' || Dt.Rec_Id || '|应收金额:' ||
                                Dt.Charge_Amt);
      END IF;
    END LOOP;
    CLOSE c_Dt;
    UPDATE Ys_Gd_Arsplithd
       SET Check_Date = SYSDATE, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE Bill_Id = p_Bill_Id;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF c_Hd%ISOPEN THEN
        CLOSE c_Hd;
      END IF;
      IF c_Dt%ISOPEN THEN
        CLOSE c_Dt;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
 ----------------------------------------------- 
  PROCEDURE Sp_Arsplit_change_one(p_Arsplitdt   IN Ys_Gd_Arsplitdt%rowTYPE,  
                                   p_Per     IN VARCHAR2, --操作员
                                   p_Commit  IN VARCHAR2 --提交标志
                                   ) AS
   CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arsplitdt.Rec_Id
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         AND Arpaidflag = 'N'
         AND Aroutflag = 'N'
         AND Arje > 0
         FOR UPDATE;
  
    CURSOR c_Rd IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = p_Arsplitdt.Rec_Id FOR UPDATE;
  
    CURSOR c_Rdf IS
      SELECT * FROM Ys_Zw_Ardetail_Fz WHERE Ardid = p_Arsplitdt.Rec_Id FOR UPDATE;
    Ar      Ys_Zw_Arlist%ROWTYPE;
    Rd      Ys_Zw_Ardetail%ROWTYPE;
    Arf     Ys_Zw_Arlist_Fz%ROWTYPE;
    Rdf     Ys_Zw_Ardetail_Fz%ROWTYPE;
    v_Arid  VARCHAR2(20);
    v_Arid2 VARCHAR2(20);
    v_Count NUMBER(10);
    v_Scode NUMBER(10);
    v_Ecode NUMBER(10);
  
  BEGIN
    NULL;
    --1、调用过程检查要分拆水量
    OPEN c_Ar;
    FETCH c_Ar
      INTO Ar;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arsplitdt.Rec_Id || '请检查！');
    END IF;
    CLOSE c_Ar;
    --p_Sl := Sf_Recfzsl(p_Arid, p_Je);
  
    IF p_Arsplitdt.Water1 + p_Arsplitdt.Water2 <> Ar.Arsl THEN
      Raise_Application_Error(Errcode,
                              '分账水量必须小于' || Ar.Arsl || ',流水号:' || Ar.Arid);
    END IF;
  
    --2、将要分账 备份 
    Arf := Ar; --备份原账务
    INSERT INTO Ys_Zw_Arlist_Fz VALUES Ar;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      INSERT INTO Ys_Zw_Ardetail_Fz VALUES Rd;
    END LOOP;
    CLOSE c_Rd;
  
    --YS_ZW_ARDETAIL插入分账第一笔
    
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid FROM Dual;
    SELECT Lpad(Seq_Arid.Nextval, 10, '0') INTO v_Arid2 FROM Dual;
    
    -- 备份起止码
    v_Scode := Ar.Arscode;
    v_Ecode := Ar.Arecode;
  
    --ys_zw_arlist插入分账第一笔
    SELECT Uuid() INTO Ar.Id FROM Dual;
  
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arcolumn5  := Arf.Ardate; --上次应帐帐日期
    Ar.Arcolumn9  := Arf.Arid; --上次应收帐流水
    Ar.Arcolumn10 := Arf.Armonth; --上次应收帐月份
    Ar.Arcolumn11 := Arf.Artrans; --上次应收帐事务
    Ar.Artrans    := 'C';
    /*ar.arSCRarID    := arF.arID; --原账务应收流水
    ar.arSCRarTRANS := arF.arTRANS; --原账务事物
    ar.arSCRarMONTH := arF.arMONTH; --原账务月份
    ar.arSCRarDATE  := arF.arDATE;  --原账务日期*/ 
    Ar.Arsl     := p_Arsplitdt.Water1;
    Ar.Arje     := p_Arsplitdt.Charge_Amt1;
    Ar.Arreadsl :=  p_Arsplitdt.Water1;
  
    --第一笔账起码不变，止码为起码加上应收水量 20140318
    Ar.Arscode     := v_Scode;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Scode + Ar.Arsl;
    Ar.Arecodechar := To_Char(Ar.Arecode);
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
  
    --ys_zw_arlist插入分账第二笔 
    SELECT Uuid() INTO Ar.Id FROM Dual;
    Ar.Hire_Code := f_Get_Hire_Code();
    Ar.Manage_No := Arf.Manage_No;
    Ar.Arid      := TRIM(v_Arid2);
    Ar.Armonth   := Fobtmanapara(Arf.Manage_No, 'READ_MONTH');
    Ar.Ardate    := Trunc(SYSDATE);
  
    Ar.Arsl     := p_Arsplitdt.Water2;
    Ar.Arje     := p_Arsplitdt.Charge_Amt2;
    Ar.Arreadsl :=  p_Arsplitdt.Water2;
  
    --第二笔账止码不变，起码为止码减去应收水量 20140318
    Ar.Arscode     := v_Ecode - Ar.Arsl;
    Ar.Arscodechar := To_Char(Ar.Arscode);
    Ar.Arecode     := v_Ecode;
    Ar.Arecodechar := To_Char(Ar.Arecode);
  
    INSERT INTO Ys_Zw_Arlist VALUES Ar;
   
   OPEN c_Rdf;
    LOOP
      FETCH c_Rdf
        INTO Rd;
      EXIT WHEN c_Rdf%NOTFOUND OR c_Rdf%NOTFOUND IS NULL;
       
      --第一笔明细    
      Rd.Ardid   := TRIM(v_Arid);
      Rd.Ardyssl := p_Arsplitdt.Water1;
      Rd.Ardsl   := p_Arsplitdt.Water1;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; --第一笔明细 
      --生成第二笔明细
      Rd.Ardid   := TRIM(v_Arid2);
      Rd.Ardyssl := p_Arsplitdt.Water2;
      Rd.Ardsl   := p_Arsplitdt.Water2;
      Rd.Ardysje := Rd.Ardysdj * Rd.Ardyssl;
      Rd.Ardje   := Rd.Arddj * Rd.Ardsl;
      INSERT INTO Ys_Zw_Ardetail VALUES Rd; 
    END LOOP;
    CLOSE c_Rdf;
    --5、检查一下分拆两条应收后水量与金额这与与原帐 ys_zw_arlist_fz,YS_ZW_ARDETAIL_fz 是否相同
    --SELECT * INTO arF FROM ys_zw_arlist_FZ WHERE
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT Arsl, Arje
              FROM Ys_Zw_Arlist_Fz
             WHERE Arid = p_Arsplitdt.Rec_Id
            MINUS
            SELECT SUM(Arsl), SUM(Arje)
              FROM Ys_Zw_Arlist
             WHERE Arid IN (TRIM(v_Arid), TRIM(v_Arid2)));
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账总金额错误！');
    END IF;
  
    SELECT COUNT(*)
      INTO v_Count
      FROM (SELECT SUM(decode(ARDPIID, '01',Ardsl,0)), sum(Ardje)
              FROM Ys_Zw_Ardetail_Fz
             WHERE Ardid = p_Arsplitdt.Rec_Id
            MINUS
            SELECT SUM(decode(ARDPIID, '01',Ardsl,0)), SUM(Ardje)
              FROM Ys_Zw_Ardetail
             WHERE Ardid IN (TRIM(v_Arid), TRIM(v_Arid2))
             /*GROUP BY Ardpmdid, Ardpiid, Ardpfid, Ardclass*/);
  
    IF v_Count > 0 THEN
      Raise_Application_Error(Errcode, '分账明细金额错误！');
    END IF;
  
    --5冲原应收帐
     Sp_Reccz_One_01(p_Arsplitdt.Rec_Id, p_Commit);
    --O_RET := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rdf%ISOPEN THEN
        CLOSE c_Rdf;
      END IF;
      ROLLBACK;
      --O_RET :='N';
      Raise_Application_Error(Errcode, SQLERRM);
  END;

  --插入单负应收与应收冲正 --单条  
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, --  行变量
                            p_Commit IN VARCHAR --是否提交标志
                            ) AS
  
    Arde Ys_Zw_Arlist%ROWTYPE;
    Arcr Ys_Zw_Arlist%ROWTYPE;
    Rd   Ys_Zw_Ardetail%ROWTYPE;
    Rdcr Ys_Zw_Ardetail%ROWTYPE;
    CURSOR c_Ar IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = p_Arid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         FOR UPDATE NOWAIT;
  
    CURSOR c_Rd IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Arde.Arid
         AND Ardpaidflag = 'N'
         FOR UPDATE NOWAIT;
  
  BEGIN
    OPEN c_Ar;
    FETCH c_Ar
      INTO Arde;
    IF c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '应收账务不存在,或不是正常欠费,流水号:' || p_Arid || '请检查！');
    END IF;
    CLOSE c_Ar;
    --将被冲应收产生对应的负帐
    Arcr := Arde;
  
    --贷帐头赋值
    /*arCR.arSCRarID    := arCR.arID;
    arCR.arSCRarTRANS := arCR.arTRANS;
    arCR.arSCRarMONTH := arCR.arMONTH;
    arCR.arSCRarDATE  := arCR.arDATE;*/
    Arcr.Arcolumn5  := Arcr.Ardate; --上次应帐帐日期
    Arcr.Arcolumn9  := Arcr.Arid; --上次应收帐流水
    Arcr.Arcolumn10 := Arcr.Armonth; --上次应收帐月份
    Arcr.Arcolumn11 := Arcr.Artrans; --上次应收帐事务
  
    SELECT Uuid() INTO Arcr.Id FROM Dual;
    --arCR.HIRE_CODE     := arDE.HIRE_CODE;
    Arcr.Arid := Lpad(Seq_Arid.Nextval, 10, '0');
    --arCR.MANAGE_NO     := arDE.MANAGE_NO;
    Arcr.Armonth := Fobtmanapara(Arde.Manage_No, 'READ_MONTH');
    Arcr.Ardate  := Trunc(SYSDATE);
  
    Arcr.Arcd       := Pg_Cb_Cost.Credit;
    Arcr.Artrans    := Arde.Artrans;
    Arcr.Ardatetime := SYSDATE;
    Arcr.Arpaidflag := 'N';
    --
    Arcr.Arsl     := 0 - Arcr.Arsl;
    Arcr.Arje     := 0 - Arcr.Arje;
    Arcr.Araddsl  := 0 - Arcr.Araddsl;
    Arcr.Arpaidje := 0 - Arcr.Arpaidje;
    --数据
    Arcr.Arsavingqc := 0 - Arcr.Arsavingqc;
    Arcr.Arsavingbq := 0 - Arcr.Arsavingbq;
    Arcr.Arsavingqm := 0 - Arcr.Arsavingqm;
    Arcr.Arsxf      := 0 - Arcr.Arsxf;
  
    Arcr.Armemo        := Arde.Armemo;
    Arcr.Arreverseflag := 'Y';
  
    --贷帐体赋值,同时更新待冲目标应收明细销帐标志
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Rd;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '无效的待冲正应收记录：无此应收费用明细');
      end if;*/
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      SELECT Uuid() INTO Rdcr.Id FROM Dual;
      Rdcr.Hire_Code     := Arcr.Hire_Code;
      Rdcr.Ardid         := NULL;
      Rdcr.Ardid         := Arcr.Arid;
      Rdcr.Ardpmdid      := Rd.Ardpmdid;
      Rdcr.Ardpiid       := Rd.Ardpiid;
      Rdcr.Ardpfid       := Rd.Ardpfid;
      Rdcr.Ardpscid      := Rd.Ardpscid;
      Rdcr.Ardclass      := Rd.Ardclass;
      Rdcr.Ardysdj       := Rd.Ardysdj;
      Rdcr.Ardyssl       := 0 - Rd.Ardyssl;
      Rdcr.Ardysje       := 0 - Rd.Ardysje;
      Rdcr.Arddj         := Rd.Arddj;
      Rdcr.Ardsl         := 0 - Rd.Ardsl;
      Rdcr.Ardje         := 0 - Rd.Ardje;
      Rdcr.Ardadjdj      := Rd.Ardadjdj;
      Rdcr.Ardadjsl      := 0 - Rd.Ardadjsl;
      Rdcr.Ardadjje      := 0 - Rd.Ardadjje;
      Rdcr.Ardmethod     := Rd.Ardmethod;
      Rdcr.Ardpaidflag   := Rd.Ardpaidflag;
      Rdcr.Ardpaiddate   := Rd.Ardpaiddate;
      Rdcr.Ardpaidmonth  := Rd.Ardpaidmonth;
      Rdcr.Ardpaidper    := Rd.Ardpaidper;
      Rdcr.Ardpmdscale   := Rd.Ardpmdscale;
      Rdcr.Ardilid       := Rd.Ardilid;
      Rdcr.Ardznj        := 0 - Rd.Ardznj;
      Rdcr.Ardmemo       := Rd.Ardmemo;
      Rdcr.Ardmsmfid     := Rd.Ardmsmfid;
      Rdcr.Ardmonth      := Rd.Ardmonth;
      Rdcr.Ardmid        := Rd.Ardmid;
      Rdcr.Ardpmdtype    := Rd.Ardpmdtype;
      Rdcr.Ardpmdcolumn1 := Rd.Ardpmdcolumn1;
      Rdcr.Ardpmdcolumn2 := Rd.Ardpmdcolumn2;
      Rdcr.Ardpmdcolumn3 := Rd.Ardpmdcolumn3;
      INSERT INTO Ys_Zw_Ardetail VALUES Rdcr;
    
    END LOOP;
    CLOSE c_Rd;
    --插入贷帐头、帐体
    INSERT INTO Ys_Zw_Arlist VALUES Arcr;
  
    --更新最近水量(如果冲正的恰好最近时)
    UPDATE Ys_Zw_Arlist SET Arreverseflag = 'Y' WHERE Arid = p_Arid;
    --排除拆账单
    IF Arde.Artrans <> '3' THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrecsl = 0
       WHERE Sbid = Arcr.Sbid
         AND Sbrecdate = Arcr.Arrdate;
    
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;
    END IF;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Sp_Reccz_One_01;

  --应收分账处理 BY sp_recfzsl by wy  20130324
  --输入应收流水，分帐金额，
  --返回分帐水量
  --1按水量乘单价分
  --2分到不足一吨水为止
  --3从高水量减起减到水量为1吨为止
  --

  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --分帐流水
                      p_Arje IN NUMBER --分帐金额
                      ) RETURN NUMBER AS
    v_Maxsl Ys_Zw_Arlist.Arsl%TYPE;
    v_Maxje Ys_Zw_Arlist.Arje%TYPE;
    v_Fzje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje  Ys_Zw_Arlist.Arje%TYPE;
    v_Jlje1 Ys_Zw_Arlist.Arje%TYPE;
    Pb      Ysparmtemp%ROWTYPE;
    v_Czsl  Ys_Zw_Arlist.Arsl%TYPE;
  
    --需拆分 费用分组、水量、金额   应拆金额
    v_Cfz   Ys_Zw_Ardetail.Ardpmdid%TYPE;
    v_Csl   Ys_Zw_Ardetail.Ardsl%TYPE;
    v_Cje   Ys_Zw_Ardetail.Ardje%TYPE;
    v_Carje Ys_Zw_Ardetail.Ardje%TYPE;
  
    CURSOR c_Rd IS
      SELECT To_Char(Ardpmdid),
             To_Char(MAX(Nvl(Ardsl, 0))) Ardsl,
             To_Char(SUM(Nvl(Ardje, 0)))
        FROM Ys_Zw_Ardetail
       WHERE Ardid = p_Arid
       GROUP BY Ardpmdid
       ORDER BY Ardpmdid;
  
  BEGIN
    --1、取总水量
    /*SELECT SUM (ardsl) INTO v_maxsl FROM
    (
      select ARDPMDID,max(nvl(ardsl,0)) ardsl
      from YS_ZW_ARDETAIL
      where aARDID=p_arid
      GROUP BY ARDPMDID
    );*/
    /*
    PB 表金额组成结构
    拆分金额120
    
    A B C表示行
    行号  分组C1   水量C2   金额C3  拆分水量C4  拆分金额C5 行拆分水量标志C6（1表示需要计算拆分水量）
    A      0        30       90       30         90          0
    B      1        50       150      10         30          1
    C      2        60       180      0          0           0
    */
    --分类获取水量金额
    --该步骤C5拆分金额为可拆分金额
    v_Fzje  := p_Arje;
    v_Maxsl := 0;
    v_Maxje := 0;
    OPEN c_Rd;
    LOOP
      FETCH c_Rd
        INTO Pb.C1, Pb.C2, Pb.C3;
      EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
      v_Maxsl := v_Maxsl + To_Number(Nvl(Pb.C2, 0));
      v_Maxje := v_Maxje + To_Number(Nvl(Pb.C3, 0));
      IF v_Fzje = 0 THEN
        Pb.C4 := '0';
        Pb.C5 := '0';
        Pb.C6 := '0';
      ELSIF v_Fzje >= To_Number(Nvl(Pb.C3, 0)) THEN
        v_Fzje := v_Fzje - To_Number(Nvl(Pb.C3, 0));
        Pb.C4  := Pb.C2;
        Pb.C5  := Pb.C3;
        Pb.C6  := '0';
      ELSE
        Pb.C5  := To_Char(Nvl(v_Fzje, 0));
        Pb.C6  := '1';
        v_Fzje := 0;
      END IF;
      INSERT INTO Ysparmtemp VALUES Pb;
    
    END LOOP;
    CLOSE c_Rd;
  
    --拆分金额如果大于金额，不允许拆分
    IF p_Arje >= v_Maxje OR p_Arje <= 0 OR v_Maxje <= 0 OR v_Maxsl <= 0 THEN
      RETURN - 1;
    END IF;
  
    --根据C6取拆分数据行
    --该部分（C4拆账水量）、（C5拆账金额）为应拆账水量、金额
    BEGIN
      SELECT * INTO Pb FROM Ysparmtemp WHERE TRIM(C6) = '1';
      v_Cfz   := To_Number(TRIM(Pb.C1));
      v_Csl   := To_Number(TRIM(Pb.C2));
      v_Cje   := To_Number(TRIM(Pb.C3));
      v_Carje := To_Number(TRIM(Pb.C5));
      v_Czsl  := 0;
    
      FOR i IN 1 .. v_Csl LOOP
        SELECT SUM(Arddj) * i, SUM(Arddj) * (i - 1)
          INTO v_Jlje, v_Jlje1
          FROM Ys_Zw_Ardetail t
         WHERE Ardid = p_Arid
           AND Ardpmdid = v_Cfz;
        /*if v_jlje<=0 then
          return -1 ;
        end if;*/
        IF v_Carje >= v_Jlje THEN
          v_Czsl := i;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      UPDATE Ysparmtemp
         SET C4 = To_Char(v_Czsl), C5 = To_Char(v_Jlje1)
       WHERE TRIM(C1) = To_Char(v_Cfz)
         AND TRIM(C6) = '1';
    EXCEPTION
      WHEN OTHERS THEN
        --无需计算水量金额，拆账金额正好匹配
        RETURN v_Maxsl;
    END;
  
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 999;
  END;

END;
/

prompt
prompt Creating package body PG_ARTRANS_01
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Artrans_01 IS

  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
    IF p_Djlb IN ('O', 'T', '6', 'N', '13', '14', '21', '23') THEN
      Sp_Rectrans(p_Billno, p_Person); --追量
    ELSIF p_Djlb = 'G' THEN
      Recadjust(p_Billno, p_Person, '', 'Y'); --调整减免   
    ELSIF p_Djlb = '12' THEN
      Sp_Paidbak(p_Billno, p_Person); --实收冲正 
    ELSIF p_Djlb = 'YSZCZ' THEN
      Sp_Recreverse(p_Billno, p_Person, '', 'Y'); --应收冲正    
    END IF;
  END;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------   
  --追量收费 V --保持原有 追量收费
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2) AS
    CURSOR c_Dt IS
      SELECT * FROM Ys_Gd_Aradddt WHERE Bill_Id = p_No FOR UPDATE;
  
    CURSOR c_Ys_Yh_Custinfo(Vcid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vcid;
  
    CURSOR c_Ys_Yh_Sbinfo(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmid FOR UPDATE NOWAIT;
  
    CURSOR c_Ys_Yh_Sbdoc(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Yh_Account(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Bas_Book(Vbook_No IN VARCHAR2) IS
      SELECT * FROM Ys_Bas_Book WHERE Book_No = Vbook_No;
  
    CURSOR c_Picount IS
      SELECT DISTINCT Nvl(t.Item_Type, 1) FROM Bas_Price_Item t;
  
    CURSOR c_Pi(Vpigroup IN NUMBER) IS
      SELECT * FROM Bas_Price_Item t WHERE t.Item_Type = Vpigroup;
    Rth    Ys_Gd_Araddhd%ROWTYPE;
    Rtd    Ys_Gd_Aradddt%ROWTYPE;
    Ci     Ys_Yh_Custinfo%ROWTYPE;
    Mi     Ys_Yh_Sbinfo%ROWTYPE;
    Bf     Ys_Bas_Book%ROWTYPE;
    Md     Ys_Yh_Sbdoc%ROWTYPE;
    Ma     Ys_Yh_Account%ROWTYPE;
    Rl     Ys_Zw_Arlist%ROWTYPE;
    Rl1    Ys_Zw_Arlist%ROWTYPE;
    Rd     Ys_Zw_Ardetail%ROWTYPE;
    p_Piid VARCHAR2(4000);
  
    v_Rlfzcount NUMBER(10);
    v_Rlfirst   NUMBER(10);
    v_Pigroup   Bas_Price_Item.Item_Type%TYPE;
    Rdtab       Pg_Cb_Cost.Rd_Table;
    Pi          Bas_Price_Item%ROWTYPE;
    Mr          Ys_Cb_Mtread%ROWTYPE;
    v_Pv        NUMBER(10);
    v_Count     NUMBER := 0;
    v_Temp      NUMBER := 0;
  BEGIN
  
    BEGIN
      SELECT * INTO Rth FROM Ys_Gd_Araddhd WHERE Bill_No = p_No;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '单据不存在!');
    END;
    --月末最后一天不能进行追量，稽查，补缴，产生应收，避免账务月份跨月
    IF Trunc(SYSDATE) = Last_Day(Trunc(SYSDATE, 'MONTH')) AND
       Rth.Bill_Type IN ('O', '13', '21') THEN
      Raise_Application_Error(Errcode, '当前为出账日，不能做此业务');
    END IF;
    IF Rth.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已审核');
    END IF;
    IF Rth.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消');
    END IF;
    IF Rth.Bill_Type = '13' THEN
      SELECT COUNT(*)
        INTO v_Count
        FROM Ys_Cb_Mtread
       WHERE Yhid = Rth.User_No
         AND Cbmrreadok = 'Y'
         AND Nvl(Cbmrifrec, 'N') = 'N'; -- by ralph 20150213 增加补缴审核时对是否抄见未算费的判断
      IF v_Count > 0 THEN
        Raise_Application_Error(Errcode,
                                '此用户存在已抄见未算费记录！不可以补缴审核!');
      END IF;
    END IF;
    --
    OPEN c_Ys_Yh_Custinfo(Rth.User_No);
    FETCH c_Ys_Yh_Custinfo
      INTO Ci;
    IF c_Ys_Yh_Custinfo%NOTFOUND OR c_Ys_Yh_Custinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此用户');
    END IF;
    CLOSE c_Ys_Yh_Custinfo;
  
    OPEN c_Ys_Yh_Sbinfo(Rth.User_No);
    FETCH c_Ys_Yh_Sbinfo
      INTO Mi;
    IF c_Ys_Yh_Sbinfo%NOTFOUND OR c_Ys_Yh_Sbinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此水表');
    END IF;
  
    OPEN c_Ys_Yh_Sbdoc(Rth.User_No);
    FETCH c_Ys_Yh_Sbdoc
      INTO Md;
    IF c_Ys_Yh_Sbdoc%NOTFOUND OR c_Ys_Yh_Sbdoc%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此水表档案');
    END IF;
    CLOSE c_Ys_Yh_Sbdoc;
  
    OPEN c_Ys_Yh_Account(Rth.User_No);
    FETCH c_Ys_Yh_Account
      INTO Ma;
    IF c_Ys_Yh_Account%NOTFOUND OR c_Ys_Yh_Account%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此水表帐务');
      NULL;
    END IF;
    CLOSE c_Ys_Yh_Account;
  
    OPEN c_Ys_Bas_Book(Rth.Book_No);
    FETCH c_Ys_Bas_Book
      INTO Bf;
    IF c_Ys_Bas_Book%NOTFOUND OR c_Ys_Bas_Book%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此表册');
      NULL;
    END IF;
    CLOSE c_Ys_Bas_Book;
  
    /*--byj add 2016.4.5 如果是(稽查补缴 补收 追量),要判断是否有未完结的 换表工单 、用水性质变更工单、撤表退费、销户工单 、预存退费工单  ----------
    if RTH.BILL_TYPE in ('21','13','O' ) then
       --判断是否有未完结的用水性质变更工单
       select count(*) into v_count
         from custchangehd hd,
              custchangedt dt
        where hd.cchno = dt.ccdno and
              hd.cchlb = 'E' and
              dt.YHID = mi.micid and
              hd.CCHSHFLAG = 'N';
       if v_count > 0 then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【水价变更】工单,不能进行审核!');
       end if;
       --判断是否有故障换表
       if mi.mistatus = '24' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【故障换表】工单,不能进行审核!');
       elsif mi.mistatus = '35' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【周期换表】工单,不能进行审核!');
       elsif mi.mistatus = '36' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存退费】工单,不能进行审核!');
       elsif mi.mistatus = '39' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存撤表退费】工单,不能进行审核!');
       elsif mi.mistatus = '19' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【销户】工单,不能进行审核!');
       end if;
       --如果修改水表指针,要判断审核时的指针是否与建立工单时一致
       if rth.rthecodeflag = 'Y' then
          if rth.rthscode <> mi.mircode then
             RAISE_APPLICATION_ERROR(ERRCODE, '此水表的止码自工单保存后已经变更,请核查!');
          end if;
          \*稽查审核时,如果当月有抄表计划已上传但未算费,提示不能审核!!! (可以算费完成时) *\
          if RTH.rthlb = '21' \*稽查补收*\ then
             begin
               select 1 into v_temp
                 from ys_cb_mtread mr
                where mr.mrmid = mi.SBID and
                      mr.MRREADOK in ('X','Y') and
                      mr.mrifrec = 'N' and
                      rownum < 2;
             exception
               when no_data_found then
                 v_temp := 0;
             end;
             if v_temp > 1 then
                RAISE_APPLICATION_ERROR(ERRCODE, '水表编号【' || mi.micid ||  '】本月已有抄表数据上传但未算费的记录,请核查!');
             end if;
          end if;
       end if;
    end if;*/
    --end!!!
  
    -----单头处理开始
  
    -- 预先赋值
    Rth.Check_Per  := p_Per;
    Rth.Check_Date := Currentdate;
  
    /*******处理追量信息*****/
    IF 1 = 1 THEN
      --是否走算费过程(不走可认为营业外)  
      --插入抄表库
      Pg_Artrans_01.Sp_Insertmr(Rth, TRIM(Rth.Bill_Type), Mi, Rl.Armrid);
    
      IF Rl.Armrid IS NOT NULL THEN
        SELECT * INTO Mr FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        IF Rth.If_Rechis = 'Y' THEN
          IF Rth.Price_Ver IS NULL THEN
            Raise_Application_Error(Errcode, '归档价格版本不能为空！');
          END IF;
          SELECT COUNT(*)
            INTO v_Pv
            FROM Bas_Price_Version
           WHERE Price_Ver = Rth.Price_Ver;
          IF v_Pv = 0 THEN
            Raise_Application_Error(Errcode, '该月份水价未归档！');
          END IF;
          --是否按历史水价算费(选择归档价格版本)
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));*/
          Pg_Cb_Cost.Costculate(Rl.Armrid, '0'); -- 无历史归档水价计费过程，先用当前计费过程
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        ELSE
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), '0000.00');*/ -- 无历史归档水价计费过程，先用当前计费过程
          Pg_Cb_Cost.Costculate(Rl.Armrid, '0');
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        END IF;
        IF Rth.Ecode_Flag = 'Y' THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = Rth.Read_Ecode, Sbrcodechar = Rth.Read_Ecode
          --miface     = mr.mrface,
           WHERE CURRENT OF c_Ys_Yh_Sbinfo;
        
        END IF;
      END IF;
    END IF;
    UPDATE Ys_Gd_Araddhd
       SET Check_Date = Currentdate,
           Check_Per  = p_Per,
           --  CHECK_PER  = rthcreper ,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_No;
  
    --处理起码的问题(由于算费的时候没有考虑到是否更新止码的问题)
    IF Rth.Ecode_Flag = 'N' THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = Rth.Read_Ecode,
             Sbrcodechar = Rth.Read_Ecode,
             Sbnewflag   = 'N'
      --miface     = mr.mrface,
       WHERE CURRENT OF c_Ys_Yh_Sbinfo;
    END IF;
  
    CLOSE c_Ys_Yh_Sbinfo;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  -----------------------------------------------------------------------------
  ----------------------------------------------------------------------------- 
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE) AS
    --抄表流水
    Mr Ys_Cb_Mtread%ROWTYPE; --抄表历史库
  BEGIN
    Mr.Id        := Uuid(); --流水号
    Omrid        := Mr.Id;
    Mr.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --抄表月份
    Mr.Manage_No := Rth.Manage_No; --营销公司
    Mr.Book_No   := Rth.Book_No; --表册
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mr.Cbmrbatch, Mr.Cbmrrper --抄表批次,抄表员
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mr.Cbmrbatch := 1; --抄表批次
        Mr.Cbmrrper  := 'system';
    END;
    Mr.Cbmrrorder := Mi.Sbrorder; --,抄表次序号
    Mr.Yhid       := Mi.Yhid; --用户编号
  
    Mr.Sbid := Mi.Sbid; --水表编号
  
    Mr.Trade_No          := Mi.Trade_No; --行业分类
    Mr.Sbpid             := Mi.Sbpid; --上级水表
    Mr.Cbmrmclass        := Mi.Sbclass; --水表级次
    Mr.Cbmrmflag         := Mi.Sbflag; --末级标志
    Mr.Cbmrcreadate      := SYSDATE; --创建日期
    Mr.Cbmrinputdate     := NULL; --编辑日期
    Mr.Cbmrreadok        := 'Y'; --抄见标志
    Mr.Cbmrrdate         := Rth.Read_Date; --抄表日期
    Mr.Cbmrprdate        := Rth.Pread_Date; --上次抄见日期(取上次有效抄表日期)
    Mr.Cbmrscode         := Rth.Read_Scode; --上期抄见
    Mr.Cbmrscodechar     := Rth.Read_Scode; --上期抄见char
    Mr.Cbmrecode         := Rth.Read_Ecode; --本期抄见
    Mr.Cbmrsl            := Rth.Read_Water; --本期水量
    Mr.Cbmrface          := NULL; --表况
    Mr.Cbmrifsubmit      := 'Y'; --是否提交计费
    Mr.Cbmrifhalt        := 'N'; --系统停算
    Mr.Cbmrdatasource    := 'Z'; --抄表结果来源
    Mr.Cbmrifignoreminsl := 'Y'; --停算最低抄量
    Mr.Cbmrpdardate      := NULL; --抄表机抄表时间
    Mr.Cbmroutflag       := 'N'; --发出到抄表机标志
    Mr.Cbmroutid         := NULL; --发出到抄表机流水号
    Mr.Cbmroutdate       := NULL; --发出到抄表机日期
    Mr.Cbmrinorder       := NULL; --抄表机接收次序
    Mr.Cbmrindate        := NULL; --抄表机接受日期
    Mr.Cbmrrpid          := Mi.Sbrpid; --计件类型
    Mr.Cbmrmemo          := NULL; --抄表备注
    Mr.Cbmrifgu          := 'N'; --估表标志
    Mr.Cbmrifrec         := 'N'; --已计费
    Mr.Cbmrrecdate       := NULL; --计费日期
    Mr.Cbmrrecsl         := NULL; --应收水量
    /*        --取未用余量
    sp_fetchaddingsl(mr.cbmrid , --抄表流水
                     sb.sbid,--水表号
                     v_tempnum,--旧表止度
                     v_tempnum,--新表起度
                     v_addsl ,--余量
                     v_date,--创建日期
                     v_tempstr,--加调事务
                     v_ret  --返回值
                     ) ;
    mr.cbmraddsl         :=   v_addsl ;  --余量   */
    Mr.Cbmraddsl         := 0; --余量
    Mr.Cbmrcarrysl       := NULL; --进位水量
    Mr.Cbmrctrl1         := NULL; --抄表机控制位1
    Mr.Cbmrctrl2         := NULL; --抄表机控制位2
    Mr.Cbmrctrl3         := NULL; --抄表机控制位3
    Mr.Cbmrctrl4         := NULL; --抄表机控制位4
    Mr.Cbmrctrl5         := NULL; --抄表机控制位5
    Mr.Cbmrchkflag       := 'N'; --复核标志
    Mr.Cbmrchkdate       := NULL; --复核日期
    Mr.Cbmrchkper        := NULL; --复核人员
    Mr.Cbmrchkscode      := NULL; --原起数
    Mr.Cbmrchkecode      := NULL; --原止数
    Mr.Cbmrchksl         := NULL; --原水量
    Mr.Cbmrchkaddsl      := NULL; --原余量
    Mr.Cbmrchkcarrysl    := NULL; --原进位水量
    Mr.Cbmrchkrdate      := NULL; --原抄见日期
    Mr.Cbmrchkface       := NULL; --原表况
    Mr.Cbmrchkresult     := NULL; --检查结果类型
    Mr.Cbmrchkresultmemo := NULL; --检查结果说明
    Mr.Cbmrprimid        := Mi.Sbpriid; --合收表主表
    Mr.Cbmrprimflag      := Mi.Sbpriflag; --  合收表标志
    Mr.Cbmrlb            := Mi.Sblb; -- 水表类别
    Mr.Cbmrnewflag       := Mi.Sbnewflag; -- 新表标志
    Mr.Cbmrface2         := NULL; --抄见故障
    Mr.Cbmrface3         := NULL; --非常计量
    Mr.Cbmrface4         := NULL; --表井设施说明
  
    Mr.Cbmrprivilegeflag := 'N'; --特权标志(Y/N)
    Mr.Cbmrprivilegeper  := NULL; --特权操作人
    Mr.Cbmrprivilegememo := NULL; --特权操作备注
    Mr.Area_No           := Mi.Area_No; --管理区域
    Mr.Cbmriftrans       := 'N'; --转单标志
    Mr.Cbmrrequisition   := 0; --通知单打印次数
    Mr.Cbmrifchk         := Mi.Sbifchk; --考核表标志
    Mr.Cbmrinputper      := NULL; --入账人员
    Mr.Price_No          := Mi.Price_No; --用水类别
    --mr.cbmrcaliber       := md.mdcaliber;--口径
    Mr.Cbmrside  := Mi.Sbside; --表位
    Mr.Cbmrmtype := Mi.Sbtype; --表型
  
    Mr.Cbmrplansl   := 0; --计划水量
    Mr.Cbmrplanje01 := 0; --计划水费
    Mr.Cbmrplanje02 := 0; --计划污水处理费
    Mr.Cbmrplanje03 := 0; --计划水资源费
  
    INSERT INTO Ys_Cb_Mtread VALUES Mr;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
      Raise_Application_Error(Errcode, '数据库错误!' || SQLERRM);
  END;
  -----------------------------------------------------------------------------
  ----------------------------------------------------------------------------- 
  --追收插入抄表计划到历史库
  PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                           p_Mriftrans IN VARCHAR2, --抄表数据事务
                           Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                           Omrid       OUT Ys_Cb_Mtread.Id%TYPE) AS
    --抄表流水
    Mrhis Ys_Cb_Mtreadhis%ROWTYPE; --抄表历史库
  BEGIN
    Mrhis.Id        := Uuid(); --流水号
    Omrid           := Mrhis.Id;
    Mrhis.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --抄表月份
    Mrhis.Manage_No := Rth.Manage_No; --营销公司
    Mrhis.Book_No   := Rth.Book_No; --表册
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mrhis.Cbmrbatch, Mrhis.Cbmrrper --抄表批次,抄表员
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mrhis.Cbmrbatch := 1; --抄表批次
        Mrhis.Cbmrrper  := 'system';
    END;
    Mrhis.Cbmrrorder := Mi.Sbrorder; --,抄表次序号
    Mrhis.Yhid       := Mi.Yhid; --用户编号
  
    Mrhis.Sbid := Mi.Sbid; --水表编号
  
    Mrhis.Trade_No          := Mi.Trade_No; --行业分类
    Mrhis.Sbpid             := Mi.Sbpid; --上级水表
    Mrhis.Cbmrmclass        := Mi.Sbclass; --水表级次
    Mrhis.Cbmrmflag         := Mi.Sbflag; --末级标志
    Mrhis.Cbmrcreadate      := SYSDATE; --创建日期
    Mrhis.Cbmrinputdate     := NULL; --编辑日期
    Mrhis.Cbmrreadok        := 'Y'; --抄见标志
    Mrhis.Cbmrrdate         := Rth.Read_Date; --抄表日期
    Mrhis.Cbmrprdate        := Rth.Pread_Date; --上次抄见日期(取上次有效抄表日期)
    Mrhis.Cbmrscode         := Rth.Read_Scode; --上期抄见
    Mrhis.Cbmrscodechar     := Rth.Read_Scode; --上期抄见char
    Mrhis.Cbmrecode         := Rth.Read_Ecode; --本期抄见
    Mrhis.Cbmrsl            := Rth.Read_Water; --本期水量
    Mrhis.Cbmrface          := NULL; --表况
    Mrhis.Cbmrifsubmit      := 'Y'; --是否提交计费
    Mrhis.Cbmrifhalt        := 'N'; --系统停算
    Mrhis.Cbmrdatasource    := 'Z'; --抄表结果来源
    Mrhis.Cbmrifignoreminsl := 'Y'; --停算最低抄量
    Mrhis.Cbmrpdardate      := NULL; --抄表机抄表时间
    Mrhis.Cbmroutflag       := 'N'; --发出到抄表机标志
    Mrhis.Cbmroutid         := NULL; --发出到抄表机流水号
    Mrhis.Cbmroutdate       := NULL; --发出到抄表机日期
    Mrhis.Cbmrinorder       := NULL; --抄表机接收次序
    Mrhis.Cbmrindate        := NULL; --抄表机接受日期
    Mrhis.Cbmrrpid          := Mi.Sbrpid; --计件类型
    Mrhis.Cbmrmemo          := NULL; --抄表备注
    Mrhis.Cbmrifgu          := 'N'; --估表标志
    Mrhis.Cbmrifrec         := 'Y'; --已计费
    Mrhis.Cbmrrecdate       := NULL; --计费日期
    Mrhis.Cbmrrecsl         := NULL; --应收水量
    /*        --取未用余量
    sp_fetchaddingsl(mrHIS.cbmrid , --抄表流水
                     sb.sbid,--水表号
                     v_tempnum,--旧表止度
                     v_tempnum,--新表起度
                     v_addsl ,--余量
                     v_date,--创建日期
                     v_tempstr,--加调事务
                     v_ret  --返回值
                     ) ;
    mrHIS.cbmraddsl         :=   v_addsl ;  --余量   */
    Mrhis.Cbmraddsl         := 0; --余量
    Mrhis.Cbmrcarrysl       := NULL; --进位水量
    Mrhis.Cbmrctrl1         := NULL; --抄表机控制位1
    Mrhis.Cbmrctrl2         := NULL; --抄表机控制位2
    Mrhis.Cbmrctrl3         := NULL; --抄表机控制位3
    Mrhis.Cbmrctrl4         := NULL; --抄表机控制位4
    Mrhis.Cbmrctrl5         := NULL; --抄表机控制位5
    Mrhis.Cbmrchkflag       := 'N'; --复核标志
    Mrhis.Cbmrchkdate       := NULL; --复核日期
    Mrhis.Cbmrchkper        := NULL; --复核人员
    Mrhis.Cbmrchkscode      := NULL; --原起数
    Mrhis.Cbmrchkecode      := NULL; --原止数
    Mrhis.Cbmrchksl         := NULL; --原水量
    Mrhis.Cbmrchkaddsl      := NULL; --原余量
    Mrhis.Cbmrchkcarrysl    := NULL; --原进位水量
    Mrhis.Cbmrchkrdate      := NULL; --原抄见日期
    Mrhis.Cbmrchkface       := NULL; --原表况
    Mrhis.Cbmrchkresult     := NULL; --检查结果类型
    Mrhis.Cbmrchkresultmemo := NULL; --检查结果说明
    Mrhis.Cbmrprimid        := Mi.Sbpriid; --合收表主表
    Mrhis.Cbmrprimflag      := Mi.Sbpriflag; --  合收表标志
    Mrhis.Cbmrlb            := Mi.Sblb; -- 水表类别
    Mrhis.Cbmrnewflag       := Mi.Sbnewflag; -- 新表标志
    Mrhis.Cbmrface2         := NULL; --抄见故障
    Mrhis.Cbmrface3         := NULL; --非常计量
    Mrhis.Cbmrface4         := NULL; --表井设施说明
  
    Mrhis.Cbmrprivilegeflag := 'N'; --特权标志(Y/N)
    Mrhis.Cbmrprivilegeper  := NULL; --特权操作人
    Mrhis.Cbmrprivilegememo := NULL; --特权操作备注
    Mrhis.Area_No           := Mi.Area_No; --管理区域
    Mrhis.Cbmriftrans       := 'N'; --转单标志
    Mrhis.Cbmrrequisition   := 0; --通知单打印次数
    Mrhis.Cbmrifchk         := Mi.Sbifchk; --考核表标志
    Mrhis.Cbmrinputper      := NULL; --入账人员
    Mrhis.Price_No          := Mi.Price_No; --用水类别
    --mrHIS.cbmrcaliber       := md.mdcaliber;--口径
    Mrhis.Cbmrside  := Mi.Sbside; --表位
    Mrhis.Cbmrmtype := Mi.Sbtype; --表型
  
    Mrhis.Cbmrplansl   := 0; --计划水量
    Mrhis.Cbmrplanje01 := 0; --计划水费
    Mrhis.Cbmrplanje02 := 0; --计划污水处理费
    Mrhis.Cbmrplanje03 := 0; --计划水资源费
    INSERT INTO Ys_Cb_Mtreadhis VALUES Mrhis;
  END;
  -----------------------------------------------------------------------------
  ----------------------------------------------------------------------------- 
  --调整减免
  --应收调整（包含应收冲正、调高、调低、调差价）
  PROCEDURE Recadjust(p_Billno IN VARCHAR2, --单据编号
                      p_Per    IN VARCHAR2, --完结人
                      p_Memo   IN VARCHAR2, --备注
                      p_Commit IN VARCHAR --是否提交标志
                      ) AS
    CURSOR c_Rah IS
      SELECT * FROM Ys_Gd_Aradjusthd WHERE Bill_Id = p_Billno FOR UPDATE;
  
    CURSOR c_Rad IS
      SELECT *
        FROM Ys_Gd_Aradjustdt
       WHERE Bill_Id = p_Billno
         AND Chk_Flag = 'Y'
       ORDER BY Id
         FOR UPDATE;
  
    CURSOR c_Rlsource(Vrlid IN VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = Vrlid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N'
         AND Arbadflag = 'N'
         AND Aroutflag = 'N';
  
    CURSOR c_Raddall(Vrd_Id IN VARCHAR2) IS
      SELECT *
        FROM Ys_Gd_Aradjustddt
       WHERE Rd_Id = Vrd_Id
       ORDER BY Id
         FOR UPDATE;
  
    Rah      Ys_Gd_Aradjusthd%ROWTYPE;
    Rad      Ys_Gd_Aradjustdt%ROWTYPE;
    Radd     Ys_Gd_Aradjustddt%ROWTYPE;
    Rlsource Ys_Zw_Arlist%ROWTYPE;
    --
    Vrd        Parm_Append1rd := Parm_Append1rd(NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL);
    Vrds       Parm_Append1rd_Tab := Parm_Append1rd_Tab();
    Vsumraddje NUMBER := 0; --再次校验单头单体金额相符，很重要
  BEGIN
    --单据状态校验
    --检查单是否已完结
    OPEN c_Rah;
    FETCH c_Rah
      INTO Rah;
    IF c_Rah%NOTFOUND OR c_Rah%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在');
    END IF;
    IF Rah.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已审核');
    END IF;
    IF Rah.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消');
    END IF;
  
    OPEN c_Rad;
    FETCH c_Rad
      INTO Rad;
    IF c_Rad%NOTFOUND OR c_Rad%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据中不存在选中的调整记录');
    END IF;
    WHILE c_Rad%FOUND LOOP
      OPEN c_Rlsource(Rad.Rec_Id);
      FETCH c_Rlsource
        INTO Rlsource;
      IF c_Rlsource%NOTFOUND OR c_Rlsource%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '待调整应收帐务不存在，或已销、已调、划账处理、代收代扣在途等原因！');
      END IF;
      CLOSE c_Rlsource;
      -------------------------------------------------
      Vsumraddje := 0;
      Vrds       := NULL;
      OPEN c_Raddall(Rad.Id);
      LOOP
        FETCH c_Raddall
          INTO Radd;
        EXIT WHEN c_Raddall%NOTFOUND OR c_Raddall%NOTFOUND IS NULL;
      
        Vrd.Hire_Code := Radd.Hire_Code;
        Vrd.Ardpmdid  := Radd.Group_No;
        Vrd.Ardpfid   := Radd.Price_No;
        Vrd.Ardpscid  := Radd.Ardpscid; --费率明细方案
        Vrd.Ardpiid   := Radd.Price_Item;
        Vrd.Ardclass  := Radd.Step_Class;
        Vrd.Arddj     := Radd.Adjust_Price;
        /* vrd.rdsl     := case when rah.rahmemo='减免' then radd.raddyssl
        when rah.rahmemo='调整' then radd.raddsl
        else radd.raddsl end;*/
        Vrd.Ardsl := Radd.Adjust_Water;
        Vrd.Ardje := Radd.Adjust_Price;
        IF Vrds IS NULL THEN
          Vrds := Parm_Append1rd_Tab(Vrd);
        ELSE
          Vrds.Extend;
          Vrds(Vrds.Last) := Vrd;
        END IF;
        Vsumraddje := Vsumraddje + Vrd.Ardje;
      END LOOP;
      CLOSE c_Raddall;
      IF Vsumraddje <> Rad.Charge_Amt THEN
        Raise_Application_Error(Errcode,
                                '单据' || Rad.Rec_Id || '数据错误，调整后金额' ||
                                Vsumraddje || '与单体明细合计' || Rad.Charge_Amt || '不符');
      END IF;
      -------------------------------------------------
      Pg_Paid.Recadjust(p_Rlmid           => Rad.User_No,
                        p_Rlcname         => Rah.User_Name,
                        p_Rlpfid          => Rad.Price_No,
                        p_Rlrdate         => Rad.Read_Date,
                        p_Rlscode         => Rad.Read_Scode,
                        p_Rlecode         => Rad.Read_Ecode,
                        p_Rlsl            => Rad.Water,
                        p_Rlje            => Rad.Charge_Amt,
                        p_Rlznj           => 0,
                        p_Rltrans         => 'X',
                        p_Rlmemo          => Rah.Adj_Memo,
                        p_Rlid_Source     => Rad.Rec_Id,
                        p_Parm_Append1rds => Vrds,
                        p_Commit          => 0,
                        p_Ctl_Mircode     => CASE
                                               WHEN Rah.Ncode_Flag = 'Y' THEN
                                                Rah.Next_Code
                                               ELSE
                                                NULL
                                             END,
                        o_Rlid_Reverse    => Rad.Rec_Id_Cr,
                        o_Rlid            => Rad.Rec_Id_De);
      ----反馈单体
      UPDATE Ys_Gd_Aradjustdt
         SET Rec_Id_Cr = Rad.Rec_Id_Cr, Rec_Id_De = Rad.Rec_Id_De
       WHERE CURRENT OF c_Rad;
      FETCH c_Rad
        INTO Rad;
    END LOOP;
    CLOSE c_Rad;
  
    --审核单头
    UPDATE Ys_Gd_Aradjusthd
       SET Check_Date = Currentdate, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE CURRENT OF c_Rah;
    CLOSE c_Rah;
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rah%ISOPEN THEN
        CLOSE c_Rah;
      END IF;
      IF c_Rad%ISOPEN THEN
        CLOSE c_Rad;
      END IF;
      IF c_Raddall%ISOPEN THEN
        CLOSE c_Raddall;
      END IF;
      IF c_Rlsource%ISOPEN THEN
        CLOSE c_Rlsource;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recadjust;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------      
  --实收冲正
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2) IS
    Ls_Retstr VARCHAR2(100);
    --单头
    CURSOR c_Hd IS
      SELECT * FROM Ys_Gd_Paidadjusthd WHERE Bill_Id = p_No FOR UPDATE;
    --单体
    CURSOR c_Dt IS
      SELECT * FROM Ys_Gd_Paidadjustdt WHERE Bill_Id = p_No FOR UPDATE;
  
    v_Hd          Ys_Gd_Paidadjusthd%ROWTYPE;
    v_Dt          Ys_Gd_Paidadjustdt %ROWTYPE;
    v_Temp        NUMBER DEFAULT 0;
    p_Pid_Reverse VARCHAR2(50);
  BEGIN
    OPEN c_Hd;
    FETCH c_Hd
      INTO v_Hd;
    /*检查处理*/
    IF c_Hd%ROWCOUNT = 0 THEN
      Raise_Application_Error(Errcode,
                              '单据不存在,可能已经由其他操作员操作！');
    END IF;
    IF v_Hd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已经审核！');
    END IF;
    IF v_Hd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消！');
    END IF;
    /*处理单体*/
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO v_Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
    
      IF v_Dt.Paid_Trans = 'H' THEN
        Raise_Application_Error(Errcode,
                                '缴费批次号' || v_Dt.Paid_Batch ||
                                '基建调拨实施前缴费,暂时不能冲正!');
      END IF;
    
      --end!!!
      Pg_Paid.Posreverse(v_Dt.Paid_Id, p_Per, '', 0, p_Pid_Reverse);
    
    END LOOP;
    UPDATE Ys_Gd_Paidadjusthd
       SET Check_Flag = 'Y', Check_Date = SYSDATE, Check_Per = p_Per
    --  PAHSHPER = pahcreper
     WHERE CURRENT OF c_Hd;
  
    IF c_Hd%ISOPEN THEN
      CLOSE c_Hd;
    END IF;
    IF c_Dt%ISOPEN THEN
      CLOSE c_Dt;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF c_Hd%ISOPEN THEN
        CLOSE c_Hd;
      END IF;
      IF c_Dt%ISOPEN THEN
        CLOSE c_Dt;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  -----------------------------------------------------------------------------
  ----------------------------------------------------------------------------- 
  --应收冲正（相当于应收调整到0 ）
  PROCEDURE Sp_Recreverse(p_Billno IN VARCHAR2, --单据编号
                          p_Per    IN VARCHAR2, --完结人
                          p_Memo   IN VARCHAR2, --备注
                          p_Commit IN VARCHAR --是否提交标志
                          ) AS
  
    CURSOR c_Rch IS
      SELECT * FROM Ys_Gd_Arrevokehd WHERE Bill_Id = p_Billno FOR UPDATE;
  
    CURSOR c_Rcd IS
      SELECT *
        FROM Ys_Gd_Arrevokedt
       WHERE Bill_Id = p_Billno
       ORDER BY Id
         FOR UPDATE;
    Rch  Ys_Gd_Arrevokehd%ROWTYPE;
    Rcd  Ys_Gd_Arrevokedt%ROWTYPE;
    Vrd  Parm_Append1rd := Parm_Append1rd(NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL);
    Vrds Parm_Append1rd_Tab := Parm_Append1rd_Tab();
  BEGIN
    --单据状态校验
    --检查单是否已完结
    OPEN c_Rch;
    FETCH c_Rch
      INTO Rch;
    IF c_Rch%NOTFOUND OR c_Rch%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在');
    END IF;
    IF Rch.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已审核');
    END IF;
    IF Rch.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消');
    END IF;
  
    OPEN c_Rcd;
    FETCH c_Rcd
      INTO Rcd;
    IF c_Rcd%NOTFOUND OR c_Rcd%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据中不存在选中的冲正记录');
    END IF;
    WHILE c_Rcd%FOUND LOOP
      Pg_Paid.Recadjust(p_Rlmid           => Rcd.Yhid,
                        p_Rlcname         => NULL,
                        p_Rlpfid          => Rcd.Arpfid,
                        p_Rlrdate         => Rcd.Ardate,
                        p_Rlscode         => Rcd.Arscode,
                        p_Rlecode         => Rcd.Arecode,
                        p_Rlsl            => 0,
                        p_Rlje            => 0,
                        p_Rlznj           => 0,
                        p_Rltrans         => 'X',
                        p_Rlmemo          => Rcd.Armemo,
                        p_Rlid_Source     => Rcd.Arid,
                        p_Parm_Append1rds => Vrds,
                        p_Commit          => 0,
                        p_Ctl_Mircode     => CASE
                                               WHEN Rcd.Ncode_Flag = 'Y' THEN
                                                Rcd.Arscode
                                               ELSE
                                                NULL
                                             END,
                        o_Rlid_Reverse    => Rcd.Rec_Id_Cr,
                        o_Rlid            => Rcd.Rec_Id_De);
    
      ----反馈单体
      UPDATE Ys_Gd_Arrevokedt
         SET Rec_Id_Cr = Rcd.Rec_Id_Cr, Rec_Id_De = Rcd.Rec_Id_De
       WHERE CURRENT OF c_Rcd;
    
      ----如果是冲正当月抄表应收，允许重新抄表
      BEGIN
        UPDATE Ys_Cb_Mtread
           SET Cbmrifrec = 'N', Cbmrifsubmit = 'N', Cbmrifhalt = 'N'
         WHERE Id = (SELECT Armrid
                       FROM Ys_Zw_Arlist
                      WHERE Arid = Rcd.Arid
                        AND Arcd = 'DE'
                        AND Artrans = '1'
                        AND Armrid IS NOT NULL);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      FETCH c_Rcd
        INTO Rcd;
    END LOOP;
    CLOSE c_Rcd;
  
    --审核单头
    UPDATE Ys_Gd_Arrevokehd
       SET Check_Date = Currentdate, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE CURRENT OF c_Rch;
    CLOSE c_Rch;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rch%ISOPEN THEN
        CLOSE c_Rch;
      END IF;
      IF c_Rcd%ISOPEN THEN
        CLOSE c_Rcd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Sp_Recreverse;

END;
/

prompt
prompt Creating package body PG_ARZNJ_01
prompt =================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Arznj_01 IS
  /*====================================================================
  -- Name: Pg_Arznj_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包,单据提交入口过程
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
  
    IF p_Djlb = '7' THEN
      SP_ARZNJJM(P_BILLNO, P_PERSON, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_Arznj_01.Sp_Arznjjm
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包,滞纳金减免
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志
                       ) AS
    v_Exist NUMBER(10);
    Znjdt   Ys_Gd_Znjadjustdt%ROWTYPE;
    Znjhd   Ys_Gd_Znjadjusthd%ROWTYPE;
    --ZNJL     ZNJADJUSTLIST%ROWTYPE;
    Ar       Ys_Zw_Arlist%ROWTYPE;
    Rd       Ys_Zw_Ardetail%ROWTYPE;
    v_Chkstr VARCHAR2(200);
    CURSOR c_Ys_Gd_Znjadjustdt IS
      SELECT * FROM Ys_Gd_Znjadjustdt WHERE Bill_Id = p_Bill_Id FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO Znjhd FROM Ys_Gd_Znjadjusthd WHERE Bill_Id = p_Bill_Id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
    --检查减免额度
    /*    V_CHKSTR :=F_CHKZNJED( P_PER ,ZNJHD.bill_id   ) ;
    IF V_CHKSTR <>'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, V_CHKSTR);
    END IF;*/
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
    Znjhd.Check_Date := SYSDATE;
    OPEN c_Ys_Gd_Znjadjustdt;
    LOOP
      FETCH c_Ys_Gd_Znjadjustdt
        INTO Znjdt;
      EXIT WHEN c_Ys_Gd_Znjadjustdt%NOTFOUND OR c_Ys_Gd_Znjadjustdt%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO Ar FROM Ys_Zw_Arlist WHERE Arid = Znjdt.Rec_Id;
      EXCEPTION
        WHEN OTHERS THEN
          Raise_Application_Error(Errcode,
                                  '应收流水号[' || Znjdt.Rec_Id || ']不存在');
      END;
      IF Ar.Arcd <> 'DE' THEN
        Raise_Application_Error(Errcode,
                                '资料号[' || Ar.Armcode || ']' || Ar.Armonth || '月份' ||
                                '应收流水号[' || Ar.Arid || ']已进行冲正处理，不能做减免！');
      END IF;
    
      IF Ar.Arpaidflag <> 'N' THEN
        Raise_Application_Error(Errcode,
                                '资料号[' || Ar.Armcode || ']' || Ar.Armonth || '月份' ||
                                '应收流水号[' || Ar.Arid || ']已为销帐状态，不能做减免！');
      END IF;
    
      /*IF AR.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '资料号[' || AR.ARMCODE || ']' || AR.ARMONTH || '月份' ||
                                '应收流水号[' || AR.rec_id ||
                                ']欠费信息已发到银行扣款，不能做减免！');
      END IF;*/
      /*UPDATE ZNJADJUSTLIST T
         SET ZALSTATUS = 'N'
       WHERE T.ZALrec_id = ZNJDT.ZADrec_id
         AND ZALSTATUS = 'Y';
      
      ZNJL.ZALrec_id      := ZNJDT.ZADrec_id; --减免应收流水
      ZNJL.ZALPIID      := ZNJDT.ZADPIID; --减免费用项目（全部为NA）
      ZNJL.ZALMID       := ZNJDT.ZADMID; --水表编号
      ZNJL.ZALMCODE     := ZNJDT.ZADMCODE; --水表号
      ZNJL.ZALMETHOD    := ZNJDT.ZADMETHOD; --减免方法（1、目标金额减免；2、比例金额减免；3、差额减免；4、调整起算日期）
      ZNJL.ZALVALUE     := ZNJDT.ZADVALUE; --减免金额/比例值
      ZNJL.ZALZNDATE    := ZNJDT.ZADZNDATE; --减免目标起算日
      ZNJL.ZALDATE      := ZNJHD.check_date; --减免日期
      ZNJL.ZALPER       := P_PER; --减免人员
      ZNJL.ZALBILLNO    := ZNJDT.bill_id; --减免单据编号
      ZNJL.ZALBILLROWNO := ZNJDT.ZADROWNO; --减免单据行号
      ZNJL.ZALSTATUS    := 'Y'; --有效标志
      INSERT INTO ZNJADJUSTLIST VALUES ZNJL;*/
      if Znjdt.Method = '01' then
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arznjreducflag = 'Y', Ar.Arznj = Znjdt.Adjust_Value
         WHERE Arid = Znjdt.Rec_Id
           --AND Arznjreducflag = 'N'
           AND Arpaidflag = 'N';
      end if;
      if Znjdt.Method = '03' then
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arznjreducflag = 'Y',
               Ar.Arznj          = round(Znjdt.Adjust_Value *
                                         Znjdt.Adjust_Ratio,
                                         2)
         WHERE Arid = Znjdt.Rec_Id
           --AND Arznjreducflag = 'N'
           AND Arpaidflag = 'N';
      end if;
    
      IF Znjdt.Method = '02' THEN
        -- 调整起算日期  
        UPDATE Ys_Zw_Arlist Ar
           SET Ar.Arzndate = Znjdt.Late_Fee_Date
         WHERE Arid = Znjdt.Rec_Id
         AND Arpaidflag = 'N';
      END IF;
    END LOOP;
    CLOSE c_Ys_Gd_Znjadjustdt;
  
    UPDATE Ys_Gd_Znjadjusthd
       SET Check_Date = Znjhd.Check_Date,
           Check_Per  = p_Per,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_Bill_Id;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

END;
/

prompt
prompt Creating package body PG_BALANCEADJ_01
prompt ======================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Balanceadj_01 IS
  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Approve
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 余额调整过程包,单据提交入口过程
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
  
    IF p_Djlb = '36' OR p_Djlb = '39' THEN
      --36预存余额退费申请  39预存余额撤表退费申请
      Sp_Balanceadj(p_Billno, p_Person, 'Y');
    ELSE
      Raise_Application_Error(Errcode, p_Billno || '->1 无效的单据类别！');
    END IF;
  END;

  /*====================================================================
  -- Name: Pg_BALANCEADJ_01.Sp_Balanceadj
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 余额调整过程包,余额调整
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Sp_Balanceadj(p_Bill_Id IN VARCHAR2, --批次流水
                          p_Per     IN VARCHAR2, --操作员
                          p_Commit  IN VARCHAR2 --提交标志
                          ) AS
    v_Exist NUMBER(10);
    Znjdt   Ys_Gd_Balanceadjdt%ROWTYPE;
    Znjhd   Ys_Gd_Balanceadjhd%ROWTYPE;
    --ZNJL     ZNJADJUSTLIST%ROWTYPE;
    Ar             Ys_Zw_Arlist%ROWTYPE;
    Mi             Ys_Yh_Sbinfo%ROWTYPE;
    Ci             Ys_Yh_Custinfo%ROWTYPE;
    c_Ptrans       VARCHAR2(3);
    v_Batch        Ys_Zw_Paidment.Pdbatch%TYPE;
    v_Pid          Ys_Zw_Paidment.Pid%TYPE;
    Vn_Remainafter Ys_Zw_Paidment.Pdsavingqm%TYPE;
    CURSOR c_Ys_Gd_Balanceadjdt IS
      SELECT *
        FROM Ys_Gd_Balanceadjdt
       WHERE Bill_Id = p_Bill_Id
         FOR UPDATE;
    CURSOR c_Custinfo(Vcid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vcid;
    CURSOR c_Meterinfo(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Yhid = Vmid;
  BEGIN
    BEGIN
      SELECT *
        INTO Znjhd
        FROM Ys_Gd_Balanceadjhd
       WHERE Bill_Id = p_Bill_Id;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
  
    IF Znjhd.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Znjhd.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
    Znjhd.Check_Date := SYSDATE;
    OPEN c_Ys_Gd_Balanceadjdt;
    LOOP
      FETCH c_Ys_Gd_Balanceadjdt
        INTO Znjdt;
      EXIT WHEN c_Ys_Gd_Balanceadjdt%NOTFOUND OR c_Ys_Gd_Balanceadjdt%NOTFOUND IS NULL;
      --SBSAVING 
      OPEN c_Custinfo(Znjdt.Yhid);
      FETCH c_Custinfo
        INTO Ci;
      IF c_Custinfo%NOTFOUND OR c_Custinfo%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无此用户');
      END IF;
      CLOSE c_Custinfo;
    
      OPEN c_Meterinfo(Znjdt.Yhid);
      FETCH c_Meterinfo
        INTO Mi;
      IF c_Meterinfo%NOTFOUND OR c_Meterinfo%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无此水表');
      END IF;
      CLOSE c_Meterinfo;
    
      IF Mi.Sbsaving + Znjdt.Adjust_Balance < 0 THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid ||
                                ']的预存余额不够,会造成负预存,请核查!');
      END IF;
      IF Mi.Sbsaving <> Znjdt.Balance THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid ||
                                ']的预存余额已被更改,请核查!');
      END IF;
      --判断是否有欠费
      BEGIN
        SELECT 1
          INTO v_Exist
          FROM Ys_Zw_Arlist Ar
         WHERE Yhid = Znjdt.Yhid
           AND Arreverseflag = 'N'
           AND Arbadflag = 'N'
           AND Arpaidflag = 'N'
           AND Arje > 0
           AND Rownum < 2;
      EXCEPTION
        WHEN No_Data_Found THEN
          NULL;
      END;
      IF v_Exist > 0 THEN
        Raise_Application_Error(Errcode,
                                '在此工单申请后，用户[' || Znjdt.Yhid || ']有欠费,请核查!');
      END IF;
    
      IF Znjdt.Change_Type = '36' THEN
        c_Ptrans := 'y';
        --yc.ycnote := '预存余额退费申请';
      ELSIF Znjdt.Change_Type = '39' THEN
        c_Ptrans := 'Y';
        --yc.ycnote := '预存余额撤表退费申请';
      END IF;
    
      SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
        INTO v_Batch
        FROM Dual;
    
      Pg_Paid.Precustback(Znjdt.Yhid, --     IN VARCHAR2,
                          Znjhd.Manage_No, --   IN VARCHAR2,
                          p_Per, --       IN VARCHAR2,
                          c_Ptrans, --    IN VARCHAR2,
                          Znjdt.Adjust_Balance, --     IN NUMBER,
                          Znjdt.Adjust_Memo, --      IN VARCHAR2,
                          v_Batch, --      IN OUT VARCHAR2,
                          v_Pid, --    OUT VARCHAR2,
                          Vn_Remainafter --OUT NUMBER
                          );
    
    END LOOP;
    CLOSE c_Ys_Gd_Balanceadjdt;
  
    UPDATE Ys_Gd_Balanceadjhd
       SET Check_Date = Znjhd.Check_Date,
           Check_Per  = p_Per,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_Bill_Id;
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

END;
/

prompt
prompt Creating package body PG_CBPLAN
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_CBPLAN" is

  /*
  进行生成抄码表
  参数：p_manage_no： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_month: 目标营业所
        p_book_no:  目标表册 
  处理：生成抄表资料
  输出：无
  */
  PROCEDURE createCB(p_HIRE_CODE in VARCHAR2,
                     p_manage_no in VARCHAR2,
                     p_month     in varchar2,
                     p_book_no   in varchar2) IS
    yh        ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr       ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --存在
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    cursor c_bksb is
      select a.yhid,
             b.sbid,
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype
        from ys_yh_custinfo a, ys_yh_sbinfo b, ys_yh_sbdoc s, ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and b.manage_no = p_manage_no
         and b.book_no = p_book_no
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         and d.read_nmonth = p_month
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid,
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --判断是否存在重复抄表计划
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id         := sys_guid(); --流水号
        sbr.hire_code  := p_HIRE_CODE;
        sbr.cbmrmonth  := p_month; --抄表月份
        sbr.manage_no  := sb.manage_no; --管辖公司
        sbr.book_no    := p_book_no; --表册
        sbr.cbMRBATCH  := bc.READ_BATCH; --抄表批次
        sbr.cbMRRPER   := bc.READ_PER; --抄表员
        sbr.cbmrrorder := sb.sbrorder; --抄表次序号
      
        sbr.YHID := yh.yhid; --用户编号
      
        sbr.sbid := sb.sbid; --水表编号
      
        sbr.TRADE_NO          := sb.TRADE_NO; --行业分类
        sbr.SBPID             := sb.sbpid; --上级水表
        sbr.CBMRMCLASS        := sb.sbclass; --水表级次
        sbr.CBMRMFLAG         := sb.sbflag; --末级标志
        sbr.CBMRCREADATE      := sysdate; --创建日期
        sbr.CBMRINPUTDATE     := null; --编辑日期
        sbr.CBMRREADOK        := 'N'; --抄见标志
        sbr.CBMRRDATE         := null; --抄表日期
        sbr.cbmrprdate        := sb.sbrecdate; --上次抄见日期(取上次有效抄表日期)
        sbr.cbmrscode         := sb.sbrcode; --上期抄见
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --上期抄见char
        sbr.cbmrecode         := null; --本期抄见
        sbr.cbmrsl            := null; --本期水量
        sbr.cbmrface          := null; --表况
        sbr.cbmrifsubmit      := 'Y'; --是否提交计费
        sbr.cbmrifhalt        := 'N'; --系统停算
        sbr.cbmrdatasource    := 1; --抄表结果来源
        sbr.cbmrifignoreminsl := 'Y'; --停算最低抄量
        sbr.cbmrpdardate      := null; --抄表机抄表时间
        sbr.cbmroutflag       := 'N'; --发出到抄表机标志
        sbr.cbmroutid         := null; --发出到抄表机流水号
        sbr.cbmroutdate       := null; --发出到抄表机日期
        sbr.cbmrinorder       := null; --抄表机接收次序
        sbr.cbmrindate        := null; --抄表机接受日期
        sbr.cbmrrpid          := sb.sbrpid; --计件类型
        sbr.CBMRMEMO          := null; --抄表备注
        sbr.cbmrifgu          := 'N'; --估表标志
        sbr.cbmrifrec         := 'N'; --已计费
        sbr.cbmrrecdate       := null; --计费日期
        sbr.cbmrrecsl         := null; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(sbr.cbmrid , --抄表流水
                         sb.sbid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --余量   */
        sbr.cbmraddsl         := 0; --余量
        sbr.cbmrcarrysl       := null; --进位水量
        sbr.cbmrctrl1         := null; --抄表机控制位1
        sbr.cbmrctrl2         := null; --抄表机控制位2
        sbr.cbmrctrl3         := null; --抄表机控制位3
        sbr.cbmrctrl4         := null; --抄表机控制位4
        sbr.cbmrctrl5         := null; --抄表机控制位5
        sbr.cbmrchkflag       := 'N'; --复核标志
        sbr.cbmrchkdate       := null; --复核日期
        sbr.cbmrchkper        := null; --复核人员
        sbr.cbmrchkscode      := null; --原起数
        sbr.cbmrchkecode      := null; --原止数
        sbr.cbmrchksl         := null; --原水量
        sbr.cbmrchkaddsl      := null; --原余量
        sbr.cbmrchkcarrysl    := null; --原进位水量
        sbr.cbmrchkrdate      := null; --原抄见日期
        sbr.cbmrchkface       := null; --原表况
        sbr.cbmrchkresult     := null; --检查结果类型
        sbr.cbmrchkresultmemo := null; --检查结果说明
        sbr.cbmrprimid        := sb.sbpriid; --合收表主表
        sbr.cbmrprimflag      := sb.sbpriflag; --  合收表标志
        sbr.cbmrlb            := sb.sblb; -- 水表类别
        sbr.cbmrnewflag       := sb.sbnewflag; -- 新表标志
        sbr.cbmrface2         := null; --抄见故障
        sbr.cbmrface3         := null; --非常计量
        sbr.cbmrface4         := null; --表井设施说明
      
        sbr.cbMRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        sbr.cbmrprivilegeper  := null; --特权操作人
        sbr.cbmrprivilegememo := null; --特权操作备注
        sbr.AREA_NO           := sb.AREA_NO; --管理区域
        sbr.cbmriftrans       := 'N'; --转单标志
        sbr.cbmrrequisition   := 0; --通知单打印次数
        sbr.cbmrifchk         := sb.sbifchk; --考核表标志
        sbr.cbmrinputper      := null; --入账人员
        sbr.PRICE_NO          := sb.PRICE_NO; --用水类别
        sbr.cbmrcaliber       := md.mdcaliber; --口径
        sbr.cbmrside          := sb.sbside; --表位
        sbr.cbmrmtype         := sb.sbtype; --表型
      
        sbr.cbmrplansl   := 0; --计划水量
        sbr.cbmrplanje01 := 0; --计划水费
        sbr.CBMRPLANJE02 := 0; --计划污水处理费
        sbr.cbmrplanje03 := 0; --计划水资源费
      
        --上次水费   至  去年度次均量
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl,
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);
      
        insert into ys_cb_mtread VALUES sbr;
      
        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;
  
    update ys_bas_book k
       set READ_NMONTH = to_char(add_months(to_date(READ_NMONTH, 'yyyy.mm'),
                                            READ_CYCLE),
                                 'yyyy.mm')
     where MANAGE_NO = p_MANAGE_NO
       and BOOK_NO = p_BOOK_NO
       and hire_code = p_HIRE_CODE;
  
    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  /*
  进行生成抄码表
  参数：p_manage_no：营业所
        p_month: 
        p_book_no:  表册 
  处理：生成抄表资料
  输出：无
  */
  PROCEDURE createCBsb(p_HIRE_CODE in VARCHAR2,
                       p_month     in varchar2,
                       p_sbid      in VARCHAR2) IS
    yh        ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr       ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --存在
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    cursor c_bksb is
      select a.yhid,
             b.sbid,
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype,
             b.book_no
        from ys_yh_custinfo a, ys_yh_sbinfo b, ys_yh_sbdoc s, ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and b.sbid = p_sbid
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid,
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype,
             sb.book_no;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --判断是否存在重复抄表计划
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id         := sys_guid(); --流水号
        sbr.hire_code  := p_HIRE_CODE;
        sbr.cbmrmonth  := p_month; --抄表月份
        sbr.manage_no  := sb.manage_no; --管辖公司
        sbr.book_no    := sb.book_no; --表册
        sbr.cbMRBATCH  := bc.READ_BATCH; --抄表批次
        sbr.cbMRRPER   := bc.READ_PER; --抄表员
        sbr.cbmrrorder := sb.sbrorder; --抄表次序号
      
        sbr.YHID := yh.yhid; --用户编号
      
        sbr.sbid := sb.sbid; --水表编号
      
        sbr.TRADE_NO          := sb.TRADE_NO; --行业分类
        sbr.SBPID             := sb.sbpid; --上级水表
        sbr.CBMRMCLASS        := sb.sbclass; --水表级次
        sbr.CBMRMFLAG         := sb.sbflag; --末级标志
        sbr.CBMRCREADATE      := sysdate; --创建日期
        sbr.CBMRINPUTDATE     := null; --编辑日期
        sbr.CBMRREADOK        := 'N'; --抄见标志
        sbr.CBMRRDATE         := null; --抄表日期
        sbr.cbmrprdate        := sb.sbrecdate; --上次抄见日期(取上次有效抄表日期)
        sbr.cbmrscode         := sb.sbrcode; --上期抄见
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --上期抄见char
        sbr.cbmrecode         := null; --本期抄见
        sbr.cbmrsl            := null; --本期水量
        sbr.cbmrface          := null; --表况
        sbr.cbmrifsubmit      := 'Y'; --是否提交计费
        sbr.cbmrifhalt        := 'N'; --系统停算
        sbr.cbmrdatasource    := 1; --抄表结果来源
        sbr.cbmrifignoreminsl := 'Y'; --停算最低抄量
        sbr.cbmrpdardate      := null; --抄表机抄表时间
        sbr.cbmroutflag       := 'N'; --发出到抄表机标志
        sbr.cbmroutid         := null; --发出到抄表机流水号
        sbr.cbmroutdate       := null; --发出到抄表机日期
        sbr.cbmrinorder       := null; --抄表机接收次序
        sbr.cbmrindate        := null; --抄表机接受日期
        sbr.cbmrrpid          := sb.sbrpid; --计件类型
        sbr.CBMRMEMO          := null; --抄表备注
        sbr.cbmrifgu          := 'N'; --估表标志
        sbr.cbmrifrec         := 'N'; --已计费
        sbr.cbmrrecdate       := null; --计费日期
        sbr.cbmrrecsl         := null; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(sbr.cbmrid , --抄表流水
                         sb.sbid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --余量   */
        sbr.cbmraddsl         := 0; --余量
        sbr.cbmrcarrysl       := null; --进位水量
        sbr.cbmrctrl1         := null; --抄表机控制位1
        sbr.cbmrctrl2         := null; --抄表机控制位2
        sbr.cbmrctrl3         := null; --抄表机控制位3
        sbr.cbmrctrl4         := null; --抄表机控制位4
        sbr.cbmrctrl5         := null; --抄表机控制位5
        sbr.cbmrchkflag       := 'N'; --复核标志
        sbr.cbmrchkdate       := null; --复核日期
        sbr.cbmrchkper        := null; --复核人员
        sbr.cbmrchkscode      := null; --原起数
        sbr.cbmrchkecode      := null; --原止数
        sbr.cbmrchksl         := null; --原水量
        sbr.cbmrchkaddsl      := null; --原余量
        sbr.cbmrchkcarrysl    := null; --原进位水量
        sbr.cbmrchkrdate      := null; --原抄见日期
        sbr.cbmrchkface       := null; --原表况
        sbr.cbmrchkresult     := null; --检查结果类型
        sbr.cbmrchkresultmemo := null; --检查结果说明
        sbr.cbmrprimid        := sb.sbpriid; --合收表主表
        sbr.cbmrprimflag      := sb.sbpriflag; --  合收表标志
        sbr.cbmrlb            := sb.sblb; -- 水表类别
        sbr.cbmrnewflag       := sb.sbnewflag; -- 新表标志
        sbr.cbmrface2         := null; --抄见故障
        sbr.cbmrface3         := null; --非常计量
        sbr.cbmrface4         := null; --表井设施说明
      
        sbr.cbMRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        sbr.cbmrprivilegeper  := null; --特权操作人
        sbr.cbmrprivilegememo := null; --特权操作备注
        sbr.AREA_NO           := sb.AREA_NO; --管理区域
        sbr.cbmriftrans       := 'N'; --转单标志
        sbr.cbmrrequisition   := 0; --通知单打印次数
        sbr.cbmrifchk         := sb.sbifchk; --考核表标志
        sbr.cbmrinputper      := null; --入账人员
        sbr.PRICE_NO          := sb.PRICE_NO; --用水类别
        sbr.cbmrcaliber       := md.mdcaliber; --口径
        sbr.cbmrside          := sb.sbside; --表位
        sbr.cbmrmtype         := sb.sbtype; --表型
      
        sbr.cbmrplansl   := 0; --计划水量
        sbr.cbmrplanje01 := 0; --计划水费
        sbr.CBMRPLANJE02 := 0; --计划污水处理费
        sbr.cbmrplanje03 := 0; --计划水资源费
      
        --上次水费   至  去年度次均量
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl,
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);
      
        insert into ys_cb_mtread VALUES sbr;
      
        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;
  
    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  /*
  均量（费）算法
  1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数
  
  【meterread/meterreadhis】均量记录结构
  mrthreesl   number(10)    前n次均量
  mrthreeje01 number(13,3)  前n次均水费
  mrthreeje02 number(13,3)  前n次均污水费
  mrthreeje03 number(13,3)  前n次均水资源费
  
  mrlastsl    number(10)    上次水量
  mrlastje01  number(13,3)  上次水费
  mrlastje02  number(13,3)  上次污水费
  mrlastje03  number(13,3)  上次水资源费
  
  mryearsl    number(10)    去年同期水量
  mryearje01  number(13,3)  去年同期水费
  mryearje02  number(13,3)  去年同期污水费
  mryearje03  number(13,3)  去年同期水资源费
  
  mrlastyearsl    number(10)    去年度次均量
  mrlastyearje01  number(13,3)  去年度次均水费
  mrlastyearje02  number(13,3)  去年度次均污水费
  mrlastyearje03  number(13,3)  去年度次均水资源费
  */
  procedure getmrhis(p_sbid   in varchar2,
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
                     o_je03_4 out number) is
    cursor c_mrh(v_sbid ys_cb_mtreadhis.sbid%type) is
      select nvl(cbmrsl, 0),
             nvl(cbmrrecje01, 0),
             nvl(cbmrrecje02, 0),
             nvl(cbmrrecje03, 0),
             cbmrmonth
        from ys_cb_mtreadhis
       where sbid = v_sbid
            /*and mrsl > 0*/
         and (cbmrdatasource <> '9' or cbmrdatasource is null)
       order by cbmrrdate desc;
  
    mrh ys_cb_mtreadhis%rowtype;
    n1  integer := 0;
    n2  integer := 0;
    n3  integer := 0;
    n4  integer := 0;
  begin
    open c_mrh(p_sbid);
    loop
      fetch c_mrh
        into mrh.cbmrsl,
             mrh.cbmrrecje01,
             mrh.cbmrrecje02,
             mrh.cbmrrecje03,
             mrh.cbmrmonth;
      exit when c_mrh%notfound is null or c_mrh%notfound or(n1 > 12 and
                                                            n2 > 1 and
                                                            n3 > 1 and
                                                            n4 > 12);
      if mrh.cbmrsl > 0 and n1 <= 12 then
        n1                := n1 + 1;
        mrh.cbmrthreesl   := nvl(mrh.cbmrthreesl, 0) + mrh.cbmrsl; --前n次均量
        mrh.cbmrthreeje01 := nvl(mrh.cbmrthreeje01, 0) + mrh.cbmrrecje01; --前n次均水费
        mrh.cbmrthreeje02 := nvl(mrh.cbmrthreeje02, 0) + mrh.cbmrrecje02; --前n次均污水费
        mrh.cbmrthreeje03 := nvl(mrh.cbmrthreeje03, 0) + mrh.cbmrrecje03; --前n次均水资源费
      end if;
    
      if c_mrh%rowcount = 1 then
        n2               := n2 + 1;
        mrh.cbmrlastsl   := nvl(mrh.cbmrlastsl, 0) + mrh.cbmrsl; --上次水量
        mrh.cbmrlastje01 := nvl(mrh.cbmrlastje01, 0) + mrh.cbmrrecje01; --上次水费
        mrh.cbmrlastje02 := nvl(mrh.cbmrlastje02, 0) + mrh.cbmrrecje02; --上次污水费
        mrh.cbmrlastje03 := nvl(mrh.cbmrlastje03, 0) + mrh.cbmrrecje03; --上次水资源费
      end if;
    
      if mrh.cbmrmonth = to_char(to_number(substr(p_month, 1, 4)) - 1) || '.' ||
         substr(p_month, 6, 2) then
        n3               := n3 + 1;
        mrh.cbmryearsl   := nvl(mrh.cbmryearsl, 0) + mrh.cbmrsl; --去年同期水量
        mrh.cbmryearje01 := nvl(mrh.cbmryearje01, 0) + mrh.cbmrrecje01; --去年同期水费
        mrh.cbmryearje02 := nvl(mrh.cbmryearje02, 0) + mrh.cbmrrecje02; --去年同期污水费
        mrh.cbmryearje03 := nvl(mrh.cbmryearje03, 0) + mrh.cbmrrecje03; --去年同期水资源费
      end if;
    
      if mrh.cbmrsl > 0 and to_number(substr(mrh.cbmrmonth, 1, 4)) =
         to_number(substr(p_month, 1, 4)) - 1 then
        n4                   := n4 + 1;
        mrh.cbmrlastyearsl   := nvl(mrh.cbmrlastyearsl, 0) + mrh.cbmrsl; --去年度次均量
        mrh.cbmrlastyearje01 := nvl(mrh.cbmrlastyearje01, 0) +
                                mrh.cbmrrecje01; --去年度次均水费
        mrh.cbmrlastyearje02 := nvl(mrh.cbmrlastyearje02, 0) +
                                mrh.cbmrrecje02; --去年度次均污水费
        mrh.cbmrlastyearje03 := nvl(mrh.cbmrlastyearje03, 0) +
                                mrh.cbmrrecje03; --去年度次均水资源费
      end if;
    end loop;
  
    o_sl_1 := (case
                when n1 = 0 then
                 0
                else
                 round(mrh.cbmrthreesl / n1, 0)
              end);
    o_je01_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje01 / n1, 3)
                end);
    o_je02_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje02 / n1, 3)
                end);
    o_je03_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje03 / n1, 3)
                end);
  
    o_sl_2 := (case
                when n2 = 0 then
                 0
                else
                 round(mrh.cbmrlastsl / n2, 0)
              end);
    o_je01_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje01 / n2, 3)
                end);
    o_je02_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje02 / n2, 3)
                end);
    o_je03_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje03 / n2, 3)
                end);
  
    o_sl_3 := (case
                when n3 = 0 then
                 0
                else
                 round(mrh.cbmryearsl / n3, 0)
              end);
    o_je01_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje01 / n3, 3)
                end);
    o_je02_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje02 / n3, 3)
                end);
    o_je03_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje03 / n3, 3)
                end);
  
    o_sl_4 := (case
                when n4 = 0 then
                 0
                else
                 round(mrh.cbmrlastyearsl / n4, 0)
              end);
    o_je01_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje01 / n4, 3)
                end);
    o_je02_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje02 / n4, 3)
                end);
    o_je03_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje03 / n4, 3)
                end);
  exception
    when others then
      if c_mrh%isopen then
        close c_mrh;
      end if;
  end getmrhis;

  -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  PROCEDURE month_over(p_HIRE_CODE in varchar2,
                       P_ID        IN VARCHAR2,
                       P_MONTH     IN VARCHAR2,
                       P_PER       IN VARCHAR2,
                       P_COMMIT    IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := fobtmanapara(P_ID, 'READ_MONTH');
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '手工账务月结月份异常,请检查!');
    END IF;
  
    update BAS_MANA_PARA
       set CONTENT = TO_CHAR(ADD_MONTHS(TO_DATE(CONTENT, 'yyyy.mm'), 1),
                             'yyyy.mm')
     WHERE MANAGE_NO = P_ID
       AND PARAMETER_NO = 'READ_MONTH'
       and HIRE_CODE = p_HIRE_CODE;
  
    INSERT INTO ys_cb_mtreadhis
      (SELECT *
         FROM ys_cb_mtread T
        WHERE T.HIRE_CODE = P_HIRE_CODE
          and MANAGE_NO = p_id
          AND T.CBMRMONTH = P_MONTH);
  
    --删除当前抄表库信息
    DELETE ys_cb_mtread T
     WHERE T.HIRE_CODE = P_HIRE_CODE
       and MANAGE_NO = p_id
       AND T.CBMRMONTH = P_MONTH;
    --
  
    --提交标志
    IF P_COMMIT = '1' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结失败' || SQLERRM);
  END;

  -- 手工账务月结处理
  --p_HIRE_CODE  租户
  --P_ID 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志 
  PROCEDURE month_over_all(p_HIRE_CODE in varchar2,
                           P_ID        IN VARCHAR2,
                           P_MONTH     IN VARCHAR2,
                           P_PER       IN VARCHAR2,
                           P_COMMIT    IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    for i in (select *
                from BAS_MANA_FRAME t
               where hire_code = 'kings'
                 and manage_no like '02%'
                 and last_mark = '1'
                 and (manage_no = P_ID or P_ID = 'ALL')) loop
      month_over(p_HIRE_CODE, I.MANAGE_NO, P_MONTH, P_PER, P_COMMIT);
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结失败' || SQLERRM);
  END;

  PROCEDURE cb_delete(p_HIRE_CODE in varchar2,
                      p_MANAGE_NO in varchar2,
                      P_book_no   IN VARCHAR2,
                      P_MONTH     IN VARCHAR2,
                      p_sbid      in varchar2,
                      P_PER       IN VARCHAR2,
                      P_COMMIT    IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
    cb          ys_cb_mtread%ROWTYPE;
  BEGIN
  
    if p_sbid = 'ALL' THEN
    
      SELECT COUNT(*)
        INTO V_COUNT
        FROM YS_CB_MTREAD
       WHERE HIRE_CODE = p_HIRE_CODE
         AND CBMRMONTH = P_MONTH
         and MANAGE_NO = p_MANAGE_NO
         AND SBID = P_SBID;
      IF V_COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '未有抄表计划，不用取消');
      ELSE
        SELECT *
          into cb
          FROM YS_CB_MTREAD
         WHERE HIRE_CODE = p_HIRE_CODE
           AND CBMRMONTH = P_MONTH
           and MANAGE_NO = p_MANAGE_NO
           AND SBID = P_SBID;
        if cb.cbmrreadok = 'Y' then
          RAISE_APPLICATION_ERROR(ERRCODE, '已抄表，不用取消');
        end if;
        delete YS_CB_MTREAD
         WHERE HIRE_CODE = p_HIRE_CODE
           AND CBMRMONTH = P_MONTH
           and MANAGE_NO = p_MANAGE_NO
           AND SBID = P_SBID;
      END IF;
    
    ELSE
       SELECT COUNT(*)
        INTO V_COUNT
        FROM YS_CB_MTREAD
       WHERE HIRE_CODE = p_HIRE_CODE
         AND CBMRMONTH = P_MONTH
         and MANAGE_NO = p_MANAGE_NO
         AND book_no  = P_book_no;
      IF V_COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '未有抄表计划，不用取消');
      ELSE
          SELECT COUNT(*)
        INTO V_COUNT
        FROM YS_CB_MTREAD
       WHERE HIRE_CODE = p_HIRE_CODE
         AND CBMRMONTH = P_MONTH
         and MANAGE_NO = p_MANAGE_NO
         AND book_no  = P_book_no
         and cbmrreadok = 'Y';
         if V_COUNT > 0 then 
            RAISE_APPLICATION_ERROR(ERRCODE, '已抄表，不用取消');
         end if;
         delete YS_CB_MTREAD
       WHERE HIRE_CODE = p_HIRE_CODE
         AND CBMRMONTH = P_MONTH
         and MANAGE_NO = p_MANAGE_NO
         AND book_no  = P_book_no;
         update ys_bas_book k
       set READ_NMONTH =  P_MONTH
     where MANAGE_NO = p_MANAGE_NO
       and BOOK_NO = p_BOOK_NO
       and hire_code = p_HIRE_CODE;
      end if;
    END IF;
    if P_COMMIT = '1' then
       commit;
    end if ;
    
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(ERRCODE, '取消抄表计划失败' || SQLERRM);
  END;
end;
/

prompt
prompt Creating package body PG_CB_COST
prompt ================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_CB_COST IS

  总表截量     VARCHAR2(10);
  最低算费水量 NUMBER(10);
  
  
  
  --提供外部批量调用
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2) IS
    CURSOR C_MR(VBFID IN VARCHAR2, VSMFID IN VARCHAR2) IS
      SELECT YCM.ID
        FROM YS_CB_MTREAD YCM, YS_YH_SBINFO YYS
       WHERE YCM.SBID = YYS.SBID
         AND YCM.BOOK_NO = VBFID
         AND YCM.MANAGE_NO = VSMFID
         AND CBMRIFREC = 'N' --未计费
         AND CBMRREADOK = 'Y' --抄见
       ORDER BY SBCLASS DESC,
                (CASE
                  WHEN SBPRIFLAG = 'Y' AND SBPRIID <> SBCODE THEN
                   1
                  ELSE
                   2
                END) ASC;
    --游标中不共享资源，解锁前资源不能被更新并且不等待并抛出异常
  
    VMRID  YS_CB_MTREAD.ID%TYPE;
    VBFID  YS_CB_MTREAD.BOOK_NO%TYPE;
    VSMFID YS_CB_MTREAD.MANAGE_NO%TYPE;
  BEGIN
  
    FOR I IN 1 .. FBOUNDPARA(P_BFID) LOOP
      VBFID  := FGETPARA(P_BFID, I, 1);
      VSMFID := FGETPARA(P_BFID, I, 2);
      OPEN C_MR(VBFID, VSMFID);
      LOOP
        FETCH C_MR
          INTO VMRID;
        EXIT WHEN C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL;
        --单条抄表记录处理
        BEGIN
          COSTCULATE(VMRID, 提交);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
      END LOOP;
      CLOSE C_MR;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  
  
  
  --计划抄表单笔算费-按抄表流水
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER) IS
    CURSOR C_MR IS
      SELECT *
        FROM YS_CB_MTREAD
       WHERE ID = P_MRID
         AND CBMRIFREC = 'N'
         AND CBMRREADOK = 'Y' --抄见
         AND CBMRSL >= 0
         FOR UPDATE NOWAIT;
  
    --合收子表抄表记录
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT CBMRSL, CBMRIFREC, YCM.SBID
        FROM YS_YH_SBINFO YYS, YS_CB_MTREAD YCM
       WHERE YYS.SBID = YCM.SBID
         AND SBPRIFLAG = 'Y'
         AND SBPRIID = P_PRIMCODE
         AND YYS.SBID <> P_PRIMCODE;
  
    --取合收表信息
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT SBPRIFLAG,
             SBPRIID,
             SBRPID,
             SBCLASS,
             SBIFCHARGE,
             SBIFSL,
             SBLB,
             SBSTATUS,
             SBIFCHK
        FROM YS_YH_SBINFO
       WHERE SBID = P_MID;
  
    MR         YS_CB_MTREAD%ROWTYPE;
    MRCHILD    YS_CB_MTREAD%ROWTYPE;
    MRPRICHILD YS_CB_MTREAD%ROWTYPE;
    MI         YS_YH_SBINFO%ROWTYPE;
    MRL        YS_CB_MTREAD%ROWTYPE;
    --MD         METERTRANSDT%ROWTYPE;
    V_COUNT  NUMBER;
    V_COUNT1 NUMBER;
    V_MRSL   YS_CB_MTREAD.CBMRSL%TYPE;
    VPID     VARCHAR2(10);
    V_MMTYPE VARCHAR2(10);
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '抄表流水号:' || P_MRID || '无效的抄表计划流水号，或不符合计费条件');
    END IF;
    MR.CBMRCHKSL := MR.CBMRSL;
  
    --水表记录
    OPEN C_MI(MR.SBID);
    FETCH C_MI
      INTO MI.SBPRIFLAG,
           MI.SBPRIID,
           MI.SBRPID,
           MI.SBCLASS,
           MI.SBIFCHARGE,
           MI.SBIFSL,
           MI.SBLB,
           MI.SBSTATUS,
           MI.SBIFCHK;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    CLOSE C_MI;
  
    MR.CBMRRECSL := MR.CBMRSL;
    IF MR.CBMRSL > 0 AND MR.CBMRSL < 最低算费水量 AND
       MR.CBMRDATASOURCE IN ('1', '5', '9') THEN
      MR.CBMRIFREC   := 'Y';
      MR.CBMRRECDATE := TRUNC(SYSDATE);
      MR.CBMRMEMO    := MR.CBMRMEMO || ',' || 最低算费水量 || '吨以下不计费';
    ELSIF 总表截量 = 'Y' THEN
      --查找是否有多级表关系 预留
    
      --计费核心----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = 调试) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, 计划抄表, '0', P_COMMIT); --均已当前水价进行计费，水价版本号默认0，后续可扩展
      END IF;
      --推止码------------------------------------------------------------
      IF P_COMMIT != 调试 THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --取本期水量（抄量）
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    ELSE
      --计费核心----------------------------------------------------------
      IF MR.CBMRIFREC = 'N' AND (MR.CBMRIFSUBMIT = 'Y' OR P_COMMIT = 调试) AND
         MI.SBIFCHARGE = 'Y' THEN
        COSTCULATECORE(MR, 计划抄表, '0', P_COMMIT); --均已当前水价进行计费，水价版本号默认0，后续可扩展
      END IF;
      --推止码------------------------------------------------------------
      IF P_COMMIT != 调试 AND MR.CBMRIFREC = 'Y' THEN
        UPDATE YS_YH_SBINFO
           SET SBRCODE     = MR.CBMRECODE,
               SBRECDATE   = MR.CBMRRDATE,
               SBRECSL     = MR.CBMRSL, --取本期水量（抄量）
               SBFACE      = MR.CBMRFACE,
               SBNEWFLAG   = 'N',
               SBRCODECHAR = MR.CBMRECODECHAR
         WHERE SBID = MR.SBID;
      END IF;
    END IF;
    --更新当前抄表记录、反馈最后计费信息
    IF P_COMMIT != 调试 AND MR.CBMRIFREC = 'Y' THEN
      UPDATE YS_CB_MTREAD
         SET CBMRIFREC   = MR.CBMRIFREC,
             CBMRRECDATE = MR.CBMRRECDATE,
             CBMRRECSL   = MR.CBMRRECSL,
             CBMRRECJE01 = MR.CBMRRECJE01,
             CBMRRECJE02 = MR.CBMRRECJE02,
             CBMRRECJE03 = MR.CBMRRECJE03,
             CBMRRECJE04 = MR.CBMRRECJE04,
             CBMRMEMO    = MR.CBMRMEMO
       WHERE CURRENT OF C_MR;
    
    ELSE
      UPDATE YS_CB_MTREAD
         SET CBMRRECJE01 = MR.CBMRRECJE01,
             CBMRRECJE02 = MR.CBMRRECJE02,
             CBMRRECJE03 = MR.CBMRRECJE03,
             CBMRRECJE04 = MR.CBMRRECJE04,
             CBMRMEMO    = MR.CBMRMEMO,
             CBMRRECDATE = MR.CBMRRECDATE,
             CBMRRECSL   = MR.CBMRRECSL
       WHERE CURRENT OF C_MR;
    END IF;
    --2、提交处理
    BEGIN
      CLOSE C_MR;
      IF P_COMMIT = 调试 THEN
        NULL;
        --rollback;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MR_PRI%ISOPEN THEN
        CLOSE C_MR_PRI;
      END IF;
      IF C_MR%ISOPEN THEN
        CLOSE C_MR;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END COSTCULATE;
  --单笔算费核心
  PROCEDURE COSTCULATECORE(MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                           P_TRANS  IN CHAR,
                           P_PSCID  IN VARCHAR2,
                           P_COMMIT IN NUMBER) IS
    CURSOR C_MI(VMIID IN YS_YH_SBINFO.SBID%TYPE) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID;
  
    CURSOR C_CI(VCIID IN YS_YH_CUSTINFO.YHID%TYPE) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID;
  
    CURSOR C_MD(VMIID IN YS_YH_SBDOC.SBID%TYPE) IS
      SELECT * FROM YS_YH_SBDOC WHERE SBID = VMIID;
  
    CURSOR C_MA(VMIID IN YS_YH_ACCOUNT.SBID%TYPE) IS
      SELECT * FROM YS_YH_ACCOUNT WHERE SBID = VMIID;
  
    CURSOR C_VER IS
      SELECT *
        FROM (SELECT MAX(PRICE_VER) ID, TO_DATE('99991231', 'yyyymmdd')
                FROM bas_price_name)
       ORDER BY ID DESC;
    V_VERID BAS_PRICE_VERSION.ID%TYPE;
    V_ODATE DATE;
    V_RDATE DATE;
    V_SL    NUMBER;
  
    --混合用水先定量再定比
    CURSOR C_PMD(VPSCID IN NUMBER, VMID IN ys_yh_pricegroup.SBID%TYPE) IS
      SELECT *
        FROM (SELECT * FROM ys_yh_pricegroup WHERE SBID = VMID)
       ORDER BY GRPTYPE DESC, GRPID; --按维护先后顺序
  
    PMD YS_YH_PRICEGROUP%ROWTYPE;
  
    --价格体系
    CURSOR C_PD(VPSCID IN NUMBER, VPFID IN BAS_PRICE_DETAIL.PRICE_NO%TYPE) IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_DETAIL T
               WHERE PRICE_VER = VPSCID
                 AND PRICE_NO = VPFID)
       ORDER BY PRICE_VER DESC, PRICE_ITEM ASC;
    PD BAS_PRICE_DETAIL%ROWTYPE;
  
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.ITEM_TYPE, 1) FROM BAS_PRICE_ITEM T;
  
    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM BAS_PRICE_ITEM T WHERE T.ITEM_TYPE = VPIGROUP;
  
    MI        YS_YH_SBINFO%ROWTYPE;
    CI        YS_YH_CUSTINFO%ROWTYPE;
    MD        YS_YH_SBDOC%ROWTYPE;
    MA        YS_YH_ACCOUNT%ROWTYPE;
    RL        YS_ZW_ARLIST%ROWTYPE;
    BF        YS_BAS_BOOK%ROWTYPE;
    MAXPMDID  NUMBER;
    PMNUM     NUMBER;
    TEMPSL    NUMBER;
    V_PMDSL   NUMBER;
    V_PMDDBSL NUMBER;
    RLVER     YS_ZW_ARLIST%ROWTYPE;
    RLTAB     RL_TABLE;
    RDTAB     RD_TABLE;
    N         NUMBER;
    M         NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法
  
    I   NUMBER;
    VRD YS_ZW_ARDETAIL%ROWTYPE;
  
  BEGIN
    --锁定水表记录
    OPEN C_MI(MR.SBID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.SBID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.SBID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.SBID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.SBID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.SBID);
    END IF;
    --如果是计费调整按工单水价进行计费
    IF MR.ID = '?' OR P_TRANS = 'O' THEN
      MI.PRICE_NO := MR.PRICE_NO;
    END IF;
    /*------------------增加年阶梯校验-------------------
    IF 是否含年阶梯水价(MI.SBID) = 'Y' AND MI.SBYEARDATE IS NULL THEN
      MI.SBYEARSL := 0; --年累计量
      MI.SBYEARDATE := TRUNC(SYSDATE, 'YYYY'); --年阶梯起算日
      UPDATE YS_YH_SBINFO
         SET SBYEARSL = MI.SBYEARSL, SBYEARDATE = MI.SBYEARDATE
       WHERE SBID = MI.SBID;
    END IF;
    ------------------增加年阶梯校验-------------------*/
  
    --非计费表执行空过程，不抛异常
    --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    BEGIN
      SELECT SYS_GUID() INTO RL.ID FROM DUAL;
      RL.HIRE_CODE     := MI.HIRE_CODE;
      RL.ARID          := LPAD(SEQ_ARID.NEXTVAL,10,'0');
      RL.MANAGE_NO     := MI.MANAGE_NO;
      RL.ARMONTH       := Fobtmanapara(RL.MANAGE_NO, 'READ_MONTH');
      RL.ARDATE        := TRUNC(SYSDATE);
      RL.YHID          := MR.YHID;
      RL.SBID          := MR.SBID;
      RL.ARCHARGEPER   := MI.SBCPER;
      RL.ARCPID        := CI.YHPID;
      RL.ARCCLASS      := CI.YHCLASS;
      RL.ARCFLAG       := CI.YHFLAG;
      RL.ARUSENUM      := MI.SBUSENUM;
      RL.ARCNAME       := CI.YHNAME;
      RL.ARCNAME2      := CI.YHNAME2;
      RL.ARCADR        := CI.YHADR;
      RL.ARMINAME      := MI.SBNAME;
      RL.ARMADR        := MI.SBADR;
      RL.ARCSTATUS     := CI.YHSTATUS;
      RL.ARMTEL        := CI.YHMTEL;
      RL.ARTEL         := CI.YHTEL1;
      RL.ARBANKID      := MA.YHABANKID;
      RL.ARTSBANKID    := MA.YHATSBANKID;
      RL.ARACCOUNTNO   := MA.YHAACCOUNTNO;
      RL.ARACCOUNTNAME := MA.YHAACCOUNTNAME;
      RL.ARIFTAX       := MI.SBIFTAX;
      RL.ARTAXNO       := MI.SBTAXNO;
      RL.ARIFINV       := CI.YHIFINV; --开票标志
      RL.ARMCODE       := MI.SBCODE;
      RL.ARMPID        := MI.SBPID;
      RL.ARMCLASS      := MI.SBCLASS;
      RL.ARMFLAG       := MI.SBFLAG;
      RL.ARDAY         := MR.CBMRDAY;
      RL.ARBFID        := MI.BOOK_NO; --
      --分段算法要求上期抄表日期和本期抄表日期非空
      RL.ARPRDATE := NVL(NVL(NVL(MR.CBMRPRDATE, MI.SBINSDATE), MI.SBNEWDATE),
                         TRUNC(SYSDATE));
      RL.ARRDATE  := NVL(NVL(MR.CBMRRDATE, TRUNC(MR.CBMRINPUTDATE)),
                         TRUNC(SYSDATE));
    
      --违约金起算日期（注意同步修改营业外收入审核）
      /*A  当月定日起算
      B  下月定日起算
      C  计费日起算*/
      /*BEGIN
        SELECT * INTO BL FROM BREACHLIST;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF BL.BLMETHOD = 'A' THEN
        RL.RLZNDATE := FIRST_DAY(RL.RLDATE) + BL.BLTCOUNT - 1;
      ELSIF BL.BLMETHOD = 'B' THEN
        RL.RLZNDATE := FIRST_DAY(ADD_MONTHS(RL.RLDATE, 1)) + BL.BLTCOUNT - 1;
      ELSIF BL.BLMETHOD = 'C' THEN
        RL.RLZNDATE := RL.RLDATE + NVL(BL.BLTCOUNT, 30);
      ELSE
        RL.RLZNDATE := FIRST_DAY(ADD_MONTHS(RL.RLDATE, 1));
      END IF;*/
      RL.ARZNDATE       := RL.ARDATE + 30;
      RL.ARCALIBER      := MD.MDCALIBER;
      RL.ARRTID         := MI.SBRTID;
      RL.ARMSTATUS      := MI.SBSTATUS;
      RL.ARMTYPE        := MI.SBTYPE;
      RL.ARMNO          := MD.MDNO;
      RL.ARSCODE        := MR.CBMRSCODE;
      RL.ARECODE        := MR.CBMRECODE;
      RL.ARREADSL       := MR.CBMRSL; --变量暂存，最后恢复
      RL.ARINVMEMO := CASE
                        WHEN NOT (P_PSCID = '0000.00' OR P_PSCID IS NULL) THEN
                         '[' || P_PSCID || ']历史单价'
                        ELSE
                         ''
                      END;
      RL.ARENTRUSTBATCH := NULL;
      RL.ARENTRUSTSEQNO := NULL;
      RL.AROUTFLAG      := 'N';
      RL.ARTRANS        := P_TRANS;
      RL.ARCD           := DEBIT;
      RL.ARYSCHARGETYPE := MI.SBCHARGETYPE;
      RL.ARSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.ARJE           := 0; --生成帐体后计算,先初始化
      RL.ARADDSL        := NVL(MR.CBMRADDSL, 0);
      RL.ARPAIDJE       := 0;
      RL.ARPAIDFLAG     := 'N';
      RL.ARPAIDPER      := NULL;
      RL.ARPAIDDATE     := NULL;
      RL.ARMRID         := MR.ID;
      RL.ARMEMO         := MR.CBMRMEMO;
      RL.ARZNJ          := 0;
      RL.ARLB           := MI.SBLB;
      RL.ARPFID         := MI.PRICE_NO;
      RL.ARDATETIME     := SYSDATE;
      RL.ARPRIMCODE     := MI.SBPRIID; --记录合收子表串
      RL.ARPRIFLAG      := MI.SBPRIFLAG;
      RL.ARRPER         := MR.CBMRRPER;
      RL.ARSCODECHAR    := MR.CBMRSCODE;
      RL.ARECODECHAR    := MR.CBMRECODE;
      RL.ARGROUP        := '1'; --应收帐分组
      RL.ARPID          := NULL; --实收流水（与payment.pid对应）
      RL.ARPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.ARSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.ARSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.ARSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.ARREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.ARBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.ARZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.ARSXF          := 0; --手续费
      RL.ARMIFACE2      := MI.SBFACE2; --抄见故障
      RL.ARMIFACE3      := MI.SBFACE3; --非常计量
      RL.ARMIFACE4      := MI.SBFACE4; --表井设施说明
      RL.ARMIIFCKF      := MI.SBIFCHK; --垃圾费户数
      RL.ARMIGPS        := MI.SBGPS; --是否合票
      RL.ARMIQFH        := MI.SBQFH; --铅封号
      RL.ARMIBOX        := MI.SBBOX; --消防水价（增值税水价）
      RL.ARMINAME2      := MI.SBNAME2; --招牌名称(小区名）
      RL.ARMISEQNO      := MI.SBSEQNO; --户号（初始化时册号+序号）
      RL.ARSCRARID      := RL.ARID; --原应收帐流水
      RL.ARSCRARTRANS   := RL.ARTRANS; --原应收帐事务
      RL.ARSCRARMONTH   := RL.ARMONTH; --原应收帐月份
      RL.ARSCRARDATE    := RL.ARDATE; --原应收帐日期
    
      IF (MR.CBMRNEWFLAG = 'Y' AND (MR.ID = '?' OR P_TRANS = 'O')) THEN
        --应收追补勾选不计阶梯标志
        CLASSCTL := 'Y';
      ELSE
        CLASSCTL := 'N';
      END IF;
    
      BEGIN
        SELECT NVL(SUM(ARDJE), 0)
          INTO RL.ARPRIORJE
          FROM YS_ZW_ARLIST, YS_ZW_ARDETAIL
         WHERE ARID = ARDID
           AND ARREVERSEFLAG = 'N'
           AND ARPAIDFLAG = 'N'
           AND ARJE > 0
           AND SBID = MI.SBID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.ARPRIORJE := 0; --算费之前欠费
      END;
      RL.ARMISAVING := MI.SBSAVING; --算费时预存
      /*END IF;*/
      RL.ARMICOMMUNITY   := MI.SBCOMMUNITY;
      RL.ARMIREMOTENO    := MI.SBREMOTENO;
      RL.ARMIREMOTEHUBNO := MI.SBREMOTEHUBNO;
      RL.ARMIEMAIL       := MI.SBEMAIL;
      RL.ARMIEMAILFLAG   := MI.SBEMAILFLAG;
      RL.ARMICOLUMN1     := P_PSCID;
      RL.ARMICOLUMN2     := NULL;
      RL.ARMICOLUMN3     := NULL;
      RL.ARMICOLUMN4     := NULL;
      RL.ARCOLUMN5       := NULL; --上次应帐帐日期
      RL.ARCOLUMN9       := NULL; --上次应收帐流水
      RL.ARCOLUMN10      := NULL; --上次应收帐月份
      RL.ARCOLUMN11      := NULL; --上次应收帐事务
    END;
    --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
  
    --0、‘按归档价格系分段’或‘指定价格系’前置数据集准备
    IF P_PSCID IS NOT NULL THEN
      --指定价格系
      IF P_PSCID = 0 THEN
        SELECT MAX(PRICE_VER) INTO RL.ARMICOLUMN1 FROM BAS_PRICE_NAME;
      END IF;
      RLTAB := RL_TABLE(RL);
    ELSE
      --分段
      OPEN C_VER;
      FETCH C_VER
        INTO V_VERID, V_ODATE;
      IF C_VER%NOTFOUND OR C_VER%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无法获取有效的价格系1');
      END IF;
      WHILE C_VER%FOUND LOOP
        IF V_ODATE >= RL.ARPRDATE AND
           (RLVER.ARRDATE IS NULL OR RLVER.ARRDATE < RL.ARRDATE) THEN
          RLVER := RL;
          ---------------------
          RLVER.ARPRDATE := CASE
                              WHEN V_RDATE IS NULL THEN
                               RL.ARPRDATE
                              ELSE
                               V_RDATE
                            END;
          RLVER.ARRDATE := CASE
                             WHEN RL.ARRDATE <= V_ODATE THEN
                              RL.ARRDATE
                             ELSE
                              V_ODATE
                           END;
          RLVER.ARREADSL := ROUND(RLVER.ARREADSL * CASE
                                    WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                     1
                                    ELSE
                                     (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                     (RL.ARRDATE - RL.ARPRDATE)
                                  END,
                                  0);
          RLVER.ARADDSL := ROUND(RLVER.ARADDSL * CASE
                                   WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                    1
                                   ELSE
                                    (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                    (RL.ARRDATE - RL.ARPRDATE)
                                 END,
                                 0);
          RLVER.ARSL := ROUND(RLVER.ARSL * CASE
                                WHEN (RL.ARRDATE - RL.ARPRDATE) = 0 THEN
                                 1
                                ELSE
                                 (RLVER.ARRDATE - RLVER.ARPRDATE) /
                                 (RL.ARRDATE - RL.ARPRDATE)
                              END,
                              0);
          V_SL              := NVL(V_SL, 0) + RLVER.ARREADSL;
          RLVER.ARMICOLUMN1 := V_VERID;
          ---------------------
          V_RDATE := RLVER.ARRDATE;
          --插入算费临时分段包
          IF RLTAB IS NULL THEN
            RLTAB := RL_TABLE(RLVER);
          ELSE
            RLTAB.EXTEND;
            RLTAB(RLTAB.LAST) := RLVER;
          END IF;
        END IF;
        FETCH C_VER
          INTO V_VERID, V_ODATE;
      END LOOP;
      RLTAB(RLTAB.LAST).ARREADSL := RLTAB(RLTAB.LAST)
                                    .ARREADSL + (RL.ARREADSL - V_SL);
      CLOSE C_VER;
    END IF;
    IF RLTAB IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无法获取有效的价格系2');
    END IF;
  
    --1、按价格体系（含归档价格）
    FOR I IN RLTAB.FIRST .. RLTAB.LAST LOOP
      RLVER := RLTAB(I);
      OPEN C_PMD(RLVER.ARMICOLUMN1, MI.SBID);
      FETCH C_PMD
        INTO PMD;
      --1.1、单一用水
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
        --1.1.1、非特别单价
        OPEN C_PD(RLVER.ARMICOLUMN1, MI.PRICE_NO);
        LOOP
          FETCH C_PD
            INTO PD;
          EXIT WHEN C_PD%NOTFOUND;
        
          PMD := NULL;
          COSTPIID(P_RL       => RLVER,
                   P_MR       => MR,
                   P_SL       => RLVER.ARREADSL,
                   PD         => PD,
                   PMD        => PMD,
                   RDTAB      => RDTAB,
                   P_CLASSCTL => CLASSCTL,
                   P_PSCID    => P_PSCID,
                   P_COMMIT   => P_COMMIT);
        
        END LOOP;
        CLOSE C_PD;
        ------------------------------------------------------
        --1.2、混合用水
      ELSE
        SELECT COUNT(GRPID)
          INTO MAXPMDID
          FROM (SELECT * FROM YS_YH_PRICEGROUP WHERE SBID = MI.SBID);
      
        V_PMDSL   := 0; --组分配水量
        PMNUM     := 0;
        V_PMDDBSL := RLVER.ARREADSL; --定比元水量
        TEMPSL    := RLVER.ARREADSL; --分配后剩余水量
      
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP
          PMNUM := PMNUM + 1;
          --拆分余量记入最后费上
          IF PMNUM = MAXPMDID THEN
            V_PMDSL := TEMPSL;
          ELSE
            IF PMD.GRPTYPE = '01' THEN
              --定比混合
              V_PMDSL := CEIL(PMD.GRPSCALE * V_PMDDBSL);
            ELSE
              --定量混合
              V_PMDSL := (CASE
                           WHEN TEMPSL >= TRUNC(PMD.GRPSCALE) THEN
                            TRUNC(PMD.GRPSCALE)
                           ELSE
                            TEMPSL
                         END);
              V_PMDDBSL := V_PMDDBSL - V_PMDSL;
            END IF;
          END IF;
        
          --此处按基本价格类别正常计费--------------------------
          OPEN C_PD(RLVER.ARMICOLUMN1, PMD.PRICE_NO);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            COSTPIID(RLVER,
                     MR,
                     V_PMDSL,
                     PD,
                     PMD,
                     RDTAB,
                     CLASSCTL,
                     P_PSCID,
                     P_COMMIT);
          END LOOP;
          CLOSE C_PD;
          ------------------------------------------------------
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - V_PMDSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
    END LOOP;
    --统一重算汇总应收水量、金额到总账上
    RL.ARREADSL := MR.CBMRSL; --还原
    RL.ARSL     := 0;
    RL.ARJE     := 0;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        IF RDTAB(I).ARDPIID = '01' THEN
          RL.ARSL := RL.ARSL + RDTAB(I).ARDSL;
        END IF;
        RL.ARJE := RL.ARJE + RDTAB(I).ARDJE;
      END LOOP;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '无法生成应收帐务明细，可能无用水性质');
    END IF;
    IF P_COMMIT != 调试 THEN
      INSERT INTO YS_ZW_ARLIST VALUES RL;
    ELSE
      INSERT INTO YS_ZW_ARLIST_BUDGET VALUES RL;
      INSERT INTO YS_ZW_ARLIST_virtual VALUES RL;
    END IF;
    INSRD(RDTAB, P_COMMIT);
  
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.CBMRRECSL        := NVL(RL.ARSL, 0);
    MR.CBMRIFREC        := 'Y';
    MR.CBMRRECDATE      := RL.ARDATE;
    MR.CBMRPRIVILEGEPER := RL.ARID; --借字段记录rlid返回，供即时销帐20140507
  
    --为适应抄表录入中的账本小结，这里先初始化为0
    MR.CBMRRECJE01 := 0;
    MR.CBMRRECJE02 := 0;
    MR.CBMRRECJE03 := 0;
    MR.CBMRRECJE04 := 0;
    MR.CBMRRECSL   := 0;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        --反馈总金额到
        CASE VRD.ARDPIID
          WHEN '01' THEN
            MR.CBMRRECJE01 := NVL(MR.CBMRRECJE01, 0) + VRD.ARDJE;
          WHEN '02' THEN
            MR.CBMRRECJE02 := NVL(MR.CBMRRECJE02, 0) + VRD.ARDJE;
          WHEN '03' THEN
            MR.CBMRRECJE03 := NVL(MR.CBMRRECJE03, 0) + VRD.ARDJE;
          WHEN '04' THEN
            MR.CBMRRECJE04 := NVL(MR.CBMRRECJE04, 0) + VRD.ARDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_VER%ISOPEN THEN
        CLOSE C_VER;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --费率明细计算步骤
  PROCEDURE COSTPIID(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                     P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                     P_SL       IN NUMBER,
                     PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                     PMD        IN YS_YH_PRICEGROUP%ROWTYPE,
                     RDTAB      IN OUT RD_TABLE,
                     P_CLASSCTL IN CHAR,
                     P_PSCID    IN NUMBER,
                     P_COMMIT   IN NUMBER) IS
    --p_classctl（Y：强制不使用阶梯计费方法；N：计算阶梯，如果是的话）
    RD        YS_ZW_ARDETAIL%ROWTYPE;
    I         INTEGER;
    V_MONTHS  NUMBER(10);
    N         NUMBER;
    M         NUMBER;
    TEMPADJSL NUMBER(10);
    VPDMETHOD BAS_PRICE_DETAIL.METHOD%TYPE;
    BF        YS_BAS_BOOK%ROWTYPE;
  BEGIN
  
    --不计阶梯控制不进入阶梯子过程，不产生1阶金额
    IF P_CLASSCTL = 'Y' AND PD.METHOD IN ('yjt', 'njt') THEN
      VPDMETHOD := 'dj';
    ELSE
      VPDMETHOD := PD.METHOD;
    END IF;
  
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --计费时段月数
        FROM DUAL;
      IF N <= 0 OR N IS NULL THEN
        N := 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE     := P_RL.HIRE_CODE;
    RD.ARDID         := P_RL.ARID; --流水号
    RD.ARDPMDID      := NVL(PMD.GRPID, 0); --混合用水分组
    RD.ARDPMDSCALE   := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID       := PD.PRICE_ITEM; --费用项目
    RD.ARDPFID       := PD.PRICE_NO; --费率
    RD.ARDPSCID      := PD.PRICE_VER; --费率明细方案
    RD.ARDMETHOD     := VPDMETHOD;
    RD.ARDPAIDFLAG   := 'N';
    RD.ARDYSDJ       := 0;
    RD.ARDYSSL       := 0;
    RD.ARDYSJE       := 0;
    RD.ARDDJ         := 0;
    RD.ARDSL         := 0;
    RD.ARDJE         := 0;
    RD.ARDADJDJ      := 0;
    RD.ARDADJSL      := 0;
    RD.ARDADJJE      := 0;
    RD.ARDMSMFID     := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH      := P_RL.ARMONTH; --帐务月份
    RD.ARDMID        := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE    := NVL(PMD.GRPTYPE, '01'); --混合类别
    RD.ARDPMDCOLUMN1 := PMD.GRPCOLUMN1; --备用字段1
  
    CASE VPDMETHOD
      WHEN '01' THEN
        --固定单价  默认方式，与抄量有关
        BEGIN
          RD.ARDCLASS := 0;
          RD.ARDYSDJ  := PD.PRICE;
          RD.ARDYSSL  := P_SL;
          RD.ARDYSJE  := ROUND(RD.ARDYSDJ * RD.ARDYSSL, 2);
          RD.ARDDJ    := PD.PRICE;
          RD.ARDSL    := P_SL;
          RD.ARDJE    := ROUND(RD.ARDDJ * RD.ARDSL, 2);
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := 0;
          RD.ARDADJJE := RD.ARDJE - RD.ARDYSJE;
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END;
      WHEN '02' THEN
        --固定金额，与抄量无关
        BEGIN
          RD.ARDCLASS := 0;
          RD.ARDYSDJ  := 0;
          RD.ARDYSSL  := 0;
          RD.ARDADJDJ := 0;
          RD.ARDADJSL := 0;
          RD.ARDADJJE := 0;
          RD.ARDYSDJ  := 0;
          RD.ARDSL    := 0;
        
          IF P_SL > 0 THEN
            RD.ARDYSDJ := ROUND(NVL(PD.MONEY, 0), 2);
            RD.ARDDJ   := ROUND(NVL(PD.MONEY, 0), 2);
            RD.ARDYSJE := ROUND(NVL(PD.MONEY, 0), 2) * N;
            RD.ARDJE   := ROUND(NVL(PD.MONEY, 0), 2) * N;
          ELSE
            RD.ARDYSJE := 0;
            RD.ARDJE   := 0;
          END IF;
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END;
      WHEN '03' THEN
        BEGIN
          COSTSTEP_MON(P_RL, P_MR, P_SL, 0, 0, PD, RDTAB, P_CLASSCTL, PMD);
        END;
      WHEN '04' THEN
        BEGIN
          NULL;
          COSTSTEP_YEAR(P_RL,
                        P_SL,
                        0,
                        0,
                        PD,
                        RDTAB,
                        P_CLASSCTL,
                        PMD,
                        P_PSCID);
        END;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持的计费方法' || VPDMETHOD);
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --月阶梯计费步骤
  PROCEDURE COSTSTEP_MON(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                         P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                         P_SL       IN NUMBER,
                         P_ADJSL    IN NUMBER,
                         P_ADJDJ    IN NUMBER,
                         PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                         RDTAB      IN OUT RD_TABLE,
                         P_CLASSCTL IN CHAR,
                         PMD        IN YS_YH_PRICEGROUP%ROWTYPE) IS
    --rd.rdpiid；rd.rdpfid；rd.rdpscid为必要参数
    CURSOR C_PS IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_STEP
               WHERE PRICE_VER = PD.PRICE_VER
                 AND PRICE_NO = PD.PRICE_NO
                 AND PRICE_ITEM = PD.PRICE_ITEM)
       ORDER BY STEP_CLASS;
  
    TMPYSSL      NUMBER;
    LASTPSSLPERS NUMBER := 0;
    TMPSL        NUMBER;
    RD           YS_ZW_ARDETAIL%ROWTYPE;
    RD0          YS_ZW_ARDETAIL%ROWTYPE;
    PS           BAS_PRICE_STEP%ROWTYPE;
    PS0          BAS_PRICE_STEP%ROWTYPE;
    MINFO        YS_YH_SBINFO%ROWTYPE;
    N            NUMBER(38, 12); --计费期数
    TMPSCODE     NUMBER;
  BEGIN
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE   := P_RL.HIRE_CODE;
    RD.ARDID       := P_RL.ARID;
    RD.ARDPMDID    := NVL(PMD.GRPID, 0);
    RD.ARDPMDSCALE := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID     := PD.PRICE_ITEM;
    RD.ARDPFID     := PD.PRICE_NO;
    RD.ARDPSCID    := PD.PRICE_VER;
    RD.ARDMETHOD   := PD.METHOD;
    RD.ARDPAIDFLAG := 'N';
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH   := P_RL.ARMONTH; --帐务月份
    RD.ARDMID     := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额
  
    --判断数据是否满足收取阶梯的条件
    SELECT MI.* INTO MINFO FROM YS_YH_SBINFO MI WHERE MI.SBID = P_RL.SBID;
  
    --阶梯计费周期
    --间隔月(即每次计费按实际间隔月数计费)
    BEGIN
      SELECT ROUND(MONTHS_BETWEEN(TRUNC(P_RL.ARRDATE, 'MM'),
                                  TRUNC(P_RL.ARPRDATE, 'MM')))
        INTO N --计费时段月数
        FROM DUAL;
    
      IF N <= 0 OR N IS NULL THEN
        N := 1; --异常周期都算一个月阶梯
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        N := 0;
    END;
  
    P_RL.ARUSENUM := NVL(P_RL.ARUSENUM, 1);
  
    PS0 := NULL;
    RD0 := NULL;
  
    OPEN C_PS;
    FETCH C_PS
      INTO PS;
    IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
    END IF;
    WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
      -->=0保证0用水至少一条费用明细
      /*
      ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
      │阶梯规则（户/人均用水量以同一地址的所有水表用水量之和为基础计算）                      │
      │1、家庭户籍人口在4人以下（含4人）的用水户，按户用水量划分阶梯式计量水价。                      │
      │2、家庭户籍人口在5人（含5人）以上的用水户，按人均用水量划分阶梯式计量水价。                    │
      └─────────┴───────────────────────┴───────────────────────────────────┴─────────────────────────┘
      */ --一阶止二阶起要求设置值相同，依此类推
      P_RL.ARUSENUM := (CASE
                         WHEN NVL(P_RL.ARUSENUM, 0) < PS.PEOPLES THEN
                          PS.PEOPLES
                         ELSE
                          P_RL.ARUSENUM
                       END);
      IF PS.STEP_CLASS > 1 THEN
        PS.START_CODE := TMPSCODE;
      END IF;
      PS.END_CODE  := CEIL(N * (PS.END_CODE +
                           GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                           PS.ADD_WATERQTY + LASTPSSLPERS)); --阶梯段止算量
      TMPSCODE     := PS.END_CODE;
      LASTPSSLPERS := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                      PS.ADD_WATERQTY;
      --以上CEIL保持入，尽量拉款子阶梯段，让利与客户
      RD.ARDCLASS      := PS.STEP_CLASS;
      RD.ARDYSDJ       := PS.PRICE;
      RD.ARDYSSL       := GETMIN(TMPYSSL, PS.END_CODE - PS.START_CODE);
      RD.ARDYSJE       := ROUND(RD.ARDYSDJ * RD.ARDYSSL, 2);
      RD.ARDDJ         := GETMAX(PS.PRICE + P_ADJDJ, 0);
      RD.ARDSL         := GETMIN(TMPSL, PS.END_CODE - PS.START_CODE);
      RD.ARDJE         := ROUND(RD.ARDDJ * RD.ARDSL, 2);
      RD.ARDADJDJ      := RD.ARDDJ - RD.ARDYSDJ;
      RD.ARDADJSL      := RD.ARDSL - RD.ARDYSSL;
      RD.ARDADJJE      := RD.ARDJE - RD.ARDYSJE;
      RD.ARDPMDCOLUMN1 := TO_CHAR(ROUND(N, 2));
      RD.ARDPMDCOLUMN2 := PS.START_CODE;
      RD.ARDPMDCOLUMN3 := PS.END_CODE;
      --插入明细包
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --累减后带入下一行游标
      TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
      TMPSL   := GETMAX(TMPSL - RD.ARDYSSL, 0);
      EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
      FETCH C_PS
        INTO PS;
    END LOOP;
    CLOSE C_PS;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  PROCEDURE COSTSTEP_YEAR(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                          P_SL       IN NUMBER,
                          P_ADJSL    IN NUMBER,
                          P_ADJDJ    IN NUMBER,
                          PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                          RDTAB      IN OUT RD_TABLE,
                          P_CLASSCTL IN CHAR,
                          PMD        YS_YH_PRICEGROUP%ROWTYPE,
                          PMONTH     IN VARCHAR2) IS
    --rd.ardpiid；rd.ardpfid；rd.ardpscid为必要参数
    CURSOR C_PS IS
      SELECT *
        FROM (SELECT *
                FROM BAS_PRICE_STEP
               WHERE PRICE_VER = PD.PRICE_VER
                 AND PRICE_NO = PD.PRICE_NO
                 AND PRICE_ITEM = PD.PRICE_ITEM)
       ORDER BY STEP_CLASS;
  
    TMPYSSL        NUMBER;
    TMPSL          NUMBER;
    RD             YS_ZW_ARDETAIL%ROWTYPE;
    PS             BAS_PRICE_STEP%ROWTYPE;
    MI             YS_YH_SBINFO%ROWTYPE;
    TMPSCODE       NUMBER;
    LASTPSSLPERS   NUMBER := 0;
    N              NUMBER; --计费期数
    年累计已用水量 NUMBER;
    年累计应收水量 NUMBER;
    年累计实收水量 NUMBER;
  BEGIN
    SELECT SYS_GUID() INTO RD.ID FROM DUAL;
    RD.HIRE_CODE   := P_RL.HIRE_CODE;
    RD.ARDID       := P_RL.ARID;
    RD.ARDPMDID    := NVL(PMD.GRPID, 0);
    RD.ARDPMDSCALE := NVL(PMD.GRPSCALE, 1);
    RD.ARDPIID     := PD.PRICE_ITEM;
    RD.ARDPFID     := PD.PRICE_NO;
    RD.ARDPSCID    := PD.PRICE_VER;
    RD.ARDMETHOD   := PD.METHOD;
    RD.ARDPAIDFLAG := 'N';
  
    RD.ARDMSMFID  := P_RL.MANAGE_NO; --营销公司
    RD.ARDMONTH   := P_RL.ARMONTH; --帐务月份
    RD.ARDMID     := P_RL.SBID; --水表编号
    RD.ARDPMDTYPE := NVL(PMD.GRPTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL + P_ADJSL; --阶梯累减实收水量余额
  
    --判断数据是否满足收取阶梯的条件
    SELECT * INTO MI FROM YS_YH_SBINFO WHERE SBID = P_RL.SBID;
  
    --实时计算年累计已用水量
    年累计已用水量 := 实时计算年累计已用量(MI.SBID, TRUNC(SYSDATE, 'YYYY'));
    --计入本次用量
    年累计应收水量 := GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), 0) + TMPYSSL;
    年累计实收水量 := GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), 0) + TMPSL;
  
    OPEN C_PS;
    FETCH C_PS
      INTO PS;
    IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
    END IF;
    WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
    
      P_RL.ARUSENUM := (CASE
                         WHEN NVL(P_RL.ARUSENUM, 0) < PS.PEOPLES THEN
                          PS.PEOPLES
                         ELSE
                          P_RL.ARUSENUM
                       END);
      IF PS.STEP_CLASS > 1 THEN
        PS.START_CODE := TMPSCODE;
      END IF;
      PS.END_CODE      := PS.END_CODE +
                          GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                          PS.ADD_WATERQTY + LASTPSSLPERS; --阶梯段止算量
      TMPSCODE         := PS.END_CODE;
      LASTPSSLPERS     := GETMAX(P_RL.ARUSENUM - PS.PEOPLES, 0) *
                          PS.PEOPLES;
      RD.ARDPMDCOLUMN1 := PS.START_CODE;
      RD.ARDPMDCOLUMN2 := PS.END_CODE;
      RD.ARDCLASS      := PS.STEP_CLASS;
    
      RD.ARDYSDJ := PS.PRICE;
      RD.ARDYSSL := CASE
                      WHEN P_CLASSCTL = 'Y' THEN
                       TMPYSSL
                      ELSE
                       CASE
                         WHEN 年累计应收水量 >= PS.START_CODE AND 年累计应收水量 <= PS.END_CODE THEN
                          年累计应收水量 -
                          GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), PS.START_CODE)
                         WHEN 年累计应收水量 > PS.END_CODE THEN
                          GETMAX(0,
                                 GETMIN(PS.END_CODE -
                                        TO_NUMBER(NVL(年累计已用水量, 0)),
                                        PS.END_CODE - PS.START_CODE))
                         ELSE
                          0
                       END
                    END;
      RD.ARDYSJE := RD.ARDYSDJ * RD.ARDYSSL;
    
      RD.ARDDJ := GETMAX(PS.PRICE + P_ADJDJ, 0);
      RD.ARDSL := CASE
                    WHEN P_CLASSCTL = 'Y' THEN
                     TMPSL
                    ELSE
                     CASE
                       WHEN 年累计实收水量 >= PS.START_CODE AND 年累计实收水量 <= PS.END_CODE THEN
                        年累计实收水量 -
                        GETMAX(TO_NUMBER(NVL(年累计已用水量, 0)), PS.START_CODE)
                       WHEN 年累计实收水量 > PS.END_CODE THEN
                        GETMAX(0,
                               GETMIN(PS.END_CODE - TO_NUMBER(NVL(年累计已用水量, 0)),
                                      PS.END_CODE - PS.START_CODE))
                       ELSE
                        0
                     END
                  END;
      RD.ARDJE := ROUND(RD.ARDDJ * RD.ARDSL, 2); --实收金额
    
      RD.ARDADJDJ := RD.ARDDJ - RD.ARDYSDJ;
      RD.ARDADJSL := RD.ARDSL - RD.ARDYSSL;
      RD.ARDADJJE := RD.ARDJE - RD.ARDYSJE;
    
      --插入明细包
      IF RDTAB IS NULL THEN
        RDTAB := RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;
      --汇总
      P_RL.ARJE := P_RL.ARJE + RD.ARDJE;
      P_RL.ARSL := P_RL.ARSL + (CASE
                     WHEN RD.ARDPIID = '01' THEN
                      RD.ARDSL
                     ELSE
                      0
                   END);
      --累减后带入下一行游标
      TMPYSSL := GETMAX(TMPYSSL - RD.ARDYSSL, 0);
      TMPSL   := GETMAX(TMPSL - RD.ARDSL, 0);
      EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
      FETCH C_PS
        INTO PS;
    END LOOP;
    CLOSE C_PS;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  PROCEDURE INSRD(RD IN RD_TABLE, P_COMMIT IN NUMBER) IS
    VRD YS_ZW_ARDETAIL%ROWTYPE;
    I   NUMBER;
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD := RD(I);
      IF P_COMMIT != 调试 THEN
        INSERT INTO YS_ZW_ARDETAIL VALUES VRD;
      ELSE
        INSERT INTO YS_ZW_ARDETAIL_BUDGET VALUES VRD;
        INSERT INTO YS_ZW_ARDETAIL_virtual VALUES VRD;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) <= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMIN;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) >= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMAX;
  FUNCTION FBOUNDPARA(P_PARASTR IN CLOB) RETURN INTEGER IS
    --一维数组规则：#####,####,####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    I     INTEGER;
    N     INTEGER := 0;
    VCHAR NCHAR(1);
  BEGIN
    FOR I IN 1 .. LENGTH(P_PARASTR) LOOP
      VCHAR := SUBSTR(P_PARASTR, I, 1);
      IF VCHAR = '|' THEN
        N := N + 1;
      END IF;
    END LOOP;
  
    RETURN N;
  END;
  FUNCTION FGETPARA(P_PARASTR IN VARCHAR2,
                    ROWN      IN INTEGER,
                    COLN      IN INTEGER) RETURN VARCHAR2 IS
    --一维数组规则：#####|####|####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    VCHAR NCHAR(1);
    V     VARCHAR2(10000);
    VSTR  VARCHAR2(10000) := '';
    R     INTEGER := 1;
    C     INTEGER := 0;
  BEGIN
    V := TRIM(P_PARASTR);
    IF LENGTH(V) = 0 OR SUBSTR(V, LENGTH(V)) != '|' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '数组字符串格式错误' || P_PARASTR);
    END IF;
    FOR I IN 1 .. LENGTH(V) LOOP
      VCHAR := SUBSTR(V, I, 1);
      CASE VCHAR
        WHEN '|' THEN
          --一行读完
          BEGIN
            C := C + 1;
            IF R = ROWN AND C = COLN THEN
              RETURN VSTR;
            END IF;
            R    := R + 1;
            C    := 0;
            VSTR := '';
          END;
        WHEN ',' THEN
          --一列读完
          BEGIN
            C := C + 1;
            IF R = ROWN AND C = COLN THEN
              RETURN VSTR;
            END IF;
            VSTR := '';
          END;
        ELSE
          BEGIN
            VSTR := VSTR || VCHAR;
          END;
      END CASE;
    END LOOP;
  
    RETURN '';
  END;
  --预算费，提供追补、应收调整、退费单据中重算费中间数据
 PROCEDURE SUBMIT_VIRTUAL(p_mid    in varchar2,
                           p_PRICE_VER  IN  VARCHAR2,
                           p_prdate in date,
                           p_rdate  in date,
                           p_scode  in number,
                           p_ecode  in number,
                           p_sl     in number,
                           p_rper   in varchar2,
                           p_pfid   in varchar2,
                           p_usenum in number,
                           p_trans  in varchar2,
                           o_rlid   out varchar2) IS 
    cb Ys_Cb_Mtread%ROWTYPE; --抄表历史库
    mi ys_yh_sbinfo%rowtype;
  BEGIN
    delete ys_zw_arlist_virtual;
    delete ys_zw_ardetail_virtual;
    BEGIN
      select * into mi from ys_yh_sbinfo where SBID = p_mid; 
      cb.id            := '?'; --varchar2(10)  流水号 
      cb.CBMRMONTH         := to_char(p_rdate, 'yyyy.mm'); --varchar2(7)  抄表月份
      cb.MANAGE_NO         := mi.MANAGE_NO; --varchar2(10)  营销公司
      cb.BOOK_NO          := mi.BOOK_NO; --varchar2(10)  表册 
      cb.cbmrbatch         := null; --number(20)  抄表批次
      cb.cbmrday           := null; --date  计划抄表日
      cb.cbmrrorder        := null; --number(10)  抄表次序
      cb.YHID           := p_mid; --varchar2(10)  用户编号 
      cb.SBID           := p_mid; --varchar2(10)  水表编号 
      cb.TRADE_NO          := null; --varchar2(10)  行业分类
      cb.SBPID          := null; --varchar2(10)  上级水表
      cb.CBMRMCLASS        := null; --number  水表级次
      cb.cbmrmflag         := null; --char(1)  末级标志
      cb.cbmrcreadate      := p_rdate; --date  创建日期
      cb.cbmrinputdate     := p_rdate; --date  编辑日期
      cb.cbmrreadok        := 'Y'; --char(1)  抄见标志
      cb.cbmrrdate         := p_rdate; --date  抄表日期
      cb.cbmrrper          := p_rper; --varchar2(15)  抄表员
      cb.cbmrprdate        := p_prdate; --date  上次抄见日期
      cb.cbmrscode         := p_scode; --number(10)  上期抄见
      cb.cbmrecode         := p_ecode; --number(10)  本期抄见
      cb.cbmrsl            := p_sl; --number(10)  本期水量
      cb.cbmrface          := null; --varchar2(2)  水表故障
      cb.cbmrifsubmit      := 'Y'; --char(1)  是否提交计费
      cb.cbmrifhalt        := null; --char(1)  系统停算
      cb.cbmrdatasource    := null; --char(1)  抄表结果来源
      cb.cbmrifignoreminsl := null; --char(1)  停算最低抄量
      cb.cbmrpdardate      := null; --date  抄表机抄表时间
      cb.cbmroutflag       := null; --char(1)  发出到抄表机标志
      cb.cbmroutid         := null; --varchar2(10)  发出到抄表机流水号
      cb.cbmroutdate       := null; --date  发出到抄表机日期
      cb.cbmrinorder       := null; --number(4)  抄表机接收次序
      cb.cbmrindate        := null; --date  抄表机接受日期
      cb.cbmrrpid          := null; --varchar2(3)  计件类型
      cb.cbmrmemo          := null; --varchar2(120)  抄表备注
      cb.cbmrifgu          := null; --char(1)  估表标志
      cb.cbmrifrec         := null; --char(1)  已计费
      cb.cbmrrecdate       := null; --date  计费日期
      cb.cbmrrecsl         := p_sl; --number(10)  应收水量
      cb.cbmraddsl         := null; --number(10)  余量
      cb.cbmrcarrysl       := null; --number(10)  校验水量
      cb.cbmrctrl1         := null; --varchar2(10)  抄表机控制位1
      cb.cbmrctrl2         := null; --varchar2(10)  抄表机控制位2
      cb.cbmrctrl3         := null; --varchar2(10)  抄表机控制位3
      cb.cbmrctrl4         := null; --varchar2(10)  抄表机控制位4
      cb.cbmrctrl5         := null; --varchar2(10)  换表单据号
      cb.cbmrchkflag       := null; --char(1)  复核标志
      cb.cbmrchkdate       := null; --date  复核日期
      cb.cbmrchkper        := null; --varchar2(10)  复核人员
      cb.cbmrchkscode      := null; --number(10)  原起数
      cb.cbmrchkecode      := null; --number(10)  原止数
      cb.cbmrchksl         := null; --number(10)  原水量
      cb.cbmrchkaddsl      := null; --number(10)  原余量
      cb.cbmrchkcarrysl    := null; --number(10)  原进位水量
      cb.cbmrchkrdate      := null; --date  原抄见日期
      cb.cbmrchkface       := null; --varchar2(2)  原表况
      cb.cbmrchkresult     := null; --varchar2(100)  检查结果类型
      cb.cbmrchkresultmemo := null; --varchar2(100)  检查结果说明
      cb.cbmrprimid        := null; --varchar2(200)  合收表主表
      cb.cbmrprimflag      := null; --char(1)  合收表标志
      cb.cbmrlb            := null; --char(1)  水表类别
      cb.cbmrnewflag       := null; --char(1)  新表标志
      cb.cbmrface2         := null; --varchar2(2)  抄见故障
      cb.cbmrface3         := null; --varchar2(2)  非常计量
      cb.cbmrface4         := null; --varchar2(2)  表井设施说明
      cb.cbmrscodechar     := p_scode; --varchar2(10)  上期抄见
      cb.cbmrecodechar     := p_ecode; --varchar2(10)  本期抄见
      cb.cbmrprivilegeflag := null; --varchar2(1)  特权标志(y/n)
      cb.cbmrprivilegeper  := null; --varchar2(10)  特权操作人
      cb.cbmrprivilegememo := null; --varchar2(200)  特权操作备注
      cb.cbmrprivilegedate := null; --date  特权操作时间
      cb.AREA_NO         := null; --varchar2(10)  管理区域
      cb.cbmriftrans       := null; --char(1)  抄表事务
      cb.cbmrrequisition   := null; --number(2)  通知单打印次数
      cb.cbmrifchk         := null; --char(1)  考核表
      cb.cbmrinputper      := null; --varchar2(10)  入账人员
      cb.Price_No          := p_pfid; --varchar2(10)  用水类别
      cb.cbmrcaliber       := null; --number(10)  口径
      cb.cbmrside          := null; --varchar2(100)  表位
      cb.cbmrlastsl        := null; --number(10)  上次抄表水量
      cb.cbmrthreesl       := null; --number(10)  前三月抄表水量
      cb.cbmryearsl        := null; --number(10)  去年同期抄表水量
      cb.cbmrrecje01       := null; --number(13,3)  应收金额费用项目01
      cb.cbmrrecje02       := null; --number(13,3)  应收金额费用项目02
      cb.cbmrrecje03       := null; --number(13,3)  应收金额费用项目03
      cb.cbmrrecje04       := null; --number(13,3)  应收金额费用项目04
      cb.cbmrmtype         := null; --varchar2(10)  表型
      cb.cbmrnullcont      := null; --number(10)  连续几月未抄见
      cb.cbmrnulltotal     := null; --number(10)  累计几月未抄见
      cb.cbmrplansl        := null; --number(18,8)  计划水量
      cb.cbmrplanje01      := null; --number(18,8)  计划水费
      cb.cbmrplanje02      := null; --number(18,8)  计划污水处理费
      cb.cbmrplanje03      := null; --number(18,8)  计划水资源费
      cb.cbmrlastje01      := null; --number(13,3)  上次水费
      cb.cbmrthreeje01     := null; --number(13,3)  前n次均水费
      cb.cbmryearje01      := null; --number(13,3)  去年同期水费
      cb.cbmrlastje02      := null; --number(13,3)  上次污水费
      cb.cbmrthreeje02     := null; --number(13,3)  前n次均污水费
      cb.cbmryearje02      := null; --number(13,3)  去年同期污水费
      cb.cbmrlastje03      := null; --number(13,3)  上次水资源费
      cb.cbmrthreeje03     := null; --number(13,3)  前n次均水资源费
      cb.cbmryearje03      := null; --number(13,3)  去年同期水资源费
      cb.cbmrlastyearsl    := null; --number(10)  去年度次均量
      cb.cbmrlastyearje01  := null; --number(13,3)  去年度次均水费
      cb.cbmrlastyearje02  := null; --number(13,3)  去年度次均污水费
      cb.cbmrlastyearje03  := null; --number(13,3)  去年度次均水资源费  
      --
      COSTCULATECORE(cb, p_trans, p_PRICE_VER, 调试);
      --20150414 应收追补预算费支持历史水价算费
      --CALCULATE(cb, p_trans, to_char(p_rdate,'yyyy.mm'), 调试);

      o_rlid := cb.cbmrprivilegeper;
    EXCEPTION
      WHEN OTHERS THEN
        /*WLOG(p_mid || ',' || p_prdate || ',' || p_rdate || ',' || p_sl || ',' ||
             p_pfid || ',' || p_usenum || ',' || p_trans || '预算费失败2，已被忽略' ||
             sqlerrm);*/
              RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

 BEGIN
  总表截量     := 'Y';
  最低算费水量 := 0;
END;
/

prompt
prompt Creating package body PG_DSZBILL_01
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Dszbill_01 IS

  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --单据流水号
                     p_Dshlb     IN VARCHAR2, --单据类别
                     p_Dshsmfid  IN VARCHAR2, --营销公司
                     p_Dshdept   IN VARCHAR2, --受理部门
                     p_Dshcreper IN VARCHAR2 --受理人员
                     ) IS
    Dbh Ys_Gd_Zwdhzd%ROWTYPE;
  BEGIN
    --赋值 单头
    Dbh.Id          := Uuid();
    Dbh.Hire_Code   := f_Get_Hire_Code();
    Dbh.Bill_Id     := p_Dshno; --单据流水号
    Dbh.Bill_No     := p_Dshno; --单据编号
    Dbh.Bill_Type   := p_Dshlb; --单据类别
    Dbh.Bill_Source := '1'; --单据来源
    Dbh.Manage_No   := p_Dshsmfid; --营销公司
    Dbh.New_Dept    := p_Dshdept; --受理部门
    Dbh.Add_Date    := SYSDATE; --受理日期
    Dbh.Add_Per     := p_Dshcreper; --受理人员
    Dbh.Check_Date  := NULL; --审核日期
    Dbh.Check_Per   := NULL; --审核人员
    Dbh.Check_Flag  := 'N'; --审核标志
    INSERT INTO Ys_Gd_Zwdhzd VALUES Dbh;
  
  END Createhd;

  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --单据流水号
                     p_Dsdrowno IN VARCHAR2, --行号
                     p_Arid     IN VARCHAR2 --应收流水
                     ) IS
    Dbt Ys_Gd_Zwdhzdt%ROWTYPE;
    Ar  Ys_Zw_Arlist%ROWTYPE;
  BEGIN
    --查询账务信息
    SELECT * INTO Ar FROM Ys_Zw_Arlist WHERE Arid = p_Arid;
    --赋值 单体      
    Dbt.Bill_Id   := p_Dsdno; --单据流水号
    Dbt.Dhzrowno  := p_Dsdrowno; --行号
    Dbt.Hire_Code := Ar.Hire_Code; --
    Dbt.Arid      := Ar.Arid; --流水号
    Dbt.Manage_No := Ar.Manage_No; --营销公司
    Dbt.Armonth   := Ar.Armonth; --帐务月份
    Dbt.Ardate    := Ar.Ardate; --帐务日期
    Dbt.Yhid      := Ar.Yhid; --用户编号
    Dbt.Sbid      := Ar.Sbid; --水表编号
    /* DBT.RLMSMFID        := Ar.RLMSMFID; --水表公司
    DBT.RLCSMFID        := Ar.RLCSMFID; --用户公司
    DBT.RLCCODE         := Ar.RLCCODE; --资料号*/
    Dbt.Archargeper     := Ar.Archargeper; --收费员
    Dbt.Arcpid          := Ar.Arcpid; --上级用户编号
    Dbt.Arcclass        := Ar.Arcclass; --用户级次
    Dbt.Arcflag         := Ar.Arcflag; --末级标志
    Dbt.Arusenum        := Ar.Arusenum; --户用水人数
    Dbt.Arcname         := Ar.Arcname; --用户名称
    Dbt.Arcadr          := Ar.Arcadr; --用户地址
    Dbt.Armadr          := Ar.Armadr; --水表地址
    Dbt.Arcstatus       := Ar.Arcstatus; --用户状态
    Dbt.Armtel          := Ar.Armtel; --移动电话
    Dbt.Artel           := Ar.Artel; --固定电话
    Dbt.Arbankid        := Ar.Arbankid; --代扣银行
    Dbt.Artsbankid      := Ar.Artsbankid; --托收银行
    Dbt.Araccountno     := Ar.Araccountno; --开户帐号
    Dbt.Araccountname   := Ar.Araccountname; --开户名称
    Dbt.Ariftax         := Ar.Ariftax; --是否税票
    Dbt.Artaxno         := Ar.Artaxno; --增殖税号
    Dbt.Arifinv         := Ar.Arifinv; --是否普票
    Dbt.Armcode         := Ar.Armcode; --水表手工编号
    Dbt.Armpid          := Ar.Armpid; --上级水表
    Dbt.Armclass        := Ar.Armclass; --水表级次
    Dbt.Armflag         := Ar.Armflag; --末级标志
    Dbt.Armsfid         := Ar.Armsfid; --水表类别
    Dbt.Arday           := Ar.Arday; --抄表日
    Dbt.Arbfid          := Ar.Arbfid; --表册
    Dbt.Arprdate        := Ar.Arprdate; --上次抄表日期
    Dbt.Arrdate         := Ar.Arrdate; --本次抄表日期
    Dbt.Arzndate        := Ar.Arzndate; --违约金起算日
    Dbt.Arcaliber       := Ar.Arcaliber; --表口径
    Dbt.Arrtid          := Ar.Arrtid; --抄表方式
    Dbt.Armstatus       := Ar.Armstatus; --状态
    Dbt.Armtype         := Ar.Armtype; --类型
    Dbt.Armno           := Ar.Armno; --表身码
    Dbt.Arscode         := Ar.Arscode; --起数
    Dbt.Arecode         := Ar.Arecode; --止数
    Dbt.Arreadsl        := Ar.Arreadsl; --抄见水量
    Dbt.Arinvmemo       := Ar.Arinvmemo; --发票备注
    Dbt.Arentrustbatch  := Ar.Arentrustbatch; --托收代扣批号
    Dbt.Arentrustseqno  := Ar.Arentrustseqno; --托收代扣流水号
    Dbt.Aroutflag       := Ar.Aroutflag; --发出标志
    Dbt.Artrans         := Ar.Artrans; --应收事务
    Dbt.Arcd            := Ar.Arcd; --借贷方向
    Dbt.Aryschargetype  := Ar.Aryschargetype; --应收方式
    Dbt.Arsl            := Ar.Arsl; --应收水量
    Dbt.Arje            := Ar.Arje; --应收金额
    Dbt.Araddsl         := Ar.Araddsl; --加调水量
    Dbt.Arscrarid       := Ar.Arscrarid; --原应收帐流水
    Dbt.Arscrartrans    := Ar.Arscrartrans; --原应收帐事务
    Dbt.Arscrarmonth    := Ar.Arscrarmonth; --原应收帐月份
    Dbt.Arpaidje        := Ar.Arpaidje; --销帐金额
    Dbt.Arpaidflag      := Ar.Arpaidflag; --销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    Dbt.Arpaidper       := Ar.Arpaidper; --销帐人员
    Dbt.Arpaiddate      := Ar.Arpaiddate; --销帐日期
    Dbt.Armrid          := Ar.Armrid; --抄表流水
    Dbt.Armemo          := Ar.Armemo; --备注
    Dbt.Arznj           := Ar.Arznj; --违约金
    Dbt.Arlb            := Ar.Arlb; --类别
    Dbt.Arcname2        := Ar.Arcname2; --曾用名
    Dbt.Arpfid          := Ar.Arpfid; --主价格类别
    Dbt.Ardatetime      := Ar.Ardatetime; --发生日期
    Dbt.Arscrardate     := Ar.Arscrardate; --原帐务日期
    Dbt.Arprimcode      := Ar.Arprimcode; --合收表主表号
    Dbt.Arpriflag       := Ar.Arpriflag; --合收表标志
    Dbt.Arrper          := Ar.Arrper; --抄表员
    Dbt.Arsafid         := Ar.Arsafid; --区域
    Dbt.Arscodechar     := Ar.Arscodechar; --上期抄表（带表位）
    Dbt.Arecodechar     := Ar.Arecodechar; --本期抄表（带表位）
    Dbt.Arilid          := Ar.Arilid; --发票流水号
    Dbt.Armiuiid        := Ar.Armiuiid; --合收单位编号
    Dbt.Argroup         := Ar.Argroup; --应收帐分组
    Dbt.Arpid           := Ar.Arpid; --实收流水（与PAYMENT.PID对应）
    Dbt.Arpbatch        := Ar.Arpbatch; --缴费交易批次（与PAYMENT.PBATCH对应）
    Dbt.Arsavingqc      := Ar.Arsavingqc; --期初预存（销帐时产生）
    Dbt.Arsavingbq      := Ar.Arsavingbq; --本期预存发生（销帐时产生）
    Dbt.Arsavingqm      := Ar.Arsavingqm; --期末预存（销帐时产生）
    Dbt.Arreverseflag   := Ar.Arreverseflag; --  冲正标志（N为正常，Y为冲正）
    Dbt.Arbadflag       := 'O'; --呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）  --发出时修改标志
    Dbt.Arznjreducflag  := Ar.Arznjreducflag; --滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取ARZNJ
    Dbt.Armistid        := Ar.Armistid; --行业分类
    Dbt.Arminame        := Ar.Arminame; --票据名称
    Dbt.Arsxf           := Ar.Arsxf; --手续费
    Dbt.Armiface2       := Ar.Armiface2; --抄见故障
    Dbt.Armiface3       := Ar.Armiface3; --非常计量
    Dbt.Armiface4       := Ar.Armiface4; --表井设施说明
    Dbt.Armiifckf       := Ar.Armiifckf; --垃圾费户数
    Dbt.Armigps         := Ar.Armigps; --是否合票
    Dbt.Armiqfh         := Ar.Armiqfh; --铅封号
    Dbt.Armibox         := Ar.Armibox; --消防水价（增值税水价，襄阳需求）
    Dbt.Arminame2       := Ar.Arminame2; --招牌名称(小区名，襄阳需求）
    Dbt.Armiseqno       := Ar.Armiseqno; --户号（初始化时册号+序号）
    Dbt.Armisaving      := Ar.Armisaving; --算费时预存
    Dbt.Arpriorje       := Ar.Arpriorje; --算费之前欠费
    Dbt.Armicommunity   := Ar.Armicommunity; --小区
    Dbt.Armiremoteno    := Ar.Armiremoteno; --远传表号
    Dbt.Armiremotehubno := Ar.Armiremotehubno; --远传HUB号
    Dbt.Armiemail       := Ar.Armiemail; --电子邮件
    Dbt.Armiemailflag   := Ar.Armiemailflag; --发票类别
    Dbt.Armicolumn1     := Ar.Armicolumn1; --备用字段1
    Dbt.Armicolumn2     := Ar.Armicolumn2; --备用字段2(预开票打印批次)
    Dbt.Armicolumn3     := Ar.Armicolumn3; --备用字段3
    Dbt.Armicolumn4     := Ar.Armicolumn4; --备用字段3
    Dbt.Arpaidmonth     := Ar.Arpaidmonth; --销账月份
    Dbt.Arcolumn5       := Ar.Arcolumn5; --上次应帐帐日期
    Dbt.Arcolumn9       := Ar.Arcolumn9; --上次应收帐流水
    Dbt.Arcolumn10      := Ar.Arcolumn10; --上次应收帐月份
    Dbt.Arcolumn11      := Ar.Arcolumn11; --上次应收帐事务
    Dbt.Arjtmk          := Ar.Arjtmk; --不记阶梯注记
    Dbt.Arjtsrq         := Ar.Arjtsrq; --本周期阶梯开始日期
    Dbt.Arcolumn12      := Ar.Arcolumn12; --年度累计量
    Dbt.Dhzappnote      := ''; --申请说明
    Dbt.Dhzfilashnote   := ''; --领导意见
    Dbt.Dhzmemo         := ''; --备注
    Dbt.Dhzshflag       := 'N'; --行审核标志
    Dbt.Dhzshdate       := ''; --行审核日期
    Dbt.Dhzshper        := ''; --行审核人
  
    INSERT INTO Ys_Gd_Zwdhzdt VALUES Dbt;
  END Createdt;

  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --单据流水号
                          p_Dshlb     IN VARCHAR2, --单据类别
                          p_Dshsmfid  IN VARCHAR2, --营销公司
                          p_Dshdept   IN VARCHAR2, --受理部门
                          p_Dshcreper IN VARCHAR2, --受理人员
                          p_Arid      IN VARCHAR2 --应收流水号
                          ) IS
    Ar      Ys_Zw_Arlist%ROWTYPE;
    v_Rowid NUMBER(10) := 0; --行号
    --单位游标
    CURSOR c_Ar IS
      SELECT t.*
        FROM Ys_Zw_Arlist t /*, PBPARMTEMP P*/
       WHERE Arid = p_Arid;
    --ARID = '';
  BEGIN
    --插入单头
    Createhd(p_Dshno, --单据流水号
             p_Dshlb, --单据类别
             p_Dshsmfid, --营销公司
             p_Dshdept, --受理部门
             p_Dshcreper --受理人员
             );
    --插入单体
    OPEN c_Ar;
    LOOP
      FETCH c_Ar
        INTO Ar;
      EXIT WHEN c_Ar%NOTFOUND OR c_Ar%NOTFOUND IS NULL;
      v_Rowid := v_Rowid + 1;
      Createdt(p_Dshno, --单据流水号
               v_Rowid, --行号
               Ar.Arid --应收流水号
               );
      --修改呆死帐标志
      UPDATE Ys_Zw_Arlist
         SET Ys_Zw_Arlist.Arbadflag = 'O'
       WHERE Arid = Ar.Arid;
    END LOOP;
    CLOSE c_Ar;
    COMMIT;
  END Createdszbill;

  --删除单据
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --单据编号
                       p_Person IN VARCHAR2, --操作员
                       p_Djlb   IN VARCHAR2) IS
    --单据类别
    CURSOR c_Dbh IS
      SELECT *
        FROM Ys_Gd_Zwdhzd
       WHERE Bill_Id = p_Billno
      --AND BILL_TYPE = P_DJLB
         FOR UPDATE;
    Dbh Ys_Gd_Zwdhzd%ROWTYPE;
  BEGIN
    OPEN c_Dbh;
    FETCH c_Dbh
      INTO Dbh;
    IF c_Dbh%NOTFOUND OR c_Dbh%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '单据不存在' || p_Billno);
    END IF;
    IF Dbh.Check_Flag <> 'N' THEN
      Raise_Application_Error(Errcode, '单据不能取消' || p_Billno);
    END IF;
    --修改呆死帐标志
    UPDATE Ys_Zw_Arlist
       SET Ys_Zw_Arlist.Arbadflag = 'N'
     WHERE Arid IN
           (SELECT Arid FROM Ys_Gd_Zwdhzdt WHERE Bill_Id = p_Billno);
    --删除单体
    DELETE FROM Ys_Gd_Zwdhzdt t WHERE t.Bill_Id = p_Billno;
    --删除单头
    DELETE FROM Ys_Gd_Zwdhzd t WHERE t.Bill_Id = p_Billno;
    CLOSE c_Dbh;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Dbh%ISOPEN THEN
        CLOSE c_Dbh;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END Cancelbill;

  --审核主程序
  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --批次流水
                         p_Per      IN VARCHAR2, --操作员
                         p_Billid   IN VARCHAR2, --单据ID
                         p_Billtype IN VARCHAR2 --单据类别
                         ) AS
  
  BEGIN
    Custbill(p_Cchno, p_Per, p_Billtype, 'N');
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

  --审核主程序
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --批次流水
                     p_Per      IN VARCHAR2, --操作员
                     p_Billtype IN VARCHAR2,
                     p_Commit   IN VARCHAR2 --提交标志
                     ) AS 
    Dbh     Ys_Gd_Zwdhzd%ROWTYPE;
    Dbt     Ys_Gd_Zwdhzdt%ROWTYPE; 
    CURSOR c_Custdt IS
      SELECT * FROM Ys_Gd_Zwdhzdt WHERE Bill_Id = p_Cchno FOR UPDATE;
  BEGIN
    BEGIN
      SELECT * INTO Dbh FROM Ys_Gd_Zwdhzd WHERE Bill_Id = p_Cchno;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '变更单头信息不存在!');
    END;
    IF Dbh.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '变更单已审核,不需再审!');
    END IF;
    IF Dbh.Check_Flag = 'C' THEN
      Raise_Application_Error(Errcode, '变更单已取消,不能审!');
    END IF;
  
    OPEN c_Custdt;
    LOOP
      FETCH c_Custdt
        INTO Dbt;
      EXIT WHEN c_Custdt%NOTFOUND OR c_Custdt%NOTFOUND IS NULL;
      --更新单体
      UPDATE Ys_Gd_Zwdhzdt
         SET Dhzshflag = 'Y', --行审核标志
             Dhzshdate = SYSDATE, --行审核日期
             Dhzshper  = p_Per --行审核人
       WHERE Bill_Id = Dbt.Bill_Id
         AND Dhzrowno = Dbt.Dhzrowno;
      --更新账务呆死帐标志
      IF p_Billtype = '8' THEN
        --正常账变更为呆坏账  ADD 20140831
        --20140227 增加呆坏账应收事务  RECTRANS
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'Y', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      ELSE
        --呆坏账变更为正常账 ADD 20140831
        UPDATE Ys_Zw_Arlist
           SET Arbadflag = 'N', Artrans = 'D'
         WHERE Arid = Dbt.Arid;
      END IF;
    END LOOP;
    CLOSE c_Custdt;
    --审核单头
    UPDATE Ys_Gd_Zwdhzd
       SET Check_Date = SYSDATE, Check_Per = p_Per, Check_Flag = 'Y'
     WHERE Bill_Id = p_Cchno;
  
  
    IF p_Commit = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;

END;
/

prompt
prompt Creating package body PG_FIND
prompt =============================
prompt
create or replace package body pg_find is

  /*
  功能：前台页面综合查询_详细信息
  参数说明
  p_yhid          用户id
  p_bookno        表册编码
  p_sbid          水表编码
  p_manageno      营销公司编码
  out             输出结果集
  */
  procedure find_zhcx_xxxx(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      t.yhid 用户编号,
      t.manage_no  营销公司编码,
      t.yhname 用户名,
      t.yhadr 用户地址,
      t.yhstatus 用户状态,--【syscuststatus】(1正常/7销户/2预立户)
      t.yhnewdate 立户日期,
      t.yhidentitylb 证件类型,--(1-身份证 2-营业执照  0-无)
      t.yhidentityno 证件号码,
      t.yhmtel 移动电话,
      t.yhconnectper 联系人,
      t.yhconnecttel 联系电话,
      t.yhprojno 工程编号,--(水账标识号)
      t.yhfileno 档案号,--(供水合同号)
      t.yhmemo 备注信息,
      sb.sbiftax 是否税票,
      sb.sbtaxno 税号,
      sb.sbifmp 混合用水标志,--(y-是,n-否 )
      sb.sbifcharge 是否计费,--(y-是,n-否 )
      sb.sbifsl 是否计量,--(y-是,n-否 )
      sb.sbifchk 是否考核表,--(y-是,n-否 )
      sb.sbpid 上级水表编号,
      sb.book_no 表册编码,
      sb.area_no 区域,
      sb.trade_no 行业分类,--【metersortframe】(20政府/21视同/22区域用户/26集体户/1居民/2企业/3特困企业/4破产企业/5增值税企业/6银行/7市直行政事业/8区行政事业/10学校/11医院/12环卫公厕/13非环卫公厕/14绿  化/15暂不开票/16销  户/17表  拆/18分  户/19报  停/23农郊用户/24校核表/25消防表/30一户一表)
      sb.sbinsdate 装表日期,
      md.sbid  水表档案编号,--(户号，入库时为空)
      md.mdno 表身码,
      md.barcode 条形码,
      md.rfid 电子标签,
      md.mdcaliber 表口径,
      md.mdbrand 表厂家,
      sb.sbname2 招牌名称,--(小区名）
      sb.sbusenum 户籍人数,
      sb.sbrecdate 本期抄见日期,
      sb.sbrecsl 本期抄见水量,
      sb.sbrcodechar 本期读数,
      sb.sbinscode 新装起度,
      sb.sbinsdate 装表日期,
      sb.sbinsper 安装人,
      sb.sbposition 水表接水地址,
      sb.sbchargetype 收费方式,--(x坐收m走收)
      sb.sbcommunity 远传表小区号,
      sb.sbremoteno 远传表号,--采集机（哈尔滨：借用建账存放合收主表表身码）
      sb.sbremotehubno 远传表hub号,--端口（哈尔滨：借用存放用户编号clt_id，坐收老号查询）
      sb.sbhtbh 合同编号,
      sb.sbmemo 备注信息,
      sb.sbicno ic卡号,
      sb.sbusenum 户籍人数,
      sb.sbface 水表故障,--(01正常/02表异常/03零水量)
      sb.sbstatus 有效状态,--【sysmeterstatus】(28基建临时用水/27移表中/19销户中/21欠费停水/24故障换表中/25周检中/7销户/1立户/2预立户/29无表/30故障表/31基建正式用水/32基建拆迁止水/34营销部收入用户/36预存冲正中/33补缴用户/35周期换表中)
      sb.sbrpid 计件类型,
      sb.sbface3 非常计量,
      sb.sbsaving 预存款余额,
      sb.sbjtkssj11 阶梯开始日期
    from
      ys_yh_custinfo t,
      ys_yh_sbinfo sb,
      ys_yh_sbdoc md
    where
      t.yhid = sb.yhid
      and sb.hire_code = t.hire_code
      and sb.sbid = md.sbid
      and (t.yhid = p_yhid or p_yhid is null)
      and (sb.book_no = p_bookno or p_bookno is null)
      and (sb.sbid = p_sbid or p_sbid is null)
      and (t.manage_no = p_manageno or p_manageno is null)
    ;
  end find_zhcx_xxxx;

  /*
  功能：柜台缴费页面基本信息查询
  参数说明
  p_yhid          用户id
  p_yhname        用户名
  p_sbposition    用水地址
  p_yhmtel        移动电话
  out             输出结果集
  */
  procedure find_gtjf_jbxx(p_yhid in varchar2,p_yhname in varchar2,p_sbposition in varchar2,p_yhmtel in varchar2 ,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      t.yhname 用户名称,
      t.yhid 客户代码,
      t.yhconnecttel 联系电话,
      t.yhmtel 移动电话,
      sb.sbposition 用水地址,
      case t.yhstatus when '1' then '正常' when '7' then '销户' when '2' then '预立户' end 用户状态,--(1正常/7销户/2预立户)
      sb.book_no 表册,
      price_name||'('||price||')' 价格分类,
      case sb.sbchargetype when 'X' then '坐收' when 'M' then '走收' end 收费方式,-- 收费方式(x坐收m走收)
      dp.dept_name 营销公司, 
      t.yhifinv 增值税发票,--是否普票（哈尔滨：借用做是否已打印增值税收据，reclist取值，置空）
      sb.sbpriflag 合收标志,--合收表标志(y-合收表标志,n-非合收主表 )
      sb.sbpriflag 合收主表,
      sb.sbifmp 混合用水,--混合用水标志(y-是,n-否 )
      sum(nvl(sb.sbsaving,0)) 预存余额
    from 
      ys_yh_custinfo t,
      ys_yh_sbinfo sb,
      base_dept dp,
      (select bas_price_name.price_no,bas_price_name.price_name,sum(bas_price_detail.price) price
      from bas_price_name,bas_price_detail 
      where bas_price_name.price_no=bas_price_detail.price_no 
      group by bas_price_name.price_no,bas_price_name.price_name) p
    where
      t.yhid = sb.yhid
      and sb.hire_code = t.hire_code
      and t.manage_no = dp.dept_no
      and dp.hire_code = 'kings'
      and sb.price_no = p.price_no
      and (t.yhid like '%'||p_yhid||'%' or p_yhid is null)
      and (t.yhname like '%'||p_yhname||'%' or p_yhname is null)
      and (sb.sbposition like '%'||p_sbposition||'%' or p_sbposition is null)
      and (t.yhmtel like '%'||p_yhmtel||'%' or p_yhmtel is null)
    group by t.yhname,
      t.yhid,
      t.yhconnecttel,
      t.yhmtel,
      sb.sbposition,
      t.yhstatus,
      sb.book_no,
      price_name||'('||price||')',
      sb.sbchargetype,
      dp.dept_name,
      t.yhifinv,
      sb.sbpriflag,
      sb.sbpriflag,
      sb.sbifmp
      ;
  end find_gtjf_jbxx;
  
  /*
  功能：柜台缴费页面欠费信息查询
  参数说明
  p_yhid          用户id
  out             输出结果集
  */
  procedure find_gtjf_qf(p_yhid in varchar2,out_tab out sys_refcursor) is
    begin
    open out_tab for select
       armonth   账务月份, 
        ardate    账务日期, 
        arscode   起数,   
        arecode   止数,   
        arsl    应收水量, 
        arje    应收金额, 
        arpaidje  销账金额, 
        arznj   违约金,   
        arzndate  违约金起算日,
        arpfid 价格分类, 
        artrans   应收事务, 
        arid    流水号   
      from ys_zw_arlist 
      where 
        arpaidflag='N'         --销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
        and arreverseflag='N'  --冲正标志（N为正常，Y为冲正）
        and aroutflag='N'      --发出标志(Y-发出 N-未发出)
        and yhid = p_yhid
      order by ardatetime desc
      ;
  end find_gtjf_qf;
  
  /*
  功能：柜台缴费页面欠费信息明细查询
  参数说明
  p_arid          流水号
  out             输出结果集
  */
  procedure find_gtjf_qfmx(p_arid in varchar2,out_tab out sys_refcursor) is
    begin
    open out_tab for select
      ardpiid 费用项目,
      item_name 费用项目名称,
      ardysje 应收金额,
      price_name||'('||price||')' 价格分类,
      ardclass 阶梯级别,
      ardysdj 单价,
      ardyssl 水量,
      ardysje 金额,
      ardznj 违约金
    from ys_zw_ardetail ard, 
       ys_zw_arlist ar,
      (select bas_price_name.price_no,bas_price_name.price_name,sum(bas_price_detail.price) price
      from bas_price_name,bas_price_detail 
      where bas_price_name.price_no=bas_price_detail.price_no 
      group by bas_price_name.price_no,bas_price_name.price_name) p,
      bas_price_item pi
    where ar.arid = ard.ardid
      and ar.arpfid = p.price_no
      and ardpiid = pi.price_item
      and ard.ardid = p_arid
    ;
  end find_gtjf_qfmx;
  
  /*
  功能：柜台缴费页面缴费入口
  参数说明
  p_yhid          用户编码
  p_arid          流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        资金来源
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_gnm           功能码， 正常999 错误000
  p_cwxx          错误信息
  */
  procedure find_gtjf_jf(p_yhid in varchar2,
            p_arid in varchar2,
            p_oper     in varchar2,
            p_payway in varchar2,
            p_payment in number,
            p_gnm out varchar2,
            p_cwxx out varchar2) is
  v_sbid varchar2(10);
  v_arstr varchar2(1000);
  v_position varchar(32);
  v_paypoint varchar(32);
  v_pid varchar(32);
  begin
      --获取水表编码
      select sbid into v_sbid from ys_yh_sbinfo where yhid = p_yhid;
      
      if p_oper is not null then
	      select base_dept.dept_no into v_position from base_user join base_dept on base_user.dept_id = base_dept.id and base_user.user_name = p_oper;
        v_paypoint := v_position;
      end if;
      
      if p_arid is not null then
        --字符串转换
        --例如：0000012726,70105341 转换成 0000012726,Y*01!Y*02!Y*03!Y*04!,0,0,0,0|70105341,Y*01!Y*02!Y*03!,0,0,0,0|
        with arstr_tab as(
          select 
            --to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') arstr
            to_char(ardid||',Y*'||replace(regexp_replace(listagg(ardpiid, ',') within group(order by ardpiid),'([^,]+)(,\1)+','\1'),',','!Y*')||'!,'||sum(nvl(ardznj,0))||',0,0,0') arstr
          from ys_zw_ardetail 
          where ardid in (select regexp_substr(p_arid, '[^,]+', 1, level) column_value from dual
                          connect by --prior dbms_random.value is not null and
                          level <= length(p_arid) - length(replace(p_arid, ',', '')) + 1) 
          group by ardid
        )
        select listagg(arstr,'|') within group(order by arstr)||'|' into v_arstr from arstr_tab;
      end if;
      
      --调用水司柜台缴费      
      pg_paid.poscustforys(p_sbid => v_sbid,
           p_arstr => v_arstr,
           p_position => v_position,
           p_oper => p_oper,
           p_paypoint => v_paypoint,
           p_payway => p_payway,
           p_payment => p_payment,
           p_batch => null,
           p_pid => v_pid);
           
     p_gnm := '999';
     p_cwxx := '缴费成功';
  exception
    when others then
      p_gnm := '000';
      p_cwxx := '缴费失败';
  end find_gtjf_jf;
  
end;
/

prompt
prompt Creating package body PG_PAID
prompt =============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_PAID IS
  CURDATETIME DATE;

  FUNCTION OBTWYJ(P_SDATE IN DATE, P_EDATE IN DATE, P_JE IN NUMBER)
    RETURN NUMBER IS
    V_RESULT NUMBER;
  BEGIN
    V_RESULT := P_JE * (TRUNC(P_EDATE) - TRUNC(P_SDATE) + 1) * 0.003;
    V_RESULT := PG_CB_COST.GETMAX(V_RESULT, 0);
    RETURN V_RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --违约金计算
  function ObtWyjAdj(p_arid     in varchar2, --应收流水
                     p_ardpiids in varchar2, --应收明细费项串'01|02|03'
                     p_edate    in date --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) return number is
    vresult          number;
    v_arzndate       ys_zw_arlist.arzndate%type;
    v_arznj          ys_zw_arlist.arznj%type;
    v_outflag        ys_zw_arlist.aroutflag%type;
    v_sbid           ys_zw_arlist.sbid%type;
    v_arje           ys_zw_arlist.arje%type;
    v_yhifzn         ys_yh_custinfo.yhifzn%type;
    v_arznjreducflag ys_zw_arlist.arznjreducflag%type;
    v_chargetype     varchar2(10);
  begin
    BEGIN
      select a.sbid,
             max(arzndate),
             max(arznj),
             max(aroutflag),
             sum(ardje),
             max(yhifzn),
             max(arznjreducflag),
             max(NVL(sbchargetype, 'X'))
        into v_sbid,
             v_arzndate,
             v_arznj,
             v_outflag,
             v_arje,
             v_yhifzn,
             v_arznjreducflag,
             v_chargetype
        from ys_zw_arlist   a,
             ys_yh_custinfo b,
             ys_zw_ardetail c,
             ys_yh_sbinfo   d
       where a.sbid = d.sbid
         and b.yhid = d.yhid
         and a.arid = c.ardid
         and instr(p_ardpiids, ardpiid) > 0
         and arid = p_arid
       group by arid, a.sbid;
    exception
      when others then
        raise;
    END;
  
    --暂时屏蔽
    --return 0;
  
    if v_yhifzn = 'N' or v_chargetype in ('D', 'T') then
      return 0;
    end if;
    if v_arje < 0 then
      v_arje := 0;
    end if;
    if v_arznjreducflag = 'Y' then
      return v_arznj;
    end if;
  
    vresult := ObtWyj(v_arzndate, p_edate, v_arje);
    --不得超过本金
    if vresult > v_arje then
      vresult := v_arje;
    end if;
  
    return trunc(vresult, 2);
  exception
    when others then
      return 0;
  end;
  /*==========================================================================
  水司柜台缴费（一表）,参数简化版
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE POSCUSTFORYS(P_SBID     IN VARCHAR2,
                         P_ARSTR    IN VARCHAR2,
                         P_POSITION IN VARCHAR2,
                         P_OPER     IN VARCHAR2,
                         P_PAYPOINT IN VARCHAR2,
                         P_PAYWAY   IN VARCHAR2,
                         P_PAYMENT  IN NUMBER,
                         P_BATCH    IN VARCHAR2,
                         P_PID      OUT VARCHAR2) IS
  
    V_PARM_AR  PARM_PAYAR;
    V_PARM_ARS PARM_PAYAR_TAB;
  BEGIN
    V_PARM_AR  := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS := PARM_PAYAR_TAB();
    FOR I IN 1 .. FMID(P_ARSTR, '|') - 1 LOOP
      V_PARM_AR.ARID     := PG_CB_COST.FGETPARA(P_ARSTR, I, 1);
      V_PARM_AR.ARDPIIDS := REPLACE(REPLACE(PG_CB_COST.FGETPARA(P_ARSTR,
                                                                I,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      V_PARM_AR.ARWYJ    := PG_CB_COST.FGETPARA(P_ARSTR, I, 3);
      V_PARM_AR.FEE1     := PG_CB_COST.FGETPARA(P_ARSTR, I, 4);
      V_PARM_AR.FEE2     := PG_CB_COST.FGETPARA(P_ARSTR, I, 5);
      V_PARM_AR.FEE3     := PG_CB_COST.FGETPARA(P_ARSTR, I, 6);
      V_PARM_ARS.EXTEND;
      V_PARM_ARS(V_PARM_ARS.LAST) := V_PARM_AR;
    END LOOP;
  
    POSCUST(P_SBID,
            V_PARM_ARS,
            P_POSITION,
            P_OPER,
            P_PAYPOINT,
            P_PAYWAY,
            P_PAYMENT,
            P_BATCH,
            P_PID);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  水司柜台缴费（一表）
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ars   in out parm_payr_tab :单表待销应收包成员参数如下：
                            arid  in number :应收流水（依此成员次序销帐）
                            ardpiids in varchar2 :费用项目串（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统费项1
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  */
  PROCEDURE POSCUST(P_SBID     IN VARCHAR2,
                    P_PARM_ARS IN PARM_PAYAR_TAB,
                    P_POSITION IN VARCHAR2,
                    P_OPER     IN VARCHAR2,
                    P_PAYPOINT IN VARCHAR2,
                    P_PAYWAY   IN VARCHAR2,
                    P_PAYMENT  IN NUMBER,
                    P_BATCH    IN VARCHAR2,
                    P_PID      OUT VARCHAR2) IS
    VBATCH       VARCHAR2(10);
    VSEQNO       VARCHAR2(10);
    V_PARM_ARS   PARM_PAYAR_TAB;
    VREMAINAFTER NUMBER;
    V_PARM_COUNT NUMBER;
  BEGIN
    VBATCH     := P_BATCH;
    V_PARM_ARS := P_PARM_ARS;
    --核心部分校验
    FOR I IN (SELECT A.AROUTFLAG
                FROM YS_ZW_ARLIST A, TABLE(V_PARM_ARS) B
               WHERE A.ARID = B.ARID) LOOP
      IF 允许重复销帐 = 0 AND I.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO V_PARM_COUNT FROM TABLE(V_PARM_ARS) B;
    IF V_PARM_COUNT = 0 THEN
      IF P_PAYMENT > 0 THEN
        --单缴预存核心
        PRECUST(P_SBID        => P_SBID,
                P_POSITION    => P_POSITION,
                P_OPER        => P_OPER,
                P_PAYWAY      => P_PAYWAY,
                P_PAYMENT     => P_PAYMENT,
                P_MEMO        => NULL,
                P_BATCH       => VBATCH,
                O_PID         => P_PID,
                O_REMAINAFTER => VREMAINAFTER);
      ELSE
        NULL;
        --退预存核心
        PRECUSTBACK(P_SBID        => P_SBID,
                    P_POSITION    => P_POSITION,
                    P_OPER        => P_OPER,
                    P_PAYWAY      => P_PAYWAY,
                    P_PAYMENT     => P_PAYMENT,
                    P_MEMO        => NULL,
                    P_BATCH       => VBATCH,
                    O_PID         => P_PID,
                    O_REMAINAFTER => VREMAINAFTER);
      END IF;
    ELSE
      PAYCUST(P_SBID,
              V_PARM_ARS,
              PTRANS_柜台缴费,
              P_POSITION,
              P_PAYPOINT,
              NULL,
              NULL,
              P_OPER,
              P_PAYWAY,
              P_PAYMENT,
              NULL,
              不提交,
              局部屏蔽通知,
              允许拆帐,
              VBATCH,
              VSEQNO,
              P_PID,
              VREMAINAFTER);
    END IF;
  
    --提交处理
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      raise_application_error(errcode, sqlerrm);
  END;
  /*==========================================================================
  一水表多应收销帐
  paymeter
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ARs   in out parm_payAR_tab :可以为空（预存充值），待销应收包结构如下：
                            ARid  in number :应收流水（依此成员次序销帐）
                            Ardpiids in varchar2 :费用项目串，必须是YS_ZW_ARDETAIL的全集（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            ARznj in number :传入的实收违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统实收费项1
  p_trans      in varchar2 :缴费事务
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_paypoint   in varchar2 :缴费点，缴费单位下级需要分收费网点点统计需要，可以为空
  p_bdate      in date :前台日期，银行交易日期(yyyy-mm-dd hh24:mi:ss '2014-02-10 13:53:01')
  p_bseqno     in varchar2 :前台流水，银行交易流水
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payee      in varchar2 :收款员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid_source in number   :可空，正常销帐时为空，也即实参为空赋值为新的实收流水号，部分退费追销时许传原实收流水用于实收行绑定
  p_commit     in number   :提交方式（0:执行成功后不提交；
                                      1:执行成功后提交；
                                      2:调试，或执行成功后提交，到模拟表）
  p_ctl_msg  in number   :全局控制参数“禁止所有通知”条件下，是否发送通知服务，组织统一缴费交易通知内容，通过sendmsg发送到外部接口（短信、微信等），
                            外部调用时选择是否需要本缴费交易核心统一组织内容（退费时通知内容得在退费头过程中组织，调用时避免本过程重复发送需要屏蔽）
                            通知客户  = 1
                            不通知客户= 0
  【输出参数说明】：
  p_batch      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_seqno      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_pid        out number：返回销帐成功后的交易流水，供父过程调用
  【过程说明】：
  1、一水表任意多月销帐次核心过程，提供各缴费事务过程调用；
  2、实收 = 销帐+实收违约金+预存（净增）+预存（净减）+其他非系统费项123；
  3、支持预存、期末负预存（依赖全局包常量：是否预存、是否负预存）；
  4、支持有且仅有违约金应收记录（无水费、追补违约金功能产生）；
  5、最小销帐单元为应收明细行或仅应收违约金，销帐前p_parm_rls.rdpiids中成员如有N勾选状态时先执行【应收调整.部分销帐】，之后重构【待销应收包】
  6、【重构待销应收包】基础上对其中目前是未销状态的全部销帐
  7、最后判断整体实收溢出时（待销中存在其它实收事务已销、前台预存）
     1）启用预存时，销帐后做期末预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用预存时，抛出异常；
  8、整体实收不足时
     1）启用负预存时，销帐后做期末负预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用负预存时，抛出异常；
  9、关于部分勾选费项缴费时补充说明，违约金在前台重算，并且违约金只从属于应收帐头无须分解到应收明细
  【更新日志】：
  */
  PROCEDURE PAYCUST(P_SBID        IN VARCHAR2,
                    P_PARM_ARS    IN PARM_PAYAR_TAB,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_PID_SOURCE  IN VARCHAR2,
                    P_COMMIT      IN NUMBER,
                    P_CTL_MSG     IN NUMBER,
                    P_CTL_PRE     IN NUMBER,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    P_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_MA(VMAMID VARCHAR2) IS
      SELECT * FROM YS_YH_ACCOUNT WHERE SBID = VMAMID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    MI         YS_YH_SBINFO%ROWTYPE;
    CI         YS_YH_CUSTINFO%ROWTYPE;
    MA         YS_YH_ACCOUNT%ROWTYPE;
    P          YS_ZW_PAIDMENT%ROWTYPE;
    V_PARM_ARS PARM_PAYAR_TAB;
    P_PARM_AR  parm_payar;
    v_exists   NUMBER;
  BEGIN
    V_PARM_ARS := P_PARM_ARS;
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
    BEGIN
      --取水表信息
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '水表编码【' || P_SBID || '】不存在！');
      END IF;
      --取用户信息
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '这个水表编码没对应用户！' || P_SBID);
      END IF;
      --取用户银行账户信息
      OPEN C_MA(MI.SBID);
      FETCH C_MA
        INTO MA;
      IF C_MA%NOTFOUND OR C_MA%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --参数校验
      /*if p_parm_rls is null then
        raise_application_error(errcode, '待销帐包是空的怎么办？');
      end if;*/
      --添加核心校验,避免户号与待销账列表不一致
      IF P_PARM_ARS.COUNT > 0 THEN
        --可以为空（预存充值时）
        FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
          P_PARM_AR := P_PARM_ARS(I);
          SELECT COUNT(1)
            INTO V_EXISTS
            FROM YS_ZW_ARLIST A, YS_YH_SBINFO B
           WHERE ARID = P_PARM_AR.ARID
             AND A.SBID = B.SBID
             AND (B.SBID = P_SBID OR SBPRIID = P_SBID);
          IF V_EXISTS = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '请求参数错误，请刷新页面后重新操作!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2、记录实收
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO P_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE  := MI.HIRE_CODE;
      P.PID        := P_PID; --varchar2(10)      流水号
      P.YHID       := CI.YHID; --varchar2(10)      用户编号
      P.SBID       := P_SBID; --varchar2(10)  y    水表编号
      P.PDDATE     := TRUNC(SYSDATE); --date  y    帐务日期
      P.PDATETIME  := SYSDATE; --date  y    发生日期
      P.PDMONTH    := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      P.MANAGE_NO  := P_POSITION; --varchar2(10)  y    缴费机构
      P.PDTRAN     := P_TRANS; --char(1)      缴费事务
      P.PDPERS     := P_OPER; --varchar2(20)  y    销帐人员
      P.PDSAVINGQC := NVL(MI.SBSAVING, 0); --number(12,2)  y    期初预存余额
      P.PDSAVINGBQ := P_PAYMENT; --number(12,2)  y    本期发生预存金额
      P.PDSAVINGQM := P.PDSAVINGQC + P.PDSAVINGBQ; --number(12,2)  y    期末预存余额
      P.PAIDMENT   := P_PAYMENT; --number(12,2)  y    付款金额
      P.PDIFSAVING := NULL; --char(1)  y    找零转预存
      P.PDCHANGE   := NULL; --number(12,2)  y    找零金额
      P.PDPAYWAY   := P_PAYWAY; --varchar2(6)  y    付款方式
      P.PDBSEQNO   := P_BSEQNO; --varchar2(20)  y    银行流水(银行实时收费交易流水)
      P.PDCSEQNO   := NULL; --varchar2(20)  y    清算中心流水(no use)
      P.PDBDATE    := P_BDATE; --date  y    银行日期(银行缴费账务日期)
      P.PDCHKDATE  := NULL; --date  y    对帐日期
      P.PDCCHKFLAG := 'N'; --char(1)  y    标志(no use)
      P.PDCDATE    := NULL; --date  y    清算日期
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO      := P_SEQNO; --varchar2(10)  y    缴费交易流水(no use)
      P.PDPAYEE      := P_OPER; --varchar2(20)  y    收款员
      P.PDCHBATCH    := NULL; --varchar2(10)  y    支票交易批次
      P.PDMEMO       := NULL; --varchar2(200)  y    备注
      P.PDPAYPOINT   := P_PAYPOINT; --varchar2(10)  y    缴费地点
      P.PDSXF        := 0; --number(12,2)  y    手续费
      P.PDILID       := NULL; --varchar2(40)  y    发票流水号
      P.PDFLAG       := 'Y'; --varchar2(1)  y    实收标志（全部为y.暂无启用）
      P.PDWYJ        := 0; --number(12,2)  y    实收滞金
      P.PDRCRECEIVED := P_PAYMENT; --number(12,2)  y      实际收款金额（实际收款金额 =  付款金额 -找零金额；销帐金额 + 实收滞金 + 手续费 + 本期发生预存金额）
      P.PDSPJE       := 0; --number(12,2)  y    销帐金额(如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0)
      P.PREVERSEFLAG := 'N'; --varchar2(1)  y    冲正标志（收水费收预存是为n,冲水费冲预存被冲实收和冲实收产生负帐匀为y）
      IF P_PID_SOURCE IS NULL THEN
        P.PDSCRID    := P.PID;
        P.PDSCRTRANS := P.PDTRAN;
        P.PDSCRMONTH := P.PDMONTH;
        P.PDSCRDATE  := P.PDDATE;
      ELSE
        SELECT PID, PDTRAN, PDMONTH, PDDATE
          INTO P.PDSCRID, P.PDSCRTRANS, P.PDSCRMONTH, P.PDSCRDATE
          FROM YS_ZW_PAIDMENT
         WHERE PID = P_PID_SOURCE;
      END IF;
      P.PDCHKNO  := NULL; --varchar2(10)  y    进账单号
      P.PDPRIID  := MI.SBPRIID; --varchar2(20)  y    合收主表号  20150105
      P.TCHKDATE := NULL; --date  y    到账日期
    END;
  
    --3、部分费项销帐分帐
    --------------------------------------------------------------------------
    IF P_CTL_PRE = 允许拆帐 THEN
      PAYZWARPRE(V_PARM_ARS, 不提交);
    END IF;
  
    --3.1、含违约金销帐分帐
    --------------------------------------------------------------------------
    IF 允许销帐违约金分帐 THEN
      PAYWYJPRE(V_PARM_ARS, 不提交);
    END IF;
  
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    --------------------------------------------------------------------------
    PAYZWARCORE(P.PID,
                P.PDBATCH,
                P_PAYMENT,
                MI.SBSAVING,
                P.PDDATE,
                P.PDMONTH,
                V_PARM_ARS,
                不提交,
                P.PDSPJE,
                P.PDWYJ,
                P.PDSXF);
  
    --5、重算预存发生、预存期末、更新用户预存余额
    P.PDSAVINGQM := P.PDSAVINGQC + P_PAYMENT - P.PDSPJE - P.PDWYJ - P.PDSXF;
    P.PDSAVINGBQ := P.PDSAVINGQM - P.PDSAVINGQC;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --6、返回预存余额
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --7、事务内应实收帐务平衡校验，及校验后分支子过程
    --------------------------------------------------------------------------
  
    --8、其他缴费事务反馈过程
  
    --5、提交处理
    BEGIN
      CLOSE C_MA;
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_PAIDMENT VALUES P;
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MA%ISOPEN THEN
        CLOSE C_MA;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  部分费用项目销帐前拆分应收（一应收帐）：重要规则：销帐包非空时拒绝0金额实销
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是YS_ZW_ARDETAIL的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  2、若存在部分费用销帐标志位（且费项额非0）则按应收调整方式拆分应收帐，否则原包返回；
  3、重构待全额销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE PAYZWARPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                       P_COMMIT   IN NUMBER DEFAULT 不提交) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_RD(VARID VARCHAR2, VARDPIID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
         AND ARDPIID = VARDPIID
       ORDER BY ARDCLASS
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    P_PARM_AR          PARM_PAYAR; --销帐包内成员之一
    I                  INTEGER;
    J                  INTEGER;
    K                  INTEGER;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
    总金额             NUMBER(13, 3) := 0;
    待销笔数           NUMBER(10) := 0;
    不销笔数           NUMBER(10) := 0;
    待销水量           NUMBER(10) := 0;
    不销水量           NUMBER(10) := 0;
    待销金额           NUMBER(13, 3) := 0;
    不销金额           NUMBER(13, 3) := 0;
    --被调整原应收
    RL YS_ZW_ARLIST%ROWTYPE;
    RD YS_ZW_ARDETAIL%ROWTYPE;
    --拆后应收1（要销的）
    RLY    YS_ZW_ARLIST%ROWTYPE;
    RDY    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABY RD_TABLE;
    --拆后应收2（不销继续挂欠费的）
    RLN    YS_ZW_ARLIST%ROWTYPE;
    RDN    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABN RD_TABLE;
    --
    O_ARID_REVERSE        YS_ZW_ARLIST.ARID%TYPE;
    O_ARTRANS_REVERSE     VARCHAR2(10);
    O_ARJE_REVERSE        NUMBER;
    O_ARZNJ_REVERSE       NUMBER;
    O_ARSXF_REVERSE       NUMBER;
    O_ARSAVINGBQ_REVERSE  NUMBER;
    IO_ARSAVINGQM_REVERSE NUMBER;
    --
    CURRENTDATE DATE;
  BEGIN
    CURRENTDATE := SYSDATE;
    --可以为空（预存充值时），空包返回
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '销帐包中应收流水不存在' || P_PARM_AR.ARID);
          END IF;
          IF P_PARM_AR.ARDPIIDS IS NOT NULL THEN
            RLY      := RL;
            RLY.ARJE := 0;
            RDTABY   := NULL;
          
            RLN        := RL;
            RLN.ARJE   := 0;
            RLN.ARSXF  := 0; --Rlfee（如有）都放rlY，且必须销帐，暂不支持拆分
            RDTABN     := NULL;
            待销笔数   := 0;
            不销笔数   := 0;
            待销水量   := 0;
            不销水量   := 0;
            待销金额   := 0;
            不销金额   := 0;
            一行费项数 := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
            FOR J IN 1 .. 一行费项数 LOOP
              一行一费项待销标志 := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
              一行一费项         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
              OPEN C_RD(P_PARM_AR.ARID, 一行一费项);
              LOOP
                --存在阶梯，所以要循环
                FETCH C_RD
                  INTO RD;
                EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
                RDY    := RD;
                RDN    := RD;
                总金额 := 总金额 + RD.ARDJE;
                IF 一行一费项待销标志 = 'Y' THEN
                  RLY.ARJE     := RLY.ARJE + RDY.ARDJE;
                  待销笔数     := 待销笔数 + 1;
                  待销水量     := 待销水量 + RD.ARDSL;
                  待销金额     := 待销金额 + RD.ARDJE;
                  RDN.ARDYSSL  := 0;
                  RDN.ARDYSJE  := 0;
                  RDN.ARDSL    := 0;
                  RDN.ARDJE    := 0;
                  RDN.ARDADJSL := 0;
                  RDN.ARDADJJE := 0;
                ELSIF 一行一费项待销标志 = 'N' THEN
                  RLN.ARJE     := RLN.ARJE + RDN.ARDJE;
                  不销笔数     := 不销笔数 + 1;
                  不销水量     := 不销水量 + RD.ARDSL;
                  不销金额     := 不销金额 + RD.ARDJE;
                  RDY.ARDYSSL  := 0;
                  RDY.ARDYSJE  := 0;
                  RDY.ARDSL    := 0;
                  RDY.ARDJE    := 0;
                  RDY.ARDADJSL := 0;
                  RDY.ARDADJJE := 0;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                          '无法识别销帐包中待销帐标志');
                END IF;
                --复制到rdY
                IF RDTABY IS NULL THEN
                  RDTABY := RD_TABLE(RDY);
                ELSE
                  RDTABY.EXTEND;
                  RDTABY(RDTABY.LAST) := RDY;
                END IF;
                --复制到rdN
                IF RDTABN IS NULL THEN
                  RDTABN := RD_TABLE(RDN);
                ELSE
                  RDTABN.EXTEND;
                  RDTABN(RDTABN.LAST) := RDN;
                END IF;
              END LOOP;
              CLOSE C_RD;
            END LOOP;
            --某一条应收帐发生部分销帐标志才拆分
            IF 待销笔数 != 0 THEN
              IF 不销笔数 != 0 THEN
                --应收调整1：在本期全额冲减
                ZWARREVERSECORE(P_PARM_AR.ARID,
                                RL.ARTRANS,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                不提交,
                                O_ARID_REVERSE,
                                O_ARTRANS_REVERSE,
                                O_ARJE_REVERSE,
                                O_ARZNJ_REVERSE,
                                O_ARSXF_REVERSE,
                                O_ARSAVINGBQ_REVERSE,
                                IO_ARSAVINGQM_REVERSE);
                --应收调整2.1：在本期追加目标应收（待销帐部分）
                RLY.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLY.ARMONTH    := FOBTMANAPARA(RLY.MANAGE_NO, 'READ_MONTH');
                RLY.ARDATE     := TRUNC(SYSDATE);
                RLY.ARDATETIME := CURRENTDATE;
                RLY.ARREADSL   := 0;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABY(K).ARDID FROM DUAL;
                  RDTABY(K).ARDID := RLY.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLY;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABY (K);
                END LOOP;
                --应收调整2.2：在本期追加目标应收（继续挂欠费部分）
                RLN.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLN.ARMONTH    := FOBTMANAPARA(RLN.MANAGE_NO, 'READ_MONTH');
                RLN.ARDATE     := TRUNC(SYSDATE);
                RLN.ARDATETIME := CURRENTDATE;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABN(K).ARDID FROM DUAL;
                  RDTABN(K).ARDID := RLN.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLN;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABN (K);
                END LOOP;
                --重构销帐包返回
                P_PARM_ARS(I).ARID := RLY.ARID;
                P_PARM_ARS(I).ARDPIIDS := REPLACE(P_PARM_ARS(I).ARDPIIDS,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --待销笔数=0
              P_PARM_ARS.DELETE(I);
            END IF;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    
    END IF;
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  应收冲正核心
  【输入参数说明】：
  p_arid_source  in number ：被冲的原应收记录流水号；
  p_pid_reverse  in number ：（可空参数），冲正、退费调用时需要传前置过程产生的冲正实收流水号；
                              在此过程中依此与冲正应收记录绑定
  p_ppayment_reverse in number ：（可空参数），同上参数冲正、退费调用时需要传前置过程产生的冲正实收金额（负），
                                  对已销帐应收的冲正时：
                                  1）依此保持的销帐记录和实收记录的帐务平衡；
                                  2）依此控制销帐预存发生（例如退费不需要发生预存增减、实收冲正时可能有）;
  p_memo ：外部传入帐务备注信息
  p_commit ： 是否过程内提交
  【输出参数说明】：
  o_arid_reverse out varchar2：冲正应收流水
  o_artrans_reverse out varchar2：冲正应收事务
  o_arje_reverse out number：冲正销帐金额
  o_arznj_reverse out number：冲正销帐违约金
  o_arsxf_reverse out number：冲正销帐其他费1
  o_arsavingbq_reverse out number：冲正销帐预存发生
  io_arsavingqm_reverse in out number：外部冲正'销帐应收'循环时的期末预存（累减器）
  【过程说明】：
  基于一条应收总帐记录全额冲正，如应收总账同时为销帐记录，还要更新本冲正帐记录的销帐信息；
  提供销帐预处理、实收冲正、退费、应收调整等业务过程调用；
  【更新日志】：
  */
  PROCEDURE ZWARREVERSECORE(P_ARID_SOURCE         IN VARCHAR2,
                            P_ARTRANS_REVERSE     IN VARCHAR2,
                            P_PBATCH_REVERSE      IN VARCHAR2,
                            P_PID_REVERSE         IN VARCHAR2,
                            P_PPAYMENT_REVERSE    IN NUMBER,
                            P_MEMO                IN VARCHAR2,
                            P_CTL_MIRCODE         IN VARCHAR2,
                            P_COMMIT              IN NUMBER DEFAULT 不提交,
                            O_ARID_REVERSE        OUT VARCHAR2,
                            O_ARTRANS_REVERSE     OUT VARCHAR2,
                            O_ARJE_REVERSE        OUT NUMBER,
                            O_ARZNJ_REVERSE       OUT NUMBER,
                            O_ARSXF_REVERSE       OUT NUMBER,
                            O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                            IO_ARSAVINGQM_REVERSE IN OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
       ORDER BY ARDPIID, ARDCLASS
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_P_REVERSE(VRPID VARCHAR2) IS
      SELECT * FROM YS_ZW_PAIDMENT WHERE PID = VRPID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    SUBTYPE RD_TYPE IS YS_ZW_ARDETAIL%ROWTYPE;
    TYPE RD_TABLE IS TABLE OF RD_TYPE;
    --被冲正原应收
    RL_SOURCE YS_ZW_ARLIST%ROWTYPE;
    RD_SOURCE YS_ZW_ARDETAIL%ROWTYPE;
    --冲正应收
    RL_REVERSE     YS_ZW_ARLIST%ROWTYPE;
    RD_REVERSE     YS_ZW_ARDETAIL%ROWTYPE;
    RD_REVERSE_TAB RD_TABLE;
    --
    P_REVERSE YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    OPEN C_RL(P_ARID_SOURCE);
    FETCH C_RL
      INTO RL_SOURCE;
    IF C_RL%FOUND THEN
      --核心部分校验
      IF 允许重复销帐 = 0 AND RL_SOURCE.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    
      RL_REVERSE                := RL_SOURCE;
      RL_REVERSE.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
      RL_REVERSE.ARDATE         := TRUNC(SYSDATE);
      RL_REVERSE.ARDATETIME     := SYSDATE; --20140514 add
      RL_REVERSE.ARMONTH        := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                                'READ_MONTH');
      RL_REVERSE.ARCD           := 贷方;
      RL_REVERSE.ARREADSL       := -RL_REVERSE.ARREADSL; --20140707 add
      RL_REVERSE.ARSL           := -RL_REVERSE.ARSL;
      RL_REVERSE.ARJE           := -RL_REVERSE.ARJE; --须全冲
      RL_REVERSE.ARZNJREDUCFLAG := RL_REVERSE.ARZNJREDUCFLAG;
      RL_REVERSE.ARZNJ          := -RL_REVERSE.ARZNJ; --若销帐则冲正原应收销帐违约金,未销则冲应收违约金
      RL_REVERSE.ARSXF          := -RL_REVERSE.ARSXF; --若销帐则冲正原应收销帐其他费1，,未销则冲应收其他费1
      RL_REVERSE.ARREVERSEFLAG  := 'Y';
      RL_REVERSE.ARMEMO         := P_MEMO;
      RL_REVERSE.ARTRANS        := P_ARTRANS_REVERSE;
      --应收冲正父过程调用下，销帐信息继承源帐
      --实收冲正父过程调用下，销帐信息改写，并判断实收冲正方法
      --退款：实收计‘实收冲销’事务C，应收计‘冲正’事务C
      --不退款：继承原实收、应收事务
      IF P_PID_REVERSE IS NOT NULL THEN
        OPEN C_P_REVERSE(P_PID_REVERSE);
        FETCH C_P_REVERSE
          INTO P_REVERSE;
        IF C_P_REVERSE%NOTFOUND OR C_P_REVERSE%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '冲正负帐不存在');
        END IF;
        CLOSE C_P_REVERSE;
      
        RL_REVERSE.ARPAIDDATE  := TRUNC(SYSDATE); --若销帐则记录冲正帐期
        RL_REVERSE.ARPAIDMONTH := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                               'READ_MONTH'); --若销帐则记录冲正帐期
      
        RL_REVERSE.ARPAIDJE   := P_PPAYMENT_REVERSE; --销帐信息改写
        RL_REVERSE.ARSAVINGQC := (CASE
                                   WHEN IO_ARSAVINGQM_REVERSE IS NULL THEN
                                    P_REVERSE.PDSAVINGQC
                                   ELSE
                                    IO_ARSAVINGQM_REVERSE
                                 END); --销帐信息初改写
        RL_REVERSE.ARSAVINGBQ := RL_REVERSE.ARPAIDJE - RL_REVERSE.ARJE -
                                 RL_REVERSE.ARZNJ - RL_REVERSE.ARSXF; --销帐信息改写
        RL_REVERSE.ARSAVINGQM := RL_REVERSE.ARSAVINGQC +
                                 RL_REVERSE.ARSAVINGBQ; --销帐信息改写
        RL_REVERSE.ARPID      := P_PID_REVERSE;
        RL_REVERSE.ARPBATCH   := P_PBATCH_REVERSE;
        IO_ARSAVINGQM_REVERSE := RL_REVERSE.ARSAVINGQM;
      END IF;
      --rlscrrlid    := ;--继承原应收值
      --rlscrrldate  := ;--继承原应收值
      --rlscrrlmonth := ;--继承原应收值
      --rlscrrllb    := ;--继承原应收值
      OPEN C_RD(P_ARID_SOURCE);
      LOOP
        FETCH C_RD
          INTO RD_SOURCE;
        EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
        RD_REVERSE := RD_SOURCE;
        SELECT SEQ_ARID.NEXTVAL INTO RD_REVERSE.ARDID FROM DUAL;
        RD_REVERSE.ARDID    := RL_REVERSE.ARID;
        RD_REVERSE.ARDYSSL  := -RD_REVERSE.ARDYSSL;
        RD_REVERSE.ARDYSJE  := -RD_REVERSE.ARDYSJE;
        RD_REVERSE.ARDSL    := -RD_REVERSE.ARDSL;
        RD_REVERSE.ARDJE    := -RD_REVERSE.ARDJE;
        RD_REVERSE.ARDADJSL := -RD_REVERSE.ARDADJSL;
        RD_REVERSE.ARDADJJE := -RD_REVERSE.ARDADJJE;
        --复制到rd_reverse_tab
        IF RD_REVERSE_TAB IS NULL THEN
          RD_REVERSE_TAB := RD_TABLE(RD_REVERSE);
        ELSE
          RD_REVERSE_TAB.EXTEND;
          RD_REVERSE_TAB(RD_REVERSE_TAB.LAST) := RD_REVERSE;
        END IF;
      END LOOP;
      CLOSE C_RD;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的应收流水号');
    END IF;
    --返回值
    O_ARID_REVERSE       := RL_REVERSE.ARID;
    O_ARTRANS_REVERSE    := RL_REVERSE.ARTRANS;
    O_ARJE_REVERSE       := RL_REVERSE.ARJE;
    O_ARZNJ_REVERSE      := RL_REVERSE.ARZNJ;
    O_ARSXF_REVERSE      := RL_REVERSE.ARSXF;
    O_ARSAVINGBQ_REVERSE := RL_REVERSE.ARSAVINGBQ;
    --2、提交处理
    BEGIN
      CLOSE C_RL;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_ARLIST VALUES RL_REVERSE;
        FOR K IN RD_REVERSE_TAB.FIRST .. RD_REVERSE_TAB.LAST LOOP
          INSERT INTO YS_ZW_ARDETAIL VALUES RD_REVERSE_TAB (K);
        END LOOP;
        UPDATE YS_ZW_ARLIST
           SET ARREVERSEFLAG = 'Y'
         WHERE ARID = P_ARID_SOURCE;
        --其他控制赋值
        IF P_CTL_MIRCODE IS NOT NULL THEN
          UPDATE YS_YH_SBINFO
             SET SBRCODE = TO_NUMBER(P_CTL_MIRCODE)
           WHERE SBID = RL_SOURCE.SBID;
        END IF;
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_P_REVERSE%ISOPEN THEN
        CLOSE C_P_REVERSE;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  销帐违约金分帐销帐包预处理
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是ys_zw_ardetail的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  3、重构待销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE PAYWYJPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                      P_COMMIT   IN NUMBER DEFAULT 不提交) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID;
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARDETAIL WHERE ARDID = VARID;
    P_PARM_AR  PARM_PAYAR := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS PARM_PAYAR_TAB := PARM_PAYAR_TAB();
    --被调整原应收
    RL                 YS_ZW_ARLIST%ROWTYPE;
    RD                 YS_ZW_ARDETAIL%ROWTYPE;
    VEXIST             NUMBER := 0;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
  BEGIN
    --可以为空（预存充值时），空包返回
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARWYJ <> 0 AND P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '销帐包中应收流水不存在' || P_PARM_AR.ARID);
          END IF;
          一行费项数 := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
          FOR J IN 1 .. 一行费项数 LOOP
            一行一费项待销标志 := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
            一行一费项         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
            IF 一行一费项待销标志 = 'N' AND UPPER(一行一费项) = 'ZNJ' THEN
              VEXIST := 1;
            END IF;
          END LOOP;
          IF VEXIST = 1 THEN
            RL.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
            RL.ARJE           := 0;
            RL.ARSL           := 0;
            RL.ARZNJ          := P_PARM_AR.ARWYJ;
            RL.ARMEMO         := '违约金追补';
            RL.ARZNJREDUCFLAG := 'Y';
            OPEN C_RD(P_PARM_AR.ARID);
            LOOP
              FETCH C_RD
                INTO RD;
              EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
              RD.ARDID    := RL.ARID;
              RD.ARDSL    := 0;
              RD.ARDJE    := 0;
              RD.ARDYSSL  := 0;
              RD.ARDYSJE  := 0;
              RD.ARDADJSL := 0;
              RD.ARDADJJE := 0;
              INSERT INTO YS_ZW_ARDETAIL VALUES RD;
            END LOOP;
            INSERT INTO YS_ZW_ARLIST VALUES RL;
            CLOSE C_RD;
            --
            P_PARM_AR.ARID := RL.ARID;
            IF V_PARM_ARS IS NULL THEN
              V_PARM_ARS := PARM_PAYAR_TAB(P_PARM_AR);
            ELSE
              V_PARM_ARS.EXTEND;
              V_PARM_ARS(V_PARM_ARS.LAST) := P_PARM_AR;
            END IF;
            --
            P_PARM_ARS(I).ARWYJ := 0;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    END IF;
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  实收销帐处理核心
  【输入参数说明】：
  p_pid in varchar2,
  p_payment in number：实收金额
  p_remainbefore in number：销帐包处理前的期初用户预存余额
  p_paiddate in date,
  p_paidmonth in varchar2,
  p_parm_rls in parm_pay1rl_tab,可以为空（预存充值时），销帐包说明
                                本过程忽略其rdpiids成员值，默认‘整笔应收总账和关联应收明细全集’全部销帐
                                其它成员详见paymeter说明包构造
  p_commit in number default 不提交：是否提交
  
  【输出参数说明】：
  o_sum_arje out number：累计销帐金额（只含待销应收明细中的金额）
  o_sum_arsavingbq out number：累计预存发生
  
  【过程说明】：
  1、应收销帐包可以为空（预存充值时）；
  2、非空时，也允许销帐包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下；
  3、包内应收总账及其关联应收明细全部销帐；
  4、允许应收总账0金额销帐；
  5、更新应收帐头、明细表中的销帐信息
  6、返回实收结果信息
  7、预存销帐逻辑：按销帐包内应收次序销帐，资金先进先销，销帐后‘实收金额’余额记录（无论正负）到最后一笔销帐记录上
  
  【更新日志】：
  */
  PROCEDURE PAYZWARCORE(P_PID          IN VARCHAR2,
                        P_BATCH        IN VARCHAR2,
                        P_PAYMENT      IN NUMBER,
                        P_REMAINBEFORE IN NUMBER,
                        P_PAIDDATE     IN DATE,
                        P_PAIDMONTH    IN VARCHAR2,
                        P_PARM_ARS     IN PARM_PAYAR_TAB,
                        P_COMMIT       IN NUMBER DEFAULT 不提交,
                        O_SUM_ARJE     OUT NUMBER,
                        O_SUM_ARZNJ    OUT NUMBER,
                        O_SUM_ARSXF    OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARLIST
       WHERE ARID = VARID
         AND ARPAIDFLAG = 'N'
         AND ARREVERSEFLAG = 'N' /*and rlje>0*/ /*支持0金额销帐*/
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    RL          YS_ZW_ARLIST%ROWTYPE;
    P_PARM_AR   PARM_PAYAR;
    SUMRLPAIDJE NUMBER(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    P_REMAIND   NUMBER(13, 3); --期初预存累减器
  BEGIN
    --期初预存累减器初始化
    P_REMAIND := P_REMAINBEFORE;
    --返回值初始化，若销帐包非空但无游标此值返回
    O_SUM_ARJE  := 0;
    O_SUM_ARZNJ := 0;
    O_SUM_ARSXF := 0;
    SAVEPOINT 未销状态;
    IF P_PARM_ARS.COUNT > 0 THEN
      --可以为空（预存充值时）
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        OPEN C_RL(P_PARM_AR.ARID);
        --销帐包非空时，也允许包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下
        FETCH C_RL
          INTO RL;
        IF C_RL%FOUND THEN
          --组织一条待销应收记录更新变量
          RL.ARPAIDFLAG  := 'Y'; --varchar2(1)  y  'n'    是否销账标志（全额销帐、不存在中间状态）
          RL.ARSAVINGQC  := P_REMAIND; --number(13,2)  y  0    销帐期初预存
          RL.ARSAVINGBQ  := -PG_CB_COST.GETMIN(P_REMAIND,
                                               RL.ARJE + P_PARM_AR.ARWYJ +
                                               P_PARM_AR.FEE1); --number(13,2)  y  0    销帐预存发生（净减）
          RL.ARSAVINGQM  := RL.ARSAVINGQC + RL.ARSAVINGBQ; --number(13,2)  y  0    销帐期末预存
          RL.ARZNJ       := P_PARM_AR.ARWYJ; --number(13,2)  y  0    实收违约金
          RL.ARSXF       := P_PARM_AR.FEE1; --number(13,2)  y  0    实收其他非系统费项1
          RL.ARPAIDDATE  := P_PAIDDATE; --date  y      销帐日期（实收帐务时钟）
          RL.ARPAIDMONTH := P_PAIDMONTH; --varchar2(7)  y      销帐月份（实收帐务时钟）
          RL.ARPAIDJE    := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          RL.ARPID       := P_PID; --
          RL.ARPBATCH    := P_BATCH;
          RL.ARMICOLUMN1 := '';
          --中间变量运算
          SUMRLPAIDJE := SUMRLPAIDJE + RL.ARPAIDJE;
          --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
          IF I = P_PARM_ARS.LAST THEN
            RL.ARSAVINGBQ := RL.ARSAVINGBQ + (P_PAYMENT - SUMRLPAIDJE);
            RL.ARSAVINGQM := RL.ARSAVINGQC + RL.ARSAVINGBQ;
            RL.ARPAIDJE   := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          END IF;
          --核心部分校验
          IF NOT 允许预存发生 AND RL.ARSAVINGBQ != 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '当前系统规则为不支持预存发生');
          END IF;
          --反馈实收记录
          O_SUM_ARJE  := O_SUM_ARJE + RL.ARJE;
          O_SUM_ARZNJ := O_SUM_ARZNJ + RL.ARZNJ;
          O_SUM_ARSXF := O_SUM_ARSXF + RL.ARSXF;
          P_REMAIND   := P_REMAIND + RL.ARSAVINGBQ;
          --更新待销帐应收记录
          UPDATE YS_ZW_ARLIST
             SET ARPAIDFLAG  = RL.ARPAIDFLAG,
                 ARSAVINGQC  = RL.ARSAVINGQC,
                 ARSAVINGBQ  = RL.ARSAVINGBQ,
                 ARSAVINGQM  = RL.ARSAVINGQM,
                 ARZNJ       = RL.ARZNJ,
                 ARMICOLUMN1 = RL.ARMICOLUMN1,
                 ARSXF       = RL.ARSXF,
                 ARPAIDDATE  = RL.ARPAIDDATE,
                 ARPAIDMONTH = RL.ARPAIDMONTH,
                 ARPAIDJE    = RL.ARPAIDJE,
                 ARPID       = RL.ARPID,
                 ARPBATCH    = RL.ARPBATCH,
                 AROUTFLAG   = 'N'
           WHERE ARID = RL.ARID; --current of c_rl;效率低
        ELSE
          O_SUM_ARSXF := O_SUM_ARSXF + P_PARM_AR.FEE1;
        END IF;
        CLOSE C_RL;
      END LOOP;
    END IF;
  
    --核心部分校验
    IF 净减为负预存不销帐 AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      O_SUM_ARJE  := 0;
      O_SUM_ARZNJ := 0;
      O_SUM_ARSXF := 0;
      ROLLBACK TO 未销状态;
    END IF;
  
    --核心部分校验
    IF NOT 允许净减后负预存 AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '当前系统规则为不支持发生更多期末负预存');
    END IF;
  
    --5、提交处理
    BEGIN
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存充值（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECUST(P_SBID        IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --校验
    IF P_PAYMENT <= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '预存充值业务金额必须为正数哦');
    END IF;
    --调用核心
    PRECORE(P_SBID,
            PTRANS_独立预存,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            不提交,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存退费（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECUSTBACK(P_SBID        IN VARCHAR2,
                        P_POSITION    IN VARCHAR2,
                        P_OPER        IN VARCHAR2,
                        P_PAYWAY      IN VARCHAR2,
                        P_PAYMENT     IN NUMBER,
                        P_MEMO        IN VARCHAR2,
                        P_BATCH       IN OUT VARCHAR2,
                        O_PID         OUT VARCHAR2,
                        O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --校验
    IF P_PAYMENT >= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '预存充值业务金额必须为负数哦');
    END IF;
    --调用核心
    PRECORE(P_SBID,
            PTRANS_独立预存,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            不提交,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  预存实收处理核心
  【输入参数说明】：
  p_sbid        in varchar2：指定预存发生的水表编号
  p_trans      in varchar2：指定预存发生计帐实收事务
  p_position      in varchar2：指定预存发生缴费单位
  p_paypoint   in varchar2：指定预存发生缴费地点
  p_bdate      in date：指定预存发生银行帐务日期
  p_bseqno     in varchar2：指定预存发生银行交易流水
  p_oper       in varchar2：预存收款人
  p_payway     in varchar2：预存发生付款方式
  p_payment    in number：预存发生金额（+/-）
  p_commit     in number：是否提交
  p_memo       in varchar2：备注信息
  p_batch      in out number：可空，绑定批次
  p_seqno      in out number：可空，绑定批次流水
  【输出参数说明】：
  p_pid        out number：预存发生记录计帐成功后返回的实收流水号
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE PRECORE(P_SBID        IN VARCHAR2,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_COMMIT      IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    MI YS_YH_SBINFO%ROWTYPE;
    CI YS_YH_CUSTINFO%ROWTYPE;
    P  YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    IF NOT 允许预存发生 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '当前系统规则为不支持预存发生');
    END IF;
    --1、校验及其初始化
    BEGIN
      --取水表信息
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '这是传的水表编码？' || P_SBID);
      END IF;
      --取用户信息
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '这个水表编码没对应用户！' || P_SBID);
      END IF;
    END;
  
    --2、记录实收
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO O_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE    := MI.HIRE_CODE;
      P.PID          := O_PID;
      P.YHID         := CI.YHID;
      P.SBID         := MI.SBID;
      P.PDRCRECEIVED := P_PAYMENT;
      P.PDDATE       := TRUNC(SYSDATE);
      P.PDATETIME    := SYSDATE;
      P.PDMONTH      := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH');
      P.MANAGE_NO    := P_POSITION;
      P.PDPAYPOINT   := P_PAYPOINT;
      P.PDTRAN       := P_TRANS;
      P.PDPERS       := P_OPER;
      P.PDPAYEE      := P_OPER;
      P.PDPAYWAY     := P_PAYWAY;
      P.PAIDMENT     := P_PAYMENT;
      P.PDSPJE       := 0;
      P.PDWYJ        := 0;
      P.PDSAVINGQC   := NVL(MI.SBSAVING, 0);
      P.PDSAVINGBQ   := P_PAYMENT;
      P.PDSAVINGQM   := P.PDSAVINGQC + P.PDSAVINGBQ;
      P.PDSXF        := 0; --若为独立押金;
      P.PREVERSEFLAG := 'N'; --帐务状态（收水费收预存是为N,冲水费冲预存被冲实收和冲实收产生负帐匀为Y）
      P.PDBDATE      := TRUNC(P_BDATE);
      P.PDBSEQNO     := P_BSEQNO;
      P.PDCHKDATE    := NULL;
      P.PDCCHKFLAG   := NULL;
      P.PDCDATE      := NULL;
      P.PDCSEQNO     := NULL;
      P.PDMEMO       := P_MEMO;
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO    := P_SEQNO;
      P.PDSCRID    := P.PID;
      P.PDSCRTRANS := P.PDTRAN;
      P.PDSCRMONTH := P.PDMONTH;
      P.PDSCRDATE  := P.PDDATE;
    END;
    P.PDCHKNO     := NULL; --varchar2(10)  y    进账单号
    P.PDPRIID     := MI.SBPRIID; --varchar2(20)  y    合收主表号  20150105
    P.TCHKDATE    := NULL; --date  y    到账日期
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --校验
    IF NOT 允许净减后负预存 AND P.PDSAVINGQM < 0 AND P.PDSAVINGQM < P.PDSAVINGQC THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '当前系统规则为不支持发生更多的期末负预存');
    END IF;
    INSERT INTO YS_ZW_PAIDMENT VALUES P;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --5、提交处理
    BEGIN
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = 调试 THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = 提交 THEN
          COMMIT;
        ELSIF P_COMMIT = 不提交 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  FUNCTION FMID(P_STR IN VARCHAR2, P_SEP IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    I INTEGER;
    N INTEGER := 1;
  BEGIN
    IF TRIM(P_STR) IS NULL THEN
      RETURN 0;
    ELSE
      FOR I IN 1 .. LENGTH(P_STR) LOOP
        IF SUBSTR(P_STR, I, 1) = P_SEP THEN
          N := N + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN N;
  END;
  
   --1、实收冲正（当月负实收）
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER) IS
    CURSOR c_p(Vpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vpid FOR UPDATE NOWAIT;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi        Ys_Yh_Sbinfo%ROWTYPE;
    p_Source  Ys_Zw_Paidment%ROWTYPE;
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_p(p_Pid_Source);
    FETCH c_p
      INTO p_Source;
    IF c_p%FOUND THEN
      OPEN c_Mi(p_Source.Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无效的用户编号');
      END IF;
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid_Reverse
        FROM Dual;
      SELECT Sys_Guid() INTO p_Reverse.Id FROM Dual;
      p_Reverse.Hire_Code  := Mi.Hire_Code;
      p_Reverse.Pid        := o_Pid_Reverse;
      p_Reverse.Yhid       := p_Source.Yhid;
      p_Reverse.Sbid       := p_Source.Sbid;
      p_Reverse.Pddate     := Trunc(SYSDATE);
      p_Reverse.Pdatetime  := SYSDATE;
      p_Reverse.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      p_Reverse.Manage_No  := p_Position;
      p_Reverse.Pdtran     := p_Ptrans;
      p_Reverse.Pdpers     := p_Oper;
      p_Reverse.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    期初预存余额
      p_Reverse.Pdsavingbq := -p_Source.Pdsavingbq;
      p_Reverse.Pdsavingqm := p_Reverse.Pdsavingqc + p_Reverse.Pdsavingbq; --number(12,2)  y    期末预存余额;
      p_Reverse.Paidment   := -p_Source.Paidment;
      /* --核心部分校验
      if not 允许预存发生 and p_reverse.psavingbq != 0 then
        raise_application_error(errcode, '当前系统规则为不支持预存发生');
      end if;
      if not 允许净减后负预存 and p_reverse.pdsavingqm < 0 and
         p_reverse.pdsavingqm < p_reverse.pdsavingqc then
        raise_application_error(errcode,
                                '当前系统规则为不支持发生更多的期末负预存');
      end if;*/
      UPDATE Ys_Yh_Sbinfo
         SET Sbsaving = p_Reverse.Pdsavingqm
       WHERE CURRENT OF c_Mi;
    
      p_Reverse.Pdifsaving := NULL;
      p_Reverse.Pdchange   := NULL;
      p_Reverse.Pdpayway   := p_Payway;
      p_Reverse.Pdbseqno   := p_Source.Pdbseqno;
      p_Reverse.Pdcseqno   := p_Source.Pdcseqno;
      p_Reverse.Pdbdate    := p_Source.Pdbdate;
      p_Reverse.Pdchkdate  := p_Source.Pdchkdate;
      p_Reverse.Pdcchkflag := p_Source.Pdcchkflag;
      p_Reverse.Pdcdate    := p_Source.Pdcdate;
      /*IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO p_reverse.PDBATCH
          FROM DUAL;
      ELSE
        p_reverse.PDBATCH := P_BATCH;
      END IF;*/
      p_Reverse.Pdbatch      := p_Source.Pdbatch;
      p_Reverse.Pdseqno      := p_Source.Pdseqno;
      p_Reverse.Pdpayee      := p_Source.Pdpayee;
      p_Reverse.Pdchbatch    := p_Source.Pdchbatch;
      p_Reverse.Pdmemo       := p_Source.Pdmemo;
      p_Reverse.Pdpaypoint   := p_Source.Pdpaypoint;
      p_Reverse.Pdsxf        := -p_Source.Pdsxf;
      p_Reverse.Pdilid       := p_Source.Pdilid;
      p_Reverse.Pdflag       := p_Source.Pdflag;
      p_Reverse.Pdwyj        := -p_Source.Pdwyj;
      p_Reverse.Pdrcreceived := -p_Source.Pdrcreceived;
      p_Reverse.Pdspje       := p_Source.Pdspje;
      p_Reverse.Preverseflag := 'Y';
      IF p_Pid_Source IS NULL THEN
        p_Reverse.Pdscrid    := p_Source.Pid;
        p_Reverse.Pdscrtrans := p_Source.Pdtran;
        p_Reverse.Pdscrmonth := p_Source.Pdmonth;
        p_Reverse.Pdscrdate  := p_Source.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p_Reverse.Pdscrid,
               p_Reverse.Pdscrtrans,
               p_Reverse.Pdscrmonth,
               p_Reverse.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
    
      p_Reverse.Pdchkno  := p_Source.Pdchkno;
      p_Reverse.Pdpriid  := p_Source.Pdpriid;
      p_Reverse.Tchkdate := p_Source.Tchkdate;
      p_Reverse.Pdtax    := p_Source.Pdtax;
      p_Reverse.Pdzdate  := p_Source.Pdzdate;
    
    ELSE
      Raise_Application_Error(Errcode, '无效的实收流水号');
    END IF;
    o_Ppayment_Reverse := p_Reverse.Paidment;
  
    --------------------------------------------------------------------------
    --2、提交处理
    BEGIN
      CLOSE c_Mi;
      CLOSE c_p;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p_Reverse;
        UPDATE Ys_Zw_Paidment
           SET Preverseflag = 'Y'
         WHERE Pid = p_Pid_Source;
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      IF c_p%ISOPEN THEN
        CLOSE c_p;
      END IF;
       dbms_output.put_line(SQLERRM);
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreversecorebypid;

  /*==========================================================================
  应收追帐核心
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  根据参数追加一套应收总账和关联应收明细（且须追加为欠费）；
  提供应收调整中追加调整目标帐、追补、营业外、冲正中追正、退费中追正等业务过程调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid;
    CURSOR c_Md(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmiid;
    CURSOR c_Ma(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmiid;
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Md Ys_Yh_Sbdoc%ROWTYPE;
    Ma Ys_Yh_Account%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    Bf Ys_Bas_Book%ROWTYPE;
    CURSOR c_Rlsource(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid;
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rl_Append Ys_Zw_Arlist%ROWTYPE;
    Rd_Append Ys_Zw_Ardetail%ROWTYPE;
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    Rdtab_Append Rd_Table;
  
    Vappend1rd Parm_Append1rd;
  BEGIN
    --取水表信息
    OPEN c_Mi(p_Rlmid);
    FETCH c_Mi
      INTO Mi;
    IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    BEGIN
      SELECT * INTO Bf FROM Ys_Bas_Book WHERE Book_No = Mi.Book_No;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    OPEN c_Md(p_Rlmid);
    FETCH c_Md
      INTO Md;
    IF c_Md%NOTFOUND OR c_Md%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    --
    OPEN c_Ma(p_Rlmid);
    FETCH c_Ma
      INTO Ma;
    IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
      NULL;
    END IF;
    --取用户信息
    OPEN c_Ci(Mi.Yhid);
    FETCH c_Ci
      INTO Ci;
    IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '这个水表编码没对应用户！' || p_Rlmid);
    END IF;
    --组织追加应收总账和明细行变量
    IF p_Rlid_Source IS NOT NULL THEN
      OPEN c_Rlsource(p_Rlid_Source);
      FETCH c_Rlsource
        INTO Rl_Source;
      IF c_Rlsource%NOTFOUND THEN
        Raise_Application_Error(Errcode,
                                '可以为空的原应收帐流水号非空但无效');
      END IF;
      CLOSE c_Rlsource;
    END IF;
    SELECT TRIM(Lpad(Seq_Arid.Nextval, 10, '0')) INTO o_Rlid FROM Dual;
    SELECT Uuid() INTO Rl_Append.Id FROM Dual;
  
    Rl_Append.Hire_Code   := f_Get_Hire_Code();
    Rl_Append.Manage_No   := Mi.Manage_No;
    Rl_Append.Arid        := o_Rlid;
    Rl_Append.Armonth     := Fobtmanapara(Rl_Source.Manage_No, 'READ_MONTH');
    Rl_Append.Ardate      := p_Rlrdate; --Trunc(SYSDATE);
    Rl_Append.Yhid        := Mi.Yhid;
    Rl_Append.Sbid        := Mi.Sbid;
    Rl_Append.Archargeper := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Archargeper
                               ELSE
                                Bf.Read_Per
                             END);
  
    Rl_Append.Arcpid        := Ci.Yhpid;
    Rl_Append.Arcclass      := Ci.Yhclass;
    Rl_Append.Arcflag       := Ci.Yhflag;
    Rl_Append.Arusenum      := Mi.Sbusenum;
    Rl_Append.Arcname       := Ci.Yhname;
    Rl_Append.Arcadr        := Ci.Yhadr;
    Rl_Append.Armadr        := Mi.Sbadr;
    Rl_Append.Arcstatus     := Ci.Yhstatus;
    Rl_Append.Armtel        := Ci.Yhmtel;
    Rl_Append.Artel         := Ci.Yhtel1;
    Rl_Append.Arbankid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arbankid
                            ELSE
                             Ma.Yhabankid
                          END);
    Rl_Append.Artsbankid := (CASE
                              WHEN Rl_Source.Arid IS NOT NULL THEN
                               Rl_Source.Artsbankid
                              ELSE
                               Ma.Yhatsbankid
                            END);
    Rl_Append.Araccountno := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Araccountno
                               ELSE
                                Ma.Yhaaccountno
                             END);
    Rl_Append.Araccountname := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Araccountname
                                 ELSE
                                  Ma.Yhaaccountname
                               END);
    Rl_Append.Ariftax := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Ariftax
                           ELSE
                            Mi.Sbiftax
                         END);
    Rl_Append.Artaxno := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Artaxno
                           ELSE
                            Mi.Sbtaxno
                         END);
    Rl_Append.Arifinv := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arifinv
                           ELSE
                            Ci.Yhifinv
                         END); --开票标志 
    Rl_Append.Armcode       := Mi.Sbcode;
    Rl_Append.Armpid        := Mi.Sbpid;
    Rl_Append.Armclass      := Mi.Sbclass;
    Rl_Append.Armflag       := Mi.Sbflag;
    Rl_Append.Arday := (CASE
                         WHEN Rl_Source.Arid IS NOT NULL THEN
                          Rl_Source.Arday
                         ELSE
                          Trunc(SYSDATE)
                       END);
    Rl_Append.Arbfid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arbfid
                          ELSE
                           Mi.Book_No
                        END);
    Rl_Append.Arprdate := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arprdate
                            ELSE
                             Trunc(SYSDATE)
                          END);
    Rl_Append.Arrdate := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arrdate
                           ELSE
                            Trunc(SYSDATE)
                         END);
    Rl_Append.Arzndate      := Rl_Append.Ardate + 30;
    Rl_Append.Arcaliber     := Md.Mdcaliber;
    Rl_Append.Arrtid        := Mi.Sbrtid;
    Rl_Append.Armstatus     := Mi.Sbstatus;
    Rl_Append.Armtype       := Mi.Sbtype;
    Rl_Append.Armno         := Md.Mdno;
    Rl_Append.Arscode       := p_Rlscode; --NUMBER(10)  Y    起数 
    Rl_Append.Arecode       := p_Rlecode; --NUMBER(10)  Y    止数 
    Rl_Append.Arreadsl      := p_Rlsl; --NUMBER(10)  Y    抄见水量 
  
    Rl_Append.Arinvmemo       := Rl_Source.Arinvmemo;
    Rl_Append.Arentrustbatch  := Rl_Source.Arentrustbatch;
    Rl_Append.Arentrustseqno  := Rl_Source.Arentrustseqno;
    Rl_Append.Aroutflag := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Aroutflag
                             ELSE
                              'N'
                           END);
    Rl_Append.Artrans         := p_Rltrans;
    Rl_Append.Arcd            := 'DE';
    Rl_Append.Aryschargetype := (CASE
                                  WHEN Rl_Source.Arid IS NOT NULL THEN
                                   Rl_Source.Aryschargetype
                                  ELSE
                                   Mi.Sbchargetype
                                END);
    Rl_Append.Arsl            := 0;
    Rl_Append.Arje            := 0;
    Rl_Append.Araddsl         := Rl_Source.Araddsl;
    Rl_Append.Arscrarid := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arscrarid
                             ELSE
                              Rl_Append.Arid
                           END);
    Rl_Append.Arscrartrans := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrartrans
                                ELSE
                                 Rl_Append.Artrans
                              END);
    Rl_Append.Arscrarmonth := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrarmonth
                                ELSE
                                 Rl_Append.Armonth
                              END);
    Rl_Append.Arpaidje        := Rl_Source.Arpaidje;
    Rl_Append.Arpaidflag      := Rl_Source.Arpaidflag;
    Rl_Append.Arpaidper       := Rl_Source.Arpaidper;
    Rl_Append.Arpaiddate      := Rl_Source.Arpaiddate;
    Rl_Append.Armrid          := Rl_Source.Armrid;
    Rl_Append.Armemo          := Nvl(p_Rlmemo, Rl_Source.Armemo);
    Rl_Append.Arznj           := Rl_Source.Arznj;
    Rl_Append.Arlb            := Rl_Source.Arlb;
    Rl_Append.Arcname2        := Rl_Source.Arcname2;
    Rl_Append.Arpfid          := p_Rlpfid; --VARCHAR2(10)  Y    主价格类别
    Rl_Append.Ardatetime      := SYSDATE;
    Rl_Append.Arscrardate := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Arscrardate
                               ELSE
                                Rl_Append.Ardate
                             END);
    Rl_Append.Arprimcode      := Rl_Source.Arprimcode;
    Rl_Append.Arpriflag       := Rl_Source.Arpriflag;
    Rl_Append.Arrper          := Rl_Source.Arrper;
    Rl_Append.Arsafid         := Rl_Source.Arsafid;
    Rl_Append.Arscodechar     := Rl_Source.Arscodechar;
    Rl_Append.Arecodechar     := Rl_Source.Arecodechar;
    Rl_Append.Arilid          := Rl_Source.Arilid;
    Rl_Append.Armiuiid        := Rl_Source.Armiuiid;
    Rl_Append.Argroup         := Rl_Source.Argroup;
    Rl_Append.Arpid           := Rl_Source.Arpid;
    Rl_Append.Arpbatch        := Rl_Source.Arpbatch;
    Rl_Append.Arsavingqc      := Rl_Source.Arsavingqc;
    Rl_Append.Arsavingbq      := Rl_Source.Arsavingbq;
    Rl_Append.Arsavingqm      := Rl_Source.Arsavingqm;
    Rl_Append.Arreverseflag   := Rl_Source.Arreverseflag;
    Rl_Append.Arbadflag       := Rl_Source.Arbadflag;
    Rl_Append.Arznjreducflag  := Rl_Source.Arznjreducflag;
    Rl_Append.Armistid        := Rl_Source.Armistid;
    Rl_Append.Arminame        := Rl_Source.Arminame;
    Rl_Append.Arsxf           := Rl_Source.Arsxf;
    Rl_Append.Armiface2       := Rl_Source.Armiface2;
    Rl_Append.Armiface3       := Rl_Source.Armiface3;
    Rl_Append.Armiface4       := Rl_Source.Armiface4;
    Rl_Append.Armiifckf       := Rl_Source.Armiifckf;
    Rl_Append.Armigps         := Rl_Source.Armigps;
    Rl_Append.Armiqfh         := Rl_Source.Armiqfh;
    Rl_Append.Armibox         := Rl_Source.Armibox;
    Rl_Append.Arminame2       := Rl_Source.Arminame2;
    Rl_Append.Armiseqno       := Rl_Source.Armiseqno;
    Rl_Append.Armisaving      := Rl_Source.Armisaving;
    Rl_Append.Arpriorje       := Rl_Source.Arpriorje;
    Rl_Append.Armicommunity   := Rl_Source.Armicommunity;
    Rl_Append.Armiremoteno    := Rl_Source.Armiremoteno;
    Rl_Append.Armiremotehubno := Rl_Source.Armiremotehubno;
    Rl_Append.Armiemail       := Rl_Source.Armiemail;
    Rl_Append.Armiemailflag   := Rl_Source.Armiemailflag;
    Rl_Append.Armicolumn1     := Rl_Source.Armicolumn1;
    Rl_Append.Armicolumn2     := Rl_Source.Armicolumn2;
    Rl_Append.Armicolumn3     := Rl_Source.Armicolumn3;
    Rl_Append.Armicolumn4     := Rl_Source.Armicolumn4;
    Rl_Append.Arpaidmonth     := Rl_Source.Arpaidmonth;
    Rl_Append.Arcolumn5       := Rl_Source.Arcolumn5;
    Rl_Append.Arcolumn9       := Rl_Source.Arcolumn9;
    Rl_Append.Arcolumn10      := Rl_Source.Arcolumn10;
    Rl_Append.Arcolumn11      := Rl_Source.Arcolumn11;
    Rl_Append.Arjtmk          := Rl_Source.Arjtmk;
    Rl_Append.Arjtsrq         := Rl_Source.Arjtsrq;
    Rl_Append.Arcolumn12      := Rl_Source.Arcolumn12;
  
    Rl_Append.Arprimcode  := Mi.Sbpriid; --VARCHAR2(200)  Y    合收表主表号
    Rl_Append.Arpriflag   := Mi.Sbpriflag; --CHAR(1)  Y    合收表标志
    Rl_Append.Arrper := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arrper
                          ELSE
                           Bf.Read_Per
                        END); --VARCHAR2(10)  Y    抄表员
    Rl_Append.Arsafid := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arsafid
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    区域
    Rl_Append.Arscodechar := To_Char(p_Rlscode); --VARCHAR2(10)  Y    上期抄表（带表位）
    Rl_Append.Arecodechar := To_Char(p_Rlecode); --VARCHAR2(10)  Y    本期抄表（带表位）
    Rl_Append.Arilid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arilid
                          ELSE
                           NULL
                        END); --VARCHAR2(40)  Y    发票打印批次
    Rl_Append.Armiuiid    := Mi.Sbuiid; --VARCHAR2(10)  Y    合收单位编号
    Rl_Append.Argroup := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Argroup
                           ELSE
                            NULL
                         END); --NUMBER(2)  Y    应收帐分组
    /**/
    Rl_Append.Arznj := p_Rlznj; --NUMBER(13,3)  Y    违约金
    /**/
    Rl_Append.Arzndate := p_Rlzndate; --DATE  Y    违约金起算日
    /**/
    Rl_Append.Arznjreducflag := p_Rlznjreducflag; --VARCHAR2(1)  Y    滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取rlznj
    Rl_Append.Armistid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Armistid
                            ELSE
                             NULL
                          END); --VARCHAR2(10)  Y    行业分类
    /**/
    Rl_Append.Arminame      := Nvl(p_Rlcname, Mi.Sbname); --VARCHAR2(64)  Y    票据名称
    Rl_Append.Arsxf         := 0; --NUMBER(12,2)  Y    手续费
    Rl_Append.Armiface2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface2
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    抄见故障
    Rl_Append.Armiface3 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface3
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    非常计量
    Rl_Append.Armiface4 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface4
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    表井设施说明
    Rl_Append.Armiifckf := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiifckf
                             ELSE
                              NULL
                           END); --CHAR(1)  Y    垃圾费户数
    Rl_Append.Armigps := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armigps
                           ELSE
                            NULL
                         END); --VARCHAR2(60)  Y    是否合票
    Rl_Append.Armiqfh := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armiqfh
                           ELSE
                            NULL
                         END); --VARCHAR2(20)  Y    铅封号
    Rl_Append.Armibox := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armibox
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    消防水价（增值税水价，襄阳需求）
    Rl_Append.Arminame2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arminame2
                             ELSE
                              NULL
                           END); --VARCHAR2(64)  Y    招牌名称(小区名，襄阳需求）
    Rl_Append.Armiseqno := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiseqno
                             ELSE
                              NULL
                           END); --VARCHAR2(50)  Y    户号（初始化时册号+序号）
    Rl_Append.Arsavingqc    := Mi.Sbsaving; --NUMBER(13,3)  Y    算费时预存
    Rl_Append.Armicommunity := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Armicommunity
                                 ELSE
                                  NULL
                               END); --VARCHAR2(10)  Y    小区
  
    --rl_append.ARbddsl         := 0; --NUMBER(10)  Y    估抄水量
    /**/
    Rl_Append.Arsl := p_Rlsl; --NUMBER(10)  Y    应收水量
    /**/
    Rl_Append.Arje          := p_Rlje; --NUMBER(13,3)  Y    应收金额
    Rl_Append.Arpaidje      := 0; --NUMBER(13,3)  Y    销帐金额
    Rl_Append.Arpaidflag    := 'N'; --CHAR(1)  Y    销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    Rl_Append.Arpaidper     := NULL; --VARCHAR2(20)  Y    销帐人员
    Rl_Append.Arpaiddate    := NULL; --DATE  Y    销帐日期
    Rl_Append.Arpaidmonth   := NULL; --VARCHAR2(7)  Y    销账月份
    Rl_Append.Arcolumn11    := NULL; --VARCHAR2(7)  Y    实收事务
    Rl_Append.Arpid         := NULL; --VARCHAR2(10)  Y    实收流水（与payment.pid对应）
    Rl_Append.Arpbatch      := NULL; --VARCHAR2(10)  Y    缴费交易批次（与payment.PBATCH对应）
    Rl_Append.Arsavingqc    := 0; --NUMBER(12,2)  Y    期初预存（销帐时产生）
    Rl_Append.Arsavingbq    := 0; --NUMBER(12,2)  Y    本期预存发生（销帐时产生）
    Rl_Append.Arsavingqm    := 0; --NUMBER(12,2)  Y    期末预存（销帐时产生）
    Rl_Append.Arreverseflag := 'N'; --VARCHAR2(1)  Y      冲正标志（N为正常，Y为冲正）
    Rl_Append.Arbadflag     := 'N'; --VARCHAR2(1)  Y    呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）
    BEGIN
      --NUMBER(13,3)  Y  之前欠费
      SELECT Nvl(SUM(Nvl(Arje, 0) - Nvl(Arpaidje, 0)), 0)
        INTO Rl_Append.Arpriorje
        FROM Ys_Zw_Arlist
       WHERE Arreverseflag = 'Y'
         AND Arpaidflag = 'N'
         AND Arje > 0
         AND Sbid = Rl_Append.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        Rl_Append.Arpriorje := 0;
    END;
    IF p_Parm_Append1rds IS NOT NULL THEN
      FOR i IN p_Parm_Append1rds.First .. p_Parm_Append1rds.Last LOOP
        Vappend1rd := p_Parm_Append1rds(i);
        --
        Rd_Append.Id            := Uuid();
        Rd_Append.Hire_Code     := f_Get_Hire_Code();
        Rd_Append.Ardid         := o_Rlid; --VARCHAR2(10)      流水号
        Rd_Append.Ardpmdid      := Vappend1rd.Ardpmdid; --NUMBER      混合用水分组
        Rd_Append.Ardpiid       := Vappend1rd.Ardpiid; --CHAR(2)      费用项目
        Rd_Append.Ardpfid       := Nvl(Vappend1rd.Ardpfid, p_Rlpfid); --VARCHAR2(10)      费率
        Rd_Append.Ardpscid      := Vappend1rd.Ardpscid; --NUMBER      费率明细方案
        Rd_Append.Ardclass      := Vappend1rd.Ardclass; --NUMBER      阶梯级别
        Rd_Append.Ardysdj       := Vappend1rd.Arddj; --NUMBER(13,3)  Y    应收单价
        Rd_Append.Ardyssl       := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    应收水量
        Rd_Append.Ardysje       := Vappend1rd.Ardje; --NUMBER(13,3)  Y    应收金额
        Rd_Append.Arddj         := Vappend1rd.Arddj; --NUMBER(13,3)  Y    实收单价
        Rd_Append.Ardsl         := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    实收水量
        Rd_Append.Ardje         := Vappend1rd.Ardje; --NUMBER(13,3)  Y    实收金额
        Rd_Append.Ardadjdj      := 0; --NUMBER(13,3)  Y    调整单价
        Rd_Append.Ardadjsl      := 0; --NUMBER(12,2)  Y    调整水量
        Rd_Append.Ardadjje      := 0; --NUMBER(13,3)  Y    调整金额
        Rd_Append.Ardmethod     := NULL; --CHAR(3)  Y    计费方法
        Rd_Append.Ardpaidflag   := NULL; --CHAR(1)  Y    销帐标志
        Rd_Append.Ardpaiddate   := NULL; --DATE  Y    销帐日期
        Rd_Append.Ardpaidmonth  := NULL; --VARCHAR2(7)  Y    销帐月份
        Rd_Append.Ardpaidper    := NULL; --VARCHAR2(20)  Y    销帐人员
        Rd_Append.Ardpmdscale   := NULL; --NUMBER(10,2)  Y    混合比例
        Rd_Append.Ardilid       := Vappend1rd.Ardilid; --VARCHAR2(10)  Y    票据流水
        Rd_Append.Ardznj        := NULL; --NUMBER(12,2)  Y    违约金
        Rd_Append.Ardmemo       := p_Rlmemo; --VARCHAR2(200)  Y    备注
        Rd_Append.Ardmsmfid     := NULL; --VARCHAR2(10)  Y    营销公司
        Rd_Append.Ardmonth      := NULL; --VARCHAR2(7)  Y    帐务月份
        Rd_Append.Ardmid        := NULL; --VARCHAR2(10)  Y    水表编号
        Rd_Append.Ardpmdtype    := NULL; --VARCHAR2(2)  Y    混合类别
        Rd_Append.Ardpmdcolumn1 := NULL; --VARCHAR2(10)  Y    备用字段1
        Rd_Append.Ardpmdcolumn2 := NULL; --VARCHAR2(10)  Y    备用字段2
        Rd_Append.Ardpmdcolumn3 := NULL; --VARCHAR2(10)  Y    备用字段3
      
        --复制到rdTab_append
        IF Rdtab_Append IS NULL THEN
          Rdtab_Append := Rd_Table(Rd_Append);
        ELSE
          Rdtab_Append.Extend;
          Rdtab_Append(Rdtab_Append.Last) := Rd_Append;
        END IF;
      END LOOP;
    END IF;
  
    --其他控制赋值
    IF p_Ctl_Mircode IS NOT NULL THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = To_Number(p_Ctl_Mircode),
             Sbrcodechar = p_Ctl_Mircode
       WHERE Sbid = p_Rlmid;
    END IF;
  
    --2、提交处理
    BEGIN
      INSERT INTO Ys_Zw_Arlist VALUES Rl_Append;
      FOR k IN Rdtab_Append.First .. Rdtab_Append.Last LOOP
        INSERT INTO Ys_Zw_Ardetail VALUES Rdtab_Append (k);
      END LOOP;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rlsource%ISOPEN THEN
        CLOSE c_Rlsource;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendcore;

  /*==========================================================================
  应收追正
  【输入参数说明】：
  p_rlid_source in number：源应收流水号
  p_rdpiids ：指定基于原应收帐派生的枚举费项（一位数组字符串，基于TOOLS.FGETPARA二维数组规范），例'01|02|03|'）;
              应收总账下全部费项传'ALL'；
              此参数为空，追正帐应收明细依然按应收总账下全部应收明细记录数生成，但量费均置0；
  p_memo in varchar2：冲正备注
  p_commit in number default 不提交：是否提交
  【输出参数说明】：
  【过程说明】：
  基于原应收记录复制追加一条应收（欠费状态）记录及关联应收明细（可指定枚举的费用项目）；
  提供给部分销帐预处理（拆分应收）、实收冲正、退费业务过程中调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER) IS
    CURSOR c_Rl(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    --原应收
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
  
    Vappend1rd  Parm_Append1rd;
    Vappend1rds Parm_Append1rd_Tab;
  BEGIN
    o_Rlje     := Nvl(o_Rlje, 0);
    Vappend1rd := Parm_Append1rd(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
    OPEN c_Rl(p_Rlid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      OPEN c_Rd(p_Rlid_Source);
      FETCH c_Rd
        INTO Rd_Source;
      IF c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '无效的应收流水号' || p_Rlid_Source);
      END IF;
      WHILE c_Rd%FOUND LOOP
        ------------------------------------------------
        IF Instr(p_Rdpiids, Rd_Source.Ardpiid || '|') > 0 OR
           Upper(p_Rdpiids) = 'ALL' THEN
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := Rd_Source.Ardsl;
          Vappend1rd.Ardje     := Rd_Source.Ardje;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        ELSE
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := 0;
          Vappend1rd.Ardje     := 0;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        END IF;
        --复制到vappend1rds
        IF Vappend1rds IS NULL THEN
          Vappend1rds := Parm_Append1rd_Tab(Vappend1rd);
        ELSE
          Vappend1rds.Extend;
          Vappend1rds(Vappend1rds.Last) := Vappend1rd;
        END IF;
        o_Rlje := o_Rlje + Vappend1rd.Ardje;
        ------------------------------------------------
        FETCH c_Rd
          INTO Rd_Source;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '无效的应收流水号');
    END IF;
  
    Recappendcore(Rl_Source.Sbid,
                  Rl_Source.Arminame,
                  Rl_Source.Arpfid,
                  Rl_Source.Arrdate,
                  Rl_Source.Arscode,
                  Rl_Source.Arecode,
                  Rl_Source.Arsl,
                  o_Rlje,
                  Rl_Source.Arznjreducflag,
                  Rl_Source.Arzndate,
                  Rl_Source.Arznj,
                  p_Rltrans, --rl_source.rltrans,
                  p_Memo,
                  Rl_Source.Arid,
                  Vappend1rds,
                  NULL, --不重置起码
                  不提交,
                  o_Rlid);
  
    --2、提交处理
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendinherit;

  /*==========================================================================
  实收冲正次核心
  【输入参数说明】：
  p_pid_source  in number：待冲正实收流水号，允许预存充值实收类型（无关联应收销帐）
  p_position      in varchar2：冲正到缴费单位
  p_paypoint    in varchar2：冲正到缴费点
  p_ptrans      in varchar2：冲正到实收事务
  p_bdate       in date：银行冲正日期
  p_bseqno      in varchar2：银行冲正流水
  p_oper        in varchar2：冲正操作员
  p_payway      in varchar2：冲正到付款方式
  p_memo        in varchar2：冲正备注
  p_commit      in number：是否提交
  
  【输出参数说明】：
  o_pid_reverse out number：冲正（负帐）记录实收流水号
  o_ppayment_reverse out number：冲正（负帐）记录实收冲正金额
  【过程说明】：
  提供水司柜台冲正、银行实时退单、银行单边帐冲正调用
  基于一条实收记录payment.pid进行实收冲正的操作，且对全部关联应收进行逆销帐，
  与退费本质不同在于
  1）同时冲正预存发生金额；
  2）应收冲正后进行应收追正，而退费视部分退费与否或追正后追销或不追；
  冲正流程为：实收冲正（当月负实收）-->应收冲正（追加当月全额负帐）-->应收追补（追加当月全额正帐）
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2) IS
    o_Append_Rlje NUMBER;
    --
    o_Rlid_Reverse        VARCHAR2(10);
    o_Rltrans_Reverse     VARCHAR2(10);
    o_Rlje_Reverse        NUMBER;
    o_Rlznj_Reverse       NUMBER;
    o_Rlsxf_Reverse       NUMBER;
    o_Rlsavingbq_Reverse  NUMBER;
    Io_Rlsavingqm_Reverse NUMBER;
  BEGIN
    --实收冲正（当月负实收）
    Payreversecorebypid(p_Pid_Source,
                        p_Position,
                        p_Paypoint,
                        p_Ptrans,
                        p_Bdate,
                        p_Bseqno,
                        p_Oper,
                        p_Payway,
                        p_Memo,
                        不提交,
                        '0',
                        o_Pid_Reverse,
                        o_Ppayment_Reverse);
    FOR i IN (SELECT Arid, Arpaidje, Artrans
                FROM Ys_Zw_Arlist
               WHERE Arpid = p_Pid_Source
                 AND Arreverseflag = 'N'
               ORDER BY Arid) LOOP
      --应收冲正（追加当月全额负帐）
      Zwarreversecore(i.Arid, -- P_ARID_SOURCE         IN VARCHAR2,
                      i.Artrans, --P_ARTRANS_REVERSE     IN VARCHAR2,
                      NULL, --    P_PBATCH_REVERSE      IN VARCHAR2,
                      o_Pid_Reverse, --     P_PID_REVERSE         IN VARCHAR2,
                      -i.Arpaidje, --    P_PPAYMENT_REVERSE    IN NUMBER,
                      p_Memo, --    P_MEMO                IN VARCHAR2,
                      NULL, --    P_CTL_MIRCODE         IN VARCHAR2,
                      不提交, --    P_COMMIT              IN NUMBER DEFAULT 不提交,
                      o_Rlid_Reverse,
                      o_Rltrans_Reverse,
                      o_Rlje_Reverse,
                      o_Rlznj_Reverse,
                      o_Rlsxf_Reverse,
                      o_Rlsavingbq_Reverse,
                      Io_Rlsavingqm_Reverse); /* O_ARID_REVERSE        OUT VARCHAR2,
                                O_ARTRANS_REVERSE     OUT VARCHAR2,
                                O_ARJE_REVERSE        OUT NUMBER,
                                O_ARZNJ_REVERSE       OUT NUMBER,
                                O_ARSXF_REVERSE       OUT NUMBER,
                                O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                                IO_ARSAVINGQM_REVERSE IN OUT NUMBER
                                */
      --应收追补（追加当月全额正帐）
      Recappendinherit(i.Arid,
                       'ALL',
                       o_Rltrans_Reverse,
                       p_Memo,
                       不提交,
                       o_Append_Rlid,
                       o_Append_Rlje);
    END LOOP;
  
    --2、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreverse;
  
  /*==========================================================================
  水司柜台冲正(不退款)，不记独立实收事务
  【输入参数说明】：
  p_pid_source  in number：待冲正原实收流水号
  p_oper        in varchar2：冲正操作员
  p_memo        in varchar2：其他冲正备注信息
  
  【输出参数说明】：
  p_pid_reverse out number：冲正成功后返回的冲正记录（负实收记录）流水号
  
  【过程说明】：
  柜台缴费页面集成功能，当日或隔日均冲正到本期，计帐为原实收单位、原实收缴费点、原实收事务、原付款方式
  支持冲正预存充值交易
  其他【过程说明】见子过程PayReverse《实收冲正次核心》说明
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2) is
    p                  ys_zw_paidment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from ys_zw_paidment  where pid = p_pid_source;
    --校验
    if not (p.PREVERSEFLAG = 'N' and p.PAIDMENT >= 0) then
      raise_application_error(errcode,
                              '待冲正实收记录无效，必须为未冲正的正常缴费');
    end if;
    PayReverse(p_pid_source,
               p.MANAGE_NO,
               p.PDPAYPOINT,
               p.PDTRAN,
               null,
               null,
               p_oper,
               p.PDPAYWAY,
               p_memo,
               不提交,
               p_pid_reverse,
               vppaymentreverse,
               vappendrlid);
  
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, '是否提交参数不正确' || p_pid_source); 
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse;

/*==========================================================================
  应收追调
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  基于应收调整业务中的调整目标账务（总账+明细）追加一条应收记录及关联应收明细
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAppendAdj(p_rlmid           in varchar2,
                         p_rlcname         in varchar2,
                         p_rlpfid          in varchar2,
                         p_rlrdate         in date,
                         p_rlscode         in number,
                         p_rlecode         in number,
                         p_rlsl            in number,
                         p_rlje            in number,
                         p_rlznj           in number,
                         p_rltrans         in varchar2,
                         p_rlmemo          in varchar2,
                         p_rlid_source     in varchar2,
                         p_parm_append1rds parm_append1rd_tab,
                         p_ctl_mircode     in varchar2,
                         p_commit          in number default 不提交,
                         o_rlid            out varchar2) is
    cursor c_rl(vrlid varchar2) is
      select * from ys_zw_arlist  where arid = vrlid for update nowait; --若被锁直接抛出异常
    rl_source ys_zw_arlist%rowtype;
  begin
    --退费正帐应收事务继承原帐务
    open c_rl(p_rlid_source);
    fetch c_rl
      into rl_source;
    if c_rl%notfound or c_rl%notfound is null then
      raise_application_error(errcode, '无原帐务应收记录');
    end if;
    close c_rl;
  
    RecAppendCore(p_rlmid,
                  p_rlcname,
                  p_rlpfid,
                  p_rlrdate,
                  p_rlscode,
                  p_rlecode,
                  p_rlsl,
                  p_rlje,
                  rl_source.arznjreducflag,
                  rl_source.arzndate,
                  p_rlznj,
                  p_rltrans,
                  p_rlmemo,
                  p_rlid_source,
                  p_parm_append1rds,
                  p_ctl_mircode,
                  不提交,
                  o_rlid);
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end RecAppendAdj;
/*==========================================================================
  应收调整
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：非空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid_reverse out varchar2：
  o_rlid out varchar2：返回追补的应收记录流水号
  【过程说明】：
  基于单据调整应收价量费
  调整流程为：应收冲正（追加当月全额负帐）-->应收追补
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAdjust(p_rlmid           in varchar2,
                      p_rlcname         in varchar2,
                      p_rlpfid          in varchar2,
                      p_rlrdate         in date,
                      p_rlscode         in number,
                      p_rlecode         in number,
                      p_rlsl            in number,
                      p_rlje            in number,
                      p_rlznj           in number,
                      p_rltrans         in varchar2,
                      p_rlmemo          in varchar2,
                      p_rlid_source     in varchar2,
                      p_parm_append1rds parm_append1rd_tab,
                      p_commit          in number default 不提交,
                      p_ctl_mircode     in varchar2,
                      o_rlid_reverse    out varchar2,
                      o_rlid            out varchar2) is
    --
    o_rltrans_reverse     varchar2(10);
    o_rlje_reverse        number;
    o_rlznj_reverse       number;
    o_rlsxf_reverse       number;
    o_rlsavingbq_reverse  number;
    io_rlsavingqm_reverse number;
  begin
    Zwarreversecore(p_rlid_source,
                   p_rltrans,
                   null,
                   null, --应收调整无关联实收记录p_pid_reverse
                   null, --应收调整无关联实收记录
                   p_rlmemo,
                   null, --此过程不重置止码，让追补核心处理
                   p_commit,
                   o_rlid_reverse,
                   o_rltrans_reverse,
                   o_rlje_reverse,
                   o_rlznj_reverse,
                   o_rlsxf_reverse,
                   o_rlsavingbq_reverse,
                   io_rlsavingqm_reverse);
    if not (p_rlsl = 0 and p_rlje = 0 and p_rlznj = 0) then
      RecAppendAdj(p_rlmid,
                   p_rlcname,
                   p_rlpfid,
                   p_rlrdate,
                   p_rlscode,
                   p_rlecode,
                   p_rlsl,
                   p_rlje,
                   p_rlznj,
                   o_rltrans_reverse,
                   p_rlmemo,
                   p_rlid_source,
                   p_parm_append1rds,
                   p_ctl_mircode,
                   p_commit,
                   o_rlid);
    else
      --其他控制赋值
      if p_ctl_mircode is not null then
        update ys_yh_sbinfo
           set sbrcode     = to_number(p_ctl_mircode),
               sbrcodechar = p_ctl_mircode
         where sbid = p_rlmid;
      end if;
    
    end if;
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      /*pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'RecAdjust,p_rlmid:' || p_rlmid);*/
      --raise;
      raise_application_error(errcode, sqlerrm);
  end RecAdjust;
BEGIN
  NULL;

END;
/

prompt
prompt Creating package body PG_PAID_01BAK
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY Pg_Paid_01bak IS
  Curdatetime DATE;

  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER IS
    v_Result NUMBER;
  BEGIN
    v_Result := p_Je * (Trunc(p_Edate) - Trunc(p_Sdate) + 1) * 0.003;
    v_Result := Pg_Cb_Cost.Getmax(v_Result, 0);
    RETURN v_Result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --违约金计算
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --应收流水
                     p_Ardpiids IN VARCHAR2, --应收明细费项串'01|02|03'
                     p_Edate    IN DATE --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
                     ) RETURN NUMBER IS
    Vresult          NUMBER;
    v_Arzndate       Ys_Zw_Arlist.Arzndate%TYPE;
    v_Arznj          Ys_Zw_Arlist.Arznj%TYPE;
    v_Outflag        Ys_Zw_Arlist.Aroutflag%TYPE;
    v_Sbid           Ys_Zw_Arlist.Sbid%TYPE;
    v_Arje           Ys_Zw_Arlist.Arje%TYPE;
    v_Yhifzn         Ys_Yh_Custinfo.Yhifzn%TYPE;
    v_Arznjreducflag Ys_Zw_Arlist.Arznjreducflag%TYPE;
    v_Chargetype     VARCHAR2(10);
  BEGIN
    BEGIN
      SELECT a.Sbid,
             MAX(Arzndate),
             MAX(Arznj),
             MAX(Aroutflag),
             SUM(Ardje),
             MAX(Yhifzn),
             MAX(Arznjreducflag),
             MAX(Nvl(Sbchargetype, 'X'))
        INTO v_Sbid,
             v_Arzndate,
             v_Arznj,
             v_Outflag,
             v_Arje,
             v_Yhifzn,
             v_Arznjreducflag,
             v_Chargetype
        FROM Ys_Zw_Arlist   a,
             Ys_Yh_Custinfo b,
             Ys_Zw_Ardetail c,
             Ys_Yh_Sbinfo   d
       WHERE a.Sbid = d.Sbid
         AND b.Yhid = d.Yhid
         AND a.Arid = c.Ardid
         AND Instr(p_Ardpiids, Ardpiid) > 0
         AND Arid = p_Arid
       GROUP BY Arid, a.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
  
    --暂时屏蔽
    --return 0;
  
    IF v_Yhifzn = 'N' OR v_Chargetype IN ('D', 'T') THEN
      RETURN 0;
    END IF;
    IF v_Arje < 0 THEN
      v_Arje := 0;
    END IF;
    IF v_Arznjreducflag = 'Y' THEN
      RETURN v_Arznj;
    END IF;
  
    Vresult := Obtwyj(v_Arzndate, p_Edate, v_Arje);
    --不得超过本金
    IF Vresult > v_Arje THEN
      Vresult := v_Arje;
    END IF;
  
    RETURN Trunc(Vresult, 2);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  /*==========================================================================
  水司柜台缴费（一表）,参数简化版
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE Poscustforys(p_Sbid     IN VARCHAR2,
                         p_Arstr    IN VARCHAR2,
                         p_Position IN VARCHAR2,
                         p_Oper     IN VARCHAR2,
                         p_Paypoint IN VARCHAR2,
                         p_Payway   IN VARCHAR2,
                         p_Payment  IN NUMBER,
                         p_Batch    IN VARCHAR2,
                         p_Pid      OUT VARCHAR2) IS
  
    v_Parm_Ar  Parm_Payar;
    v_Parm_Ars Parm_Payar_Tab;
  BEGIN
    v_Parm_Ar  := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars := Parm_Payar_Tab();
    FOR i IN 1 .. Fmid(p_Arstr, '|') - 1 LOOP
      v_Parm_Ar.Arid     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 1);
      v_Parm_Ar.Ardpiids := REPLACE(REPLACE(Pg_Cb_Cost.Fgetpara(p_Arstr,
                                                                i,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      v_Parm_Ar.Arwyj    := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 3);
      v_Parm_Ar.Fee1     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 4);
      v_Parm_Ar.Fee2     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 5);
      v_Parm_Ar.Fee3     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 6);
      v_Parm_Ars.Extend;
      v_Parm_Ars(v_Parm_Ars.Last) := v_Parm_Ar;
    END LOOP;
  
    Poscust(p_Sbid,
            v_Parm_Ars,
            p_Position,
            p_Oper,
            p_Paypoint,
            p_Payway,
            p_Payment,
            p_Batch,
            p_Pid);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  水司柜台缴费（一表）
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ars   in out parm_payr_tab :单表待销应收包成员参数如下：
                            arid  in number :应收流水（依此成员次序销帐）
                            ardpiids in varchar2 :费用项目串（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统费项1
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  */
  PROCEDURE Poscust(p_Sbid     IN VARCHAR2,
                    p_Parm_Ars IN Parm_Payar_Tab,
                    p_Position IN VARCHAR2,
                    p_Oper     IN VARCHAR2,
                    p_Paypoint IN VARCHAR2,
                    p_Payway   IN VARCHAR2,
                    p_Payment  IN NUMBER,
                    p_Batch    IN VARCHAR2,
                    p_Pid      OUT VARCHAR2) IS
    Vbatch       VARCHAR2(10);
    Vseqno       VARCHAR2(10);
    v_Parm_Ars   Parm_Payar_Tab;
    Vremainafter NUMBER;
    v_Parm_Count NUMBER;
  BEGIN
    Vbatch     := p_Batch;
    v_Parm_Ars := p_Parm_Ars;
    --核心部分校验
    FOR i IN (SELECT a.Aroutflag
                FROM Ys_Zw_Arlist a, TABLE(v_Parm_Ars) b
               WHERE a.Arid = b.Arid) LOOP
      IF 允许重复销帐 = 0 AND i.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO v_Parm_Count FROM TABLE(v_Parm_Ars) b;
    IF v_Parm_Count = 0 THEN
      IF p_Payment > 0 THEN
        --单缴预存核心
        Precust(p_Sbid        => p_Sbid,
                p_Position    => p_Position,
                p_Oper        => p_Oper,
                p_Payway      => p_Payway,
                p_Payment     => p_Payment,
                p_Memo        => NULL,
                p_Batch       => Vbatch,
                o_Pid         => p_Pid,
                o_Remainafter => Vremainafter);
      ELSE
        NULL;
        --退预存核心
        Precustback(p_Sbid        => p_Sbid,
                    p_Position    => p_Position,
                    p_Oper        => p_Oper,
                    p_Payway      => p_Payway,
                    p_Payment     => p_Payment,
                    p_Memo        => NULL,
                    p_Batch       => Vbatch,
                    o_Pid         => p_Pid,
                    o_Remainafter => Vremainafter);
      END IF;
    ELSE
      Paycust(p_Sbid,
              v_Parm_Ars,
              Ptrans_柜台缴费,
              p_Position,
              p_Paypoint,
              NULL,
              NULL,
              p_Oper,
              p_Payway,
              p_Payment,
              NULL,
              不提交,
              局部屏蔽通知,
              允许拆帐,
              Vbatch,
              Vseqno,
              p_Pid,
              Vremainafter);
    END IF;
  
    --提交处理
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  一水表多应收销帐
  paymeter
  【输入参数说明】：
  p_sbid        in varchar2 :单一水表编号
  p_parm_ARs   in out parm_payAR_tab :可以为空（预存充值），待销应收包结构如下：
                            ARid  in number :应收流水（依此成员次序销帐）
                            Ardpiids in varchar2 :费用项目串，必须是YS_ZW_ARDETAIL的全集（待销费用项目,由前台勾选否(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                            ARznj in number :传入的实收违约金（本过程内不计算不校验），传多少销多少
                            fee1 in number  :其他非系统实收费项1
  p_trans      in varchar2 :缴费事务
  p_position      in varchar2 :缴费单位，营销架构中营业所编码，实收计帐单位
  p_paypoint   in varchar2 :缴费点，缴费单位下级需要分收费网点点统计需要，可以为空
  p_bdate      in date :前台日期，银行交易日期(yyyy-mm-dd hh24:mi:ss '2014-02-10 13:53:01')
  p_bseqno     in varchar2 :前台流水，银行交易流水
  p_oper       in varchar2 :销帐员，柜台缴费时销帐人员与收款员统一
  p_payee      in varchar2 :收款员，柜台缴费时销帐人员与收款员统一
  p_payway     in varchar2 :付款方式，每交易有且仅有一种付款方式
  p_payment    in number   :实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid_source in number   :可空，正常销帐时为空，也即实参为空赋值为新的实收流水号，部分退费追销时许传原实收流水用于实收行绑定
  p_commit     in number   :提交方式（0:执行成功后不提交；
                                      1:执行成功后提交；
                                      2:调试，或执行成功后提交，到模拟表）
  p_ctl_msg  in number   :全局控制参数“禁止所有通知”条件下，是否发送通知服务，组织统一缴费交易通知内容，通过sendmsg发送到外部接口（短信、微信等），
                            外部调用时选择是否需要本缴费交易核心统一组织内容（退费时通知内容得在退费头过程中组织，调用时避免本过程重复发送需要屏蔽）
                            通知客户  = 1
                            不通知客户= 0
  【输出参数说明】：
  p_batch      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_seqno      in out number：传空值时本过程生成，非空时用此值绑定实收记录，返回销帐成功后的交易批次，供打印时二次查询
  p_pid        out number：返回销帐成功后的交易流水，供父过程调用
  【过程说明】：
  1、一水表任意多月销帐次核心过程，提供各缴费事务过程调用；
  2、实收 = 销帐+实收违约金+预存（净增）+预存（净减）+其他非系统费项123；
  3、支持预存、期末负预存（依赖全局包常量：是否预存、是否负预存）；
  4、支持有且仅有违约金应收记录（无水费、追补违约金功能产生）；
  5、最小销帐单元为应收明细行或仅应收违约金，销帐前p_parm_rls.rdpiids中成员如有N勾选状态时先执行【应收调整.部分销帐】，之后重构【待销应收包】
  6、【重构待销应收包】基础上对其中目前是未销状态的全部销帐
  7、最后判断整体实收溢出时（待销中存在其它实收事务已销、前台预存）
     1）启用预存时，销帐后做期末预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用预存时，抛出异常；
  8、整体实收不足时
     1）启用负预存时，销帐后做期末负预存，且记录在分解之销帐预存到最后销帐记录上（即待销应收包末尾销帐单元）；
     2）未启用负预存时，抛出异常；
  9、关于部分勾选费项缴费时补充说明，违约金在前台重算，并且违约金只从属于应收帐头无须分解到应收明细
  【更新日志】：
  */
  PROCEDURE Paycust(p_Sbid        IN VARCHAR2,
                    p_Parm_Ars    IN Parm_Payar_Tab,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Pid_Source  IN VARCHAR2,
                    p_Commit      IN NUMBER,
                    p_Ctl_Msg     IN NUMBER,
                    p_Ctl_Pre     IN NUMBER,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    p_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ma(Vmamid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmamid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi         Ys_Yh_Sbinfo%ROWTYPE;
    Ci         Ys_Yh_Custinfo%ROWTYPE;
    Ma         Ys_Yh_Account%ROWTYPE;
    p          Ys_Zw_Paidment%ROWTYPE;
    v_Parm_Ars Parm_Payar_Tab;
    p_Parm_Ar  Parm_Payar;
    v_Exists   NUMBER;
  BEGIN
    v_Parm_Ars := p_Parm_Ars;
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
    BEGIN
      --取水表信息
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '水表编码【' || p_Sbid || '】不存在！');
      END IF;
      --取用户信息
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '这个水表编码没对应用户！' || p_Sbid);
      END IF;
      --取用户银行账户信息
      OPEN c_Ma(Mi.Sbid);
      FETCH c_Ma
        INTO Ma;
      IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --参数校验
      /*if p_parm_rls is null then
        raise_application_error(errcode, '待销帐包是空的怎么办？');
      end if;*/
      --添加核心校验,避免户号与待销账列表不一致
      IF p_Parm_Ars.Count > 0 THEN
        --可以为空（预存充值时）
        FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
          p_Parm_Ar := p_Parm_Ars(i);
          SELECT COUNT(1)
            INTO v_Exists
            FROM Ys_Zw_Arlist a, Ys_Yh_Sbinfo b
           WHERE Arid = p_Parm_Ar.Arid
             AND a.Sbid = b.Sbid
             AND (b.Sbid = p_Sbid OR Sbpriid = p_Sbid);
          IF v_Exists = 0 THEN
            Raise_Application_Error(Errcode,
                                    '请求参数错误，请刷新页面后重新操作!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2、记录实收
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO p_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code  := Mi.Hire_Code;
      p.Pid        := p_Pid; --varchar2(10)      流水号
      p.Yhid       := Ci.Yhid; --varchar2(10)      用户编号
      p.Sbid       := p_Sbid; --varchar2(10)  y    水表编号
      p.Pddate     := Trunc(SYSDATE); --date  y    帐务日期
      p.Pdatetime  := SYSDATE; --date  y    发生日期
      p.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      p.Manage_No  := p_Position; --varchar2(10)  y    缴费机构
      p.Pdtran     := p_Trans; --char(1)      缴费事务
      p.Pdpers     := p_Oper; --varchar2(20)  y    销帐人员
      p.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    期初预存余额
      p.Pdsavingbq := p_Payment; --number(12,2)  y    本期发生预存金额
      p.Pdsavingqm := p.Pdsavingqc + p.Pdsavingbq; --number(12,2)  y    期末预存余额
      p.Paidment   := p_Payment; --number(12,2)  y    付款金额
      p.Pdifsaving := NULL; --char(1)  y    找零转预存
      p.Pdchange   := NULL; --number(12,2)  y    找零金额
      p.Pdpayway   := p_Payway; --varchar2(6)  y    付款方式
      p.Pdbseqno   := p_Bseqno; --varchar2(20)  y    银行流水(银行实时收费交易流水)
      p.Pdcseqno   := NULL; --varchar2(20)  y    清算中心流水(no use)
      p.Pdbdate    := p_Bdate; --date  y    银行日期(银行缴费账务日期)
      p.Pdchkdate  := NULL; --date  y    对帐日期
      p.Pdcchkflag := 'N'; --char(1)  y    标志(no use)
      p.Pdcdate    := NULL; --date  y    清算日期
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno      := p_Seqno; --varchar2(10)  y    缴费交易流水(no use)
      p.Pdpayee      := p_Oper; --varchar2(20)  y    收款员
      p.Pdchbatch    := NULL; --varchar2(10)  y    支票交易批次
      p.Pdmemo       := NULL; --varchar2(200)  y    备注
      p.Pdpaypoint   := p_Paypoint; --varchar2(10)  y    缴费地点
      p.Pdsxf        := 0; --number(12,2)  y    手续费
      p.Pdilid       := NULL; --varchar2(40)  y    发票流水号
      p.Pdflag       := 'Y'; --varchar2(1)  y    实收标志（全部为y.暂无启用）
      p.Pdwyj        := 0; --number(12,2)  y    实收滞金
      p.Pdrcreceived := p_Payment; --number(12,2)  y      实际收款金额（实际收款金额 =  付款金额 -找零金额；销帐金额 + 实收滞金 + 手续费 + 本期发生预存金额）
      p.Pdspje       := 0; --number(12,2)  y    销帐金额(如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0)
      p.Preverseflag := 'N'; --varchar2(1)  y    冲正标志（收水费收预存是为n,冲水费冲预存被冲实收和冲实收产生负帐匀为y）
      IF p_Pid_Source IS NULL THEN
        p.Pdscrid    := p.Pid;
        p.Pdscrtrans := p.Pdtran;
        p.Pdscrmonth := p.Pdmonth;
        p.Pdscrdate  := p.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p.Pdscrid, p.Pdscrtrans, p.Pdscrmonth, p.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
      p.Pdchkno  := NULL; --varchar2(10)  y    进账单号
      p.Pdpriid  := Mi.Sbpriid; --varchar2(20)  y    合收主表号  20150105
      p.Tchkdate := NULL; --date  y    到账日期
    END;
  
    --3、部分费项销帐分帐
    --------------------------------------------------------------------------
    IF p_Ctl_Pre = 允许拆帐 THEN
      Payzwarpre(v_Parm_Ars, 不提交);
    END IF;
  
    --3.1、含违约金销帐分帐
    --------------------------------------------------------------------------
    IF 允许销帐违约金分帐 THEN
      Paywyjpre(v_Parm_Ars, 不提交);
    END IF;
  
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    --------------------------------------------------------------------------
    Payzwarcore(p.Pid,
                p.Pdbatch,
                p_Payment,
                Mi.Sbsaving,
                p.Pddate,
                p.Pdmonth,
                v_Parm_Ars,
                不提交,
                p.Pdspje,
                p.Pdwyj,
                p.Pdsxf);
  
    --5、重算预存发生、预存期末、更新用户预存余额
    p.Pdsavingqm := p.Pdsavingqc + p_Payment - p.Pdspje - p.Pdwyj - p.Pdsxf;
    p.Pdsavingbq := p.Pdsavingqm - p.Pdsavingqc;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --6、返回预存余额
    o_Remainafter := p.Pdsavingqm;
  
    --7、事务内应实收帐务平衡校验，及校验后分支子过程
    --------------------------------------------------------------------------
  
    --8、其他缴费事务反馈过程
  
    --5、提交处理
    BEGIN
      CLOSE c_Ma;
      CLOSE c_Ci;
      CLOSE c_Mi;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p;
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Ma%ISOPEN THEN
        CLOSE c_Ma;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  部分费用项目销帐前拆分应收（一应收帐）：重要规则：销帐包非空时拒绝0金额实销
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是YS_ZW_ARDETAIL的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  2、若存在部分费用销帐标志位（且费项额非0）则按应收调整方式拆分应收帐，否则原包返回；
  3、重构待全额销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE Payzwarpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                       p_Commit   IN NUMBER DEFAULT 不提交) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Varid VARCHAR2, Vardpiid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
         AND Ardpiid = Vardpiid
       ORDER BY Ardclass
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    p_Parm_Ar          Parm_Payar; --销帐包内成员之一
    i                  INTEGER;
    j                  INTEGER;
    k                  INTEGER;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
    总金额             NUMBER(13, 3) := 0;
    待销笔数           NUMBER(10) := 0;
    不销笔数           NUMBER(10) := 0;
    待销水量           NUMBER(10) := 0;
    不销水量           NUMBER(10) := 0;
    待销金额           NUMBER(13, 3) := 0;
    不销金额           NUMBER(13, 3) := 0;
    --被调整原应收
    Rl Ys_Zw_Arlist%ROWTYPE;
    Rd Ys_Zw_Ardetail%ROWTYPE;
    --拆后应收1（要销的）
    Rly    Ys_Zw_Arlist%ROWTYPE;
    Rdy    Ys_Zw_Ardetail%ROWTYPE;
    Rdtaby Rd_Table;
    --拆后应收2（不销继续挂欠费的）
    Rln    Ys_Zw_Arlist%ROWTYPE;
    Rdn    Ys_Zw_Ardetail%ROWTYPE;
    Rdtabn Rd_Table;
    --
    o_Arid_Reverse        Ys_Zw_Arlist.Arid%TYPE;
    o_Artrans_Reverse     VARCHAR2(10);
    o_Arje_Reverse        NUMBER;
    o_Arznj_Reverse       NUMBER;
    o_Arsxf_Reverse       NUMBER;
    o_Arsavingbq_Reverse  NUMBER;
    Io_Arsavingqm_Reverse NUMBER;
    --
    Currentdate DATE;
  BEGIN
    Currentdate := SYSDATE;
    --可以为空（预存充值时），空包返回
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '销帐包中应收流水不存在' || p_Parm_Ar.Arid);
          END IF;
          IF p_Parm_Ar.Ardpiids IS NOT NULL THEN
            Rly      := Rl;
            Rly.Arje := 0;
            Rdtaby   := NULL;
          
            Rln        := Rl;
            Rln.Arje   := 0;
            Rln.Arsxf  := 0; --Rlfee（如有）都放rlY，且必须销帐，暂不支持拆分
            Rdtabn     := NULL;
            待销笔数   := 0;
            不销笔数   := 0;
            待销水量   := 0;
            不销水量   := 0;
            待销金额   := 0;
            不销金额   := 0;
            一行费项数 := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
            FOR j IN 1 .. 一行费项数 LOOP
              一行一费项待销标志 := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
              一行一费项         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
              OPEN c_Rd(p_Parm_Ar.Arid, 一行一费项);
              LOOP
                --存在阶梯，所以要循环
                FETCH c_Rd
                  INTO Rd;
                EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
                Rdy    := Rd;
                Rdn    := Rd;
                总金额 := 总金额 + Rd.Ardje;
                IF 一行一费项待销标志 = 'Y' THEN
                  Rly.Arje     := Rly.Arje + Rdy.Ardje;
                  待销笔数     := 待销笔数 + 1;
                  待销水量     := 待销水量 + Rd.Ardsl;
                  待销金额     := 待销金额 + Rd.Ardje;
                  Rdn.Ardyssl  := 0;
                  Rdn.Ardysje  := 0;
                  Rdn.Ardsl    := 0;
                  Rdn.Ardje    := 0;
                  Rdn.Ardadjsl := 0;
                  Rdn.Ardadjje := 0;
                ELSIF 一行一费项待销标志 = 'N' THEN
                  Rln.Arje     := Rln.Arje + Rdn.Ardje;
                  不销笔数     := 不销笔数 + 1;
                  不销水量     := 不销水量 + Rd.Ardsl;
                  不销金额     := 不销金额 + Rd.Ardje;
                  Rdy.Ardyssl  := 0;
                  Rdy.Ardysje  := 0;
                  Rdy.Ardsl    := 0;
                  Rdy.Ardje    := 0;
                  Rdy.Ardadjsl := 0;
                  Rdy.Ardadjje := 0;
                ELSE
                  Raise_Application_Error(Errcode,
                                          '无法识别销帐包中待销帐标志');
                END IF;
                --复制到rdY
                IF Rdtaby IS NULL THEN
                  Rdtaby := Rd_Table(Rdy);
                ELSE
                  Rdtaby.Extend;
                  Rdtaby(Rdtaby.Last) := Rdy;
                END IF;
                --复制到rdN
                IF Rdtabn IS NULL THEN
                  Rdtabn := Rd_Table(Rdn);
                ELSE
                  Rdtabn.Extend;
                  Rdtabn(Rdtabn.Last) := Rdn;
                END IF;
              END LOOP;
              CLOSE c_Rd;
            END LOOP;
            --某一条应收帐发生部分销帐标志才拆分
            IF 待销笔数 != 0 THEN
              IF 不销笔数 != 0 THEN
                --应收调整1：在本期全额冲减
                Zwarreversecore(p_Parm_Ar.Arid,
                                Rl.Artrans,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                不提交,
                                o_Arid_Reverse,
                                o_Artrans_Reverse,
                                o_Arje_Reverse,
                                o_Arznj_Reverse,
                                o_Arsxf_Reverse,
                                o_Arsavingbq_Reverse,
                                Io_Arsavingqm_Reverse);
                --应收调整2.1：在本期追加目标应收（待销帐部分）
                Rly.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rly.Armonth    := Fobtmanapara(Rly.Manage_No, 'READ_MONTH');
                Rly.Ardate     := Trunc(SYSDATE);
                Rly.Ardatetime := Currentdate;
                Rly.Arreadsl   := 0;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtaby(k).Ardid FROM Dual;
                  Rdtaby(k).Ardid := Rly.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rly;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtaby (k);
                END LOOP;
                --应收调整2.2：在本期追加目标应收（继续挂欠费部分）
                Rln.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rln.Armonth    := Fobtmanapara(Rln.Manage_No, 'READ_MONTH');
                Rln.Ardate     := Trunc(SYSDATE);
                Rln.Ardatetime := Currentdate;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtabn(k).Ardid FROM Dual;
                  Rdtabn(k).Ardid := Rln.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rln;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtabn (k);
                END LOOP;
                --重构销帐包返回
                p_Parm_Ars(i).Arid := Rly.Arid;
                p_Parm_Ars(i).Ardpiids := REPLACE(p_Parm_Ars(i).Ardpiids,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --待销笔数=0
              p_Parm_Ars.Delete(i);
            END IF;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    
    END IF;
    --5、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  应收冲正核心
  【输入参数说明】：
  p_arid_source  in number ：被冲的原应收记录流水号；
  p_pid_reverse  in number ：（可空参数），冲正、退费调用时需要传前置过程产生的冲正实收流水号；
                              在此过程中依此与冲正应收记录绑定
  p_ppayment_reverse in number ：（可空参数），同上参数冲正、退费调用时需要传前置过程产生的冲正实收金额（负），
                                  对已销帐应收的冲正时：
                                  1）依此保持的销帐记录和实收记录的帐务平衡；
                                  2）依此控制销帐预存发生（例如退费不需要发生预存增减、实收冲正时可能有）;
  p_memo ：外部传入帐务备注信息
  p_commit ： 是否过程内提交
  【输出参数说明】：
  o_arid_reverse out varchar2：冲正应收流水
  o_artrans_reverse out varchar2：冲正应收事务
  o_arje_reverse out number：冲正销帐金额
  o_arznj_reverse out number：冲正销帐违约金
  o_arsxf_reverse out number：冲正销帐其他费1
  o_arsavingbq_reverse out number：冲正销帐预存发生
  io_arsavingqm_reverse in out number：外部冲正'销帐应收'循环时的期末预存（累减器）
  【过程说明】：
  基于一条应收总帐记录全额冲正，如应收总账同时为销帐记录，还要更新本冲正帐记录的销帐信息；
  提供销帐预处理、实收冲正、退费、应收调整等业务过程调用；
  【更新日志】：
  */
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT 不提交,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
       ORDER BY Ardpiid, Ardclass
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_p_Reverse(Vrpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vrpid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    --被冲正原应收
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
    --冲正应收
    Rl_Reverse     Ys_Zw_Arlist%ROWTYPE;
    Rd_Reverse     Ys_Zw_Ardetail%ROWTYPE;
    Rd_Reverse_Tab Rd_Table;
    --
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_Rl(p_Arid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      --核心部分校验
      IF 允许重复销帐 = 0 AND Rl_Source.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '当前系统规则不允许划扣中进行应收冲正');
      END IF;
    
      Rl_Reverse                := Rl_Source;
      Rl_Reverse.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
      Rl_Reverse.Ardate         := Trunc(SYSDATE);
      Rl_Reverse.Ardatetime     := SYSDATE; --20140514 add
      Rl_Reverse.Armonth        := Fobtmanapara(Rl_Reverse.Manage_No,
                                                'READ_MONTH');
      Rl_Reverse.Arcd           := 贷方;
      Rl_Reverse.Arreadsl       := -Rl_Reverse.Arreadsl; --20140707 add
      Rl_Reverse.Arsl           := -Rl_Reverse.Arsl;
      Rl_Reverse.Arje           := -Rl_Reverse.Arje; --须全冲
      Rl_Reverse.Arznjreducflag := Rl_Reverse.Arznjreducflag;
      Rl_Reverse.Arznj          := -Rl_Reverse.Arznj; --若销帐则冲正原应收销帐违约金,未销则冲应收违约金
      Rl_Reverse.Arsxf          := -Rl_Reverse.Arsxf; --若销帐则冲正原应收销帐其他费1，,未销则冲应收其他费1
      Rl_Reverse.Arreverseflag  := 'Y';
      Rl_Reverse.Armemo         := p_Memo;
      Rl_Reverse.Artrans        := p_Artrans_Reverse;
      --应收冲正父过程调用下，销帐信息继承源帐
      --实收冲正父过程调用下，销帐信息改写，并判断实收冲正方法
      --退款：实收计‘实收冲销’事务C，应收计‘冲正’事务C
      --不退款：继承原实收、应收事务
      IF p_Pid_Reverse IS NOT NULL THEN
        OPEN c_p_Reverse(p_Pid_Reverse);
        FETCH c_p_Reverse
          INTO p_Reverse;
        IF c_p_Reverse%NOTFOUND OR c_p_Reverse%NOTFOUND IS NULL THEN
          Raise_Application_Error(Errcode, '冲正负帐不存在');
        END IF;
        CLOSE c_p_Reverse;
      
        Rl_Reverse.Arpaiddate  := Trunc(SYSDATE); --若销帐则记录冲正帐期
        Rl_Reverse.Arpaidmonth := Fobtmanapara(Rl_Reverse.Manage_No,
                                               'READ_MONTH'); --若销帐则记录冲正帐期
      
        Rl_Reverse.Arpaidje   := p_Ppayment_Reverse; --销帐信息改写
        Rl_Reverse.Arsavingqc := (CASE
                                   WHEN Io_Arsavingqm_Reverse IS NULL THEN
                                    p_Reverse.Pdsavingqc
                                   ELSE
                                    Io_Arsavingqm_Reverse
                                 END); --销帐信息初改写
        Rl_Reverse.Arsavingbq := Rl_Reverse.Arpaidje - Rl_Reverse.Arje -
                                 Rl_Reverse.Arznj - Rl_Reverse.Arsxf; --销帐信息改写
        Rl_Reverse.Arsavingqm := Rl_Reverse.Arsavingqc +
                                 Rl_Reverse.Arsavingbq; --销帐信息改写
        Rl_Reverse.Arpid      := p_Pid_Reverse;
        Rl_Reverse.Arpbatch   := p_Pbatch_Reverse;
        Io_Arsavingqm_Reverse := Rl_Reverse.Arsavingqm;
      END IF;
      --rlscrrlid    := ;--继承原应收值
      --rlscrrldate  := ;--继承原应收值
      --rlscrrlmonth := ;--继承原应收值
      --rlscrrllb    := ;--继承原应收值
      OPEN c_Rd(p_Arid_Source);
      LOOP
        FETCH c_Rd
          INTO Rd_Source;
        EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
        Rd_Reverse := Rd_Source;
        SELECT Seq_Arid.Nextval INTO Rd_Reverse.Ardid FROM Dual;
        Rd_Reverse.Ardid    := Rl_Reverse.Arid;
        Rd_Reverse.Ardyssl  := -Rd_Reverse.Ardyssl;
        Rd_Reverse.Ardysje  := -Rd_Reverse.Ardysje;
        Rd_Reverse.Ardsl    := -Rd_Reverse.Ardsl;
        Rd_Reverse.Ardje    := -Rd_Reverse.Ardje;
        Rd_Reverse.Ardadjsl := -Rd_Reverse.Ardadjsl;
        Rd_Reverse.Ardadjje := -Rd_Reverse.Ardadjje;
        --复制到rd_reverse_tab
        IF Rd_Reverse_Tab IS NULL THEN
          Rd_Reverse_Tab := Rd_Table(Rd_Reverse);
        ELSE
          Rd_Reverse_Tab.Extend;
          Rd_Reverse_Tab(Rd_Reverse_Tab.Last) := Rd_Reverse;
        END IF;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '无效的应收流水号');
    END IF;
    --返回值
    o_Arid_Reverse       := Rl_Reverse.Arid;
    o_Artrans_Reverse    := Rl_Reverse.Artrans;
    o_Arje_Reverse       := Rl_Reverse.Arje;
    o_Arznj_Reverse      := Rl_Reverse.Arznj;
    o_Arsxf_Reverse      := Rl_Reverse.Arsxf;
    o_Arsavingbq_Reverse := Rl_Reverse.Arsavingbq;
    --2、提交处理
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Arlist VALUES Rl_Reverse;
        FOR k IN Rd_Reverse_Tab.First .. Rd_Reverse_Tab.Last LOOP
          INSERT INTO Ys_Zw_Ardetail VALUES Rd_Reverse_Tab (k);
        END LOOP;
        UPDATE Ys_Zw_Arlist
           SET Arreverseflag = 'Y'
         WHERE Arid = p_Arid_Source;
        --其他控制赋值
        IF p_Ctl_Mircode IS NOT NULL THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = To_Number(p_Ctl_Mircode)
           WHERE Sbid = Rl_Source.Sbid;
        END IF;
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_p_Reverse%ISOPEN THEN
        CLOSE c_p_Reverse;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  销帐违约金分帐销帐包预处理
  【输入参数说明】：
  p_parm_ars in out parm_payar_tab：可以为空（预存充值），待销应收包
                arid  in number :应收流水（依此成员次序销帐）
                ardpiids in varchar2 : 待销费用项目,由是否销帐(Y/N)+费项ID组成的二维数组（基于PG_CB_COST.FGETPARA二维数组规范），例如：Y,01|Y,02|N,03|,次序很重要）
                        为空时：忽略，不拆
                        非空时：1）必须是ys_zw_ardetail的全集费用项目串；
                                2）YN两集合必须均含有非0金额，否则忽略，不拆；
                arznj in number :传入的违约金（本过程内不计算不校验），传多少销多少
                fee1 in number  :其他非系统费项1
  p_commit in number default 不提交
  【输出参数说明】：
  【过程说明】：
  1、解析销帐包完成校验；
  3、重构待销帐包并返回否则原包返回；
  【更新日志】：
  */
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT 不提交) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid;
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Varid;
    p_Parm_Ar  Parm_Payar := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars Parm_Payar_Tab := Parm_Payar_Tab();
    --被调整原应收
    Rl                 Ys_Zw_Arlist%ROWTYPE;
    Rd                 Ys_Zw_Ardetail%ROWTYPE;
    Vexist             NUMBER := 0;
    一行费项数         INTEGER;
    一行一费项         VARCHAR2(10);
    一行一费项待销标志 CHAR(1);
  BEGIN
    --可以为空（预存充值时），空包返回
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arwyj <> 0 AND p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '销帐包中应收流水不存在' || p_Parm_Ar.Arid);
          END IF;
          一行费项数 := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
          FOR j IN 1 .. 一行费项数 LOOP
            一行一费项待销标志 := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
            一行一费项         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
            IF 一行一费项待销标志 = 'N' AND Upper(一行一费项) = 'ZNJ' THEN
              Vexist := 1;
            END IF;
          END LOOP;
          IF Vexist = 1 THEN
            Rl.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
            Rl.Arje           := 0;
            Rl.Arsl           := 0;
            Rl.Arznj          := p_Parm_Ar.Arwyj;
            Rl.Armemo         := '违约金追补';
            Rl.Arznjreducflag := 'Y';
            OPEN c_Rd(p_Parm_Ar.Arid);
            LOOP
              FETCH c_Rd
                INTO Rd;
              EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
              Rd.Ardid    := Rl.Arid;
              Rd.Ardsl    := 0;
              Rd.Ardje    := 0;
              Rd.Ardyssl  := 0;
              Rd.Ardysje  := 0;
              Rd.Ardadjsl := 0;
              Rd.Ardadjje := 0;
              INSERT INTO Ys_Zw_Ardetail VALUES Rd;
            END LOOP;
            INSERT INTO Ys_Zw_Arlist VALUES Rl;
            CLOSE c_Rd;
            --
            p_Parm_Ar.Arid := Rl.Arid;
            IF v_Parm_Ars IS NULL THEN
              v_Parm_Ars := Parm_Payar_Tab(p_Parm_Ar);
            ELSE
              v_Parm_Ars.Extend;
              v_Parm_Ars(v_Parm_Ars.Last) := p_Parm_Ar;
            END IF;
            --
            p_Parm_Ars(i).Arwyj := 0;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    END IF;
    --5、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  实收销帐处理核心
  【输入参数说明】：
  p_pid in varchar2,
  p_payment in number：实收金额
  p_remainbefore in number：销帐包处理前的期初用户预存余额
  p_paiddate in date,
  p_paidmonth in varchar2,
  p_parm_rls in parm_pay1rl_tab,可以为空（预存充值时），销帐包说明
                                本过程忽略其rdpiids成员值，默认‘整笔应收总账和关联应收明细全集’全部销帐
                                其它成员详见paymeter说明包构造
  p_commit in number default 不提交：是否提交
  
  【输出参数说明】：
  o_sum_arje out number：累计销帐金额（只含待销应收明细中的金额）
  o_sum_arsavingbq out number：累计预存发生
  
  【过程说明】：
  1、应收销帐包可以为空（预存充值时）；
  2、非空时，也允许销帐包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下；
  3、包内应收总账及其关联应收明细全部销帐；
  4、允许应收总账0金额销帐；
  5、更新应收帐头、明细表中的销帐信息
  6、返回实收结果信息
  7、预存销帐逻辑：按销帐包内应收次序销帐，资金先进先销，销帐后‘实收金额’余额记录（无论正负）到最后一笔销帐记录上
  
  【更新日志】：
  */
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT 不提交,
                        o_Sum_Arje     OUT NUMBER,
                        o_Sum_Arznj    OUT NUMBER,
                        o_Sum_Arsxf    OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = Varid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N' /*and rlje>0*/ /*支持0金额销帐*/
         FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Rl          Ys_Zw_Arlist%ROWTYPE;
    p_Parm_Ar   Parm_Payar;
    Sumrlpaidje NUMBER(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    p_Remaind   NUMBER(13, 3); --期初预存累减器
  BEGIN
    --期初预存累减器初始化
    p_Remaind := p_Remainbefore;
    --返回值初始化，若销帐包非空但无游标此值返回
    o_Sum_Arje  := 0;
    o_Sum_Arznj := 0;
    o_Sum_Arsxf := 0;
    SAVEPOINT 未销状态;
    IF p_Parm_Ars.Count > 0 THEN
      --可以为空（预存充值时）
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        OPEN c_Rl(p_Parm_Ar.Arid);
        --销帐包非空时，也允许包含不符合销帐条件的应收id，例如代扣隔日销帐本地已销情况下
        FETCH c_Rl
          INTO Rl;
        IF c_Rl%FOUND THEN
          --组织一条待销应收记录更新变量
          Rl.Arpaidflag  := 'Y'; --varchar2(1)  y  'n'    是否销账标志（全额销帐、不存在中间状态）
          Rl.Arsavingqc  := p_Remaind; --number(13,2)  y  0    销帐期初预存
          Rl.Arsavingbq  := -Pg_Cb_Cost.Getmin(p_Remaind,
                                               Rl.Arje + p_Parm_Ar.Arwyj +
                                               p_Parm_Ar.Fee1); --number(13,2)  y  0    销帐预存发生（净减）
          Rl.Arsavingqm  := Rl.Arsavingqc + Rl.Arsavingbq; --number(13,2)  y  0    销帐期末预存
          Rl.Arznj       := p_Parm_Ar.Arwyj; --number(13,2)  y  0    实收违约金
          Rl.Arsxf       := p_Parm_Ar.Fee1; --number(13,2)  y  0    实收其他非系统费项1
          Rl.Arpaiddate  := p_Paiddate; --date  y      销帐日期（实收帐务时钟）
          Rl.Arpaidmonth := p_Paidmonth; --varchar2(7)  y      销帐月份（实收帐务时钟）
          Rl.Arpaidje    := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          Rl.Arpid       := p_Pid; --
          Rl.Arpbatch    := p_Batch;
          Rl.Armicolumn1 := '';
          --中间变量运算
          Sumrlpaidje := Sumrlpaidje + Rl.Arpaidje;
          --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
          IF i = p_Parm_Ars.Last THEN
            Rl.Arsavingbq := Rl.Arsavingbq + (p_Payment - Sumrlpaidje);
            Rl.Arsavingqm := Rl.Arsavingqc + Rl.Arsavingbq;
            Rl.Arpaidje   := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    实收金额（实收金额=应收金额+实收违约金+实收其他非系统费项123+预存发生）；sum(rl.rlpaidje)=p.ppayment
          END IF;
          --核心部分校验
          IF NOT 允许预存发生 AND Rl.Arsavingbq != 0 THEN
            Raise_Application_Error(Errcode,
                                    '当前系统规则为不支持预存发生');
          END IF;
          --反馈实收记录
          o_Sum_Arje  := o_Sum_Arje + Rl.Arje;
          o_Sum_Arznj := o_Sum_Arznj + Rl.Arznj;
          o_Sum_Arsxf := o_Sum_Arsxf + Rl.Arsxf;
          p_Remaind   := p_Remaind + Rl.Arsavingbq;
          --更新待销帐应收记录
          UPDATE Ys_Zw_Arlist
             SET Arpaidflag  = Rl.Arpaidflag,
                 Arsavingqc  = Rl.Arsavingqc,
                 Arsavingbq  = Rl.Arsavingbq,
                 Arsavingqm  = Rl.Arsavingqm,
                 Arznj       = Rl.Arznj,
                 Armicolumn1 = Rl.Armicolumn1,
                 Arsxf       = Rl.Arsxf,
                 Arpaiddate  = Rl.Arpaiddate,
                 Arpaidmonth = Rl.Arpaidmonth,
                 Arpaidje    = Rl.Arpaidje,
                 Arpid       = Rl.Arpid,
                 Arpbatch    = Rl.Arpbatch,
                 Aroutflag   = 'N'
           WHERE Arid = Rl.Arid; --current of c_rl;效率低
        ELSE
          o_Sum_Arsxf := o_Sum_Arsxf + p_Parm_Ar.Fee1;
        END IF;
        CLOSE c_Rl;
      END LOOP;
    END IF;
  
    --核心部分校验
    IF 净减为负预存不销帐 AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      o_Sum_Arje  := 0;
      o_Sum_Arznj := 0;
      o_Sum_Arsxf := 0;
      ROLLBACK TO 未销状态;
    END IF;
  
    --核心部分校验
    IF NOT 允许净减后负预存 AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      Raise_Application_Error(Errcode,
                              '当前系统规则为不支持发生更多期末负预存');
    END IF;
  
    --5、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  预存充值（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE Precust(p_Sbid        IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --校验
    IF p_Payment <= 0 THEN
      Raise_Application_Error(Errcode, '预存充值业务金额必须为正数哦');
    END IF;
    --调用核心
    Precore(p_Sbid,
            Ptrans_独立预存,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            不提交,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  预存退费（一表）
  【输入参数说明】：
  【输出参数说明】：
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE Precustback(p_Sbid        IN VARCHAR2,
                        p_Position    IN VARCHAR2,
                        p_Oper        IN VARCHAR2,
                        p_Payway      IN VARCHAR2,
                        p_Payment     IN NUMBER,
                        p_Memo        IN VARCHAR2,
                        p_Batch       IN OUT VARCHAR2,
                        o_Pid         OUT VARCHAR2,
                        o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --校验
    IF p_Payment >= 0 THEN
      Raise_Application_Error(Errcode, '预存充值业务金额必须为负数哦');
    END IF;
    --调用核心
    Precore(p_Sbid,
            Ptrans_独立预存,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            不提交,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  预存实收处理核心
  【输入参数说明】：
  p_sbid        in varchar2：指定预存发生的水表编号
  p_trans      in varchar2：指定预存发生计帐实收事务
  p_position      in varchar2：指定预存发生缴费单位
  p_paypoint   in varchar2：指定预存发生缴费地点
  p_bdate      in date：指定预存发生银行帐务日期
  p_bseqno     in varchar2：指定预存发生银行交易流水
  p_oper       in varchar2：预存收款人
  p_payway     in varchar2：预存发生付款方式
  p_payment    in number：预存发生金额（+/-）
  p_commit     in number：是否提交
  p_memo       in varchar2：备注信息
  p_batch      in out number：可空，绑定批次
  p_seqno      in out number：可空，绑定批次流水
  【输出参数说明】：
  p_pid        out number：预存发生记录计帐成功后返回的实收流水号
  【过程说明】：
  【更新日志】：
  */
  PROCEDURE Precore(p_Sbid        IN VARCHAR2,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Commit      IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    p  Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    IF NOT 允许预存发生 THEN
      Raise_Application_Error(Errcode, '当前系统规则为不支持预存发生');
    END IF;
    --1、校验及其初始化
    BEGIN
      --取水表信息
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Sbid);
      END IF;
      --取用户信息
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '这个水表编码没对应用户！' || p_Sbid);
      END IF;
    END;
  
    --2、记录实收
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code    := Mi.Hire_Code;
      p.Pid          := o_Pid;
      p.Yhid         := Ci.Yhid;
      p.Sbid         := Mi.Sbid;
      p.Pdrcreceived := p_Payment;
      p.Pddate       := Trunc(SYSDATE);
      p.Pdatetime    := SYSDATE;
      p.Pdmonth      := Fobtmanapara(Mi.Manage_No, 'READ_MONTH');
      p.Manage_No    := p_Position;
      p.Pdpaypoint   := p_Paypoint;
      p.Pdtran       := p_Trans;
      p.Pdpers       := p_Oper;
      p.Pdpayee      := p_Oper;
      p.Pdpayway     := p_Payway;
      p.Paidment     := p_Payment;
      p.Pdspje       := 0;
      p.Pdwyj        := 0;
      p.Pdsavingqc   := Nvl(Mi.Sbsaving, 0);
      p.Pdsavingbq   := p_Payment;
      p.Pdsavingqm   := p.Pdsavingqc + p.Pdsavingbq;
      p.Pdsxf        := 0; --若为独立押金;
      p.Preverseflag := 'N'; --帐务状态（收水费收预存是为N,冲水费冲预存被冲实收和冲实收产生负帐匀为Y）
      p.Pdbdate      := Trunc(p_Bdate);
      p.Pdbseqno     := p_Bseqno;
      p.Pdchkdate    := NULL;
      p.Pdcchkflag   := NULL;
      p.Pdcdate      := NULL;
      p.Pdcseqno     := NULL;
      p.Pdmemo       := p_Memo;
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno    := p_Seqno;
      p.Pdscrid    := p.Pid;
      p.Pdscrtrans := p.Pdtran;
      p.Pdscrmonth := p.Pdmonth;
      p.Pdscrdate  := p.Pddate;
    END;
    p.Pdchkno     := NULL; --varchar2(10)  y    进账单号
    p.Pdpriid     := Mi.Sbpriid; --varchar2(20)  y    合收主表号  20150105
    p.Tchkdate    := NULL; --date  y    到账日期
    o_Remainafter := p.Pdsavingqm;
  
    --校验
    IF NOT 允许净减后负预存 AND p.Pdsavingqm < 0 AND p.Pdsavingqm < p.Pdsavingqc THEN
      Raise_Application_Error(Errcode,
                              '当前系统规则为不支持发生更多的期末负预存');
    END IF;
    INSERT INTO Ys_Zw_Paidment VALUES p;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --5、提交处理
    BEGIN
      CLOSE c_Ci;
      CLOSE c_Mi;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  --
  FUNCTION Fmid(p_Str IN VARCHAR2, p_Sep IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    i INTEGER;
    n INTEGER := 1;
  BEGIN
    IF TRIM(p_Str) IS NULL THEN
      RETURN 0;
    ELSE
      FOR i IN 1 .. Length(p_Str) LOOP
        IF Substr(p_Str, i, 1) = p_Sep THEN
          n := n + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN n;
  END;
  --1、实收冲正（当月负实收）
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER) IS
    CURSOR c_p(Vpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vpid FOR UPDATE NOWAIT;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    Mi        Ys_Yh_Sbinfo%ROWTYPE;
    p_Source  Ys_Zw_Paidment%ROWTYPE;
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_p(p_Pid_Source);
    FETCH c_p
      INTO p_Source;
    IF c_p%FOUND THEN
      OPEN c_Mi(p_Source.Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '无效的用户编号');
      END IF;
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid_Reverse
        FROM Dual;
      SELECT Sys_Guid() INTO p_Reverse.Id FROM Dual;
      p_Reverse.Hire_Code  := Mi.Hire_Code;
      p_Reverse.Pid        := p_Source.Pid;
      p_Reverse.Yhid       := p_Source.Yhid;
      p_Reverse.Sbid       := p_Source.Sbid;
      p_Reverse.Pddate     := Trunc(SYSDATE);
      p_Reverse.Pdatetime  := SYSDATE;
      p_Reverse.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    缴费月份
      p_Reverse.Manage_No  := p_Position;
      p_Reverse.Pdtran     := p_Ptrans;
      p_Reverse.Pdpers     := p_Oper;
      p_Reverse.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    期初预存余额
      p_Reverse.Pdsavingbq := -p_Source.Pdsavingbq;
      p_Reverse.Pdsavingqm := p_Reverse.Pdsavingqc + p_Reverse.Pdsavingbq; --number(12,2)  y    期末预存余额;
      p_Reverse.Paidment   := -p_Source.Paidment;
      /* --核心部分校验
      if not 允许预存发生 and p_reverse.psavingbq != 0 then
        raise_application_error(errcode, '当前系统规则为不支持预存发生');
      end if;
      if not 允许净减后负预存 and p_reverse.pdsavingqm < 0 and
         p_reverse.pdsavingqm < p_reverse.pdsavingqc then
        raise_application_error(errcode,
                                '当前系统规则为不支持发生更多的期末负预存');
      end if;*/
      UPDATE Ys_Yh_Sbinfo
         SET Sbsaving = p_Reverse.Pdsavingqm
       WHERE CURRENT OF c_Mi;
    
      p_Reverse.Pdifsaving := NULL;
      p_Reverse.Pdchange   := NULL;
      p_Reverse.Pdpayway   := p_Payway;
      p_Reverse.Pdbseqno   := p_Source.Pdbseqno;
      p_Reverse.Pdcseqno   := p_Source.Pdcseqno;
      p_Reverse.Pdbdate    := p_Source.Pdbdate;
      p_Reverse.Pdchkdate  := p_Source.Pdchkdate;
      p_Reverse.Pdcchkflag := p_Source.Pdcchkflag;
      p_Reverse.Pdcdate    := p_Source.Pdcdate;
      /*IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO p_reverse.PDBATCH
          FROM DUAL;
      ELSE
        p_reverse.PDBATCH := P_BATCH;
      END IF;*/
      p_Reverse.Pdbatch      := p_Source.Pdbatch;
      p_Reverse.Pdseqno      := p_Source.Pdseqno;
      p_Reverse.Pdpayee      := p_Source.Pdpayee;
      p_Reverse.Pdchbatch    := p_Source.Pdchbatch;
      p_Reverse.Pdmemo       := p_Source.Pdmemo;
      p_Reverse.Pdpaypoint   := p_Source.Pdpaypoint;
      p_Reverse.Pdsxf        := -p_Source.Pdsxf;
      p_Reverse.Pdilid       := p_Source.Pdilid;
      p_Reverse.Pdflag       := p_Source.Pdflag;
      p_Reverse.Pdwyj        := -p_Source.Pdwyj;
      p_Reverse.Pdrcreceived := -p_Source.Pdrcreceived;
      p_Reverse.Pdspje       := p_Source.Pdspje;
      p_Reverse.Preverseflag := 'Y';
      IF p_Pid_Source IS NULL THEN
        p_Reverse.Pdscrid    := p_Source.Pid;
        p_Reverse.Pdscrtrans := p_Source.Pdtran;
        p_Reverse.Pdscrmonth := p_Source.Pdmonth;
        p_Reverse.Pdscrdate  := p_Source.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p_Reverse.Pdscrid,
               p_Reverse.Pdscrtrans,
               p_Reverse.Pdscrmonth,
               p_Reverse.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
    
      p_Reverse.Pdchkno  := p_Source.Pdchkno;
      p_Reverse.Pdpriid  := p_Source.Pdpriid;
      p_Reverse.Tchkdate := p_Source.Tchkdate;
      p_Reverse.Pdtax    := p_Source.Pdtax;
      p_Reverse.Pdzdate  := p_Source.Pdzdate;
    
    ELSE
      Raise_Application_Error(Errcode, '无效的实收流水号');
    END IF;
    o_Ppayment_Reverse := p_Reverse.Paidment;
  
    --------------------------------------------------------------------------
    --2、提交处理
    BEGIN
      CLOSE c_Mi;
      CLOSE c_p;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p_Reverse;
        UPDATE Ys_Zw_Paidment
           SET Preverseflag = 'Y'
         WHERE Pid = p_Pid_Source;
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      IF c_p%ISOPEN THEN
        CLOSE c_p;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreversecorebypid;

  /*==========================================================================
  应收追帐核心
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  根据参数追加一套应收总账和关联应收明细（且须追加为欠费）；
  提供应收调整中追加调整目标帐、追补、营业外、冲正中追正、退费中追正等业务过程调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid;
    CURSOR c_Md(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmiid;
    CURSOR c_Ma(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmiid;
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Md Ys_Yh_Sbdoc%ROWTYPE;
    Ma Ys_Yh_Account%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    Bf Ys_Bas_Book%ROWTYPE;
    CURSOR c_Rlsource(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid;
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rl_Append Ys_Zw_Arlist%ROWTYPE;
    Rd_Append Ys_Zw_Ardetail%ROWTYPE;
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    Rdtab_Append Rd_Table;
  
    Vappend1rd Parm_Append1rd;
  BEGIN
    --取水表信息
    OPEN c_Mi(p_Rlmid);
    FETCH c_Mi
      INTO Mi;
    IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    BEGIN
      SELECT * INTO Bf FROM Ys_Bas_Book WHERE Book_No = Mi.Book_No;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    OPEN c_Md(p_Rlmid);
    FETCH c_Md
      INTO Md;
    IF c_Md%NOTFOUND OR c_Md%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '这是传的水表编码？' || p_Rlmid);
    END IF;
    --
    OPEN c_Ma(p_Rlmid);
    FETCH c_Ma
      INTO Ma;
    IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
      NULL;
    END IF;
    --取用户信息
    OPEN c_Ci(Mi.Yhid);
    FETCH c_Ci
      INTO Ci;
    IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '这个水表编码没对应用户！' || p_Rlmid);
    END IF;
    --组织追加应收总账和明细行变量
    IF p_Rlid_Source IS NOT NULL THEN
      OPEN c_Rlsource(p_Rlid_Source);
      FETCH c_Rlsource
        INTO Rl_Source;
      IF c_Rlsource%NOTFOUND THEN
        Raise_Application_Error(Errcode,
                                '可以为空的原应收帐流水号非空但无效');
      END IF;
      CLOSE c_Rlsource;
    END IF;
    SELECT TRIM(Lpad(Seq_Arid.Nextval, 10, '0')) INTO o_Rlid FROM Dual;
    SELECT Uuid() INTO Rl_Append.Id FROM Dual;
  
    Rl_Append.Hire_Code   := f_Get_Hire_Code();
    Rl_Append.Manage_No   := Mi.Manage_No;
    Rl_Append.Arid        := o_Rlid;
    Rl_Append.Armonth     := Fobtmanapara(Rl_Source.Manage_No, 'READ_MONTH');
    Rl_Append.Ardate      := p_Rlrdate; --Trunc(SYSDATE);
    Rl_Append.Yhid        := Mi.Yhid;
    Rl_Append.Sbid        := Mi.Sbid;
    Rl_Append.Archargeper := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Archargeper
                               ELSE
                                Bf.Read_Per
                             END);
  
    Rl_Append.Arcpid        := Ci.Yhpid;
    Rl_Append.Arcclass      := Ci.Yhclass;
    Rl_Append.Arcflag       := Ci.Yhflag;
    Rl_Append.Arusenum      := Mi.Sbusenum;
    Rl_Append.Arcname       := Ci.Yhname;
    Rl_Append.Arcadr        := Ci.Yhadr;
    Rl_Append.Armadr        := Mi.Sbadr;
    Rl_Append.Arcstatus     := Ci.Yhstatus;
    Rl_Append.Armtel        := Ci.Yhmtel;
    Rl_Append.Artel         := Ci.Yhtel1;
    Rl_Append.Arbankid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arbankid
                            ELSE
                             Ma.Yhabankid
                          END);
    Rl_Append.Artsbankid := (CASE
                              WHEN Rl_Source.Arid IS NOT NULL THEN
                               Rl_Source.Artsbankid
                              ELSE
                               Ma.Yhatsbankid
                            END);
    Rl_Append.Araccountno := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Araccountno
                               ELSE
                                Ma.Yhaaccountno
                             END);
    Rl_Append.Araccountname := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Araccountname
                                 ELSE
                                  Ma.Yhaaccountname
                               END);
    Rl_Append.Ariftax := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Ariftax
                           ELSE
                            Mi.Sbiftax
                         END);
    Rl_Append.Artaxno := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Artaxno
                           ELSE
                            Mi.Sbtaxno
                         END);
    Rl_Append.Arifinv := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arifinv
                           ELSE
                            Ci.Yhifinv
                         END); --开票标志 
    Rl_Append.Armcode       := Mi.Sbcode;
    Rl_Append.Armpid        := Mi.Sbpid;
    Rl_Append.Armclass      := Mi.Sbclass;
    Rl_Append.Armflag       := Mi.Sbflag;
    Rl_Append.Arday := (CASE
                         WHEN Rl_Source.Arid IS NOT NULL THEN
                          Rl_Source.Arday
                         ELSE
                          Trunc(SYSDATE)
                       END);
    Rl_Append.Arbfid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arbfid
                          ELSE
                           Mi.Book_No
                        END);
    Rl_Append.Arprdate := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arprdate
                            ELSE
                             Trunc(SYSDATE)
                          END);
    Rl_Append.Arrdate := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arrdate
                           ELSE
                            Trunc(SYSDATE)
                         END);
    Rl_Append.Arzndate      := Rl_Append.Ardate + 30;
    Rl_Append.Arcaliber     := Md.Mdcaliber;
    Rl_Append.Arrtid        := Mi.Sbrtid;
    Rl_Append.Armstatus     := Mi.Sbstatus;
    Rl_Append.Armtype       := Mi.Sbtype;
    Rl_Append.Armno         := Md.Mdno;
    Rl_Append.Arscode       := p_Rlscode; --NUMBER(10)  Y    起数 
    Rl_Append.Arecode       := p_Rlecode; --NUMBER(10)  Y    止数 
    Rl_Append.Arreadsl      := p_Rlsl; --NUMBER(10)  Y    抄见水量 
  
    Rl_Append.Arinvmemo       := Rl_Source.Arinvmemo;
    Rl_Append.Arentrustbatch  := Rl_Source.Arentrustbatch;
    Rl_Append.Arentrustseqno  := Rl_Source.Arentrustseqno;
    Rl_Append.Aroutflag := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Aroutflag
                             ELSE
                              'N'
                           END);
    Rl_Append.Artrans         := p_Rltrans;
    Rl_Append.Arcd            := 'DE';
    Rl_Append.Aryschargetype := (CASE
                                  WHEN Rl_Source.Arid IS NOT NULL THEN
                                   Rl_Source.Aryschargetype
                                  ELSE
                                   Mi.Sbchargetype
                                END);
    Rl_Append.Arsl            := 0;
    Rl_Append.Arje            := 0;
    Rl_Append.Araddsl         := Rl_Source.Araddsl;
    Rl_Append.Arscrarid := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arscrarid
                             ELSE
                              Rl_Append.Arid
                           END);
    Rl_Append.Arscrartrans := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrartrans
                                ELSE
                                 Rl_Append.Artrans
                              END);
    Rl_Append.Arscrarmonth := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrarmonth
                                ELSE
                                 Rl_Append.Armonth
                              END);
    Rl_Append.Arpaidje        := Rl_Source.Arpaidje;
    Rl_Append.Arpaidflag      := Rl_Source.Arpaidflag;
    Rl_Append.Arpaidper       := Rl_Source.Arpaidper;
    Rl_Append.Arpaiddate      := Rl_Source.Arpaiddate;
    Rl_Append.Armrid          := Rl_Source.Armrid;
    Rl_Append.Armemo          := Nvl(p_Rlmemo, Rl_Source.Armemo);
    Rl_Append.Arznj           := Rl_Source.Arznj;
    Rl_Append.Arlb            := Rl_Source.Arlb;
    Rl_Append.Arcname2        := Rl_Source.Arcname2;
    Rl_Append.Arpfid          := p_Rlpfid; --VARCHAR2(10)  Y    主价格类别
    Rl_Append.Ardatetime      := SYSDATE;
    Rl_Append.Arscrardate := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Arscrardate
                               ELSE
                                Rl_Append.Ardate
                             END);
    Rl_Append.Arprimcode      := Rl_Source.Arprimcode;
    Rl_Append.Arpriflag       := Rl_Source.Arpriflag;
    Rl_Append.Arrper          := Rl_Source.Arrper;
    Rl_Append.Arsafid         := Rl_Source.Arsafid;
    Rl_Append.Arscodechar     := Rl_Source.Arscodechar;
    Rl_Append.Arecodechar     := Rl_Source.Arecodechar;
    Rl_Append.Arilid          := Rl_Source.Arilid;
    Rl_Append.Armiuiid        := Rl_Source.Armiuiid;
    Rl_Append.Argroup         := Rl_Source.Argroup;
    Rl_Append.Arpid           := Rl_Source.Arpid;
    Rl_Append.Arpbatch        := Rl_Source.Arpbatch;
    Rl_Append.Arsavingqc      := Rl_Source.Arsavingqc;
    Rl_Append.Arsavingbq      := Rl_Source.Arsavingbq;
    Rl_Append.Arsavingqm      := Rl_Source.Arsavingqm;
    Rl_Append.Arreverseflag   := Rl_Source.Arreverseflag;
    Rl_Append.Arbadflag       := Rl_Source.Arbadflag;
    Rl_Append.Arznjreducflag  := Rl_Source.Arznjreducflag;
    Rl_Append.Armistid        := Rl_Source.Armistid;
    Rl_Append.Arminame        := Rl_Source.Arminame;
    Rl_Append.Arsxf           := Rl_Source.Arsxf;
    Rl_Append.Armiface2       := Rl_Source.Armiface2;
    Rl_Append.Armiface3       := Rl_Source.Armiface3;
    Rl_Append.Armiface4       := Rl_Source.Armiface4;
    Rl_Append.Armiifckf       := Rl_Source.Armiifckf;
    Rl_Append.Armigps         := Rl_Source.Armigps;
    Rl_Append.Armiqfh         := Rl_Source.Armiqfh;
    Rl_Append.Armibox         := Rl_Source.Armibox;
    Rl_Append.Arminame2       := Rl_Source.Arminame2;
    Rl_Append.Armiseqno       := Rl_Source.Armiseqno;
    Rl_Append.Armisaving      := Rl_Source.Armisaving;
    Rl_Append.Arpriorje       := Rl_Source.Arpriorje;
    Rl_Append.Armicommunity   := Rl_Source.Armicommunity;
    Rl_Append.Armiremoteno    := Rl_Source.Armiremoteno;
    Rl_Append.Armiremotehubno := Rl_Source.Armiremotehubno;
    Rl_Append.Armiemail       := Rl_Source.Armiemail;
    Rl_Append.Armiemailflag   := Rl_Source.Armiemailflag;
    Rl_Append.Armicolumn1     := Rl_Source.Armicolumn1;
    Rl_Append.Armicolumn2     := Rl_Source.Armicolumn2;
    Rl_Append.Armicolumn3     := Rl_Source.Armicolumn3;
    Rl_Append.Armicolumn4     := Rl_Source.Armicolumn4;
    Rl_Append.Arpaidmonth     := Rl_Source.Arpaidmonth;
    Rl_Append.Arcolumn5       := Rl_Source.Arcolumn5;
    Rl_Append.Arcolumn9       := Rl_Source.Arcolumn9;
    Rl_Append.Arcolumn10      := Rl_Source.Arcolumn10;
    Rl_Append.Arcolumn11      := Rl_Source.Arcolumn11;
    Rl_Append.Arjtmk          := Rl_Source.Arjtmk;
    Rl_Append.Arjtsrq         := Rl_Source.Arjtsrq;
    Rl_Append.Arcolumn12      := Rl_Source.Arcolumn12;
  
    Rl_Append.Arprimcode  := Mi.Sbpriid; --VARCHAR2(200)  Y    合收表主表号
    Rl_Append.Arpriflag   := Mi.Sbpriflag; --CHAR(1)  Y    合收表标志
    Rl_Append.Arrper := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arrper
                          ELSE
                           Bf.Read_Per
                        END); --VARCHAR2(10)  Y    抄表员
    Rl_Append.Arsafid := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arsafid
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    区域
    Rl_Append.Arscodechar := To_Char(p_Rlscode); --VARCHAR2(10)  Y    上期抄表（带表位）
    Rl_Append.Arecodechar := To_Char(p_Rlecode); --VARCHAR2(10)  Y    本期抄表（带表位）
    Rl_Append.Arilid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arilid
                          ELSE
                           NULL
                        END); --VARCHAR2(40)  Y    发票打印批次
    Rl_Append.Armiuiid    := Mi.Sbuiid; --VARCHAR2(10)  Y    合收单位编号
    Rl_Append.Argroup := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Argroup
                           ELSE
                            NULL
                         END); --NUMBER(2)  Y    应收帐分组
    /**/
    Rl_Append.Arznj := p_Rlznj; --NUMBER(13,3)  Y    违约金
    /**/
    Rl_Append.Arzndate := p_Rlzndate; --DATE  Y    违约金起算日
    /**/
    Rl_Append.Arznjreducflag := p_Rlznjreducflag; --VARCHAR2(1)  Y    滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取rlznj
    Rl_Append.Armistid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Armistid
                            ELSE
                             NULL
                          END); --VARCHAR2(10)  Y    行业分类
    /**/
    Rl_Append.Arminame      := Nvl(p_Rlcname, Mi.Sbname); --VARCHAR2(64)  Y    票据名称
    Rl_Append.Arsxf         := 0; --NUMBER(12,2)  Y    手续费
    Rl_Append.Armiface2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface2
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    抄见故障
    Rl_Append.Armiface3 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface3
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    非常计量
    Rl_Append.Armiface4 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface4
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    表井设施说明
    Rl_Append.Armiifckf := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiifckf
                             ELSE
                              NULL
                           END); --CHAR(1)  Y    垃圾费户数
    Rl_Append.Armigps := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armigps
                           ELSE
                            NULL
                         END); --VARCHAR2(60)  Y    是否合票
    Rl_Append.Armiqfh := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armiqfh
                           ELSE
                            NULL
                         END); --VARCHAR2(20)  Y    铅封号
    Rl_Append.Armibox := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armibox
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    消防水价（增值税水价，襄阳需求）
    Rl_Append.Arminame2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arminame2
                             ELSE
                              NULL
                           END); --VARCHAR2(64)  Y    招牌名称(小区名，襄阳需求）
    Rl_Append.Armiseqno := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiseqno
                             ELSE
                              NULL
                           END); --VARCHAR2(50)  Y    户号（初始化时册号+序号）
    Rl_Append.Arsavingqc    := Mi.Sbsaving; --NUMBER(13,3)  Y    算费时预存
    Rl_Append.Armicommunity := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Armicommunity
                                 ELSE
                                  NULL
                               END); --VARCHAR2(10)  Y    小区
  
    --rl_append.ARbddsl         := 0; --NUMBER(10)  Y    估抄水量
    /**/
    Rl_Append.Arsl := p_Rlsl; --NUMBER(10)  Y    应收水量
    /**/
    Rl_Append.Arje          := p_Rlje; --NUMBER(13,3)  Y    应收金额
    Rl_Append.Arpaidje      := 0; --NUMBER(13,3)  Y    销帐金额
    Rl_Append.Arpaidflag    := 'N'; --CHAR(1)  Y    销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    Rl_Append.Arpaidper     := NULL; --VARCHAR2(20)  Y    销帐人员
    Rl_Append.Arpaiddate    := NULL; --DATE  Y    销帐日期
    Rl_Append.Arpaidmonth   := NULL; --VARCHAR2(7)  Y    销账月份
    Rl_Append.Arcolumn11    := NULL; --VARCHAR2(7)  Y    实收事务
    Rl_Append.Arpid         := NULL; --VARCHAR2(10)  Y    实收流水（与payment.pid对应）
    Rl_Append.Arpbatch      := NULL; --VARCHAR2(10)  Y    缴费交易批次（与payment.PBATCH对应）
    Rl_Append.Arsavingqc    := 0; --NUMBER(12,2)  Y    期初预存（销帐时产生）
    Rl_Append.Arsavingbq    := 0; --NUMBER(12,2)  Y    本期预存发生（销帐时产生）
    Rl_Append.Arsavingqm    := 0; --NUMBER(12,2)  Y    期末预存（销帐时产生）
    Rl_Append.Arreverseflag := 'N'; --VARCHAR2(1)  Y      冲正标志（N为正常，Y为冲正）
    Rl_Append.Arbadflag     := 'N'; --VARCHAR2(1)  Y    呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）
    BEGIN
      --NUMBER(13,3)  Y  之前欠费
      SELECT Nvl(SUM(Nvl(Arje, 0) - Nvl(Arpaidje, 0)), 0)
        INTO Rl_Append.Arpriorje
        FROM Ys_Zw_Arlist
       WHERE Arreverseflag = 'Y'
         AND Arpaidflag = 'N'
         AND Arje > 0
         AND Sbid = Rl_Append.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        Rl_Append.Arpriorje := 0;
    END;
    IF p_Parm_Append1rds IS NOT NULL THEN
      FOR i IN p_Parm_Append1rds.First .. p_Parm_Append1rds.Last LOOP
        Vappend1rd := p_Parm_Append1rds(i);
        --
        Rd_Append.Id            := Uuid();
        Rd_Append.Hire_Code     := f_Get_Hire_Code();
        Rd_Append.Ardid         := o_Rlid; --VARCHAR2(10)      流水号
        Rd_Append.Ardpmdid      := Vappend1rd.Ardpmdid; --NUMBER      混合用水分组
        Rd_Append.Ardpiid       := Vappend1rd.Ardpiid; --CHAR(2)      费用项目
        Rd_Append.Ardpfid       := Nvl(Vappend1rd.Ardpfid, p_Rlpfid); --VARCHAR2(10)      费率
        Rd_Append.Ardpscid      := Vappend1rd.Ardpscid; --NUMBER      费率明细方案
        Rd_Append.Ardclass      := Vappend1rd.Ardclass; --NUMBER      阶梯级别
        Rd_Append.Ardysdj       := Vappend1rd.Arddj; --NUMBER(13,3)  Y    应收单价
        Rd_Append.Ardyssl       := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    应收水量
        Rd_Append.Ardysje       := Vappend1rd.Ardje; --NUMBER(13,3)  Y    应收金额
        Rd_Append.Arddj         := Vappend1rd.Arddj; --NUMBER(13,3)  Y    实收单价
        Rd_Append.Ardsl         := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    实收水量
        Rd_Append.Ardje         := Vappend1rd.Ardje; --NUMBER(13,3)  Y    实收金额
        Rd_Append.Ardadjdj      := 0; --NUMBER(13,3)  Y    调整单价
        Rd_Append.Ardadjsl      := 0; --NUMBER(12,2)  Y    调整水量
        Rd_Append.Ardadjje      := 0; --NUMBER(13,3)  Y    调整金额
        Rd_Append.Ardmethod     := NULL; --CHAR(3)  Y    计费方法
        Rd_Append.Ardpaidflag   := NULL; --CHAR(1)  Y    销帐标志
        Rd_Append.Ardpaiddate   := NULL; --DATE  Y    销帐日期
        Rd_Append.Ardpaidmonth  := NULL; --VARCHAR2(7)  Y    销帐月份
        Rd_Append.Ardpaidper    := NULL; --VARCHAR2(20)  Y    销帐人员
        Rd_Append.Ardpmdscale   := NULL; --NUMBER(10,2)  Y    混合比例
        Rd_Append.Ardilid       := Vappend1rd.Ardilid; --VARCHAR2(10)  Y    票据流水
        Rd_Append.Ardznj        := NULL; --NUMBER(12,2)  Y    违约金
        Rd_Append.Ardmemo       := p_Rlmemo; --VARCHAR2(200)  Y    备注
        Rd_Append.Ardmsmfid     := NULL; --VARCHAR2(10)  Y    营销公司
        Rd_Append.Ardmonth      := NULL; --VARCHAR2(7)  Y    帐务月份
        Rd_Append.Ardmid        := NULL; --VARCHAR2(10)  Y    水表编号
        Rd_Append.Ardpmdtype    := NULL; --VARCHAR2(2)  Y    混合类别
        Rd_Append.Ardpmdcolumn1 := NULL; --VARCHAR2(10)  Y    备用字段1
        Rd_Append.Ardpmdcolumn2 := NULL; --VARCHAR2(10)  Y    备用字段2
        Rd_Append.Ardpmdcolumn3 := NULL; --VARCHAR2(10)  Y    备用字段3
      
        --复制到rdTab_append
        IF Rdtab_Append IS NULL THEN
          Rdtab_Append := Rd_Table(Rd_Append);
        ELSE
          Rdtab_Append.Extend;
          Rdtab_Append(Rdtab_Append.Last) := Rd_Append;
        END IF;
      END LOOP;
    END IF;
  
    --其他控制赋值
    IF p_Ctl_Mircode IS NOT NULL THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = To_Number(p_Ctl_Mircode),
             Sbrcodechar = p_Ctl_Mircode
       WHERE Sbid = p_Rlmid;
    END IF;
  
    --2、提交处理
    BEGIN
      INSERT INTO Ys_Zw_Arlist VALUES Rl_Append;
      FOR k IN Rdtab_Append.First .. Rdtab_Append.Last LOOP
        INSERT INTO Ys_Zw_Ardetail VALUES Rdtab_Append (k);
      END LOOP;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rlsource%ISOPEN THEN
        CLOSE c_Rlsource;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendcore;

  /*==========================================================================
  应收追正
  【输入参数说明】：
  p_rlid_source in number：源应收流水号
  p_rdpiids ：指定基于原应收帐派生的枚举费项（一位数组字符串，基于TOOLS.FGETPARA二维数组规范），例'01|02|03|'）;
              应收总账下全部费项传'ALL'；
              此参数为空，追正帐应收明细依然按应收总账下全部应收明细记录数生成，但量费均置0；
  p_memo in varchar2：冲正备注
  p_commit in number default 不提交：是否提交
  【输出参数说明】：
  【过程说明】：
  基于原应收记录复制追加一条应收（欠费状态）记录及关联应收明细（可指定枚举的费用项目）；
  提供给部分销帐预处理（拆分应收）、实收冲正、退费业务过程中调用
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER) IS
    CURSOR c_Rl(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
    CURSOR c_Rd(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Vrlid FOR UPDATE NOWAIT; --若被锁直接抛出异常
  
    --原应收
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
  
    Vappend1rd  Parm_Append1rd;
    Vappend1rds Parm_Append1rd_Tab;
  BEGIN
    o_Rlje     := Nvl(o_Rlje, 0);
    Vappend1rd := Parm_Append1rd(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
    OPEN c_Rl(p_Rlid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      OPEN c_Rd(p_Rlid_Source);
      FETCH c_Rd
        INTO Rd_Source;
      IF c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '无效的应收流水号' || p_Rlid_Source);
      END IF;
      WHILE c_Rd%FOUND LOOP
        ------------------------------------------------
        IF Instr(p_Rdpiids, Rd_Source.Ardpiid || '|') > 0 OR
           Upper(p_Rdpiids) = 'ALL' THEN
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := Rd_Source.Ardsl;
          Vappend1rd.Ardje     := Rd_Source.Ardje;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        ELSE
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := 0;
          Vappend1rd.Ardje     := 0;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        END IF;
        --复制到vappend1rds
        IF Vappend1rds IS NULL THEN
          Vappend1rds := Parm_Append1rd_Tab(Vappend1rd);
        ELSE
          Vappend1rds.Extend;
          Vappend1rds(Vappend1rds.Last) := Vappend1rd;
        END IF;
        o_Rlje := o_Rlje + Vappend1rd.Ardje;
        ------------------------------------------------
        FETCH c_Rd
          INTO Rd_Source;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '无效的应收流水号');
    END IF;
  
    Recappendcore(Rl_Source.Sbid,
                  Rl_Source.Arminame,
                  Rl_Source.Arpfid,
                  Rl_Source.Arrdate,
                  Rl_Source.Arscode,
                  Rl_Source.Arecode,
                  Rl_Source.Arsl,
                  o_Rlje,
                  Rl_Source.Arznjreducflag,
                  Rl_Source.Arzndate,
                  Rl_Source.Arznj,
                  p_Rltrans, --rl_source.rltrans,
                  p_Memo,
                  Rl_Source.Arid,
                  Vappend1rds,
                  NULL, --不重置起码
                  不提交,
                  o_Rlid);
  
    --2、提交处理
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendinherit;

  /*==========================================================================
  实收冲正次核心
  【输入参数说明】：
  p_pid_source  in number：待冲正实收流水号，允许预存充值实收类型（无关联应收销帐）
  p_position      in varchar2：冲正到缴费单位
  p_paypoint    in varchar2：冲正到缴费点
  p_ptrans      in varchar2：冲正到实收事务
  p_bdate       in date：银行冲正日期
  p_bseqno      in varchar2：银行冲正流水
  p_oper        in varchar2：冲正操作员
  p_payway      in varchar2：冲正到付款方式
  p_memo        in varchar2：冲正备注
  p_commit      in number：是否提交
  
  【输出参数说明】：
  o_pid_reverse out number：冲正（负帐）记录实收流水号
  o_ppayment_reverse out number：冲正（负帐）记录实收冲正金额
  【过程说明】：
  提供水司柜台冲正、银行实时退单、银行单边帐冲正调用
  基于一条实收记录payment.pid进行实收冲正的操作，且对全部关联应收进行逆销帐，
  与退费本质不同在于
  1）同时冲正预存发生金额；
  2）应收冲正后进行应收追正，而退费视部分退费与否或追正后追销或不追；
  冲正流程为：实收冲正（当月负实收）-->应收冲正（追加当月全额负帐）-->应收追补（追加当月全额正帐）
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2) IS
    o_Append_Rlje NUMBER;
    --
    o_Rlid_Reverse        VARCHAR2(10);
    o_Rltrans_Reverse     VARCHAR2(10);
    o_Rlje_Reverse        NUMBER;
    o_Rlznj_Reverse       NUMBER;
    o_Rlsxf_Reverse       NUMBER;
    o_Rlsavingbq_Reverse  NUMBER;
    Io_Rlsavingqm_Reverse NUMBER;
  BEGIN
    --实收冲正（当月负实收）
    Payreversecorebypid(p_Pid_Source,
                        p_Position,
                        p_Paypoint,
                        p_Ptrans,
                        p_Bdate,
                        p_Bseqno,
                        p_Oper,
                        p_Payway,
                        p_Memo,
                        不提交,
                        'Y',
                        o_Pid_Reverse,
                        o_Ppayment_Reverse);
    FOR i IN (SELECT Arid, Arpaidje, Artrans
                FROM Ys_Zw_Arlist
               WHERE Arpid = p_Pid_Source
                 AND Arreverseflag = 'N'
               ORDER BY Arid) LOOP
      --应收冲正（追加当月全额负帐）
      Zwarreversecore(i.Arid, -- P_ARID_SOURCE         IN VARCHAR2,
                      i.Artrans, --P_ARTRANS_REVERSE     IN VARCHAR2,
                      NULL, --    P_PBATCH_REVERSE      IN VARCHAR2,
                      o_Pid_Reverse, --     P_PID_REVERSE         IN VARCHAR2,
                      -i.Arpaidje, --    P_PPAYMENT_REVERSE    IN NUMBER,
                      p_Memo, --    P_MEMO                IN VARCHAR2,
                      NULL, --    P_CTL_MIRCODE         IN VARCHAR2,
                      不提交, --    P_COMMIT              IN NUMBER DEFAULT 不提交,
                      o_Rlid_Reverse,
                      o_Rltrans_Reverse,
                      o_Rlje_Reverse,
                      o_Rlznj_Reverse,
                      o_Rlsxf_Reverse,
                      o_Rlsavingbq_Reverse,
                      Io_Rlsavingqm_Reverse); /* O_ARID_REVERSE        OUT VARCHAR2,
                                O_ARTRANS_REVERSE     OUT VARCHAR2,
                                O_ARJE_REVERSE        OUT NUMBER,
                                O_ARZNJ_REVERSE       OUT NUMBER,
                                O_ARSXF_REVERSE       OUT NUMBER,
                                O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                                IO_ARSAVINGQM_REVERSE IN OUT NUMBER
                                */
      --应收追补（追加当月全额正帐）
      Recappendinherit(i.Arid,
                       'ALL',
                       o_Rltrans_Reverse,
                       p_Memo,
                       不提交,
                       o_Append_Rlid,
                       o_Append_Rlje);
    END LOOP;
  
    --2、提交处理
    BEGIN
      IF p_Commit = 调试 THEN
        ROLLBACK;
      ELSE
        IF p_Commit = 提交 THEN
          COMMIT;
        ELSIF p_Commit = 不提交 THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '是否提交参数不正确');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreverse;
  
  /*==========================================================================
  水司柜台冲正(不退款)，不记独立实收事务
  【输入参数说明】：
  p_pid_source  in number：待冲正原实收流水号
  p_oper        in varchar2：冲正操作员
  p_memo        in varchar2：其他冲正备注信息
  
  【输出参数说明】：
  p_pid_reverse out number：冲正成功后返回的冲正记录（负实收记录）流水号
  
  【过程说明】：
  柜台缴费页面集成功能，当日或隔日均冲正到本期，计帐为原实收单位、原实收缴费点、原实收事务、原付款方式
  支持冲正预存充值交易
  其他【过程说明】见子过程PayReverse《实收冲正次核心》说明
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2) is
    p                  ys_zw_paidment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from ys_zw_paidment  where pid = p_pid_source;
    --校验
    if not (p.PREVERSEFLAG = 'N' and p.PAIDMENT >= 0) then
      raise_application_error(errcode,
                              '待冲正实收记录无效，必须为未冲正的正常缴费');
    end if;
    PayReverse(p_pid_source,
               p.MANAGE_NO,
               p.PDPAYPOINT,
               p.PDTRAN,
               null,
               null,
               p_oper,
               p.PDPAYWAY,
               p_memo,
               不提交,
               p_pid_reverse,
               vppaymentreverse,
               vappendrlid);
  
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, '是否提交参数不正确' || p_pid_source); 
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse;

-----
/*==========================================================================
  应收追调
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：可空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid out number：返回追补的应收记录流水号
  【过程说明】：
  基于应收调整业务中的调整目标账务（总账+明细）追加一条应收记录及关联应收明细
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAppendAdj(p_rlmid           in varchar2,
                         p_rlcname         in varchar2,
                         p_rlpfid          in varchar2,
                         p_rlrdate         in date,
                         p_rlscode         in number,
                         p_rlecode         in number,
                         p_rlsl            in number,
                         p_rlje            in number,
                         p_rlznj           in number,
                         p_rltrans         in varchar2,
                         p_rlmemo          in varchar2,
                         p_rlid_source     in varchar2,
                         p_parm_append1rds parm_append1rd_tab,
                         p_ctl_mircode     in varchar2,
                         p_commit          in number default 不提交,
                         o_rlid            out varchar2) is
    cursor c_rl(vrlid varchar2) is
      select * from ys_zw_arlist  where arid = vrlid for update nowait; --若被锁直接抛出异常
    rl_source ys_zw_arlist%rowtype;
  begin
    --退费正帐应收事务继承原帐务
    open c_rl(p_rlid_source);
    fetch c_rl
      into rl_source;
    if c_rl%notfound or c_rl%notfound is null then
      raise_application_error(errcode, '无原帐务应收记录');
    end if;
    close c_rl;
  
    RecAppendCore(p_rlmid,
                  p_rlcname,
                  p_rlpfid,
                  p_rlrdate,
                  p_rlscode,
                  p_rlecode,
                  p_rlsl,
                  p_rlje,
                  rl_source.arznjreducflag,
                  rl_source.arzndate,
                  p_rlznj,
                  p_rltrans,
                  p_rlmemo,
                  p_rlid_source,
                  p_parm_append1rds,
                  p_ctl_mircode,
                  不提交,
                  o_rlid);
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end RecAppendAdj;
/*==========================================================================
  应收调整
  【输入参数说明】：
  p_rlmid  varchar2(20)  ：非空，水表编号
  p_rlcname in varchar2 ：为空时reclist.rlcname取实时ci.ciname，非空时去传入值（营业外收费业务中指定票据名称）
  p_rlpfid  varchar2(10)  ：非空，价格类别编号
  p_rlrmonth  varchar2(7)  ：非空，抄表月份
  p_rlrdate  date  ：非空，抄表日期
  p_rlscode  number(10)  ：非空，上次抄表读数
  p_rlecode  number(10)  ：非空，本次抄表读数
  p_rlsl  number(10)  ：非空，应收水量
  p_rlje  number(13,2)  ：非空，应收金额
  p_rltrans in varchar2 ：非空，应收事务（类别），reclist.rllb
  p_rlmemo  varchar2(100)  ：可空，备注信息
  p_rlid_source in number ：非空，绑定原应收帐
  p_parm_append1rds parm_append1rd_tab ：非空，应收帐明细包
  p_ctl_mircode ：非空时以此值覆盖meterinfo.mircode(即重置下期起码)，为空时不进行此处理
  【输出参数说明】：
  o_rlid_reverse out varchar2：
  o_rlid out varchar2：返回追补的应收记录流水号
  【过程说明】：
  基于单据调整应收价量费
  调整流程为：应收冲正（追加当月全额负帐）-->应收追补
  【更新日志】：
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        制作
  --
  */
  procedure RecAdjust(p_rlmid           in varchar2,
                      p_rlcname         in varchar2,
                      p_rlpfid          in varchar2,
                      p_rlrdate         in date,
                      p_rlscode         in number,
                      p_rlecode         in number,
                      p_rlsl            in number,
                      p_rlje            in number,
                      p_rlznj           in number,
                      p_rltrans         in varchar2,
                      p_rlmemo          in varchar2,
                      p_rlid_source     in varchar2,
                      p_parm_append1rds parm_append1rd_tab,
                      p_commit          in number default 不提交,
                      p_ctl_mircode     in varchar2,
                      o_rlid_reverse    out varchar2,
                      o_rlid            out varchar2) is
    --
    o_rltrans_reverse     varchar2(10);
    o_rlje_reverse        number;
    o_rlznj_reverse       number;
    o_rlsxf_reverse       number;
    o_rlsavingbq_reverse  number;
    io_rlsavingqm_reverse number;
  begin
    Zwarreversecore(p_rlid_source,
                   p_rltrans,
                   null,
                   null, --应收调整无关联实收记录p_pid_reverse
                   null, --应收调整无关联实收记录
                   p_rlmemo,
                   null, --此过程不重置止码，让追补核心处理
                   p_commit,
                   o_rlid_reverse,
                   o_rltrans_reverse,
                   o_rlje_reverse,
                   o_rlznj_reverse,
                   o_rlsxf_reverse,
                   o_rlsavingbq_reverse,
                   io_rlsavingqm_reverse);
    if not (p_rlsl = 0 and p_rlje = 0 and p_rlznj = 0) then
      RecAppendAdj(p_rlmid,
                   p_rlcname,
                   p_rlpfid,
                   p_rlrdate,
                   p_rlscode,
                   p_rlecode,
                   p_rlsl,
                   p_rlje,
                   p_rlznj,
                   o_rltrans_reverse,
                   p_rlmemo,
                   p_rlid_source,
                   p_parm_append1rds,
                   p_ctl_mircode,
                   p_commit,
                   o_rlid);
    else
      --其他控制赋值
      if p_ctl_mircode is not null then
        update ys_yh_sbinfo
           set sbrcode     = to_number(p_ctl_mircode),
               sbrcodechar = p_ctl_mircode
         where sbid = p_rlmid;
      end if;
    
    end if;
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      /*pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'RecAdjust,p_rlmid:' || p_rlmid);*/
      --raise;
      raise_application_error(errcode, sqlerrm);
  end RecAdjust;


/* procedure PosReverse$(p_pid_source  in varchar2,
                        p_oper        in varchar2,
                        p_pposition   in varchar2,
                        p_ppaypoint   in varchar2,
                        p_ppayway     in varchar2,
                        p_memo        in varchar2,
                        p_commit      in number default 不提交,
                        p_pid_reverse out varchar2) is
    p                payment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from payment where pid = p_pid_source;
    --校验
    if not (p.preverseflag = 'N' and p.ppayment >= 0) then
      raise_application_error(errcode,
                              '待冲正实收记录无效，必须为未冲正的正常缴费');
    end if;
    PayReverse(p_pid_source,
               p_pposition,
               p_ppaypoint,
               'C',
               null,
               null,
               p_oper,
               p_ppayway,
               p_memo,
               不提交,
               p_pid_reverse,
               vppaymentreverse,
               vappendrlid);
  
    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'PosReverse,p_pid_source:' || p_pid_source);
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse$;
  */ /*******************************************************************************************
  函数名：F_PAYBACK_BY_PMID
  用途：实收冲正,按实收流水id冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************/
/*FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN YS_ZW_PAIDMENT.PID%TYPE,
                             P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                             P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                             P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                             P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                             P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE,
                             P_COMMIT   IN VARCHAR2) 
                              RETURN VARCHAR2 IS

    PM YS_ZW_PAIDMENT%ROWTYPE;
    MI  ys_yh_sbinfo%ROWTYPE;
    CQ CHEQUE%ROWTYPE;
    --函数变量在此说明F
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果
    V_RECID  YS_ZW_ARLIST.ARID%TYPE;

    ERR_SAVING EXCEPTION;

    V_CALL NUMBER;
    V_COUNT NUMBER:=0;
    R1 RECLIST_1METER_TMP%ROWTYPE;
    RL1 RECLIST%ROWTYPE;

    \*修正隔月冲正之后账务月份为当前月的BUG*\
     cursor c_sscz_list is
        select s.* from reclist_1meter_tmp s;

      v_sscz_list  reclist_1meter_tmp%rowtype;

  BEGIN
    --STEP 1:实收帐处理----------------------------------

    V_STEP    := 1;
    V_PRC_MSG := '实收帐处理';
    --检查是否有符合条件的待冲正记录
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PID = P_PAYID
       AND T.PREVERSEFLAG <> 'Y';

    --支票档处理,冲正时需写入一笔资负帐入支票档cheque
    --如果不写入后续财务结账不一致。金额对不上
      -- modify 201406708 hb
      --20160503 增加  PS  原因同上
      IF PM.PPAYWAY in ('ZP','MZ','DC','PS') THEN
          SELECT COUNT(CHEQUEID) INTO V_COUNT FROM CHEQUE   WHERE CHEQUEID=PM.PBATCH;
          IF V_COUNT> 0 THEN  --存在时才写入资料，基建补缴相关资料未写入
              select * into CQ from  CHEQUE   WHERE CHEQUEID=PM.PBATCH;
               CQ.CHEQUEID :=P_BATCH;
               cq.enteringtime :=sysdate;
               --cq.chequemoney:=0 - cq.chequemoney;
               cq.chequemoney:= 0 - PM.PPAYMENT;
               CQ.CHEQUECWNO :='';
               CQ.CHEQUEYXNO :='';
            --   if  cq.chequemoney > 0 then --ADD 20140905
               --   CQ.chequecrflag:='Y';
            --   else
                  CQ.chequecrflag:='Y';
                  CQ.CHEQUEMEMO:='实收冲正写入'; --ADD 20140905
             --  end if ;
               CQ.chequecrdate:=SYSDATE;
               CQ.chequecroper:=P_OPER;
               DELETE FROM cheque  WHERE CHEQUEID=CQ.CHEQUEID ;
               insert into cheque values CQ;
           END IF ;
       end if ;
     --end 支票处理

    --取水表信息
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = PM.PMID;

    \*--检查当前预存是否够冲正回退,不够则退出 [yujia 2012-02-08]
    IF PM.PSAVINGBQ>MI.MISAVING THEN
       RAISE ERR_SAVING;
    END IF;*\

    --准备实收冲正负记录的数据
    PM.PPOSITION    := P_POSITION; --参数
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  如果实收冲正冲预存抵扣，则用户回写system，以免扎帐出问题
      --因用户5038003584银行单边帐多300元，系统有做预存抵扣，只能用户进行冲销，冲销之后系统记录的是用户账号，到时候收费员结账有问题
          PM.PPER         := 'SYSTEM'; --参数
    else
          PM.PPER         := P_OPER; --参数
    end if ;
    PM.PSAVINGQC    := MI.MISAVING; --取当前
    PM.PSAVINGBQ    := 0 - PM.PSAVINGBQ; --取负
    PM.PSAVINGQM    := MI.MISAVING + PM.PSAVINGBQ; --计算
    PM.PPAYMENT     := 0 - PM.PPAYMENT; --取负
    PM.PBATCH       := P_BATCH; --参数
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  如果实收冲正冲预存抵扣，则用户回写system，以免扎帐出问题
      --因用户5038003584银行单边帐多300元，系统有做预存抵扣，只能用户进行冲销，冲销之后系统记录的是用户账号，到时候收费员结账有问题
           PM.PPAYEE        := 'SYSTEM'; --参数
    else
             PM.PPAYEE       := P_OPER; --参数
    end if ;

    pm.pchkdate     :=sysdate ; --这里需要将扎帐日期记录为当前的系统操作日期 by 20150203 ralph
    PM.PPAYPOINT    := P_PAYPOINT; --参数
    PM.PSXF         := 0 - PM.PSXF; --取负
    PM.PILID        := ''; --无
    PM.PZNJ         := 0 - PM.PZNJ; --取负
    PM.PRCRECEIVED  := 0 - PM.PRCRECEIVED; --取负
    PM.PSPJE        := 0 - PM.PSPJE; --取负
    PM.PREVERSEFLAG := 'Y'; --Y
    PM.PSCRID       := PM.PID; --原记录.PID
    PM.PSCRTRANS    := PM.PTRANS; --原记录.PTRANS
    PM.PSCRMONTH    := PM.PMONTH; --原记录.PMONTH
    PM.PSCRDATE     := PM.PDATE; --原记录.PDATE
    ----以下几个变量赋值一定要放在最后，和次序有关
    PM.PID   := FGETSEQUENCE('PAYMENT'); --新生成
    PM.PDATE := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    ----以下几个变量赋值一定要放在最后，和次序有关
    PM.PID       := FGETSEQUENCE('PAYMENT'); --新生成
    PM.PDATE     := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    PM.PDATETIME := SYSDATE; --SYSDATE
    PM.PMONTH    := TOOLS.FGETRECMONTH(MI.MISMFID); --当前月份
    PM.PCHKNO := null ;-- 20140806营销单号写入为空，以免造成对账误解
    pm.TCHKDATE :=null;-- 20140806营销单号写入为空，以免造成对账误解
    pm.pdzdate :=null;-- 20140806营销单号写入为空，以免造成对账误解
   -- PM.PTRANS    := P_TRANS; --参数  modify 20140625 hb 取消,因冲正时，应收事务与原应收事务应该相等，不需根据外部传入参数更新参数
    -----------------------------------------------------------------
    --插入冲正实收负记录
    INSERT INTO PAYMENT T VALUES PM;
    --原被冲正记录打上冲正标志
    UPDATE PAYMENT T SET T.PREVERSEFLAG = 'Y' WHERE T.PID = P_PAYID;
    --END OF STEP 1: 处理结果：---------------------------------------------------
    --PAYMENT 增加了了一条负记录
    -- 被冲正记录的冲正标志为Y
    ----------------------------------------------------------------------------------------
 
    --应收账处理--------------------------------------------------------------
    -----STEP 10: 增加负应收记录
    ------在临时表中存放需要冲正处理的应收总账和明细帐记录
    ---先清空临时表
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---保存需要冲正处理的应收总账记录
    V_STEP    := 10;
    V_PRC_MSG := '保存需要冲正处理的应收总账记录';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';
  

    ---保存需要冲正处理的应收明细帐记录
    V_STEP    := 11;
    V_PRC_MSG := '保存需要冲正处理的应收明细帐记录';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    V_PRC_MSG := '在应收总账临时表中做负记录的调整';
    \* UPDATE RECLIST_1METER_TMP T
    SET T.RLID    = FGETSEQUENCE('RECLIST'),
        T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --当前              帐务月份
        T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --当前              帐务日期
       \* T.RLMONTH = PM.PMONTH, --当前              帐务月份
        T.RLDATE  = PM.PDATE, --当前              帐务日期*\
        T.RLREADSL     = 0 - T.RLREADSL ,--抄见水量
        t.rlentrustbatch = null,--托收代扣批号
        t.rlentrustseqno = null,-- 托收代扣流水号
        -- T.RLCHARGEPER   = PM.PPER, --同实收            收费员
        T.RLSL          = 0 - T.RLSL, --取负              应收水量
        T.RLJE          = 0 - T.RLJE, --取负              应收金额
        T.RLADDSL       = 0 - T.RLADDSL, --取负              加调水量

        T.rlcolumn9     = T.RLID, --原记录.RLID       原应收帐流水
        T.rlcolumn11  = T.RLTRANS, --原记录.RLTRANS    原应收帐事务
        T.rlcolumn10  = T.RLMONTH, --原记录.RLMONTH    原应收帐月份
        T.RLCOLUMN5   = T.RLDATE, --原记录.RLDATE     原帐务日期

        \*T.RLSCRRLID     = T.RLID, --原记录.RLID       原应收帐流水
        T.RLSCRRLTRANS  = T.RLTRANS, --原记录.RLTRANS    原应收帐事务
        T.RLSCRRLMONTH  = T.RLMONTH, --原记录.RLMONTH    原应收帐月份*\
        T.RLPAIDJE      = 0 - T.RLPAIDJE, --取负              销帐金额
        --T.RLPAIDFLAG    = 'Y', --Y                 销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
        T.RLPAIDPER     = PM.PPER, --同实收            销帐人员
        T.RLPAIDDATE    = PM.PDATE, --同实收            销帐日期
        T.RLZNJ         = 0 - T.RLZNJ, --取负              违约金
        T.RLDATETIME    = SYSDATE, --SYSDATE           发生日期

       \* T.RLSCRRLDATE   = T.RLDATE, --原记录.RLDATE     原帐务日期*\
        T.RLPID         = PM.PID, --对应的负实收流水  实收流水（与YS_ZW_PAIDMENT.pid对应）
        T.RLPBATCH      = PM.PBATCH, --对应的负实收流水  缴费交易批次（与YS_ZW_PAIDMENT.PBATCH对应）
        T.RLSAVINGQC    = T.RLSAVINGQM + nvl(mi.misaving,0) , --计算              期初预存（销帐时产生）
        T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --计算              本期预存发生（销帐时产生）
        T.RLSAVINGQM    = T.RLSAVINGQC + nvl(mi.misaving,0), --计算              期末预存（销帐时产生）
        T.RLREVERSEFLAG = 'Y', --Y                   冲正标志（N为正常，Y为冲正）
        t.rlilid        =null ,--发票流水号
        t.rlmisaving    = 0,--算费时预存
        t.rlpriorje     = 0,--算费之前欠费
        T.RLSXF         = 0 - T.RLSXF;*\

    --冲正时应收帐负数据
    V_CALL := F_SET_CR_RECLIST(PM);

    --将应收冲正负记录插入到应收总账中
    V_STEP    := 13;
    V_PRC_MSG := '将应收冲正负记录插入到应收总账中';

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---在应收明细临时表中做负记录的调整
    V_STEP    := 14;
    V_PRC_MSG := '在应收明细临时表中做负记录的调整';

    --一般字段调整
    UPDATE RECDETAIL_TMP T
       SET T.RDYSSL  = 0 - T.RDYSSL,
           T.RDYSJE  = 0 - T.RDYSJE,
           T.RDSL    = 0 - T.RDSL,
           T.RDJE    = 0 - T.RDJE,
           T.RDADJSL = 0 - T.RDADJSL,
           T.RDADJJE = 0 - T.RDADJJE,
           T.RDZNJ   = 0 - T.RDZNJ;
    --流水id调整
    UPDATE RECDETAIL_TMP T
       SET T.RDID =
           (SELECT S.RLID
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --插入到应收明细表

    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);
 

    -----END OF  STEP 10: 增加负应收记录处理完成---------------------------------------

    -----STEP 20: 增加正应收记录--------------------------------------------------------------
    ------在临时表中存放需要冲正处理的应收总账和明细帐记录
    ---先清空临时表
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---保存需要冲正处理的应收总账记录
    V_STEP    := 20;
    V_PRC_MSG := '保存需要冲正处理的应收总账记录';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---保存需要冲正处理的应收明细帐记录
    V_STEP    := 21;
    V_PRC_MSG := '保存需要冲正处理的应收明细帐记录';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---在应收总账临时表中做正记录的调整
    V_STEP    := 22;
    V_PRC_MSG := '在应收总账临时表中做正记录的调整';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID    = FGETSEQUENCE('RECLIST'), --新生成
           T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --当前              帐务月份
           T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --当前              帐务日期
           \*           T.RLMONTH       = PM.PMONTH, --当前
           T.RLDATE        = PM.PDATE, --当前*\
           --T.RLCHARGEPER   = '', --无

           T.RLCOLUMN5  = T.RLDATE, --上次应帐帐日期
           T.RLCOLUMN9  = T.RLID, --上次应收帐流水
           T.RLCOLUMN10 = T.RLMONTH, --上次应收帐月份
           T.RLCOLUMN11 = T.RLTRANS, --上次应收帐事务

           \*           T.RLSCRRLID     = T.RLID, --原记录.RLID
           T.RLSCRRLTRANS  = T.RLTRANS, --原记录.RLTRANS
           T.RLSCRRLMONTH  = T.RLMONTH, --原记录.RLMONTH*\
           T.RLPAIDFLAG = 'N', --N
           T.RLPAIDPER  = '', --无
           T.RLPAIDDATE = '', --无
           T.RLDATETIME = SYSDATE, --SYSDATE
           \*           T.RLSCRRLDATE   = T.RLDATE, --原记录.RLDATE*\
           T.RLPID         = NULL, --无
           T.RLPBATCH      = NULL, --无
           T.RLSAVINGQC    = 0, --无
           T.RLSAVINGBQ    = 0, --无
           T.RLSAVINGQM    = 0, --无
           T.RLREVERSEFLAG = 'N',
           T.RLPAIDJE      = 0,
           T.RLSXF         = 0, --手续费
           T.RLZNJ         = 0, --违约金
           T.RLOUTFLAG     = 'N'; --N

    --将应收冲正正记录插入到应收总账中
    V_STEP    := 23;
    V_PRC_MSG := '将应收冲正正记录插入到应收总账中';

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S); 

    --诸暨减量退费
    INSERT INTO RECLISTTEMPCZ
      (SELECT S.RLID, RLCOLUMN9 FROM RECLIST_1METER_TMP S);

    ---在应收明细临时表中做正记录的调整
    V_STEP    := 14;
    V_PRC_MSG := '在应收明细临时表中做正记录的调整';

    UPDATE RECDETAIL_TMP T
       SET (T.RDID,
            T.RDPAIDFLAG,
            T.RDPAIDDATE,
            T.RDPAIDMONTH,
            T.RDPAIDPER,
            T.RDMONTH,
            T.RDZNJ) =
           (SELECT S.RLID, 'N', NULL, NULL, NULL, S.RLMONTH, 0
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --插入到应收明细表
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);
    --add 2013.02.01 向reclist_charge_01表中插入正应收记录
    \*   for  i in (SELECT S.RDID FROM RECDETAIL_TMP S)
     LOOP
      sp_reclist_charge_01(i.RDID ,'1');
    END LOOP;*\
    --add 2013.02.01
    ----END OF STEP 20: 增加正应收记录  处理完成 ------------------------------------------
    ----STEP 30 原应收记录打冲正标记
    V_STEP    := 30;
    V_PRC_MSG := '原应收记录打冲正标记';
    UPDATE RECLIST T
       SET T.RLREVERSEFLAG = 'Y'

     WHERE T.RLPID = P_PAYID
       AND T.RLPAIDFLAG = 'Y';
    --END OF  应收账处理完成--------------------------------------------------------------

    --STEP 40 水表资料预存余额调整--------------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := '水表资料预存余额调整';
    UPDATE METERINFO T
       SET T.MISAVING = PM.PSAVINGQM, T.MIPAYMENTID = P_PAYID
     WHERE T.MIID = PM.PMID;
    -- END OF STEP 40 水表资料预存余额调整------------------------------------------------------------

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END;
*/
BEGIN
  NULL;

END;
/

prompt
prompt Creating package body PG_SBTRANS
prompt ================================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_SBTRANS" IS

  最低算费水量 NUMBER(10);
  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                  P_BILLNO    IN VARCHAR2,
                  P_PERSON    IN VARCHAR2,
                  P_BILLID    IN VARCHAR2,
                  P_DJLB      IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
  
    SP_SBTRANS(p_HIRE_CODE, P_DJLB, P_BILLNO, P_PERSON, 'N');
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END AUDIT;

  --工单主程序
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                       P_TYPE      IN VARCHAR2, --操作类型
                       P_BILL_ID   IN VARCHAR2, --批次流水
                       P_PER       IN VARCHAR2, --操作员
                       P_COMMIT    IN VARCHAR2 --提交标志
                       ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
  BEGIN
    BEGIN
      SELECT *
        INTO MH
        FROM ys_gd_metertranshd
       WHERE BILL_ID = P_BILL_ID
         and HIRE_CODE = p_HIRE_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
  
    --byj update 2016.10.21
    IF mh.check_flag = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;
  
    for md in (SELECT *
                 FROM ys_gd_metertransdt
                WHERE BILL_ID = P_BILL_ID
                  and HIRE_CODE = p_HIRE_CODE) loop
      SP_SBTRANSONE(P_TYPE, P_PER, MD);
    
    end loop;
  
    UPDATE ys_gd_metertransdt
       SET CHECK_FLAG = 'Y'
     WHERE BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    UPDATE ys_gd_metertranshd
       SET check_flag = 'Y', CHECK_DATE = SYSDATE, CHECK_PER = P_PER
     where BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --工单单个审核过程
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --类型
                          P_PERSON IN VARCHAR2, -- 操作员
                          P_MD     IN ys_gd_metertransdt%ROWTYPE --单体行变更
                          ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
    MI ys_yh_sbinfo%ROWTYPE;
    CI ys_yh_custinfo%ROWTYPE;
    MC ys_yh_sbdoc%ROWTYPE;
    MA ys_gd_sbaddsl%ROWTYPE;
    --v_mrmemo       meterread.mrmemo%type;
    V_COUNT     NUMBER(4);
    V_COUNTMRID NUMBER(4);
    V_COUNTFLAG NUMBER(4);
    V_NUMBER    NUMBER(10);
    v_rcode     NUMBER(10);
    V_CRHNO     VARCHAR2(10);
    V_OMRID     VARCHAR2(20);
    O_STR       VARCHAR2(20);
  
    --未算费抄表记录
    cursor cur_nocalc(p_sbid varchar2, p_mrmonth varchar2) is
      select *
        from ys_cb_mtread mr
       where mr.sbid = p_sbid
         and mr.CBMRMONTH = p_mrmonth;
  
  BEGIN
    BEGIN
      SELECT *
        INTO MH
        FROM ys_gd_metertranshd
       WHERE BILL_ID = P_MD.BILL_ID
         and HIRE_CODE = P_MD.HIRE_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
    BEGIN
      SELECT *
        INTO MI
        FROM ys_yh_sbinfo
       WHERE sbid = P_MD.SBID
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT *
        INTO CI
        FROM ys_yh_custinfo
       WHERE yhid = MI.Yhid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT *
        INTO MC
        FROM ys_yh_sbdoc
       WHERE sbid = P_MD.Sbid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;
  
    IF MI.sbRCODE != MD.SCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '上期抄见发生变化，请重置上期抄见');
    END IF;
  
    --F销户拆表
    IF P_TYPE = 'XHCB' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      update ys_yh_sbinfo
         set sbSTATUS      = m销户,
             sbSTATUSDATE  = sysdate,
             sbSTATUSTRANS = P_TYPE,
             sbUNINSDATE   = sysdate,
             BOOK_NO       = NULL -- by 20170904 wlj 销户拆表将表册置空
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --销户后同步用户状态
      UPDATE ys_yh_custinfo
         SET yhSTATUS      = m销户,
             yhstatusdate  = sysdate,
             yhstatustrans = P_TYPE
       WHERE yhid = mi.yhid
         and Hire_Code = p_md.hire_code;
    
      --METERDOC  表状态 表状态发生时间
      update ys_yh_sbdoc
         set MDSTATUS = m销户, MDSTATUSDATE = sysdate
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --记余量表 METERADDSL
    
      -- MD.MASID           :=     ;--记录流水号
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT口径变更
    ELSIF P_TYPE = 'KJBG' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M立户,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE,
             SBREINSCODE   = P_MD.NEW_CODE, --换表起度
             SBREINSDATE   = P_MD.TRANS_TIME, --换表日期
             SBREINSPER    = P_MD.TRANS_PER, --换表人
             SBTYPE        = P_MD.METER_TYPE, --表型
             BOOK_NO       = NULL
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
    
      update ys_yh_sbdoc
         set MDSTATUS     = M立户,
             MDCALIBER    = P_MD.CALIBER,
             MDNO         = P_MD.MODEL, ---表型号
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费？？？
      --BT换阀门
    ELSIF P_TYPE = 'HFM' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --记余量表 METERADDSL
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费
      --
      --BT欠费停水
    ELSIF P_TYPE = 'QFTS' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M欠费停水,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT恢复供水
    ELSIF P_TYPE = 'HFGS' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M立户,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE YS_YH_SBDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      /*  --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;*/
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT报停
    ELSIF P_TYPE = 'BT' THEN
    
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M报停,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT校表
    ELSIF P_TYPE = 'XB' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE,
             sbREINSDATE   = P_MD.TRANS_TIME
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M立户,
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.TRANS_TIME
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT复装
    ELSIF P_TYPE = 'FZ' THEN
      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户, --状态
             sbSTATUSDATE  = SYSDATE, --状态日期
             sbSTATUSTRANS = P_TYPE, --状态表务 
             sbREINSCODE   = P_MD.NEW_CODE, --换表起度
             sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
             sbREINSPER    = P_MD.TRANS_PER --换表人
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.WATER_CODE, --表身号
             MDCALIBER    = P_MD.CALIBER, --表口径
             MDBRAND      = P_MD.BRAND, --表厂家
             MDMODEL      = P_MD.MODEL, --表型号
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --METERTRANSDT 回滚换表日期 回滚水表状态
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费
    
     --换表
    ELSIF P_TYPE = 'HB' THEN
       --BT故障换表
      IF P_MD.TRANS_TYPE = '02' THEN
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM YS_CB_MTREAD
         WHERE sbid = P_MD.Sbid
           and cbmrreadok = 'Y' --已抄表
           AND cbMRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '【' || P_MD.Sbid ||
                                  '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        end if;
      
        update YS_CB_MTREAD t
           set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  增加的将未抄见指针更换掉
         where SBID = P_MD.SBID
           AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
                   t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
        ;
      
        UPDATE ys_yh_sbinfo
           SET sbSTATUS      = M立户, --状态
               sbSTATUSDATE  = SYSDATE, --状态日期
               sbSTATUSTRANS = P_TYPE, --状态表务 
               sbREINSCODE   = P_MD.NEW_CODE, --换表起度
               sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
               sbREINSPER    = P_MD.TRANS_PER, --换表人
               
               sbRCODE = P_MD.NEW_CODE, --换表起度
               SBTYPE        = P_MD.METER_TYPE,
               SBDZBZ1 = 'N', --换表后将 等针标志清除(如果有)  
               sbRTID  = p_md.sbRTID --换表后 根据工单更新 抄表方式!  
         where sbid = P_MD.sbid
           and Hire_Code = p_md.hire_code;
      
        UPDATE ys_yh_sbdoc
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --状态发生时间
               MDNO         = P_MD.WATER_CODE, --表身号
               MDCALIBER    = P_MD.CALIBER, --表口径
               MDBRAND      = P_MD.BRAND, --表厂家
               MDMODEL      = P_MD.MODEL, --表型号
               MDCYCCHKDATE = P_MD.MTDYCCHKDATE
         where sbid = P_MD.sbid
           and Hire_Code = p_md.hire_code;
      
        MA.id           := uuid();
        MA.hire_code    := p_md.hire_code;
        MA.yhid         := mi.yhid;
        MA.sbid         := mi.sbid;
        MA.addscodeo    := p_md.SCODE;
        MA.addecoden    := p_md.ecode;
        MA.adduninsdate := p_md.REMOVE_TIME;
        MA.adduninsper  := p_md.REMOVE_PER;
        MA.addsl        := p_md.ADD_WATER;
        MA.addtrans     := 'L';
        MA.bill_id      := P_MD.BILL_ID;
        MA.addscoden    := P_MD.NEW_CODE;
        MA.addinsdate   := P_MD.TRANS_TIME;
        MA.addcredate   := SYSDATE;
        MA.ADDCREPER    := 'SYS';
        /*MA.ifrecmk,*/
        /*MA.addmrid*/
      
        INSERT INTO YS_GD_SBADDSL VALUES MA;
      
      ELSIF P_MD.TRANS_TYPE = '01' THEN
      
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM YS_CB_MTREAD
         WHERE sbid = P_MD.Sbid
           and cbmrreadok = 'Y' --已抄表
           AND cbMRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '【' || P_MD.Sbid ||
                                  '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        end if;
      
        update YS_CB_MTREAD t
           set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  增加的将未抄见指针更换掉
         where SBID = P_MD.SBID
           AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
                   t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
        ;
      
        UPDATE ys_yh_sbinfo
           SET sbSTATUS      = M立户, --状态
               sbSTATUSDATE  = SYSDATE, --状态日期
               sbSTATUSTRANS = P_TYPE, --状态表务 
               sbREINSCODE   = P_MD.NEW_CODE, --换表起度
               sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
               sbREINSPER    = P_MD.TRANS_PER, --换表人
               SBTYPE        = P_MD.METER_TYPE,
               sbRCODE = P_MD.NEW_CODE, --换表起度
               
               SBDZBZ1 = 'N', --换表后将 等针标志清除(如果有) byj 2016.08
               sbRTID  = p_md.sbRTID --换表后 根据工单更新 抄表方式! byj 2016.12
         where sbid = P_MD.sbid
           and Hire_Code = p_md.hire_code;
      
        UPDATE ys_yh_sbdoc
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --状态发生时间
               MDNO         = P_MD.WATER_CODE, --表身号
               MDCALIBER    = P_MD.CALIBER, --表口径
               MDBRAND      = P_MD.BRAND, --表厂家
               MDMODEL      = P_MD.MODEL, --表型号
               MDCYCCHKDATE = P_MD.MTDYCCHKDATE
         where sbid = P_MD.sbid
           and Hire_Code = p_md.hire_code;
      
        MA.id           := uuid();
        MA.hire_code    := p_md.hire_code;
        MA.yhid         := mi.yhid;
        MA.sbid         := mi.sbid;
        MA.addscodeo    := p_md.SCODE;
        MA.addecoden    := p_md.ecode;
        MA.adduninsdate := p_md.REMOVE_TIME;
        MA.adduninsper  := p_md.REMOVE_PER;
        MA.addsl        := p_md.ADD_WATER;
        MA.addtrans     := 'L';
        MA.bill_id      := P_MD.BILL_ID;
        MA.addscoden    := P_MD.NEW_CODE;
        MA.addinsdate   := P_MD.TRANS_TIME;
        MA.addcredate   := SYSDATE;
        MA.ADDCREPER    := 'SYS';
        /*MA.ifrecmk,*/
        /*MA.addmrid*/
      
        INSERT INTO YS_GD_SBADDSL VALUES MA;
      END IF;
      --算费
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

BEGIN
  null;
END;
/

prompt
prompt Creating type body CONNSTRIMPL
prompt ==============================
prompt
CREATE OR REPLACE TYPE BODY CONNSTRIMPL is
      static function ODCIAggregateInitialize(sctx IN OUT connstrImpl)
      return number is
      begin
        sctx := connstrImpl('','/');
        return ODCIConst.Success;
      end;
      member function ODCIAggregateIterate(self IN OUT connstrImpl, value IN VARCHAR2) return number is
      begin
        if self.currentstr is null then
          self.currentstr := value;
        else
          self.currentstr := self.currentstr ||currentseprator || value;
        end if;
        return ODCIConst.Success;
      end;
      member function ODCIAggregateTerminate(self IN connstrImpl, returnValue OUT VARCHAR2, flags IN number) return number is
      begin
        returnValue := self.currentstr;
        return ODCIConst.Success;
      end;
      member function ODCIAggregateMerge(self IN OUT connstrImpl, ctx2 IN connstrImpl) return number is
      begin
        if ctx2.currentstr is null then
          self.currentstr := self.currentstr;
        elsif self.currentstr is null then
          self.currentstr := ctx2.currentstr;
        else
          self.currentstr := self.currentstr || currentseprator || ctx2.currentstr;
        end if;
        return ODCIConst.Success;
      end;
      end;
/

prompt
prompt Creating trigger TIDB_YS_GD_ZWDHZDT
prompt ===================================
prompt
CREATE OR REPLACE TRIGGER TIDB_YS_GD_ZWDHZDT
  BEFORE INSERT OR DELETE ON YS_GD_ZWDHZDT
  FOR EACH ROW
DECLARE
  -- LOCAL VARIABLES HERE
  V_BILL_TYPE YS_GD_ZWDHZD.BILL_TYPE%TYPE;
  CURSOR S1(V_BILL_ID YS_GD_ZWDHZD.BILL_ID%TYPE) IS
  SELECT A.BILL_TYPE
  FROM  YS_GD_ZWDHZD A
  WHERE A.BILL_ID = V_BILL_ID;

BEGIN
    IF INSERTING THEN  --新增
       OPEN S1(:NEW.BILL_ID) ;
       FETCH S1 INTO V_BILL_TYPE ;
       IF S1%NOTFOUND THEN
          V_BILL_TYPE:='';
       END IF ;
       CLOSE S1;
       IF TRIM(V_BILL_TYPE)= '8' OR TRIM(V_BILL_TYPE)='38'  THEN  --呆坏账
           UPDATE  YS_ZW_ARLIST  AR
           SET AR.ARBADFLAG ='0'
           WHERE AR.ARID =:NEW.ARID;
        END IF ;
    ELSE  --删除

       OPEN S1(:OLD.BILL_ID) ;
       FETCH S1 INTO V_BILL_TYPE ;
       IF S1%NOTFOUND THEN
          V_BILL_TYPE:='';
       END IF ;
       CLOSE S1;

      IF TRIM(V_BILL_TYPE)= '8'  THEN  --呆坏账
         UPDATE YS_ZW_ARLIST   AR
         SET AR.ARBADFLAG ='N'
         WHERE AR.ARID =:OLD.ARID;
       ELSIF  TRIM(V_BILL_TYPE)='38' THEN
             UPDATE YS_ZW_ARLIST  AR
           SET AR.ARBADFLAG ='N'
           WHERE AR.ARID =:OLD.ARID;
      END IF ;
    END IF ;
END TIDB_YS_GD_ZWDHZDT;
/


prompt Done
spool off
set define on

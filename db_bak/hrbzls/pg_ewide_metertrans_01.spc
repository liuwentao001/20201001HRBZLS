CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_METERTRANS_01" is

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  errcode constant integer := -20012;

--0 用户状态
   c正常   constant varchar2(1) := '0';  --正常
   c销户   constant varchar2(1) := '1';  --正常
   c预立户   constant varchar2(1) := '2';  --正常

  /*水表状态:总仓、分公司公用属性*/
  --1、库存水表状态
  m待立户     constant varchar2(2) := '2';  --【分公司】水表出库后没有安装
  m暂拆       constant varchar2(2) := '3';  --【分公司】欠费拆表后，则处于暂拆
  m新购       constant varchar2(2) := '4';  --【总仓】、【分公司】新购买的水表
  m报废       constant varchar2(2) := '5';  --【分公司】报废处理后，为报废
  m待检       constant varchar2(2) := '6';  --【分公司】水表送检后处于待检状态
  m故障       constant varchar2(2) := '8';  --【分公司】故障拆表后如果没有送检，水表状态为故障
  m周检到期   constant varchar2(2) := '9';  --【分公司】周检拆表后如果没有送检，水表状态为周检到期
  m可用老表   constant varchar2(2) := '10'; --【总仓】、【分公司】经检修后的老表，如果没有报废，入库后状态就为可用老表
  m换表       constant varchar2(2) := '11'; --【分公司】换表拆表后如果没有送检，水表状态为换表
  m违章       constant varchar2(2) := '12'; --【分公司】违章拆表后，水表状态为违章
  m报停       constant varchar2(2) := '13'; --【分公司】报停拆表后，则处于报停
  m暂停       constant varchar2(2) := '14'; --【分公司】暂停拆表后，则处于暂停
  m遗失       constant varchar2(2) := '15'; --【分公司】遗失处理后，为遗失
  m总仓出库   constant varchar2(2) := '17'; --【总仓】总仓配表到分公司后，总仓水表为总仓出库
  m拆迁       constant varchar2(2) := '16'; --【分公司】拆迁拆表后如果没有送检，为拆迁

  --2、在装水表状态
  m立户       constant varchar2(2) := '1';  --【分公司】用户正在使用
  m销户       constant varchar2(2) := '7';  --【分公司】销户拆表后如果没有送检，则处于销户
  m销户中     constant varchar2(2) := '19'; --【分公司】销户拆表派工后后完工前
  m口径变更中 constant varchar2(2) := '20'; --【分公司】口径变更派工后完工前
  m欠费停水中 constant varchar2(2) := '21'; --【分公司】欠费停水派工后完工前
  m复装中     constant varchar2(2) := '22'; --【分公司】复装派工后完工前
  m校表中     constant varchar2(2) := '23'; --【分公司】校表派工后完工前
  m故障换表中 constant varchar2(2) := '24'; --【分公司】故障换表派工后完工前
  m周检换表中 constant varchar2(2) := '25'; --【分公司】周检换表派工后完工前
  m复查中     constant varchar2(2) := '26'; --【分公司】复查派工后完工前
  m升移中     constant varchar2(2) := '27'; --【分公司】水表升移改造派工后完工前

  --应收事务
  计划抄表   constant char(1) :='1';
  消防表底度   constant char(1) :='5';

  营业外收入 constant char(1) :='T';
  追量       constant char(1) :='O';
  减欠       constant char(1) :='V';
  无表户       constant char(2) :='29';
  故障表       constant char(2) :='30';

  --单据类别,表务类别
  bt立户单         constant char(1) :='R';

  bt基础资料变更   constant char(1) :='B';
  bt银行信息变更   constant char(1) :='C';
  bt过户           constant char(1) :='D';
  bt水价变更       constant char(1) :='E';
  --
  bt水表升移       constant char(1) :='3';
  bt改装总表       constant char(1) :='A';--报装类
  bt销户拆表       constant char(1) :='F';
  bt口径变更       constant char(1) :='G';
  bt欠费停水       constant char(1) :='H';
  bt复装           constant char(1) :='I';
  bt校表           constant char(1) :='J';
  bt故障换表       constant char(1) :='K';
  bt周期换表       constant char(1) :='L';
  bt复查工单       constant char(1) :='M';
  bt安装分类计量表 constant char(1) :='P';--报装类
  bt补装户表       constant char(1) :='Q';--报装类
  bt报停           constant char(1) :='6';--报装类
  bt开水           constant char(1) :='9';--报装类

  --工单审核状态
  未派    constant char(1) :='N';
  已派工  constant char(1) :='W';
  待解决  constant char(1) :='D';
  已解决  constant char(1) :='Z';
  完工    constant char(1) :='Y';
  退单    constant char(1) :='Q';



   --模拟客户端转单功能
procedure sp_billnew_test ;
  --生成单据过程（基于billnewhdNOCOMMIT插入的触发器）
procedure sp_billbuild_test;
--抄表计划批量生成故障换表工单
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_type in varchar2,
                            p_source in varchar2,
                            p_smfid in varchar2,
                            p_dept in varchar2,
                            p_oper in varchar2,
                            p_flag in varchar2,
                            o_billno out varchar2);
  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) ;
   --单个单体总体审核
  PROCEDURE SP_METERTRANS_BY(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_mtdrowno IN VARCHAR2,--行号
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         )  ;
  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- 操作员
                             P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                             p_commit in varchar2 --提交标志
                             ) ;
--插入抄表计划
procedure sp_insertmr(
                      p_pper in varchar2,--操作员
                      p_month  in varchar2,--应收月份
                      p_mrtrans in varchar2,--抄表事务
                      p_rlsl   in number,--应收水量
                      p_scode  in number,--起码
                      p_ecode  in number,--止码
                      mi in meterinfo%rowtype,  --水表信息
                      omrid out meterread.mrid%type --抄表流水
                      ) ;
end ;
/


prompt PL/SQL Developer Export User Objects for user SF_USER@221.212.191.142:32771/ORCL
prompt Created by xss on 2021年2月24日星期三
set define off
spool ruoyi.log

prompt
prompt Creating sequence ACT_EVT_LOG_SEQ
prompt =================================
prompt
create sequence ACT_EVT_LOG_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
cache 20;

prompt
prompt Creating sequence SEQIMUSERID
prompt =============================
prompt
create sequence SEQIMUSERID
minvalue 1
maxvalue 99999999
start with 178
increment by 1
nocache;

prompt
prompt Creating sequence SEQMESTERDOCID
prompt ================================
prompt
create sequence SEQMESTERDOCID
minvalue 1
maxvalue 9999999999999999999999999999
start with 2917271
increment by 1
cache 10;

prompt
prompt Creating sequence SEQPRICEID
prompt ============================
prompt
create sequence SEQPRICEID
minvalue 1
maxvalue 9999999999999999999999999999
start with 261
increment by 1
cache 20;

prompt
prompt Creating sequence SEQUSERNO
prompt ===========================
prompt
create sequence SEQUSERNO
minvalue 1
maxvalue 9999999999999999999999999999
start with 2200000600
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_BS_IMPORTUSERS
prompt ====================================
prompt
create sequence SEQ_BS_IMPORTUSERS
minvalue 1
maxvalue 9999999999999999999999999999
start with 30
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_BS_METERFH_STORE
prompt ======================================
prompt
create sequence SEQ_BS_METERFH_STORE
minvalue 1
maxvalue 9999999999999999999999999999
start with 130
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_DZGD
prompt ==========================
prompt
create sequence SEQ_DZGD
minvalue 1000000000
maxvalue 9999999999999999999999999999
start with 1000000000
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_EVENT_BK
prompt ==============================
prompt
create sequence SEQ_EVENT_BK
minvalue 1
maxvalue 999999999
start with 154879
increment by 1
cache 50;

prompt
prompt Creating sequence SEQ_GEN_TABLE
prompt ===============================
prompt
create sequence SEQ_GEN_TABLE
minvalue 1
maxvalue 9999999999999999999999999999
start with 1144
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_GEN_TABLE_COLUMN
prompt ======================================
prompt
create sequence SEQ_GEN_TABLE_COLUMN
minvalue 1
maxvalue 9999999999999999999999999999
start with 4822
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_JZGD
prompt ==========================
prompt
create sequence SEQ_JZGD
minvalue 1000000000
maxvalue 9999999999999999999999999999
start with 1000000014
increment by 1
nocache;

prompt
prompt Creating sequence SEQ_LOGID
prompt ===========================
prompt
create sequence SEQ_LOGID
minvalue 1
maxvalue 999999
start with 21
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_METERREAD
prompt ===============================
prompt
create sequence SEQ_METERREAD
minvalue 1
maxvalue 9999999999999999999999999999
start with 906642
increment by 1
nocache;

prompt
prompt Creating sequence SEQ_METERREADM
prompt ================================
prompt
create sequence SEQ_METERREADM
minvalue 1
maxvalue 99999999999
start with 91
increment by 1
cache 50;

prompt
prompt Creating sequence SEQ_MRID
prompt ==========================
prompt
create sequence SEQ_MRID
minvalue 1
maxvalue 9999999999
start with 2379516351
increment by 1
cache 50
order;

prompt
prompt Creating sequence SEQ_PAIDBATCH
prompt ===============================
prompt
create sequence SEQ_PAIDBATCH
minvalue 1
maxvalue 9999999999
start with 248023
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
start with 248263
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_PJ_INV_INFO
prompt =================================
prompt
create sequence SEQ_PJ_INV_INFO
minvalue 100000
maxvalue 9999999999999999999999999999
start with 100000
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_RECLIST
prompt =============================
prompt
create sequence SEQ_RECLIST
minvalue 1
maxvalue 9999999999
start with 1000202163
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_SMS_LOGLIST
prompt =================================
prompt
create sequence SEQ_SMS_LOGLIST
minvalue 1
maxvalue 9999999999999999999999999999
start with 710
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SMS_MONTH_LOG
prompt ===================================
prompt
create sequence SEQ_SMS_MONTH_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 10
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_CONFIG
prompt ================================
prompt
create sequence SEQ_SYS_CONFIG
minvalue 1
maxvalue 9999999999999999999999999999
start with 140
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DEPT
prompt ==============================
prompt
create sequence SEQ_SYS_DEPT
minvalue 1
maxvalue 9999999999999999999999999999
start with 220
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DICT_DATA
prompt ===================================
prompt
create sequence SEQ_SYS_DICT_DATA
minvalue 1
maxvalue 9999999999999999999999999999
start with 1040
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DICT_TYPE
prompt ===================================
prompt
create sequence SEQ_SYS_DICT_TYPE
minvalue 1
maxvalue 9999999999999999999999999999
start with 500
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_JOB
prompt =============================
prompt
create sequence SEQ_SYS_JOB
minvalue 1
maxvalue 9999999999999999999999999999
start with 120
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_JOB_LOG
prompt =================================
prompt
create sequence SEQ_SYS_JOB_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 1981
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_LOGININFOR
prompt ====================================
prompt
create sequence SEQ_SYS_LOGININFOR
minvalue 1
maxvalue 9999999999999999999999999999
start with 8128
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_MENU
prompt ==============================
prompt
create sequence SEQ_SYS_MENU
minvalue 1
maxvalue 9999999999999999999999999999
start with 18737
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_NOTICE
prompt ================================
prompt
create sequence SEQ_SYS_NOTICE
minvalue 1
maxvalue 9999999999999999999999999999
start with 120
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_OPER_LOG
prompt ==================================
prompt
create sequence SEQ_SYS_OPER_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 6797
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_POST
prompt ==============================
prompt
create sequence SEQ_SYS_POST
minvalue 1
maxvalue 9999999999999999999999999999
start with 10
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_PRICEFRAME
prompt ====================================
prompt
create sequence SEQ_SYS_PRICEFRAME
minvalue 1
maxvalue 9999999999999999999999999999
start with 320
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_ROLE
prompt ==============================
prompt
create sequence SEQ_SYS_ROLE
minvalue 1
maxvalue 9999999999999999999999999999
start with 240
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_USER
prompt ==============================
prompt
create sequence SEQ_SYS_USER
minvalue 1
maxvalue 9999999999999999999999999999
start with 20294
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_WF_FLOWMAIN
prompt =================================
prompt
create sequence SEQ_WF_FLOWMAIN
minvalue 1
maxvalue 9999999999999999999999999999
start with 50
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_WF_FRMMAIN
prompt ================================
prompt
create sequence SEQ_WF_FRMMAIN
minvalue 1
maxvalue 9999999999999999999999999999
start with 30
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_MENU
prompt ==============================
prompt
create sequence SEQ_YYT_MENU
minvalue 1
maxvalue 9999999999999999999999999999
start with 190
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_USER
prompt ==============================
prompt
create sequence SEQ_YYT_USER
minvalue 1
maxvalue 9999999999999999999999999999
start with 110
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_WATERCUTOFF
prompt =====================================
prompt
create sequence SEQ_YYT_WATERCUTOFF
minvalue 1
maxvalue 9999999999999999999999999999
start with 50
increment by 1
cache 20;

prompt
prompt Creating sequence SYS_DICT_DATA_DICT_CODE_SEQ
prompt =============================================
prompt
create sequence SYS_DICT_DATA_DICT_CODE_SEQ
minvalue 1
maxvalue 999999999
start with 441
increment by 1
cache 20;

prompt
prompt Creating sequence SYS_DICT_TYPE_DICT_ID_SEQ
prompt ===========================================
prompt
create sequence SYS_DICT_TYPE_DICT_ID_SEQ
minvalue 1
maxvalue 999999999
start with 513
increment by 1
cache 20;

prompt
prompt Creating view TMP_VI_DZGL
prompt =========================
prompt
create or replace force view tmp_vi_dzgl as
select mdid,MDMODEL,IFDZSB,MIADR,MIPFID,MRSL,MIWCODE,'' as mitgl,MIMEMO from BS_METERDOC
left join BS_METERINFO on mdid=MICODE and MICODE=3126163992
left join BS_METERREAD on MRMID=MICODE and MRMID=3126163992
where MDID=3126163992;
comment on table TMP_VI_DZGL is '等针管理';

prompt
prompt Creating view VIEW_CHAOBIAO
prompt ===========================
prompt
CREATE OR REPLACE FORCE VIEW VIEW_CHAOBIAO AS
SELECT a.miid,a.MISEQNO,a.mismfid,a.mibfid,a.miadr,b.ciadr,a.mistid,a.mipfid,a.miside,c.MDMODEL,a.miclass,c.MDJIDIANZHUANHUAN,
       b.MICHARGETYPE,a.miface,a.MISTATUS,b.CIIFINV,a.miyl1,a.miyl2,(case a.MISTATUS when '29' then '是'
                            when '30' then '是'
                            else '否' end) as gudingliang,a.mirtid,c.MDCALIBER,a.isallowreading,c.MDBRAND,c.IFDZSB,b.ciname,c.MDNO,substr(a.MIBFID,1,5) as daihao
        from BS_METERINFO a
    left join BS_CUSTINFO b on b.CIID=a.MIID
    left join BS_METERDOC c on a.miid=c.MDID;
comment on table VIEW_CHAOBIAO is '抄表视图';
comment on column VIEW_CHAOBIAO.MIID is '水表档案编号';
comment on column VIEW_CHAOBIAO.MISEQNO is '用户号';
comment on column VIEW_CHAOBIAO.MISMFID is '营业分公司';
comment on column VIEW_CHAOBIAO.MIBFID is '表册';
comment on column VIEW_CHAOBIAO.MIADR is '用水地址';
comment on column VIEW_CHAOBIAO.CIADR is '用户地址';
comment on column VIEW_CHAOBIAO.MISTID is '行业分类';
comment on column VIEW_CHAOBIAO.MIPFID is '用水性质';
comment on column VIEW_CHAOBIAO.MISIDE is '表位';
comment on column VIEW_CHAOBIAO.MDMODEL is '计量方式';
comment on column VIEW_CHAOBIAO.MICLASS is '总分表';
comment on column VIEW_CHAOBIAO.MDJIDIANZHUANHUAN is '基电转换方式';
comment on column VIEW_CHAOBIAO.MICHARGETYPE is '收费方式';
comment on column VIEW_CHAOBIAO.MIFACE is '水表故障';
comment on column VIEW_CHAOBIAO.MISTATUS is '水表状态';
comment on column VIEW_CHAOBIAO.CIIFINV is '是否增值税';
comment on column VIEW_CHAOBIAO.MIYL1 is '等针标识';
comment on column VIEW_CHAOBIAO.MIYL2 is '总表收免';
comment on column VIEW_CHAOBIAO.GUDINGLIANG is '固定量';
comment on column VIEW_CHAOBIAO.MIRTID is '抄表方式';
comment on column VIEW_CHAOBIAO.MDCALIBER is '表口径';
comment on column VIEW_CHAOBIAO.ISALLOWREADING is '手工录入开关';
comment on column VIEW_CHAOBIAO.MDBRAND is '表厂家';
comment on column VIEW_CHAOBIAO.IFDZSB is '水表倒装';
comment on column VIEW_CHAOBIAO.CINAME is '用户名';
comment on column VIEW_CHAOBIAO.MDNO is '表身码';
comment on column VIEW_CHAOBIAO.DAIHAO is '代号';

prompt
prompt Creating view VIEW_CUSTINFO
prompt ===========================
prompt
create or replace force view view_custinfo as
select mirtid, ciid, ciname, ciadr, cimtel, ciconnectper, cinewdate,miside, ciconnecttel,miadr,mistid,miusenum,mdno,'' yhye,'' qfje from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
left join BS_METERINFO c on a.CIID=c.MIID
where rownum<100;
comment on table VIEW_CUSTINFO is '户表信息';

prompt
prompt Creating view VIEW_CUSTMETERINFO
prompt ================================
prompt
create or replace force view view_custmeterinfo as
select
      a.ciid,
      a.ciname,
      a.ciadr,
      a.cimtel,
      a.ciconnectper,
      a.cinewdate,
      a.ciconnecttel,
      a.misaving ,
      c.miside ,
      c.mirtid ,
      c.miadr,
      c.mistid,
      c.miusenum ,
      b.mdno,
      c.mistatus,
      c.miid,
      sum(rlje) as qfje
      from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
      left join BS_METERINFO c on a.CIID=c.micode
      left join BS_RECLIST d on a.ciid=d.RLCID and d.RLPAIDFLAG=0
      group by a.ciid,a.ciname,a.ciadr,a.cimtel,a.ciconnectper,a.cinewdate,a.ciconnecttel,a.misaving,b.mdno,c.miside,c.mirtid,c.miadr,c.mistid,c.miusenum,d.rlcid,c.mistatus,c.miid;

prompt
prompt Creating view VIEW_PAYMENT
prompt ==========================
prompt
create or replace force view view_payment as
select "用户编号","合收主表号","缴费月份","发生日期","缴费机构","收费员","付款金额","交易流水","付款方式","缴费交易批次","微信交易流水","微信申请日期","老户号"
    from view_payment@hrbzls;

prompt
prompt Creating view VIEW_ZKH
prompt ======================
prompt
create or replace force view view_zkh as
select bfid    表册编码,
         bfsmfid 营业所,
         bfpid   上级编码,
         bfclass 级次,
         bfrper  抄表员
    From bs_bookframe
   where bfid in
         ('01', '01001', '01001001', '01001002', '01001003', '01001003')
   order by bfclass;
comment on table VIEW_ZKH is '帐卡号树';

prompt
prompt Creating view VI_BOOKFRAME
prompt ==========================
prompt
create or replace force view vi_bookframe as
select
BFID  编码,
BFSMFID 营业分公司,
BFBATCH 抄表批次,
BFNAME 名称,
BFPID 上级编码,
BFCLASS 级次,
BFFLAG  末级标志,
BFSTATUS  有效状态,
BFHANDLES 下级数量,
BFMEMO  备注,
BFORDER 册间次序,
BFCREPER  创建人,
BFCREDATE 创建日期,
BFRCYC  抄表周期,
BFLB  表册类别,
BFRPER  抄表员,
BFSAFID 区域,
BFNRMONTH   下次抄表月份,
BFDAY 偏移天数,
BFSDATE 计划起始日期,
BFEDATE 计划结束日期,
BFMONTH 本期抄表月份,
BFPPER    收费员,
BFJTSNY   阶梯开始月

 from BS_BOOKFRAME bf
LEFT JOIN BS_METERINFO mo on BF.BFID=MO.MIBFID
 where rownum<=100;
comment on table VI_BOOKFRAME is '帐卡号管理';

prompt
prompt Creating view VI_ZHUILIANG
prompt ==========================
prompt
create or replace force view vi_zhuiliang as
select a.ciid,a.ciname,a.ciname1,a.ciadr,
        b.mibfid,b.mistid,b.mircode,b.mirecsl,b.miid,
        c.mrscode,c.mrecode,
        '' czbqzz,'' sqzz,'' bnrjt,'' zblb,'' bz
      from bs_meterinfo b
      left join bs_custinfo a on b.micode=a.ciid
      left join bs_meterread c on b.miid = c.mrmid;
comment on table VI_ZHUILIANG is '追量';
comment on column VI_ZHUILIANG.CIID is '用户号';
comment on column VI_ZHUILIANG.CINAME is '用户名';
comment on column VI_ZHUILIANG.CINAME1 is '票据名';
comment on column VI_ZHUILIANG.CIADR is '用水地址';
comment on column VI_ZHUILIANG.MIBFID is '表册';
comment on column VI_ZHUILIANG.MISTID is '用水类别';
comment on column VI_ZHUILIANG.MIRCODE is '上期抄表';
comment on column VI_ZHUILIANG.MIRECSL is '本期抄表';
comment on column VI_ZHUILIANG.MIID is '水表档案编号';
comment on column VI_ZHUILIANG.MRSCODE is '本期指针';
comment on column VI_ZHUILIANG.MRECODE is '应收水量';
comment on column VI_ZHUILIANG.CZBQZZ is '重置本期指针';
comment on column VI_ZHUILIANG.SQZZ is '上期指针';
comment on column VI_ZHUILIANG.BNRJT is '不纳入阶梯';
comment on column VI_ZHUILIANG.ZBLB is '追补类别';
comment on column VI_ZHUILIANG.BZ is '备注';

prompt
prompt Creating package PG_CB_COST
prompt ===========================
prompt
create or replace package pg_cb_cost is

  --应收明细包
  subtype rd_type is bs_recdetail%rowtype;
  type rd_table is table of rd_type;


  --错误返回码
  errcode constant integer := -20012;

	procedure wlog(p_txt in varchar2);

  procedure autosubmit;
  --计划内抄表提交算费
  procedure submit(p_mrbfids in varchar2, log out varchar2);
  --算费前虚拟算费，供月抄表明细调用
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype in varchar2,    -- 01 虚拟算费; 02 正式算费
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             o_mrsumje   out number,
             err_log out varchar2);
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type);
  -- 自来水单笔算费，提供外部调用
  procedure calculate(mr      in out bs_meterread%rowtype,
                      p_trans in char,
                      p_ny    in varchar2,
                      p_rec_cal in varchar2);
  --自来水单笔算费，只用于记账不计费（哈尔滨）
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2);
  --费率计算步骤
  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table)  ;
  --阶梯计费步骤
  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table);

  procedure insrd(rd in rd_table);

  --应收冲正_按工单
  procedure yscz_gd(p_reno   in varchar2,--工单流水号
                 p_oper    in varchar2,--完结人
                 p_memo   in varchar2 --备注
                 );

  --应收冲正_按应收账流水

  procedure yscz_rl(p_rlid   in varchar2, --应收账流水号
                 p_oper    in varchar2,    --完结人
                 p_memo   in varchar2,    --备注
                 o_rlcrid out varchar2    --返回负应收账流水号
                 );

end;
/

prompt
prompt Creating package PG_CHKOUT
prompt ==========================
prompt
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

prompt
prompt Creating package PG_DHZ
prompt =======================
prompt
create or replace package pg_dhz is

  --呆账坏账 工单处理
  procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2);

  --呆账坏账 销账
  procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, o_log out varchar2) ;

end pg_dhz;
/

prompt
prompt Creating package PG_EWIDE_METERTRANS
prompt ====================================
prompt
CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS IS

  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(P_MTHNO  IN VARCHAR2, --批次流水
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2); --提交标志

  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER    IN VARCHAR2, -- 操作员
                              P_MD     IN METERTRANSDT%ROWTYPE, --单体行变更
                              P_COMMIT IN VARCHAR2); --提交标志

  --插入抄表计划
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        MI        IN BS_METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT BS_METERREAD.MRID%TYPE); --抄表流水

  --计划内算费
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE);

  -- 自来水单笔算费，提供外部调用
  PROCEDURE CALCULATE(MR      IN OUT BS_METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           );

  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT BS_METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);

  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);

  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2);

  -- 费率明细计算步骤
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    P_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2);

  PROCEDURE INSRD(RD IN RD_TABLE);

  PROCEDURE SP_RECLIST_CHARGE_01(V_RDID IN VARCHAR2, V_TYPE IN VARCHAR2);

    --阶梯计费步骤
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);

  --缴费自动执行电子发票开具任务
  PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2);

  --违约金计算（含节假日规则，含减免规则）
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --应收流水
                     P_RLJE     IN NUMBER, --应收金额
                     P_RLGROUP  IN NUMBER, --应收组号
                     P_RLZNDATE IN DATE, --滞纳金起算日
                     P_SMFID    VARCHAR2, --水表营业所
                     P_EDATE    IN DATE --终算日'不计入'违约日
                     ) RETURN NUMBER;

  --水价调整函数   BY WY 20130531
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE;

  --调整水价+费用项目函数   BY WY 20130531
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;

  --自来水柜台缴费
  FUNCTION POS(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
               P_OPER     IN PAYMENT.PPER%TYPE, --收款员
               P_RLIDS    IN VARCHAR2, --应收流水串
               P_RLJE     IN NUMBER, --应收总金额
               P_ZNJ      IN NUMBER, --销帐违约金
               P_SXF      IN NUMBER, --手续费
               P_PAYJE    IN NUMBER, --实际收款
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
               P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --销帐批次
               P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
               P_INVNO    IN VARCHAR2, --发票号
               P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
               ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_POS_1METER
  用途：单只水表缴费
      1、单表缴费业务，调用本函数，在PAYMENT 中记一条记录，一个id流水，一个批次
      2、多表缴费业务，通过循环调用本函数实现业务，一只水表一条记录，多个水表一个批次。
  业务规则：
     1、单只水表，非欠费全销，将待销应收id，按xxxxx,xxxxx,xxxxx| 格式存放P_RLIDS, 调用本过程
     2、银行行等代收机构或柜台进行单只水表的欠费全销，P_RLIDS='ALL'
     3、单缴预存，P_RLJE=0
  参数：参见用途说明
     P_PAYBATCH='999999999',则在模块内生成批次号，否则，直接使用P_PAYBATCH作为批次号
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_RLIDS    IN VARCHAR2, --应收流水串
                        P_RLJE     IN NUMBER, --应收总金额
                        P_ZNJ      IN NUMBER, --销帐违约金
                        P_SXF      IN NUMBER, --手续费
                        P_PAYJE    IN NUMBER, --实际收款
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --销帐批次
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
                        ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_POS_MULT_HS
  用途：
      合收表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，每只水表都根据客户端选择的结果返回待销流水id
     2、主表先销帐，所有销帐金额计算到主表期末余额上
     3、逐笔处理子表，主表预存转子表预存，子表预存销帐，
     4、整体事务提交
  参数：
  前置条件：
      水表和水表对应的应收帐流水串，存放在临时接口表 PAY_PARA_TMP 中
  *******************************************************************************************/
  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                         P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --合收主表号
                         P_PAYJE    IN NUMBER, --总实际收款金额
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                         P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                         P_INVNO    IN VARCHAR2, --发票号
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_POS_MULT_M
  用途：
      多表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，支持水表挑选销帐月份
     2、每只水表都不发生预存变化，收费金额=欠费金额
     3、所有水表的销帐，在PAYMENT中，同一个批次流水。
  参数：
  前置条件：
      1、最重要的销帐参数（水表id，应收帐流水id串，应收金额，违约金，手续费） 在调用本过程前，
       存放在临时接口表 PAY_PARA_TMP
      2、应收帐流水串的格式见核心单表销帐过程的说明。
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_PAYJE    IN NUMBER, --总实际收款金额
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    MID_COUNT NUMBER; --水表只数
    V_INP     NUMBER; --循环变量

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --销账错误
    ERR_JE EXCEPTION; --金额错误

    CURSOR C_M_PAY IS
      SELECT * FROM PAY_PARA_TMP RT;

  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    --生成统一批次号
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');
    V_BATCH := P_BATCH;
    V_TOTAL := 0;
    --调用单表销帐过程，进行逐水表销帐 处理
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --计算单只水表的实际收款金额
      V_PAID_METER := V_PP.RLJE + V_PP.RLZNJ + V_PP.RLSXF;

      V_TOTAL := V_TOTAL + V_PAID_METER;

      ---单表销帐---------------------------------------------------------------------------------
      V_RESULT := F_POS_1METER(P_POSITION, --缴费机构
                               P_OPER, --收款员
                               V_PP.PLIDS, --应收流水串
                               V_PP.RLJE, --应收总金额
                               V_PP.RLZNJ, --销帐违约金
                               V_PP.RLSXF, --手续费
                               V_PAID_METER, -- 水表实际收款
                               P_TRANS, --缴费事务
                               V_PP.MID, --水表资料号
                               P_FKFS, --付款方式
                               P_PAYPOINT, --缴费地点
                               V_BATCH, --自动生成销帐批次
                               P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                               P_INVNO, --发票号
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;
    END LOOP;

    /*--全部水表处理完毕，后台数据影响如下：------------------------------------------------------
    1、【PAYMENT】中，增加了和水表数量相同的记录，实际收费金额=应缴金额（水费、违约金、手续费等）
          没有预存变化，这些记录有相同的批次号。
    2、在应收总账【RECLIST】中，指定水表指定的应收记录，都按照销帐规则进行处理。没有预存的变化
    3、在应收明细【RECDETAIL 】中，和RECLIST中相匹配的记录，都按照销帐规则进行处理。
    ----------------------------------------------------------------------------------------------------*/
    --检查总金额是否相符，否则报错
    IF V_TOTAL <> P_PAYJE THEN
      RAISE ERR_JE;
    END IF;
    --一次性提交-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_M', V_INP, '表号:' || V_PP.MID, '');
      RETURN '999';
  END F_POS_MULT_M;

  /*******************************************************************************************
  函数名：F_SET_REC_TMP
  用途：为销帐核心过程准备待处理应收数据
  处理过程：
       1、如果是全部销帐，则直接将相应记录从RECLIST拷贝到临时表
       2、如果是部分记录销帐，则根据应收帐流水串，逐条从RECLIST拷贝到临时表
       3、计算违约金、手续费等销帐前计算的金额信息
  参数：
       1、部分销帐，P_RLIDS 应收流水串，格式：XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| 逗号分隔
       2、全部销帐：_RLIDS='ALL'
       3、P_MIID  水表资料号
  返回值：成功--应收流水ID个数，失败--0
  *******************************************************************************************/
  FUNCTION F_SET_REC_TMP(P_RLIDS IN VARCHAR2, P_MIID IN VARCHAR2)
    RETURN NUMBER;

  /*******************************************************************************************
  函数名：F_CHK_AMOUNT
  用途：检查销帐金额是否相符
  参数： 应缴，手续费，违约金，实收金额，预存期初
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --应收金额
                      P_ZNJ    IN NUMBER, --销帐违约金
                      P_SXF    IN NUMBER, --手续费
                      P_PAYJE  IN NUMBER, --实际收款
                      P_SAVING IN METERINFO.MISAVING%TYPE --水表资料号
                      ) RETURN NUMBER;

  /*******************************************************************************************
  新的销帐处理过程由此以下:
  销帐业务总体规则说明如下：
  1、最小缴费单元：一块水表一个月的全部费用
  2、实收帐PAYMENT中一条记录，对应一只水表的一个月或多个月的应收销帐
  3、如有多表缴费（托收、合收户等），则在PAYMENT中记录多条收费流水，每条记录参见第2点说明
  多条收费流水通过批次流水关联成一次销帐业务。
  4、欠费判断依据：t.rlpaidflag=’N’ AND t.RLJE>0 AND t.RLREVERSEFLAG=’N’
  *******************************************************************************************/
  /*******************************************************************************************
  函数名：F_PAY_CORE
  用途：核心销帐过程，所有针销帐业务都最终调用本函数实现
  参数：

  返回值：
          000---成功
          其他--失败
  前置条件：
          在临时表RECLIST_1METER_TMP中，准备好所有【待销帐数据】
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                      P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                      P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                      P_RLJE     IN NUMBER, --应收金额
                      P_ZNJ      IN NUMBER, --销帐违约金
                      P_SXF      IN NUMBER, --手续费
                      P_PAYJE    IN NUMBER, --实际收款
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                      P_PAYBATCH IN VARCHAR2, --缴费事务流水
                      P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                      P_INVNO    IN PAYMENT.PILID%TYPE, --发票号
                      P_PAYID    OUT PAYMENT.PID%TYPE --实收流水，返回此次记账的实收流水号
                      ) RETURN VARCHAR2;

  /*******************************************************************************************
  函数名：F_REMAIND_TRANS
  用途：在2块水表之间进行预存转移
  参数： 转出水表号，准入水表号，金额
  业务规则：
     1、调用核心销帐过程，水费金额=0时为单缴预存，
     2、在PAYMENT中，增加2条记录，一个为正预存，一个为负预存
     3、2条记录同一个批次号
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --转出水表号
                            P_MID_T    IN METERINFO.MIID%TYPE, --水表资料号
                            P_JE       IN METERINFO.MISAVING%TYPE, --转移金额
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --实收帐批次号
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --是否提交
                            ) RETURN VARCHAR2;

END PG_EWIDE_METERTRANS;
/

prompt
prompt Creating package PG_EWIDE_METERTRANS_01
prompt =======================================
prompt
CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS_01 IS
  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER    IN VARCHAR2, -- 操作员
                              P_MD     IN METERTRANSDT%ROWTYPE, --单体行变更
                              P_COMMIT IN VARCHAR2 --提交标志
                              );
  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           );
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE); --计划内算费
  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT BS_METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);
  --插入抄表计划
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        MI        IN BS_METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT BS_METERREAD.MRID%TYPE --抄表流水
                        );
  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2);
  -- 费率明细计算步骤
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    P_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2);
  --阶梯计费步骤
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);
  --写算费日志
  PROCEDURE WLOG(P_TXT IN VARCHAR2);
  --调整水价+费用项目函数   BY WY 20130531
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE;
END;
/

prompt
prompt Creating package PG_EWIDE_RAEDPLAN_01
prompt =====================================
prompt
CREATE OR REPLACE PACKAGE "PG_EWIDE_RAEDPLAN_01" IS

  --复核检查(哈尔滨)
  --返回 0  正常
  --返回 -1 异常
  PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2, /*流水号*/
                             P_MRSL      IN NUMBER, /*用水量*/
                             O_SUBCOMMIT OUT VARCHAR2); /*返回结果*/

END;
/

prompt
prompt Creating package PG_INSERT
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_INSERT IS

  --表册信息插入
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --起始编码号
                           I_BFID_END   IN VARCHAR2,  --结束编码号
                           I_BFSMFID    IN VARCHAR2,  --营销公司
                           I_BFBATCH    IN VARCHAR2,  --抄表批次
                           I_BFPID      IN VARCHAR2,  --上级编码
                           I_BFCLASS    IN VARCHAR2,  --级次
                           I_BFFLAG     IN VARCHAR2,  --末级标志
                           I_BFMEMO     IN VARCHAR2,  --备注
                           I_OPER       IN VARCHAR2,  --操作人
                           I_BFRCYC     IN VARCHAR2,  --抄表周期
                           I_BFLB       IN VARCHAR2,  --表册类别
                           I_BFRPER     IN VARCHAR2,  --抄表员
                           I_BFSAFID    IN VARCHAR2,  --区域
                           I_BFNRMONTH  IN VARCHAR2,  --下次抄表月份
                           I_BFDAY      IN VARCHAR2,  --偏移天数
                           I_BFSDATE    IN VARCHAR2,  --计划起始日期
                           I_BFEDATE    IN VARCHAR2,  --计划结束日期
                           I_BFPPER     IN VARCHAR2,  --收费员
                           I_BFJTSNY    IN VARCHAR2,  --阶梯开始月
                           O_RETURN     OUT VARCHAR2, --返回重复编号
                           O_STATE      OUT NUMBER);  --返回执行状态或数量

END;
/

prompt
prompt Creating package PG_METERTRANS
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE "PG_METERTRANS" IS

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;


  --2、在装水表状态
  M立户       CONSTANT VARCHAR2(2) := '1'; --【分公司】用户正在使用
  M销户       CONSTANT VARCHAR2(2) := '7'; --【分公司】销户拆表后如果没有送检，则处于销户
  --单据类别,表务类别
  BT拆表           CONSTANT CHAR(1) := 'F';
  BT故障换表       CONSTANT CHAR(1) := 'K';
  BT周期换表       CONSTANT CHAR(1) := 'L';

   --周期换表、拆表、故障换表
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          );



  --撤表销户简单的销户操作 不考虑财务
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --批次流水
                                 I_PER   IN VARCHAR2, --操作员
                                 O_STATE OUT NUMBER);  --执行状态



/*  --工单单个审核过程
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN GD_METERTGLDT%ROWTYPE --单体行变更
                             );*/



  --分户、合户
  PROCEDURE SP_METERUSER(I_RENO   IN  VARCHAR2, --批次流水
                         I_PER    IN  VARCHAR2, --操作员
                         I_TYPE   IN  VARCHAR2, --类型
                         O_STATE  OUT NUMBER); -- 执行状态



  --工单流程未通过
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --操作类型
                           P_MTHNO  IN VARCHAR2, --批次流水
                           P_PER    IN VARCHAR2, --操作员
                           P_REMARK IN VARCHAR2,--备注、拒绝原因
                           P_COMMIT IN VARCHAR2);--提交标志
END;
/

prompt
prompt Creating package PG_METER_READ
prompt ==============================
prompt
create or replace package PG_METER_READ is

  -- Author  : ADMIN
  -- Created : 2020-12-23 15:34:59
  -- Purpose : 抄表

  --手工抄表，重抄操作
  PROCEDURE METERREAD_RE(
            --mrid IN VARCHAR2,  --meterread表当前流水号
            smiid IN VARCHAR2,  --水表编号
            gs_oper_id  IN VARCHAR2,  --登录人员id
            RES IN OUT INTEGER);



end PG_METER_READ;
/

prompt
prompt Creating package PG_PAID
prompt ========================
prompt
create or replace package pg_paid is
  --错误返回码
  errcode constant integer := -20012;
  --常量参数
  paytrans_pos      constant char(1) := 'P'; --自来水柜台缴费
  paytrans_ds       constant char(1) := 'B'; --银行实时代收
  paytrans_bsav     constant char(1) := 'W'; --银行实时单缴预存
  paytrans_dsde     constant char(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销隔日发起）
  paytrans_dk       constant char(1) := 'D'; --代扣销帐
  paytrans_ts       constant char(1) := 'T'; --托收票据销帐
  paytrans_sav      constant char(1) := 'S'; --自来水柜台独立预存
  paytrans_inv      constant char(1) := 'I'; --走收票据销帐
  paytrans_预存抵扣 constant char(1) := 'U'; --算费过程即时预存抵扣
  paytrans_ycdb     constant char(1) := 'K'; --预存调拨
  paytrans_cr     constant char(1) := 'C'; --其它所有未独立业务冲销（销帐冲正单据发起）
  paytrans_bankcr constant char(1) := 'X'; --实时代收冲销（银行当日冲销发起）
  paytrans_dscr   constant char(1) := 'R'; --实时代收单边帐冲销
  paytrans_adj    constant char(1) := 'V'; --减量退费：退费贷帐事务(cr)、借帐补销事务(de)
  paytrans_稽查   constant char(1) := 'F'; --稽查罚款
  paytrans_追量   constant char(1) := 'Z'; --追量
  paytrans_预留   constant char(1) := 'Y'; --预留
  paytrans_余度   constant char(1) := 'A'; --余度
  paytrans_工程款 constant char(1) := 'G'; --工程款
  paytrans_价差   constant char(1) := 'J'; --价差
  paytrans_水损   constant char(1) := 'K'; --水损

  /*  
  --按票据销账 批量
  p_pjida         票据编码,多个票据按逗号分隔
  p_cply          出票来源：SMSF 上门收费 BJSF 补缴收费
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号
  */
  procedure poscustforys_pj_pl(p_pjids varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2);
             
  /*  
  --按票据销账
  p_pjid          票据编码
  p_cply          出票来源：SMSF 上门收费 BJSF 补缴收费
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号
  */
  procedure poscustforys_pj(p_pjid varchar2,
             p_cply     varchar2,
             p_oper     in varchar2,
             o_log      out varchar2);
             
  --缴费入口
  /*
  p_yhid          用户编码
  p_arstr          欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号*/
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2);

  --一水表多应收销帐
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_pbatch   in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number);

  --实收销帐处理核心
  procedure payzwarcore(p_pid          in varchar2,
              p_batch        in varchar2,
              p_payment      in number,
              p_remainbefore in number,
              p_oper         in varchar,
              p_paiddate     in date,
              p_paidmonth    in varchar2,
              p_arstr        in varchar2,
              o_sum_arje     out number,
              o_sum_arznj    out number,
              o_sum_arsxf    out number);

  --批量预存充值
  procedure precust_pl(p_yhids     in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    o_pid_reverse out varchar2);

  --预存退费工单_批量
  procedure precust_yctf_gd_pl(p_renos     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --预存退费工单
  procedure precust_yctf_gd(p_reno     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --预存充值
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_pbatch      in varchar2,
                    p_trans       in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number);

  --实收冲正，按工单
  procedure pay_back_gd(p_reno in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，多流水号批量冲正，只冲正缴费交易，不冲正抵扣交易
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，按缴费批次
  procedure pay_back_by_pbatch(p_pbatch in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，柜台缴费退费，
  --  1.事务为U 或 事务为P且预存金额大于退费金额，直接冲正当条实收
  --  2.事务为P且预存金额小于退费金额，按收费时间倒序冲正事务为U的实收，直到预存金额大于退费金额，然后冲正事务为P的当条实收
  procedure pay_back_by_pdate_desc(p_pid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正
  --  p_payid  实收流水号
  --  p_oper   操作员编码
  --  p_recflg 是否冲正应收账
  --  o_pid_reverse      返回实收冲正流水号
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, p_recflag in varchar2, o_pid_reverse out varchar2) ;

/*******************************************************************************************
函数名：f_set_cr_reclist
用途： 本函数由核心实收冲正帐过程调用，调用前【待冲正应收记录记录】已经在从RECLIST 中拷贝到临时表中，本函数对临时表进行逐条冲正处理，
返回主程序后，核心冲正过程根据临时表更新RECLIST ，达到快捷冲正目的。
       逐条处理的目的：将冲正金额和预存逐条分配到应收帐记录上，预存管理
例子： A水表，个月欠费110元，期初预存30元，本次收费100元，违约金5元，应收冲正后记录如下：
----------------------------------------------------------------------------------------------------
月     份       预初     本次收费    应缴水费     违约金    预存期末   预存发生
----------------------------------------------------------------------------------------------------
原  2011.06         30          100           110         5        15         15
新  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
参数：pm 负实收 。
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype) return number;



end;
/

prompt
prompt Creating package PG_PJ
prompt ======================
prompt
create or replace package pg_pj is
  --票据处理包
  
  --补缴收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );
  
  --上门收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );

  --票据 收费 单用户应收账
  /*
  p_rlids     应收账编码，多个按逗号分隔
  p_fkfs      付款类型(XJ 现金,ZP,支票
  p_cply      出票来源：SMSF 上门收费 BJSF 补缴收费
  */
  procedure pj_sf(p_rlids varchar2,  p_fkfs varchar2, p_cply varchar2);

end pg_pj;
/

prompt
prompt Creating package PG_RAEDPLAN
prompt ============================
prompt
CREATE OR REPLACE PACKAGE PG_RAEDPLAN IS

  -- AUTHOR  : ADMIN
  -- CREATED : 2020-12-22
  -- PURPOSE : 抄表计划
  --取消、取消单户 为前台SQL语句实现
  --错误代码

  ERRCODE CONSTANT INTEGER := -20012;

  NO_DATA_FOUND EXCEPTION;

  --生成抄表计划
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                     P_MONTH     IN VARCHAR2, /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2, /*表册*/
                     O_STATE     OUT VARCHAR2); /*执行状态*/
  --生成抄表计划
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                     P_MONTH     IN VARCHAR2, /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2, /*表册*/
                     O_STATE     OUT VARCHAR2); /*执行状态*/

  --单户月初
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CREATECBSB(P_MONTH IN VARCHAR2, /*抄表月份*/
                       P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2); /*执行状态*/

  -- 月终
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, /*营业所,售水公司*/
                            P_MONTH  IN VARCHAR2, /*当前月份*/
                            P_COMMIT IN VARCHAR2, /*提交标识*/
                            O_STATE  OUT VARCHAR2); /*执行状态*/

  -- 抄表审核
  --TIME 2020-12-24  BY WL
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID  IN VARCHAR2,  /*流水号*/
                            P_OPER  IN VARCHAR2,  /*操作人姓名*/
                            P_FLAG  IN VARCHAR2,  /*是否通过*/
                            O_STATE OUT VARCHAR2);/*执行状态*/

  --生成抄表调用
  --单户月初调用
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER);

  --工单抄表库回写
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CREATECBGD(P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2); /*执行状态*/
END;
/

prompt
prompt Creating package PG_RECTRANS
prompt ============================
prompt
create or replace package pg_rectrans is

  -- Author  : lwt
  -- Created : 2021-1-14 14:43:52
  -- Purpose : 水量、账务调整
  errcode constant integer := -20012;

  --追量收费 工单a
  --源表：request_zlsf
  procedure rectrans_gd(p_reno varchar2, p_gdtype varchar2, o_log out varchar2);

  --生成抄表记录
  procedure ins_mr(p_miid         varchar2,
                   p_mrscode      number,
                   p_mrecode      number,
                   p_mrsl         number,
                   p_mrdatasource varchar2,
                   p_mrgdid       varchar2,
                   p_mrifreset    varchar2,
                   p_mrifstep     varchar2,
                   o_mrid         out varchar2,
                   o_log          out varchar2);


end pg_rectrans;
/

prompt
prompt Creating package PG_UPDATE
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_UPDATE IS

  --变更管理
  -- A 用户信息维护
  -- B 票据信息维护
  -- C 收费方式变更
  -- D 用水性质变更
  -- E 水表档案变更
  -- F 过户
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER); --执行状态

  --表册调整
  -- A 跨区域调整
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER); --执行状态

  --抄表员间表册转移
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --表册号
                       I_BFRPER  IN VARCHAR2, --新抄表员
                       I_BFRCYC  IN VARCHAR2, --新抄表周期
                       I_BFSDATE IN VARCHAR2, --新计划起始日期
                       I_BFEDATE IN VARCHAR2, --新计划结束日期
                       I_BFNRMONTH IN VARCHAR2, --新下次抄表月份
                       O_STATE   OUT NUMBER); --执行状态

  --账卡号调整
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --水表档案编号
                      I_MIBFID  IN VARCHAR2, --表册号
                      O_STATE   OUT NUMBER); --执行状态

  --等针
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --流水号
                    O_STATE   OUT NUMBER); --执行状态

  --固定量
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --流水号
                     O_STATE   OUT NUMBER); --执行状态

  --总表收免
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --流水号
                      O_STATE   OUT NUMBER); --执行状态

END;
/

prompt
prompt Creating package TOOLS
prompt ======================
prompt
CREATE OR REPLACE PACKAGE "TOOLS" IS

  -- AUTHOR  : 江浩
  -- CREATED : 2008-01-08 16:34:39
  -- PURPOSE : JH

  --抄表月份
  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2;

  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

END TOOLS;
/

prompt
prompt Creating type CONNSTRIMPL
prompt =========================
prompt
CREATE OR REPLACE TYPE "CONNSTRIMPL"  AS OBJECT
(
  CURRENTSTR VARCHAR2(4000),
  CURRENTSEPRATOR VARCHAR2(8),
  STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT CONNSTRIMPL)
    RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT CONNSTRIMPL,
    VALUE IN VARCHAR2) RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF IN CONNSTRIMPL,
    RETURNVALUE OUT VARCHAR2, FLAGS IN NUMBER) RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT CONNSTRIMPL,
    CTX2 IN CONNSTRIMPL) RETURN NUMBER
)
/

prompt
prompt Creating function CONNSTR
prompt =========================
prompt
CREATE OR REPLACE FUNCTION "CONNSTR" (input VARCHAR2) RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING CONNSTRIMPL;
/

prompt
prompt Creating function FCHKMETERNEEDCHARGE
prompt =====================================
prompt
CREATE OR REPLACE FUNCTION FCHKMETERNEEDCHARGE
   (VMSTATUS IN VARCHAR2,
    VIFCHK IN VARCHAR2,
    VMTYPE IN VARCHAR2)
   RETURN CHAR
AS
   LRET CHAR(1);
BEGIN
  --【哈尔滨】20140306 允许销户拆表余度量算费（计划内抄表、追量等在哈尔滨本身就不会对销户状态的用户做操作）
   IF VIFCHK='Y' THEN
      RETURN 'N';
   END IF;
   SELECT SMTIFCHARGE INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMTYPE;
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   RETURN 'Y';
EXCEPTION WHEN OTHERS THEN
   RETURN 'N';
END;
/

prompt
prompt Creating function FCHKMETERNEEDREAD
prompt ===================================
prompt
CREATE OR REPLACE FUNCTION "FCHKMETERNEEDREAD"
   (VMIID IN VARCHAR2)
   RETURN CHAR
AS
   LRET       CHAR(1);
   VMISTATUS  BS_METERINFO.MISTATUS%TYPE;
   VMITYPE    BS_CUSTINFO.MICHARGETYPE%TYPE;
   VMIIFSL    BS_METERINFO.MIIFSL%TYPE;
   VMIIFCHK   BS_METERINFO.MIIFCHK%TYPE;
   MI         BS_METERINFO%ROWTYPE;
BEGIN
   SELECT MISTATUS,NVL(MICHARGETYPE,'1'),MIIFSL,NVL(MIIFCHK,'N')
     INTO VMISTATUS,VMITYPE,VMIIFSL,VMIIFCHK
     FROM BS_METERINFO,BS_CUSTINFO
    WHERE MIID=CIID AND MIID=VMIID;
   --非抄表类型的表状态水表不抄
   --SELECT SMSMEMO INTO LRET FROM SYSMETERSTATUS WHERE SMSID=VMISTATUS;
   --对应值暂时无法取出默认为Y   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmeterstatus';
   LRET:='Y';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --非抄表类型的表类型水表不抄
   --SELECT SMTIFREAD INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMITYPE;
   --对应值暂时无法取出默认为Y   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmetertype';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --一表多户分表水表不抄 ZHB
   --暂不考虑多表情况
   /*SELECT * INTO MI FROM BS_METERINFO WHERE MIID=VMIID;
   IF MI.MICOLUMN9='Y' AND MI.MICODE <> MI.MIPRIID  THEN
      RETURN 'N';
   END IF;*/

   RETURN 'Y';
EXCEPTION

WHEN OTHERS THEN
   RETURN 'N';
END;
/

prompt
prompt Creating function FGETCUSTNAME
prompt ==============================
prompt
CREATE OR REPLACE FUNCTION "FGETCUSTNAME" (P_CIID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(60);
BEGIN
 SELECT CINAME
 INTO LRET
 FROM BS_CUSTINFO
 WHERE CIID = P_CIID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

prompt
prompt Creating function FGETMETERINFO
prompt ===============================
prompt
CREATE OR REPLACE FUNCTION "FGETMETERINFO"(P_MIID IN VARCHAR2,
                                           P_TYPE IN VARCHAR2)
  RETURN VARCHAR2 AS
  MI METERINFO%ROWTYPE;
  MA METERACCOUNT%ROWTYPE;
  CI CUSTINFO%ROWTYPE;
BEGIN
  SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;
  IF UPPER(P_TYPE) = 'MICHARGETYPE' THEN
    RETURN MI.MICHARGETYPE;
  END IF;
  IF UPPER(P_TYPE) = 'MISTATUS' THEN
    RETURN MI.MISTATUS;
  END IF;
  IF UPPER(P_TYPE) = 'MISMFID' THEN
    RETURN MI.MISMFID;
  END IF;
  IF UPPER(P_TYPE) = 'MISEQNO' THEN
    RETURN MI.MISEQNO;
  END IF;
  IF UPPER(P_TYPE) = 'MIIFCHK' THEN
    RETURN MI.MIIFCHK;
  END IF;
  IF UPPER(P_TYPE) = 'MILB' THEN
    RETURN MI.MILB;
  END IF;
  IF UPPER(P_TYPE) = 'MIPFID' THEN
    RETURN MI.MIPFID;
  END IF;
  IF UPPER(P_TYPE) = 'MINAME' THEN
    RETURN MI.MINAME;
  END IF;
  IF UPPER(P_TYPE) = 'MIBFID' THEN
    RETURN MI.MIBFID;
  END IF;
  IF UPPER(P_TYPE) = 'MIRCODE' THEN
    RETURN MI.MIRCODE;
  END IF;

  SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = P_MIID;
  IF UPPER(P_TYPE) = 'MABANKID' THEN
    RETURN MA.MABANKID;
  END IF;
  IF UPPER(P_TYPE) = 'MAACCOUNTNO' THEN
    RETURN MA.MAACCOUNTNO;
  END IF;
  IF UPPER(P_TYPE) = 'MAACCOUNTNAME' THEN
    RETURN MA.MAACCOUNTNAME;
  END IF;

  SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
  IF UPPER(P_TYPE) = 'CINAME' THEN
    RETURN CI.CINAME;
  END IF;
  IF UPPER(P_TYPE) = 'CIADR' THEN
    RETURN CI.CIADR;
  END IF;
  IF UPPER(P_TYPE) = 'CIMTEL' THEN
    RETURN CI.CIMTEL;
  END IF;
  IF UPPER(P_TYPE) = 'CINAME2' THEN
    RETURN CI.CINAME2;
  END IF;

  RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FGETSEQUENCE
prompt ==============================
prompt
CREATE OR REPLACE FUNCTION "FGETSEQUENCE"(AS_TAB_NAME IN VARCHAR2)
  RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- 函数：GET_SEQUENCE
  -- 按照在SEQ LIST 表中定义的细节返回序列值
  -- INPUT： AS_TAB_NAME 数据表名
  -- RETURN：VARCHAR2 返回的序列值
  ----------------------------------------------------------------------------
  LN_SEQ_NUM    NUMBER;
  V_SQL         VARCHAR2(500);
  LS_SEQ_NUM    VARCHAR2(20);
  AS_SEQ_NAME   VARCHAR2(30);
  TEMP_ID       VARCHAR2(40);
  LS_CUR_SYNTAX VARCHAR(200);
  LR_SEQLIST    SYS_SEQLIST%ROWTYPE;
  PRELEN        NUMBER;
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  --获得当前的序列相关的定义
  SELECT SSLSEQNAME, NVL(SSLPREFIX, ' '), SSLWIDTH, SSLSTARTNO
    INTO LR_SEQLIST.SSLSEQNAME,
         LR_SEQLIST.SSLPREFIX,
         LR_SEQLIST.SSLWIDTH,
         LR_SEQLIST.SSLSTARTNO
    FROM SYS_SEQLIST
   WHERE UPPER(SSLTBLNAME) = UPPER(AS_TAB_NAME);

  IF TRIM(LR_SEQLIST.SSLPREFIX) IS NULL THEN
    PRELEN := 0;
  ELSE
    PRELEN := LENGTH(TRIM(LR_SEQLIST.SSLPREFIX));
  END IF;

  --动态SQL取序列的值
  AS_SEQ_NAME   := LR_SEQLIST.SSLSEQNAME;
  LS_CUR_SYNTAX := 'SELECT ' || AS_SEQ_NAME || '.NEXTVAL FROM DUAL';

  -- 按照预定的格式返回序列值
  TEMP_ID    := '000000000000000000000000000000' ||
                TO_CHAR(LR_SEQLIST.SSLSTARTNO);
  LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                     SUBSTR(TEMP_ID,
                            LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH + PRELEN + 1,
                            LR_SEQLIST.SSLWIDTH - PRELEN));
  V_SQL      := 'UPDATE SYS_SEQLIST A SET A.SSLSTARTNO=' || (LS_SEQ_NUM + 1) ||' WHERE A.SSLSEQNAME = UPPER(''' || AS_SEQ_NAME || ''')';
  EXECUTE IMMEDIATE V_SQL;
  COMMIT;

  RETURN(LS_SEQ_NUM);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    LS_SEQ_NUM := 'SEQ NOT EXIST!';
    RETURN LS_SEQ_NUM;
  WHEN OTHERS THEN
    BEGIN
      -- 如果序列不存在，则按SEQ LIST数据表中的定义动态生成序列
      LS_CUR_SYNTAX := 'CREATE SEQUENCE ' || AS_SEQ_NAME ||
                       ' MINVALUE 1
                            MAXVALUE 9999999999999999999999999999 START WITH ' ||
                       TO_CHAR(LR_SEQLIST.SSLSTARTNO + 1);
      EXECUTE IMMEDIATE (LS_CUR_SYNTAX);
      LN_SEQ_NUM := LR_SEQLIST.SSLSTARTNO;

      -- 按照预定的格式返回序列的初始值
      TEMP_ID    := '000000000000000000000000000000' || TO_CHAR(LN_SEQ_NUM);
      LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                         SUBSTR(TEMP_ID,
                                LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH +
                                PRELEN + 1,
                                LR_SEQLIST.SSLWIDTH - PRELEN));
      RETURN LS_SEQ_NUM;
    EXCEPTION
      WHEN OTHERS THEN
        LS_SEQ_NUM := 'SEQ ERROR!';
        RETURN LS_SEQ_NUM;
    END;
END;
/

prompt
prompt Creating function FGET_TZDJ
prompt ===========================
prompt
CREATE OR REPLACE FUNCTION FGET_TZDJ(P_MIID IN VARCHAR2,
                                      P_PIID IN VARCHAR2) RETURN NUMBER AS
  V_COUNT   NUMBER(10);
  P_PFPRICE NUMBER(12, 2);
BEGIN
  --是否调整费用项目单价
  SELECT COUNT(PALMID)
    INTO V_COUNT
    FROM PRICEADJUSTLIST T
   WHERE T.PALMID = P_MIID
     AND T.PALTACTIC = '09'
     and  nvl(T.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
     and  nvl(T.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
     AND T.PALPIID = P_PIID
     AND PALSTATUS = 'Y';
  IF V_COUNT < 1 THEN
    P_PFPRICE := 0;
  END IF;
  IF V_COUNT >= 1 THEN
    SELECT (CASE
             WHEN T2.PDDJ + T3.PALWAY * T3.PALVALUE  >=0 THEN
              T3.PALWAY * T3.PALVALUE
             ELSE
              T3.PALWAY * T2.PDDJ
           END)
      INTO P_PFPRICE
      FROM METERINFO T1, PRICEDETAIL T2, PRICEADJUSTLIST T3
     WHERE T2.PDPFID = T1.MIPFID
       AND T1.MIID = P_MIID
       AND T1.MIID = T3.PALMID
       AND T2.PDPIID = T3.PALPIID
      and  nvl(T3.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
       and  nvl(T3.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
        AND T2.PDPIID = P_PIID;
  END IF;

  RETURN P_PFPRICE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FGET调整单价
prompt ==========================
prompt
CREATE OR REPLACE FUNCTION "FGET调整单价"(P_MIID IN VARCHAR2,
                                      P_PIID IN VARCHAR2) RETURN NUMBER AS
  V_COUNT   NUMBER(10);
  P_PFPRICE NUMBER(12, 2);
BEGIN
  --是否调整费用项目单价
  SELECT COUNT(PALMID)
    INTO V_COUNT
    FROM PRICEADJUSTLIST T
   WHERE T.PALMID = P_MIID
     AND T.PALTACTIC = '09'
     and  nvl(T.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
     and  nvl(T.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
     AND T.PALPIID = P_PIID
     AND PALSTATUS = 'Y';
  IF V_COUNT < 1 THEN
    P_PFPRICE := 0;
  END IF;
  IF V_COUNT >= 1 THEN
    SELECT (CASE
             WHEN T2.PDDJ + T3.PALWAY * T3.PALVALUE  >=0 THEN
              T3.PALWAY * T3.PALVALUE
             ELSE
              T3.PALWAY * T2.PDDJ
           END)
      INTO P_PFPRICE
      FROM METERINFO T1, PRICEDETAIL T2, PRICEADJUSTLIST T3
     WHERE T2.PDPFID = T1.MIPFID
       AND T1.MIID = P_MIID
       AND T1.MIID = T3.PALMID
       AND T2.PDPIID = T3.PALPIID
      and  nvl(T3.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
       and  nvl(T3.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
        AND T2.PDPIID = P_PIID;
  END IF;

  RETURN P_PFPRICE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FPARA
prompt =======================
prompt
CREATE OR REPLACE FUNCTION "FPARA" (P_SMPID IN VARCHAR2,P_SMPPID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(4000);
BEGIN
 SELECT SMPPVALUE
 INTO LRET
 FROM SYSMANAPARA
 WHERE SMPID = P_SMPID AND SMPPID = P_SMPPID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

prompt
prompt Creating function MD5
prompt =====================
prompt
CREATE OR REPLACE FUNCTION "MD5" (input_string VARCHAR2) return varchar2
IS
raw_input RAW(128) := UTL_RAW.CAST_TO_RAW(input_string);
decrypted_raw RAW(2048);
error_in_input_buffer_length EXCEPTION;
BEGIN
sys.dbms_obfuscation_toolkit.MD5(input => raw_input, checksum => decrypted_raw);
return lower(rawtohex(decrypted_raw));
END;
/

prompt
prompt Creating procedure LIN
prompt ======================
prompt
CREATE OR REPLACE PROCEDURE LIN(V_DATE IN VARCHAR2, V_CODE IN VARCHAR2) AS
  O_STATE VARCHAR2(10);
  O_DATE  VARCHAR2(10);
  O_CODE  VARCHAR2(10);
BEGIN
  O_STATE := '0';
  O_DATE  := V_DATE;
  O_CODE  := V_CODE;
  IF O_CODE IS NULL THEN
    FOR I IN (SELECT DEPT_CODE
                FROM SYS_DEPT
               WHERE PARENT_ID = '2'
               ORDER BY DEPT_ID) LOOP
      INSERT INTO BS_CBJH_TEMP
        SELECT A.CIID,
               B.MIID,
               B.MISMFID,
               B.MIRORDER,
               MISTID,
               MIPID,
               MICLASS,
               MIFLAG,
               MIRECDATE,
               MIRCODE,
               MDMODEL,
               MIPRIFLAG,
               BFBATCH,
               BFRPER,
               B.MISAFID,
               MIIFCHK,
               MDCALIBER,
               MISIDE,
               B.MISTATUS,
               D.BFNRMONTH,
               B.MIBFID,
               B.MIRECSL,
               B.MIENEED
          FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
         WHERE A.CIID = B.MICODE
           AND B.MIID = S.MDID
           AND B.MISMFID = D.BFSMFID
           AND B.MIBFID = D.BFID
           AND B.MISMFID = I.DEPT_CODE
           AND A.CISTATUS = '1';
      --AND D.BFNRMONTH = TO_CHAR(O_DATE, 'YYYY.MM');
      COMMIT;
      IF O_STATE = '0' THEN
        FOR B IN (SELECT BFID
                    FROM BS_BOOKFRAME A
                   WHERE A.BFSTATUS = 'Y'
                     AND A.BFSMFID = I.DEPT_CODE
                     AND BFNRMONTH = O_DATE) LOOP
          IF B.BFID IS NOT NULL THEN
            BEGIN
              INSERT INTO LINB
                (SELECT SYSDATE,
                        I.DEPT_CODE,
                        B.BFID,
                        (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                   FROM DUAL);
              PG_RAEDPLAN.CREATECB2(I.DEPT_CODE, O_DATE, B.BFID, O_STATE);
              COMMIT;
            END;
          END IF;
        END LOOP;
      END IF;
      EXECUTE IMMEDIATE 'TRUNCATE TABLE BS_CBJH_TEMP';
    END LOOP;
  ELSE
    INSERT INTO BS_CBJH_TEMP
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             D.BFNRMONTH,
             B.MIBFID,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = O_CODE;
    COMMIT;
    IF O_STATE = '0' THEN
      FOR B IN (SELECT BFID
                  FROM BS_BOOKFRAME A
                 WHERE A.BFSTATUS = 'Y'
                   AND A.BFSMFID = O_CODE
                   AND BFNRMONTH = O_DATE) LOOP
        IF B.BFID IS NOT NULL THEN
          BEGIN
            INSERT INTO LINB
              (SELECT SYSDATE,
                      O_CODE,
                      B.BFID,
                      (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                 FROM DUAL);
            PG_RAEDPLAN.CREATECB(O_CODE, O_DATE, B.BFID, O_STATE);
            COMMIT;
          END;
        END IF;
      END LOOP;
    END IF;
  END IF;
END;
/

prompt
prompt Creating procedure PROC_DELETEZONGBIAO
prompt ======================================
prompt
create or replace procedure proc_deletezongbiao(
	v_miids in varchar,
	u_result out number(20)
)
as
begin
	--删总表

	--删分表
END
/

prompt
prompt Creating procedure PROC_INSERTMETER
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE PROC_INSERTMETER(U_MDNO1        IN VARCHAR, --开始水表号
                                             U_MDNO2        IN VARCHAR, --结束水表号
                                             U_STOREROOMID  IN VARCHAR, --库房编号
                                             U_MDSTORE      IN VARCHAR, --库存位置
                                             U_QFH          IN VARCHAR, --铅封号
                                             U_MDCALIBER    IN NUMBER, --表口径
                                             U_MDBRAND      IN VARCHAR2, --表厂家
                                             U_MDMODEL      IN VARCHAR2, --计量方式
                                             U_MDSTATUS     IN VARCHAR2, --表状态
                                             U_MDSTATUSDATE IN DATE, --表状态发生时间
                                             U_MDCYCCHKDATE IN DATE, --周检起算日
                                             U_RKBATCH      IN VARCHAR2, --入库批次
                                             U_RKDNO        IN VARCHAR2, --入库单号
                                             U_MDSTOCKDATE  IN DATE, --表状态发生时间
                                             U_RKMAN        IN VARCHAR2, --入库人员
                                             U_RETURN       OUT VARCHAR2, --返回重复编号
                                             U_RESULT       OUT NUMBER) IS  --返回执行状态或数量
  V_SL     VARCHAR2(100);
  V_COUNT  VARCHAR2(100);
BEGIN
  V_SL     := U_MDNO1;
  U_RETURN := '';
  WHILE U_MDNO2 >= V_SL LOOP
    SELECT COUNT(*) INTO V_COUNT FROM BS_METERDOC WHERE MDNO = V_SL;
    IF V_COUNT <> 0 THEN
      U_RETURN := U_RETURN || V_SL || ',';
    END IF;
    V_SL     := V_SL + 1;
  END LOOP;
  V_SL     := U_MDNO1;
  IF U_RETURN IS NULL THEN
    WHILE U_MDNO2 >= V_SL LOOP
      INSERT INTO BS_METERDOC
        (ID,
         MDNO,
         STOREROOMID,
         QFH,
         MDCALIBER,
         MDBRAND,
         MDMODEL,
         MDSTATUS,
         MDSTATUSDATE,
         MDCYCCHKDATE,
         RKBATCH,
         RKDNO,
         MDSTOCKDATE,
         RKMAN,
         MDSTORE)
      VALUES
        (SEQMESTERDOCID.NEXTVAL,
         V_SL,
         U_STOREROOMID,
         U_QFH,
         U_MDCALIBER,
         U_MDBRAND,
         U_MDMODEL,
         U_MDSTATUS,
         U_MDSTATUSDATE,
         U_MDCYCCHKDATE,
         U_RKBATCH,
         U_RKDNO,
         U_MDSTOCKDATE,
         U_RKMAN,
         U_MDSTORE);
      V_SL     := V_SL + 1;
      U_RESULT := TO_NUMBER(U_MDNO2 - U_MDNO1 + 1);
    END LOOP;
    COMMIT;
  ELSE
    U_RESULT := '-1';
  END IF;
  IF LENGTH(U_RETURN)<>0 THEN
    U_RETURN := SUBSTR(U_RETURN,1,LENGTH(U_RETURN)-1);
    END IF;
END;
/

prompt
prompt Creating procedure PROC_JZ
prompt ==========================
prompt
CREATE OR REPLACE PROCEDURE PROC_JZ(u_reno IN VARCHAR) is

  v_ciid varchar2(10); --ciid
  --v_s int;
  --v_y varchar2(4);
  VN_ROWS NUMBER; --行数

BEGIN
  --插入bs_custinfo
  select r.ciid into v_ciid from request_jzgl r where r.reno = u_reno;
  select count(1) into VN_ROWS from bs_custinfo where ciid = v_ciid;
  IF VN_ROWS = 0 THEN
    insert into bs_custinfo
      (ciid, ciname)
      select r.ciid, r.ciname from request_jzgl r where r.reno = u_reno;
    --VN_ROWS := SQL%ROWCOUNT;
    --dbms_output.Put_lin('更新了' || to_char(VN_ROWS) ||'条记录');
  else
    dbms_output.Put_line('用户已经存在！');
    return;
  END IF;
  --插入bs_meterinfo
  insert into bs_meterinfo
    (miid, miadr)
    select r.miid, r.miadr from request_jzgl r where r.reno = u_reno;
  --commit;
END;
/

prompt
prompt Creating procedure PROC_METERCHANAGE
prompt ====================================
prompt
create or replace procedure PROC_meterChanage(
	v_ciid1 in varchar,
	v_ciid2 in varchar,
	v_miids in varchar,
	u_result out number(20)
)
as
begin
	--不合户 更新户表信息 ，水表余额累加 直接生成应收帐
	--update BS_METERINFO set micode=v_ciid1 where miid in v_miids

	---合户 合并余额 销户
END
/

prompt
prompt Creating procedure PROC_METERREAD_BATCH_MAKE
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE "PROC_METERREAD_BATCH_MAKE" (aa IN VARCHAR2, bb OUT INTEGER)
AS
BEGIN
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');

  --1 先根据原有抄表计划算费，生成应收账（未算过费的抄表记录）

  --2 根据表册（bookframe）筛选出当前月的表册号，对应此表册号的所有户表记录(meterinfo)


  NULL;
END;
/

prompt
prompt Creating procedure PROC_SPLIT_REQUEST_JZGL
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE "PROC_SPLIT_REQUEST_JZGL" (par_reno IN VARCHAR,res OUT VARCHAR)
AS
flagc NUMBER;
flagm NUMBER;
v_ciid VARCHAR2(10);
v_miid VARCHAR2(10);
BEGIN
select r.ciid,r.miid into v_ciid,v_miid from request_jzgl r where r.reno = par_reno;
select count(1) into flagc from BS_CUSTINFO c where c.CIID=v_ciid;
select count(1) into flagm from BS_METERINFO m where m.MIID=v_miid;
if flagc=0 then
insert into bs_custinfo (ciid,CISMFID,CINAME,CIADR,CISTATUS,CITEL1,CIMTEL,CICONNECTPER,CIIFSMS,MICHARGETYPE,CIUSENUM,CIAMOUNT,CIIDENTITYLB,CIIDENTITYNO,
                          CIIFINV,CINAME1,CITAXNO,CIBANKNAME,CIBANKNO,CIADR1,CITEL4,CIDBBS,CIWXNO,CICQNO)

        select r.ciid,r.RESMFID,r.CINAME,r.CIADR,r.CISTATUS,r.CITEL1,r.CIMTEL,r.CICONNECTPER,r.CIIFSMS,r.MICHARGETYPE,r.CIUSENUM,r.CIAMOUNT,r.CIIDENTITYLB,r.CIIDENTITYNO,
      r.CIIFINV,r.CINAME1,r.CITAXNO,r.CIBANKNAME,r.CIBANKNO,r.CIADR1,r.CITEL4,r.REDBBS,r.CIWXNO,r.CICQNO from request_jzgl r
where r.reno = par_reno;
end if;
if flagm=0 then
insert into bs_meterinfo (miid,MISTATUS,MIADR,MISIDE,DQSFH,DQGFH,SJSJ,MISTID,MIINSCODE,MIINSDATE,MIRTID,MIPFID,MIPID,MICLASS,
             MICODE,MILH,MIDYH,MIMPH,MIXQM,MIJD,MIYL13,MIBFID,MIRORDER,MICARDNO)
             select r.miid,r.MISTATUS,r.MIADR,r.MISIDE,r.DQSFH,r.DQGFH,r.SJDATE,r.MISTID,r.MIINSCODE,r.MIINSDATE,r.MIRTID,r.MIPFID,r.MIPID,r.MICLASS,
             r.CIID,r.MILH,r.MIDYH,r.MIMPH,r.MIXQM,r.MIJD,r.MIYL13,r.MIBFID,r.MIRORDER,r.MICARDNO from request_jzgl r
where r.reno = par_reno;
end if;
res := sql%rowcount;
commit;
END;
/

prompt
prompt Creating procedure SP_CANCELUSERPROC
prompt ====================================
prompt
CREATE OR REPLACE PROCEDURE SP_CancelUserProc(p_ciid IN VARCHAR,p_miid IN VARCHAR,p_mdno IN VARCHAR)
AS
BEGIN

--销户
update BS_CUSTINFO set CISTATUS='7',CISTATUSDATE=sysdate where ciid=p_ciid;    --销户
update BS_METERDOC set mdstatus= '2',mdstatusdate=sysdate where mdid=p_miid;   --表身码作废
update BS_METERFH_STORE set FHSTATUS='2',MAINDATE=sysdate where BSM=p_mdno;   --封号作废
update BS_METERINFO set MISTATUS='2',MISTATUSDATE=sysdate where miid=p_miid;   --水表作废

commit;

end;
/

prompt
prompt Creating procedure SP_CBPROC
prompt ============================
prompt
CREATE OR REPLACE PROCEDURE SP_CBProc(p_miid IN VARCHAR,p_mdno IN VARCHAR)
AS
BEGIN

--撤表

update BS_METERDOC set mdstatus= '2',mdstatusdate=sysdate  where mdid=p_miid;   --表身码作废
update BS_METERFH_STORE set FHSTATUS='2',MAINDATE=sysdate  where BSM=p_mdno;   --封号作废
update BS_METERINFO set MISTATUS='2',MISTATUSDATE=sysdate  where miid=p_miid;   --水表作废

commit;

end;
/

prompt
prompt Creating procedure SP_METERINFO_MIRORDER
prompt ========================================
prompt
CREATE OR REPLACE PROCEDURE SP_METERINFO_MIRORDER(I_MICODE IN VARCHAR2,O_STATE  OUT VARCHAR2) AS

--更新户表信息中单独表册的抄表次序

BEGIN
  FOR I IN (SELECT ROWNUM RN, MIID
              FROM (SELECT B.MIID
                      FROM BS_CUSTINFO A
                      LEFT JOIN BS_METERINFO B
                        ON A.CIID = B.MICODE
                     WHERE A.CISTATUS IN ('1', '2')
                       AND B.MIBFID = I_MICODE
                     ORDER BY A.CISTATUS)) LOOP
    UPDATE BS_METERINFO T SET T.MIRORDER = I.RN WHERE T.MIID = I.MIID;
  END LOOP;
  COMMIT;
  O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
END;
/

prompt
prompt Creating procedure SP_JZGLAUDIT
prompt ===============================
prompt
CREATE OR REPLACE PROCEDURE SP_JZGLAUDIT(P_WORKID IN VARCHAR2) AS
  --V_CIID  VARCHAR2(50);
  --V_MIID  VARCHAR2(50);
  V_MIRORDER  VARCHAR2(060);
  V_FLAGC     NUMBER;
  V_FLAGM     NUMBER;
	V_CIDBBS    NUMBER;
BEGIN

  FOR JZGL IN (SELECT *
                 FROM REQUEST_JZGL
                WHERE ENABLED = 5
                  AND WORKID = P_WORKID) LOOP
    DBMS_OUTPUT.PUT_LINE(JZGL.RENO);
    SELECT COUNT(1) INTO V_FLAGC FROM BS_CUSTINFO WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGC);
    SELECT COUNT(1) INTO V_FLAGM FROM BS_METERINFO WHERE MIID = JZGL.MIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGM);
    SELECT COUNT(1) INTO V_CIDBBS FROM REQUEST_JZGL WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_CIDBBS);

    -----BS_CUSTINFO
    IF V_FLAGC = 0 THEN
      INSERT INTO BS_CUSTINFO
        (CIMTEL,  --移动电话
         CITEL1,  --电话1
         CICONNECTPER,  --联系人
         CIIFINV,  --是否普票
         CIIFSMS,  --是否提供短信服务
         MICHARGETYPE,  --类型（1=坐收，2=走收,收费方式）
         MISAVING,  --预存款余额
         CIID,  --用户号
         CINAME,  --用户名
         CIADR,  --用户地址
         CISTATUS,  --用户状态【syscuststatus】
         CIIDENTITYLB,  --证件类型
         CIIDENTITYNO,  --证件号码
         CISMFID,  --营销公司
         CINEWDATE,  --立户日期
         CISTATUSDATE,  --状态日期
         CIDBBS,  --是否一户多表
         CIUSENUM,  --户籍人数
         CIAMOUNT,  --户数
         CIPASSWORD)  --用户密码
        SELECT CIMTEL,  --移动电话
               CITEL1,  --电话1
               CICONNECTPER,  --联系人
               CIIFINV,  --是否普票
               CIIFSMS,  --是否提供短信服务
               MICHARGETYPE,  --类型（1=坐收，2=走收,收费方式）
               0,  --预存款余额
               CIID,  --用户号
               CINAME,  --用户名
               CIADR,  --用户地址
               CISTATUS,  --用户状态【syscuststatus】
               CIIDENTITYLB,  --证件类型(1-身份证 2-营业执照  0-无)
               CIIDENTITYNO,  --证件号码
               RESMFID,  --营销公司
               SYSDATE,  --立户日期
               MODIFYDATE,  --修改时间
               CASE WHEN V_CIDBBS='1' THEN 'N' ELSE 'Y' END,  --是否一户多表
               CIUSENUM,  --户籍人数
               CIAMOUNT,  --户数
               '123456'  --用户密码
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERINFO
    IF V_FLAGM = 0 THEN
      INSERT INTO BS_METERINFO
        (MIID,  --水表档案编号
         MIADR,  --表地址
         MICODE,  --用户号
         MISMFID,  --营销公司(SYSMANAFRAME)
         MIBFID,  --表册(bookframe)
         MIRORDER,  --抄表次序
         MIPID,  --上级水表编号
         MICLASS,  --水表级次
         MIRTID,  --抄表方式【sysreadtype】
         MISTID,  --行业分类【metersortframe】
         MIPFID,  --用水性质(priceframe)
         MISTATUS,  --有效状态【sysmeterstatus】
         MISIDE,  --表位【syscharlist】
         MIINSCODE,  --新装起度
         MIINSDATE,  --装表日期
         MILH,  --楼号
         MIDYH,  --单元号
         MIMPH,  --门牌号
         MIXQM,  --小区名
         MIJD,  --街道
         MIYL13,  --街道号
         DQSFH,  --塑封号
         DQGFH,  --钢封号
         MICARDNO,  --卡片图号
         MIRCODE,  --本期读数
         MISEQNO,  --帐卡号（初始化时册号+序号，帐卡号）
         ISALLOWREADING)  --是否允许手工录入开关(0允许，1禁止)
        SELECT MIID,  --水表档案编号
               MIADR,  --表地址
               CIID,  --用户号
               RESMFID,  --营销公司
               MIBFID,  --表册(bookframe)
               MIRORDER,  --抄表次序
               MIPID,  --上级水表编号
               MICLASS,  --水表级次
               MIRTID,  --采集类型（原抄表方式【sysreadtype】）
               MISTID,  --行业分类【metersortframe】
               MIPFID,  --用水性质(priceframe)
               MISTATUS,  --水表状态【sysmeterstatus】
               MISIDE,  --表位【syscharlist】
               MIINSCODE,  --初始指针
               MIINSDATE,  --装表日期
               MILH,  --楼号
               MIDYH,  --单元号
               MIMPH,  --门牌号
               MIXQM,  --小区名
               MIJD,  --街道
               MIYL13,  --街道号
               DQSFH,  --塑封号
               DQGFH,  --钢封号
               MICARDNO,  --卡片图号
               MIINSCODE,  --初始指针
               MIBFID||SORTCODE MISEQNO,  --表册(bookframe)||序号
               '1'  --是否允许手工录入开关(0允许，1禁止)
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERDOC 更新表使用状态及变更日期
    UPDATE BS_METERDOC B
       SET MDID        =
           (SELECT A.MIID
              FROM REQUEST_JZGL A
             WHERE A.MDNO = B.MDNO
               AND A.RENO = JZGL.RENO),
           MDSTATUS     = 1,
           MDSTATUSDATE = SYSDATE
     WHERE EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.MDNO = B.MDNO
               AND C.RENO = JZGL.RENO);

    -----BS_METERFH_STORE 更新表身码及状态
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '1'
               AND A.DQSFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '1'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '2'
               AND A.DQGFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '2'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);

  END LOOP;
  V_MIRORDER := '0';
  COMMIT;
  IF V_MIRORDER ='0' THEN
    FOR I IN (SELECT MIBFID FROM REQUEST_JZGL WHERE ENABLED = 5 AND WORKID = P_WORKID) LOOP
    SP_METERINFO_MIRORDER(I.MIBFID,V_MIRORDER);
    END LOOP;
    END IF ;

END;
/

prompt
prompt Creating procedure SP_MRSLCHECK_HRB
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2,
                           P_MRSL      IN NUMBER,
                           O_SUBCOMMIT OUT VARCHAR2) AS
  V_TYPE        VARCHAR2(10);
  V_SCALE_H     NUMBER(10);
  V_SCALE_L     NUMBER(10);
  V_USE_H       NUMBER(10);
  V_USE_L       NUMBER(10);
 -- V_TOTAL_H     NUMBER(10);
  V_TOTAL_L     NUMBER(10);
  V_PFID        VARCHAR2(10); --用水类别
  V_THREEMONAVG NUMBER(10);
BEGIN
  O_SUBCOMMIT := 'Y';
  --获得该用户前三月均量
  SELECT MRTHREESL INTO V_THREEMONAVG FROM BS_METERREAD WHERE MRMID = P_MRMID;
  --获得该用户的用水类别
  SELECT MIPFID INTO V_PFID FROM BS_METERINFO WHERE MIID = P_MRMID;
  begin
    --查出该用水类别的波动规则
    SELECT USETYPE, SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
      INTO V_TYPE,
           V_SCALE_H, --超上限比例
           V_SCALE_L, --超下限比例
           V_USE_H, --超上限相对用量
           V_USE_L, --超下限相对用量
           V_TOTAL_H, --超上限绝对用量
           V_TOTAL_L --超下限绝对用量
      FROM CHK_METERREAD
     WHERE USETYPE = V_PFID;
   exception
      when others then
           V_TYPE:='';
           V_SCALE_H:=0; --超上限比例
           V_SCALE_L:=0; --超下限比例
           V_USE_H:=0; --超上限相对用量
           V_USE_L:=0; --超下限相对用量
           V_TOTAL_H:=0; --超上限绝对用量
           V_TOTAL_L:=0; --超下限绝对用量
  end ;
  IF P_MRSL IS NOT NULL THEN

    --如果绝对用量 不为空
    IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
         P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --如果相对用量 限制不为空
    IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG + V_USE_H OR
         P_MRSL < V_THREEMONAVG - V_USE_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --如果相对用量 限制不为空
    IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
      IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

  END IF;

END;
/

prompt
prompt Creating procedure SP_UPDATEYHZT
prompt ================================
prompt
CREATE OR REPLACE PROCEDURE SP_UpdateYHZT(P_WORKID IN VARCHAR2)
AS
  v_ciid        VARCHAR2(50);
	v_miid        VARCHAR2(50);
	v_flagc NUMBER;
	v_flagm NUMBER;
BEGIN

for yhzt in (select * from request_yhzt where enabled=5 and workid= P_WORKID) loop
		update bs_custinfo set cistatus=1,cistatusdate=sysdate where ciid=yhzt.ciid;
		update bs_meterinfo set mistatus=1,mistatusdate=sysdate where miid=yhzt.ciid and micode=yhzt.ciid;
end loop;

commit;

end;
/

prompt
prompt Creating procedure TEST
prompt =======================
prompt
create or replace procedure test is
       p_mrid     varchar2(20);
       p_caltype  varchar2(10);
       o_mrrecje01 number;
       o_mrrecje02 number;
       o_mrrecje03 number;
       o_mrrecje04 number;
       err_log     varchar(100);
begin
  p_mrid := '2372463611';
  p_caltype := '01';
  for i in 1 .. 1000 loop
      pg_cb_cost.calculatebf(p_mrid,p_caltype,o_mrrecje01,o_mrrecje02,o_mrrecje03,o_mrrecje04,err_log);
  end loop;
end test;
/

prompt
prompt Creating package body PG_CB_COST
prompt ================================
prompt
create or replace package body pg_cb_cost is
  callogtxt varchar2(20000);
  最低算费水量        number(10);
  总表截量            char(1);
  是否审批算费        char(1);
  分账操作            char(1);
  算费时预存自动销账  char(1);
  v_smtifcharge1      char(1); --是否计费 1 普表

  procedure wlog(p_txt in varchar2) is
  begin
    callogtxt := callogtxt || chr(10) || to_char(sysdate, 'mm-dd hh24:mi:ss >> ') || p_txt;
  end;

  --外部调用，自动算费
  procedure autosubmit is
  begin
    for i in (select mrbfid from bs_meterread
               where mrreadok = 'Y' and mrifrec = 'N'
               group by mrsmfid, mrbfid) loop
      submit(i.mrbfid , callogtxt);
    end loop;
  exception
    when others then raise;
  end;

  --计划内抄表提交算费
  procedure submit(p_mrbfids in varchar2, log out varchar2) is
    cursor c_mr(vbfid in varchar2) is
      select mr.mrid
        from bs_meterread mr
             left join bs_meterinfo mi on mr.mrmid = mi.miid
             left join bs_custinfo ci on ci.ciid = mr.mrccode
       where ((mr.mrdatasource in ('1','5','6','7','9') and  (ci.reflag <> 'Y' or ci.reflag is null)) or (mr.mrdatasource not in ('1','5','6','7','9') and ci.reflag = 'Y')) --有审核状态的工单按工单状态算费
         and mr.mrbfid in (select regexp_substr(vbfid, '[^,]+', 1, level) mrbfid from dual connect by level <= length(vbfid) - length(replace(vbfid, ',', '')) + 1)
         --and bs_meterinfo.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费
         and mr.mrifrec = 'N' --是否已计费
         and mr.mrsl >= 0
       order by miclass desc,(case when mipriflag = 'Y' and miid <> mipid then 1 else 2 end) asc;
     vmrid bs_meterread.mrid%type;
     v_mrrecje01 bs_meterread.mrrecje01%type;
     v_mrrecje02 bs_meterread.mrrecje02%type;
     v_mrrecje03 bs_meterread.mrrecje03%type;
     v_mrrecje04 bs_meterread.mrrecje04%type;
     v_mrsumje   number;
  begin
    callogtxt := null;
    wlog('正在算费表册号：' || p_mrbfids || ' ...');
    open c_mr(p_mrbfids);
    loop
      fetch c_mr into vmrid;
      exit when c_mr%notfound or c_mr%notfound is null;
      --单条抄表记录处理
      begin
        calculatebf(vmrid, '02',v_mrrecje01, v_mrrecje02, v_mrrecje03, v_mrrecje04, v_mrsumje, log);
        wlog('抄表流水：'||vmrid || ' 算费完成'|| ' ' || v_mrrecje01 || ' ' ||  v_mrrecje02 || ' ' ||  v_mrrecje03 || ' ' ||  v_mrrecje04 );
        commit;
      exception
        when others then rollback; wlog('抄表记录' || vmrid || '算费失败，已被忽略');
      end;
    end loop;
    close c_mr;
    wlog('算费过程处理完毕：'||p_mrbfids);
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      if c_mr%isopen then close c_mr; end if;
      --raise_application_error(errcode, sqlerrm);
  end;

  --算费前虚拟算费，供月抄表明细调用
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype   in  varchar2,    -- 01 虚拟算费; 02 正式算费
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             o_mrsumje   out number,
             err_log out varchar2) is
    mr bs_meterread%rowtype;
    v_reflag varchar(10);          --工单状态(Y:存在审批过程中的工单；N:不存在)
  begin
    select * into mr from bs_meterread where mrid = p_mrid;
    select reflag into v_reflag from bs_custinfo where ciid = mr.mrccode;

    if mr.mrdatasource in ('1','5','6','7','9') and v_reflag = 'Y' then
      wlog('存在审批过程中的工单，无法算费');
      err_log := callogtxt;
      return;
    end if;

    if mr.mrifrec = 'N' then
      --重置水表信息
      --dbms_output.put_line(systimestamp ||'：重置水表信息开始');
      if p_caltype = '01' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'N',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      elsif p_caltype = '02' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'Y',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      else
        wlog('请正确输入算费类型：01 虚拟算费，02 正式算费');
        err_log := callogtxt;
        return;
      end if;

      --重置抄表库
      update bs_meterread
      set    mrrecje01 = null,
             mrrecje02 = null,
             mrrecje03 = null,
             mrrecje04 = null
      where  mrid = p_mrid and mrifrec = 'N';

      --删除应收账务信息
      delete from bs_recdetail where rdid in (select rlid from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y');
      delete from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y';

      commit;
      calculate(p_mrid);

      --更改 用户 有审核状态的工单 状态
      if v_reflag = 'Y' then
        update bs_custinfo set reflag = 'N' where ciid = mr.mrccode;
      end if;

      commit;
      select mrrecje01,mrrecje02,mrrecje03,mrrecje04 ,nvl(mrrecje01,0) + nvl(mrrecje02,0) + nvl(mrrecje03,0) + nvl(mrrecje04,0)
             into o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje
       from bs_meterread
      where mrid = p_mrid;
      err_log := callogtxt;
    else
      wlog('当前抄表计划流水号已正式算费，无法重算');
      err_log := callogtxt;
    end if;
  exception
    when others then
      rollback;
      wlog('无效的抄表计划流水号：'|| p_mrid );
      err_log := callogtxt;
      --raise_application_error(errcode, sqlerrm);
  end;

  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type) is
   cursor c_mr is
      select * from bs_meterread
       where mrid = p_mrid
         and mrifrec = 'N'   --已计费(Y-是 N-否)
         and mrsl >= 0
         for update nowait;
   cursor c_mr_child(p_mpid in varchar2, p_month in varchar2) is
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl --校验水量
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipid = p_mpid
         and mrmonth = p_month
      union all
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mipid = p_mpid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N';
    --一户多表用户信息zhb
    cursor c_mr_pr(p_mipriid in varchar2) is
      select miid
        from bs_meterinfo, bs_meterread
       where mrmid(+) = miid
         and mipid = p_mipriid
       order by miid;
    --合收子表抄表记录
    cursor c_mr_pri(p_primcode in varchar2) is
      select mrsl, mrifrec, mrmid
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipriflag = 'Y'
         and mipid = p_primcode
         and micode <> p_primcode;
    --取合收表信息
    cursor c_mi(p_mid in varchar2) is
      select * from bs_meterinfo where miid = p_mid;
    --总表有周期换表、故障换表的余量抓取
    cursor c_mi_class(p_mrmid in varchar2, p_month in varchar2) is
      select nvl(decode(nvl(sum(mraddsl), 0), 0, sum(mrsl), sum(mraddsl)),0)
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mrmid = p_mrmid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N' --未冲正
         and rlsl > 0;
    mr         bs_meterread%rowtype;
    mrchild    bs_meterread%rowtype;
    mi         bs_meterinfo%rowtype;
    mrl        bs_meterread%rowtype;
    mil        bs_meterinfo%rowtype;
    mid        bs_meterinfo.miid%type;
    v_tempsl   number;
    v_count    number;
    v_row      number;
    v_sumnum      number; --子表数
    v_readnum     number; --抄见子表数
    v_recnum      number; --算费子表数
    v_miclass     number;
    v_mipid       varchar2(10);
    v_mrmcode     varchar2(10);
    v_mdhis_addsl bs_meterread_his.mraddsl%type;
    v_pd_addsl    bs_meterread_his.mraddsl%type;
    v_mrcode_tmp number;
    v_rec_cal varchar2(1);
  begin
    open c_mr;
    fetch c_mr into mr;
    if c_mr%notfound or c_mr%notfound is null then
      wlog('无效的抄表计划流水号：'|| p_mrid);
      raise_application_error(errcode, '无效的抄表计划流水号：'||p_mrid);
    end if;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    if mr.mrsl < 最低算费水量 and mr.mrdatasource in ('1', '5', '9', '2') /*and (mr.mrrpid = '00' or mr.mrrpid is null) --计件类型*/ then
      wlog('抄表水量小于最低算费水量，不需要算费');
      raise_application_error(errcode, '抄表水量小于最低算费水量，不需要算费');
    end if;

   --水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    close c_mi;


    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    if mi.miyl1 = 'Y' then
       wlog('此水表等针状态，无法算费！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表等针状态，无法算费！');
    end if;
    /*
    if mi.mistatus = '24' and mr.mrdatasource <> 'M' then
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      wlog('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    end if;
    if mi.mistatus = '35' and mr.mrdatasource <> 'L' then
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      wlog('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || mr.mrmid);
      raise_application_error(errcode,'此水表编号[' || mr.mrmid ||']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    end if;
    if mi.mistatus = '36' then
      --预存冲正中
      wlog('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;
    if mi.mistatus = '39' then
      --预存冲正中
      wlog('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;
    if mi.mistatus = '19' then
      --销户中
      wlog('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;
    */

    --反向算费，计算负向指针先把指针互换
    if mr.mrscode > mr.mrecode then
      v_mrcode_tmp := mr.mrscode;
      mr.mrscode := mr.mrecode;
      mr.mrecode := v_mrcode_tmp;
      mi.mircode := mr.mrscode;
      v_rec_cal := 'Y';        --反向算费标志
    end if;

    --总表收免  真实水量等于抄表水量 减去 总表收免水量最大值
    if mi.miyl2 = '1' then
       mr.mrrecsl := mr.mrsl - nvl(mi.miyl7,0);
    else
       mr.mrrecsl := mr.mrsl; --本期水量
    end if;

    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    if 总表截量 = 'Y' then
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
      --STEP1 检查是否总表
      select miclass, mipid into v_miclass, v_mipid from bs_meterinfo where micode = mr.mrccode;
      if v_miclass = 2 then
        --是总表
        v_mrmcode := mr.mrmid; --赋值为总表号
        --step2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        select count(*),
               sum(decode(nvl(mrreadok, 'N'), 'Y', 1, 0)),
               sum(decode(nvl(mrifrec, 'N'), 'Y', 1, 0))
          into v_sumnum, v_readnum, v_recnum
          from bs_meterinfo, bs_meterread
         where miid = mrmid(+)
           and mipid = v_mrmcode
           and miclass = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        if v_sumnum > v_readnum then
          wlog('抄表记录' || mr.mrid || '总分表中包含未抄子表，暂停产生费用');
          raise_application_error(errcode,'总分表中包含未抄子表，暂停产生费用');
        end if;
        --总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        if v_sumnum > v_recnum then
          wlog('抄表记录' || mr.mrid || '收费总表发现子表未计费，暂停产生费用');
          raise_application_error(errcode, '收费总表子表未计费，暂停产生费用');
        end if;
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
        open c_mi_class(v_mrmcode, mr.mrmonth);
        fetch c_mi_class
          into v_mdhis_addsl; --故障换表余量
        if c_mi_class%notfound or c_mi_class%notfound is null then
          v_mdhis_addsl := 0;
        end if;
        close c_mi_class;

        v_pd_addsl := v_mdhis_addsl; --判断水量=故障换表余量

        open c_mr_child(v_mrmcode, mr.mrmonth);
        loop
          fetch c_mr_child
            into mrchild.mrsl,
                 mrchild.mrifrec,
                 mrchild.mrreadok,
                 mrchild.mrcarrysl;
          exit when c_mr_child%notfound or c_mr_child%notfound is null;
          --判断的水量 v_pd_addsl 实际为故障换表水量
          v_pd_addsl := v_pd_addsl - mrchild.mrsl - mrchild.mrcarrysl;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量
        end loop;
        close c_mr_child;

        if v_pd_addsl < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          mr.mrrecsl := mr.mrrecsl + v_mdhis_addsl;
          --step3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          open c_mr_child(v_mrmcode, mr.mrmonth);
          loop
            fetch c_mr_child
              into mrchild.mrsl,
                   mrchild.mrifrec,
                   mrchild.mrreadok,
                   mrchild.mrcarrysl;
            exit when c_mr_child%notfound or c_mr_child%notfound is null;
            --抵消水量
            mr.mrrecsl := mr.mrrecsl - mrchild.mrsl - mrchild.mrcarrysl;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量
          end loop;
          close c_mr_child;
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          mr.mrrecsl := mr.mrrecsl;
        end if;
        --如果收费总表水量小于子表水量，暂停产生费用
        if mr.mrrecsl < 0 then
          --如果总表截量小于0，则总表停算费用
          wlog('抄表记录' || mr.mrid || '收费总表水量小于子表水量，暂停产生费用');
          raise_application_error(errcode, '收费总表水量小于子表水量，暂停产生费用');
        end if;
      end if;
    end if;
    -----------------------------------------------------------------------------
    --判断一表多户 分表按比例分摊水量
    if /*mi.micolumn9 = 'Y'*/ 1>1 then
      open c_mr_pr(mr.mrmid);
      v_tempsl := mr.mrsl;
      v_row    := 1;
      select count(*)
        into v_count
        from bs_meterinfo
       where mipid = mr.mrmid
             and miifchk <> 'Y'
             and miifcharge <> 'N'
       --order by micolumn6
       ;
      loop
        fetch c_mr_pr
          into mid;
        exit when c_mr_pr%notfound or c_mr_pr%notfound is null;
        mrl := mr;
        select * into mil from bs_meterinfo where miid = mid;
        mrl.mrsmfid := mil.mismfid;
        mrl.mrccode   := mil.micode;
        mrl.mrmid   := mil.miid;
        mrl.mrccode := mil.micode;
        mrl.mrbfid  := mil.mibfid;
        mrl.mrrecsl := trunc(v_tempsl);
        v_tempsl    := v_tempsl - mrl.mrrecsl;
        v_row       := v_row + 1;
        if mrl.mrifrec = 'Y' and --mrl.mrifsubmit = 'Y' and
           mrl.mrifhalt = 'Y' and mil.miifcharge = 'Y' and
           (mil.miifchk <> 'Y' or mil.miifchk is null) and
           v_smtifcharge1 <> 'N'
           then
          --正常算费
          calculate(mrl, '1', '0000.00', v_rec_cal);
        elsif mil.miifcharge = 'Y' or mrl.mrifhalt = 'Y' then
          --计量不计费,将数据记录到费用库
          calculatenp(mrl, '1', '0000.00');
        end if;
      end loop;
      mr.mrifrec   := 'Y';
      mr.mrrecdate := trunc(sysdate);
      if c_mr_pr%isopen then
        close c_mr_pr;
      end if;
    else
      if mr.mrifrec = 'N' and --mr.mrifsubmit = 'Y' and
         mr.mrifhalt = 'N' and
         mi.miifcharge = 'Y' and
         (mil.miifchk <> 'Y' or mil.miifchk is null) and
         v_smtifcharge1 <> 'N'
         then
        --正常算费
        calculate(mr, '1', '0000.00', v_rec_cal);
      elsif mi.miifcharge = 'N' or mr.mrifhalt = 'Y' then
        --计量不计费,将数据记录到费用库
        calculatenp(mr, '1', '0000.00');
        mr.mrifrec := 'N';
      end if;
    end if;
    -----------------------------------------------------------------------------


    --更新当前抄表记录
    if 是否审批算费 = 'N' then
      update bs_meterread
         set mrifrec   = mr.mrifrec,
             mrrecdate = mr.mrrecdate,
             mrsl      = mr.mrsl,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    else
      update bs_meterread
         set mrrecdate = mr.mrrecdate,
             mrsl      = mr.mrsl,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    end if;
    close c_mr;
    commit;

      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
  exception
    when others then
      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calculate(mr in out bs_meterread%rowtype,p_trans in char, p_ny in varchar2, p_rec_cal in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    v_pmisaving bs_custinfo.misaving%type;
    rdtab rd_table;
    i     number;
    vrd   bs_recdetail%rowtype;
    cursor c_hs_meter(c_miid varchar2) is select miid from bs_meterinfo where mipid = c_miid;
    v_hs_meter bs_meterinfo%rowtype;
    v_psumrlje bs_reclist.rlje%type;
    v_hs_rlids varchar2(1280); --应收流水
    v_hs_rlje  number(12, 2); --应收金额
    v_hs_znj   number(12, 2); --滞纳金
    v_hs_outje number(12, 2);
    --预存自动抵扣
    v_rlidlist varchar2(4000);
    v_rlid     bs_reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    cursor c_ycdk is
      select rlid,sum(rlje) rlje
        from bs_reclist, bs_meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rlreverseflag = 'N'
         and rlbadflag = 'N' -- 添加呆坏帐过滤条件
         and rlje <> 0
         and rltrans not in ('13', '14', 'U')
         and ((t.mipid = mi.mipid and mi.mipriflag = 'Y') or
             (t.miid = mi.miid and
             (mi.mipriflag = 'N' or mi.mipid is null)))
       group by rlmid, t.miid, t.mipid, rlmonth, rlid, rlsmfid
       order by  rlmonth, rlid, mipid, miid;
    v_retstr varchar2(40);
  begin
    --锁定水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定水表档案
    open c_md(mr.mrmid);
    fetch c_md into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('无效的水表档案' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定用户记录
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('无效的用户编号' || mi.micode);
      raise_application_error(errcode, '无效的用户编号' || mi.micode);
    end if;
    --判断起码是否改变
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L','Z') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;

    delete bs_reclist_temp where rlmrid = mr.mrid;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' then
      --如果是倒表 要判断一下指针的问题
      if mr.mrecode > mr.mrscode then
        raise_application_error(errcode, '该用户' || mi.micode || '是倒表用户,起码应大于止码');
      end if;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if mr.mrecode < mr.mrscode then
           raise_application_error(errcode,'该用户' || mi.micode || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;
    end if;
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := mr.mrmonth;
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --开票标志
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist抄见水量 = mr.抄见水量+mr 校验水量
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      rl.rlje           := 0; --生成帐体后计算,先初始化
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '历史单价' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --记录合收子表串
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '该用户' || mi.micode || '的抄表员不能为空!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --实收流水（与payment.pid对应）
      rl.rlpbatch       := null; --缴费交易批次（与payment.pbatch对应）
      rl.rlsavingqc     := 0; --期初预存（销帐时产生）
      rl.rlsavingbq     := 0; --本期预存发生（销帐时产生）
      rl.rlsavingqm     := 0; --期末预存（销帐时产生）
      rl.rlreverseflag  := 'N'; --  冲正标志（n为正常，y为冲正）
      rl.rlbadflag      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      rl.rlscrrlid      := rl.rlid; --原应收帐流水
      rl.rlscrrltrans   := rl.rltrans; --原应收帐事务
      rl.rlscrrlmonth   := rl.rlmonth; --原应收帐月份
      rl.rlscrrldate    := rl.rldate; --原应收帐日期
      rl.rlifstep       := mr.mrifstep; --是否纳入阶梯,数据来源：追量收费表request_zlsf
      rl.rldatasource   := mr.mrdatasource;--来源(1-手工,5-抄表器,9-手机抄表,K-故障换表,L-周期换表,Z-追量  I-智能表接口，6-视频直读，7-集抄)
      /*
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --算费之前欠费
      end;
      */
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --算费时预存
      end if;
      rl.rlcolumn9       := rl.rlid; --上次应收帐流水
    end if;

    -------------调用算费过程-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------

    if mi.miclass = '2' then
      --总分表
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist抄见水量 = mr.抄见水量+mr 校验水量
    end if;

    rl.rlje := 0;
    for i in rdtab.first .. rdtab.last loop
      rl.rlje := rl.rlje + rdtab(i).rdje;
    end loop;

    if 是否审批算费 = 'N' then
      insert into bs_reclist values rl;
    else
      insert into bs_reclist_temp values rl;
    end if;
    insrd(rdtab);

    --根据负账标志，把金额水量改成负值
    if p_rec_cal = 'Y' then
      mr.mrsl := 0 - mr.mrsl;
      mr.mrrecje01 := 0 - mr.mrrecje01;
      mr.mrrecje02 := 0 - mr.mrrecje02;
      mr.mrrecje03 := 0 - mr.mrrecje03;
      mr.mrrecje04 := 0 - mr.mrrecje04;

      update bs_reclist
         set rlscode = rlecode,
             rlecode = rlscode,
             rlreadsl = 0 - rlreadsl,
             rlsl = 0 - rlsl,
             rlje = 0 - rlje
       where rlmrid = mr.mrid;

      update bs_recdetail
         set rdsl = 0 - rdsl,
             rdje = 0 - rdje
       where rdid = (select rlid from bs_reclist where rlmrid = mr.mrid);
    end if;


    --预存自动扣款
    if 算费时预存自动销账 = 'Y' and 是否审批算费 = 'N' then
      if mi.mipid is not null and mi.mipriflag = 'Y' then
        --总预存
        v_pmisaving := 0;
        select count(*)
          into v_countall
          from bs_meterread
         where mrmid <> mr.mrmid
           and mrifrec <> 'Y'
           and mrmid in
               (select miid from bs_meterinfo where mipid = mi.mipid);
        if v_countall < 1 then
          begin
            select sum(misaving) into v_pmisaving from bs_custinfo where ciid =  mi.micode;
          exception
            when others then v_pmisaving := 0;
          end;
          --总欠费
          v_psumrlje := 0;
          begin
            select sum(rlje)
              into v_psumrlje
              from bs_reclist
             where rlmpid = mi.mipid
               and rlbadflag = 'N'
               and rlreverseflag = 'N'
               and rlpaidflag = 'N';
          exception
            when others then v_psumrlje := 0;
          end;
          if v_pmisaving >= v_psumrlje then
            --合收表
            v_rlidlist := '';
            v_rljes    := 0;
            v_znj      := 0;
            open c_ycdk;
            loop
              fetch c_ycdk
                into v_rlid, v_rlje;
              exit when c_ycdk%notfound or c_ycdk%notfound is null;
              --预存够扣
              if v_pmisaving >= v_rlje + v_znj then
                v_rlidlist  := v_rlidlist || v_rlid || ',';
                v_pmisaving := v_pmisaving - (v_rlje + v_znj);
                v_rljes     := v_rljes + v_rlje;
                v_znjs      := v_znjs + v_znj;
              else
                exit;
              end if;
            end loop;
            close c_ycdk;
            if length(v_rlidlist) > 0 then
              --插入pay_para_tmp 表做合收表销账准备
              delete pay_para_tmp;
              open c_hs_meter(mi.mipid);
              loop
                fetch c_hs_meter
                  into v_hs_meter.miid;
                exit when c_hs_meter%notfound or c_hs_meter%notfound is null;
                v_hs_outje := 0;
                v_hs_rlids := '';
                v_hs_rlje  := 0;
                v_hs_znj   := 0;
                select replace(connstr(rlid), '/', ',') || '|',
                       sum(rlje)
                  into v_hs_rlids, v_hs_rlje
                  from bs_reclist rl
                 where rl.rlmid = v_hs_meter.miid
                   and rl.rlje > 0
                   and rl.rlpaidflag = 'N'
                   and rl.rlreverseflag = 'N'
                   and rl.rlbadflag = 'N';
                if v_hs_rlje > 0 then
                  insert into pay_para_tmp
                  values
                    (v_hs_meter.miid,
                     v_hs_rlids,
                     v_hs_rlje,
                     0,
                     v_hs_znj);
                end if;
              end loop;
              close c_hs_meter;
              v_rlidlist := substr(v_rlidlist,
                                   1,
                                   length(v_rlidlist) - 1);
               pg_paid.poscustforys(
                      p_yhid   => ci.ciid,    --用户编码
                      p_arstr  => v_rlidlist, --欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
                      p_oper   => 1,          --销帐员，柜台缴费时销帐人员与收款员统一
                      p_payway => 'XJ',       --付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
                      p_payment=> 0,          --实收，即为（付款-找零），付款与找零在前台计算和校验
                      p_pid    => v_retstr       --返回交易流水号
                );
            end if;
          end if;
        end if;
      else
        v_rlidlist  := '';
        v_rljes     := 0;
        v_znj       := 0;
        v_pmisaving := ci.misaving;
        open c_ycdk;
        loop
          fetch c_ycdk
            into v_rlid, v_rlje;
          exit when c_ycdk%notfound or c_ycdk%notfound is null;
          --预存够扣
          if v_pmisaving >= v_rlje + v_znj or p_rec_cal = 'Y'then
            v_rlidlist  := v_rlidlist || v_rlid || ',';
            v_pmisaving := v_pmisaving - (v_rlje + v_znj);
            v_rljes     := v_rljes + v_rlje;
            v_znjs      := v_znjs + v_znj;
          else
            exit;
          end if;
        end loop;
        close c_ycdk;
        --单表
        if length(v_rlidlist) > 0 then
          v_rlidlist := substr(v_rlidlist, 1, length(v_rlidlist) - 1);
          pg_paid.poscustforys(
                p_yhid   => ci.ciid,    --用户编码
                p_arstr  => v_rlidlist, --欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
                p_oper   => 1,          --销帐员，柜台缴费时销帐人员与收款员统一
                p_payway => 'XJ',       --付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
                p_payment=> 0,          --实收，即为（付款-找零），付款与找零在前台计算和校验
                p_pid    => v_retstr       --返回交易流水号
          );
        end if;
      end if;
    end if;

    --不重置指针   追量收费工单，补缴收费工单
    if mr.mrifreset = 'N' then
      null;
    else
      update bs_meterinfo
         set mircode     = mr.mrecode,
             mirecdate   = mr.mrrdate,
             mirecsl     = mr.mrsl, --取本期水量（抄量）
             miface      = mr.mrface,
             miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
       where current of c_mi;
    end if;
    close c_mi;
    close c_md;
    close c_ci;
    --反馈应收水量水费到原始抄表记录
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('其他异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

    --自来水单笔算费，只用于记账不计费（哈尔滨）
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    rdtab         rd_table;
    i             number;
    vrd           bs_recdetail%rowtype;
  begin
    --锁定水表记录
    open c_mi(mr.mrmid);
    fetch c_mi
      into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定水表档案
    open c_md(mr.mrmid);
    fetch c_md
      into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('无效的水表档案' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定用户记录
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('无效的用户编号' || mi.micode);
      raise_application_error(errcode, '无效的用户编号' || mi.micode);
    end if;
    delete bs_reclist_temp where rlmrid = mr.mrid;
    --非计费表执行空过程，不抛异常
    --合收子表
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := mr.mrmonth;
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --开票标志
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist抄见水量 = mr.抄见水量+mr 校验水量
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      rl.rlje           := 0; --生成帐体后计算,先初始化
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '历史单价' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --记录合收子表串
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '该用户' || mi.micode || '的抄表员不能为空!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --实收流水（与payment.pid对应）
      rl.rlpbatch       := null; --缴费交易批次（与payment.pbatch对应）
      rl.rlsavingqc     := 0; --期初预存（销帐时产生）
      rl.rlsavingbq     := 0; --本期预存发生（销帐时产生）
      rl.rlsavingqm     := 0; --期末预存（销帐时产生）
      rl.rlreverseflag  := 'N'; --  冲正标志（n为正常，y为冲正）
      rl.rlbadflag      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      rl.rlscrrlid      := rl.rlid; --原应收帐流水
      rl.rlscrrltrans   := rl.rltrans; --原应收帐事务
      rl.rlscrrlmonth   := rl.rlmonth; --原应收帐月份
      rl.rlscrrldate    := rl.rldate; --原应收帐日期
      rl.rlifstep       := mr.mrifstep; --是否纳入阶梯,数据来源：追量收费表request_zlsf
      rl.rldatasource   := mr.mrdatasource;--来源(1-手工,5-抄表器,9-手机抄表,K-故障换表,L-周期换表,Z-追量  I-智能表接口，6-视频直读，7-集抄)
      /*
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --算费之前欠费
      end;
      */
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --算费时预存
      end if;
      rl.rlcolumn9       := rl.rlid; --上次应收帐流水
    end if;

    -------------调用算费过程-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------

    if mi.miclass = '2' then
      --合收表
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist抄见水量 = mr.抄见水量+mr 校验水量
    end if;

    if 是否审批算费 = 'N' then
      insert into bs_reclist values rl;
    else
      insert into bs_reclist_temp values rl;
    end if;
    insrd(rdtab);

    update bs_meterinfo
       set mircode     = mr.mrecode,
           mirecdate   = mr.mrrdate,
           mirecsl     = mr.mrsl, --取本期水量（抄量）
           miface      = mr.mrface,
           miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
     where current of c_mi;
    close c_mi;
    close c_md;
    close c_ci;
    --反馈应收水量水费到原始抄表记录
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('其他异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table) is
    rd       bs_recdetail%rowtype;
  begin
    rd.rdid       := p_rl.rlid; --流水号
    rd.rdpiid     := pd.pdpiid; --费用项目
    rd.rdpfid     := pd.pdpfid; --费率
    rd.rdpscid    := pd.pdpscid; --费率明细方案
    rd.rddj     := 0; --单价
    rd.rdsl     := 0; --水量
    rd.rdje     := 0; --金额
    rd.rdmethod   := pd.pdmethod; --计费方法
    if pd.pdmethod = '01' /*or (pd.pdmethod = '02' and p_rl.rlifstep = 'N' )*/ then
    --case pd.pdmethod
    --  when '01' then
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        begin
          rd.rdclass := 0; --阶梯级别
          rd.rddj  := pd.pddj; --单价
          rd.rdsl  := p_sl; --水量
          rd.rdje := 0; --调整金额
          --计算调整
          rd.rdje   := round(rd.rddj * rd.rdsl, 2); --实收金额
          --插入明细包
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
          --汇总
          p_rl.rlje := p_rl.rlje + rd.rdje;
          p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01' then rd.rdsl else 0 end);
        end;
    elsif pd.pdmethod = '02' then
    --  when '02' then
        --阶梯计费  简单模式阶梯水价
        rd.rdsl    := p_sl;
        begin
          --阶梯计费
          calstep(p_rl,
                  rd.rdsl,
                  pd,
                  rdtab);
        end;
      else raise_application_error(errcode, '不支持的计费方法' || pd.pdmethod);
    --end case;
    end if;
  exception
    when others then
      wlog(p_rl.rlid || '计算费用项目费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table) is
    cursor c_ps is
      select *
        from bs_pricestep
       where pspscid = pd.pdpscid
         and pspfid = pd.pdpfid
         and pspiid = pd.pdpiid
       order by psclass;
    tmpyssl        number;
    tmpsl          number;
    rd             bs_recdetail%rowtype;
    ps             bs_pricestep%rowtype;
    年累计水量     number;
    minfo          bs_meterinfo%rowtype;
    usenum         number; --计费人口数
    v_date         date;
    v_dateold      date;
    v_rljtmk       varchar2(1);
    bk             bs_bookframe%rowtype;
    v_rlscrrlmonth bs_reclist.rlmonth%type;     --原应收账月份
    v_rlmonth      bs_reclist.rlmonth%type;     --账务月份
    v_rljtsrq      bs_reclist.rljtsrq%type;     --本周期阶梯开始日期 ==> 表册阶梯开始月份           v_date
    v_rljtsrqold   bs_reclist.rljtsrq%type;     --本周期阶梯开始日期                                v_date_old
    v_jgyf         number;
    v_jtny         number;
    v_newmk        char(1);
    v_jtqzny       bs_reclist.rljtsrq%type;
    v_betweenny    number;
  begin
    rd.rdid       := p_rl.rlid;
    rd.rdpiid     := pd.pdpiid;
    rd.rdpfid     := pd.pdpfid;
    rd.rdpscid    := pd.pdpscid;
    rd.rdmethod   := pd.pdmethod;
    tmpyssl := p_sl; --阶梯累减应收水量余额
    tmpsl   := p_sl; --阶梯累减实收水量余额
    v_newmk := 'N';
    --取上次算费月份，以及阶梯开始月份
   select nvl(max(rlscrrlmonth), 'a'), nvl(max(rljtsrq), 'a'),nvl(max(rlmonth),'2015.12')
      into v_rlscrrlmonth, v_rljtsrqold,v_rlmonth        --rlscrrlmonth  原应收帐月份   rljtsrq  本周期阶梯开始日期    rlmonth  帐务月份
      from bs_reclist
     where rlmid = p_rl.rlmid
       and rlreverseflag = 'N';
    --第一次算费比进入阶梯

    select * into bk from bs_bookframe where bfid = p_rl.rlbfid;
    --判断数据是否满足收取阶梯的条件
    select mi.* into minfo from bs_meterinfo mi where mi.miid = p_rl.rlmid;
    --取合收表人口最大表的用户数
    select nvl(max(miusenum),0)
      into usenum
      from bs_meterinfo
     where mipid = minfo.mipid;
    if usenum <= 5 then
      usenum := 5;
    end if;
    bk.bfjtsny := nvl(bk.bfjtsny, '01');              --bfjtsny  阶梯开始月
    bk.bfjtsny := to_char(to_number(bk.bfjtsny), 'FM00');
    if substr(p_rl.rlmonth, 6, 2) >= bk.bfjtsny then
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --新阶梯起止
    v_date := add_months(to_date(v_rljtsrq, 'yyyy.mm'), 12);
    if v_rljtsrqold <> 'a' then
      --旧阶梯起止
      v_dateold := add_months(to_date(v_rljtsrqold, 'yyyy.mm'), 12);
    else
      v_dateold := v_date;
    end if;
    --旧阶梯起止不等于新阶梯起止
    if v_dateold <> v_date then

      v_betweenny := months_between(v_date, v_dateold);
      if substr(v_rljtsrq, 1, 4) <> to_char(v_dateold, 'yyyy') then
        if v_rljtsrq < to_char(v_dateold, 'yyyy.mm') then
          if v_rljtsrq = p_rl.rlmonth then
            p_rl.rljtmk  := 'Y';          --rljtmk  不记阶梯注记
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          end if;
        else
          p_rl.rljtmk  := 'Y';
          p_rl.rljtsrq := v_rljtsrq;
        end if;
      else
        if mod(v_betweenny, 12) = 0 then
          --跨年的情况
          if v_betweenny / 12 > 1 then
            p_rl.rljtmk  := 'Y';
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny < 12 then
          if p_rl.rlmonth = v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          elsif p_rl.rlmonth < v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny > 12 then
          if p_rl.rlmonth = v_rljtsrq then
            if substr(p_rl.rlmonth, 1, 4) = substr(v_rlscrrlmonth, 1, 4) then
              p_rl.rljtsrq := v_rljtsrq;
              p_rl.rljtmk  := 'Y';
            else
              p_rl.rljtsrq := v_rljtsrq;
              v_newmk      := 'Y';
              v_jtqzny     := v_rljtsrqold;
            end if;
          else
            if p_rl.rlmonth = v_rljtsrqold then
              p_rl.rljtsrq := to_char(v_dateold, 'yyyy.mm');
              v_jtqzny     := v_rljtsrqold;
            else
              p_rl.rljtsrq := v_rljtsrqold;
              v_jtqzny     := v_rljtsrqold;
            end if;
          end if;
        end if;
      end if;
    else
      if p_rl.rlmonth = v_rljtsrq then
        v_jtqzny := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        v_jtqzny := v_rljtsrq;
      end if;
      p_rl.rljtsrq := v_rljtsrq;

    end if;

    -- 第一次算费不进入阶梯
    -- 2016年1月起（含一月）首次抄表不计入阶梯

    if p_rl.rljtmk = 'Y' or p_rl.rltrans in('14', '21') or v_rlscrrlmonth = 'a' or v_rlmonth <='2015.12' or p_rl.rlifstep = 'N'
      then
      v_rljtmk := 'Y';
    else
      v_rljtmk := 'N';
    end if;

    --没有跨阶梯年月程序处理
    if v_dateold >= to_date(p_rl.rlmonth, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(rdsl), 0)
        into p_rl.rlcolumn12
        from bs_reclist, bs_recdetail,bs_meterinfo
       where rlid = rdid
         and rlmid = miid
         and nvl(rljtmk, 'N') = 'N'
         and (rlifstep <> 'N' or rlifstep is null)
         and rlscrrltrans not in ('14', '21')
         and rdpmdcolumn3 = substr(v_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = '02'
         and rlscrrlmonth <= p_rl.rlmonth
         and micode = minfo.micode;
      rd.rdpmdcolumn3 := substr(v_jtqzny, 1, 4);
      年累计水量      := case when p_rl.rlcolumn12<0 then 0 else to_number(nvl(p_rl.rlcolumn12, 0)) end + p_sl;

      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );
        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                            年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)),ps.psscode)
                          when 年累计水量 >= ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)),ps.psecode - ps.psscode))
                          else
                            0
                        end
                    end
                    ;
        rd.rdje  := rd.rddj * rd.rdsl;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
            rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
          elsif 年累计水量 > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case
                       when rd.rdpiid = '01' then
                        rd.rdsl
                       else
                        0
                     end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;
    else
      --跨年，需要按用水月份比例拆分
      v_jgyf := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'), v_dateold);
      v_jtny := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'),
                               to_date(v_rlscrrlmonth, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;
      if v_jgyf > 12 then
        tmpyssl  := p_sl;
        tmpsl    := p_sl;
        v_rljtmk := 'Y';
      else
        tmpyssl := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减应收水量余额
        tmpsl   := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减实收水量余额
      end if;
      rd.rdpscid := -1;
      if v_rljtmk = 'Y' then
        p_rl.rlcolumn12 := 0;
      else
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(v_rljtsrqold, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
      end if;
      rd.rdpmdcolumn3 := substr(v_rljtsrqold, 1, 4);
      年累计水量      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (p_sl - round(p_sl * v_jgyf / v_jtny));
      --计算去年的阶梯
      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );

        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                            年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                          when 年累计水量 > ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                          else
                            0
                        end
                     end
                     ;
        rd.rdje  := rd.rddj * rd.rdsl;
        rd.rddj    := ps.psprice;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
            rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
          elsif 年累计水量 > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01'then rd.rdsl else 0 end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;

      if v_jgyf <= 12 then
        if v_newmk = 'Y' then
          v_rljtmk := 'Y';
        end if;
        rd.rdpscid := pd.pdpscid;
        tmpyssl    := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减应收水量余额
        tmpsl      := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减实收水量余额
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(p_rl.rlmonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
        rd.rdpmdcolumn3 := substr(p_rl.rlmonth, 1, 4);
        年累计水量      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (round(p_sl * v_jgyf / v_jtny));

        --计算去年的阶梯
          open c_ps;
          fetch c_ps
            into ps;
          if c_ps%notfound or c_ps%notfound is null then
            raise_application_error(errcode, '无效的阶梯计费设置');
          end if;
          while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
            --居民水费阶梯数量跟户籍人数有关
            if ps.psscode = 0 then
              ps.psscode := 0;
            else
              ps.psscode := round((ps.psscode + 30 * (usenum - 5)));
            end if;
            ps.psecode := round((ps.psecode + 30 * (usenum - 5)));
            rd.rdclass := ps.psclass;
            rd.rddj    := ps.psprice;
            rd.rdsl := case when v_rljtmk = 'Y' then tmpsl else
                          case
                            when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                              年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                            when 年累计水量 > ps.psecode then
                              tools.getmax(0,tools.getmin(ps.psecode -  to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                            else
                              0
                          end
                       end
                       ;
            rd.rdje    := rd.rddj * rd.rdsl;
            if v_rljtmk <> 'Y' then
              rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
              if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
              elsif 年累计水量 > ps.psecode then
                rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
              else
                rd.rdpmdcolumn2 := 0;
              end if;
            end if;

            if rd.rdsl > 0 then
              if rdtab is null then
                rdtab := rd_table(rd);
              else
                rdtab.extend;
                rdtab(rdtab.last) := rd;
              end if;
            end if;
            --汇总
            p_rl.rlje := p_rl.rlje + rd.rdje;
            p_rl.rlsl := p_rl.rlsl + (case
                           when rd.rdpiid = '01' then
                            rd.rdsl
                           else
                            0
                         end);
            --累减后带入下一行游标
            tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
            tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
            exit when tmpyssl <= 0 and tmpsl <= 0;
            fetch c_ps into ps;
          end loop;
          close c_ps;
      end if;
    end if;
    if v_rljtmk = 'N' then
      p_rl.rlcolumn12 := 年累计水量;
    else p_rl.rljtmk := 'Y';
    end if;
    if c_ps%isopen then close c_ps; end if;
  exception
    when others then
      if c_ps%isopen then close c_ps; end if;
      wlog(p_rl.rlmid || '计算阶梯水量费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure insrd(rd in rd_table) is
    vrd      bs_recdetail%rowtype;
    i        number;
    v_rdpiid varchar2(10);
  begin
    for i in rd.first .. rd.last loop
      vrd      := rd(i);
      v_rdpiid := vrd.rdpiid;
      if 是否审批算费 = 'N' then
        insert into bs_recdetail values vrd;
      else
        insert into bs_recdetail_temp values vrd;
      end if;
    end loop;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end;

  --应收冲正_按工单
  procedure yscz_gd(p_reno   in varchar2,--工单流水号
                 p_oper    in varchar2,--完结人
                 p_memo   in varchar2 --备注
                 ) is
    o_rerid        varchar2(20);
    r_yscz         request_yscz%rowtype;
    --o_pid_reverse  bs_reclist.rlpid%type;
    rlcr bs_reclist%rowtype;
    v_oldrecsl number;
  begin
    select * into r_yscz from request_yscz where reno = p_reno;

    if r_yscz.reno is null then raise_application_error(errcode, '工单不存在'); end if;
    if r_yscz.reshbz <> 'Y' then raise_application_error(errcode, '工单未审核'); end if;
    if r_yscz.rewcbz = 'Y' then raise_application_error(errcode, '工单已冲正'); end if;

    for rlde in (select * from bs_reclist t where t.rlid in
                     (select regexp_substr(r_yscz.rerlid, '[^,]+', 1, level) pid from dual connect by level <= length(r_yscz.rerlid) - length(replace(r_yscz.rerlid, ',', '')) + 1)
                 order by rlday desc) loop
      if rlde.rlid is null then
        wlog('无效的应收账流水号：'|| r_yscz.rerlid);
        raise_application_error(errcode, '无效的应收账流水号：'||r_yscz.rerlid);
      end if;
      if rlde.rlreverseflag <> 'N' then
        raise_application_error(errcode, '应收' || rlde.rlid || '已经冲正！');
      end if;
      if rlde.rlpaidflag <> 'N' then
        raise_application_error(errcode,'应收' || rlde.rlid || '不是欠费状态，状态标志为' ||rlde.rlpaidflag);
      end if;
      if rlde.rlje < 0 then
        raise_application_error(errcode,'应收' || rlde.rlid || '应收帐金额应该大于等于零！');
      end if;
      /*
      if rlde.rlpaidje > 0 then
        raise_application_error(errcode, '应收' || rlde.rlid || '已部分销帐不能冲正');
      end if;
      */

      rlcr := rlde;
      rlcr.rlcolumn9  := rlcr.rlid; --上次应收帐流水
      rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
      rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
      rlcr.rldate     := sysdate;
      rlcr.rldatetime := sysdate;
      rlcr.rlpaidflag := 'N';
      rlcr.rlsl       := 0 - rlcr.rlsl;
      rlcr.rlje       := 0 - rlcr.rlje;
      rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
      rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
      rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
      rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
      rlcr.rlmemo        := p_memo;
      rlcr.rlreverseflag := 'Y';
      --插入负应收记录
      insert into bs_reclist values rlcr;

      rlde.rlpaidflag    := rlcr.rlpaidflag;
      rlde.rlpaiddate    := rlcr.rldate;
      rlde.rlpaidper     := p_oper;
      rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
      rlde.rlreverseflag := rlcr.rlreverseflag;
      --更新标记源帐
      update bs_reclist
         set rlpaidflag    = rlcr.rlpaidflag,
             rlpaiddate    = rlcr.rldate,
             rlpaidper     = p_oper,
             rlreverseflag = rlde.rlreverseflag
       where rlid = rlde.rlid;

      insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
      select rlcr.rlid,
             rdpiid,
             rdpfid,
             rdpscid,
             rdclass,
             rddj,
             0 - rdsl,
             0 - rdje,
             rdmethod,
             rdmemo,
             rdpmdcolumn1,
             rdpmdcolumn2,
             rdpmdcolumn3
      from bs_recdetail
      where rdid = rlde.rlid;

      v_oldrecsl := null;
      begin
        select mr.mrsl into v_oldrecsl from bs_meterread mr where mr.mrmid = rlde.rlmid and mr.mrecode = rlde.rlscode;
      exception
        when no_data_found then v_oldrecsl := null;
      end;

      if v_oldrecsl is null then
        begin
          select mrh.mrsl into v_oldrecsl from bs_meterread_his mrh where mrh.mrmid = rlde.rlmid and mrh.mrecode = rlde.rlscode;
        exception
          when no_data_found then v_oldrecsl := null;
        end;
      end if;

      --rercodeflag      是否重置抄表指针
      if r_yscz.rercodeflag = 'Y' then
        update bs_meterinfo
           set mircode   = rlde.rlscode,
               mirecdate = rlde.rlday, --本期抄见日期 =应收账抄表日期
               mirecsl   = v_oldrecsl
               --mirecsl   = rlde.rlreadsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --抄见标志
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null,
                 mrscode    = rlde.rlscode, --上期抄见
                 mrecode    = null , --本期抄见
                 mrsl       = null  --本期水量
           where mrid = rlde.rlmrid;
         end if;
      else
        update bs_meterinfo
           set --mirecsl = 0
               mirecsl = v_oldrecsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --抄见标志
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null
           where mrid       = rlde.rlmrid;
         end if;
      end if;
      commit;
    end loop;
   --更新工单状态
    update request_yscz
       set rewcbz = 'Y',
           rerlid_rev = o_rerid,
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper),
           remark = p_memo
     where reno = p_reno;
    --更改 用户 有审核状态的工单 状态
    update bs_custinfo set reflag = 'N' where ciid = r_yscz.rlcid;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --应收冲正_按应收账流水
  procedure yscz_rl(p_rlid   in varchar2, --应收账流水号
                 p_oper    in varchar2,    --完结人
                 p_memo   in varchar2,    --备注
                 o_rlcrid out varchar2    --返回负应收账流水号
                 ) is
    cursor c_rl is select * from bs_reclist t where t.rlid = p_rlid;
    rlde bs_reclist%rowtype;
    rlcr bs_reclist%rowtype;
  begin
    open c_rl;
    fetch c_rl into rlde;

    if c_rl%notfound or c_rl%notfound is null then
      wlog('无效的应收账流水号：'|| p_rlid);
      raise_application_error(errcode, '无效的应收账流水号：'||p_rlid);
    end if;
    if rlde.rlreverseflag <> 'N' then
      raise_application_error(errcode, '应收' || rlde.rlid || '已经冲正！');
    end if;
    if rlde.rlpaidflag <> 'N' then
      raise_application_error(errcode,'应收' || rlde.rlid || '不是欠费状态，状态标志为' ||rlde.rlpaidflag);
    end if;
    if rlde.rlje < 0 then
      raise_application_error(errcode,'应收' || rlde.rlid || '应收帐金额应该大于等于零！');
    end if;
    /*
    if rlde.rlpaidje > 0 then
      raise_application_error(errcode, '应收' || rlde.rlid || '已部分销帐不能冲正');
    end if;
    */
    rlcr := rlde;
    rlcr.rlcolumn9  := rlcr.rlid; --上次应收帐流水
    rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
    rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
    rlcr.rldate     := trunc(sysdate);
    rlcr.rldatetime := sysdate;
    rlcr.rlpaidflag := 'N';
    rlcr.rlsl       := 0 - rlcr.rlsl;
    rlcr.rlje       := 0 - rlcr.rlje;
    rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
    rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
    rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
    rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
    rlcr.rlmemo        := p_memo;
    rlcr.rlreverseflag := 'Y';
    o_rlcrid := rlcr.rlid;
    --插入负应收记录
    insert into bs_reclist values rlcr;

    rlde.rlpaidflag    := rlcr.rlpaidflag;
    rlde.rlpaiddate    := rlcr.rldate;
    rlde.rlpaidper     := p_oper;
    rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
    rlde.rlreverseflag := rlcr.rlreverseflag;
    --更新标记源帐
    update bs_reclist
       set rlpaidflag    = rlcr.rlpaidflag,
           rlpaiddate    = rlcr.rldate,
           rlpaidper     = p_oper,
           rlreverseflag = rlde.rlreverseflag
     where rlid = rlde.rlid;

    insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
    select rlcr.rlid,
           rdpiid,
           rdpfid,
           rdpscid,
           rdclass,
           rddj,
           0 - rdsl,
           0 - rdje,
           rdmethod,
           rdmemo,
           rdpmdcolumn1,
           rdpmdcolumn2,
           rdpmdcolumn3
    from bs_recdetail
    where rdid = rlde.rlid;

    update bs_meterinfo
       set mirecsl = 0
     where miid = rlcr.rlmid;

    update bs_meterread
       set mrifsubmit = 'N',
           mrifrec    = 'N',
           mrifyscz   = 'Y',
           mrreadok   = 'N',  --抄见标志
           mrrecje01  = null,
           mrrecje02  = null,
           mrrecje03  = null,
           mrrecje04  = null
     where mrid       = rlcr.rlmrid;

    commit;
    close c_rl;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

begin
  select to_number(spvalue) into 最低算费水量 from sys_para where spid='1092';
  select spvalue into 总表截量 from sys_para where spid='1069';
  select spvalue into 是否审批算费 from sys_para where spid='ifrl';
  select spvalue into 分账操作 from sys_para where spid='1104';
  select spvalue into 算费时预存自动销账 from sys_para where spid='0006';
  select smtifcharge into v_smtifcharge1 from sysmetertype where smtid='1';
end;
/

prompt
prompt Creating package body PG_CHKOUT
prompt ===============================
prompt
create or replace package body pg_chkout is
  --对账处理程序包
  
  /*
  生成建账工单        
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数：  p_userid        收费员编码
  */
  procedure ins_jzgd(p_userid varchar2) is
    v_chkdate date;
    v_deptid varchar2(20); 
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    
    --获取操作员最后对账时间
    select chk_date, dept_id into v_chkdate, v_deptid from sys_user where user_id = p_userid;
    
    --生成对账信息
    insert into request_jzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hauditflag, hauditdate, hauditper,  hauditno,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch, st_sdate, st_edate
    )
    select v_reno reno, v_deptid resmfid,
    
           sum(case when ppayway in ('XJ','ZP') then 1 else 0 end) hcount,         --收款总笔数（=现金总笔数+支票总笔数）
           sum(case when ppayway in ('XJ','ZP') then ppayment else 0 end) hje,   --收款总金额（=现金总金额+支票总金额）
           null hqc,             --期初预存
           null hfs,             --预存发生
           null hqm,            --期末预存
           
           null hsf,              --水费
           null hwsf,             --污水费
           null hljf,             --垃圾费
           null hznj,             --违约金
           null hfpsl,            --票据张数（=有效发票数+作废发票数）
           null hauditflag,       --发出标志(总财务)
           null hauditdate,       --发出时间(总财务)
           null hauditper,        --发出人(总财务)
           null hauditno,         --发出单号
           
           sum(case when ppayway = 'XJ' then ppayment else 0 end) hxjje,       --现金总金额（=现金实际金额+现金冲正金额）
           sum(case when ppayway = 'ZP' then ppayment else 0 end) hzpje,       --支票总金额（=支票实际金额+支票冲正金额）
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then ppayment else 0 end) hcolumn1,    --现金实际金额
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn2,    --现金冲正金额
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then ppayment else 0 end) hcolumn3,    --支票实际金额
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then ppayment else 0 end) hcolumn4,    --支票冲正金额
           
           null hcolumn5,        --违约金笔数
           null hcolumn6,        --手续费笔数
           null hcolumn7,        --手续费
           
           sum(case when ppayway = 'XJ' then 1 else 0 end) hcolumn8,             --现金总笔数（=现金实际笔数-现金冲正笔数）
           sum(case when ppayway = 'ZP' then 1 else 0 end) hcolumn9,             --支票总笔数（=支票实际笔数-支票冲正笔数）
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then 1 else 0 end) hcolumn10,    --现金实际笔数
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then 1 else 0 end) hcolumn11,    --现金冲正笔数
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then 1 else 0 end) hcolumn12,    --支票实际笔数
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then 1 else 0 end) hcolumn13,    --支票冲正笔数
           
           sum(case when preverseflag = 'N' then 1 else 0 end) hcolumn14,           --实际总笔数（=现金实际笔数+支票实际笔数）
           sum(case when preverseflag = 'N' then ppayment else 0 end) hcolumn15,    --实际总金额（=现金实际金额+支票实际金额）
           sum(case when preverseflag = 'Y' then 1 else 0 end) hcolumn16,           --冲正总笔数（=现金冲正笔数+支票冲正笔数）
           sum(case when preverseflag = 'Y' then ppayment else 0 end) hcolumn17,    --冲正总金额（=现金冲正金额+支票冲正金额）
           
           null hcolumn18,            --有效发票数
           null hcolumn19,            --作废发票数
           
           sum(case when ppayway = 'DC' then 1 else 0 end) hcolumn20,                                        --倒存总笔数（=倒存实际总笔数-倒存冲正总笔数） 
           sum(case when ppayway = 'DC' and preverseflag = 'N' then 1 else 0 end) hcolumn21,                 --倒存实际总笔数
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then 1 else 0 end) hcolumn22,                 --倒存冲正总笔数
           sum(case when ppayway = 'DC' then ppayment else 0 end) hcolumn23,                                 --倒存总金额（=倒存实际总金额-倒存冲正总金额）
           sum(case when ppayway = 'DC' and preverseflag = 'N' then ppayment else 0 end) hcolumn24,          --倒存实际总金额 
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then ppayment else 0 end) hcolumn25,          --倒存冲正总金额
           
           sum(case when ppayway = 'MZ' then 1 else 0 end) hcolumn26,                                        --抹账总笔数（=抹账实际总笔数-抹账冲正总笔数）
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then 1 else 0 end) hcolumn27,                 --抹账实际总笔数
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then 1 else 0 end) hcolumn28,                 --抹账冲正总笔数
           sum(case when ppayway = 'MZ' then ppayment else 0 end) hcolumn29,                                 --抹账总金额（=抹账实际总金额-抹账冲正总金额）
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then ppayment else 0 end) hcolumn30,          --抹账实际总金额 
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn31,          --抹账冲正总金额
           
           sum(case when ppayway = 'POS' then ppayment else 0 end) hcolumn32,                                        --POS总金额（=POS实际金额+POS冲正金额）
           sum(case when ppayway = 'POS' and preverseflag = 'N' then ppayment else 0 end) hcolumn33,                 --POS实际金额
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then ppayment else 0 end) hcolumn34,                 --POS冲正金额pos实际笔数 
           sum(case when ppayway = 'POS' then 1 else 0 end) hcolumn35,                                               --POS总笔数（=POS实际笔数-POS冲正笔数）
           sum(case when ppayway = 'POS' and preverseflag = 'N' then 1 else 0 end) hcolumn36,                        --POS实际笔数 
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then 1 else 0 end) hcolumn37,                        --POS冲正笔数
           
           null reappnote, null restaus, null reper, null reflag,
           null enabled,
           null sortcode, null deletemark, sysdate createdate, p_userid createuserid, null createusername,
           null modifydate, null modifyuserid, null modifyusername,
           null remark, null workno, null workbatch, v_chkdate st_sdate, sysdate st_edate
    from bs_payment
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null
          and (preverseflag = 'N' or (preverseflag = 'Y' and ppayment > 0)) ;
    
    --更新对账信息水费，污水费
    update request_jzgd 
    set (hsf,hwsf,hljf) = (select 
                                sum(case when rd.rdpiid = '01' then rd.rdje end) je_sf ,
                                sum(case when rd.rdpiid = '02' then rd.rdje end) je_wsf,
                                sum(case when rd.rdpiid = '03' then rd.rdje end) je_fjf
                            from bs_reclist rl 
                                 left join bs_recdetail rd on rl.rlid = rd.rdid
                            where rl.rlpid in (select pid 
                                               from  bs_payment 
                                               where ppayee = p_userid
                                                     and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                                                     and pchkno is null)
    )
    where reno = v_reno;
    
    --更新期初、期末
    update request_jzgd
    set (hqc, hfs, hqm) = (select sum(hqc),sum(hqm) - sum(hqc),sum(hqm)
                               from (select distinct pcid, 
                                            first_value(psavingqc) over (partition by pcid order by pdatetime) hqc,
                                            first_value(psavingqc) over (partition by pcid order by pdatetime desc) hqm
                                       from bs_payment
                                      where ppayee = p_userid
                                            and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                                            and pchkno is null) t );
    
    --更新交易信息
    update bs_payment 
    set pchkno = v_reno 
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null;
    
    --更新操作员信息
    update sys_user set chk_date = sysdate where user_id = p_userid;
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  删除建账工单
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数     p_reno      建账工单编码
  */
  procedure del_jzgd(p_reno varchar2) is
    v_chkdate date;
    v_userid varchar2(50);
  begin
    select st_sdate, createuserid into v_chkdate, v_userid from request_jzgd where reno = p_reno;
    --更新操作员信息
    update sys_user set chk_date = v_chkdate where user_id = v_userid;
    --更新交易信息
    update bs_payment set pchkno = null where pchkno = p_reno;
    --删除建账工单
    delete from request_jzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  生成对账工单        
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_deptid    机构编码
  */
  procedure ins_dzgd(p_deptid varchar2) is
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    --生成对账信息
    insert into request_dzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch)
    select v_reno reno, resmfid,
           sum(hcount), sum(hje), sum(hqc), sum(hfs), sum(hqm),
           sum(hsf), sum(hwsf), sum(hljf), sum(hznj), sum(hfpsl),
           sum(hxjje), sum(hzpje), sum(hcolumn1),  sum(hcolumn2), sum(hcolumn3),  sum(hcolumn4),
           sum(hcolumn5),  sum(hcolumn6), sum(hcolumn7),
           sum(hcolumn8),  sum(hcolumn9), sum(hcolumn10), sum(hcolumn11), sum(hcolumn12), sum(hcolumn13),
           sum(hcolumn14), sum(hcolumn15), sum(hcolumn16), sum(hcolumn17),
           sum(hcolumn18), sum(hcolumn19),
           sum(hcolumn20), sum(hcolumn21), sum(hcolumn22), sum(hcolumn23), sum(hcolumn24), sum(hcolumn25),
           sum(hcolumn26), sum(hcolumn27), sum(hcolumn28), sum(hcolumn29), sum(hcolumn30), sum(hcolumn31),
           sum(hcolumn32), sum(hcolumn33), sum(hcolumn34), sum(hcolumn35), sum(hcolumn36), sum(hcolumn37),
           null reappnote,null  restaus, null reper, null reflag,
           null enabled,
           null sortcode,  null deletemark, null createdate,  null createuserid, null createusername,
           null modifydate, null  modifyuserid, null modifyusername,
           null remark,  null workno,  null workbatch
    from request_jzgd 
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y'
    group by resmfid;
    
    --更新建账信息
    update request_jzgd 
    set   dzgd_no = v_reno, rewcbz = 'Y'
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y';
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  删除对账工单        
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_reno    对账工单  编码
  */  
  procedure del_dzgd(p_reno varchar2) is
  begin
    --更新建账信息
    update request_jzgd set dzgd_no = null, rewcbz = 'N' where dzgd_no = p_reno;
    --删除对账工单
    delete from request_dzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
end pg_chkout;
/

prompt
prompt Creating package body PG_DHZ
prompt ============================
prompt
create or replace package body pg_dhz is

    --呆账坏账 工单处理
    procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2) is
      v_reshbz char(1);
      v_rewcbz char(1);
      v_rlid varchar(2000);
      v_rlcid varchar2(10);
      v_rlpaidflag char(1);
      v_rlreverseflag char(1);
      v_n number;
    begin
      begin
        select reshbz, rewcbz, rlid, rlcid into v_reshbz, v_rewcbz, v_rlid, v_rlcid from request_dhgl where reno = p_reno;
      exception
        when no_data_found then o_log := o_log || p_reno || '无效的工单号' || chr(10);
        return;
      end;

      if v_reshbz <> 'Y' then
        o_log := o_log || p_reno || '工单未完成审核，无法提交' || chr(10);
        return;
      elsif v_rewcbz = 'Y' then
        o_log := o_log || p_reno || '工单已完成，无法重复提交'|| chr(10);
        return;
      end if;

      o_log := o_log || p_reno || '呆账坏账工单开始执行'|| chr(10);

      for i in (select regexp_substr(v_rlid, '[^,]+', 1, level) rlid from dual connect by level <= length(v_rlid) - length(replace(v_rlid, ',', '')) + 1) loop
        begin
          select rlpaidflag, rlreverseflag into v_rlpaidflag, v_rlreverseflag from bs_reclist where rlid = i.rlid;
        exception
          when no_data_found then o_log := o_log || i.rlid || '无效的应收账流水号' || chr(10);
          return;
        end;

        if v_rlpaidflag = 'Y' then
          o_log := o_log || i.rlid || '应收账已销账，无法变更状态' || chr(10);
        elsif v_rlreverseflag = 'Y' then
          o_log := o_log || i.rlid || '应收账已冲正，无法变更状态' || chr(10);
        else
          update bs_reclist set rlbadflag = 'Y' where rlid = i.rlid;
          v_n := sql%rowcount;
          if v_n = 0 then
             o_log := o_log || i.rlid || '应收帐状态更新失败'|| chr(10);
          else
             o_log := o_log || i.rlid || '应收帐状态更新完成'|| chr(10);
          end if;
         end if;
      end loop;

      --更新工单状态
      update request_dhgl
         set rewcbz = 'Y',
             modifydate = sysdate,
             modifyuserid = p_oper,
             modifyusername = (select user_name from sys_user where user_id = p_oper)
       where reno = p_reno;
      --更改 用户 有审核状态的工单 状态
      update bs_custinfo set reflag = 'N' where ciid = v_rlcid;

      o_log := o_log || p_reno || '呆账坏账工单执行完成'|| chr(10);

      commit;
    exception
      when others then
        o_log := o_log || p_reno || '无效的工单号' ;
        rollback;
    end;

    --呆账坏账 销账
    procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, o_log out varchar2) is
      v_rlcid varchar2(100);
      v_pid varchar2(100);
      v_rlje number;
      v_misaving number;
    begin
      for i in (select regexp_substr(p_rlids, '[^,]+', 1, level) rlid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) loop

        begin
          select bs_reclist.rlcid , bs_reclist.rlje, bs_custinfo.misaving into v_rlcid ,v_rlje, v_misaving
          from bs_reclist left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
          where bs_reclist.rlid = i.rlid;
        exception
          when no_data_found then o_log := o_log || i.rlid || '无效的应收帐流水号' || chr(10);
          return;
        end;

        if v_rlje > v_misaving then
           o_log := o_log || i.rlid ||  '用户余额不足无法销账' || chr(10);
        else
          pg_paid.poscustforys(p_yhid     => v_rlcid,
                               p_arstr    => i.rlid,
                               p_oper     => p_oper,
                               p_payway   => 'XJ',
                               p_payment  => 0,
                               p_pid      => v_pid);
          o_log := o_log || i.rlid || '应收帐，销账完成'|| chr(10);
        end if;

      end loop;
    exception
      when others then
        rollback;
    end;

end pg_dhz;
/

prompt
prompt Creating package body PG_EWIDE_METERTRANS
prompt =========================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_EWIDE_METERTRANS IS

  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and t.mtdflag='N' for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单头信息不存在!');
    END;
    --工单信息已经审核不能再审
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --单体完工
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    end loop;
    close c_md;
    --更新单头
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --更新流程
    update kpi_task t set t.do_date=sysdate,t.isfinish='Y' where t.report_id=trim(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;

  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- 操作员
                             P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                             p_commit in varchar2 --提交标志
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    mdsl meteraddsl%ROWTYPE;
    V_COUNT NUMBER(4);
    v_number number(10);
    v_crhno  varchar2(10);
    v_omrid  varchar2(20);
    o_str varchar2(20);

  begin
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;

    if mi.mircode != md.MTDSCODE then
      raise_application_error(errcode,'上期抄见发生变化，请重置上期抄见');
    end if;

    --F销户拆表
    if P_MD.MTBK8 = bt销户拆表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;


      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO    ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      --算费
      --?????
    --修改用户状态 custinfo
      UPDATE custinfo  t
      set t.cistatus=c销户 where CIID= mi.micid ;

    ---- METERINFO 有效状态 --状态日期 --状态表务 【yujia 20110323】
      update METERINFO
      set MISTATUS =m销户,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=sysdate
      where MIID=P_MD.Mtdmid;
    -----METERDOC  表状态 表状态发生时间  【yujia 20110323】

      update METERDOC set MDSTATUS =m销户,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;
    elsif P_MD.MTBK8 = bt口径变更 then
      -- METERINFO 有效状态 --状态日期 --状态表务

      --备份记录回滚信息 METERTRANSROLLBACK
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER, --换表人
          mitype = p_md.mtdmtypen  --表型
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS =m立户 ,
          mdcaliber =P_MD.MTDCALIBERN,
          mdno = p_md.mtdmnon, ---表型号
          MDSTATUSDATE=sysdate,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;
/*      --METERTRANSDT 回滚换表日期 回滚水表状态   备份记录回滚信息 METERTRANSROLLBACK 已处理
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE Mtdmid=MI.MIID;*/


      --算费
      --?????


    elsif P_MD.MTBK8 = bt欠费停水 then

      --备份记录回滚信息
      delete    METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      update METERINFO set MISTATUS =m暂停 ,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC set MDSTATUS =m暂停 ,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????


    elsif P_MD.MTBK8 = bt校表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS     = m立户 ,
          MDSTATUSDATE = sysdate,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????
    elsif P_MD.MTBK8 = bt复装 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;



      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS =m立户 ,--状态
          MISTATUSDATE=sysdate,--状态日期
          MISTATUSTRANS=P_MD.MTBK8,--状态表务
          MIADR= P_MD.MTDMADRN,--水表地址
          MISIDE= P_MD.MTDSIDEN,--表位
          MIPOSITION = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE =  P_MD.MTDREINSDATE , --换表日期
          MIREINSPER = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS =m立户 ,--状态
          MDSTATUSDATE=sysdate,--状态发生时间
          MDNO=P_MD.MTDMNON,--表身号
          MDCALIBER=P_MD.MTDCALIBERN,--表口径
          MDBRAND=P_MD.MTDBRANDN,--表厂家
          MDMODEL=P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;



      --算费
      --????

    elsif P_MD.MTBK8 = bt故障换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS     =m立户 ,--状态
          MDSTATUSDATE =sysdate,--表状态发生时间
          MDNO         =P_MD.MTDMNON,--表身号
          MDCALIBER    =P_MD.MTDCALIBERN,--表口径
          MDBRAND      =P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;

      --算费
      --??????

    elsif P_MD.MTBK8 = bt周期换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS      = m立户 ,--状态
          MDSTATUSDATE  = sysdate,--表状态发生时间
          MDNO          = P_MD.MTDMNON,--表身号
           MDCALIBER     = P_MD.MTDCALIBERN,--表口径
          MDBRAND       = P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;
      --算费
      --？？？？

    elsif P_MD.MTBK8 = bt复查工单 then
      null;
    elsif P_MD.MTBK8 = bt改装总表 then
       null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
          insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmcode);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
      elsif P_MD.MTBK8 = bt补装户表 then
         null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
           insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmpid);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
    elsif  P_MD.MTBK8 = bt安装分类计量表 then
       null;
      /*tools.SP_BillSeq('100',v_crhno);

      insert into custreghd
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

      insert into custmeterregdt
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR)
      VALUES(v_crhno,1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
      P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
      P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000');*/
     elsif P_MD.MTBK8 = bt水表升移 then
        null;
             /*-- METERINFO 有效状态 --状态日期 --状态表务
                 update METERINFO
                         set MISTATUS      = m立户 ,
                          MISTATUSDATE  = sysdate,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.Mtdpositionn
                 where MIID=P_MD.Mtdmid;
                 -- meterdoc
                update METERDOC
                 set MDSTATUS     = m立户 ,
                  MDSTATUSDATE = sysdate
                where MDMID=P_MD.Mtdmid;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE Mtdmid=MI.MIID;
      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      --算费*/
    END IF;

    --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
 IF FSYSPARA('1102')='Y' THEN
    if P_MD.MTDADDSL >= 0 and P_MD.MTDADDSL is not null then        --余量大于0 进行算费
    --将余量添加抄表库
    v_omrid := to_char(sysdate,'yyyy.mm');
      sp_insertmr(p_per,to_char(sysdate,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,mi,v_omrid);

      if v_omrid is not null then --返回流水不等于空，添加成功

           --算费
           pg_ewide_meterread_01.Calculate(v_omrid);

          --将之前余用掉
           PG_ewide_RAEDPLAN_01.sp_useaddingsl(v_omrid, --抄表流水
                        MA.Masid     , --余量流水
                           o_str     --返回值
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=v_omrid ;
           DELETE METERREAD WHERE  MRID=v_omrid ;


    end if;
      MR :=null;
      --查询抄表计划，如果有抄表计划没有抄表就可以修改本抄表计划期抄码
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=mi.micode
      AND MRMONTH= TOOLS.fgetreadmonth(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      if mr.mrid is not null then
         if mr.mrreadok='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      end if;

    end if;
  END IF;

  --更新完工标志
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=sysdate,MTDSHPER=P_PER where MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --提交标志
  if p_commit='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
  end;

  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --追收头
                        P_MRIFTRANS IN VARCHAR2, --抄表数据事务
                        MI          IN METERINFO%ROWTYPE, --水表信息
                        OMRID       OUT METERREAD.MRID%TYPE) AS
    --抄表流水
    MR METERREAD%ROWTYPE; --抄表历史库
  BEGIN
    MR.MRID    := FGETSEQUENCE('METERREAD'); --流水号
    OMRID      := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
    MR.MRBFID  := RTH.RTHBFID; --表册
    BEGIN
      SELECT BFBATCH
        INTO MR.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRBATCH := 1; --抄表批次
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MR.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MR.MRMONTH
         AND MRBBATCH = MR.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRDAY := SYSDATE; --计划抄表日
      /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
            raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
      end if;*/
    END;
    MR.MRDAY       := SYSDATE; --计划抄表日
    MR.MRRORDER    := MI.MIRORDER; --抄表次序
    MR.MRCID       := RTH.RTHCID; --用户编号
    MR.MRCCODE     := RTH.RTHCCODE; --用户号
    MR.MRMID       := RTH.RTHMID; --水表编号
    MR.MRMCODE     := RTH.RTHMCODE; --水表手工编号
    MR.MRSTID      := MI.MISTID; --行业分类
    MR.MRMPID      := MI.MIPID; --上级水表
    MR.MRMCLASS    := MI.MICLASS; --水表级次
    MR.MRMFLAG     := MI.MIFLAG; --末级标志
    MR.MRCREADATE  := SYSDATE; --创建日期
    MR.MRINPUTDATE := SYSDATE; --编辑日期
    MR.MRREADOK    := 'Y'; --抄见标志
    MR.MRRDATE     := RTH.RTHRDATE; --抄表日期
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := RTH.RTHSHPER; --抄表员
    END;

    MR.MRPRDATE        := RTH.RTHPRDATE; --上次抄见日期
    MR.MRSCODE         := RTH.RTHSCODE; --上期抄见
    MR.MRECODE         := RTH.RTHECODE; --本期抄见
    MR.MRSL            := RTH.RTHREADSL; --本期水量
    MR.MRFACE          := NULL; --水表故障
    MR.MRIFSUBMIT      := 'Y'; --是否提交计费
    MR.MRIFHALT        := 'N'; --系统停算
    MR.MRDATASOURCE    := 'Z'; --抄表结果来源：表务抄表
    MR.MRIFIGNOREMINSL := 'N'; --停算最低抄量
    MR.MRPDARDATE      := NULL; --抄表机抄表时间
    MR.MROUTFLAG       := 'N'; --发出到抄表机标志
    MR.MROUTID         := NULL; --发出到抄表机流水号
    MR.MROUTDATE       := NULL; --发出到抄表机日期
    MR.MRINORDER       := NULL; --抄表机接收次序
    MR.MRINDATE        := NULL; --抄表机接受日期
    MR.MRRPID          := RTH.RTHMRPID; --计件类型
    MR.MRMEMO          := RTH.RTHMEMO; --抄表备注
    MR.MRIFGU          := 'N'; --估表标志
    MR.MRIFREC         := 'Y'; --已计费
    MR.MRRECDATE       := SYSDATE; --计费日期
    MR.MRRECSL         := RTH.RTHSL; --应收水量
    MR.MRADDSL         := RTH.RTHADDSL; --余量
    MR.MRCARRYSL       := 0; --进位水量
    MR.MRCTRL1         := NULL; --抄表机控制位1
    MR.MRCTRL2         := NULL; --抄表机控制位2
    MR.MRCTRL3         := NULL; --抄表机控制位3
    MR.MRCTRL4         := NULL; --抄表机控制位4
    MR.MRCTRL5         := NULL; --抄表机控制位5
    MR.MRCHKFLAG       := 'N'; --复核标志
    MR.MRCHKDATE       := NULL; --复核日期
    MR.MRCHKPER        := NULL; --复核人员
    MR.MRCHKSCODE      := NULL; --原起数
    MR.MRCHKECODE      := NULL; --原止数
    MR.MRCHKSL         := NULL; --原水量
    MR.MRCHKADDSL      := NULL; --原余量
    MR.MRCHKCARRYSL    := NULL; --原进位水量
    MR.MRCHKRDATE      := NULL; --原抄见日期
    MR.MRCHKFACE       := NULL; --原表况
    MR.MRCHKRESULT     := NULL; --检查结果类型
    MR.MRCHKRESULTMEMO := NULL; --检查结果说明
    MR.MRPRIMID        := RTH.RTHPRIID; --合收表主表
    MR.MRPRIMFLAG      := RTH.RTHPRIFLAG; --合收表标志
    MR.MRLB            := RTH.RTHMLB; --水表类别
    MR.MRNEWFLAG       := NULL; --新表标志
    MR.MRFACE2         := NULL; --抄见故障
    MR.MRFACE3         := NULL; --非常计量
    MR.MRFACE4         := NULL; --表井设施说明
    MR.MRSCODECHAR     := RTH.RTHSCODECHAR; --上期抄见
    MR.MRECODECHAR     := RTH.RTHECODECHAR; --本期抄见
    MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --特权操作人
    MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
    MR.MRPRIVILEGEDATE := NULL; --特权操作时间
    MR.MRSAFID         := MI.MISAFID; --管理区域
    MR.MRIFTRANS       := P_MRIFTRANS; --抄表数据事务
    MR.MRREQUISITION   := 0; --通知单打印次数
    MR.MRIFCHK         := MI.MIIFCHK; --考核表
    INSERT INTO METERREAD VALUES MR;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
     RAISE_APPLICATION_ERROR(ERRCODE, '数据库错误!'||sqlerrm);
  END;

  --计划抄表单笔算费
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0用水允许算费
         FOR UPDATE NOWAIT;

    --总分表子表抄表记录
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/

    --20140512 总表截量修改
    --总表截量=子表换表余量（M）+子表换表后当月抄见水量（1）
    --追量收费的
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --校验水量
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N';

    --一户多表用户信息zhb
    CURSOR C_MR_PR(P_MIPRIID IN VARCHAR2) IS
      SELECT MIID
        FROM METERINFO, METERREAD
       WHERE MRMID(+) = MIID
         AND MIPRIID = P_MIPRIID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MIID;

    --合收子表抄表记录
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRMCODE
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPRIFLAG = 'Y'
         AND MIPRIID = P_PRIMCODE
         AND MICODE <> P_PRIMCODE
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y';

    --取合收表信息
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --总表有周期换表、故障换表的余量抓取  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N' --未冲正
         and rlsl > 0;

    MR         METERREAD%ROWTYPE;
    MRCHILD    METERREAD%ROWTYPE;
    MRPRICHILD METERREAD%ROWTYPE;
    MI         METERINFO%ROWTYPE;
    MRL        METERREAD%ROWTYPE;
    MIL        METERINFO%ROWTYPE;
    MID        METERINFO.MIID%TYPE;
    V_TEMPSL   NUMBER;
    V_COUNT    NUMBER;
    V_ROW      NUMBER;

    V_SUMNUM      NUMBER; --子表数
    V_READNUM     NUMBER; --抄见子表数
    V_RECNUM      NUMBER; --算费子表数
    V_MICLASS     NUMBER;
    V_MIPID       VARCHAR2(10);
    V_MRMCODE     VARCHAR2(10);
    V_MDHIS_ADDSL METERREADHIS.MRADDSL%TYPE;
    V_PD_ADDSL    METERREADHIS.MRADDSL%TYPE;
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表计划流水号');
    END IF;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    IF MR.MRSL < 最低算费水量 AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '抄表水量小于最低算费水量，不需要算费');
    END IF;
    --水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    CLOSE C_MI;

    IF MI.mistatus = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      WLOG('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    END IF;

    IF MI.mistatus = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      WLOG('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    END IF;

    if MI.mistatus = '36' then
      --预存冲正中
      WLOG('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;

    --byj add
    if MI.mistatus = '39' then
      --预存冲正中
      WLOG('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;

    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!

    if MI.mistatus = '19' then
      --销户中
      WLOG('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;

    -------
    MR.MRRECSL := MR.MRSL; --本期水量
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    IF 总表截量 = 'Y' THEN

      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3

      --STEP1 检查是否总表
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;

      IF V_MICLASS = 2 THEN
        --是总表
        V_MRMCODE := MR.MRMCODE; --赋值为总表号

        --STEP2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        IF V_SUMNUM > V_READNUM THEN
          WLOG('抄表记录' || MR.MRID || '总分表中包含未抄子表，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '总分表中包含未抄子表，暂停产生费用');
        END IF;

        --20140512 总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        IF V_SUMNUM > V_RECNUM THEN
          WLOG('抄表记录' || MR.MRID || '收费总表发现子表未计费，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表子表未计费，暂停产生费用');
        END IF;
        --add modiby  20140809  hb
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量

        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --故障换表余量
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;

        V_PD_ADDSL := V_MDHIS_ADDSL; --判断水量=故障换表余量

        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --判断的水量 V_PD_ADDSL 实际为故障换表水量
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;

        if V_PD_ADDSL < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809
          --STEP3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --抵消水量
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;

        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          MR.MRRECSL := MR.MRRECSL;
        end if;

        --如果收费总表水量小于子表水量，暂停产生费用
        IF MR.MRRECSL < 0 THEN
          --如果总表截量小于0，则总表停算费用
          WLOG('抄表记录' || MR.MRID || '收费总表水量小于子表水量，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表水量小于子表水量，暂停产生费用');
        END IF;

      END IF;
    END IF;

    -----------------------------------------------------------------------------
    --判断一表多户 分表按比例分摊水量
    IF MI.MICOLUMN9 = 'Y' THEN
      OPEN C_MR_PR(MR.MRMID);

      V_TEMPSL := MR.MRSL;
      V_ROW    := 1;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIPRIID = MR.MRMID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MICOLUMN6;
      LOOP
        FETCH C_MR_PR
          INTO MID;
        EXIT WHEN C_MR_PR%NOTFOUND OR C_MR_PR%NOTFOUND IS NULL;
        MRL := MR;
        SELECT * INTO MIL FROM METERINFO WHERE MIID = MID;
        MRL.MRSMFID := MIL.MISMFID;
        MRL.MRCID   := MIL.MICID;
        MRL.MRMID   := MIL.MIID;
        MRL.MRCCODE := MIL.MICODE;
        MRL.MRBFID  := MIL.MIBFID;
        IF V_ROW >= V_COUNT THEN
          MRL.MRRECSL := TRUNC(V_TEMPSL);
        ELSE
          MRL.MRRECSL := TRUNC(MR.MRSL * MIL.MICOLUMN6);
        END IF;
        MRL.MRSAFID := MIL.MISAFID;
        V_TEMPSL    := V_TEMPSL - MRL.MRRECSL;
        V_ROW       := V_ROW + 1;
        IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
          --正常算费
          CALCULATE(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
          --计量不计费,将数据记录到费用库
          CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        END IF;

      END LOOP;
      MR.MRIFREC   := 'Y';
      MR.MRRECDATE := TRUNC(SYSDATE);
      IF C_MR_PR%ISOPEN THEN
        CLOSE C_MR_PR;
      END IF;

    ELSE
      IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
        --正常算费
        CALCULATE(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
        --计量不计费,将数据记录到费用库
        CALCULATENP(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      END IF;

    END IF;
    -----------------------------------------------------------------------------
    --更新当前抄表记录
    IF 是否审批算费 = 'N' THEN
      UPDATE METERREAD
         SET MRIFREC   = MR.MRIFREC,
             MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    ELSE
      UPDATE METERREAD
         SET MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    END IF;
    CLOSE C_MR;
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
  END CALCULATE;

  -- 自来水单笔算费，提供外部调用
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----历史价格体系
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD         PRICEMULTIDETAIL%ROWTYPE;
    PD          PRICEDETAIL%ROWTYPE;
    temp_pd     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量   NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_表的验效数量   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);

    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --应收流水
    V_HS_RLJE  NUMBER(12, 2); --应收金额
    V_HS_ZNJ   NUMBER(12, 2); --滞纳金
    V_HS_SXF   NUMBER(12, 2); --手续费
    V_HS_OUTJE NUMBER(12, 2);

    --预存自动抵扣
    v_rlidlist varchar2(4000);
    v_rlid     reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    CURSOR C_YCDK IS
      select rlid,
             sum(rlje) rlje,
             pg_ewide_pay_01.getznjadj(rlid,
                                       sum(rlje),
                                       rlgroup,
                                       max(rlzndate),
                                       rlsmfid,
                                       trunc(sysdate)) rlznj
        from reclist, meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and RLBADFLAG = 'N' --add 20151217 添加呆坏帐过滤条件
         and rlje <> 0
         and rltrans not in ('13', '14', 'u')
         and ((t.mipriid = MI.MIPRIID and MI.MIPRIFLAG = 'Y') or
             (t.miid = MI.MIID and
             (MI.MIPRIFLAG = 'N' or MI.MIPRIID is null)))
       group by rlmcode, t.miid, t.mipriid, rlmonth, rlid, rlgroup, rlsmfid
       order by rlgroup, rlmonth, rlid, mipriid, miid;

  BEGIN
    --
    --yujia  2012-03-20
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;

    --byj add 判断起码是否改变!!!
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!

    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' THEN
      --如果是倒表 要判断一下指针的问题
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '是倒表用户,起码应大于止码');
      END IF;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if MR.MRECODE < MR.MRSCODE then
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;

    /*ELSE
      if MR.MRECODE < MR.MRSCODE  then
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表用户,起码应小于止码');
      end if;*/
    END IF;
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      --ZHW2O160329修改---start
/*      IF P_TRANS = 'OY' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'N';
      ELSE
        RL.RLTRANS := P_TRANS;
      END IF;*/
      ---------------------end
      IF P_TRANS = 'OY' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then  --by 20200506 加入基建判断，如果是基建用户算费后应收事务为u
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'N';
      ELSE
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := P_TRANS;
        end if;
      END IF;



      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --记录合收子表串
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;

      RL.RLPRIFLAG := MI.MIPRIFLAG;
      IF MR.MRRPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '的抄表员不能为空!');
      END IF;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --应收帐分组

      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务

      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --计费调整
      --策略02 仅按水表
      --表的调整量 调整应收水量，调整方法=（02，03，04，05，06）
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;

      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---

        --策略07 按水表+价格类别
        --表费的调整量 调整综合单价，调整方法=（01 固定单价调整）
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;

        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);

        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;

        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;

            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---

            --计算调整
            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);

            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    v_表的调整量 /v_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量

        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;

          --取水价  11 --周期性单价  按水表+价格类别

          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
          end if;

          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;

          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);

          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;

          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

              --水价调整 按水表+价格类别+费用项目
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;

              --水价调整 按水表+价格类别+费用项目
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

      --   RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --总分表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
      --插入帐务
      --垃圾费基本数据
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 做为打印的预留

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
              IF MI.MIPRIFLAG = 'Y' and MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                --ZHW 20160329--------START
                select count(*)
                  into v_countall
                  from meterread
                 where mrmid <> MR.MRMID
                   and MRIFREC <> 'Y'
                   and mrmid in (SELECT miid
                                   FROM METERINFO
                                  WHERE MIPRIID = MI.MIPRIID);
                IF v_countall < 1 THEN
                  ----------------------------------------end
                  BEGIN
                    SELECT sum(MISAVING)
                      INTO V_PMISAVING
                      FROM METERINFO
                     WHERE MIPRIID = MI.MIPRIID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      V_PMISAVING := 0;
                  END;
                  --合收表
                  IF V_PMISAVING >= RL1.RLJE THEN
                    IF V_BATCH IS NULL THEN
                      V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                    END IF;
                    V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                    MI.MISMFID, --缴费机构
                                                    'system', --收款员
                                                    RL1.RLID || '|', --应收流水串
                                                    RL1.RLJE, --应收总金额
                                                    0, --销帐违约金
                                                    0, --手续费
                                                    0, --实际收款
                                                    PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                    MI.MIPRIID, --水表资料号
                                                    'XJ', --付款方式
                                                    MI.MISMFID, --缴费地点
                                                    V_BATCH, --销帐批次
                                                    'N', --是否打票  Y 打票，N不打票， R 应收票
                                                    NULL, --发票号
                                                    'N' --控制是否提交（Y/N）
                                                    );
                  END IF;
                end if;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              END IF;

            END IF;

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLIST VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
        INSRD(RDTAB);
        --预存自动扣款
        IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
            --总预存
            V_PMISAVING := 0;
            --ZHW 20160329--------START
            select count(*)
              into v_countall
              from meterread
             where mrmid <> MR.MRMID
               and MRIFREC <> 'Y'
               and mrmid in
                   (SELECT miid FROM METERINFO WHERE MIPRIID = MI.MIPRIID);
            IF v_countall < 1 THEN
              ----------------------------------------end
              BEGIN
                /*            SELECT MISAVING
                 INTO V_PMISAVING
                 FROM METERINFO
                WHERE MIID = MI.MIPRIID;*/
                SELECT sum(MISAVING)
                  INTO V_PMISAVING
                  FROM METERINFO
                 WHERE MIPRIID = MI.MIPRIID;

              EXCEPTION
                WHEN OTHERS THEN
                  V_PMISAVING := 0;
              END;

              --总欠费
              V_PSUMRLJE := 0;
              BEGIN
                SELECT SUM(RLJE)
                  INTO V_PSUMRLJE
                  FROM RECLIST
                 WHERE RLPRIMCODE = MI.MIPRIID
                   AND RLBADFLAG = 'N'
                   AND RLREVERSEFLAG = 'N'
                   AND RLPAIDFLAG = 'N';
              EXCEPTION
                WHEN OTHERS THEN
                  V_PSUMRLJE := 0;
              END;

              IF V_PMISAVING >= V_PSUMRLJE THEN
                --合收表
                V_RLIDLIST := '';
                V_RLJES    := 0;
                V_ZNJ      := 0;

                OPEN C_YCDK;
                LOOP
                  FETCH C_YCDK
                    INTO V_RLID, V_RLJE, V_ZNJ;
                  EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                  --预存够扣
                  IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                    V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                    V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                    V_RLJES     := V_RLJES + V_RLJE;
                    V_ZNJS      := V_ZNJS + V_ZNJ;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE C_YCDK;

                IF LENGTH(V_RLIDLIST) > 0 THEN
                  --插入PAY_PARA_TMP 表做合收表销账准备
                  DELETE PAY_PARA_TMP;

                  OPEN C_HS_METER(MI.MIPRIID);
                  LOOP
                    FETCH C_HS_METER
                      INTO V_HS_METER.MIID;
                    EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
                    V_HS_OUTJE := 0;
                    V_HS_RLIDS := '';
                    V_HS_RLJE  := 0;
                    V_HS_ZNJ   := 0;
                    SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
                           REPLACE(CONNSTR(RLID), '/', ',') || '|',
                           SUM(RLJE),
                           SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                                         NVL(RLJE, 0),
                                                         RLGROUP,
                                                         RLZNDATE,
                                                         RLSMFID,
                                                         SYSDATE))
                      INTO V_HS_OUTJE, V_HS_RLIDS, V_HS_RLJE, V_HS_ZNJ
                      FROM RECLIST RL
                     WHERE RL.RLMID = V_HS_METER.MIID
                       AND RL.RLJE > 0
                       AND RL.RLPAIDFLAG = 'N'
                          --AND RL.RLOUTFLAG = 'N'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLBADFLAG = 'N';
                    IF V_HS_RLJE > 0 THEN
                      INSERT INTO PAY_PARA_TMP
                      VALUES
                        (V_HS_METER.MIID,
                         V_HS_RLIDS,
                         V_HS_RLJE,
                         0,
                         V_HS_ZNJ);
                    END IF;
                  END LOOP;
                  CLOSE C_HS_METER;

                  V_RLIDLIST := SUBSTR(V_RLIDLIST,
                                       1,
                                       LENGTH(V_RLIDLIST) - 1);
                  V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                    MI.MISMFID, --缴费机构
                                                    'system', --收款员
                                                    V_RLIDLIST || '|', --应收流水串
                                                    NVL(V_RLJES, 0), --应收总金额
                                                    NVL(V_ZNJS, 0), --销帐违约金
                                                    0, --手续费
                                                    0, --实际收款
                                                    PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                    MI.MIPRIID, --水表资料号
                                                    'XJ', --付款方式
                                                    MI.MISMFID, --缴费地点
                                                    FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                                    'N', --是否打票  Y 打票，N不打票， R 应收票
                                                    NULL, --发票号
                                                    'N' --控制是否提交（Y/N）
                                                    );
                END IF;
              END IF;
            end if;
          ELSE
            V_RLIDLIST  := '';
            V_RLJES     := 0;
            V_ZNJ       := 0;
            V_PMISAVING := MI.MISAVING;

            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID, V_RLJE, V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --预存够扣
              IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                V_RLJES     := V_RLJES + V_RLJE;
                V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                EXIT;

              END IF;

            END LOOP;
            CLOSE C_YCDK;
            --单表
            IF LENGTH(V_RLIDLIST) > 0 THEN
              V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
              V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                MI.MISMFID, --缴费机构
                                                'system', --收款员
                                                V_RLIDLIST || '|', --应收流水串
                                                NVL(V_RLJES, 0), --应收总金额
                                                NVL(V_ZNJS, 0), --销帐违约金
                                                0, --手续费
                                                0, --实际收款
                                                PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                MI.MIID, --水表资料号
                                                'XJ', --付款方式
                                                MI.MISMFID, --缴费地点
                                                FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                                'N', --是否打票  Y 打票，N不打票， R 应收票
                                                NULL, --发票号
                                                'N' --控制是否提交（Y/N）
                                                );
            END IF;
          END IF;

        END IF;

      END IF;

    END IF;

    --add 2013.01.16      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF 是否审批算费 = 'N' THEN
          IF MR.MRMEMO = '换表余量欠费' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;

          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */

    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --取本期水量（抄量）
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR,
           --zhw-------------------start
           MIYL11      = to_date(rl.rljtsrq, 'yyyy.mm')
           ------------------------------end
     WHERE CURRENT OF C_MI;

    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
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
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
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
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           ) AS
  BEGIN
    --将领用的余量信息转到历史
    INSERT INTO METERADDSLHIS
      SELECT MASID,
             MASSCODEO,
             MASECODEN,
             MASUNINSDATE,
             MASUNINSPER,
             MASCREDATE,
             MASCID,
             MASMID,
             MASSL,
             MASCREPER,
             MASTRANS,
             MASBILLNO,
             MASSCODEN,
             MASINSDATE,
             MASINSPER,
             P_MRID
        FROM METERADDSL T
       WHERE MASID = P_MASID;
    --删除当前余量信息
    DELETE METERADDSL T WHERE MASID = P_MASID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;

  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----历史价格体系
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD     PRICEMULTIDETAIL%ROWTYPE;
    PD      PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    RDTAB   RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量   NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_表的验效数量   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);

  BEGIN
    --
    --yujia  2012-03-20
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL;
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      RL.RLPRIMCODE     := MR.MRPRIMID; --记录合收子表串
      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --应收帐分组

      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
      --表的调整量/ 表费的调整量 /表费项目调整量
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;

      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

        --取水价  11 --周期性单价  按水表+价格类别

        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;

        --按水表+价格类别 调整量
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;

        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);

        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;

        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --水价调整 按水表+价格类别+费用项目
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --计算调整

            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;

            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);

            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量, --效验数量
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    v_表的调整量 /v_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量

        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;

          --取水价  11 --周期性单价  按水表+价格类别

          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
          end if;

          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;

          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);

          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;

          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

              --水价调整 按水表+价格类别+费用项目
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;

              --水价调整 按水表+价格类别+费用项目
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;

              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;

              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      -- RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --合收表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;

      --插入帐务
      --垃圾费基本数据
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 做为打印的预留

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAILNP VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLISTNP VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
              IF MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT MISAVING
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIID = MI.MIPRIID;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PMISAVING := 0;
                END;
                --合收表
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIPRIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              END IF;

            END IF;*/

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLISTNP VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;

        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          VRD := RDTAB(I);

          IF 是否审批算费 = 'N' THEN
            INSERT INTO RECDETAILNP VALUES VRD;
          ELSE
            INSERT INTO RECDETAILTEMP VALUES VRD;
          END IF;
        END LOOP;

        --INSRD(RDTAB);
        --预存自动扣款
        /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
          IF MI.MIPRIID IS NOT NULL THEN
            V_PMISAVING := 0;
            BEGIN
              SELECT MISAVING
                INTO V_PMISAVING
                FROM METERINFO
               WHERE MIID = MI.MIPRIID;
            EXCEPTION
              WHEN OTHERS THEN
                V_PMISAVING := 0;
            END;
            --合收表
            IF V_PMISAVING >= RL.RLJE THEN
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --销帐违约金
                                              0, --手续费
                                              0, --实际收款
                                              PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                              MI.MIPRIID, --水表资料号
                                              'XJ', --付款方式
                                              MI.MISMFID, --缴费地点
                                              FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                              'N', --是否打票  Y 打票，N不打票， R 应收票
                                              NULL, --发票号
                                              'N' --控制是否提交（Y/N）
                                              );
            END IF;
          ELSE
            --单表
            IF MI.MISAVING >= RL.RLJE THEN

              V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --饰ピ冀？                                              0, --手续费
                                              0, --实际收款
                                              PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                              MI.MIID, --水表资料号
                                              'XJ', --付款方式
                                              MI.MISMFID, --缴费地点
                                              FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                              'N', --是否打票  Y 打票，N不打票， R 应收票
                                              NULL, --发票号
                                              'N' --控制是否提交（Y/N）
                                              );
            END IF;
          END IF;
          \*PG_EWIDE_PAY_01.SP_RLSAVING(mi,
          RL,
          fgetsequence('ENTRUSTLOG'),
          mi.mismfid,
          'system',
          'XJ',
          mi.mismfid,
          0,
          PG_ewide_PAY_01.PAYTRANS_预存抵扣,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;

    END IF;

    --add 2013.01.16      向reclist_charge_01表中插入数据
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF 是否审批算费 = 'N' THEN
          IF MR.MRMEMO = '换表余量欠费' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;

          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */

    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --取本期水量（抄量）
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR
     WHERE CURRENT OF C_MI;

    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
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
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
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
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --匹配计费调整记录
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE) IS
    CURSOR C_PAL IS
      SELECT *
        FROM PRICEADJUSTLIST
       WHERE PALSTATUS = 'Y'
         AND PALSTARTMON <= P_MONTH
         AND (PALENDMON IS NULL OR PALENDMON >= P_MONTH)
         AND ((PALTACTIC = '02' AND PALMID = P_MID AND P_TYPE = '仅按水表') OR --仅按水表
             (PALTACTIC = '07' AND PALMID = P_MID AND PALPFID = P_PFID AND
             P_TYPE = '按水表+价格类别') OR --按水表+价格类别
             (PALTACTIC = '09' AND PALMID = P_MID AND PALPFID = P_PFID AND
             PALPIID = P_PIID AND P_TYPE = '按水表+价格类别+费用项目') --按水表+价格类别+费用项目
             )
         and ((PALDATETYPE is null or PALDATETYPE = '0') or
             (PALDATETYPE = '1' and
             instr(PALMONTHSTR, substr(P_MONTH, 6)) > 0) or
             (PALDATETYPE = '2' and instr(PALMONTHSTR, P_MONTH) > 0))
       ORDER BY PALID;

    PAL PRICEADJUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_PAL;
    LOOP
      FETCH C_PAL
        INTO PAL;
      EXIT WHEN C_PAL%NOTFOUND OR C_PAL%NOTFOUND IS NULL;
      --插入明细包
      IF PALTAB IS NULL THEN
        PALTAB := PAL_TABLE(PAL);
      ELSE
        PALTAB.EXTEND;
        PALTAB(PALTAB.LAST) := PAL;
      END IF;
    END LOOP;
    CLOSE C_PAL;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PAL%ISOPEN THEN
        CLOSE C_PAL;
      END IF;
      WLOG('查找计费预调整信息异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2) IS

    NMONTH   NUMBER(12);
    V_SMONTH VARCHAR2(20);
    V_EMONTH VARCHAR2(20);
  BEGIN
    -- IF P_策略 IN ('02', '07', '09') THEN

    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC in ('02', '07', '09') then

        --固定单价调整
        IF PALTAB(I).PALMETHOD = '01' THEN
          null; --水量无变化
        end if;

        --固定量调整
        IF PALTAB(I).PALMETHOD = '02' THEN

          /*20131206 确认：当月修改当月生效，之前的月份不累计计费调整*/
          NMONTH := 1; --计费时段月数
          /* BEGIN
            SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                           NVL(P_RL.RLPRDATE,
                                               ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                            0))
              INTO NMONTH --计费时段月数
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              NMONTH := 1;
          END;
          IF NMONTH <= 0 THEN
            NMONTH := 1; --异常周期都不算阶梯
          END IF;*/

          --增加为1 减免为-1
          IF PALTAB(I).PALWAY = 0 then
            P_减后水量值 := PALTAB(I).PALVALUE;
          else
            IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := P_减后水量值 + PALTAB(I)
                          .PALVALUE * PALTAB(I).PALWAY * NMONTH;
              END IF;
              P_调整量 := P_调整量 + PALTAB(I)
                      .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            ELSE
              P_调整量 := P_调整量 - P_减后水量值;
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := 0;
              END IF;
            end if;

          END IF;
        END IF;
        --比例调整
        IF PALTAB(I).PALMETHOD = '03' THEN
          IF P_减后水量值 +
             TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY) >= 0 THEN
            P_调整量 := P_调整量 +
                     TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY);
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I)
                                         .PALWAY);
            END IF;
          ELSE
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
        --保底调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '05' THEN
          IF P_减后水量值 >= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
        --封顶量调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '06' THEN
          IF P_减后水量值 <= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;

        --累计减免量
        IF PALTAB(I).PALMETHOD = '04' THEN
          IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY >= 0 THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            --累计量用完，更新累计量0
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            end if;
          ELSE
            --更新累计量
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_减后水量值
               WHERE PALID = PALTAB(I).PALID;
            end if;
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
      end if;
    END LOOP;

    --  END IF;
  END;

  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    p_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --p_classctl 2008.11.16增加（Y：强制不使用阶梯计费方法
    --N：计算阶梯，如果是的话）
    RD       RECDETAIL%ROWTYPE;
    MINFO    METERINFO%ROWTYPE;
    I        INTEGER;
    V_PER    INTEGER;
    V_PALSL  VARCHAR2(10);
    V_ZQ     VARCHAR2(10);
    V_MONTHS NUMBER(10);
  BEGIN

    RD.RDID       := P_RL.RLID; --流水号
    RD.RDPMDID    := P_PMDID; --混合用水分组
    RD.RDPMDSCALE := P_PMDSCALE; --混合比例
    RD.RDPIID     := PD.PDPIID; --费用项目
    RD.RDPFID     := PD.PDPFID; --费率
    RD.RDPSCID    := PD.PDPSCID; --费率明细方案
    RD.RDYSDJ     := 0; --应收单价
    RD.RDYSSL     := 0; --应收水量
    RD.RDYSJE     := 0; --应收金额

    RD.RDADJDJ    := 0; --调整单价
    RD.RDADJSL    := 0; --调整水量
    RD.RDADJJE    := 0; --调整金额
    RD.RDMETHOD   := PD.PDMETHOD; --计费方法
    RD.RDPAIDFLAG := 'N'; --销帐标志

    RD.RDMSMFID     := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH      := P_RL.RLMONTH; --帐务月份
    RD.RDMID        := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE    := NVL(PMD.PMDTYPE, '01'); --混合类别
    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --备用字段1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --备用字段2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --备用字段3

    /*    --yujia  2012-03-20
    固定金额标志   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/

    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        BEGIN
          RD.RDCLASS := 0; --阶梯级别
          RD.RDYSDJ  := PD.PDDJ; --应收单价
          RD.RDYSSL  := P_SL + p_表的验效数量 - P_混合表调整量; --应收水量

          RD.RDADJDJ := FGET调整单价(RD.RDMID, RD.RDPIID); --调整单价
          RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量; --调整水量
          RD.RDADJJE := 0; --调整金额

          RD.RDDJ := PD.PDDJ + RD.RDADJDJ; --实收单价
          RD.RDSL := P_SL + RD.RDADJSL - P_混合表调整量; --实收水量

          --计算调整
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2); --应收金额
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2); --实收金额

          /*          IF RD.RDPFID = '0102' AND 固定金额标志 = 'Y' AND RD.RDJE <= 固定金额最低值 THEN
            RD.RDJE := ROUND(固定金额最低值);
          END IF;*/

          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'dj2' THEN
        --COD单价  绍兴需求：COD单价×水量，其中COD单价＝抄见COD值即化学含氧量对应单价，与抄量有关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'je1' THEN
        --固定金额  许昌需求：比如对全市所有水表加收1元钱的水表维修费，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDJE;
          RD.RDYSSL  := 0;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDJE;
          RD.RDSL    := 0;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整

                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;

          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          --p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid='01' then rd.rdsl else 0 end);
        END;
      WHEN 'sl1' THEN
        --固定单价、用量  许昌需求：包月用户，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := PD.PDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := PD.PDSL;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2);
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          /*lgb tm 20120412*/
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'sl2' THEN
        --固定单价、用量/户口  承德需求：楼户 按3吨/人月计算；平房 按2吨/人月计算，与抄量无关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'sl3' THEN
        -- raise_application_error(errcode, '阶梯水价');
        --阶梯计费  简单模式阶梯水价

        RD.RDYSSL  := P_SL - P_混合表调整量;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_混合表调整量;
        /*          rd.rdsl    := p_sl  ;*/
        BEGIN
          --计算调整

          --阶梯计费
          CALSTEP(P_RL,
                  RD.RDYSSL,
                  RD.RDADJSL,
                  P_PMDID,
                  P_PMDSCALE,
                  PD,
                  RDTAB,
                  P_CLASSCTL,
                  PMD,
                  P_NY);

          /* --阶梯计费
          calstep(p_rl,
                  rd.rdsl,
                  rd.rdadjsl,
                  p_pmdid,
                  p_pmdscale,
                  pd,
                  rdtab,
                  p_classctl);*/

        END;
      WHEN 'njf' THEN
        --与水量有关，小于等于X吨收固定Y元，大于X吨收固定Z元(苏州吴中需求)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        if minfo.miusenum is null or minfo.miusenum = 0 then
             v_per := 1;
           else
             v_per := nvl(to_number(minfo.miusenum), 1);
           end if;*/

        -- yujia 20120208  垃圾费从2012年一月份开始征收

        IF P_RL.RLPRDATE < TO_DATE('20120101', 'YYYY-MM-DD') THEN
          P_RL.RLPRDATE := TO_DATE('20120101', 'YYYY-MM-DD');
        END IF;

        IF P_RL.RLPRDATE IS NULL THEN
          V_MONTHS := 1;
        ELSE
          BEGIN
            SELECT NVL(MONTHS_BETWEEN(TRUNC(P_RL.RLRDATE, 'mm'),
                                      NVL(TRUNC(P_RL.RLPRDATE, 'mm'),
                                          ADD_MONTHS(TRUNC(P_RL.RLRDATE, 'mm'),
                                                     -1))),
                       0)
              INTO V_MONTHS --计费时段月数
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              V_MONTHS := 1;
          END;

          /*  --v_months := months_between(to_date(to_char(p_rl.RLRDATE,'yyyy.mm')), to_date(to_char(p_rl.RLPRDATE,'yyyy.mm')));
          v_months := trunc(months_between(p_rl.RLRDATE, p_rl.RLPRDATE));*/

        END IF;

        IF V_MONTHS < 1 THEN
          V_MONTHS := 1;
        END IF;

        /*  if minfo.miifmp = 'N' and minfo.mipfid in ('A1', 'A2') and
           minfo.MISTID = '30' then
          v_per    := 1;
          v_months := 2;
        end if;*/

        ---yujia [20120208 默认为一户]
        BEGIN
          V_PER := TO_NUMBER(MINFO.MIGPS);
          IF V_PER < 0 THEN
            V_PER := 0;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            V_PER := 0;
        END;

        IF V_PER >= 1 AND MINFO.MIIFMP = 'N' AND
           MINFO.MIPFID IN ('A1', 'A2') AND MINFO.MISTID = '30' AND
           P_RL.RLREADSL > 0 THEN
          RD.RDYSDJ := 垃圾费单价;
          RD.RDYSSL := V_PER * V_MONTHS;
          RD.RDYSJE := 垃圾费单价 * V_PER * V_MONTHS;

          RD.RDDJ    := 垃圾费单价;
          RD.RDSL    := V_PER * V_MONTHS;
          RD.RDJE    := 垃圾费单价 * V_PER * V_MONTHS;
          RD.RDADJDJ := 0;
          --  RD.RDADJSL := 0;
          -- modify by hb 20140703 明细调整水量等于reclist调整水量
          RD.RDADJSL := P_RL.Rladdsl;
          RD.RDADJJE := 0;

        ELSE
          RD.RDYSDJ := 0;
          RD.RDYSSL := 0;
          RD.RDYSJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
        END IF;

        ----$$$$$$$$$$$$$$$$$$$$$$$$4
        IF RD.RDJE > 0 THEN
          --插入明细包

          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END IF;
        --汇总
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持的计费方法' || PD.PDMETHOD);
    END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      WLOG(P_RL.RLCCODE || '计算费用项目费用异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

prompt
prompt Creating package body PG_EWIDE_RAEDPLAN_01
prompt ==========================================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_EWIDE_RAEDPLAN_01" IS

  --水量波动检查（哈尔滨）
  PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2, /*流水号*/
                             P_MRSL      IN NUMBER, /*用水量*/
                             O_SUBCOMMIT OUT VARCHAR2) AS
    /*返回结果*/
    V_SCALE_H     NUMBER(10); --超上限比例
    V_SCALE_L     NUMBER(10); --超下限比例
    V_USE_H       NUMBER(10); --超上限相对用量
    V_USE_L       NUMBER(10); --超下限相对用量
    V_TOTAL_H     NUMBER(10); --超上限绝对用量
    V_TOTAL_L     NUMBER(10); --超下限绝对用量
    V_CODE        VARCHAR2(10); --客户代码
    V_PFID        VARCHAR2(10); --用水性质
    V_THREEMONAVG NUMBER(10); --前三月抄表水量
  BEGIN
    O_SUBCOMMIT := '0';
    --查询出该次抄表的客户代码
    SELECT MRMID INTO V_CODE FROM BS_METERREAD WHERE MRID = P_MRMID;
    --获得该用户前三月均量
    SELECT MRTHREESL
      INTO V_THREEMONAVG
      FROM BS_METERREAD
     WHERE MRID = P_MRMID;
    --获得该用户的用水类别
    SELECT MIPFID INTO V_PFID FROM BS_METERINFO WHERE MIID = V_CODE;
    BEGIN
      --查出该用水类别的波动规则
      SELECT SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
        INTO V_SCALE_H, --超上限比例
             V_SCALE_L, --超下限比例
             V_USE_H, --超上限相对用量
             V_USE_L, --超下限相对用量
             V_TOTAL_H, --超上限绝对用量
             V_TOTAL_L --超下限绝对用量
        FROM CHK_METERREAD
       WHERE USETYPE = V_PFID;
    EXCEPTION
      WHEN OTHERS THEN
        V_SCALE_H := 0; --超上限比例
        V_SCALE_L := 0; --超下限比例
        V_USE_H   := 0; --超上限相对用量
        V_USE_L   := 0; --超下限相对用量
        V_TOTAL_H := 0; --超上限绝对用量
        V_TOTAL_L := 0; --超下限绝对用量
    END;
    IF P_MRSL IS NOT NULL THEN
      --如果绝对用量 不为空
      IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
        IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
           P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
      --如果相对用量 限制不为空
      IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
        IF P_MRSL > V_THREEMONAVG + V_USE_H OR
           P_MRSL < V_THREEMONAVG - V_USE_L THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
      --如果相对用量 限制不为空
      IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
        IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
    END IF;
  END;

END;
/

prompt
prompt Creating package body PG_INSERT
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_INSERT IS

  --表册信息插入
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --起始编码号
                           I_BFID_END   IN VARCHAR2,  --结束编码号
                           I_BFSMFID    IN VARCHAR2,  --营销公司
                           I_BFBATCH    IN VARCHAR2,    --抄表批次
                           I_BFPID      IN VARCHAR2,  --上级编码
                           I_BFCLASS    IN VARCHAR2,  --级次
                           I_BFFLAG     IN VARCHAR2,  --末级标志
                           I_BFMEMO     IN VARCHAR2,  --备注
                           I_OPER       IN VARCHAR2,  --操作人
                           I_BFRCYC     IN VARCHAR2,  --抄表周期
                           I_BFLB       IN VARCHAR2,  --表册类别
                           I_BFRPER     IN VARCHAR2,  --抄表员
                           I_BFSAFID    IN VARCHAR2,  --区域
                           I_BFNRMONTH  IN VARCHAR2,  --下次抄表月份
                           I_BFDAY      IN VARCHAR2,  --偏移天数
                           I_BFSDATE    IN VARCHAR2,  --计划起始日期
                           I_BFEDATE    IN VARCHAR2,  --计划结束日期
                           I_BFPPER     IN VARCHAR2,  --收费员
                           I_BFJTSNY    IN VARCHAR2,  --阶梯开始月
                           O_RETURN     OUT VARCHAR2, --返回重复编号
                           O_STATE      OUT NUMBER) IS--返回执行状态或数量
    V_SL    VARCHAR2(1000);
    V_COUNT VARCHAR2(1000);
  BEGIN
    V_SL     := I_BFID_START;
    O_RETURN := '';
    WHILE I_BFID_END >= V_SL LOOP
      SELECT COUNT(*) INTO V_COUNT FROM BS_BOOKFRAME WHERE BFID = V_SL;
      IF V_COUNT <> 0 THEN
        O_RETURN := O_RETURN || V_SL || ',';
      END IF;
      V_SL := V_SL + 1;
    END LOOP;
    V_SL := I_BFID_START;
    IF O_RETURN IS NULL THEN
      WHILE I_BFID_END >= V_SL LOOP
        INSERT INTO BS_BOOKFRAME 
        (BFID,    --编码
        BFSMFID,  --营销公司
        BFBATCH,  --抄表批次
        BFNAME,   --名称
        BFPID,    --上级编码
        BFCLASS,  --级次
        BFFLAG,   --末级标志
        BFSTATUS, --有效状态
        BFMEMO,   --备注
        BFORDER,  --册间次序
        BFCREPER, --创建人
        BFCREDATE,--创建日期
        BFRCYC,   --抄表周期
        BFLB,     --表册类别
        BFRPER,   --抄表员
        BFSAFID,  --区域
        BFNRMONTH,--下次抄表月份
        BFDAY,    --偏移天数
        BFSDATE,  --计划起始日期
        BFEDATE,  --计划结束日期
        BFPPER,   --收费员
        BFJTSNY,  --阶梯开始月
        BFTYPE)   --表册状态
        VALUES 
        (V_SL,      --编码
        I_BFSMFID,  --营销公司
        TO_NUMBER(I_BFBATCH),  --抄表批次
        V_SL,       --名称
        I_BFPID,    --上级编码
        TO_NUMBER(I_BFCLASS),  --级次
        I_BFFLAG,   --末级标志
        'Y',        --有效状态
        I_BFMEMO,   --备注
        '0',        --册间次序
        I_OPER,     --创建人
        SYSDATE,    --创建日期
        TO_NUMBER(I_BFRCYC),   --抄表周期
        I_BFLB,     --表册类别
        I_BFRPER,   --抄表员
        I_BFSAFID,  --区域
        I_BFNRMONTH,--下次抄表月份
        TO_NUMBER(I_BFDAY),    --偏移天数
        TO_DATE(I_BFSDATE,'YYYY/MM/DD'),  --计划起始日期
        TO_DATE(I_BFEDATE,'YYYY/MM/DD'),  --计划结束日期
        I_BFPPER,   --收费员
        I_BFJTSNY,  --阶梯开始月
        '0');       --表册状态
        V_SL := V_SL + 1;
      END LOOP;
      O_STATE := TO_NUMBER(I_BFID_END - I_BFID_START + 1);
      COMMIT;
    ELSE
      O_STATE := '-1';
    END IF;
    IF LENGTH(O_RETURN) <> 0 THEN
      O_RETURN := SUBSTR(O_RETURN, 1, LENGTH(O_RETURN) - 1);
    END IF;
  END;
END;
/

prompt
prompt Creating package body PG_METERTRANS
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_METERTRANS IS

  --周期换表、拆表、故障换表
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --操作类型
                            P_MTHNO  IN VARCHAR2, --批次流水
                            P_PER    IN VARCHAR2, --操作员
                            P_COMMIT IN VARCHAR2 --提交标志
                            ) AS
    MF REQUEST_CB%ROWTYPE;
    MK REQUEST_GZHB%ROWTYPE;
    ML REQUEST_ZQGZ%ROWTYPE;
  BEGIN
    IF P_TYPE IN ('L') THEN
      --周期换表
      BEGIN
        SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '周期换表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = ML.MDNO;
        /*        --现用表状态更新,去掉倒表标志
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE,
               IFDZSB   = 'N'
         WHERE MDNO = ML.MDNO;*/
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = ML.MDNO;
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = ML.MDNO
           AND FHSTATUS = '1';
        --新表状态、水表档案号更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = ML.MIID
         WHERE MDNO = ML.NEWMDNO;
        --故障换表后为正常户
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = ML.MIID;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_ZQGZ
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('F') THEN
      --拆表
      BEGIN
        SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_CB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '拆表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MF.MDNO;
        /*        UPDATE BS_METERDOC
          SET MDSTATUS = '0',
              MDID     = '',
              MAINMAN  = P_PER,
              MAINDATE = SYSDATE
        WHERE MDNO = MF.MDNO;*/
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = MF.MDNO;
        --更新户表信息为作废
        --暂未确定 等待确定
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '拆表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE A.MIID = MF.MIID;
        /*        UPDATE BS_METERINFO T
          SET T.MISTATUS = '40' --, T.MICOLUMN5 = NULL
        WHERE T.MIID = MF.MIID;*/
        --正事表中删除旧户表
        DELETE FROM BS_METERINFO A WHERE A.MIID = MF.MIID;
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MF.MDNO
           AND FHSTATUS = '1';
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_CB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      --故障换表
      BEGIN
        SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '工单信息不存在!');
      END;

      FOR V_CURSOR IN (SELECT * FROM REQUEST_GZHB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '工单明细信息不存在!');
        END;
        --插入一条旧表记录作为历史状态用
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '故障换表' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MK.MDNO;
        --正事表中删除旧表
        DELETE FROM BS_METERDOC WHERE MDNO = MK.MDNO;
        /*        --现用表状态更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MK.MDNO;*/
        --销户拆表旧表所有封号作废
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MK.MDNO
           AND FHSTATUS = '1';
        --新表状态、水表档案号更新
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = MK.MIID
         WHERE MDNO = MK.NEWMDNO;
        --重置正常表态
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MK.MIID;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_GZHB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --撤表销户简单的销户操作 不考虑财务
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --批次流水
                                 I_PER   IN VARCHAR2, --操作员
                                 O_STATE OUT NUMBER) IS
    --执行状态
    MX     REQUEST_XH%ROWTYPE;
    V_LINA VARCHAR2(30);
    V_LINB VARCHAR2(100);
  BEGIN
    O_STATE := 0;
    SELECT * INTO MX FROM REQUEST_XH WHERE RENO = I_RENO;
    FOR I IN (SELECT * FROM BS_METERINFO A WHERE A.MICODE = MX.CIID) LOOP
      V_LINA := SYS_GUID();
      SELECT MDNO INTO V_LINB FROM BS_METERDOC WHERE MDID = I.MIID;
      INSERT INTO REQUEST_CB
        (RENO, MDNO, MIID)
        SELECT V_LINA, V_LINB, I.MIID FROM DUAL;
      PG_METERTRANS.SP_CHEBIAOTRANS('F', V_LINA, I_PER, 'Y');
      DELETE FROM REQUEST_CB WHERE RENO = V_LINA;
    END LOOP;
    --0.插入历史记录
    INSERT INTO BS_METERINFO_HIS
      SELECT A.*, '销户' GDLX, I_RENO GDID, SYSDATE GDSJ
        FROM BS_METERINFO A
       WHERE MICODE = MX.CIID;
    --1.更新METERINFO主表状态
    UPDATE BS_METERINFO
       SET MISTATUS      = '7', --销户状态
           MISTATUSDATE  = SYSDATE,
           MISTATUSTRANS = '0',
           MIUNINSDATE   = SYSDATE
     WHERE MICODE = MX.CIID;
    --2.销户后同步用户状态
    UPDATE BS_CUSTINFO
       SET CISTATUS = '7', CISTATUSDATE = SYSDATE, CISTATUSTRANS = '0'
     WHERE CIID = MX.CIID;
    --3.更新工单完成状态
    UPDATE REQUEST_XH
       SET MODIFYDATE   = SYSDATE,
           MODIFYUSERID = I_PER,
           MTDFLAG      = 'Y'
     WHERE RENO = I_RENO;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  /*  --工单单个审核过程
    PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                               P_PERSON IN VARCHAR2, -- 操作员
                               P_MD     IN REQUEST_GZHB%ROWTYPE --单体行变更
                               ) AS
      MH REQUEST_GZHB%ROWTYPE;
      MD REQUEST_GZHB%ROWTYPE;
      MI BS_METERINFO%ROWTYPE;
      CI BS_CUSTINFO%ROWTYPE;
      MC BS_METERDOC%ROWTYPE;
      MA BS_METERREAD%ROWTYPE;

      V_MRMEMO     BS_METERREAD.MRMEMO%TYPE;
      V_COUNT      NUMBER(4);
      V_COUNTMRID  NUMBER(4);
      V_COUNTFLAG  NUMBER(4);
      V_NUMBER     NUMBER(10);
      V_RCODE      NUMBER(10);
      V_CRHNO      VARCHAR2(10);
      V_OMRID      VARCHAR2(20);
      O_STR        VARCHAR2(20);
      O_STATE      VARCHAR2(20);
      V_METERSTORE SYS_DICT_DATA%ROWTYPE;
      O_OUT        BS_METERREAD%ROWTYPE;

      --未算费抄表记录
      CURSOR CUR_METERREAD_NOCALC(P_MRMID VARCHAR2, P_MRMONTH VARCHAR2) IS
        SELECT *
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MRMID
           AND MR.MRMONTH = P_MRMONTH;

    BEGIN
      BEGIN
        SELECT * INTO MI FROM BS_METERINFO WHERE MIID = P_MD.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
      END;
      BEGIN
        SELECT * INTO CI FROM BS_CUSTINFO WHERE BS_CUSTINFO.CIID = MI.MICODE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
      END;
      BEGIN
        SELECT *
          INTO MC
          FROM BS_METERDOC
         WHERE MDID = P_MD.MIID
           AND IFOLD = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
      END;

      BEGIN
        SELECT MDSTATUS
          INTO V_METERSTORE.DICT_VALUE
          FROM BS_METERDOC A
         WHERE MDNO = P_MD.NEWMDNO
           AND A.IFOLD = 'N';

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTORE.DICT_VALUE) <> '0' THEN
        SELECT A.DICT_LABEL
          INTO V_METERSTORE.DICT_LABEL
          FROM SYS_DICT_DATA A
         WHERE A.DICT_TYPE = 'sys_meterusestatus'
           AND A.DICT_VALUE = V_METERSTORE.DICT_VALUE;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MIID || '该水表状态为【' ||
                                V_METERSTORE.DICT_LABEL || '】不能使用！');
      END IF;

      --F销户拆表
      IF P_TYPE = BT拆表 THEN
        -- BS_METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = BT拆表,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIUNINSDATE   = SYSDATE,
               MIBFID        = NULL -- BY 20170904 WLJ 销户拆表将表册置空
         WHERE MIID = P_MD.MIID;

        ---销户拆表收取余量水费（在去掉低度之前）
        --STEP1 插入抄表记录

        \*      --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;*\
        ----增加拆表数据的实时型
        BEGIN
          PG_RAEDPLAN.CREATECBGD(MI.MIID, O_STATE);
          IF O_STATE = '0' THEN
            SELECT MAX(MRID)
              INTO O_STATE
              FROM BS_METERREAD A
             WHERE A.MRMID = MI.MIID;
            PG_CB_COST.CALCULATEBF(O_STATE,
                                   '02',
                                   O_OUT.MRRECJE01,
                                   O_OUT.MRRECJE02,
                                   O_OUT.MRRECJE03,
                                   O_OUT.MRRECJE04,
                                   O_OUT.MRMEMO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        ---- METERINFO 有效状态 --状态日期 --状态表务 【YUJIA 20110323】
        UPDATE BS_METERDOC
           SET MDSTATUS = '4', MDID = MI.MIID, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';
  \*      -----METERDOC  表状态 表状态发生时间  【YUJIA 20110323】

        UPDATE BS_METERDOC
           SET MDSTATUS = M销户, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';*\

      ELSIF P_TYPE = BT口径变更 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER, --换表人
               MIBFID        = NULL
         WHERE MIID = P_MD.MIID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户,
               MDCALIBER    = P_MD.MTDCALIBERN,
               MDNO         = P_MD.MTDMNON, ---表型号
               MDSTATUSDATE = SYSDATE,
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
        ------表身码状态改变    旧表状态
        UPDATE BS_METERDOC
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费？？？

      ELSIF P_TYPE = BT换阀门 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
        --
      ELSIF P_TYPE = BT欠费停水 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M欠费停水,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
      ELSIF P_TYPE = BT恢复供水 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
      ELSIF P_TYPE = BT报停 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M报停,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
        --
      ELSIF P_TYPE = BT校表 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSDATE   = P_MD.MTDREINSDATE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  表状态 表状态发生时间
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户,
               MDSTATUSDATE = SYSDATE,
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
      ELSIF P_TYPE = BT复装 THEN
        --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户, --状态
               MISTATUSDATE  = SYSDATE, --状态日期
               MISTATUSTRANS = P_TYPE, --状态表务
               MIADR         = P_MD.MTDMADRN, --水表地址
               MISIDE        = P_MD.MTDSIDEN, --表位
               MIPOSITION    = P_MD.MTDPOSITIONN, --水表接水地址
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER --换表人
         WHERE MIID = P_MD.MTDMID;
        --METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDMODEL      = P_MD.MTDMODELN, --表型号
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;

        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        --算费
      ELSIF P_TYPE = BT故障换表 THEN
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --已抄表
           AND MR.MRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '【' || P_MD.MTDMID ||
                                  '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        END IF;

        UPDATE BS_METERREAD T
           SET MRSCODE = P_MD.MTDREINSCODE --BY RALPH 20151021  增加的将未抄见指针更换掉
         WHERE MRMID = P_MD.MTDMID
           AND MRREADOK = 'N';

        --ADD 20141117 HB
        --如果故障换表为9月份开立故障换表单据一直未审核，10月份如果又有抄表算费，则不允许进行审核9月份的故障换表
        --因这样会造成初始指针错误

        ------水表量程校验与更新 ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN

          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --水表最大量程
           WHERE MIID = P_MD.MTDMID;
          --- END IF ;
        END IF;
        ----------------------------20160828

        --END ADD 20141117 HB

        --20140809 总分表故障换表 MODIBY HB
        --总表先换表、分表出账导致水量不够减，换表后不出账

        -- END 20140809 总分表故障换表 MODIBY HB
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户, --状态
               MISTATUSDATE  = SYSDATE, --状态日期
               MISTATUSTRANS = P_TYPE, --状态表务
               MIRCODE       = P_MD.MTDREINSCODE, --换表起度
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER, --换表人
               MIYL1         = 'N', --换表后将 等针标志清除(如果有) BYJ 2016.08
               MIRTID        = P_MD.MTDMIRTID --换表后 根据工单更新 抄表方式! BYJ 2016.12
         WHERE MIID = P_MD.MTDMID;

        --换表后清除等针中间表标志 BYJ 2016.08-------------
        UPDATE METERTGL MTG
           SET MTG.MTSTATUS = 'N'
         WHERE MTMID = P_MD.MTDMID
           AND MTSTATUS = 'Y';
        ---------------------------------------------------

        --METERDOC 更新新表信息
        BEGIN
          SELECT *
            INTO V_METERSTORE
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
             SET MDSTATUS     = M立户, --状态
                 MDSTATUSDATE = SYSDATE, --表状态发生时间
                 MDNO         = P_MD.MTDMNON, --表身号
                 DQSFH        = P_MD.MTDDQSFHN, --塑封号
                 DQGFH        = P_MD.MTDLFHN, --钢封号
                 QFH          = P_MD.MTDQFHN, --铅封号
                 MDCALIBER    = V_METERSTORE.CALIBER, --表口径
                 MDBRAND      = P_MD.MTDBRANDN, --表厂家
                 MDCYCCHKDATE = P_MD.MTDREINSDATE, --
                 MDMODEL      = V_METERSTORE.MODEL --表型号
           WHERE MDMID = P_MD.MTDMID;
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE BS_METERDOC
               SET MDSTATUS     = M立户, --状态
                   MDSTATUSDATE = SYSDATE, --表状态发生时间
                   MDNO         = P_MD.MTDMNON, --表身号
                   DQSFH        = P_MD.MTDDQSFHN, --塑封号
                   DQGFH        = P_MD.MTDLFHN, --钢封号
                   QFH          = P_MD.MTDQFHN, --铅封号
                   MDCALIBER    = P_MD.MTDCALIBERN, --表口径
                   MDBRAND      = P_MD.MTDBRANDN, --表厂家
                   MDCYCCHKDATE = P_MD.MTDREINSDATE --
             WHERE MDMID = P_MD.MTDMID;
        END;

        --设置塑封号为已使用
        IF P_MD.MTDDQSFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDDQSFHN
             AND STOREID = MI.MISMFID --地区
             AND CALIBER = P_MD.MTDCALIBERO --口径
             AND FHTYPE = '1';
        END IF;
        --设置钢封号为已使用
        IF P_MD.MTDLFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDLFHN
             AND STOREID = MI.MISMFID --地区
             AND FHTYPE = '2';
        END IF;
        --设置铅封号为已使用
        IF P_MD.MTDQFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDQFHN
             AND STOREID = MI.MISMFID --地区
             AND FHTYPE = '4';
        END IF;

        --【抄表审核转单】故障换表后回写复核标志
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --复核标志
                 MR.MRCHKDATE = SYSDATE, --复核日期
                 MR.MRCHKPER  = P_PERSON --复核人员

           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        BEGIN
          SELECT STATUS
            INTO V_METERSTATUS.SID
            FROM BS_METERDOC
           WHERE BSM = P_MD.MTDMNON;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        IF TRIM(V_METERSTATUS.SID) <> '2' THEN
          SELECT SNAME
            INTO V_METERSTATUS.SNAME
            FROM METERSTATUS
           WHERE SID = V_METERSTATUS.SID;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '该水表状态为【' || V_METERSTATUS.SNAME ||
                                  '】不能使用！');
        END IF;
        IF TRIM(V_METERSTATUS.SID) = '2' THEN
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
             SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
        --算费
      ELSIF P_TYPE = BT水表整改 THEN
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户, --状态
               MISTATUSDATE  = SYSDATE, --状态日期
               MISTATUSTRANS = P_TYPE, --状态表务
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER --换表人
         WHERE MIID = P_MD.MTDMID;
        --METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS     = M立户, --状态
               MDSTATUSDATE = SYSDATE, --表状态发生时间
               MDNO         = P_MD.MTDMNON, --表身号
               MDCALIBER    = P_MD.MTDCALIBERN, --表口径
               MDBRAND      = P_MD.MTDBRANDN, --表厂家
               MDMODEL      = P_MD.MTDMODELN, --表型号
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
      ELSIF P_TYPE = BT周期换表 THEN
        --以上为之前周期换表代码 MODIBY HB 20140815
        --下述为故障换表的代码放过来，原理与故障换表原理一致

        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --已抄表
           AND MR.MRIFREC <> 'Y'; --未算费
        IF V_COUNTFLAG > 0 THEN
          --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '此水表[' || P_MD.MTDMID ||
                                  ']已经抄表录入,抄见标志有打上,不能进行周期换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
        END IF;

        ------水表量程校验与更新 ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN
          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --水表最大量程
           WHERE MIID = P_MD.MTDMID;
          ---  END IF ;
        END IF;
        ----------------------------20160828

        --20140809 总分表故障换表 MODIBY HB
        --总表先换表、分表出账导致水量不够减，换表后不出账

        -- END 20140809 总分表故障换表 MODIBY HB
        -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户, --状态
               MISTATUSDATE  = SYSDATE, --状态日期
               MISTATUSTRANS = P_TYPE, --状态表务
               MIRCODE       = P_MD.MTDREINSCODE, --换表起度
               MIREINSCODE   = P_MD.MTDREINSCODE, --换表起度
               MIREINSDATE   = P_MD.MTDREINSDATE, --换表日期
               MIREINSPER    = P_MD.MTDREINSPER, --换表人
               MIYL1         = 'N', --换表后将 等针标志清除(如果有) BYJ 2016.08
               MIRTID        = P_MD.MTDMIRTID --换表后 根据工单更新 抄表方式! BYJ 2016.12
         WHERE MIID = P_MD.MTDMID;

        --换表后清除等针中间表标志 BYJ 2016.08-------------
        UPDATE METERTGL MTG
           SET MTG.MTSTATUS = 'N'
         WHERE MTMID = P_MD.MTDMID
           AND MTSTATUS = 'Y';
        ---------------------------------------------------

        --METERDOC 更新新表信息
        BEGIN
          SELECT *
            INTO V_METERSTORE
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
             SET MDSTATUS     = M立户, --状态
                 MDSTATUSDATE = SYSDATE, --表状态发生时间
                 MDNO         = P_MD.MTDMNON, --表身号
                 DQSFH        = P_MD.MTDDQSFHN, --塑封号
                 DQGFH        = P_MD.MTDLFHN, --钢封号
                 QFH          = P_MD.MTDQFHN, --铅封号
                 MDCALIBER    = V_METERSTORE.CALIBER, --表口径
                 MDBRAND      = P_MD.MTDBRANDN, --表厂家
                 MDCYCCHKDATE = P_MD.MTDREINSDATE, --
                 MDMODEL      = V_METERSTORE.MODEL --表型号
           WHERE MDMID = P_MD.MTDMID;
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE BS_METERDOC
               SET MDSTATUS     = M立户, --状态
                   MDSTATUSDATE = SYSDATE, --表状态发生时间
                   MDNO         = P_MD.MTDMNON, --表身号
                   DQSFH        = P_MD.MTDDQSFHN, --塑封号
                   DQGFH        = P_MD.MTDLFHN, --钢封号
                   QFH          = P_MD.MTDQFHN, --铅封号
                   MDCALIBER    = P_MD.MTDCALIBERN, --表口径
                   MDBRAND      = P_MD.MTDBRANDN, --表厂家
                   MDCYCCHKDATE = P_MD.MTDREINSDATE --
             WHERE MDMID = P_MD.MTDMID;
        END;

        --设置塑封号为已使用
        IF P_MD.MTDDQSFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDDQSFHN
             AND STOREID = MI.MISMFID --地区
             AND CALIBER = P_MD.MTDCALIBERO --口径
             AND FHTYPE = '1';
        END IF;
        --设置钢封号为已使用
        IF P_MD.MTDLFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDLFHN
             AND STOREID = MI.MISMFID --地区
             AND FHTYPE = '2';
        END IF;
        --设置铅封号为已使用
        IF P_MD.MTDQFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDQFHN
             AND STOREID = MI.MISMFID --地区
             AND FHTYPE = '4';
        END IF;

        --【抄表审核转单】周期换表后回写复核标志
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --复核标志
                 MR.MRCHKDATE = SYSDATE, --复核日期
                 MR.MRCHKPER  = P_PERSON --复核人员

           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;

        --记余量表 METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--记录流水号
        MA.MASSCODEO    := P_MD.MTDSCODE; --旧表起度
        MA.MASECODEN    := P_MD.MTDECODE; --旧表止度
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --拆表日期
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --拆表人
        MA.MASCREDATE   := SYSDATE; --创建日期
        MA.MASCID       := MI.MICID; --用户编号
        MA.MASMID       := MI.MIID; --水表编号
        MA.MASSL        := P_MD.MTDADDSL; --余量
        MA.MASCREPER    := P_PERSON; --创建人员
        MA.MASTRANS     := P_TYPE; --加调事务
        MA.MASBILLNO    := P_MD.MTDNO; --单据流水
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --新表起度
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --装表日期
        MA.MASINSPER    := P_MD.MTDREINSPER; --装表人
        INSERT INTO METERADDSL VALUES MA;
        BEGIN
          SELECT STATUS
            INTO V_METERSTATUS.SID
            FROM BS_METERDOC
           WHERE BSM = P_MD.MTDMNON;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        IF TRIM(V_METERSTATUS.SID) <> '2' THEN
          SELECT SNAME
            INTO V_METERSTATUS.SNAME
            FROM METERSTATUS
           WHERE SID = V_METERSTATUS.SID;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  MI.MICID || '该水表状态为【' ||
                                  V_METERSTATUS.SNAME || '】不能使用！');
        END IF;
        IF TRIM(V_METERSTATUS.SID) = '2' THEN
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
             SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        END IF;

        --算费
      ELSIF P_TYPE = BT复查工单 THEN
        NULL;
      ELSIF P_TYPE = BT改装总表 THEN
        IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
          TOOLS.SP_BILLSEQ('100', V_CRHNO);
          INSERT INTO CUSTREGHD
            (CRHNO,
             CRHBH,
             CRHLB,
             CRHSOURCE,
             CRHSMFID,
             CRHDEPT,
             CRHCREDATE,
             CRHCREPER,
             CRHSHFLAG)
          VALUES
            (V_CRHNO,
             P_MD.MTDNO,
             '0',
             P_TYPE,
             P_MD.MTDSMFID,
             NULL,
             SYSDATE,
             P_PERSON,
             'N');

          V_NUMBER := 0;
          LOOP
            INSERT INTO CUSTMETERREGDT
              (CMRDNO,
               CMRDROWNO,
               CISMFID,
               CINAME,
               CINAME2,
               CIADR,
               CISTATUS,
               CISTATUSTRANS,
               CIIDENTITYLB,
               CIIDENTITYNO,
               CIMTEL,
               CITEL1,
               CITEL2,
               CITEL3,
               CICONNECTPER,
               CICONNECTTEL,
               CIIFINV,
               CIIFSMS,
               CIIFZN,
               MIADR,
               MISAFID,
               MISMFID,
               MIRTID,
               MISTID,
               MIPFID,
               MISTATUS,
               MISTATUSTRANS,
               MIRPID,
               MISIDE,
               MIPOSITION,
               MITYPE,
               MIIFCHARGE,
               MIIFSL,
               MIIFCHK,
               MIIFWATCH,
               MICHARGETYPE,
               MILB,
               MINAME,
               MINAME2,
               CICLASS,
               CIFLAG,
               MIIFMP,
               MIIFSP,
               MIIFCKF,
               MIUSENUM,
               MISAVING,
               MIIFTAX,
               MIINSCODE,
               MIINSDATE,
               MIPRIFLAG,
               MDSTATUS,
               MAIFXEZF,
               MIRCODE,
               MDNO,
               MDMODEL,
               MDBRAND,
               MDCALIBER,
               CMDCHKPER,
               MIINSCODECHAR,
               MIPID)
            VALUES
              (V_CRHNO,
               V_NUMBER + 1,
               MI.MISMFID,
               '新用户',
               '新用户',
               CI.CIADR,
               '0',
               CI.CISTATUSTRANS,
               '1',
               CI.CIIDENTITYNO,
               P_MD.MTDTEL,
               CI.CITEL1,
               CI.CITEL2,
               CI.CITEL3,
               P_MD.MTDCONPER,
               P_MD.MTDCONTEL,
               'Y',
               'N',
               'Y',
               MI.MIADR,
               MI.MISAFID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MISTID,
               MI.MIPFID,
               '1',
               MI.MISTATUSTRANS,
               MI.MIRPID,
               P_MD.MTDSIDEO,
               P_MD.MTDPOSITIONO,
               '1',
               'Y',
               'Y',
               'N',
               'N',
               'X',
               'H',
               MI.MINAME,
               MI.MINAME2,
               1,
               'Y',
               'N',
               'N',
               'N',
               1,
               0,
               'N',
               0,
               TRUNC(SYSDATE),
               'N',
               '00',
               'N',
               P_MD.MTDREINSCODE,
               P_MD.MTDMNOO,
               P_MD.MTDMODELO,
               P_MD.MTDBRANDO,
               P_MD.MTDCALIBERO,
               P_MD.MTDCHKPER,
               '00000',
               P_MD.MTDMCODE);
            V_NUMBER := V_NUMBER + 1;
            EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
          END LOOP;
        END IF;
      ELSIF P_TYPE = BT补装户表 THEN
        IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
          TOOLS.SP_BILLSEQ('100', V_CRHNO);
          INSERT INTO CUSTREGHD
            (CRHNO,
             CRHBH,
             CRHLB,
             CRHSOURCE,
             CRHSMFID,
             CRHDEPT,
             CRHCREDATE,
             CRHCREPER,
             CRHSHFLAG)
          VALUES
            (V_CRHNO,
             P_MD.MTDNO,
             '0',
             P_TYPE,
             P_MD.MTDSMFID,
             NULL,
             SYSDATE,
             P_PERSON,
             'N');

          V_NUMBER := 0;
          LOOP
            INSERT INTO CUSTMETERREGDT
              (CMRDNO,
               CMRDROWNO,
               CISMFID,
               CINAME,
               CINAME2,
               CIADR,
               CISTATUS,
               CISTATUSTRANS,
               CIIDENTITYLB,
               CIIDENTITYNO,
               CIMTEL,
               CITEL1,
               CITEL2,
               CITEL3,
               CICONNECTPER,
               CICONNECTTEL,
               CIIFINV,
               CIIFSMS,
               CIIFZN,
               MIADR,
               MISAFID,
               MISMFID,
               MIRTID,
               MISTID,
               MIPFID,
               MISTATUS,
               MISTATUSTRANS,
               MIRPID,
               MISIDE,
               MIPOSITION,
               MITYPE,
               MIIFCHARGE,
               MIIFSL,
               MIIFCHK,
               MIIFWATCH,
               MICHARGETYPE,
               MILB,
               MINAME,
               MINAME2,
               CICLASS,
               CIFLAG,
               MIIFMP,
               MIIFSP,
               MIIFCKF,
               MIUSENUM,
               MISAVING,
               MIIFTAX,
               MIINSCODE,
               MIINSDATE,
               MIPRIFLAG,
               MDSTATUS,
               MAIFXEZF,
               MIRCODE,
               MDNO,
               MDMODEL,
               MDBRAND,
               MDCALIBER,
               CMDCHKPER,
               MIINSCODECHAR,
               MIPID)
            VALUES
              (V_CRHNO,
               V_NUMBER + 1,
               MI.MISMFID,
               '新用户',
               '新用户',
               CI.CIADR,
               '0',
               CI.CISTATUSTRANS,
               '1',
               CI.CIIDENTITYNO,
               P_MD.MTDTEL,
               CI.CITEL1,
               CI.CITEL2,
               CI.CITEL3,
               P_MD.MTDCONPER,
               P_MD.MTDCONTEL,
               'Y',
               'N',
               'Y',
               MI.MIADR,
               MI.MISAFID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MISTID,
               MI.MIPFID,
               '1',
               MI.MISTATUSTRANS,
               MI.MIRPID,
               P_MD.MTDSIDEO,
               P_MD.MTDPOSITIONO,
               '1',
               'Y',
               'Y',
               'N',
               'N',
               'X',
               'H',
               MI.MINAME,
               MI.MINAME2,
               1,
               'Y',
               'N',
               'N',
               'N',
               1,
               0,
               'N',
               0,
               TRUNC(SYSDATE),
               'N',
               '00',
               'N',
               P_MD.MTDREINSCODE,
               P_MD.MTDMNOO,
               P_MD.MTDMODELO,
               P_MD.MTDBRANDO,
               P_MD.MTDCALIBERO,
               P_MD.MTDCHKPER,
               '00000',
               P_MD.MTDMPID);
            V_NUMBER := V_NUMBER + 1;
            EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
          END LOOP;
        END IF;
      ELSIF P_TYPE = BT安装分类计量表 THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);

        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        INSERT INTO CUSTMETERREGDT
          (CMRDNO,
           CMRDROWNO,
           CISMFID,
           CINAME,
           CINAME2,
           CIADR,
           CISTATUS,
           CISTATUSTRANS,
           CIIDENTITYLB,
           CIIDENTITYNO,
           CIMTEL,
           CITEL1,
           CITEL2,
           CITEL3,
           CICONNECTPER,
           CICONNECTTEL,
           CIIFINV,
           CIIFSMS,
           CIIFZN,
           MIADR,
           MISAFID,
           MISMFID,
           MIRTID,
           MISTID,
           MIPFID,
           MISTATUS,
           MISTATUSTRANS,
           MIRPID,
           MISIDE,
           MIPOSITION,
           MITYPE,
           MIIFCHARGE,
           MIIFSL,
           MIIFCHK,
           MIIFWATCH,
           MICHARGETYPE,
           MILB,
           MINAME,
           MINAME2,
           CICLASS,
           CIFLAG,
           MIIFMP,
           MIIFSP,
           MIIFCKF,
           MIUSENUM,
           MISAVING,
           MIIFTAX,
           MIINSCODE,
           MIINSDATE,
           MIPRIFLAG,
           MDSTATUS,
           MAIFXEZF,
           MIRCODE,
           MDNO,
           MDMODEL,
           MDBRAND,
           MDCALIBER,
           CMDCHKPER,
           MIINSCODECHAR)
        VALUES
          (V_CRHNO,
           1,
           MI.MISMFID,
           '新用户',
           '新用户',
           CI.CIADR,
           '0',
           CI.CISTATUSTRANS,
           '1',
           CI.CIIDENTITYNO,
           P_MD.MTDTEL,
           CI.CITEL1,
           CI.CITEL2,
           CI.CITEL3,
           P_MD.MTDCONPER,
           P_MD.MTDCONTEL,
           'Y',
           'N',
           'Y',
           MI.MIADR,
           MI.MISAFID,
           MI.MISMFID,
           MI.MIRTID,
           MI.MISTID,
           MI.MIPFID,
           '1',
           MI.MISTATUSTRANS,
           MI.MIRPID,
           P_MD.MTDSIDEO,
           P_MD.MTDPOSITIONO,
           '1',
           'Y',
           'Y',
           'N',
           'N',
           'X',
           'D',
           MI.MINAME,
           MI.MINAME2,
           1,
           'Y',
           'N',
           'N',
           'N',
           1,
           0,
           'N',
           0,
           TRUNC(SYSDATE),
           'N',
           '00',
           'N',
           P_MD.MTDREINSCODE,
           P_MD.MTDMNOO,
           P_MD.MTDMODELO,
           P_MD.MTDBRANDO,
           P_MD.MTDCALIBERO,
           P_MD.MTDCHKPER,
           '00000');
      ELSIF P_TYPE = BT水表升移 THEN
        -- METERINFO 有效状态 --状态日期 --状态表务
        UPDATE BS_METERINFO
           SET MISTATUS      = M立户,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIPOSITION    = P_MD.MTDPOSITIONN
         WHERE MIID = P_MD.MTDMID;
        -- METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB 回滚换表日期 回滚水表状态
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE

         WHERE MTDMID = MI.MIID;

        --记余量表 METERADDSL
        --算费
      END IF;
      --库存管理开关
      IF FSYSPARA('sys4') = 'Y' THEN
        --更新新表状态
        UPDATE BS_METERDOC
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        IF P_TYPE = BT拆表 OR P_TYPE = BT报停 OR P_TYPE = BT欠费停水 OR P_TYPE = BT复装 OR
           P_TYPE = BT换阀门 OR P_TYPE = BT水表整改 THEN
          --更新旧表状态
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        ELSE
          --更新旧表状态
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE,
                 MIID       = NULL
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
      END IF;

      --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
      IF FSYSPARA('1102') = 'Y' THEN
        IF P_TYPE = BT周期换表 THEN
          --余量大于0 进行算费
          --20140520 余量算费增加调整水量
          --将余量添加抄表库METERREAD
          V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
          SP_INSERTMR(P_PERSON,
                      TO_CHAR(SYSDATE, 'yyyy.mm'),
                      'L',
                      P_MD.MTDADDSL,
                      P_MD.MTDSCODE,
                      P_MD.MTDECODE,
                      P_MD.MTCARRYSL,
                      MI,
                      V_OMRID);
        ELSE
          --余量大于0 进行算费
          --20140520 余量算费增加调整水量
          --将余量添加抄表库METERREAD
          V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
          SP_INSERTMR(P_PERSON,
                      TO_CHAR(SYSDATE, 'yyyy.mm'),
                      'M',
                      P_MD.MTDADDSL,
                      P_MD.MTDSCODE,
                      P_MD.MTDECODE,
                      P_MD.MTCARRYSL,
                      MI,
                      V_OMRID);
        END IF;

        IF P_MD.MTDADDSL > 0 AND P_MD.MTDADDSL IS NOT NULL THEN
          IF V_OMRID IS NOT NULL THEN
            --返回流水不等于空，添加成功

            --算费
            PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

            --将之前余用掉
            PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --抄表流水
                                                MA.MASID, --余量流水
                                                O_STR --返回值
                                                );

            --更新换表止码
            IF P_TYPE IN (BT故障换表, BT周期换表) THEN
              UPDATE BS_METERINFO
                 SET MIRCODE     = P_MD.MTDREINSCODE, --换表起度
                     MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
               WHERE MIID = P_MD.MTDMID;
            END IF;

            -- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
            FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                               TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
              IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
                DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
              END IF;
            END LOOP;

            INSERT INTO BS_METERREADHIS
              SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
            DELETE BS_METERREAD WHERE MRID = V_OMRID;
          END IF;
        ELSIF P_MD.MTDADDSL = 0 OR P_MD.MTDADDSL IS NULL THEN
          --20140512 换表后如果当月有未算费的正常抄表记录，则更新起码
          IF P_TYPE = BT故障换表 THEN
            V_MRMEMO := '故障换表重置指针';
          ELSIF P_TYPE = BT周期换表 THEN
            V_MRMEMO := '周期换表重置指针';
          END IF;
          --更新换表止码
          IF P_TYPE IN (BT故障换表, BT周期换表) THEN
            UPDATE BS_METERINFO
               SET MIRCODE     = P_MD.MTDREINSCODE, --换表起度
                   MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --换表起度CHAR
             WHERE MIID = P_MD.MTDMID;
          END IF;

          -- MODIFY 20140628 如果抄见标志为N且未算费，故障换表审核之后清空抄表库，用户重新做抄表
          FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                             TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
            IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
              DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
            END IF;
          END LOOP;

          INSERT INTO BS_METERREADHIS
            SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
          DELETE BS_METERREAD WHERE MRID = V_OMRID;

        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  */
  --工单流程未通过
  PROCEDURE SP_METERUSER(I_RENO  IN VARCHAR2, --批次流水
                         I_PER   IN VARCHAR2, --操作员
                         I_TYPE  IN VARCHAR2, --类型
                         O_STATE OUT NUMBER) AS -- 执行状态
    -- 执行状态
    MH      REQUEST_YHDBYH%ROWTYPE;
    MB      REQUEST_YHDBSB%ROWTYPE;
    V_COUNT VARCHAR2(100);
  BEGIN
    --分户
    IF I_TYPE = '1' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --插入历史记录
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '分户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        --更新户表信息水表档案号
        UPDATE BS_METERINFO SET MICODE = I.CIID WHERE MIID = I.MIID;
        SELECT COUNT(*)
          INTO V_COUNT
          FROM BS_CUSTINFO
         WHERE CIID = I.CIID;
        --分户后插入信息到用户信息表 如果有则不插入
        IF V_COUNT = 0 THEN
          INSERT INTO BS_CUSTINFO
            SELECT I.CIID MIID, --用户号
                   CISMFID, --营销公司
                   CIPID, --上级用户编号
                   CICLASS, --用户级次
                   CIFLAG, --末级标志
                   MH.CINAMEB CINAME, --用户名
                   MH.CIADRB CIADR, --用户地址
                   CISTATUS, --用户状态【SYSCUSTSTATUS】
                   SYSDATE CISTATUSDATE, --状态日期
                   CISTATUSTRANS, --状态表务
                   SYSDATE CINEWDATE, --立户日期
                   CIIDENTITYLB, --证件类型
                   CIIDENTITYNO, --证件号码
                   CIMTEL, --移动电话
                   CITEL1, --电话1
                   CITEL2, --电话2
                   CITEL3, --电话3
                   CICONNECTPER, --联系人
                   CICONNECTTEL, --联系电话
                   CIIFINV, --是否普票（迁移数据时同步BS_METERINFO.MIIFTAX(是否税票)）
                   CIIFSMS, --是否提供短信服务
                   CIPROJNO, --工程编号(老系统水账标识号)
                   CIFILENO, --档案号(老系统供水合同号)
                   CIMEMO, --备注信息
                   MICHARGETYPE, --类型（1=坐收，2=走收,收费方式）
                   '0' MISAVING, --预存款余额
                   MIEMAIL, --电子邮件
                   MIEMAILFLAG, --发账是否发邮件
                   MIYHPJ, --用户信用评级
                   MISTARLEVEL, --星级等级
                   ISCONTRACTFLAG, --是否签订供用水合同
                   WATERPW, --用户水表密码(限定6位,默为用户号后6位）
                   LADDERWATERDATE, --阶梯开始日期
                   CIHTBH, --合同编号
                   CIHTZQ, --周期（合同用）
                   CIRQXZ, --日期限制（合同用）
                   HTDATE, --合同签订日期
                   ZFDATE, --合同作废日期
                   JZDATE, --合同签订截止日期
                   SIGNPER, --签订人
                   SIGNID, --签订人身份证号
                   POCID, --房产证号
                   CIBANKNAME, --开户行名称(电票)
                   CIBANKNO, --开户行账号(电票)
                   CINAME2, --招牌名称
                   CINAME1, --票据名称
                   CITAXNO, --税号
                   CIADR1, --票据地址
                   CITEL4, --票据电话
                   CICOLUMN11, --特困标志
                   CITKZJH, --特困证件号
                   CICOLUMN2, --低保用户标志
                   CIDBZJH, --低保证件号
                   CICOLUMN1, --低保减免水量
                   CICOLUMN3, --低保截止月份
                   CIPASSWORD, --用户密码
                   CIUSENUM, --户籍人数
                   CIAMOUNT, --户数
                   CIDBBS, --是否一户多表
                   CILTID, --老户号
                   CIWXNO, --微信号码
                   CICQNO, --产权证号
                   'N' REFLAG --工单状态(Y:存在审批过程中的工单；N:不存在)
              FROM BS_CUSTINFO
             WHERE CIID = MH.CIIDA;
        END IF;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
      --合户
    ELSIF I_TYPE = '0' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --插入历史记录
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '合户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        UPDATE BS_METERINFO SET MICODE = MH.CIIDA WHERE MICODE = MH.CIIDB AND MIID = I.MIID;
        --插入历史记录
        INSERT INTO BS_CUSTINFO_HIS
          SELECT A.*, '合户' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_CUSTINFO A
           WHERE CIID = MH.CIIDB;
        --删除合并后取消的用户信息
        DELETE FROM BS_CUSTINFO A WHERE CIID = MH.CIIDB;
        --合户后余额相加
        UPDATE BS_CUSTINFO A
           SET MISAVING = MH.MISAVINGA + MH.MISAVINGB
         WHERE CIID = MH.CIIDA;
      END LOOP;
      --更新工单完成状态
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --工单流程未通过
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --操作类型
                           P_MTHNO  IN VARCHAR2, --批次流水
                           P_PER    IN VARCHAR2, --操作员
                           P_REMARK IN VARCHAR2, --备注、拒绝原因
                           P_COMMIT IN VARCHAR2) AS --提交标志
  BEGIN
    IF P_TYPE IN ('F') THEN
      UPDATE REQUEST_CB A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      UPDATE REQUEST_GZHB A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('L') THEN
      UPDATE REQUEST_ZQGZ A
         SET A.MTDFLAG        = 'Y', --完工标志
             A.MODIFYUSERNAME = P_PER, --修改人
             A.REMARK         = P_REMARK, --备注、拒绝原因
             A.MODIFYDATE     = SYSDATE --修改时间
       WHERE A.RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  END;

END;
/

prompt
prompt Creating package body PG_METER_READ
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_METER_READ IS

/*  --抄表录入处调用的重抄
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD表当前流水号
                         SMIID      IN VARCHAR2, --水表编号
                         GS_OPER_ID IN VARCHAR2, --登录人员ID
                         RES        IN OUT INTEGER) --返回结果 0成功 >0 失败*/

  --抄表录入处调用的重抄
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD表当前流水号
                         SMIID      IN VARCHAR2, --水表编号
                         GS_OPER_ID IN VARCHAR2, --登录人员ID
                         RES        IN OUT INTEGER) --返回结果 0成功 >0 失败
   IS
    LS_MRIFREC      VARCHAR2(10);
    LS_MRDATASOURCE VARCHAR2(10);
    LS_READOK       VARCHAR2(1);
    LS_BFRPER       VARCHAR2(20);
    LS_MISTATUS     VARCHAR2(20);
    LL_MICOLUMN5    VARCHAR2(20);
    LS_BFRPER1      VARCHAR2(20);
    LS_MRMID      VARCHAR2(20);

  BEGIN

    RES := 0;

/*    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER
      FROM BS_METERREAD
     WHERE MRMID = SMIID;*/
    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER, MRMID
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER,LS_MRMID
      FROM BS_METERREAD
     WHERE MRID = SMIID;

    IF LS_MRDATASOURCE = '9' AND LS_READOK = 'Y' THEN
      RES := 1;
      RETURN;
    END IF;
    IF LS_MRIFREC = 'Y' THEN
      RES := 2;
      RETURN;
    END IF;

    --判断当前是否免抄户
/*    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = SMIID);*/
    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = LS_MRMID);
    IF LS_BFRPER1 <> LS_BFRPER THEN
      LS_BFRPER := LS_BFRPER1;
    END IF;

/*    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = SMIID;*/
    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = LS_MRMID;

    IF (LS_MISTATUS = '29' OR LS_MISTATUS = '30') THEN
      UPDATE BS_METERREAD
         SET MRREADOK    = 'Y',
             MRIFSUBMIT  = 'N', --免拆户重抄后进抄表审核
             MRCHKFLAG   = 'Y', --重抄时是复核标志重置为'N'
             MRCHKRESULT = NULL, --重抄时检查结果类型重置为空
             MRINPUTPER  = GS_OPER_ID, --入账人员，取系统登录人员
             MRINPUTDATE = SYSDATE,
             --MRMEMO = '',
             MRFACE    = '01',
             MRFACE2   = '01',
             MRCARRYSL = 0,
             MRRPER    = LS_BFRPER
       WHERE MRID = SMIID;
    ELSE
      UPDATE BS_METERREAD
         SET MRREADOK    = 'N',
             MRIFSUBMIT  = 'N', --重抄时是否提交计费标志重置为'Y'
             MRCHKFLAG   = 'Y', --重抄时是复核标志重置为'N'
             MRCHKRESULT = NULL, --重抄时检查结果类型重置为空
             MRINPUTPER  = GS_OPER_ID, --入账人员，取系统登录人员
             MRINPUTDATE = SYSDATE,
             MRMEMO      = NULL,
             MRFACE      = '01',
             MRFACE2     = '01',
             MRCARRYSL   = 0,
             MRRPER      = LS_BFRPER,
             MRECODE     = NULL,
             MRSL        = NULL
       WHERE MRID = SMIID;

    END IF;

  END;

END;
/

prompt
prompt Creating package body PG_PAID
prompt =============================
prompt
create or replace package body pg_paid is
  err_str varchar2(1000);
  
  /*  
  --按票据销账 批量
  p_pjida         票据编码,多个票据按逗号分隔
  p_cply          出票来源：SMSF 上门收费 BJSF 补缴收费
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号
  */
  procedure poscustforys_pj_pl(p_pjids varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2) is
  begin
    for i in (select regexp_substr(p_pjids, '[^,]+', 1, level) id from dual connect by level <= length(p_pjids) - length(replace(p_pjids, ',', '')) + 1) loop
      poscustforys_pj(i.id , p_cply, p_oper , o_log);
    end loop;
  exception
    when others then
      rollback;
  end;
  
  /*  
  --按票据销账
  p_pjid          票据编码
  p_cply          出票来源：SMSF 上门收费 BJSF 补缴收费
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号
  */
  procedure poscustforys_pj(p_pjid varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2) is
    v_pbatch varchar2(10);  --缴费交易批次
    v_ptrans char(1);       --缴费事务
    v_position varchar(32); --缴费机构
    v_yhid varchar2(10);    --用户编码
    v_fkfs varchar2(2);     --付款方式
    v_arstr varchar2(2000); --应收账流水号，多个按逗号分隔
    v_kpje number;          --开票金额
    v_cply varchar2(10);
    v_pid varchar2(20);
    v_remainafter number;
    v_reflag varchar2(10);  --用户工单存在标志
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --缴费交易批次
    
    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;
    
    begin
      select mcode, fkfs, rlid, kpje, cply into v_yhid ,v_fkfs, v_arstr, v_kpje, v_cply from pj_inv_info where id = p_pjid;
    exception
      when no_data_found then raise_application_error(errcode, '无效的票据编码！' || p_pjid);
      return;
    end;
    
    if p_cply = 'SMSF' and v_cply = p_cply  then
      v_ptrans := 'I';
    elsif p_cply = 'SMSF' and v_cply <> p_cply  then
      o_log := o_log || p_pjid || ' 不是上门收费的票据' || chr(10);
      return;
    elsif p_cply = 'BJSF' and v_cply = p_cply  then
      v_ptrans := 'Z';
    elsif p_cply = 'BJSF' and v_cply <> p_cply  then
      o_log := o_log || p_pjid || ' 不是补缴收费的票据' || chr(10);
      return;
    end if;

    --1. 先单缴预存
    precust(p_yhid        => v_yhid,
            p_position    => v_position,
            p_pbatch      => v_pbatch,
            p_trans       => v_ptrans,
            p_oper        => p_oper,
            p_payway      => v_fkfs,
            p_payment     => v_kpje,
            p_memo        => null,
            p_pid         => v_pid,
            o_remainafter => v_remainafter);
    --2. 按照抄表日期逐条扣费
    select reflag into v_reflag from bs_custinfo where ciid = v_yhid;
    --存在审批过程中的工单不进行抵扣
    if v_reflag <> 'Y' or v_reflag is null then
      for i in (select regexp_substr(v_arstr, '[^,]+', 1, level) rlid from dual connect by level <= length(v_arstr) - length(replace(v_arstr, ',', '')) + 1) loop
        paycust(v_yhid,
               i.rlid,
               v_pbatch,
               v_position,
               v_ptrans,  
               p_oper,
               v_fkfs,
               0,
               null,
               v_pid,
               v_remainafter);
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  
  
  
  --柜台缴费入口
  /*
  p_yhid          用户编码
  p_arstr         （已废弃）欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号
  1. 先单缴预存
  2. 按照抄表日期扣费
  */
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2) is
  v_remainafter number;
  v_payment number;
  v_position varchar(32);
  v_pbatch varchar2(10);
  v_misaving number;
  v_reflag varchar2(10);
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --缴费交易批次

    v_payment := to_number(p_payment);
    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    --1. 先单缴预存
    if v_payment <> 0 then
      precust(p_yhid        => p_yhid,
              p_position    => v_position,
              p_pbatch      => v_pbatch,
              p_trans       => 'P',
              p_oper        => p_oper,
              p_payway      => p_payway,
              p_payment     => v_payment,
              p_memo        => null,
              p_pid         => p_pid,
              o_remainafter => v_remainafter);
    end if;
    --2. 按照抄表日期逐条扣费
    select misaving, reflag into v_misaving, v_reflag from bs_custinfo where ciid = p_yhid;
    --存在审批过程中的工单不进行抵扣
    if v_reflag <> 'Y' or v_reflag is null then
      for i in (select rlid, rlje from bs_reclist t where rlpaidflag = 'N' and rlreverseflag = 'N'and rlje <> 0 and rlcid = p_yhid order by rlday) loop
        exit when v_misaving < i.rlje;
        paycust(p_yhid,
               i.rlid,
               v_pbatch,
               v_position,
               'U',  --缴费事务   柜台缴费
               p_oper,
               p_payway,
               0,
               null,
               p_pid,
               v_remainafter);
        v_misaving := v_misaving - i.rlje;
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --一水表多应收销帐
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_pbatch   in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number) is
    cursor c_ci(vciid varchar2) is
        select * from bs_custinfo where ciid = vciid for update nowait; --若被锁直接抛出异常
    cursor c_mi(vmiid varchar2) is
        select * from bs_meterinfo where micode = vmiid for update nowait; --若被锁直接抛出异常
    p bs_payment%rowtype;
    mi bs_meterinfo%rowtype;
    ci bs_custinfo%rowtype;
    v_pdspje number;  --销账金额
    v_pdwyj number;   --违约金
    v_pdsxf number;   --手续费
  begin
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
      --取用户信息
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'用户编码【' || p_yhid || '】不存在！');
      end if;
      --取水表信息
      open c_mi(ci.ciid);
      fetch c_mi into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(errcode, '这个用户编码没对应水表！' || p_yhid);
      end if;
    --2、记录实收
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --流水号
      p.pcid := ci.ciid;          --用户编号
      p.pmid := mi.miid;           --水表编号
      p.pdate := trunc(sysdate);  --帐务日期
      p.pdatetime := sysdate;     --发生日期
      p.pmonth := to_char(sysdate,'yyyy-mm');        --缴费月份
      p.pposition := p_position;  --缴费机构
      p.ptrans := p_trans;        --缴费事务
      p.ppayee := p_oper;         --销帐人员
      p.psavingqc := nvl(ci.misaving,0);        --期初预存余额
      p.psavingbq := p_payment;                 --本期发生预存金额
      p.psavingqm := p.psavingqc + p.psavingbq; --期末预存余额
      p.ppayment := p_payment;                  --付款金额
      p.ppayway := p_payway;       --付款方式(xj-现金 zp-支票 mz-抹账 dc-倒存)
      p.pbseqno := null;           --缴费机构流水(银行实时收费交易流水)
      p.pbdate := null;            --银行日期(银行缴费账务日期)
      p.pchkdate := null;          --扎帐日期（收费员结账后回写审核日期）
      if p_pbatch is not null then
        p.pbatch := p_pbatch;
      else
        select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --缴费交易批次
      end if;
      p.pmemo := null;        --备注
      p.preverseflag := 'N';  --冲正标志
      if p_pid_source is null then
        p.pscrid    := p.pid;     --原实收帐流水（应收冲实产生的负帐时payment.pscrid不空，且为被冲实收帐流水号，用于关联冲与被冲的关联，其它情况payment.pscrid为空）
        p.pscrtrans := p.ptrans;  --原实收缴费事务（实收冲正产生的负帐时payment.pscrtrans不空，且为被冲应收帐事务，用于关联冲与被冲的关联，其它情况payment.pscrtrans为空）
        p.pscrmonth := p.pmonth; --原实收收月份（实收冲正（因冲帐产生负实收帐）：新生成负实收帐的原实收帐月份与被冲正实由帐月份相同（如：a用户2011年8月缴一笔水费，自来水公司在2011年9月发现这笔有问题，需要做实收冲正，做实收冲正时会产生一笔2011年9月负实帐，2011年9月负帐原实收帐月份为2011年8月）
        p.pscrdate  := p.pdate;  --原实收日期
      else
        select pid, ptrans, pmonth, pdate
          into p.pscrid, p.pscrtrans, p.pscrmonth, p.pscrdate
          from bs_payment
         where pid = p_pid_source;
      end if;
    --------------------------------------------------------------------------
    --4、销帐核心调用（应收记录处理、反馈实收数据）
    payzwarcore(p.pid,
                p.pbatch,
                p_payment,
                ci.misaving,
                p_oper,
                p.pdate,
                p.pmonth,
                p_arstr,
                v_pdspje,
                v_pdwyj,
                v_pdsxf);
    --------------------------------------------------------------------------
    --5、重算预存发生、预存期末、更新用户预存余额
    p.psavingqm := p.psavingqc + p_payment - v_pdspje - v_pdwyj - v_pdsxf;
    p.psavingbq := p.psavingqm - p.psavingqc;
    update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;
    --6、返回预存余额
    o_remainafter := p.psavingqm;

    insert into bs_payment values p;

    close c_ci;
    close c_mi;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      if c_mi%isopen then close c_mi; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收销帐处理核心
  procedure payzwarcore(p_pid          in varchar2,
                        p_batch        in varchar2,
                        p_payment      in number,
                        p_remainbefore in number,
                        p_oper         in varchar,
                        p_paiddate     in date,
                        p_paidmonth    in varchar2,
                        p_arstr        in varchar2,
                        o_sum_arje     out number,
                        o_sum_arznj    out number,
                        o_sum_arsxf    out number) is
    rl bs_reclist%rowtype;
    cursor c_rl is
      select *
      from bs_reclist
      where rlpaidflag = 'N' and
        rlreverseflag = 'N' and
        rlid = p_arstr;
        --rlid in (select regexp_substr(p_arstr, '[^,]+', 1, level) column_value from dual connect by level <= length(p_arstr) - length(replace(p_arstr, ',', '')) + 1);
    sumrlpaidje number(13, 3) := 0; --累计实收金额（应收金额+实收违约金+实收其他非系统费项123）
    p_remaind   number(13, 3);      --期初预存累减器
    --v_rlid varchar2(20);
  begin
    --期初预存累减器初始化
    p_remaind := p_remainbefore;
    --返回值初始化，若销帐包非空但无游标此值返回
    o_sum_arje  := 0;
    o_sum_arznj := 0;
    o_sum_arsxf := 0;
    if p_arstr is not null then
      open c_rl;
      loop
        fetch c_rl into rl;
        if c_rl%notfound then
          exit;
        else
          --组织一条待销应收记录更新变量
          rl.rlpaidflag := 'Y';
          rl.rlsavingqc := p_remaind;   --期初预存（销帐时产生）
          if p_remaind > rl.rlje then
            rl.rlsavingbq := rl.rlje;   --本期预存发生（销帐时产生）
          else
            rl.rlsavingbq := p_remaind;
          end if;
          rl.rlsavingqm := rl.rlsavingqc - rl.rlsavingbq;   --期末预存（销帐时产生）
          rl.rlpaiddate := p_paiddate;            --销帐日期
          rl.rlpaidmonth := p_paidmonth;          --销账月份
          rl.rlpid := p_pid;                      --实收流水（与payment.pid对应）
          rl.rlpbatch := p_batch;                 --缴费交易批次（与payment.pbatch对应）
          rl.rlpaidje := rl.rlje ; --销帐金额（实收金额=应收金额+预存发生）
          rl.rlpaidper := p_oper;                 --销账人员
          --中间变量运算
          sumrlpaidje := sumrlpaidje + rl.rlpaidje;
          --记录末条销帐记录
          --v_rlid := rl.rlid;
          --反馈实收记录
          o_sum_arje  := o_sum_arje + rl.rlje;
          p_remaind   := p_remaind + rl.rlsavingbq;
          --更新待销帐应收记录
          update bs_reclist
             set rlpaidflag  = rl.rlpaidflag,
                 rlsavingqc  = rl.rlsavingqc,
                 rlsavingbq  = rl.rlsavingbq,
                 rlsavingqm  = rl.rlsavingqm,
                 rlpaiddate  = rl.rlpaiddate,
                 rlpaidmonth = rl.rlpaidmonth,
                 rlpaidje    = rl.rlpaidje,
                 rlpid       = rl.rlpid,
                 rlpbatch    = rl.rlpbatch
           where rlid = rl.rlid;
        end if;
      end loop;
      close c_rl;
      --末条销帐记录处理，销帐溢出的实收金额计入末笔销帐记录的预存发生中！！！
      --update bs_reclist set rlsavingbq = rlsavingbq + (p_payment - sumrlpaidje) where rlid = v_rlid;
    end if;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --批量预存充值
  procedure precust_pl(p_yhids     in varchar2,
                     p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    o_pid_reverse out varchar2) is
    v_pid_reverse varchar2(100);
    v_position varchar(32);
    o_remainafter varchar2(100);
    v_pbatch varchar2(10);
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --缴费交易批次

    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    o_pid_reverse := null;
    for i in (select regexp_substr(p_yhids, '[^,]+', 1, level) yhid from dual connect by level <= length(p_yhids) - length(replace(p_yhids, ',', '')) + 1) loop
      v_pid_reverse := null;
      precust(i.yhid, v_position, v_pbatch, 'S',p_oper, p_payway, p_payment, p_memo, v_pid_reverse, o_remainafter);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --预存退费工单_批量
  procedure precust_yctf_gd_pl(p_renos     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2) is
    v_log varchar(1000);
  begin
    for i in (select regexp_substr(p_renos, '[^,]+', 1, level) reno from dual connect by level <= length(p_renos) - length(replace(p_renos, ',', '')) + 1) loop
      precust_yctf_gd(i.reno, p_oper, p_memo , v_log);
      o_log := o_log || v_log || chr(10);
    end loop;
  end;

  --预存退费工单_单条
  procedure precust_yctf_gd(p_reno     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2) is
    v_pid_reverse varchar2(100);
    v_position varchar(32);
    v_pbatch varchar2(10);
    o_remainafter varchar2(100);
    v_ciid varchar2(100);
    v_reshbz varchar2(1);
    v_rewcbz varchar2(1);
    v_misaving number;
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --缴费交易批次

    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    begin
      select ciid, reshbz, rewcbz into v_ciid, v_reshbz, v_rewcbz from request_yctf where reno = p_reno;
    exception
      when no_data_found then o_log := '无效的工单号：' || p_reno;
      return;
    end;

    if v_reshbz <> 'Y' or v_reshbz is null then
      o_log :=  '工单未审核完成，无法退费';
      return;
    elsif v_rewcbz = 'Y' then
      o_log := '预存退费工单已经完成，无法重复退费';
      return;
    end if;

    begin
        select misaving into v_misaving from bs_custinfo where ciid = v_ciid;
    exception
      when no_data_found then o_log := '无效的用户号：' || v_ciid;
      return;
    end;

    if v_misaving <= 0 or v_misaving is null then
      o_log :=  '预存余额不足，无法退费';
      return;
    end if;

    precust(v_ciid, v_position, v_pbatch, 'V', p_oper, 'XJ', -v_misaving, p_memo, v_pid_reverse, o_remainafter);
    o_log :=  '退费完成，用户' || v_ciid || '，退费' || v_misaving;

    update request_yctf set rewcbz = 'Y' ,relog = o_log where reno = p_reno;
    commit;

  exception
    when others then o_log := '无效的工单号：' || p_reno;
  end;

  --预存充值
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_pbatch      in varchar2,
                    p_trans       in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number) is
    cursor c_ci(vciid varchar2) is select * from bs_custinfo where ciid = vciid for update nowait; --若被锁直接抛出异常
    p bs_payment%rowtype;
    ci bs_custinfo%rowtype;
  begin
    --1、实参校验、必要变量准备
    --------------------------------------------------------------------------
      --取用户信息
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'用户编码【' || p_yhid || '】不存在！');
      end if;
    --2、记录实收
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --流水号
      p.pcid := ci.ciid;          --用户编号
      p.pdate := trunc(sysdate);  --帐务日期
      p.pdatetime := sysdate;     --发生日期
      p.pmonth := to_char(sysdate,'yyyy-mm');        --缴费月份
      p.pposition := p_position;  --缴费机构
      p.ptrans := p_trans;            --缴费事务  独立预存S
      p.ppayee := p_oper;         --销帐人员
      p.psavingqc := nvl(ci.misaving,0);        --期初预存余额
      p.psavingbq := p_payment;                 --本期发生预存金额
      p.psavingqm := p.psavingqc + p.psavingbq; --期末预存余额
      p.ppayment := p_payment;                  --付款金额
      p.ppayway := p_payway;       --付款方式(xj-现金 zp-支票 mz-抹账 dc-倒存)
      p.pbseqno := null;           --缴费机构流水(银行实时收费交易流水)
      p.pbdate := null;            --银行日期(银行缴费账务日期)
      p.pchkdate := null;          --扎帐日期（收费员结账后回写审核日期）
      if p_pbatch is not null then
        p.pbatch := p_pbatch;
      else
        select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --缴费交易批次
      end if;
      p.pmemo := p_memo;        --备注
      p.preverseflag := 'N';    --冲正标志
      p.pscrid    := p.pid;     --原实收帐流水（应收冲实产生的负帐时payment.pscrid不空，且为被冲实收帐流水号，用于关联冲与被冲的关联，其它情况payment.pscrid为空）
      p.pscrtrans := p.ptrans;  --原实收缴费事务（实收冲正产生的负帐时payment.pscrtrans不空，且为被冲应收帐事务，用于关联冲与被冲的关联，其它情况payment.pscrtrans为空）
      p.pscrmonth := p.pmonth;  --原实收收月份（实收冲正（因冲帐产生负实收帐）：新生成负实收帐的原实收帐月份与被冲正实由帐月份相同（如：a用户2011年8月缴一笔水费，自来水公司在2011年9月发现这笔有问题，需要做实收冲正，做实收冲正时会产生一笔2011年9月负实帐，2011年9月负帐原实收帐月份为2011年8月）
      p.pscrdate  := p.pdate;   --原实收日期
      p.pchkno      := NULL;    --进账单号
      p.tchkdate    := NULL;    --到账日期
      o_remainafter := p.psavingqm;

      insert into bs_payment values p;
      update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;

      commit;

      close c_ci;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正，按工单

  procedure pay_back_gd(p_reno in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_payids varchar(100);
    v_pid_reverse varchar(100);
    v_pcid varchar(20);
  begin
    select pid, pcid into v_payids, v_pcid from request_sscz where reshbz = 'Y' and (rewcbz <> 'Y' or rewcbz is  null) and reno = p_reno;
    o_pid_reverse := null;
    for i in (select regexp_substr(v_payids, '[^,]+', 1, level) pid from dual connect by level <= length(v_payids) - length(replace(v_payids, ',', '')) + 1) loop
      v_pid_reverse := null;
      pay_back_by_pdate_desc(i.pid,p_oper,v_pid_reverse);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;

    --更新工单状态
    update request_sscz
       set rewcbz = 'Y',
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper)
     where reno = p_reno;
    --更改 用户 有审核状态的工单 状态
    update bs_custinfo set reflag = 'N' where ciid = v_pcid;
    commit;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正，多流水号批量冲正，只冲正缴费交易，不冲正抵扣交易
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar(100);
    v_ppayment number;
    v_misaving number;
    v_reflag varchar2(1);
  begin
    o_pid_reverse := null;
    for i in (select regexp_substr(p_payids, '[^,]+', 1, level) pid from dual connect by level <= length(p_payids) - length(replace(p_payids, ',', '')) + 1) loop
      begin
        select nvl(p.ppayment,0), nvl(ci.misaving,0), nvl(ci.reflag,'N') into v_ppayment, v_misaving, v_reflag
          from bs_payment p left join bs_custinfo ci on p.pcid = ci.ciid
         where p.pid = i.pid;
      exception
        when no_data_found then o_pid_reverse := o_pid_reverse || i.pid || '： 无效的交易流水号，无法冲正' || CHR(10);
        continue;
      end;

      if v_ppayment = 0 then
        o_pid_reverse := o_pid_reverse || i.pid || '： 不是预存缴费交易流水号，无法冲正' || CHR(10);
      elsif v_reflag = 'Y' then
        o_pid_reverse := o_pid_reverse || i.pid || '： 用户存在审批中的工单，无法冲正' || CHR(10);
      elsif v_ppayment > v_misaving then
        o_pid_reverse := o_pid_reverse || i.pid || '： 用户余额不足，无法冲正' || CHR(10);
      else
        v_pid_reverse := null;
        pay_back_by_pid(i.pid, p_oper, 'N', v_pid_reverse);
        o_pid_reverse := o_pid_reverse || i.pid || '： 冲正完成，冲销流水号' || v_pid_reverse || CHR(10) ;
      end if;

    end loop;
  end;

  --实收冲正，按缴费批次
  procedure pay_back_by_pbatch(p_pbatch in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar(100);
  begin
    o_pid_reverse := null;
    for i in (select pid from bs_payment where pbatch = p_pbatch) loop
      v_pid_reverse := null;
      pay_back_by_pid(i.pid,p_oper,'',v_pid_reverse);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正，柜台缴费退费，
  --  1.事务为U 或 事务为P且预存金额大于退费金额，直接冲正当条实收
  --  2.事务为P且预存金额小于退费金额，按抄表时间倒序冲正事务为U的实收，直到预存金额大于退费金额，然后冲正事务为P的当条实收
  procedure pay_back_by_pdate_desc(p_pid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar2(100);
    v_ptrans varchar2(1);
    v_pcid   varchar2(20);
    v_misaving number;
    v_ppayment number;
    v_sumrlje  number;
  begin
    o_pid_reverse := null;
    v_sumrlje := 0;
    select pcid, ppayment into v_pcid, v_ppayment from bs_payment where pid = p_pid;
    select misaving into v_misaving from bs_custinfo where ciid = v_pcid;
    select ptrans into v_ptrans from bs_payment where pid = p_pid;

    if v_ptrans = 'U' or (v_ptrans = 'P' and v_misaving >= v_ppayment) then
      pay_back_by_pid(p_pid, p_oper, '', v_pid_reverse);
      o_pid_reverse := v_pid_reverse;
    elsif v_ptrans = 'P' and v_misaving < v_ppayment then
      null;
      --自动销账
      for i in (select p.pid ,rl.rlje
                  from bs_payment p
                       left join bs_reclist rl on p.pid = rl.rlpid
                 where p.preverseflag <> 'Y'
                       and p.ptrans = 'U'
                       and pdate = trunc(sysdate)
                       and pcid = v_pcid
                 order by rl.rlday desc
               ) loop
        v_pid_reverse := null;
        pay_back_by_pid(i.pid,p_oper,'',v_pid_reverse);
        if o_pid_reverse is null then
           o_pid_reverse := v_pid_reverse;
        else
           o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
        end if;
        v_sumrlje := v_sumrlje + i.rlje;
        exit when v_misaving + v_sumrlje >= v_ppayment;
      end loop;

      pay_back_by_pid(p_pid, p_oper, '', v_pid_reverse);
      o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
    end if;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --实收冲正
  --  p_payid  实收流水号
  --  p_oper   操作员编码
  --  p_recflg 是否冲正应收账
  --  o_pid_reverse      返回实收冲正流水号
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, p_recflag in varchar2, o_pid_reverse out varchar2) is
    cursor c_p(vpid varchar2) is
      select * from bs_payment where pid = vpid and preverseflag <> 'Y' for update nowait;
    p_source  bs_payment%rowtype;
    p_reverse bs_payment%rowtype;
    v_call number;
    v_rlid varchar2(20);
  begin
    --STEP 1:实收帐处理----------------------------------
    open c_p(p_payid);
    fetch c_p into p_source;
    if c_p%found then
      select trim(to_char(seq_paidment.nextval, '0000000000')) into o_pid_reverse from dual;
      p_reverse.pid        := o_pid_reverse;
      p_reverse.pcid       := p_source.pcid;
      p_reverse.pmid       := p_source.pmid;
      p_reverse.pdate      := trunc(sysdate);
      p_reverse.pdatetime  := sysdate;
      p_reverse.pmonth     := to_char(sysdate,'yyyy-mm');        --缴费月份
      p_reverse.pposition  := p_source.pposition;
      p_reverse.ptrans     := p_source.ptrans;
      select misaving into p_reverse.psavingqc from bs_custinfo where ciid = p_source.pcid;      --期初预存余额
      p_reverse.psavingbq := -p_source.psavingbq;
      p_reverse.psavingqm := p_reverse.psavingqc + p_reverse.psavingbq; --期末预存余额;
      p_reverse.ppayment  := -p_source.ppayment;
      p_reverse.ppayway   := p_source.ppayway;
      p_reverse.pbseqno   := p_source.pbseqno;
      p_reverse.pbdate    := p_source.pbdate;
      p_reverse.pchkdate  := p_source.pchkdate;
      p_reverse.pbatch    := p_source.pbatch;
      p_reverse.ppayee    := p_oper;
      p_reverse.pmemo     := p_source.pmemo;
      p_reverse.preverseflag := 'Y';
      p_reverse.pscrid    := p_source.pid;
      p_reverse.pscrtrans := p_source.ptrans;
      p_reverse.pscrmonth := p_source.pmonth;
      p_reverse.pscrdate  := p_source.pdate;
      p_reverse.pchkno    := null;
      p_reverse.tchkdate  := null;
      p_reverse.pdzdate   := null;
      p_reverse.pcseqno   := p_source.pcseqno;
      p_reverse.pcchkflag := p_source.pcchkflag;
      p_reverse.pcdate    := p_source.pcdate;
      p_reverse.pwseqno   := null;
      p_reverse.pwdate    := null;
    else
      err_str :=  '无效的实收流水号：'|| p_payid;
      raise_application_error(errcode, '无效的实收流水号：'|| p_payid);
    end if;
    insert into bs_payment values p_reverse;
    update bs_payment set preverseflag = 'Y' where pid = p_payid;
    --END OF STEP 1: 处理结果：---------------------------------------------------
    --PAYMENT 增加了了一条负记录
    -- 被冲正记录的冲正标志为Y

    --判断是否冲正应收账
    if p_recflag <> 'N' or p_recflag is null then

      -----STEP 10: 增加负应收记录
      ---保存需要冲正处理的应收总账记录
      delete from bs_reclist_sscz_temp;
      insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
      --保存需要冲正处理的应收明细帐记录
      delete from bs_recdetail_sscz_temp;
      insert into bs_recdetail_sscz_temp t (select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

      --冲正时应收帐负数据
      v_call := f_set_cr_reclist(p_reverse);

      --将应收冲正负记录插入到应收总账中
      insert into bs_reclist t (select * from bs_reclist_sscz_temp);

      ---在应收明细临时表中做负记录的调整
      --一般字段调整
      update bs_recdetail_sscz_temp t
         set t.rdsl  = 0 - t.rdsl,
             t.rdje  = 0 - t.rdje;
      --流水id调整
      update bs_recdetail_sscz_temp t
         set t.rdid =
             (select s.rlid
                from bs_reclist_sscz_temp s
               where t.rdid = s.rlcolumn9)
       where t.rdid in (select rlcolumn9 from bs_reclist_sscz_temp);
      --插入到应收明细表
      insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

      -----STEP 20: 增加正应收记录--------------------------------------------------------------
      ---保存需要冲正处理的应收总账记录
      delete from bs_reclist_sscz_temp;
      insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
      ---保存需要冲正处理的应收明细帐记录
      delete from bs_recdetail_sscz_temp;
      insert into bs_recdetail_sscz_temp t(select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

      ---在应收总账临时表中做正记录的调整
      v_rlid := trim(to_char(seq_reclist.nextval, '0000000000'));
      update bs_reclist_sscz_temp t
         set t.rlid    = v_rlid, --新生成
             t.rlmonth = to_char(sysdate, 'yyyy.mm'), --当前              帐务月份
             t.rldate  = sysdate, --当前              帐务日期
             t.rlscrrlid = t.rlid,--上次应收帐流水
             t.rlscrrltrans = t.rltrans,--上次应收帐事务
             t.rlscrrlmonth = t.rlmonth,--上次应收帐月份
             t.rlpaidflag = 'N',
             t.rlpaidper  = '', --无
             t.rlpaiddate = '', --无
             t.rldatetime = sysdate, --sysdate
             t.rlpid         = null, --无
             t.rlpbatch      = null, --无
             t.rlsavingqc    = 0, --无
             t.rlsavingbq    = 0, --无
             t.rlsavingqm    = 0, --无
             t.rlreverseflag = 'N';
      --将应收冲正正记录插入到应收总账中
      insert into bs_reclist t (select * from bs_reclist_sscz_temp);

      ---在应收明细临时表中做正记录的调整
      update bs_recdetail_sscz_temp t
         set t.rdid = v_rlid;

      --插入到应收明细表
      insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

      ----STEP 30 原应收记录打冲正标记
      update bs_reclist t set t.rlreverseflag = 'Y' where t.rlpid = p_payid and t.rlpaidflag = 'Y';

    end if;
    ----STEP 40 水表资料预存余额调整--------------------------------------------------------------
    update bs_custinfo set misaving = p_reverse.psavingqm where ciid = p_source.pcid;
    commit;
    close c_p;
  exception
    when others then
      if c_p%isopen then close c_p; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

/*******************************************************************************************
函数名：f_set_cr_reclist
用途： 本函数由核心实收冲正帐过程调用，调用前【待冲正应收记录记录】已经在从reclist 中拷贝到临时表中，本函数对临时表进行逐条冲正处理，
返回主程序后，核心冲正过程根据临时表更新reclist ，达到快捷冲正目的。
       逐条处理的目的：将冲正金额和预存逐条分配到应收帐记录上，预存管理
例子： a水表，个月欠费110元，期初预存30元，本次收费100元，违约金5元，应收冲正后记录如下：
----------------------------------------------------------------------------------------------------
月     份       预初     本次收费    应缴水费     违约金    预存期末   预存发生
----------------------------------------------------------------------------------------------------
原  2011.06         30          100           110         5        15         15
新  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
参数：pm 负实收 。
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype --负的实收
                            ) return number as
    --应收帐销帐临时表游标,按原应收帐月份排序
    cursor c_rl is
      select t.*
        from bs_reclist_sscz_temp t
       order by t.rlscrrlmonth;
    v_rcount number;
    v_rl     bs_reclist%rowtype;
    v_qc     number;
  begin
    v_rcount := 0;
    open c_rl;
    v_qc := pm.psavingqm;
    loop
      fetch c_rl into v_rl;
      exit when c_rl%notfound or c_rl%notfound is null;
      --销本应收记录后的预存期末
      v_rl.rlsavingqm := v_qc;
      v_rl.rlsavingbq := -v_rl.rlsavingbq;
      v_rl.rlsavingqc := v_rl.rlsavingqm - v_rl.rlsavingbq; --销本应收记录时的预存期初
      ----销本应收记录时的预存发生
      v_qc := v_rl.rlsavingqc; --上一条期末，成为下一条期初
      ----金额处理完毕------------------------------------------------------------------------------------------------
      ---更新临时应收表
      update bs_reclist_sscz_temp t
         set t.rlid    = trim(to_char(seq_reclist.nextval, '0000000000')),
             t.rlmonth = to_char(sysdate, 'yyyy.mm'), --当前              帐务月份
             t.rldate  = sysdate, --当前              帐务日期
             t.rlreadsl       = 0 - t.rlreadsl, --抄见水量
             t.rlsl    = 0 - t.rlsl, --取负              应收水量
             t.rlje    = 0 - t.rlje, --取负              应收金额
             t.rlcolumn9  = t.rlid, --原记录.rlid       原应收帐流水
             t.rlscrrlid = t.rlid,--上次应收帐流水
             t.rlscrrltrans = t.rltrans,--上次应收帐事务
             t.rlscrrlmonth = t.rlmonth,--上次应收帐月份
             t.rlpaidje = 0 - t.rlpaidje, --取负              销帐金额
             t.rlpaidper  = pm.ppayee, --同实收            销帐人员
             t.rlpaiddate = pm.pdate, --同实收            销帐日期
             t.rldatetime = sysdate, --sysdate           发生日期
             t.rlpid         = pm.pid, --对应的负实收流水  实收流水（与payment.pid对应）
             t.rlpbatch      = pm.pbatch, --对应的负实收流水  缴费交易批次（与payment.pbatch对应）
             t.rlsavingqc    = v_rl.rlsavingqc, --计算              期初预存（销帐时产生）
             t.rlsavingbq    = 0 - t.rlsavingbq, --计算              本期预存发生（销帐时产生）
             t.rlsavingqm    = v_rl.rlsavingqm, --计算              期末预存（销帐时产生）
             t.rlreverseflag = 'Y', --y                   冲正标志（n为正常，y为冲正）
             t.rlmisaving    = 0, --算费时预存
             t.rlpriorje     = 0 --算费之前欠费
       where t.rlid = v_rl.rlid;
      v_rcount := v_rcount + 1;
    end loop;
    return v_rcount;
  exception
    when others then return 0;
  end;

end;
/

prompt
prompt Creating package body PG_PJ
prompt ===========================
prompt
create or replace package body pg_pj is
  --票据处理包
  
  --补缴收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --将应收账流水号按用户分组
    for i in (select rlcid, rldatasource, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
               group by rlcid, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.rldatasource <> 'Z' then 
        o_log := o_log || i.rlid || ' 不是补缴收费的应收账' || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' 无效的应收账流水号' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已销账，无法出票' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已冲正，无法出票' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已出票，无法重复出票' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'BJSF');
        o_log := o_log || i.rlid || ' 出票完成' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --上门收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --将应收账流水号按用户分组
    for i in (select rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
                     left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
               group by rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.michargetype <> '2' then 
        o_log := o_log || i.rlid || ' 不是上门收费的用户' || i.rlcid || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' 无效的应收账流水号' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已销账，无法出票' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已冲正，无法出票' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已出票，无法重复出票' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'SMSF');
        o_log := o_log || i.rlid || ' 出票完成' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --票据 收费 单用户应收账
  /*
  p_rlids     应收账编码，多个按逗号分隔
  p_fkfs      付款类型(XJ 现金,ZP,支票
  p_cply      出票来源：SMSF 上门收费 BJSF 补缴收费
  */
  procedure pj_sf(p_rlids varchar2, p_fkfs varchar2, p_cply varchar2)is
    --v_pj_id varchar2(10);
  begin
    --v_pj_id := seq_paidbatch.nextval;

    insert into pj_inv_info(id, dyfs, status, cplx, fkfs, month, mcode, rlcname, rlcadr,  scode, ecode, sl, kpje, rlid ,cpje01, cpje02, cpje03, cply)
    with rd as (
         select rdid,
                sum(case when rdpiid = '01' then rdje end) je01 ,
                sum(case when rdpiid = '02' then rdje end) je02 ,
                sum(case when rdpiid = '03' then rdje end) je03
         from bs_recdetail
         where rdid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
         group by rdid
    )
    --select v_pj_id, '0', '0','L', p_fkfs, max(rlmonth), rlcid , rlcname, rlcadr, min(rlscode) , max(rlecode), sum(rlsl) ,sum(rlje), p_rlids, sum(je01), sum(je02), sum(je03), p_cply
    select seq_paidbatch.nextval, '0', '0','L', p_fkfs, rlmonth, rlcid , rlcname, rlcadr, rlscode , rlecode, rlsl, rlje, p_rlids, je01, je02, je03, p_cply
    from bs_reclist rl left join rd on rl.rlid = rd.rdid
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y'
    --group by v_pj_id, rlcid ,rlcname, rlcadr, p_rlids
    ;

    --更新出票标志
    update bs_reclist 
    set rlifinv = 'Y', isprintfp = 'Y' 
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y';
    commit;
  end;

end pg_pj;
/

prompt
prompt Creating package body PG_RAEDPLAN
prompt =================================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_RAEDPLAN" IS

  /*
  进行生成抄码表
  参数：P_MANAGE_NO： 临时表类型(PBPARMTEMP.C1)，存放调段后目标表册中所有水表编号C1,抄表次序C2
        P_MONTH: 目标营业所
        P_BOOK_NO:  目标表册
  处理：生成抄表资料
  输出：返回  0  执行成功
        返回 -1 执行失败
  */
--为演示临时注销
/*  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, \*营销公司*\
                     P_MONTH     IN VARCHAR2, \*抄表月份*\
                     P_BOOK_NO   IN VARCHAR2, \*表册*\
                     O_STATE     OUT VARCHAR2) \*执行状态*\
   IS
    \*表册*\
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND D.BFNRMONTH = P_MONTH
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;

    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),
                               'yyyy.mm')
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;*/
  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                     P_MONTH     IN VARCHAR2, /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2, /*表册*/
                     O_STATE     OUT VARCHAR2) /*执行状态*/
   IS
    /*表册*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    V_DATE DATE;
    
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND A.CISTATUS = '1';
  BEGIN
    SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
       
    IF TO_DATE(P_MONTH, 'yyyy.mm') >= V_DATE THEN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    
    SELECT ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC)
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
    
    WHILE TO_DATE(TO_CHAR(SYSDATE, 'yyyy.mm'),'yyyy.mm') >= V_DATE LOOP
      UPDATE BS_BOOKFRAME K
         SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC),
                                 'yyyy.mm')
       WHERE BFSMFID = P_MANAGE_NO
         AND BFID = P_BOOK_NO;
         
        SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
    END LOOP;
    END IF;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
  /*
  进行生成抄码表
  参数：P_MANAGE_NO： 临时表类型(PBPARMTEMP.C1)，存放调段后目标表册中所有水表编号C1,抄表次序C2
        P_MONTH: 目标营业所
        P_BOOK_NO:  目标表册
  处理：生成抄表资料
  输出：返回  0  执行成功
        返回 -1 执行失败
  */

  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, /*营销公司*/
                     P_MONTH     IN VARCHAR2, /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2, /*表册*/
                     O_STATE     OUT VARCHAR2) /*执行状态*/
   IS
    /*表册*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,
             A.MIID,
             A.MISMFID,
             A.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             A.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             MISTATUS,
             MIRECSL,
             MIENEED
        FROM BS_CBJH_TEMP A
       WHERE A.MIBFID = P_BOOK_NO
         AND A.MISMFID = P_MANAGE_NO
         AND A.BFNRMONTH = P_MONTH;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := P_BOOK_NO; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
         --COMMIT;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM')
     WHERE BFID = P_BOOK_NO;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;

  /*
  单户月初
  进行生成抄码表
  参数：P_MONTH:抄表月份
        P_SBID:水表档案编号
  处理：生成抄表资料
  输出：返回 0  执行成功
        返回 -1 执行失败
  */
  PROCEDURE CREATECBSB(P_MONTH IN VARCHAR2, /*抄表月份*/
                       P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2) /*执行状态*/
   IS
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --存在
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,    --用户号
             B.MIID,    --水表档案编号
             B.MISMFID, --营销公司
             B.MIRORDER, --抄表次序
             B.MISTID, --行业分类
             B.MIPID,    --上级水表编号
             B.MICLASS,  --水表级次
             B.MIFLAG, --末级标志
             B.MIRECDATE, --本期抄见日期
             B.MIRCODE, --本期读数
             S.MDMODEL, --计量方式
             B.MIPRIFLAG,  --合收表标志
             D.BFBATCH, --抄表批次
             D.BFRPER,  --抄表员
             B.MIRMON,  --本期抄表月份
             B.MISAFID, --区域
             B.MIIFCHK, --是否考核表(Y-是,N-否 )
             S.MDCALIBER, --表口径(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := P_MONTH; --抄表月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := SB.MIBFID; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --本期抄见
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'N'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRLASTSL      := SB.MIRECSL;  --上次抄表水量
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;

  -- 月终
  --TIME 2020-12-22  BY WL
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, /*营业所,售水公司*/
                            P_MONTH  IN VARCHAR2, /*当前月份*/
                            P_COMMIT IN VARCHAR2, /*提交标识*/
                            O_STATE  OUT VARCHAR2) /*执行状态*/
   IS
    --提交标识
    --P_COMMIT 提交标志
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '月终月份异常,请检查!');
    END IF;
    --更新上期抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --月份加一
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --更新抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';
    --将抄表数据转入到历史抄表库
    INSERT INTO BS_METERREAD_HIS
      (SELECT MRID,
              MRMONTH,
              MRSMFID,
              MRBFID,
              MRBATCH,
              MRDAY,
              MRRORDER,
              MRCCODE,
              MRMID,
              MRSTID,
              MRMPID,
              MRMCLASS,
              MRMFLAG,
              MRCREADATE,
              MRINPUTDATE,
              MRREADOK,
              MRRDATE,
              MRRPER,
              MRPRDATE,
              MRSCODE,
              MRECODE,
              MRSL,
              MRFACE,
              MRIFSUBMIT,
              MRIFHALT,
              MRDATASOURCE,
              '' MRPDARDATE,
              '' MROUTFLAG,
              '' MROUTID,
              '' MROUTDATE,
              '' MRINORDER,
              '' MRINDATE,
              MRMEMO,
              MRIFGU,
              MRIFREC,
              MRRECDATE,
              MRRECSL,
              MRADDSL,
              '' MRCTRL1,
              '' MRCTRL2,
              '' MRCTRL3,
              '' MRCTRL4,
              '' MRCTRL5,
              MRCARRYSL,
              MRCHKFLAG,
              MRCHKDATE,
              MRCHKPER,
              '' MRCHKSCODE,
              '' MRCHKECODE,
              '' MRCHKSL,
              '' MRCHKADDSL,
              '' MRCHKRDATE,
              '' MRCHKFACE,
              MRCHKRESULT,
              MRCHKRESULTMEMO,
              MRPRIMID,
              MRPRIMFLAG,
              MRFACE2,
              '' MRSCODECHAR,
              '' MRECODECHAR,
              '' MRIFTRANS,
              MRREQUISITION,
              MRIFCHK,
              MRINPUTPER,
              MRPFID,
              MRCALIBER,
              MRSIDE,
              MRLASTSL,
              MRTHREESL,
              MRYEARSL,
              MRRECJE01,
              MRRECJE02,
              MRRECJE03,
              MRRECJE04,
              MRNULLCONT,
              MRNULLTOTAL,
              MRBFSDATE,
              MRBFEDATE,
              MRBFDAY,
              MRIFMCH,
              MRIFZBSM,
              MRIFYSCZ,
              MRDZSL,
              MRDZFLAG,
              MRDZSYSCODE,
              MRDZCURCODE,
              MRDZTGL,
              MRZKH,
              MRSFFS,
              MRGDID
         FROM BS_METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);

    --删除当前抄表库信息
    DELETE BS_METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    /*    --历史均量计算
    UPDATEMRSLHIS(P_SMFID, P_MONTH);*/
    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
      O_STATE := '0';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '月终失败' || SQLERRM);
      O_STATE := '-1';
  END;

  -- 抄表审核
  --TIME 2020-12-24  BY WL
  --返回 0  执行成功
  --返回 -1 执行失败
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID  IN VARCHAR2,     /*流水号*/
                            P_OPER  IN VARCHAR2,     /*操作人姓名*/
                            P_FLAG  IN VARCHAR2,     /*是否通过*/
                            O_STATE OUT VARCHAR2) AS /*执行状态*/
    MR BS_METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM BS_METERREAD WHERE MRID = P_MRID;
      IF MR.MRIFSUBMIT = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无需审核');
      END IF;
      IF MR.MRSL IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '用户号【' || MR.MRCCODE || '】抄表水量为空');
      END IF;
      IF MR.MRIFREC = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '已计费无需审核');
      END IF;
      /*    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表记录');*/
    END;

    UPDATE BS_METERREAD
       SET MRIFSUBMIT = 'Y',
           MRCHKFLAG  = 'Y', --复核标志
           MRCHKDATE  = SYSDATE, --复核日期
           MRCHKPER   = P_OPER, --复核人员
           --MRCHKSCODE      = MR.MRSCODE, --原起数
           --MRCHKECODE      = MR.MRECODE, --原止数
           --MRCHKSL         = MR.MRSL, --原水量
           --MRCHKADDSL      = MR.MRADDSL, --原余量
           --MRCHKCARRYSL    = MR.MRCARRYSL, --原进位水量
           --MRCHKRDATE      = MR.MRRDATE, --原抄见日期
           --MRCHKFACE       = MR.MRFACE, --原表况
           MRCHKRESULT = (CASE
                           WHEN P_FLAG = '0' THEN
                            '确认通过'
                           ELSE
                            '退回重入帐'
                         END), --检查结果类型
           MRCHKRESULTMEMO = (CASE
                               WHEN P_FLAG = '0' THEN
                                '确认通过'
                               ELSE
                                '退回重入帐'
                             END) --检查结果说明
     WHERE MRID = P_MRID;

    IF P_FLAG = '-1' THEN
      --审批不通过
      UPDATE BS_METERREAD
         SET MRREADOK   = 'N',
             MRIFSUBMIT = 'N',
             MRRDATE    = NULL,
             MRECODE    = NULL,
             MRSL       = NULL,
             MRFACE     = NULL,
             MRFACE2    = NULL,
             --MRFACE3      = NULL,
             --MRFACE4      = NULL,
             --MRECODECHAR  = NULL,
             MRDATASOURCE = NULL
       WHERE MRID = P_MRID;
    END IF;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_STATE := '-1';
  END;
  /*
  均量（费）算法
  1、前N次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数
  */
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER) IS
    CURSOR C_MRH(V_SBID BS_METERREAD_HIS.MRMID%TYPE) IS
      SELECT NVL(MRSL, 0),
             NVL(MRRECJE01, 0),
             NVL(MRRECJE02, 0),
             NVL(MRRECJE03, 0),
             MRMONTH
        FROM BS_METERREAD_HIS
       WHERE MRMID = V_SBID
            /*AND MRSL > 0*/
         AND (MRDATASOURCE <> '9' OR MRDATASOURCE IS NULL)
       ORDER BY MRRDATE DESC;

    MRH BS_METERREAD_HIS%ROWTYPE;
    N1  INTEGER := 0;
    N2  INTEGER := 0;
    N3  INTEGER := 0;
    N4  INTEGER := 0;
  BEGIN
    OPEN C_MRH(P_SBID);
    LOOP
      FETCH C_MRH
        INTO MRH.MRSL,
             MRH.MRRECJE01,
             MRH.MRRECJE02,
             MRH.MRRECJE03,
             MRH.MRMONTH;
      EXIT WHEN C_MRH%NOTFOUND IS NULL OR C_MRH%NOTFOUND OR(N1 > 12 AND
                                                            N2 > 1 AND
                                                            N3 > 1 AND
                                                            N4 > 12);
      IF MRH.MRSL > 0 AND N1 <= 12 THEN
        N1            := N1 + 1;
        MRH.MRTHREESL := NVL(MRH.MRTHREESL, 0) + MRH.MRSL; --前N次均量
      END IF;

      IF C_MRH%ROWCOUNT = 1 THEN
        N2           := N2 + 1;
        MRH.MRLASTSL := NVL(MRH.MRLASTSL, 0) + MRH.MRSL; --上次水量
      END IF;

      IF MRH.MRMONTH = TO_CHAR(TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1) || '.' ||
         SUBSTR(P_MONTH, 6, 2) THEN
        N3           := N3 + 1;
        MRH.MRYEARSL := NVL(MRH.MRYEARSL, 0) + MRH.MRSL; --去年同期水量
      END IF;

      IF MRH.MRSL > 0 AND TO_NUMBER(SUBSTR(MRH.MRMONTH, 1, 4)) =
         TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1 THEN
        N4 := N4 + 1;
      END IF;
    END LOOP;

    O_SL_1 := (CASE
                WHEN N1 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRTHREESL / N1, 0)
              END);

    O_SL_2 := (CASE
                WHEN N2 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTSL / N2, 0)
              END);

    O_SL_3 := (CASE
                WHEN N3 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRYEARSL / N3, 0)
              END);

  EXCEPTION
    WHEN OTHERS THEN
      IF C_MRH%ISOPEN THEN
        CLOSE C_MRH;
      END IF;
  END GETMRHIS;
  /*
  工单抄表库回写
  处理：生成抄表资料
  输出：返回 0  执行成功
        返回 -1 执行失败
  */
  PROCEDURE CREATECBGD(P_SBID  IN VARCHAR2, /*水表档案编号*/
                       O_STATE OUT VARCHAR2) /*执行状态*/
   IS
    YH   BS_CUSTINFO%ROWTYPE;
    SB   BS_METERINFO%ROWTYPE;
    MD   BS_METERDOC%ROWTYPE;
    BC   BS_BOOKFRAME%ROWTYPE;
    SBR  BS_METERREAD%ROWTYPE;

    --计划
    CURSOR C_BKSB IS
      SELECT A.CIID,    --用户号
             B.MIID,    --水表档案编号
             B.MISMFID, --营销公司
             B.MIRORDER, --抄表次序
             B.MISTID, --行业分类
             B.MIPID,    --上级水表编号
             B.MICLASS,  --水表级次
             B.MIFLAG, --末级标志
             B.MIRECDATE, --本期抄见日期
             B.MIRCODE, --本期读数
             S.MDMODEL, --计量方式
             B.MIPRIFLAG,  --合收表标志
             D.BFBATCH, --抄表批次
             D.BFRPER,  --抄表员
             B.MIRMON,  --本期抄表月份
             B.MISAFID, --区域
             B.MIIFCHK, --是否考核表(Y-是,N-否 )
             S.MDCALIBER, --表口径(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         /*AND FCHKCBMK(B.MRMID) = 'Y'*/;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;

        SBR.MRID          := FGETSEQUENCE('METERREAD'); --流水号
        SBR.MRMONTH       := TO_CHAR(SYSDATE,'YYYY.MM'); --当前月份
        SBR.MRSMFID       := SB.MISMFID; --管辖公司
        SBR.MRBFID        := SB.MIBFID; --表册
        SBR.MRBATCH       := BC.BFBATCH; --抄表批次
        SBR.MRRPER        := BC.BFRPER; --抄表员
        SBR.MRRORDER      := SB.MIRORDER; --抄表次序号
        SBR.MRCCODE       := YH.CIID; --用户编号
        SBR.MRMID         := SB.MIID; --水表编号
        SBR.MRSTID        := SB.MISTID; --行业分类
        SBR.MRMPID        := SB.MIPID; --上级水表
        SBR.MRMCLASS      := SB.MICLASS; --水表级次
        SBR.MRMFLAG       := SB.MIFLAG; --末级标志
        SBR.MRCREADATE    := SYSDATE; --创建日期
        SBR.MRINPUTDATE   := NULL; --编辑日期
        SBR.MRREADOK      := 'N'; --抄见标志
        SBR.MRRDATE       := NULL; --抄表日期
        SBR.MRPRDATE      := SB.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        SBR.MRSCODE       := SB.MIRCODE; --上期抄见
        SBR.MRECODE       := NULL; --本期抄见
        SBR.MRSL          := NULL; --本期水量
        SBR.MRFACE        := NULL; --表况
        SBR.MRIFSUBMIT    := 'Y'; --是否提交计费
        SBR.MRIFHALT      := 'N'; --系统停算
        SBR.MRDATASOURCE  := 1; --抄表结果来源
        SBR.MRMEMO        := NULL; --抄表备注
        SBR.MRIFGU        := 'N'; --估表标志
        SBR.MRIFREC       := 'N'; --已计费
        SBR.MRRECDATE     := NULL; --计费日期
        SBR.MRRECSL       := NULL; --应收水量
        SBR.MRADDSL       := 0; --余量
        SBR.MRCHKFLAG     := 'N'; --复核标志
        SBR.MRCHKDATE     := NULL; --复核日期
        SBR.MRCHKPER      := NULL; --复核人员
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  合收表标志
        SBR.MRFACE2       := NULL; --抄见故障
        SBR.MRREQUISITION := 0; --通知单打印次数
        SBR.MRIFCHK       := SB.MIIFCHK; --考核表标志
        SBR.MRINPUTPER    := NULL; --入账人员
        SBR.MRCALIBER     := MD.MDCALIBER; --口径
        SBR.MRSIDE        := SB.MISIDE; --表位
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --是否免抄户(Y-是 N-否)固定量

        --上次水费   至  去年度次均量
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
END;
/

prompt
prompt Creating package body PG_RECTRANS
prompt =================================
prompt
create or replace package body pg_rectrans is

  --工单
  --p_gdtype: ZLSF  追量收费,  BJSF  补缴收费
  --追量收费：request_zlsf
  --
  procedure rectrans_gd(p_reno varchar2, p_gdtype varchar2, o_log out varchar2) is
    v_gdtype_name varchar(10);
    v_miid varchar(20);
    v_mrscode number;
    v_mrecode number;
    v_mrsl number;
    v_mrdatasource varchar2(1);
    v_mrid varchar2(20);
    o_mrrecje01 bs_meterread.mrrecje01%type;
    o_mrrecje02 bs_meterread.mrrecje02%type;
    o_mrrecje03 bs_meterread.mrrecje03%type;
    o_mrrecje04 bs_meterread.mrrecje04%type;
    o_mrsumje   number;
    v_insmr_log varchar2(2000);
    v_cal_log varchar2(2000);
    v_reshbz varchar2(1);
    v_rewcbz varchar(1);
    v_reifreset varchar(1);
    v_reifstep varchar(1);
  begin
    select decode(p_gdtype, 'ZLSF', '追量收费', 'BJSF', '补缴收费') into v_gdtype_name from dual;

    if p_gdtype = 'ZLSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_zlsf where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_bjsf where reno = p_reno;
    else
      o_log := '请正确输入工单类型。';
      return;
    end if;

    if v_reshbz <> 'Y' or v_reshbz is null then o_log := '工单未审核，无法' || v_gdtype_name || '。工单编号：'|| p_reno || chr(10); return; end if;
    if v_rewcbz = 'Y' then  o_log := '工单已完成，无法' || v_gdtype_name || '。工单编号：'|| p_reno || chr(10); return; end if;

    o_log := '开始执行' || v_gdtype_name || '工单。工单编号：'|| p_reno || chr(10);
    --生成抄表信息
    ins_mr(v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource, p_reno, v_reifreset, v_reifstep, v_mrid, v_insmr_log);
    o_log := o_log || '开始执行工单。生成抄表记录：'|| v_insmr_log || v_mrid || chr(10);
    --算费
    pg_cb_cost.calculatebf(v_mrid, '02', o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje, v_cal_log);
    o_log := o_log || '开始执行' || v_gdtype_name || '工单。算费：'|| v_cal_log || chr(10);

    if p_gdtype = 'ZLSF' then
      update request_zlsf set rewcbz = 'Y' where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      update request_bjsf set rewcbz = 'Y' where reno = p_reno;
    end if;

    commit;
    o_log := o_log || v_gdtype_name || '工单完成。工单编号：'|| p_reno;

  exception
      when no_data_found then o_log := '无效的工单号：' || p_reno;
      return;
  end;

  --生成抄表记录
  procedure ins_mr(p_miid varchar2, p_mrscode number, p_mrecode number, p_mrsl number,
            p_mrdatasource varchar2, p_mrgdid varchar2, p_mrifreset varchar2, p_mrifstep varchar2,
            o_mrid out varchar2, o_log out varchar2) is
    v_rowcount number;
  begin
    o_mrid := fgetsequence('METERREAD');

    insert into bs_meterread (mrid, mrmonth, mrsmfid, mrbfid, mrccode, mrmid, mrstid, mrcreadate, mrreadok, mrrdate, mrprdate, mrrper,
       mrscode, mrecode, mrsl, mrifsubmit, mrifhalt, mrdatasource, mrifrec, mrrecsl, mrpfid, mrgdid, mrifreset, mrifstep)
    select o_mrid, to_char(sysdate, 'yyyy.mm'), mismfid, mibfid, micode, miid, mistid, sysdate, 'N', sysdate, sysdate, '1',
           p_mrscode, p_mrecode, p_mrsl, 'Y', 'N', p_mrdatasource, 'N', 0, mipfid, p_mrgdid, p_mrifreset, p_mrifstep
    from bs_meterinfo
    where miid = p_miid;
    v_rowcount := sql%rowcount;

    commit;
    if v_rowcount = 1 then
      o_log := '生成抄表记录成功';
    else
      o_log := '生成抄表记录失败';
    end if;

  end;

end pg_rectrans;
/

prompt
prompt Creating package body PG_UPDATE
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_UPDATE IS

  --变更管理
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER) IS --执行状态
  V_MDNO VARCHAR2(100);
  BEGIN
    --用户信息维护
    IF I_TPYE = 'A' THEN
      FOR I IN (SELECT * FROM REQUEST_YHXX WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'用户信息维护',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --用户名
      CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --用户地址
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --票据电话
      CINAME2 = CASE WHEN I.CINAME2 IS NULL THEN A.CINAME2 ELSE I.CINAME2 END,  --招牌名称
      CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --是否提供短信服务
      CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END,  --证件类型(1-身份证 2-营业执照  0-无)
      CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --证件号码
      CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --微信号码
      CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END  --产权证号
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_YHXX A SET REFLAG = 'Y' WHERE RENO = I.RENO;
    END LOOP;
    --票据信息维护
    ELSIF I_TPYE = 'B' THEN
      FOR I IN (SELECT * FROM REQUEST_PJXX WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'票据信息维护',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END  --票据电话
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_PJXX A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    --收费方式变更
    ELSIF I_TPYE = 'C' THEN
      FOR I IN (SELECT * FROM REQUEST_SFFS WHERE RENO = I_RENO) LOOP
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'收费方式变更',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --更新用户信息表
      UPDATE BS_CUSTINFO A SET
      MICHARGETYPE = CASE WHEN I.MICHARGETYPE IS NULL THEN A.MICHARGETYPE ELSE I.MICHARGETYPE END  --类型（1=坐收，2=走收,收费方式）
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_SFFS A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
     --用水性质变更
    ELSIF I_TPYE = 'D' THEN
      FOR I IN (SELECT * FROM REQUEST_SJBG WHERE RENO = I_RENO) LOOP
        --备份户表信息
        INSERT INTO BS_METERINFO_HIS
        SELECT A.*,'用水性质变更',I.RENO,SYSDATE 
        FROM BS_METERINFO A WHERE A.MIID=I.MIID;
        --更新户表信息
        UPDATE BS_METERINFO A SET 
        MIPFID = CASE WHEN I.MIPFID IS NULL THEN A.MIPFID ELSE I.MIPFID END  --用水性质(priceframe)
        WHERE A.MIID=I.MIID;
        --备份用户信息表
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'用水性质变更',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
        --更新用户信息表
        UPDATE BS_CUSTINFO A SET 
        CICOLUMN11 = CASE WHEN I.CICOLUMN11 IS NULL THEN A.CICOLUMN11 ELSE I.CICOLUMN11 END,  --特困标志
        CITKZJH = CASE WHEN I.CITKZJH IS NULL THEN A.CITKZJH ELSE I.CITKZJH END,  --特困证件号
        CICOLUMN2 = CASE WHEN I.CICOLUMN2 IS NULL THEN A.CICOLUMN2 ELSE I.CICOLUMN2 END,  --低保用户标志
        CIDBZJH = CASE WHEN I.CIDBZJH IS NULL THEN A.CIDBZJH ELSE I.CIDBZJH END  --低保证件号
        WHERE A.CIID=I.CIID;
        UPDATE REQUEST_SJBG A SET REFLAG = 'Y' WHERE RENO = I.RENO;
       END LOOP;
      --水表档案变更
    ELSIF I_TPYE = 'E' THEN
     FOR I IN (SELECT * FROM REQUEST_SBDA WHERE RENO = I_RENO) LOOP
       SELECT MDNO INTO V_MDNO FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --备份水表档案
       INSERT INTO BS_METERDOC_HIS
       SELECT A.*,'水表档案变更',I.RENO,SYSDATE 
       FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --更新水表档案
       UPDATE BS_METERDOC A SET 
       MDNO = CASE WHEN I.MDNO IS NULL THEN A.MDNO ELSE I.MDNO END,  --表身码
       MDBRAND = CASE WHEN I.MDBRAND IS NULL THEN A.MDBRAND ELSE I.MDBRAND END,  --表厂家(meterbrand)
       MDCALIBER = CASE WHEN I.MDCALIBER IS NULL THEN A.MDCALIBER ELSE I.MDCALIBER END,  --表口径(METERCALIBER)
       BARCODE = CASE WHEN I.BARCODE IS NULL THEN A.BARCODE ELSE I.BARCODE END,  --条形码
       RFID = CASE WHEN I.RFID IS NULL THEN A.RFID ELSE I.RFID END,  --电子标签
       COLLENTTYPE = CASE WHEN I.MIRTID IS NULL THEN A.COLLENTTYPE ELSE I.MIRTID END,  --采集类型（原抄表方式【sysreadtype】）
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --塑封号
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --钢封号
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --稽查刚封号
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END  --铅封号
       WHERE A.MDID=I.MIID;
       --备份户表信息
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'水表档案变更',I.RENO,SYSDATE 
       FROM BS_METERINFO A WHERE A.MIID=I.MIID;
       --更新户表信息
       UPDATE BS_METERINFO A SET 
       MIADR = CASE WHEN I.MIADR IS NULL THEN A.MIADR ELSE I.MIADR END,  --表地址
       MISIDE = CASE WHEN I.MISIDE IS NULL THEN A.MISIDE ELSE I.MISIDE END,  --表位【syscharlist】
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --塑封号
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --钢封号
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --稽查刚封号
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END,  --铅封号
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --卡片图号
       WHERE A.MIID=I.MIID;
       --封号表：塑封号更新
       IF I.DQSFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND FHSTATUS = '0' AND METERFH = I.DQSFH;
         END IF;
       --封号表：钢封号更新
       IF I.DQGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND FHSTATUS = '0' AND METERFH = I.DQGFH;
         END IF;
       --封号表：稽查刚封号更新
       IF I.JCGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND FHSTATUS = '0' AND METERFH = I.JCGFH;
         END IF;
       --封号表：铅封号更新
       IF I.QFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND FHSTATUS = '0' AND METERFH = I.QFH;
         END IF;
         UPDATE REQUEST_SBDA A SET REFLAG = 'Y' WHERE RENO = I.RENO;
      END LOOP;
    --过户
    ELSIF I_TPYE = 'F' THEN
      FOR I IN (SELECT * FROM REQUEST_GH WHERE RENO = I_RENO) LOOP
       --备份用户信息表
       INSERT INTO BS_CUSTINFO_HIS
       SELECT A.*,'过户',I.RENO,SYSDATE 
       FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
       --更新用户信息表
       UPDATE BS_CUSTINFO A SET 
       A.CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END,  --产权证号
       --A.?????? = I.ACCESSORYFLAG5, --新户主身份证复印件标识  暂不确定对应字段 对应表
       A.CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --开户行名称(电票)
       A.CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --开户行账号(电票)
       A.CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --联系人
       A.CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --票据地址
       A.CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --票据电话
       A.CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --票据名称
       A.CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --是否提供短信服务（短信号码同移动电话）
       A.CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --税号
       A.CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --微信号码
       A.CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --移动电话
       A.CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --用户地址
       A.CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --用户名
       A.CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --是否普票（迁移数据时同步bs_meterinfo.MIIFTAX(是否税票)）
       A.CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --证件号码
       A.CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END  --证件类型
       WHERE A.CIID=I.CIID;
       --备份户表信息
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'过户',I.RENO,SYSDATE 
       FROM BS_METERINFO A 
       WHERE A.MICODE=I.CIID;
       --更新户表信息
       UPDATE BS_METERINFO A SET 
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --卡片图号
       WHERE A.MICODE=I.CIID;
       UPDATE REQUEST_GH A SET A.MODIFYDATE = SYSDATE, MODIFYUSERNAME = I_OPER,REFLAG = 'Y' WHERE A.RENO=I.RENO;
        END LOOP;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  --表册调整
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --流水号
                      I_TPYE  IN VARCHAR2, --更新类型
                      I_OPER  IN VARCHAR2, --操作人
                      O_STATE OUT NUMBER) IS --执行状态
  V_DEPT VARCHAR2(100);
  V_COUNT NUMBER(10);
  BEGIN
    -- A 跨区域调整
    IF I_TPYE = 'A' THEN
    FOR I IN (SELECT *
                FROM (SELECT REGEXP_SUBSTR(YBFID, '[^,]+', 1, LEVEL) YBFID,
                             REGEXP_SUBSTR(MBFID, '[^,]+', 1, LEVEL) MBFID
                        FROM REQUEST_QYDZ
                       WHERE RENO = I_RENO
                      CONNECT BY LEVEL <= LENGTH(YBFID) -
                                 LENGTH(REPLACE(YBFID, ',', '')) + 1)
               GROUP BY YBFID, MBFID
               ORDER BY YBFID, MBFID) LOOP
      V_DEPT := SUBSTR(I.MBFID,1,2);
      
      UPDATE BS_METERINFO SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT,MIRORDER='' WHERE MIBFID = I.YBFID;
      UPDATE BS_METERINFO_HIS SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT WHERE MIBFID = I.YBFID;
      UPDATE BS_METERREAD SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT,MRRORDER='' WHERE MRBFID = I.YBFID;
      UPDATE BS_METERREAD_HIS SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT WHERE MRBFID = I.YBFID;
      UPDATE BS_RECLIST SET RLBFID = I.MBFID,RLSMFID = '02'||V_DEPT WHERE RLBFID = I.YBFID;
      
      FOR A IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I.MBFID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I.MBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I.MBFID||V_COUNT WHERE MIID=A.MIID;
        UPDATE BS_METERREAD SET MRRORDER=V_COUNT,MRZKH=I.MBFID||V_COUNT WHERE MRMID=A.MIID;
        END LOOP;
    END LOOP;
    UPDATE REQUEST_QYDZ A SET REFLAG = 'Y' WHERE RENO = I_RENO;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  
  --抄表员间表册转移
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --表册号
                       I_BFRPER  IN VARCHAR2, --新抄表员
                       I_BFRCYC  IN VARCHAR2, --新抄表周期
                       I_BFSDATE IN VARCHAR2, --新计划起始日期
                       I_BFEDATE IN VARCHAR2, --新计划结束日期
                       I_BFNRMONTH IN VARCHAR2, --新下次抄表月份
                       O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(BFID, '[^,]+', 1, LEVEL) BFID
                        FROM (SELECT I_BFID AS BFID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(BFID) -
                                 LENGTH(REPLACE(BFID, ',', '')) + 1) LOOP
    UPDATE BS_BOOKFRAME 
    SET BFRPER = I_BFRPER,  --抄表员
        BFRCYC = NVL(I_BFRCYC,BFRCYC), --抄表周期
        BFSDATE = NVL(TO_DATE(I_BFSDATE,'YYYY/MM/DD'),BFSDATE),  --计划起始日期
        BFEDATE = NVL(TO_DATE(I_BFEDATE,'YYYY/MM/DD'),BFEDATE),  --计划结束日期
        BFNRMONTH = NVL(I_BFNRMONTH,BFNRMONTH)  --下次抄表月份
         WHERE BFID = I.BFID;
    END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --账卡号调整
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --水表档案编号
                      I_MIBFID  IN VARCHAR2, --表册号
                      O_STATE   OUT NUMBER) IS --执行状态
  V_COUNT NUMBER(10);
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(I_MIID, '[^,]+', 1, LEVEL) I_MIID
                        FROM (SELECT I_MIID AS I_MIID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(I_MIID) -
                                 LENGTH(REPLACE(I_MIID, ',', '')) + 1) LOOP
    INSERT INTO BS_METERINFO_HIS
    SELECT A.*,'账卡号调整','',SYSDATE FROM BS_METERINFO A WHERE A.MIID=I_MIID;
    UPDATE BS_METERINFO SET MIBFID = I_MIBFID,MIRORDER='' WHERE MIID=I_MIID;
    FOR I IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I_MIID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I_MIBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I_MIBFID||V_COUNT WHERE MIID=I_MIID;
        END LOOP;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --等针
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --流水号
                    O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_DZ WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL1 = 'Y', A.MIENEED=I.MIWCODE WHERE MIID=I.MIID;
    UPDATE REQUEST_DZ A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --固定量
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --流水号
                     O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_GDL WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MICOLUMN5 = I.MICOLUMN5 WHERE MIID=I.MIID;
    UPDATE REQUEST_GDL A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --总表收免
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --流水号
                      O_STATE   OUT NUMBER) IS --执行状态
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_ZBSM WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL2 = I.MIYL2,A.MIYL7=I.MIYL7  WHERE MIID=I.MIID;
    UPDATE REQUEST_ZBSM A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

END;
/

prompt
prompt Creating package body TOOLS
prompt ===========================
prompt
CREATE OR REPLACE PACKAGE BODY "TOOLS" IS

  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    --抄表月份
    RETURN FPARA(P_SMFID, '000009');
  END;

  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE AS
    XTRQ DATE;
  BEGIN
    SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYY/MM/DD')
      INTO XTRQ
      FROM DUAL;
    RETURN XTRQ;
  END;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) >= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMAX;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) <= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMIN;

END TOOLS;
/

prompt
prompt Creating type body CONNSTRIMPL
prompt ==============================
prompt
CREATE OR REPLACE TYPE BODY "CONNSTRIMPL" IS
      STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT CONNSTRIMPL)
      RETURN NUMBER IS
      BEGIN
        SCTX := CONNSTRIMPL('','/');
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT CONNSTRIMPL, VALUE IN VARCHAR2) RETURN NUMBER IS
      BEGIN
        IF SELF.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := VALUE;
        ELSE
          SELF.CURRENTSTR := SELF.CURRENTSTR ||CURRENTSEPRATOR || VALUE;
        END IF;
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF IN CONNSTRIMPL, RETURNVALUE OUT VARCHAR2, FLAGS IN NUMBER) RETURN NUMBER IS
      BEGIN
        RETURNVALUE := SELF.CURRENTSTR;
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT CONNSTRIMPL, CTX2 IN CONNSTRIMPL) RETURN NUMBER IS
      BEGIN
        IF CTX2.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := SELF.CURRENTSTR;
        ELSIF SELF.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := CTX2.CURRENTSTR;
        ELSE
          SELF.CURRENTSTR := SELF.CURRENTSTR || CURRENTSEPRATOR || CTX2.CURRENTSTR;
        END IF;
        RETURN ODCICONST.SUCCESS;
      END;
      END;
/

prompt
prompt Creating trigger SMS_SEND_INSERT
prompt ================================
prompt
CREATE OR REPLACE TRIGGER SMS_SEND_INSERT
  before insert
  on sms_month_log
  for each row
declare
  day_count number;
  month_count number;
  day_max number;
  month_max number;
  -- local variables here
begin
select DAYMAX into day_max from SMS_PARAM where   ROWNUM <= 1;--日发送上限
select MONTHMAX into month_max from SMS_PARAM where  ROWNUM <= 1;--月发送上限
select count(1) into day_count from sms_month_log where SMS_USERID=:new.sms_userid  and  extract(day from CREATE_TIME)=extract(day from sysdate);--当天发送数量
select count(1) into month_count from sms_month_log where SMS_USERID=:new.sms_userid and send_success=0 and  extract(month from CREATE_TIME)=extract(month from sysdate);--当月发送数量
if(day_count>=day_max or month_count>=month_max) then
--当日或当月发送达到上限，发送状态置为否
:new.send_success:=34;
:new.send_states:=1;
:new.is_send:='N';
end if;

end SMS_SEND_INSERT;
/

prompt
prompt Creating trigger TRI_SYS_DICT_TYPE
prompt ==================================
prompt
CREATE OR REPLACE TRIGGER tri_Sys_Dict_Type BEFORE INSERT ON Sys_Dict_Type FOR EACH ROW
BEGIN SELECT Sys_Dict_Type_Dict_ID_Seq.NEXTVAL INTO :NEW.Dict_ID FROM DUAL;
END tri_Sys_Dict_Type;
/


prompt Done
spool off
set define on

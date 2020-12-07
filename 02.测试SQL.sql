--查询所有用户表
select * from user_tables
--查询所有用户表字段
select * from user_tab_columns order by table_name,column_id
--查询所有用户表字段备注
select * from user_col_comments;
--查询所有用户表备注
select * from user_tab_comments;
--查询所有同义词
SELECT * FROM SYS.ALL_SYNONYMS t WHERE t.owner in ('YYSF')
--正则表达式
select case when regexp_like( 'T0101','^T[0-9]*$') then 1 else 0 end from dual


--查询所有表说明、字段说明
select case when regexp_like(user_tab_columns.table_name,'^T[0-9]*$') then '大经理专用' else '外包' end 性质,
       user_tab_columns.table_name 表名,
       user_tab_comments.comments 表说明,
       user_tab_columns.column_name 字段名,
       user_col_comments.comments 字段说明
from user_tab_columns 
     left join user_tab_comments on user_tab_columns.table_name=user_tab_comments.table_name 
     left join user_col_comments on user_tab_columns.column_name=user_col_comments.column_name and user_tab_columns.table_name=user_col_comments.table_name
order by user_tab_columns.table_name,user_tab_columns.column_id

--创建同义词
create or replace synonym bs_menu for t01001

--同义词测试脚本
select * from bs_menu

insert into bs_menu (ID, LABEL, PARENT, ICON, COLOR) values ('002001222222222', '综合查询', '002', 'images/mainMenu/m_000.png', null);

delete from bs_menu where id='002001222222222'

alter table T01001 add test VARCHAR2(100);
alter table T01001 drop column test;

SELECT t.sql_text, t.last_load_time,t.*
FROM v$sql t
WHERE t.last_load_time IS NOT NULL
ORDER BY t.last_load_time DESC

select * from v$active_session_history 

select *
from v$sqlarea b
where sql_text like '%1307580923%'
--where b.FIRST_LOAD_TIME between '2009-10-15/09:24:47' and '2009-10-15/09:24:47' 
order by b.FIRST_LOAD_TIME 

select * from ys_yh_custinfo where yhid='1307580923'
--1 B4ADF12CF98E6179E053FB3EE931ED82  kings 1307580923    0201    1 Y 李四3   武汉市武昌区xxx路        2020-11-22 15:22:37                   Y           
select * from base_dept where dept_no='0201' and hire_code='kings'

select * from ys_yh_sbdoc where sbid='1307580923'
--1 B4ADF12CF9906179E053FB3EE931ED82  1307580923    13            2020-11-22 15:22:37                       1202011221307580923 Y N                               kings

select * from ys_yh_sbinfo where yhid='1307580923'
--1 B4ADF12CF9886179E053FB3EE931ED82  kings 1307580923  1307580923      0201  2020.11 2020.12 0200101 2               0103        01        0 2020-11-22    0       300 2020-12-1 15:38:39  300 Y             Y 4 X 12332.000   N   Y                 1                   123123      2020-11-22 15:22:37             0.00          0 0.000 0.000     Y                                                                 


select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual

select PG_CB_COST.FGETPARA('111,112,113|221,222,223|331,332,333|', 2, 3) from dual
select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual


YS_CB_MTREAD.BOOK_NO,YS_CB_MTREAD.MANAGE_NO|YS_CB_MTREAD.BOOK_NO,YS_CB_MTREAD.MANAGE_NO|

表册编码1,营销公司编码1|表册编码2,营销公司编码2





SELECT
  t.yhid 用户编号,
  t.manage_no	营销公司编码,
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
  md.sbid	水表档案编号,--(户号，入库时为空)
  md.mdno 表身码,
  md.barcode 条形码,
  md.rfid 电子标签,
  md.mdcaliber 表口径,
  md.mdbrand 表厂家,
  sb.sbname2 招牌名称,--(小区名，襄阳需求）
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
FROM
  ys_yh_custinfo t,
  ys_yh_sbinfo sb,
  ys_yh_sbdoc md
WHERE 
  t.yhid = sb.yhid
  AND sb.hire_code = t.hire_code
  AND sb.sbid = md.sbid 
  AND t.yhid = #{yhid,jdbcType=VARCHAR}
  AND sb.book_no = #{bookNo,jdbcType=VARCHAR}
  AND sb.sbid = #{sbid,jdbcType=VARCHAR}
  AND t.manage_no = #{manageNo,jdbcType=VARCHAR}





CREATE OR REPLACE PACKAGE pg_find is
  PROCEDURE findCustMeterComplexDoc(p_yhid IN VARCHAR2,bookNo IN VARCHAR2,sbid IN VARCHAR2,manageNo IN VARCHAR2 ,out_tab out sys_refcursor);
END;
CREATE OR REPLACE PACKAGE BODY PG_CB_COST IS
  PROCEDURE findCustMeterComplexDoc(p_yhid IN VARCHAR2,bookNo IN VARCHAR2,sbid IN VARCHAR2,manageNo IN VARCHAR2 ,out_tab out sys_refcursor) IS
    BEGIN
      open out_tab for SELECT
        t.yhid 用户编号,
        t.manage_no	营销公司编码,
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
        md.sbid	水表档案编号,--(户号，入库时为空)
        md.mdno 表身码,
        md.barcode 条形码,
        md.rfid 电子标签,
        md.mdcaliber 表口径,
        md.mdbrand 表厂家,
        sb.sbname2 招牌名称,--(小区名，襄阳需求）
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
      FROM
        ys_yh_custinfo t,
        ys_yh_sbinfo sb,
        ys_yh_sbdoc md
      WHERE 
        t.yhid = sb.yhid
        AND sb.hire_code = t.hire_code
        AND sb.sbid = md.sbid 
        AND t.yhid = p_yhid
        AND sb.book_no = p_bookNo
        AND sb.sbid = p_sbid
        AND t.manage_no = p_manageNo
    END;
END;


select * from YS_ZW_ARDETAIL where ARDYSJE>0
--1 70105341  kings 70105341  0 01  030201  0 0 6.700 21.00 140.700 6.700 21.00 140.700 0.000 0.00  0.000           0.00    0.00  数据迁移  0201  2010.06 1000000920        
select * from YS_ZW_ARLIST where arid='70105342'
--1 70105341  kings 70105341  0201  2010.06 2010-6-2 10:22:38 1000000920  1000000920      1 Y 1 九号院炭火锅      1             N   Y 1000000920    1 Y H 2010-6-2 10:22:38 21011   2010-6-2 10:22:38 2019-11-1   1 1 1   309 330 46        N 1   DE  X 46  381.340 0 70105341  1   2010.06 381.340 Y   2010-6-11 14:30:05  77763905  1000296694  0.000 H   030201  2010-6-2 10:22:38 2010-6-2 10:22:38 1000000920  Y 5682  21011         0 71535168  1000296694  0.00  0.00  0.00  N N N 01    0.00          N       210111  0.000 0.000         N                       
select * from ys_yh_sbinfo where sbid='1000000920'
--1 1000000920  kings 1000000920  1000000920  东吉大路南141号 21011 0201  2020.09 2020.10 020102  1   1 Y 1 Y N 01  0101  1 2016-3-6 23:25:32 1 01    | 东吉大路南141号 0 2008-11-17          1 2049  2020-10-14  393 Y N N Y 1 数据迁移  1000000920  Y 1 X 0.620 H N   N               2049    N     0 柴火大院    210111  2008-11-17            N           0               1000000920  1000000920    0.000                               Y                     

YS_ZW_ARDETAIL	应收帐明细【ARD】	ARDYSJE



select
        t.yhid 用户编号,
        t.manage_no  营销公司编码
      from
        ys_yh_custinfo t,
        ys_yh_sbinfo sb,
        ys_yh_sbdoc md
      where
        t.yhid = sb.yhid
        and sb.hire_code = t.hire_code
        and sb.sbid = md.sbid
        and (t.yhid = '1307580761' or '1307580761'='')
        and (sb.book_no = '' or '' is null)
        and (sb.sbid = '' or ''='')
        and (t.manage_no = '' or ''='')


select * from ys_yh_custinfo


select t.yhname 用户名称,
       t.yhid 客户代码,
       sb.SBSAVING 用户余额,
       t.YHCONNECTTEL 联系电话,
       t.YHMTEL 移动电话,
       sb.SBPOSITION 用水地址,--YS_YH_SBINFO	户表信息【sb】	SBPOSITION	水表接水地址
       t.YHSTATUS 用户状态,--YHSTATUS	用户状态【syscuststatus】(1正常/7销户/2预立户)
       sb.BOOK_NO 表册,--YS_YH_SBINFO	户表信息【sb】	BOOK_NO	表册(bookframe)
       sb.PRICE_NO 价格分类,--	YS_YH_SBINFO	户表信息【sb】	PRICE_NO	价格分类(priceframe)
       sb.SBCHARGETYPE 收费方式,--	YS_YH_SBINFO	户表信息【sb】	SBCHARGETYPE	收费方式(X坐收M走收)
       t.MANAGE_NO 营销公司,--	YS_YH_CUSTINFO	用户信息表【yh】	MANAGE_NO	营销公司
       t.YHIFINV 增值税发票,--外包	YS_YH_CUSTINFO	用户信息表【yh】	YHIFINV	是否普票（哈尔滨：借用做是否已打印增值税收据，reclist取值，置空）
       sb.SBPRIFLAG 合收标志,--外包	YS_YH_SBINFO	户表信息【sb】	SBPRIFLAG	合收表标志(Y-合收表标志,N-非合收主表 )
       sb.SBPRIFLAG 合收主表,--外包	YS_YH_SBINFO	户表信息【sb】	SBPRIID	合收表主表号
       sb.SBIFMP 混合用水,--外包	YS_YH_SBINFO	户表信息【sb】	SBIFMP	混合用水标志(Y-是,N-否 )
       ar.ARZNJ+ar.ARJE 合计水费,
       sb.SBSAVING 预存余额,--外包	YS_YH_SBINFO	户表信息【sb】	SBSAVING	预存款余额
       ar.ARZNJ 违约金,--外包	YS_ZW_ARLIST	应收总帐明细【AR】	ARZNJ	违约金
       ar.ARJE 本次应缴--外包	YS_ZW_ARLIST	应收总帐明细【AR】	ARJE	应收金额
from 
       ys_yh_custinfo t,
       ys_yh_sbinfo sb,
       ys_zw_arlist ar
where
       t.yhid = sb.yhid
       and sb.hire_code = t.hire_code
       and t.yhid = ar.yhid
       and sb.sbid = ar.sbid
       and (t.yhid = p_yhid or p_yhid is null)
       and (t.yhname = p_yhname or p_yhname is null)
       and (sb.SBPOSITION like '%'||b.p_sbposition||'%' or p_sbposition is null)
       and (t.YHMTEL = p_yhmtel or p_yhmtel is null)




select * from YS_ZW_PAIDMENT






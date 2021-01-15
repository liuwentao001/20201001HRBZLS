--系统表查询----------------------------------------------------------------------------------------------------
--查询所有用户表
select * from user_tables
--查询所有用户表字段
select * from user_tab_columns order by table_name,column_id
--查询所有用户表字段备注
select * from user_col_comments;
--查询所有用户表备注
select * from user_tab_comments;
--查询所有同义词
select * from sys.all_synonyms t where t.owner in ('YYSF')
--正则表达式
select case when regexp_like( 'T0101','^T[0-9]*$') then 1 else 0 end from dual
--查询所有表说明、字段说明
select
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
insert into bs_menu (id, label, parent, icon, color) values ('002001222222222', '综合查询', '002', 'images/mainMenu/m_000.png', null);
delete from bs_menu where id='002001222222222'
alter table t01001 add test varchar2(100);
alter table t01001 drop column test;
--sql执行历史
select t.sql_text, t.last_load_time,t.*
from v$sql t
where t.last_load_time is not null
order by t.last_load_time desc

select * from v$active_session_history 

select *
from v$sqlarea b
where sql_text like '%1307580923%'
--where b.first_load_time between '2009-10-15/09:24:47' and '2009-10-15/09:24:47' 
order by b.first_load_time 

--字符串转table----------------------------------------------------------------------------------------------------
--拼接字符串
select listagg(ardpiid,',') within group(order by ardpiid) from ys_zw_ardetail where ardid='0000012726'
select to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') from ys_zw_ardetail where ardid='0000012726' group by ardid
--字符串转table
with tb as
 (select '00,19,2,3,4,5,6,7,8' i_name
    from dual)
select regexp_substr(i_name, '[^,]+', 1, level) column_value
  from tb
connect by prior dbms_random.value is not null
       and level <= length(i_name) - length(replace(i_name, ',', '')) + 1;

select regexp_substr('0000012726,70105341,7,77', '[^,]+', 1, level) column_value from dual
connect by level <= length('0000012726,70105341,7,7') - length(replace('0000012726,70105341,7,7', ',', '')) + 1;

with t as(
  --select to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') a 
  select to_char(ardid||',Y*'||replace(regexp_replace(listagg(ardpiid, ',') within group(order by ardpiid),'([^,]+)(,\1)+','\1'),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') a
  from ys_zw_ardetail 
  where ardid in ('0000012726','70105341') group by ardid
)
select listagg(a,'|') within group(order by a) from tvarchar2(30) 

-------------------------------------------------
--测试

update bs_custinfo set misaving='10000000' where ciid='0100172364';--预存
update bs_meterinfo set mipfid='D0102' where miid='0100172364';--固定水价
update bs_meterinfo set mipfid='A0103' where miid='0100172364';--阶梯水价
update bs_meterinfo set mircode=2861 where miid='0100172364';
update bs_meterread set mrscode=2861 where mrid='2372463611';
update bs_meterread set mrecode=3861 where mrid='2372463611';
update bs_meterread set mrsl=1000 where mrid='2372463611';
update bs_meterread set mrifrec='N' where mrid='2372463611';
update bs_meterread set mrrecje01=null where mrid='2372463611';
update bs_meterread set mrrecje02=null where mrid='2372463611';
update bs_meterread set mrrecje03=null where mrid='2372463611';
update bs_reclist set rlscrrlmonth='2020.11' where rlmid='0100172364';
update bs_reclist set rlmonth='2020.11' where rlmid='0100172364';
commit;
delete from bs_reclist where rlcid='0100172364';
delete from bs_recdetail where rdid not in (select rlid from bs_reclist);
delete from bs_payment where pcid='0100172364';
commit;

  --追量收费 工单
select * from request_zlsf t
/*
    RENO  RESMFID CIID  CINAME  CIADR CIIFINV CINAME1 CIADR1  MIID  MIPFID  MIADR MIBFID  MIRCODE MIRECDATE REIFRESET RERCODE RECDATE RETYPE  REIFSTEP  REAPPNOTE RESTAUS REPER REFLAG  ENABLED SORTCODE  DELETEMARK  CREATEDATE  CREATEUSERID  CREATEUSERNAME  MODIFYDATE  MODIFYUSERID  MODIFYUSERNAME  REMARK  WORKNO  WORKBATCH
1 880061f2-18e7-4329-a573-d10cc95a4d88  0203  3108054610  肖乐宏 林兴小区7#3-101       3108054610  A0103 林兴小区7#3-101 03609319  887 2020-2-28 Y 800 2020-4-20 08  Y 奥德赛发送到发送到发士大夫撒地方撒地方撒地方撒旦法师打发士大夫撒地方撒旦法师打发大水                              
2 ee060c46-efc4-49c5-8fe8-7afed7195a09  0201  3101033508  左志伟 安定街12号1单元404        3101033508  A0103 安定街12号1单元404  01305202  625 2019-8-14 Y 630 2020-4-27 02  Y 说明                          备注    
3 ccb09a8e-9edf-4214-8a63-d6441974b4a2  0201  4051000079  李福海 安化街136号3-401        4051000079  A0103 安化街136号3-401  01206112  1065  2019-7-17 Y 2000  2020-4-27 01  Y 说明                          备注    
*/

select * from bs_custinfo where ciid='3108054610'
/*
    CIID  CISMFID CIPID CICLASS CIFLAG  CINAME  CIADR CISTATUS  CISTATUSDATE  CISTATUSTRANS CINEWDATE CIIDENTITYLB  CIIDENTITYNO  CIMTEL  CITEL1  CITEL2  CITEL3  CICONNECTPER  CICONNECTTEL  CIIFINV CIIFSMS CIPROJNO  CIFILENO  CIMEMO  MICHARGETYPE  MISAVING  MIEMAIL MIEMAILFLAG MIYHPJ  MISTARLEVEL ISCONTRACTFLAG  WATERPW LADDERWATERDATE CIHTBH  CIHTZQ  CIRQXZ  HTDATE  ZFDATE  JZDATE  SIGNPER SIGNID  POCID CIBANKNAME  CIBANKNO  CINAME2 CINAME1 CITAXNO CIADR1  CITEL4  CICOLUMN11  CITKZJH CICOLUMN2 CIDBZJH CICOLUMN1 CICOLUMN3 CIPASSWORD  CIUSENUM  CIAMOUNT  CIDBBS  CILTID  CIWXNO  CICQNO  REFLAG
1 3108054610  0203    1 Y 肖乐宏 林兴小区7#3-101 1 2005-11-30 14:44:39   2005-11-30  1   18245078203       肖乐宏     Y 0801038000070301011 20031008054610  正常用户老系统数据迁移   0.000                                                           1aa515d9f3eddf614434eca6fef12c46              
*/

select * from bs_meterinfo where micode='3108054610'
/*
1 3108054610  林兴小区7#3-101 03609 3108054610  0203  2019.06 2019.09 03609319  4   1 Y 1 1 A0103 1     03  CF    2005-4-4  080204    2005-4-4  080204  887 2019-9-10 14:25:14  0 Y Y N 正常用户老数据迁移【现金】 N 2 080370          036093194           肖乐宏               2015-12-19 17:11:44 2019-3-1                                            
*/


select * from bs_payment where pcid in ('2200000504','2200000409');

select * from request_yctf where reno = '1' for update

select misaving, t.* from bs_custinfo t where ciid = '3126163958' for update




/*

mrbfid    1002001 varchar2(10), optional, 表册(bookframe)
mrccode   41016746  varchar2(10), optional, 用户号
mrmid   41016746  varchar2(10), optional, 水表编号
mrstid    1 varchar2(10), optional, 行业分类
mrcreadate    2019-4-30 1:00  date, optional, 创建日期
mrreadok    n char(1), optional, 抄见标志(y-是 n-否)
mrrdate     date, optional, 抄表日期
mrprdate    2019-4-3 9:03 date, optional, 上次抄见日期
mrscode   2731  number(10), optional, 上期抄见
mrecode     number(10), optional, 本期抄见
mrsl      number(10), optional, 本期水量
mrifsubmit    y char(1), optional, 是否提交计费(y-是 n-否)
mrifhalt    n char(1), optional, 系统停算(y-是 n-否)
mrdatasource    1 char(1), optional, 抄表结果来源(1-手工,5-抄表器,9-手机抄表,k-故障换表,l-周期换表,z-追量  i-智能表接口，6-视频直读，7-集抄)
mrifrec   n char(1), optional, 已计费(y-是 n-否)
mrrecsl     number(10), optional, 应收水量
mrpfid    b0201 varchar2(10), optional, 用水类别
*/

insert into bs_meterread (mrid, mrmonth, mrsmfid, mrbfid, mrccode, mrmid, mrstid, mrcreadate, mrreadok, mrrdate, mrprdate,
       mrscode, mrecode, mrsl, mrifsubmit, mrifhalt, mrdatasource, mrifrec, mrrecsl, mrpfid )
       
select trim(to_char(seq_mrid.nextval,'0000000000')), to_char(sysdate, 'yyyy.mm'), mismfid, mibfid, micode, miid, mistid, sysdate, 'N', sysdate, sysdate, 
       0,0,0,'Y','N','Z','N',0,mipfid
from bs_meterinfo 
where miid='5118818093'




select * from bs_meterread where mrccode='5118818093';

select * from request_zlsf t where reno='ee060c46-efc4-49c5-8fe8-7afed7195a09'

select * from bs_custinfo where ciid='3101033508';

select * from bs_meterinfo where miid='3101033508'

select * from bs_meterread where mrccode='3101033508'
delete from bs_meterread where mrid='597016'

select * from bs_reclist where rlcid='3101033508'
delete from bs_reclist where rlcid='3101033508'




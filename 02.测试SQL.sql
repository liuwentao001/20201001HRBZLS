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
select * from sys.all_synonyms t where t.owner in ('YYSF');
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

--并行执行
--alter session enable parallel dml;
--update /*+ parallel(t,32)*/ bs_meterinfo t set t.mircode = (select a.mircode from meterinfo@hrbzls a where t.miid = a.miid)

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
select listagg(a,'|') within group(order by a) from t;

-------------------------------------------------
--测试

update bs_custinfo set misaving='10000000' where ciid='0100172364';--预存
update bs_meterinfo set mipfid='D0102' where miid='0100172364';--固定水价
update bs_meterinfo set mipfid='A0103' where miid='0100172364';--阶梯水价
update bs_meterinfo set mircode=0 where miid='0100172364';
update bs_meterread set mrscode=2861 where mrid='819260';
update bs_meterread set mrecode=3161 where mrid='819260';
update bs_meterread set mrsl=300 where mrid='819260';
update bs_meterread set mrifrec='N' where mrid='819260';
update bs_meterread set mrrecje01=null where mrid='819260';
update bs_meterread set mrrecje02=null where mrid='819260';
update bs_meterread set mrrecje03=null where mrid='819260';
update bs_reclist set rlscrrlmonth='2020.11' where rlmid='0100172364';
update bs_reclist set rlmonth='2020.11' where rlmid='0100172364';
commit;
delete from bs_reclist where rlcid='0100172364';
delete from bs_payment where pcid='0100172364';
commit;
update bs_meterread set mrifrec='N',mrrecsl=mrecode-mrscode where mrccode='0100172364';
commit;

update bs_reclist set rlpaidflag='N' where rlcid='0100172364';
delete from bs_payment where pcid='0100172364';
commit;
update request_yscz set rerlid='1000202081,1000202082,1000202083' where reno='6A1CEB5E34534D6380E17383F74EF4F9';
commit;

select * from bs_custinfo where ciid='0100172364';
select * from bs_meterinfo where micode='0100172364';
select * from bs_meterread where mrccode='0100172364' order by mrid;-- for update;
select * from bs_bookframe where bfid = '01003003';
select * from bs_reclist where rlcid='0100172364';
select * from bs_recdetail where rdid in (select rlid from bs_reclist where rlcid='0100172364') order by rdid ,rdpiid,rdclass;
select * from bs_pricestep where pspfid='A0103' order by pspfid ,pspiid, psclass;
select * from bs_payment where pcid='0100172364'


select * from request_bjsf where reno='00F224A227A9434D855F5BC124792308' for update;

开始执行补缴收费工单。工单编号：00F224A227A9434D855F5BC124792308
开始执行工单。生成抄表记录：生成抄表记录成功2377621192
开始执行补缴收费工单。算费：
补缴收费工单完成。工单编号：00F224A227A9434D855F5BC124792308

select * from bs_meterinfo where miid='8091680891'
select * from bs_meterread where mrid = '2377621192'
select * from bs_reclist where rlmrid='2377621192'
select * from bs_recdetail where rdid='1000202123'
select * from bs_priceframe where pfid='A0103';
select * from bs_pricestep where pspfid='A0103' order by pspfid ,pspiid, psclass;
select * from bs_pricedetail where pdpfid='A0103'
--929	1015	86 86	774.000
select 1015-929,774/86 from dual
--9





select * from bs_priceframe order by pfid;
select * from bs_pricestep order by pspfid ,pspiid, psclass;
select * from bs_pricedetail order by pdpfid;








--追量收费正向调整测试
update request_zlsf set reshbz = 'Y',rewcbz='N' where reno='ee060c46-efc4-49c5-8fe8-7afed7195a09';
commit;
delete from bs_meterread where mrccode='3101033508';
delete from bs_reclist where rlcid='3101033508';
commit;

select * from request_zlsf t where reno='ee060c46-efc4-49c5-8fe8-7afed7195a09';
select * from bs_custinfo where ciid='3101033508';
select * from bs_meterinfo where miid='3101033508';
select * from bs_meterread where mrccode='3101033508';
select * from bs_reclist where rlcid='3101033508';

--追量收费反向调整测试
update request_zlsf set reshbz = 'Y',rewcbz='N' where reno='880061f2-18e7-4329-a573-d10cc95a4d88'; 
commit;
delete from bs_meterread where mrccode='3108054610';
delete from bs_reclist where rlcid='3108054610';
delete from bs_payment where pcid='3108054610';
update bs_custinfo set misaving = 0 where ciid='3108054610';
update bs_meterinfo set mircode = 887 where micode='3108054610';
commit;

select * from request_zlsf t where reno='880061f2-18e7-4329-a573-d10cc95a4d88';
select misaving,ci.* from bs_custinfo ci where ciid='3108054610';
select mi.* from bs_meterinfo mi where micode='3108054610';
select * from bs_meterread where mrccode='3108054610';
select * from bs_reclist where rlcid='3108054610';
select * from bs_recdetail where rdid in (select rlid from bs_reclist where rlcid='3108054610');
select * from bs_payment where pcid='3108054610';


--补缴收费
insert into request_bjsf (reno,resmfid,ciid,ciname,ciadr,ciifinv,ciname1,ciadr1,miid,mipfid,miadr,mibfid,mircode,mirecdate,reifreset,rercode,recdate,retype,reifstep,reappnote,restaus,reper,reflag,enabled,sortcode,deletemark,createdate,createuserid,createusername,modifydate,modifyuserid,modifyusername,remark,workno,workbatch,reshbz,rewcbz)
select reno,resmfid,ciid,ciname,ciadr,ciifinv,ciname1,ciadr1,miid,mipfid,miadr,mibfid,mircode,mirecdate,reifreset,rercode,recdate,retype,reifstep,reappnote,restaus,reper,reflag,enabled,sortcode,deletemark,createdate,createuserid,createusername,modifydate,modifyuserid,modifyusername,remark,workno,workbatch,reshbz,rewcbz from request_zlsf;


update request_bjsf set reshbz = 'Y',rewcbz='N' where reno='ee060c46-efc4-49c5-8fe8-7afed7195a09';
commit;
delete from bs_meterread where mrccode='3101033508';
delete from bs_reclist where rlcid='3101033508';
commit;

select * from request_bjsf t where reno='ee060c46-efc4-49c5-8fe8-7afed7195a09';
select * from bs_custinfo where ciid='3101033508';
select * from bs_meterinfo where miid='3101033508';
select * from bs_meterread where mrccode='3101033508';
select * from bs_reclist where rlcid='3101033508';



--呆账坏账工单处理
update request_dhgl set rlid = '1000202111,1000202112,1000202113',rewcbz = 'N' ,reshbz='Y'  where reno='dh1';
commit;

update bs_reclist set rlpaidflag = 'N' where rlcid='0100172364';
delete from bs_payment where pcid='0100172364';
commit;


select * from bs_reclist where rlcid='0100172364';
select * from request_dhgl t;

select * from bs_payment where pcid='0100172364';


---出票
truncate table pj_inv_info
select * from pj_inv_info
select * from bs_reclist where rlreverseflag<>'Y' and rlpaidflag <> 'Y' and rlreadsl>0
select * from bs_payment where pid <= '0000248146' order by pid desc 
      
--收费员结账
update sys_user set chk_date = null where user_id = '1';
truncate table request_jzgd;
update bs_payment set pchkno = null where ppayee = '1';
commit;

update bs_payment set ppayway = 'XJ' where ppayee='1';
commit;

select * from sys_user where user_id = '1';

select * from request_jzgd;

select * from bs_reclist rl where rl.rlcid = '2200000470';
      
select * from bs_recdetail rd where rdid in (select rlid from bs_reclist rl where rl.rlcid = '2200000470') ;

select * from bs_payment where ppayee='1';




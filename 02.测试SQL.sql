--ϵͳ���ѯ----------------------------------------------------------------------------------------------------
--��ѯ�����û���
select * from user_tables
--��ѯ�����û����ֶ�
select * from user_tab_columns order by table_name,column_id
--��ѯ�����û����ֶα�ע
select * from user_col_comments;
--��ѯ�����û���ע
select * from user_tab_comments;
--��ѯ����ͬ���
SELECT * FROM SYS.ALL_SYNONYMS t WHERE t.owner in ('YYSF')
--������ʽ
select case when regexp_like( 'T0101','^T[0-9]*$') then 1 else 0 end from dual
--��ѯ���б�˵�����ֶ�˵��
select case when regexp_like(user_tab_columns.table_name,'^T[0-9]*$') then '����ר��' else '���' end ����,
       user_tab_columns.table_name ����,
       user_tab_comments.comments ��˵��,
       user_tab_columns.column_name �ֶ���,
       user_col_comments.comments �ֶ�˵��
from user_tab_columns 
     left join user_tab_comments on user_tab_columns.table_name=user_tab_comments.table_name 
     left join user_col_comments on user_tab_columns.column_name=user_col_comments.column_name and user_tab_columns.table_name=user_col_comments.table_name
order by user_tab_columns.table_name,user_tab_columns.column_id
--����ͬ���
create or replace synonym bs_menu for t01001
--ͬ��ʲ��Խű�
select * from bs_menu
insert into bs_menu (ID, LABEL, PARENT, ICON, COLOR) values ('002001222222222', '�ۺϲ�ѯ', '002', 'images/mainMenu/m_000.png', null);
delete from bs_menu where id='002001222222222'
alter table T01001 add test VARCHAR2(100);
alter table T01001 drop column test;
--SQLִ����ʷ
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

--�ַ���תtable----------------------------------------------------------------------------------------------------
--ƴ���ַ���
select listagg(ardpiid,',') within group(order by ardpiid) from ys_zw_ardetail where ardid='0000012726'
select to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') from ys_zw_ardetail where ardid='0000012726' group by ardid
--�ַ���תtable
WITH tb AS
 (SELECT '0,1,2,3,4,5,6,7,8' i_name
    FROM dual)
SELECT regexp_substr(i_name, '[^,]+', 1, LEVEL) COLUMN_VALUE
  FROM tb
CONNECT BY PRIOR dbms_random.value IS NOT NULL
       AND LEVEL <= length(i_name) - length(REPLACE(i_name, ',', '')) + 1;

select regexp_substr('0000012726,70105341,7,77', '[^,]+', 1, level) column_value from dual
connect by level <= length('0000012726,70105341,7,7') - length(replace('0000012726,70105341,7,7', ',', '')) + 1;

with t as(
  --select to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') a 
  select to_char(ardid||',Y*'||replace(regexp_replace(listagg(ardpiid, ',') within group(order by ardpiid),'([^,]+)(,\1)+','\1'),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') a
  from ys_zw_ardetail 
  where ardid in ('0000012726','70105341') group by ardid
)
select listagg(a,'|') within group(order by a) from t

--�����ˮ���ݿ������Ϣ���ѯ----------------------------------------------------------------------------------------------------
--��ȡ�ַ���
select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual
select PG_CB_COST.FGETPARA('111,112,113|221,222,223|331,332,333|', 2, 3) from dual
select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual
/*
�û��ֵ�	        base_user_dictionary
���ű�	           base_dept
������Ŀ	        bas_price_item
������ϸ	        bas_price_detail
�û���Ϣ��yh��	 ys_yh_custinfo
ˮ����	        ys_yh_sbdoc
������Ϣ��sb��	  ys_yh_sbinfo
Ӧ������ϸ��ard��     ys_zw_ardetail
Ӧ��������ϸ��ar��	  ys_zw_arlist
����ס�p��	        ys_zw_paidment
*/

select dic_value,dic_name from base_user_dictionary where parent_id = (select id from base_user_dictionary where dic_value='SWMS_SYS_CHEQUETYPE') order by show_order

select * from ys_yh_custinfo where yhid='1307580923'
--1 B4ADF12CF98E6179E053FB3EE931ED82  kings 1307580923    0201    1 Y ����3   �人�������xxx·        2020-11-22 15:22:37                   Y           
select * from base_dept where dept_no='0201' and hire_code='kings'

select * from ys_yh_sbdoc where sbid='1307580923'
--1 B4ADF12CF9906179E053FB3EE931ED82  1307580923    13            2020-11-22 15:22:37                       1202011221307580923 Y N                               kings

select * from ys_yh_sbinfo where yhid='1307580923'
--1 B4ADF12CF9886179E053FB3EE931ED82  kings 1307580923  1307580923      0201  2020.11 2020.12 0200101 2               0103        01        0 2020-11-22    0       300 2020-12-1 15:38:39  300 Y             Y 4 X 12332.000   N   Y                 1                   123123      2020-11-22 15:22:37             0.00          0 0.000 0.000     Y                                                                 
select * from ys_zw_ardetail where ARDYSJE>0
--1 70105341  kings 70105341  0 01  030201  0 0 6.700 21.00 140.700 6.700 21.00 140.700 0.000 0.00  0.000           0.00    0.00  ����Ǩ��  0201  2010.06 1000000920        
select * from ys_zw_arlist where arid='70105342'
--1 70105341  kings 70105341  0201  2010.06 2010-6-2 10:22:38 1000000920  1000000920      1 Y 1 �ź�Ժ̿���      1             N   Y 1000000920    1 Y H 2010-6-2 10:22:38 21011   2010-6-2 10:22:38 2019-11-1   1 1 1   309 330 46        N 1   DE  X 46  381.340 0 70105341  1   2010.06 381.340 Y   2010-6-11 14:30:05  77763905  1000296694  0.000 H   030201  2010-6-2 10:22:38 2010-6-2 10:22:38 1000000920  Y 5682  21011         0 71535168  1000296694  0.00  0.00  0.00  N N N 01    0.00          N       210111  0.000 0.000         N                       
select *
from ys_zw_ardetail ard, ys_zw_arlist ar
where ar.arid=ard.ardid

select * from bas_price_item

select * from bas_price_detail

select * from base_user_dictionary

select * from ys_zw_paidment t WHERE PID='0000247255' for update 

select * from ys_cb_mtread 

select * from ys_zw_arlist where aroutflag='Y' and yhid='1000005954'
select aroutflag,ys_zw_arlist.* from ys_zw_arlist where armonth='2020.11' and yhid='1000005954'

-------------------------------------------------
--�ɷѲ���
select rlje, t.* from bs_reclist t where rlpaidflag = 'N' and rlreverseflag = 'N'and rlje > 0 and rlcid='8091680510'

select misaving,t.* from bs_custinfo t where ciid = '8091680510'

select * from bs_payment where pid='0000247441'
select * from bs_payment where pid='0000247438'

--��������
delete from bs_reclist_sscz_temp;
update bs_payment set preverseflag='N' where pid='0000247400';
delete from bs_payment where pid='0000247408';
commit;

--��������
select rlje, t.* from bs_reclist t where rlid='0325058150'
select rlje, t.* from bs_reclist t where rlcid='7031434576' order by rlid desc;
select rlje, t.* from bs_reclist t where rlcid='7031434576' and rlpaidflag = 'N' and rlreverseflag='N'

delete from bs_reclist_sscz_temp
select * from bs_reclist_sscz_temp

select * from bs_reclist where rlpid = '0000247400'
select * from bs_reclist where rlid = '0000200007'

insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = '0000247400' and rlpaidflag = 'Y'
insert into bs_reclist_temp (select t.* from bs_reclist t where rlpid = '0000247400' and rlpaidflag = 'Y');

delete from bs_reclist_sscz_temp where rlpid = '0000247400' and rlpaidflag = 'Y';
insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = '0000247400' and rlpaidflag = 'Y';


---------------------------------------------------
--��Ѳ���
select mrid,mrccode,mrmid,mrscode,mrecode,mrdatasource,t.* from bs_meterread t where mrifrec='N' and mrid='2372463611';
/*
MRID	2372463611	varchar2(10), mandatory, ��ˮ��
MRCCODE	0100172364	varchar2(10), optional, �û���
MRMID	0100172364	varchar2(10), optional, ˮ����
MRSCODE	1861	number(10), optional, ���ڳ���
MRECODE	1961	number(10), optional, ���ڳ���

*/
--          if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('m','l') then
select mircode,mipfid,t.* from bs_meterinfo t where miid='0100172364';
/*
MIRCODE	1861	number(10), optional, ���ڶ���
MIPFID	D0102	varchar2(10), optional, ��ˮ����(priceframe)
*/

--��Ч�Ľ��ݼƷ�����
select *
from bs_pricestep
where pspscid = pd.pdpscid
and pspfid = pd.pdpfid
and pspiid = pd.pdpiid
order by psclass;

select * from bs_pricedetail

update bs_meterinfo set mipfid='D0102' where miid='0100172364';--�̶�ˮ��
update bs_meterinfo set mipfid='A0103' where miid='0100172364';--����ˮ��
update bs_meterinfo set mircode=1861 where miid='0100172364';
update bs_meterread set mrscode=1861 where mrid='2372463611';
update bs_meterread set mrecode=2861 where mrid='2372463611';
update bs_meterread set mrsl=1000 where mrid='2372463611';
update bs_meterread set mrifrec='N' where mrid='2372463611';
commit;

select mrid,mrccode,mrmid,mrscode,mrecode,mrdatasource,mrifrec,t.* from bs_meterread t where mrid='2372463611';

select * from bs_reclist where rlmid='0100172364'
select * from bs_recdetail where rdid in (select rlid from bs_reclist where rlmid='0100172364' );

select * from bs_pricedetail where pdpfid='A0103' for update;

select * from bs_pricedetail t where pdpfid = 'A0103'
/*
PDPSCID 0 number, mandatory, ��������
PDPFID  A0103 varchar2(10), mandatory, ���ʱ���
PDPIID  01  char(2), mandatory, ������Ŀ
PDDJ  1.000 number(12,3), optional, ����
PDSL  10  number(10), optional, ˮ��
PDJE  10.00 number(12,2), optional, ���
PDMETHOD  02  varchar2(3), mandatory, �Ʒѷ���
PDSDATE   date, optional, ��ʼ����
PDEDATE   date, optional, ��������
PDSMONTH    varchar2(7), optional, ��ʼ�·�
PDEMONTH    varchar2(7), optional, �����·�
*/

select * from bs_pricestep where pspscid = 0 and pspfid = 'A0103' for update
--and pspiid = 03








































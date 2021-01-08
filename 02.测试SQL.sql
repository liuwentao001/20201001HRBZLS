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
select
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
 (SELECT '00,19,2,3,4,5,6,7,8' i_name
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
/*
1 42.600  0319688896  0201  2019.07 2019-7-10 8091680510  8091680510  010541  ����־ ����·51��2��Ԫ202  ����·51��2��Ԫ202  1     N   N   1 Y 1 2019-6-30 1:46:41 01202113  150 162 12  1 X 12  42.600  0319688896  1 2019.07 0.000 N     2373978676  �Ⳮ��   [0000.00��ʷ����] A0107 2019-7-10 9:09:22 2019-7-10 N 010541      0.00  0.00  0.00  N N   15.800  0.000   0319688896        
2 42.600  0321498775  0201  2019.10 2019-10-10  8091680510  8091680510  010541  ����־ ����·51��2��Ԫ202  ����·51��2��Ԫ202  1     N   N   1 Y 1 2019-9-30 1:44:08 01202113  162 174 12  1 X 12  42.600  0321498775  1 2019.10 0.000 N     2376294324  �Ⳮ��   [0000.00��ʷ����] A0107 2019-10-10 9:27:41  2019-10-10  N 010541      0.00  0.00  0.00  N N   15.800  0.000   0321498775        
3 42.600  0323262960  0201  2020.01 2020-1-6  8091680510  8091680510  010541  ����־ ����·51��2��Ԫ202  ����·51��2��Ԫ202  1     N   N   1 Y 1 2019-12-31 2:13:22  01202113  174 186 12  1 X 12  42.600  0323262960  1 2020.01 0.000 N     2378770063  �Ⳮ��   [0000.00��ʷ����] A0107 2020-1-6 11:02:14 2020-1-6  N 010541      0.00  0.00  0.00  N N   15.800  0.000   0323262960        
*/


select misaving,t.* from bs_custinfo t where ciid = '8091680510'

select * from bs_payment where pid='0000247683';
select * from bs_payment where pid='0000247684';
select * from bs_payment where pid='0000247685';
select * from bs_payment where pid='0000247686';

select * from bs_reclist where rlpid='0000247678';

select rlje, t.* from bs_reclist t where rlcid='8091680510' and rlid in ('0319688896','0321498775','0323262960')


--��������
update bs_payment set preverseflag='N' where pid='0000247400';
delete from bs_payment where pid='0000247408';
commit;

--��������
select * from bs_payment where pid='0000247644'

select rlje, t.* from bs_reclist t where rlid='0325058150'
select rlje, t.* from bs_reclist t where rlcid='8091680510' order by rlid desc;
select rlje, t.* from bs_reclist t where rlcid='7031434576' and rlpaidflag = 'N' and rlreverseflag='N'

select * from bs_reclist where rlpid = '0000247400'
select * from bs_reclist where rlid = '0000200007'

delete from bs_reclist_sscz_temp where rlpid = '0000247400' and rlpaidflag = 'Y';
insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = '0000247400' and rlpaidflag = 'Y';

select * from bs_recdetail where rdid='0319688896'
select * from bs_recdetail where rdid='1000200096'
--������������
select * from bs_payment where preverseflag <> 'Y';
/*
119 123 1300522001  1300522001  2020-6-18 2020-6-18 10:22:06  2020.06 0201  P       100.00  XJ        2020061801  5455    N 123 P 2020.06 2020-6-18               
120 124 1300522001  1300522001  2020-6-18 2020-6-18 10:27:35  2020.06 0201  P 0.00  100.00  100.00  100.00  XJ        2020061802  5455    N 124 P 2020.06 2020-6-18               
*/
select * from bs_payment where pid in('123','124','0000247546','0000247547')

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

�²����û��� 2200000480
ˮ��� 2200000481

select * from bs_custinfo where ciid='2200000480'
select * from bs_meterinfo where micode='2200000480';
select * from bs_meterread where mrccode='2200000480'





select * from bs_pricedetail
select * from bs_custinfo where ciid='0100172364'
select * from bs_meterinfo where micode='0100172364';
select * from bs_meterread where mrid='2372463611';

update bs_custinfo set misaving='10000000' where ciid='0100172364';--Ԥ��
update bs_meterinfo set mipfid='D0102' where miid='0100172364';--�̶�ˮ��
update bs_meterinfo set mipfid='A0103' where miid='0100172364';--����ˮ��
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
update request_yscz set reshbz = 'Y',rewcbz = 'N',rerlid='1000201774',rerlid_rev='',rercodeflag='Y' where reno='36C5D8097D4F406285E158A8E2DCF178';
commit;


select * from bs_reclist where rlcid='0100172364' order by rlid
delete from bs_reclist where rlcid='0100172364' 

select * from request_yscz;
select * from bs_reclist t where t.rlid = '1000201772'

select * from bs_meterread where mrid='2372463611';

select mrid,mrccode,mrmid,mrscode,mrecode,mrdatasource,mrifrec,t.* from bs_meterread t where mrid='2372463611' ;

select * from bs_reclist where rlmid='0100172364' --for update
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


select miclass, mipid from bs_meterinfo where micode = 0100172364;
select * from bs_meterinfo

select * from bs_meterread where mrccode='0100172364';
select mrid,mrccode,mrmid,mrscode,mrecode,mrdatasource,t.* from bs_meterread t where mrid='2372463611';
select rlje, t.* from bs_reclist t where rlpaidflag = 'N' and rlreverseflag = 'N'and rlje > 0 and rlcid='0100172364'
select rlje, t.* from bs_reclist t where rlcid='0100172364' and rlpaidflag = 'N'

select rlje, t.* from bs_reclist t where rlcid='0100172364'
select t.* from bs_recdetail t where rdid='1000200456'
select * from bs_payment where pcid='0100172364';
--1 0000247527  0100172364  0100172364  2020-12-29  2020-12-29 9:28:11  2020-12 1 P 10000000.00 -39600.00 9960400.00  0.00  XJ        0000247485  1   N 0000247527  P 2020-12 2020-12-29                          
--0000247528     --������payment.id
select rlje, t.* from bs_reclist t where rlcid='0100172364' or rlid='1000200448'



select * from bs_reclist t where t.rlid = '1000201732'

--0100172364,3126163958,3126163992
select t.misaving,t.* from bs_custinfo t where ciid in ('0100172364','3126163958','3126163992')

0000247687,0000247688,0000247689

select * from bs_payment where pid='0000247702'


select * from bs_custinfo where ciid='2200000502'
select * from bs_meterinfo where micode='2200000502'
select * from bs_meterread where mrccode='2200000502'
--1 596994  2019.08 0201  01004003  1     2200000502  2200000503  1   1   2021-1-5 15:05:56 2021-1-5 16:07:37 Y 2021-1-5  010542    20  400 380 02  N N 1 ����  N Y 2021-1-5 16:10:37 380 0 0 Y     ȷ��ͨ��        08  0   1   100 BF  0 0 0 988.000 361.000 0.000             N                   
select * from bs_reclist where rlmrid='596994' order by rlid
select * from bs_payment where pcid='2200000502' order by pid desc



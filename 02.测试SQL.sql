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
--SQL执行历史
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

--字符串转table----------------------------------------------------------------------------------------------------
--拼接字符串
select listagg(ardpiid,',') within group(order by ardpiid) from ys_zw_ardetail where ardid='0000012726'
select to_char(ardid||',Y*'||replace(wm_concat(distinct ardpiid),',','!Y*')||','||sum(nvl(ardznj,0))||',0,0,0') from ys_zw_ardetail where ardid='0000012726' group by ardid
--字符串转table
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

--外包供水数据库基础信息表查询----------------------------------------------------------------------------------------------------
--截取字符串
select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual
select PG_CB_COST.FGETPARA('111,112,113|221,222,223|331,332,333|', 2, 3) from dual
select PG_CB_COST.FBOUNDPARA('111,112,113|221,222,223|331,332,333|') from dual
/*
用户字典	        base_user_dictionary
部门表	           base_dept
费率项目	        bas_price_item
费率明细	        bas_price_detail
用户信息表【yh】	 ys_yh_custinfo
水表档案	        ys_yh_sbdoc
户表信息【sb】	  ys_yh_sbinfo
应收帐明细【ard】     ys_zw_ardetail
应收总帐明细【ar】	  ys_zw_arlist
付款交易【p】	        ys_zw_paidment
*/

select dic_value,dic_name from base_user_dictionary where parent_id = (select id from base_user_dictionary where dic_value='SWMS_SYS_CHEQUETYPE') order by show_order

select * from ys_yh_custinfo where yhid='1307580923'
--1 B4ADF12CF98E6179E053FB3EE931ED82  kings 1307580923    0201    1 Y 李四3   武汉市武昌区xxx路        2020-11-22 15:22:37                   Y           
select * from base_dept where dept_no='0201' and hire_code='kings'

select * from ys_yh_sbdoc where sbid='1307580923'
--1 B4ADF12CF9906179E053FB3EE931ED82  1307580923    13            2020-11-22 15:22:37                       1202011221307580923 Y N                               kings

select * from ys_yh_sbinfo where yhid='1307580923'
--1 B4ADF12CF9886179E053FB3EE931ED82  kings 1307580923  1307580923      0201  2020.11 2020.12 0200101 2               0103        01        0 2020-11-22    0       300 2020-12-1 15:38:39  300 Y             Y 4 X 12332.000   N   Y                 1                   123123      2020-11-22 15:22:37             0.00          0 0.000 0.000     Y                                                                 
select * from ys_zw_ardetail where ARDYSJE>0
--1 70105341  kings 70105341  0 01  030201  0 0 6.700 21.00 140.700 6.700 21.00 140.700 0.000 0.00  0.000           0.00    0.00  数据迁移  0201  2010.06 1000000920        
select * from ys_zw_arlist where arid='70105342'
--1 70105341  kings 70105341  0201  2010.06 2010-6-2 10:22:38 1000000920  1000000920      1 Y 1 九号院炭火锅      1             N   Y 1000000920    1 Y H 2010-6-2 10:22:38 21011   2010-6-2 10:22:38 2019-11-1   1 1 1   309 330 46        N 1   DE  X 46  381.340 0 70105341  1   2010.06 381.340 Y   2010-6-11 14:30:05  77763905  1000296694  0.000 H   030201  2010-6-2 10:22:38 2010-6-2 10:22:38 1000000920  Y 5682  21011         0 71535168  1000296694  0.00  0.00  0.00  N N N 01    0.00          N       210111  0.000 0.000         N                       
select *
from ys_zw_ardetail ard, ys_zw_arlist ar
where ar.arid=ard.ardid

select * from bas_price_item

select * from bas_price_detail

select * from base_user_dictionary

select * from ys_zw_paidment t WHERE PID='0000247255' for update 


select * from ys_cb_mtread 


 select
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
        and yhid = 
        
select * from ys_zw_arlist where arpid='0000247323'

select 
  yhid 客户代码,
  arrdate 抄表日期,
  armonth 账务月份,
  ardate 账务日期,
  arscode 起数,
  arecode 止数,
  arsl 应收水量,
  arje 应收金额,
  arznj 违约金
from ys_zw_arlist 
where arpid='0000247323'


select * from ys_zw_arlist where aroutflag='Y' and yhid='1000005954'
select aroutflag,ys_zw_arlist.* from ys_zw_arlist where armonth='2020.11' and yhid='1000005954'



select * from ys_zw_paidment order by pdatetime desc 

 where yhid='1307580783'



    select a.pdpers,a.type,a.pdpayway,a.jfNums,a.zfNums,a.paidment,nvl(su.true_name,a.pdpers) paidPerName from (
    SELECT
    pdpers as pdpers,
    '1' type,
    pdpayway pdpayway,
    sum( CASE WHEN yzp.preverseflag = 'N' AND yzp.paidment > 0 THEN 1 ELSE 0 END ) jfNums,
    sum( CASE WHEN yzp.preverseflag = 'Y' AND yzp.paidment > 0 THEN 1 ELSE 0 END ) zfNums,
    sum( CASE WHEN yzp.preverseflag = 'N' AND yzp.paidment > 0 THEN yzp.paidment ELSE 0 END ) paidment,
    yzp.hire_code
    FROM
    ys_zw_paidment yzp,ys_yh_custinfo yyc
    WHERE
    1 = 1 and yzp.yhid = yyc.yhid and yzp.hire_code = yyc.hire_code
    AND yzp.pdatetime <![CDATA[>=]]> to_date(#{pdatetimes,jdbcType=VARCHAR}, 'yyyy-MM-dd' )
    AND yzp.pdatetime <![CDATA[<]]>  to_date( #{pdatetimee,jdbcType=VARCHAR}, 'yyyy-MM-dd' )
    AND yzp.HIRE_CODE = #{hireCode,jdbcType=VARCHAR}
    <if test="pdpers  != null and  pdpers !='' ">
      AND yzp.pdpers = #{pdpers,jdbcType=VARCHAR}
    </if>
    <if test="manageNo  != null and  manageNo !='' ">
      and yzp.manage_No = #{manageNo,jdbcType=VARCHAR}
    </if>
    GROUP BY
    yzp.pdpers,
    yzp.hire_code,
    yzp.pdpayway
    UNION ALL
    SELECT
    pdpers as pdpers,
    '2' type,
    pdpayway pdpayway,
    sum( CASE WHEN yzp.preverseflag = 'N' AND yzp.pdspje = 0 THEN 1 ELSE 0 END ) jfNums,
    sum( CASE WHEN yzp.preverseflag = 'Y' AND yzp.pdspje = 0 THEN 1 ELSE 0 END ) zfNums,
    sum( CASE WHEN yzp.preverseflag = 'N' AND yzp.pdspje = 0 THEN yzp.paidment ELSE 0 END ) paidment,
    yzp.hire_code
    FROM
    ys_zw_paidment yzp,ys_yh_custinfo yyc
    WHERE
    1 = 1 and yzp.yhid = yyc.yhid and yzp.hire_code = yyc.hire_code
    AND yzp.pdatetime <![CDATA[>=]]> to_date(#{pdatetimes,jdbcType=VARCHAR}, 'yyyy-MM-dd' )
    AND yzp.pdatetime <![CDATA[<]]> to_date( #{pdatetimee,jdbcType=VARCHAR}, 'yyyy-MM-dd' )
    AND yzp.HIRE_CODE = #{hireCode,jdbcType=VARCHAR}
    <if test="pdpers  != null and  pdpers !='' ">
      AND yzp.pdpers = #{pdpers,jdbcType=VARCHAR}
    </if>
    <if test="manageNo  != null and  manageNo !='' ">
      and yzp.manage_No = #{manageNo,jdbcType=VARCHAR}
    </if>
    GROUP BY
    yzp.pdpers,
    yzp.pdpayway,
    yzp.hire_code
    ) a  LEFT JOIN base_user su on su.hire_code = a.hire_code and su.user_name = a.pdpers
    order by pdpers ,type,pdpayway
        

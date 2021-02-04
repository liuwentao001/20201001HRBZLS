create or replace force view hrbzls.view_usertabandcolqulity as
select t2.table_name   表名,
       t1.comments     表的说明,
       t2.COLUMN_NAME  字段名,
       t3.comments 字段说明,
       t2.DATA_TYPE    数据类型,
       t2.DATA_LENGTH  长度,
       t2.NULLABLE 是否为空,
       t2.DATA_DEFAULT 默认值,
       t2.COLUMN_ID    字段序号
  from USER_TAB_COMMENTS T1 ,USER_TAB_COLUMNS t2,user_col_comments t3,USER_OBJECTS T4 where T1.table_name=T2.TABLE_NAME and T1.table_name=t3.table_name and T1.table_name=T4.OBJECT_NAME AND  t2.COLUMN_NAME=t3.column_name AND T4.OBJECT_TYPE='TABLE'
order by t2.table_name,t2.COLUMN_ID;


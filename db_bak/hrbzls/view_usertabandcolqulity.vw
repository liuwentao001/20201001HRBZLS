create or replace force view hrbzls.view_usertabandcolqulity as
select t2.table_name   ����,
       t1.comments     ���˵��,
       t2.COLUMN_NAME  �ֶ���,
       t3.comments �ֶ�˵��,
       t2.DATA_TYPE    ��������,
       t2.DATA_LENGTH  ����,
       t2.NULLABLE �Ƿ�Ϊ��,
       t2.DATA_DEFAULT Ĭ��ֵ,
       t2.COLUMN_ID    �ֶ����
  from USER_TAB_COMMENTS T1 ,USER_TAB_COLUMNS t2,user_col_comments t3,USER_OBJECTS T4 where T1.table_name=T2.TABLE_NAME and T1.table_name=t3.table_name and T1.table_name=T4.OBJECT_NAME AND  t2.COLUMN_NAME=t3.column_name AND T4.OBJECT_TYPE='TABLE'
order by t2.table_name,t2.COLUMN_ID;


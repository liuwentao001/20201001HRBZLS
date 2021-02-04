CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORTSUM_XY" is

  -- Author  : stevewei
  -- Created : 2012-0101
  -- Purpose : 月报

--从实例化视图生成 0--实时 1--重算
  ls_need_reeval constant integer := 1;

   procedure 预存存档(a_month in varchar2);
   procedure 抄表统计(a_month in varchar2);
   procedure 账务明细统计(a_month in varchar2);
   procedure 收费统计(a_month in varchar2);
   procedure 综合统计(a_month in varchar2);
   procedure 综合月报(a_month in varchar2);

end;
/


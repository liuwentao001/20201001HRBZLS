CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_YWB_01" is
--具体项目特殊业务包
  操作员领取户号数 number(10) := 50;
  PROCEDURE 重新生成数据;
  PROCEDURE 操作员获取欠费用户(p_per in varchar2);
end;
/


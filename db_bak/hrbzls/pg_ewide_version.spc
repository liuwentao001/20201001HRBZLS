CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_VERSION" IS
  errcode constant integer := -20012;
  -- Author  : 刘光波
  -- Created : 2012/7/5 10:44:00
  -- Purpose : lgb
  --memo: 水价及账务归档
  --  指标执行  p_month ：归档月份  p_oper ：归档人员
 PROCEDURE price_version(p_Smonth IN VARCHAR2,p_emonth in varchar2,p_memo in varchar2,p_oper in varchar2);

END PG_ewide_Version;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_VERSION" IS
  errcode constant integer := -20012;
  -- Author  : ���Ⲩ
  -- Created : 2012/7/5 10:44:00
  -- Purpose : lgb
  --memo: ˮ�ۼ�����鵵
  --  ָ��ִ��  p_month ���鵵�·�  p_oper ���鵵��Ա
 PROCEDURE price_version(p_Smonth IN VARCHAR2,p_emonth in varchar2,p_memo in varchar2,p_oper in varchar2);

END PG_ewide_Version;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORTSUM_XY" is

  -- Author  : stevewei
  -- Created : 2012-0101
  -- Purpose : �±�

--��ʵ������ͼ���� 0--ʵʱ 1--����
  ls_need_reeval constant integer := 1;

   procedure Ԥ��浵(a_month in varchar2);
   procedure ����ͳ��(a_month in varchar2);
   procedure ������ϸͳ��(a_month in varchar2);
   procedure �շ�ͳ��(a_month in varchar2);
   procedure �ۺ�ͳ��(a_month in varchar2);
   procedure �ۺ��±�(a_month in varchar2);

end;
/


CREATE OR REPLACE PACKAGE pg_meter_cost is
  /*����ģ�
   ys_zw_ardetail
   ys_zw_arlist

  �������ϣ�
   ys_yh_sbdoc
   ys_yh_sbinfo
   ys_yh_pricegroup
   ys_yh_custinfo
   ys_yh_account

  ˮ�ۣ�
   bas_price_name
   bas_price_detail
   bas_price_step

  ����
   ys_cb_mtread*/

  ���ύ CONSTANT NUMBER := 0;
  �ύ   CONSTANT NUMBER := 1;
  ����   CONSTANT NUMBER := 2;
  PROCEDURE PTEST(P_TXT IN VARCHAR2);
end;
/


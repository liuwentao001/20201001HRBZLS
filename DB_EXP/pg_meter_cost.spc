CREATE OR REPLACE PACKAGE pg_meter_cost is
  /*账务的：
   ys_zw_ardetail
   ys_zw_arlist

  基本资料：
   ys_yh_sbdoc
   ys_yh_sbinfo
   ys_yh_pricegroup
   ys_yh_custinfo
   ys_yh_account

  水价：
   bas_price_name
   bas_price_detail
   bas_price_step

  抄表：
   ys_cb_mtread*/

  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  PROCEDURE PTEST(P_TXT IN VARCHAR2);
end;
/


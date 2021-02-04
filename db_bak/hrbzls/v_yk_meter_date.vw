create or replace force view hrbzls.v_yk_meter_date as
select   "METER_CODE","METER_SN","METER_HAND","METER_TIME","METER_MAN","METER_FLAG",
"SWITCH_FLAG","METER_TYPE","UPDATE_TIME","IF_READ","SUBMIT_FLAG","MAINTATNER","AMOUNT" from gsuser.YK_METER_DATE_BY_YINSHOU@yk_server;


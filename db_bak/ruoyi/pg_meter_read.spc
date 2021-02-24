create or replace package PG_METER_READ is

  -- Author  : ADMIN
  -- Created : 2020-12-23 15:34:59
  -- Purpose : 抄表

  --手工抄表，重抄操作
  PROCEDURE METERREAD_RE(
            --mrid IN VARCHAR2,  --meterread表当前流水号
            smiid IN VARCHAR2,  --水表编号
            gs_oper_id  IN VARCHAR2,  --登录人员id
            RES IN OUT INTEGER);



end PG_METER_READ;
/


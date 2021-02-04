CREATE OR REPLACE PACKAGE HRBZLS."PG_KPI" IS

  -- Author  : 刘光波
  -- Created : 2012/7/5 10:44:00
  -- Purpose : lgb
  --  指标执行  p_kt_id ：指标id
  PROCEDURE KPI_EXC(P_KT_ID IN VARCHAR2);
  --指标定阅
  --PROCEDURE sp_KPI_subscribe(p_aper IN arr, p_kt_id in VARCHAR2);
  --指标任务  --全部执行
  PROCEDURE KPI_JOB;
  --指标任务单行 作用于触发器
  PROCEDURE KPI_JOB_ROW(P_KPI KPI_DEFINE%ROWTYPE);
END PG_KPI;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_KPI" IS

  -- Author  : ���Ⲩ
  -- Created : 2012/7/5 10:44:00
  -- Purpose : lgb
  --  ָ��ִ��  p_kt_id ��ָ��id
  PROCEDURE KPI_EXC(P_KT_ID IN VARCHAR2);
  --ָ�궨��
  --PROCEDURE sp_KPI_subscribe(p_aper IN arr, p_kt_id in VARCHAR2);
  --ָ������  --ȫ��ִ��
  PROCEDURE KPI_JOB;
  --ָ�������� �����ڴ�����
  PROCEDURE KPI_JOB_ROW(P_KPI KPI_DEFINE%ROWTYPE);
END PG_KPI;
/


CREATE OR REPLACE PROCEDURE HRBZLS."DAY_RPT_MONTHS" (a_smonth varchar2,a_emonth varchar2) IS
  V_PROJECT VARCHAR2(10);
BEGIN
  V_PROJECT := UPPER(FSYSPARA('sys1'));
  IF V_PROJECT = 'TM' THEN
    --��������ˮ
     null;
  ELSIF V_PROJECT = 'XY' THEN
    --��������ˮ
    NULL;
  elsif  V_PROJECT = 'LYG' THEN  --���Ƹ�����ˮ
     PG_EWIDE_REPORTSUM_lyg_01. �ۺ��±���ʼִ��(a_smonth,a_emonth);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


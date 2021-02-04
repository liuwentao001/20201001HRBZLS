CREATE OR REPLACE PROCEDURE HRBZLS."DAY_RPT_MONTHS" (a_smonth varchar2,a_emonth varchar2) IS
  V_PROJECT VARCHAR2(10);
BEGIN
  V_PROJECT := UPPER(FSYSPARA('sys1'));
  IF V_PROJECT = 'TM' THEN
    --天门自来水
     null;
  ELSIF V_PROJECT = 'XY' THEN
    --襄阳自来水
    NULL;
  elsif  V_PROJECT = 'LYG' THEN  --连云港自来水
     PG_EWIDE_REPORTSUM_lyg_01. 综合月报初始执行(a_smonth,a_emonth);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


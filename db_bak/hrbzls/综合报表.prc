CREATE OR REPLACE PROCEDURE HRBZLS."综合报表" IS
  V_PROJECT VARCHAR2(10);
  A_MONTH   VARCHAR2(10);
  CURSOR C_SM IS
    SELECT * FROM SYSMANAFRAME T WHERE T.SMFPID = '0201';
  V_SM SYSMANAFRAME%ROWTYPE;
BEGIN
  V_PROJECT := UPPER(FSYSPARA('sys1'));
  -- open c_sm;
  --loop
  -- fetch c_sm into v_sm;
  -- exit when c_sm%notfound or c_sm%notfound is null;
  A_MONTH := TOOLS.FGETPAYMONTH('020101');
  IF V_PROJECT = 'TM' THEN
    --天门自来水
    NULL;
  ELSIF V_PROJECT = 'XY' THEN
    --襄阳自来水
    NULL;
  ELSIF V_PROJECT = 'LYG' THEN
    --连云港自来水
    PG_EWIDE_REPORTSUM_LYG_01.综合月报(A_MONTH);
  END IF;
  --  end loop;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


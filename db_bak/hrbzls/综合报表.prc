CREATE OR REPLACE PROCEDURE HRBZLS."�ۺϱ���" IS
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
    --��������ˮ
    NULL;
  ELSIF V_PROJECT = 'XY' THEN
    --��������ˮ
    NULL;
  ELSIF V_PROJECT = 'LYG' THEN
    --���Ƹ�����ˮ
    PG_EWIDE_REPORTSUM_LYG_01.�ۺ��±�(A_MONTH);
  END IF;
  --  end loop;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


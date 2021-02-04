CREATE OR REPLACE PROCEDURE HRBZLS."DAY_RPT" IS
  V_PROJECT VARCHAR2(10);
  a_month VARCHAR2(10);
  cursor c_sm is
    select * from sysmanaframe t where t.smfpid='0201';
  v_sm sysmanaframe%rowtype;
BEGIN
  V_PROJECT := UPPER(FSYSPARA('sys1'));
  -- open c_sm;
     --loop
     -- fetch c_sm into v_sm;
     -- exit when c_sm%notfound or c_sm%notfound is null;
      a_month   :=tools.fgetpaymonth('020101');
      IF V_PROJECT = 'TM' THEN
        --天门自来水
         null;
      ELSIF V_PROJECT = 'XY' THEN
        --襄阳自来水
        NULL;
      elsif  V_PROJECT = 'LYG' THEN  --连云港自来水
         PG_EWIDE_REPORTSUM_lyg_01.综合月报(a_month);
      END IF;
   --  end loop;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


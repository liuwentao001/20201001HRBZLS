CREATE OR REPLACE FUNCTION HRBZLS."FGET调整单价"(P_MIID IN VARCHAR2,
                                      P_PIID IN VARCHAR2) RETURN NUMBER AS
  V_COUNT   NUMBER(10);
  P_PFPRICE NUMBER(12, 2);
BEGIN
  --是否调整费用项目单价
  SELECT COUNT(PALMID)
    INTO V_COUNT
    FROM PRICEADJUSTLIST T
   WHERE T.PALMID = P_MIID
     AND T.PALTACTIC = '09'
     and  nvl(T.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm') 
     and  nvl(T.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
     AND T.PALPIID = P_PIID
     AND PALSTATUS = 'Y';
  IF V_COUNT < 1 THEN
    P_PFPRICE := 0;
  END IF;
  IF V_COUNT >= 1 THEN
    SELECT (CASE
             WHEN T2.PDDJ + T3.PALWAY * T3.PALVALUE  >=0 THEN
              T3.PALWAY * T3.PALVALUE
             ELSE
              T3.PALWAY * T2.PDDJ
           END)
      INTO P_PFPRICE
      FROM METERINFO T1, PRICEDETAIL T2, PRICEADJUSTLIST T3
     WHERE T2.PDPFID = T1.MIPFID
       AND T1.MIID = P_MIID
       AND T1.MIID = T3.PALMID
       AND T2.PDPIID = T3.PALPIID
      and  nvl(T3.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm') 
       and  nvl(T3.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
        AND T2.PDPIID = P_PIID;
  END IF;

  RETURN P_PFPRICE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


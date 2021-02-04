CREATE OR REPLACE FUNCTION HRBZLS."FGETPRINTDATEFP"(P_TYPE IN VARCHAR2,
                                             P_ID   IN VARCHAR2)
  RETURN VARCHAR2 IS
  V_DATE VARCHAR2(20);
BEGIN
  IF UPPER(P_TYPE) = 'RLID' THEN
    SELECT TO_CHAR(MAX(ISSTATUSDATE), 'YYYY.MM.DD')
      INTO V_DATE
      FROM (SELECT ISSTATUSDATE
              FROM RECLIST RL, INVSTOCK IT, INV_DETAIL IDT
             WHERE RL.RLID = IDT.RLID
               AND IT.ISID = IDT.ISID
               AND ISSTATUS = '1'
               AND IT.ISTYPE = 'S'
               AND IDT.RLID = P_ID
            UNION
            SELECT ISSTATUSDATE
              FROM RECLIST RL, INVSTOCK_SP IT, INV_DETAIL_SP IDT
             WHERE RL.RLID = IDT.RLID
               AND IT.ISID = IDT.ISID
               AND ISSTATUS = '1'
               AND IT.ISTYPE = 'P'
               AND IDT.RLID = P_ID);

  ELSIF UPPER(P_TYPE) = 'PID' THEN
    SELECT TO_CHAR(MAX(ISSTATUSDATE), 'YYYY.MM.DD')
      INTO V_DATE
      FROM (SELECT ISSTATUSDATE
              FROM PAYMENT P, INVSTOCK IT, INV_DETAIL IDT
             WHERE P.PID = IDT.PID
               AND IT.ISID = IDT.ISID
               AND ISSTATUS = '1'
               AND IT.ISTYPE = 'S'
               AND IDT.PID = P_ID
            UNION
            SELECT ISSTATUSDATE
              FROM PAYMENT P, INVSTOCK_SP IT, INV_DETAIL_SP IDT
             WHERE P.PID = IDT.PID
               AND IT.ISID = IDT.ISID
               AND ISSTATUS = '1'
               AND IT.ISTYPE = 'P'
               AND IDT.PID = P_ID);
  END IF;
  RETURN V_DATE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


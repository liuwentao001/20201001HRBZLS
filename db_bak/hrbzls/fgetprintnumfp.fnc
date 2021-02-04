CREATE OR REPLACE FUNCTION HRBZLS."FGETPRINTNUMFP"(P_TYPE IN VARCHAR2,
                                            P_RLID IN VARCHAR2)
  RETURN VARCHAR2 IS
  V_RET   VARCHAR2(2);
  V_COUNT NUMBER:=0;
BEGIN
  --无库存管理

  --库存管理
  IF UPPER(P_TYPE) = 'RLID' THEN

    SELECT COUNT(*)
      INTO V_COUNT
      FROM RECLIST RL, INVSTOCK IT, INV_DETAIL IDT
     WHERE RL.RLID = IDT.RLID
       AND IT.ISID = IDT.ISID
       AND ISSTATUS = '1'
       AND IT.ISTYPE IN ('S', 'P')
       AND RL.RLSCRRLID = P_RLID;

    IF V_COUNT = 0 THEN
      SELECT COUNT(*)
        INTO V_COUNT
				FROM invstock_sp it, inv_info_sp ii
				WHERE it.isid = to_number(ii.isid)
				AND ii.rlid = P_RLID
				AND it.istype = 'P'
				AND ii.status in ('0','3','2')
				And it.isstatus = '1';
     /* SELECT COUNT(*)
        INTO V_COUNT
        FROM RECLIST RL, INVSTOCK_SP IT, INV_DETAIL_SP IDT
       WHERE RL.RLID = IDT.RLID
         AND IT.ISID = IDT.ISID
         AND ISSTATUS = '1'
         AND IT.ISTYPE IN ('S', 'P')
         AND IDT.RLID = P_RLID;*/
    END IF;
  ELSIF UPPER(P_TYPE) = 'PID' THEN

    SELECT COUNT(*)
      INTO V_COUNT
      FROM PAYMENT P, INVSTOCK IT, INV_DETAIL IDT
     WHERE P.PID = IDT.PID
       AND IT.ISID = IDT.ISID
       AND ISSTATUS = '1'
       AND IT.ISTYPE IN ('S', 'P')
       AND IDT.PID = P_RLID;

    IF V_COUNT = 0 THEN
      SELECT COUNT(*)
        INTO V_COUNT
				FROM invstock_sp it, inv_info_sp ii
				WHERE it.isid = to_number(ii.isid)
				AND ii.pid = P_RLID
				AND it.istype = 'P'
        AND ii.status in ('0','3','2')
        And it.isstatus = '1';
      /*SELECT COUNT(*)
        INTO V_COUNT
        FROM PAYMENT P, INVSTOCK_SP IT, INV_DETAIL_SP IDT
       WHERE P.PID = IDT.PID
         AND IT.ISID = IDT.ISID
         AND ISSTATUS = '1'
         AND IT.ISTYPE = 'P'
         AND IDT.PID = P_RLID;
      IF V_COUNT = 0 THEN
        SELECT COUNT(*)
          INTO V_COUNT
          FROM PAYMENT P, RECLIST RL, INVSTOCK_SP IT, INV_DETAIL_SP IDT
         WHERE P.PID = RL.RLPID
           AND RL.RLID = IDT.RLID
           AND IT.ISID = IDT.ISID
           AND ISSTATUS = '1'
           AND IT.ISTYPE = 'P'
           AND P.PID = P_RLID;
      END IF;*/
    END IF;
  END IF;
  RETURN V_COUNT;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '0';
END;
/


CREATE OR REPLACE PROCEDURE HRBZLS."SP_FPTZ" (V_BCNO      IN VARCHAR2,
                                    V_MINNO     IN VARCHAR2,
                                    V_MAXNO     IN VARCHAR2,
                                    V_BCNOSWAP  IN VARCHAR2,
                                    V_MINNOSWAP IN VARCHAR2,
                                    V_MAXNOSWAP IN VARCHAR2,
                                    MSG         OUT VARCHAR2) AS
  V_TEMP      VARCHAR2(8); ---
  V_TEMPCOUNT VARCHAR2(8);
  V_MINFP     VARCHAR2(8);
  V_MAXFP     VARCHAR2(8);
  INV         INVSTOCK%ROWTYPE;
  CURSOR C_IS IS
    SELECT * FROM INVSTOCK_TEMP ORDER BY ISID;

  CURSOR C_ISB IS
    SELECT * FROM INVSTOCK_TEMPBAK ORDER BY ISID;

  CURSOR C_INVINFO IS
    SELECT * FROM INV_INFOTEMPTZ ORDER BY ISID;

  CURSOR C_INVDETIAL IS
    SELECT * FROM INV_DETAILTEMPTZ ORDER BY ISID;

BEGIN
  V_TEMP      := V_MINNOSWAP - V_MINNO;
  V_TEMPCOUNT := V_MAXNO - V_MINNO + 1;
  IF V_MAXNOSWAP - V_MINNOSWAP <> V_MAXNO - V_MINNO THEN
    MSG := 'N';
  END IF;
  INSERT INTO INVSTOCK_TEMP VALUE
    (SELECT *
       FROM INVSTOCK
      WHERE ISBCNO = V_BCNO
        AND ISNO >= TRIM(TO_CHAR(V_MINNO, '00000000'))
        AND ISNO <= TRIM(TO_CHAR(V_MAXNO, '00000000')));

  INSERT INTO INVSTOCK_TEMPBAK VALUE
    (SELECT *
       FROM INVSTOCK
      WHERE ((ISBCNO = V_BCNO AND
            ISNO >= TRIM(TO_CHAR(V_MINNO, '00000000')) AND
            ISNO <= TRIM(TO_CHAR(V_MAXNO, '00000000'))) OR
            (ISBCNO = V_BCNOSWAP AND
            ISNO >= TRIM(TO_CHAR(V_MINNOSWAP, '00000000')) AND
            ISNO <= TRIM(TO_CHAR(V_MAXNOSWAP, '00000000'))))
        AND ISNO NOT IN
            (SELECT ISNO
               FROM INVSTOCK
              WHERE ISBCNO = V_BCNO
                AND ISNO >= TRIM(TO_CHAR(V_MINNO, '00000000'))
                AND ISNO <= TRIM(TO_CHAR(V_MAXNO, '00000000'))));
  /*
    INSERT INTO INV_INFOTEMPTZ
      (SELECT *
         FROM INV_INFO
        WHERE ISID IN
              (SELECT ISID
                 FROM INVSTOCK
                WHERE ISBCNO = V_BCNO
                  AND ISNO >= TRIM(TO_CHAR(V_MINNO, '00000000'))
                  AND ISNO <= TRIM(TO_CHAR(V_MAXNO, '00000000')))

       );
  */

  DELETE FROM INVSTOCK
   WHERE ISBCNO = V_BCNO
     AND ISNO >= TRIM(TO_CHAR(V_MINNO, '00000000'))
     AND ISNO <= TRIM(TO_CHAR(V_MAXNO, '00000000'));

  DELETE FROM INVSTOCK
   WHERE ISBCNO = V_BCNOSWAP
     AND ISNO >= TRIM(TO_CHAR(V_MINNOSWAP, '00000000'))
     AND ISNO <= TRIM(TO_CHAR(V_MAXNOSWAP, '00000000'));

  OPEN C_IS;
  LOOP
    FETCH C_IS
      INTO INV;
    EXIT WHEN C_IS%NOTFOUND OR C_IS%NOTFOUND IS NULL;
    INV.ISBCNO := V_BCNOSWAP;
    INV.ISNO   := TRIM(TO_CHAR(INV.ISNO + V_TEMP, '00000000'));
    --INV.ISPCISNO := INV.ISBCNO || '.' || INV.ISNO;
    INV.ISMEMO := '人工调整票号';
    --inv.isstatus :='1';
    INSERT INTO INVSTOCK VALUES INV;
  END LOOP;
  CLOSE C_IS;

  OPEN C_ISB;
  LOOP
    FETCH C_ISB
      INTO INV;
    EXIT WHEN C_ISB%NOTFOUND OR C_ISB%NOTFOUND IS NULL;
    INV.ISSTATUS := '0';
    INV.ISBCNO   := V_BCNO;
    INV.ISNO     := TRIM(TO_CHAR(INV.ISNO - V_TEMP, '00000000'));
    --    INV.ISPCISNO := INV.ISBCNO || '.' || INV.ISNO;
    INV.ISMEMO := '人工调整票号';
    INSERT INTO INVSTOCK VALUES INV;
  END LOOP;
  CLOSE C_ISB;

  /* for i in V_minno .. V_maxno loop
      update invstock_datatemp
         set isbcno=V_bcno,
             isno=to_char(i+v_temp,'00000000'),
             ismemo='人工调整票号',
             isstatus='1'
       where isbcno=V_bcno and isno =to_char(i,'00000000');
  end loop;
  commit;
  insert into invstock
  value(select * from invstock_datatemp);*/

  UPDATE INVSTOCK
     SET ISPCISNO =
         (ISBCNO || '.' || ISNO)
   WHERE ISID IN (SELECT T.ISID
                    FROM INVSTOCK T
                   WHERE T.ISPCISNO <> (T.ISBCNO || '.' || T.ISNO));

  UPDATE INV_INFO T3
     SET ISPCISNO =
         (SELECT ISPCISNO FROM INVSTOCK T WHERE T.ISID = T3.ISID)
   WHERE ID IN (SELECT T0.ID
                  FROM INV_INFO T0, INVSTOCK T1
                 WHERE T0.ISPCISNO <> T1.ISPCISNO
                   AND T0.ISID = T1.ISID);

  /*  UPDATE INV_INFO TT
    SET ISID =
        (SELECT ISID FROM INVSTOCK T WHERE T.ISPCISNO = TT.ISPCISNO)
  WHERE ISPCISNO >= V_BCNO || '.' || TRIM(TO_CHAR(V_MINNO, '00000000'))
    AND ISPCISNO <= V_BCNO || '.' || TRIM(TO_CHAR(V_MAXNO, '00000000'));*/

  MSG := 'Y';

EXCEPTION
  WHEN OTHERS THEN
    MSG := 'N';
    ROLLBACK;
    RAISE;
END;
/


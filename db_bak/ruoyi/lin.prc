CREATE OR REPLACE PROCEDURE LIN(I_CODE IN VARCHAR2) AS
  O_STATE VARCHAR2(10);
  V_DATE  VARCHAR2(10);
  V_CODE  VARCHAR2(10);
BEGIN
  O_STATE := '0';
  V_DATE  := SYSDATE;
  V_CODE  := I_CODE;
  IF V_CODE IS NULL THEN
    FOR I IN (SELECT DEPT_CODE
                FROM SYS_DEPT
               WHERE PARENT_ID = '2'
               ORDER BY DEPT_ID) LOOP
      INSERT INTO BS_CBJH_TEMP
        SELECT A.CIID,
               B.MIID,
               B.MISMFID,
               B.MIRORDER,
               MISTID,
               MIPID,
               MICLASS,
               MIFLAG,
               MIRECDATE,
               MIRCODE,
               MDMODEL,
               MIPRIFLAG,
               BFBATCH,
               BFRPER,
               B.MISAFID,
               MIIFCHK,
               MDCALIBER,
               MISIDE,
               B.MISTATUS,
               D.BFNRMONTH,
               B.MIBFID,
               B.MIRECSL,
               B.MIENEED
          FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
         WHERE A.CIID = B.MICODE
           AND B.MIID = S.MDID
           AND B.MISMFID = D.BFSMFID
           AND B.MIBFID = D.BFID
           AND B.MISMFID = I.DEPT_CODE
           AND A.CISTATUS = '1';
      COMMIT;
      IF O_STATE = '0' THEN
        FOR B IN (SELECT BFID
                    FROM BS_BOOKFRAME A
                   WHERE A.BFSTATUS = 'Y'
                     AND A.BFSMFID = I.DEPT_CODE
                     AND BFNRMONTH = V_DATE) LOOP
          IF B.BFID IS NOT NULL THEN
            BEGIN
              INSERT INTO LINB
                (SELECT SYSDATE,
                        I.DEPT_CODE,
                        B.BFID,
                        (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                   FROM DUAL);
              PG_RAEDPLAN.CREATECB2(I.DEPT_CODE, V_DATE, B.BFID, O_STATE);
              COMMIT;
            END;
          END IF;
        END LOOP;
      END IF;
      EXECUTE IMMEDIATE 'TRUNCATE TABLE BS_CBJH_TEMP';
    END LOOP;
  ELSE
    INSERT INTO BS_CBJH_TEMP
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             D.BFNRMONTH,
             B.MIBFID,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = V_CODE;
    COMMIT;
    IF O_STATE = '0' THEN
      FOR B IN (SELECT BFID
                  FROM BS_BOOKFRAME A
                 WHERE A.BFSTATUS = 'Y'
                   AND A.BFSMFID = V_CODE
                   AND BFNRMONTH = V_DATE) LOOP
        IF B.BFID IS NOT NULL THEN
            INSERT INTO LINB
              (SELECT SYSDATE,
                      V_CODE,
                      B.BFID,
                      (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                 FROM DUAL);
            PG_RAEDPLAN.CREATECB(V_CODE, V_DATE, B.BFID, O_STATE);
            COMMIT;
        END IF;
      END LOOP;
    END IF;
  END IF;
END;
/


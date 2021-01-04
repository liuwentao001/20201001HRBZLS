CREATE OR REPLACE PROCEDURE LIN(V_DATE IN VARCHAR2) AS
  O_STATE VARCHAR2(10);
  O_DATE  VARCHAR2(10);
BEGIN
  O_STATE := '0';
  O_DATE  := V_DATE;
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
             B.MIBFID
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = I.DEPT_CODE;
         --AND D.BFNRMONTH = TO_CHAR(O_DATE, 'YYYY.MM');
    COMMIT;
    IF O_STATE = '0' THEN
      FOR B IN (SELECT BFID
                  FROM BS_BOOKFRAME A
                 WHERE A.BFSTATUS = 'Y'
                   AND A.BFSMFID = I.DEPT_CODE
                   AND BFNRMONTH =O_DATE) LOOP
        IF B.BFID IS NOT NULL THEN
          BEGIN
            PG_RAEDPLAN.CREATECB(I.DEPT_CODE,
                                 O_DATE,
                                 B.BFID,
                                 O_STATE);
          END;
        END IF;
      END LOOP;
    END IF;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE BS_CBJH_TEMP';
  END LOOP;
END;
/


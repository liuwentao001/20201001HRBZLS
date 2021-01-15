CREATE OR REPLACE PROCEDURE SP_JZGLAUDIT(P_WORKID IN VARCHAR2) AS
  --V_CIID  VARCHAR2(50);
  --V_MIID  VARCHAR2(50);
  --V_RENO  VARCHAR2(60);
  V_FLAGC NUMBER;
  V_FLAGM NUMBER;
BEGIN

  FOR JZGL IN (SELECT *
                 FROM REQUEST_JZGL
                WHERE ENABLED = 5
                  AND WORKID = P_WORKID) LOOP
    DBMS_OUTPUT.PUT_LINE(JZGL.RENO);
    SELECT COUNT(1) INTO V_FLAGC FROM BS_CUSTINFO WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGC);
    SELECT COUNT(1) INTO V_FLAGM FROM BS_METERINFO WHERE MIID = JZGL.MIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGM);
  
    -----BS_CUSTINFO
    IF V_FLAGC = 0 THEN
      INSERT INTO BS_CUSTINFO
        (CIMTEL,
         CITEL1,
         CICONNECTPER,
         CIIFINV,
         CIIFSMS,
         MICHARGETYPE,
         MISAVING,
         CIID,
         CINAME,
         CIADR,
         CISTATUS,
         CIIDENTITYLB,
         CIIDENTITYNO,
         CISMFID,
         CINEWDATE,
         CISTATUSDATE,
         CIDBBS,
         CIUSENUM,
         CIAMOUNT)
        SELECT CIMTEL,
               CITEL1,
               CICONNECTPER,
               CIIFINV,
               CIIFSMS,
               MICHARGETYPE,
               0,
               CIID,
               CINAME,
               CIADR,
               CISTATUS,
               CIIDENTITYLB,
               CIIDENTITYNO,
               RESMFID,
               SYSDATE,
               MODIFYDATE,
               REDBBS,
               CIUSENUM,
               CIAMOUNT
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERINFO
    IF V_FLAGM = 0 THEN
      INSERT INTO BS_METERINFO
        (MIID,
         MIADR,
         MICODE,
         MISMFID,
         MIBFID,
         MIRORDER,
         MIPID,
         MICLASS,
         MIRTID,
         MISTID,
         MIPFID,
         MISTATUS,
         MISIDE,
         MIINSCODE,
         MIINSDATE,
         MILH,
         MIDYH,
         MIMPH,
         MIXQM,
         MIJD,
         MIYL13,
         DQSFH,
         DQGFH,
         MICARDNO,
         MIRCODE,
         MISEQNO)
        SELECT MIID,
               MIADR,
               CIID,
               RESMFID,
               MIBFID,
               MIRORDER,
               MIPID,
               MICLASS,
               MIRTID,
               MISTID,
               MIPFID,
               MISTATUS,
               MISIDE,
               MIINSCODE,
               MIINSDATE,
               MILH,
               MIDYH,
               MIMPH,
               MIXQM,
               MIJD,
               MIYL13,
               DQSFH,
               DQGFH,
               MICARDNO,
               MIINSCODE,
               MIBFID||SORTCODE MISEQNO
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERDOC 更新表使用状态及变更日期
    UPDATE BS_METERDOC B
       SET MDID        =
           (SELECT A.MIID
              FROM REQUEST_JZGL A
             WHERE A.MDNO = B.MDNO
               AND A.RENO = JZGL.RENO),
           MDSTATUS     = 1,
           MDSTATUSDATE = SYSDATE
     WHERE EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.MDNO = B.MDNO
               AND C.RENO = JZGL.RENO);
  
    -----BS_METERFH_STORE 更新表身码及状态
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '1'
               AND A.DQSFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '1'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '2'
               AND A.DQGFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '2'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
  
  END LOOP;

  COMMIT;

END;
/


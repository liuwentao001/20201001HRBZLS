CREATE OR REPLACE TRIGGER HRBZLS."TBI_INV_INFO"
  BEFORE INSERT ON INV_INFO
  FOR EACH ROW
DECLARE
  CURSOR C_IT IS
    SELECT * FROM INVSTOCK T WHERE T.ISID = :NEW.ISID;
BEGIN
  IF :NEW.ID IS NULL THEN
    SELECT FGETSEQUENCE('inv_info') INTO :NEW.ID FROM DUAL;
  END IF;
  UPDATE INVSTOCK T
     SET ISPSTATUS      = ISSTATUS,
         ISPSTATUSDATEP = ISSTATUSDATE,
         ISPTATUSPER    = ISSTATUSPER,
         T.ISSTATUS     = DECODE(:NEW.STATUS, '0', 1, 2),
         ISSTATUSDATE   = SYSDATE,
         ISSTATUSMEMO   = :NEW.STATUSMEMO
   WHERE T.ISID = :NEW.ISID;
  IF :NEW.ISID IS NULL THEN
    :NEW.ISID := :NEW.ID;
  END IF;
  IF TRIM(:NEW.CPFS) = 'YK' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              RL.RLID,
              RL.RLPID,
              RL.RLMCODE,
              RL.RLCNAME,
              RL.RLPBATCH,
              :NEW.CPFS,
              '发票预开'
         FROM RECLIST RL
        WHERE RL.RLID = :NEW.RLID);

  ELSIF TRIM(:NEW.CPFS) = 'YC' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              '',
              PID,
              PMID,
              MI.MINAME,
              PBATCH,
              :NEW.CPFS,
              '柜台预存开票'
         FROM PAYMENT, METERINFO MI
        WHERE PMID = MIID
          AND PBATCH = :NEW.BATCH
          AND PMCODE = :NEW.MCODE);
  ELSIF TRIM(:NEW.CPFS) = 'F' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              RL.RLID,
              RL.RLPID,
              RL.RLMCODE,
              RL.RLCNAME,
              RL.RLPBATCH,
              :NEW.CPFS,
              '柜台分票打印'
         FROM RECLIST RL
        WHERE RL.RLID = :NEW.RLID);
  ELSIF TRIM(:NEW.CPFS) = 'H' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              RL.RLID,
              RL.RLPID,
              RL.RLMCODE,
              RL.RLCNAME,
              RL.RLPBATCH,
              :NEW.CPFS,
              '柜台合票打印'
         FROM RECLIST RL
        WHERE RL.RLREVERSEFLAG = 'N'
          AND (RL.RLPBATCH = :NEW.BATCH OR RL.RLMICOLUMN2=:NEW.PPBATCH)
        --  AND RLMCODE = :NEW.MCODE);
          AND rl.RLMID = :NEW.MCODE);   
  ELSIF TRIM(:NEW.CPFS) = 'M' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              RL.RLID,
              RL.RLPID,
              RL.RLMCODE,
              RL.RLCNAME,
              RL.RLPBATCH,
              :NEW.CPFS,
              '柜台合票打印'
         FROM RECLIST RL
        WHERE RLID IN (SELECT C1 FROM PBPARMTEMP));

  ELSIF TRIM(:NEW.CPFS) = 'TS' THEN
    INSERT INTO INV_DETAIL VALUE
      (SELECT :NEW.ID,
              :NEW.ISID,
              RL.RLID,
              RL.RLPID,
              RL.RLMCODE,
              RL.RLCNAME,
              RL.RLPBATCH,
              :NEW.CPFS,
              '托收预开合票打印'
         FROM RECLIST RL, METERINFO MI
        WHERE RLMID = MIID
          AND MI.MIUIID IN
              (SELECT MIUIID FROM METERINFO MI WHERE MI.MICODE = :NEW.MCODE)
          AND RLID IN (SELECT C1 FROM PBPARMTEMP));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


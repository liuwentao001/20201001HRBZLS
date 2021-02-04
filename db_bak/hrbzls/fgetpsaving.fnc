CREATE OR REPLACE FUNCTION HRBZLS."FGETPSAVING"(P_PBATCH IN VARCHAR2,
                                         P_TYPE   IN VARCHAR2)
  RETURN NUMBER AS
  N_RET NUMBER(12, 2);
BEGIN
  IF P_TYPE = 'QC' THEN
    SELECT PM.PSAVINGQC
      INTO N_RET
      FROM PAYMENT PM
     WHERE PM.PID = (SELECT MIN(T.PID)
                       FROM PAYMENT T
                      WHERE T.PBATCH = P_PBATCH
                        AND T.PMID = T.PPRIID);
  END IF;
  IF P_TYPE = 'QM' THEN
    SELECT PM.PSAVINGQM
      INTO N_RET
      FROM PAYMENT PM
     WHERE PM.PID = (SELECT MAX(T.PID)
                       FROM PAYMENT T
                      WHERE T.PBATCH = P_PBATCH
                        AND T.PMID = T.PPRIID);
  END IF;
   IF P_TYPE = 'DQ' THEN
    SELECT sum(MI.MISAVING )
      INTO N_RET
      FROM METERINFO MI
     WHERE MI.MIPRIID = (SELECT MAX(T.PPRIID )  --这里应该判断合收表账户的总金额 by wangwei 20150123
                       FROM PAYMENT T
                      WHERE T.PBATCH = P_PBATCH
                        AND T.PMID = T.PPRIID);
  END IF;
  
  RETURN N_RET;
EXCEPTION
  WHEN OTHERS THEN
    N_RET := 0;
    RETURN N_RET;
END FGETPSAVING;
/


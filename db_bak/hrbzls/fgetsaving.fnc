CREATE OR REPLACE FUNCTION HRBZLS."FGETSAVING"
   (P_PID IN VARCHAR2,P_TYPE IN VARCHAR2)
   RETURN NUMBER
AS
   LRET   NUMBER;
   LRET1   NUMBER;
   LRET2   NUMBER;
   VCOUNT NUMBER;

BEGIN
    SELECT COUNT(*) INTO VCOUNT
                      FROM PAIDLIST
                      WHERE   PLPID = P_PID
                      ORDER BY PLID ;
    FOR RL IN ( SELECT PLID,PLSAVINGQC,PLSAVINGBQ,PLSAVINGQM,ROW_NUMBER()OVER( PARTITION BY PLPID ORDER BY PLID) RNUM
                      FROM PAIDLIST
                      WHERE   PLPID = P_PID
                      ORDER BY PLID ) LOOP
       IF RL.RNUM = 1 THEN
          LRET1 := RL.PLSAVINGQC;
       END IF;
       IF RL.RNUM = VCOUNT  THEN
          LRET2 := RL.PLSAVINGQM;
       END IF;
    END LOOP;
    IF P_TYPE = '1' THEN
          LRET :=   LRET1;
    ELSIF P_TYPE = '2' THEN
          LRET :=   LRET2;
    ELSIF P_TYPE = '3' THEN
          LRET :=   LRET2-LRET1;
    END IF;
    RETURN LRET;
EXCEPTION WHEN OTHERS THEN
   RETURN 0;
END FGETSAVING;
/

CREATE OR REPLACE FUNCTION �Ƿ������ˮ��(P_SBID IN VARCHAR2) RETURN VARCHAR2 AS
  VCOUNT NUMBER := 0;
BEGIN
  SELECT COUNT(*)
    INTO VCOUNT
    FROM (SELECT 1
            FROM YS_YH_SBINFO MI
           WHERE MI.SBID = P_SBID
             AND MI.SBIFMP = 'N'
             AND �Ƿ������ˮ��(MI.PRICE_NO) = 'Y'
          UNION
          SELECT 1
            FROM YS_YH_SBINFO MI, YS_YH_PRICEGROUP PMD
           WHERE MI.SBID = P_SBID
             AND MI.SBID = PMD.SBID
             AND MI.SBIFMP = 'Y'
             AND �Ƿ������ˮ��(PMD.PRICE_NO) = 'Y');
  IF VCOUNT > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/


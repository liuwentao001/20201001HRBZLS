CREATE OR REPLACE FUNCTION HRBZLS."FGET_CBJ_REC"(P_MIID IN VARCHAR2,
                                          P_TYPE IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_QF    NUMBER(12, 3);
  V_ZYC    NUMBER(12, 3);
  V_BS    NUMBER(10);
  V_DATE  DATE;
  V_JFJE  NUMBER(12, 3);
  V_QFYF  VARCHAR2(10);
  V_RET   VARCHAR2(3000);
  V_WJSSF NUMBER(12, 3);
  V_MCODE VARCHAR2(10);
BEGIN

  --Ƿ�ѽ��
  --20140109�޸�ΪǷ�ѽ��=����������Ԥ�����- �����ձ������ӱ���Ƿ��
  IF P_TYPE = 'QF' THEN
    SELECT MIPRIID INTO V_MCODE FROM METERINFO WHERE MIID = P_MIID;
    SELECT NVL((SELECT MISAVING FROM METERINFO WHERE MIID = V_MCODE), 0) -
           NVL((SELECT SUM(RLJE)
                 FROM RECLIST
                WHERE RLPRIMCODE = V_MCODE
                  AND RLPAIDFLAG = 'N'
                  AND RLJE > 0
                  AND RLREVERSEFLAG = 'N'
                  AND RLBADFLAG = 'N'),
               0)
      INTO V_QF
      FROM DUAL;
  
    IF V_QF IS NULL THEN
      V_QF := 0;
    END IF;
    V_RET := V_QF;
    
     --��Ԥ��
  ELSIF P_TYPE = 'HSYC' THEN
    SELECT NVL(SUM(MISAVING),0) INTO V_ZYC FROM METERINFO WHERE MIPRIID = P_MIID;
    IF V_ZYC IS NULL THEN
      V_ZYC := 0;
    END IF;
    V_RET := V_ZYC;
  
    --δ����ˮ��
  ELSIF P_TYPE = 'WJSSF' THEN
    SELECT MIPRIID INTO V_MCODE FROM METERINFO WHERE MIID = P_MIID;
    SELECT NVL(SUM(RLJE), 0)
      INTO V_WJSSF
      FROM RECLIST
     WHERE RLPRIMCODE = V_MCODE
       AND RLPAIDFLAG = 'N'
       AND RLJE > 0
       AND RLREVERSEFLAG = 'N'
       AND RLBADFLAG = 'N';
    IF V_WJSSF IS NULL THEN
      V_WJSSF := 0;
    END IF;
    V_RET := V_WJSSF;
  
    --Ƿ�ѱ���   
  ELSIF P_TYPE = 'BS' THEN
    SELECT COUNT(RLID)
      INTO V_BS
      FROM RECLIST
     WHERE RLMID = P_MIID
       AND RLPAIDFLAG = 'N'
       AND RLJE > 0
       AND RLREVERSEFLAG = 'N'
       AND RLBADFLAG = 'N';
    IF V_BS IS NULL THEN
      V_BS := 0;
    END IF;
    V_RET := V_BS;
    --�ϴνɷ�����
  ELSIF P_TYPE = 'SCJFRQ' THEN
  
    SELECT MAX(PDATETIME)
      INTO V_DATE
      FROM PAYMENT
     WHERE PMID = P_MIID
       AND PREVERSEFLAG = 'N'
       AND PTRANS <> 'U';
  
    IF V_DATE IS NOT NULL THEN
      V_RET := TO_CHAR(V_DATE, 'YYYY-MM-DD HH24:MI:SS');
    END IF;
    --�ϴνɷѽ��
  ELSIF P_TYPE = 'SCJFJE' THEN
    SELECT SUM(PPAYMENT)
      INTO V_JFJE
      FROM PAYMENT
     WHERE PBATCH = (SELECT MAX(PBATCH)
                       FROM PAYMENT
                      WHERE PMID = P_MIID
                        AND PREVERSEFLAG = 'N'
                        AND PTRANS <> 'U');
  
    IF V_JFJE IS NULL THEN
      V_JFJE := 0;
    END IF;
    V_RET := V_JFJE;
    --����Ƿ���·�
  
  ELSIF P_TYPE = 'QFYF' THEN
    SELECT TO_CHAR(MIN(RLDATE), 'YYYYMMDD')
      INTO V_QFYF
      FROM RECLIST
     WHERE RLMID = P_MIID
       AND RLREVERSEFLAG = 'N'
       AND RLPAIDFLAG = 'N'
       AND RLBADFLAG = 'N';
  
    V_RET := V_QFYF;
  END IF;

  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END;
/


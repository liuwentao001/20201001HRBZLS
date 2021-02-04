CREATE OR REPLACE PROCEDURE HRBZLS."SP_COPYINVOICE"(P_ITID IN VARCHAR2, --����
                                             P_IP   IN VARCHAR2, --��IP
                                             P_FILE IN VARCHAR2, --srd�ļ�
                                             P_TYPE IN VARCHAR2, --��������
                                             MSG    OUT VARCHAR2) IS

  CURSOR C_REPORT1(P_DW VARCHAR2) IS
    SELECT *
      FROM REPORT1
     WHERE REPORT_DW = P_DW
     ORDER BY REPORT_SYSTEM ASC;

  CURSOR C_REPORT2(P_RPTID VARCHAR2) IS
    SELECT *
      FROM REPORT2
     WHERE REPORT_ID = P_RPTID
     ORDER BY OBJECT_NAME ASC;

  V_REPORT1   REPORT1%ROWTYPE;
  RPT1        REPORT1%ROWTYPE;
  V_REPORT2   REPORT2%ROWTYPE;
  RPT2        REPORT2%ROWTYPE;
  V_REPORT_DW VARCHAR2(50);
BEGIN
  IF P_TYPE = 'I' THEN
    --��Ʊ��
    --STEP 1 ����HX_INVOICE
    INSERT INTO HX_INVOICE
      SELECT TRIM(SUBSTR(T.ITID, 1, 1) ||
                  (SELECT TO_CHAR(MAX(NVL(TO_NUMBER(SUBSTR(H.ITID, 2, 4)), 0)) + 1)
                     FROM HX_INVOICE H
                    WHERE SUBSTR(H.ITID, 1, 1) = SUBSTR(T.ITID, 1, 1))),
             '����' || T.ITNAME,
             '',
             P_FILE,
             T.ITPROPERTY2,
             T.ITPROPERTY3,
             T.ITPROPERTY4,
             T.ITPROPERTY5,
             'Y',
             '2',
             P_IP,
             T.ITID
        FROM HX_INVOICE T
       WHERE T.ITID = P_ITID;
    COMMIT;
  
    --STEP 2 ����REPORT1��REPORT1����
    SELECT ITPROPERTY1
      INTO V_REPORT_DW
      FROM HX_INVOICE
     WHERE ITID = P_ITID;
  
    OPEN C_REPORT1(V_REPORT_DW);
    LOOP
      FETCH C_REPORT1
        INTO V_REPORT1;
      EXIT WHEN C_REPORT1%NOTFOUND OR C_REPORT1%NOTFOUND IS NULL;
      RPT1                   := NULL;
      RPT1.REPORT_ID         := 'RT' || trim(to_char(SEQ_REPORT1_REPORTID.NEXTVAL,
                                                     '00000000'));
      RPT1.REPORT_NAME       := V_REPORT1.REPORT_NAME;
      RPT1.REPORT_STATE      := NULL;
      RPT1.REPORT_DW         := P_FILE;
      RPT1.REPORT_SYSTEM     := V_REPORT1.REPORT_SYSTEM;
      RPT1.REPORT_PAPER_SIZE := V_REPORT1.REPORT_PAPER_SIZE;
      RPT1.REPORT_PERCENT    := V_REPORT1.REPORT_PERCENT;
      INSERT INTO REPORT1 VALUES RPT1;
    
      OPEN C_REPORT2(V_REPORT1.REPORT_ID);
      LOOP
        FETCH C_REPORT2
          INTO V_REPORT2;
        EXIT WHEN C_REPORT2%NOTFOUND OR C_REPORT2%NOTFOUND IS NULL;
        RPT2               := NULL;
        RPT2.REPORT_ID     := RPT1.REPORT_ID;
        RPT2.OBJECT_NAME   := V_REPORT2.OBJECT_NAME;
        RPT2.BANDRPT       := V_REPORT2.BANDRPT;
        RPT2.XRPT          := V_REPORT2.XRPT;
        RPT2.YRPT          := V_REPORT2.YRPT;
        RPT2.X2RPT         := V_REPORT2.X2RPT;
        RPT2.Y2RPT         := V_REPORT2.Y2RPT;
        RPT2.HEIGHT        := V_REPORT2.HEIGHT;
        RPT2.WIDTH         := V_REPORT2.WIDTH;
        RPT2.BORDERRPT     := V_REPORT2.BORDERRPT;
        RPT2.COLOR         := V_REPORT2.COLOR;
        RPT2.FONT_NAME     := V_REPORT2.FONT_NAME;
        RPT2.FONT_SIZE     := V_REPORT2.FONT_SIZE;
        RPT2.SELECT_LABEL  := V_REPORT2.SELECT_LABEL;
        RPT2.EXPR          := V_REPORT2.EXPR;
        RPT2.EXPR_ENGLISH  := V_REPORT2.EXPR_ENGLISH;
        RPT2.ALIGNMENT_RPT := V_REPORT2.ALIGNMENT_RPT;
        RPT2.FORMAT_RPT    := V_REPORT2.FORMAT_RPT;
        INSERT INTO REPORT2 VALUES RPT2;
      
      END LOOP;
      CLOSE C_REPORT2;
      COMMIT;
    
    END LOOP;
    CLOSE C_REPORT1;
    COMMIT;
  
  ELSIF P_TYPE = 'D' THEN
    --ɾ����
    --step1��ɾ��REPORT2
    DELETE REPORT2 R2
     WHERE R2.REPORT_ID IN
           (SELECT R1.REPORT_ID FROM REPORT1 R1 WHERE R1.REPORT_DW = P_FILE);
    --step2��ɾ��REPORT1
    DELETE REPORT1 R1 WHERE R1.REPORT_DW = P_FILE;
    --step3��ɾ��HX_INVOICE
    DELETE HX_INVOICE WHERE ITID = P_ITID;
    COMMIT;
  END IF;

  --�ж�ÿ���Ƿ���ӳɹ�
  IF SQL%ROWCOUNT > 0 THEN
    MSG := 'Y';
  ELSE
    MSG := 'N';
    RETURN;
  END IF;
END;
/


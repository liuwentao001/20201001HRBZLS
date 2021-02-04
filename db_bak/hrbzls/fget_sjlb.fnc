CREATE OR REPLACE FUNCTION HRBZLS."FGET_SJLB" (P_NO IN VARCHAR2) RETURN VARCHAR2 AS
    LRET VARCHAR2(60);
  BEGIN

    LRET := 'E';
        --�й��ƶ���ͨ����
    IF REGEXP_LIKE(P_NO, '^1(3[4-9]|5[012789]|8[78])\d{8}$') THEN
      LRET := 'A';
    END IF;
    --�й��ƶ�3G����
    IF REGEXP_LIKE(P_NO, '^((157)|(18[78]))[0-9]{8}$') THEN
      LRET := 'A';
    END IF;


    --�й���ͨ��ͨ����
    IF REGEXP_LIKE(P_NO, '^1(([3][012])|([5][6])|([8][56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --�й���ͨ3G����
    IF REGEXP_LIKE(P_NO, '^((156)|(18[56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --�й�������ͨ����
    IF REGEXP_LIKE(P_NO, '^1(([3][3])|([5][3])|([8][09]))[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    --�й�����3G����
    IF REGEXP_LIKE(P_NO, '^(18[09])[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    RETURN LRET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
  END;
/


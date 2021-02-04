CREATE OR REPLACE FUNCTION HRBZLS."FGET_SJLB" (P_NO IN VARCHAR2) RETURN VARCHAR2 AS
    LRET VARCHAR2(60);
  BEGIN

    LRET := 'E';
        --中国移动普通号码
    IF REGEXP_LIKE(P_NO, '^1(3[4-9]|5[012789]|8[78])\d{8}$') THEN
      LRET := 'A';
    END IF;
    --中国移动3G号码
    IF REGEXP_LIKE(P_NO, '^((157)|(18[78]))[0-9]{8}$') THEN
      LRET := 'A';
    END IF;


    --中国联通普通号码
    IF REGEXP_LIKE(P_NO, '^1(([3][012])|([5][6])|([8][56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --中国联通3G号码
    IF REGEXP_LIKE(P_NO, '^((156)|(18[56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --中国电信普通号码
    IF REGEXP_LIKE(P_NO, '^1(([3][3])|([5][3])|([8][09]))[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    --中国电信3G号码
    IF REGEXP_LIKE(P_NO, '^(18[09])[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    RETURN LRET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
  END;
/


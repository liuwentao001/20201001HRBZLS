CREATE OR REPLACE FUNCTION HRBZLS."FGETKTPFID"(P_MCODE IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET       VARCHAR2(4000);
  V_ZKH       VARCHAR2(4000);
  V_PRICE     VARCHAR2(4000);
  V_NUM       NUMBER;
  V_MCODETEMP VARCHAR2(4000);
  V_STR       VARCHAR2(4000);
  V_FLAG      VARCHAR2(1);
BEGIN
  SELECT INSTR(P_MCODE, '/') INTO V_NUM FROM DUAL;
  --如果是一户一单，V_MCODE格式是 '3126091240'
  IF V_NUM = 0 THEN
    SELECT MISEQNO, MIPFID
      INTO V_ZKH, V_PRICE
      FROM METERINFO
     WHERE MIID = P_MCODE;
    V_RET :=  V_PRICE;
  ELSE
/*    --如果是多户一单，V_MCODE格式是 '3126091240/1304395165/1304395166' ，需要解析
    V_FLAG := 'Y';
    V_STR  := P_MCODE;
    LOOP
      EXIT WHEN(V_FLAG = 'N' OR LENGTH(V_STR)>=3970);
      --获取客户号
      V_MCODETEMP := SUBSTR(V_STR, 1, V_NUM-1);
      --截取字符串
      V_STR := SUBSTR(V_STR, V_NUM+1);
      --拼返回结果
      SELECT MISEQNO, MIPFID
        INTO V_ZKH, V_PRICE
        FROM METERINFO
       WHERE MIID = V_MCODETEMP;
      V_RET := V_RET || '【帐卡号：' || V_ZKH || '，用水性质：' || V_PRICE || '】';
      --判断是否还包含分隔符
      SELECT INSTR(V_STR, '/') INTO V_NUM FROM DUAL;
      IF V_NUM = 0 THEN
        --不包含则表示只剩一个用户号
        SELECT MISEQNO, MIPFID
          INTO V_ZKH, V_PRICE
          FROM METERINFO
         WHERE MIID = V_STR;
        V_RET := V_RET || '【帐卡号：' || V_ZKH || '，用水性质：' || V_PRICE || '】';
        --跳出循环
        V_FLAG := 'N';
      END IF;
    END LOOP;*/
    V_RET :='批量';
  END IF;
  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


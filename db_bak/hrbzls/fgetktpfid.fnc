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
  --�����һ��һ����V_MCODE��ʽ�� '3126091240'
  IF V_NUM = 0 THEN
    SELECT MISEQNO, MIPFID
      INTO V_ZKH, V_PRICE
      FROM METERINFO
     WHERE MIID = P_MCODE;
    V_RET :=  V_PRICE;
  ELSE
/*    --����Ƕ໧һ����V_MCODE��ʽ�� '3126091240/1304395165/1304395166' ����Ҫ����
    V_FLAG := 'Y';
    V_STR  := P_MCODE;
    LOOP
      EXIT WHEN(V_FLAG = 'N' OR LENGTH(V_STR)>=3970);
      --��ȡ�ͻ���
      V_MCODETEMP := SUBSTR(V_STR, 1, V_NUM-1);
      --��ȡ�ַ���
      V_STR := SUBSTR(V_STR, V_NUM+1);
      --ƴ���ؽ��
      SELECT MISEQNO, MIPFID
        INTO V_ZKH, V_PRICE
        FROM METERINFO
       WHERE MIID = V_MCODETEMP;
      V_RET := V_RET || '���ʿ��ţ�' || V_ZKH || '����ˮ���ʣ�' || V_PRICE || '��';
      --�ж��Ƿ񻹰����ָ���
      SELECT INSTR(V_STR, '/') INTO V_NUM FROM DUAL;
      IF V_NUM = 0 THEN
        --���������ʾֻʣһ���û���
        SELECT MISEQNO, MIPFID
          INTO V_ZKH, V_PRICE
          FROM METERINFO
         WHERE MIID = V_STR;
        V_RET := V_RET || '���ʿ��ţ�' || V_ZKH || '����ˮ���ʣ�' || V_PRICE || '��';
        --����ѭ��
        V_FLAG := 'N';
      END IF;
    END LOOP;*/
    V_RET :='����';
  END IF;
  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/


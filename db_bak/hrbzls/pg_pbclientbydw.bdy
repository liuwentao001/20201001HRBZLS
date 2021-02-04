CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_PBCLIENTBYDW" IS
  PROCEDURE MAIN(P_TYPE IN VARCHAR2) IS
    V_REG VARCHAR2(100);
  BEGIN
    /*    INSERT INTO PBDWPARMTEMPTEST
    SELECT * FROM PBDWPARMTEMP;*/
    IF TRIM(P_TYPE) = '托收批次生成' THEN
      PG_EWIDE_TS_01.SP_CREATE_TS_MAACCOUNT_04('TS',
                                               FGETPARA('收款银行'),
                                               FGETPARA('营业所'), --营业所
                                               FGETPBOPER, --当前操作员
                                               '',
                                               '',
                                               FGETPARA('账务月份'),
                                               FGETPARA('账务月份'),
                                               'T',
                                               'Y',
                                               FGETPARA('托收号'),
                                               FGETPARA('至'),
                                               V_REG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --获取参数值
  FUNCTION FGETPARA(P_NAME IN VARCHAR2) RETURN VARCHAR2 IS
    V_RET VARCHAR2(400);
  BEGIN
    SELECT DWVAL
      INTO V_RET
      FROM PBDWPARMTEMP
     WHERE DWTXT LIKE '%' || P_NAME || '%';
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
BEGIN

  NULL;
END;
/


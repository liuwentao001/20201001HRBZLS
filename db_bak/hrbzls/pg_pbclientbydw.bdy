CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_PBCLIENTBYDW" IS
  PROCEDURE MAIN(P_TYPE IN VARCHAR2) IS
    V_REG VARCHAR2(100);
  BEGIN
    /*    INSERT INTO PBDWPARMTEMPTEST
    SELECT * FROM PBDWPARMTEMP;*/
    IF TRIM(P_TYPE) = '������������' THEN
      PG_EWIDE_TS_01.SP_CREATE_TS_MAACCOUNT_04('TS',
                                               FGETPARA('�տ�����'),
                                               FGETPARA('Ӫҵ��'), --Ӫҵ��
                                               FGETPBOPER, --��ǰ����Ա
                                               '',
                                               '',
                                               FGETPARA('�����·�'),
                                               FGETPARA('�����·�'),
                                               'T',
                                               'Y',
                                               FGETPARA('���պ�'),
                                               FGETPARA('��'),
                                               V_REG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --��ȡ����ֵ
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


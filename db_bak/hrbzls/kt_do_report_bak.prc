CREATE OR REPLACE PROCEDURE HRBZLS."KT_DO_REPORT_BAK" (AS_TYPE      IN VARCHAR2,
                                         AS_FUNC_ID   IN VARCHAR2,
                                         AS_USER      IN VARCHAR2,
                                         AS_TOUSER    IN VARCHAR2,
                                         AS_REPORT_ID IN VARCHAR2,
                                         AS_MEMO      IN VARCHAR2) IS
  V_KIPID   VARCHAR2(10);
  V_COUNT   NUMBER;
  V_TYPE    VARCHAR(100);
  V_LINKTAB VARCHAR(3000);
  V_MEMO    VARCHAR(4000);
  V_SQL     VARCHAR(4000);
  V_MCODE   VARCHAR2(4000);
BEGIN

  BEGIN
    /** ��ȡ������Ϣ***/
    V_TYPE := FGETFUNCNAME(AS_FUNC_ID);
    /*     select ef.efname,ef.linktab into v_type, v_linktab  from erpfunction ef where trim(ef.efid)=trim(as_func_id);
    v_sql:=v_linktab ||  as_report_id;*/

  END;

  SELECT COUNT(*)
    INTO V_COUNT
    FROM KPI_TASK KT
   WHERE KT.REPORT_ID = AS_REPORT_ID
     AND KT_OPERATOR = AS_TOUSER;
  IF V_COUNT > 0 THEN
    /*         raise_application_error(-20012,
    ' �������ѷ��͸���:'||  fgetopername(as_touser) || ',�����ٴη��ͣ�');*/
    RETURN;
  END IF;

  IF AS_TYPE = 1 THEN
    DELETE KPI_TASK KT
     WHERE KT.REPORT_ID = AS_REPORT_ID
       AND KT_OPERATOR = AS_USER;
    --���ϱ����
    IF AS_FUNC_ID IN
       ('G020232', 'G020234', 'G020235', 'G020250', 'G020256') THEN
      BEGIN
        SELECT CONNSTR(CT.CICODE)
          INTO V_MCODE
          FROM CUSTCHANGEDT CT
         WHERE CT.CCDNO = AS_REPORT_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    ELSIF AS_FUNC_ID IN ('G020236', 'G020341', 'G020351') THEN
      --������
      BEGIN
        SELECT CONNSTR(MT.MTDMCODE)
          INTO V_MCODE
          FROM METERTRANSDT MT
         WHERE MT.MTDNO = AS_REPORT_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    V_MEMO := '����˵����' || AS_MEMO || '; �û���:' || V_MCODE;
    SELECT FGETBILLID('SEQ_KPI_TASK') INTO V_KIPID FROM DUAL;
    INSERT INTO KPI_TASK
    VALUES
      (V_KIPID,
       V_TYPE,
       AS_USER,
       SYSDATE,
       AS_REPORT_ID,
       'Y',
       AS_TOUSER,
       SYSDATE + 3,
       '����ָ��',
       'Ӫҵ�շ�',
       '��������',
       '',
       V_MEMO,
       AS_FUNC_ID,
       NULL,
       NULL,
       NULL,
       null,
       null);
  ELSE
    UPDATE KPI_TASK KT
       SET KT_OPERATOR = ORG_OPERATOR, KT_REMARK = V_MEMO, KT_TYPE = '����'
     WHERE KT.REPORT_ID = AS_REPORT_ID;
  END IF;

  COMMIT;
END;
/


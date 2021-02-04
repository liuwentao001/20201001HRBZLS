CREATE OR REPLACE PROCEDURE HRBZLS."KT_DO_REPORT_COMMITFLAG" (AS_TYPE      IN VARCHAR2,
                                         AS_FUNC_ID   IN VARCHAR2,
                                         AS_USER      IN VARCHAR2,
                                         AS_TOUSER    IN VARCHAR2,
                                         AS_REPORT_ID IN VARCHAR2,
                                         AS_MEMO      IN VARCHAR2,
                                         p_commit in varchar2) IS
  V_KIPID   VARCHAR2(10);
  V_COUNT   NUMBER;
  V_TYPE    VARCHAR(100);
  V_LINKTAB VARCHAR(3000);
  V_MEMO    VARCHAR(4000);
  V_SQL     VARCHAR(4000);
  v_mcode VARCHAR2(4000);
BEGIN

  BEGIN
    /** 获取功能信息***/
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
    ' 该任务已发送给了:'||  fgetopername(as_touser) || ',不需再次发送！');*/
    RETURN;
  END IF;

  IF AS_TYPE = 1 THEN
    DELETE KPI_TASK KT
     WHERE KT.REPORT_ID = AS_REPORT_ID
       AND KT_OPERATOR = AS_USER;
       --资料变更类
      IF AS_FUNC_ID in('G020232','G020234','G020235','G020250','G020256') THEN
        BEGIN
        SELECT connstr(ct.cicode) INTO v_mcode  FROM  custchangedt ct WHERE ct.ccdno=AS_REPORT_ID;
          EXCEPTION
             when OTHERS THEN
             NULL;
         END;

        ELSIF AS_FUNC_ID in('G020236','G020341','G020351') THEN  --表务类
         BEGIN
        SELECT connstr(mt.mtdmcode) INTO v_mcode  FROM  metertransdt mt WHERE mt.mtdno=AS_REPORT_ID;
          EXCEPTION
             when OTHERS THEN
             NULL;
         END;
      end IF;
    V_MEMO := '申请说明：' || AS_MEMO  || '; 用户号:'  || v_mcode ;
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
       '流程指派',
       '营业收费[KT_DO_REPORT_COMMITFLAG]',
       '审批申请',
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
       SET KT_OPERATOR = ORG_OPERATOR,
            KT_REMARK = V_MEMO,
            KT_TYPE     =  '回退'
     WHERE KT.REPORT_ID = AS_REPORT_ID;
  END IF;
if p_commit='Y' THEN
  COMMIT;
END IF;
END;
/


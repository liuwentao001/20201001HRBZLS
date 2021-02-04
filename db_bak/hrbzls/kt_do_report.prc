CREATE OR REPLACE PROCEDURE HRBZLS."KT_DO_REPORT" (AS_TYPE      IN VARCHAR2,
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
  V_PFID    VARCHAR(4000);
  V_PRICE    VARCHAR(4000);

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
    --存在发送多笔用户的情况，发送时先更新此单据所有的用户完成注记,以免在待完成事项中用户还存在
    --20140612 modiby hb
/*   UPDATE  KPI_TASK 
     SET  isfinish='Y',DO_DATE =SYSDATE ,KT_REMARK =trim(KT_REMARK)||trim(AS_USER)
     WHERE  REPORT_ID = AS_REPORT_ID and  KT_TYPE <> '回退';*/
     
    DELETE KPI_TASK KT
     WHERE KT.REPORT_ID = AS_REPORT_ID
       AND KT_OPERATOR = AS_USER;
       

    --资料变更类
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
      --表务类
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
    
    --V_MEMO := '申请说明：' || AS_MEMO || '; 用户号:' || V_MCODE;
    --【哈尔滨】根据用户号查询帐卡号和用水性质
     V_MEMO := FGETKTMEMO(V_MCODE);
     V_PFID := FGETKTPFID(V_MCODE);
     V_PRICE:= FGETKTPRICE(V_MCODE);

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
       '营业收费[KT_DO_REPORT]',
       '审批申请',
       '',
       V_MEMO,
       AS_FUNC_ID,
       NULL,
       NULL,
       NULL,
       V_PFID,
       V_PRICE);
  ELSE
    
    V_MEMO := '回退原因：' || AS_MEMO ;
 
/*        
    UPDATE KPI_TASK KT
       SET KT_OPERATOR = ORG_OPERATOR, KT_REMARK = V_MEMO, KT_TYPE = '回退' 
     WHERE KT.REPORT_ID = AS_REPORT_ID;*/
     --20140821厚凯提出有BUG调整
         UPDATE KPI_TASK KT
       SET ORG_OPERATOR = AS_USER,
           ORG_DATE     = SYSDATE,
           KT_OPERATOR =
           (SELECT FMOPER
              FROM FLOW_MAIN
             WHERE FMBILLNO = AS_REPORT_ID
               AND FMSTAUS = '3'),
           KT_REMARK    = V_MEMO,
           KT_TYPE      = '回退'
     WHERE KT.REPORT_ID = AS_REPORT_ID;
     
  END IF;

  COMMIT;
END;
/


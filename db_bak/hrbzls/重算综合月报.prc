CREATE OR REPLACE PROCEDURE HRBZLS.重算综合月报(A_MONTH IN VARCHAR2) AS
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;
    n_app   number;
    c_error varchar2(200);
  BEGIN

    /*********
           名称：        重算哈尔滨综合月报
           作者:          朱芳
           时间:           2017-10-01
           参数说明：  A_MONTH  账务月份
           用途 :     调整历史账务数据后，调用此过程可重算  2.抄表统计 3.账务明细统计 4.收费统计 5.综合统计
    ************/
    --可选
   /* --------初始化中间表--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '初始化中间表';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

      初始化中间表(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '初始化中间表成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '初始化中间表失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------记录操作日志--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;*/

    -------------记录操作日志-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '抄表统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.抄表统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '抄表统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '抄表统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '账务明细统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.账务明细统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '账务明细统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '账务明细统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------记录操作日志--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '收费统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.收费统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '收费统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '收费统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '综合统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.综合统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '综合统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '综合统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

      -------------记录操作日志-------------
      --20140626蔡俊平
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '财务资金统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.财务资金统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '财务资金统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '财务资金统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
    ------------------------------------------------------------
    --2014/05/31
    -- START 增加执行可编辑售水量报表的中间表生成
  --  PG_EWIDE_JOB_HRB.月售水情况归档_1(A_MONTH);

     --20140720   贺帮
     --添加记录操作日志
     -- START 增加执行可编辑售水量报表的中间表生成
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '月售水情况归档_1';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       PG_EWIDE_JOB_HRB.月售水情况归档_1(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '月售水情况归档_1成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '月售水情况归档_1失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;



  END;
/


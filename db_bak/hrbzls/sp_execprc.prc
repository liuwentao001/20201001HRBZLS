CREATE OR REPLACE PROCEDURE HRBZLS."SP_EXECPRC" (
               p_type  IN VARCHAR2,/*过程执行类别*/
               p_taskid IN VARCHAR2,  /*系统任务号*/
               p_para IN VARCHAR2 DEFAULT NULL,--参数
               p_commit IN VARCHAR2,--是否提交
               O_RET OUT VARCHAR2)   --返回值
    AS
     lProcName     varchar2(30000);
     dest_cursor   integer;
     rowp        integer;
     Row_task    TaskDefine%RowType;
    BEGIN

    if p_type='0' then
   --不从表出
      IF LTRIM(p_para) IS NULL THEN
        lProcName := 'BEGIN  :O_RET :='||p_taskid||';  END; ';  /*执行主过程*/
      ELSE
        lProcName := 'BEGIN  :O_RET :='||p_taskid||'('||p_para||');  END; ';
      END IF;

      EXECUTE IMMEDIATE  lProcName USING OUT O_RET  ;
      RETURN ;

    elsif p_type='1' then
       row_task.TDmproc :=p_taskid ;
   --有从其它表出
    elsif  p_type='2' then
        BEGIN
          SELECT * INTO row_task FROM TASKDEFINE WHERE tdid = p_taskid;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20201, p_taskid || '任务未定义,请检查!');
        END;
    --单据执行过程
    elsif  p_type='3' then
        BEGIN
          SELECT * INTO row_task FROM TASKDEFINE WHERE tdid = p_taskid;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20201, p_taskid || '任务未定义,请检查!');
        END;
    else
      raise_application_error( -20201,'过程执行方式错误!');
    end if;

    /*IF LTRIM(p_para) IS NULL THEN
      lProcName := 'BEGIN  '||row_task.TDmproc||';  END;';  \*执行主过程*\
    ELSE
      lProcName := 'BEGIN  '||row_task.TDmproc||'('||p_para||');  END;';
    END IF;*/

    dest_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(dest_cursor,lProcName,dbms_sql.V7);
    rowp   := dbms_sql.execute(dest_cursor);
    dbms_sql.close_cursor(dest_cursor);
    if p_commit='Y' THEN
      COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    IF dbms_sql.is_open(dest_cursor) THEN
      dbms_sql.close_cursor(dest_cursor);
    END IF;
    ROLLBACK;
    Raise;
  END;
/


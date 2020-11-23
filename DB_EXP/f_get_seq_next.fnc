CREATE OR REPLACE FUNCTION F_GET_SEQ_NEXT(AS_TAB_NAME IN VARCHAR2)
  RETURN VARCHAR2 IS
  -- --------------------------------------------------------------------------
  -- Name         : F_GET_SEQ_NEXT
  -- Author       : Tim
  -- Description  : 按照在SYS_SEQ_ID 表中定义的细节返回序列值
  -- Ammedments   : 
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation
  -- --------------------------------------------------------------------------
  LN_SEQ_NUM    NUMBER;
  LS_SEQ_NUM    VARCHAR2(20);
  LS_PREFIX     VARCHAR2(2);
  AS_SEQ_NAME   VARCHAR2(30);
  TEMP_ID       VARCHAR2(40);
  LS_CUR_SYNTAX VARCHAR(200);
  LI_CUR_HANDLE INTEGER;
  LI_RTN        INTEGER;
  LR_SEQLIST    SYS_SEQ_ID%ROWTYPE;
  PRELEN        NUMBER;
BEGIN
  --获得当前的序列相关的定义
  SELECT SEQSEQNAME, NVL(SEQPREFIX, ' '), SEQWIDTH, SEQSTARTNO
    INTO LR_SEQLIST.SEQSEQNAME,
         LR_SEQLIST.SEQPREFIX,
         LR_SEQLIST.SEQWIDTH,
         LR_SEQLIST.SEQSTARTNO
    FROM SYS_SEQ_ID
   WHERE UPPER(SEQTBLNAME) = UPPER(AS_TAB_NAME);

  IF TRIM(LR_SEQLIST.SEQPREFIX) IS NULL THEN
    PRELEN := 0;
  ELSE
    PRELEN := LENGTH(TRIM(LR_SEQLIST.SEQPREFIX));
  END IF;

  --动态SQL取序列的值
  AS_SEQ_NAME   := LR_SEQLIST.SEQSEQNAME;
  LS_PREFIX     := LR_SEQLIST.SEQPREFIX;
  LI_CUR_HANDLE := DBMS_SQL.OPEN_CURSOR;
  LS_CUR_SYNTAX := 'select ' || AS_SEQ_NAME || '.nextval from dual';
  DBMS_SQL.PARSE(LI_CUR_HANDLE, LS_CUR_SYNTAX, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(LI_CUR_HANDLE, 1, LN_SEQ_NUM);

  LI_RTN := DBMS_SQL.EXECUTE(LI_CUR_HANDLE);
  IF DBMS_SQL.FETCH_ROWS(LI_CUR_HANDLE) > 0 THEN
    DBMS_SQL.COLUMN_VALUE(LI_CUR_HANDLE, 1, LN_SEQ_NUM);
    DBMS_SQL.CLOSE_CURSOR(LI_CUR_HANDLE);
  END IF;

  -- 按照预定的格式返回序列值
  TEMP_ID    := '000000000000000000000000000000' || TO_CHAR(LN_SEQ_NUM);
  LS_SEQ_NUM := TRIM(LR_SEQLIST.SEQPREFIX ||
                     SUBSTR(TEMP_ID,
                            LENGTH(TEMP_ID) - LR_SEQLIST.SEQWIDTH + PRELEN + 1,
                            LR_SEQLIST.SEQWIDTH - PRELEN));

  RETURN(LS_SEQ_NUM);

EXCEPTION
  
  WHEN OTHERS THEN 
      RETURN ' seq        error!';
   
END;
/


CREATE OR REPLACE PROCEDURE HRBZLS."SP_DWCONTINFOMG" (P_TYPE       IN VARCHAR2, -- 类型
                                         P_DCIFID     IN  VARCHAR2, --流水号
                                         P_DCIFTYPE   IN VARCHAR2, --条件类型
                                         P_DCIFOWNER  IN VARCHAR2, --所有者
                                         P_DCIFNAME   IN VARCHAR2, --条件名称
                                         P_DCIFFUNID  IN VARCHAR2, --功能编号
                                         P_DCIFDWNAME IN VARCHAR2, --数据窗口名
                                         P_DCIFDWCONSTR IN   VARCHAR2, --条件字符串
                                         O_DCIFID     OUT  VARCHAR2, --OUT流水号
                                         O_DCIFDWCONSTR  OUT  VARCHAR2 ) --OUT条件字符串
 AS
  DCIF     DWCONTINFO%ROWTYPE;
  V_COUNT  NUMBER(10);
BEGIN

  /*----------------------------------------------------
    --NAME:FDWCONTINFOMG
    --NOTE:数据窗口查询条件信息管理
    --AUTHOR:WY
    --DATE：2009/02/14
    --INPUT: P_TYPE       IN VARCHAR2, -- 类型
    --01查询
    --02保存
    --03修改
    --04删除
     P_DCIFID     IN VARCHAR2, --流水号
     P_DCIFTYPE   IN VARCHAR2, --条件类型 SEARCHSTRING, FILTERSTRING
     P_DCIFOWNER   IN VARCHAR2, --所有者
     P_DCIFFUNID  IN VARCHAR2,  --方法编号
     P_DCIFDWNAME IN VARCHAR2,  --数据窗口名
     DCIFDWCONSTR IN VARCHAR2)  --条件字符串
  */
  IF P_TYPE = '01' THEN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM DWCONTINFO
     WHERE DCIFTYPE = P_DCIFTYPE
       AND DCIFOWNER = P_DCIFOWNER

       AND DCIFDWNAME = P_DCIFDWNAME;
    IF V_COUNT < 1 THEN
      O_DCIFDWCONSTR := NULL;
    ELSE
      SELECT COUNT(*)
        INTO V_COUNT
        FROM DWCONTINFO
       WHERE DCIFTYPE = P_DCIFTYPE
         AND DCIFOWNER = P_DCIFOWNER
         AND DCIFDWNAME = P_DCIFDWNAME
         AND DCIFFLAG = 'Y';
      IF V_COUNT > 0 THEN
        SELECT DCIFDWCONSTR,DCIFID
          INTO DCIF.DCIFDWCONSTR,
          O_DCIFID
          FROM DWCONTINFO
         WHERE DCIFTYPE = P_DCIFTYPE
           AND DCIFOWNER = P_DCIFOWNER
           AND DCIFDWNAME = P_DCIFDWNAME
           AND DCIFFLAG = 'Y';
      ELSE
        SELECT DCIFDWCONSTR,DCIFID
          INTO DCIF.DCIFDWCONSTR,
          O_DCIFID
          FROM DWCONTINFO
         WHERE DCIFTYPE = P_DCIFTYPE
           AND DCIFOWNER = P_DCIFOWNER
           AND DCIFDWNAME = P_DCIFDWNAME
           AND DCIFDATE IN (SELECT MAX(DCIFDATE)
                              FROM DWCONTINFO
                             WHERE DCIFTYPE = P_DCIFTYPE
                               AND DCIFOWNER = P_DCIFOWNER
                               AND DCIFDWNAME = P_DCIFDWNAME)
           AND ROWNUM = 1;
      END IF;
      O_DCIFDWCONSTR := DCIF.DCIFDWCONSTR;
    END IF;
  END IF;
IF P_TYPE = '01' THEN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM DWCONTINFO
     WHERE DCIFTYPE = P_DCIFTYPE
       AND DCIFOWNER = P_DCIFOWNER

       AND DCIFDWNAME = P_DCIFDWNAME;
    IF V_COUNT < 1 THEN
      O_DCIFDWCONSTR := NULL;
    ELSE
      SELECT COUNT(*)
        INTO V_COUNT
        FROM DWCONTINFO
       WHERE DCIFTYPE = P_DCIFTYPE
         AND DCIFOWNER = P_DCIFOWNER
         AND DCIFDWNAME = P_DCIFDWNAME
         AND DCIFFLAG = 'Y';
      IF V_COUNT > 0 THEN
        SELECT DCIFDWCONSTR,DCIFID
          INTO DCIF.DCIFDWCONSTR,
          O_DCIFID
          FROM DWCONTINFO
         WHERE DCIFTYPE = P_DCIFTYPE
           AND DCIFOWNER = P_DCIFOWNER
           AND DCIFDWNAME = P_DCIFDWNAME
           AND DCIFFLAG = 'Y';
      ELSE
        SELECT DCIFDWCONSTR,DCIFID
          INTO DCIF.DCIFDWCONSTR,
          O_DCIFID
          FROM DWCONTINFO
         WHERE DCIFTYPE = P_DCIFTYPE
           AND DCIFOWNER = P_DCIFOWNER
           AND DCIFDWNAME = P_DCIFDWNAME
           AND DCIFDATE IN (SELECT MAX(DCIFDATE)
                              FROM DWCONTINFO
                             WHERE DCIFTYPE = P_DCIFTYPE
                               AND DCIFOWNER = P_DCIFOWNER
                               AND DCIFDWNAME = P_DCIFDWNAME)
           AND ROWNUM = 1;
      END IF;
      O_DCIFDWCONSTR := DCIF.DCIFDWCONSTR;
    END IF;
   ELSIF P_TYPE = '02' THEN
      SELECT COUNT(*)
      INTO V_COUNT
      FROM DWCONTINFO
     WHERE DCIFTYPE = P_DCIFTYPE
       AND DCIFOWNER = P_DCIFOWNER
       AND DCIFDWNAME = P_DCIFDWNAME
       AND DCIFFLAG='Y';
       IF V_COUNT=1 THEN
          UPDATE DWCONTINFO SET DCIFDWCONSTR=P_DCIFDWCONSTR,
          DCIFNAME = '默认条件'||to_char(sysdate,'yyyymmddhh24miss'),
          DCIFDATE =  SYSDATE WHERE DCIFTYPE = P_DCIFTYPE
       AND DCIFOWNER = P_DCIFOWNER
       AND DCIFDWNAME = P_DCIFDWNAME
       AND DCIFFLAG='Y' ;
       ELSE
       IF  V_COUNT>1  THEN
       DELETE DWCONTINFO
        WHERE DCIFTYPE = P_DCIFTYPE
       AND DCIFOWNER = P_DCIFOWNER
       AND DCIFDWNAME = P_DCIFDWNAME
       AND DCIFFLAG='Y' ;
       END IF;
       SELECT SEQ_DWCONTINFO.NEXTVAL INTO  DCIF.DCIFID  FROM DUAL;
          INSERT INTO DWCONTINFO VALUES
          (
          DCIF.DCIFID,
          SYSDATE,
          P_DCIFTYPE,
          P_DCIFOWNER,
          '默认条件'||to_char(sysdate,'yyyymmddhh24miss'),
          P_DCIFFUNID,
          P_DCIFDWNAME,
          P_DCIFDWCONSTR,
          'Y'
          );
       END IF;

       O_DCIFID :=P_DCIFID ;
       O_DCIFDWCONSTR :=P_DCIFDWCONSTR ;
       COMMIT;


  END IF;
EXCEPTION
  WHEN OTHERS THEN
    O_DCIFID :='0';
    O_DCIFDWCONSTR := NULL;
END;
/


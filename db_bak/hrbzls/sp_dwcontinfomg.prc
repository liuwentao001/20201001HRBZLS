CREATE OR REPLACE PROCEDURE HRBZLS."SP_DWCONTINFOMG" (P_TYPE       IN VARCHAR2, -- ����
                                         P_DCIFID     IN  VARCHAR2, --��ˮ��
                                         P_DCIFTYPE   IN VARCHAR2, --��������
                                         P_DCIFOWNER  IN VARCHAR2, --������
                                         P_DCIFNAME   IN VARCHAR2, --��������
                                         P_DCIFFUNID  IN VARCHAR2, --���ܱ��
                                         P_DCIFDWNAME IN VARCHAR2, --���ݴ�����
                                         P_DCIFDWCONSTR IN   VARCHAR2, --�����ַ���
                                         O_DCIFID     OUT  VARCHAR2, --OUT��ˮ��
                                         O_DCIFDWCONSTR  OUT  VARCHAR2 ) --OUT�����ַ���
 AS
  DCIF     DWCONTINFO%ROWTYPE;
  V_COUNT  NUMBER(10);
BEGIN

  /*----------------------------------------------------
    --NAME:FDWCONTINFOMG
    --NOTE:���ݴ��ڲ�ѯ������Ϣ����
    --AUTHOR:WY
    --DATE��2009/02/14
    --INPUT: P_TYPE       IN VARCHAR2, -- ����
    --01��ѯ
    --02����
    --03�޸�
    --04ɾ��
     P_DCIFID     IN VARCHAR2, --��ˮ��
     P_DCIFTYPE   IN VARCHAR2, --�������� SEARCHSTRING, FILTERSTRING
     P_DCIFOWNER   IN VARCHAR2, --������
     P_DCIFFUNID  IN VARCHAR2,  --�������
     P_DCIFDWNAME IN VARCHAR2,  --���ݴ�����
     DCIFDWCONSTR IN VARCHAR2)  --�����ַ���
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
          DCIFNAME = 'Ĭ������'||to_char(sysdate,'yyyymmddhh24miss'),
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
          'Ĭ������'||to_char(sysdate,'yyyymmddhh24miss'),
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


CREATE OR REPLACE PROCEDURE HRBZLS.�����ۺ��±�(A_MONTH IN VARCHAR2) AS
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;
    n_app   number;
    c_error varchar2(200);
  BEGIN

    /*********
           ���ƣ�        ����������ۺ��±�
           ����:          �췼
           ʱ��:           2017-10-01
           ����˵����  A_MONTH  �����·�
           ��; :     ������ʷ�������ݺ󣬵��ô˹��̿�����  2.����ͳ�� 3.������ϸͳ�� 4.�շ�ͳ�� 5.�ۺ�ͳ��
    ************/
    --��ѡ
   /* --------��ʼ���м��--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '��ʼ���м��';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

      ��ʼ���м��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '��ʼ���м��ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '��ʼ���м��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------��¼������־--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;*/

    -------------��¼������־-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '����ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.����ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '����ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '����ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '������ϸͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.������ϸͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '������ϸͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '������ϸͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------��¼������־--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�շ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.�շ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�շ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�շ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�ۺ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.�ۺ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�ۺ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�ۺ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

      -------------��¼������־-------------
      --20140626�̿�ƽ
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�����ʽ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      pg_ewide_reportsum_hrb.�����ʽ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�����ʽ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�����ʽ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
    ------------------------------------------------------------
    --2014/05/31
    -- START ����ִ�пɱ༭��ˮ��������м������
  --  PG_EWIDE_JOB_HRB.����ˮ����鵵_1(A_MONTH);

     --20140720   �ذ�
     --��Ӽ�¼������־
     -- START ����ִ�пɱ༭��ˮ��������м������
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '����ˮ����鵵_1';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       PG_EWIDE_JOB_HRB.����ˮ����鵵_1(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '����ˮ����鵵_1�ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '����ˮ����鵵_1ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;



  END;
/


CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_EINVOICE IS
  /*
  --��Ȩ dba�û���ִ��
  begin
    dbms_java.grant_permission('TZZLS','SYS:java.net.SocketPermission','1.1.1.83:8999','connect,resolve');
  end;
  */
  /*
    CREATE SEQUENCE SEQ_EINVOICE
    MINVALUE 1
    MAXVALUE 9999999999
    START WITH 1
    INCREMENT BY 1
    CACHE 20
    ORDER;
    DELETE SYSSEQLIST WHERE SSLTBLNAME='INV_EINVOICE';
    INSERT INTO SYSSEQLIST (SSLTBLNAME, SSLSEQNAME, SSLPREFIX, SSLWIDTH, SSLCNAME, SSLSTARTNO)
           VALUES ('INV_EINVOICE', 'SEQ_EINVOICE', '', 10, '��ά��ƽ̨���ӷ�Ʊ��ˮ��', NULL);

  */
  DEBUG      CONSTANT BOOLEAN := FALSE;
  ERRCODE    CONSTANT INTEGER := -20012;
  G_��˰     CONSTANT BOOLEAN := FALSE;
  G_��Ʊ�޶� CONSTANT NUMBER(10) := 9999999;
  G_����˰Ʊ CONSTANT BOOLEAN := TRUE;

  --��Ʊ�������
  PROCEDURE P_EINVOICE(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                       );
  PROCEDURE p_distribute(O_INVLIST   OUT INVLIST%ROWTYPE);
  --��������ϲ�Ϊһ����ϸ
  PROCEDURE P_UNION(P_ID VARCHAR2);
  --��������Ŀ���
  PROCEDURE P_SHARE(P_ID VARCHAR2);
  --����ΥԼ����ϸ��
  PROCEDURE P_ZNJ(P_ID VARCHAR2, P_JE IN NUMBER, P_PIID IN VARCHAR2);
  --���ɷ�Ʊ������ˮ�ţ�����¼��־��
  FUNCTION F_GET_FPQQLSH(P_ICID VARCHAR2) RETURN VARCHAR2;
  --�޶��Ʊ����
  PROCEDURE P_SPLIT_��˰;
  PROCEDURE P_SPLIT_����˰;
  --��ȡ��Ʊ��ע
  FUNCTION F_NOTES(P_ID VARCHAR2) RETURN VARCHAR2;
  --��ȡ˰�ز���
  FUNCTION F_GET_PARM(P_PARM VARCHAR2) RETURN VARCHAR2;
  --ȥ���س���
  FUNCTION F_DISCARDCR(P_CHAR VARCHAR2) RETURN VARCHAR2;
  --���ɷ�Ʊ����¼
  PROCEDURE P_INVSTOCK_ADD;
  --���濪Ʊ��¼
  PROCEDURE P_SAVEINV;
  --������־
  PROCEDURE P_LOG(P_ID      IN OUT NUMBER,
                  P_CODE    IN VARCHAR2,
                  P_FPQQLSH IN VARCHAR2,
                  P_XH      IN NUMBER,
                  P_I_JSON  IN VARCHAR2,
                  P_O_JSON  IN VARCHAR2);
  --��Ʊ����
  PROCEDURE P_BUILDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2);
  --���ߺ�Ʊ
  PROCEDURE P_REDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2);
  --��Ʊ����
  PROCEDURE P_BUILDINVFILE(P_ICID     IN VARCHAR2,
                           P_SLTJ     IN VARCHAR2 DEFAULT 'YYSF', --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           P_FILETYPE IN VARCHAR2 DEFAULT 'PNG', --�ļ����ͣ�PNG,PDF,JPG ���ָ�ʽ��
                           O_CODE     OUT VARCHAR2,
                           O_ERRMSG   OUT VARCHAR2,
                           O_URL1     OUT VARCHAR2,
                           O_URL2     OUT VARCHAR2);
  --��Ʊ���
  PROCEDURE P_GETINVKC(O_CODE OUT VARCHAR2, O_ERRMSG OUT VARCHAR2);

  --��ȡȡƱ��ά��
  FUNCTION F_BUILDMATRIX(P_FPQQLSH VARCHAR2) RETURN VARCHAR2;

  --��Ʊ����
  PROCEDURE P_CANCEL(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
  --��Ʊ����
  PROCEDURE P_CANCELINV(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2);
  --��Ʊ����
  PROCEDURE P_CANCEL_HRB(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     P_CDRLID VARCHAR2,
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
PROCEDURE P_CANCEL_HRBtest(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     P_CDRLID VARCHAR2, --Ӧ����ˮ��

                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2);
  --��Ʊ����
  PROCEDURE P_CANCELINV_HRB(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        P_CDRLID VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2);

  --΢�ŷ�Ʊ����
  PROCEDURE P_PRINT_WX(I_ID   IN VARCHAR2, --������ˮ
                       O_JSON OUT CLOB --���߽��
                       );

  --��������
  PROCEDURE P_SENDMAIL(P_URL    IN VARCHAR2,
                       P_MIID   IN VARCHAR2,
                       P_EMAIL  IN VARCHAR2,
                       P_MINAME IN VARCHAR2);

  --��ѯ������ˮ���Ƿ��ѿ�
  PROCEDURE P_QUERYINV(P_FPQQLSH IN VARCHAR2, P_RETURN OUT VARCHAR2);

  --��Ʊ��ѯ����״̬
  PROCEDURE P_ASYNCINV(P_FPQQLSH IN VARCHAR2,

                       P_QYSH    IN VARCHAR2,
                       /*P_RETURN  OUT LONG*/
                       O_TYPE    OUT VARCHAR2,
                       O_MSG     OUT VARCHAR2);

  --��Ϣ����
PROCEDURE P_PUSHURL(P_TYPE    IN VARCHAR2,
                      P_FPQQLSH IN VARCHAR2,
                      P_CONTENT IN CLOB,
                      P_RETURN  OUT VARCHAR2);

PROCEDURE P_QUICKCANCEL(P_FPQQLSH IN VARCHAR2,
                          P_FPDM    IN VARCHAR2,
                          P_FPHM    IN VARCHAR2,
                          O_CODE    OUT VARCHAR2,
                          O_ERRMSG  OUT VARCHAR2);
--ʵ�ղ�Ʊ
PROCEDURE P_INV_ADDFP(P_DATE IN VARCHAR2);
--��Ʊ
PROCEDURE P_CHK_INV(P_DATE IN VARCHAR2);

--ƽƱ
PROCEDURE P_INV_PP(P_DATE IN VARCHAR2);
PROCEDURE P_INV_PP_HRB(P_DATE IN VARCHAR2);
--ÿ���Զ���Ʊ����ǰһ��Ʊ��
PROCEDURE P_INV_DP;

--��Ʊ����-��Ʊ���ܷ���
PROCEDURE P_INV_ADDFP_RUN(V_DATE IN VARCHAR2);

END PG_EWIDE_EINVOICE;
/


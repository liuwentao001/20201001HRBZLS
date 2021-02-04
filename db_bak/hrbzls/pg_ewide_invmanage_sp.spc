CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_INVMANAGE_SP" IS

  ERRCODE CONSTANT INTEGER := -20012;
  --���������ӷ�Ʊƾ֤���
  C_Ԥ��     CONSTANT VARCHAR2(10) := '1';
  C_��Ʊ     CONSTANT VARCHAR2(10) := '2';
  C_��Ʊ     CONSTANT VARCHAR2(10) := '3';
  C_Ԥ����Ʊ CONSTANT VARCHAR2(10) := '4';
  C_Ԥ����Ʊ CONSTANT VARCHAR2(10) := '5';

  --������Ʊ
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --���κ�
                           P_ISPER     VARCHAR2, --��Ʊ��
                           P_ISTYPE    VARCHAR2, --��Ʊ���
                           P_ISNOSTART VARCHAR2, --��Ʊ���
                           P_ISNOEND   VARCHAR2, --��Ʊֹ��
                           P_OUTPER    VARCHAR2, --����Ʊ����
                           MSG         OUT VARCHAR2);

  --��Ʊת��
  PROCEDURE SP_INVMANG_ZLY(P_INVTYPE     VARCHAR2,
                           P_ISNOSTART   VARCHAR2, --��Ʊ���
                           P_ISNOEND     VARCHAR2, --��Ʊֹ��
                           P_ISBCNO      VARCHAR2, --���κ�
                           P_ISSTATUSPER VARCHAR2, --������Ա
                           P_STATUS      NUMBER, --״̬0
                           P_MEMO        VARCHAR2, --��ע
                           MSG           OUT VARCHAR2);

  --�޸ķ�Ʊ״̬
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_INVTYPE     VARCHAR2,
                                    P_ISNOSTART   VARCHAR2, --��Ʊ���
                                    P_ISNOEND     VARCHAR2, --��Ʊֹ��
                                    P_ISBCNO      VARCHAR2, --���κ�
                                    P_ISSTATUSPER VARCHAR2, --״̬�����Ա
                                    P_STATUS      NUMBER, --״̬2
                                    P_MEMO        VARCHAR2, --��ע
                                    MSG           OUT VARCHAR2);
  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --��Ʊ���κ�
                                P_ISNO  IN VARCHAR2 --��Ʊ��
                                );
  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --��Ʊ���κ�
                              P_ISNO   IN VARCHAR2, --��Ʊ��
                              P_STATUS NUMBER);

  --Ԥ��Ʊ��Դ
  PROCEDURE SP_SWAPINVYC(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         );
  --��Ʊ����Դ
  PROCEDURE SP_SWAPINVHP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         );
  --��Ʊ����Դ
  PROCEDURE SP_SWAPINVFP(P_PRINTTYPE IN VARCHAR2,
                         P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                         );
  --Ԥ����Ʊ����Դ
  PROCEDURE SP_SWAPINVYKHP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           );
  --Ԥ����Ʊ����Դ
  PROCEDURE SP_SWAPINVYKFP(P_PRINTTYPE IN VARCHAR2,
                           P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           );

  --��ӡ˰Ʊƾ֤������Ʊ�ţ�
  PROCEDURE SP_PREPRINT_SPPZ(P_PRINTTYPE IN VARCHAR2,
                             P_INVTYPE   IN VARCHAR2,
                             P_INVNO     IN VARCHAR2,
                             O_CODE      OUT VARCHAR2,
                             O_ERRMSG    OUT VARCHAR2);

  --��ά��ƽ̨���ӷ�Ʊ
  PROCEDURE SP_PREPRINT_EINVOICE(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                                 );
    PROCEDURE SP_PREPRINT_EINVOICEtest(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2,
                                 P_RLID    IN VARCHAR2,
                                 O_CODE      OUT VARCHAR2,
                                 O_ERRMSG    OUT VARCHAR2,
                                 P_SLTJ      IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                                 );

  PROCEDURE P_QUEUE(P_ID      IN VARCHAR2,P_TYPE IN VARCHAR2);
  --ɾ����Ʊ��¼
  PROCEDURE SP_DELINV(P_TYPE IN VARCHAR2);
  --���ӷ�Ʊ�ӳٿ�Ʊ����
  PROCEDURE SP_EINVOICE_DELAY(V_ID IN VARCHAR2);
  PROCEDURE SP_EINVOICE_DELAY_JOB(P_ID IN NUMBER);
  PROCEDURE SP_EINVOICE_DELAY_ATONCE(P_ID IN NUMBER);

  --ƾ֤��ϸ��
  PROCEDURE SP_GET_INV_DETAIL(P_ID   IN VARCHAR2,
                              P_TYPE IN VARCHAR2,
                              P_INV  IN OUT INV_INFOTEMP_SP%ROWTYPE);

  --ȥ���ַ��������ַ�
  FUNCTION FGETFORMAT(P_STR IN VARCHAR2) RETURN VARCHAR2;
  --�����ַ������루C=���У�L=����룬R=�Ҷ��룩
  FUNCTION FSETSTRALIGN(P_STR   IN VARCHAR2,
                        P_LEN   IN INTEGER,
                        P_ALIGN IN VARCHAR2) RETURN VARCHAR2;

  --�ж��û��Ƿ�Ϊ�Ⳮ��
  FUNCTION FGETMETERSTATUS(P_CODE IN VARCHAR2 --�û���
                           ) RETURN VARCHAR2;
  --��ȡһ�������ĩԤ�����
  FUNCTION FGETHSQMSAVING(P_MIID IN VARCHAR2 --�ͻ�����
                          ) RETURN VARCHAR2;
  --��ȡ���ջ���
  FUNCTION FGETHSCODE(P_MIID IN VARCHAR2 --�ͻ�����
                      ) RETURN VARCHAR2;
  --��Ʊ��ӡ��ϸ(һ�����)
  FUNCTION FGETHSINVDEATIL(P_MIID IN VARCHAR2 --�ͻ�����
                           ) RETURN VARCHAR2;
  --��ȡ�û����˿��ţ�����+������ţ�
  FUNCTION FGETNEWCARDNO(P_MIID IN VARCHAR2 --�ͻ�����
                         ) RETURN VARCHAR2;
  --��ȡ��ע��Ϣ
  FUNCTION FGETINVMEMO(P_RLID IN VARCHAR2, --Ӧ����ˮ
                       P_TYPE IN VARCHAR2 --��ע����
                       ) RETURN VARCHAR2;
  --��ȡ��Ʊ��ά��
  FUNCTION FGETINVEWM(P_ID   IN VARCHAR2, --��Ʊ��ȡ��
                      P_TYPE IN VARCHAR2 --��ȡ������
                      ) RETURN VARCHAR2;
FUNCTION FGETINVUP(P_ID   IN VARCHAR2
                      ) RETURN NUMBER;
PROCEDURE SP_PREPRINT_EINVOICE_JOBRUN(P_PRINTTYPE IN VARCHAR2,
                                 P_INVTYPE   IN VARCHAR2,
                                 P_INVNO     IN VARCHAR2,
                                 P_SLTJ      IN VARCHAR2,
                                 P_PBATCH    IN VARCHAR2
                                 );
--�ɷ��Զ�ִ�е��ӷ�Ʊ��������
PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2);
--JOB�ж�����2��ִ��һ��
 PROCEDURE SP_EINV_JOB;

END;
/


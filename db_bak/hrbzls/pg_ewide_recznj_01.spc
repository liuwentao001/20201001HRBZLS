CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RECZNJ_01" IS

  -- Author  : ����
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;

  --�����ύ��ڹ���
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --���ⵥ��
  PROCEDURE SP_RECZNJJM(P_ZAHNO  IN VARCHAR2, --������ˮ
                        P_PER    IN VARCHAR2, --����Ա
                        P_COMMIT IN VARCHAR2 --�ύ��־
                        );

  --���ɽ����ȡ��
  PROCEDURE SP_RECZNJJMCANCEL(P_ZAHNO  IN VARCHAR2, --������ˮ
                              P_PER    IN VARCHAR2, --����Ա
                              P_COMMIT IN VARCHAR2 --�ύ��־
                              );

  --������Ա�Ƿ����������
  FUNCTION F_CHKZNJED(P_OPER IN VARCHAR2, P_WYDNO IN VARCHAR2)
    RETURN VARCHAR2;
  --���ɽ���⹦��ʹ��
  PROCEDURE SP_ZNJJM_GETZNJLIST(P_CODE    IN VARCHAR2,
                                P_BFID    IN VARCHAR2,
                                P_MINDATE IN DATE,
                                P_MAXDATE IN DATE,
                                O_FLAG    OUT VARCHAR2);
  PROCEDURE ����ΥԼ����ⵥ��(P_ZASMFID    IN VARCHAR2, --Ӫҵ��
                      P_ZAHDEPT    IN VARCHAR2, -- ��������
                      P_ZAHCREPER  IN VARCHAR2, --������Ա
                      P_ZAHCREDATE IN VARCHAR2, --��������
                      P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                      P_ZAHNO      IN OUT VARCHAR2, --������ݺ�
                      P_ZNJ        IN NUMBER, --Ŀ����
                      P_COMMIT     IN VARCHAR2 --�ύ��־
                      );

END;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_CUSTBASE_01" IS

  -- Author  : ����
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;
  �Ƿ������       VARCHAR(2) := FSYSPARA('sys4');
  �ͻ������Ƿ�Ӫҵ�� VARCHAR(2) := FSYSPARA('CODE');
  --����쳣��־
    PROCEDURE WLOG(P_TXT IN VARCHAR2);
  --�������·�ɹ���
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --�������·�ɹ��̣��򻯣�
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --�����ȡ��
  PROCEDURE CANCEL(P_BILLNO IN VARCHAR2,
                   P_PERSON IN VARCHAR2,
                   P_DJLB   IN VARCHAR2);
  --����������
  PROCEDURE APPROVEROW(P_BILLNO IN VARCHAR2,
                       P_PERSON IN VARCHAR2,
                       P_BILLID IN VARCHAR2,
                       P_DJLB   IN VARCHAR2,
                       P_ROWNO  IN NUMBER);

  --������ˣ�һ��һ��
  PROCEDURE SP_REGISTER(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);
  --��������
    PROCEDURE SP_REGISTER1(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);
  --������ˣ�һ�����
  PROCEDURE SP_REGISTER12(P_TYPE   IN VARCHAR2,
                          P_CRHNO  IN VARCHAR2,
                          P_PER    IN VARCHAR2,
                          P_COMMIT IN VARCHAR2);
  --��ʱ��ˮ����
  PROCEDURE sp_��ʱ��ˮ����(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);

  --���������
  PROCEDURE SP_CUSTCHANGE(P_TYPE   IN VARCHAR2, --��������
                          P_CCHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          );
  --�����������
  PROCEDURE SP_CUSTCHANGEBYROW(P_TYPE   IN VARCHAR2, --��������
                               P_CCHNO  IN VARCHAR2, --������ˮ
                               P_ROWNO  IN NUMBER, --�к�
                               P_PER    IN VARCHAR2, --����Ա
                               P_COMMIT IN VARCHAR2 --�ύ��־
                               );
  --���������˹���
  PROCEDURE SP_CUSTCHANGEONE(P_TYPE IN VARCHAR2, --����
                             P_CD   IN OUT CUSTCHANGEDT%ROWTYPE --�����б��
                             );
  PROCEDURE METERSTATICREFRESH(P_SDATE IN VARCHAR2, P_EDATE IN VARCHAR2);
  --����ˮ����־���ύͳ��
  PROCEDURE METERLOG(P_MSL    IN OUT METER_STATIC_LOG%ROWTYPE,
                     P_COMMIT IN VARCHAR2);
  PROCEDURE SUM$DAY$METER(P_MIID   VARCHAR2,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2);
  PROCEDURE SUM$DAY$METER(P_MI     IN METERINFO%ROWTYPE,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2);
  PROCEDURE INITMETER_STATIC(P_SCRDATE IN DATE, P_DESDATE IN DATE);

PROCEDURE  sp_��ʽ��ˮ����(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
PROCEDURE sp_��ʱ��ˮ����(P_TYPE   IN VARCHAR2,--�������
                      P_billNO  IN VARCHAR2,--���ݱ��
                      P_PER    IN VARCHAR2,--������
                      P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
PROCEDURE sp_��ˮ�������(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
PROCEDURE sp_�ػݻ�����(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;                        
                        
PROCEDURE  sp_Ӫҵ�����(P_TYPE   IN VARCHAR2,--�������
                        P_CCHNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
PROCEDURE  sp_����Ԥ��(P_MICODE IN VARCHAR2, --�ͻ�����
                       P_OPER   IN VARCHAR2, --�տ���
                       P_SAVING IN NUMBER,   --Ԥ��
                       O_PBATCH OUT VARCHAR2)   --�ɷ�����
                        ;
PROCEDURE  sp_����Ԥ��(P_BATCH   IN VARCHAR2,--�ɷ�����
                        P_PID  IN VARCHAR2,--�ɷ���ˮ
                        P_MICODE IN VARCHAR2, --�ͻ�����
                        P_POSITION    IN VARCHAR2,--�ɷѵص�
                        P_OPER IN VARCHAR2,--�ɷ���
                        P_TYPE IN VARCHAR2) --������� 1�����γ���2���ɷ���ˮ����
                        ;
                        
PROCEDURE  sp_��Ǩֹˮ(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_OPER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
                        
PROCEDURE  sp_�쳣��̬����(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
                        
PROCEDURE  sp_��Ź���(P_TYPE   IN VARCHAR2,--�������
                        P_billNO  IN VARCHAR2,--���ݱ��
                        P_PER    IN VARCHAR2,--������
                        P_COMMIT IN VARCHAR2)--�Ƿ��ύ
                        ;
 PROCEDURE SP_Ӫ�������뽨��(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);                       
procedure  SP_CUSTCHANGE_BYMIID(
           P_BILLNO   in varchar2,             --���ݱ��
           p_BILLTYPE  in varchar2,            --���ݱ��
           p_per    in varchar2,             --������
           P_MIID   IN VARCHAR2,             --�ͻ�����
           P_SMFID  IN VARCHAR2,             --Ӫҵ��
           p_commit in varchar2              --�Ƿ��ύ
           );
 PROCEDURE SP_Զ������;   
 
END;
/


CREATE OR REPLACE PACKAGE HRBZLS."PG_METERTRANS" IS

  -- Author  : ����
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;

  /*ˮ��״̬:�ܲ֡��ֹ�˾��������*/
  --1�����ˮ��״̬
  M������   CONSTANT VARCHAR2(2) := '2'; --���ֹ�˾��ˮ������û�а�װ
  M�ݲ�     CONSTANT VARCHAR2(2) := '3'; --���ֹ�˾��Ƿ�Ѳ��������ݲ�
  M�¹�     CONSTANT VARCHAR2(2) := '4'; --���ܲ֡������ֹ�˾���¹����ˮ��
  M����     CONSTANT VARCHAR2(2) := '5'; --���ֹ�˾�����ϴ����Ϊ����
  M����     CONSTANT VARCHAR2(2) := '6'; --���ֹ�˾��ˮ���ͼ���ڴ���״̬
  M����     CONSTANT VARCHAR2(2) := '8'; --���ֹ�˾�����ϲ������û���ͼ죬ˮ��״̬Ϊ����
  M�ܼ쵽�� CONSTANT VARCHAR2(2) := '9'; --���ֹ�˾���ܼ�������û���ͼ죬ˮ��״̬Ϊ�ܼ쵽��
  M�����ϱ� CONSTANT VARCHAR2(2) := '10'; --���ܲ֡������ֹ�˾�������޺���ϱ����û�б��ϣ�����״̬��Ϊ�����ϱ�
  M����     CONSTANT VARCHAR2(2) := '11'; --���ֹ�˾������������û���ͼ죬ˮ��״̬Ϊ����
  MΥ��     CONSTANT VARCHAR2(2) := '12'; --���ֹ�˾��Υ�²���ˮ��״̬ΪΥ��
  M��ͣ     CONSTANT VARCHAR2(2) := '13'; --���ֹ�˾����ͣ�������ڱ�ͣ
  M��ͣ     CONSTANT VARCHAR2(2) := '14'; --���ֹ�˾����ͣ����������ͣ
  M��ʧ     CONSTANT VARCHAR2(2) := '15'; --���ֹ�˾����ʧ�����Ϊ��ʧ
  M�ֳܲ��� CONSTANT VARCHAR2(2) := '17'; --���ܲ֡��ܲ�����ֹ�˾���ܲ�ˮ��Ϊ�ֳܲ���
  M��Ǩ     CONSTANT VARCHAR2(2) := '16'; --���ֹ�˾����Ǩ�������û���ͼ죬Ϊ��Ǩ
  MǷ��ͣˮ CONSTANT VARCHAR2(2) := '21'; --���ܲ֡�Ƿ�����ͣˮ

  --2����װˮ��״̬
  M����       CONSTANT VARCHAR2(2) := '1'; --���ֹ�˾���û�����ʹ��
  M����       CONSTANT VARCHAR2(2) := '7'; --���ֹ�˾�������������û���ͼ죬��������
  M������     CONSTANT VARCHAR2(2) := '19'; --���ֹ�˾����������ɹ�����깤ǰ
  M�ھ������ CONSTANT VARCHAR2(2) := '20'; --���ֹ�˾���ھ�����ɹ����깤ǰ
  MǷ��ͣˮ�� CONSTANT VARCHAR2(2) := '21'; --���ֹ�˾��Ƿ��ͣˮ�ɹ����깤ǰ
  M��ͣ��     CONSTANT VARCHAR2(2) := '13';
  M��װ��     CONSTANT VARCHAR2(2) := '22'; --���ֹ�˾����װ�ɹ����깤ǰ
  MУ����     CONSTANT VARCHAR2(2) := '23'; --���ֹ�˾��У���ɹ����깤ǰ
  M���ϻ����� CONSTANT VARCHAR2(2) := '24'; --���ֹ�˾�����ϻ����ɹ����깤ǰ
  M�ܼ컻���� CONSTANT VARCHAR2(2) := '25'; --���ֹ�˾���ܼ컻���ɹ����깤ǰ
  M������     CONSTANT VARCHAR2(2) := '26'; --���ֹ�˾�������ɹ����깤ǰ
  M������     CONSTANT VARCHAR2(2) := '27'; --���ֹ�˾��ˮ�����Ƹ����ɹ����깤ǰ

  --Ӧ������
  �ƻ�����   CONSTANT CHAR(1) := '1';
  ������׶� CONSTANT CHAR(1) := '5';

  Ӫҵ������ CONSTANT CHAR(1) := 'T';
  ׷��       CONSTANT CHAR(1) := 'O';
  ��Ƿ       CONSTANT CHAR(1) := 'V';

  --�������,�������
  BT������ CONSTANT CHAR(1) := 'R';

  BT�������ϱ�� CONSTANT CHAR(1) := 'B';
  BT������Ϣ��� CONSTANT CHAR(1) := 'C';
  BT����         CONSTANT CHAR(1) := 'D';
  BTˮ�۱��     CONSTANT CHAR(1) := 'E';
  --
  BTˮ������       CONSTANT CHAR(1) := '3';
  BTˮ������       CONSTANT CHAR(1) := '4';
  BT��װ�ܱ�       CONSTANT CHAR(2) := 'NA'; --��װ��
  BT�������       CONSTANT CHAR(1) := 'F';
  BT�ھ����       CONSTANT CHAR(1) := 'G';
  BTǷ��ͣˮ       CONSTANT CHAR(1) := 'H';
  BT�ָ���ˮ       CONSTANT CHAR(1) := '9';
  BT��ͣ           CONSTANT CHAR(1) := '2';
  BT��װ           CONSTANT CHAR(1) := 'I';
  BT������         CONSTANT CHAR(1) := 'P';
  BTУ��           CONSTANT CHAR(1) := 'A';
  BT���ϻ���       CONSTANT CHAR(1) := 'K';
  BT���ڻ���       CONSTANT CHAR(1) := 'L';
  BT���鹤��       CONSTANT CHAR(2) := 'NM';
  BT��װ��������� CONSTANT CHAR(2) := 'NP'; --��װ��
  BT��װ����       CONSTANT CHAR(2) := 'NQ'; --��װ��

  --�������״̬
  δ��   CONSTANT CHAR(1) := 'N';
  ���ɹ� CONSTANT CHAR(1) := 'W';
  ����� CONSTANT CHAR(1) := 'D';
  �ѽ�� CONSTANT CHAR(1) := 'Z';
  �깤   CONSTANT CHAR(1) := 'Y';
  �˵�   CONSTANT CHAR(1) := 'Q';

  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);


  --����������
  PROCEDURE SP_METERTRANS(P_TYPE   IN VARCHAR2, --��������
                          P_MTHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          );
   --����������-���ڻ���
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --��������
                          P_MTHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          );
                                                   
  --����������˹���
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --����
                             P_PERSON IN VARCHAR2, -- ����Ա
                             P_MD     IN METERTRANSDT%ROWTYPE --�����б��
                             );
  --�����ɹ�
  PROCEDURE SP_METEROUT(P_BILLID IN VARCHAR2, --������ˮ
                        P_DEPT   IN VARCHAR2, --�ɹ�����
                        P_OPER   IN VARCHAR2, --����Ա
                        P_MAN    IN VARCHAR2 --ʩ��Ա
                        );
  --��������
  PROCEDURE SP_METERZF(P_BILLID IN VARCHAR2, --������ˮ
                       P_OPER   IN VARCHAR2 --����Ա
                       );
  PROCEDURE SP_METERWAITER(P_BILLID IN VARCHAR2, --������ˮ
                           P_OPER   IN VARCHAR2 --����Ա
                           );
  --�����ѽ��
  PROCEDURE SP_METEROK(P_BILLID IN VARCHAR2, --������ˮ
                       P_OPER   IN VARCHAR2 --����Ա
                       );
  --���봦��                      
   PROCEDURE SP_METERDZ(P_BILLID IN VARCHAR2, --������ˮ
                     P_OPER   IN VARCHAR2, --����Ա
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     );                    
  --����ƻ��������ɹ��ϻ�����
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID   IN VARCHAR2,
                            P_TYPE   IN VARCHAR2,
                            P_SOURCE IN VARCHAR2,
                            P_SMFID  IN VARCHAR2,
                            P_DEPT   IN VARCHAR2,
                            P_OPER   IN VARCHAR2,
                            P_FLAG   IN VARCHAR2);
  --���չ�����������Ƿ�ѹ���
  PROCEDURE SP_CRERECBILL(P_MID    IN VARCHAR2,
                          P_TYPE   IN VARCHAR2,
                          P_SOURCE IN VARCHAR2,
                          P_SMFID  IN VARCHAR2,
                          P_DEPT   IN VARCHAR2,
                          P_OPER   IN VARCHAR2,
                          P_FLAG   IN VARCHAR2);
  --���������ܼ칤��
  PROCEDURE SP_BUILDZJBILL(P_NUM    IN VARCHAR2,
                           P_TYPE   IN VARCHAR2,
                           P_SOURCE IN VARCHAR2,
                           P_SMFID  IN VARCHAR2,
                           P_DEPT   IN VARCHAR2,
                           P_OPER   IN VARCHAR2);
  --���볭���
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        P_CARRYSL    IN NUMBER, --����ˮ��
                        MI        IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT METERREAD.MRID%TYPE --������ˮ
                        );
   --���볭����ʷ��
  PROCEDURE SP_INSERTMRHIS(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        P_CARRYSL    IN NUMBER, --����ˮ��
                        MI        IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT METERREADHIS.MRID%TYPE --������ˮ
                        );
  

END PG_METERTRANS;
/


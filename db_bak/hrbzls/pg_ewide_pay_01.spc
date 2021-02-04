CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PAY_01" IS

  -- Author  : WANGYNG
  -- Created : 2011-10-18
  -- Purpose : �ɷ������

  -- Public type declarations
  TYPE VARCHAR_IDXTAB IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
  -- Public constant declarations

  ȫ��˾ͳһ��׼�����ɽ� VARCHAR2(100); --ȫ��˾ͳһ��׼�����ɽ�(Y),��Ӫҵ����׼�����ɽ�(N)

  V_PROJECT VARCHAR2(10); --��Ŀ���
  --�������
  ERRCODE  CONSTANT INTEGER := -20012;
  NOCUST   CONSTANT INTEGER := -20013;
  NOARREAR CONSTANT INTEGER := -20014;
  NOENOUGH CONSTANT INTEGER := -20015;
  --��������
  PAYTRANS_POS      CONSTANT CHAR(1) := 'P'; --����ˮ��̨�ɷ�
  PAYTRANS_DS       CONSTANT CHAR(1) := 'B'; --����ʵʱ����
  PAYTRANS_DSDE     CONSTANT CHAR(1) := 'E'; --����ʵʱ���յ����ʲ��������ʽ���������շ���
  PAYTRANS_DK       CONSTANT CHAR(1) := 'D'; --��������
  PAYTRANS_TS       CONSTANT CHAR(1) := 'T'; --����Ʊ������
  PAYTRANS_SAV      CONSTANT CHAR(1) := 'S'; --����ˮ��̨����Ԥ��
  PAYTRANS_BANKSAV  CONSTANT CHAR(1) := 'Q'; --����ˮ��̨����Ԥ��
  PAYTRANS_INV      CONSTANT CHAR(1) := 'I'; --����Ʊ������
  PAYTRANS_Ԥ��ֿ� CONSTANT CHAR(1) := 'U'; --��ѹ��̼�ʱԤ��ֿ�

  PAYTRANS_CR     CONSTANT CHAR(1) := 'C'; --��������δ����ҵ����������ʳ������ݷ���
  PAYTRANS_BANKCR CONSTANT CHAR(1) := 'X'; --ʵʱ���ճ��������е��ճ�������
  PAYTRANS_DSCR   CONSTANT CHAR(1) := 'R'; --ʵʱ���յ����ʳ���
  PAYTRANS_ADJ    CONSTANT CHAR(1) := 'V'; --�����˷ѣ��˷Ѵ�������(CR)�����ʲ�������(DE)

  PAYTRANS_����   CONSTANT CHAR(1) := 'F'; --���鷣��
  PAYTRANS_׷��   CONSTANT CHAR(1) := 'Z'; --׷��
  PAYTRANS_Ԥ��   CONSTANT CHAR(1) := 'Y'; --Ԥ��
  PAYTRANS_���   CONSTANT CHAR(1) := 'A'; --���
  PAYTRANS_���̿� CONSTANT CHAR(1) := 'G'; --���̿�
  PAYTRANS_�۲�   CONSTANT CHAR(1) := 'J'; --�۲�
  PAYTRANS_ˮ��   CONSTANT CHAR(1) := 'K'; --ˮ��

  DEBIT  CONSTANT CHAR(2) := 'DE'; --�跽
  CREDIT CONSTANT CHAR(2) := 'CR'; --����

  CTL_PAYPART CONSTANT VARCHAR2(10) := 'FULL'; --����
  CAL_DAYS    CONSTANT INTEGER := 3; --�Ʒѻ����գ��������ɽ�
  --������Ӧ�հ�
  SUBTYPE RL_TYPE IS RECLIST%ROWTYPE;
  TYPE RL_TABLE IS TABLE OF RL_TYPE;

  --�����ò�ѯǷ�ѹ��̣�ͬ��INQ101��
  FUNCTION GETREC(P_MID IN VARCHAR2) RETURN NUMBER;
  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������

  --ȡ���ɽ���ޱ���
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --���ɽ����
                       P_SMFID   IN VARCHAR2, --Ӫҵ��
                       P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
                       ) RETURN NUMBER;
  --ȡ���ɽ��������
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --���ɽ����
                     P_SMFID   IN VARCHAR2, --Ӫҵ��
                     P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
                     ) RETURN NUMBER;
  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --Ӫҵ��
                  P_RLGROUP IN VARCHAR2, --Ӧ�շ��ʺ�
                  P_SDATE   IN DATE, --������'����'ΥԼ��
                  P_EDATE   IN DATE, --������'������'ΥԼ��
                  P_JE      IN NUMBER) --ΥԼ�𱾽�
   RETURN NUMBER;

  --ΥԼ����㣨���ڼ��չ��򣬺��������
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --Ӧ����ˮ
                     P_RLJE     IN NUMBER, --Ӧ�ս��
                     P_RLGROUP  IN NUMBER, --Ӧ�����
                     P_RLZNDATE IN DATE, --���ɽ�������
                     P_SMFID    VARCHAR2, --ˮ��Ӫҵ��
                     P_EDATE    IN DATE --������'������'ΥԼ��
                     ) RETURN NUMBER;

  --����ˮ��̨�ɷ�
  FUNCTION POS(P_TYPE     IN VARCHAR2, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
               P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
               P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
               P_RLJE     IN NUMBER, --Ӧ���ܽ��
               P_ZNJ      IN NUMBER, --����ΥԼ��
               P_SXF      IN NUMBER, --������
               P_PAYJE    IN NUMBER, --ʵ���տ�
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
               P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
               P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
               P_INVNO    IN VARCHAR2, --��Ʊ��
               P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��
               ) RETURN VARCHAR2;
               
  --֧�����ɷ�
  FUNCTION POS_ZFB (
               P_PAYJE    IN NUMBER, --ʵ���տ�
               p_pbseqno  IN VARCHAR2,  --֧������ˮ
               P_MIID     IN VARCHAR2 --ˮ�����Ϻ�
               ) RETURN VARCHAR2;

  --΢�Žɷ�
  FUNCTION POS_WX (
               P_PAYJE    IN NUMBER, --ʵ���տ�
               p_pbseqno  IN VARCHAR2,  --������ˮ
               P_MIID     IN VARCHAR2, --ˮ�����Ϻ�
               P_BZ       IN VARCHAR2, --�ɷ���Դ
               p_pwseqno  IN VARCHAR2,  --΢����ˮ
               p_date     IN VARCHAR2       --��������ʱ��
               ) RETURN VARCHAR2;



  --����ˮ��̨�ɷ�
  FUNCTION POS_test(P_TYPE     IN VARCHAR2, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
               P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
               P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
               P_RLJE     IN NUMBER, --Ӧ���ܽ��
               P_ZNJ      IN NUMBER, --����ΥԼ��
               P_SXF      IN NUMBER, --������
               P_PAYJE    IN NUMBER, --ʵ���տ�
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
               P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
               P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
               P_INVNO    IN VARCHAR2, --��Ʊ��
               P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��
               ) RETURN VARCHAR2;
  --ʵ�ճ����� �ɷ���ˮ PAYMENT.pid
  PROCEDURE SP_PAIDBAK(P_PID      IN PAYMENT.PID%TYPE, --ʵ����ˮ
                       P_POSITION IN VARCHAR2, --������λ�ص�
                       P_OPER     IN VARCHAR2, --��������Ա
                       P_PAYEE    IN VARCHAR2, --��������Ա
                       P_TRANS    IN VARCHAR2, --��������
                       P_MEMO     IN VARCHAR2, --������ע
                       P_IFFP     IN VARCHAR2, --�Ƿ��Ʊ
                       P_INVNO    IN VARCHAR2, --Ʊ��
                       P_CRPBATCH IN VARCHAR2, --����������ˮ
                       P_COMMIT   IN VARCHAR2 --�ύ��־
                       );
  --ʵ�ճ����� �ɷ����� PAYMENT.PBATCH
  PROCEDURE SP_PAIDBAK_BYPBATCH(P_PBATCH   IN PAYMENT.PBATCH%TYPE, --ʵ����ˮ
                                P_POSITION IN VARCHAR2, --������λ�ص�
                                P_OPER     IN VARCHAR2, --��������Ա
                                P_PAYEE    IN VARCHAR2, --��������Ա
                                P_TRANS    IN VARCHAR2, --��������
                                P_MEMO     IN VARCHAR2, --������ע
                                P_IFFP     IN VARCHAR2, --�Ƿ��Ʊ
                                P_INVNO    IN VARCHAR2, --Ʊ��
                                P_CRPBATCH IN VARCHAR2, --����������ˮ
                                P_COMMIT   IN VARCHAR2 --�ύ��־
                                );
  /*******************************************************************************************
  ��������F_PAYBACK_BATCH
  ��;��ʵ�ճ���,�����γ���
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                              P_POSITION IN PAYMENT.PPOSITION%TYPE,
                              P_OPER     IN PAYMENT.PPER%TYPE,
                              P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                              P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2;
    
    -------------֧�����˷�-------------------------------------------
    FUNCTION REVERSE_ZFB(P_BATCH    IN PAYMENT.PBATCH%TYPE)
    RETURN VARCHAR2;
            -------------΢���˷�-------------------------------------------
    FUNCTION REVERSE_WX(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                        P_BZ       IN VARCHAR2)
    RETURN VARCHAR2;
  --Ԥ��ۿ�
--Ԥ��ۿ�(Ԥ��ֿۣ�����������)

--��̨���ձ��Ԥ������

END;
/


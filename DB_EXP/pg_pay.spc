CREATE OR REPLACE PACKAGE PG_PAY IS
  -- Public type declarations
  SUBTYPE RD_TYPE IS YS_ZW_ARDETAIL%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --�洢��ʱ����
  SUBTYPE PB_TYPE IS YSPARMTEMP%ROWTYPE;
  TYPE ARR_TABLE IS TABLE OF PB_TYPE;
  --
  -- Public constant declarations
  --���󷵻���
  ERRCODE CONSTANT INTEGER := -20012;

  --�����������������ת��Ϊ��ϵͳ������ʼ����
  --��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ----�����ύ����
  ���ύ CONSTANT NUMBER := 0;
  �ύ   CONSTANT NUMBER := 1;
  ����   CONSTANT NUMBER := 2;
  ----�ɺ��Ե�Ӧʵ�ռ��ʷ���������+/-ֵ�������
  �跽 CONSTANT CHAR(2) := 'DE';
  ���� CONSTANT CHAR(2) := 'CR';
  --���ɷ�ҵ����Ĺ���
  --  ȫ����Ҫ���������������������Ԥ�淢��
  --  ���磺��Ԥ��ҵ�����Ŀ������λ��Ϊfalse
  --  �����ڣ�PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  ����Ԥ�淢�� CONSTANT BOOLEAN := TRUE;

  --  ȫ����Ҫ����������������������ڳ������Ǹ�Ԥ�桢���ʺ�Ҳ�����Ǹ�Ԥ�棬�����ܷ�������ĸ�Ԥ��
  --  trueʱ��ζ�����������ʳɹ����������޵��ߵ�ת��Ԥ�����
  --  ���磺ĳЩ��Ŀ��������ȡ������Ĺ���ʱ�˿���λΪtrue��ȡ�������ڵ���ǰ����ok�����غ�̨��У��
  --  �����ڣ�PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  ��������Ԥ�� CONSTANT BOOLEAN := TRUE;

  ----����Ϊ��Ԥ�����ʱ������תԤ��
  --  �����ڣ�PayRecCore
  ����Ϊ��Ԥ�治���� CONSTANT BOOLEAN := FALSE;
  ���ۺ��Ƿ��Ͷ��� CONSTANT BOOLEAN := FALSE;

  --  ������ҵ��ʽ��������ֿ۵�ǰǷ��ʱ�����Ƿ�ֿۺ�ΥԼ��Ƿ�Ѽ�¼
  --  �����ڣ�pg_pay.ReMainPayCoreByCust
  ����Ԥ��ֿ�ΥԼǷ�� CONSTANT INTEGER := 1;

  �����ظ����� CONSTANT INTEGER := 1;

  ----ʵʱ���յ���Ԥ�����
  --  �����ڣ�BPay
  ����ʵʱ���յ���Ԥ�� CONSTANT BOOLEAN := FALSE; --20140812 0:30 true->flase

  --��һЩ��ѡ�����ʷ�ʽ��
  ----�������ʲ���
  ��������� CONSTANT INTEGER := 0; --0����0ˮ������
  �������   CONSTANT INTEGER := 1; --Ĭ��
  ----���ն��ʷ���
  �������� CONSTANT INTEGER := 1; --�Զ�������ʱ�ɴ��˲������������Ѷ��ʼ�¼������ƽ�ʣ������ʧ�ܣ�
  ���¶��� CONSTANT INTEGER := 2; --�ֹ�ҵ�����ʱ���˲������������Ѷ��ʼ�¼������ƽ�ʣ���ԭƽ�ʣ����ʳ������ж��ʲ��������ʲ������ж��ʳ�����������״ζ��ʣ�
  ----���۱��ش���ʽ
  �������۴��� CONSTANT INTEGER := 1; --�Զ�������ʱ�ɴ��˲��������������˼�¼�������ʣ����������;����־ȫ��������
  �������۴��� CONSTANT INTEGER := 2; --�ֹ�ҵ�����ʱ���˲����������������ʼ�¼����ԭ���ʣ��������ʽ��д��۳������������������
  ----������;����
  ����δ���� CONSTANT INTEGER := 0; --�����ĵ������л�δ�����۷�
  ���۽���   CONSTANT INTEGER := 1; --�ѽ���
  ----�����ı�����
  �ɹ������ı�   CONSTANT INTEGER := 0; --ֻ��ʧ�ܼ�¼
  ʧ�������ı�   CONSTANT INTEGER := 1; --ֻ�гɹ���¼
  ȫ�������ı�   CONSTANT INTEGER := 2; --���м�¼
  ���ı�ȫ���ɹ� CONSTANT INTEGER := 3; --���ı����أ����п�ͷ֪ͨ�������۳ɹ�
  ----�ּ�Ԥ���������
  �ּ�Ԥ��������� CONSTANT INTEGER := 1; --���۷���ʱԤ�����������Ӧ�ɣ�etlje = etlrlje +etlwyj +etlremaind
  NO�ּ�Ԥ�������� CONSTANT INTEGER := 0; --���۷���ʱԤ�����������Ӧ�ɣ�etlje = etlrlje +etlwyj
  ----�ɷ�֪ͨ
  ȫ������֪ͨ CONSTANT BOOLEAN := FALSE;
  �ֲ�����֪ͨ CONSTANT INTEGER := 0; --�����������ⲿ���Σ���ʹ��ͨ��int���ͣ�
  �ֲ�����֪ͨ CONSTANT INTEGER := 1; --�����������ⲿ���Σ���ʹ��ͨ��int���ͣ�
  ----����ΥԼ����ʣ���ͨ�������������ʺ��Ĺ����ж�ΥԼ��ͱ�����ʴ���������������
  ----����ΥԼ��Ʊ����
  ��������ΥԼ����� CONSTANT BOOLEAN := TRUE; --
  --������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  --��������
  PTRANS_��̨�ɷ� CONSTANT CHAR(1) := 'P'; --����ˮ��̨�ɷ�
  PTRANS_�������� CONSTANT CHAR(1) := 'B'; --����ʵʱ����
  PTRANS_���ղ��� CONSTANT CHAR(1) := 'E'; --����ʵʱ���յ����ʲ��������ʽ������,���շ���
  PTRANS_�������� CONSTANT CHAR(1) := 'D'; --��������
  PTRANS_�������� CONSTANT CHAR(1) := 'T'; --����Ʊ������
  PTRANS_����Ԥ�� CONSTANT CHAR(1) := 'S'; --����ˮ��̨����Ԥ��
  PTRANS_Ʊ������ CONSTANT CHAR(1) := 'I'; --����Ʊ������
  PTRANS_Ԥ��ֿ� CONSTANT CHAR(1) := 'U'; --��ѹ��̼�ʱԤ��ֿ�
  PTRANS_Ԥ����� CONSTANT CHAR(1) := 'K'; --���ձ���ʱ�ӱ�Ԥ�����ת������Ԥ�������

  PTRANS_����       CONSTANT CHAR(1) := 'C'; --����
  PTRANS_�˷�       CONSTANT CHAR(1) := 'V'; --�˷�
  PTRANS_���ճ���   CONSTANT CHAR(1) := 'R'; --ʵʱ���յ����ʳ���
  PTRANS_Ԥ��       CONSTANT CHAR(1) := 'Q'; --Ԥ��ˮ
  PTRANS_���������� CONSTANT CHAR(1) := 'W'; --����������
  --
  FUNCTION OBTWYJ(P_SDATE IN DATE, P_EDATE IN DATE, P_JE IN NUMBER)
    RETURN NUMBER;
  --
  function ObtWyjAdj(p_arid     in varchar2, --Ӧ����ˮ
                     p_ardpiids in varchar2, --Ӧ����ϸ���'01|02|03'
                     p_edate    in date --������'������'ΥԼ��,������ʽ'yyyy-mm-dd'
                     ) return number;
  --
  PROCEDURE POSCUSTFORYS(P_SBID     IN VARCHAR2,
                         P_ARSTR    IN VARCHAR2,
                         P_POSITION IN VARCHAR2,
                         P_OPER     IN VARCHAR2,
                         P_PAYPOINT IN VARCHAR2,
                         P_PAYWAY   IN VARCHAR2,
                         P_PAYMENT  IN NUMBER,
                         P_BATCH    IN VARCHAR2,
                         P_PID      OUT VARCHAR2);
  --
  PROCEDURE POSCUST(P_SBID     IN VARCHAR2,
                    P_PARM_ARS IN PARM_PAYAR_TAB,
                    P_POSITION IN VARCHAR2,
                    P_OPER     IN VARCHAR2,
                    P_PAYPOINT IN VARCHAR2,
                    P_PAYWAY   IN VARCHAR2,
                    P_PAYMENT  IN NUMBER,
                    P_BATCH    IN VARCHAR2,
                    P_PID      OUT VARCHAR2);
  --
  PROCEDURE PAYCUST(P_SBID        IN VARCHAR2,
                    P_PARM_ARS    IN PARM_PAYAR_TAB,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_PID_SOURCE  IN VARCHAR2,
                    P_COMMIT      IN NUMBER,
                    P_CTL_MSG     IN NUMBER,
                    P_CTL_PRE     IN NUMBER,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    P_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PAYZWARPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                       P_COMMIT   IN NUMBER DEFAULT ���ύ);
  --
  PROCEDURE ZWARREVERSECORE(P_ARID_SOURCE         IN VARCHAR2,
                            P_ARTRANS_REVERSE     IN VARCHAR2,
                            P_PBATCH_REVERSE      IN VARCHAR2,
                            P_PID_REVERSE         IN VARCHAR2,
                            P_PPAYMENT_REVERSE    IN NUMBER,
                            P_MEMO                IN VARCHAR2,
                            P_CTL_MIRCODE         IN VARCHAR2,
                            P_COMMIT              IN NUMBER DEFAULT ���ύ,
                            O_ARID_REVERSE        OUT VARCHAR2,
                            O_ARTRANS_REVERSE     OUT VARCHAR2,
                            O_ARJE_REVERSE        OUT NUMBER,
                            O_ARZNJ_REVERSE       OUT NUMBER,
                            O_ARSXF_REVERSE       OUT NUMBER,
                            O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                            IO_ARSAVINGQM_REVERSE IN OUT NUMBER);
  --
  PROCEDURE PAYWYJPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                      P_COMMIT   IN NUMBER DEFAULT ���ύ);
  --
  PROCEDURE PAYZWARCORE(P_PID          IN VARCHAR2,
                        P_BATCH        IN VARCHAR2,
                        P_PAYMENT      IN NUMBER,
                        P_REMAINBEFORE IN NUMBER,
                        P_PAIDDATE     IN DATE,
                        P_PAIDMONTH    IN VARCHAR2,
                        P_PARM_ARS     IN PARM_PAYAR_TAB,
                        P_COMMIT       IN NUMBER DEFAULT ���ύ,
                        O_SUM_ARJE     OUT NUMBER,
                        O_SUM_ARZNJ    OUT NUMBER,
                        O_SUM_ARSXF    OUT NUMBER);
  --                    
  PROCEDURE PRECUST(P_SBID        IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PRECUSTBACK(P_SBID        IN VARCHAR2,
                        P_POSITION    IN VARCHAR2,
                        P_OPER        IN VARCHAR2,
                        P_PAYWAY      IN VARCHAR2,
                        P_PAYMENT     IN NUMBER,
                        P_MEMO        IN VARCHAR2,
                        P_BATCH       IN OUT VARCHAR2,
                        O_PID         OUT VARCHAR2,
                        O_REMAINAFTER OUT NUMBER);
  --
  PROCEDURE PRECORE(P_SBID        IN VARCHAR2,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_COMMIT      IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER);
  --
  FUNCTION FMID(P_STR IN VARCHAR2, P_SEP IN VARCHAR2) RETURN INTEGER;
END PG_PAY;
/


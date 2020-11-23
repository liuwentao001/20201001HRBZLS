CREATE OR REPLACE PACKAGE Pg_Paid_01bak IS
  -- Public type declarations
  SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
  TYPE Rd_Table IS TABLE OF Rd_Type;
  --�洢��ʱ����
  SUBTYPE Pb_Type IS Ysparmtemp%ROWTYPE;
  TYPE Arr_Table IS TABLE OF Pb_Type;
  --
  -- Public constant declarations
  --���󷵻���
  Errcode CONSTANT INTEGER := -20012;

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
  No�ּ�Ԥ�������� CONSTANT INTEGER := 0; --���۷���ʱԤ�����������Ӧ�ɣ�etlje = etlrlje +etlwyj
  ----�ɷ�֪ͨ
  ȫ������֪ͨ CONSTANT BOOLEAN := FALSE;
  �ֲ�����֪ͨ CONSTANT INTEGER := 0; --�����������ⲿ���Σ���ʹ��ͨ��int���ͣ�
  �ֲ�����֪ͨ CONSTANT INTEGER := 1; --�����������ⲿ���Σ���ʹ��ͨ��int���ͣ�
  ----����ΥԼ����ʣ���ͨ�������������ʺ��Ĺ����ж�ΥԼ��ͱ�����ʴ���������������
  ----����ΥԼ��Ʊ����
  ��������ΥԼ����� CONSTANT BOOLEAN := TRUE; --
  --������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  --��������
  Ptrans_��̨�ɷ� CONSTANT CHAR(1) := 'P'; --����ˮ��̨�ɷ�
  Ptrans_�������� CONSTANT CHAR(1) := 'B'; --����ʵʱ����
  Ptrans_���ղ��� CONSTANT CHAR(1) := 'E'; --����ʵʱ���յ����ʲ��������ʽ������,���շ���
  Ptrans_�������� CONSTANT CHAR(1) := 'D'; --��������
  Ptrans_�������� CONSTANT CHAR(1) := 'T'; --����Ʊ������
  Ptrans_����Ԥ�� CONSTANT CHAR(1) := 'S'; --����ˮ��̨����Ԥ��
  Ptrans_Ʊ������ CONSTANT CHAR(1) := 'I'; --����Ʊ������
  Ptrans_Ԥ��ֿ� CONSTANT CHAR(1) := 'U'; --��ѹ��̼�ʱԤ��ֿ�
  Ptrans_Ԥ����� CONSTANT CHAR(1) := 'K'; --���ձ���ʱ�ӱ�Ԥ�����ת������Ԥ�������

  Ptrans_����       CONSTANT CHAR(1) := 'C'; --����
  Ptrans_�˷�       CONSTANT CHAR(1) := 'V'; --�˷�
  Ptrans_���ճ���   CONSTANT CHAR(1) := 'R'; --ʵʱ���յ����ʳ���
  Ptrans_Ԥ��       CONSTANT CHAR(1) := 'Q'; --Ԥ��ˮ
  Ptrans_���������� CONSTANT CHAR(1) := 'W'; --����������
  --
  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER;
  --
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --Ӧ����ˮ
                     p_Ardpiids IN VARCHAR2, --Ӧ����ϸ���'01|02|03'
                     p_Edate    IN DATE --������'������'ΥԼ��,������ʽ'yyyy-mm-dd'
                     ) RETURN NUMBER;
  --
  PROCEDURE Poscustforys(p_Sbid     IN VARCHAR2,
                         p_Arstr    IN VARCHAR2,
                         p_Position IN VARCHAR2,
                         p_Oper     IN VARCHAR2,
                         p_Paypoint IN VARCHAR2,
                         p_Payway   IN VARCHAR2,
                         p_Payment  IN NUMBER,
                         p_Batch    IN VARCHAR2,
                         p_Pid      OUT VARCHAR2);
  --
  PROCEDURE Poscust(p_Sbid     IN VARCHAR2,
                    p_Parm_Ars IN Parm_Payar_Tab,
                    p_Position IN VARCHAR2,
                    p_Oper     IN VARCHAR2,
                    p_Paypoint IN VARCHAR2,
                    p_Payway   IN VARCHAR2,
                    p_Payment  IN NUMBER,
                    p_Batch    IN VARCHAR2,
                    p_Pid      OUT VARCHAR2);
  --
  PROCEDURE Paycust(p_Sbid        IN VARCHAR2,
                    p_Parm_Ars    IN Parm_Payar_Tab,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Pid_Source  IN VARCHAR2,
                    p_Commit      IN NUMBER,
                    p_Ctl_Msg     IN NUMBER,
                    p_Ctl_Pre     IN NUMBER,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    p_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  PROCEDURE Payzwarpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                       p_Commit   IN NUMBER DEFAULT ���ύ);
  --
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT ���ύ,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER);
  --
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT ���ύ);
  --
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT ���ύ,
                        o_Sum_Arje     OUT NUMBER,
                        o_Sum_Arznj    OUT NUMBER,
                        o_Sum_Arsxf    OUT NUMBER);
  --                    
  PROCEDURE Precust(p_Sbid        IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  PROCEDURE Precustback(p_Sbid        IN VARCHAR2,
                        p_Position    IN VARCHAR2,
                        p_Oper        IN VARCHAR2,
                        p_Payway      IN VARCHAR2,
                        p_Payment     IN NUMBER,
                        p_Memo        IN VARCHAR2,
                        p_Batch       IN OUT VARCHAR2,
                        o_Pid         OUT VARCHAR2,
                        o_Remainafter OUT NUMBER);
  --
  PROCEDURE Precore(p_Sbid        IN VARCHAR2,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Commit      IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER);
  --
  FUNCTION Fmid(p_Str IN VARCHAR2, p_Sep IN VARCHAR2) RETURN INTEGER;

  --1��ʵ�ճ��������¸�ʵ�գ�
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER);
 -- Ӧ��׷�ʺ���
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT ���ύ,
                          o_Rlid            OUT VARCHAR2);
  --Ӧ��׷��
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT ���ύ,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER);
  
  --ʵ�ճ����κ���
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2);
   --ˮ˾��̨����(���˿�)   
   procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default ���ύ,
                       p_pid_reverse out varchar2);                                                                           
  /*******************************************************************************************
  ��������F_PAYBACK_BY_PMID
  ��;��ʵ�ճ���,��ʵ����ˮid����
  ������
  ҵ�����
  
  ����ֵ��
  *******************************************************************************************/
/*  FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN YS_ZW_PAIDMENT.PID%TYPE,
                             P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                             P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                             P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                             P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                             P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE,
                             P_COMMIT   IN VARCHAR2) 
                   RETURN VARCHAR2;*/

/* \*******************************************************************************************
  ��������F_PAYBACK_BATCH
  ��;��ʵ�ճ���,�����γ���
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************\
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                              P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                              P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                              P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                              P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE)
    RETURN VARCHAR2;
    */
END;
/


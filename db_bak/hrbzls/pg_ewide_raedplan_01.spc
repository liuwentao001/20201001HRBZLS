CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RAEDPLAN_01" IS

  -- Author  : ADMIN
  -- Created : 2004-4-12 20:49:17
  -- Purpose : �³�����

  --�������

  ERRCODE CONSTANT INTEGER := -20012;

  NO_DATA_FOUND EXCEPTION;
  PROCEDURE CREATEMR(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
  
	--���ɳ���ƻ�-byj �޸İ� 
	--�³�ʱ��Ӫҵ��ѭ�� ���ݱ��Ϊ ��ֵ                  
   PROCEDURE CREATEMR2(P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2);		
	
   PROCEDURE CREATEMRBYMIID(P_CICODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
   PROCEDURE CREATEMR�Ⳮ��(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2);
  /*
  ������ҳ���ύ����
  ������p_mtab�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_smfid: Ŀ��Ӫҵ��
        p_bfid:  Ŀ����
        p_oper�� ����ԱID
  ����1�����³������
        2�����±��
        3�����ţ���ҳ�ţ���ʼ��
        4������ϵͳ��������γ���ʷ�������
  �������
  */
  PROCEDURE METERBOOK(P_SMFID IN VARCHAR2,
                      P_BFID  IN VARCHAR2,
                      P_OPER  IN VARCHAR2);
  --ɾ������ƻ�
  PROCEDURE DELETEPLAN(P_TYPE    IN VARCHAR2,
                       P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2);
                       
  --����ȡ������ƻ�
  PROCEDURE DELETEPLANONE(p_mrmid    IN VARCHAR2,  --ˮ����
                          P_BFID     IN VARCHAR2,  --����
                          P_MRID     IN VARCHAR2,   --������ˮ��
                          on_appcode out number,
                          oc_error   out varchar2
  );
  
  --�����½�
  PROCEDURE CARRYFORPAY_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);
  -- �����½�
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2009-04-04  by wy
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);
  -- �ֹ������½ᴦ��
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2010-08-20  by yf
  PROCEDURE CARRYFPAY_MR(P_SMFID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2);
  --���µ�������ƻ�
  PROCEDURE SP_UPDATEMRONE(P_TYPE   IN VARCHAR2, --�������� :01 ��������
                           P_MRID   IN VARCHAR2, --������ˮ��
                           P_COMMIT IN VARCHAR2 --�Ƿ��ύ
                           );

  --��δ������
  PROCEDURE SP_GETADDINGSL(P_MIID      IN VARCHAR2, --ˮ���
                           O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                           O_MASSCODEN OUT NUMBER, --�±����
                           O_MASSL     OUT NUMBER, --����
                           O_ADDDATE   OUT DATE, --��������
                           O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                           O_STR       OUT VARCHAR2 --����ֵ
                           );

  --����������
  PROCEDURE SP_GETADDEDSL(P_MRID      IN VARCHAR2, --������ˮ
                          O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                          O_MASSCODEN OUT NUMBER, --�±����
                          O_MASSL     OUT NUMBER, --����
                          O_ADDDATE   OUT DATE, --��������
                          O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                          O_STR       OUT VARCHAR2 --����ֵ
                          );
  --ȡ����
  PROCEDURE SP_FETCHADDINGSL(P_MRID      IN VARCHAR2, --������ˮ
                             P_MIID      IN VARCHAR2, --ˮ���
                             O_MASECODEN OUT NUMBER, --�ɱ�ֹ��
                             O_MASSCODEN OUT NUMBER, --�±����
                             O_MASSL     OUT NUMBER, --����
                             O_ADDDATE   OUT DATE, --��������
                             O_MASTRANS  OUT VARCHAR2, --�ӵ�����
                             O_STR       OUT VARCHAR2 --����ֵ
                             );

  --������
  PROCEDURE SP_ROLLBACKADDEDSL(P_MRID IN VARCHAR2, --������ˮ
                               O_STR  OUT VARCHAR2 --����ֵ
                               );

  --�����Ⱦ�������12����ʷˮ��������������ˮ��
  PROCEDURE UPDATEMRSLHIS(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2);

  PROCEDURE UPDATEMRSLHIS_CK(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2);
  --���˼��
  --���˼��
  PROCEDURE SP_MRSLCHECK(P_SMFID     IN VARCHAR2,
                         P_MRMID     IN VARCHAR2,
                         P_MRSCODE   IN VARCHAR2,
                         P_MRECODE   IN NUMBER,
                         P_MRSL      IN NUMBER,
                         P_MRADDSL   IN NUMBER,
                         P_MRRDATE   IN DATE,
                         O_ERRFLAG   OUT VARCHAR2,
                         O_IFMSG     OUT VARCHAR2,
                         O_MSG       OUT VARCHAR2,
                         O_EXAMINE   OUT VARCHAR2,
                         O_SUBCOMMIT OUT VARCHAR2);
  --��¼���¾���
  FUNCTION FGETMRSLMONAVG(P_MIID    IN VARCHAR2,
                          P_MRSL    IN NUMBER,
                          P_MRRDATE IN DATE) RETURN NUMBER;
  --ȡ����ƽ��
  FUNCTION FGETTHREEMONAVG(P_MIID IN VARCHAR2) RETURN NUMBER;

  --������
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --������ˮ
                           P_MASID IN NUMBER, --������ˮ
                           O_STR   OUT VARCHAR2 --����ֵ
                           );
  --������
  PROCEDURE SP_RETADDINGSL(P_MASMRID IN VARCHAR2, --������ˮ
                           O_STR     OUT VARCHAR2 --����ֵ
                           );
  --�������μ��
  FUNCTION FCHECKMRBATCH(P_MRID IN VARCHAR2, P_SMFID IN VARCHAR2)
    RETURN VARCHAR2;
  --������Ȩ
  PROCEDURE SP_MRPRIVILEGE(P_MRID IN VARCHAR2,
                           P_OPER IN VARCHAR2,
                           P_MEMO IN VARCHAR2,
                           O_STR  OUT VARCHAR2);
  --��ѯ������Ƿ���ȫ��¼��ˮ��
  FUNCTION FCKKBFIDALLIMPUTSL(P_SMFID IN VARCHAR2,
                              P_BFID  IN VARCHAR2,
                              P_MON   IN VARCHAR2) RETURN VARCHAR2;
  --��ѯ������Ƿ������
  FUNCTION FCKKBFIDALLSUBMIT(P_SMFID IN VARCHAR2,
                             P_BFID  IN VARCHAR2,
                             P_MON   IN VARCHAR2) RETURN VARCHAR2;
  --�������
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID IN VARCHAR2,
                            P_OPER IN VARCHAR2,
                            P_MEMO IN VARCHAR2,
                            P_FLAG IN VARCHAR2);

  PROCEDURE SP_MRSLERRCHK(P_MRID            IN VARCHAR2, --������ˮ��
                          P_MRCHKPER        IN VARCHAR2, --������Ա
                          P_MRCHKSCODE      IN NUMBER, --ԭ����
                          P_MRCHKECODE      IN NUMBER, --ԭֹ��
                          P_MRCHKSL         IN NUMBER, --ԭˮ��
                          P_MRCHKADDSL      IN NUMBER, --ԭ����
                          P_MRCHKCARRYSL    IN NUMBER, --ԭ��λˮ��
                          P_MRCHKRDATE      IN DATE, --ԭ��������
                          P_MRCHKFACE       IN VARCHAR2, --ԭ���
                          P_MRCHKRESULT     IN VARCHAR2, --���������
                          P_MRCHKRESULTMEMO IN VARCHAR2, --�����˵��
                          O_STR             OUT VARCHAR2 --����ֵ
                          );

  -- �������������
  --p_cont ���ɳ������������
  --p_commit �ύ��־
  --time 2010-03-14  by wy
  PROCEDURE SP_POSHANDCREATE(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2);

  -- �����������ȡ��

  --p_commit �ύ��־
  --time 2010-06-21  by wy
  PROCEDURE SP_POSHANDCANCEL(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2);

  -- ���������ȡ��
  --p_batch �������������
  --p_commit �ύ��־
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDDEL(P_BATCH IN VARCHAR2, P_COMMIT IN VARCHAR2);
  -- ��������
  --p_type �����������
  --p_batch �������������
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDCHK(P_TYPE IN VARCHAR2, P_BATCH IN VARCHAR2);

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
PROCEDURE SP_POSHANDIMP_HRB(P_OPER IN VARCHAR2, --����Ա
                            P_SMFID IN VARCHAR2, --Ӫҵ��
                          P_TYPE IN VARCHAR2, --���뷽ʽ
                          O_MSG OUT VARCHAR2  --���ظ�����Ϣ
                          );
  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP(P_OPER IN VARCHAR2, --����Ա
                          P_TYPE IN VARCHAR2 --���뷽ʽ
                          );
  PROCEDURE SP_POSHANDIMP1(P_OPER IN VARCHAR2, --����Ա
                           P_TYPE IN VARCHAR2 --���뷽ʽ
                           );
  PROCEDURE SP_POSHANDIMP_YCB(P_OPER  IN VARCHAR2, --����Ա
                              P_TYPE  IN VARCHAR2, --���뷽ʽ
                              P_BFID  OUT VARCHAR2,
                              P_BFID1 OUT VARCHAR2);
  PROCEDURE GETMRHIS(P_MIID   IN VARCHAR2,
                     P_MONTH  IN VARCHAR2,
                     O_SL_1   OUT NUMBER,
                     O_JE01_1 OUT NUMBER,
                     O_JE02_1 OUT NUMBER,
                     O_JE03_1 OUT NUMBER,
                     O_SL_2   OUT NUMBER,
                     O_JE01_2 OUT NUMBER,
                     O_JE02_2 OUT NUMBER,
                     O_JE03_2 OUT NUMBER,
                     O_SL_3   OUT NUMBER,
                     O_JE01_3 OUT NUMBER,
                     O_JE02_3 OUT NUMBER,
                     O_JE03_3 OUT NUMBER,
                     O_SL_4   OUT NUMBER,
                     O_JE01_4 OUT NUMBER,
                     O_JE02_4 OUT NUMBER,
                     O_JE03_4 OUT NUMBER);
  PROCEDURE SP_GETNOREAD(VMID   IN VARCHAR2,
                         VCONT  OUT NUMBER,
                         VTOTAL OUT NUMBER);

  PROCEDURE SP_POSHANDIMP_TP800(P_OPER IN VARCHAR2, --����Ա
                                P_TYPE IN VARCHAR2 --���뷽ʽ
                                );
  PROCEDURE SP_POSHANDCREATE_TP900(P_SMFID   IN VARCHAR2,
                                   P_MONTH   IN VARCHAR2,
                                   P_BFIDSTR IN VARCHAR2,
                                   P_OPER    IN VARCHAR2,
                                   P_COMMIT  IN VARCHAR2);
  FUNCTION FBDSL(P_MRID IN VARCHAR2) RETURN VARCHAR2;
  function fgetavgmonthsl(P_MIID   IN VARCHAR2,
                                   P_READDATE1   IN DATE,
                                   P_READDATE2 IN DATE) RETURN NUMBER;
  
  --����ˮ������(���ξ�����ȥ��ͬ�ڣ��ϴ�)                               
  FUNCTION FGETBDMONTHSL(P_MIID   IN VARCHAR2,
                                   P_READDATE   IN DATE,
                                   P_TYPE IN VARCHAR2) RETURN NUMBER;
                                                                    
  --���˼��(������)
   PROCEDURE SP_MRSLCHECK_HRB(
                         P_MRMID     IN VARCHAR2,
                         P_MRSL      IN NUMBER,
                         O_SUBCOMMIT OUT VARCHAR2);
												 
   TYPE HISAVGDATA IS RECORD( mrmid   varchar2(20),
                             mrsl    number,
                             je01    number,
                             je02    number,
                             je03    number
  );
  TYPE TAB_HISAVGDATA IS TABLE OF HISAVGDATA;												 
  
END;
/


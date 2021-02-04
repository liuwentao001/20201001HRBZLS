CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_METERREAD_01_2013" IS

  -- Author  : ����
  -- Created : 2011-10-16
  -- Purpose :

  --Ӧ����ϸ��
  SUBTYPE RD_TYPE IS RECDETAIL%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --Ӧ����ʱ������ϸ��
  SUBTYPE RDT_TYPE IS RECDETAILTEMP%ROWTYPE;
  TYPE RDT_TABLE IS TABLE OF RDT_TYPE;
  --�Ż���ϸ��
  SUBTYPE PAL_TYPE IS PRICEADJUSTLIST%ROWTYPE;
  TYPE PAL_TABLE IS TABLE OF PAL_TYPE;
  -- Public constant declarations

  --���˷���
  DEBIT  CONSTANT CHAR(2) := 'DE'; --�跽
  CREDIT CONSTANT CHAR(2) := 'CR'; --����

  --�������
  ERRCODE CONSTANT INTEGER := -20012;

  --���������麯��
  FUNCTION DEBUG(P_ARRSTR IN VARCHAR2) RETURN ARR;
  --д�����־
  PROCEDURE WLOG(P_TXT IN VARCHAR2);
  PROCEDURE AUTOSUBMIT;
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB);
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB);
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE); --�ƻ������
  -- ����ˮ������ѣ��ṩ�ⲿ����
  --procedure Calculate(mr in out meterread%rowtype, p_trans in char);
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --�����·�
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);

  -- ������ϸ���㲽��
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_��ĵ�����     IN NUMBER,
                    P_��ѵĵ�����   IN NUMBER,
                    P_�����Ŀ������ IN NUMBER,
                    P_��ϱ������   IN NUMBER,
                    P_NY             IN VARCHAR2);
  --ˮ����������   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_������           IN OUT NUMBER,
                       P_����ˮ��ֵ       IN OUT NUMBER,
                       P_����             IN VARCHAR2,
                       P_�������ۼ������ IN VARCHAR2);
function  f_GETpfid(PALTAB   IN  PAL_TABLE )   return PAL_TABLE;


  --����ˮ��+������Ŀ����   BY WY 20130531
function  f_GETpfid_piid(PALTAB   IN  PAL_TABLE ,p_piid in varchar2 )
  return PAL_TABLE    ;
--ˮ�۵�������   BY WY 20130531
 --procedure sp_GETJMpfid(PALTAB   IN  PAL_TABLE,o_pdj  out  PAL_TABLE) ;
  --���ݼƷѲ���
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);

  PROCEDURE INSRD(RD IN RD_TABLE);
  PROCEDURE SP_RLSAVING(MI      IN METERINFO%ROWTYPE,
                        RL      IN RECLIST%ROWTYPE,
                        P_BATCH VARCHAR2);
  --�������� by lgb 20120514
  PROCEDURE ��������(P_BFID IN VARCHAR2);
  --׷������������ϸ by lgb 20120526
  PROCEDURE INSRD01(RD IN RD_TABLE);
END;
/


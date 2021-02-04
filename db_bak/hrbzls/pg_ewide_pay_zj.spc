CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PAY_ZJ" is
  /*************************************************************************************
    -- Author  : ֣�˻�
    -- Created : 2012-02-03
    -- Purpose : �ɷ������
  *************************************************************************************/
  -- ȫ������˵��
  type varchar_idxtab is table of VARCHAR2(500) index by binary_integer;
  -- type pay_para
  -- ȫ�ֳ���˵��
  ȫ��˾ͳһ��׼�����ɽ� varchar2(100); --ȫ��˾ͳһ��׼�����ɽ�(Y),��Ӫҵ����׼�����ɽ�(N)
  --�������
  errcode  constant integer := -20012;
  nocust   constant integer := -20013;
  noarrear constant integer := -20014;
  noenough constant integer := -20015;
  --��������
  PAYTRANS_POS      constant char(1) := 'P'; --����ˮ��̨�ɷ�
  PAYTRANS_DS       constant char(1) := 'B'; --����ʵʱ����
  PAYTRANS_BSAV     constant char(1) := 'W'; --����ʵʱ����Ԥ��
  PAYTRANS_DSDE     constant char(1) := 'E'; --����ʵʱ���յ����ʲ��������ʽ���������շ���
  PAYTRANS_DK       constant char(1) := 'D'; --��������
  PAYTRANS_TS       constant char(1) := 'T'; --����Ʊ������
  PAYTRANS_SAV      constant char(1) := 'S'; --����ˮ��̨����Ԥ��
  PAYTRANS_INV      constant char(1) := 'I'; --����Ʊ������
  PAYTRANS_Ԥ��ֿ� constant char(1) := 'U'; --��ѹ��̼�ʱԤ��ֿ�
  PAYTRANS_YCDB     constant char(1) := 'K'; --Ԥ�����

  PAYTRANS_CR     constant char(1) := 'C'; --��������δ����ҵ����������ʳ������ݷ���
  PAYTRANS_BANKCR constant char(1) := 'X'; --ʵʱ���ճ��������е��ճ�������
  PAYTRANS_DSCR   constant char(1) := 'R'; --ʵʱ���յ����ʳ���
  PAYTRANS_ADJ    constant char(1) := 'V'; --�����˷ѣ��˷Ѵ�������(CR)�����ʲ�������(DE)

  PAYTRANS_����   constant char(1) := 'F'; --���鷣��
  PAYTRANS_׷��   constant char(1) := 'Z'; --׷��
  PAYTRANS_Ԥ��   constant char(1) := 'Y'; --Ԥ��
  PAYTRANS_���   constant char(1) := 'A'; --���
  PAYTRANS_���̿� constant char(1) := 'G'; --���̿�
  PAYTRANS_�۲�   constant char(1) := 'J'; --�۲�
  PAYTRANS_ˮ��   constant char(1) := 'K'; --ˮ��

  DEBIT  constant char(2) := 'DE'; --�跽
  CREDIT constant char(2) := 'CR'; --����

  CTL_PAYPART constant varchar2(10) := 'FULL'; --����
  CAL_DAYS    constant integer := 3; --�Ʒѻ����գ��������ɽ�
  --������Ӧ�հ�
  subtype rl_type is reclist%rowtype;
  type rl_table is table of rl_type;

  --�����ò�ѯǷ�ѹ��̣�ͬ��INQ101��
  function getrec(p_mid in varchar2) return number;
  --ʵʱǷ�ѽ��
  FUNCTION GETREC(P_MID   IN VARCHAR2,
                  P_RECJE OUT RECLIST.RLJE%TYPE,
                  P_ZNJ   OUT RECLIST.RLZNJ%TYPE) RETURN NUMBER;
  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������

  --ȡ���ɽ���ޱ���
  function fgetznscale(p_type    in varchar2, --���ɽ����
                       p_smfid   in varchar2, --Ӫҵ��
                       p_RLGROUP in varchar2 --Ӧ�շ��ʺ�
                       ) return number;
  --ȡ���ɽ��������
  function fgetznday(p_type    in varchar2, --���ɽ����
                     p_smfid   in varchar2, --Ӫҵ��
                     p_RLGROUP in varchar2 --Ӧ�շ��ʺ�
                     ) return number;
  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������
  function getznj(p_smfid   in varchar2, --Ӫҵ��
                  p_RLGROUP in varchar2, --Ӧ�շ��ʺ�
                  p_sdate   in date, --������'����'ΥԼ��
                  p_edate   in date, --������'������'ΥԼ��
                  p_je      in number) --ΥԼ�𱾽�
   return number;
  --ΥԼ����㣨���ڼ��չ��򣬺��������
  function getznjadj(p_rlid     IN varchar2, --Ӧ����ˮ
                     p_rlje     in number, --Ӧ�ս��
                     p_rlgroup  in number, --Ӧ�����
                     p_rlzndate in date, --���ɽ�������
                     P_SMFID    varchar2, --ˮ��Ӫҵ��
                     p_edate    in date --������'������'ΥԼ��
                     ) return number;

  /*******************************************************************************************
  �µ����ʴ�������ɴ�����:
  ����ҵ���������˵�����£�
  1����С�ɷѵ�Ԫ��һ��ˮ��һ���µ�ȫ������
  2��ʵ����PAYMENT��һ����¼����Ӧһֻˮ���һ���»����µ�Ӧ������
  3�����ж��ɷѣ����ա����ջ��ȣ�������PAYMENT�м�¼�����շ���ˮ��ÿ����¼�μ���2��˵��
  �����շ���ˮͨ��������ˮ������һ������ҵ��
  4��Ƿ���ж����ݣ�t.rlpaidflag=��N�� AND t.RLJE>0 AND t.RLREVERSEFLAG=��N��
  *******************************************************************************************/
  /*******************************************************************************************
  ��������F_PAY_CORE
  ��;���������ʹ��̣�����������ҵ�����յ��ñ�����ʵ��
  ������

  ����ֵ��
          000---�ɹ�
          ����--ʧ��
  ǰ��������
          ����ʱ��RECLIST_1METER_TMP�У�׼�������С����������ݡ�
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                      P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                      P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
                      P_RLJE     IN NUMBER, --Ӧ�ս��
                      P_ZNJ      IN NUMBER, --����ΥԼ��
                      P_SXF      IN NUMBER, --������
                      P_PAYJE    IN NUMBER, --ʵ���տ�
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                      P_PAYBATCH IN VARCHAR2, --�ɷ�������ˮ
                      P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                      P_INVNO    IN PAYMENT.PILID%TYPE, --��Ʊ��
                      P_PAYID    OUT PAYMENT.PID%TYPE --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                      ) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_PSET_RECLIST
  ��;�� �������ɺ������ʹ��̵��ã�����ǰ�������ʼ�¼���Ѿ��ڴ�RECLIST �п�������ʱ���У�����������ʱ������������ʴ���
  ����������󣬺������ʹ��̸�����ʱ�����RECLIST ���ﵽ�������Ŀ�ġ�
             ���������Ŀ�ģ����շѽ���Ԥ���������䵽Ӧ���ʼ�¼�ϣ������Ʊ����
  ���ӣ� Aˮ��3����Ƿ��110Ԫ���ڳ�Ԥ��30Ԫ�������շ�100Ԫ��ΥԼ��5Ԫ��Ӧ�����ʼ�¼���£�
  ----------------------------------------------------------------------------------------------------
   ��     ��       Ԥ��     �����շ�    Ӧ��ˮ��     ΥԼ��    Ԥ����ĩ   Ԥ�淢��
  ----------------------------------------------------------------------------------------------------
  2011.06        30        100           30             1               99             69
  -----------------------------------------------------------------------------------------------------
  2011.08        99         0              40             2                57           -42
  -----------------------------------------------------------------------------------------------------
  2011.10        57         0              40             2                15           -42
  -----------------------------------------------------------------------------------------------------
  ������P_PAYJE NUMBER��ʵ�ս��
           P_REMAIND NUMBER ��ǰԤ��
  ǰ��������RECLIST_1METER_TMP ��RLID, RLJE,RLZNJ ��RLSXF ��������ˡ�
  *******************************************************************************************/
  FUNCTION F_PSET_RECLIST(P_PAYJE   IN NUMBER, --ʵ�ս��
                          P_PID     IN PAYMENT.PID%TYPE, --ʵ����ˮ
                          P_REMAIND IN NUMBER, --��ǰԤ��
                          P_DATE    DATE, --��������
                          P_PPER    IN PAYMENT.PPER%TYPE --�տ�Ա
                          ) RETURN NUMBER;
  /*******************************************************************************************
  ��������F_POS_1METER
  ��;����ֻˮ��ɷ�
      1������ɷ�ҵ�񣬵��ñ���������PAYMENT �м�һ����¼��һ��id��ˮ��һ������
      2�����ɷ�ҵ��ͨ��ѭ�����ñ�����ʵ��ҵ��һֻˮ��һ����¼�����ˮ��һ�����Ρ�
  ҵ�����
     1����ֻˮ����Ƿ��ȫ����������Ӧ��id����xxxxx,xxxxx,xxxxx| ��ʽ���P_RLIDS, ���ñ�����
     2�������еȴ��ջ������̨���е�ֻˮ���Ƿ��ȫ����P_RLIDS='ALL'
     3������Ԥ�棬P_RLJE=0
  �������μ���;˵��
     P_PAYBATCH='999999999',����ģ�����������κţ�����ֱ��ʹ��P_PAYBATCH��Ϊ���κ�
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
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
  /*******************************************************************************************
  ��������F_POS_MULT_M
  ��;��
      ���ɷѣ�ͨ��ѭ�����õ���ɷѹ���ʵ�֡�
  ҵ�����
     1����ֻˮ�����ʣ�֧��ˮ����ѡ�����·�
     2��ÿֻˮ��������Ԥ��仯���շѽ��=Ƿ�ѽ��
  ������
  ǰ��������
      1������Ҫ�����ʲ�����ˮ��id��Ӧ������ˮid����Ӧ�ս�ΥԼ�������ѣ� �ڵ��ñ�����ǰ��
       �������ʱ�ӿڱ� PAY_PARA_TMP
      2��Ӧ������ˮ���ĸ�ʽ�����ĵ������ʹ��̵�˵����
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                        P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                        P_PAYJE    IN NUMBER, --��ʵ���տ���
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                        P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                        P_INVNO    IN VARCHAR2, --��Ʊ��
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2;
  /*******************************************************************************************
  ��������F_POS_MULT_HS
  ��;��
      ���ձ�ɷѣ�ͨ��ѭ�����õ���ɷѹ���ʵ�֡�
  ҵ�����
     1����ֻˮ�����ʣ�ÿֻˮ�����ݿͻ���ѡ��Ľ�����ش�����ˮid
     2�����������ʣ��������ʽ����㵽������ĩ�����
     3����ʴ����ӱ�����Ԥ��ת�ӱ�Ԥ�棬�ӱ�Ԥ�����ʣ�
     4�����������ύ
  ������
  ǰ��������
      ˮ���ˮ���Ӧ��Ӧ������ˮ�����������ʱ�ӿڱ� PAY_PARA_TMP ��
  *******************************************************************************************/
  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                         P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --���������
                         P_PAYJE    IN NUMBER, --��ʵ���տ���
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                         P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         P_INVNO    IN VARCHAR2, --��Ʊ��
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2;
  /*******************************************************************************************
  ��������F_SET_REC_TMP
  ��;��Ϊ���ʺ��Ĺ���׼��������Ӧ������
  ������̣�
       1�������ȫ�����ʣ���ֱ�ӽ���Ӧ��¼��RECLIST��������ʱ��
       2������ǲ��ּ�¼���ʣ������Ӧ������ˮ����������RECLIST��������ʱ��
       3������ΥԼ�������ѵ�����ǰ����Ľ����Ϣ
  ������
       1���������ʣ�P_RLIDS Ӧ����ˮ������ʽ��XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| ���ŷָ�
       2��ȫ�����ʣ�_RLIDS='ALL'
       3��P_MIID  ˮ�����Ϻ�
  ����ֵ���ɹ�--Ӧ����ˮID������ʧ��--0
  *******************************************************************************************/
  function F_SET_REC_TMP(P_RLIDS in varchar2, P_MIID IN VARCHAR2)
    return NUMBER;

  /*******************************************************************************************
  ��������F_CHK_AMOUNT
  ��;��������ʽ���Ƿ����
  ������ Ӧ�ɣ������ѣ�ΥԼ��ʵ�ս�Ԥ���ڳ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  function F_CHK_LIST(p_rlje   in number, --Ӧ�ս��
                      p_znj    in number, --����ΥԼ��
                      P_sxf    in number, --������
                      p_payje  in number, --ʵ���տ�
                      p_saving IN meterinfo.Misaving%type --ˮ�����Ϻ�
                      ) return NUMBER;
  /*******************************************************************************************
  ��������F_REMAIND_TRANS
  ��;����2��ˮ��֮�����Ԥ��ת��
  ������ ת��ˮ��ţ�׼��ˮ��ţ����
  ҵ�����
     1�����ú������ʹ��̣�ˮ�ѽ��=0ʱΪ����Ԥ�棬
     2����PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
     3��2����¼ͬһ�����κ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --ת��ˮ���
                            P_MID_T    IN METERINFO.MIID%TYPE, --ˮ�����Ϻ�
                            P_JE       IN METERINFO.MISAVING%TYPE, --ת�ƽ��
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --ʵ�������κ�
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --�Ƿ��ύ
                            ) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������SP_AUTO_PAY
  ��;��
      ��ͨˮ���Զ�Ԥ��ֿ۽ɷ�
  ҵ�����

  ������  --ˮ���
  ǰ��������
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY(P_MIID IN METERINFO.MIID%TYPE);
  /*******************************************************************************************
  ��������SP_AUTO_PAY_1REC
  ��;��
      ��ͨˮ��1��Ӧ�ռ�¼�Զ�Ԥ��ֿ۽ɷ�
  ҵ�����

  ������  --Ӧ����ˮid
  ǰ��������
  *******************************************************************************************/
  PROCEDURE SP_AUTO_PAY_1REC(P_REC IN RECLIST%ROWTYPE);
  /*******************************************************************************************
  ��������F_PAYBACK_BY_PMID
  ��;��ʵ�ճ���,��ʵ����ˮid����
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN PAYMENT.PID%TYPE,
                             P_POSITION IN PAYMENT.PPOSITION%TYPE,
                             P_OPER     IN PAYMENT.PPER%TYPE,
                             P_BATCH    IN PAYMENT.PBATCH%TYPE,
                             P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                             P_TRANS    IN PAYMENT.PTRANS%TYPE,
                             P_COMMIT   IN VARCHAR2) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_PAYBACK_BANKSEQNO
  ��;��ʵ�ճ���,��������ˮid����
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BANKNO(P_BSEQNO   IN PAYMENT.PBSEQNO%TYPE,
                               P_POSITION IN PAYMENT.PPOSITION%TYPE,
                               P_OPER     IN PAYMENT.PPER%TYPE,
                               P_BATCH    IN PAYMENT.PBATCH%TYPE,
                               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                               P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2;
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
END;
/


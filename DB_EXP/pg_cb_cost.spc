CREATE OR REPLACE PACKAGE pg_cb_cost is
  /*add 20201113*/
  ----�����ύ����
  ���ύ CONSTANT NUMBER := 0;
  �ύ   CONSTANT NUMBER := 1;
  ����   CONSTANT NUMBER := 2;
  --�Ʒ�����
  �ƻ�����   CONSTANT CHAR(1) := '1';
  ���       CONSTANT CHAR(1) := 'Q';
  Ӫҵ������ CONSTANT CHAR(1) := 'T';
  ׷��       CONSTANT CHAR(1) := 'O';
  --Ӧ�����˰�
  SUBTYPE RL_TYPE IS YS_ZW_ARLIST%ROWTYPE;
  TYPE RL_TABLE IS TABLE OF RL_TYPE;
  --Ӧ����ϸ��
  SUBTYPE RD_TYPE IS ys_zw_ardetail%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --Ӧ����ʱ������ϸ��
  SUBTYPE RDT_TYPE IS ys_zw_ardetail_budget%ROWTYPE;
  TYPE RDT_TABLE IS TABLE OF RDT_TYPE;

  --���˷���
  DEBIT  CONSTANT CHAR(2) := 'DE'; --�跽
  CREDIT CONSTANT CHAR(2) := 'CR'; --����

  --�������
  ERRCODE CONSTANT INTEGER := -20012;

  --д�����־
  /*PROCEDURE AUTOSUBMIT;
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB);
  
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB);*/
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2);
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER); --�ƻ������
  --������Ѻ���
  PROCEDURE COSTCULATECORE(MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                           P_TRANS  IN CHAR,
                           P_PSCID  IN NUMBER,
                           P_COMMIT IN NUMBER);
  --
  PROCEDURE COSTPIID(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                     P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                     P_SL       IN NUMBER,
                     PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                     PMD        IN YS_YH_PRICEGROUP%ROWTYPE,
                     RDTAB      IN OUT RD_TABLE,
                     P_CLASSCTL IN CHAR,
                     P_PSCID    IN NUMBER,
                     P_COMMIT   IN NUMBER);
  --
  PROCEDURE COSTSTEP_MON(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                         P_MR       IN OUT YS_CB_MTREAD%ROWTYPE,
                         P_SL       IN NUMBER,
                         P_ADJSL    IN NUMBER,
                         P_ADJDJ    IN NUMBER,
                         PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                         RDTAB      IN OUT RD_TABLE,
                         P_CLASSCTL IN CHAR,
                         PMD        IN YS_YH_PRICEGROUP%ROWTYPE);
  --
  PROCEDURE COSTSTEP_YEAR(P_RL       IN OUT YS_ZW_ARLIST%ROWTYPE,
                          P_SL       IN NUMBER,
                          P_ADJSL    IN NUMBER,
                          P_ADJDJ    IN NUMBER,
                          PD         IN BAS_PRICE_DETAIL%ROWTYPE,
                          RDTAB      IN OUT RD_TABLE,
                          P_CLASSCTL IN CHAR,
                          PMD        YS_YH_PRICEGROUP%ROWTYPE,
                          PMONTH     IN VARCHAR2);
  --                        
  PROCEDURE INSRD(RD IN RD_TABLE, P_COMMIT IN NUMBER);
  --
  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;
  --
  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;
  --
  FUNCTION FBOUNDPARA(P_PARASTR IN CLOB) RETURN INTEGER;
  --
  FUNCTION FGETPARA(P_PARASTR IN VARCHAR2,
                    ROWN      IN INTEGER,
                    COLN      IN INTEGER) RETURN VARCHAR2;
   --Ԥ��ѣ��ṩ׷����Ӧ�յ������˷ѵ�����������м�����                  
  PROCEDURE SUBMIT_VIRTUAL(p_mid    in varchar2,
                           p_prdate in date,
                           p_rdate  in date,
                           p_scode  in number,
                           p_ecode  in number,
                           p_sl     in number,
                           p_rper   in varchar2,
                           p_pfid   in varchar2,
                           p_usenum in number,
                           p_trans  in varchar2,
                           o_rlid   out varchar2)  ;                
end;
/


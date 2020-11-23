CREATE OR REPLACE PACKAGE pg_cb_cost is
  /*add 20201113*/
  ----过程提交控制
  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  --计费事务
  计划抄表   CONSTANT CHAR(1) := '1';
  余度       CONSTANT CHAR(1) := 'Q';
  营业外收入 CONSTANT CHAR(1) := 'T';
  追量       CONSTANT CHAR(1) := 'O';
  --应收总账包
  SUBTYPE RL_TYPE IS YS_ZW_ARLIST%ROWTYPE;
  TYPE RL_TABLE IS TABLE OF RL_TYPE;
  --应收明细包
  SUBTYPE RD_TYPE IS ys_zw_ardetail%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --应收临时审批明细包
  SUBTYPE RDT_TYPE IS ys_zw_ardetail_budget%ROWTYPE;
  TYPE RDT_TABLE IS TABLE OF RDT_TYPE;

  --记账方向
  DEBIT  CONSTANT CHAR(2) := 'DE'; --借方
  CREDIT CONSTANT CHAR(2) := 'CR'; --贷方

  --错误代码
  ERRCODE CONSTANT INTEGER := -20012;

  --写算费日志
  /*PROCEDURE AUTOSUBMIT;
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB);
  
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB);*/
  PROCEDURE COSTBATCH(P_BFID IN VARCHAR2);
  PROCEDURE COSTCULATE(P_MRID IN YS_CB_MTREAD.ID%TYPE, P_COMMIT IN NUMBER); --计划内算费
  --单笔算费核心
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
   --预算费，提供追补、应收调整、退费单据中重算费中间数据                  
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


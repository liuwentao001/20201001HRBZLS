CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_METERREAD_01" IS

  -- Author  : 王勇
  -- Created : 2011-10-16
  -- Purpose :

  --应收明细包
  SUBTYPE RD_TYPE IS RECDETAIL%ROWTYPE;
  TYPE RD_TABLE IS TABLE OF RD_TYPE;
  --应收临时审批明细包
  SUBTYPE RDT_TYPE IS RECDETAILTEMP%ROWTYPE;
  TYPE RDT_TABLE IS TABLE OF RDT_TYPE;
  --优惠明细包
  SUBTYPE PAL_TYPE IS PRICEADJUSTLIST%ROWTYPE;
  TYPE PAL_TABLE IS TABLE OF PAL_TYPE;
  -- Public constant declarations

  --记账方向
  DEBIT  CONSTANT CHAR(2) := 'DE'; --借方
  CREDIT CONSTANT CHAR(2) := 'CR'; --贷方

  --错误代码
  ERRCODE CONSTANT INTEGER := -20012;

  --调试用数组函数
  FUNCTION DEBUG(P_ARRSTR IN VARCHAR2) RETURN ARR;
  --写算费日志
  PROCEDURE WLOG(P_TXT IN VARCHAR2);
  PROCEDURE AUTOSUBMIT;
  PROCEDURE SUBMIT(P_BFID IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2);
  PROCEDURE SUBMIT1(P_MICODE IN VARCHAR2, LOG OUT CLOB);

  PROCEDURE SUBMIT(P_BFID IN VARCHAR2, LOG OUT CLOB);

  --算费前虚拟算费，供月抄表明细调用
  FUNCTION CALCULATEBF(P_MRID IN VARCHAR2, P_TYPE IN VARCHAR2) RETURN NUMBER;

  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE); --计划内算费

  PROCEDURE CALCULATE_YSFH(P_MRID    IN METERREAD.MRID%TYPE,
                           o_rlje    out reclist.rlje%type,
                           o_message out varchar2); --手机抄表预算费 20150309
  -- 自来水单笔算费，提供外部调用
  --procedure Calculate(mr in out meterread%rowtype, p_trans in char);
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  PROCEDURE CALCULATE_YSFD(MR        IN OUT METERREAD%ROWTYPE,
                           P_TRANS   IN CHAR,
                           P_NY      IN VARCHAR2,
                           o_rlje    out reclist.rlje%type,
                           o_message out varchar2);

  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);

  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);

  -- 费率明细计算步骤
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    p_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2);
  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2);
  function f_GETpfid(PALTAB IN PAL_TABLE) return PAL_TABLE;

  --调整水价+费用项目函数   BY WY 20130531   
  function f_GETpfid_piid(PALTAB IN PAL_TABLE, p_piid in varchar2)
    return PAL_TABLE;
  --水价调整函数   BY WY 20130531
  --procedure sp_GETJMpfid(PALTAB   IN  PAL_TABLE,o_pdj  out  PAL_TABLE) ;                       
  --阶梯计费步骤
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
  --账务审批 by lgb 20120514
  PROCEDURE 账务审批(P_BFID IN VARCHAR2);
  --追量插入账务明细 by lgb 20120526
  PROCEDURE INSRD01(RD IN RD_TABLE);
  
  --批量算费 for pb 前台
  procedure submit_forpb(p_bfid in  varchar2,   --表册Id  
                         p_app  out number,     --返回码 1-成功 -1 有错误 
                         p_err  out varchar2    --错误信息 
  ); 
END;
/


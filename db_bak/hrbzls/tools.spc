CREATE OR REPLACE PACKAGE HRBZLS."TOOLS" is

  -- author  : 江浩
  -- created : 2008-01-08 16:34:39
  -- purpose : jh

  -- public type declarations
  subtype mi_type is meterinfo%rowtype;
  type mi_table is table of mi_type;
  type out_base is ref cursor;
  -- public constant declarations
  errcode constant integer := -20012;

  -- public variable declarations

  -- public function and procedure declarations
  procedure getmeterchildall(p_mid in varchar2,p_mitab in out tminfotree);
  procedure getmeterchild(p_mid in varchar2,p_mitab in out tminfotree);
  --procedure getmeterchildlist(p_mid in varchar2,p_mitab in out tminfotree,numrowtotal  in out number);
  procedure getmeterparent(p_mid in varchar2,p_mitab in out tminfotree);
  --procedure getmeterparentlist(p_mid in varchar2,p_mitab in out tminfotree,numrowtotal  in out number);
  function fgetpmonth(p_month in varchar2,p_cycid in char) return varchar2;
  function fgetaheadmonth(p_month in varchar2,p_cycid in char) return varchar2;
  function fgetmonth(p_month in varchar2,p_cycid in char) return varchar2;
  function fgetnextmonth(p_month in varchar2,p_cycid in char) return varchar2;
  procedure sp_createcal;
  function  fgetpaymonth(p_smfid in varchar2) return varchar2;
  function  fgetrecmonth(p_smfid in varchar2) return varchar2;
  function  fgetinvmonth(p_smfid in varchar2) return varchar2;
  function  fgetreadmonth(p_smfid in varchar2) return varchar2;
  function fgetinvdate(p_smfid in varchar2) return varchar2;
  function  fgetpaydate(p_smfid in varchar2) return date;
  function  fgetrecdate(p_smfid in varchar2) return date;
  function fmidn_sepmore(p_str in varchar2,p_sep in varchar2) return integer;
  function fmid_sepmore(p_str in varchar2,p_n in number,p_null in char,p_sep in varchar2) return varchar2;
  function fmidn(p_str in varchar2,p_sep in varchar2) return integer;
  function fmid(p_str in varchar2,p_n in number,p_null in char,p_sep in varchar2) return varchar2;
    --本函数和下面同名的函数为重载函数
  function fgetpara(p_parastr in varchar2,rown in integer,coln in integer) return varchar2;
  function  fgetpara(p_parastr in clob,rown in integer,coln in integer) return varchar2;
  FUNCTION fGetmeterplanMon(p_smfid in VARCHAR2) RETURN varchar2;
  --------------------------------------------
  function  fgetpara2(p_parastr in clob,rown in integer,coln in integer) return varchar2;
  function  fboundpara(p_parastr in clob) return integer;
  function fboundpara2(p_parastr in varchar2) return integer;
  function  f0null(p_n in number) return number;
  function  fnull0(p_n in number) return number;

  function fuppernumber(input_nbr in number default 0) return varchar2;
  function fformatnum(p_n in number,p_float in integer) return varchar2;

  function fgetznlimitday return integer;
  function fgetznscale return number;
    --营业所收滞金额比例
  function fgetsmfidznscale(p_smfid in varchar2) return number ;
    --营业所收滞金宽限天数
  function fgetsmfidzndays(p_smfid in varchar2) return number ;
    function fgetznscale02 return number;
  procedure sp_login(p_wsid in varchar2,
                     p_oper in varchar2,
                     p_hostname in varchar2,
                     p_memo in varchar2);

  function getmin(n1 in number,n2 in number) return number;
  function getmax(n1 in number,n2 in number) return number;
  function fgetinvprop(p_id in varchar2,no in integer) return varchar2;
  FUNCTION fGetSysDate RETURN DATE;
 -- FUNCTION fGetmeterplanMon(p_smfid in VARCHAR2) RETURN varchar2;
--生成单据游水号
 PROCEDURE SP_BillSeq
   (vBillId  IN  varCHAR2,
    vBillSeqno   OUT varCHAR2,
    vCommit    IN varCHAR2 default 'Y');

/*系统任务号*/
PROCEDURE sp_execprc(vtaskid IN VARCHAR2,  /*系统任务号*/
               vpara IN VARCHAR2 DEFAULT NULL);

/*****************************************************************************
后台任务事件记录
前置条件：
  时间id序列  seq_event_bk
  后台事件记录表EVENT_BACKGROUND
*****************************************************************************/
PROCEDURE SP_BKEVENT_REC(P_TASKNAME VARCHAR2,
                                               P_TASKSTEP NUMBER,
                                               P_STEPMSG VARCHAR2,
                                               P_PARAS VARCHAR2) ;
  ----
/*****************************************************************************
后台任务事件记录
  时间id序列  seq_event_bk
  后台事件记录表EVENT_BACKGROUND
*****************************************************************************/
PROCEDURE SP_BKEVENT_REC(P_TASKNAME VARCHAR2,
                                               P_TASKSTEP NUMBER,
                                               P_STEPMSG VARCHAR2,
                                               P_PARAS VARCHAR2,
                                               P_COMMIT VARCHAR2
                                               )  ;
                                               
PROCEDURE SP_OAIC;

function fgetinsertchar(p_num in number,p_char varchar2)  return varchar2;
PROCEDURE sp_fgetpcodetemp(p_rllist in varchar2,P_RLJE IN NUMBER,ret out varchar2);
end tools;
/


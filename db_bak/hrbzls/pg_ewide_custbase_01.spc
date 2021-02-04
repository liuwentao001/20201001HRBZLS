CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_CUSTBASE_01" IS

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;
  是否库存管理       VARCHAR(2) := FSYSPARA('sys4');
  客户代码是否营业所 VARCHAR(2) := FSYSPARA('CODE');
  --审核异常日志
    PROCEDURE WLOG(P_TXT IN VARCHAR2);
  --单据审核路由过程
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --单据审核路由过程（简化）
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --变更单取消
  PROCEDURE CANCEL(P_BILLNO IN VARCHAR2,
                   P_PERSON IN VARCHAR2,
                   P_DJLB   IN VARCHAR2);
  --变更单行审核
  PROCEDURE APPROVEROW(P_BILLNO IN VARCHAR2,
                       P_PERSON IN VARCHAR2,
                       P_BILLID IN VARCHAR2,
                       P_DJLB   IN VARCHAR2,
                       P_ROWNO  IN NUMBER);

  --立户审核（一户一表）
  PROCEDURE SP_REGISTER(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);
  --立户建账
    PROCEDURE SP_REGISTER1(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);
  --立户审核（一户多表）
  PROCEDURE SP_REGISTER12(P_TYPE   IN VARCHAR2,
                          P_CRHNO  IN VARCHAR2,
                          P_PER    IN VARCHAR2,
                          P_COMMIT IN VARCHAR2);
  --临时用水建帐
  PROCEDURE sp_临时用水立户(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);

  --变更主程序
  PROCEDURE SP_CUSTCHANGE(P_TYPE   IN VARCHAR2, --操作类型
                          P_CCHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          );
  --变更主程序单行
  PROCEDURE SP_CUSTCHANGEBYROW(P_TYPE   IN VARCHAR2, --操作类型
                               P_CCHNO  IN VARCHAR2, --批次流水
                               P_ROWNO  IN NUMBER, --行号
                               P_PER    IN VARCHAR2, --操作员
                               P_COMMIT IN VARCHAR2 --提交标志
                               );
  --变更单个审核过程
  PROCEDURE SP_CUSTCHANGEONE(P_TYPE IN VARCHAR2, --类型
                             P_CD   IN OUT CUSTCHANGEDT%ROWTYPE --单体行变更
                             );
  PROCEDURE METERSTATICREFRESH(P_SDATE IN VARCHAR2, P_EDATE IN VARCHAR2);
  --插入水表日志并提交统计
  PROCEDURE METERLOG(P_MSL    IN OUT METER_STATIC_LOG%ROWTYPE,
                     P_COMMIT IN VARCHAR2);
  PROCEDURE SUM$DAY$METER(P_MIID   VARCHAR2,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2);
  PROCEDURE SUM$DAY$METER(P_MI     IN METERINFO%ROWTYPE,
                          P_TYPE   VARCHAR2,
                          P_COMMIT VARCHAR2);
  PROCEDURE INITMETER_STATIC(P_SCRDATE IN DATE, P_DESDATE IN DATE);

PROCEDURE  sp_正式用水管理(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
PROCEDURE sp_临时用水管理(P_TYPE   IN VARCHAR2,--单据类别
                      P_billNO  IN VARCHAR2,--单据编号
                      P_PER    IN VARCHAR2,--审批人
                      P_COMMIT IN VARCHAR2)--是否提交
                        ;
PROCEDURE sp_污水超标管理(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
PROCEDURE sp_特惠户管理(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;                        
                        
PROCEDURE  sp_营业所变更(P_TYPE   IN VARCHAR2,--单据类别
                        P_CCHNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
PROCEDURE  sp_批量预存(P_MICODE IN VARCHAR2, --客户代码
                       P_OPER   IN VARCHAR2, --收款人
                       P_SAVING IN NUMBER,   --预存
                       O_PBATCH OUT VARCHAR2)   --缴费批次
                        ;
PROCEDURE  sp_撤销预存(P_BATCH   IN VARCHAR2,--缴费批次
                        P_PID  IN VARCHAR2,--缴费流水
                        P_MICODE IN VARCHAR2, --客户代码
                        P_POSITION    IN VARCHAR2,--缴费地点
                        P_OPER IN VARCHAR2,--缴费人
                        P_TYPE IN VARCHAR2) --冲销类别 1、批次冲销2、缴费流水冲销
                        ;
                        
PROCEDURE  sp_拆迁止水(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_OPER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
                        
PROCEDURE  sp_异常表态审批(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
                        
PROCEDURE  sp_封号管理(P_TYPE   IN VARCHAR2,--单据类别
                        P_billNO  IN VARCHAR2,--单据编号
                        P_PER    IN VARCHAR2,--审批人
                        P_COMMIT IN VARCHAR2)--是否提交
                        ;
 PROCEDURE SP_营销部收入建账(P_TYPE   IN VARCHAR2,
                        P_CRHNO  IN VARCHAR2,
                        P_PER    IN VARCHAR2,
                        P_COMMIT IN VARCHAR2);                       
procedure  SP_CUSTCHANGE_BYMIID(
           P_BILLNO   in varchar2,             --单据编号
           p_BILLTYPE  in varchar2,            --单据编号
           p_per    in varchar2,             --创建人
           P_MIID   IN VARCHAR2,             --客户代码
           P_SMFID  IN VARCHAR2,             --营业所
           p_commit in varchar2              --是否提交
           );
 PROCEDURE SP_远传建账;   
 
END;
/


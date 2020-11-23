CREATE OR REPLACE PACKAGE Pg_Paid_01bak IS
  -- Public type declarations
  SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
  TYPE Rd_Table IS TABLE OF Rd_Type;
  --存储临时变量
  SUBTYPE Pb_Type IS Ysparmtemp%ROWTYPE;
  TYPE Arr_Table IS TABLE OF Pb_Type;
  --
  -- Public constant declarations
  --错误返回码
  Errcode CONSTANT INTEGER := -20012;

  --【代码规则常量】（可转化为由系统参数初始化）
  --↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  ----过程提交控制
  不提交 CONSTANT NUMBER := 0;
  提交   CONSTANT NUMBER := 1;
  调试   CONSTANT NUMBER := 2;
  ----可忽略的应实收计帐方向，现已由+/-值含义替代
  借方 CONSTANT CHAR(2) := 'DE';
  贷方 CONSTANT CHAR(2) := 'CR';
  --【缴费业务核心规则】
  --  全局重要参数，允许各帐务流程中预存发生
  --  例如：无预存业务的项目本控制位设为false
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许预存发生 CONSTANT BOOLEAN := TRUE;

  --  全局重要参数，允许各帐务流程中期初可以是负预存、销帐后也可以是负预存，但不能发生更多的负预存
  --  true时意味着无条件销帐成功，不足额部分无底线的转负预存余额
  --  例如：某些项目中有向下取整找零的规则时此控制位为true，取整规则在调用前计算ok，本地后台不校验
  --  作用于：PayRecCore
  --          ReMainCore
  --          PayReverseCoreByPid
  允许净减后负预存 CONSTANT BOOLEAN := TRUE;

  ----净减为负预存余额时不销帐转预存
  --  作用于：PayRecCore
  净减为负预存不销帐 CONSTANT BOOLEAN := FALSE;
  代扣后是否发送短信 CONSTANT BOOLEAN := FALSE;

  --  调度作业方式下余额足额抵扣当前欠费时控制是否抵扣含违约金欠费记录
  --  作用于：pg_pay.ReMainPayCoreByCust
  允许预存抵扣违约欠费 CONSTANT INTEGER := 1;

  允许重复销帐 CONSTANT INTEGER := 1;

  ----实时代收单缴预存规则
  --  作用于：BPay
  允许实时代收单缴预存 CONSTANT BOOLEAN := FALSE; --20140812 0:30 true->flase

  --【一些可选的销帐方式】
  ----允许销帐拆帐
  不允许拆帐 CONSTANT INTEGER := 0; --0金额非0水量销帐
  允许拆帐   CONSTANT INTEGER := 1; --默认
  ----代收对帐方法
  正常对帐 CONSTANT INTEGER := 1; --自动化调用时可传此参数，若存在已对帐记录，且有平帐，则对帐失败；
  重新对帐 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已对帐记录，且有平帐，则还原平帐（对帐冲正进行对帐补销、对帐补销进行对帐冲正）后进行首次对帐；
  ----批扣本地处理方式
  正常批扣处理 CONSTANT INTEGER := 1; --自动化调用时可传此参数，对新已下账记录进行销帐，其余根据在途完结标志全部解锁；
  重新批扣处理 CONSTANT INTEGER := 2; --手工业务调用时传此参数，若存在已销帐记录，则还原销帐（代扣销帐进行代扣冲正）后进行正常处理；
  ----批次在途完结否
  批扣未结束 CONSTANT INTEGER := 0; --本次文档后银行还未结束扣费
  批扣结束   CONSTANT INTEGER := 1; --已结束
  ----批扣文本类型
  成功批扣文本   CONSTANT INTEGER := 0; --只有失败记录
  失败批扣文本   CONSTANT INTEGER := 1; --只有成功记录
  全部批扣文本   CONSTANT INTEGER := 2; --所有记录
  无文本全部成功 CONSTANT INTEGER := 3; --无文本返回，银行口头通知所有批扣成功
  ----抵减预存余额后代扣
  抵减预存余额后代扣 CONSTANT INTEGER := 1; --批扣发包时预存余额参与计算应缴，etlje = etlrlje +etlwyj +etlremaind
  No抵减预存余额代扣 CONSTANT INTEGER := 0; --批扣发包时预存余额不参与计算应缴，etlje = etlrlje +etlwyj
  ----缴费通知
  全局屏蔽通知 CONSTANT BOOLEAN := FALSE;
  局部屏蔽通知 CONSTANT INTEGER := 0; --（可能用于外部传参，故使用通用int类型）
  局部允许通知 CONSTANT INTEGER := 1; --（可能用于外部传参，故使用通用int类型）
  ----销帐违约金分帐，可通过参数控制销帐核心过程中对违约金和本金分帐处理，分帐条件内置
  ----独立违约金发票需求
  允许销帐违约金分帐 CONSTANT BOOLEAN := TRUE; --
  --↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
  --常量参数
  Ptrans_柜台缴费 CONSTANT CHAR(1) := 'P'; --自来水柜台缴费
  Ptrans_代收销帐 CONSTANT CHAR(1) := 'B'; --银行实时代收
  Ptrans_代收补销 CONSTANT CHAR(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销,隔日发起）
  Ptrans_代扣销帐 CONSTANT CHAR(1) := 'D'; --代扣销帐
  Ptrans_托收销帐 CONSTANT CHAR(1) := 'T'; --托收票据销帐
  Ptrans_独立预存 CONSTANT CHAR(1) := 'S'; --自来水柜台独立预存
  Ptrans_票据销帐 CONSTANT CHAR(1) := 'I'; --走收票据销帐
  Ptrans_预存抵扣 CONSTANT CHAR(1) := 'U'; --算费过程即时预存抵扣
  Ptrans_预存调拨 CONSTANT CHAR(1) := 'K'; --合收表创建时子表预存余额转到主表预存余额中

  Ptrans_冲正       CONSTANT CHAR(1) := 'C'; --冲正
  Ptrans_退费       CONSTANT CHAR(1) := 'V'; --退费
  Ptrans_代收冲正   CONSTANT CHAR(1) := 'R'; --实时代收单边帐冲销
  Ptrans_预售       CONSTANT CHAR(1) := 'Q'; --预售水
  Ptrans_零量费销帐 CONSTANT CHAR(1) := 'W'; --零量费销帐
  --
  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER;
  --
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --应收流水
                     p_Ardpiids IN VARCHAR2, --应收明细费项串'01|02|03'
                     p_Edate    IN DATE --终算日'不计入'违约日,参数格式'yyyy-mm-dd'
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
                       p_Commit   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT 不提交,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER);
  --
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT 不提交);
  --
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT 不提交,
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

  --1、实收冲正（当月负实收）
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
 -- 应收追帐核心
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
                          p_Commit          IN NUMBER DEFAULT 不提交,
                          o_Rlid            OUT VARCHAR2);
  --应收追正
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT 不提交,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER);
  
  --实收冲正次核心
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
   --水司柜台冲正(不退款)   
   procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default 不提交,
                       p_pid_reverse out varchar2);                                                                           
  /*******************************************************************************************
  函数名：F_PAYBACK_BY_PMID
  用途：实收冲正,按实收流水id冲正
  参数：
  业务规则：
  
  返回值：
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
  函数名：F_PAYBACK_BATCH
  用途：实收冲正,按批次冲正
  参数：
  业务规则：

  返回值：
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


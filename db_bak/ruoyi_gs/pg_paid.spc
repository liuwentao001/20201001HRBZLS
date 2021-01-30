create or replace package pg_paid is
  --错误返回码
  errcode constant integer := -20012;
  --常量参数
  paytrans_pos      constant char(1) := 'P'; --自来水柜台缴费
  paytrans_ds       constant char(1) := 'B'; --银行实时代收
  paytrans_bsav     constant char(1) := 'W'; --银行实时单缴预存
  paytrans_dsde     constant char(1) := 'E'; --银行实时代收单边帐补销（对帐结果补销隔日发起）
  paytrans_dk       constant char(1) := 'D'; --代扣销帐
  paytrans_ts       constant char(1) := 'T'; --托收票据销帐
  paytrans_sav      constant char(1) := 'S'; --自来水柜台独立预存
  paytrans_inv      constant char(1) := 'I'; --走收票据销帐
  paytrans_预存抵扣 constant char(1) := 'U'; --算费过程即时预存抵扣
  paytrans_ycdb     constant char(1) := 'K'; --预存调拨
  paytrans_cr     constant char(1) := 'C'; --其它所有未独立业务冲销（销帐冲正单据发起）
  paytrans_bankcr constant char(1) := 'X'; --实时代收冲销（银行当日冲销发起）
  paytrans_dscr   constant char(1) := 'R'; --实时代收单边帐冲销
  paytrans_adj    constant char(1) := 'V'; --减量退费：退费贷帐事务(cr)、借帐补销事务(de)
  paytrans_稽查   constant char(1) := 'F'; --稽查罚款
  paytrans_追量   constant char(1) := 'Z'; --追量
  paytrans_预留   constant char(1) := 'Y'; --预留
  paytrans_余度   constant char(1) := 'A'; --余度
  paytrans_工程款 constant char(1) := 'G'; --工程款
  paytrans_价差   constant char(1) := 'J'; --价差
  paytrans_水损   constant char(1) := 'K'; --水损
  --缴费入口
  /*
  p_yhid          用户编码
  p_arstr          欠费流水号，多个流水号用逗号分隔，例如：0000012726,70105341
  p_oper          销帐员，柜台缴费时销帐人员与收款员统一
  p_payway        付款方式(XJ-现金 ZP-支票 MZ-抹账 DC-倒存)
  p_payment       实收，即为（付款-找零），付款与找零在前台计算和校验
  p_pid           返回交易流水号*/
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2);

  --一水表多应收销帐
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_pbatch   in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number);

  --实收销帐处理核心
  procedure payzwarcore(p_pid          in varchar2,
              p_batch        in varchar2,
              p_payment      in number,
              p_remainbefore in number,
              p_oper         in varchar,
              p_paiddate     in date,
              p_paidmonth    in varchar2,
              p_arstr        in varchar2,
              o_sum_arje     out number,
              o_sum_arznj    out number,
              o_sum_arsxf    out number);

  --批量预存充值
  procedure precust_pl(p_yhids     in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    o_pid_reverse out varchar2);

  --预存退费工单_批量
  procedure precust_yctf_gd_pl(p_renos     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --预存退费工单
  procedure precust_yctf_gd(p_reno     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --预存充值
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_pbatch      in varchar2,
                    p_trans       in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number);

  --实收冲正，按工单
  procedure pay_back_gd(p_reno in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，多流水号批量冲正，只冲正缴费交易，不冲正抵扣交易
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，按缴费批次
  procedure pay_back_by_pbatch(p_pbatch in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正，柜台缴费退费，
  --  1.事务为U 或 事务为P且预存金额大于退费金额，直接冲正当条实收
  --  2.事务为P且预存金额小于退费金额，按收费时间倒序冲正事务为U的实收，直到预存金额大于退费金额，然后冲正事务为P的当条实收
  procedure pay_back_by_pdate_desc(p_pid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --实收冲正
  --  p_payid  实收流水号
  --  p_oper   操作员编码
  --  p_recflg 是否冲正应收账
  --  o_pid_reverse      返回实收冲正流水号
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, p_recflag in varchar2, o_pid_reverse out varchar2) ;

/*******************************************************************************************
函数名：f_set_cr_reclist
用途： 本函数由核心实收冲正帐过程调用，调用前【待冲正应收记录记录】已经在从RECLIST 中拷贝到临时表中，本函数对临时表进行逐条冲正处理，
返回主程序后，核心冲正过程根据临时表更新RECLIST ，达到快捷冲正目的。
       逐条处理的目的：将冲正金额和预存逐条分配到应收帐记录上，预存管理
例子： A水表，个月欠费110元，期初预存30元，本次收费100元，违约金5元，应收冲正后记录如下：
----------------------------------------------------------------------------------------------------
月     份       预初     本次收费    应缴水费     违约金    预存期末   预存发生
----------------------------------------------------------------------------------------------------
原  2011.06         30          100           110         5        15         15
新  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
参数：pm 负实收 。
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype) return number;



end;
/


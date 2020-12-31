create or replace package pg_paid is
  --错误返回码
  errcode constant integer := -20012;

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

  --预存充值
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number);

  --实收冲正，多流水号批量冲正
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);
                     
  --实收冲正
  /*
  p_payid           交易流水号
  p_oper            操作员
  o_pid_reverse     返回冲正交易流水号
  */
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) ;
  
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


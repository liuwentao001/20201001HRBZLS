CREATE OR REPLACE PACKAGE HRBZLS."ZHONGBE" is

  type myarray IS TABLE OF varchar2(500) INDEX BY BINARY_INTEGER;
  /*  arr_1 arr index by binary_integer;*/
  --常量定义
  errcode constant integer := -20012;
  --过程定义于此

  --函数定义于此
  function main(P_CODE in VARCHAR2, p_in in arr, p_out in out arr)
    return varchar2;
  function f_set_item(p_arr in out arr, p_data in varchar2) return number;
  function F_SET_TEXT(P_ROW IN VARCHAR2,P_DATE IN VARCHAR2) return number;
  function F_GET_HDTEXT(P_ROW IN VARCHAR2) return VARCHAR2;
  function F_GET_DTTEXT(P_ROW IN VARCHAR2) return VARCHAR2;

  procedure f520(p_in in arr, p_out in out arr);
  procedure f521(p_in in arr, p_out in out arr);
  procedure f522(p_in in arr, p_out in out arr);

  procedure f540(p_in in arr, p_out in out arr);
  procedure sp_qf_month(p_qf in out arr, p_rlid in varchar2);
  procedure sp_ysjl_month(p_qf in out arr, p_rlid in varchar2);
  procedure sp_ssjl_month(p_qf in out arr, p_pid in varchar2);
  procedure sp_ssjy_month(p_qf in out arr, p_rlid in varchar2);
  procedure f600(p_in in arr, p_out in out arr);
  procedure f580(p_in in arr, p_out in out arr);
  procedure f550(p_in in arr, p_out in out arr);
  procedure f510(p_in in arr, p_out in out arr);
  procedure f511(p_in in arr, p_out in out arr);
  procedure f110(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 111 签订代扣关系（不检验水表户名）交易
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f111(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 120 解除代扣关系
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f120(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 130 查询用户签约状态
  Input: p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f130(p_in in arr, p_out in out arr);
  procedure sp_test;
  procedure sp_extensiondata(P_ROW IN NUMBER);
  /*---------------------------------------------------------------------
   将 arr 内容转化为|分隔的字符串
  ---------------------------------------------------------------------*/
  function f_arr2var(p_msg in arr) return varchar2;
  /*---------------------------------------------------------------------
  记录交易日志
  ---------------------------------------------------------------------*/
  procedure sp_tran_log(p_code in varchar2, p_req in arr, p_ans in arr);
  procedure sp_tran_errlog(p_code in varchar2, 
                           p_req in arr, 
                           p_ans in arr,
                           p_errid in varchar2,
                           p_errtext in varchar2);
  /*记录签约日志*/
  procedure entrust_sign_log(p_ccode       in varchar2,
                             p_cname       in varchar2,
                             p_bankid      in varchar2,
                             p_ACCOUNTNO   in varchar2,
                             p_ACCOUNTNAME in varchar2,
                             p_CHARGETYPE  in varchar2,
                             p_SIGN_TYPE   in char,
                             p_SIGN_OK     in char);
  /*----------------------------------------------------------------------
  Note:银行实时缴费销账过程
  Input:  p_bankid    银行编码,
          p_chg_op    收费员,
          p_mcode     水表资料号,
          p_chg_total 缴费金额
  output: p_chgno     传入为银行流水，输出为系统实收流水号,
          p_discharge 本次缴费预存的发生值，如果为正则预存增加，如果为负则是使用预存进行了抵扣
          p_curr_sav  本次缴费后，预存的余额
  return：1  无此水表号
          5  金额不符
          21 数据库错误
          22 其他错误
  业务规则说明：
  1、水表资料号下全额欠费必须一同缴清；
  2、代扣托收在途时允许银行实时代收，待代扣托收回帐且成功时计预存；
  3、交易时段每日5:00-23:00
  ----------------------------------------------------------------------*/
  function f_bank_chg_total(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2;
  ----------------------------------------------------------------------*/
  -----------平帐调用-----------------------------------------------------
  function f_bank_chg_total_pz(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2;
  /*银行实时缴费冲正----------------------------------------------------------------------
   p_bankid:银行代码
   p_transno:待撤销交易流水
   p_date :银行交易日期
   return：
         6：交易不存在
         21：数据库操作错
         22：其他错误；
  ------------------------------------------------------------------------------------------*/
  function f_bank_discharged(p_bankid  in varchar2,
                            p_transno in varchar2,
                            p_meterno in varchar2,
                            p_date    in date) return number;
  /* 银行实时缴费冲正----------------------------------------------------------------------
  p_bankid:银行代码
  p_transno:待撤销交易流水
  p_date :银行交易日期
  return： */
  function f_bank_dischargeone(p_bankid  in varchar2,
                               p_transno in varchar2,
                               p_meterno in varchar2,
                               p_date    in date) return varchar2;
  --银行补销
  function f_bank_charged_total(p_bankid    in varchar2, --银行
                                p_chg_op    in varchar2, --操作员
                                p_mcode     in varchar2, --户号
                                p_chg_total in number, --缴费金额
                                p_chg_no    in varchar2, --交易流水
                                p_paydate   in varchar2 --交易日期
                                ) return number;
  --银行补销平帐
  function f_bank_charged_total_pz(p_bankid    in varchar2, --银行
                                p_chg_op    in varchar2, --操作员
                                p_mcode     in varchar2, --户号
                                p_chg_total in number, --缴费金额
                                p_chg_no    in varchar2, --交易流水
                                p_paydate   in varchar2 --交易日期
                                ) return number;
                                
  --银行对账（生成自来水对账信息）
  procedure sp_bankdz(p_date in date,p_smfid in varchar2);
  
    --判断合收表各水表水费单价是否相同
    function f_priceissame(p_pmiid  in varchar2) return varchar2;
    
   --获取用户账卡号
    function f_getcardno(p_rlcid  in varchar2) return varchar2;
    
    --翻译付款方式
    function f_getpayway(p_ppayway  in varchar2) return varchar2;
    
    --判断银行交易开关
    FUNCTION F_GETBANKSYSPARA(P_BANKID IN VARCHAR2) RETURN VARCHAR2;
    
    --设置银行交易开关
    PROCEDURE P_SETBANKSYSPARA(P_BANKID IN VARCHAR2, P_TYPE IN VARCHAR2,P_COMMIT IN VARCHAR2);
    
    --自动银行扎帐
    PROCEDURE SP_AUTOBANKZZ;
    --自动银行扎帐手动
    PROCEDURE SP_AUTOBANKZZ_手动;
        
    --自动银行平账
    PROCEDURE SP_AUTOBANKPZ(p_date in date,p_smfid in varchar2);
    
    PROCEDURE SP_AUTOBANKPZ_test(p_date in date,p_smfid in varchar2);
     
      
end ZHONGBE;
/


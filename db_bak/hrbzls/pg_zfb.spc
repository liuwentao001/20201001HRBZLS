CREATE OR REPLACE PACKAGE HRBZLS.PG_ZFB IS

  -- Author  : 刘光波
  -- Created : 2014-07-27 星期日 16:56:19
  -- Purpose : 朗新支付宝接口

  /*主程序入口
  服务编码说明 机构信息系统
  200001  欠费查询
  200002  代收缴费
  200003  用户信息查询
  200004  用户绑定通知
  200005  账单实时查询
  200006  用户缴费类型查询
  200007  余额查询
  200008  缴费记录查询
  200009  公用事业平台代扣协议维护
  200010  费控用户测算信息查询
  200011  机构接受文本服务
  */
  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB);
  /*欠费查询
  响应码
  1000  缴费单已经支付
  1001  缴费单未出账
  1002  查询的号码不合法
  1003  未欠费
  1004  缴费号码超过受理期，请至收费单位缴费。
  1005  暂时无法缴费或超过限定缴费金额，请咨询事业单位
  1006  银行代扣期间禁止缴费*/

  FUNCTION F200001(JSONSTR IN VARCHAR2) RETURN CLOB;
  --  --代收缴费
  /*2001  缴费单已经销账 缴费单已经在交纳过
  2002  缴费金额不等  报文中的金额和销账机构中需要缴纳的金额不相等
  2003  缴费号码超过受理期，请至收费单位缴费。 缴费号码超过受理期，请至收费单位缴费。
  2004  超过限定缴费金额  超过限定缴费金额
  2005  业务状态异常  业务状态异常，暂时无法缴费
  查询确认错误*/

  FUNCTION F200002(JSONSTR IN VARCHAR2) RETURN CLOB;

  --用户查询
  /*  3000  没有该条记录  销账机构没有处理过这个缴费纪录。
      3001  处理失败  销账机构处理这个缴费纪录的时候处理失败
      3002  处理状态不明确 状态不明确，可能在对账的时候来同步两边的缴费记录状态。
  */
  FUNCTION F200003(JSONSTR IN VARCHAR2) RETURN CLOB;
  --用户绑定通知
  FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB;
  --账单实时查询
  FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB;
   --用户密码修改
  FUNCTION F200006(JSONSTR IN VARCHAR2) RETURN CLOB;
  --余额查询
  FUNCTION F200007(JSONSTR IN VARCHAR2) RETURN CLOB;
  --缴费记录查询
  FUNCTION F200008(JSONSTR IN VARCHAR2) RETURN CLOB;
  --前置机状态报告
  FUNCTION F300001(JSONSTR IN VARCHAR2) RETURN CLOB;
  --缴费撤销
  FUNCTION F300002(JSONSTR IN VARCHAR2) RETURN CLOB;
  --状态报告
  FUNCTION F300003(JSONSTR IN VARCHAR2) RETURN CLOB;
  --对账
  FUNCTION F200011(JSONSTR IN VARCHAR2) RETURN CLOB;

  --文本实时推送报文
  --缴费记录文本
  --凌晨推送昨天的缴费记录
  PROCEDURE SP_JFJLFILE;
  --账单文本
  PROCEDURE SP_ZDFILE;
  --催费通知;
  PROCEDURE SP_CFTZFILE;
  /* Note:支付宝实时缴费销账过程
  Input:  p_bankid    银行编码,
          p_chg_op    收费员,
          p_mcode     水表资料号,
          p_chg_total 缴费金额*/
  FUNCTION F_BANK_CHG_TOTAL(P_BANKID     IN VARCHAR2,
                            P_CHG_OP     IN VARCHAR2,
                            P_TYPE       IN VARCHAR2,
                            P_CHG_TOTAL  IN NUMBER,
                            P_TRANS      IN VARCHAR2,
                            P_MICODE     IN VARCHAR2,
                            P_CHGNO      IN VARCHAR2,
                            P_PAYDATE    IN DATE,
                            P_BANKBILLNO OUT VARCHAR2) RETURN VARCHAR2;

procedure sp_zfbdz(p_sdate in VARCHAR2,
                   p_edate in VARCHAR2,
                   p_smfid in varchar2,
                   p_zfbid out varchar2);

procedure SP_DZ_IMP(
                    p_clob  in clob --扣款文本
                    );

procedure SP_ZFBLOG(
                    P_TYPE IN VARCHAR2,
                    P_NAME IN VARCHAR2,
                    P_GETCLOB IN CLOB,
                    P_RETNO IN VARCHAR2,
                    P_OUTCLOB IN CLOB,
                    P_STAP IN VARCHAR2
                    );
FUNCTION ERR_LOG_RET(JS         IN JSON,
                      ECODE     IN VARCHAR2, --错误码
                      ESMG      IN VARCHAR2, --错误信息
                      PCODE     IN VARCHAR2, --协议码
                      PNAME     IN VARCHAR2, --协议名称
                      PJS       IN VARCHAR2,
                      rtnCode   IN VARCHAR2,
                      stap      IN VARCHAR2,
                      P_OUTISONSTR IN CLOB) RETURN CLOB;
                      
                      
END PG_ZFB;
/


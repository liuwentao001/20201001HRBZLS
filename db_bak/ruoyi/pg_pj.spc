create or replace package pg_pj is
  --票据处理包

  --补缴收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );

  --上门收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );

  --票据 收费 单用户应收账
  /*
  p_rlids     应收账编码，多个按逗号分隔
  p_fkfs      付款类型(XJ 现金,ZP,支票
  p_cply      出票来源：SMSF 上门收费 BJSF 补缴收费
  */
  procedure pj_sf(p_rlids varchar2,  p_fkfs varchar2, p_cply varchar2);

end pg_pj;
/


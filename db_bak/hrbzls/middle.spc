CREATE OR REPLACE PACKAGE HRBZLS."MIDDLE" is
  errcode constant integer := 0;
  err001 EXCEPTION;--交费号码不存在
  err002 EXCEPTION;--特殊用户不交费
  err003 EXCEPTION;--记录已锁（如已转非实时方式处理）
  err004 EXCEPTION;--无欠费记录（水量未录入或已交费）
  err005 EXCEPTION;--金额不符
  err006 EXCEPTION;--交易不存在
  err007 EXCEPTION;--交易重复
  err008 EXCEPTION;--扎帐(或对账)时间不等于系统时间
  err009 EXCEPTION;--欠费金额大于交费金额
  err020 EXCEPTION;--数据包格式错
  err021 EXCEPTION;--数据库操作错
  err022 EXCEPTION;--其他错误
  err023 EXCEPTION;--欠费记录数超出，应到营业所缴费
  err024 EXCEPTION;--当日未扎帐
  err025 EXCEPTION;--未发送对账文件或未同步
  err026 EXCEPTION;--当日已对账

  procedure mainzb(p_tran_code in varchar2,
                    i_char in varchar2,
                    o_char out varchar2);
                    
  --向BANK_TRAN_LOG_ALL中插入日志
  procedure addlogall(p_t_code in varchar2,
                    p_i_char in varchar2,
                    p_o_char in varchar2) ;
  
  function lengthValidation(i_char in varchar2,i_start in number,i_length in number) return varchar;
  function typeValidation(i_char in varchar2,type in number) return varchar;
  function charFormat(i_char in varchar2,i_length number,i_type number,i_align number,i_stuff varchar,i_default varchar) return varchar;
  function getValueByNname(narr in arr,iarr in arr,i_name in varchar)return varchar;

end MIDDLE;
/


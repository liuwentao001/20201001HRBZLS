create or replace package "TOOLS" is

  --抄表月份
  function fgetreadmonth(p_smfid in varchar2) return varchar2;

  --取当前系统年月日'YYYY/MM/DD'
  function fgetsysdate return date;

  function getmax(n1 in number, n2 in number) return number;
  function getmin(n1 in number, n2 in number) return number;

  --创建用户编码，验证历史库中是否存在，如存在则重新生成
  procedure seq_gen_custinfo_chk(o_seq out varchar2);
  --创建用户表编码
  --用户表编码规则，2位年 + 2位月(可扩展：如13也代表1月) + 5位自动生产编码 + 1位校验位
  procedure seq_gen_custinfo(o_seq out varchar2);
  --设置seq值
  procedure seq_set(seq_name varchar2, seq_num number);
  
end tools;
/


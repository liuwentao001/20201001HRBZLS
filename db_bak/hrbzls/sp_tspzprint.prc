CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSPZPRINT" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      select
           etlbatch 托收批次号, --托收批次号
           etlmiuiid  托收凭证号, --托收凭证号
           to_char(eloutdate,'yyyy')||'   '||to_char(eloutdate,'mm')||'   '||to_char(eloutdate,'dd') 托收日期, --托收日期
           etlaccountname 全称,--用户开户名
           etlaccountno 帐号, --帐号
           etlbankidname 开户行,--开户行
           etlbankidno 开户行实际行号,--开户行实际行号
           etltsaccountname/*fpara(etltsbankid,'HM')*/ 收款开户名,--收款开户名
           etltsaccountno/*fpara(etltsbankid,'ZH')*/ 收款开户帐号,--收款开户帐号
           etltsbankidno 收款行号, --收款行号,
           etlbankid 用户托收行系统编号,--用户托收行系统编号
           etltsbankid 公司托收行系统编号,--公司托收行系统编号
           c2 ,--打印员编号
           fgetopername(c2) 打印员中文,--打印员中文
           etlje 收款金额,--收款金额
           tools.fuppernumber(round(etlje,2)) 大写,--大写
 '' 分,
          '' 角,
          '' 元,
         '' 十,
        '' 百,
         '' 千,
        '' 万,
       '' 十万,
          '' 百万,
     '' 千万,
  substr(to_char(round(etlje,2) *100),0,length(to_char(round(etlje,2) *100))-2)||'.'||substr(to_char(round(etlje,2) *100),length(to_char(round(etlje,2) *100))-1,2) 人民币代号,
           etlinvcount 发票张数,--发票张数
  replace((case when length(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)))>=116
           then substr(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)),1,116)||'等'
           else connstr_like((case when instr((ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)) end),',','　') 客户号, --客户号
           substr(max(etlrlmonth),1,4)||'年'|| substr(max(etlrlmonth),6,2)||'月份水费' 预留1,--预留1
           '30500000300201'||lpad(etlmiuiid,32,'0') 预留2,--预留2
           '预留3' 预留3,--预留3
           '预留4' 预留4,--预留4
           '预留5' 预留5,--预留5
           '预留6' 预留6,--预留6
           '预留7' 预留7,--预留7
           1 预留8,--预留8
           1 预留9,--预留9
           1 预留10--预留10
    from reclist t0,
         entrustlist t,
         entrustlog  t1,
         pbparmtemp  t2
   where
      --instr(ETLRLIDPIID, t0.rlid )>0
      t0.rlentrustseqno= etlseqno
      and t1.elbatch=t.etlbatch
      and  c4 = etlseqno
      group by etlbatch,etlmiuiid,eloutdate,etlaccountname,etlaccountno,etlbankid,
      etlbankidname,etlbankidno,etltsbankidno,etltsbankid,etltsaccountno,etltsaccountname,c2,etlje,etlinvcount,c3
          order by to_number(etlmiuiid);
  end ;
/


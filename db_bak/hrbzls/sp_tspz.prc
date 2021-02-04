CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSPZ" (
                  o_base out tools.out_base) is
  begin
    open o_base for
            select
            max(ciname2) 发票用户名,
            substr(to_char(sysdate,'yyyymmdd') ,1,4 ) ||'  '||substr(to_char(sysdate,'yyyymmdd') ,5,2 )||'      22'  年月日,
            '上月行度      '||to_char(max(rlscode))||'      立方米      '||to_char(max(rlsl))||'      '||tools.fformatnum(sum(nvl(rdDJ,0)*RDPMDSCALE),2)||CHR(10)||CHR(10)||'本月行度      '||to_char(max(rlecode))  水量明细,
            '水费    '||tools.fformatnum(max(ETLSFJE) ,2)||CHR(10)||CHR(10)||'滞纳金    '||  tools.fformatnum(max(nvl(ETLSFZNJ,0)),2) ||CHR(10)||CHR(10)||'合计    '||  tools.fformatnum( ROUND(max(ETLSFJE + ETLSFZNJ ) ,2),2)  费用明细,
            '￥    ' ||tools.fformatnum( ROUND(    max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0))  ,2)   ,2 )  合计,
             tools.fuppernumber(ROUND(    max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0))  ,2)  )  大写,
             max(RLPAIDPER) 销帐员,
             fGetOperName(max(RLPAIDPER))   销帐员序号,
             fGetOperName(max(c2))   打印员,
             max(c2) 打印员编号,
              max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0)) 预留1,
             2 预留2,
             3 预留3,
              max(ciadr) 预留4,
             max('帐号:'||MAACCOUNTNO||'  行号:'||(select smppvalue from sysmanapara where smppid='YHHH' and smpid= mabankid ))  预留5,
             max(mibfid) 预留6,
             max(trim(to_char(MIRORDER))) 预留7,
             max( micode ) 资料号,
             '预留8' 预留8,
             '预留9' 预留9,
             '预留10' 预留10
    from entrustlist t,
         pbparmtemp  t2,
         reclist    t3,
         recdetail  t4,
         custinfo   t5,
         meterinfo  t6,
         meteraccount t7,
          entrustlog   T8
   where rlcid=ciid
     and rlid=rdid
     and elbatch=etlbatch
     and RLENTRUSTBATCH = etlbatch
     and RLENTRUSTSEQNO=ETLSEQNO
     and rlmid=miid
     and miid=mamid(+)
     and c4 = etlbatch
     and c5 = etlmcode
     and rlcd='DE'
     and rdpaidflag='Y'
     and ((instr(etlpiid, '01') > 0 AND elchargetype='D' ) or ( (instr(etlrlidpiid, rlid||',01/02')>0 or instr(etlrlidpiid, rlid||',02/01')>0   or instr(etlrlidpiid, rlid||',01')>0     ) AND elchargetype='T' ) )
     and rdpiid='01'
     group by rlid,rdpiid,c3
     order by c3 ;
  end ;
/


CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSPZ" (
                  o_base out tools.out_base) is
  begin
    open o_base for
            select
            max(ciname2) ��Ʊ�û���,
            substr(to_char(sysdate,'yyyymmdd') ,1,4 ) ||'  '||substr(to_char(sysdate,'yyyymmdd') ,5,2 )||'      22'  ������,
            '�����ж�      '||to_char(max(rlscode))||'      ������      '||to_char(max(rlsl))||'      '||tools.fformatnum(sum(nvl(rdDJ,0)*RDPMDSCALE),2)||CHR(10)||CHR(10)||'�����ж�      '||to_char(max(rlecode))  ˮ����ϸ,
            'ˮ��    '||tools.fformatnum(max(ETLSFJE) ,2)||CHR(10)||CHR(10)||'���ɽ�    '||  tools.fformatnum(max(nvl(ETLSFZNJ,0)),2) ||CHR(10)||CHR(10)||'�ϼ�    '||  tools.fformatnum( ROUND(max(ETLSFJE + ETLSFZNJ ) ,2),2)  ������ϸ,
            '��    ' ||tools.fformatnum( ROUND(    max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0))  ,2)   ,2 )  �ϼ�,
             tools.fuppernumber(ROUND(    max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0))  ,2)  )  ��д,
             max(RLPAIDPER) ����Ա,
             fGetOperName(max(RLPAIDPER))   ����Ա���,
             fGetOperName(max(c2))   ��ӡԱ,
             max(c2) ��ӡԱ���,
              max(nvl(ETLSFJE,0) + nvl(ETLSFZNJ,0)) Ԥ��1,
             2 Ԥ��2,
             3 Ԥ��3,
              max(ciadr) Ԥ��4,
             max('�ʺ�:'||MAACCOUNTNO||'  �к�:'||(select smppvalue from sysmanapara where smppid='YHHH' and smpid= mabankid ))  Ԥ��5,
             max(mibfid) Ԥ��6,
             max(trim(to_char(MIRORDER))) Ԥ��7,
             max( micode ) ���Ϻ�,
             'Ԥ��8' Ԥ��8,
             'Ԥ��9' Ԥ��9,
             'Ԥ��10' Ԥ��10
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


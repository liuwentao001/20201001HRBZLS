CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSPZPRINT" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      select
           etlbatch �������κ�, --�������κ�
           etlmiuiid  ����ƾ֤��, --����ƾ֤��
           to_char(eloutdate,'yyyy')||'   '||to_char(eloutdate,'mm')||'   '||to_char(eloutdate,'dd') ��������, --��������
           etlaccountname ȫ��,--�û�������
           etlaccountno �ʺ�, --�ʺ�
           etlbankidname ������,--������
           etlbankidno ������ʵ���к�,--������ʵ���к�
           etltsaccountname/*fpara(etltsbankid,'HM')*/ �տ����,--�տ����
           etltsaccountno/*fpara(etltsbankid,'ZH')*/ �տ���ʺ�,--�տ���ʺ�
           etltsbankidno �տ��к�, --�տ��к�,
           etlbankid �û�������ϵͳ���,--�û�������ϵͳ���
           etltsbankid ��˾������ϵͳ���,--��˾������ϵͳ���
           c2 ,--��ӡԱ���
           fgetopername(c2) ��ӡԱ����,--��ӡԱ����
           etlje �տ���,--�տ���
           tools.fuppernumber(round(etlje,2)) ��д,--��д
 '' ��,
          '' ��,
          '' Ԫ,
         '' ʮ,
        '' ��,
         '' ǧ,
        '' ��,
       '' ʮ��,
          '' ����,
     '' ǧ��,
  substr(to_char(round(etlje,2) *100),0,length(to_char(round(etlje,2) *100))-2)||'.'||substr(to_char(round(etlje,2) *100),length(to_char(round(etlje,2) *100))-1,2) ����Ҵ���,
           etlinvcount ��Ʊ����,--��Ʊ����
  replace((case when length(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)))>=116
           then substr(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)),1,116)||'��'
           else connstr_like((case when instr((ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)) end),',','��') �ͻ���, --�ͻ���
           substr(max(etlrlmonth),1,4)||'��'|| substr(max(etlrlmonth),6,2)||'�·�ˮ��' Ԥ��1,--Ԥ��1
           '30500000300201'||lpad(etlmiuiid,32,'0') Ԥ��2,--Ԥ��2
           'Ԥ��3' Ԥ��3,--Ԥ��3
           'Ԥ��4' Ԥ��4,--Ԥ��4
           'Ԥ��5' Ԥ��5,--Ԥ��5
           'Ԥ��6' Ԥ��6,--Ԥ��6
           'Ԥ��7' Ԥ��7,--Ԥ��7
           1 Ԥ��8,--Ԥ��8
           1 Ԥ��9,--Ԥ��9
           1 Ԥ��10--Ԥ��10
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


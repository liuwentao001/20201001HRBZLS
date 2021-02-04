CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSSFPRINT" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 select
           max(etlbatch) �������κ�, --�������κ�
           max(etlpzno) ����ƾ֤��, --����ƾ֤��
           max(to_char(eloutdate,'yyyy')) ��,
           max(to_char(eloutdate,'mm')) ��,
           max(to_char(eloutdate,'dd')) ��,
           max(to_char(eloutdate,'yyyy')||'/'||to_char(eloutdate,'mm')||'/'||to_char(eloutdate,'dd')) ��ӡ����,
           to_char(max(t0.rldate ),'yyyy')||'  '||to_char(max(t0.rldate ),'mm')||'  '||to_char(max(t0.rldate ),'dd') Ӧ��������,-- Ӧ��������
           '����' �տʽ,
          max(t0.rlmcode) �ͻ����� ,--�ͻ�����
           max(t0.rlcname) �û��� , --�û���
           max(t0.rlmadr)  ˮ���ַ ,--ˮ���ַ
           max(RLBFID) ����,
           (case when trim(max(rltel)) is not null then 'tel:'||trim(max(rltel))
                when trim(max(rltel )) is  null and trim(max(rlmtel)) is not null  then 'tel:'||trim(max(rlmtel))
                else '' end) �绰,--�绰
           max(RLRPER) ����Ա,
           '�����·�'  �����·ݱ���, --�����·ݱ���
           max(substr(t0.rlmonth,1,4)||substr(t0.rlmonth,6,2)) Ӧ���·�, --Ӧ���·�
           '����' �������,--�������
           max(t0.rlscodechar)  ����,--����
           'ֹ��' ֹ�����,--ֹ�����
           max(t0.rlecodechar)  ֹ��,--ֹ��
           'ˮ��' ˮ������,--ˮ������
           max(t3.rdsl*RDPMDSCALE )    ˮ��,--ˮ��
           '����' ���۱���,--���۱���
           sum(t3.rddj) ����,--����
           'ˮ��' ˮ�ѱ���,--ˮ�ѱ���
           sum(case when rdpiid='01' then t3.rdje else 0 end)  ˮ��,--ˮ��
           tools.fuppernumber(round(   sum(case when rdpiid='01' then t3.rdje else 0 end)  ,2)  ) ˮ�Ѵ�д,--��д
           tools.fformatnum( round(   sum(t3.rdje)  ,2),2) ���,--ʵ��
           tools.fuppernumber(round(   sum(t3.rdje)  ,2)  ) ����д,--��д
           max(c2) c2,--��ӡԱ���
           max(c3) c3, --˳���
           '��������' ��ע,
           fgetopername( max(c2)) ��ӡԱ����,--��ӡԱ����
           'Ԥ��1' Ԥ��1,--Ԥ��1
           'Ԥ��2' Ԥ��2,--Ԥ��2
           'Ԥ��3' Ԥ��3,--Ԥ��3
           'Ԥ��4' Ԥ��4,--Ԥ��4
           'Ԥ��5' Ԥ��5,--Ԥ��5
           'Ԥ��6' Ԥ��6,--Ԥ��6
           'Ԥ��7' Ԥ��7,--Ԥ��7
           1 Ԥ��8,--Ԥ��8
           1 Ԥ��9,--Ԥ��9
           1 Ԥ��10--Ԥ��10

    from reclist t0,
         recdetail t3,
         entrustlist t,
         entrustlog  t1,
         pbparmtemp  t2
   where
      t0.rlid = c5
      --t0.rlentrustseqno= etlseqno
      and t0.rlid=t3.rdid
      --and t3.rdpiid='01'
      and t1.elbatch=t.etlbatch
      and  c4 = etlseqno
      group by rlid
           order by c3 ;
  end ;
/


CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSWSFPRINT" (
                  o_base out tools.out_base) is
  begin
    open o_base for

 select
           max(etlbatch) �������κ�, --�������κ�
           etlmiuiid ����ƾ֤��, --����ƾ֤��
           max(to_char(eloutdate,'yyyy')) ��,
           max(to_char(eloutdate,'mm')) ��,
           max(to_char(eloutdate,'dd')) ��,
           max(to_char(eloutdate,'yyyy')||'/'||to_char(eloutdate,'mm')||'/'||to_char(eloutdate,'dd')) ��ӡ����,
           to_char(max(t3.rldate ),'yyyy')||'  '||to_char(max(t3.rldate ),'mm')||'  '||to_char(max(t3.rldate ),'dd') Ӧ��������,-- Ӧ��������
          ''�տʽ,
          max(t3.rlmcode) �ͻ����� ,--�ͻ�����
           max(t3.rlcname) �û��� , --�û���
           max(t3.rlmadr)  ˮ���ַ ,--ˮ���ַ
           max(RLBFID) ����,
           (case when trim(max(rltel)) is not null then 'tel:'||trim(max(rltel))
                when trim(max(rltel )) is  null and trim(max(rlmtel)) is not null  then 'tel:'||trim(max(rlmtel))
                else '' end) �绰,--�绰
           max(RLRPER) ����Ա,
           fgetopername( max(c2))  �����·ݱ���, --�����·ݱ���
         fgetopername( max(c2)) Ӧ���·�, --Ӧ���·�
           sp_getdjmx(etlmiuiid,max(etlseqno),1)  �������,--�������
         sp_getdjmx(etlmiuiid,max(etlseqno),2)  ����,--����
           sp_getdjmx(etlmiuiid,max(etlseqno),3)  ֹ�����,--ֹ�����
           ''  ֹ��,--ֹ��
           'ˮ��' ˮ������,--ˮ������
           max(etlsl  )    ˮ��,--ˮ��
           '��ˮ�����' ���۱���,--���۱���
           '' ����,--����
           '��ˮ�����' ˮ�ѱ���,--ˮ�ѱ���
            max(etlsl *F_GETTSDJ(etlseqno)  )ˮ��,--ˮ��
           tools.fuppernumber(          max(F_GETTSJE(etlseqno ,etlmiuiid)  ) )ˮ�Ѵ�д,--��д
                  max(F_GETTSJE(etlseqno ,etlmiuiid)  ) ���,--ʵ��
           tools.fuppernumber(          max(F_GETTSJE(etlseqno ,etlmiuiid)  )) ����д,--��д
         -- max(c2) c2,--��ӡԱ���x
        --   max(c3) c3, --˳���
          fgetopername( max(c2)) ��ע,
      --     fgetopername( max(c2)) ��ӡԱ����,--��ӡԱ����
           max( etlaccountno)  Ԥ��1,--Ԥ��1
             max( etlbankidname ) Ԥ��2,--Ԥ��2
               '�������й�ˮ���޹�˾' Ԥ��3,--Ԥ��3
             '�����������о��ÿ�����'  Ԥ��4,--Ԥ��4
         '32201997591050682841'  Ԥ��5,--Ԥ��5
          ''  Ԥ��6,--Ԥ��6
           fgetopername( max(c2)) Ԥ��7,--Ԥ��7
             1 Ԥ��8,--Ԥ��8
           1 Ԥ��9,--Ԥ��9
           1 Ԥ��10--Ԥ��10

   from reclist t3,
         entrustlist t,
         entrustlog  t1,
        pbparmtemp  t2
   where
      --instr(ETLRLIDPIID, t3.rlid )>0
      t3.rlentrustseqno= etlseqno
      and t1.elbatch=t.etlbatch
    and  c4 = etlmiuiid
      group by etlmiuiid order by to_number(etlmiuiid) ;
  end ;
/


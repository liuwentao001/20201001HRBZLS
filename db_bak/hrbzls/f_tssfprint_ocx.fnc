CREATE OR REPLACE FUNCTION HRBZLS."F_TSSFPRINT_OCX" (p_rlid in varchar2,p_batch in varchar2,p_modelno in varchar2)  return varchar2  is

v_invprintstr varchar2(32767);
  begin
select  trim(to_char(lengthb( constructhd||constructdt ),'0000000000'))||
        trim(to_char(lengthb( contentstrorder||contentstr ),'0000000000'))||
        constructhd||
        constructdt||
        contentstrorder||
        contentstr into v_invprintstr
          from

   ( select
replace(
connstr(
 trim(�������κ�  )||'^'
||trim(����ƾ֤�� )||'^'
||trim(��  )||'^'
||trim(��  )||'^'
||trim(��  )||'^'
||trim(��ӡ����  )||'^'
||trim(Ӧ��������  )||'^'
||trim(�տʽ  )||'^'
||trim(�ͻ�����  )||'^'
||trim(�û��� )||'^'
||trim(ˮ���ַ )||'^'
||trim(���� )||'^'
||trim(�绰 )||'^'
||trim(����Ա )||'^'
||trim(�����·ݱ��� )||'^'
||trim(Ӧ���·� )||'^'
||trim(������� )||'^'
||trim(���� )||'^'
||trim(ֹ����� )||'^'
||trim(ֹ�� )||'^'
||trim(ˮ������ )||'^'
||trim(ˮ�� )||'^'
||trim(���۱���)||'^'
||trim(���� )||'^'
||trim(ˮ�ѱ��� )||'^'
||trim(ˮ�� )||'^'
||trim(ˮ�Ѵ�д )||'^'
||trim(��� )||'^'
||trim(����д )||'^'
||trim(c2 )||'^'
||trim(c3 )||'^'
||trim(��ע )||'^'
||trim(��ӡԱ���� )||'^'
||trim(Ԥ��1 )||'^'
||trim(Ԥ��2 )||'^'
||trim(Ԥ��3 )||'^'
||trim(Ԥ��4 )||'^'
||trim(Ԥ��5 )||'^'
||trim(Ԥ��6 )||'^'
||trim(Ԥ��7 )||'^'
||trim(Ԥ��8 )||'^'
||trim(Ԥ��9 )||'^'
||trim(Ԥ��10)
||'|' )
,'|/','|') contentstr
from
(
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
           max('c2') c2,--��ӡԱ���
           max('c3') c3, --˳���
           '��������' ��ע,
           fgetopername( max('c2')) ��ӡԱ����,--��ӡԱ����
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
         entrustlog  t1/*,
         pbparmtemp  t2*/
   where
        t0.rlid=p_rlid
      /*t0.rlid = c5*/
      and t0.rlentrustseqno= etlseqno
      and t0.rlid=t3.rdid
      --and t3.rdpiid='01'
      and t1.elbatch=t.etlbatch
      and etlseqno = p_batch
      --and  c4 = etlseqno
      group by rlid
           order by c3
          )
)  a,
(
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(t.ptdfontalign)||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;
    return v_invprintstr;

  end ;
/


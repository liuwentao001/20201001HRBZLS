create or replace force view hrbzls.view_�ɷѲ�ѯ as
select pbatch,--�ɷѽ�������
       ppriid,--���������
       max(pdate) pdate,--�շ�����
       sum(pm.ppayment) ppayment,--������
       sum(pm.psavingbq) psavingbq,--���ڷ���Ԥ����
       sum(pspje) pspje,--���ʽ�������ʽ�����ˮ�ѣ����ʽ����Ϊˮ�ѽ������Ԥ����Ϊ0��
       FGETSYSMANAFRAME(max(pposition)) pposition, --�ɷѻ�����Ӫҵ�������У�
       FGETOPERNAME(max(pper)) pper, --������Ա
       decode(max(ptrans),'B','����','��̨') ptrans--�ɷ�����
from payment pm
where preverseflag='N'
      and (pposition like '02%' or pposition like '03%')
      --and ppriid='3124089728'
group by pbatch,ppriid
having sum(pm.ppayment)<>0
order by pdate desc
;


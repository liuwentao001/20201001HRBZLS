create or replace force view hrbzls.view_Ӧ�ղ�ѯ as
select rlmonth,--Ƿ���·�
       rldate,--�������
       trunc(rlday) rlday,--��������
       rl.rlscode,--�����ж�
       rl.rlecode,--�����ж�
       rlsl,--ˮ��
       rd.dj,--����
       rd.charge1,--ˮ��
       rd.charge2,--��ˮ�����
       rd.charge3,--ˮ��Դ��
       rd.chargetotal,--�ϼ�ˮ��
       rl.rltrans,--Ӧ������
       mi.micode,--�û����
       mi.mipriid,--�����
       mi.mistatus,--ˮ��״̬
       rlpfid,--�û����
       md.mdno,--������
       rlpaidflag--���˱�־

from reclist rl,view_reclist_charge rd,meterinfo mi,meterdoc md
where rl.rlid=rd.rdid
      and rlmid=miid
      and mi.miid=md.mdmid
      --and rl.rlpaidflag='N'
      and rl.rlreverseflag='N'
      and rl.rlbadflag='N'
      and rlje>0
      and rltrans not in (lower('u'), lower('v'), '13', '14', '21','23')
order by   rlday desc,miid,mdno
;


create or replace force view hrbzls.v_ˮ������ͳ�Ʊ� as
select
--����ˮ����ͳ��ˮ��ֻ�������������Դ
  A.Ӫ����˾,
  sum(DECODE(A.����,'����������ˮ',����,0)) ����������ˮ,
  sum(DECODE(A.����,'����ҵ��������',����,0)) ����ҵ��������,
  sum(DECODE(A.����,'�̷�',����,0)) �̷�,
  sum(DECODE(A.����,'���ݲ���ҵ',����,0)) ���ݲ���ҵ,
  sum(DECODE(A.����,'��ҵ',����,0)) ��ҵ,
  sum(DECODE(A.����,'�ߵ�ϴԡ',����,0)) �ߵ�ϴԡ

from
(select
MISMFID Ӫ����˾,
fgetpricename(substr(mi.mipfid,1,1)) ����,
s.smsname ״��,
sum(decode(miid,mi.mipriid,1,0)) hs,
count(mi.miid) ����
from meterinfo mi,sysmeterstatus s
where mi.mistatus=s.smsid(+)
and mi.mistatus not in ('28','31','32','7','34'��'33')
--and mi.mistatus ='1'   --��������
group by mi.MISMFID,fgetpricename(substr(mi.mipfid,1,1)),s.smsname
) A

group by Ӫ����˾
order by Ӫ����˾
;


create or replace force view hrbzls.v_ˮ��ھ�ͳ�Ʊ� as
select
--���ھ�ͳ��ˮ��ֻ�������������Դ
  A.Ӫ����˾,
/*  A.�ھ�,*/
  sum(DECODE(A.�ھ�,0,����,0))  x0,
  sum(DECODE(A.�ھ�,13,����,0)) x13,
  sum(DECODE(A.�ھ�,15,����,0)) x15,
  sum(DECODE(A.�ھ�,20,����,0)) x20,
  sum(DECODE(A.�ھ�,25,����,0)) x25,
  sum(DECODE(A.�ھ�,32,����,0)) x32,
  sum(DECODE(A.�ھ�,40,����,0)) x40,
  sum(DECODE(A.�ھ�,50,����,0)) x50,
  sum(DECODE(A.�ھ�,65,����,0)) x65,
  sum(DECODE(A.�ھ�,80,����,0)) x80,
  sum(DECODE(A.�ھ�,100,����,0)) x100,
  sum(DECODE(A.�ھ�,150,����,0)) x150,
  sum(DECODE(A.�ھ�,200,����,0)) x200,
  sum(DECODE(A.�ھ�,300,����,0)) x300,
  sum(DECODE(A.�ھ�,700,����,0)) x700,
  sum(DECODE(sign(A.�ھ�-700),1,����,0)) ����

from
(select
mi.MISMFID Ӫ����˾,
s.smsname ״��,
case
   when md.mdcaliber in (0,13,15,20,25,32,40,50,65,80,100,150,200,300,700)
     then md.mdcaliber
    else 999
  end  �ھ�,
count(mi.miid) ����
from meterinfo mi,meterdoc md,sysmeterstatus s
where mi.mistatus=s.smsid
and mi.miid=md.mdmid
and mi.mistatus not in ('28','31','32','7','34','33')
--and mi.mistatus ='1'   --��������
group by mi.MISMFID,s.smsname,md.mdcaliber
) A

group by Ӫ����˾
order by Ӫ����˾
;


create or replace force view hrbzls.vie_Ӫ������_ʵ�ճ��� as
select pahno  �����ˮ��,pahlb  �������,pahsmfid Ӫ����˾ ,pahcreper  �Ǽ���Ա,pahcredate  �Ǽ�����,pahshper  �����Ա,pahshdate  �������,pahshflag  ��˱�־,pahmid   ˮ����,pahmcode  ���Ϻ�,pahmid     �û����,pahmid   �û���,pahcname �û���,pahmadr �û���ַ ,'ʵ�ճ��������������λ'  �������,'' ���ǰ, FGETSYSMANAFRAME(t1.pahfromsmfid) �����,'N' ״̬
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO  and t1.pahfromsmfid IS NOT NULL
and t1.pahlb='G'
---���������λ
---����ԭ��
union
select pahno  �����ˮ��,pahlb  �������,pahsmfid Ӫ����˾,pahcreper  �Ǽ���Ա,pahcredate  �Ǽ�����,pahshper  �����Ա,pahshdate  �������,pahshflag  ��˱�־,pahmid   ˮ����,pahmcode  ���Ϻ�,pahmid     �û����,pahmid   �û���,pahcname �û���,pahmadr �û���ַ,'ʵ�ճ���������ԭ��'  �������,'' ���ǰ,t1.pahmemo �����,'Y' ״̬
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and t1.pahmemo IS NOT NULL
and t1.pahlb='G'
---����ˮ��
union
select pahno  �����ˮ��,pahlb  �������,pahsmfid Ӫ����˾,pahcreper  �Ǽ���Ա,pahcredate  �Ǽ�����,pahshper  �����Ա,pahshdate  �������,pahshflag  ��˱�־,pahmid   ˮ����,pahmcode  ���Ϻ�,pahmid     �û����,pahmid   �û���,pahcname �û���,pahmadr �û���ַ,'ʵ�ճ���������ˮ��'  �������,'' ���ǰ,to_char(t2.padplsl) �����,'N' ״̬
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and  nvl(t2.padplsl,0)<>0
and t1.pahlb='G'
---�ɷѽ��
union
select pahno  �����ˮ��,pahlb  �������,pahsmfid Ӫ����˾,pahcreper  �Ǽ���Ա,pahcredate  �Ǽ�����,pahshper  �����Ա,pahshdate  �������,pahshflag  ��˱�־,pahmid   ˮ����,pahmcode  ���Ϻ�,pahmid     �û����,pahmid   �û���,pahcname �û���,pahmadr �û���ַ,'ʵ�ճ������ɷѽ��'  �������,'' ���ǰ,to_char(t2.padplje) �����,'N' ״̬
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and  nvl(t2.padplje,0)<>0
and t1.pahlb='G'
;


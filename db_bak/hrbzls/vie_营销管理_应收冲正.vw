create or replace force view hrbzls.vie_Ӫ������_Ӧ�ճ��� as
select RCHNO  �����ˮ��,RCHLB  �������,RCHSMFID Ӫ����˾,RCHCREPER  �Ǽ���Ա,RCHCREDATE  �Ǽ�����,RCHSHPER  �����Ա,RCHSHDATE  �������,RCHSHFLAG  ��˱�־,RCDMID   ˮ����,RCDMCODE  ���Ϻ�,RCDCID     �û����,RCDCCODE   �û���,rcdcname �û���,rcdcadr �û���ַ ,'Ӧ�ճ��������������λ'  �������,'' ���ǰ, FGETSYSMANAFRAME(t1.RCHSMFID) �����,'N' ״̬
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and t1.RCHSMFID IS NOT NULL
and t1.RCHLB='G'
---���������λ
---��ע
union
select RCHNO  �����ˮ��,RCHLB  �������,RCHSMFID Ӫ����˾,RCHCREPER  �Ǽ���Ա,RCHCREDATE  �Ǽ�����,RCHSHPER  �����Ա,RCHSHDATE  �������,RCHSHFLAG  ��˱�־,RCDMID   ˮ����,RCDMCODE  ���Ϻ�,RCDCID     �û����,RCDCCODE   �û���,rcdcname �û���,rcdcadr �û���ַ,'Ӧ�ճ�������ע'  �������,'' ���ǰ,t2.rcdmemo �����,'N' ״̬
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and t2.rcdmemo IS NOT NULL
and t1.RCHLB='G'

---Ӧ�ս��
union
select RCHNO  �����ˮ��,RCHLB  �������,RCHSMFID Ӫ����˾,RCHCREPER  �Ǽ���Ա,RCHCREDATE  �Ǽ�����,RCHSHPER  �����Ա,RCHSHDATE  �������,RCHSHFLAG  ��˱�־,RCDMID   ˮ����,RCDMCODE  ���Ϻ�,RCDCID     �û����,RCDCCODE   �û���,rcdcname �û���,rcdcadr �û���ַ,'Ӧ�ճ�����Ӧ�ս��'  �������,'' ���ǰ,to_char(t2.rcdje) �����,'Y' ״̬
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and  nvl(t2.rcdje,0)<>0
and t1.RCHLB='G'
;


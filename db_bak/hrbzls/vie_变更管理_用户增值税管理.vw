create or replace force view hrbzls.vie_�������_�û���ֵ˰���� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�û���ֵ˰�����Ƿ���ֵ˰'  �������,decode(t3.miiftax,'Y','��','N','��') ���ǰ,decode(t2.miiftax,'Y','��','N','��') �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miiftax IS NOT NULL AND t3.miiftax IS NOT NULL AND t2.miiftax <> t3.miiftax) OR (t2.miiftax IS NULL AND t3.miiftax IS NOT NULL) OR (t2.miiftax IS NOT NULL AND t3.miiftax IS NULL))
and t1.cchlb='33'
---�Ƿ���ֵ˰
---��ֵ˰��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�û���ֵ˰������ֵ˰��'  �������,t3.mitaxno ���ǰ,t2.mitaxno �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mitaxno IS NOT NULL AND t3.mitaxno IS NOT NULL AND t2.mitaxno <> t3.mitaxno) OR (t2.mitaxno IS NULL AND t3.mitaxno IS NOT NULL) OR (t2.mitaxno IS NOT NULL AND t3.mitaxno IS NULL))
and t1.cchlb='33'
;


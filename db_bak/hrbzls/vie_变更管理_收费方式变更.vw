create or replace force view hrbzls.vie_�������_�շѷ�ʽ��� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�շѷ�ʽ������շѷ�ʽ'  �������,FGETSYSCHARGETYPE(t3.michargetype) ���ǰ,FGETSYSCHARGETYPE(t2.michargetype) �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.michargetype IS NOT NULL AND t3.michargetype IS NOT NULL AND t2.michargetype <> t3.michargetype) OR (t2.michargetype IS NULL AND t3.michargetype IS NOT NULL) OR (t2.michargetype IS NOT NULL AND t3.michargetype IS NULL))
and t1.cchlb='C'
---�շѷ�ʽ
---����˵��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�շѷ�ʽ���������˵��'  �������,'' ���ǰ,ccdappnote �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='C'
;


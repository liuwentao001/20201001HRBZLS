create or replace force view hrbzls.vie_�������_����� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ ,'����ϣ�ˮ��״̬'  �������,FGETSYSCUSTSTATUS(t3.mistatus) ���ǰ,FGETSYSCUSTSTATUS(t2.mistatus) �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mistatus IS NOT NULL-- ( (t2.mistatus IS NOT NULL AND t3.mistatus IS NOT NULL AND t2.mistatus <> t3.mistatus) OR (t2.mistatus IS NULL AND t3.mistatus IS NOT NULL) OR (t2.mistatus IS NOT NULL AND t3.mistatus IS NULL))
and t1.cchlb='17'
union
---����ԭ��
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾��CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'����ϣ�����ԭ��'  �������,'' ���ǰ,FGETSYSFACELIST2(t2.miface2) �����, 'N'   ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and miface2 is not null
and t1.cchlb='17'
---ָ��ˮ��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾��CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'����ϣ�ָ��ˮ��'  �������,to_char(t3.micolumn5) ���ǰ,to_char(t2.micolumn5) �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.micolumn5 IS NOT NULL AND t3.micolumn5 IS NOT NULL AND t2.micolumn5 <> t3.micolumn5) OR (t2.micolumn5 IS NULL AND t3.micolumn5 IS NOT NULL) OR (t2.micolumn5 IS NOT NULL AND t3.micolumn5 IS NULL))
and t1.cchlb='17'
---����˵��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾��CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'����ϣ�����˵��'  �������,'' ���ǰ,ccdappnote �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='17'
---��ע��Ϣ
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'����ϣ���ע��Ϣ'  �������,t3.mimemo ���ǰ, t2.mimemo �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='17'
;


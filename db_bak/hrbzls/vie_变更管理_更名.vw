create or replace force view hrbzls.vie_�������_���� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�������û���'  �������,t3.ciname ���ǰ,t2.ciname �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciname IS NOT NULL AND t3.ciname IS NOT NULL AND t2.ciname <> t3.ciname) OR (t2.ciname IS NULL AND t3.ciname IS NOT NULL) OR (t2.ciname IS NOT NULL AND t3.ciname IS NULL))
and t1.cchlb='B'
union
---֤������
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'������֤������'  �������,decode(t3.ciidentitylb,'NULL','','1','���֤','2','��ʻ֤') ���ǰ,decode(t2.ciidentitylb,'NULL','','1','���֤','2','��ʻ֤') �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NOT NULL AND t2.ciidentitylb <> t3.ciidentitylb) OR (t2.ciidentitylb IS NULL AND t3.ciidentitylb IS NOT NULL) OR (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NULL))
and t1.cchlb='B'
---֤������
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'������֤������'  �������,t3.ciidentityno ���ǰ,t2.ciidentityno �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NOT NULL AND t2.ciidentityno <> t3.ciidentityno) OR (t2.ciidentityno IS NULL AND t3.ciidentityno IS NOT NULL) OR (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NULL))
and t1.cchlb='B'
---��ϵ��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'��������ϵ��'  �������,t3.ciconnectper ���ǰ,t2.ciconnectper �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciconnectper IS NOT NULL AND t3.ciconnectper IS NOT NULL AND t2.ciconnectper <> t3.ciconnectper) OR (t2.ciconnectper IS NULL AND t3.ciconnectper IS NOT NULL) OR (t2.ciconnectper IS NOT NULL AND t3.ciconnectper IS NULL))
and t1.cchlb='B'
---��ϵ�绰
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'��������ϵ�绰'  �������,t3.ciconnecttel ���ǰ,t2.ciconnecttel �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciconnecttel IS NOT NULL AND t2.ciconnecttel <> t3.ciconnecttel) OR (t2.ciconnecttel IS NULL AND t3.ciconnecttel IS NOT NULL) OR (t2.ciconnecttel IS NOT NULL AND t3.ciconnecttel IS NULL))
and t1.cchlb='B'
---�ƶ��绰
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�������ƶ��绰'  �������,t3.cimtel ���ǰ,t2.cimtel �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.cimtel IS NOT NULL AND t3.cimtel IS NOT NULL AND t2.cimtel <> t3.cimtel) OR (t2.cimtel IS NULL AND t3.cimtel IS NOT NULL) OR (t2.cimtel IS NOT NULL AND t3.cimtel IS NULL))
and t1.cchlb='B'
---Ʊ����
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'������Ʊ����'  �������,t3.miname ���ǰ,t2.miname �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miname IS NOT NULL AND t3.miname IS NOT NULL AND t2.miname <> t3.miname) OR (t2.miname IS NULL AND t3.miname IS NOT NULL) OR (t2.miname IS NOT NULL AND t3.miname IS NULL))
and t1.cchlb='B'
---סլ�绰
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'������סլ�绰'  �������,t3.citel1 ���ǰ,t2.citel1 �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.citel1 IS NOT NULL AND t3.citel1 IS NOT NULL AND t2.citel1 <> t3.citel1) OR (t2.citel1 IS NULL AND t3.citel1 IS NOT NULL) OR (t2.citel1 IS NOT NULL AND t3.citel1 IS NULL))
and t1.cchlb='B'
---�칫�绰
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�������칫�绰'  �������,t3.citel2 ���ǰ,t2.citel2 �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.citel2 IS NOT NULL AND t3.citel2 IS NOT NULL AND t2.citel2 <> t3.citel2) OR (t2.citel2 IS NULL AND t3.citel2 IS NOT NULL) OR (t2.citel2 IS NOT NULL AND t3.citel2 IS NULL))
and t1.cchlb='B'
---�Ƿ����
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�������Ƿ����'  �������,decode(t3.ciifsms,'Y','��','N','��') ���ǰ,decode(t2.ciifsms,'Y','��','N','��') �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciifsms IS NOT NULL AND t3.ciifsms IS NOT NULL AND t2.ciifsms <> t3.ciifsms) OR (t2.ciifsms IS NULL AND t3.ciifsms IS NOT NULL) OR (t2.ciifsms IS NOT NULL AND t3.ciifsms IS NULL))
and t1.cchlb='B'

---����˵��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'����������˵��'  �������,'' ���ǰ,ccdappnote �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='B'
---�쵼���
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'�������쵼���'  �������,'' ���ǰ, t2.ccdfilashnote �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  t2.ccdfilashnote IS NOT NULL
and t1.cchlb='B'
;


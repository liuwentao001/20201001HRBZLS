create or replace force view hrbzls.vie_�������_���ձ�ά�� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'���ձ�ά����֤������'  �������,decode(t3.ciidentitylb,'NULL','��','1','���֤','2','��ʻ֤') ���ǰ,decode(t2.ciidentitylb,'NULL','��','1','���֤','2','��ʻ֤') �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NOT NULL AND t2.ciidentitylb <> t3.ciidentitylb) OR (t2.ciidentitylb IS NULL AND t3.ciidentitylb IS NOT NULL) OR (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NULL))
and t1.cchlb='Y'
---֤������
---֤������
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'���ձ�ά����֤������'  �������,t3.ciidentityno ���ǰ,t2.ciidentityno �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NOT NULL AND t2.ciidentityno <> t3.ciidentityno) OR (t2.ciidentityno IS NULL AND t3.ciidentityno IS NOT NULL) OR (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NULL))
and t1.cchlb='Y'
---���ձ��־
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'���ձ�ά�������ձ��־'  �������,decode(t3.mipriflag,'Y','��','N','��') ���ǰ,decode(t2.mipriflag,'Y','��','N','��') �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mipriflag IS NOT NULL AND t3.mipriflag IS NOT NULL AND t2.mipriflag <> t3.mipriflag) OR (t2.mipriflag IS NULL AND t3.mipriflag IS NOT NULL) OR (t2.mipriflag IS NOT NULL AND t3.mipriflag IS NULL))
and t1.cchlb='Y'
---���������
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'���ձ�ά�������������'  �������,t3.mipriid ���ǰ,t2.mipriid �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mipriid IS NOT NULL AND t3.mipriid IS NOT NULL AND t2.mipriid <> t3.mipriid) OR (t2.mipriid IS NULL AND t3.mipriid IS NOT NULL) OR (t2.mipriid IS NOT NULL AND t3.mipriid IS NULL))
and t1.cchlb='Y'

---��ע��Ϣ
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'���ձ�ά������ע��Ϣ'  �������,t3.mimemo ���ǰ, t2.mimemo �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='Y'
;


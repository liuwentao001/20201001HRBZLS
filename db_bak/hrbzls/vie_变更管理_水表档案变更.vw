create or replace force view hrbzls.vie_�������_ˮ������� as
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ�����������ھ�'  �������,TO_CHAR(t3.mdcaliber) ���ǰ,TO_CHAR(t2.mdcaliber) �����,'Y' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mdcaliber IS NOT NULL-- ( (t2.mdcaliber IS NOT NULL AND t3.mdcaliber IS NOT NULL AND t2.mdcaliber <> t3.mdcaliber) OR (t2.mdcaliber IS NULL AND t3.mdcaliber IS NOT NULL) OR (t2.mdcaliber IS NOT NULL AND t3.mdcaliber IS NULL))
and t1.cchlb='W'
---��ھ�
---����
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ�������������'  �������,t3.mdbrand ���ǰ,t2.mdbrand �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdbrand IS NOT NULL AND t3.mdbrand IS NOT NULL AND t2.mdbrand <> t3.mdbrand) OR (t2.mdbrand IS NULL AND t3.mdbrand IS NOT NULL) OR (t2.mdbrand IS NOT NULL AND t3.mdbrand IS NULL))
and t1.cchlb='W'
---���ͺ�
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ������������ͺ�'  �������,FGETMETERMODEL(t3.mdmodel) ���ǰ,FGETMETERMODEL(t2.mdmodel) �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdmodel IS NOT NULL AND t3.mdmodel IS NOT NULL AND t2.mdmodel <> t3.mdmodel) OR (t2.mdmodel IS NULL AND t3.mdmodel IS NOT NULL) OR (t2.mdmodel IS NOT NULL AND t3.mdmodel IS NULL))
and t1.cchlb='W'
---������
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ���������������'  �������,t3.mdno ���ǰ,t2.mdno �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdno IS NOT NULL AND t3.mdno IS NOT NULL AND t2.mdno <> t3.mdno) OR (t2.mdno IS NULL AND t3.mdno IS NOT NULL) OR (t2.mdno IS NOT NULL AND t3.mdno IS NULL))
and t1.cchlb='W'
---�ܷ��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ����������ܷ��'  �������,t3.dqsfh ���ǰ,t2.dqsfh �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqsfh IS NOT NULL AND t3.dqsfh IS NOT NULL AND t2.dqsfh <> t3.dqsfh) OR (t2.dqsfh IS NULL AND t3.dqsfh IS NOT NULL) OR (t2.dqsfh IS NOT NULL AND t3.dqsfh IS NULL))
and t1.cchlb='W'
---�ַ��
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ����������ַ��'  �������,t3.dqgfh ���ǰ,t2.dqgfh �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NOT NULL AND t2.dqgfh <> t3.dqgfh) OR (t2.dqgfh IS NULL AND t3.dqgfh IS NOT NULL) OR (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NULL))
and t1.cchlb='W'
---������
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ���������������'  �������,t3.jcgfh ���ǰ,t2.jcgfh �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NOT NULL AND t2.jcgfh <> t3.jcgfh) OR (t2.jcgfh IS NULL AND t3.jcgfh IS NOT NULL) OR (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NULL))
and t1.cchlb='W'
---Ǧ���
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ���������Ǧ���'  �������,t3.qhf ���ǰ,t2.qhf �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.qhf IS NOT NULL AND t3.qhf IS NOT NULL AND t2.qhf <> t3.qhf) OR (t2.qhf IS NULL AND t3.qhf IS NOT NULL) OR (t2.qhf IS NOT NULL AND t3.qhf IS NULL))
and t1.cchlb='W'
---��ע��Ϣ
union
select CCHNO �����ˮ��,CCHLB �������,CCHSMFID Ӫ����˾,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,t2.ciname �û���,t2.ciadr �û���ַ,'ˮ�����������ע��Ϣ'  �������,t3.mimemo ���ǰ, t2.mimemo �����,'N' ״̬
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='W'
;


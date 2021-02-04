create or replace force view hrbzls.view_custmetermdocchange_2 as
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��Ȩ��'  �������,t3.CINAME ���ǰ,t2.CINAME �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CINAME IS NOT NULL AND t3.CINAME IS NOT NULL AND t2.CINAME <> t3.CINAME) OR (t2.CINAME IS NULL AND t3.CINAME IS NOT NULL) OR (t2.CINAME IS NOT NULL AND t3.CINAME IS NULL)))
union
--���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'���'  �������,t3.MDNO ���ǰ,t2.MDNO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDNO IS NOT NULL AND t3.MDNO IS NOT NULL AND t2.MDNO <> t3.MDNO) OR (t2.MDNO IS NULL AND t3.MDNO IS NOT NULL) OR (t2.MDNO IS NOT NULL AND t3.MDNO IS NULL)))
union
--��ˮ��ַ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ��ַ'  �������,t3.MIADR ���ǰ,t2.MIADR �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIADR IS NOT NULL AND t3.MIADR IS NOT NULL AND t2.MIADR <> t3.MIADR) OR (t2.MIADR IS NULL AND t3.MIADR IS NOT NULL) OR (t2.MIADR IS NOT NULL AND t3.MIADR IS NULL)))

union
--����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'����'  �������,FGETSYSAREAFRAME(t3.MISAFID) ���ǰ,FGETSYSAREAFRAME(t2.MISAFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISAFID IS NOT NULL AND t3.MISAFID IS NOT NULL AND t2.MISAFID <> t3.MISAFID) OR (t2.MISAFID IS NULL AND t3.MISAFID IS NOT NULL) OR (t2.MISAFID IS NOT NULL AND t3.MISAFID IS NULL)))
union
--����ʽ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'����ʽ'  �������,t3.MIRTID ���ǰ,t2.MIRTID �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIRTID IS NOT NULL AND t3.MIRTID IS NOT NULL AND t2.MIRTID <> t3.MIRTID) OR (t2.MIRTID IS NULL AND t3.MIRTID IS NOT NULL) OR (t2.MIRTID IS NOT NULL AND t3.MIRTID IS NULL)))
 union
 --�շ�Ա
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�շ�Ա'  �������,t3.MICPER ���ǰ,t2.MICPER �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MICPER IS NOT NULL AND t3.MICPER IS NOT NULL AND t2.MICPER <> t3.MICPER) OR (t2.MICPER IS NULL AND t3.MICPER IS NOT NULL) OR (t2.MICPER IS NOT NULL AND t3.MICPER IS NULL)))
union
--��ҵ����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ҵ����'  �������,FGETMETERSORTFRAME(t3.MISTID) ���ǰ,FGETMETERSORTFRAME(t2.MISTID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISTID IS NOT NULL AND t3.MISTID IS NOT NULL AND t2.MISTID <> t3.MISTID) OR (t2.MISTID IS NULL AND t3.MISTID IS NOT NULL) OR (t2.MISTID IS NOT NULL AND t3.MISTID IS NULL)))
union
 --�Ƽ�����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƽ�����'  �������,t3.MIRPID ���ǰ,t2.MIRPID �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIRPID IS NOT NULL AND t3.MIRPID IS NOT NULL AND t2.MIRPID <> t3.MIRPID) OR (t2.MIRPID IS NULL AND t3.MIRPID IS NOT NULL) OR (t2.MIRPID IS NOT NULL AND t3.MIRPID IS NULL)))
union
--��λ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��λ'  �������,t3.MISIDE ���ǰ,t2.MISIDE �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISIDE IS NOT NULL AND t3.MISIDE IS NOT NULL AND t2.MISIDE <> t3.MISIDE) OR (t2.MISIDE IS NULL AND t3.MISIDE IS NOT NULL) OR (t2.MISIDE IS NOT NULL AND t3.MISIDE IS NULL)))
union
--��ˮ��ַ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ��ַ'  �������,t3.MIPOSITION ���ǰ,t2.MIPOSITION �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPOSITION IS NOT NULL AND t3.MIPOSITION IS NOT NULL AND t2.MIPOSITION <> t3.MIPOSITION) OR (t2.MIPOSITION IS NULL AND t3.MIPOSITION IS NOT NULL) OR (t2.MIPOSITION IS NOT NULL AND t3.MIPOSITION IS NULL)))
union
--��װ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��װ���'  �������,trim(to_char(t3.MIINSCODE)) ���ǰ,trim(to_char(t2.MIINSCODE)) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIINSCODE IS NOT NULL AND t3.MIINSCODE IS NOT NULL AND t2.MIINSCODE <> t3.MIINSCODE) OR (t2.MIINSCODE IS NULL AND t3.MIINSCODE IS NOT NULL) OR (t2.MIINSCODE IS NOT NULL AND t3.MIINSCODE IS NULL)))
union
--װ������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'װ������'  �������,trim(to_char(t3.MIINSDATE,'YYYYMMDD')) ���ǰ,trim(to_char(t2.MIINSDATE,'YYYYMMDD')) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIINSDATE IS NOT NULL AND t3.MIINSDATE IS NOT NULL AND t2.MIINSDATE <> t3.MIINSDATE) OR (t2.MIINSDATE IS NULL AND t3.MIINSDATE IS NOT NULL) OR (t2.MIINSDATE IS NOT NULL AND t3.MIINSDATE IS NULL)))
union
--��������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��������'  �������,trim(to_char(t3.MIREINSDATE,'YYYYMMDD')) ���ǰ,trim(to_char(t2.MIREINSDATE,'YYYYMMDD')) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIREINSDATE IS NOT NULL AND t3.MIREINSDATE IS NOT NULL AND t2.MIREINSDATE <> t3.MIREINSDATE) OR (t2.MIREINSDATE IS NULL AND t3.MIREINSDATE IS NOT NULL) OR (t2.MIREINSDATE IS NOT NULL AND t3.MIREINSDATE IS NULL)))
union
--����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'����'  �������,t3.MITYPE ���ǰ,t2.MITYPE �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MITYPE IS NOT NULL AND t3.MITYPE IS NOT NULL AND t2.MITYPE <> t3.MITYPE) OR (t2.MITYPE IS NULL AND t3.MITYPE IS NOT NULL) OR (t2.MITYPE IS NOT NULL AND t3.MITYPE IS NULL)))
union
--�ھ�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�ھ�'  �������,to_char(t3.MDCALIBER) ���ǰ,to_char(t2.MDCALIBER) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (to_char(t2.MDCALIBER) IS NOT NULL AND to_char(t3.MDCALIBER) IS NOT NULL AND to_char(t2.MDCALIBER) <> to_char(t3.MDCALIBER)) OR (to_char(t2.MDCALIBER) IS NULL AND to_char(t3.MDCALIBER) IS NOT NULL) OR (to_char(t2.MDCALIBER) IS NOT NULL AND to_char(t3.MDCALIBER) IS NULL)))
 union
--����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'����'  �������,FGETMETERBRAND(t3.MDBRAND) ���ǰ,FGETMETERBRAND(t2.MDBRAND) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDBRAND IS NOT NULL AND t3.MDBRAND IS NOT NULL AND t2.MDBRAND <> t3.MDBRAND) OR (t2.MDBRAND IS NULL AND t3.MDBRAND IS NOT NULL) OR (t2.MDBRAND IS NOT NULL AND t3.MDBRAND IS NULL)))
union
--���ͺ�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'���ͺ�'  �������,FGETMETERMODEL(t3.MDMODEL) ���ǰ,FGETMETERMODEL(t2.MDMODEL) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDMODEL IS NOT NULL AND t3.MDMODEL IS NOT NULL AND t2.MDMODEL <> t3.MDMODEL) OR (t2.MDMODEL IS NULL AND t3.MDMODEL IS NOT NULL) OR (t2.MDMODEL IS NOT NULL AND t3.MDMODEL IS NULL)))
union
--�Ƿ񿼺˱�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ񿼺˱�'  �������,t3.MIIFCHK ���ǰ,t2.MIIFCHK �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFCHK IS NOT NULL AND t3.MIIFCHK IS NOT NULL AND t2.MIIFCHK <> t3.MIIFCHK) OR (t2.MIIFCHK IS NULL AND t3.MIIFCHK IS NOT NULL) OR (t2.MIIFCHK IS NOT NULL AND t3.MIIFCHK IS NULL)))
 union
--�Ƿ��ˮ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ��ˮ'  �������,t3.MIIFWATCH ���ǰ,t2.MIIFWATCH �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFWATCH IS NOT NULL AND t3.MIIFWATCH IS NOT NULL AND t2.MIIFWATCH <> t3.MIIFWATCH) OR (t2.MIIFWATCH IS NULL AND t3.MIIFWATCH IS NOT NULL) OR (t2.MIIFWATCH IS NOT NULL AND t3.MIIFWATCH IS NULL)))
union
--IC����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'IC����'  �������,t3.MIICNO ���ǰ,t2.MIICNO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIICNO IS NOT NULL AND t3.MIICNO IS NOT NULL AND t2.MIICNO <> t3.MIICNO) OR (t2.MIICNO IS NULL AND t3.MIICNO IS NOT NULL) OR (t2.MIICNO IS NOT NULL AND t3.MIICNO IS NULL)))
union
--��ע��Ϣ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ע��Ϣ'  �������,t3.MIMEMO ���ǰ,t2.MIMEMO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NOT NULL AND t2.MIMEMO <> t3.MIMEMO) OR (t2.MIMEMO IS NULL AND t3.MIMEMO IS NOT NULL) OR (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NULL)))
union
--���ձ������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'���ձ������'  �������,t3.MIPRIID ���ǰ,t2.MIPRIID �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPRIID IS NOT NULL AND t3.MIPRIID IS NOT NULL AND t2.MIPRIID <> t3.MIPRIID) OR (t2.MIPRIID IS NULL AND t3.MIPRIID IS NOT NULL) OR (t2.MIPRIID IS NOT NULL AND t3.MIPRIID IS NULL)))
union
--���ձ��־
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'���ձ��־'  �������,t3.MIPRIFLAG ���ǰ,t2.MIPRIFLAG �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPRIFLAG IS NOT NULL AND t3.MIPRIFLAG IS NOT NULL AND t2.MIPRIFLAG <> t3.MIPRIFLAG) OR (t2.MIPRIFLAG IS NULL AND t3.MIPRIFLAG IS NOT NULL) OR (t2.MIPRIFLAG IS NOT NULL AND t3.MIPRIFLAG IS NULL)))
union
--��������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��������'  �������,trim(to_char(t3.MIUSENUM)) ���ǰ,trim(to_char(t2.MIUSENUM)) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIUSENUM IS NOT NULL AND t3.MIUSENUM IS NOT NULL AND t2.MIUSENUM <> t3.MIUSENUM) OR (t2.MIUSENUM IS NULL AND t3.MIUSENUM IS NOT NULL) OR (t2.MIUSENUM IS NOT NULL AND t3.MIUSENUM IS NULL)))
union
--������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'������'  �������,t3.CINAME2 ���ǰ,t2.CINAME2 �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CINAME2 IS NOT NULL AND t3.CINAME2 IS NOT NULL AND t2.CINAME2 <> t3.CINAME2) OR (t2.CINAME2 IS NULL AND t3.CINAME2 IS NOT NULL) OR (t2.CINAME2 IS NOT NULL AND t3.CINAME2 IS NULL)))
union
--�û���ַ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�û���ַ'  �������,t3.CIADR ���ǰ,t2.CIADR �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIADR IS NOT NULL AND t3.CIADR IS NOT NULL AND t2.CIADR <> t3.CIADR) OR (t2.CIADR IS NULL AND t3.CIADR IS NOT NULL) OR (t2.CIADR IS NOT NULL AND t3.CIADR IS NULL)))
union
--֤������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'֤������'  �������,(case when t3.CIIDENTITYLB ='1' then '���֤'
when t3.CIIDENTITYLB ='2' then '��ʻ֤'
else
'��' end)
 ���ǰ,(case when t2.CIIDENTITYLB ='1' then '���֤'
when t2.CIIDENTITYLB ='2' then '��ʻ֤'
else
'��' end) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIDENTITYLB IS NOT NULL AND t3.CIIDENTITYLB IS NOT NULL AND t2.CIIDENTITYLB <> t3.CIIDENTITYLB) OR (t2.CIIDENTITYLB IS NULL AND t3.CIIDENTITYLB IS NOT NULL) OR (t2.CIIDENTITYLB IS NOT NULL AND t3.CIIDENTITYLB IS NULL)))
union
--֤������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'֤������'  �������,t3.CIIDENTITYNO ���ǰ,t2.CIIDENTITYNO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIDENTITYNO IS NOT NULL AND t3.CIIDENTITYNO IS NOT NULL AND t2.CIIDENTITYNO <> t3.CIIDENTITYNO) OR (t2.CIIDENTITYNO IS NULL AND t3.CIIDENTITYNO IS NOT NULL) OR (t2.CIIDENTITYNO IS NOT NULL AND t3.CIIDENTITYNO IS NULL)))
union
--�ƶ��绰
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�ƶ��绰'  �������,t3.CIMTEL ���ǰ,t2.CIMTEL �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIMTEL IS NOT NULL AND t3.CIMTEL IS NOT NULL AND t2.CIMTEL <> t3.CIMTEL) OR (t2.CIMTEL IS NULL AND t3.CIMTEL IS NOT NULL) OR (t2.CIMTEL IS NOT NULL AND t3.CIMTEL IS NULL)))
union
--סլ�绰
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'סլ�绰'  �������,t3.CITEL1 ���ǰ,t2.CITEL1 �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL1 IS NOT NULL AND t3.CITEL1 IS NOT NULL AND t2.CITEL1 <> t3.CITEL1) OR (t2.CITEL1 IS NULL AND t3.CITEL1 IS NOT NULL) OR (t2.CITEL1 IS NOT NULL AND t3.CITEL1 IS NULL)))
union
--�칫�绰
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�칫�绰'  �������,t3.CITEL2 ���ǰ,t2.CITEL2 �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL2 IS NOT NULL AND t3.CITEL2 IS NOT NULL AND t2.CITEL2 <> t3.CITEL2) OR (t2.CITEL2 IS NULL AND t3.CITEL2 IS NOT NULL) OR (t2.CITEL2 IS NOT NULL AND t3.CITEL2 IS NULL)))
union
--�̶��绰3
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�̶��绰3'  �������,t3.CITEL3 ���ǰ,t2.CITEL3 �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL3 IS NOT NULL AND t3.CITEL3 IS NOT NULL AND t2.CITEL3 <> t3.CITEL3) OR (t2.CITEL3 IS NULL AND t3.CITEL3 IS NOT NULL) OR (t2.CITEL3 IS NOT NULL AND t3.CITEL3 IS NULL)))
union
--��ϵ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ϵ��'  �������,t3.CICONNECTPER ���ǰ,t2.CICONNECTPER �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CICONNECTPER IS NOT NULL AND t3.CICONNECTPER IS NOT NULL AND t2.CICONNECTPER <> t3.CICONNECTPER) OR (t2.CICONNECTPER IS NULL AND t3.CICONNECTPER IS NOT NULL) OR (t2.CICONNECTPER IS NOT NULL AND t3.CICONNECTPER IS NULL)))
union
--��ϵ�绰
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ϵ�绰'  �������,t3.CICONNECTTEL ���ǰ,t2.CICONNECTTEL �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CICONNECTTEL IS NOT NULL AND t3.CICONNECTTEL IS NOT NULL AND t2.CICONNECTTEL <> t3.CICONNECTTEL) OR (t2.CICONNECTTEL IS NULL AND t3.CICONNECTTEL IS NOT NULL) OR (t2.CICONNECTTEL IS NOT NULL AND t3.CICONNECTTEL IS NULL)))
union
--�Ƿ��ṩ���ŷ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ��ṩ���ŷ���'  �������,t3.CIIFSMS ���ǰ,t2.CIIFSMS �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIFSMS IS NOT NULL AND t3.CIIFSMS IS NOT NULL AND t2.CIIFSMS <> t3.CIIFSMS) OR (t2.CIIFSMS IS NULL AND t3.CIIFSMS IS NOT NULL) OR (t2.CIIFSMS IS NOT NULL AND t3.CIIFSMS IS NULL)))
union
--������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'������'  �������,t3.CIFILENO ���ǰ,t2.CIFILENO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIFILENO IS NOT NULL AND t3.CIFILENO IS NOT NULL AND t2.CIFILENO <> t3.CIFILENO) OR (t2.CIFILENO IS NULL AND t3.CIFILENO IS NOT NULL) OR (t2.CIFILENO IS NOT NULL AND t3.CIFILENO IS NULL)))
union
--�û���ע��Ϣ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�û���ע��Ϣ'  �������,t3.CIMEMO ���ǰ,t2.CIMEMO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIMEMO IS NOT NULL AND t3.CIMEMO IS NOT NULL AND t2.CIMEMO <> t3.CIMEMO) OR (t2.CIMEMO IS NULL AND t3.CIMEMO IS NOT NULL) OR (t2.CIMEMO IS NOT NULL AND t3.CIMEMO IS NULL)))
union
--�շѷ�ʽ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�շѷ�ʽ'  �������,fgetsyschargetype(t3.MICHARGETYPE) ���ǰ,fgetsyschargetype(t2.MICHARGETYPE) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MICHARGETYPE IS NOT NULL AND t3.MICHARGETYPE IS NOT NULL AND t2.MICHARGETYPE <> t3.MICHARGETYPE) OR (t2.MICHARGETYPE IS NULL AND t3.MICHARGETYPE IS NOT NULL) OR (t2.MICHARGETYPE IS NOT NULL AND t3.MICHARGETYPE IS NULL)))
union
--ί����Ȩ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'ί����Ȩ��'  �������,t3.MANO ���ǰ,t2.MANO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MANO IS NOT NULL AND t3.MANO IS NOT NULL AND t2.MANO <> t3.MANO) OR (t2.MANO IS NULL AND t3.MANO IS NOT NULL) OR (t2.MANO IS NOT NULL AND t3.MANO IS NULL)))
union
--ǩԼ����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'ǩԼ����'  �������,t3.MANONAME ���ǰ,t2.MANONAME �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MANONAME IS NOT NULL AND t3.MANONAME IS NOT NULL AND t2.MANONAME <> t3.MANONAME) OR (t2.MANONAME IS NULL AND t3.MANONAME IS NOT NULL) OR (t2.MANONAME IS NOT NULL AND t3.MANONAME IS NULL)))
union
--��������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,
      '��������'  �������,
      (case when t3.michargetype='T' then '['||fsmfid2hh(t3.MABANKID)||']'||fsmfid2hm(t3.mabankid) else FGETSYSMANAFRAME(t3.MABANKID) end) ���ǰ,
      (case when t2.michargetype='T' then '['||fsmfid2hh(t2.MABANKID)||']'||fsmfid2hm(t2.mabankid) else FGETSYSMANAFRAME(t2.MABANKID) end) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t3.ccdrowno and t2.miid = t3.miid
 and ( (t2.MABANKID IS NOT NULL AND t3.MABANKID IS NOT NULL AND t2.MABANKID <> t3.MABANKID) OR (t2.MABANKID IS NULL AND t3.MABANKID IS NOT NULL) OR (t2.MABANKID IS NOT NULL AND t3.MABANKID IS NULL)))
union
--�����ʺ�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�����ʺ�'  �������,t3.MAACCOUNTNO ���ǰ,t2.MAACCOUNTNO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAACCOUNTNO IS NOT NULL AND t3.MAACCOUNTNO IS NOT NULL AND t2.MAACCOUNTNO <> t3.MAACCOUNTNO) OR (t2.MAACCOUNTNO IS NULL AND t3.MAACCOUNTNO IS NOT NULL) OR (t2.MAACCOUNTNO IS NOT NULL AND t3.MAACCOUNTNO IS NULL)))
union
--�������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�������'  �������,t3.MAACCOUNTNAME ���ǰ,t2.MAACCOUNTNAME �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAACCOUNTNAME IS NOT NULL AND t3.MAACCOUNTNAME IS NOT NULL AND t2.MAACCOUNTNAME <> t3.MAACCOUNTNAME) OR (t2.MAACCOUNTNAME IS NULL AND t3.MAACCOUNTNAME IS NOT NULL) OR (t2.MAACCOUNTNAME IS NOT NULL AND t3.MAACCOUNTNAME IS NULL)))
union
--�տ�����
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�տ�����'  �������,FGETSYSMANAFRAME(t3.MATSBANKID) ���ǰ,FGETSYSMANAFRAME(t2.MATSBANKID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MATSBANKID IS NOT NULL AND t3.MATSBANKID IS NOT NULL AND t2.MATSBANKID <> t3.MATSBANKID) OR (t2.MATSBANKID IS NULL AND t3.MATSBANKID IS NOT NULL) OR (t2.MATSBANKID IS NOT NULL AND t3.MATSBANKID IS NULL)))
union
--С��֧�����У�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'С��֧��'  �������,t3.MAIFXEZF ���ǰ,t2.MAIFXEZF �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAIFXEZF IS NOT NULL AND t3.MAIFXEZF IS NOT NULL AND t2.MAIFXEZF <> t3.MAIFXEZF) OR (t2.MAIFXEZF IS NULL AND t3.MAIFXEZF IS NOT NULL) OR (t2.MAIFXEZF IS NOT NULL AND t3.MAIFXEZF IS NULL)))
union
--�Ƿ�˰Ʊ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ�˰Ʊ'  �������,t3.MIIFTAX ���ǰ,t2.MIIFTAX �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFTAX IS NOT NULL AND t3.MIIFTAX IS NOT NULL AND t2.MIIFTAX <> t3.MIIFTAX) OR (t2.MIIFTAX IS NULL AND t3.MIIFTAX IS NOT NULL) OR (t2.MIIFTAX IS NOT NULL AND t3.MIIFTAX IS NULL)))
union
--˰��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'˰��'  �������,t3.MITAXNO ���ǰ,t2.MITAXNO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MITAXNO IS NOT NULL AND t3.MITAXNO IS NOT NULL AND t2.MITAXNO <> t3.MITAXNO) OR (t2.MITAXNO IS NULL AND t3.MITAXNO IS NOT NULL) OR (t2.MITAXNO IS NOT NULL AND t3.MITAXNO IS NULL)))
union
--ˮ��ע��Ϣ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'ˮ��ע��Ϣ'  �������,t3.MIMEMO ���ǰ,t2.MIMEMO �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NOT NULL AND t2.MIMEMO <> t3.MIMEMO) OR (t2.MIMEMO IS NULL AND t3.MIMEMO IS NOT NULL) OR (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NULL)))
union
--�Ƿ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ���'  �������,t3.MIIFMP ���ǰ,t2.MIIFMP �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFMP IS NOT NULL AND t3.MIIFMP IS NOT NULL AND t2.MIIFMP <> t3.MIIFMP) OR (t2.MIIFMP IS NULL AND t3.MIIFMP IS NOT NULL) OR (t2.MIIFMP IS NOT NULL AND t3.MIIFMP IS NULL)))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.MIPFID) ���ǰ,FGETPRICEFRAME(t2.MIPFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='N'  AND      ( (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NOT NULL AND t2.MIPFID <> t3.MIPFID) OR (t2.MIPFID IS NULL AND t3.MIPFID IS NOT NULL) OR (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NULL))))

union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID)||'����'||TO_CHAR(t3.PMDSCALE*100) ���ǰ,FGETPRICEFRAME(t2.PMDPFID)||'����'||TO_CHAR(t2.PMDSCALE*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE IS NOT NULL AND t3.PMDSCALE IS NOT NULL AND t2.PMDSCALE <> t3.PMDSCALE) OR (t2.PMDSCALE IS NULL AND t3.PMDSCALE IS NOT NULL) OR (t2.PMDSCALE IS NOT NULL AND t3.PMDSCALE IS NULL)
OR (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NOT NULL AND t2.PMDPFID <> t3.PMDPFID) OR (t2.PMDPFID IS NULL AND t3.PMDPFID IS NOT NULL) OR (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NULL)  )))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID3)||'����'||TO_CHAR(t3.PMDSCALE2*100) ���ǰ,FGETPRICEFRAME(t2.PMDPFID3)||'����'||TO_CHAR(t2.PMDSCALE2*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE2 IS NOT NULL AND t3.PMDSCALE2 IS NOT NULL AND t2.PMDSCALE2 <> t3.PMDSCALE2) OR (t2.PMDSCALE2 IS NULL AND t3.PMDSCALE2 IS NOT NULL) OR (t2.PMDSCALE2 IS NOT NULL AND t3.PMDSCALE2 IS NULL)
OR (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NOT NULL AND t2.PMDPFID2 <> t3.PMDPFID2) OR (t2.PMDPFID2 IS NULL AND t3.PMDPFID2 IS NOT NULL) OR (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NULL) )))
 union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID3)||'����'||TO_CHAR(t3.PMDSCALE3*100) ���ǰ,FGETPRICEFRAME(t2.PMDPFID3)||'����'||TO_CHAR(t2.PMDSCALE3*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE3 IS NOT NULL AND t3.PMDSCALE3 IS NOT NULL AND t2.PMDSCALE3 <> t3.PMDSCALE3) OR (t2.PMDSCALE3 IS NULL AND t3.PMDSCALE3 IS NOT NULL) OR (t2.PMDSCALE3 IS NOT NULL AND t3.PMDSCALE3 IS NULL)
OR (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NOT NULL AND t2.PMDPFID3 <> t3.PMDPFID3) OR (t2.PMDPFID3 IS NULL AND t3.PMDPFID3 IS NOT NULL) OR (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NULL)  )))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID4)||'����'||TO_CHAR(t3.PMDSCALE4*100) ���ǰ,FGETPRICEFRAME(t2.PMDPFID4)||'����'||TO_CHAR(t2.PMDSCALE4*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE4 IS NOT NULL AND t3.PMDSCALE4 IS NOT NULL AND t2.PMDSCALE4 <> t3.PMDSCALE4) OR (t2.PMDSCALE4 IS NULL AND t3.PMDSCALE4 IS NOT NULL) OR (t2.PMDSCALE4 IS NOT NULL AND t3.PMDSCALE4 IS NULL)
OR (t2.PMDPFID4 IS NOT NULL AND t3.PMDPFID4 IS NOT NULL AND t2.PMDPFID4 <> t3.PMDPFID4) OR (t2.PMDPFID4 IS NULL AND t3.PMDPFID4 IS NOT NULL) OR (t2.PMDPFID4 IS NOT NULL AND t3.PMDPFID4 IS NULL)
 )))
union

--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.MIPFID) ���ǰ,FGETPRICEFRAME(t2.PMDPFID)||'����'||TO_CHAR(t2.PMDSCALE*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID IS NOT NULL )))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.MIPFID) ���ǰ,FGETPRICEFRAME(t2.PMDPFID2)||'����'||TO_CHAR(t2.PMDSCALE2*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID2 IS NOT NULL )))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.MIPFID) ���ǰ,FGETPRICEFRAME(t2.PMDPFID3)||'����'||TO_CHAR(t2.PMDSCALE3*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID3 IS NOT NULL )))
union
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.MIPFID) ���ǰ,FGETPRICEFRAME(t2.PMDPFID4)||'����'||TO_CHAR(t2.PMDSCALE4*100) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID4 IS NOT NULL )))
UNION
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID)||'����'||TO_CHAR(t3.PMDSCALE*100)  ���ǰ,FGETPRICEFRAME(t2.MIPFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID IS NOT NULL )))
 UNION
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID2)||'����'||TO_CHAR(t3.PMDSCALE2*100)  ���ǰ,FGETPRICEFRAME(t2.MIPFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID2 IS NOT NULL )))
UNION
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID3)||'����'||TO_CHAR(t3.PMDSCALE3*100)  ���ǰ,FGETPRICEFRAME(t2.MIPFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID3 IS NOT NULL )))
UNION
--��ˮ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��ˮ���'  �������,FGETPRICEFRAME(t3.PMDPFID4)||'����'||TO_CHAR(t3.PMDSCALE4*100)  ���ǰ,FGETPRICEFRAME(t2.MIPFID) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID4 IS NOT NULL )))
union
--�Ƿ�ſط�
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ƿ�ſط�'  �������,t3.MIIFCKF ���ǰ,t2.MIIFCKF �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFCKF IS NOT NULL AND t3.MIIFCKF IS NOT NULL AND t2.MIIFCKF <> t3.MIIFCKF) OR (t2.MIIFCKF IS NULL AND t3.MIIFCKF IS NOT NULL) OR (t2.MIIFCKF IS NOT NULL AND t3.MIIFCKF IS NULL)))
union
--GPS��ַ
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'GPS��ַ'  �������,t3.MIGPS ���ǰ,t2.MIGPS �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIGPS IS NOT NULL AND t3.MIGPS IS NOT NULL AND t2.MIGPS <> t3.MIGPS) OR (t2.MIGPS IS NULL AND t3.MIGPS IS NOT NULL) OR (t2.MIGPS IS NOT NULL AND t3.MIGPS IS NULL)))
union
--Ǧ���
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'Ǧ���'  �������,t3.MIQFH ���ǰ,t2.MIQFH �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIQFH IS NOT NULL AND t3.MIQFH IS NOT NULL AND t2.MIQFH <> t3.MIQFH) OR (t2.MIQFH IS NULL AND t3.MIQFH IS NOT NULL) OR (t2.MIQFH IS NOT NULL AND t3.MIQFH IS NULL)))
union
--�ַ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�ַ��'  �������,t3.dqgfh ���ǰ,t2.dqgfh �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqgfh  IS NOT NULL AND t3.dqgfh IS NOT NULL AND t2.dqgfh <> t3.dqgfh) OR (t2.dqgfh IS NULL AND t3.dqgfh IS NOT NULL) OR (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NULL)))
union
--�ܷ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�ܷ��'  �������,t3.dqsfh ���ǰ,t2.dqsfh �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqsfh  IS NOT NULL AND t3.dqsfh  IS NOT NULL AND t2.dqsfh <> t3.dqsfh) OR (t2.dqsfh IS NULL AND t3.dqsfh IS NOT NULL) OR (t2.dqsfh IS NOT NULL AND t3.dqsfh  IS NULL)))
union
--����շ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'����շ�� '  �������,t3.jcgfh ���ǰ,t2.jcgfh �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.jcgfh  IS NOT NULL AND t3.jcgfh IS NOT NULL AND t2.jcgfh <> t3.jcgfh) OR (t2.jcgfh IS NULL AND t3.jcgfh IS NOT NULL) OR (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NULL)))

union
--������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'������'  �������,t3.MIBOX ���ǰ,t2.MIBOX �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIBOX IS NOT NULL AND t3.MIBOX IS NOT NULL AND t2.MIBOX <> t3.MIBOX) OR (t2.MIBOX IS NULL AND t3.MIBOX IS NOT NULL) OR (t2.MIBOX IS NOT NULL AND t3.MIBOX IS NULL)))

union
--Ʊ������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'Ʊ������'  �������,t3.MINAME ���ǰ,t2.MINAME �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MINAME IS NOT NULL AND t3.MINAME IS NOT NULL AND t2.MINAME <> t3.MINAME) OR (t2.MINAME IS NULL AND t3.MINAME IS NOT NULL) OR (t2.MINAME IS NOT NULL AND t3.MINAME IS NULL)))
union
--�Ⳮ��ָ��ˮ��
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'�Ⳮ��ָ��ˮ��'  �������,to_char(t3.MICOLUMN5) ���ǰ,to_char(t2.MICOLUMN5) �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MICOLUMN5 IS NOT NULL AND t3.MICOLUMN5 IS NOT NULL AND t2.MICOLUMN5 <> t3.MICOLUMN5) OR (t2.MICOLUMN5 IS NULL AND t3.MICOLUMN5 IS NOT NULL) OR (t2.MICOLUMN5 IS NOT NULL AND t3.MICOLUMN5 IS NULL)))
union
--��������
(
select CCHNO �����ˮ��,CCHLB �������,CCHCREPER �Ǽ���Ա,CCHCREDATE �Ǽ�����,CCHSHPER �����Ա,CCHSHDATE �������,CCHSHFLAG ��˱�־,t3.MIID  ˮ����,t3.MICODE ���Ϻ�,t3.CIID    �û����,t3.CICODE  �û���,'��������'  �������,t3.MINAME2 ���ǰ,t2.MINAME2 �����
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MINAME2 IS NOT NULL AND t3.MINAME2 IS NOT NULL AND t2.MINAME2 <> t3.MINAME2) OR (t2.MINAME2 IS NULL AND t3.MINAME2 IS NOT NULL) OR (t2.MINAME2 IS NOT NULL AND t3.MINAME2 IS NULL)))
;


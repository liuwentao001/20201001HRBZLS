create or replace force view hrbzls.vie_�������_��ˮ������� as
select cmrdno  �����ˮ��,crhlb  �������,crhsmfid Ӫ����˾  ,crhcreper  �Ǽ���Ա,crhcredate  �Ǽ�����,crhshper  �����Ա,crhshdate  �������,crhshflag  ��˱�־,t2.MIID  ˮ����,t2.MICODE ���Ϻ�,t2.CIID    �û����,t2.CICODE  �û���,ciname �û���, ciadr �û���ַ,   '��ˮ���������������'  �������,'' ���ǰ,decode(t1.pamid,'01','�̶����۵���') �����,'N' ״̬
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.pamid IS NOT NULL )
and t2.crhlb='w'
---��������
---����ֵ
union
select cmrdno  �����ˮ��,crhlb  �������,crhsmfid Ӫ����˾,crhcreper  �Ǽ���Ա,crhcredate  �Ǽ�����,crhshper  �����Ա,crhshdate  �������,crhshflag  ��˱�־,t2.MIID  ˮ����,t2.MICODE ���Ϻ�,t2.CIID    �û����,t2.CICODE  �û���,ciname �û���, ciadr �û���ַ,'��ˮ�����������ֵ'  �������,'' ���ǰ,to_char(cmnewvalue) �����,'N' ״̬
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.cmnewvalue IS NOT NULL )
and t2.crhlb='w'
---ȡ����ˮ����
union
select cmrdno  �����ˮ��,crhlb  �������,crhsmfid Ӫ����˾,crhcreper  �Ǽ���Ա,crhcredate  �Ǽ�����,crhshper  �����Ա,crhshdate  �������,crhshflag  ��˱�־,t2.MIID  ˮ����,t2.MICODE ���Ϻ�,t2.CIID    �û����,t2.CICODE  �û���,ciname �û���, ciadr �û���ַ,'��ˮ�������ȡ����ˮ����'  �������,'' ���ǰ,decode(cmtype,'Y','��','N','��') �����,'Y' ״̬
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.cmtype IS NOT NULL )
and t2.crhlb='w'
;


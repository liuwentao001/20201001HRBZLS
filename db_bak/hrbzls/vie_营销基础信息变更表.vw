create or replace force view hrbzls.vie_Ӫ��������Ϣ����� as
select ��ˮ����,decode(�������,'17','�����','22','�ܱ�����','U','ˮ��װ','w','��ˮ����') �������,Ӫ����˾,��������,������,�������,�����,��˱�־
from
(select CCHNO ��ˮ����,CCHLB �������,CISMFID Ӫ����˾,CCHCREDATE ��������,CCHCREPER ������
,CCHSHDATE �������,CCHSHPER �����,CCHSHFLAG ��˱�־
from CUSTCHANGEDT,CUSTCHANGEhd where cchlb in ('17','22','U') and CCDNO=CCHNO
union
select CRHNO ��ˮ����,CRHLB �������,CRHSMFID Ӫ����˾,crhcredate ��������,crhcreper ������Ա
,crhshdate �������,crhshper  �����Ա,crhshflag ��˱�־
  from TDSJhd where CRHLB='w');


create or replace force view hrbzls.view_meterread_small as
select
       rank() over(partition by a.mrcid order by  a.mrrdate) mrow,--���
       a.mrid ,--��ˮ��
       a.mrmonth ,--�����·�
       a.mrbfid ,--���
       a.mrcid ,--�û����
       a.mrrdate ,--��������
       a.mrprdate ,--�ϴγ�������
       a.mrscode ,--���ڳ���
       a.mrecode  ,--���ڳ���
       a.mrsl --����ˮ��
       from view_meterreadall a
       where nvl(mrdatasource,1) not in ('M','Z')
       order by a.mrcid --,a.mrid
;


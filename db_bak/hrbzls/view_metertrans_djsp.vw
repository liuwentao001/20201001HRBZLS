create or replace force view hrbzls.view_metertrans_djsp as
select mthno ������ˮ��,
       mtdrowno �к�,
       mthshflag ��˱�־ ,
       mthshdate ������� ,
       mthshper �����Ա ,
       mthlb �������,
       mthcredate ��������,
       mthcreper ������,
       mtdmcode �ͻ����� ,
       mtdsentper �ɹ���Ա ,
       mtdsentdate �ɹ�ʱ�� ,
       mtduninsper ���Ա ,
       mtduninsdate ������� ,
       mtdshper �깤��Ա ,
       mtdshdate �깤���� ,
       mtdscode ���ڶ��� ,
       mtdecode ������ ,
       mtdaddsl ���� ,
       mtdreinscode �±����� ,
       mtdappnote ����˵��
from metertranshd,metertransdt
where mthno =mtdno and mthshflag='N';


CREATE OR REPLACE FORCE VIEW HRBZLS.V_ˮ�����ʸ����� AS
select
--����ˮ����ͳ�Ƶ��¹��ϱ������������Դ
  A.Ӫ����˾,
  A.�·�,
  sum(DECODE(A.����,'����������ˮ',����,0)) ����������ˮ,
  sum(DECODE(A.����,'����ҵ��������',����,0)) ����ҵ��������,
  sum(DECODE(A.����,'�̷�',����,0)) �̷�,
  sum(DECODE(A.����,'���ݲ���ҵ',����,0)) ���ݲ���ҵ,
  sum(DECODE(A.����,'��ҵ',����,0)) ��ҵ,
  sum(DECODE(A.����,'�ߵ�ϴԡ',����,0)) �ߵ�ϴԡ,
   ��˱�־
from
(
SELECT MTDSMFID Ӫ����˾,
       TO_CHAR(MT.MTDSHDATE,'YYYY.MM') �·�,
       fgetpricename(substr(mi.mipfid,1,1)) ����,
       count(mt.MTDNO)  ����,
       MTHSHFLAG ��˱�־
 FROM METERTRANSHD md,METERTRANSDT mt,METERINFO MI
 where md.MTHNO=mt.MTDNO
 and md.MTHLB='K'
 --AND MT.MTDFLAG='Y'  // by 20141030 ȥ����˱�־ ��ΰ
 AND MT.MTDMID=MI.MIID
 GROUP BY MTDSMFID,TO_CHAR(MT.MTDSHDATE,'YYYY.MM'), fgetpricename(substr(mi.mipfid,1,1)),MTHSHFLAG
 ) A
 GROUP BY Ӫ����˾,�·�,��˱�־
 ORDER BY Ӫ����˾,�·�
;


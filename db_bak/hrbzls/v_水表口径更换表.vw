CREATE OR REPLACE FORCE VIEW HRBZLS.V_ˮ��ھ������� AS
select
--����ˮ�ھ�ͳ�Ƶ��¹��ϱ������������Դ
  A.Ӫ����˾,
  A.�·�,
  sum(DECODE(A.�ھ�,0,����,0))  x0,
  sum(DECODE(A.�ھ�,13,����,0)) x13,
  sum(DECODE(A.�ھ�,15,����,0)) x15,
  sum(DECODE(A.�ھ�,20,����,0)) x20,
  sum(DECODE(A.�ھ�,25,����,0)) x25,
  sum(DECODE(A.�ھ�,32,����,0)) x32,
  sum(DECODE(A.�ھ�,40,����,0)) x40,
  sum(DECODE(A.�ھ�,50,����,0)) x50,
  sum(DECODE(A.�ھ�,65,����,0)) x65,
  sum(DECODE(A.�ھ�,80,����,0)) x80,
  sum(DECODE(A.�ھ�,100,����,0)) x100,
  sum(DECODE(A.�ھ�,150,����,0)) x150,
  sum(DECODE(A.�ھ�,200,����,0)) x200,
  sum(DECODE(A.�ھ�,300,����,0)) x300,
  sum(DECODE(A.�ھ�,700,����,0)) x700,
  sum(DECODE(sign(A.�ھ�-700),1,����,0)) ����
from
(
SELECT MTDSMFID Ӫ����˾,
       TO_CHAR(MT.MTDSHDATE,'YYYY.MM') �·�,
      case
         when mt.MTDCALIBERO in (0,13,15,20,25,32,40,50,65,80,100,150,200,300,700)
           then mt.MTDCALIBERO
          else 999
        end  �ھ�,
       count(mt.MTDNO)  ����
 FROM METERTRANSHD md,METERTRANSDT mt
 where md.MTHNO=mt.MTDNO
 and md.MTHLB='K'
 AND MT.MTDFLAG='Y'
 GROUP BY mt.MTDSMFID,TO_CHAR(MT.MTDSHDATE,'YYYY.MM'), mt.MTDCALIBERO
 ) A
 GROUP BY Ӫ����˾,�·�
 ORDER BY Ӫ����˾,�·�
;


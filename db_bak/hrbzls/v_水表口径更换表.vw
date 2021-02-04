CREATE OR REPLACE FORCE VIEW HRBZLS.V_水表口径更换表 AS
select
--按用水口径统计当月故障表更换的数据来源
  A.营销公司,
  A.月份,
  sum(DECODE(A.口径,0,表数,0))  x0,
  sum(DECODE(A.口径,13,表数,0)) x13,
  sum(DECODE(A.口径,15,表数,0)) x15,
  sum(DECODE(A.口径,20,表数,0)) x20,
  sum(DECODE(A.口径,25,表数,0)) x25,
  sum(DECODE(A.口径,32,表数,0)) x32,
  sum(DECODE(A.口径,40,表数,0)) x40,
  sum(DECODE(A.口径,50,表数,0)) x50,
  sum(DECODE(A.口径,65,表数,0)) x65,
  sum(DECODE(A.口径,80,表数,0)) x80,
  sum(DECODE(A.口径,100,表数,0)) x100,
  sum(DECODE(A.口径,150,表数,0)) x150,
  sum(DECODE(A.口径,200,表数,0)) x200,
  sum(DECODE(A.口径,300,表数,0)) x300,
  sum(DECODE(A.口径,700,表数,0)) x700,
  sum(DECODE(sign(A.口径-700),1,表数,0)) 其他
from
(
SELECT MTDSMFID 营销公司,
       TO_CHAR(MT.MTDSHDATE,'YYYY.MM') 月份,
      case
         when mt.MTDCALIBERO in (0,13,15,20,25,32,40,50,65,80,100,150,200,300,700)
           then mt.MTDCALIBERO
          else 999
        end  口径,
       count(mt.MTDNO)  表数
 FROM METERTRANSHD md,METERTRANSDT mt
 where md.MTHNO=mt.MTDNO
 and md.MTHLB='K'
 AND MT.MTDFLAG='Y'
 GROUP BY mt.MTDSMFID,TO_CHAR(MT.MTDSHDATE,'YYYY.MM'), mt.MTDCALIBERO
 ) A
 GROUP BY 营销公司,月份
 ORDER BY 营销公司,月份
;


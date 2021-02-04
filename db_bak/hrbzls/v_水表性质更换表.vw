CREATE OR REPLACE FORCE VIEW HRBZLS.V_水表性质更换表 AS
select
--按用水性质统计当月故障表更换的数据来源
  A.营销公司,
  A.月份,
  sum(DECODE(A.性质,'居民生活用水',表数,0)) 居民生活用水,
  sum(DECODE(A.性质,'企事业机关团体',表数,0)) 企事业机关团体,
  sum(DECODE(A.性质,'商服',表数,0)) 商服,
  sum(DECODE(A.性质,'宾馆餐饮业',表数,0)) 宾馆餐饮业,
  sum(DECODE(A.性质,'特业',表数,0)) 特业,
  sum(DECODE(A.性质,'高档洗浴',表数,0)) 高档洗浴,
   审核标志
from
(
SELECT MTDSMFID 营销公司,
       TO_CHAR(MT.MTDSHDATE,'YYYY.MM') 月份,
       fgetpricename(substr(mi.mipfid,1,1)) 性质,
       count(mt.MTDNO)  表数,
       MTHSHFLAG 审核标志
 FROM METERTRANSHD md,METERTRANSDT mt,METERINFO MI
 where md.MTHNO=mt.MTDNO
 and md.MTHLB='K'
 --AND MT.MTDFLAG='Y'  // by 20141030 去掉审核标志 王伟
 AND MT.MTDMID=MI.MIID
 GROUP BY MTDSMFID,TO_CHAR(MT.MTDSHDATE,'YYYY.MM'), fgetpricename(substr(mi.mipfid,1,1)),MTHSHFLAG
 ) A
 GROUP BY 营销公司,月份,审核标志
 ORDER BY 营销公司,月份
;


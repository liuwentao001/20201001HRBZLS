create or replace force view hrbzls.v_水表性质统计表 as
select
--按用水性质统计水表只数报表的数据来源
  A.营销公司,
  sum(DECODE(A.性质,'居民生活用水',表数,0)) 居民生活用水,
  sum(DECODE(A.性质,'企事业机关团体',表数,0)) 企事业机关团体,
  sum(DECODE(A.性质,'商服',表数,0)) 商服,
  sum(DECODE(A.性质,'宾馆餐饮业',表数,0)) 宾馆餐饮业,
  sum(DECODE(A.性质,'特业',表数,0)) 特业,
  sum(DECODE(A.性质,'高档洗浴',表数,0)) 高档洗浴

from
(select
MISMFID 营销公司,
fgetpricename(substr(mi.mipfid,1,1)) 性质,
s.smsname 状况,
sum(decode(miid,mi.mipriid,1,0)) hs,
count(mi.miid) 表数
from meterinfo mi,sysmeterstatus s
where mi.mistatus=s.smsid(+)
and mi.mistatus not in ('28','31','32','7','34'，'33')
--and mi.mistatus ='1'   --正常抄表
group by mi.MISMFID,fgetpricename(substr(mi.mipfid,1,1)),s.smsname
) A

group by 营销公司
order by 营销公司
;


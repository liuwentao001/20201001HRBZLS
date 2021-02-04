create or replace force view hrbzls.view_出账率 as
select t.mismfid 营销公司,
       bfrper 抄表员,
       dh 代号,
       mibfid 表册,
       mipfid 价格类别,mmonth 抄表月份  ,lb 类别,
       sum(nvl(jhbs,0)+nvl(hbbs,0)) 抄表计划总件数,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0) else 0 end) 计算件数,
       sum(case when mipfid not in ('A06','C13') then nvl(czbs,0) else 0 end) 出账,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0)-nvl(czbs,0) else 0 end) 未出账,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0) else 0 end) 车库抄表计划,
       sum(case when mipfid  in ('A06','C13') then nvl(czbs,0) else 0 end) 车库出账,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0)-nvl(czbs,0) else 0 end) 车库未出账,
       sum(nvl(ylhbs,0)) 预立户,
       michargetype 收费方式
from 抄表情况统计_hrb t
group by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,mmonth ,lb,michargetype
order by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,mmonth ,lb;


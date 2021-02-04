create or replace force view hrbzls.view_检表率 as
select t.mismfid 营销公司,
       bfrper 抄表员 ,
       dh 代号 ,
       mibfid 表册 ,
       mipfid 价格类别 ,
       mmonth 抄表月份 ,
       lb  类别,
       sum(nvl(jhbs,0)) 抄表计划总件数,
       --sum(nvl(hbbs,0)) 换表件数,
       sum(case when mipfid not in ('A06','C13') then nvl(hbbs,0) else 0 end) 换表件数,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0) else 0 end) 计算件数,
       sum(case when mipfid not in ('A06','C13') then nvl(tscbs,0) else 0 end)+ sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  else 0 end) 指针同上次,
       sum(case when mipfid not in ('A06','C13') then nvl(cqwrbs,0) else 0 end) 长期无人,
       sum(case when mipfid not in ('A06','C13') then nvl(tybs,0) else 0 end) 停业,
       sum(case when mipfid not in ('A06','C13') then nvl(bxbs,0) else 0 end) 闭栓,
       sum(case when mipfid not in ('A06','C13') then nvl(bysbs,0) else 0 end) 不用水,
        --sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  ELSE 0 END )
        0 非正常数据, --by ralph  暂时定义为0 将数据加到指针同上 20150206
         sum(case when mipfid not in ('A06','C13') then case when MMONTH>='2015.03' then nvl(cjbs,0) else nvl(czbs,0) end else 0 end) 正常数据,--(增加一个抄见未出账的数据列)
       --sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  else 0 end) 非正常数据,--20140910 添加非正常 及其它数据
       sum(case when mipfid not in ('A06','C13') then nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0)  else 0 end) 小计,
       sum(case when mipfid not in ('A06','C13') then nvl(hbbs,0) else 0 end) 换表,

       sum(case when mipfid not in ('A06','C13') then nvl(czbs,0) else 0 end) 出账,

       sum(case when mipfid not in ('A06','C13') then case when MMONTH>='2015.03'  then nvl(cjbs,0) + nvl(hbbs,0)+nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0) else nvl(cjbs,0)+nvl(hbbs,0)  end else 0 end) 检表,
       sum(case when mipfid not in ('A06','C13') then nvl(wcjbs,0) else 0 end) 未检表,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0) else 0 end) 车库抄表计划,
       sum(case when mipfid  in ('A06','C13') then case when MMONTH>='2015.03'  then nvl(cjbs,0)+nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0) else nvl(cjbs,0) end  else 0 end) 车库检表,
       sum(case when mipfid  in ('A06','C13') then nvl(wcjbs,0) else 0 end) 车库未检表,
       sum(nvl(ylhbs,0)) 预立户,
       michargetype 收费方式
from 抄表情况统计_hrb t
group by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,
       mmonth,
       lb,michargetype
order by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,
       mmonth,
       lb
;


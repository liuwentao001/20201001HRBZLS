create or replace force view hrbzls.view_应收查询 as
select rlmonth,--欠费月份
       rldate,--算费日期
       trunc(rlday) rlday,--抄表日期
       rl.rlscode,--上月行度
       rl.rlecode,--本月行度
       rlsl,--水量
       rd.dj,--单价
       rd.charge1,--水费
       rd.charge2,--污水处理费
       rd.charge3,--水资源费
       rd.chargetotal,--合计水费
       rl.rltrans,--应收事务
       mi.micode,--用户编号
       mi.mipriid,--主表号
       mi.mistatus,--水表状态
       rlpfid,--用户类别
       md.mdno,--表身码
       rlpaidflag--销账标志

from reclist rl,view_reclist_charge rd,meterinfo mi,meterdoc md
where rl.rlid=rd.rdid
      and rlmid=miid
      and mi.miid=md.mdmid
      --and rl.rlpaidflag='N'
      and rl.rlreverseflag='N'
      and rl.rlbadflag='N'
      and rlje>0
      and rltrans not in (lower('u'), lower('v'), '13', '14', '21','23')
order by   rlday desc,miid,mdno
;


create or replace force view hrbzls.view_breclist as
select ci.ciid 用户编号,
       ci.ciname 用户名称,
       ci.cismfid 区域代码,
       FGETPRICENAME(rl.RLPFID) 用水分类,
       FGETSYSMANAFRAME(mi.mismfid) 所属供水公司,
       rl.rlmonth 账务月份,
       rl.rlscode 起数,
       rl.rlecode 止数,
       rl.rlreadsl 抄见水量
  from custinfo ci, meterinfo mi, reclist rl
 where ci.ciid = mi.micid
   and (mi.mipfid like 'B%' or mi.mipfid like 'C%' or mi.mipfid like 'D%' or mi.mipfid like 'E%' or mi.mipfid like 'F%')
   and mistatus <> 7
   and rl.rlmid = mi.micid
   and rl.rlreverseflag = 'N';


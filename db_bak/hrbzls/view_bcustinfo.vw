create or replace force view hrbzls.view_bcustinfo as
select ci.ciid 用户编号,
       ci.ciname 用户名称,
       ci.ciadr 用户地址,
       ci.cismfid 区域代码,
       FGETPRICENAME(mi.mipfid) 用水分类,
       FGETSYSMANAFRAME(mi.mismfid) 所属供水公司
  from custinfo ci, meterinfo mi
 where ci.ciid = mi.micid
   and (mi.mipfid like 'B%' or mi.mipfid like 'C%' or mi.mipfid like 'D%' or mi.mipfid like 'E%' or mi.mipfid like 'F%')
   and mi.mistatus <> 7
   and mipriid = miid;


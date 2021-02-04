create or replace force view hrbzls.view_bcustinfo as
select ci.ciid �û����,
       ci.ciname �û�����,
       ci.ciadr �û���ַ,
       ci.cismfid �������,
       FGETPRICENAME(mi.mipfid) ��ˮ����,
       FGETSYSMANAFRAME(mi.mismfid) ������ˮ��˾
  from custinfo ci, meterinfo mi
 where ci.ciid = mi.micid
   and (mi.mipfid like 'B%' or mi.mipfid like 'C%' or mi.mipfid like 'D%' or mi.mipfid like 'E%' or mi.mipfid like 'F%')
   and mi.mistatus <> 7
   and mipriid = miid;


create or replace force view hrbzls.v_用户数统计 as
select mismfid,substr(mibfid,1,5)dh,mipfid,mi.michargetype,mistatus,
       sum(decode(miid,mi.mipriid,1,0)) hs,
       count(*) bs
from meterinfo mi
where  mi.mistatus not in ('28','31','32','7','34'，'33')
group by mismfid,substr(mibfid,1,5),mipfid,mi.michargetype,mistatus;


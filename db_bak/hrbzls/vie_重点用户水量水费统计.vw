create or replace force view hrbzls.vie_重点用户水量水费统计 as
select
IMPORTANT_USER_INFOID 重点用户号,
AREA_ID  营业公司,
USER_NAME 重点用户名,
MICID 用户编号,
important_user_info.type 用水类型,
RLMONTH 调查年月,
wateruse 水量,
charge1 水费,
charge3 附加费,
charge2 污水费,
chargetotal 合计,

ciname 用户名称,
CIADR 用户地址
from important_user_info,
RECLIST,
view_reclist_charge_01 rd,
meterinfo,
custinfo
where important_user_info.important_user_infoid=meterinfo.MIIFZDH
and meterinfo.miid=RECLIST.RLMID
and rd.RDID=RECLIST.RLID
and custinfo.ciid=meterinfo.miid
--group by IMPORTANT_USER_INFOID,AREA_ID,USER_NAME,MICID,MISMFID,ciname,important_user_info.type,RLMONTH,CIADR
order by IMPORTANT_USER_INFOID,MISMFID,MICID,RLMONTH
;


create or replace force view hrbzls.vie_�ص��û�ˮ��ˮ��ͳ�� as
select
IMPORTANT_USER_INFOID �ص��û���,
AREA_ID  Ӫҵ��˾,
USER_NAME �ص��û���,
MICID �û����,
important_user_info.type ��ˮ����,
RLMONTH ��������,
wateruse ˮ��,
charge1 ˮ��,
charge3 ���ӷ�,
charge2 ��ˮ��,
chargetotal �ϼ�,

ciname �û�����,
CIADR �û���ַ
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


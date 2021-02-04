create or replace force view hrbzls.vie_重点用户信息 as
select
IMPORTANT_USER_INFOID 重点用户号,
trim(AREA_ID)  营业公司,
USER_NAME 重点用户名,
ADDRESS 地址,
PROJECT_UID 立项编号,
(select SPTITLE from syspara  where SPDATATYPE ='ZDYH' and important_user_info.type=syspara.spvalue ) 用水类型,
CONTACT 联系人,
TEL 联系电话,
DESCRIPTION 描述,
FLAG 有效标志,
CRT_MAN 创建人,
CRT_DATE   创建时间,
MAIN_MAN 审核人,
MAIN_DATE 审核时间
from important_user_info;


create or replace force view hrbzls.vie_�ص��û���Ϣ as
select
IMPORTANT_USER_INFOID �ص��û���,
trim(AREA_ID)  Ӫҵ��˾,
USER_NAME �ص��û���,
ADDRESS ��ַ,
PROJECT_UID ������,
(select SPTITLE from syspara  where SPDATATYPE ='ZDYH' and important_user_info.type=syspara.spvalue ) ��ˮ����,
CONTACT ��ϵ��,
TEL ��ϵ�绰,
DESCRIPTION ����,
FLAG ��Ч��־,
CRT_MAN ������,
CRT_DATE   ����ʱ��,
MAIN_MAN �����,
MAIN_DATE ���ʱ��
from important_user_info;


create or replace force view hrbzls.view_sysfaceunion_forpda_e as
select "SFTYPE","SFLID","SFLNAME" from (
select '4����ʩ˵��' sftype,
       sflid,
       sflname
from sysfacelist4
union all
select '1��������' sftype,
       sflid,
       sflname
from sysfacelist2
union all
select '2ˮ�����' sftype,
       mfid,
       mfname
from meterface
union all
select '3�ǳ�����' sftype,
       sflid,
       sflname
from sysfacelist3)
order by sftype,to_number(sflid);


create or replace force view hrbzls.view_sysfaceunion_forpda_e as
select "SFTYPE","SFLID","SFLNAME" from (
select '4表井设施说明' sftype,
       sflid,
       sflname
from sysfacelist4
union all
select '1抄见故障' sftype,
       sflid,
       sflname
from sysfacelist2
union all
select '2水表故障' sftype,
       mfid,
       mfname
from meterface
union all
select '3非常计量' sftype,
       sflid,
       sflname
from sysfacelist3)
order by sftype,to_number(sflid);


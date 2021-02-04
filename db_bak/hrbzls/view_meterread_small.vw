create or replace force view hrbzls.view_meterread_small as
select
       rank() over(partition by a.mrcid order by  a.mrrdate) mrow,--序号
       a.mrid ,--流水号
       a.mrmonth ,--抄表月份
       a.mrbfid ,--表册
       a.mrcid ,--用户编号
       a.mrrdate ,--抄表日期
       a.mrprdate ,--上次抄见日期
       a.mrscode ,--上期抄见
       a.mrecode  ,--本期抄见
       a.mrsl --本期水量
       from view_meterreadall a
       where nvl(mrdatasource,1) not in ('M','Z')
       order by a.mrcid --,a.mrid
;


CREATE OR REPLACE PROCEDURE HRBZLS."SP_EZ_DATEMOVEJOB" is
  --求总户数



begin
null;
 /* ez_datamove.基础数据;
  commit;
--数据迁移 --7分钟(849秒)
ez_datamove.合并应实收(to_date('20070101','yyyymmdd'),to_date('20110901','yyyymmdd'));
 commit;
--数据迁移 --180分钟(12650秒)
ez_datamove.添加应实收帐( '', ''  );
  commit;

  --补应补合并应实收
  DELETE EZ.补合并应实收 ;
insert into EZ.补合并应实收
select * from EZ.tarrearage t where t."yearmonth" <'200801' ;
--补合并应实收明细
DELETE EZ.补合并应实收明细;
insert into EZ.补合并应实收明细
select t.* from EZ.tarrearage1 t,EZ.补合并应实收 t1 where t."ID"=t1."id" ;
COMMIT;
--补添加应实收帐
 ez_datamove.补添加应实收帐( '', ''  );
COMMIT;

--迁移预存 --5分钟(259秒)
 ez_datamove.插入预存(to_date('20010101','yyyymmdd'),to_date('20120101','yyyymmdd'));
  commit;
--发票信息 --15分钟(259秒)
ez_datamove.插入发票信息(to_date('20010101','yyyymmdd'),to_date('20120101','yyyymmdd'));
 commit;*/

end;
/


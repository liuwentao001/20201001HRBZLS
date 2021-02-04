create or replace force view hrbzls.vie_呆坏账信息查询 as
select rlid 流水单号,
rlmonth  账务日期,
rlsmfid 营销公司,
rlmid 用户号,
rlcname 用户名,
rlcadr 用户地址,
rlscode 起始指数,
rlecode 截止指数,
rlsl 水量,
rlje 金额,
charge1 金额1,
charge2 金额2，
charge3 金额3
from rpt_dhz;


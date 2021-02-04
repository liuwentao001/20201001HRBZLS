create or replace force view hrbzls.view_缴费查询 as
select pbatch,--缴费交易批次
       ppriid,--合收主表号
       max(pdate) pdate,--收费日期
       sum(pm.ppayment) ppayment,--付款金额
       sum(pm.psavingbq) psavingbq,--本期发生预存金额
       sum(pspje) pspje,--销帐金额（如果销帐交易中水费，销帐金额则为水费金额，如果是预存帐为0）
       FGETSYSMANAFRAME(max(pposition)) pposition, --缴费机构（营业所或银行）
       FGETOPERNAME(max(pper)) pper, --销帐人员
       decode(max(ptrans),'B','银行','柜台') ptrans--缴费事务
from payment pm
where preverseflag='N'
      and (pposition like '02%' or pposition like '03%')
      --and ppriid='3124089728'
group by pbatch,ppriid
having sum(pm.ppayment)<>0
order by pdate desc
;


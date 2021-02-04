CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PAYMENT_DZ AS
select /*"分公司营业所",*/"用户编号","合收主表号","缴费月份","发生日期","缴费机构","收费员",/*"期初预存余额","本期发生预存金额","期末预存余额",*/"付款金额","交易流水","付款方式","缴费交易批次" ,"微信交易流水","微信申请日期","老户号"from (
SELECT --FGETSMFNAME(MAX(MI.MISMFID)) 分公司营业所,
       /*MAX(MI.miid)*/pmid 用户编号,
       PPRIID 合收主表号,
       PMONTH 缴费月份,
       /*to_char((PM.PDATETIME),'yyyy-mm-dd hh24:mi:ss')*/pdate 发生日期,
       (FGETSYSMANAFRAME(PM.PPOSITION) ) 缴费机构,
       /*FGETPSAVING(PM.PBATCH, 'QC') 期初预存余额,
       SUM(PM.PSAVINGBQ) 本期发生预存金额,
       FGETPSAVING(PM.PBATCH, 'QM') 期末预存余额,*/
       (PM.PPAYMENT) 付款金额,
       (pbseqno) 交易流水,
       (decode(TRIM(PM.PPAYWAY), 'XJ','现金','DC','倒存','ZP','支票','MZ','抹帐') ) 付款方式,
       PM.PBATCH 缴费交易批次,
       pm.pper 收费员,
       (pwseqno) 微信交易流水,
       pwdate 微信申请日期,
       MIREMOTEHUBNO 老户号
  FROM PAYMENT PM, METERINFO MI
 WHERE PM.PMID = MI.MIID
   --AND PM.PPAYMENT<>0
  -- AND PM.PREVERSEFLAG = 'N'
--and  MI.MIID ='7023346322'
 /*GROUP BY PM.PBATCH,ptrans
 having  SUM(PM.PPAYMENT) > 0
 order by 发生日期 desc )
 where ROWNUM <= 5;*/
 and PPAYMENT>0
） order by  发生日期
;


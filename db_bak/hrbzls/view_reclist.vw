CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_RECLIST AS
SELECT RLCID 客户代码,
       FGETSMFNAME(RLSMFID) 分公司营业所,
       --RLID,
       RLBFID 帐卡号,
       RLMONTH 帐务月份,
       RLDATE 帐务日期,
       RLSL 应收水量,
       RLJE 应收金额,
       RLSCODECHAR 上次表针,
       RLECODECHAR 本次表针,
       CASE
         WHEN MIN(RDPIID) = '01' THEN
          max(case
                when RDPIID = '01' then
                 RDDJ
                else
                 0
              end) + SUM(case
                           when RDPIID = '01' then
                            0
                           else
                            RDDJ
                         end)
         ELSE
          0
       END 单价,
       SUM(case
             when RDPIID = '01' then
              RDJE
             else
              0
           end) 水费,
       SUM(case
             when RDPIID = '02' then
              RDJE
             else
              0
           end) 污水费,
       SUM(case
             when RDPIID = '03' then
              RDJE
             else
              0
           end) 附加费,
       MAX(DECODE(RDCLASS, '1', RDYSDJ, 0)) 一阶水费单价,
       MAX(DECODE(RDCLASS, '2', RDYSDJ, 0)) 二阶水费单价,
       MAX(DECODE(RDCLASS, '3', RDYSDJ, 0)) 三阶水费单价,
       sum(DECODE(RDCLASS, '1', RDYSSL, 0)) 一阶水量,
       sum(DECODE(RDCLASS, '2', RDYSSL, 0)) 二阶水量,
       sum(DECODE(RDCLASS, '3', RDYSSL, 0)) 三阶水量,
       sum(DECODE(RDCLASS, '1', RDYSJE, 0)) 一阶金额,
       sum(DECODE(RDCLASS, '2', RDYSJE, 0)) 二阶金额,
       sum(DECODE(RDCLASS, '3', RDYSJE, 0)) 三阶金额,
       RLPAIDDATE 销账日期 --,
-- max(RLCOLUMN12) RLCOLUMN12,
--decode(max(RLSCRRLMONTH),max(RLJTSRQ),substr(max(RLJTSRQ),1,4) - 1 ,substr(max(RLJTSRQ),1,4) ) jtyear
  FROM RECLIST, view_recdetailall
 WHERE  RLID = RDID
   and RLREVERSEFLAG = 'N'
   and not exists (select 1
          from meterread mr
         where mr.mrid = rlmrid
           and MRDZFLAG = 'Y'
           and MRSL = 0)
   and not exists (select 1
          from meterreadhis mrh
         where mrh.mrid = rlmrid
           and MRDZFLAG = 'Y'
           and MRSL = 0)
 GROUP BY RLSMFID,
          RLID,
          RLMONTH,
          RLDATE,
          RLcid,
          RLTRANS,
          RLRDATE,
          RLZNDATE,
          RLPAIDFLAG,
          RLCD,
          RLSL,
          RLJE,
          RLPAIDJE,
          RLSCODECHAR,
          RLECODECHAR,
          RLBFID,
          RLRPER,
          RLOUTFLAG,
          rlcolumn5,
          RLPAIDDATE,
          RLENTRUSTBATCH,
          RLENTRUSTSEQNO,
          rlcolumn9,
          RLUSENUM
 order by RLrDATE desc
;


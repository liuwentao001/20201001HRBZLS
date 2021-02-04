CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_RECLIST AS
SELECT RLCID �ͻ�����,
       FGETSMFNAME(RLSMFID) �ֹ�˾Ӫҵ��,
       --RLID,
       RLBFID �ʿ���,
       RLMONTH �����·�,
       RLDATE ��������,
       RLSL Ӧ��ˮ��,
       RLJE Ӧ�ս��,
       RLSCODECHAR �ϴα���,
       RLECODECHAR ���α���,
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
       END ����,
       SUM(case
             when RDPIID = '01' then
              RDJE
             else
              0
           end) ˮ��,
       SUM(case
             when RDPIID = '02' then
              RDJE
             else
              0
           end) ��ˮ��,
       SUM(case
             when RDPIID = '03' then
              RDJE
             else
              0
           end) ���ӷ�,
       MAX(DECODE(RDCLASS, '1', RDYSDJ, 0)) һ��ˮ�ѵ���,
       MAX(DECODE(RDCLASS, '2', RDYSDJ, 0)) ����ˮ�ѵ���,
       MAX(DECODE(RDCLASS, '3', RDYSDJ, 0)) ����ˮ�ѵ���,
       sum(DECODE(RDCLASS, '1', RDYSSL, 0)) һ��ˮ��,
       sum(DECODE(RDCLASS, '2', RDYSSL, 0)) ����ˮ��,
       sum(DECODE(RDCLASS, '3', RDYSSL, 0)) ����ˮ��,
       sum(DECODE(RDCLASS, '1', RDYSJE, 0)) һ�׽��,
       sum(DECODE(RDCLASS, '2', RDYSJE, 0)) ���׽��,
       sum(DECODE(RDCLASS, '3', RDYSJE, 0)) ���׽��,
       RLPAIDDATE �������� --,
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


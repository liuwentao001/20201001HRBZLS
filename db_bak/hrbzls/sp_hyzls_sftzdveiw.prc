CREATE OR REPLACE PROCEDURE HRBZLS."SP_HYZLS_SFTZDVEIW" (
                  o_base out tools.out_base) is
  begin
    open o_base for
        select
          rlid,
          fgetopername(MICPER)||'['||MICPER||']'    催费员 ,                   -- rlmonth,
          rlmid,
          to_char(sysdate,'YY') 年, to_char(sysdate,'MM') 月, to_char(sysdate,'DD') 日,
          mibfid 台区号,RLCADR 用户地址,
          rlmcode 户号,rlcname 户名,rlprdate 上期抄表时间,rlrdate 本期抄表时间,
          rlscode 上期表码,rlecode 本期抄码,rlsl 本期水量,rlje 本期水费,
          tools.fformatnum ( (rlje - rlpaidje) ,2) 本期欠费,
          '正常' 水表状态,
          tools.fformatnum ((select tools.fformatnum (nvl(sum(pddj),0),2) from pricedetail  where pdpscid=0 and pdmethod='dj1' and pdpfid=RLPFID),2) 综合水价,
          ''  陈欠水费,
          tools.fformatnum (0,2) 违约金,
          tools.fformatnum (misaving,2)   预存余额,
          tools.fformatnum (rlje  ,2) 应缴水费,
          fgetopername(RLRPER) 抄表员,
          --||'['||RLRPER||']'
          '应缴' 应缴,
           '' 欠费次数,
          '' 明细,
          c2
           from reclist t,meterinfo t1,PBPARMTEMP   where
           rlpaidflag in ('Y','N','V','K','T','W')
           and rlid =trim(c1)
           AND RLCD='DE'
           and miid=rlmid
           order by c3
          ;
end;
/


create or replace procedure hrbzls.sp_欠费中间表 is
begin
  delete from 欠费中间表;
  commit;
  insert into 欠费中间表
    select RLSMFID,
           RLMONTH,
           sum(rlsl),
           sum(rlje),
           MICHARGETYPE,
           RLREVERSEFLAG,
           RLBADFLAG,
           RLTRANS,
           RLPFID,
           sum(charg1),
           sum(charg2),
           sum(charg3),
           SUM(MI.MISAVING)
      from reclist rl,
           meterinfo mi,
           (select RDID,
/*                   sum(DECODE(RDPIID, '01', RDYSJe,0)) charg1,
                   sum(DECODE(RDPIID, '02', RDYSJE,0)) charg2,
                   sum(DECODE(RDPIID, '03', RDYSJE,0)) charg3*/ 
                    sum(DECODE(RDPIID, '01', RDJe,0)) charg1,
                   sum(DECODE(RDPIID, '02', RDJE,0)) charg2,
                   sum(DECODE(RDPIID, '03', RDJE,0)) charg3
              from RECDETAIL
             group by RDID) rd
     where rl.rlid = rd.rdid
       and RLPAIDFLAG = 'N'
       and RLJE <> 0
       AND mi.miid = rl.rlcid  and  RL.rltrans not in (lower( 'u'), lower('v'), '13', '14', '21','23')
       and RLREVERSEFLAG = 'N'
     group by RLMONTH,
              MICHARGETYPE,
              RLREVERSEFLAG,
              RLTRANS,
              RLPFID,
              RLSMFID,
              RLBADFLAG;
  commit;
end sp_欠费中间表;
/

